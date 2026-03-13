<#
.SYNOPSIS
    Pester-тести для security.ps1 — UAC, паролі, облікові записи, криптографія
.NOTES
    Тести виконують Apply → Check → Revert для кожного налаштування.
    Вимоги: права адміністратора, Pester 5+
#>

#Requires -RunAsAdministrator
BeforeAll {
    . "$PSScriptRoot\..\core\helpers.ps1"
    $settings = & "$PSScriptRoot\..\settings\security.ps1"
}

Describe "security.ps1 — UAC / Вхід до системи" {

    Context "Вимагати Ctrl+Alt+Del (DisableCAD=0, CIS 2.3.7.2)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Ctrl\+Alt\+Del" }
            $item.Apply.Invoke()
        }
        It "Check повертає true після Apply" {
            $item.Check.Invoke() | Should -BeTrue
        }
        It "DisableCAD дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
                "DisableCAD" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "UAC суворий — FilterAdministratorToken=1 (ACSC)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "UAC суворий" }
            $item.Apply.Invoke()
        }
        It "Check повертає true після Apply" {
            $item.Check.Invoke() | Should -BeTrue
        }
        It "FilterAdministratorToken дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
                "FilterAdministratorToken" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Блокування при бездіяльності — 15 хв (ACSC 33)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "бездіяльності" }
            $item.Apply.Invoke()
        }
        It "InactivityTimeoutSecs дорівнює 900" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
                "InactivityTimeoutSecs" | Should -Be 900
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "security.ps1 — Паролі / Облікові записи" {

    Context "LAPS — локальний адмін з автоматичним паролем (ACSC 08)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "LAPS" }
            $item.Apply.Invoke()
        }
        It "AdmPwdEnabled дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft Services\AdmPwd" `
                "AdmPwdEnabled" | Should -Be 1
        }
        It "PasswordAgeDays не більше 30" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" `
                "PasswordAgeDays" -ErrorAction SilentlyContinue | Should -BeLessOrEqual 30
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Заборонити порожні паролі (LimitBlankPasswordUse=1)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "порожні паролі" }
            $item.Apply.Invoke()
        }
        It "LimitBlankPasswordUse дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
                "LimitBlankPasswordUse" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Вимкнути гостьовий обліковий запис" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "гостьовий" }
            $item.Apply.Invoke()
        }
        It "EnableGuestAccount дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
                "EnableGuestAccount" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "security.ps1 — UAC / Administrator Protection (25H2+)" {

    Context "Administrator Protection — Windows Hello для UAC (25H2+)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Administrator Protection" }
        }
        It "Налаштування має MinBuild=26200" {
            $item.MinBuild | Should -Be 26200
        }
        It "Apply є ScriptBlock" {
            $item.Apply | Should -BeOfType [scriptblock]
        }
        It "ExclusiveGroup = UAC-Level" {
            $item.ExclusiveGroup | Should -Be "UAC-Level"
        }
    }
}

Describe "security.ps1 — Credential / Logon Hardening" {

    Context "WDigest Authentication — legacy, 24H2 і нижче" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "WDigest" }
        }
        It "Apply є ScriptBlock" {
            $item.Apply | Should -BeOfType [scriptblock]
        }
        It "Check враховує Win11Track" {
            # Check повинен повернути bool незалежно від версії
            $result = $item.Check.Invoke()
            $result | Should -BeOfType [bool]
        }
    }

    Context "Заборонити збереження мережевих паролів (ACSC)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "мережевих паролів" }
            $item.Apply.Invoke()
        }
        It "DisableDomainCreds дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
                "DisableDomainCreds" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "security.ps1 — Паролі — розширена політика" {

    Context "PasswordComplexity=1 (CIS 1.1.5)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "розширена політика" -or $_.Name -match "ACSC.*макс.*вік" }
            if (-not $item) { $item = $settings | Where-Object { $_.Group -eq "Паролі — розширена політика" } | Select-Object -First 1 }
            $item.Apply.Invoke()
        }
        It "secedit: PasswordComplexity дорівнює 1" {
            $tmp = "$env:TEMP\pester_secedit.inf"
            secedit /export /cfg $tmp /areas SECURITYPOLICY /quiet 2>$null
            $val = (Get-Content $tmp -ErrorAction SilentlyContinue |
                    Where-Object { $_ -match "PasswordComplexity" }) -replace '.*=\s*',''
            Remove-Item $tmp -Force -ErrorAction SilentlyContinue
            [int]$val | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "security.ps1 — UAC Network / SEHOP" {

    Context "SEHOP увімкнено (ACSC)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "SEHOP" }
            $item.Apply.Invoke()
        }
        It "DisableExceptionChainValidation дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" `
                "DisableExceptionChainValidation" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "security.ps1 — System Cryptography" {

    Context "FIPS + ForceKeyProtection (ACSC)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "FIPS" }
            $item.Apply.Invoke()
        }
        It "FIPSAlgorithmPolicy Enabled дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" `
                "Enabled" | Should -Be 1
        }
        It "ForceKeyProtection дорівнює 2" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography" `
                "ForceKeyProtection" | Should -Be 2
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "security.ps1 — Application Control" {

    Context "Windows Script Host — вимкнути" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Script Host" }
            $item.Apply.Invoke()
        }
        It "WSH Enabled дорівнює 0 (HKLM)" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" `
                "Enabled" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "security.ps1 — Application Hardening (25H2 Baseline)" {

    Context "IE11 COM Automation — вимкнути (25H2 Baseline)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "IE11 COM" }
        }
        It "Налаштування має MinBuild=26200" {
            $item.MinBuild | Should -Be 26200
        }
        It "Apply є ScriptBlock" {
            $item.Apply | Should -BeOfType [scriptblock]
        }
        It "Check є ScriptBlock" {
            $item.Check | Should -BeOfType [scriptblock]
        }
    }
}

Describe "security.ps1 — Printer Hardening (25H2 Baseline)" {

    Context "Принтери — IPPS + TLS/SSL (25H2)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "IPPS.*TLS" }
            $item.Apply.Invoke()
        }
        It "RequireIpps дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\IPP" `
                "RequireIpps" | Should -Be 1
        }
        It "RequireSslCerts дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\IPP" `
                "RequireSslCerts" | Should -Be 1
        }
        It "RestrictDriverInstallationToAdministrators дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" `
                "RestrictDriverInstallationToAdministrators" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "security.ps1 — Hardware Security (26H1)" {

    Context "Secure Boot — нові сертифікати + NoIntegrityChecks" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Secure Boot.*нові сертифікати" }
        }
        It "Apply є ScriptBlock" {
            $item.Apply | Should -BeOfType [scriptblock]
        }
        It "Check є ScriptBlock" {
            $item.Check | Should -BeOfType [scriptblock]
        }
        # НЕ виконуємо Apply — bcdedit може вплинути на завантажувач системи
    }
}

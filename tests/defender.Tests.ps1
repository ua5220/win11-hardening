<#
.SYNOPSIS
    Pester-тести для defender.ps1 — Defender, SmartScreen, ASR, DMA, VBS
.NOTES
    Тести виконують Apply → перевірка → Revert.
    Вимоги: права адміністратора, Pester 5+
#>

#Requires -RunAsAdministrator
BeforeAll {
    . "$PSScriptRoot\..\core\helpers.ps1"
    $settings = & "$PSScriptRoot\..\settings\defender.ps1"
}

Describe "defender.ps1 — Defender / Antivirus" {

    Context "Defender ACSC — повна безпечна конфігурація (ACSC 22)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Defender ACSC" }
            $item.Apply.Invoke()
        }
        It "PUAProtection дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" `
                "PUAProtection" | Should -Be 1
        }
        It "Check повертає true після Apply" {
            $item.Check.Invoke() | Should -BeTrue
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Exploit Protection — DEP, SEHOP, ASLR (ACSC 03)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Exploit Protection — DEP, SEHOP, ASLR" }
            $item.Apply.Invoke()
        }
        It "exe MSYS/Cygwin мають BottomUp/HighEntropy/ForceRelocateImages = OFF" {
            Test-PosixRuntimeAslrExclusion | Should -BeTrue
        }
        It "Check повертає true після Apply" {
            $item.Check.Invoke() | Should -BeTrue
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "ASR Rules — 16 правил (ACSC 02)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "ASR Rules" }
            $item.Apply.Invoke()
        }
        It "ExploitGuard_ASR_Rules дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR" `
                "ExploitGuard_ASR_Rules" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Controlled Folder Access — захист від ransomware (ACSC 04)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Controlled Folder Access" }
            $item.Apply.Invoke()
        }
        # CFA вмикається лише через Set-MpPreference: GPO-ключ блокує «Allow an app»
        It "Apply не залишає GPO-ключ CFA у SOFTWARE\Policies" {
            Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access" |
                Should -BeFalse
        }
        It "Apply прибирає DisableLocalAdminMerge і HideExclusionsFromLocalAdmins" {
            $d = Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -ErrorAction SilentlyContinue
            $d.DisableLocalAdminMerge        | Should -BeNullOrEmpty
            $d.HideExclusionsFromLocalAdmins | Should -BeNullOrEmpty
        }
        It "EnableControlledFolderAccess = Enabled (Get-MpPreference)" -Skip:(-not (Get-Command Get-MpPreference -ErrorAction SilentlyContinue)) {
            (Get-MpPreference).EnableControlledFolderAccess | Should -Be 1
        }
        It "Revert видаляє GPO-вузол (не залишає =0)" {
            $item.Revert.Invoke()
            $key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access"
            $keyExists = Test-Path $key
            if ($keyExists) {
                $val = Get-ItemProperty $key -ErrorAction SilentlyContinue
                $val.EnableControlledFolderAccess | Should -Not -Be 0
            } else {
                $keyExists | Should -BeFalse
            }
        }
    }

    Context "ELAM — Early Launch Antimalware (ACSC 07)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "ELAM" }
            $item.Apply.Invoke()
        }
        It "DriverLoadPolicy дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch" `
                "DriverLoadPolicy" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "defender.ps1 — SmartScreen / Recall / Телеметрія" {

    Context "SmartScreen ACSC — увімкнити та заблокувати обхід (ACSC 34)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "SmartScreen ACSC" }
            $item.Apply.Invoke()
        }
        It "ShellSmartScreenLevel дорівнює Block" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
                "ShellSmartScreenLevel" | Should -Be "Block"
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Вимкнути Windows Recall (AIX сервіс)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Windows Recall" -and $_.Group -match "SmartScreen" }
            $item.Apply.Invoke()
        }
        It "DisableAIDataAnalysis дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" `
                "DisableAIDataAnalysis" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Діагностичні дані — дозволити додаткові (AllowTelemetry=3)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Діагностичні дані.*AllowTelemetry=3" }
            $item.Apply.Invoke()
        }
        It "AllowTelemetry дорівнює 3 (toggle у Settings не заблоковано)" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
                "AllowTelemetry" | Should -Be 3
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "defender.ps1 — Windows Sandbox / Virtualization Security" {

    Context "HVCI — цілісність коду під захистом гіпервізора" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "HVCI" }
            $item.Apply.Invoke()
        }
        It "HypervisorEnforcedCodeIntegrity дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" `
                "HypervisorEnforcedCodeIntegrity" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Заборонити Custom SSPs/APs (LSASS захист)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Custom SSPs" }
            $item.Apply.Invoke()
        }
        It "AllowCustomSSPsAPs дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
                "AllowCustomSSPsAPs" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "defender.ps1 — ASR / WDAC (25H2/26H1 Baseline)" {

    Context "ASR PSExec/WMI — Audit режим (25H2 Baseline)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "ASR PSExec/WMI" }
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

    Context "WDAC — COM-об'єкти (26H1)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "WDAC.*COM" }
        }
        It "Налаштування має MinBuild=26300" {
            $item.MinBuild | Should -Be 26300
        }
        It "Apply є ScriptBlock" {
            $item.Apply | Should -BeOfType [scriptblock]
        }
    }
}

Describe "defender.ps1 — Захист сервісів та драйверів" {

    Context "Remote Registry — вимкнути" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Remote Registry" }
            $item.Apply.Invoke()
        }
        It "RemoteRegistry сервіс вимкнено" {
            $s = Get-Service "RemoteRegistry" -ErrorAction SilentlyContinue
            $s.StartType | Should -Be 'Disabled'
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

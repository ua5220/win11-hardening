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
        It "EnableControlledFolderAccess дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access" `
                "EnableControlledFolderAccess" | Should -Be 1
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

    Context "Вимкнути телеметрію (DiagTrack + AllowTelemetry=0)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "DiagTrack.*AllowTelemetry" }
            $item.Apply.Invoke()
        }
        It "AllowTelemetry дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
                "AllowTelemetry" | Should -Be 0
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

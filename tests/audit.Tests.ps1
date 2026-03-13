<#
.SYNOPSIS
    Pester-тести для audit.ps1 — PowerShell, аудит, scheduled tasks
.NOTES
    Тести виконують Apply → перевірка → Revert.
    Вимоги: права адміністратора, Pester 5+
#>

#Requires -RunAsAdministrator
BeforeAll {
    . "$PSScriptRoot\..\core\helpers.ps1"
    $settings = & "$PSScriptRoot\..\settings\audit.ps1"
}

Describe "audit.ps1 — PowerShell / Audit" {

    Context "PowerShell — AllSigned + Module/Script logging (ACSC 31)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "AllSigned.*logging" }
            $item.Apply.Invoke()
        }
        It "EnableScriptBlockLogging дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" `
                "EnableScriptBlockLogging" | Should -Be 1
        }
        It "EnableModuleLogging дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" `
                "EnableModuleLogging" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Audit Policy — розширений аудит подій (ACSC 24)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Audit Policy.*розширений" }
            $item.Apply.Invoke()
        }
        It "ProcessCreationIncludeCmdLine_Enabled дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" `
                "ProcessCreationIncludeCmdLine_Enabled" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "audit.ps1 — Аудит процесів (25H2 Baseline)" {

    Context "Process Creation — командний рядок у подіях (25H2 Baseline)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Process Creation.*25H2" }
            $item.Apply.Invoke()
        }
        It "ProcessCreationIncludeCmdLine_Enabled дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" `
                "ProcessCreationIncludeCmdLine_Enabled" | Should -Be 1
        }
        It "MinBuild дорівнює 26200" {
            $item.MinBuild | Should -Be 26200
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "audit.ps1 — Розширений аудит (CIS / STIG)" {

    Context "Event Log — розширені розміри (Security 200MB)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Event Log.*розширені розміри" }
            $item.Apply.Invoke()
        }
        It "Security MaxSize не менше 204800" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security" `
                "MaxSize" | Should -BeGreaterOrEqual 204800
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Audit — Account Logon та Group Management (CIS)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Account Logon.*Group Management" }
            $item.Apply.Invoke()
        }
        It "Credential Validation аудит увімкнено" {
            $out = auditpol /get /subcategory:"Credential Validation" 2>$null
            $out -match 'Success' | Should -Not -BeNullOrEmpty
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "audit.ps1 — Scheduled Tasks" {

    Context "CEIP tasks — вимкнути" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "CEIP tasks" }
            $item.Apply.Invoke()
        }
        It "Check повертає true або задача не існує" {
            # На деяких системах задачі CEIP відсутні
            $t = Get-ScheduledTask -TaskPath "\Microsoft\Windows\Customer Experience Improvement Program\" `
                                   -TaskName "Consolidator" -ErrorAction SilentlyContinue
            if ($t) {
                $t.State | Should -Be 'Disabled'
            } else {
                $true | Should -BeTrue  # задача не існує — пропускаємо
            }
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

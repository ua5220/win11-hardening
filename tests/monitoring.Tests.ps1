<#
.SYNOPSIS
    Pester-тести для monitoring.ps1 — моніторинг безпеки, Token Impersonation, SAM
.NOTES
    Тести перевіряють коректність Check-блоків та наявність обов'язкових полів.
    Моніторинг-скрипти переважно працюють у режимі читання — тести не змінюють систему.
    Вимоги: права адміністратора, Pester 5+
#>

#Requires -RunAsAdministrator
BeforeAll {
    . "$PSScriptRoot\..\core\helpers.ps1"
    $settings = & "$PSScriptRoot\..\settings\monitoring.ps1"
}

Describe "monitoring.ps1 — Моніторинг PowerShell" {

    Context "Виявлення підробки PS-скриптів — хеш-базовий моніторинг" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "підробки PS-скриптів" }
        }
        It "Apply є ScriptBlock" {
            $item.Apply | Should -BeOfType [scriptblock]
        }
        It "Check виконується без помилок" {
            { $item.Check.Invoke() } | Should -Not -Throw
        }
    }

    Context "Виявлення підозрілих викликів PowerShell" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "підозрілих викликів" }
        }
        It "Check повертає bool" {
            $result = $item.Check.Invoke()
            $result | Should -BeOfType [bool]
        }
    }
}

Describe "monitoring.ps1 — Аудит маркерів (Token Impersonation)" {

    Context "Увімкнути аудит підміни маркерів" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Увімкнути аудит підміни маркерів" }
            $item.Apply.Invoke()
        }
        It "auditpol Token Right Adjusted Events увімкнено" {
            $out = auditpol /get /subcategory:"Token Right Adjusted Events" 2>$null | Out-String
            $out -match 'Success' | Should -BeTrue
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "monitoring.ps1 — SAM / Anonymous Security" {

    Context "SAM-Anonymous — заборона анонімного доступу" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "SAM-Anonymous" }
            $item.Apply.Invoke()
        }
        It "RestrictAnonymous дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
                "RestrictAnonymous" | Should -Be 1
        }
        It "RestrictAnonymousSAM дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
                "RestrictAnonymousSAM" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "monitoring.ps1 — Дамп кешів / Forensic" {

    Context "Dump Caches — дамп DNS/ARP/NetBIOS кешів" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Dump Caches" }
        }
        It "Check повертає true (завжди можна запустити)" {
            $item.Check.Invoke() | Should -BeTrue
        }
    }
}

Describe "monitoring.ps1 — OPSEC / Маскування" {

    Context "Timezone Spoofer — підміна часового поясу" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Timezone Spoofer" }
        }
        It "Apply є ScriptBlock" {
            $item.Apply | Should -BeOfType [scriptblock]
        }
        It "Revert є ScriptBlock" {
            $item.Revert | Should -BeOfType [scriptblock]
        }
        # НЕ виконуємо Apply — зміна часового поясу може вплинути на систему
    }
}

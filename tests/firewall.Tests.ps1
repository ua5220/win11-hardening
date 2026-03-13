<#
.SYNOPSIS
    Pester-тести для firewall.ps1 — брандмауер, блокування протоколів, TOR, Lateral Movement
.NOTES
    Тести перевіряють створення правил брандмауера через Apply та видалення через Revert.
    Вимоги: права адміністратора, Pester 5+
#>

#Requires -RunAsAdministrator
BeforeAll {
    . "$PSScriptRoot\..\core\helpers.ps1"
    $settings = & "$PSScriptRoot\..\settings\firewall.ps1"
}

Describe "firewall.ps1 — Блокування протоколів Inbound" {

    Context "Застарілі протоколи Inbound (Telnet, FTP, rsh…)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "застарілі.*небезпечні.*Inbound" }
            $item.Apply.Invoke()
        }
        It "Правило Block Telnet Inbound існує" {
            Get-NetFirewallRule -DisplayName "Block Telnet Inbound" `
                -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
        It "Check повертає true" {
            $item.Check.Invoke() | Should -BeTrue
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "firewall.ps1 — Apply/Revert цикл для всіх правил" {

    # Перевірити що кожне налаштування має валідні Apply/Revert/Check
    foreach ($s in $settings) {
        Context "Apply/Revert: $($s.Name.Substring(0, [Math]::Min(60, $s.Name.Length)))" {
            It "Apply є ScriptBlock" {
                $s.Apply | Should -BeOfType [scriptblock]
            }
            It "Revert є ScriptBlock" {
                $s.Revert | Should -BeOfType [scriptblock]
            }
            It "Check є ScriptBlock" {
                $s.Check | Should -BeOfType [scriptblock]
            }
        }
    }
}

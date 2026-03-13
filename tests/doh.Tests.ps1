<#
.SYNOPSIS
    Pester-тести для doh.ps1 — DNS-over-HTTPS та ARP Spoofing Mitigation
.NOTES
    Тести виконують Apply → перевірка → Revert.
    Вимоги: права адміністратора, Pester 5+
#>

#Requires -RunAsAdministrator
BeforeAll {
    . "$PSScriptRoot\..\core\helpers.ps1"
    $settings = & "$PSScriptRoot\..\settings\doh.ps1"
}

Describe "doh.ps1 — DNS-over-HTTPS" {

    Context "Force DNS over HTTPS — примусовий DoH (Cloudflare/Google)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Force DNS over HTTPS" }
            $item.Apply.Invoke()
        }
        It "EnableAutoDoh дорівнює 2" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" `
                "EnableAutoDoh" | Should -Be 2
        }
        It "Check повертає true після Apply" {
            $item.Check.Invoke() | Should -BeTrue
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "DoH Edge GPO — примусовий DNS-over-HTTPS для Edge" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "DoH Edge GPO" }
            $item.Apply.Invoke()
        }
        It "DnsOverHttpsMode дорівнює force" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Edge" `
                "DnsOverHttpsMode" | Should -Be "force"
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "ARP Spoofing Mitigation — статичні ARP-записи" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "ARP Spoofing" }
            $item.Apply.Invoke()
        }
        It "ArpRetryCount дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" `
                "ArpRetryCount" | Should -Be 1
        }
        It "Check повертає bool" {
            $result = $item.Check.Invoke()
            $result | Should -BeOfType [bool]
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

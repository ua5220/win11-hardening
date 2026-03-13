<#
.SYNOPSIS
    Pester-тести для policy.ps1 — MSS Legacy, принтери, RPC, Group Policy
.NOTES
    Тести виконують Apply → перевірка → Revert.
    Вимоги: права адміністратора, Pester 5+
#>

#Requires -RunAsAdministrator
BeforeAll {
    . "$PSScriptRoot\..\core\helpers.ps1"
    $settings = & "$PSScriptRoot\..\settings\policy.ps1"
}

Describe "policy.ps1 — MSS Legacy" {

    Context "IP Source Routing — максимальний захист (ACSC)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "IP Source Routing" }
            $item.Apply.Invoke()
        }
        It "DisableIPSourceRouting дорівнює 2 (IPv4)" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" `
                "DisableIPSourceRouting" | Should -Be 2
        }
        It "DisableIPSourceRouting дорівнює 2 (IPv6)" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" `
                "DisableIPSourceRouting" | Should -Be 2
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "ICMP Redirects — заборонити (ACSC)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "ICMP Redirects" }
            $item.Apply.Invoke()
        }
        It "EnableICMPRedirect дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" `
                "EnableICMPRedirect" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "policy.ps1 — Принтери — Hardening" {

    Context "Принтери RPC/IPPS/TLS — захист (ACSC)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Принтери RPC" }
            $item.Apply.Invoke()
        }
        It "RequireIPPS дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" `
                "RequireIPPS" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "policy.ps1 — Remote Assistance / RPC" {

    Context "Remote Assistance — вимкнути (ACSC)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Remote Assistance.*вимкнути" }
            $item.Apply.Invoke()
        }
        It "fAllowToGetHelp дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" `
                "fAllowToGetHelp" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "RPC — обмежити неавтентифікованих клієнтів (ACSC)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "RPC.*обмежити" }
            $item.Apply.Invoke()
        }
        It "RestrictRemoteClients дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Rpc" `
                "RestrictRemoteClients" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "policy.ps1 — Group Policy Processing" {

    Context "Registry/Security policy — примусове оновлення (ACSC)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "примусове оновлення" }
            $item.Apply.Invoke()
        }
        It "NoGPOListChanges дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}" `
                "NoGPOListChanges" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "policy.ps1 — Startup / Logon Programs" {

    Context "Вимкнути legacy run list (ACSC)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "legacy run list" }
            $item.Apply.Invoke()
        }
        It "DisableLocalMachineRun дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
                "DisableLocalMachineRun" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

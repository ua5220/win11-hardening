<#
.SYNOPSIS
    Pester-тести для network.ps1 — NTLM, SMB, TCP/IP, брандмауер, мережева ізоляція
.NOTES
    Тести виконують Apply → перевірка реєстру → Revert.
    Вимоги: права адміністратора, Pester 5+
#>

#Requires -RunAsAdministrator
BeforeAll {
    . "$PSScriptRoot\..\core\helpers.ps1"
    $settings = & "$PSScriptRoot\..\settings\network.ps1"
}

Describe "network.ps1 — Мережева безпека" {

    Context "NTLMv2 тільки (LmCompatibilityLevel=5)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "NTLMv2" }
            $item.Apply.Invoke()
        }
        It "LmCompatibilityLevel дорівнює 5" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
                "LmCompatibilityLevel" | Should -Be 5
        }
        It "NTLMMinClientSec дорівнює 537395200" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" `
                "NTLMMinClientSec" | Should -Be 537395200
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "SMBv1 вимкнено" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "SMB v1" }
            $item.Apply.Invoke()
        }
        It "SMB1 дорівнює 0 у реєстрі" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" `
                "SMB1" | Should -Be 0
        }
        It "mrxsmb10 Start=4 (вимкнено)" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Services\mrxsmb10" `
                "Start" | Should -Be 4
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Anonymous connections — заборонити (ACSC 21)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Anonymous connections" }
            $item.Apply.Invoke()
        }
        It "RestrictAnonymous дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
                "RestrictAnonymous" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "LLMNR вимкнути (ACSC 32)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "LLMNR" }
            $item.Apply.Invoke()
        }
        It "EnableMulticast дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" `
                "EnableMulticast" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "WinRM — вимкнути Basic auth (ACSC 29)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "WinRM.*Basic" }
            $item.Apply.Invoke()
        }
        It "WinRM Client AllowBasic дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client" `
                "AllowBasic" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "network.ps1 — TCP/IP стек — захист від атак" {

    Context "Захист від SYN Flood (SynAttackProtect)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "SYN Flood" }
            $item.Apply.Invoke()
        }
        It "SynAttackProtect встановлено" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" `
                "SynAttackProtect" | Should -BeGreaterOrEqual 1
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "TCP Timestamps вимкнути" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "TCP Timestamps" }
            $item.Apply.Invoke()
        }
        It "Tcp1323Opts дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" `
                "Tcp1323Opts" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "network.ps1 — IPv6 / NetBIOS" {

    Context "IPv6 — вимкнути (DisabledComponents=0xFE)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "IPv6.*вимкнути" }
            $item.Apply.Invoke()
        }
        It "DisabledComponents дорівнює 254 (0xFE)" {
            Get-ItemPropertyValue `
                "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" `
                "DisabledComponents" | Should -Be 254
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "network.ps1 — Брандмауер — профілі та правила" {

    Context "Firewall Logging увімкнено" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Firewall Logging" }
            $item.Apply.Invoke()
        }
        It "Public profile LogBlocked = True" {
            $p = Get-NetFirewallProfile -Profile Public -ErrorAction SilentlyContinue
            $p.LogBlocked | Should -Be "True"
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Firewall — увімкнути профілі + блокувати вхідні" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "увімкнути всі профілі" }
            $item.Apply.Invoke()
        }
        It "Public профіль увімкнено з Block Inbound" {
            $p = Get-NetFirewallProfile -Profile Public -ErrorAction SilentlyContinue
            $p.Enabled | Should -BeTrue
            $p.DefaultInboundAction | Should -Be 'Block'
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "network.ps1 — Мережева ізоляція / Domain Hardening" {

    Context "SMB Encryption — обов'язкове шифрування" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "SMB Encryption" }
            $item.Apply.Invoke()
        }
        It "EncryptData увімкнено" {
            $cfg = Get-SmbServerConfiguration -ErrorAction SilentlyContinue
            $cfg.EncryptData | Should -BeTrue
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

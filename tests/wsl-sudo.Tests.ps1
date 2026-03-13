<#
.SYNOPSIS
    Pester-тести для wsl-sudo.ps1 — WSL hardening та Sudo (Win 11 24H2+)
.NOTES
    Тести виконують Apply → перевірка → Revert.
    Вимоги: права адміністратора, Pester 5+
#>

#Requires -RunAsAdministrator
BeforeAll {
    . "$PSScriptRoot\..\core\helpers.ps1"
    $settings = & "$PSScriptRoot\..\settings\wsl-sudo.ps1"
}

Describe "wsl-sudo.ps1 — WSL / Sudo" {

    Context "WSL Hardening — вимкнення Windows Subsystem for Linux" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "WSL Hardening" }
            $item.Apply.Invoke()
        }
        It "AllowDevelopmentWithoutDevLicense дорівнює 0 (GPO)" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsSubsystemForLinux" `
                "AllowDevelopmentWithoutDevLicense" | Should -Be 0
        }
        It "AllowDevelopmentWithoutDevLicense дорівнює 0 (AppModelUnlock)" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" `
                "AllowDevelopmentWithoutDevLicense" | Should -Be 0
        }
        It "Check повертає bool" {
            $result = $item.Check.Invoke()
            $result | Should -BeOfType [bool]
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Sudo Hardening — вимкнення Windows 11 Sudo (24H2+)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Sudo Hardening" }
            $item.Apply.Invoke()
        }
        It "Sudo Enabled дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Sudo" `
                "Enabled" | Should -Be 0
        }
        It "Check повертає true після Apply" {
            $item.Check.Invoke() | Should -BeTrue
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

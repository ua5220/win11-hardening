<#
.SYNOPSIS
    Pester-тести для services.ps1 — шифрування, сервіси, живлення, пристрої
.NOTES
    Тести виконують Apply → перевірка → Revert.
    Вимоги: права адміністратора, Pester 5+
#>

#Requires -RunAsAdministrator
BeforeAll {
    . "$PSScriptRoot\..\core\helpers.ps1"
    $settings = & "$PSScriptRoot\..\settings\services.ps1"
}

Describe "services.ps1 — Шифрування / BitLocker" {

    Context "BitLocker — XTS-AES 128 + DMA вимкнено (ACSC 27)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "BitLocker.*XTS-AES" }
            $item.Apply.Invoke()
        }
        It "DisableExternalDMAUnderLock дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\FVE" `
                "DisableExternalDMAUnderLock" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Знімні носії — заборонити доступ (ACSC 28)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Знімні носії" }
            $item.Apply.Invoke()
        }
        It "Deny_All дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices" `
                "Deny_All" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Credential Guard — VBS + LSASS (ACSC 01)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Credential Guard" }
            $item.Apply.Invoke()
        }
        It "LsaCfgFlags дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" `
                "LsaCfgFlags" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "services.ps1 — Сервіси: History / Logs / Footprint" {

    Context "Вимкнути Activity History (Timeline)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Activity History" }
            $item.Apply.Invoke()
        }
        It "PublishUserActivities дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
                "PublishUserActivities" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Вимкнути Windows Error Reporting (WerSvc)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Error Reporting" }
            $item.Apply.Invoke()
        }
        It "WerSvc сервіс вимкнено" {
            $s = Get-Service "WerSvc" -ErrorAction SilentlyContinue
            $s.StartType | Should -Be 'Disabled'
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "services.ps1 — Живлення / Патчі / Автозапуск" {

    Context "Вимкнути Autoplay / AutoRun повністю (ACSC 25)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Autoplay.*AutoRun" }
            $item.Apply.Invoke()
        }
        It "NoDriveTypeAutoRun дорівнює 255 (HKLM)" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
                "NoDriveTypeAutoRun" | Should -Be 255
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "services.ps1 — Misc / Low Priority" {

    Context "AlwaysInstallElevated = вимкнути (ACSC 34)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "AlwaysInstallElevated" }
            $item.Apply.Invoke()
        }
        It "AlwaysInstallElevated дорівнює 0 (HKLM)" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" `
                "AlwaysInstallElevated" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Показувати розширення файлів (ACSC 40)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "розширення файлів" }
            $item.Apply.Invoke()
        }
        It "HideFileExt дорівнює 0" {
            Get-ItemPropertyValue `
                "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
                "HideFileExt" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "services.ps1 — Відновлення / Зручність" {

    Context "Windows Store — відновити доступ" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Store.*відновити" }
            $item.Apply.Invoke()
        }
        It "RemoveWindowsStore дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" `
                "RemoveWindowsStore" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

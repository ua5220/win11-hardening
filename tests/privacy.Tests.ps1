<#
.SYNOPSIS
    Pester-тести для privacy.ps1 — Copilot, AI, Widgets, OneDrive, приватність
.NOTES
    Тести виконують Apply → перевірка → Revert.
    Вимоги: права адміністратора, Pester 5+
#>

#Requires -RunAsAdministrator
BeforeAll {
    . "$PSScriptRoot\..\core\helpers.ps1"
    $settings = & "$PSScriptRoot\..\settings\privacy.ps1"
}

Describe "privacy.ps1 — Copilot / AI / Widgets" {

    Context "Windows Copilot — вимкнути" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Windows Copilot.*вимкнути" }
            $item.Apply.Invoke()
        }
        It "TurnOffWindowsCopilot дорівнює 1 (HKLM)" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" `
                "TurnOffWindowsCopilot" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Windows Recall — вимкнути (AIDataAnalysis)" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Windows Recall.*AIDataAnalysis" }
            $item.Apply.Invoke()
        }
        It "DisableAIDataAnalysis дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" `
                "DisableAIDataAnalysis" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Widgets / Feeds / Фонові застосунки — вимкнути" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Widgets.*Feeds" }
            $item.Apply.Invoke()
        }
        It "AllowNewsAndInterests дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" `
                "AllowNewsAndInterests" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "privacy.ps1 — Приватність (HKCU)" {

    Context "Advertising ID — вимкнути" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Advertising ID.*HKCU.*HKLM" }
            $item.Apply.Invoke()
        }
        It "AdvertisingInfo Enabled дорівнює 0" {
            Get-ItemPropertyValue `
                "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" `
                "Enabled" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "ContentDeliveryManager — вимкнути рекламу та пропозиції" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "ContentDeliveryManager" }
            $item.Apply.Invoke()
        }
        It "ContentDeliveryAllowed дорівнює 0" {
            Get-ItemPropertyValue `
                "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
                "ContentDeliveryAllowed" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "privacy.ps1 — Приватність — розширена (HKLM)" {

    Context "SettingSync — вимкнути всі типи синхронізації" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "SettingSync" }
            $item.Apply.Invoke()
        }
        It "DisableSettingSync дорівнює 2" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync" `
                "DisableSettingSync" | Should -Be 2
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Connected Devices Platform (CDP) — вимкнути" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Connected Devices Platform" }
            $item.Apply.Invoke()
        }
        It "EnableCdp дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
                "EnableCdp" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Cortana / Search — повністю вимкнути" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Cortana.*Search.*повністю" }
            $item.Apply.Invoke()
        }
        It "AllowCortana дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" `
                "AllowCortana" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }

    Context "Delivery Optimization — вимкнути P2P" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Delivery Optimization.*P2P" }
            $item.Apply.Invoke()
        }
        It "DODownloadMode дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" `
                "DODownloadMode" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "privacy.ps1 — Приватність — розширена (HKCU)" {

    Context "Хмарна синхронізація / буфер обміну — вимкнути" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "буфер обміну" }
            $item.Apply.Invoke()
        }
        It "AllowCrossDeviceClipboard дорівнює 0" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
                "AllowCrossDeviceClipboard" | Should -Be 0
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

Describe "privacy.ps1 — IE / Edge — захист" {

    Context "Edge — заблокувати збір даних та рекламу" {
        BeforeAll {
            $item = $settings | Where-Object { $_.Name -match "Edge.*збір даних" }
            $item.Apply.Invoke()
        }
        It "DoNotTrack дорівнює 1" {
            Get-ItemPropertyValue `
                "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" `
                "DoNotTrack" | Should -Be 1
        }
        AfterAll { $item.Revert.Invoke() }
    }
}

<#
.SYNOPSIS
    Hardening settings data for HardeningGUI_v2
.NOTES
    Dot-sourced by HardeningGUI_v2.ps1 after helpers.ps1.
    Exports: Get-HardeningSettings

    Налаштування розбито на категоризовані файли в директорії settings/:
      security.ps1   — UAC, паролі, облікові записи, WSL, Sudo, біометрія
      defender.ps1   — Defender, SmartScreen, ASR, DMA, пісочниця
      network.ps1    — мережева безпека, DoH, ARP, протоколи, TCP/IP
      firewall.ps1   — брандмауер, блокування портів, Pivot, TOR, Pineapple
      privacy.ps1    — приватність HKCU/HKLM, OneDrive, Xbox, Edge
      services.ps1   — сервіси, журнали, бекап, живлення, пристрої
      audit.ps1      — PowerShell аудит, CIS/STIG, заплановані завдання
      policy.ps1     — MSS Legacy, принтери, RPC, Group Policy
      monitoring.ps1 — моніторинг PS, Token Impersonation, Defender audit, USB
#>

function Get-HardeningSettings {
    $settingsDir = Join-Path $PSScriptRoot 'settings'

    $categoryFiles = @(
        'security.ps1',
        'defender.ps1',
        'network.ps1',
        'firewall.ps1',
        'privacy.ps1',
        'services.ps1',
        'audit.ps1',
        'policy.ps1',
        'monitoring.ps1'
    )

    $Settings = @()

    foreach ($file in $categoryFiles) {
        $fullPath = Join-Path $settingsDir $file
        if (-not (Test-Path $fullPath -PathType Leaf)) {
            Write-AppLog -Level 'WARN' -Message "Файл налаштувань відсутній: $fullPath"
            continue
        }
        $categorySettings = @(. $fullPath)
        $Settings += $categorySettings
    }

    return $Settings
}

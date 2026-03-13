<#
.SYNOPSIS
    Hardening settings data for Windows 11 Hardening Suite
.NOTES
    Dot-sourced by Run-Hardening.ps1 after helpers.ps1.
    Exports: Get-HardeningSettings

    Налаштування розбито на категоризовані файли в директорії settings/:
      security.ps1   — UAC, паролі, облікові записи, біометрія
      defender.ps1   — Defender, SmartScreen, ASR, DMA, пісочниця
      network.ps1    — мережева безпека, протоколи, TCP/IP, SMB
      firewall.ps1   — брандмауер, блокування портів, Pivot, TOR, Pineapple
      privacy.ps1    — приватність HKCU/HKLM, OneDrive, Xbox, Edge
      services.ps1   — сервіси, журнали, бекап, живлення, пристрої
      audit.ps1      — PowerShell аудит, CIS/STIG, заплановані завдання
      policy.ps1     — MSS Legacy, принтери, RPC, Group Policy
      monitoring.ps1 — моніторинг PS, Token Impersonation, Defender audit, USB
      wsl-sudo.ps1   — WSL, Sudo (Win 11 24H2+)
      doh.ps1        — DNS-over-HTTPS, Edge DoH GPO, ARP захист
      uefi-hardening.ps1 — UEFI/BIOS захист, Secure Boot, DMA, ASUS CVE
#>

$Global:SettingsModules = @(
    @{ Name="security";    File="settings\security.ps1";    Version="3.1"; MinBuild=22000 }
    @{ Name="defender";    File="settings\defender.ps1";    Version="3.1"; MinBuild=22000 }
    @{ Name="network";     File="settings\network.ps1";     Version="3.1"; MinBuild=22000 }
    @{ Name="firewall";    File="settings\firewall.ps1";    Version="2.0"; MinBuild=22000 }
    @{ Name="privacy";     File="settings\privacy.ps1";     Version="2.0"; MinBuild=22000 }
    @{ Name="services";    File="settings\services.ps1";    Version="2.0"; MinBuild=22000 }
    @{ Name="audit";       File="settings\audit.ps1";       Version="3.1"; MinBuild=22000 }
    @{ Name="policy";      File="settings\policy.ps1";      Version="1.0"; MinBuild=22000 }
    @{ Name="monitoring";  File="settings\monitoring.ps1";  Version="2.0"; MinBuild=22000 }
    @{ Name="wsl-sudo";    File="settings\wsl-sudo.ps1";    Version="1.0"; MinBuild=22000 }
    @{ Name="doh";             File="settings\doh.ps1";             Version="1.0"; MinBuild=22000 }
    @{ Name="uefi-hardening"; File="settings\uefi-hardening.ps1"; Version="1.0"; MinBuild=22000 }
)

function Get-HardeningSettings {
    # core/ -> root: піднімаємось на один рівень від $PSScriptRoot
    $rootDir     = Split-Path $PSScriptRoot -Parent
    $settingsDir = Join-Path $rootDir 'settings'

    $Settings = @()

    foreach ($mod in $Global:SettingsModules) {
        $fullPath = Join-Path $rootDir $mod.File
        if (-not (Test-Path $fullPath -PathType Leaf)) {
            Write-AppLog -Level 'WARN' -Message "Модуль '$($mod.Name)' не знайдено: $fullPath"
            continue
        }
        try {
            $categorySettings = @(. $fullPath)
            $Settings += $categorySettings
        } catch {
            Write-AppLog -Level 'ERROR' -Message "Помилка завантаження модуля '$($mod.Name)': $_"
        }
    }

    return $Settings
}

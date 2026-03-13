<#
.SYNOPSIS
    Windows 11 Hardening Suite — єдина точка входу
.NOTES
    Вимоги: PowerShell 5.1+, права адміністратора
    Джерела: PrivacyHarden_v5, dev-sec, troennes/private-secure-windows,
             SaneRelapse/PSHardening
    Структура:
      Run-Hardening.ps1    -> цей файл (bootstrap + orchestration)
      core/helpers.ps1     -> інфраструктурні функції (реєстр, сервіси, логування)
      core/settings.data.ps1 -> Get-HardeningSettings (агрегатор налаштувань)
      core/ui.ps1          -> WinForms factory, row rendering
      core/actions.ps1     -> bulk operations, event wiring
      settings/            -> категоризовані файли налаштувань:
        security.ps1, defender.ps1, network.ps1, firewall.ps1, privacy.ps1,
        services.ps1, audit.ps1, policy.ps1, monitoring.ps1, wsl-sudo.ps1, doh.ps1
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

# Перевірка версії ОС
if ([System.Environment]::OSVersion.Version.Build -lt 22000) {
    Write-Warning "Скрипт розроблено для Windows 11 (build 22000+)"
    exit 1
}

# Завантаження ядра
$coreDir = Join-Path $PSScriptRoot 'core'
foreach ($file in @('helpers.ps1', 'settings.data.ps1', 'ui.ps1', 'actions.ps1')) {
    $fullPath = Join-Path $coreDir $file
    if (-not (Test-Path $fullPath -PathType Leaf)) {
        throw "Відсутній обов'язковий файл: $fullPath"
    }
    . $fullPath
}

# Перевірка директорії налаштувань
$settingsDir = Join-Path $PSScriptRoot 'settings'
if (-not (Test-Path $settingsDir -PathType Container)) {
    throw "Відсутня директорія налаштувань: $settingsDir"
}

Initialize-WinForms

$settings = Get-HardeningSettings

$check = Invoke-StartupSelfCheck -RootPath $PSScriptRoot -Settings $settings
if ($check.Errors.Count -gt 0) {
    $message = $check.Errors -join "`r`n"
    Write-AppLog -Level 'ERROR' -Message "Startup self-check failed :: $message"
    [void][System.Windows.Forms.MessageBox]::Show(
        "Self-check не пройдено:`r`n`r`n$message",
        'Помилка старту',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    return
}

Write-AppLog -Level 'INFO' -Message "Startup OK :: $($settings.Count) settings loaded"

$context = New-HardeningUi -Settings $settings
Build-SettingRows        -Context $context
Connect-HardeningActions -Context $context

[System.Windows.Forms.Application]::Run($context.Form)

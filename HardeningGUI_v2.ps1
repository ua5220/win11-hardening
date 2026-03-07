<#
.SYNOPSIS
    Windows 11 Hardening GUI v2 — launcher
.NOTES
    Вимоги: PowerShell 5.1+, права адміністратора
    Структура:
      HardeningGUI_v2.ps1  -> цей файл (bootstrap + orchestration)
      helpers.ps1          -> інфраструктурні функції
      settings.data.ps1    -> Get-HardeningSettings (дані hardening-правил)
      ui.ps1               -> WinForms factory, row rendering
      actions.ps1          -> bulk operations, event wiring
#>

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'helpers.ps1')
. (Join-Path $PSScriptRoot 'settings.data.ps1')
. (Join-Path $PSScriptRoot 'ui.ps1')
. (Join-Path $PSScriptRoot 'actions.ps1')

Ensure-Elevated
Initialize-WinForms

$settings = Get-HardeningSettings
if (-not $settings -or $settings.Count -eq 0) {
    throw 'Get-HardeningSettings() повернув порожній список налаштувань.'
}

$context = New-HardeningUi -Settings $settings
Build-SettingRows   -Context $context
Connect-HardeningActions -Context $context

[System.Windows.Forms.Application]::Run($context.Form)

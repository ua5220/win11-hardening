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

#Requires -Version 5.1
#Requires -RunAsAdministrator

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

foreach ($file in @('helpers.ps1', 'settings.data.ps1', 'ui.ps1', 'actions.ps1')) {
    $fullPath = Join-Path $PSScriptRoot $file
    if (-not (Test-Path $fullPath -PathType Leaf)) {
        throw "Відсутній обов'язковий файл: $fullPath"
    }
    . $fullPath
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
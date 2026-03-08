<#
.SYNOPSIS
    Windows 11 Hardening GUI v2 â€” launcher
.NOTES
    Ð’Ð¸Ð¼Ð¾Ð³Ð¸: PowerShell 5.1+, Ð¿Ñ€Ð°Ð²Ð° Ð°Ð´Ð¼Ñ–Ð½Ñ–ÑÑ‚Ñ€Ð°Ñ‚Ð¾Ñ€Ð°
    Ð¡Ñ‚Ñ€ÑƒÐºÑ‚ÑƒÑ€Ð°:
      HardeningGUI_v2.ps1  -> Ñ†ÐµÐ¹ Ñ„Ð°Ð¹Ð» (bootstrap + orchestration)
      helpers.ps1          -> Ñ–Ð½Ñ„Ñ€Ð°ÑÑ‚Ñ€ÑƒÐºÑ‚ÑƒÑ€Ð½Ñ– Ñ„ÑƒÐ½ÐºÑ†Ñ–Ñ—
      settings.data.ps1    -> Get-HardeningSettings (Ð´Ð°Ð½Ñ– hardening-Ð¿Ñ€Ð°Ð²Ð¸Ð»)
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

$check = Invoke-StartupSelfCheck -RootPath $PSScriptRoot -Settings $settings
if ($check.Errors.Count -gt 0) {
    $message = ($check.Errors -join "`r`n")
    Write-AppLog -Level 'ERROR' -Message "Startup self-check failed :: $message"
    [System.Windows.Forms.MessageBox]::Show(
        "Self-check Ð½Ðµ Ð¿Ñ€Ð¾Ð¹Ð´ÐµÐ½Ð¾:`r`n`r`n$message",
        'ÐŸÐ¾Ð¼Ð¸Ð»ÐºÐ° ÑÑ‚Ð°Ñ€Ñ‚Ñƒ',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    return
}

Write-AppLog -Level 'INFO' -Message "Startup OK :: $($settings.Count) settings loaded"

$context = New-HardeningUi -Settings $settings
Build-SettingRows   -Context $context
Connect-HardeningActions -Context $context

[System.Windows.Forms.Application]::Run($context.Form)

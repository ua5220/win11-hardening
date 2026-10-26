<#
.SYNOPSIS
    Створює ярлик «Windows 11 Hardening» на робочому столі та в меню «Пуск» — запуск GUI одним кліком
.DESCRIPTION
    Ярлик:
      - запускається від імені адміністратора (запит UAC / Administrator protection);
      - не показує консоль: conhost.exe --headless (-WindowStyle Hidden не ховає Windows Terminal);
      - бере PowerShell 7 з Program Files, інакше Windows PowerShell 5.1. Версію з Microsoft Store
        (WindowsApps) не беремо — з Administrator protection Store-програми від адміністратора не стартують.
    Права адміністратора для створення ярлика не потрібні. Після перенесення репо — запустити знову.
.PARAMETER NoStartMenu
    Не створювати ярлик у меню «Пуск».
.EXAMPLE
    .\tools\New-HardeningShortcut.ps1
#>
[CmdletBinding()]
param([switch]$NoStartMenu)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$launcher = Join-Path $PSScriptRoot 'Start-HardeningGui.ps1'
$rootDir  = Split-Path $PSScriptRoot -Parent

$ps = @(
    (Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe')
    (Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe')
) | Where-Object { Test-Path $_ } | Select-Object -First 1

$icon = Join-Path $env:SystemRoot 'System32\SecurityHealthSystray.exe'
$iconLocation = if (Test-Path $icon) { "$icon,0" } else { "$env:SystemRoot\System32\imageres.dll,73" }

$targets = @(Join-Path ([Environment]::GetFolderPath('Desktop')) 'Windows 11 Hardening.lnk')
if (-not $NoStartMenu) { $targets += Join-Path ([Environment]::GetFolderPath('Programs')) 'Windows 11 Hardening.lnk' }

$shell = New-Object -ComObject WScript.Shell
foreach ($lnkPath in $targets) {
    $lnk = $shell.CreateShortcut($lnkPath)
    $lnk.TargetPath       = Join-Path $env:SystemRoot 'System32\conhost.exe'
    $lnk.Arguments        = "--headless `"$ps`" -NoProfile -ExecutionPolicy Bypass -STA -File `"$launcher`""
    $lnk.WorkingDirectory = $rootDir
    $lnk.IconLocation     = $iconLocation
    $lnk.Description      = 'Windows 11 Hardening Suite (GUI)'
    $lnk.Save()

    # Прапорець «Запуск від імені адміністратора»: біт 0x20 у байті 0x15 (LinkFlags.RunAsUser)
    $bytes = [System.IO.File]::ReadAllBytes($lnkPath)
    $bytes[0x15] = $bytes[0x15] -bor 0x20
    [System.IO.File]::WriteAllBytes($lnkPath, $bytes)

    Write-Host "[OK] $lnkPath" -ForegroundColor Green
}
Write-Host "PowerShell: $ps" -ForegroundColor DarkGray

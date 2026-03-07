<#
.SYNOPSIS
    Infrastructure helpers for HardeningGUI_v2
.NOTES
    Dot-sourced by HardeningGUI_v2.ps1 before any other module.
    Provides: elevation check, WinForms init, registry/service/task helpers,
              and Test-SettingEnabled.
#>

function Ensure-Elevated {
    $currentIdentity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $currentPrincipal = [Security.Principal.WindowsPrincipal]::new($currentIdentity)

    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Start-Process powershell.exe `
            -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
            -Verb RunAs
        exit
    }
}

function Initialize-WinForms {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()
}

function Set-Reg {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)]$Value,
        [string]$Type = 'DWord'
    )

    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }

    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction SilentlyContinue
}

function Get-Reg {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        $Default = $null
    )

    try {
        return (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
    }
    catch {
        return $Default
    }
}

function Remove-RegValue {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name
    )

    Remove-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
}

function Set-ServiceDisabled {
    param([Parameter(Mandatory)][string]$Name)

    $s = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($s) {
        Stop-Service -Name $Name -Force -ErrorAction SilentlyContinue
        Set-Service  -Name $Name -StartupType Disabled -ErrorAction SilentlyContinue
    }
}

function Set-ServiceManual {
    param([Parameter(Mandatory)][string]$Name)

    $s = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($s) {
        Set-Service -Name $Name -StartupType Manual -ErrorAction SilentlyContinue
    }
}

function Disable-Task {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name
    )

    Get-ScheduledTask -TaskPath $Path -TaskName $Name -ErrorAction SilentlyContinue |
        Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null
}

function Enable-Task {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name
    )

    Get-ScheduledTask -TaskPath $Path -TaskName $Name -ErrorAction SilentlyContinue |
        Enable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null
}

# ── Logging ──────────────────────────────────────────────────────────────

function Get-AppLogPath {
    $dir = Join-Path $env:ProgramData 'HardeningGUI'
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    return (Join-Path $dir 'hardeninggui.log')
}

function Write-AppLog {
    param(
        [Parameter(Mandatory)][string]$Level,
        [Parameter(Mandatory)][string]$Message
    )

    $line = "[{0}] [{1}] {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level.ToUpperInvariant(), $Message
    try {
        Add-Content -Path (Get-AppLogPath) -Value $line -Encoding UTF8
    }
    catch {}
}

function Write-AppError {
    param(
        [Parameter(Mandatory)][string]$Context,
        [Parameter(Mandatory)]$ErrorRecord
    )

    $message = if ($ErrorRecord.Exception) { $ErrorRecord.Exception.Message } else { "$ErrorRecord" }
    Write-AppLog -Level 'ERROR' -Message "$Context :: $message"
}

function Test-SettingEnabled {
    param([Parameter(Mandatory)]$Setting)

    try {
        return [bool](& $Setting.Check)
    }
    catch {
        return $false
    }
}

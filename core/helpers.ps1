<#
.SYNOPSIS
    Infrastructure helpers for Windows 11 Hardening Suite
.NOTES
    Dot-sourced by Run-Hardening.ps1 before any other module.
    Provides: WinForms init, registry/service/task helpers,
              firewall, logging, backup, rollback, startup self-check,
              Test-SettingEnabled.
#>

# ── WinForms ─────────────────────────────────────────────────────────────

function Initialize-WinForms {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()
}

# ── Registry ──────────────────────────────────────────────────────────────

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
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction Stop
}

function Get-Reg {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        $Default = $null
    )

    try {
        return (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
    } catch {
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

function Remove-RegKey {
    param(
        [Parameter(Mandatory)][string]$Path
    )
    Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
}

# ── Services & Tasks ──────────────────────────────────────────────────────

function Set-ServiceDisabled {
    param([Parameter(Mandatory)][string]$Name)

    if (Get-Service -Name $Name -ErrorAction SilentlyContinue) {
        Stop-Service -Name $Name -Force -ErrorAction SilentlyContinue
        Set-Service  -Name $Name -StartupType Disabled -ErrorAction SilentlyContinue
    }
}

function Set-ServiceManual {
    param([Parameter(Mandatory)][string]$Name)

    if (Get-Service -Name $Name -ErrorAction SilentlyContinue) {
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

# ── Logging ───────────────────────────────────────────────────────────────

$script:_logPath = $null

function Get-AppLogPath {
    if (-not $script:_logPath) {
        $dir = Join-Path $env:ProgramData 'HardeningGUI'
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
        $script:_logPath = Join-Path $dir 'hardeninggui.log'
    }
    return $script:_logPath
}

function Write-AppLog {
    param(
        [Parameter(Mandatory)][string]$Level,
        [Parameter(Mandatory)][string]$Message
    )

    $line = '[{0}] [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level.ToUpperInvariant(), $Message
    try {
        $writer = [System.IO.StreamWriter]::new((Get-AppLogPath), $true, [System.Text.Encoding]::UTF8)
        try   { $writer.WriteLine($line) }
        finally { $writer.Dispose() }
    } catch {}
}

function Write-AppError {
    param(
        [Parameter(Mandatory)][string]$Context,
        [Parameter(Mandatory)]$ErrorRecord
    )

    $message = if ($ErrorRecord.Exception) { $ErrorRecord.Exception.Message } else { "$ErrorRecord" }
    $location = if ($ErrorRecord.InvocationInfo) {
        $ErrorRecord.InvocationInfo.ScriptName + ':' + $ErrorRecord.InvocationInfo.ScriptLineNumber
    } else { '' }
    $details = if ($location) { "$Context :: $message [$location]" } else { "$Context :: $message" }
    Write-AppLog -Level 'ERROR' -Message $details
}

# ── Startup self-check ────────────────────────────────────────────────────

function Invoke-StartupSelfCheck {
    param(
        [Parameter(Mandatory)][string]$RootPath,
        [Parameter(Mandatory)]$Settings
    )

    $result = [PSCustomObject]@{
        Errors   = [System.Collections.ArrayList]::new()
        Warnings = [System.Collections.ArrayList]::new()
    }

    if (-not $Settings -or $Settings.Count -eq 0) {
        [void]$result.Errors.Add('Get-HardeningSettings() повернув порожній список.')
        return $result
    }

    $requiredProps = 'Group', 'Name', 'Desc', 'Apply', 'Revert', 'Check'
    $index = 0
    foreach ($s in $Settings) {
        foreach ($prop in $requiredProps) {
            if (-not $s.PSObject.Properties[$prop]) {
                [void]$result.Errors.Add("Settings[$index] відсутнє поле '$prop'")
            }
        }
        $index++
    }

    return $result
}

function Test-SettingEnabled {
    param([Parameter(Mandatory)]$Setting)
    try   { return [bool](& $Setting.Check) }
    catch { return $false }
}

# ── Firewall ─────────────────────────────────────────────────────────────

function Set-FirewallRule {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Direction,
        [string]$Protocol = 'TCP',
        [string]$LocalPort,
        [string]$Action = 'Block',
        [string]$Profile = 'Any'
    )
    $exists = Get-NetFirewallRule -DisplayName $Name -ErrorAction SilentlyContinue
    if ($exists) { Remove-NetFirewallRule -DisplayName $Name -ErrorAction SilentlyContinue }
    $params = @{
        DisplayName = $Name
        Direction   = $Direction
        Action      = $Action
        Profile     = $Profile
        Enabled     = 'True'
    }
    if ($Protocol -and $Protocol -ne 'Any') { $params.Protocol = $Protocol }
    if ($LocalPort) { $params.LocalPort = $LocalPort }
    New-NetFirewallRule @params | Out-Null
}

# ── Admin check ──────────────────────────────────────────────────────────

function Test-AdminRequired {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Необхідні права адміністратора"
    }
}

# ── Backup & Rollback ────────────────────────────────────────────────────

function Backup-RegistryKey {
    param([Parameter(Mandatory)][string]$Path)
    $backupDir = Join-Path $env:ProgramData 'win11-hardening\backup'
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    $safeName = $Path -replace '[:\\]', '-'
    $outFile  = Join-Path $backupDir "$safeName-$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"
    reg export $Path $outFile /y 2>$null
    Write-AppLog -Level 'INFO' -Message "Backup: $Path -> $outFile"
}

function Invoke-WithRollback {
    param(
        [Parameter(Mandatory)][scriptblock]$Apply,
        [Parameter(Mandatory)][scriptblock]$Revert,
        [Parameter(Mandatory)][string]$Name
    )
    try {
        Write-AppLog -Level 'INFO' -Message "Застосування: $Name"
        & $Apply
        Write-AppLog -Level 'INFO' -Message "OK: $Name"
    } catch {
        Write-AppLog -Level 'ERROR' -Message "ПОМИЛКА в $Name — відкат: $_"
        try { & $Revert } catch {
            Write-AppLog -Level 'ERROR' -Message "Відкат також не вдався для $Name : $_"
        }
    }
}

<#
.SYNOPSIS
    Windows 11 Hardening GUI — єдина програма керування параметрами безпеки
.NOTES
    Вимоги: PowerShell 5.1+, права адміністратора
    Запуск: Right-click → Run with PowerShell (або через Run.bat)
#>

# ── Самопідвищення прав ────────────────────────────────────────────────────
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ══════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ══════════════════════════════════════════════════════════════════════════

function Set-Reg {
    param([string]$Path, [string]$Name, $Value, [string]$Type = 'DWord')
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction SilentlyContinue
}

function Get-Reg {
    param([string]$Path, [string]$Name, $Default = $null)
    try { return (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name }
    catch { return $Default }
}

function Set-ServiceDisabled {
    param([string]$Name)
    $s = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($s) {
        Stop-Service  -Name $Name -Force -ErrorAction SilentlyContinue
        Set-Service   -Name $Name -StartupType Disabled -ErrorAction SilentlyContinue
    }
}

function Set-ServiceManual {
    param([string]$Name)
    $s = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($s) { Set-Service -Name $Name -StartupType Manual -ErrorAction SilentlyContinue }
}

function Disable-Task { param([string]$Path,[string]$Name)
    Get-ScheduledTask -TaskPath $Path -TaskName $Name -ErrorAction SilentlyContinue |
        Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null }

function Enable-Task { param([string]$Path,[string]$Name)
    Get-ScheduledTask -TaskPath $Path -TaskName $Name -ErrorAction SilentlyContinue |
        Enable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null }

# ══════════════════════════════════════════════════════════════════════════
# SETTINGS DEFINITIONS
# Кожен запис: Name, Description, Group, Apply{}, Revert{}, Check{}
# ══════════════════════════════════════════════════════════════════════════

$Settings = @(

    # ── UAC ──────────────────────────────────────────────────────────────
    [PSCustomObject]@{
        Group = "UAC / Вхід до системи"
        Name  = "UAC рівень 5 — підтвердження без пароля"
        Desc  = "ConsentPromptBehaviorAdmin=5: сповіщення без запиту пароля (без secure desktop)"
        Apply = {
            $p = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            Set-Reg $p "EnableLUA"                        1
            Set-Reg $p "ConsentPromptBehaviorAdmin"       5
            Set-Reg $p "ConsentPromptBehaviorUser"        3
            Set-Reg $p "PromptOnSecureDesktop"            0
            Set-Reg $p "EnableInstallerDetection"         1
            Set-Reg $p "FilterAdministratorToken"         0
        }
        Revert = {
            $p = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            Set-Reg $p "ConsentPromptBehaviorAdmin"       1
            Set-Reg $p "PromptOnSecureDesktop"            1
        }
        Check = {
            (Get-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ConsentPromptBehaviorAdmin" -1) -eq 5
        }
    },

    [PSCustomObject]@{
        Group = "UAC / Вхід до системи"
        Name  = "Вимкнути Ctrl+Alt+Del на екрані входу"
        Desc  = "DisableCAD=1: не вимагати натискання Ctrl+Alt+Del перед входом"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableCAD" 1
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableCAD" 0
        }
        Check = {
            (Get-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableCAD" 0) -eq 1
        }
    },

    [PSCustomObject]@{
        Group = "UAC / Вхід до системи"
        Name  = "Не показувати мережеве меню на екрані входу"
        Desc  = "DontDisplayNetworkSelectionUI=1"
        Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DontDisplayNetworkSelectionUI" 1 }
        Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DontDisplayNetworkSelectionUI" 0 }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DontDisplayNetworkSelectionUI" 0) -eq 1 }
    },

    # ── ПАРОЛЬ ───────────────────────────────────────────────────────────
    [PSCustomObject]@{
        Group = "Паролі"
        Name  = "Мінімальна довжина пароля = 10"
        Desc  = "net accounts /minpwlen:10"
        Apply  = { net accounts /minpwlen:10 2>$null | Out-Null }
        Revert = { net accounts /minpwlen:0  2>$null | Out-Null }
        Check  = {
            $out = net accounts 2>$null
            $line = $out | Where-Object { $_ -match 'Minimum password length' -or $_ -match 'Мінімальна довжина' }
            if ($line) { $line -match ':\s*10\b' } else { $false }
        }
    },

    [PSCustomObject]@{
        Group = "Паролі"
        Name  = "Заборонити порожні паролі (лише консоль)"
        Desc  = "LimitBlankPasswordUse=1"
        Apply  = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LimitBlankPasswordUse" 1 }
        Revert = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LimitBlankPasswordUse" 0 }
        Check  = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LimitBlankPasswordUse" 0) -eq 1 }
    },

    # ── МОНІТОРИНГ / DEFENDER ─────────────────────────────────────────────
    [PSCustomObject]@{
        Group = "Моніторинг / Defender"
        Name  = "Вимкнути Real-Time моніторинг Defender"
        Desc  = "DisableRealtimeMonitoring=1"
        Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableRealtimeMonitoring" 1 }
        Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableRealtimeMonitoring" 0 }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableRealtimeMonitoring" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "Моніторинг / Defender"
        Name  = "Вимкнути Behavior Monitoring"
        Desc  = "DisableBehaviorMonitoring=1"
        Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableBehaviorMonitoring" 1 }
        Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableBehaviorMonitoring" 0 }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableBehaviorMonitoring" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "Моніторинг / Defender"
        Name  = "Вимкнути Cloud Protection (MAPS)"
        Desc  = "SpynetReporting=0, SubmitSamplesConsent=2"
        Apply  = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "SpynetReporting"       0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "SubmitSamplesConsent"  2
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "SpynetReporting"       2
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "SubmitSamplesConsent"  1
        }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "SpynetReporting" -1) -eq 0 }
    },

    [PSCustomObject]@{
        Group = "Моніторинг / Defender"
        Name  = "Вимкнути Script Scanning"
        Desc  = "DisableScriptScanning=1"
        Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableScriptScanning" 1 }
        Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableScriptScanning" 0 }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableScriptScanning" 0) -eq 1 }
    },

    # ── SMARTSCREEN ───────────────────────────────────────────────────────
    [PSCustomObject]@{
        Group = "SmartScreen / Recall / Telemetry"
        Name  = "Вимкнути SmartScreen (Explorer)"
        Desc  = "EnableSmartScreen=0 — вимкнути перевірку завантажень у провіднику"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableSmartScreen"     0
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" "SmartScreenEnabled" "Off" "String"
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableSmartScreen"     1
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" "SmartScreenEnabled" "Warn" "String"
        }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableSmartScreen" 1) -eq 0 }
    },

    [PSCustomObject]@{
        Group = "SmartScreen / Recall / Telemetry"
        Name  = "Вимкнути SmartScreen сервіс (webthreatdefsvc)"
        Desc  = "Зупинити та вимкнути сервіс webthreatdefsvc + webthreatdefusersvc"
        Apply = {
            Set-ServiceDisabled "webthreatdefsvc"
            Set-ServiceDisabled "webthreatdefusersvc_*"
            Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\webthreatdefsvc" "Start" 4
        }
        Revert = {
            Set-ServiceManual "webthreatdefsvc"
            Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\webthreatdefsvc" "Start" 3
        }
        Check  = {
            $s = Get-Service "webthreatdefsvc" -ErrorAction SilentlyContinue
            $s -and $s.StartType -eq 'Disabled'
        }
    },

    [PSCustomObject]@{
        Group = "SmartScreen / Recall / Telemetry"
        Name  = "Вимкнути Windows Recall (AIX сервіс)"
        Desc  = "Вимкнути сервіс Recall/Copilot AI snapshots"
        Apply = {
            Set-ServiceDisabled "AiXHostService"
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" 1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "AllowRecallEnablement"  0
        }
        Revert = {
            Set-ServiceManual "AiXHostService"
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis"  0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "AllowRecallEnablement"   1
        }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "SmartScreen / Recall / Telemetry"
        Name  = "Вимкнути телеметрію (DiagTrack)"
        Desc  = "AllowTelemetry=0 + зупинити сервіс DiagTrack"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0
            Set-ServiceDisabled "DiagTrack"
            Set-ServiceDisabled "dmwappushservice"
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 1
            Set-ServiceManual "DiagTrack"
        }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" -1) -eq 0 }
    },

    # ── СЕРВІСИ: HISTORY / LOGS / FOOTPRINT ──────────────────────────────
    [PSCustomObject]@{
        Group = "Сервіси: History / Logs / Footprint"
        Name  = "Вимкнути Activity History (Timeline)"
        Desc  = "PublishUserActivities=0, UploadUserActivities=0"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "PublishUserActivities" 0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "UploadUserActivities"  0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableActivityFeed"    0
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "PublishUserActivities" 1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "UploadUserActivities"  1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableActivityFeed"    1
        }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "PublishUserActivities" 1) -eq 0 }
    },

    [PSCustomObject]@{
        Group = "Сервіси: History / Logs / Footprint"
        Name  = "Вимкнути Windows Error Reporting"
        Desc  = "Зупинити WerSvc, вимкнути WER"
        Apply = {
            Set-ServiceDisabled "WerSvc"
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" "Disabled" 1
        }
        Revert = {
            Set-ServiceManual "WerSvc"
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" "Disabled" 0
        }
        Check  = {
            $s = Get-Service "WerSvc" -ErrorAction SilentlyContinue
            $s -and $s.StartType -eq 'Disabled'
        }
    },

    [PSCustomObject]@{
        Group = "Сервіси: History / Logs / Footprint"
        Name  = "Вимкнути Diagnostics Policy Service (DPS)"
        Desc  = "Зупинити сервіс DPS (troubleshooting)"
        Apply  = { Set-ServiceDisabled "DPS" }
        Revert = { Set-ServiceManual   "DPS" }
        Check  = {
            $s = Get-Service "DPS" -ErrorAction SilentlyContinue
            $s -and $s.StartType -eq 'Disabled'
        }
    },

    [PSCustomObject]@{
        Group = "Сервіси: History / Logs / Footprint"
        Name  = "Вимкнути Diagnostics Tracking (dmwappushservice)"
        Desc  = "WAP Push message routing service"
        Apply  = { Set-ServiceDisabled "dmwappushservice" }
        Revert = { Set-ServiceManual   "dmwappushservice" }
        Check  = {
            $s = Get-Service "dmwappushservice" -ErrorAction SilentlyContinue
            $s -and $s.StartType -eq 'Disabled'
        }
    },

    [PSCustomObject]@{
        Group = "Сервіси: History / Logs / Footprint"
        Name  = "Вимкнути Connected User Experiences (CDPSvc / SysMain)"
        Desc  = "CDPSvc=відстеження активності; SysMain=Superfetch (prefetch/cache)"
        Apply = {
            Set-ServiceDisabled "CDPSvc"
            Set-ServiceDisabled "CDPUserSvc"
            Set-ServiceDisabled "SysMain"
        }
        Revert = {
            Set-ServiceManual "CDPSvc"
            Set-ServiceManual "SysMain"
        }
        Check  = {
            $s = Get-Service "SysMain" -ErrorAction SilentlyContinue
            $s -and $s.StartType -eq 'Disabled'
        }
    },

    [PSCustomObject]@{
        Group = "Сервіси: History / Logs / Footprint"
        Name  = "Вимкнути Prefetch"
        Desc  = "EnablePrefetcher=0, EnableSuperfetch=0 у реєстрі"
        Apply = {
            $p = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
            Set-Reg $p "EnablePrefetcher"   0
            Set-Reg $p "EnableSuperfetch"   0
        }
        Revert = {
            $p = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
            Set-Reg $p "EnablePrefetcher"   3
            Set-Reg $p "EnableSuperfetch"   3
        }
        Check  = {
            $p = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
            (Get-Reg $p "EnablePrefetcher" 3) -eq 0
        }
    },

    # ── СЕРВІСИ: BACKUP / RECOVERY ────────────────────────────────────────
    [PSCustomObject]@{
        Group = "Сервіси: Backup / Recovery"
        Name  = "Вимкнути Volume Shadow Copy (VSS)"
        Desc  = "Зупинити VSS — тіньові копії диска"
        Apply  = { Set-ServiceDisabled "VSS" }
        Revert = { Set-ServiceManual   "VSS" }
        Check  = {
            $s = Get-Service "VSS" -ErrorAction SilentlyContinue
            $s -and $s.StartType -eq 'Disabled'
        }
    },

    [PSCustomObject]@{
        Group = "Сервіси: Backup / Recovery"
        Name  = "Вимкнути Windows Backup (SDRSVC)"
        Desc  = "Зупинити SDRSVC — служба резервного копіювання"
        Apply  = { Set-ServiceDisabled "SDRSVC" }
        Revert = { Set-ServiceManual   "SDRSVC" }
        Check  = {
            $s = Get-Service "SDRSVC" -ErrorAction SilentlyContinue
            $s -and $s.StartType -eq 'Disabled'
        }
    },

    [PSCustomObject]@{
        Group = "Сервіси: Backup / Recovery"
        Name  = "Вимкнути System Restore (SR)"
        Desc  = "Відключити точки відновлення системи"
        Apply = {
            Set-ServiceDisabled "SDRSVC"
            Disable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        }
        Revert = {
            Set-ServiceManual "SDRSVC"
            Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        }
        Check  = {
            $rp = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -ErrorAction SilentlyContinue
            $rp -and $rp.RPSessionInterval -eq 0
        }
    },

    [PSCustomObject]@{
        Group = "Сервіси: Backup / Recovery"
        Name  = "Вимкнути Windows Recovery Environment реклам"
        Desc  = "Відключити автоматичне завантаження WinRE tasks"
        Apply = {
            Disable-Task "\Microsoft\Windows\RecoveryEnvironment\" "VerifyWinRE"
        }
        Revert = {
            Enable-Task "\Microsoft\Windows\RecoveryEnvironment\" "VerifyWinRE"
        }
        Check  = {
            $t = Get-ScheduledTask -TaskPath "\Microsoft\Windows\RecoveryEnvironment\" -TaskName "VerifyWinRE" -ErrorAction SilentlyContinue
            $t -and $t.State -eq 'Disabled'
        }
    },

    # ── СЕРВІСИ: TROUBLESHOOTING ──────────────────────────────────────────
    [PSCustomObject]@{
        Group = "Сервіси: Troubleshooting"
        Name  = "Вимкнути автоматичне усунення несправностей"
        Desc  = "Microsoft Support Diagnostic Tool + автозапуск тробл-шутерів"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\ScriptedDiagnostics"         "EnableDiagnostics" 0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WDI\{C295FBBA-FD47-46AC-8BEE-B1715EC634E7}" "ScenarioExecutionEnabled" 0
            Disable-Task "\Microsoft\Windows\Diagnosis\" "Scheduled"
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\ScriptedDiagnostics"         "EnableDiagnostics" 1
            Enable-Task "\Microsoft\Windows\Diagnosis\" "Scheduled"
        }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\ScriptedDiagnostics" "EnableDiagnostics" 1) -eq 0 }
    },

    [PSCustomObject]@{
        Group = "Сервіси: Troubleshooting"
        Name  = "Вимкнути Compatibility Telemetry (AppCompat)"
        Desc  = "DisableInventory=1, DisableUAR=1"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableInventory"  1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableUAR"        1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisablePCA"        1
            Disable-Task "\Microsoft\Windows\Application Experience\" "Microsoft Compatibility Appraiser"
            Disable-Task "\Microsoft\Windows\Application Experience\" "ProgramDataUpdater"
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableInventory"  0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableUAR"        0
            Enable-Task "\Microsoft\Windows\Application Experience\" "Microsoft Compatibility Appraiser"
        }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableInventory" 0) -eq 1 }
    },

    # ── СЕРВІСИ: CACHE / ІНДЕКСАЦІЯ ───────────────────────────────────────
    [PSCustomObject]@{
        Group = "Сервіси: Cache / Індексація"
        Name  = "Вимкнути Windows Search Indexing"
        Desc  = "Зупинити WSearch — індексація файлів"
        Apply  = {
            Set-ServiceDisabled "WSearch"
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana"            0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch"        1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "ConnectedSearchUseWeb"   0
        }
        Revert = { Set-ServiceManual "WSearch" }
        Check  = {
            $s = Get-Service "WSearch" -ErrorAction SilentlyContinue
            $s -and $s.StartType -eq 'Disabled'
        }
    },

    [PSCustomObject]@{
        Group = "Сервіси: Cache / Індексація"
        Name  = "Вимкнути DNS-кеш клієнт (dnscache)"
        Desc  = "Вимкнути локальний DNS-кеш"
        Apply  = { Set-ServiceDisabled "dnscache" }
        Revert = { Set-ServiceManual   "dnscache" }
        Check  = {
            $s = Get-Service "dnscache" -ErrorAction SilentlyContinue
            $s -and $s.StartType -eq 'Disabled'
        }
    },

    [PSCustomObject]@{
        Group = "Сервіси: Cache / Індексація"
        Name  = "Вимкнути Delivery Optimization (BITS cache)"
        Desc  = "Вимкнути DoSvc — P2P оновлення та кешування"
        Apply  = {
            Set-ServiceDisabled "DoSvc"
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode" 0
        }
        Revert = {
            Set-ServiceManual "DoSvc"
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode" 1
        }
        Check  = {
            $s = Get-Service "DoSvc" -ErrorAction SilentlyContinue
            $s -and $s.StartType -eq 'Disabled'
        }
    }
)

# ══════════════════════════════════════════════════════════════════════════
# GUI BUILDER
# ══════════════════════════════════════════════════════════════════════════

$form = New-Object System.Windows.Forms.Form
$form.Text          = "Windows 11 Hardening Control Panel"
$form.Size          = New-Object System.Drawing.Size(860, 720)
$form.MinimumSize   = New-Object System.Drawing.Size(760, 600)
$form.StartPosition = "CenterScreen"
$form.BackColor     = [System.Drawing.Color]::FromArgb(18, 18, 24)
$form.ForeColor     = [System.Drawing.Color]::FromArgb(220, 220, 230)
$form.Font          = New-Object System.Drawing.Font("Segoe UI", 9)

# ── Title bar ─────────────────────────────────────────────────────────────
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text      = "  Windows 11 Hardening Control Panel"
$lblTitle.Dock      = "Top"
$lblTitle.Height    = 42
$lblTitle.Font      = New-Object System.Drawing.Font("Segoe UI Semibold", 13)
$lblTitle.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 40)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(100, 180, 255)
$lblTitle.TextAlign = "MiddleLeft"
$form.Controls.Add($lblTitle)

# ── Status bar ────────────────────────────────────────────────────────────
$statusBar = New-Object System.Windows.Forms.Label
$statusBar.Dock      = "Bottom"
$statusBar.Height    = 26
$statusBar.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 35)
$statusBar.ForeColor = [System.Drawing.Color]::FromArgb(160, 160, 170)
$statusBar.TextAlign = "MiddleLeft"
$statusBar.Text      = "  Готово."
$statusBar.Font      = New-Object System.Drawing.Font("Segoe UI", 8.5)
$form.Controls.Add($statusBar)

# ── Bottom button panel ───────────────────────────────────────────────────
$btnPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$btnPanel.Dock          = "Bottom"
$btnPanel.Height        = 48
$btnPanel.BackColor     = [System.Drawing.Color]::FromArgb(22, 22, 32)
$btnPanel.FlowDirection = "LeftToRight"
$btnPanel.Padding       = New-Object System.Windows.Forms.Padding(10, 8, 0, 0)

function New-Btn {
    param([string]$Text, [string]$ColorHex, [string]$ToolTip = "")
    $b = New-Object System.Windows.Forms.Button
    $b.Text      = $Text
    $b.Height    = 30
    $b.Width     = 150
    $b.Margin    = New-Object System.Windows.Forms.Padding(0, 0, 8, 0)
    $b.FlatStyle = "Flat"
    $b.FlatAppearance.BorderSize = 1
    $b.BackColor = [System.Drawing.ColorTranslator]::FromHtml($ColorHex)
    $b.ForeColor = [System.Drawing.Color]::White
    $b.Font      = New-Object System.Drawing.Font("Segoe UI Semibold", 9)
    $b.Cursor    = "Hand"
    if ($ToolTip) {
        $tt = New-Object System.Windows.Forms.ToolTip
        $tt.SetToolTip($b, $ToolTip)
    }
    return $b
}

$btnApplyAll  = New-Btn "Застосувати все"   "#1a6b3a" "Застосувати всі увімкнені параметри"
$btnRevertAll = New-Btn "Скасувати все"     "#7a2020" "Скасувати всі параметри (повернути до стандарту)"
$btnRefresh   = New-Btn "Оновити стани"     "#1a3a6b" "Перечитати поточні значення реєстру/сервісів"
$btnApplySelected = New-Btn "Застосувати вибране" "#3a5a1a" "Застосувати тільки відмічені параметри"

$btnPanel.Controls.AddRange(@($btnApplyAll, $btnApplySelected, $btnRevertAll, $btnRefresh))
$form.Controls.Add($btnPanel)

# ── Main scroll panel ─────────────────────────────────────────────────────
$scroll = New-Object System.Windows.Forms.Panel
$scroll.Dock        = "Fill"
$scroll.AutoScroll  = $true
$scroll.BackColor   = [System.Drawing.Color]::FromArgb(18, 18, 24)
$scroll.Padding     = New-Object System.Windows.Forms.Padding(0)
$form.Controls.Add($scroll)

# ── Row factory ──────────────────────────────────────────────────────────
$rowControls = [System.Collections.ArrayList]::new()  # {Checkbox, ToggleBtn, Setting, StatusLbl}

function Get-SettingStatus {
    param($setting)
    try { return [bool](& $setting.Check) }
    catch { return $false }
}

function Build-Rows {
    $scroll.Controls.Clear()
    $rowControls.Clear()

    $y         = 8
    $lastGroup = ""
    $rowIndex  = 0

    foreach ($s in $Settings) {
        # Group header
        if ($s.Group -ne $lastGroup) {
            $lbl = New-Object System.Windows.Forms.Label
            $lbl.Text      = "  " + $s.Group
            $lbl.Location  = New-Object System.Drawing.Point(10, $y)
            $lbl.Size      = New-Object System.Drawing.Size(820, 28)
            $lbl.Font      = New-Object System.Drawing.Font("Segoe UI Semibold", 10)
            $lbl.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 50)
            $lbl.ForeColor = [System.Drawing.Color]::FromArgb(130, 190, 255)
            $scroll.Controls.Add($lbl)
            $y += 32
            $lastGroup = $s.Group
        }

        # Row panel
        $rowBg = if ($rowIndex % 2 -eq 0) { [System.Drawing.Color]::FromArgb(24,24,33) } else { [System.Drawing.Color]::FromArgb(28,28,38) }
        $row = New-Object System.Windows.Forms.Panel
        $row.Location  = New-Object System.Drawing.Point(10, $y)
        $row.Size      = New-Object System.Drawing.Size(820, 46)
        $row.BackColor = $rowBg

        # Checkbox (select for batch)
        $chk = New-Object System.Windows.Forms.CheckBox
        $chk.Location  = New-Object System.Drawing.Point(8, 14)
        $chk.Size      = New-Object System.Drawing.Size(20, 20)
        $chk.BackColor = $rowBg

        # Status indicator
        $active = Get-SettingStatus $s
        $statusDot = New-Object System.Windows.Forms.Label
        $statusDot.Location  = New-Object System.Drawing.Point(32, 8)
        $statusDot.Size      = New-Object System.Drawing.Size(10, 30)
        $statusDot.Text      = ""
        $statusDot.BackColor = if ($active) { [System.Drawing.Color]::FromArgb(40,180,80) } else { [System.Drawing.Color]::FromArgb(160,40,40) }

        # Name label
        $lblName = New-Object System.Windows.Forms.Label
        $lblName.Text      = "  " + $s.Name
        $lblName.Location  = New-Object System.Drawing.Point(46, 4)
        $lblName.Size      = New-Object System.Drawing.Size(480, 20)
        $lblName.Font      = New-Object System.Drawing.Font("Segoe UI", 9)
        $lblName.ForeColor = [System.Drawing.Color]::FromArgb(220,220,230)
        $lblName.BackColor = $rowBg

        # Desc label
        $lblDesc = New-Object System.Windows.Forms.Label
        $lblDesc.Text      = "  " + $s.Desc
        $lblDesc.Location  = New-Object System.Drawing.Point(46, 24)
        $lblDesc.Size      = New-Object System.Drawing.Size(480, 18)
        $lblDesc.Font      = New-Object System.Drawing.Font("Segoe UI", 7.5)
        $lblDesc.ForeColor = [System.Drawing.Color]::FromArgb(130,130,150)
        $lblDesc.BackColor = $rowBg

        # Status text
        $statusLbl = New-Object System.Windows.Forms.Label
        $statusLbl.Location  = New-Object System.Drawing.Point(530, 14)
        $statusLbl.Size      = New-Object System.Drawing.Size(90, 18)
        $statusLbl.Font      = New-Object System.Drawing.Font("Segoe UI Semibold", 8)
        $statusLbl.TextAlign = "MiddleCenter"
        $statusLbl.BackColor = $rowBg
        if ($active) {
            $statusLbl.Text      = "УВІМКНЕНО"
            $statusLbl.ForeColor = [System.Drawing.Color]::FromArgb(60,200,100)
        } else {
            $statusLbl.Text      = "вимкнено"
            $statusLbl.ForeColor = [System.Drawing.Color]::FromArgb(160,160,180)
        }

        # Toggle button
        $toggleBtn = New-Object System.Windows.Forms.Button
        $toggleBtn.Location  = New-Object System.Drawing.Point(626, 9)
        $toggleBtn.Size      = New-Object System.Drawing.Size(90, 28)
        $toggleBtn.FlatStyle = "Flat"
        $toggleBtn.FlatAppearance.BorderSize = 1
        $toggleBtn.Font   = New-Object System.Drawing.Font("Segoe UI Semibold", 8.5)
        $toggleBtn.Cursor = "Hand"
        if ($active) {
            $toggleBtn.Text      = "Вимкнути"
            $toggleBtn.BackColor = [System.Drawing.Color]::FromArgb(90, 30, 30)
            $toggleBtn.ForeColor = [System.Drawing.Color]::FromArgb(255,140,140)
        } else {
            $toggleBtn.Text      = "Увімкнути"
            $toggleBtn.BackColor = [System.Drawing.Color]::FromArgb(20, 70, 30)
            $toggleBtn.ForeColor = [System.Drawing.Color]::FromArgb(120,220,140)
        }

        # Info button
        $infoBtn = New-Object System.Windows.Forms.Button
        $infoBtn.Location  = New-Object System.Drawing.Point(722, 9)
        $infoBtn.Size      = New-Object System.Drawing.Size(88, 28)
        $infoBtn.FlatStyle = "Flat"
        $infoBtn.FlatAppearance.BorderSize = 1
        $infoBtn.Text      = "Деталі"
        $infoBtn.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 55)
        $infoBtn.ForeColor = [System.Drawing.Color]::FromArgb(150,180,255)
        $infoBtn.Font      = New-Object System.Drawing.Font("Segoe UI", 8.5)
        $infoBtn.Cursor    = "Hand"

        # Wire up events — capture variables explicitly
        $capturedS       = $s
        $capturedStatus  = $statusDot
        $capturedSLbl    = $statusLbl
        $capturedToggle  = $toggleBtn
        $capturedBar     = $statusBar
        $capturedRowBg   = $rowBg

        $toggleBtn.Add_Click({
            $isActive = Get-SettingStatus $capturedS
            try {
                if ($isActive) {
                    & $capturedS.Revert
                    $capturedBar.Text = "  [OK] Скасовано: $($capturedS.Name)"
                } else {
                    & $capturedS.Apply
                    $capturedBar.Text = "  [OK] Застосовано: $($capturedS.Name)"
                }
            } catch {
                $capturedBar.Text = "  [ПОМИЛКА] $($capturedS.Name): $_"
            }
            $now = Get-SettingStatus $capturedS
            if ($now) {
                $capturedStatus.BackColor  = [System.Drawing.Color]::FromArgb(40,180,80)
                $capturedSLbl.Text         = "УВІМКНЕНО"
                $capturedSLbl.ForeColor    = [System.Drawing.Color]::FromArgb(60,200,100)
                $capturedToggle.Text       = "Вимкнути"
                $capturedToggle.BackColor  = [System.Drawing.Color]::FromArgb(90,30,30)
                $capturedToggle.ForeColor  = [System.Drawing.Color]::FromArgb(255,140,140)
            } else {
                $capturedStatus.BackColor  = [System.Drawing.Color]::FromArgb(160,40,40)
                $capturedSLbl.Text         = "вимкнено"
                $capturedSLbl.ForeColor    = [System.Drawing.Color]::FromArgb(160,160,180)
                $capturedToggle.Text       = "Увімкнути"
                $capturedToggle.BackColor  = [System.Drawing.Color]::FromArgb(20,70,30)
                $capturedToggle.ForeColor  = [System.Drawing.Color]::FromArgb(120,220,140)
            }
        }.GetNewClosure())

        $infoBtn.Add_Click({
            [System.Windows.Forms.MessageBox]::Show(
                "Параметр: $($capturedS.Name)`n`n$($capturedS.Desc)`n`nГрупа: $($capturedS.Group)",
                "Деталі",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            ) | Out-Null
        }.GetNewClosure())

        $row.Controls.AddRange(@($chk, $statusDot, $lblName, $lblDesc, $statusLbl, $toggleBtn, $infoBtn))
        $scroll.Controls.Add($row)

        $null = $rowControls.Add([PSCustomObject]@{
            Checkbox = $chk
            Toggle   = $toggleBtn
            Setting  = $s
            StatusDot = $statusDot
            StatusLbl = $statusLbl
        })

        $y += 50
        $rowIndex++
    }

    # Spacer at bottom
    $spacer = New-Object System.Windows.Forms.Panel
    $spacer.Location  = New-Object System.Drawing.Point(0, $y)
    $spacer.Size      = New-Object System.Drawing.Size(1, 20)
    $spacer.BackColor = [System.Drawing.Color]::FromArgb(18,18,24)
    $scroll.Controls.Add($spacer)
    $scroll.AutoScrollMinSize = New-Object System.Drawing.Size(820, ($y + 30))
}

Build-Rows

# ── Button handlers ───────────────────────────────────────────────────────
$btnRefresh.Add_Click({
    $statusBar.Text = "  Оновлення станів..."
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    foreach ($rc in $rowControls) {
        $active = Get-SettingStatus $rc.Setting
        if ($active) {
            $rc.StatusDot.BackColor = [System.Drawing.Color]::FromArgb(40,180,80)
            $rc.StatusLbl.Text      = "УВІМКНЕНО"
            $rc.StatusLbl.ForeColor = [System.Drawing.Color]::FromArgb(60,200,100)
            $rc.Toggle.Text         = "Вимкнути"
            $rc.Toggle.BackColor    = [System.Drawing.Color]::FromArgb(90,30,30)
            $rc.Toggle.ForeColor    = [System.Drawing.Color]::FromArgb(255,140,140)
        } else {
            $rc.StatusDot.BackColor = [System.Drawing.Color]::FromArgb(160,40,40)
            $rc.StatusLbl.Text      = "вимкнено"
            $rc.StatusLbl.ForeColor = [System.Drawing.Color]::FromArgb(160,160,180)
            $rc.Toggle.Text         = "Увімкнути"
            $rc.Toggle.BackColor    = [System.Drawing.Color]::FromArgb(20,70,30)
            $rc.Toggle.ForeColor    = [System.Drawing.Color]::FromArgb(120,220,140)
        }
    }
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
    $statusBar.Text = "  Стани оновлено."
})

$btnApplyAll.Add_Click({
    $res = [System.Windows.Forms.MessageBox]::Show(
        "Застосувати ВСІ параметри?`nЦе змінить налаштування системи.",
        "Підтвердження", "YesNo", "Warning")
    if ($res -ne "Yes") { return }
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    $ok = 0; $err = 0
    foreach ($s in $Settings) {
        try { & $s.Apply; $ok++ }
        catch { $err++; $statusBar.Text = "  [ПОМИЛКА] $($s.Name): $_" }
    }
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
    & $btnRefresh.PerformClick
    $statusBar.Text = "  Готово: застосовано $ok, помилок $err."
})

$btnApplySelected.Add_Click({
    $selected = @($rowControls | Where-Object { $_.Checkbox.Checked })
    if ($selected.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Не вибрано жодного параметру.","Увага","OK","Information") | Out-Null
        return
    }
    $res = [System.Windows.Forms.MessageBox]::Show(
        "Застосувати $($selected.Count) вибраних параметрів?",
        "Підтвердження", "YesNo", "Question")
    if ($res -ne "Yes") { return }
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    $ok = 0; $err = 0
    foreach ($rc in $selected) {
        try { & $rc.Setting.Apply; $ok++ }
        catch { $err++ }
        $rc.Checkbox.Checked = $false
    }
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
    & $btnRefresh.PerformClick
    $statusBar.Text = "  Вибране застосовано: $ok OK, $err помилок."
})

$btnRevertAll.Add_Click({
    $res = [System.Windows.Forms.MessageBox]::Show(
        "СКАСУВАТИ всі параметри і повернути до стандарту Windows?",
        "Підтвердження", "YesNo", "Warning")
    if ($res -ne "Yes") { return }
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    foreach ($s in $Settings) {
        try { & $s.Revert } catch {}
    }
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
    & $btnRefresh.PerformClick
    $statusBar.Text = "  Всі параметри скасовано."
})

# ── Launch ────────────────────────────────────────────────────────────────
[System.Windows.Forms.Application]::Run($form)

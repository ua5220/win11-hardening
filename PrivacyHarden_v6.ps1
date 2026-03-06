<#
.SYNOPSIS
    Privacy & Security Hardening v5.0 UA — Maximum Privacy Edition
.NOTES
    Вимоги: PowerShell 5.1+, права адміністратора
#>

# ── Самопідвищення прав ────────────────────────────────────────────────────────
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Set-StrictMode -Version Latest
$ErrorActionPreference = 'SilentlyContinue'
$Is64   = [Environment]::Is64BitOperatingSystem
$IsWin11 = ([System.Environment]::OSVersion.Version.Build -ge 22000)
$LogFile = "$env:TEMP\PrivacyHarden_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# ══════════════════════════════════════════════════════════════════════════════
# БАЗОВІ ФУНКЦІЇ
# ══════════════════════════════════════════════════════════════════════════════

function Write-Log {
    param([string]$Msg, [ValidateSet('INFO','OK','WARN','ERROR','HEAD')][string]$L = 'INFO')
    $icon  = @{ INFO='[i]'; OK='[+]'; WARN='[!]'; ERROR='[x]'; HEAD='[=]' }[$L]
    $color = switch ($L) { 'OK'{'Green'} 'WARN'{'Yellow'} 'ERROR'{'Red'} 'HEAD'{'Cyan'} default{'White'} }
    $line  = "[{0}] {1} {2}" -f (Get-Date -Format 'HH:mm:ss'), $icon, $Msg
    Write-Host $line -ForegroundColor $color
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

function Set-Reg {
    param([string]$P, [string]$N, $V, [string]$T = 'DWord')
    try {
        if (-not (Test-Path $P)) { New-Item -Path $P -Force | Out-Null }
        Set-ItemProperty -Path $P -Name $N -Value $V -Type $T -Force
    } catch { Write-Log "Set-Reg помилка [$P\$N]: $_" 'ERROR' }
}

function Remove-Reg {
    param([string]$P, [string]$N = $null)
    if ($N) { Remove-ItemProperty -Path $P -Name $N -Force -ErrorAction SilentlyContinue }
    else    { Remove-Item -Path $P -Recurse -Force -ErrorAction SilentlyContinue }
}

function Disable-Svc {
    param([string]$Name)
    $s = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($s) {
        Stop-Service  -Name $Name -Force -ErrorAction SilentlyContinue
        Set-Service   -Name $Name -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Log "Сервіс вимкнено: $Name" 'OK'
    }
}

function Disable-Task {
    param([string]$Path, [string]$Name)
    $t = Get-ScheduledTask -TaskPath $Path -TaskName $Name -ErrorAction SilentlyContinue
    if ($t) { Disable-ScheduledTask -TaskPath $Path -TaskName $Name -ErrorAction SilentlyContinue | Out-Null }
}

function Add-FirewallBlock {
    param([string]$Name, [string[]]$IPs)
    Remove-NetFirewallRule -DisplayName $Name -ErrorAction SilentlyContinue
    New-NetFirewallRule -DisplayName $Name -Direction Outbound `
        -RemoteAddress $IPs -Action Block -Profile Any -Enabled True | Out-Null
    Write-Log "Firewall: заблоковано '$Name'" 'OK'
}

# ══════════════════════════════════════════════════════════════════════════════
# СИСТЕМА ПІДМЕНЮ
# ══════════════════════════════════════════════════════════════════════════════

function Show-SubMenu {
    param([string]$Title, [System.Collections.ArrayList]$Items)
    do {
        Clear-Host
        Write-Host ""
        Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "  ║  $Title" -ForegroundColor Cyan
        Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  Стан: " -NoNewline
        Write-Host "[+ ЗАХИЩЕНО]" -ForegroundColor Green -NoNewline
        Write-Host "  /  " -NoNewline
        Write-Host "[x ВРАЗЛИВО]" -ForegroundColor Red
        Write-Host ""

        for ($i = 0; $i -lt $Items.Count; $i++) {
            $item   = $Items[$i]
            $isHard = $false
            try { $isHard = [bool](& $item.Check) } catch {}
            $num   = "{0,2}" -f ($i + 1)
            $badge = if ($isHard) { "[+]" } else { "[x]" }
            $color = if ($isHard) { 'Green' } else { 'Red' }
            Write-Host "  [$num] " -NoNewline
            Write-Host $badge -ForegroundColor $color -NoNewline
            Write-Host "  $($item.Name)"
        }

        Write-Host ""
        Write-Host "  [A]  Захистити всi пункти"   -ForegroundColor Yellow
        Write-Host "  [R]  Вiдкатити всi до стандарту" -ForegroundColor DarkYellow
        Write-Host "  [Q]  Назад"                   -ForegroundColor DarkGray
        Write-Host ""

        $raw = (Read-Host "  Оберiть номер або команду").Trim().ToUpper()

        switch ($raw) {
            'A' {
                foreach ($item in $Items) {
                    try { & $item.Harden } catch { Write-Log "Harden помилка: $($item.Name) — $_" 'ERROR' }
                }
                Write-Log "Усi пункти захищено: $Title" 'OK'
                Start-Sleep -Milliseconds 800
            }
            'R' {
                foreach ($item in $Items) {
                    try { & $item.Restore } catch { Write-Log "Restore помилка: $($item.Name) — $_" 'ERROR' }
                }
                Write-Log "Усi пункти вiдкатано: $Title" 'WARN'
                Start-Sleep -Milliseconds 800
            }
            'Q' { return }
            default {
                if ($raw -match '^\d+$') {
                    $idx = [int]$raw - 1
                    if ($idx -ge 0 -and $idx -lt $Items.Count) {
                        $item   = $Items[$idx]
                        $isHard = $false
                        try { $isHard = [bool](& $item.Check) } catch {}
                        if ($isHard) {
                            try { & $item.Restore } catch { Write-Log "Restore помилка: $($item.Name)" 'ERROR' }
                            Write-Log "Вiдкатано: $($item.Name)" 'WARN'
                        } else {
                            try { & $item.Harden } catch { Write-Log "Harden помилка: $($item.Name)" 'ERROR' }
                            Write-Log "Захищено: $($item.Name)" 'OK'
                        }
                        Start-Sleep -Milliseconds 500
                    } else {
                        Write-Host "  Невiрний номер." -ForegroundColor Red
                        Start-Sleep -Milliseconds 800
                    }
                }
            }
        }
    } while ($true)
}

# ══════════════════════════════════════════════════════════════════════════════
# БЛОК 1 — ТЕЛЕМЕТРIЯ ТА СТЕЖЕННЯ
# ══════════════════════════════════════════════════════════════════════════════
function Invoke-DisableSpy {
    $items = [System.Collections.ArrayList]@(
        @{
            Name    = 'Сервiс DiagTrack (Connected User Experiences & Telemetry)'
            Check   = { (Get-Service 'DiagTrack' -EA SilentlyContinue).StartType -eq 'Disabled' }
            Harden  = { Disable-Svc 'DiagTrack'; Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\DiagTrack' 'Start' 4 }
            Restore = { Set-Service 'DiagTrack' -StartupType Automatic -EA SilentlyContinue; Start-Service 'DiagTrack' -EA SilentlyContinue }
        },
        @{
            Name    = 'Сервiс dmwappushservice (WAP Push телеметрiя)'
            Check   = { (Get-Service 'dmwappushservice' -EA SilentlyContinue).StartType -eq 'Disabled' }
            Harden  = { Disable-Svc 'dmwappushservice' }
            Restore = { Set-Service 'dmwappushservice' -StartupType Automatic -EA SilentlyContinue }
        },
        @{
            Name    = 'Сервiс diagnosticshub.standardcollector'
            Check   = { (Get-Service 'diagnosticshub.standardcollector.service' -EA SilentlyContinue).StartType -eq 'Disabled' }
            Harden  = { Disable-Svc 'diagnosticshub.standardcollector.service' }
            Restore = { Set-Service 'diagnosticshub.standardcollector.service' -StartupType Manual -EA SilentlyContinue }
        },
        @{
            Name    = 'Сервiс WerSvc (Windows Error Reporting)'
            Check   = { (Get-Service 'WerSvc' -EA SilentlyContinue).StartType -eq 'Disabled' }
            Harden  = { Disable-Svc 'WerSvc' }
            Restore = { Set-Service 'WerSvc' -StartupType Manual -EA SilentlyContinue }
        },
        @{
            Name    = 'Сервiс RemoteRegistry (Вiддалений реєстр — КРИТИЧНО)'
            Check   = { (Get-Service 'RemoteRegistry' -EA SilentlyContinue).StartType -eq 'Disabled' }
            Harden  = { Disable-Svc 'RemoteRegistry' }
            Restore = { Set-Service 'RemoteRegistry' -StartupType Manual -EA SilentlyContinue }
        },
        @{
            Name    = 'Сервiс wisvc (Windows Insider Service)'
            Check   = { (Get-Service 'wisvc' -EA SilentlyContinue).StartType -eq 'Disabled' }
            Harden  = { Disable-Svc 'wisvc' }
            Restore = { Set-Service 'wisvc' -StartupType Manual -EA SilentlyContinue }
        },
        @{
            Name    = 'Сервiс lfsvc (Geolocation Service)'
            Check   = { (Get-Service 'lfsvc' -EA SilentlyContinue).StartType -eq 'Disabled' }
            Harden  = { Disable-Svc 'lfsvc' }
            Restore = { Set-Service 'lfsvc' -StartupType Manual -EA SilentlyContinue }
        },
        @{
            Name    = 'Реєстр: AllowTelemetry = 0'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' `
                    -Name 'AllowTelemetry' -EA SilentlyContinue).AllowTelemetry -eq 0
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'MaxTelemetryAllowed' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowDeviceNameInTelemetry' 0
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'AllowTelemetry' 0
            }
            Restore = {
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry'
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'MaxTelemetryAllowed'
            }
        },
        @{
            Name    = 'Реєстр: CEIP / SQM вимкнено'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows' `
                    -Name 'CEIPEnable' -EA SilentlyContinue).CEIPEnable -eq 0
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows' 'CEIPEnable' 0
                Set-Reg 'HKLM:\SOFTWARE\Microsoft\SQMClient\Windows' 'CEIPEnable' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat' 'AITEnable' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat' 'DisableInventory' 1
            }
            Restore = {
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows' 'CEIPEnable'
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat' 'AITEnable'
            }
        },
        @{
            Name    = 'Реєстр: Activity History / Timeline вимкнено'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
                    -Name 'EnableActivityFeed' -EA SilentlyContinue).EnableActivityFeed -eq 0
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableActivityFeed' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'PublishUserActivities' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'UploadUserActivities' 0
            }
            Restore = {
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableActivityFeed'
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'PublishUserActivities'
            }
        },
        @{
            Name    = 'Реєстр: Feedback / SIUF вимкнено'
            Check   = {
                (Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules' `
                    -Name 'NumberOfSIUFInPeriod' -EA SilentlyContinue).NumberOfSIUFInPeriod -eq 0
            }
            Harden  = {
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules' 'NumberOfSIUFInPeriod' 0
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules' 'PeriodInNanoSeconds' 0
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy' 'TailoredExperiencesWithDiagnosticDataEnabled' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'DoNotShowFeedbackNotifications' 1
            }
            Restore = {
                Remove-Reg 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules' 'NumberOfSIUFInPeriod'
                Remove-Reg 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules' 'PeriodInNanoSeconds'
            }
        },
        @{
            Name    = 'Реклама в меню Пуск / ContentDelivery'
            Check   = {
                (Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' `
                    -Name 'ContentDeliveryAllowed' -EA SilentlyContinue).ContentDeliveryAllowed -eq 0
            }
            Harden  = {
                $p = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
                Set-Reg $p 'ContentDeliveryAllowed'          0
                Set-Reg $p 'OemPreInstalledAppsEnabled'      0
                Set-Reg $p 'PreInstalledAppsEnabled'         0
                Set-Reg $p 'SilentInstalledAppsEnabled'      0
                Set-Reg $p 'SystemPaneSuggestionsEnabled'    0
                Set-Reg $p 'SubscribedContent-338388Enabled' 0
                Set-Reg $p 'SubscribedContent-353698Enabled' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures' 1
            }
            Restore = {
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'ContentDeliveryAllowed' 1
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures'
            }
        },
        @{
            Name    = 'Рекламний iдентифiкатор (Advertising ID)'
            Check   = {
                (Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' `
                    -Name 'Enabled' -EA SilentlyContinue).Enabled -eq 0
            }
            Harden  = {
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' 'Enabled' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' 'DisabledByGroupPolicy' 1
                Remove-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' 'Id'
            }
            Restore = {
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' 'Enabled' 1
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' 'DisabledByGroupPolicy'
            }
        },
        @{
            Name    = 'Завдання: Compatibility Appraiser'
            Check   = {
                $t = Get-ScheduledTask -TaskPath '\Microsoft\Windows\Application Experience\' `
                     -TaskName 'Microsoft Compatibility Appraiser' -EA SilentlyContinue
                $t -and $t.State -eq 'Disabled'
            }
            Harden  = { Disable-Task '\Microsoft\Windows\Application Experience\' 'Microsoft Compatibility Appraiser' }
            Restore = { Enable-ScheduledTask -TaskPath '\Microsoft\Windows\Application Experience\' -TaskName 'Microsoft Compatibility Appraiser' -EA SilentlyContinue | Out-Null }
        },
        @{
            Name    = 'Завдання: CEIP Consolidator'
            Check   = {
                $t = Get-ScheduledTask -TaskPath '\Microsoft\Windows\Customer Experience Improvement Program\' `
                     -TaskName 'Consolidator' -EA SilentlyContinue
                $t -and $t.State -eq 'Disabled'
            }
            Harden  = { Disable-Task '\Microsoft\Windows\Customer Experience Improvement Program\' 'Consolidator' }
            Restore = { Enable-ScheduledTask -TaskPath '\Microsoft\Windows\Customer Experience Improvement Program\' -TaskName 'Consolidator' -EA SilentlyContinue | Out-Null }
        },
        @{
            Name    = 'Завдання: QueueReporting (Error Reporting)'
            Check   = {
                $t = Get-ScheduledTask -TaskPath '\Microsoft\Windows\Windows Error Reporting\' `
                     -TaskName 'QueueReporting' -EA SilentlyContinue
                $t -and $t.State -eq 'Disabled'
            }
            Harden  = { Disable-Task '\Microsoft\Windows\Windows Error Reporting\' 'QueueReporting' }
            Restore = { Enable-ScheduledTask -TaskPath '\Microsoft\Windows\Windows Error Reporting\' -TaskName 'QueueReporting' -EA SilentlyContinue | Out-Null }
        }
    )
    Show-SubMenu -Title "БЛОК 1 - Телеметрiя та стеження" -Items $items
}

# ══════════════════════════════════════════════════════════════════════════════
# БЛОК 2 — COPILOT / AI / CORTANA
# ══════════════════════════════════════════════════════════════════════════════
function Invoke-DisableAI {
    $items = [System.Collections.ArrayList]@(
        @{
            Name    = 'Windows Copilot (кнопка + GP)'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' `
                    -Name 'TurnOffWindowsCopilot' -EA SilentlyContinue).TurnOffWindowsCopilot -eq 1
            }
            Harden  = {
                Set-Reg 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 1
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 1
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowCopilotButton' 0
            }
            Restore = {
                Remove-Reg 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot'
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot'
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowCopilotButton' 1
            }
        },
        @{
            Name    = 'Windows Recall (AI-знiмки екрану)'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' `
                    -Name 'DisableAIDataAnalysis' -EA SilentlyContinue).DisableAIDataAnalysis -eq 1
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' 1
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'EnableRecallOnDevice' 0
                Set-Reg 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' 1
            }
            Restore = {
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis'
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'EnableRecallOnDevice'
            }
        },
        @{
            Name    = 'Cortana'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' `
                    -Name 'AllowCortana' -EA SilentlyContinue).AllowCortana -eq 0
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortana' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortanaAboveLock' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'ConnectedSearchUseWeb' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'DisableWebSearch' 1
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'CortanaEnabled' 0
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled' 0
            }
            Restore = {
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortana'
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'DisableWebSearch'
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'CortanaEnabled' 1
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled' 1
            }
        },
        @{
            Name    = 'Bing Search у рядку пошуку'
            Check   = {
                (Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' `
                    -Name 'BingSearchEnabled' -EA SilentlyContinue).BingSearchEnabled -eq 0
            }
            Harden  = { Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled' 0 }
            Restore = { Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled' 1 }
        },
        @{
            Name    = 'Widgets (новини та iнтереси)'
            Check   = {
                (Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' `
                    -Name 'TaskbarDa' -EA SilentlyContinue).TaskbarDa -eq 0
            }
            Harden  = {
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarDa' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests' 0
            }
            Restore = {
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarDa' 1
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests'
            }
        },
        @{
            Name    = 'Copilot в Microsoft Edge'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' `
                    -Name 'HubsSidebarEnabled' -EA SilentlyContinue).HubsSidebarEnabled -eq 0
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' 'HubsSidebarEnabled' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' 'CopilotPageContext' 0
            }
            Restore = {
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' 'HubsSidebarEnabled'
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' 'CopilotPageContext'
            }
        },
        @{
            Name    = 'Онлайн-розпiзнавання мовлення'
            Check   = {
                (Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy' `
                    -Name 'HasAccepted' -EA SilentlyContinue).HasAccepted -eq 0
            }
            Harden  = {
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy' 'HasAccepted' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization' 'AllowInputPersonalization' 0
            }
            Restore = {
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy' 'HasAccepted' 1
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization' 'AllowInputPersonalization'
            }
        },
        @{
            Name    = 'Фоновi застосунки (Global Background Access)'
            Check   = {
                (Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' `
                    -Name 'GlobalUserDisabled' -EA SilentlyContinue).GlobalUserDisabled -eq 1
            }
            Harden  = {
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' 'GlobalUserDisabled' 1
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'BackgroundAppGlobalToggle' 0
            }
            Restore = {
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' 'GlobalUserDisabled' 0
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'BackgroundAppGlobalToggle' 1
            }
        }
    )
    Show-SubMenu -Title "БЛОК 2 - Copilot / AI / Cortana / Widgets" -Items $items
}

# ══════════════════════════════════════════════════════════════════════════════
# БЛОК 3 — ДОЗВОЛИ ЗАСТОСУНКIВ
# ══════════════════════════════════════════════════════════════════════════════
function Invoke-DenyAppPermissions {
    $cs   = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore'
    $glob = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global'

    function Get-CS { param($c)
        (Get-ItemProperty "$cs\$c" -Name 'Value' -EA SilentlyContinue).Value -eq 'Deny'
    }
    function Set-CS-Deny  { param($c) Set-Reg "$cs\$c" 'Value' 'Deny'  'String' }
    function Set-CS-Allow { param($c) Set-Reg "$cs\$c" 'Value' 'Allow' 'String' }

    function Set-GlobDeny {
        param($guid, $type = 'InterfaceClass')
        $p = "$glob\{$guid}"
        if (-not (Test-Path $p)) { New-Item $p -Force | Out-Null }
        Set-ItemProperty $p -Name 'Type'  -Value $type  -Type String -Force
        Set-ItemProperty $p -Name 'Value' -Value 'Deny' -Type String -Force
    }
    function Set-GlobAllow { param($guid)
        $p = "$glob\{$guid}"
        if (Test-Path $p) { Set-ItemProperty $p -Name 'Value' -Value 'Allow' -Type String -Force }
    }

    $items = [System.Collections.ArrayList]@(
        @{
            Name    = 'Камера (webcam)'
            Check   = { Get-CS 'webcam' }
            Harden  = { Set-CS-Deny 'webcam'; Set-GlobDeny 'E5323777-F976-4f5b-9B55-B94699C46E44' }
            Restore = { Set-CS-Allow 'webcam'; Set-GlobAllow 'E5323777-F976-4f5b-9B55-B94699C46E44' }
        },
        @{
            Name    = 'Мiкрофон'
            Check   = { Get-CS 'microphone' }
            Harden  = { Set-CS-Deny 'microphone'; Set-GlobDeny '2EEF81BE-33FA-4800-9670-1CD474972C3F' }
            Restore = { Set-CS-Allow 'microphone'; Set-GlobAllow '2EEF81BE-33FA-4800-9670-1CD474972C3F' }
        },
        @{
            Name    = 'Геолокацiя (Location)'
            Check   = { Get-CS 'location' }
            Harden  = {
                Set-CS-Deny 'location'
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' 'DisableLocation' 1
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' 'DisableSensors'  1
                Disable-Svc 'lfsvc'
            }
            Restore = {
                Set-CS-Allow 'location'
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' 'DisableLocation'
                Set-Service 'lfsvc' -StartupType Manual -EA SilentlyContinue
            }
        },
        @{
            Name    = 'Контакти'
            Check   = { Get-CS 'contacts' }
            Harden  = { Set-CS-Deny 'contacts' }
            Restore = { Set-CS-Allow 'contacts' }
        },
        @{
            Name    = 'Календар / Зустрiчi'
            Check   = { Get-CS 'appointments' }
            Harden  = { Set-CS-Deny 'appointments' }
            Restore = { Set-CS-Allow 'appointments' }
        },
        @{
            Name    = 'Дзвiнки (Phone calls)'
            Check   = { Get-CS 'phoneCall' }
            Harden  = { Set-CS-Deny 'phoneCall' }
            Restore = { Set-CS-Allow 'phoneCall' }
        },
        @{
            Name    = 'Повiдомлення (Chat / SMS)'
            Check   = { Get-CS 'chat' }
            Harden  = { Set-CS-Deny 'chat' }
            Restore = { Set-CS-Allow 'chat' }
        },
        @{
            Name    = 'Електронна пошта'
            Check   = { Get-CS 'email' }
            Harden  = { Set-CS-Deny 'email' }
            Restore = { Set-CS-Allow 'email' }
        },
        @{
            Name    = 'Сповiщення застосункiв'
            Check   = { Get-CS 'userNotificationListener' }
            Harden  = { Set-CS-Deny 'userNotificationListener' }
            Restore = { Set-CS-Allow 'userNotificationListener' }
        },
        @{
            Name    = 'Рухова активнiсть (Activity / Motion)'
            Check   = { Get-CS 'activity' }
            Harden  = { Set-CS-Deny 'activity' }
            Restore = { Set-CS-Allow 'activity' }
        },
        @{
            Name    = 'Bluetooth-синхронiзацiя'
            Check   = { Get-CS 'bluetoothSync' }
            Harden  = { Set-CS-Deny 'bluetoothSync' }
            Restore = { Set-CS-Allow 'bluetoothSync' }
        },
        @{
            Name    = 'Радiо (Wireless devices)'
            Check   = {
                (Get-ItemProperty "$glob\{A8804298-2D5F-42E3-9531-9C8C39EB29CE}" -Name 'Value' -EA SilentlyContinue).Value -eq 'Deny'
            }
            Harden  = { Set-GlobDeny 'A8804298-2D5F-42E3-9531-9C8C39EB29CE' }
            Restore = { Set-GlobAllow 'A8804298-2D5F-42E3-9531-9C8C39EB29CE' }
        },
        @{
            Name    = 'Камера на екранi блокування'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' `
                    -Name 'NoLockScreenCamera' -EA SilentlyContinue).NoLockScreenCamera -eq 1
            }
            Harden  = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' 'NoLockScreenCamera' 1 }
            Restore = { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' 'NoLockScreenCamera' }
        },
        @{
            Name    = 'LooselyCoupled (широкий доступ UWP-застосункiв)'
            Check   = {
                (Get-ItemProperty "$glob\LooselyCoupled" -Name 'Value' -EA SilentlyContinue).Value -eq 'Deny'
            }
            Harden  = {
                $p = "$glob\LooselyCoupled"
                if (-not (Test-Path $p)) { New-Item $p -Force | Out-Null }
                Set-ItemProperty $p -Name 'Type'  -Value 'LooselyCoupled' -Type String -Force
                Set-ItemProperty $p -Name 'Value' -Value 'Deny'           -Type String -Force
            }
            Restore = {
                $p = "$glob\LooselyCoupled"
                if (Test-Path $p) { Set-ItemProperty $p -Name 'Value' -Value 'Allow' -Type String -Force }
            }
        }
    )
    Show-SubMenu -Title "БЛОК 3 - Дозволи застосункiв" -Items $items
}

# ══════════════════════════════════════════════════════════════════════════════
# БЛОК 4 — ПРИВАТНIСТЬ
# ══════════════════════════════════════════════════════════════════════════════
function Invoke-PrivacySettings {
    $items = [System.Collections.ArrayList]@(
        @{
            Name    = 'OneDrive — вимкнути синхронiзацiю'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' `
                    -Name 'DisableFileSyncNGSC' -EA SilentlyContinue).DisableFileSyncNGSC -eq 1
            }
            Harden  = {
                Get-Process 'OneDrive' -EA SilentlyContinue | Stop-Process -Force
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' 'DisableFileSyncNGSC' 1
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' 'DisableMeteredNetworkFileSync' 1
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' 'DisableLibrariesDefaultSaveToOneDrive' 1
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\OneDrive' 'DisablePersonalSync' 1
                @('HKLM:\SOFTWARE\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}',
                  'HKCU:\SOFTWARE\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}') |
                    ForEach-Object { Set-Reg $_ 'System.IsPinnedToNameSpaceTree' 0 }
            }
            Restore = {
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' 'DisableFileSyncNGSC'
                @('HKLM:\SOFTWARE\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}',
                  'HKCU:\SOFTWARE\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}') |
                    ForEach-Object { Set-Reg $_ 'System.IsPinnedToNameSpaceTree' 1 }
            }
        },
        @{
            Name    = 'SmartScreen — вимкнути'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
                    -Name 'EnableSmartScreen' -EA SilentlyContinue).EnableSmartScreen -eq 0
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableSmartScreen' 0
                Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' 'SmartScreenEnabled' 'Off' 'String'
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost' 'EnableWebContentEvaluation' 0
            }
            Restore = {
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableSmartScreen'
                Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' 'SmartScreenEnabled' 'Warn' 'String'
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost' 'EnableWebContentEvaluation' 1
            }
        },
        @{
            Name    = 'RDP (Remote Desktop) — вимкнути'
            Check   = {
                (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' `
                    -Name 'fDenyTSConnections' -EA SilentlyContinue).fDenyTSConnections -eq 1
            }
            Harden  = {
                Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' 'fDenyTSConnections' 1
                Disable-Svc 'TermService'
                Disable-Svc 'UmRdpService'
            }
            Restore = {
                Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' 'fDenyTSConnections' 0
                Set-Service 'TermService' -StartupType Manual -EA SilentlyContinue
            }
        },
        @{
            Name    = 'Windows Hello / Biometrics — вимкнути'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Biometrics' `
                    -Name 'Enabled' -EA SilentlyContinue).Enabled -eq 0
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Biometrics' 'Enabled' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork' 'Enabled' 0
                Disable-Svc 'WbioSrvc'
            }
            Restore = {
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Biometrics' 'Enabled'
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork' 'Enabled'
                Set-Service 'WbioSrvc' -StartupType Manual -EA SilentlyContinue
            }
        },
        @{
            Name    = 'Game DVR / Game Bar — вимкнути'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' `
                    -Name 'AllowgameDVR' -EA SilentlyContinue).AllowgameDVR -eq 0
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' 'AllowgameDVR' 0
                Set-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' 0
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' 'AppCaptureEnabled' 0
            }
            Restore = {
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' 'AllowgameDVR'
                Set-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' 1
                Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR' 'AppCaptureEnabled' 1
            }
        },
        @{
            Name    = 'AutoRun / AutoPlay — вимкнути'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' `
                    -Name 'NoDriveTypeAutoRun' -EA SilentlyContinue).NoDriveTypeAutoRun -eq 255
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoDriveTypeAutoRun' 255
                Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoAutorun' 1
            }
            Restore = {
                Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoDriveTypeAutoRun' 145
                Remove-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoAutorun'
            }
        },
        @{
            Name    = 'LLMNR — вимкнути (витiк iменi машини)'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' `
                    -Name 'EnableMulticast' -EA SilentlyContinue).EnableMulticast -eq 0
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' 'EnableMulticast' 0
                Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces' |
                    ForEach-Object { Set-Reg $_.PSPath 'NetbiosOptions' 2 }
            }
            Restore = {
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' 'EnableMulticast'
                Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces' |
                    ForEach-Object { Set-Reg $_.PSPath 'NetbiosOptions' 0 }
            }
        },
        @{
            Name    = 'Синхронiзацiя налаштувань (SettingSync)'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync' `
                    -Name 'DisableSettingSync' -EA SilentlyContinue).DisableSettingSync -eq 2
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync' 'DisableSettingSync' 2
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync' 'DisableSettingSyncUserOverride' 1
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync' 'DisablePasswordSettingSync' 2
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync' 'DisableWindowsCredentialSettingSync' 2
            }
            Restore = {
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync' 'DisableSettingSync'
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync' 'DisableSettingSyncUserOverride'
            }
        },
        @{
            Name    = 'Cloud Clipboard — вимкнути (хмарний буфер)'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' `
                    -Name 'AllowClipboardHistory' -EA SilentlyContinue).AllowClipboardHistory -eq 0
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'AllowClipboardHistory' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'AllowCrossDeviceClipboard' 0
            }
            Restore = {
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'AllowClipboardHistory'
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'AllowCrossDeviceClipboard'
            }
        },
        @{
            Name    = 'WiFi Sense — вимкнути'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config' `
                    -Name 'AutoConnectAllowedOEM' -EA SilentlyContinue).AutoConnectAllowedOEM -eq 0
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config' 'AutoConnectAllowedOEM' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy' 'fMinimizeConnections' 1
            }
            Restore = {
                Set-Reg 'HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config' 'AutoConnectAllowedOEM' 1
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy' 'fMinimizeConnections'
            }
        }
    )
    Show-SubMenu -Title "БЛОК 4 - Налаштування приватностi" -Items $items
}

# ══════════════════════════════════════════════════════════════════════════════
# БЛОК 5 — МЕРЕЖА
# ══════════════════════════════════════════════════════════════════════════════
function Invoke-NetworkHardening {
    $items = [System.Collections.ArrayList]@(
        @{
            Name    = 'DNS -> Cloudflare 1.1.1.1 (усi активнi адаптери)'
            Check   = {
                $null -ne (Get-DnsClientServerAddress -AddressFamily IPv4 -EA SilentlyContinue |
                           Where-Object { $_.ServerAddresses -contains '1.1.1.1' })
            }
            Harden  = {
                Get-NetAdapter | Where-Object Status -eq 'Up' | ForEach-Object {
                    Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ServerAddresses @('1.1.1.1','1.0.0.1')
                }
                Clear-DnsClientCache
            }
            Restore = {
                Get-NetAdapter | Where-Object Status -eq 'Up' | ForEach-Object {
                    Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ResetServerAddresses
                }
                Clear-DnsClientCache
            }
        },
        @{
            Name    = 'IPv6 — вимкнути на всiх адаптерах'
            Check   = {
                (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' `
                    -Name 'DisabledComponents' -EA SilentlyContinue).DisabledComponents -eq 255
            }
            Harden  = {
                Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' 'DisabledComponents' 255
                Get-NetAdapter | ForEach-Object {
                    Disable-NetAdapterBinding -Name $_.Name -ComponentID 'ms_tcpip6' -EA SilentlyContinue
                }
            }
            Restore = {
                Remove-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' 'DisabledComponents'
                Get-NetAdapter | ForEach-Object {
                    Enable-NetAdapterBinding -Name $_.Name -ComponentID 'ms_tcpip6' -EA SilentlyContinue
                }
            }
        },
        @{
            Name    = 'Firewall: блокування IP телеметрiї Microsoft'
            Check   = { $null -ne (Get-NetFirewallRule -DisplayName 'Block MS Telemetry IPs' -EA SilentlyContinue) }
            Harden  = {
                Add-FirewallBlock 'Block MS Telemetry IPs' @(
                    '134.170.30.202','137.116.81.24','157.56.106.189','184.86.53.99',
                    '2.22.61.43','2.22.61.44','204.79.197.200','23.218.212.69',
                    '65.55.108.23','65.55.252.43','64.4.54.254','65.52.108.33',
                    '191.232.139.254','65.55.252.63','65.52.100.7','207.68.128.11',
                    '94.245.121.3','111.221.29.177','23.102.21.4','23.102.4.253'
                )
            }
            Restore = { Remove-NetFirewallRule -DisplayName 'Block MS Telemetry IPs' -EA SilentlyContinue }
        },
        @{
            Name    = 'Firewall: блокування NVIDIA телеметрiї'
            Check   = { $null -ne (Get-NetFirewallRule -DisplayName 'Block NVIDIA Telemetry IPs' -EA SilentlyContinue) }
            Harden  = { Add-FirewallBlock 'Block NVIDIA Telemetry IPs' @('169.254.0.0','192.169.1.0') }
            Restore = { Remove-NetFirewallRule -DisplayName 'Block NVIDIA Telemetry IPs' -EA SilentlyContinue }
        },
        @{
            Name    = 'Hosts: блокування доменiв телеметрiї Microsoft'
            Check   = {
                $h = Get-Content "$env:WINDIR\System32\drivers\etc\hosts" -EA SilentlyContinue
                [bool]($h -match 'vortex\.data\.microsoft\.com')
            }
            Harden  = {
                $hp = "$env:WINDIR\System32\drivers\etc\hosts"
                Copy-Item $hp "$hp.bak" -Force
                $domains = @(
                    '0.0.0.0 vortex.data.microsoft.com',
                    '0.0.0.0 vortex-win.data.microsoft.com',
                    '0.0.0.0 telecommand.telemetry.microsoft.com',
                    '0.0.0.0 oca.telemetry.microsoft.com',
                    '0.0.0.0 sqm.telemetry.microsoft.com',
                    '0.0.0.0 watson.telemetry.microsoft.com',
                    '0.0.0.0 telemetry.microsoft.com',
                    '0.0.0.0 watson.microsoft.com',
                    '0.0.0.0 statsfe2.ws.microsoft.com',
                    '0.0.0.0 df.telemetry.microsoft.com',
                    '0.0.0.0 choice.microsoft.com',
                    '0.0.0.0 events.gfe.nvidia.com',
                    '0.0.0.0 telemetry.nvidia.com'
                )
                $exist = Get-Content $hp
                $new   = $domains | Where-Object { $exist -notcontains $_ }
                if ($new) {
                    Add-Content $hp -Value "`n# PrivacyHarden $(Get-Date -Format 'yyyy-MM-dd')"
                    $new | Add-Content $hp
                }
                Clear-DnsClientCache
            }
            Restore = {
                $hp = "$env:WINDIR\System32\drivers\etc\hosts"
                Get-Content $hp | Where-Object {
                    $_ -notmatch '(vortex|telemetry|watson|sqm|statsfe|telecommand|nvidia)' -and
                    $_ -notmatch 'PrivacyHarden'
                } | Set-Content $hp -Encoding UTF8
                Clear-DnsClientCache
            }
        },
        @{
            Name    = 'Delivery Optimization (P2P-роздача оновлень)'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' `
                    -Name 'DODownloadMode' -EA SilentlyContinue).DODownloadMode -eq 0
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' 'DODownloadMode' 0
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' 'DOMaxUploadBandwidth' 0
                Disable-Svc 'DoSvc'
            }
            Restore = {
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' 'DODownloadMode'
                Set-Service 'DoSvc' -StartupType Automatic -EA SilentlyContinue
            }
        }
    )
    Show-SubMenu -Title "БЛОК 5 - Мережа: Firewall / Hosts / DNS" -Items $items
}

# ══════════════════════════════════════════════════════════════════════════════
# БЛОК 6 — ОНОВЛЕННЯ WINDOWS
# ══════════════════════════════════════════════════════════════════════════════
function Invoke-UpdateHardening {
    $items = [System.Collections.ArrayList]@(
        @{
            Name    = 'Вiдкласти Feature Updates на 365 днiв'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' `
                    -Name 'DeferFeatureUpdatesPeriodInDays' -EA SilentlyContinue).DeferFeatureUpdatesPeriodInDays -eq 365
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'DeferFeatureUpdates' 1
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'DeferFeatureUpdatesPeriodInDays' 365
            }
            Restore = {
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'DeferFeatureUpdates'
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'DeferFeatureUpdatesPeriodInDays'
            }
        },
        @{
            Name    = 'Вiдкласти Quality Updates на 30 днiв'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' `
                    -Name 'DeferQualityUpdatesPeriodInDays' -EA SilentlyContinue).DeferQualityUpdatesPeriodInDays -eq 30
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'DeferQualityUpdates' 1
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'DeferQualityUpdatesPeriodInDays' 30
            }
            Restore = {
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'DeferQualityUpdates'
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'DeferQualityUpdatesPeriodInDays'
            }
        },
        @{
            Name    = 'Без автоматичного перезавантаження'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' `
                    -Name 'NoAutoRebootWithLoggedOnUsers' -EA SilentlyContinue).NoAutoRebootWithLoggedOnUsers -eq 1
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'NoAutoRebootWithLoggedOnUsers' 1
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'AUPowerManagement' 0
            }
            Restore = { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'NoAutoRebootWithLoggedOnUsers' }
        },
        @{
            Name    = 'Вимкнути оновлення драйверiв через WU'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' `
                    -Name 'ExcludeWUDriversInQualityUpdate' -EA SilentlyContinue).ExcludeWUDriversInQualityUpdate -eq 1
            }
            Harden  = { Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'ExcludeWUDriversInQualityUpdate' 1 }
            Restore = { Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'ExcludeWUDriversInQualityUpdate' }
        },
        @{
            Name    = 'BITS — лише ручний запуск (фоновий трафiк)'
            Check   = { (Get-Service 'BITS' -EA SilentlyContinue).StartType -eq 'Manual' }
            Harden  = { Set-Service 'BITS' -StartupType Manual -EA SilentlyContinue }
            Restore = { Set-Service 'BITS' -StartupType Automatic -EA SilentlyContinue }
        },
        @{
            Name    = 'Заборонити MCT / Windows Upgrade нагадування'
            Check   = {
                (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade' `
                    -Name 'HideMCTLink' -EA SilentlyContinue).HideMCTLink -eq 1
            }
            Harden  = {
                Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade' 'HideMCTLink' 1
                Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GWX' 'DisableGwx' 1
            }
            Restore = {
                Remove-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade' 'HideMCTLink'
                Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GWX' 'DisableGwx'
            }
        }
    )
    Show-SubMenu -Title "БЛОК 6 - Оновлення Windows" -Items $items
}

# ══════════════════════════════════════════════════════════════════════════════
# БЛОК 7 — ОЧИЩЕННЯ АРТЕФАКТIВ
# ══════════════════════════════════════════════════════════════════════════════
function Invoke-CleanupMenu {
    $items = [System.Collections.ArrayList]@(
        @{
            Name    = 'Тимчасовi файли (TEMP / INetCache / Minidump)'
            Check   = {
                $s = (Get-ChildItem $env:TEMP -Force -Recurse -EA SilentlyContinue |
                      Measure-Object -Property Length -Sum).Sum
                $s -eq 0 -or $null -eq $s
            }
            Harden  = {
                @($env:TEMP,$env:TMP,"$env:LOCALAPPDATA\Temp","$env:WINDIR\Temp",
                  "$env:LOCALAPPDATA\Microsoft\Windows\INetCache",
                  "$env:LOCALAPPDATA\Microsoft\Windows\WebCache",
                  "$env:LOCALAPPDATA\Microsoft\Windows\Explorer",
                  "$env:WINDIR\Minidump") | ForEach-Object {
                    if (Test-Path $_) {
                        Get-ChildItem $_ -Force -Recurse -EA SilentlyContinue |
                            Remove-Item -Force -Recurse -EA SilentlyContinue
                    }
                }
                Write-Log "Тимчасовi файли очищено." 'OK'
            }
            Restore = { Write-Log "Тимчасовi файли не вiдновлюються." 'WARN' }
        },
        @{
            Name    = 'Prefetch (слiди запуску програм)'
            Check   = {
                (Get-ChildItem "$env:WINDIR\Prefetch" -Filter '*.pf' -Force -EA SilentlyContinue |
                 Measure-Object).Count -eq 0
            }
            Harden  = {
                Get-ChildItem "$env:WINDIR\Prefetch" -Filter '*.pf' -Force -EA SilentlyContinue |
                    Remove-Item -Force -EA SilentlyContinue
                Write-Log "Prefetch очищено." 'OK'
            }
            Restore = { Write-Log "Prefetch вiдновлюється Windows автоматично." 'WARN' }
        },
        @{
            Name    = 'Нещодавнi документи + реєстр RecentDocs'
            Check   = {
                (Get-ChildItem "$env:APPDATA\Microsoft\Windows\Recent" -Force -EA SilentlyContinue |
                 Measure-Object).Count -eq 0
            }
            Harden  = {
                @("$env:APPDATA\Microsoft\Windows\Recent",
                  "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations",
                  "$env:APPDATA\Microsoft\Windows\Recent\CustomDestinations",
                  "$env:APPDATA\Microsoft\Office\Recent") | ForEach-Object {
                    if (Test-Path $_) {
                        Get-ChildItem $_ -Force -EA SilentlyContinue |
                            Remove-Item -Force -Recurse -EA SilentlyContinue
                    }
                }
                @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs',
                  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU',
                  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths',
                  'HKCU:\Software\Microsoft\Internet Explorer\TypedURLs') |
                    ForEach-Object { Remove-Item $_ -Recurse -Force -EA SilentlyContinue }
                Write-Log "Нещодавнi документи очищено." 'OK'
            }
            Restore = { Write-Log "Нещодавнi документи не вiдновлюються." 'WARN' }
        },
        @{
            Name    = 'Iсторiя PowerShell (перезапис нулями)'
            Check   = {
                -not (Test-Path "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt")
            }
            Harden  = {
                @("$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt",
                  "$env:USERPROFILE\.config\powershell\PSReadLine\ConsoleHost_history.txt") | ForEach-Object {
                    if (Test-Path $_) {
                        $b = [System.IO.File]::ReadAllBytes($_)
                        [Array]::Clear($b, 0, $b.Length)
                        [System.IO.File]::WriteAllBytes($_, $b)
                        Remove-Item $_ -Force
                    }
                }
                Write-Log "Iсторiя PS перезаписана та видалена." 'OK'
            }
            Restore = { Write-Log "Iсторiя PS не вiдновлюється." 'WARN' }
        },
        @{
            Name    = 'DNS / ARP / NetBIOS кеш'
            Check   = { $false }
            Harden  = {
                Clear-DnsClientCache -EA SilentlyContinue
                arp -d * 2>$null
                nbtstat -R 2>$null
                Write-Log "DNS/ARP/NetBIOS кеш очищено." 'OK'
            }
            Restore = { Write-Log "Кеш не вiдновлюється." 'WARN' }
        },
        @{
            Name    = 'Тiньовi копiї (VSS Shadow Copies)'
            Check   = {
                @(Get-CimInstance -ClassName Win32_ShadowCopy -EA SilentlyContinue).Count -eq 0
            }
            Harden  = {
                $s = @(Get-CimInstance -ClassName Win32_ShadowCopy -EA SilentlyContinue)
                if ($s.Count -gt 0) {
                    $s | Remove-CimInstance -EA SilentlyContinue
                    Write-Log "Видалено тiньових копiй: $($s.Count)." 'OK'
                }
            }
            Restore = { Write-Log "Тiньовi копiї не вiдновлюються автоматично." 'WARN' }
        },
        @{
            Name    = 'Журнали подiй Windows'
            Check   = {
                (Get-WinEvent -ListLog * -EA SilentlyContinue |
                 Where-Object { $_.IsEnabled -and $_.RecordCount -gt 0 } |
                 Measure-Object).Count -eq 0
            }
            Harden  = {
                $logs = Get-WinEvent -ListLog * -EA SilentlyContinue |
                        Where-Object { $_.IsEnabled -and $_.RecordCount -gt 0 }
                $c = 0; $sk = 0
                foreach ($log in $logs) {
                    try {
                        [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($log.LogName)
                        $c++
                    } catch { $sk++ }
                }
                wevtutil cl Security 2>$null
                Write-Log "Журнали очищено: $c, пропущено: $sk." 'OK'
            }
            Restore = { Write-Log "Журнали не вiдновлюються." 'WARN' }
        },
        @{
            Name    = 'Данi браузерiв (Chrome/Edge/Firefox/Brave/Opera)'
            Check   = { $false }
            Harden  = {
                $br = @{
                    Chrome  = @("$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History",
                                "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies",
                                "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data",
                                "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache")
                    Edge    = @("$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\History",
                                "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cookies",
                                "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache")
                    Firefox = @("$env:APPDATA\Mozilla\Firefox\Profiles")
                    Brave   = @("$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\History",
                                "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cache")
                    Opera   = @("$env:APPDATA\Opera Software\Opera Stable\History",
                                "$env:APPDATA\Opera Software\Opera Stable\Cache")
                }
                foreach ($b in $br.Keys) {
                    foreach ($p in $br[$b]) {
                        if (-not (Test-Path $p)) { continue }
                        if ((Get-Item $p).PSIsContainer) {
                            Get-ChildItem $p -Recurse -Force | Remove-Item -Force -Recurse -EA SilentlyContinue
                        } else { Remove-Item $p -Force -EA SilentlyContinue }
                    }
                }
                Write-Log "Браузери очищено." 'OK'
            }
            Restore = { Write-Log "Данi браузерiв не вiдновлюються." 'WARN' }
        },
        @{
            Name    = 'Windows Defender — журнал захисту'
            Check   = {
                $p = 'C:\ProgramData\Microsoft\Windows Defender\Scans\History\Service'
                -not (Test-Path $p) -or
                (Get-ChildItem $p -Force -EA SilentlyContinue | Measure-Object).Count -eq 0
            }
            Harden  = {
                $p = 'C:\ProgramData\Microsoft\Windows Defender\Scans\History\Service'
                if (Test-Path $p) {
                    Remove-Item "$p\*" -Recurse -Force -EA SilentlyContinue
                    Write-Log "Журнал Defender очищено." 'OK'
                }
            }
            Restore = { Write-Log "Журнал Defender не вiдновлюється." 'WARN' }
        },
        @{
            Name    = 'Буфер обмiну'
            Check   = { $false }
            Harden  = {
                try {
                    Add-Type -AssemblyName System.Windows.Forms
                    [System.Windows.Forms.Clipboard]::Clear()
                } catch { cmd /c "echo off | clip" 2>$null }
                Write-Log "Буфер обмiну очищено." 'OK'
            }
            Restore = { Write-Log "Буфер не вiдновлюється." 'WARN' }
        }
    )
    Show-SubMenu -Title "БЛОК 7 - Очищення артефактiв" -Items $items
}

# ══════════════════════════════════════════════════════════════════════════════
# БЛОК 8 — БЕЗПЕЧНИЙ ПЕРЕЗАПИС ДИСКУ
# ══════════════════════════════════════════════════════════════════════════════
function Invoke-SecureWipe {
    param([string]$Drive = 'C:')
    Write-Log "Cipher /w — тричi перезаписує вiльне мiсце. Не переривайте!" 'WARN'
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    & cipher /w:"$Drive\" 2>&1 | Out-Null
    $sw.Stop()
    Write-Log "Перезапис завершено за $([math]::Round($sw.Elapsed.TotalMinutes,1)) хв." 'OK'
}

# ══════════════════════════════════════════════════════════════════════════════
# БЛОК 9 — АУДИТ
# ══════════════════════════════════════════════════════════════════════════════
function Invoke-PrivacyAudit {
    Clear-Host
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║              АУДИТ ПРИВАТНОСТI                          ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    $checks = @(
        @{ Name='Телеметрiя AllowTelemetry=0';  Test={ (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -EA SilentlyContinue).AllowTelemetry -eq 0 } },
        @{ Name='Сервiс DiagTrack вимкнено';    Test={ (Get-Service 'DiagTrack' -EA SilentlyContinue).StartType -eq 'Disabled' } },
        @{ Name='Сервiс RemoteRegistry вимкнено'; Test={ (Get-Service 'RemoteRegistry' -EA SilentlyContinue).StartType -eq 'Disabled' } },
        @{ Name='Рекламний ID вимкнено';         Test={ (Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -EA SilentlyContinue).Enabled -eq 0 } },
        @{ Name='OneDrive вимкнено';             Test={ (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' -Name 'DisableFileSyncNGSC' -EA SilentlyContinue).DisableFileSyncNGSC -eq 1 } },
        @{ Name='Copilot вимкнено';              Test={ (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' -Name 'TurnOffWindowsCopilot' -EA SilentlyContinue).TurnOffWindowsCopilot -eq 1 } },
        @{ Name='Windows Recall вимкнено';       Test={ (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' -Name 'DisableAIDataAnalysis' -EA SilentlyContinue).DisableAIDataAnalysis -eq 1 } },
        @{ Name='RDP вимкнено';                  Test={ (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -EA SilentlyContinue).fDenyTSConnections -eq 1 } },
        @{ Name='LLMNR вимкнено';               Test={ (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' -Name 'EnableMulticast' -EA SilentlyContinue).EnableMulticast -eq 0 } },
        @{ Name='DNS = Cloudflare 1.1.1.1';     Test={ $null -ne (Get-DnsClientServerAddress -AddressFamily IPv4 -EA SilentlyContinue | Where-Object { $_.ServerAddresses -contains '1.1.1.1' }) } },
        @{ Name='Delivery Optimization вимкнено'; Test={ (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Name 'DODownloadMode' -EA SilentlyContinue).DODownloadMode -eq 0 } },
        @{ Name='Камера заблокована';            Test={ (Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam' -Name 'Value' -EA SilentlyContinue).Value -eq 'Deny' } },
        @{ Name='Мiкрофон заблокований';         Test={ (Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone' -Name 'Value' -EA SilentlyContinue).Value -eq 'Deny' } },
        @{ Name='Геолокацiя заблокована';        Test={ (Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location' -Name 'Value' -EA SilentlyContinue).Value -eq 'Deny' } },
        @{ Name='AutoRun вимкнено';              Test={ (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'NoDriveTypeAutoRun' -EA SilentlyContinue).NoDriveTypeAutoRun -eq 255 } }
    )

    $passed = 0; $failed = 0
    foreach ($c in $checks) {
        $ok = $false
        try { $ok = [bool](& $c.Test) } catch {}
        if ($ok) {
            Write-Host "  [+] $($c.Name)" -ForegroundColor Green
            $passed++
        } else {
            Write-Host "  [x] $($c.Name)  <-- РИЗИК" -ForegroundColor Red
            $failed++
        }
        Write-Log "$($c.Name): $(if($ok){'OK'}else{'FAIL'})" $(if($ok){'OK'}else{'ERROR'})
    }

    Write-Host ""
    $color = if ($failed -eq 0) { 'Green' } else { 'Yellow' }
    Write-Host "  Результат: $passed / $($checks.Count) захищено" -ForegroundColor $color
    if ($failed -gt 0) {
        Write-Host "  Ризикiв: $failed — запустiть вiдповiднi блоки!" -ForegroundColor Red
    }
    Write-Host ""
    Read-Host "  Enter — повернутись до меню"
}

# ══════════════════════════════════════════════════════════════════════════════
# ГОЛОВНЕ МЕНЮ
# ══════════════════════════════════════════════════════════════════════════════
function Show-Menu {
    Clear-Host
    $wl = if ($IsWin11) { 'Windows 11' } else { 'Windows 10' }
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║   Privacy & Security Hardening  v5.0 UA                 ║" -ForegroundColor Cyan
    Write-Host "  ║   $wl  |  $(Get-Date -Format 'dd.MM.yyyy HH:mm')                       ║" -ForegroundColor DarkCyan
    Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1]  Телеметрiя та стеження"      -ForegroundColor Magenta
    Write-Host "  [2]  Copilot / AI / Cortana"       -ForegroundColor Magenta
    Write-Host "  [3]  Дозволи застосункiв"          -ForegroundColor Yellow
    Write-Host "  [4]  Приватнiсть"                  -ForegroundColor Yellow
    Write-Host "  [5]  Мережа (Firewall/Hosts/DNS)"  -ForegroundColor Cyan
    Write-Host "  [6]  Оновлення Windows"            -ForegroundColor Green
    Write-Host "  [7]  Очищення артефактiв"          -ForegroundColor Green
    Write-Host "  [8]  Перезапис диску (cipher /w)"  -ForegroundColor Red
    Write-Host "  [9]  Аудит приватностi"            -ForegroundColor White
    Write-Host "  [A]  Захистити все (без cipher)"   -ForegroundColor Red
    Write-Host "  [Q]  Вихiд"                        -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Лог: $LogFile" -ForegroundColor DarkGray
    Write-Host ""
}

# ══════════════════════════════════════════════════════════════════════════════
# ГОЛОВНИЙ ЦИКЛ
# ══════════════════════════════════════════════════════════════════════════════
do {
    Show-Menu
    $choice = (Read-Host "  Оберiть дiю").Trim().ToUpper()
    switch ($choice) {
        '1' { Invoke-DisableSpy }
        '2' { Invoke-DisableAI }
        '3' { Invoke-DenyAppPermissions }
        '4' { Invoke-PrivacySettings }
        '5' { Invoke-NetworkHardening }
        '6' { Invoke-UpdateHardening }
        '7' { Invoke-CleanupMenu }
        '8' {
            $drv = (Read-Host "  Лiтера диску (Enter = C:)").Trim()
            if ([string]::IsNullOrWhiteSpace($drv)) { $drv = 'C:' }
            $c2 = Read-Host "  УВАГА: незворотно. Продовжити? (Y/N)"
            if ($c2 -eq 'Y') { Invoke-SecureWipe -Drive $drv }
        }
        '9' { Invoke-PrivacyAudit }
        'A' {
            Invoke-DisableSpy
            Invoke-DisableAI
            Invoke-DenyAppPermissions
            Invoke-PrivacySettings
            Invoke-NetworkHardening
            Invoke-UpdateHardening
            Invoke-CleanupMenu
            Write-Host "  Cipher /w пропущено — запустiть [8] окремо." -ForegroundColor Yellow
            Read-Host "  Enter — продовжити"
        }
        'Q' { break }
        default {
            Write-Host "  Невiрний вибiр." -ForegroundColor Red
            Start-Sleep -Milliseconds 800
        }
    }
} while ($choice -ne 'Q')

Write-Log "Сесiю завершено. Лог: $LogFile" 'OK'
<#
.SYNOPSIS
    Privacy & Security Hardening — Windows 10/11
.DESCRIPTION
    Повна модернізація AutoSettings LTSB 3.16 + розширення 2025-2026.
    Блоки: Телеметрія · Copilot/AI · Дозволи · Приватність · Мережа ·
           Брандмауер · Hosts · Оновлення · Очищення · Cipher.
.NOTES
    Версія  : 5.0 UA — Maximum Privacy Edition
    Вимоги  : PowerShell 5.1+, права адміністратора
    УВАГА   : Частина змін незворотна. Тестуйте на не-виробничих системах.
#>

# ── Самопідвищення прав ────────────────────────────────────────────────────────
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Set-StrictMode -Version Latest
$ErrorActionPreference = 'SilentlyContinue'

# ── Визначення архітектури ─────────────────────────────────────────────────────
$Is64 = [Environment]::Is64BitOperatingSystem
$WinVer = [System.Environment]::OSVersion.Version
$IsWin11 = ($WinVer.Build -ge 22000)

# ── Логування ──────────────────────────────────────────────────────────────────
$LogFile = "$env:TEMP\PrivacyHarden_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Write-Log {
    param([string]$Msg, [ValidateSet('INFO','OK','WARN','ERROR','HEAD')][string]$Level = 'INFO')
    $icon = @{ INFO='[i]'; OK='[✓]'; WARN='[!]'; ERROR='[✗]'; HEAD='═' }[$Level]
    $color = switch ($Level) {
        'OK'    { 'Green' }
        'WARN'  { 'Yellow' }
        'ERROR' { 'Red' }
        'HEAD'  { 'Cyan' }
        default { 'White' }
    }
    $line = "[{0}] {1} {2}" -f (Get-Date -Format 'HH:mm:ss'), $icon, $Msg
    Write-Host $line -ForegroundColor $color
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

# ── Допоміжні функції ──────────────────────────────────────────────────────────
function Set-Reg {
    param([string]$Path, [string]$Name, $Value, [string]$Type = 'DWord')
    try {
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
    } catch { Write-Log "Set-Reg помилка: $Path\$Name — $_" 'ERROR' }
}

function Remove-Reg {
    param([string]$Path, [string]$Name = $null)
    if ($Name) { Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction SilentlyContinue }
    else       { Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue }
}

function Disable-Svc {
    param([string]$Name)
    $s = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($s) {
        Stop-Service  -Name $Name -Force  -ErrorAction SilentlyContinue
        Set-Service   -Name $Name -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Log "Сервіс вимкнено: $Name" 'OK'
    }
}

function Disable-Task {
    param([string]$Path, [string]$Name)
    $t = Get-ScheduledTask -TaskPath $Path -TaskName $Name -ErrorAction SilentlyContinue
    if ($t) {
        Disable-ScheduledTask -TaskPath $Path -TaskName $Name | Out-Null
        Write-Log "Завдання вимкнено: $Path$Name" 'OK'
    }
}

function Add-FirewallBlock {
    param([string]$Name, [string[]]$IPs)
    $existing = Get-NetFirewallRule -DisplayName $Name -ErrorAction SilentlyContinue
    if ($existing) { Remove-NetFirewallRule -DisplayName $Name }
    New-NetFirewallRule -DisplayName $Name -Direction Outbound `
        -RemoteAddress $IPs -Action Block -Profile Any -Enabled True | Out-Null
    Write-Log "Брандмауер: заблоковано '$Name' ($($IPs.Count) IP)" 'OK'
}

# ══════════════════════════════════════════════════════════════════════════════
# БЛОК 1 — ТЕЛЕМЕТРІЯ ТА СТЕЖЕННЯ
# ══════════════════════════════════════════════════════════════════════════════
function Invoke-DisableSpy {
    Write-Log "══════ БЛОК 1: Телеметрія та стеження ══════" 'HEAD'

    # ── 1.1 Сервіси ────────────────────────────────────────────────────────
    Write-Log "Вимкнення сервісів телеметрії..."
    @(
        'DiagTrack',                                    # Connected User Experiences & Telemetry
        'diagnosticshub.standardcollector.service',     # Diagnostics Hub
        'dmwappushservice',                             # WAP Push (телеметрія)
        'DcpSvc',                                       # DataCollectionPublishingService
        'NcbService',                                   # Network Connection Broker
        'XblGameSave', 'XblAuthManager', 'XboxNetApiSvc', 'XboxGipSvc', # Xbox Live
        'CDPSvc',                                       # Connected Devices Platform
        'MapsBroker',                                   # Offline Maps
        'WalletService',
        'WMPNetworkSvc',                                # Windows Media Player Network
        'wcncsvc',                                      # Windows Connect Now / WiFi
        'SensrSvc', 'SensorService', 'SensorDataService',
        'WbioSrvc',                                     # Біометрія
        'RetailDemo',
        'WerSvc',                                       # Windows Error Reporting
        'PcaSvc',                                       # Program Compatibility Assistant
        'NvTelemetryContainer',                         # NVIDIA Telemetry
        'AdobeARMservice',                              # Adobe Update
        'DoSvc',                                        # Delivery Optimization
        'lfsvc',                                        # Geolocation Service
        'icssvc',                                       # Windows Mobile Hotspot
        'SharedAccess',                                 # Internet Connection Sharing
        'wisvc',                                        # Windows Insider Service
        'wlidsvc',                                      # Microsoft Account Sign-in Assistant
        'WSearch',                                      # Windows Search (індексація) — за вибором
        'RemoteRegistry'                                # Віддалений реєстр — критично!
    ) | ForEach-Object { Disable-Svc $_ }

    # ── 1.2 Реєстр телеметрії ──────────────────────────────────────────────
    Write-Log "Реєстр телеметрії — рівень 0..."

    # Основний AllowTelemetry
    @(
        'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'
    ) | ForEach-Object {
        Set-Reg $_ 'AllowTelemetry'                       0
        Set-Reg $_ 'MaxTelemetryAllowed'                  0
        Set-Reg $_ 'AllowDeviceNameInTelemetry'           0
        Set-Reg $_ 'DoNotShowFeedbackNotifications'       1
    }

    # CEIP / SQM / Asimov
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows'            'CEIPEnable'                                0
    Set-Reg 'HKLM:\SOFTWARE\Microsoft\SQMClient\Windows'                     'CEIPEnable'                                0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat'            'AITEnable'                                 0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat'            'DisableInventory'                          1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat'            'DisablePCA'                                1
    Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack' 'Disabled'                           1
    Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack' 'DisableAutomaticTelemetryKeywordReporting' 1
    Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack' 'TelemetryServiceDisabled'           1
    Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack' 'DisableAsimovUpLoad'                1

    # AppCompat / Application Experience
    Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' 'DisablePCFaultChecking' 1
    @(
        'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry'
    ) | ForEach-Object {
        Set-Reg $_ 'IsCensusDisabled' 1
        Set-Reg $_ 'DontRetryOnError' 1
        Set-Reg $_ 'TaskEnableRun'    0
    }

    # Insider / Preview Builds
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds'        'AllowBuildPreview'                         0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds'        'EnableConfigFlighting'                     0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds'        'HideInsiderPage'                           1
    Remove-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds'     'EnableExperimentation'

    # Windows Error Reporting
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' 'Disabled'               1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' 'DontSendAdditionalData' 1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' 'LoggingDisabled'        1
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\Windows Error Reporting'       'Disabled'                   1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\PCHealth\ErrorReporting'      'DoReport'                   0
    Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting'       'DontSendAdditionalData'     1
    Disable-Svc 'WerSvc'
    Disable-Task '\Microsoft\Windows\Windows Error Reporting\' 'QueueReporting'

    # Activity History / Timeline
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'               'EnableActivityFeed'                        0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'               'PublishUserActivities'                     0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'               'UploadUserActivities'                      0

    # PerfTrack / SQM
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC'             'PreventHandwritingDataSharing'             1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports' 'PreventHandwritingErrorReports'         1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\SQM'        'DisableCustomerImprovementProgram'         1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Messenger\Client'             'CEIP'                                      2

    # DiagTrack ETL pipeline
    Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\DiagTrack'              'Start'                                     4
    Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice'       'Start'                                     4
    $etl = "$env:ProgramData\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl"
    if (Test-Path $etl) { Remove-Item $etl -Force }

    # SIUF / Feedback
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules'                            'NumberOfSIUFInPeriod'                      0
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules'                            'PeriodInNanoSeconds'                       0
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy'        'TailoredExperiencesWithDiagnosticDataEnabled' 0

    # ── 1.3 Scheduled Tasks ────────────────────────────────────────────────
    Write-Log "Вимкнення запланованих завдань телеметрії..."
    @(
        @('\Microsoft\Windows\Application Experience\',                    'Microsoft Compatibility Appraiser'),
        @('\Microsoft\Windows\Application Experience\',                    'ProgramDataUpdater'),
        @('\Microsoft\Windows\Application Experience\',                    'StartupAppTask'),
        @('\Microsoft\Windows\Application Experience\',                    'MareBackup'),
        @('\Microsoft\Windows\Autochk\',                                   'Proxy'),
        @('\Microsoft\Windows\Customer Experience Improvement Program\',   'Consolidator'),
        @('\Microsoft\Windows\Customer Experience Improvement Program\',   'KernelCeipTask'),
        @('\Microsoft\Windows\Customer Experience Improvement Program\',   'UsbCeip'),
        @('\Microsoft\Windows\Customer Experience Improvement Program\',   'BthSQM'),
        @('\Microsoft\Windows\Customer Experience Improvement Program\',   'HypervisorFlightingTask'),
        @('\Microsoft\Windows\DiskDiagnostic\',                            'Microsoft-Windows-DiskDiagnosticDataCollector'),
        @('\Microsoft\Windows\DiskDiagnostic\',                            'Microsoft-Windows-DiskDiagnosticResolver'),
        @('\Microsoft\Windows\Feedback\Siuf\',                             'DmClient'),
        @('\Microsoft\Windows\Feedback\Siuf\',                             'DmClientOnScenarioDownload'),
        @('\Microsoft\Windows\Windows Error Reporting\',                   'QueueReporting'),
        @('\Microsoft\Windows\CloudExperienceHost\',                       'CreateObjectTask'),
        @('\Microsoft\Windows\PI\',                                        'Sqm-Tasks'),
        @('\Microsoft\Windows\NetTrace\',                                  'GatherNetworkInfo'),
        @('\Microsoft\Windows\AppID\',                                     'SmartScreenSpecific'),
        @('\Microsoft\Windows\Clip\',                                      'License Validation'),
        @('\Microsoft\Windows\Power Efficiency Diagnostics\',              'AnalyzeSystem'),
        @('\Microsoft\Windows\Maintenance\',                               'WinSAT'),
        @('\Microsoft\Windows\WlanSvc\',                                   'CDSSync'),
        @('\Microsoft\Windows\WCM\',                                       'WiFiTask'),
        @('\Microsoft\Windows\Maps\',                                      'MapsUpdateTask'),
        @('\Microsoft\Windows\Maps\',                                      'MapsToastTask'),
        @('\Microsoft\Windows\Shell\',                                     'FamilySafetyMonitor'),
        @('\Microsoft\Windows\Shell\',                                     'FamilySafetyRefreshTask'),
        @('\Microsoft\Windows\RemoteAssistance\',                          'RemoteAssistanceTask'),
        @('\Microsoft\Windows\SoftwareProtectionPlatform\',                'SvcRestartTask'),
        @('\Microsoft\Windows\SoftwareProtectionPlatform\',                'SvcRestartTaskNetwork'),
        @('\Microsoft\Windows\SoftwareProtectionPlatform\',                'SvcRestartTaskLogon'),
        @('\Microsoft\Windows\SpacePort\',                                 'SpaceAgentTask'),
        @('\Microsoft\Windows\SettingSync\',                               'BackgroundUploadTask'),
        @('\Microsoft\Windows\SettingSync\',                               'NetworkStateChangeTask'),
        @('\Microsoft\Windows\SmartScreenSpecific\',                       'SmartScreenSpecific'),
        @('\Microsoft\Windows\Work Folders\',                              'Work Folders Logon Synchronization'),
        @('\Microsoft\XblGameSave\',                                       'XblGameSaveTask'),
        @('\Microsoft\XblGameSave\',                                       'XblGameSaveTaskLogon')
    ) | ForEach-Object { Disable-Task $_[0] $_[1] }

    # ── 1.4 Рекламний ідентифікатор ────────────────────────────────────────
    Write-Log "Вимкнення рекламного ID..."
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'       'Enabled'                 0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo'             'DisabledByGroupPolicy'   1
    Remove-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'    'Id'
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-338388Enabled' 0
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-338389Enabled' 0
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-353698Enabled' 0
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'ContentDeliveryAllowed'          0
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'OemPreInstalledAppsEnabled'      0
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'PreInstalledAppsEnabled'         0
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SilentInstalledAppsEnabled'      0
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SystemPaneSuggestionsEnabled'    0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'                 'DisableWindowsConsumerFeatures'  1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'                 'DisableCloudOptimizedContent'    1

    # ── 1.5 Рукописне введення / Inking ────────────────────────────────────
    Write-Log "Вимкнення збору рукописного введення..."
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Personalization\Settings'              'AcceptedPrivacyPolicy'           0
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\InputPersonalization'                  'RestrictImplicitInkCollection'   1
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\InputPersonalization'                  'RestrictImplicitTextCollection'  1
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore' 'HarvestContacts'                 0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization'         'AllowInputPersonalization'       0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization'         'RestrictImplicitInkCollection'   1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization'         'RestrictImplicitTextCollection'  1

    Write-Log "БЛОК 1 завершено." 'OK'
}

# ══════════════════════════════════════════════════════════════════════════════
# БЛОК 2 — COPILOT / AI / CORTANA / WIDGETS (Windows 11)
# ══════════════════════════════════════════════════════════════════════════════
function Invoke-DisableAI {
    Write-Log "══════ БЛОК 2: Copilot / AI / Cortana / Widgets ══════" 'HEAD'

    # ── Windows Recall (AI-знімки екрану) ──────────────────────────────────
    Write-Log "Вимкнення Windows Recall..."
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'           'DisableAIDataAnalysis'           1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'           'EnableRecallOnDevice'            0
    Set-Reg 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'           'DisableAIDataAnalysis'           1
    # Видалити компонент Recall якщо доступно (Windows 11 24H2+)
    if ($IsWin11) {
        & dism /online /disable-feature /featurename:Recall /norestart 2>$null
        Write-Log "Recall — спроба видалення через DISM." 'OK'
    }

    # ── Windows Copilot ────────────────────────────────────────────────────
    Write-Log "Вимкнення Windows Copilot..."
    Set-Reg 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot'      'TurnOffWindowsCopilot'           1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot'      'TurnOffWindowsCopilot'           1
    # Taskbar button
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowCopilotButton'            0

    # ── Copilot в Edge ─────────────────────────────────────────────────────
    Write-Log "Вимкнення Copilot в Edge/Office..."
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'                        'HubsSidebarEnabled'              0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'                        'CopilotPageContext'               0
    # Copilot в Office
    Set-Reg 'HKCU:\SOFTWARE\Policies\Microsoft\office\16.0\common\privacy'  'optionaldiagnosticdata'          0
    Set-Reg 'HKCU:\SOFTWARE\Policies\Microsoft\office\16.0\common\privacy'  'sendtelemetry'                   3

    # ── Cortana ────────────────────────────────────────────────────────────
    Write-Log "Вимкнення Cortana..."
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'      'AllowCortana'                    0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'      'AllowCortanaAboveLock'           0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'      'ConnectedSearchUseWeb'           0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'      'ConnectedSearchPrivacy'          3
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'      'DisableWebSearch'                1
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'        'CortanaEnabled'                  0
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'        'SearchboxTaskbarMode'            1
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'        'BingSearchEnabled'               0
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'        'AllowSearchToUseLocation'        0
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'        'HistoryViewEnabled'              0
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'        'DeviceHistoryEnabled'            0
    Disable-Task '\Microsoft\Windows\Cortana\'                               'SearchUserDataAccountProviders'
    Disable-Task '\Microsoft\Windows\Cortana\'                               'BingSafety'

    # ── Widgets (Windows 11) ───────────────────────────────────────────────
    Write-Log "Вимкнення Widgets..."
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarDa' 0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh'                         'AllowNewsAndInterests'           0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds'       'EnableFeeds'                     0

    # ── Фонові застосунки ──────────────────────────────────────────────────
    Write-Log "Вимкнення фонових застосунків..."
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' 'GlobalUserDisabled' 1
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'        'BackgroundAppGlobalToggle'       0

    # ── Онлайн-розпізнавання мовлення ─────────────────────────────────────
    Write-Log "Вимкнення онлайн-розпізнавання мовлення..."
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy' 'HasAccepted' 0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization'         'AllowInputPersonalization'       0

    Write-Log "БЛОК 2 завершено." 'OK'
}

# ══════════════════════════════════════════════════════════════════════════════
# БЛОК 3 — ДОЗВОЛИ ЗАСТОСУНКІВ
# ══════════════════════════════════════════════════════════════════════════════
function Invoke-DenyAppPermissions {
    Write-Log "══════ БЛОК 3: Дозволи застосунків ══════" 'HEAD'

    $base = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global'

    $guids = @{
        '{E5323777-F976-4f5b-9B55-B94699C46E44}' = 'Камера'
        '{2EEF81BE-33FA-4800-9670-1CD474972C3F}' = 'Мікрофон'
        '{C1D23ACC-752B-43E5-8448-8D0E519CD6D6}' = 'Рухова активність'
        '{7D7E8402-7C54-4821-A34E-AEEFD62DED93}' = 'Сповіщення'
        '{D89823BA-7180-4B81-B50C-7E471E6121A3}' = 'Обл. запис'
        '{992AFA70-6F47-4148-B3E9-3003349C1548}' = 'Дзвінки'
        '{21157C1F-2651-4CC1-90CA-1F28B02263F6}' = 'Повідомлення'
        '{A8804298-2D5F-42E3-9531-9C8C39EB29CE}' = 'Радіо'
        '{BFA794E4-F964-4FDB-90F6-51056BFE4B44}' = 'Геолокація'
        '{E6AD100E-5F4E-44CD-BE0F-2265D88D14F5}' = 'Контакти'
        '{235B668D-B2AC-4864-B49C-ED1084F6C9D3}' = 'Пристрої поруч'
        '{8BC668CF-7728-45BD-93F8-CF2B3B41D7AB}' = 'Телефонні дзвінки'
        '{52079E78-A92B-413F-B213-E8FE35712E72}' = 'Завдання'
        '{9231CB4C-BF57-4AF3-8C55-FDA7BFCC04C5}' = 'Email'
        '{9D9E0118-1807-4F2E-96E4-2CE57142E196}' = 'Діагностика застосунків'
        '{2297E4E2-5DBE-466D-A3B5-2556E3BA2B9A}' = 'Документи'
        '{3D0D3B23-6B8B-4B2B-A8BF-6B8E3F3B3F3B}' = 'Зображення'
        '{4D36E96D-E325-11CE-BFC1-08002BE10318}' = 'Відео'
    }

    foreach ($guid in $guids.Keys) {
        $p = "$base\$guid"
        if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
        Set-ItemProperty -Path $p -Name 'Type'  -Value 'InterfaceClass' -Type String -Force
        Set-ItemProperty -Path $p -Name 'Value' -Value 'Deny'           -Type String -Force
        Write-Log "Доступ заблоковано: $($guids[$guid])" 'OK'
    }

    # LooselyCoupled — широкий доступ UWP
    $lc = "$base\LooselyCoupled"
    if (-not (Test-Path $lc)) { New-Item -Path $lc -Force | Out-Null }
    Set-ItemProperty -Path $lc -Name 'Type'  -Value 'LooselyCoupled' -Type String -Force
    Set-ItemProperty -Path $lc -Name 'Value' -Value 'Deny'           -Type String -Force

    # Геолокація системний рівень
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors'  'DisableLocation'                 1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors'  'DisableLocationScripting'        1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors'  'DisableSensors'                  1
    # HKCU consent store (Windows 11)
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'             'Value' 'Deny' 'String'
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone'           'Value' 'Deny' 'String'
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam'               'Value' 'Deny' 'String'
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts'             'Value' 'Deny' 'String'
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments'         'Value' 'Deny' 'String'
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall'            'Value' 'Deny' 'String'
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat'                 'Value' 'Deny' 'String'
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email'                'Value' 'Deny' 'String'
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener' 'Value' 'Deny' 'String'
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\activity'             'Value' 'Deny' 'String'
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync'        'Value' 'Deny' 'String'

    # Камера на екрані блокування
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'     'NoLockScreenCamera'              1

    Write-Log "БЛОК 3 завершено." 'OK'
}

# ══════════════════════════════════════════════════════════════════════════════
# БЛОК 4 — НАЛАШТУВАННЯ ПРИВАТНОСТІ
# ══════════════════════════════════════════════════════════════════════════════
function Invoke-PrivacySettings {
    Write-Log "══════ БЛОК 4: Налаштування приватності ══════" 'HEAD'

    # ── OneDrive ───────────────────────────────────────────────────────────
    Write-Log "Вимкнення OneDrive..."
    Get-Process -Name 'OneDrive' -ErrorAction SilentlyContinue | Stop-Process -Force
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive'            'DisableFileSyncNGSC'             1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive'            'DisableMeteredNetworkFileSync'   1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive'            'DisableLibrariesDefaultSaveToOneDrive' 1
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\OneDrive'                             'DisablePersonalSync'             1
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowSyncProviderNotifications' 0
    @(
        'HKLM:\SOFTWARE\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}',
        'HKCU:\SOFTWARE\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}'
    ) | ForEach-Object { Set-Reg $_ 'System.IsPinnedToNameSpaceTree' 0 }
    if ($Is64) {
        @(
            'HKLM:\SOFTWARE\Wow6432Node\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}',
            'HKCU:\SOFTWARE\Wow6432Node\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}'
        ) | ForEach-Object { Set-Reg $_ 'System.IsPinnedToNameSpaceTree' 0 }
    }
    # Завдання OneDrive
    @('OneDrive Standalone Update Task v2','OneDrive Reporting Task-S-1-5-21') | ForEach-Object {
        Get-ScheduledTask -TaskName "*$_*" -ErrorAction SilentlyContinue |
            Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null
    }
    Write-Log "OneDrive вимкнено." 'OK'

    # ── Синхронізація CDP/PIM ──────────────────────────────────────────────
    Write-Log "Вимкнення сервісів синхронізації..."
    @('CDPUserSvc','OneSyncSvc','PimIndexMaintenanceSvc','UnistoreSvc',
      'UserDataSvc','MessagingService','WpnUserService') | ForEach-Object {
        $svcName = $_
        Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services' |
            Where-Object { $_.PSChildName -like "$svcName*" } |
            ForEach-Object { Set-Reg $_.PSPath 'Start' 4 }
    }
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'              'LetAppsSyncWithDevices'          2

    # ── SmartScreen ────────────────────────────────────────────────────────
    Write-Log "Вимкнення SmartScreen..."
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'              'EnableSmartScreen'               0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'              'ShellSmartScreenLevel'           'Off' 'String'
    Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer'      'SmartScreenEnabled'              'Off' 'String'
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost'       'EnableWebContentEvaluation'      0
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost'       'PreventOverride'                 0
    Disable-Task '\Microsoft\Windows\AppID\' 'SmartScreenSpecific'

    # ── WiFi Sense ─────────────────────────────────────────────────────────
    Write-Log "Вимкнення WiFi Sense..."
    Set-Reg 'HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config'     'AutoConnectAllowedOEM'           0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy'  'fMinimizeConnections'            1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy'  'fSoftDisconnectConnections'      1

    # ── Синхронізація налаштувань ──────────────────────────────────────────
    Write-Log "Вимкнення синхронізації налаштувань..."
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'         'DisableSettingSync'              2
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'         'DisableSettingSyncUserOverride'  1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'         'EnableBackupForWin8Apps'         0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'         'DisableApplicationSettingSync'   2
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'         'DisableAppSyncSettingSync'       2
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'         'DisableDesktopThemeSettingSync'  2
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'         'DisableStartLayoutSettingSync'   2
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'         'DisableWebBrowserSettingSync'    2
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'         'DisableWindowsCredentialSettingSync' 2
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'         'DisablePasswordSettingSync'      2

    # ── Windows Hello / Biometrics ─────────────────────────────────────────
    Write-Log "Вимкнення Windows Hello / Biometrics..."
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Biometrics'                  'Enabled'                         0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork'             'Enabled'                         0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'              'AllowDomainPINLogon'             0
    Disable-Svc 'WbioSrvc'

    # ── GameDVR / Game Bar ─────────────────────────────────────────────────
    Write-Log "Вимкнення Game DVR / Game Bar / Xbox..."
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR'             'AllowGameDVR'                    0
    Set-Reg 'HKCU:\System\GameConfigStore'                                   'GameDVR_Enabled'                 0
    Set-Reg 'HKCU:\System\GameConfigStore'                                   'GameDVR_FSEBehaviorMode'         2
    Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR'       'AppCaptureEnabled'               0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR'             'DownloadGameInfo'                0

    # ── Store / AppStore ───────────────────────────────────────────────────
    Write-Log "Обмеження Windows Store..."
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore'                'DisableStoreApps'                1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore'                'RemoveWindowsStore'              1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore'                'AutoDownload'                    2
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore'                'DisableAutoInstall'              1

    # ── DRM ───────────────────────────────────────────────────────────────
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\WMDRM'                       'DisableOnline'                   1

    # ── Media Foundation (авто-відкривання камери) ─────────────────────────
    Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows Media Foundation'             'EnableFrameServerMode'           0
    if ($Is64) {
        Set-Reg 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows Media Foundation' 'EnableFrameServerMode' 0
    }

    # ── MRT / Defender без звітування ─────────────────────────────────────
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\MRT'                         'DontOfferThroughWUAU'            1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\MRT'                         'DontReportInfectionInformation'  1

    # ── Віддалений робочий стіл (вимкнути якщо не потрібен) ───────────────
    Write-Log "Вимкнення RDP (Remote Desktop)..."
    Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'        'fDenyTSConnections'              1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' 'fDenyTSConnections'             1
    Disable-Svc 'TermService'
    Disable-Svc 'UmRdpService'

    # ── NetBIOS / LLMNR (витік імені машини) ──────────────────────────────
    Write-Log "Вимкнення LLMNR та NetBIOS..."
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient'        'EnableMulticast'                 0
    # NetBIOS вимкнути на всіх адаптерах
    Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces' |
        ForEach-Object { Set-Reg $_.PSPath 'NetbiosOptions' 2 }

    # ── Автозапуск / AutoRun ───────────────────────────────────────────────
    Write-Log "Вимкнення AutoRun/AutoPlay..."
    Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoDriveTypeAutoRun' 255
    Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoAutorun'          1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'             'NoAutoplayfornonVolume'          1

    Write-Log "БЛОК 4 завершено." 'OK'
}

# ══════════════════════════════════════════════════════════════════════════════
# БЛОК 5 — МЕРЕЖА: БРАНДМАУЕР + HOSTS + DNS
# ══════════════════════════════════════════════════════════════════════════════
function Invoke-NetworkHardening {
    Write-Log "══════ БЛОК 5: Мережа — Брандмауер / Hosts / DNS ══════" 'HEAD'

    # ── 5.1 Firewall — блокування IP телеметрії Microsoft ──────────────────
    Write-Log "Додавання правил брандмауера для блокування телеметрії..."
    # Актуальні IP-адреси телеметрії Microsoft (2025)
    $telemetryIPs = @(
        '134.170.30.202','137.116.81.24','157.56.106.189',
        '184.86.53.99','2.22.61.43','2.22.61.44',
        '204.79.197.200','23.218.212.69','65.55.108.23',
        '65.55.252.43','64.4.54.254','65.52.108.33',
        '191.232.139.254','65.55.252.63','65.52.100.7',
        '207.68.128.11','94.245.121.3','111.221.29.177',
        '23.102.21.4','23.102.4.253','131.253.40.37',
        '65.52.108.29','191.237.218.239','131.253.34.230'
    )
    Add-FirewallBlock 'Block MS Telemetry IPs' $telemetryIPs

    # Блокування NVIDIA телеметрії
    $nvidiaTelIPs = @('169.254.0.0','192.169.1.0')
    Add-FirewallBlock 'Block NVIDIA Telemetry IPs' $nvidiaTelIPs

    # Вимкнути вхідні підключення RemoteRegistry, RPC за замовчуванням
    Get-NetFirewallRule -DisplayName "Remote*" -ErrorAction SilentlyContinue |
        Where-Object { $_.Direction -eq 'Inbound' -and $_.Action -eq 'Allow' } |
        ForEach-Object {
            Set-NetFirewallRule -Name $_.Name -Enabled False -ErrorAction SilentlyContinue
            Write-Log "Вхідне правило вимкнено: $($_.DisplayName)" 'WARN'
        }

    # ── 5.2 HOSTS файл — блокування доменів телеметрії ────────────────────
    Write-Log "Оновлення hosts файлу..."
    $hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"

    $telemetryDomains = @(
        '# ── Microsoft Telemetry ──────────────────────────────────────────',
        '0.0.0.0 vortex.data.microsoft.com',
        '0.0.0.0 vortex-win.data.microsoft.com',
        '0.0.0.0 telecommand.telemetry.microsoft.com',
        '0.0.0.0 telecommand.telemetry.microsoft.com.nsatc.net',
        '0.0.0.0 oca.telemetry.microsoft.com',
        '0.0.0.0 oca.telemetry.microsoft.com.nsatc.net',
        '0.0.0.0 sqm.telemetry.microsoft.com',
        '0.0.0.0 sqm.telemetry.microsoft.com.nsatc.net',
        '0.0.0.0 watson.telemetry.microsoft.com',
        '0.0.0.0 watson.telemetry.microsoft.com.nsatc.net',
        '0.0.0.0 redir.metaservices.microsoft.com',
        '0.0.0.0 choice.microsoft.com',
        '0.0.0.0 choice.microsoft.com.nsatc.net',
        '0.0.0.0 df.telemetry.microsoft.com',
        '0.0.0.0 reports.wes.df.telemetry.microsoft.com',
        '0.0.0.0 wes.df.telemetry.microsoft.com',
        '0.0.0.0 services.wes.df.telemetry.microsoft.com',
        '0.0.0.0 sqm.df.telemetry.microsoft.com',
        '0.0.0.0 telemetry.microsoft.com',
        '0.0.0.0 watson.ppe.telemetry.microsoft.com',
        '0.0.0.0 telemetry.appex.bing.net',
        '0.0.0.0 telemetry.urs.microsoft.com',
        '0.0.0.0 telemetry.appex.bing.net:443',
        '0.0.0.0 settings-sandbox.data.microsoft.com',
        '0.0.0.0 vortex-sandbox.data.microsoft.com',
        '0.0.0.0 survey.watson.microsoft.com',
        '0.0.0.0 watson.live.com',
        '0.0.0.0 watson.microsoft.com',
        '0.0.0.0 statsfe2.ws.microsoft.com',
        '0.0.0.0 corpext.msitadfs.glbdns2.microsoft.com',
        '0.0.0.0 compatexchange.cloudapp.net',
        '0.0.0.0 cs1.wpc.v0cdn.net',
        '0.0.0.0 a-0001.a-msedge.net',
        '0.0.0.0 statsfe2.update.microsoft.com.akadns.net',
        '0.0.0.0 sls.update.microsoft.com.akadns.net',
        '0.0.0.0 fe2.update.microsoft.com.akadns.net',
        '0.0.0.0 diagnostics.support.microsoft.com',
        '0.0.0.0 rstats.update.microsoft.com',
        '# ── NVIDIA Telemetry ─────────────────────────────────────────────',
        '0.0.0.0 events.gfe.nvidia.com',
        '0.0.0.0 telemetry.nvidia.com',
        '0.0.0.0 ssl.google-analytics.com',
        '0.0.0.0 www.google-analytics.com',
        '# ── Adobe Telemetry ──────────────────────────────────────────────',
        '0.0.0.0 activate.adobe.com',
        '0.0.0.0 practivate.adobe.com',
        '0.0.0.0 ereg.adobe.com',
        '0.0.0.0 activate.wip3.adobe.com',
        '0.0.0.0 wip3.adobe.com',
        '0.0.0.0 3dns-3.adobe.com',
        '0.0.0.0 hl2rcv.adobe.com'
    )

    # Резервна копія hosts
    $hostsBackup = "$hostsPath.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $hostsPath $hostsBackup -Force
    Write-Log "Резервна копія hosts: $hostsBackup" 'OK'

    # Додати лише рядки, яких ще немає
    $existingContent = Get-Content $hostsPath -ErrorAction SilentlyContinue
    $newEntries = $telemetryDomains | Where-Object {
        $_ -notmatch '^#' -and ($existingContent -notcontains $_)
    }
    if ($newEntries.Count -gt 0) {
        Add-Content -Path $hostsPath -Value "`n# === Privacy Hardening v5.0 $(Get-Date -Format 'yyyy-MM-dd') ===" -Encoding UTF8
        $newEntries | Add-Content -Path $hostsPath -Encoding UTF8
        Write-Log "Hosts оновлено: додано $($newEntries.Count) записів." 'OK'
    } else {
        Write-Log "Hosts вже містить усі записи." 'WARN'
    }

    # ── 5.3 DNS — перемикання на Cloudflare / Privacy DNS ─────────────────
    Write-Log "Налаштування DNS на Cloudflare (1.1.1.1)..."
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
    foreach ($a in $adapters) {
        Set-DnsClientServerAddress -InterfaceIndex $a.InterfaceIndex -ServerAddresses @('1.1.1.1','1.0.0.1')
        Write-Log "DNS встановлено для: $($a.Name)" 'OK'
    }

    # Вимкнути IPv6 (може витікати реальна IP через WebRTC тощо)
    Write-Log "Вимкнення IPv6 на адаптерах..."
    Get-NetAdapter | ForEach-Object {
        Disable-NetAdapterBinding -Name $_.Name -ComponentID 'ms_tcpip6' -ErrorAction SilentlyContinue
    }
    Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters'     'DisabledComponents'              255

    # Flush DNS після змін
    Clear-DnsClientCache
    Write-Log "DNS очищено після змін." 'OK'

    Write-Log "БЛОК 5 завершено." 'OK'
}

# ══════════════════════════════════════════════════════════════════════════════
# БЛОК 6 — ОНОВЛЕННЯ WINDOWS
# ══════════════════════════════════════════════════════════════════════════════
function Invoke-UpdateHardening {
    Write-Log "══════ БЛОК 6: Оновлення Windows ══════" 'HEAD'

    # Відкласти Feature Updates на 365 днів, Quality — на 30
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'       'DeferFeatureUpdates'             1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'       'DeferFeatureUpdatesPeriodInDays' 365
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'       'DeferQualityUpdates'             1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'       'DeferQualityUpdatesPeriodInDays' 30
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'       'ExcludeWUDriversInQualityUpdate' 1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'       'DisableWindowsUpdateAccess'      0

    # Без автоперезавантаження
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'    'NoAutoRebootWithLoggedOnUsers'   1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'    'AUPowerManagement'               0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'    'AutoInstallMinorUpdates'         0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'    'IncludeRecommendedUpdates'       0

    # Delivery Optimization (P2P-роздача) — вимкнути
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' 'DODownloadMode'                 0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' 'DOMaxUploadBandwidth'           0
    Disable-Svc 'DoSvc'

    # MCT / Windows Upgrade
    Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade' 'HideMCTLink'           1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'       'DisableOSUpgrade'                1
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GWX'                 'DisableGwx'                      1

    # BITS (Background Intelligent Transfer) — лише ручний запуск
    Set-Service 'BITS' -StartupType Manual -ErrorAction SilentlyContinue
    Write-Log "BITS → ручний запуск." 'OK'

    Write-Log "БЛОК 6 завершено." 'OK'
}

# ══════════════════════════════════════════════════════════════════════════════
# БЛОК 7 — ОЧИЩЕННЯ КРИМІНАЛІСТИЧНИХ АРТЕФАКТІВ
# ══════════════════════════════════════════════════════════════════════════════
function Invoke-CleanupArtifacts {
    Write-Log "══════ БЛОК 7: Очищення артефактів ══════" 'HEAD'

    # ── 7.1 Тимчасові файли ────────────────────────────────────────────────
    Write-Log "Очищення тимчасових файлів..."
    $tempPaths = @(
        $env:TEMP, $env:TMP,
        "$env:LOCALAPPDATA\Temp",
        "$env:WINDIR\Temp",
        "$env:LOCALAPPDATA\Microsoft\Windows\INetCache",
        "$env:LOCALAPPDATA\Microsoft\Windows\WebCache",
        "$env:LOCALAPPDATA\Microsoft\Windows\Explorer",   # thumbcache_*.db
        "$env:LOCALAPPDATA\Microsoft\Windows\Caches",
        "$env:LOCALAPPDATA\CrashDumps",
        "$env:WINDIR\Minidump",
        "$env:WINDIR\MEMORY.DMP"
    ) | Select-Object -Unique
    $removed = 0
    foreach ($p in $tempPaths) {
        if (-not (Test-Path -LiteralPath $p)) { continue }
        if ((Get-Item $p).PSIsContainer) {
            Get-ChildItem -LiteralPath $p -Force -Recurse -ErrorAction SilentlyContinue |
                ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force -Recurse -ErrorAction SilentlyContinue; $removed++ }
        } else { Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue; $removed++ }
    }
    Write-Log "Видалено об'єктів: $removed." 'OK'

    # ── 7.2 Prefetch ───────────────────────────────────────────────────────
    Write-Log "Очищення Prefetch..."
    Get-ChildItem "$env:WINDIR\Prefetch" -Filter '*.pf' -Force -ErrorAction SilentlyContinue |
        Remove-Item -Force
    Write-Log "Prefetch очищено." 'OK'

    # ── 7.3 Нещодавні документи + реєстр ──────────────────────────────────
    Write-Log "Очищення нещодавніх документів..."
    @(
        "$env:APPDATA\Microsoft\Windows\Recent",
        "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations",
        "$env:APPDATA\Microsoft\Windows\Recent\CustomDestinations",
        "$env:APPDATA\Microsoft\Office\Recent"
    ) | ForEach-Object {
        if (Test-Path $_) {
            Get-ChildItem $_ -Force -ErrorAction SilentlyContinue |
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
    @(
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU',
        'HKCU:\Software\Microsoft\Office\16.0\Common\Open Find'
    ) | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
    Write-Log "Нещодавні документи очищено." 'OK'

    # ── 7.4 Пошукова + командна історія реєстру ───────────────────────────
    Write-Log "Очищення пошукової та командної історії..."
    @(
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps',
        'HKCU:\Software\Microsoft\Internet Explorer\TypedURLs',
        'HKCU:\Software\Microsoft\Internet Explorer\TypedURLsTime',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Map Network Drive MRU'
    ) | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
    Write-Log "Пошукова історія очищена." 'OK'

    # ── 7.5 PowerShell історія (перезапис нулями) ──────────────────────────
    Write-Log "Перезапис та видалення історії PowerShell..."
    @(
        "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt",
        "$env:USERPROFILE\.config\powershell\PSReadLine\ConsoleHost_history.txt"
    ) | ForEach-Object {
        if (Test-Path $_) {
            $bytes = [System.IO.File]::ReadAllBytes($_)
            [Array]::Clear($bytes, 0, $bytes.Length)
            [System.IO.File]::WriteAllBytes($_, $bytes)
            Remove-Item $_ -Force
            Write-Log "Перезаписано: $_" 'OK'
        }
    }

    # ── 7.6 DNS, ARP, мережа ──────────────────────────────────────────────
    Write-Log "Очищення мережевих кешів..."
    Clear-DnsClientCache -ErrorAction SilentlyContinue
    arp -d * 2>$null
    nbtstat -R 2>$null       # Очистити NetBIOS кеш
    nbtstat -RR 2>$null      # Оновити NetBIOS
    netsh winsock reset 2>$null
    Write-Log "DNS, ARP, NetBIOS кеш очищено." 'OK'

    # Мережеві профілі
    $netProf = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles'
    if (Test-Path $netProf) {
        Get-ChildItem $netProf | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }

    # ── 7.7 Буфер обміну ──────────────────────────────────────────────────
    Write-Log "Очищення буфера обміну..."
    try {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.Clipboard]::Clear()
    } catch { cmd /c "echo off | clip" 2>$null }
    # Вимкнути Cloud Clipboard (синхронізація буфера з хмарою)
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'              'AllowClipboardHistory'           0
    Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'              'AllowCrossDeviceClipboard'       0
    Write-Log "Буфер обміну очищено та синхронізацію вимкнено." 'OK'

    # ── 7.8 Тіньові копії ─────────────────────────────────────────────────
    Write-Log "Видалення тіньових копій..."
    $shadows = @(Get-CimInstance -ClassName Win32_ShadowCopy -ErrorAction SilentlyContinue)
    if ($shadows.Count -gt 0) {
        $shadows | Remove-CimInstance -ErrorAction SilentlyContinue
        Write-Log "Видалено: $($shadows.Count) тіньових копій." 'OK'
    } else { Write-Log "Тіньові копії відсутні." 'WARN' }

    # ── 7.9 Журнали подій ─────────────────────────────────────────────────
    Write-Log "Очищення журналів подій..."
    $logs    = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue |
               Where-Object { $_.IsEnabled -and $_.RecordCount -gt 0 }
    $cleared = 0; $skipped = 0
    foreach ($log in $logs) {
        try {
            [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($log.LogName)
            $cleared++
        } catch [System.UnauthorizedAccessException] { $skipped++ }
          catch { $skipped++ }
    }
    wevtutil cl Security 2>$null
    Write-Log "Журнали очищено: $cleared, пропущено: $skipped." 'OK'

    # ── 7.10 Windows Defender ─────────────────────────────────────────────
    $defPath = Join-Path $env:ProgramData 'Microsoft\Windows Defender\Scans\History\Service'
    if (Test-Path $defPath) {
        Remove-Item "$defPath\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Журнал Defender очищено." 'OK'
    }

    # ── 7.11 Браузери ─────────────────────────────────────────────────────
    Write-Log "Очищення даних браузерів..."
    $browsers = @{
        Chrome  = @("$env:LOCALAPPDATA\Google\Chrome\User Data\Default\History",
                    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies",
                    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data",
                    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Web Data",
                    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
                    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Network\Cookies")
        Edge    = @("$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\History",
                    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cookies",
                    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Login Data",
                    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
                    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Network\Cookies")
        Firefox = @("$env:APPDATA\Mozilla\Firefox\Profiles")
        Brave   = @("$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\History",
                    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cookies",
                    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cache")
        Opera   = @("$env:APPDATA\Opera Software\Opera Stable\History",
                    "$env:APPDATA\Opera Software\Opera Stable\Cookies",
                    "$env:APPDATA\Opera Software\Opera Stable\Cache")
        Vivaldi = @("$env:LOCALAPPDATA\Vivaldi\User Data\Default\History",
                    "$env:LOCALAPPDATA\Vivaldi\User Data\Default\Cookies",
                    "$env:LOCALAPPDATA\Vivaldi\User Data\Default\Cache")
    }
    foreach ($b in $browsers.Keys) {
        $found = $false
        foreach ($p in $browsers[$b]) {
            if (-not (Test-Path $p)) { continue }
            $found = $true
            if ((Get-Item $p).PSIsContainer) {
                Get-ChildItem $p -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            } else { Remove-Item $p -Force -ErrorAction SilentlyContinue }
        }
        if ($found) { Write-Log "$b — очищено." 'OK' }
    }

    Write-Log "БЛОК 7 завершено." 'OK'
}

# ══════════════════════════════════════════════════════════════════════════════
# БЛОК 8 — ПЕРЕЗАПИС ВІЛЬНОГО МІСЦЯ (cipher /w)
# ══════════════════════════════════════════════════════════════════════════════
function Invoke-SecureWipe {
    param([string]$Drive = 'C:')
    Write-Log "══════ БЛОК 8: Безпечний перезапис диску $Drive ══════" 'HEAD'
    Write-Log "cipher /w — тричі перезаписує вільне місце (0x00, 0xFF, random)." 'WARN'
    Write-Log "Може тривати від 5 хвилин до кількох годин. Не переривайте!" 'WARN'
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    & cipher /w:"$Drive\" 2>&1 | Out-Null
    $sw.Stop()
    Write-Log "Перезапис завершено за $([math]::Round($sw.Elapsed.TotalMinutes,1)) хв." 'OK'
}

# ══════════════════════════════════════════════════════════════════════════════
# БЛОК 9 — АУДИТ: ПЕРЕВІРКА ПОТОЧНОГО СТАНУ ПРИВАТНОСТІ
# ══════════════════════════════════════════════════════════════════════════════
function Invoke-PrivacyAudit {
    Write-Log "══════ БЛОК 9: Аудит стану приватності ══════" 'HEAD'

    $checks = @(
        @{
            Name = 'Телеметрія AllowTelemetry = 0'
            Test = {
                $v = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -ErrorAction SilentlyContinue).AllowTelemetry
                $v -eq 0
            }
        },
        @{
            Name = 'Сервіс DiagTrack вимкнено'
            Test = {
                (Get-Service 'DiagTrack' -ErrorAction SilentlyContinue).StartType -eq 'Disabled'
            }
        },
        @{
            Name = 'Рекламний ID вимкнено'
            Test = {
                $v = (Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -ErrorAction SilentlyContinue).Enabled
                $v -eq 0
            }
        },
        @{
            Name = 'OneDrive вимкнено (DisableFileSyncNGSC)'
            Test = {
                $v = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' -Name 'DisableFileSyncNGSC' -ErrorAction SilentlyContinue).DisableFileSyncNGSC
                $v -eq 1
            }
        },
        @{
            Name = 'Copilot вимкнено'
            Test = {
                $v = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' -Name 'TurnOffWindowsCopilot' -ErrorAction SilentlyContinue).TurnOffWindowsCopilot
                $v -eq 1
            }
        },
        @{
            Name = 'Windows Recall вимкнено'
            Test = {
                $v = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' -Name 'DisableAIDataAnalysis' -ErrorAction SilentlyContinue).DisableAIDataAnalysis
                $v -eq 1
            }
        },
        @{
            Name = 'RDP вимкнено'
            Test = {
                $v = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -ErrorAction SilentlyContinue).fDenyTSConnections
                $v -eq 1
            }
        },
        @{
            Name = 'RemoteRegistry вимкнено'
            Test = {
                (Get-Service 'RemoteRegistry' -ErrorAction SilentlyContinue).StartType -eq 'Disabled'
            }
        },
        @{
            Name = 'LLMNR вимкнено'
            Test = {
                $v = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' -Name 'EnableMulticast' -ErrorAction SilentlyContinue).EnableMulticast
                $v -eq 0
            }
        },
        @{
            Name = 'Delivery Optimization вимкнено'
            Test = {
                $v = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Name 'DODownloadMode' -ErrorAction SilentlyContinue).DODownloadMode
                $v -eq 0
            }
        }
    )

    Write-Host "`n  ┌──────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host   "  │              АУДИТ ПРИВАТНОСТІ                      │" -ForegroundColor Cyan
    Write-Host   "  └──────────────────────────────────────────────────────┘" -ForegroundColor Cyan

    $passed = 0; $failed = 0
    foreach ($c in $checks) {
        $ok = & $c.Test
        if ($ok) {
            Write-Host "  [✓] $($c.Name)" -ForegroundColor Green
            $passed++
        } else {
            Write-Host "  [✗] $($c.Name) — РИЗИК!" -ForegroundColor Red
            $failed++
        }
        Write-Log "$($c.Name): $(if($ok){'OK'}else{'FAIL'})" $(if($ok){'OK'}else{'ERROR'})
    }

    Write-Host ""
    Write-Host "  Пройдено: $passed / $($checks.Count)" -ForegroundColor $(if($failed -eq 0){'Green'}else{'Yellow'})
    if ($failed -gt 0) {
        Write-Host "  Виявлено ризиків: $failed — рекомендується запустити відповідні блоки!" -ForegroundColor Red
    }
    Write-Host ""
    Write-Log "Аудит завершено: $passed пройдено, $failed ризиків." $(if($failed -eq 0){'OK'}else{'WARN'})
}

# ══════════════════════════════════════════════════════════════════════════════
# ГОЛОВНЕ МЕНЮ
# ══════════════════════════════════════════════════════════════════════════════
function Show-Menu {
    Clear-Host
    $winLabel = if ($IsWin11) { "Windows 11" } else { "Windows 10" }
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║   Privacy & Security Hardening  v5.0 UA                 ║" -ForegroundColor Cyan
    Write-Host "  ║   $winLabel · $(Get-Date -Format 'dd.MM.yyyy HH:mm')                         ║" -ForegroundColor DarkCyan
    Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1]  Телеметрія та стеження       (сервіси + реєстр + завдання)" -ForegroundColor Magenta
    Write-Host "  [2]  Copilot / AI / Cortana / Widgets" -ForegroundColor Magenta
    Write-Host "  [3]  Дозволи застосунків           (камера, мік, локація + ConsentStore)" -ForegroundColor Yellow
    Write-Host "  [4]  Приватність                   (OneDrive, SmartScreen, RDP, LLMNR...)" -ForegroundColor Yellow
    Write-Host "  [5]  Мережа                        (Firewall + Hosts + DNS + IPv6)" -ForegroundColor Cyan
    Write-Host "  [6]  Оновлення Windows             (відстрочка, P2P off, без перезавант.)" -ForegroundColor Green
    Write-Host "  [7]  Очищення артефактів           (temp/prefetch/браузери/журнали/DNS)" -ForegroundColor Green
    Write-Host "  [8]  Перезапис диску               (cipher /w — повільно, незворотно)" -ForegroundColor Red
    Write-Host "  [9]  Аудит приватності             (перевірка поточного стану)" -ForegroundColor White
    Write-Host "  [A]  Все вищезазначене             (повний захист, крім cipher)" -ForegroundColor Red
    Write-Host "  [Q]  Вихід" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Лог: $LogFile" -ForegroundColor DarkGray
    Write-Host ""
}

# ── Основний цикл ─────────────────────────────────────────────────────────────
do {
    Show-Menu
    $choice = (Read-Host "  Оберіть дію").Trim().ToUpper()

    switch ($choice) {
        '1' { Invoke-DisableSpy }
        '2' { Invoke-DisableAI }
        '3' { Invoke-DenyAppPermissions }
        '4' { Invoke-PrivacySettings }
        '5' { Invoke-NetworkHardening }
        '6' { Invoke-UpdateHardening }
        '7' { Invoke-CleanupArtifacts }
        '8' {
            $drv = (Read-Host "  Літера диску (Enter = C:)").Trim()
            if ([string]::IsNullOrWhiteSpace($drv)) { $drv = 'C:' }
            if ($drv -notmatch '^[A-Za-z]:?$') {
                Write-Log "Невірна літера диску: $drv" 'ERROR'
                continue
            }
            if ($drv.Length -eq 1) { $drv = "${drv}:" }
            $confirm = Read-Host "  УВАГА: cipher /w незворотний. Продовжити? (Y/N)"
            if ($confirm -eq 'Y') { Invoke-SecureWipe -Drive $drv }
        }
        '9' { Invoke-PrivacyAudit }
        'A' {
            Invoke-DisableSpy
            Invoke-DisableAI
            Invoke-DenyAppPermissions
            Invoke-PrivacySettings
            Invoke-NetworkHardening
            Invoke-UpdateHardening
            Invoke-CleanupArtifacts
            Write-Host "  Cipher /w пропущено (запустіть [8] окремо)." -ForegroundColor Yellow
        }
        'Q' { break }
        default { Write-Log "Невірний вибір: $choice" 'WARN' }
    }

    if ($choice -ne 'Q') {
        Write-Host ""
        Write-Host "  [✓] Готово. Enter — повернутись до меню..." -ForegroundColor Green
        Read-Host | Out-Null
    }

} while ($choice -ne 'Q')

Write-Log "Сесію завершено. Лог: $LogFile" 'OK'
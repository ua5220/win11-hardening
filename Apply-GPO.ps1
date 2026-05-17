#Requires -RunAsAdministrator
<#
.SYNOPSIS
    GPO Edition 3.0 — Apply / Revert / Check Windows 11 hardening via LGPO.exe
.DESCRIPTION
    Застосовує Administrative Templates-налаштування через офіційний Microsoft LGPO.exe.
    Підтримує три режими: Apply, Revert, Check.
    Покриває 9 розділів: Defender, Firewall, Security, Privacy, Network, Audit,
    BitLocker, Update, Office.
.PARAMETER Action
    Apply   — застосувати всі політики
    Revert  — скасувати (відновити стандарт)
    Check   — перевірити поточний стан реєстру
.EXAMPLE
    .\Apply-GPO.ps1 -Action Apply
    .\Apply-GPO.ps1 -Action Check
    .\Apply-GPO.ps1 -Action Revert
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Apply','Revert','Check')]
    [string]$Action
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir   = $PSScriptRoot
$LGPOPath    = Join-Path $ScriptDir 'LGPO.exe'
$PoliciesDir = Join-Path $ScriptDir 'policies'
$RevertDir   = Join-Path $ScriptDir 'policies\revert'

# ── Перевірка LGPO.exe ──────────────────────────────────────────────────────
if (-not (Test-Path $LGPOPath)) {
    # Спробувати автозавантаження
    $toolsScript = Join-Path $ScriptDir 'tools\Get-LGPO.ps1'
    if (Test-Path $toolsScript) {
        Write-Host "LGPO.exe не знайдено. Запускаю Get-LGPO.ps1..." -ForegroundColor Yellow
        & $toolsScript
    }
    if (-not (Test-Path $LGPOPath)) {
        Write-Error "LGPO.exe не знайдено: $LGPOPath. Покладіть LGPO.exe в папку v3-gpo/ або запустіть tools\Get-LGPO.ps1"
        exit 1
    }
}

$PolicyFiles = @(
    'defender.txt'
    'firewall.txt'
    'security.txt'
    'privacy.txt'
    'network.txt'
    'audit.txt'
    'bitlocker.txt'
    'update.txt'
    'office.txt'
)

$SecurityTemplate = 'GptTmpl.inf'

function Invoke-LGPO {
    param([string]$PolicyFile)
    $FullPath = Join-Path $PoliciesDir $PolicyFile
    if (-not (Test-Path $FullPath)) {
        Write-Warning "Пропускаємо (не знайдено): $FullPath"
        return
    }
    Write-Host "  [LGPO] Застосовую: $PolicyFile" -ForegroundColor Cyan
    $Result = & $LGPOPath /t $FullPath /v 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "LGPO повернув код $LASTEXITCODE для $PolicyFile"
        $Result | ForEach-Object { Write-Warning $_ }
    } else {
        Write-Host "  [OK] $PolicyFile" -ForegroundColor Green
    }
}

function Invoke-SecurityTemplate {
    $InfPath = Join-Path $PoliciesDir $SecurityTemplate
    if (-not (Test-Path $InfPath)) {
        Write-Warning "Security template не знайдено: $InfPath (пропускаємо)"
        return
    }
    $SdbPath = Join-Path $env:TEMP 'gpo-secedit.sdb'
    $LogPath = Join-Path $env:TEMP 'gpo-secedit.log'
    Write-Host "  [SECEDIT] Застосовую: $SecurityTemplate" -ForegroundColor Cyan
    $Result = & secedit /configure /db $SdbPath /cfg $InfPath /log $LogPath /overwrite /quiet 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "secedit повернув код $LASTEXITCODE для $SecurityTemplate"
        if (Test-Path $LogPath) { Get-Content $LogPath | ForEach-Object { Write-Warning $_ } }
    } else {
        Write-Host "  [OK] $SecurityTemplate" -ForegroundColor Green
    }
    Remove-Item $SdbPath -ErrorAction SilentlyContinue
    Remove-Item $LogPath -ErrorAction SilentlyContinue
}

function Invoke-SecurityTemplate-Revert {
    Write-Host "  [SECEDIT] Відкочую Security Template (скидання до стандартних)..." -ForegroundColor Yellow
    $DefaultInf = "$env:SystemRoot\inf\defltbase.inf"
    if (-not (Test-Path $DefaultInf)) {
        Write-Warning "Стандартний шаблон $DefaultInf не знайдено. Пропускаємо відкат Security Template."
        return
    }
    $SdbPath = Join-Path $env:TEMP 'gpo-secedit-revert.sdb'
    & secedit /configure /db $SdbPath /cfg $DefaultInf /overwrite /quiet 2>&1 | Out-Null
    Write-Host "  [OK] Security Template відкочено до стандартних" -ForegroundColor Green
    Remove-Item $SdbPath -ErrorAction SilentlyContinue
}

function Invoke-LGPO-Revert {
    param([string]$PolicyFile)
    $FullPath = Join-Path $RevertDir $PolicyFile
    if (-not (Test-Path $FullPath)) {
        Write-Warning "Revert-файл не знайдено: $FullPath (пропускаємо)"
        return
    }
    Write-Host "  [LGPO] Відкочую: $PolicyFile" -ForegroundColor Yellow
    & $LGPOPath /t $FullPath /v 2>&1 | Out-Null
    Write-Host "  [OK] Revert: $PolicyFile" -ForegroundColor Green
}

function Get-CheckValue {
    param([string]$RegPath, [string]$ValueName)
    try {
        $val = Get-ItemProperty -Path $RegPath -Name $ValueName -ErrorAction Stop
        return $val.$ValueName
    } catch {
        return '(не задано)'
    }
}

function Invoke-Check {
    Write-Host "`n=== GPO Edition 3.0 — Check ==="  -ForegroundColor Magenta

    $Checks = @(
        # ── Defender ───────────────────────────────────────────────────────
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender'; Name='DisableAntiSpyware';       Expect=0;   Label='Defender: AntiSpyware = ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender'; Name='PUAProtection';            Expect=1;   Label='Defender: PUA Protection = ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender'; Name='DisableLocalAdminMerge';   Expect=1;   Label='Defender: DisableLocalAdminMerge = ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection'; Name='DisableRealtimeMonitoring'; Expect=0; Label='Defender: Real-Time = ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection'; Name='DisableScriptScanning'; Expect=0; Label='Defender: Script Scanning = ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine'; Name='MpEnablePus'; Expect=1; Label='Defender: PUS Engine = ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine'; Name='MpCloudBlockLevel'; Expect=2; Label='Defender: Cloud Block = High' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet'; Name='SpynetReporting'; Expect=2; Label='Defender: MAPS = Advanced' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet'; Name='SubmitSamplesConsent'; Expect=3; Label='Defender: Samples = All' }
        # ASR
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR'; Name='ExploitGuard_ASR_Rules'; Expect=1; Label='ASR: Rules Enabled' }
        # Network Protection
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection'; Name='EnableNetworkProtection'; Expect=1; Label='Network Protection: ON' }
        # CFA
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access'; Name='EnableControlledFolderAccess'; Expect=1; Label='CFA: ON' }
        # SmartScreen
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name='EnableSmartScreen'; Expect=1; Label='SmartScreen: ON' }
        # Recall
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'; Name='DisableAIDataAnalysis'; Expect=1; Label='Recall: Disabled' }
        # DMA
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection'; Name='DeviceEnumerationPolicy'; Expect=0; Label='DMA: Block all' }
        # Exploit Protection Override
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection'; Name='DisallowExploitProtectionOverride'; Expect=1; Label='Exploit Protection: No Override' }

        # ── Firewall ──────────────────────────────────────────────────────
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile'; Name='EnableFirewall'; Expect=1; Label='Firewall: Domain = ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile'; Name='EnableFirewall'; Expect=1; Label='Firewall: Private = ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile'; Name='EnableFirewall'; Expect=1; Label='Firewall: Public = ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile'; Name='DefaultInboundAction'; Expect=1; Label='Firewall: Domain Inbound = Block' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile'; Name='DefaultInboundAction'; Expect=1; Label='Firewall: Public Inbound = Block' }

        # ── UAC / Security ────────────────────────────────────────────────
        @{ Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name='EnableLUA'; Expect=1; Label='UAC: EnableLUA = 1' }
        @{ Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name='ConsentPromptBehaviorAdmin'; Expect=2; Label='UAC: Prompt = 2 (Consent)' }
        @{ Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name='PromptOnSecureDesktop'; Expect=1; Label='UAC: SecureDesktop = ON' }
        @{ Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name='FilterAdministratorToken'; Expect=1; Label='UAC: FilterAdmin = ON' }
        # LSASS
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name='RunAsPPL'; Expect=1; Label='LSA: PPL = ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name='AllowCustomSSPsAPs'; Expect=0; Label='LSA: Custom SSP = OFF' }
        # LSA
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'; Name='LmCompatibilityLevel'; Expect=5; Label='NTLM: NTLMv2 only (Level 5)' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'; Name='NoLMHash'; Expect=1; Label='LSA: No LM Hash' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'; Name='RestrictAnonymous'; Expect=1; Label='LSA: Restrict Anonymous' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'; Name='DisableDomainCreds'; Expect=1; Label='LSA: DisableDomainCreds' }
        # WDigest
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\SecurityProviders\WDigest'; Name='UseLogonCredential'; Expect=0; Label='WDigest: OFF' }
        # VBS / Device Guard
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard'; Name='EnableVirtualizationBasedSecurity'; Expect=1; Label='VBS: ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard'; Name='HypervisorEnforcedCodeIntegrity'; Expect=1; Label='HVCI: ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard'; Name='LsaCfgFlags'; Expect=1; Label='Credential Guard: ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard'; Name='ConfigureSystemGuardLaunch'; Expect=1; Label='System Guard: ON' }
        # RDP
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'; Name='fDenyTSConnections'; Expect=1; Label='RDP: Disabled' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'; Name='fAllowToGetHelp'; Expect=0; Label='Remote Assistance: OFF' }
        # Biometrics
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Biometrics'; Name='Enabled'; Expect=0; Label='Biometrics: OFF' }
        # Installer
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer'; Name='AlwaysInstallElevated'; Expect=0; Label='Installer: No Elevation' }
        @{ Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name='InactivityTimeoutSecs'; Expect=600; Label='Inactivity Timeout: 10 min' }
        @{ Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name='DontDisplayLastUserName'; Expect=1; Label='Logon: Hide Last Username' }
        @{ Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name='ValidateAdminCodeSignatures'; Expect=1; Label='UAC: Validate Code Signatures' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'; Name='AuditBaseObjects'; Expect=1; Label='LSA: Audit Base Objects' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'; Name='CrashOnAuditFail'; Expect=2; Label='LSA: Crash On Audit Fail' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0'; Name='RestrictSendingNTLMTraffic'; Expect=2; Label='NTLM: Block Sending' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\pku2u'; Name='AllowOnlineID'; Expect=0; Label='PKU2U: Online ID OFF' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Services\LDAP'; Name='LDAPClientConfidentiality'; Expect=2; Label='LDAP: Client Confidentiality' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'; Name='RestrictNTLMInDomain'; Expect=7; Label='Netlogon: Restrict NTLM' }
        # Security Template
        @{ Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name='ConsentPromptBehaviorEnhancedAdmin'; Expect=1; Label='UAC: Enhanced Admin Prompt = ON' }
        @{ Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name='TypeOfAdminApprovalMode'; Expect=1; Label='UAC: Admin Approval Mode v2' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy'; Name='Enabled'; Expect=1; Label='FIPS: ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Cryptography'; Name='ForceKeyProtection'; Expect=2; Label='Crypto: Force Key Protection' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'; Name='ClearPageFileAtShutdown'; Expect=1; Label='Memory: Clear PageFile on Shutdown' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Services\LDAP'; Name='LDAPClientIntegrity'; Expect=1; Label='LDAP: Client Signing Required' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'; Name='RestrictRemoteSAM'; Expect='O:BAG:BAD:(A;;RC;;;BA)'; Label='LSA: Restrict Remote SAM' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions'; Name='DenyDeviceIDs'; Expect=1; Label='DMA: Device Install Restrict' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Services\pci\Parameters'; Name='PeerToPeerTransferSupported'; Expect=0; Label='PCIe P2P DMA: OFF' }

        # ── Privacy / Telemetry ───────────────────────────────────────────
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='AllowTelemetry'; Expect=0; Label='Telemetry: OFF' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='DoNotShowFeedbackNotifications'; Expect=1; Label='Feedback: OFF' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name='EnableActivityFeed'; Expect=0; Label='Activity Feed: OFF' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot'; Name='TurnOffWindowsCopilot'; Expect=1; Label='Copilot: OFF' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo'; Name='DisabledByGroupPolicy'; Expect=1; Label='Advertising ID: OFF' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors'; Name='DisableLocation'; Expect=1; Label='Location: OFF' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name='DisableWindowsConsumerFeatures'; Expect=1; Label='Consumer Features: OFF' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name='AllowClipboardHistory'; Expect=0; Label='Clipboard History: OFF' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name='EnableCdp'; Expect=0; Label='CDP: OFF' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive'; Name='DisableFileSyncNGSC'; Expect=1; Label='OneDrive: OFF' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name='AllowCortana'; Expect=0; Label='Cortana: OFF' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name='DisableWebSearch'; Expect=1; Label='Web Search: OFF' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name='DisableSettingSync'; Expect=2; Label='Setting Sync: OFF' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Dsh'; Name='AllowNewsAndInterests'; Expect=0; Label='News/Interests: OFF' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization'; Name='DODownloadMode'; Expect=0; Label='Delivery Opt: HTTP only' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR'; Name='AllowGameDVR'; Expect=0; Label='Game DVR: OFF' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting'; Name='Disabled'; Expect=1; Label='Error Reporting: OFF' }

        # ── Network ───────────────────────────────────────────────────────
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation'; Name='AllowInsecureGuestAuth'; Expect=0; Label='SMB: InsecureGuest = OFF' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient'; Name='EnableMulticast'; Expect=0; Label='LLMNR: OFF' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient'; Name='EnableMDNS'; Expect=0; Label='mDNS: OFF' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD'; Name='EnableLLTDIO'; Expect=0; Label='LLTD: OFF' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'; Name='DisableIPSourceRouting'; Expect=2; Label='MSS: IP Source Routing OFF' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'; Name='EnableICMPRedirect'; Expect=0; Label='MSS: ICMP Redirect OFF' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'; Name='RequireSecuritySignature'; Expect=1; Label='SMB Server: Signing Required' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters'; Name='RequireSecuritySignature'; Expect=1; Label='SMB Client: Signing Required' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'; Name='RequireSignOrSeal'; Expect=1; Label='Netlogon: Sign/Seal Required' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'; Name='PerformRouterDiscovery'; Expect=0; Label='TCP: Router Discovery OFF' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters'; Name='EnableAutoDoh'; Expect=2; Label='System DoH: Force' }
        @{ Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters'; Name='SupportedEncryptionTypes'; Expect=2147483640; Label='Kerberos: Strong Enc Types' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Services\mrxsmb10'; Name='Start'; Expect=4; Label='SMBv1 Client: Disabled' }

        # ── Audit ─────────────────────────────────────────────────────────
        @{ Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit'; Name='ProcessCreationIncludeCmdLine_Enabled'; Expect=1; Label='Audit: CmdLine = ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'; Name='EnableScriptBlockLogging'; Expect=1; Label='PS: Script Block Logging = ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging'; Name='EnableModuleLogging'; Expect=1; Label='PS: Module Logging = ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription'; Name='EnableTranscripting'; Expect=1; Label='PS: Transcription = ON' }

        # ── BitLocker ─────────────────────────────────────────────────────
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\FVE'; Name='EncryptionMethodWithXtsOs'; Expect=7; Label='BitLocker OS: AES-256 XTS' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\FVE'; Name='UseAdvancedStartup'; Expect=1; Label='BitLocker: TPM+PIN' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\FVE'; Name='UseEnhancedPin'; Expect=1; Label='BitLocker: Enhanced PIN' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\FVE'; Name='DisableExternalDMAUnderLock'; Expect=1; Label='BitLocker: DMA Lock' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\FVE'; Name='RDVDenyWriteAccess'; Expect=1; Label='BitLocker: Removable Write Deny' }

        # ── Update / Autoplay ─────────────────────────────────────────────
        @{ Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name='NoDriveTypeAutoRun'; Expect=255; Label='AutoRun: Disabled (0xFF)' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'; Name='DeferFeatureUpdates'; Expect=1; Label='WU: Feature Defer = ON' }

        # ── Office ────────────────────────────────────────────────────────
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Word\Security'; Name='blockcontentexecutionfrominternet'; Expect=1; Label='Office Word: Block Internet Macros' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers'; Name='RequireIPPS'; Expect=1; Label='Printers: IPPS Required' }
        @{ Path='HKLM:\SYSTEM\CurrentControlSet\Control\Print'; Name='RpcAuthnLevelPrivacyEnabled'; Expect=1; Label='Print Spooler: RPC Privacy' }
    )

    $Ok = 0; $Fail = 0
    foreach ($c in $Checks) {
        $val = Get-CheckValue -RegPath $c.Path -ValueName $c.Name
        if ($val -eq $c.Expect) {
            Write-Host "  [PASS] $($c.Label)" -ForegroundColor Green
            $Ok++
        } else {
            Write-Host "  [FAIL] $($c.Label) | Поточне: $val | Очікується: $($c.Expect)" -ForegroundColor Red
            $Fail++
        }
    }

    Write-Host ""
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  Результат: $Ok PASS / $Fail FAIL (з $($Ok + $Fail) перевірок)" -ForegroundColor ($Fail -eq 0 ? 'Green' : 'Yellow')
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
}

# ── MAIN ────────────────────────────────────────────────────────────────────
switch ($Action) {
    'Apply' {
        Write-Host "`n=== GPO Edition 3.0 — Apply ===" -ForegroundColor Magenta
        Write-Host "Застосовую $($PolicyFiles.Count) файлів політик...`n"
        foreach ($f in $PolicyFiles) { Invoke-LGPO -PolicyFile $f }
        Invoke-SecurityTemplate
        Write-Host "`n[DONE] Всі політики застосовано." -ForegroundColor Green
        Write-Host "Примусове оновлення локальних політик..." -ForegroundColor Cyan
        gpupdate /force | Out-Null
        Write-Host "[INFO] Рекомендується перезавантаження для повного застосування.`n" -ForegroundColor Yellow
    }
    'Revert' {
        Write-Host "`n=== GPO Edition 3.0 — Revert ===" -ForegroundColor Magenta
        Write-Host "Відкочую $($PolicyFiles.Count) файлів політик...`n"
        foreach ($f in $PolicyFiles) { Invoke-LGPO-Revert -PolicyFile $f }
        Invoke-SecurityTemplate-Revert
        Write-Host "`n[DONE] Політики відкочено." -ForegroundColor Yellow
        Write-Host "Примусове оновлення локальних політик..." -ForegroundColor Cyan
        gpupdate /force | Out-Null
        Write-Host "[INFO] Рекомендується перезавантаження для повного відкату.`n" -ForegroundColor Yellow
    }
    'Check' {
        Invoke-Check
    }
}

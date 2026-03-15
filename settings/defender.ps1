<#
.SYNOPSIS
    Defender: антивірус, SmartScreen, ASR, захист сервісів, DMA, пісочниця
.NOTES
    Частина Get-HardeningSettings — підвантажується через settings.data.ps1
#>

@(

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 3: DEFENDER / ANTIVIRUS ──────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Defender / Antivirus"
    Name  = "Вимкнути Real-Time моніторинг Defender"
    Desc  = "DisableRealtimeMonitoring=1 (для тестових середовищ)"
    Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableRealtimeMonitoring" 1 }
    Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableRealtimeMonitoring" 0 }
    Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableRealtimeMonitoring" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Defender / Antivirus"
    Name  = "Defender ACSC — повна безпечна конфігурація (ACSC 22)"
    Desc  = "Блокування PUA, MAPS Advanced (SpynetReporting=2), Block at First Seen, SubmitSamplesConsent=3 (всі зразки), хмарна перевірка 50с, сканування email/USB/архівів"
    Apply = {
        $d = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
        Set-Reg $d "PUAProtection"              1
        Set-Reg $d "DisableLocalAdminMerge"     1
        Set-Reg $d "HideExclusionsFromLocalAdmins" 1
        Set-Reg $d "DisableAntiSpyware"         0
        Set-Reg $d "DisableRoutinelyTakingAction" 0
        Set-Reg "$d\Spynet" "LocalSettingOverrideSpynetReporting" 0
        Set-Reg "$d\Spynet" "DisableBlockAtFirstSeen"             0
        Set-Reg "$d\Spynet" "SpynetReporting"                     2
        Set-Reg "$d\Spynet" "SubmitSamplesConsent"                3
        Set-Reg "$d\MpEngine" "MpBafsExtendedTimeout"             50
        Set-Reg "$d\MpEngine" "EnableFileHashComputation"         1
        Set-Reg "$d\MpEngine" "MpCloudBlockLevel"                 2
        Set-Reg "$d\Quarantine" "PurgeItemsAfterDelay"            0
        $rt = "$d\Real-Time Protection"
        Set-Reg $rt "DisableIOAVProtection"        0
        Set-Reg $rt "DisableRealtimeMonitoring"    0
        Set-Reg $rt "DisableBehaviorMonitoring"    0
        Set-Reg $rt "DisableScanOnRealtimeEnable"  0
        Set-Reg $rt "DisableScriptScanning"        0
        $sc = "$d\Scan"
        Set-Reg $sc "DisablePauseOnIdleTask"       1
        Set-Reg $sc "CheckForSignaturesBeforeRunningScan" 1
        Set-Reg $sc "DisableArchiveScanning"       0
        Set-Reg $sc "DisablePackedExeScanning"     0
        Set-Reg $sc "DisableRemovableDriveScanning" 0
        Set-Reg $sc "DisableEmailScanning"         0
        Set-Reg $sc "DisableHeuristics"            0
    }
    Revert = {
        $d = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
        Set-Reg $d "PUAProtection" 0
        # MAPS (SpynetReporting) не вимикається при відкаті — хмарний захист залишається активним
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" "PUAProtection" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Defender / Antivirus"
    Name  = "Hosts-файл — виключити зі сканування Defender"
    Desc  = "Додає hosts до Exclusions\Paths на policy-рівні (обходить DisableLocalAdminMerge=1 з ACSC-блоку)"
    Apply = {
        $hp = "$env:SystemRoot\System32\drivers\etc\hosts"
        $rp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths"
        if (-not (Test-Path $rp)) { New-Item -Path $rp -Force | Out-Null }
        Set-ItemProperty -Path $rp -Name $hp -Value 0 -Type DWord -ErrorAction SilentlyContinue
        try { Add-MpPreference -ExclusionPath $hp -ErrorAction SilentlyContinue } catch {}
    }
    Revert = {
        $hp = "$env:SystemRoot\System32\drivers\etc\hosts"
        $rp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths"
        Remove-ItemProperty -Path $rp -Name $hp -ErrorAction SilentlyContinue
        try { Remove-MpPreference -ExclusionPath $hp -ErrorAction SilentlyContinue } catch {}
    }
    Check = {
        $hp = "$env:SystemRoot\System32\drivers\etc\hosts"
        $rp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths"
        (Test-Path $rp) -and ((Get-ItemProperty -Path $rp -ErrorAction SilentlyContinue).$hp -eq 0)
    }
},


[PSCustomObject]@{
    Group = "Defender / Antivirus"
    Name  = "ASR Rules — 16 правил Attack Surface Reduction (ACSC 02)"
    Desc  = @"
Всі 16 ASR-правил у режимі Блокування: захист від Office-макросів, LSASS, WMI, скриптів, USB тощо.
CVE-2025-30397, CVE-2025-33053: scripting-engine та Office-атаки.
GPO: Computer Configuration > Administrative Templates > Windows Components >
  Microsoft Defender Antivirus > Microsoft Defender Exploit Guard > Attack Surface Reduction
  → "Configure Attack Surface Reduction rules" = Enabled (GUID=1 для кожного правила)
Значення: 0=Disabled, 1=Block, 2=Audit, 6=Warn
"@
    Apply = {
        $rp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR"
        $ru = "$rp\Rules"
        Set-Reg $rp "ExploitGuard_ASR_Rules" 1
        if (-not (Test-Path $ru)) { New-Item -Path $ru -Force | Out-Null }
        $guids = @(
            "56a863a9-875e-4185-98a7-b882c64b5ce5","7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c",
            "d4f940ab-401b-4efc-aadc-ad5f3c50688a","9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2",
            "be9ba2d9-53ea-4cdc-84e5-9b1eeee46550","01443614-cd74-433a-b99e-2ecdc07bfc25",
            "5beb7efe-fd9a-4556-801d-275e5ffc04cc","d3e037e1-3eb8-44c8-a917-57927947596d",
            "3b576869-a4ec-4529-8536-b80a7769e899","75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84",
            "26190899-1602-49e8-8b27-eb1d0a1ce869","e6db77e5-3df2-4cf1-b95a-636979351e5b",
            "d1e49aac-8f56-4280-b9ba-993a6d77406c","b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4",
            "92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b","c1db55ab-c21a-4637-bb3f-a12568109d35"
        )
        foreach ($g in $guids) { Set-Reg $ru $g 1 }
        try {
            Set-MpPreference -AttackSurfaceReductionRules_Ids ([string[]]$guids) `
                -AttackSurfaceReductionRules_Actions (@(1)*$guids.Count) -ErrorAction SilentlyContinue
        } catch { Write-AppLog -Level 'WARN' -Message "ASR Set-MpPreference :: $($_.Exception.Message)" }
    }
    Revert = {
        $ru = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules"
        if (Test-Path $ru) { Remove-Item $ru -Recurse -Force -ErrorAction SilentlyContinue }
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR" "ExploitGuard_ASR_Rules" 0
    }
    Check = {
        $rp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR"
        (Get-Reg $rp "ExploitGuard_ASR_Rules" 0) -eq 1
    }
},

[PSCustomObject]@{
    Group = "Defender / Antivirus"
    Name  = "Controlled Folder Access — захист від ransomware (ACSC 04)"
    Desc  = @"
Вмикає CFA виключно через Set-MpPreference — без запису в HKLM:\SOFTWARE\Policies\.
Це критично: GPO-ключ у \Policies\ блокує UI "Allow an app through Controlled folder access"
та показує "Your administrator has blocked this action" навіть на дозволених програмах.
Додає до whitelist: powershell.exe та pwsh.exe (PowerShell 7, якщо встановлено).
Revert: видаляє GPO-ключ (якщо лишився з попередніх запусків) та вимикає CFA.
"@
    Apply = {
        $gpoPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access"
        # Видалити GPO-ключ якщо лишився з попередніх запусків — він блокує UI контроль
        if (Test-Path $gpoPath) {
            Remove-Item -Path $gpoPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-AppLog -Level 'INFO' -Message "CFA: старий GPO-ключ видалено перед увімкненням."
        }

        # Вмикати лише через Set-MpPreference — UI "Allow an app" залишається доступним
        try {
            Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction Stop
            Write-AppLog -Level 'INFO' -Message "CFA: увімкнено через Set-MpPreference."
        } catch { Write-AppLog -Level 'WARN' -Message "CFA Enable :: $($_.Exception.Message)" }

        # Дозволити PowerShell — системний інструмент, що легітимно пише у Documents
        $ps1 = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
        $ps2 = "$env:SystemRoot\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"
        $ps7 = "$env:ProgramFiles\PowerShell\7\pwsh.exe"
        foreach ($exe in @($ps1, $ps2, $ps7)) {
            if (Test-Path $exe) {
                try {
                    Add-MpPreference -ControlledFolderAccessAllowedApplications $exe -ErrorAction Stop
                    Write-AppLog -Level 'INFO' -Message "CFA: allowed — $exe"
                } catch { Write-AppLog -Level 'WARN' -Message "CFA AllowApp $exe :: $($_.Exception.Message)" }
            }
        }
    }
    Revert = {
        # Видаляємо GPO-ключ якщо існує (на випадок старих запусків)
        $gpoPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access"
        if (Test-Path $gpoPath) {
            Remove-Item -Path $gpoPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-AppLog -Level 'INFO' -Message "CFA: GPO-ключ видалено."
        }
        # Прибрати PowerShell з whitelist і вимкнути CFA
        $ps1 = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
        $ps2 = "$env:SystemRoot\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"
        $ps7 = "$env:ProgramFiles\PowerShell\7\pwsh.exe"
        foreach ($exe in @($ps1, $ps2, $ps7)) {
            try { Remove-MpPreference -ControlledFolderAccessAllowedApplications $exe -ErrorAction SilentlyContinue } catch {}
        }
        try { Set-MpPreference -EnableControlledFolderAccess Disabled -ErrorAction SilentlyContinue } catch { Write-AppLog -Level 'WARN' -Message "CFA Disable :: $($_.Exception.Message)" }
        Write-AppLog -Level 'INFO' -Message "CFA: вимкнено, PowerShell видалено з whitelist."
    }
    Check = {
        $pref = Get-MpPreference -ErrorAction SilentlyContinue
        $pref -and ($pref.EnableControlledFolderAccess -eq 1)
    }
},

[PSCustomObject]@{
    Group = "Defender / Antivirus"
    Name  = "Exploit Protection — DEP, SEHOP, ASLR (ACSC 03)"
    Desc  = "DisallowExploitProtectionOverride=1, SEHOP увімкнено, DEP для Провідника Windows"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection" "DisallowExploitProtectionOverride" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoDataExecutionPrevention" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoTurnOffSPIAndSAI"       1
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "DisableExceptionChainValidation" 0
        try { Set-ProcessMitigation -System -Enable DEP,EmulateAtlThunks,SEHOP,ForceRelocateImages,BottomUp,HighEntropy,CFG -ErrorAction SilentlyContinue } catch { Write-AppLog -Level 'WARN' -Message "ExploitProtection :: $($_.Exception.Message)" }
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection" "DisallowExploitProtectionOverride" 0
    }
    Check = {
        (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection" "DisallowExploitProtectionOverride" 0) -eq 1
    }
},

[PSCustomObject]@{
    Group = "Defender / Antivirus"
    Name  = "Early Launch Antimalware — ELAM (ACSC 07)"
    Desc  = "DriverLoadPolicy=1: завантажувати лише драйвери з позначкою «Добре» (найсуворіший режим ACSC)"
    Apply  = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch" "DriverLoadPolicy" 1 }
    Revert = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch" "DriverLoadPolicy" 7 }
    Check  = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch" "DriverLoadPolicy" -1) -eq 1 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 4: SMARTSCREEN / RECALL / ТЕЛЕМЕТРІЯ ─────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "SmartScreen / Recall / Телеметрія"
    Name  = "Вимкнути SmartScreen (Explorer)"
    Desc  = "EnableSmartScreen=0 — вимкнути перевірку завантажень у провіднику"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableSmartScreen" 0
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" "SmartScreenEnabled" "Off" "String"
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableSmartScreen" 1
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" "SmartScreenEnabled" "Warn" "String"
    }
    Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableSmartScreen" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "SmartScreen / Recall / Телеметрія"
    Name  = "SmartScreen ACSC — увімкнути та заблокувати обхід (ACSC 34)"
    Desc  = "EnableSmartScreen=1, ShellSmartScreenLevel=Block — не дозволяти обхід"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableSmartScreen"     1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "ShellSmartScreenLevel" "Block" "String"
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "ShellSmartScreenLevel" "Warn" "String"
    }
    Check = {
        $v = Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "ShellSmartScreenLevel" ""
        $v -eq "Block"
    }
},

[PSCustomObject]@{
    Group = "SmartScreen / Recall / Телеметрія"
    Name  = "Вимкнути Windows Recall (AIX сервіс)"
    Desc  = "Вимкнути сервіс AiXHostService + DisableAIDataAnalysis=1 + AllowRecallEnablement=0 + EnableRecallOnDevice=0"
    Apply = {
        Set-ServiceDisabled "AiXHostService"
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis"  1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "AllowRecallEnablement"  0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "EnableRecallOnDevice"   0
    }
    Revert = {
        Set-ServiceManual "AiXHostService"
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis"  0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "AllowRecallEnablement"  1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "EnableRecallOnDevice"   1
    }
    Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "SmartScreen / Recall / Телеметрія"
    Name  = "Діагностичні дані — дозволити додаткові (AllowTelemetry=3)"
    Desc  = "AllowTelemetry=3 (Optional/Full): дозволяє відправку додаткових діагностичних даних. Не блокує toggle «Send optional diagnostic data» у Settings → Privacy → Diagnostics & feedback. DiagTrack залишається у режимі Manual."
    Apply = {
        # AllowTelemetry=3 = Optional (Full) — не блокує toggle у Settings
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 3
        Set-ServiceManual "DiagTrack"
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 1
        Set-ServiceManual "DiagTrack"
    }
    Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" -1) -eq 3 }
},

[PSCustomObject]@{
    Group = "SmartScreen / Recall / Телеметрія"
    Name  = "Вимкнути SmartScreen сервіс (webthreatdefsvc)"
    Desc  = "Зупинити та вимкнути webthreatdefsvc + webthreatdefusersvc"
    Apply = {
        Set-ServiceDisabled "webthreatdefsvc"
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
    Group = "SmartScreen / Recall / Телеметрія"
    Name  = "Вимкнути Microsoft Consumer Experiences + OneDrive"
    Desc  = "DisableWindowsConsumerFeatures=1, DisableFileSyncNGSC=1, DisableUserAuth=1"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"    "DisableWindowsConsumerFeatures" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"        "DisableFileSyncNGSC"            1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount"        "DisableUserAuth"                1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppRuntime"      "AllowMicrosoftAccountsToBeOptional" 1
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"     "DisableFileSyncNGSC"            0
    }
    Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 0) -eq 1 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 32: KERNEL DMA PROTECTION ─────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Kernel DMA Protection"
    Name  = "DMA-захист — Заблокувати всі зовнішні пристрої (ACSC)"
    Desc  = "DeviceEnumerationPolicy=0: блокувати всі зовнішні пристрої несумісні з Kernel DMA Protection"
    Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy" 0 }
    Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy" 1 }
    Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy" -1) -eq 0 }
},


# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 47: ЗАХИСТ СЕРВІСІВ ТА ДРАЙВЕРІВ ───────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Захист сервісів та драйверів"
    Name  = "SNMP сервіс — вимкнути та видалити"
    Desc  = "Зупинити SNMP Service, вимкнути та деінсталювати Windows Feature SNMP-Service"
    Apply = {
        Set-ServiceDisabled "SNMP"
        Get-WindowsCapability -Online -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like '*SNMP*' -and $_.State -eq 'Installed' } |
            ForEach-Object { Remove-WindowsCapability -Online -Name $_.Name -ErrorAction SilentlyContinue }
    }
    Revert = {
        Set-ServiceManual "SNMP"
    }
    Check = {
        $s = Get-Service "SNMP" -ErrorAction SilentlyContinue
        -not $s -or $s.StartType -eq 'Disabled'
    }
},

[PSCustomObject]@{
    Group = "Захист сервісів та драйверів"
    Name  = "Remote Registry — вимкнути"
    Desc  = "Зупинити та вимкнути Remote Registry сервіс (віддалений доступ до реєстру)"
    Apply  = { Set-ServiceDisabled "RemoteRegistry" }
    Revert = { Set-ServiceManual "RemoteRegistry" }
    Check  = { $s = Get-Service "RemoteRegistry" -ErrorAction SilentlyContinue; $s -and $s.StartType -eq 'Disabled' }
},

[PSCustomObject]@{
    Group = "Захист сервісів та драйверів"
    Name  = "Fax / XboxGipSvc / RetailDemo — вимкнути"
    Desc  = "Зупинити Fax, XboxGipSvc, XboxNetApiSvc, RetailDemo сервіси"
    Apply = {
        foreach ($svc in @("Fax","XboxGipSvc","XboxNetApiSvc","RetailDemo","MapsBroker")) {
            Set-ServiceDisabled $svc
        }
    }
    Revert = {
        foreach ($svc in @("Fax","XboxGipSvc","XboxNetApiSvc","RetailDemo","MapsBroker")) {
            Set-ServiceManual $svc
        }
    }
    Check = { $s = Get-Service "XboxGipSvc" -ErrorAction SilentlyContinue; $s -and $s.StartType -eq 'Disabled' }
},

[PSCustomObject]@{
    Group = "Захист сервісів та драйверів"
    Name  = "Bluetooth Support / SSDP Discovery — вимкнути"
    Desc  = "Зупинити bthserv (Bluetooth), SSDPSRV (SSDP Discovery), upnphost (UPnP)"
    Apply = {
        foreach ($svc in @("bthserv","SSDPSRV","upnphost")) {
            Set-ServiceDisabled $svc
        }
    }
    Revert = {
        foreach ($svc in @("bthserv","SSDPSRV","upnphost")) {
            Set-ServiceManual $svc
        }
    }
    Check = { $s = Get-Service "SSDPSRV" -ErrorAction SilentlyContinue; $s -and $s.StartType -eq 'Disabled' }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 48: WINDOWS SANDBOX / VIRTUALIZATION SECURITY ───────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Windows Sandbox / Virtualization Security"
    Name  = "HVCI — цілісність коду під захистом гіпервізора"
    Desc  = "HypervisorEnforcedCodeIntegrity=1, HVCIMATRequired=1: захист ядра від непідписаних драйверів"
    Apply = {
        $dg = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
        Set-Reg $dg "HypervisorEnforcedCodeIntegrity" 1
        Set-Reg $dg "HVCIMATRequired"                 1
    }
    Revert = {
        $dg = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
        Set-Reg $dg "HypervisorEnforcedCodeIntegrity" 0
        Set-Reg $dg "HVCIMATRequired"                 0
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" "HypervisorEnforcedCodeIntegrity" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Windows Sandbox / Virtualization Security"
    Name  = "System Guard Secure Launch + тіньові стеки ядра"
    Desc  = "ConfigureSystemGuardLaunch=1, ConfigureKernelShadowStacksLaunch=1"
    Apply = {
        $dg = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
        Set-Reg $dg "ConfigureSystemGuardLaunch"            1
        Set-Reg $dg "ConfigureKernelShadowStacksLaunch"    1
    }
    Revert = {
        $dg = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
        Remove-RegValue $dg "ConfigureSystemGuardLaunch"
        Remove-RegValue $dg "ConfigureKernelShadowStacksLaunch"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" "ConfigureSystemGuardLaunch" 0) -eq 1 }
},

[PSCustomObject]@{
    Group    = "Defender — ASR Rules"
    Name     = "ASR PSExec/WMI — Audit режим (25H2 Baseline рекомендація)"
    Desc     = "d1e49aac: Block process creations from PSExec/WMI = 2 (Audit). Microsoft НЕ рекомендує Block (1) — ламає законні admin-скрипти"
    MinBuild = 26200
    Apply  = {
        Add-MpPreference -AttackSurfaceReductionRules_Ids    "d1e49aac-8f56-4280-b9ba-993a6d77406c" `
                         -AttackSurfaceReductionRules_Actions 2 -EA SilentlyContinue
    }
    Revert = {
        Add-MpPreference -AttackSurfaceReductionRules_Ids    "d1e49aac-8f56-4280-b9ba-993a6d77406c" `
                         -AttackSurfaceReductionRules_Actions 0 -EA SilentlyContinue
    }
    Check  = {
        $p = Get-MpPreference -EA SilentlyContinue
        $idx = [Array]::IndexOf($p.AttackSurfaceReductionRules_Ids, "d1e49aac-8f56-4280-b9ba-993a6d77406c")
        $idx -ge 0 -and $p.AttackSurfaceReductionRules_Actions[$idx] -eq 2
    }
},

[PSCustomObject]@{
    Group    = "Application Control"
    Name     = "WDAC — COM-об'єкти дозволені для системних процесів (26H1)"
    Desc     = "Покращена обробка COM Allow-list у WDAC: 26H1 виправляє False Positive для системних COM"
    MinBuild = 26300
    Apply  = {
        # Базова WDAC Audit-режим політика через PowerShell (не ламає систему)
        $wdacPath = "$env:ProgramData\win11-hardening\WDAC"
        $null = New-Item -ItemType Directory -Path $wdacPath -Force
        # Генерувати базову Allow Microsoft Audit Policy
        if (Get-Command New-CIPolicy -EA SilentlyContinue) {
            New-CIPolicy -Level Publisher -Fallback Hash -FilePath "$wdacPath\BaseAudit.xml" `
                         -UserPEs -MultiplePolicyFormat -EA SilentlyContinue
            ConvertFrom-CIPolicy "$wdacPath\BaseAudit.xml" "$wdacPath\BaseAudit.bin" -EA SilentlyContinue
            Write-AppLog -Level 'INFO' -Message "WDAC Audit Policy створено: $wdacPath\BaseAudit.bin"
        } else {
            Write-AppLog -Level 'WARN' -Message "WDAC: ConfigCI модуль недоступний на цій версії"
        }
    }
    Revert = {
        Remove-Item "$env:ProgramData\win11-hardening\WDAC" -Recurse -Force -EA SilentlyContinue
    }
    Check  = { Test-Path "$env:ProgramData\win11-hardening\WDAC\BaseAudit.bin" }
},

[PSCustomObject]@{
    Group = "Windows Sandbox / Virtualization Security"
    Name  = "Заборонити Custom SSPs/APs (LSASS захист)"
    Desc  = "AllowCustomSSPsAPs=0: не дозволяти нестандартним SSP/AP підключатися до LSASS"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCustomSSPsAPs" 0
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCustomSSPsAPs"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCustomSSPsAPs" 1) -eq 0 }
},

# ════════════════════════════════════════════════════════════════════════
# ── ADVANCED DEFENDER: Network Protection / RestorePoint / BruteForce ──
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Defender / Advanced Protection"
    Name  = "Network Protection — увімкнути (EnableNetworkProtection=1)"
    Desc  = @"
EnableNetworkProtection=1 (Enabled): блокує доступ до шкідливих IP/доменів/URL.
Потребує увімкненого Defender Real-Time Protection.
Revert: повертає у режим AuditMode (2) — не блокує, але логує.
"@
    Apply = {
        $np = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection"
        Set-Reg $np "EnableNetworkProtection" 1
        Write-AppLog -Level 'INFO' -Message "Network Protection: Enabled (1)."
    }
    Revert = {
        $np = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection"
        Set-Reg $np "EnableNetworkProtection" 2
        Write-AppLog -Level 'INFO' -Message "Network Protection: AuditMode (2)."
    }
    Check = {
        $np = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection"
        (Get-Reg $np "EnableNetworkProtection" 0) -eq 1
    }
},

[PSCustomObject]@{
    Group = "Defender / Advanced Protection"
    Name  = "Defender Advanced — DisableRestorePoint=false + BruteForceProtection + IntelTDT"
    Desc  = @"
Три рекомендовані налаштування з аналізу Get-MpPreference:
  DisableRestorePoint=$false   — Defender створює точку відновлення перед лікуванням загрози.
  BruteForceProtectionConfiguredState=1 — захист від атак перебором паролів (Enabled).
  IntelTDTEnabled=$true        — Intel Threat Detection Technology (лише на Intel CPU;
                                 ігнорується на AMD/ARM, помилка пригнічується).
Revert: повертає до значень за замовчуванням через Set-MpPreference.
"@
    Apply = {
        # Точки відновлення перед лікуванням
        try { Set-MpPreference -DisableRestorePoint $false -ErrorAction Stop
              Write-AppLog -Level 'INFO' -Message "DisableRestorePoint=false — точки відновлення увімкнено." }
        catch { Write-AppLog -Level 'WARN' -Message "DisableRestorePoint: $_" }

        # Захист від брутфорсу
        try { Set-MpPreference -BruteForceProtectionConfiguredState 1 -ErrorAction Stop
              Write-AppLog -Level 'INFO' -Message "BruteForceProtection=Enabled." }
        catch { Write-AppLog -Level 'WARN' -Message "BruteForceProtection: $_" }

        # Intel TDT — лише якщо Intel CPU
        $cpu = (Get-WmiObject Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1).Name
        if ($cpu -match 'Intel') {
            try { Set-MpPreference -IntelTDTEnabled $true -ErrorAction Stop
                  Write-AppLog -Level 'INFO' -Message "IntelTDTEnabled=true ($cpu)." }
            catch { Write-AppLog -Level 'WARN' -Message "IntelTDT: $_" }
        } else {
            Write-AppLog -Level 'INFO' -Message "IntelTDT пропущено: CPU=$cpu (не Intel)."
        }
    }
    Revert = {
        try { Set-MpPreference -DisableRestorePoint $true  -ErrorAction SilentlyContinue } catch {}
        try { Set-MpPreference -BruteForceProtectionConfiguredState 0 -ErrorAction SilentlyContinue } catch {}
        try { Set-MpPreference -IntelTDTEnabled $false -ErrorAction SilentlyContinue } catch {}
        Write-AppLog -Level 'INFO' -Message "Advanced Defender налаштування відновлено до дефолту."
    }
    Check = {
        $pref = Get-MpPreference -ErrorAction SilentlyContinue
        $pref -and ($pref.DisableRestorePoint -eq $false) -and ($pref.BruteForceProtectionConfiguredState -eq 1)
    }
}

)

<#
.SYNOPSIS
    Сервіси: журнали, бекап, кеш, живлення, шифрування, пристрої
.NOTES
    Частина Get-HardeningSettings — підвантажується через settings.data.ps1
#>

@(

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 6: ШИФРУВАННЯ / BITLOCKER / ПРИСТРОЇ ─────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Шифрування / BitLocker"
    Name  = "BitLocker — XTS-AES 128 + AD backup + мін PIN 15 (ACSC 27)"
    Desc  = "Метод шифрування XTS-AES128, резервна копія в AD обов'язкова, повне шифрування, PIN мін. 15, DMA вимкнено при блокуванні"
    Apply = {
        $b = "HKLM:\SOFTWARE\Policies\Microsoft\FVE"
        Set-Reg $b "EncryptionMethodWithXtsOs"        4
        Set-Reg $b "EncryptionMethodWithXtsFdv"       4
        Set-Reg $b "EncryptionMethodWithXtsRdv"       4
        Set-Reg $b "DisableExternalDMAUnderLock"      1
        Set-Reg $b "MorBehavior"                      0
        Set-Reg $b "OSRecovery"                       1
        Set-Reg $b "OSActiveDirectoryBackup"          1
        Set-Reg $b "OSRequireActiveDirectoryBackup"   1
        Set-Reg $b "OSEncryptionType"                 1
        Set-Reg $b "OSMinimumPIN"                     15
        Set-Reg $b "UseEnhancedPin"                   1
        Set-Reg $b "OSAllowSecureBootForIntegrity"    1
        Set-Reg $b "FDVRecovery"                      1
        Set-Reg $b "FDVActiveDirectoryBackup"         1
        Set-Reg $b "FDVRequireActiveDirectoryBackup"  1
        Set-Reg $b "FDVEncryptionType"                1
        Set-Reg $b "FDVDenyWriteAccess"               1
        Set-Reg $b "RDVRecovery"                      1
        Set-Reg $b "RDVEncryptionType"                1
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "MaxDevicePasswordFailedAttempts" 10
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\FVE" "DisableExternalDMAUnderLock" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\FVE" "FDVDenyWriteAccess" 0
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\FVE" "DisableExternalDMAUnderLock" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Шифрування / BitLocker"
    Name  = "Знімні носії — заборонити доступ (ACSC 28)"
    Desc  = "Deny_All=1 у RemovableStorageDevices — повна заборона всіх знімних носіїв"
    Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices" "Deny_All" 1 }
    Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices" "Deny_All" 0 }
    Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices" "Deny_All" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Шифрування / BitLocker"
    Name  = "Credential Guard — VBS + LSASS як protected process (ACSC 01)"
    Desc  = "EnableVirtualizationBasedSecurity=1, LsaCfgFlags=1 (блокування UEFI), RunAsPPL=1, WDigest вимкнено"
    Apply = {
        $dg = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
        Set-Reg $dg "EnableVirtualizationBasedSecurity"    1
        Set-Reg $dg "RequirePlatformSecurityFeatures"      3
        Set-Reg $dg "HypervisorEnforcedCodeIntegrity"      1
        Set-Reg $dg "HVCIMATRequired"                      1
        Set-Reg $dg "LsaCfgFlags"                          1
        Set-Reg $dg "ConfigureSystemGuardLaunch"           1
        Set-Reg $dg "ConfigureKernelShadowStacksLaunch"    1
        $lsa = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
        Set-Reg "$lsa\SecurityProviders\WDigest" "UseLogonCredential" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCustomSSPsAPs" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "RunAsPPL"           1
        Set-Reg $lsa "CachedLogonsCount" "1" "String"
        Set-Reg $lsa "DisableDomainCreds" 1
    }
    Revert = {
        $dg = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
        Set-Reg $dg "EnableVirtualizationBasedSecurity" 0
        Set-Reg $dg "LsaCfgFlags" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "RunAsPPL" 0
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" "LsaCfgFlags" 0) -eq 1 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 8: СЕРВІСИ: HISTORY / LOGS / FOOTPRINT ───────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Сервіси: History / Logs / Footprint"
    Name  = "Вимкнути Activity History (Timeline)"
    Desc  = "PublishUserActivities=0, UploadUserActivities=0, EnableActivityFeed=0"
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
    Name  = "Вимкнути Windows Error Reporting (WerSvc)"
    Desc  = "Зупинити WerSvc, WER Disabled=1"
    Apply = {
        Set-ServiceDisabled "WerSvc"
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" "Disabled" 1
    }
    Revert = {
        Set-ServiceManual "WerSvc"
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" "Disabled" 0
    }
    Check  = { $s = Get-Service "WerSvc" -ErrorAction SilentlyContinue; $s -and $s.StartType -eq 'Disabled' }
},

[PSCustomObject]@{
    Group = "Сервіси: History / Logs / Footprint"
    Name  = "Вимкнути DiagTrack, DPS, dmwappushservice, CDPSvc, SysMain"
    Desc  = "Зупинити сервіси телеметрії та відстеження активності"
    Apply = {
        foreach ($svc in @("DiagTrack","DPS","dmwappushservice","CDPSvc","CDPUserSvc","SysMain")) {
            Set-ServiceDisabled $svc
        }
    }
    Revert = {
        foreach ($svc in @("DiagTrack","DPS","dmwappushservice","CDPSvc","SysMain")) {
            Set-ServiceManual $svc
        }
    }
    Check  = { $s = Get-Service "DiagTrack" -ErrorAction SilentlyContinue; $s -and $s.StartType -eq 'Disabled' }
},

[PSCustomObject]@{
    Group = "Сервіси: History / Logs / Footprint"
    Name  = "Вимкнути Prefetch / Superfetch"
    Desc  = "EnablePrefetcher=0, EnableSuperfetch=0"
    Apply = {
        $p = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
        Set-Reg $p "EnablePrefetcher"  0
        Set-Reg $p "EnableSuperfetch"  0
    }
    Revert = {
        $p = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
        Set-Reg $p "EnablePrefetcher"  3
        Set-Reg $p "EnableSuperfetch"  3
    }
    Check  = {
        $p = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
        (Get-Reg $p "EnablePrefetcher" 3) -eq 0
    }
},

[PSCustomObject]@{
    Group = "Сервіси: History / Logs / Footprint"
    Name  = "Вимкнути Compatibility Telemetry (AppCompat)"
    Desc  = "DisableInventory=1, DisableUAR=1, DisablePCA=1"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableInventory" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableUAR"       1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisablePCA"       1
        Disable-Task "\Microsoft\Windows\Application Experience\" "Microsoft Compatibility Appraiser"
        Disable-Task "\Microsoft\Windows\Application Experience\" "ProgramDataUpdater"
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableInventory" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableUAR"       0
        Enable-Task "\Microsoft\Windows\Application Experience\" "Microsoft Compatibility Appraiser"
    }
    Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableInventory" 0) -eq 1 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 9: СЕРВІСИ BACKUP / CACHE / RECOVERY ─────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Сервіси: Backup / Cache / Recovery"
    Name  = "Вимкнути Volume Shadow Copy (VSS) + Windows Backup (SDRSVC)"
    Desc  = "Зупинити VSS та SDRSVC — тіньові копії та резервне копіювання"
    Apply  = { Set-ServiceDisabled "VSS"; Set-ServiceDisabled "SDRSVC" }
    Revert = { Set-ServiceManual   "VSS"; Set-ServiceManual   "SDRSVC" }
    Check  = { $s = Get-Service "VSS" -ErrorAction SilentlyContinue; $s -and $s.StartType -eq 'Disabled' }
},

[PSCustomObject]@{
    Group = "Сервіси: Backup / Cache / Recovery"
    Name  = "Вимкнути Windows Search (WSearch) + Cortana"
    Desc  = "Зупинити WSearch, AllowCortana=0, DisableWebSearch=1"
    Apply = {
        Set-ServiceDisabled "WSearch"
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana"          0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch"      1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "ConnectedSearchUseWeb" 0
    }
    Revert = { Set-ServiceManual "WSearch" }
    Check  = { $s = Get-Service "WSearch" -ErrorAction SilentlyContinue; $s -and $s.StartType -eq 'Disabled' }
},

[PSCustomObject]@{
    Group = "Сервіси: Backup / Cache / Recovery"
    Name  = "Вимкнути Delivery Optimization (DoSvc) + DNS cache"
    Desc  = "DoSvc=Вимкнено, DODownloadMode=0, dnscache=Вимкнено"
    Apply = {
        Set-ServiceDisabled "DoSvc"
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode" 0
        Set-ServiceDisabled "dnscache"
    }
    Revert = {
        Set-ServiceManual "DoSvc"
        Set-ServiceManual "dnscache"
    }
    Check  = { $s = Get-Service "DoSvc" -ErrorAction SilentlyContinue; $s -and $s.StartType -eq 'Disabled' }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 10: ЖИВЛЕННЯ / OS PATCHING / АВТОЗАПУСК ──────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Живлення / Патчі / Автозапуск"
    Name  = "Вимкнути Sleep/Hibernate (ACSC 30)"
    Desc  = "powercfg /hibernate off, DCSettingIndex=0, ACSettingIndex=0, ShowSleepOption=0"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\abfc2519-3608-4c2a-94ea-171b0ed546ab" "DCSettingIndex" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\abfc2519-3608-4c2a-94ea-171b0ed546ab" "ACSettingIndex" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51" "DCSettingIndex" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51" "ACSettingIndex" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "ShowHibernateOption" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "ShowSleepOption"     0
        powercfg /hibernate off 2>$null
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "ShowHibernateOption" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "ShowSleepOption"     1
        powercfg /hibernate on 2>$null
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "ShowSleepOption" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Живлення / Патчі / Автозапуск"
    Name  = "Автоматичні оновлення Windows (ACSC 10)"
    Desc  = "NoAutoUpdate=0, AUOptions=4 (автозавантаження і встановлення), AllowMUUpdateService=1"
    Apply = {
        $wu = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
        Set-Reg $wu "NoAutoUpdate"           0
        Set-Reg $wu "AUOptions"              4
        Set-Reg $wu "ScheduledInstallDay"    0
        Set-Reg $wu "AllowMUUpdateService"   1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "SetDisablePauseUXAccess" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" "AllowUpdatesInOOBE" 1
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" 1
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" -1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Живлення / Патчі / Автозапуск"
    Name  = "Вимкнути Autoplay / AutoRun (ACSC 25)"
    Desc  = "NoAutoplayfornonVolume=1, NoAutorun=1, NoDriveTypeAutoRun=255"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoAutoplayfornonVolume" 1
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoAutorun"          1
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoDriveTypeAutoRun" 255
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoAutorun"          0
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoDriveTypeAutoRun" 145
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoDriveTypeAutoRun" 0) -eq 255 }
},

[PSCustomObject]@{
    Group = "Живлення / Патчі / Автозапуск"
    Name  = "Windows Hello for Business + anti-spoofing (ACSC 09)"
    Desc  = "UsePassportForWork=1, RequireSecurityDevice=1, MinPINLength=6, EnhancedAntiSpoofing=1"
    Apply = {
        $wh = "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork"
        Set-Reg $wh "UsePassportForWork"      1
        Set-Reg $wh "RequireSecurityDevice"   1
        Set-Reg $wh "UseBiometrics"           1
        Set-Reg "$wh\PINComplexity" "Expiration"      365
        Set-Reg "$wh\PINComplexity" "MinimumPINLength" 6
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics\FacialFeatures" "EnhancedAntiSpoofing" 1
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork" "UsePassportForWork" 0
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork" "UsePassportForWork" 0) -eq 1 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 11: MISCELLANEOUS / LOW PRIORITY ──────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Misc / Low Priority"
    Name  = "Вимкнути CMD (ACSC 34)"
    Desc  = "HKCU DisableCMD=1 — заборонити доступ до командного рядка"
    Apply  = { Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableCMD" 1 }
    Revert = { Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableCMD" 0 }
    Check  = { (Get-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableCMD" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Misc / Low Priority"
    Name  = "Заборонити редактор реєстру (ACSC 34)"
    Desc  = "HKCU DisableRegistryTools=2 — тихий режим заборони regedit/reg.exe"
    Apply  = { Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableRegistryTools" 2 }
    Revert = { Remove-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableRegistryTools" -ErrorAction SilentlyContinue }
    Check  = { (Get-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableRegistryTools" 0) -eq 2 }
},

[PSCustomObject]@{
    Group = "Misc / Low Priority"
    Name  = "AlwaysInstallElevated = вимкнути (ACSC 34)"
    Desc  = "AlwaysInstallElevated=0 (HKLM+HKCU) + EnableUserControl=0"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" "EnableUserControl"        0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" "AlwaysInstallElevated"    0
        Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" "AlwaysInstallElevated"    0
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" "AlwaysInstallElevated" 1
        Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" "AlwaysInstallElevated" 1
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" "AlwaysInstallElevated" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Misc / Low Priority"
    Name  = "Вимкнути Game DVR, Widgets, Store, Sound Recorder (ACSC 32)"
    Desc  = "AllowGameDVR=0, DisableWidgets=1, RemoveWindowsStore=1, Soundrec=0"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"    "AllowGameDVR"             0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Widgets"    "DisableWidgetsOnLockScreen" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Widgets"    "DisableWidgetsBoard"       1
        # Disable News and Interests feed (private-secure-windows)
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"               "AllowNewsAndInterests"     0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"       "RemoveWindowsStore"        1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\SoundRecorder"      "Soundrec"                  0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"     "DisableHTTPPrinting"       1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" "RestrictDriverInstallationToAdministrators" 1
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR"      1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"    "RemoveWindowsStore" 0
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowGameDVR" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Misc / Low Priority"
    Name  = "Вимкнути Location Services (ACSC 34)"
    Desc  = "DisableLocation=1, DisableLocationScripting=1, DisableWindowsLocationProvider=1"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" "DisableLocation"        1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" "DisableLocationScripting" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors\WindowsLocationProvider" "DisableWindowsLocationProvider" 1
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" "DisableLocation" 0
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" "DisableLocation" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Misc / Low Priority"
    Name  = "Показувати розширення файлів + блок Safe Mode для не-адмінів (ACSC 40)"
    Desc  = "HideFileExt=0, SafeModeBlockNonAdmins=1, FIPS=1, ForceKeyProtection=2"
    Apply = {
        Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "SafeModeBlockNonAdmins" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography" "ForceKeyProtection" 2
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" "Enabled" 1
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "ProtectionMode" 1
        Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableThirdPartySuggestions" 1
    }
    Revert = {
        Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 1
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" "Enabled" 0
    }
    Check = { (Get-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Misc / Low Priority"
    Name  = "Attachment Manager — зберігати Zone інформацію (ACSC 23)"
    Desc  = "SaveZoneInformation=2 (не видаляти), HideZoneInfoOnProperties=1"
    Apply = {
        $am = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments"
        Set-Reg $am "SaveZoneInformation"      2
        Set-Reg $am "HideZoneInfoOnProperties" 1
    }
    Revert = { Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments" "SaveZoneInformation" 1 }
    Check  = { (Get-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments" "SaveZoneInformation" 1) -eq 2 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 16: ЖИВЛЕННЯ — ДЕТАЛЬНІ НАЛАШТУВАННЯ ───────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Живлення — детальні"
    Name  = "Standby S1-S3 вимкнути + пароль при пробудженні (ACSC)"
    Desc  = "Заборонити режими очікування (S1-S3), вимагати пароль при пробудженні (батарея і мережа)"
    Apply = {
        $pw = "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings"
        # Allow standby states (S1-S3) = Disabled (0 = disabled)
        Set-Reg "$pw\abfc2519-3608-4c2a-94ea-171b0ed546ab" "DCSettingIndex" 0
        Set-Reg "$pw\abfc2519-3608-4c2a-94ea-171b0ed546ab" "ACSettingIndex" 0
        # Require password on wake
        Set-Reg "$pw\0e796bdb-100d-47d6-a2d5-f7d2daa51f51" "DCSettingIndex" 1
        Set-Reg "$pw\0e796bdb-100d-47d6-a2d5-f7d2daa51f51" "ACSettingIndex" 1
        # Hibernate timeout = 0
        Set-Reg "$pw\9d7815a6-7ee4-497e-8888-515a05f02364" "DCSettingIndex" 0
        Set-Reg "$pw\9d7815a6-7ee4-497e-8888-515a05f02364" "ACSettingIndex" 0
        # Sleep timeout = 0
        Set-Reg "$pw\29f6c1db-86da-48c5-9fdb-f2b67b1f44da" "DCSettingIndex" 0
        Set-Reg "$pw\29f6c1db-86da-48c5-9fdb-f2b67b1f44da" "ACSettingIndex" 0
        # Unattended sleep timeout = 0
        Set-Reg "$pw\7bc4a2f9-d8fc-4469-b07b-33eb785aaca0" "DCSettingIndex" 0
        Set-Reg "$pw\7bc4a2f9-d8fc-4469-b07b-33eb785aaca0" "ACSettingIndex" 0
        # Turn off hybrid sleep
        Set-Reg "$pw\94ac6d29-73ce-41a6-809f-6363ba21b47e" "DCSettingIndex" 0
        Set-Reg "$pw\94ac6d29-73ce-41a6-809f-6363ba21b47e" "ACSettingIndex" 0
        # Hide hibernate and sleep from power menu
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "ShowHibernateOption" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "ShowSleepOption"     0
        powercfg /hibernate off 2>$null
    }
    Revert = {
        $pw = "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings"
        Remove-RegValue "$pw\abfc2519-3608-4c2a-94ea-171b0ed546ab" "DCSettingIndex"
        Remove-RegValue "$pw\abfc2519-3608-4c2a-94ea-171b0ed546ab" "ACSettingIndex"
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "ShowHibernateOption" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "ShowSleepOption"     1
        powercfg /hibernate on 2>$null
    }
    Check = {
        $v = Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\abfc2519-3608-4c2a-94ea-171b0ed546ab" "DCSettingIndex" -1
        $v -eq 0
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 22: ПРИСТРОЇ — CD/WLAN/RSS/SEARCH ─────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Пристрої — CD/WLAN/RSS/Search"
    Name  = "Вимкнути запис CD (ACSC)"
    Desc  = "NoCDBurning=1: заборонити функції запису CD/DVD у Провіднику Windows"
    Apply  = { Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoCDBurning" 1 }
    Revert = { Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoCDBurning" 0 }
    Check  = { (Get-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoCDBurning" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Пристрої — CD/WLAN/RSS/Search"
    Name  = "Device Installation — заблокувати FireWire/Thunderbolt класи (ACSC)"
    Desc  = "Заблокувати установку пристроїв IEEE 1394 класу {d48179be-ec20-11d1-b6b8-00c04fa372a7}"
    Apply = {
        $dr = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions"
        Set-Reg $dr "DenyDeviceClasses"  1
        Set-Reg $dr "DenyDeviceClassesRetroactive" 1
        $dc = "$dr\DenyDeviceClasses"
        if (-not (Test-Path $dc)) { New-Item -Path $dc -Force | Out-Null }
        Set-Reg $dc "1" "{d48179be-ec20-11d1-b6b8-00c04fa372a7}" "String"
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceClasses" 0
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceClasses" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Пристрої — CD/WLAN/RSS/Search"
    Name  = "WLAN — вимкнути автоматичне підключення до hotspots (ACSC)"
    Desc  = "AutoConnectAllowedOEM=0: не підключатися до запропонованих відкритих точок доступу"
    Apply  = { Set-Reg "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" "AutoConnectAllowedOEM" 0 }
    Revert = { Set-Reg "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" "AutoConnectAllowedOEM" 1 }
    Check  = { (Get-Reg "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" "AutoConnectAllowedOEM" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Пристрої — CD/WLAN/RSS/Search"
    Name  = "RSS Feeds — заборонити завантаження вкладень (ACSC)"
    Desc  = "DisableEnclosureDownload=1: заборонити завантаження вкладень із RSS-стрічок"
    Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds" "DisableEnclosureDownload" 1 }
    Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds" "DisableEnclosureDownload" 0 }
    Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds" "DisableEnclosureDownload" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Пристрої — CD/WLAN/RSS/Search"
    Name  = "Search — вимкнути індексацію шифрованих файлів (ACSC)"
    Desc  = "AllowIndexingEncryptedStoresOrItems=0: заборонити індексацію зашифрованих файлів"
    Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowIndexingEncryptedStoresOrItems" 0 }
    Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowIndexingEncryptedStoresOrItems" 1 }
    Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowIndexingEncryptedStoresOrItems" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Пристрої — CD/WLAN/RSS/Search"
    Name  = "Web Search — вимкнути пошук у вебі (ACSC)"
    Desc  = "DisableWebSearch=1, ConnectedSearchUseWeb=0: не показувати веб-результати в пошуку"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch"      1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "ConnectedSearchUseWeb" 0
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch" 0
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Пристрої — CD/WLAN/RSS/Search"
    Name  = "File Explorer — heap termination, shell protocol (ACSC)"
    Desc  = "NoHeapTerminationOnCorruption=0, PreXPSP2ShellProtocolBehavior=0: не вимикати DEP та захист оболонки"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoHeapTerminationOnCorruption"    0
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "PreXPSP2ShellProtocolBehavior" 0
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoHeapTerminationOnCorruption"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoHeapTerminationOnCorruption" 1) -eq 0 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ: ВІДНОВЛЕННЯ / ЗРУЧНІСТЬ ─────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Відновлення / Зручність"
    Name  = "Windows Store — відновити доступ"
    Desc  = "RemoveWindowsStore=0; знімає GPO-блокування Microsoft Store і modern-застосунків (Notepad, SnippingTool тощо)"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" "RemoveWindowsStore" 0
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" "RemoveWindowsStore" 1
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" "RemoveWindowsStore" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Відновлення / Зручність"
    Name  = "Snipping Tool — відновити"
    Desc  = "DisableSnippingTool=0 у HKLM і HKCU; повертає доступ до Snipping Tool / Snip & Sketch"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SnippingTool"     "DisableSnippingTool" 0
        Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer"         "DisableSnippingTool" 0
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DisabledHotkeys" "" "String"
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SnippingTool" "DisableSnippingTool" 1
        Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer"      "DisableSnippingTool" 1
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SnippingTool" "DisableSnippingTool" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Відновлення / Зручність"
    Name  = "Notepad — відновити (system + Store)"
    Desc  = "Знімає DisableUAT/AppCompat-блок; Store Notepad стає доступним після відновлення WindowsStore"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableUAT"            0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "AITEnable"             1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableProgramCompat"  0
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableUAT" 1
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableUAT" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Відновлення / Зручність"
    Name  = "PowerShell + CMD — RemoteSigned замість AllSigned"
    Desc  = "ExecutionPolicy=RemoteSigned: локальні скрипти не вимагають підпису; знімає Authenticode SRP (AuthenticodeEnabled=0)"
    Apply = {
        $ps = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell"
        Set-Reg $ps "ExecutionPolicy" "RemoteSigned" "String"
        Set-Reg $ps "EnableScripts"   1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Safer\CodeIdentifiers" "AuthenticodeEnabled" 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" `
            -Name "ExecutionPolicy" -Value "RemoteSigned" -ErrorAction SilentlyContinue
    }
    Revert = {
        $ps = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell"
        Set-Reg $ps "ExecutionPolicy" "AllSigned" "String"
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Safer\CodeIdentifiers" "AuthenticodeEnabled" 1
    }
    Check = {
        $ep = Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell" "ExecutionPolicy" "AllSigned"
        $ep -eq "RemoteSigned"
    }
},

[PSCustomObject]@{
    Group = "Відновлення / Зручність"
    Name  = "Windows Security — відновити іконку у systray"
    Desc  = "HideSystray=0, HideSCAHealth=0; повертає іконку щита Windows Security у панель сповіщень"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" "HideSystray"  0
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"           "HideSCAHealth" 0
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"           "HideSCAHealth" 0
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" "HideSystray"  1
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"           "HideSCAHealth" 1
    }
    Check = {
        (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" "HideSystray" 1) -eq 0
    }
},

[PSCustomObject]@{
    Group = "Відновлення / Зручність"
    Name  = "Windows Security Center — відновити сервіс і застосунок"
    Desc  = "SecurityHealthService та wscsvc у режимі Автоматичний; PerUserSecurityHealthAgent=1; перезапускає SecurityHealthSystray"
    Apply = {
        Set-Service -Name "SecurityHealthService" -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name "SecurityHealthService"                       -ErrorAction SilentlyContinue
        Set-Service -Name "wscsvc"                -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name "wscsvc"                                      -ErrorAction SilentlyContinue
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" `
            "SecurityHealth" "%windir%\system32\SecurityHealthSystray.exe" "ExpandString"
    }
    Revert = {
        Stop-Service -Name "SecurityHealthService" -Force     -ErrorAction SilentlyContinue
        Set-Service  -Name "SecurityHealthService" -StartupType Disabled -ErrorAction SilentlyContinue
    }
    Check = {
        $s = Get-Service -Name "SecurityHealthService" -ErrorAction SilentlyContinue
        $s -and $s.StartType -eq 'Automatic'
    }
}

)

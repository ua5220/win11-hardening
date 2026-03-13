<#
.SYNOPSIS
    Приватність: HKCU/HKLM налаштування, OneDrive, Xbox, Edge, звукозапис
.NOTES
    Частина Get-HardeningSettings — підвантажується через settings.data.ps1
#>

@(

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 21: MICROSOFT ACCOUNTS / ONEDRIVE ──────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Microsoft Accounts / OneDrive"
    Name  = "Заблокувати Consumer Microsoft accounts (ACSC)"
    Desc  = "DisableUserAuth=1, AllowMicrosoftAccountsToBeOptional=1, DisableFileSyncNGSC=1"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount"   "DisableUserAuth"                  1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppRuntime" "AllowMicrosoftAccountsToBeOptional" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"   "DisableFileSyncNGSC"              1
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount" "DisableUserAuth" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 0
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount" "DisableUserAuth" 0) -eq 1 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 30: SOUND RECORDER ─────────────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Sound Recorder"
    Name  = "Sound Recorder — заборонити запуск (ACSC)"
    Desc  = "Soundrec=0: не дозволяти запуск Sound Recorder"
    Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\SoundRecorder" "Soundrec" 0 }
    Revert = { Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\SoundRecorder" "Soundrec" }
    Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\SoundRecorder" "Soundrec" 1) -eq 0 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 37: ПРИВАТНІСТЬ (HKCU) ────────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Приватність (HKCU)"
    Name  = "Tailored experiences / Feedback notifications / SoftLanding — вимкнути"
    Desc  = "DisableTailoredExperiencesWithDiagnosticData=1, DoNotShowFeedbackNotifications=1, DisableSoftLanding=1"
    Apply = {
        $p = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
        Set-Reg $p "DisableTailoredExperiencesWithDiagnosticData" 1
        Set-Reg $p "DoNotShowFeedbackNotifications"               1
        Set-Reg $p "DisableSoftLanding"                           1
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" `
                "TailoredExperiencesWithDiagnosticDataEnabled" 0
    }
    Revert = {
        $p = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
        Remove-RegValue $p "DisableTailoredExperiencesWithDiagnosticData"
        Remove-RegValue $p "DoNotShowFeedbackNotifications"
        Remove-RegValue $p "DisableSoftLanding"
    }
    Check = {
        (Get-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
                 "DisableTailoredExperiencesWithDiagnosticData" 0) -eq 1
    }
},

[PSCustomObject]@{
    Group = "Приватність (HKCU)"
    Name  = "Advertising ID — вимкнути (HKCU + HKLM GPO)"
    Desc  = "AdvertisingInfo Enabled=0 (HKCU) + DisabledByGroupPolicy=1 (HKLM)"
    Apply = {
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" `
                "Enabled" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" `
                "DisabledByGroupPolicy" 1
    }
    Revert = {
        Remove-RegValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled"
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" "DisabledByGroupPolicy"
    }
    Check = {
        (Get-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" 1) -eq 0
    }
},

[PSCustomObject]@{
    Group = "Приватність (HKCU)"
    Name  = "LetApps: Камера / Мікрофон / Локація = Заборонити"
    Desc  = "ConsentStore webcam/microphone/location → Заборонити; LetAppsAccess* = 2 у AppPrivacy"
    Apply = {
        $cs = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore"
        Set-Reg "$cs\webcam"     "Value" "Deny" "String"
        Set-Reg "$cs\microphone" "Value" "Deny" "String"
        Set-Reg "$cs\location"   "Value" "Deny" "String"
        $ap = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy"
        Set-Reg $ap "LetAppsAccessCamera"      2
        Set-Reg $ap "LetAppsAccessMicrophone"  2
        Set-Reg $ap "LetAppsAccessLocation"    2
    }
    Revert = {
        $cs = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore"
        Remove-RegValue "$cs\webcam"     "Value"
        Remove-RegValue "$cs\microphone" "Value"
        Remove-RegValue "$cs\location"   "Value"
        $ap = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy"
        Remove-RegValue $ap "LetAppsAccessCamera"
        Remove-RegValue $ap "LetAppsAccessMicrophone"
        Remove-RegValue $ap "LetAppsAccessLocation"
    }
    Check = {
        $v = Get-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" ""
        $v -eq "Deny"
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 38: СЕРВІСИ XBOX / DEMO / ГЕОЛОКАЦІЯ ──────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Сервіси: Xbox / Demo / Геолокація"
    Name  = "Xbox Gaming Services — вимкнути"
    Desc  = "XblGameSave, XblAuthManager, XboxNetApiSvc, XboxGipSvc → Вимкнено"
    Apply = {
        foreach ($svc in @("XblGameSave","XblAuthManager","XboxNetApiSvc","XboxGipSvc")) {
            Set-ServiceDisabled $svc
        }
    }
    Revert = {
        foreach ($svc in @("XblGameSave","XblAuthManager","XboxNetApiSvc","XboxGipSvc")) {
            Set-ServiceManual $svc
        }
    }
    Check = {
        $s = Get-Service "XblGameSave" -ErrorAction SilentlyContinue
        $s -and $s.StartType -eq 'Disabled'
    }
},

[PSCustomObject]@{
    Group = "Сервіси: Xbox / Demo / Геолокація"
    Name  = "Retail Demo / Media / Peer-кешування — вимкнути"
    Desc  = "RetailDemo, WMPNetworkSvc, WpcMonSvc, PeerDistSvc, PhoneSvc → Вимкнено"
    Apply = {
        foreach ($svc in @("RetailDemo","WMPNetworkSvc","WpcMonSvc","PeerDistSvc","PhoneSvc")) {
            Set-ServiceDisabled $svc
        }
    }
    Revert = {
        foreach ($svc in @("RetailDemo","WMPNetworkSvc","WpcMonSvc","PeerDistSvc","PhoneSvc")) {
            Set-ServiceManual $svc
        }
    }
    Check = {
        $s = Get-Service "RetailDemo" -ErrorAction SilentlyContinue
        $s -and $s.StartType -eq 'Disabled'
    }
},

[PSCustomObject]@{
    Group = "Сервіси: Xbox / Demo / Геолокація"
    Name  = "Геолокація / Mobile Hotspot / SharedAccess / TapiSrv — вимкнути"
    Desc  = "lfsvc (GPS), icssvc (точка доступу), SharedAccess (ICS), TapiSrv (телефонія) → Вимкнено"
    Apply = {
        foreach ($svc in @("lfsvc","icssvc","SharedAccess","TapiSrv")) {
            Set-ServiceDisabled $svc
        }
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" "DisableLocation" 1
    }
    Revert = {
        foreach ($svc in @("lfsvc","icssvc","SharedAccess","TapiSrv")) {
            Set-ServiceManual $svc
        }
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" "DisableLocation"
    }
    Check = {
        $s = Get-Service "lfsvc" -ErrorAction SilentlyContinue
        $s -and $s.StartType -eq 'Disabled'
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 44: IE / EDGE — ЗАХИСТ ──────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "IE / Edge — захист"
    Name  = "IE — 64-bit Tab Isolation + ActiveX захист"
    Desc  = "Isolation64Bit=1: 64-бітна ізоляція процесів для IE; 270C=0: захист ActiveX від шкідливого ПЗ в Internet Zone"
    Apply = {
        Set-Reg "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main" "Isolation64Bit" 1
        Set-Reg "HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" "270C" 0
    }
    Revert = {
        Remove-RegValue "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main" "Isolation64Bit"
        Remove-RegValue "HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" "270C"
    }
    Check = { (Get-Reg "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main" "Isolation64Bit" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "IE / Edge — захист"
    Name  = "IE — Enhanced Protected Mode + заборонити Flash"
    Desc  = "Isolation=PMEM, Enhanced Protected Mode, вимкнути Flash Player для Internet Explorer"
    Apply = {
        $ie = "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main"
        Set-Reg $ie "Isolation"          "PMEM" "String"
        Set-Reg $ie "EnableEnhancedProtectedMode" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BLOCK_SHOCKWAVE_FLASH" "iexplore.exe" 1
    }
    Revert = {
        $ie = "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main"
        Remove-RegValue $ie "Isolation"
        Remove-RegValue $ie "EnableEnhancedProtectedMode"
    }
    Check = { (Get-Reg "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main" "EnableEnhancedProtectedMode" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "IE / Edge — захист"
    Name  = "Edge — заблокувати збір даних та рекламу"
    Desc  = "DoNotTrack=1, FormSuggest=no, PersonalizationReportingEnabled=0 — вимкнути відстеження та автозаповнення у браузері"
    Apply = {
        $edge = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main"
        Set-Reg $edge "DoNotTrack"     1
        Set-Reg $edge "FormSuggest"    "no" "String"
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Privacy" "EnableEncryptedMediaExtensions" 0
        Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" "PersonalizationReportingEnabled" 0
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" "DoNotTrack"
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" "FormSuggest"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" "DoNotTrack" 0) -eq 1 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 46: ПРИВАТНІСТЬ — РОЗШИРЕНА (HKLM) ─────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Приватність — розширена (HKLM)"
    Name  = "Connected Devices Platform (CDP) — вимкнути"
    Desc  = "EnableCdp=0: вимкнути міжпристроєву синхронізацію, спільний буфер обміну, «Продовжити на ПК»"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableCdp" 0
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableCdp"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableCdp" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Приватність — розширена (HKLM)"
    Name  = "Cortana / Search — повністю вимкнути"
    Desc  = "AllowCortana=0, DisableWebSearch=1, ConnectedSearchUseWeb=0, AllowSearchToUseLocation=0"
    Apply = {
        $ws = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
        Set-Reg $ws "AllowCortana"           0
        Set-Reg $ws "DisableWebSearch"       1
        Set-Reg $ws "ConnectedSearchUseWeb"  0
        Set-Reg $ws "AllowSearchToUseLocation" 0
        Set-Reg $ws "AllowCloudSearch"       0
        Set-Reg $ws "AllowCortanaAboveLock"  0
    }
    Revert = {
        $ws = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
        Set-Reg $ws "AllowCortana"      1
        Set-Reg $ws "DisableWebSearch"  0
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Приватність — розширена (HKLM)"
    Name  = "Windows Store — вимкнути автооновлення та пропозиції"
    Desc  = "AutoDownload=4, DisableOSUpgrade=1: обмежити автозавантаження, вимкнути оновлення ОС через Store"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" "AutoDownload"    4
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" "DisableOSUpgrade" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableSoftLanding" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableCloudOptimizedContent" 1
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" "AutoDownload"
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" "DisableOSUpgrade"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" "AutoDownload" 0) -eq 4 }
},

[PSCustomObject]@{
    Group = "Приватність — розширена (HKLM)"
    Name  = "Microsoft Accounts — вимкнути автентифікацію"
    Desc  = "DisableUserAuth=1, AllowMicrosoftAccountsToBeOptional=1: блокувати автентифікацію MSA на пристрої"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount" "DisableUserAuth" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppRuntime" "AllowMicrosoftAccountsToBeOptional" 1
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount" "DisableUserAuth"
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppRuntime" "AllowMicrosoftAccountsToBeOptional"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount" "DisableUserAuth" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Приватність — розширена (HKLM)"
    Name  = "Delivery Optimization — вимкнути P2P оновлення"
    Desc  = "DODownloadMode=0: тільки HTTP, без P2P розповсюдження оновлень"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode" 0
        Set-ServiceDisabled "DoSvc"
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode"
        Set-ServiceManual "DoSvc"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Приватність — розширена (HKLM)"
    Name  = "Encrypted Files — заборонити індексацію (CIS)"
    Desc  = "AllowIndexingEncryptedStoresOrItems=0: не індексувати шифровані файли Windows Search"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowIndexingEncryptedStoresOrItems" 0
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowIndexingEncryptedStoresOrItems"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowIndexingEncryptedStoresOrItems" 1) -eq 0 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 50: ПРИВАТНІСТЬ — РОЗШИРЕНА (HKCU) ─────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Приватність — розширена (HKCU)"
    Name  = "Advertising ID — вимкнути для поточного користувача"
    Desc  = "Enabled=0: вимкнути рекламний ідентифікатор Windows"
    Apply = {
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" 0
    }
    Revert = {
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" 1
    }
    Check = { (Get-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Приватність — розширена (HKCU)"
    Name  = "Персоналізація введення / рукопис — вимкнути"
    Desc  = "RestrictImplicitInkCollection=1, RestrictImplicitTextCollection=1: не збирати дані рукопису/введення"
    Apply = {
        Set-Reg "HKCU:\SOFTWARE\Microsoft\InputPersonalization" "RestrictImplicitInkCollection"  1
        Set-Reg "HKCU:\SOFTWARE\Microsoft\InputPersonalization" "RestrictImplicitTextCollection" 1
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" "AcceptedPrivacyPolicy" 0
    }
    Revert = {
        Set-Reg "HKCU:\SOFTWARE\Microsoft\InputPersonalization" "RestrictImplicitInkCollection"  0
        Set-Reg "HKCU:\SOFTWARE\Microsoft\InputPersonalization" "RestrictImplicitTextCollection" 0
    }
    Check = { (Get-Reg "HKCU:\SOFTWARE\Microsoft\InputPersonalization" "RestrictImplicitInkCollection" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Приватність — розширена (HKCU)"
    Name  = "Хмарна синхронізація / журнал буфера обміну — вимкнути"
    Desc  = "AllowCrossDeviceClipboard=0, AllowClipboardHistory=0: вимкнути хмарний буфер обміну"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCrossDeviceClipboard" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowClipboardHistory"     0
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCrossDeviceClipboard"
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowClipboardHistory"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCrossDeviceClipboard" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Приватність — розширена (HKCU)"
    Name  = "Діагностичні дані / зворотний зв'язок — мінімізувати"
    Desc  = "NumberOfSIUFInPeriod=0, DoNotShowFeedbackNotifications=1: вимкнути запити зворотного зв'язку"
    Apply = {
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "DoNotShowFeedbackNotifications" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "LimitDiagnosticLogCollection"    1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "LimitDumpCollection"             1
    }
    Revert = {
        Remove-RegValue "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod"
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "DoNotShowFeedbackNotifications"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "DoNotShowFeedbackNotifications" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Приватність — розширена (HKCU)"
    Name  = "Дозволи програм — заборонити доступ до камери/мікрофона/локації"
    Desc  = "LetAppsAccessCamera=2, LetAppsAccessMicrophone=2, LetAppsAccessLocation=2 (Примусова заборона)"
    Apply = {
        $ap = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore"
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessCamera"     2
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessMicrophone" 2
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessLocation"   2
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessContacts"   2
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessCalendar"   2
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessCallHistory" 2
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessMessaging"  2
    }
    Revert = {
        $keys = @("LetAppsAccessCamera","LetAppsAccessMicrophone","LetAppsAccessLocation",
                  "LetAppsAccessContacts","LetAppsAccessCalendar","LetAppsAccessCallHistory","LetAppsAccessMessaging")
        foreach ($k in $keys) {
            Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" $k
        }
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessCamera" 0) -eq 2 }
}

)

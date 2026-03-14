<#
.SYNOPSIS
    Приватність: HKCU/HKLM налаштування, OneDrive, Xbox, Edge, звукозапис
.NOTES
    Частина Get-HardeningSettings — підвантажується через settings.data.ps1
#>

@(

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 52: COPILOT / AI / CORTANA / WIDGETS ───────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Copilot / AI / Widgets"
    Name  = "Windows Recall — вимкнути (AIDataAnalysis + EnableRecallOnDevice)"
    Desc  = "DisableAIDataAnalysis=1 (HKLM+HKCU), EnableRecallOnDevice=0: повне вимкнення Windows Recall"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis"  1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "EnableRecallOnDevice"   0
        Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis"  1
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis"
        Remove-RegValue "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Copilot / AI / Widgets"
    Name  = "Windows Copilot — вимкнути (HKLM + HKCU + Taskbar button)"
    Desc  = "TurnOffWindowsCopilot=1 (HKLM+HKCU), ShowCopilotButton=0: повне вимкнення Copilot та кнопки на панелі задач"
    Apply = {
        Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" 1
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowCopilotButton" 0
    }
    Revert = {
        Remove-RegValue "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot"
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot"
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowCopilotButton" 1
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Copilot / AI / Widgets"
    Name  = "Copilot в Edge / Office — вимкнути"
    Desc  = "HubsSidebarEnabled=0, CopilotPageContext=0 (Edge); optionaldiagnosticdata=0, sendtelemetry=3 (Office)"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge"                       "HubsSidebarEnabled"        0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge"                       "CopilotPageContext"         0
        Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\office\16.0\common\privacy" "optionaldiagnosticdata"     0
        Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\office\16.0\common\privacy" "sendtelemetry"              3
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "HubsSidebarEnabled"
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "CopilotPageContext"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "HubsSidebarEnabled" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Copilot / AI / Widgets"
    Name  = "Widgets / Feeds / Фонові застосунки — вимкнути"
    Desc  = "TaskbarDa=0, AllowNewsAndInterests=0, EnableFeeds=0, GlobalUserDisabled=1, BackgroundAppGlobalToggle=0"
    Apply = {
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"                "AllowNewsAndInterests"        0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" "EnableFeeds"               0
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" 1
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "BackgroundAppGlobalToggle"  0
    }
    Revert = {
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" 1
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" "AllowNewsAndInterests"
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" 0
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" "AllowNewsAndInterests" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Copilot / AI / Widgets"
    Name  = "Онлайн-розпізнавання мовлення — вимкнути"
    Desc  = "HasAccepted=0 (OnlineSpeechPrivacy), AllowInputPersonalization=0: відмовитись від онлайн-розпізнавання мовлення"
    Apply = {
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" "HasAccepted" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" "AllowInputPersonalization"      0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" "RestrictImplicitInkCollection"  1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" "RestrictImplicitTextCollection" 1
    }
    Revert = {
        Remove-RegValue "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" "HasAccepted"
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" "AllowInputPersonalization"
    }
    Check = { (Get-Reg "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" "HasAccepted" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Copilot / AI / Widgets"
    Name  = "Cortana Scheduled Tasks — вимкнути"
    Desc  = "SearchUserDataAccountProviders, BingSafety → Вимкнено"
    Apply = {
        Disable-Task "\Microsoft\Windows\Cortana\" "SearchUserDataAccountProviders"
        Disable-Task "\Microsoft\Windows\Cortana\" "BingSafety"
    }
    Revert = {
        Enable-Task "\Microsoft\Windows\Cortana\" "SearchUserDataAccountProviders"
        Enable-Task "\Microsoft\Windows\Cortana\" "BingSafety"
    }
    Check = {
        $t = Get-ScheduledTask -TaskPath "\Microsoft\Windows\Cortana\" `
                               -TaskName "BingSafety" -ErrorAction SilentlyContinue
        $t -and $t.State -eq 'Disabled'
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 21: MICROSOFT ACCOUNTS / ONEDRIVE ──────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Microsoft Accounts / OneDrive"
    Name  = "OneDrive — вимкнути синхронізацію (ACSC)"
    Desc  = "DisableFileSyncNGSC=1: вимкнути OneDrive sync. DisableUserAuth прибрано — ламає MS Store та UWP-застосунки"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 1
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 0
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 0) -eq 1 }
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
    Name  = "ContentDeliveryManager — вимкнути рекламу та пропозиції"
    Desc  = "SubscribedContent-338388/338389/353698Enabled=0, ContentDeliveryAllowed=0, SilentInstalledAppsEnabled=0 тощо"
    Apply = {
        $cdm = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
        Set-Reg $cdm "SubscribedContent-338388Enabled"   0
        Set-Reg $cdm "SubscribedContent-338389Enabled"   0
        Set-Reg $cdm "SubscribedContent-353698Enabled"   0
        Set-Reg $cdm "ContentDeliveryAllowed"             0
        Set-Reg $cdm "OemPreInstalledAppsEnabled"         0
        Set-Reg $cdm "PreInstalledAppsEnabled"            0
        Set-Reg $cdm "SilentInstalledAppsEnabled"         0
        Set-Reg $cdm "SystemPaneSuggestionsEnabled"       0
    }
    Revert = {
        $cdm = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
        Set-Reg $cdm "ContentDeliveryAllowed"       1
        Set-Reg $cdm "SilentInstalledAppsEnabled"   1
        Set-Reg $cdm "SystemPaneSuggestionsEnabled" 1
    }
    Check = { (Get-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "ContentDeliveryAllowed" 1) -eq 0 }
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

[PSCustomObject]@{
    Group = "Приватність (HKCU)"
    Name  = "ConsentStore — заборонити доступ для контактів/пошти/нотифікацій/активності/Bluetooth"
    Desc  = "contacts/appointments/phoneCall/chat/email/userNotificationListener/activity/bluetoothSync → Deny"
    Apply = {
        $cs = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore"
        foreach ($cap in @("contacts","appointments","phoneCall","chat","email",
                           "userNotificationListener","activity","bluetoothSync")) {
            Set-Reg "$cs\$cap" "Value" "Deny" "String"
        }
    }
    Revert = {
        $cs = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore"
        foreach ($cap in @("contacts","appointments","phoneCall","chat","email",
                           "userNotificationListener","activity","bluetoothSync")) {
            Remove-RegValue "$cs\$cap" "Value"
        }
    }
    Check = {
        $v = Get-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" "Value" ""
        $v -eq "Deny"
    }
},

[PSCustomObject]@{
    Group = "Приватність (HKCU)"
    Name  = "DeviceAccess\Global — заборонити доступ UWP-застосунків (GUID-перелік)"
    Desc  = "Усі відомі GUIDs: камера, мікрофон, локація, контакти, пошта, дзвінки, завдання, пристрої поруч → Deny"
    Apply = {
        $base = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global"
        $guids = @{
            '{E5323777-F976-4f5b-9B55-B94699C46E44}' = 'Камера'
            '{2EEF81BE-33FA-4800-9670-1CD474972C3F}' = 'Мікрофон'
            '{C1D23ACC-752B-43E5-8448-8D0E519CD6D6}' = 'Рухова активність'
            '{7D7E8402-7C54-4821-A34E-AEEFD62DED93}' = 'Сповіщення'
            '{D89823BA-7180-4B81-B50C-7E471E6121A3}' = 'Облікові записи'
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
        }
        foreach ($guid in $guids.Keys) {
            $p = "$base\$guid"
            if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
            Set-ItemProperty -Path $p -Name "Type"  -Value "InterfaceClass" -Type String -Force
            Set-ItemProperty -Path $p -Name "Value" -Value "Deny"           -Type String -Force
        }
        # LooselyCoupled — широкий доступ UWP
        $lc = "$base\LooselyCoupled"
        if (-not (Test-Path $lc)) { New-Item -Path $lc -Force | Out-Null }
        Set-ItemProperty -Path $lc -Name "Type"  -Value "LooselyCoupled" -Type String -Force
        Set-ItemProperty -Path $lc -Name "Value" -Value "Deny"           -Type String -Force
    }
    Revert = {
        $base = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global"
        $guids = @(
            '{E5323777-F976-4f5b-9B55-B94699C46E44}','{2EEF81BE-33FA-4800-9670-1CD474972C3F}',
            '{C1D23ACC-752B-43E5-8448-8D0E519CD6D6}','{7D7E8402-7C54-4821-A34E-AEEFD62DED93}',
            '{D89823BA-7180-4B81-B50C-7E471E6121A3}','{992AFA70-6F47-4148-B3E9-3003349C1548}',
            '{21157C1F-2651-4CC1-90CA-1F28B02263F6}','{A8804298-2D5F-42E3-9531-9C8C39EB29CE}',
            '{BFA794E4-F964-4FDB-90F6-51056BFE4B44}','{E6AD100E-5F4E-44CD-BE0F-2265D88D14F5}',
            '{235B668D-B2AC-4864-B49C-ED1084F6C9D3}','{8BC668CF-7728-45BD-93F8-CF2B3B41D7AB}',
            '{52079E78-A92B-413F-B213-E8FE35712E72}','{9231CB4C-BF57-4AF3-8C55-FDA7BFCC04C5}',
            '{9D9E0118-1807-4F2E-96E4-2CE57142E196}','{2297E4E2-5DBE-466D-A3B5-2556E3BA2B9A}'
        )
        foreach ($guid in $guids) {
            $p = "$base\$guid"
            if (Test-Path $p) { Remove-ItemProperty -Path $p -Name "Value" -ErrorAction SilentlyContinue }
        }
    }
    Check = {
        $p = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2EEF81BE-33FA-4800-9670-1CD474972C3F}"
        if (Test-Path $p) {
            (Get-ItemProperty -Path $p -ErrorAction SilentlyContinue).Value -eq "Deny"
        } else { $false }
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
    Name  = "OneDrive — розширені параметри вимкнення"
    Desc  = "DisableMeteredNetworkFileSync=1, DisableLibrariesDefaultSaveToOneDrive=1, DisablePersonalSync=1, ShowSyncProviderNotifications=0, CLSID приховати"
    Apply = {
        $od = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
        Set-Reg $od "DisableFileSyncNGSC"                       1
        Set-Reg $od "DisableMeteredNetworkFileSync"             1
        Set-Reg $od "DisableLibrariesDefaultSaveToOneDrive"     1
        Set-Reg "HKCU:\SOFTWARE\Microsoft\OneDrive"            "DisablePersonalSync"       1
        Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSyncProviderNotifications" 0
        # Приховати OneDrive з бічної панелі Провідника
        Set-Reg "HKLM:\SOFTWARE\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
        Set-Reg "HKCU:\SOFTWARE\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
        if ([Environment]::Is64BitOperatingSystem) {
            Set-Reg "HKLM:\SOFTWARE\Wow6432Node\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
            Set-Reg "HKCU:\SOFTWARE\Wow6432Node\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
        }
        # Вимкнути завдання OneDrive
        @("OneDrive Standalone Update Task v2","OneDrive Reporting Task-S-1-5-21") | ForEach-Object {
            Get-ScheduledTask -TaskName "*$_*" -ErrorAction SilentlyContinue |
                Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null
        }
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" "DisableMeteredNetworkFileSync" 0
        Set-Reg "HKLM:\SOFTWARE\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 1
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" "DisableMeteredNetworkFileSync" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Приватність — розширена (HKLM)"
    Name  = "CDP Per-user Services — вимкнути (CDPUserSvc, OneSyncSvc, PimIndex, UserDataSvc та ін.)"
    Desc  = "CDPUserSvc, OneSyncSvc, PimIndexMaintenanceSvc, UnistoreSvc, UserDataSvc, MessagingService, WpnUserService → Start=4"
    Apply = {
        $svcs = @("CDPUserSvc","OneSyncSvc","PimIndexMaintenanceSvc","UnistoreSvc",
                  "UserDataSvc","MessagingService","WpnUserService")
        foreach ($svcName in $svcs) {
            Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services" |
                Where-Object { $_.PSChildName -like "$svcName*" } |
                ForEach-Object { Set-Reg $_.PSPath "Start" 4 }
        }
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "LetAppsSyncWithDevices" 2
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "LetAppsSyncWithDevices" 0
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "LetAppsSyncWithDevices" 0) -eq 2 }
},

[PSCustomObject]@{
    Group = "Приватність — розширена (HKLM)"
    Name  = "SettingSync — вимкнути всі типи синхронізації"
    Desc  = "DisableSettingSync=2, DisableApplicationSettingSync=2, DisableDesktopThemeSettingSync=2, DisableWebBrowserSettingSync=2 тощо"
    Apply = {
        $ss = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync"
        Set-Reg $ss "DisableSettingSync"              2
        Set-Reg $ss "DisableSettingSyncUserOverride"  1
        Set-Reg $ss "EnableBackupForWin8Apps"         0
        Set-Reg $ss "DisableApplicationSettingSync"   2
        Set-Reg $ss "DisableAppSyncSettingSync"       2
        Set-Reg $ss "DisableDesktopThemeSettingSync"  2
        Set-Reg $ss "DisableStartLayoutSettingSync"   2
        Set-Reg $ss "DisableWebBrowserSettingSync"    2
        Set-Reg $ss "DisableWindowsCredentialSettingSync" 2
        Set-Reg $ss "DisablePasswordSettingSync"      2
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync" "DisableSettingSync"
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync" "DisableSettingSyncUserOverride"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync" "DisableSettingSync" 0) -eq 2 }
},

[PSCustomObject]@{
    Group = "Приватність — розширена (HKLM)"
    Name  = "Windows Hello / Biometrics — повністю вимкнути"
    Desc  = "Biometrics Enabled=0, PassportForWork Enabled=0, AllowDomainPINLogon=0, WbioSrvc → Вимкнено"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics" "Enabled"           0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork" "Enabled"       0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"  "AllowDomainPINLogon" 0
        Set-ServiceDisabled "WbioSrvc"
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics" "Enabled" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork" "Enabled" 1
        Set-ServiceManual "WbioSrvc"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics" "Enabled" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Приватність — розширена (HKLM)"
    Name  = "DRM / Media Foundation / MRT — вимкнути онлайн-компоненти"
    Desc  = "WMDRM DisableOnline=1, EnableFrameServerMode=0, DontOfferThroughWUAU=1, DontReportInfectionInformation=1"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WMDRM"            "DisableOnline"                  1
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows Media Foundation"  "EnableFrameServerMode"           0
        if ([Environment]::Is64BitOperatingSystem) {
            Set-Reg "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows Media Foundation" "EnableFrameServerMode" 0
        }
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\MRT"              "DontOfferThroughWUAU"            1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\MRT"              "DontReportInfectionInformation"  1
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WMDRM"   "DisableOnline"
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\MRT"     "DontOfferThroughWUAU"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\MRT" "DontOfferThroughWUAU" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Приватність — розширена (HKLM)"
    Name  = "RDP — вимкнути (fDenyTSConnections + Terminal Services)"
    Desc  = "fDenyTSConnections=1 (CurrentControlSet + Policies), TermService + UmRdpService → Вимкнено"
    Apply = {
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server"         "fDenyTSConnections" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDenyTSConnections" 1
        Set-ServiceDisabled "TermService"
        Set-ServiceDisabled "UmRdpService"
    }
    Revert = {
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server"         "fDenyTSConnections" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDenyTSConnections" 0
        Set-ServiceManual "TermService"
        Set-ServiceManual "UmRdpService"
    }
    Check = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" "fDenyTSConnections" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Приватність — розширена (HKLM)"
    Name  = "CEIP / AppCompat Telemetry — реєстр DiagTrack + ETL"
    Desc  = "CEIPEnable=0, AITEnable=0, DisableInventory=1, DisablePCA=1, DiagTrack Service Start=4, DiagTrack ETL remove"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows"   "CEIPEnable"                       0
        Set-Reg "HKLM:\SOFTWARE\Microsoft\SQMClient\Windows"            "CEIPEnable"                       0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat"   "AITEnable"                        0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat"   "DisableInventory"                  1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat"   "DisablePCA"                        1
        $dt = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack"
        Set-Reg $dt "Disabled"                                1
        Set-Reg $dt "DisableAutomaticTelemetryKeywordReporting" 1
        Set-Reg $dt "TelemetryServiceDisabled"               1
        Set-Reg $dt "DisableAsimovUpLoad"                    1
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\DiagTrack"        "Start" 4
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice" "Start" 4
        # AppCompat ClientTelemetry
        $act = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry"
        Set-Reg $act "IsCensusDisabled" 1
        Set-Reg $act "DontRetryOnError" 1
        Set-Reg $act "TaskEnableRun"    0
        # Insider / Preview Builds
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" "AllowBuildPreview"      0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" "EnableConfigFlighting"  0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" "HideInsiderPage"        1
        # Видалити ETL файл
        $etl = "$env:ProgramData\Microsoft\Diagnosis\ETLLogs\AutoLogger\AutoLogger-Diagtrack-Listener.etl"
        if (Test-Path $etl) { Remove-Item $etl -Force -ErrorAction SilentlyContinue }
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" "CEIPEnable" 1
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" "AllowBuildPreview"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" "CEIPEnable" 1) -eq 0 }
},

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
    Name  = "Microsoft Accounts — зробити необов'язковими (не блокувати)"
    Desc  = "AllowMicrosoftAccountsToBeOptional=1: MSA не обов'язковий, але автентифікація дозволена. DisableUserAuth прибрано — ламає MS Store та UWP"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppRuntime" "AllowMicrosoftAccountsToBeOptional" 1
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppRuntime" "AllowMicrosoftAccountsToBeOptional"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppRuntime" "AllowMicrosoftAccountsToBeOptional" 0) -eq 1 }
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

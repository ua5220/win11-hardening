<#
.SYNOPSIS
    Аудит: PowerShell, CIS/STIG, заплановані завдання
.NOTES
    Частина Get-HardeningSettings — підвантажується через settings.data.ps1
#>

@(

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 7: POWERSHELL / AUDIT ────────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "PowerShell / Audit"
    Name  = "PowerShell — AllSigned + Module/Script logging + Transcription (ACSC 31)"
    Desc  = "ExecutionPolicy=AllSigned, EnableModuleLogging=1, EnableScriptBlockLogging=1, EnableTranscripting=1"
    Apply = {
        $ps = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell"
        Set-Reg "$ps\ModuleLogging"    "EnableModuleLogging"      1
        Set-Reg "$ps\ModuleLogging\ModuleNames" "*"               "*" "String"
        Set-Reg "$ps\ScriptBlockLogging" "EnableScriptBlockLogging" 1
        Set-Reg "$ps\Transcription"    "EnableTranscripting"      1
        Set-Reg $ps "EnableScripts"    1
        Set-Reg $ps "ExecutionPolicy"  "AllSigned" "String"
    }
    Revert = {
        $ps = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell"
        Set-Reg "$ps\ModuleLogging"    "EnableModuleLogging"      0
        Set-Reg "$ps\ScriptBlockLogging" "EnableScriptBlockLogging" 0
        Set-Reg $ps "ExecutionPolicy"  "Unrestricted" "String"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" "EnableScriptBlockLogging" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "PowerShell / Audit"
    Name  = "Audit Policy — розширений аудит подій (ACSC 24)"
    Desc  = "ProcessCreationIncludeCmdLine, розміри журналів подій, розширений аудит: вхід/об'єкти/політика/система"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" "ProcessCreationIncludeCmdLine_Enabled" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application" "MaxSize" 20480
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security"    "MaxSize" 102400
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System"      "MaxSize" 20480
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\FileSystem" "ClfsMachineSigning" 1
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "SCENoApplyLegacyAuditPolicy"  1
        $subs = @("Process Creation","Process Termination","Logon","Logoff",
                  "Account Lockout","Special Logon","Group Membership",
                  "Other Logon/Logoff Events","User Account Management",
                  "Security Group Management","Audit Policy Change","System Integrity")
        foreach ($s in $subs) {
            auditpol /set /subcategory:"$s" /success:enable /failure:enable 2>$null | Out-Null
        }
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" "ProcessCreationIncludeCmdLine_Enabled" 0
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" "ProcessCreationIncludeCmdLine_Enabled" 0) -eq 1 }
},

[PSCustomObject]@{
    Group    = "Аудит процесів"
    Name     = "Process Creation — включати командний рядок у події (25H2 Baseline)"
    Desc     = "ProcessCreationIncludeCmdLine_Enabled=1: Event ID 4688 містить повний командний рядок — виявлення obfuscated payloads та credential tools"
    MinBuild = 26200
    Apply  = {
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" `
                "ProcessCreationIncludeCmdLine_Enabled" 1
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" `
                "ProcessCreationIncludeCmdLine_Enabled" 0
    }
    Check  = {
        (Get-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" `
                 "ProcessCreationIncludeCmdLine_Enabled" 0) -eq 1
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 39: SCHEDULED TASKS — ТЕЛЕМЕТРІЯ / CEIP ───────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Scheduled Tasks — телеметрія / CEIP"
    Name  = "CEIP tasks — вимкнути (Consolidator / KernelCeipTask / UsbCeip / FamilySafetyMonitor)"
    Desc  = "Завдання Customer Experience Improvement Program → Вимкнено"
    Apply = {
        $ceip = "\Microsoft\Windows\Customer Experience Improvement Program\"
        Disable-Task $ceip "Consolidator"
        Disable-Task $ceip "KernelCeipTask"
        Disable-Task $ceip "UsbCeip"
        Disable-Task "\Microsoft\Windows\Family Safety\" "FamilySafetyMonitor"
        Disable-Task "\Microsoft\Windows\Family Safety\" "FamilySafetyRefreshTask"
    }
    Revert = {
        $ceip = "\Microsoft\Windows\Customer Experience Improvement Program\"
        Enable-Task $ceip "Consolidator"
        Enable-Task $ceip "KernelCeipTask"
        Enable-Task $ceip "UsbCeip"
        Enable-Task "\Microsoft\Windows\Family Safety\" "FamilySafetyMonitor"
    }
    Check = {
        $t = Get-ScheduledTask -TaskPath "\Microsoft\Windows\Customer Experience Improvement Program\" `
                               -TaskName "Consolidator" -ErrorAction SilentlyContinue
        $t -and $t.State -eq 'Disabled'
    }
},

[PSCustomObject]@{
    Group = "Scheduled Tasks — телеметрія / CEIP"
    Name  = "Feedback / Maps / DmClient tasks — вимкнути"
    Desc  = "DmClient, DmClientOnScenarioDownload, MapsToastTask, MapsUpdateTask → Вимкнено"
    Apply = {
        Disable-Task "\Microsoft\Windows\Feedback\Siuf\" "DmClient"
        Disable-Task "\Microsoft\Windows\Feedback\Siuf\" "DmClientOnScenarioDownload"
        Disable-Task "\Microsoft\Windows\Maps\"          "MapsToastTask"
        Disable-Task "\Microsoft\Windows\Maps\"          "MapsUpdateTask"
    }
    Revert = {
        Enable-Task "\Microsoft\Windows\Feedback\Siuf\" "DmClient"
        Enable-Task "\Microsoft\Windows\Feedback\Siuf\" "DmClientOnScenarioDownload"
        Enable-Task "\Microsoft\Windows\Maps\"          "MapsToastTask"
        Enable-Task "\Microsoft\Windows\Maps\"          "MapsUpdateTask"
    }
    Check = {
        $t = Get-ScheduledTask -TaskPath "\Microsoft\Windows\Feedback\Siuf\" `
                               -TaskName "DmClient" -ErrorAction SilentlyContinue
        $t -and $t.State -eq 'Disabled'
    }
},


# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 45: РОЗШИРЕНИЙ АУДИТ (CIS / STIG) ──────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Розширений аудит (CIS / STIG)"
    Name  = "Audit — Account Logon та Group Management (CIS)"
    Desc  = "Credential Validation, Application/Security/Distribution Group Management — успіх+невдача"
    Apply = {
        $subs = @("Credential Validation","Application Group Management",
                  "Security Group Management","Distribution Group Management",
                  "Computer Account Management","Other Account Management Events")
        foreach ($s in $subs) {
            auditpol /set /subcategory:"$s" /success:enable /failure:enable 2>$null | Out-Null
        }
    }
    Revert = {
        $subs = @("Credential Validation","Application Group Management",
                  "Security Group Management","Distribution Group Management",
                  "Computer Account Management","Other Account Management Events")
        foreach ($s in $subs) {
            auditpol /set /subcategory:"$s" /success:disable /failure:disable 2>$null | Out-Null
        }
    }
    Check = {
        $out = auditpol /get /subcategory:"Credential Validation" 2>$null
        $out -match 'Success and Failure'
    }
},

[PSCustomObject]@{
    Group = "Розширений аудит (CIS / STIG)"
    Name  = "Audit — Object Access та Privilege Use (STIG)"
    Desc  = "File System, Registry, Handle Manipulation, SAM, Sensitive/Non-Sensitive Privilege Use — аудит доступу до об'єктів та використання привілеїв"
    Apply = {
        $subs = @("File System","Registry","Handle Manipulation","SAM",
                  "Sensitive Privilege Use","Non Sensitive Privilege Use",
                  "Filtering Platform Packet Drop","Filtering Platform Connection")
        foreach ($s in $subs) {
            auditpol /set /subcategory:"$s" /success:enable /failure:enable 2>$null | Out-Null
        }
    }
    Revert = {
        $subs = @("File System","Registry","Handle Manipulation","SAM",
                  "Sensitive Privilege Use","Non Sensitive Privilege Use",
                  "Filtering Platform Packet Drop","Filtering Platform Connection")
        foreach ($s in $subs) {
            auditpol /set /subcategory:"$s" /success:disable /failure:disable 2>$null | Out-Null
        }
    }
    Check = {
        $out = auditpol /get /subcategory:"Sensitive Privilege Use" 2>$null
        $out -match 'Success and Failure'
    }
},

[PSCustomObject]@{
    Group = "Розширений аудит (CIS / STIG)"
    Name  = "Event Log — розширені розміри (Security 200MB, інші 50MB)"
    Desc  = "Security=204800KB, Application/System/Setup=51200KB, PowerShell Operational=51200KB"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security"    "MaxSize" 204800
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application" "MaxSize" 51200
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System"      "MaxSize" 51200
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Setup"       "MaxSize" 51200
        wevtutil sl "Microsoft-Windows-PowerShell/Operational" /ms:52428800 2>$null
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security"    "MaxSize" 20480
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application" "MaxSize" 20480
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System"      "MaxSize" 20480
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security" "MaxSize" 20480) -ge 204800 }
},

[PSCustomObject]@{
    Group = "Розширений аудит (CIS / STIG)"
    Name  = "Audit — Logon/Logoff розширений + NTLM аудит"
    Desc  = "Network Policy Server, IPsec Main/Quick/Extended Mode, Detailed Tracking, NTLM Audit — розширений аудит входу та NTLM-трафіку"
    Apply = {
        $subs = @("Network Policy Server","IPsec Main Mode","IPsec Quick Mode",
                  "IPsec Extended Mode","Detailed File Share","DPAPI Activity",
                  "RPC Events","Token Right Adjusted Events")
        foreach ($s in $subs) {
            auditpol /set /subcategory:"$s" /success:enable /failure:enable 2>$null | Out-Null
        }
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "AuditReceivingNTLMTraffic" 2
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "RestrictSendingNTLMTraffic" 1
    }
    Revert = {
        Remove-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "AuditReceivingNTLMTraffic"
        Remove-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "RestrictSendingNTLMTraffic"
    }
    Check = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "AuditReceivingNTLMTraffic" 0) -eq 2 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 51: SCHEDULED TASKS — РОЗШИРЕНЕ ВІДКЛЮЧЕННЯ ─────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Scheduled Tasks — розширене відключення"
    Name  = "Задачі телеметрії v5 — AppExperience / Autochk / DiskDiagnostic / NetTrace / Clip / PI"
    Desc  = "MareBackup, StartupAppTask, Proxy (Autochk), DiskDiagnosticDataCollector/Resolver, GatherNetworkInfo, SmartScreenSpecific (AppID), License Validation (Clip), Sqm-Tasks (PI)"
    Apply = {
        $tasks = @(
            @('\Microsoft\Windows\Application Experience\',                  'MareBackup'),
            @('\Microsoft\Windows\Application Experience\',                  'StartupAppTask'),
            @('\Microsoft\Windows\Autochk\',                                 'Proxy'),
            @('\Microsoft\Windows\DiskDiagnostic\',                          'Microsoft-Windows-DiskDiagnosticDataCollector'),
            @('\Microsoft\Windows\DiskDiagnostic\',                          'Microsoft-Windows-DiskDiagnosticResolver'),
            @('\Microsoft\Windows\NetTrace\',                                 'GatherNetworkInfo'),
            @('\Microsoft\Windows\AppID\',                                    'SmartScreenSpecific'),
            @('\Microsoft\Windows\Clip\',                                     'License Validation'),
            @('\Microsoft\Windows\PI\',                                       'Sqm-Tasks'),
            @('\Microsoft\Windows\Maintenance\',                              'WinSAT')
        )
        foreach ($t in $tasks) { Disable-Task $t[0] $t[1] }
    }
    Revert = {
        $tasks = @(
            @('\Microsoft\Windows\Application Experience\',                  'MareBackup'),
            @('\Microsoft\Windows\Application Experience\',                  'StartupAppTask'),
            @('\Microsoft\Windows\Autochk\',                                 'Proxy'),
            @('\Microsoft\Windows\DiskDiagnostic\',                          'Microsoft-Windows-DiskDiagnosticDataCollector'),
            @('\Microsoft\Windows\DiskDiagnostic\',                          'Microsoft-Windows-DiskDiagnosticResolver'),
            @('\Microsoft\Windows\NetTrace\',                                 'GatherNetworkInfo'),
            @('\Microsoft\Windows\AppID\',                                    'SmartScreenSpecific'),
            @('\Microsoft\Windows\Clip\',                                     'License Validation'),
            @('\Microsoft\Windows\PI\',                                       'Sqm-Tasks'),
            @('\Microsoft\Windows\Maintenance\',                              'WinSAT')
        )
        foreach ($t in $tasks) { Enable-Task $t[0] $t[1] }
    }
    Check = {
        $t = Get-ScheduledTask -TaskPath '\Microsoft\Windows\Autochk\' `
                               -TaskName 'Proxy' -ErrorAction SilentlyContinue
        $t -and $t.State -eq 'Disabled'
    }
},

[PSCustomObject]@{
    Group = "Scheduled Tasks — розширене відключення"
    Name  = "Задачі телеметрії v5 — WlanSvc / WCM / Shell / RemoteAssistance / SoftwareProtection / SpacePort"
    Desc  = "CDSSync (WlanSvc), WiFiTask (WCM), FamilySafetyMonitor/Refresh, RemoteAssistanceTask, SvcRestartTask*, SpaceAgentTask"
    Apply = {
        $tasks = @(
            @('\Microsoft\Windows\WlanSvc\',                 'CDSSync'),
            @('\Microsoft\Windows\WCM\',                     'WiFiTask'),
            @('\Microsoft\Windows\Shell\',                   'FamilySafetyMonitor'),
            @('\Microsoft\Windows\Shell\',                   'FamilySafetyRefreshTask'),
            @('\Microsoft\Windows\RemoteAssistance\',        'RemoteAssistanceTask'),
            @('\Microsoft\Windows\SoftwareProtectionPlatform\', 'SvcRestartTask'),
            @('\Microsoft\Windows\SoftwareProtectionPlatform\', 'SvcRestartTaskNetwork'),
            @('\Microsoft\Windows\SoftwareProtectionPlatform\', 'SvcRestartTaskLogon'),
            @('\Microsoft\Windows\SpacePort\',               'SpaceAgentTask'),
            @('\Microsoft\Windows\SettingSync\',             'BackgroundUploadTask'),
            @('\Microsoft\Windows\SettingSync\',             'NetworkStateChangeTask'),
            @('\Microsoft\Windows\Work Folders\',            'Work Folders Logon Synchronization'),
            @('\Microsoft\XblGameSave\',                     'XblGameSaveTask'),
            @('\Microsoft\XblGameSave\',                     'XblGameSaveTaskLogon')
        )
        foreach ($t in $tasks) { Disable-Task $t[0] $t[1] }
    }
    Revert = {
        $tasks = @(
            @('\Microsoft\Windows\WlanSvc\',                 'CDSSync'),
            @('\Microsoft\Windows\WCM\',                     'WiFiTask'),
            @('\Microsoft\Windows\Shell\',                   'FamilySafetyMonitor'),
            @('\Microsoft\Windows\Shell\',                   'FamilySafetyRefreshTask'),
            @('\Microsoft\Windows\RemoteAssistance\',        'RemoteAssistanceTask'),
            @('\Microsoft\Windows\SpacePort\',               'SpaceAgentTask'),
            @('\Microsoft\Windows\Work Folders\',            'Work Folders Logon Synchronization'),
            @('\Microsoft\XblGameSave\',                     'XblGameSaveTask'),
            @('\Microsoft\XblGameSave\',                     'XblGameSaveTaskLogon')
        )
        foreach ($t in $tasks) { Enable-Task $t[0] $t[1] }
    }
    Check = {
        $t = Get-ScheduledTask -TaskPath '\Microsoft\Windows\WlanSvc\' `
                               -TaskName 'CDSSync' -ErrorAction SilentlyContinue
        $t -and $t.State -eq 'Disabled'
    }
},

[PSCustomObject]@{
    Group = "Scheduled Tasks — розширене відключення"
    Name  = "Задачі телеметрії — Office / Device Census / Cloud Experience"
    Desc  = "Вимкнути задачі: OfficeTelemetryAgentFallBack, Proxy, Consolidator, DeviceCensus, CreateObjectTask"
    Apply = {
        Disable-Task "\Microsoft\Office\OfficeTelemetryAgentFallBack2016\" "OfficeTelemetryAgentFallBack2016"
        Disable-Task "\Microsoft\Office\OfficeTelemetryAgentLogOn2016\"    "OfficeTelemetryAgentLogOn2016"
        Disable-Task "\Microsoft\Windows\Device Information\"     "Device"
        Disable-Task "\Microsoft\Windows\CloudExperienceHost\"    "CreateObjectTask"
        Disable-Task "\Microsoft\Windows\License Manager\"        "TempSignedLicenseExchange"
    }
    Revert = {
        Enable-Task "\Microsoft\Office\OfficeTelemetryAgentFallBack2016\" "OfficeTelemetryAgentFallBack2016"
        Enable-Task "\Microsoft\Office\OfficeTelemetryAgentLogOn2016\"    "OfficeTelemetryAgentLogOn2016"
        Enable-Task "\Microsoft\Windows\Device Information\"     "Device"
        Enable-Task "\Microsoft\Windows\CloudExperienceHost\"    "CreateObjectTask"
        Enable-Task "\Microsoft\Windows\License Manager\"        "TempSignedLicenseExchange"
    }
    Check = {
        $t = Get-ScheduledTask -TaskPath "\Microsoft\Windows\Device Information\" `
                               -TaskName "Device" -ErrorAction SilentlyContinue
        $t -and $t.State -eq 'Disabled'
    }
},

[PSCustomObject]@{
    Group = "Scheduled Tasks — розширене відключення"
    Name  = "Фонові задачі — Defrag / WDI / Memory Diagnostic"
    Desc  = "Вимкнути ScheduledDefrag, WDI ResolutionHost, MemoryDiagnostic RunFullMemoryDiagnostic"
    Apply = {
        Disable-Task "\Microsoft\Windows\Defrag\"                  "ScheduledDefrag"
        Disable-Task "\Microsoft\Windows\WDI\"                     "ResolutionHost"
        Disable-Task "\Microsoft\Windows\MemoryDiagnostic\"        "RunFullMemoryDiagnostic"
        Disable-Task "\Microsoft\Windows\Power Efficiency Diagnostics\" "AnalyzeSystem"
    }
    Revert = {
        Enable-Task "\Microsoft\Windows\Defrag\"                  "ScheduledDefrag"
        Enable-Task "\Microsoft\Windows\WDI\"                     "ResolutionHost"
        Enable-Task "\Microsoft\Windows\MemoryDiagnostic\"        "RunFullMemoryDiagnostic"
        Enable-Task "\Microsoft\Windows\Power Efficiency Diagnostics\" "AnalyzeSystem"
    }
    Check = {
        $t = Get-ScheduledTask -TaskPath "\Microsoft\Windows\Defrag\" `
                               -TaskName "ScheduledDefrag" -ErrorAction SilentlyContinue
        $t -and $t.State -eq 'Disabled'
    }
}

)

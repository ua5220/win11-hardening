<#
.SYNOPSIS
    Політики: MSS Legacy, принтери, RPC, Group Policy, автозавантаження
.NOTES
    Частина Get-HardeningSettings — підвантажується через settings.data.ps1
#>

@(

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 15: MSS LEGACY ─────────────────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "MSS Legacy"
    Name  = "IP Source Routing — максимальний захист (ACSC)"
    Desc  = "DisableIPSourceRouting=2 (IPv4+IPv6): повністю вимкнути джерельну маршрутизацію для захисту від підробки"
    Apply = {
        $tcp = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
        $tcp6 = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"
        Set-Reg $tcp  "DisableIPSourceRouting" 2
        Set-Reg $tcp6 "DisableIPSourceRouting" 2
    }
    Revert = {
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"  "DisableIPSourceRouting" 1
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisableIPSourceRouting" 1
    }
    Check = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "DisableIPSourceRouting" 0) -eq 2 }
},

[PSCustomObject]@{
    Group = "MSS Legacy"
    Name  = "ICMP Redirects — заборонити перевизначення OSPF маршрутів (ACSC)"
    Desc  = "EnableICMPRedirect=0: не дозволяти ICMP-перенаправленням перевизначати OSPF маршрути"
    Apply  = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "EnableICMPRedirect" 0 }
    Revert = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "EnableICMPRedirect" 1 }
    Check  = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "EnableICMPRedirect" 1) -eq 0 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 17: ПРИНТЕРИ — HARDENING ───────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Принтери — Hardening"
    Name  = "Принтери RPC/IPPS/TLS — захист (ACSC)"
    Desc  = "RPC через TCP, Redirection Guard, IPPS обов'язковий, політика TLS, підпис драйверів, ліміт файлів черги"
    Apply = {
        $pr = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers"
        # RPC packet level privacy
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" "RpcUseNamedPipeProtocol" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" "RpcAuthentication"       0
        # Configure RPC connection settings (outgoing)
        Set-Reg "$pr\RPC" "RpcProtocol" 6
        Set-Reg "$pr\RPC" "ForceKerberosForRpc" 0
        # Configure RPC listener settings
        Set-Reg "$pr\RPC" "RpcListenerProtocol"  6
        Set-Reg "$pr\RPC" "RpcListenerAuth"      1
        # RPC over TCP port = 0
        Set-Reg "$pr\RPC" "RpcTcpPort" 0
        # IPPS required for IPP printers
        Set-Reg "$pr" "RequireIPPS" 1
        # TLS/SSL security policy
        Set-Reg "$pr" "IPPTLSPolicy" 1
        # Redirection Guard enabled
        Set-Reg "$pr" "RedirectionGuardPolicy" 1
        # Driver signature validation
        Set-Reg "$pr" "PrintDriverSignatureValidation" 1
        # Queue-specific files = Color profiles only
        Set-Reg "$pr" "QueueSpecificFiles" 1
        # Disable HTTP print driver download
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" "DisableHTTPPrinting" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableHTTPPrinting"      1
        # MS Security Guide: RPC packet level privacy
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Rpc" "EnableAuthEpResolution" 1
        # Restrict printer driver file copying (private-secure-windows)
        Set-Reg "$pr" "CopyFilesPolicy" 1
        # Enforce encryption for Print Spooler RPC communications
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Print" "RpcAuthnLevelPrivacyEnabled" 1
    }
    Revert = {
        $pr = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers"
        Remove-RegValue "$pr" "RequireIPPS"
        Remove-RegValue "$pr" "IPPTLSPolicy"
        Remove-RegValue "$pr" "RedirectionGuardPolicy"
        Remove-RegValue "$pr" "CopyFilesPolicy"
        Remove-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Print" "RpcAuthnLevelPrivacyEnabled"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" "RequireIPPS" 0) -eq 1 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 18: REMOTE ASSISTANCE / RPC ────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Remote Assistance / RPC"
    Name  = "Remote Assistance — вимкнути Offer та Solicited (ACSC)"
    Desc  = "fAllowUnsolicited=0, fAllowToGetHelp=0: заборонити пропоновану та запитувану віддалену допомогу"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fAllowUnsolicited" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fAllowToGetHelp"   0
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fAllowToGetHelp" 1
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fAllowToGetHelp" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Remote Assistance / RPC"
    Name  = "RPC — обмежити неавтентифікованих клієнтів (ACSC)"
    Desc  = "RestrictRemoteClients=1: дозволити лише автентифіковані RPC з'єднання"
    Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Rpc" "RestrictRemoteClients" 1 }
    Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Rpc" "RestrictRemoteClients" 0 }
    Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Rpc" "RestrictRemoteClients" 0) -eq 1 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 19: GROUP POLICY PROCESSING ────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Group Policy Processing"
    Name  = "Registry/Security policy — примусове оновлення (ACSC)"
    Desc  = "NoBackgroundPolicy=0, NoGPOListChanges=0: завжди обробляти GP навіть без змін"
    Apply = {
        # Registry policy processing
        $rp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}"
        Set-Reg $rp "NoBackgroundPolicy"  0
        Set-Reg $rp "NoGPOListChanges"    0
        # Security policy processing
        $sp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{827D319E-6EAC-11D2-A4EA-00C04F79F83A}"
        Set-Reg $sp "NoBackgroundPolicy"  0
        Set-Reg $sp "NoGPOListChanges"    0
    }
    Revert = {
        $rp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}"
        Set-Reg $rp "NoGPOListChanges" 1
        $sp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{827D319E-6EAC-11D2-A4EA-00C04F79F83A}"
        Set-Reg $sp "NoGPOListChanges" 1
    }
    Check = {
        (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}" "NoGPOListChanges" 1) -eq 0
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 20: STARTUP / LOGON PROGRAMS ───────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Startup / Logon Programs"
    Name  = "Вимкнути legacy run list та run once list (ACSC)"
    Desc  = "DisableLocalMachineRunOnce=1, DisableLocalMachineRun=1: заборонити автозапуск застарілих програм"
    Apply = {
        $ep = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
        Set-Reg $ep "DisableLocalMachineRun"      1
        Set-Reg $ep "DisableLocalMachineRunOnce"  1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableLogonBackgroundImage" 0
    }
    Revert = {
        $ep = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
        Set-Reg $ep "DisableLocalMachineRun"      0
        Set-Reg $ep "DisableLocalMachineRunOnce"  0
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "DisableLocalMachineRun" 0) -eq 1 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 17: OFFICE / MSHTML / ACTIVEX HARDENING ──────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Office / MSHTML Hardening"
    Name  = "ActiveX обмеження для MSHTML/IE (CVE-2025-30397)"
    Desc  = @"
FEATURE_RESTRICT_ACTIVEXINSTALL=1 для explorer.exe та iexplore.exe: заборонити інсталяцію ActiveX-компонентів через MSHTML.
CVE-2025-30397: scripting-engine exploit через MSHTML/ActiveX.
GPO: Computer Configuration > Administrative Templates > Windows Components > Internet Explorer
  → "Restrict ActiveX Install" = Enabled (для explorer.exe та iexplore.exe)
"@
    Apply = {
        $feat = "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_RESTRICT_ACTIVEXINSTALL"
        Set-Reg $feat "explorer.exe"  1
        Set-Reg $feat "iexplore.exe"  1
    }
    Revert = {
        $feat = "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_RESTRICT_ACTIVEXINSTALL"
        Remove-RegValue $feat "explorer.exe"
        Remove-RegValue $feat "iexplore.exe"
    }
    Check = {
        $feat = "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_RESTRICT_ACTIVEXINSTALL"
        (Get-Reg $feat "explorer.exe" 0) -eq 1
    }
},

[PSCustomObject]@{
    Group = "Office / MSHTML Hardening"
    Name  = "Office 365/2016+ — заблокувати макроси з інтернету + Protected View"
    Desc  = @"
blockcontentexecutionfrominternet=1, VBAWarnings=4: заблокувати VBA-макроси
з інтернету для Word, Excel, PowerPoint (Office 16.0+).
Protected View увімкнено для вкладень, інтернет-файлів та ненадійних розташувань.
Захист від CVE-2026-21513, CVE-2026-21514, Office macro атак.
GPO: User Configuration > Administrative Templates > Microsoft Word/Excel/PowerPoint 2016 >
  Word Options > Security > Trust Center
  → "Block macros from running in Office files from the Internet" = Enabled
  → "VBA Macro Notification Settings" = Disable all with notification
"@
    Apply = {
        foreach ($app in @("Word", "Excel", "PowerPoint")) {
            $sec = "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\$app\Security"
            Set-Reg $sec "blockcontentexecutionfrominternet" 1
            Set-Reg $sec "VBAWarnings"                      4

            $pv = "$sec\ProtectedView"
            Set-Reg $pv "DisableAttachmentsInPV"      0
            Set-Reg $pv "DisableInternetFilesInPV"    0
            Set-Reg $pv "DisableUnsafeLocationsInPV"  0
        }
    }
    Revert = {
        foreach ($app in @("Word", "Excel", "PowerPoint")) {
            $sec = "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\$app\Security"
            Remove-RegValue $sec "blockcontentexecutionfrominternet"
            Remove-RegValue $sec "VBAWarnings"

            $pv = "$sec\ProtectedView"
            Remove-RegValue $pv "DisableAttachmentsInPV"
            Remove-RegValue $pv "DisableInternetFilesInPV"
            Remove-RegValue $pv "DisableUnsafeLocationsInPV"
        }
    }
    Check = {
        $sec = "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Word\Security"
        (Get-Reg $sec "blockcontentexecutionfrominternet" 0) -eq 1
    }
}

)

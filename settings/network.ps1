<#
.SYNOPSIS
    Мережа: безпека з'єднань, брандмауер, протоколи, NTLM, TCP/IP стек
.NOTES
    Частина Get-HardeningSettings — підвантажується через settings.data.ps1
#>

@(

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 5: МЕРЕЖЕВА БЕЗПЕКА (ACSC 26) ────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Мережева безпека"
    Name  = "NTLMv2 тільки, заборонити LM та NTLM (ACSC 26)"
    Desc  = "LmCompatibilityLevel=5, NTLMMinClientSec/ServerSec=537395200, NoLMHash=1"
    Apply = {
        $lsa = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
        Set-Reg $lsa "LmCompatibilityLevel" 5
        Set-Reg $lsa "NoLMHash"             1
        Set-Reg "$lsa\MSV1_0" "NTLMMinClientSec" 537395200
        Set-Reg "$lsa\MSV1_0" "NTLMMinServerSec" 537395200
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters" "SupportedEncryptionTypes" 24
    }
    Revert = {
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LmCompatibilityLevel" 3
    }
    Check = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LmCompatibilityLevel" 0) -eq 5 }
},

[PSCustomObject]@{
    Group = "Мережева безпека"
    Name  = "SMB v1 вимкнути + SMB Signing (ACSC 26)"
    Desc  = "mrxsmb10 Start=4, SMB1=0, RequireSecuritySignature=1 (клієнт і сервер)"
    Apply = {
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\mrxsmb10" "Start" 4
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "SMB1"                    0
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" "RequireSecuritySignature" 1
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" "EnablePlainTextPassword"  0
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"      "RequireSecuritySignature" 1
    }
    Revert = {
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\mrxsmb10" "Start" 3
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "SMB1" 1
    }
    Check = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "SMB1" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Мережева безпека"
    Name  = "DMA-захист — Заблокувати FireWire/Thunderbolt (ACSC 26)"
    Desc  = "DeviceEnumerationPolicy=0, заблокувати PCI CC_0C0010 та CC_0C0A"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceIDs" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs" "1" "PCI\CC_0C0010" "String"
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs" "2" "PCI\CC_0C0A"   "String"
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceIDs" 0
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy" -1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Мережева безпека"
    Name  = "Anonymous connections — заборонити (ACSC 21)"
    Desc  = "RestrictAnonymous=1, RestrictAnonymousSAM=1, EveryoneIncludesAnonymous=0, InsecureGuestAuth=0"
    Apply = {
        $lsa = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AllowInsecureGuestAuth" 0
        Set-Reg $lsa "AnonymousNameLookup"    0
        Set-Reg $lsa "RestrictAnonymousSAM"   1
        Set-Reg $lsa "RestrictAnonymous"       1
        Set-Reg $lsa "EveryoneIncludesAnonymous" 0
        Set-Reg $lsa "RestrictRemoteSAM"      "O:BAG:BAD:(A;;RC;;;BA)" "String"
        Set-Reg $lsa "TurnOffAnonymousBlock"  1
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "RestrictNullSessAccess" 1
    }
    Revert = {
        $lsa = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
        Set-Reg $lsa "RestrictAnonymous"    0
        Set-Reg $lsa "RestrictAnonymousSAM" 0
    }
    Check = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RestrictAnonymous" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Мережева безпека"
    Name  = "WinRM — вимкнути Basic auth та нешифрований трафік (ACSC 29)"
    Desc  = "WinRM Client/Service: AllowBasic=0, AllowUnencryptedTraffic=0, DisableRunAs=1"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client"  "AllowBasic"             0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client"  "AllowUnencryptedTraffic" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client"  "AllowDigest"            0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" "AllowBasic"             0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" "AllowUnencryptedTraffic" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" "DisableRunAs"           1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\WinRS" "AllowRemoteShellAccess" 0
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client"  "AllowBasic" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" "AllowBasic" 1
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client" "AllowBasic" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Мережева безпека"
    Name  = "Remote Desktop — NLA + SSL + заборона збереження паролів (ACSC 29)"
    Desc  = "UserAuthentication=1, SecurityLayer=2, MinEncryptionLevel=3, DisablePasswordSaving=1, fDisableClip=1"
    Apply = {
        $ts = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
        Set-Reg $ts "fAllowUnsolicited"     0
        Set-Reg $ts "fAllowToGetHelp"       0
        Set-Reg $ts "AllowEncryptionOracle" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation" "AllowProtectedCreds" 1
        Set-Reg $ts "AuthenticationLevel"   1
        Set-Reg $ts "DisablePasswordSaving" 1
        Set-Reg $ts "fPromptForPassword"    1
        Set-Reg $ts "fEncryptRPCTraffic"    1
        Set-Reg $ts "SecurityLayer"         2
        Set-Reg $ts "UserAuthentication"    1
        Set-Reg $ts "MinEncryptionLevel"    3
        Set-Reg $ts "fDisableClip"          1
        Set-Reg $ts "fDisableCdm"           1
    }
    Revert = {
        $ts = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
        Set-Reg $ts "UserAuthentication" 0
        Set-Reg $ts "SecurityLayer"      0
        Set-Reg $ts "fDisableClip"       0
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "UserAuthentication" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Мережева безпека"
    Name  = "LLMNR вимкнути, RPC restricted (ACSC 32)"
    Desc  = "EnableMulticast=0, RestrictRemoteClients=1, Захищені UNC-шляхи SYSVOL/NETLOGON"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableMulticast" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Rpc"       "RestrictRemoteClients" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths" "\\*\SYSVOL"   "RequireMutualAuthentication=1, RequireIntegrity=1" "String"
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths" "\\*\NETLOGON" "RequireMutualAuthentication=1, RequireIntegrity=1" "String"
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableMulticast" 1
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableMulticast" 1) -eq 0 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 23: NTLM LOGGING / PKU2U / LDAP ───────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "NTLM / PKU2U / LDAP"
    Name  = "NTLM розширене журналювання + Netlogon (ACSC)"
    Desc  = "AuditNTLMInDomain=7, AuditReceivingNTLMTraffic=2: розширений аудит NTLM"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\Netlogon\Parameters" "AuditNTLMInDomain" 7
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "AuditReceivingNTLMTraffic" 2
    }
    Revert = {
        Remove-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "AuditReceivingNTLMTraffic"
    }
    Check = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "AuditReceivingNTLMTraffic" 0) -eq 2 }
},

[PSCustomObject]@{
    Group = "NTLM / PKU2U / LDAP"
    Name  = "PKU2U вимкнути + LDAP client signing (ACSC)"
    Desc  = "AllowOnlineID=0 (для локального AD), LDAPClientIntegrity=1 (узгодження підпису)"
    Apply = {
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\pku2u" "AllowOnlineID" 0
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"       "LDAPClientIntegrity" 1
    }
    Revert = {
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\pku2u" "AllowOnlineID" 1
    }
    Check = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\pku2u" "AllowOnlineID" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "NTLM / PKU2U / LDAP"
    Name  = "System Objects — посилити дозволи символьних посилань (ACSC)"
    Desc  = "ProtectionMode=1: посилити стандартні дозволи для внутрішніх системних об'єктів"
    Apply  = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "ProtectionMode" 1 }
    Revert = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "ProtectionMode" 0 }
    Check  = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "ProtectionMode" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "NTLM / PKU2U / LDAP"
    Name  = "Аудит підтримки SPN SMB-клієнта (ACSC)"
    Desc  = "AuditSmb1Access=1: аудит спроб доступу через SMB1 SPN"
    Apply  = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "AuditSmb1Access" 1 }
    Revert = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "AuditSmb1Access" 0 }
    Check  = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "AuditSmb1Access" 0) -eq 1 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 36: IPv6 / NetBIOS / WPAD / TCP-IP ────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Мережева приватність / IPv6 / NetBIOS"
    Name  = "IPv6 — повністю вимкнути (DisabledComponents=0xFF)"
    Desc  = "DisabledComponents=0xFF: відключити всі IPv6-компоненти у стеку Tcpip6 (окрім loopback)"
    Apply = {
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" 0xFF
    }
    Revert = {
        Remove-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents"
    }
    Check = {
        (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" 0) -eq 0xFF
    }
},

[PSCustomObject]@{
    Group = "Мережева приватність / IPv6 / NetBIOS"
    Name  = "NetBIOS over TCP/IP — вимкнути на всіх адаптерах (NetbiosOptions=2)"
    Desc  = "NetbiosOptions=2 для кожного інтерфейсу в NetBT\Parameters\Interfaces; EnableLmHosts=0"
    Apply = {
        $root = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters"
        Set-Reg $root "EnableLmHosts"          0
        Set-Reg $root "NoNameReleaseOnDemand"  1
        Get-ChildItem "$root\Interfaces" -ErrorAction SilentlyContinue | ForEach-Object {
            Set-ItemProperty -Path $_.PSPath -Name "NetbiosOptions" -Value 2 -ErrorAction SilentlyContinue
        }
    }
    Revert = {
        $root = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters"
        Set-Reg $root "EnableLmHosts" 1
        Get-ChildItem "$root\Interfaces" -ErrorAction SilentlyContinue | ForEach-Object {
            Set-ItemProperty -Path $_.PSPath -Name "NetbiosOptions" -Value 0 -ErrorAction SilentlyContinue
        }
    }
    Check = {
        $first = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces" -ErrorAction SilentlyContinue |
                 Select-Object -First 1
        if ($first) {
            (Get-ItemProperty -Path $first.PSPath -ErrorAction SilentlyContinue).NetbiosOptions -eq 2
        } else { $false }
    }
},

[PSCustomObject]@{
    Group = "Мережева приватність / IPv6 / NetBIOS"
    Name  = "DNS Client — вимкнути NetBIOS name resolution (EnableNetbios=2)"
    Desc  = "Забороняє NetBIOS через DNS Client policy (private-secure-windows)"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableNetbios" 2
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableNetbios"
    }
    Check = {
        (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableNetbios" 0) -eq 2
    }
},

[PSCustomObject]@{
    Group = "Мережева приватність / IPv6 / NetBIOS"
    Name  = "WPAD / Auto-Detect Proxy — вимкнути"
    Desc  = "HKCU AutoDetect=0 + WinHttpAutoProxySvc Вимкнено: заборонити автовиявлення проксі"
    Apply = {
        Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" "AutoDetect" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings" `
                "EnableAutoProxyResultCache" 0
        Set-ServiceDisabled "WinHttpAutoProxySvc"
    }
    Revert = {
        Remove-RegValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" "AutoDetect"
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings" `
                        "EnableAutoProxyResultCache"
        Set-ServiceManual "WinHttpAutoProxySvc"
    }
    Check = {
        (Get-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" "AutoDetect" 1) -eq 0
    }
},

[PSCustomObject]@{
    Group = "Мережева приватність / IPv6 / NetBIOS"
    Name  = "TCP/IP hardening — DeadGW / RouterDiscovery / TcpMaxDataRetransmissions"
    Desc  = "EnableDeadGWDetect=0, PerformRouterDiscovery=0, TcpMaxDataRetransmissions=3"
    Apply = {
        $tcp = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
        Set-Reg $tcp "EnableDeadGWDetect"        0
        Set-Reg $tcp "PerformRouterDiscovery"    0
        Set-Reg $tcp "TcpMaxDataRetransmissions" 3
    }
    Revert = {
        $tcp = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
        Remove-RegValue $tcp "EnableDeadGWDetect"
        Remove-RegValue $tcp "PerformRouterDiscovery"
        Remove-RegValue $tcp "TcpMaxDataRetransmissions"
    }
    Check = {
        (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "EnableDeadGWDetect" 1) -eq 0
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 40: TCP/IP СТЕК — ЗАХИСТ ВІД АТАК ──────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "TCP/IP стек — захист від атак"
    Name  = "Захист від SYN Flood (SynAttackProtect + обмеження з'єднань)"
    Desc  = "SynAttackProtect=2, TcpMaxHalfOpen=25, TcpMaxHalfOpenRetried=20, TcpMaxSynRetransmissions=1"
    Apply = {
        $tcp = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
        Set-Reg $tcp "SynAttackProtect"          2
        Set-Reg $tcp "TcpMaxHalfOpen"            25
        Set-Reg $tcp "TcpMaxHalfOpenRetried"     20
        Set-Reg $tcp "TcpMaxSynRetransmissions"  1
    }
    Revert = {
        $tcp = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
        Remove-RegValue $tcp "SynAttackProtect"
        Remove-RegValue $tcp "TcpMaxHalfOpen"
        Remove-RegValue $tcp "TcpMaxHalfOpenRetried"
        Remove-RegValue $tcp "TcpMaxSynRetransmissions"
    }
    Check = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "SynAttackProtect" 0) -eq 2 }
},

[PSCustomObject]@{
    Group = "TCP/IP стек — захист від атак"
    Name  = "TCP Timestamps вимкнути (захист від визначення ОС)"
    Desc  = "Tcp1323Opts=0: вимкнути TCP timestamps щоб запобігти визначенню ОС через аналіз зміщення годинника"
    Apply = {
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "Tcp1323Opts" 0
        netsh int tcp set global timestamps=disabled 2>$null | Out-Null
    }
    Revert = {
        Remove-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "Tcp1323Opts"
        netsh int tcp set global timestamps=enabled 2>$null | Out-Null
    }
    Check = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "Tcp1323Opts" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "TCP/IP стек — захист від атак"
    Name  = "TIME_WAIT скорочення + розширений діапазон портів"
    Desc  = "TcpTimedWaitDelay=30, MaxUserPort=61000: швидше звільнення портів + більший діапазон ефемерних портів"
    Apply = {
        $tcp = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
        Set-Reg $tcp "TcpTimedWaitDelay" 30
        Set-Reg $tcp "MaxUserPort"       61000
    }
    Revert = {
        $tcp = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
        Remove-RegValue $tcp "TcpTimedWaitDelay"
        Remove-RegValue $tcp "MaxUserPort"
    }
    Check = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "TcpTimedWaitDelay" 240) -eq 30 }
},

[PSCustomObject]@{
    Group = "TCP/IP стек — захист від атак"
    Name  = "PMTU Discovery вимкнути + виявлення «чорних дір»"
    Desc  = "EnablePMTUDiscovery=0, EnablePMTUBHDetect=1: відключити MTU на основі ICMP, увімкнути відновлення після «чорних дір»"
    Apply = {
        $tcp = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
        Set-Reg $tcp "EnablePMTUDiscovery" 0
        Set-Reg $tcp "EnablePMTUBHDetect"  1
    }
    Revert = {
        $tcp = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
        Set-Reg $tcp "EnablePMTUDiscovery" 1
        Remove-RegValue $tcp "EnablePMTUBHDetect"
    }
    Check = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "EnablePMTUDiscovery" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "TCP/IP стек — захист від атак"
    Name  = "Захист від ARP Spoofing (WeakHost вимкнути)"
    Desc  = "WeakHostSend=Вимкнено, WeakHostReceive=Вимкнено на всіх IPv4 інтерфейсах"
    Apply = {
        Get-NetIPInterface -AddressFamily IPv4 -ErrorAction SilentlyContinue | ForEach-Object {
            Set-NetIPInterface -InterfaceIndex $_.InterfaceIndex -WeakHostSend Disabled -WeakHostReceive Disabled -ErrorAction SilentlyContinue
        }
    }
    Revert = {
        Get-NetIPInterface -AddressFamily IPv4 -ErrorAction SilentlyContinue | ForEach-Object {
            Set-NetIPInterface -InterfaceIndex $_.InterfaceIndex -WeakHostSend Enabled -WeakHostReceive Enabled -ErrorAction SilentlyContinue
        }
    }
    Check = {
        $iface = Get-NetIPInterface -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1
        $iface -and $iface.WeakHostSend -eq 'Disabled' -and $iface.WeakHostReceive -eq 'Disabled'
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 41: БРАНДМАУЕР — ПРОФІЛІ ТА ПРАВИЛА ────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Брандмауер — профілі та правила"
    Name  = "Firewall — увімкнути всі профілі + Блокувати вхідні за замовчуванням"
    Desc  = "Увімкнути брандмауер Domain/Private/Public, DefaultInboundAction=Блокувати, DefaultOutboundAction=Дозволити"
    Apply = {
        Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True -DefaultInboundAction Block -DefaultOutboundAction Allow -ErrorAction SilentlyContinue
    }
    Revert = {
        Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True -DefaultInboundAction NotConfigured -ErrorAction SilentlyContinue
    }
    Check = {
        $p = Get-NetFirewallProfile -Profile Public -ErrorAction SilentlyContinue
        $p -and $p.Enabled -and $p.DefaultInboundAction -eq 'Block'
    }
},

[PSCustomObject]@{
    Group = "Брандмауер — профілі та правила"
    Name  = "Firewall Stealth Mode (IPsec)"
    Desc  = "EnableStealthModeForIPsec=True на всіх профілях: не відповідати на небажаний трафік"
    Apply = {
        @("Domain","Private","Public") | ForEach-Object {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\${_}Profile" "EnableStealthModeForIPsec" 1
        }
        netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound 2>$null | Out-Null
    }
    Revert = {
        @("Domain","Private","Public") | ForEach-Object {
            Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\${_}Profile" "EnableStealthModeForIPsec"
        }
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" "EnableStealthModeForIPsec" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Брандмауер — профілі та правила"
    Name  = "Firewall Logging — увімкнути журнал для всіх профілів"
    Desc  = "LogAllowed=True, LogBlocked=True, LogMaxSizeKilobytes=16384 для профілів Domain/Private/Public"
    Apply = {
        Set-NetFirewallProfile -Profile Domain,Private,Public `
            -LogAllowed True -LogBlocked True -LogMaxSizeKilobytes 16384 `
            -LogFileName "%SystemRoot%\System32\LogFiles\Firewall\pfirewall.log" `
            -ErrorAction SilentlyContinue
    }
    Revert = {
        Set-NetFirewallProfile -Profile Domain,Private,Public `
            -LogAllowed False -LogBlocked False -LogMaxSizeKilobytes 4096 `
            -ErrorAction SilentlyContinue
    }
    Check = {
        $p = Get-NetFirewallProfile -Profile Public -ErrorAction SilentlyContinue
        $p -and $p.LogBlocked -eq 'True'
    }
},

[PSCustomObject]@{
    Group = "Брандмауер — профілі та правила"
    Name  = "Firewall — заблокувати ICMP Timestamp (Type 13/14)"
    Desc  = "Блокувати вхідні ICMP Timestamp Request (13) та Reply (14) для захисту від розвідки"
    Apply = {
        New-NetFirewallRule -DisplayName "Block ICMP Timestamp Request In"  -Direction Inbound  -Protocol ICMPv4 -IcmpType 13 -Action Block -Profile Any -ErrorAction SilentlyContinue | Out-Null
        New-NetFirewallRule -DisplayName "Block ICMP Timestamp Reply In"    -Direction Inbound  -Protocol ICMPv4 -IcmpType 14 -Action Block -Profile Any -ErrorAction SilentlyContinue | Out-Null
    }
    Revert = {
        Remove-NetFirewallRule -DisplayName "Block ICMP Timestamp Request In"  -ErrorAction SilentlyContinue
        Remove-NetFirewallRule -DisplayName "Block ICMP Timestamp Reply In"    -ErrorAction SilentlyContinue
    }
    Check = { $null -ne (Get-NetFirewallRule -DisplayName "Block ICMP Timestamp Request In" -ErrorAction SilentlyContinue) }
},

[PSCustomObject]@{
    Group = "Брандмауер — профілі та правила"
    Name  = "Firewall — заблокувати SNMP порти (161/162)"
    Desc  = "Блокувати UDP 161 та 162 (SNMP) вхідний/вихідний трафік"
    Apply = {
        New-NetFirewallRule -DisplayName "Block SNMP Inbound UDP 161"   -Direction Inbound  -Protocol UDP -LocalPort 161 -Action Block -Profile Any -ErrorAction SilentlyContinue | Out-Null
        New-NetFirewallRule -DisplayName "Block SNMP Inbound UDP 162"   -Direction Inbound  -Protocol UDP -LocalPort 162 -Action Block -Profile Any -ErrorAction SilentlyContinue | Out-Null
        New-NetFirewallRule -DisplayName "Block SNMP Outbound UDP 161"  -Direction Outbound -Protocol UDP -RemotePort 161 -Action Block -Profile Any -ErrorAction SilentlyContinue | Out-Null
        New-NetFirewallRule -DisplayName "Block SNMP Outbound UDP 162"  -Direction Outbound -Protocol UDP -RemotePort 162 -Action Block -Profile Any -ErrorAction SilentlyContinue | Out-Null
    }
    Revert = {
        Remove-NetFirewallRule -DisplayName "Block SNMP*" -ErrorAction SilentlyContinue
    }
    Check = { $null -ne (Get-NetFirewallRule -DisplayName "Block SNMP Inbound UDP 161" -ErrorAction SilentlyContinue) }
},

[PSCustomObject]@{
    Group = "Брандмауер — профілі та правила"
    Name  = "Firewall — заблокувати SMB порт 445 (TCP/UDP)"
    Desc  = "Блокувати порт 445 (SMB/CIFS) вхідний/вихідний для повного блокування SMB"
    Apply = {
        New-NetFirewallRule -DisplayName "Block SMB Inbound TCP 445"   -Direction Inbound  -Protocol TCP -LocalPort 445  -Action Block -Profile Any -ErrorAction SilentlyContinue | Out-Null
        New-NetFirewallRule -DisplayName "Block SMB Outbound TCP 445"  -Direction Outbound -Protocol TCP -RemotePort 445 -Action Block -Profile Any -ErrorAction SilentlyContinue | Out-Null
        New-NetFirewallRule -DisplayName "Block SMB Inbound UDP 445"   -Direction Inbound  -Protocol UDP -LocalPort 445  -Action Block -Profile Any -ErrorAction SilentlyContinue | Out-Null
        New-NetFirewallRule -DisplayName "Block SMB Outbound UDP 445"  -Direction Outbound -Protocol UDP -RemotePort 445 -Action Block -Profile Any -ErrorAction SilentlyContinue | Out-Null
    }
    Revert = {
        Remove-NetFirewallRule -DisplayName "Block SMB*" -ErrorAction SilentlyContinue
    }
    Check = { $null -ne (Get-NetFirewallRule -DisplayName "Block SMB Inbound TCP 445" -ErrorAction SilentlyContinue) }
},

[PSCustomObject]@{
    Group = "Брандмауер — профілі та правила"
    Name  = "Firewall — заблокувати IRC порти"
    Desc  = "Блокувати TCP 194, 529, 6660-6669, 6697, 7000 (IRC) вхідний трафік"
    Apply = {
        New-NetFirewallRule -DisplayName "Block IRC Inbound" -Direction Inbound -Protocol TCP `
            -LocalPort 194,529,6660,6661,6662,6663,6664,6665,6666,6667,6668,6669,6697,7000 `
            -Action Block -Profile Any -ErrorAction SilentlyContinue | Out-Null
    }
    Revert = {
        Remove-NetFirewallRule -DisplayName "Block IRC Inbound" -ErrorAction SilentlyContinue
    }
    Check = { $null -ne (Get-NetFirewallRule -DisplayName "Block IRC Inbound" -ErrorAction SilentlyContinue) }
},

[PSCustomObject]@{
    Group = "Брандмауер — профілі та правила"
    Name  = "Firewall — заблокувати Port 0 (HPING3 DDoS)"
    Desc  = "Блокувати TCP/UDP порт 0 вхідний/вихідний (HPING3 DDoS-атаки)"
    Apply = {
        New-NetFirewallRule -DisplayName "Block Port0 Inbound TCP"   -Direction Inbound  -Protocol TCP -LocalPort 0  -Action Block -Profile Any -ErrorAction SilentlyContinue | Out-Null
        New-NetFirewallRule -DisplayName "Block Port0 Outbound TCP"  -Direction Outbound -Protocol TCP -RemotePort 0 -Action Block -Profile Any -ErrorAction SilentlyContinue | Out-Null
        New-NetFirewallRule -DisplayName "Block Port0 Inbound UDP"   -Direction Inbound  -Protocol UDP -LocalPort 0  -Action Block -Profile Any -ErrorAction SilentlyContinue | Out-Null
        New-NetFirewallRule -DisplayName "Block Port0 Outbound UDP"  -Direction Outbound -Protocol UDP -RemotePort 0 -Action Block -Profile Any -ErrorAction SilentlyContinue | Out-Null
    }
    Revert = {
        Remove-NetFirewallRule -DisplayName "Block Port0*" -ErrorAction SilentlyContinue
    }
    Check = { $null -ne (Get-NetFirewallRule -DisplayName "Block Port0 Inbound TCP" -ErrorAction SilentlyContinue) }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 42: МЕРЕЖЕВІ ПРОТОКОЛИ — БЛОКУВАННЯ ────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Мережеві протоколи — блокування"
    Name  = "Прив'язка «Спільний доступ до файлів і принтерів» — вимкнути на адаптерах"
    Desc  = "Вимкнути компонент ms_server (Спільний доступ до файлів і принтерів) на адаптерах Ethernet та Wi-Fi"
    Apply = {
        Get-NetAdapter -ErrorAction SilentlyContinue | ForEach-Object {
            Disable-NetAdapterBinding -Name $_.Name -ComponentID ms_server -ErrorAction SilentlyContinue
        }
    }
    Revert = {
        Get-NetAdapter -ErrorAction SilentlyContinue | ForEach-Object {
            Enable-NetAdapterBinding -Name $_.Name -ComponentID ms_server -ErrorAction SilentlyContinue
        }
    }
    Check = {
        $adapter = Get-NetAdapter -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($adapter) {
            $b = Get-NetAdapterBinding -Name $adapter.Name -ComponentID ms_server -ErrorAction SilentlyContinue
            $b -and -not $b.Enabled
        } else { $false }
    }
},

[PSCustomObject]@{
    Group = "Мережеві протоколи — блокування"
    Name  = "WinRM / PowerShell Remoting — повністю вимкнути"
    Desc  = "Зупинити WinRM, вимкнути PowerShell Remoting, LocalAccountTokenFilterPolicy=0"
    Apply = {
        Set-ServiceDisabled "WinRM"
        Disable-PSRemoting -Force -ErrorAction SilentlyContinue 2>$null
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "LocalAccountTokenFilterPolicy" 0
    }
    Revert = {
        Set-ServiceManual "WinRM"
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "LocalAccountTokenFilterPolicy" 1
    }
    Check = { $s = Get-Service "WinRM" -ErrorAction SilentlyContinue; $s -and $s.StartType -eq 'Disabled' }
},

[PSCustomObject]@{
    Group = "Мережеві протоколи — блокування"
    Name  = "SSTP VPN сервіс — вимкнути"
    Desc  = "Зупинити та вимкнути SstpSvc (Secure Socket Tunneling Protocol)"
    Apply  = { Set-ServiceDisabled "SstpSvc" }
    Revert = { Set-ServiceManual "SstpSvc" }
    Check  = { $s = Get-Service "SstpSvc" -ErrorAction SilentlyContinue; $s -and $s.StartType -eq 'Disabled' }
},

[PSCustomObject]@{
    Group = "Мережеві протоколи — блокування"
    Name  = "SMBv2 протокол — вимкнути (тільки для ізольованих станцій)"
    Desc  = "Вимкнути SMB2Protocol через Set-SmbServerConfiguration (УВАГА: може вплинути на мережеві ресурси)"
    Apply = {
        Set-SmbServerConfiguration -EnableSMB2Protocol $false -Force -ErrorAction SilentlyContinue
    }
    Revert = {
        Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force -ErrorAction SilentlyContinue
    }
    Check = {
        $cfg = Get-SmbServerConfiguration -ErrorAction SilentlyContinue
        $cfg -and -not $cfg.EnableSMB2Protocol
    }
},

[PSCustomObject]@{
    Group = "Мережеві протоколи — блокування"
    Name  = "LMHosts / LanmanServer / LanmanWorkstation — вимкнути"
    Desc  = "Зупинити сервіси lmhosts, LanmanServer, LanmanWorkstation для ізольованих станцій"
    Apply = {
        foreach ($svc in @("lmhosts","LanmanServer","LanmanWorkstation")) {
            Set-ServiceDisabled $svc
        }
    }
    Revert = {
        foreach ($svc in @("lmhosts","LanmanServer","LanmanWorkstation")) {
            Set-ServiceManual $svc
        }
    }
    Check = { $s = Get-Service "LanmanServer" -ErrorAction SilentlyContinue; $s -and $s.StartType -eq 'Disabled' }
},

[PSCustomObject]@{
    Group = "Мережеві протоколи — блокування"
    Name  = "Null-сесії / анонімні канали — розширений захист"
    Desc  = "NullSessionPipes='', NullSessionShares='', RestrictNullSessAccess=1, LmCompatibilityLevel=5"
    Apply = {
        $lsa = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
        $smb = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
        Set-Reg $lsa "LmCompatibilityLevel"   5
        Set-Reg $smb "NullSessionPipes"        "" "MultiString"
        Set-Reg $smb "NullSessionShares"       "" "MultiString"
        Set-Reg $smb "RestrictNullSessAccess"  1
    }
    Revert = {
        $smb = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
        Remove-RegValue $smb "NullSessionPipes"
        Remove-RegValue $smb "NullSessionShares"
    }
    Check = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "RestrictNullSessAccess" 0) -eq 1 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 49: МЕРЕЖЕВА ІЗОЛЯЦІЯ / DOMAIN HARDENING ───────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Мережева ізоляція / Domain Hardening"
    Name  = "Заблокувати підключення до мереж поза доменом при підключенні до домену"
    Desc  = "fBlockNonDomain=1, fMinimizeConnections=3: ізоляція від публічних мереж при підключенні до домену"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy" "fBlockNonDomain"       1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy" "fMinimizeConnections"  3
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy" "fBlockNonDomain"
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy" "fMinimizeConnections"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy" "fBlockNonDomain" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Мережева ізоляція / Domain Hardening"
    Name  = "Захищені UNC-шляхи — SYSVOL та NETLOGON"
    Desc  = "RequireMutualAuthentication=1, RequireIntegrity=1 для \\*\\SYSVOL та \\*\\NETLOGON"
    Apply = {
        $hp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths"
        Set-Reg $hp "\\*\SYSVOL"    "RequireMutualAuthentication=1, RequireIntegrity=1" "String"
        Set-Reg $hp "\\*\NETLOGON"  "RequireMutualAuthentication=1, RequireIntegrity=1" "String"
    }
    Revert = {
        $hp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths"
        Remove-RegValue $hp "\\*\SYSVOL"
        Remove-RegValue $hp "\\*\NETLOGON"
    }
    Check = {
        $val = Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths" "\\*\SYSVOL" ""
        $val -match 'RequireMutualAuthentication=1'
    }
},

[PSCustomObject]@{
    Group = "Мережева ізоляція / Domain Hardening"
    Name  = "Мережеві підключення — приховати інтерфейс спільного доступу"
    Desc  = "NC_ShowSharedAccessUI=0: заборонити інтерфейс спільного використання підключення до Інтернету"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" "NC_ShowSharedAccessUI" 0
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" "NC_ShowSharedAccessUI"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" "NC_ShowSharedAccessUI" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Мережева ізоляція / Domain Hardening"
    Name  = "Небезпечна гостьова автентифікація — заборонити для SMB"
    Desc  = "AllowInsecureGuestAuth=0: заблокувати гостьовий доступ до SMB ресурсів"
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AllowInsecureGuestAuth" 0
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AllowInsecureGuestAuth"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AllowInsecureGuestAuth" 1) -eq 0 }
},

[PSCustomObject]@{
    Group = "Мережева ізоляція / Domain Hardening"
    Name  = "SMB Encryption — увімкнути обов'язкове шифрування"
    Desc  = "EncryptData=True, RejectUnencryptedAccess=True: весь SMB трафік має бути зашифрований"
    Apply = {
        Set-SmbServerConfiguration -EncryptData $true -RejectUnencryptedAccess $true -Force -ErrorAction SilentlyContinue
    }
    Revert = {
        Set-SmbServerConfiguration -EncryptData $false -RejectUnencryptedAccess $false -Force -ErrorAction SilentlyContinue
    }
    Check = {
        $cfg = Get-SmbServerConfiguration -ErrorAction SilentlyContinue
        $cfg -and $cfg.EncryptData
    }
}

)

<#
.SYNOPSIS
    Мережа: безпека з'єднань, протоколи, NTLM, TCP/IP стек, SMB
.NOTES
    Частина Get-HardeningSettings — підвантажується через settings.data.ps1
    DoH та ARP Spoofing винесено у doh.ps1
#>

@(

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 5: МЕРЕЖЕВА БЕЗПЕКА (ACSC 26) ────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Мережева безпека"
    Name  = "NTLMv2 тільки, заборонити LM та NTLM (ACSC 26)"
    Desc  = @"
LmCompatibilityLevel=5, NTLMMinClientSec/ServerSec=537395200, NoLMHash=1.
CVE-2025-24054, CVE-2025-50154: NTLM relay/pass-the-hash.
GPO: Computer Configuration > Windows Settings > Security Settings > Local Policies > Security Options
  → "Network security: LAN Manager authentication level" = Send NTLMv2 response only. Refuse LM & NTLM
  → "Network security: Restrict NTLM: Outgoing NTLM traffic" = Deny all
  → "Network security: Do not store LAN Manager hash value on next password change" = Enabled
"@
    Apply = {
        $lsa = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
        Set-Reg $lsa "LmCompatibilityLevel" 5
        Set-Reg $lsa "NoLMHash"             1
        Set-Reg "$lsa\MSV1_0" "NTLMMinClientSec" 537395200
        Set-Reg "$lsa\MSV1_0" "NTLMMinServerSec" 537395200
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters" "SupportedEncryptionTypes" 2147483640
    }
    Revert = {
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LmCompatibilityLevel" 3
    }
    Check = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LmCompatibilityLevel" 0) -eq 5 }
},

[PSCustomObject]@{
    Group = "Мережева безпека"
    Name  = "SMB v1 вимкнути + SMB Signing (ACSC 26)"
    Desc  = @"
mrxsmb10 Start=4, SMB1=0, RequireSecuritySignature=1 (клієнт і сервер).
GPO: Computer Configuration > Windows Settings > Security Settings > Local Policies > Security Options
  → "Microsoft network client: Digitally sign communications (always)" = Enabled
  → "Microsoft network server: Digitally sign communications (always)" = Enabled
  → Computer Configuration > Administrative Templates > Network > Lanman Workstation
  → "Enable insecure guest logons" = Disabled
PowerShell: Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
"@
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
    Desc  = @"
EnableMulticast=0, RestrictRemoteClients=1, Захищені UNC-шляхи SYSVOL/NETLOGON.
GPO: Computer Configuration > Administrative Templates > Network > DNS Client
  → "Turn off multicast name resolution" = Enabled
"@
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
    Group = "Мережева приватність / Hosts / DNS"
    Name  = "Firewall — заблокувати IP-адреси телеметрії Microsoft та NVIDIA"
    Desc  = "Вихідне блокування IP телеметрії через Firewall. УВАГА: IP-список може застаріти — використовуйте HOSTS блокування як основний метод."
    Apply = {
        $msIPs = @(
            '134.170.30.202','137.116.81.24','157.56.106.189',
            '184.86.53.99','2.22.61.43','2.22.61.44',
            '204.79.197.200','23.218.212.69','65.55.108.23',
            '65.55.252.43','64.4.54.254','65.52.108.33',
            '191.232.139.254','65.55.252.63','65.52.100.7',
            '207.68.128.11','94.245.121.3','111.221.29.177',
            '23.102.21.4','23.102.4.253','131.253.40.37',
            '65.52.108.29','191.237.218.239','131.253.34.230'
        )
        $existing = Get-NetFirewallRule -DisplayName "Block MS Telemetry IPs" -ErrorAction SilentlyContinue
        if ($existing) { Remove-NetFirewallRule -DisplayName "Block MS Telemetry IPs" -ErrorAction SilentlyContinue }
        New-NetFirewallRule -DisplayName "Block MS Telemetry IPs" -Direction Outbound `
            -RemoteAddress $msIPs -Action Block -Profile Any -Enabled True | Out-Null

        $nvIPs = @('169.254.0.0','192.169.1.0')
        $existing2 = Get-NetFirewallRule -DisplayName "Block NVIDIA Telemetry IPs" -ErrorAction SilentlyContinue
        if ($existing2) { Remove-NetFirewallRule -DisplayName "Block NVIDIA Telemetry IPs" -ErrorAction SilentlyContinue }
        New-NetFirewallRule -DisplayName "Block NVIDIA Telemetry IPs" -Direction Outbound `
            -RemoteAddress $nvIPs -Action Block -Profile Any -Enabled True | Out-Null
    }
    Revert = {
        Remove-NetFirewallRule -DisplayName "Block MS Telemetry IPs"     -ErrorAction SilentlyContinue
        Remove-NetFirewallRule -DisplayName "Block NVIDIA Telemetry IPs" -ErrorAction SilentlyContinue
    }
    Check = { $null -ne (Get-NetFirewallRule -DisplayName "Block MS Telemetry IPs" -ErrorAction SilentlyContinue) }
},

[PSCustomObject]@{
    Group = "Мережева приватність / Hosts / DNS"
    Name  = "HOSTS файл — додати домени телеметрії Microsoft / NVIDIA / Adobe"
    Desc  = "Заблокувати через hosts (0.0.0.0): vortex, telemetry, watson, sqm, oca, statsfe та ін."
    Apply = {
        $hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
        $hostsBackup = "$hostsPath.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item $hostsPath $hostsBackup -Force -ErrorAction SilentlyContinue

        $telemetryDomains = @(
            '0.0.0.0 vortex.data.microsoft.com',
            '0.0.0.0 vortex-win.data.microsoft.com',
            '0.0.0.0 telecommand.telemetry.microsoft.com',
            '0.0.0.0 oca.telemetry.microsoft.com',
            '0.0.0.0 sqm.telemetry.microsoft.com',
            '0.0.0.0 watson.telemetry.microsoft.com',
            '0.0.0.0 redir.metaservices.microsoft.com',
            '0.0.0.0 choice.microsoft.com',
            '0.0.0.0 df.telemetry.microsoft.com',
            '0.0.0.0 reports.wes.df.telemetry.microsoft.com',
            '0.0.0.0 wes.df.telemetry.microsoft.com',
            '0.0.0.0 sqm.df.telemetry.microsoft.com',
            '0.0.0.0 telemetry.microsoft.com',
            '0.0.0.0 watson.ppe.telemetry.microsoft.com',
            '0.0.0.0 telemetry.appex.bing.net',
            '0.0.0.0 telemetry.urs.microsoft.com',
            '0.0.0.0 settings-sandbox.data.microsoft.com',
            '0.0.0.0 vortex-sandbox.data.microsoft.com',
            '0.0.0.0 survey.watson.microsoft.com',
            '0.0.0.0 watson.live.com',
            '0.0.0.0 watson.microsoft.com',
            '0.0.0.0 statsfe2.ws.microsoft.com',
            '0.0.0.0 compatexchange.cloudapp.net',
            '0.0.0.0 diagnostics.support.microsoft.com',
            '0.0.0.0 rstats.update.microsoft.com',
            '0.0.0.0 statsfe2.update.microsoft.com.akadns.net',
            '0.0.0.0 fe2.update.microsoft.com.akadns.net',
            '0.0.0.0 events.gfe.nvidia.com',
            '0.0.0.0 telemetry.nvidia.com',
            '0.0.0.0 ssl.google-analytics.com',
            '0.0.0.0 www.google-analytics.com',
            '0.0.0.0 activate.adobe.com',
            '0.0.0.0 practivate.adobe.com',
            '0.0.0.0 ereg.adobe.com'
        )
        $existingContent = Get-Content $hostsPath -ErrorAction SilentlyContinue
        $newEntries = $telemetryDomains | Where-Object { $existingContent -notcontains $_ }
        if ($newEntries.Count -gt 0) {
            Add-Content -Path $hostsPath -Value "`n# === Privacy Hardening $(Get-Date -Format 'yyyy-MM-dd') ===" -Encoding UTF8
            $newEntries | Add-Content -Path $hostsPath -Encoding UTF8
        }
        Clear-DnsClientCache -ErrorAction SilentlyContinue
    }
    Revert = {
        # Відновити hosts з останнього .bak файлу
        $hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
        $bak = Get-ChildItem "$hostsPath.bak_*" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($bak) {
            Copy-Item $bak.FullName $hostsPath -Force
        } else {
            # Видалити рядки що починаються з 0.0.0.0 (додані блокуванням)
            $lines = Get-Content $hostsPath -ErrorAction SilentlyContinue
            $filtered = $lines | Where-Object { $_ -notmatch '^0\.0\.0\.0\s+' -and $_ -notmatch '=== Privacy Hardening' }
            $filtered | Set-Content $hostsPath -Encoding UTF8
        }
        Clear-DnsClientCache -ErrorAction SilentlyContinue
    }
    Check = {
        $hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
        $content = Get-Content $hostsPath -ErrorAction SilentlyContinue
        $content -contains '0.0.0.0 vortex.data.microsoft.com'
    }
},

[PSCustomObject]@{
    Group = "Мережева приватність / Hosts / DNS"
    Name  = "DNS — перемкнути на Cloudflare (1.1.1.1 / 1.0.0.1)"
    Desc  = "Set-DnsClientServerAddress на всіх активних адаптерах; Flush DNS після зміни"
    Apply = {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
        foreach ($a in $adapters) {
            Set-DnsClientServerAddress -InterfaceIndex $a.InterfaceIndex `
                -ServerAddresses @('1.1.1.1','1.0.0.1') -ErrorAction SilentlyContinue
        }
        Clear-DnsClientCache -ErrorAction SilentlyContinue
    }
    Revert = {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
        foreach ($a in $adapters) {
            Set-DnsClientServerAddress -InterfaceIndex $a.InterfaceIndex -ResetServerAddresses -ErrorAction SilentlyContinue
        }
        Clear-DnsClientCache -ErrorAction SilentlyContinue
    }
    Check = {
        $adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
        if ($adapter) {
            $dns = (Get-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses
            $dns -contains '1.1.1.1'
        } else { $false }
    }
},

[PSCustomObject]@{
    Group = "Мережева приватність / IPv6 / NetBIOS"
    Name  = "IPv6 — вимкнути на адаптерах (DisabledComponents=0xFE)"
    Desc  = "DisabledComponents=0xFE: відключити IPv6 на адаптерах, залишити loopback (::1) активним (KB929852)"
    Apply = {
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" 0xFE
        Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | ForEach-Object {
            Disable-NetAdapterBinding -Name $_.Name -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
        }
    }
    Revert = {
        Remove-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents"
        Get-NetAdapter | ForEach-Object {
            Enable-NetAdapterBinding -Name $_.Name -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
        }
    }
    Check = {
        (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" 0) -eq 0xFE
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
    Desc  = "SynAttackProtect=1 (SYN Cookies), TcpMaxHalfOpen=25, TcpMaxHalfOpenRetried=20, TcpMaxSynRetransmissions=1"
    Apply = {
        $tcp = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
        Set-Reg $tcp "SynAttackProtect"          1
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
    Name  = "SMBv2 протокол — вимкнути (НЕБЕЗПЕЧНО, тільки для ізольованих станцій)"
    Desc  = "УВАГА: вимикає File Explorer мережу, Windows Update (частково), мережеві принтери. Тільки для повністю ізольованих машин без мережі."
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
    Desc  = "NullSessionPipes='', NullSessionShares='', RestrictNullSessAccess=1"
    Apply = {
        $smb = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
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
    Desc  = @"
AllowInsecureGuestAuth=0: заблокувати гостьовий доступ до SMB ресурсів.
GPO: Computer Configuration > Administrative Templates > Network > Lanman Workstation
  → "Enable insecure guest logons" = Disabled
"@
    Apply = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AllowInsecureGuestAuth" 0
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AllowInsecureGuestAuth"
    }
    Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AllowInsecureGuestAuth" 1) -eq 0 }
},

[PSCustomObject]@{
    Group    = "Мережева безпека"
    Name     = "NetBIOS — вимкнути через GPO на всіх мережах (25H2 Baseline)"
    Desc     = "ConfigureNBT=2 у DNS Client policy: офіційний метод 25H2 замість NetbiosOptions на кожному адаптері"
    MinBuild = 26200
    Apply  = {
        # Новий GPO-ключ 25H2 (DNS Client\Configure NetBIOS settings)
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "ConfigureNBT" 2
        # Залишити старий метод як додатковий рівень
        Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces" -EA SilentlyContinue |
            ForEach-Object { Set-ItemProperty -Path $_.PSPath -Name "NetbiosOptions" -Value 2 -EA SilentlyContinue }
    }
    Revert = {
        Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "ConfigureNBT"
    }
    Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "ConfigureNBT" 0) -eq 2 }
},

[PSCustomObject]@{
    Group = "Мережева ізоляція / Domain Hardening"
    Name  = "SMB Encryption — увімкнути обов'язкове шифрування"
    Desc  = @"
EncryptData=True, RejectUnencryptedAccess=True: весь SMB трафік має бути зашифрований.
GPO: Computer Configuration > Administrative Templates > Network > Lanman Server
  → "Require message encryption" = Enabled
  → "Reject unencrypted access" = Enabled
"@
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
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 12: LEGACY TLS/SSL DISABLE — DOWNGRADE ATTACK PREVENTION ────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "TLS/SSL Hardening"
    Name  = "Вимкнути SSL 2.0, SSL 3.0, TLS 1.0, TLS 1.1 (SCHANNEL)"
    Desc  = @"
Вимикає застарілі протоколи (SSL 2.0/3.0, TLS 1.0/1.1) для Server та Client:
  Enabled=0, DisabledByDefault=1 для кожного протоколу.
  Захист від downgrade-атак (POODLE, BEAST, DROWN).
  TLS 1.2 залишається увімкненим.
GPO: немає прямого GPO — тільки реєстр SCHANNEL\Protocols.
  Протоколи для вимкнення: SSL 2.0, SSL 3.0, TLS 1.0, TLS 1.1
  Протоколи для увімкнення: TLS 1.2, TLS 1.3
"@
    Apply = {
        $base = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"
        foreach ($proto in @("SSL 2.0", "SSL 3.0", "TLS 1.0", "TLS 1.1")) {
            foreach ($role in @("Server", "Client")) {
                $p = "$base\$proto\$role"
                Set-Reg $p "Enabled"            0
                Set-Reg $p "DisabledByDefault"   1
            }
        }
        # Переконатися що TLS 1.2 увімкнено
        foreach ($role in @("Server", "Client")) {
            $p = "$base\TLS 1.2\$role"
            Set-Reg $p "Enabled"            1
            Set-Reg $p "DisabledByDefault"   0
        }
        Write-AppLog -Level 'INFO' -Message "SCHANNEL: SSL 2.0/3.0, TLS 1.0/1.1 вимкнено; TLS 1.2 увімкнено"
    }
    Revert = {
        $base = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"
        foreach ($proto in @("TLS 1.0", "TLS 1.1")) {
            foreach ($role in @("Server", "Client")) {
                Remove-RegValue "$base\$proto\$role" "Enabled"
                Remove-RegValue "$base\$proto\$role" "DisabledByDefault"
            }
        }
    }
    Check = {
        $base = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"
        $tls10 = Get-Reg "$base\TLS 1.0\Server" "Enabled" 1
        $tls11 = Get-Reg "$base\TLS 1.1\Server" "Enabled" 1
        $tls12 = Get-Reg "$base\TLS 1.2\Server" "Enabled" 0
        ($tls10 -eq 0) -and ($tls11 -eq 0) -and ($tls12 -eq 1)
    }
}

)

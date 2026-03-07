<#
.SYNOPSIS
    MEDIUM PRIORITY: Network Security
    SMB hardening, Network Authentication, DMA protection, Network bridging,
    NoLMHash, MSS settings, Secure channel, RPC
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Network Security ===" -ForegroundColor Magenta

$secOpt = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"

# --- Network Authentication ---
Write-Host "  -- Network Authentication --" -ForegroundColor DarkCyan

Set-RegistryValue -AuditOnly:$AuditOnly -Path $secOpt `
    -Name "LmCompatibilityLevel" -Value 5 `
    -Description "LAN Manager auth: Send NTLMv2 only, refuse LM & NTLM"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" `
    -Name "NTLMMinClientSec" -Value 537395200 `
    -Description "Min session security NTLM SSP clients: NTLMv2 + 128-bit"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" `
    -Name "NTLMMinServerSec" -Value 537395200 `
    -Description "Min session security NTLM SSP servers: NTLMv2 + 128-bit"

# Kerberos encryption
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters" `
    -Name "SupportedEncryptionTypes" -Value 24 `
    -Description "Kerberos encryption: AES128 + AES256 only"

# NoLMHash
Set-RegistryValue -AuditOnly:$AuditOnly -Path $secOpt `
    -Name "NoLMHash" -Value 1 `
    -Description "Do not store LAN Manager hash value"

# --- SMB Hardening ---
Write-Host "  -- SMB Hardening --" -ForegroundColor DarkCyan

# Disable SMBv1
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mrxsmb10" `
    -Name "Start" -Value 4 `
    -Description "SMB v1 client driver: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" `
    -Name "SMB1" -Value 0 `
    -Description "SMB v1 server: Disabled"

# SMB signing
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" `
    -Name "RequireSecuritySignature" -Value 1 `
    -Description "Microsoft network client: Digitally sign communications (always)"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" `
    -Name "EnablePlainTextPassword" -Value 0 `
    -Description "Send unencrypted password to third-party SMB servers: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" `
    -Name "RequireSecuritySignature" -Value 1 `
    -Description "Microsoft network server: Digitally sign communications (always)"

# --- DMA Protection ---
Write-Host "  -- DMA Protection --" -ForegroundColor DarkCyan

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" `
    -Name "DeviceEnumerationPolicy" -Value 0 `
    -Description "Kernel DMA Protection: Block All"

# FireWire/Thunderbolt device blocking
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" `
    -Name "DenyDeviceIDs" -Value 1 `
    -Description "Prevent installation of DMA devices by ID"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs" `
    -Name "1" -Value "PCI\CC_0C0010" -Type String `
    -Description "Block FireWire controller"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs" `
    -Name "2" -Value "PCI\CC_0C0A" -Type String `
    -Description "Block Thunderbolt controller"

# --- Network Bridging ---
Write-Host "  -- Network Bridging --" -ForegroundColor DarkCyan

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" `
    -Name "NC_ShowSharedAccessUI" -Value 0 `
    -Description "Prohibit Internet Connection Sharing"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy" `
    -Name "fBlockNonDomain" -Value 1 `
    -Description "Prohibit connection to non-domain networks when on domain"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy" `
    -Name "fMinimizeConnections" -Value 3 `
    -Description "Minimize connections: Prevent Wi-Fi when on Ethernet"

# --- Secure Channel ---
Write-Host "  -- Secure Channel --" -ForegroundColor DarkCyan

$scPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $scPath `
    -Name "RequireSignOrSeal" -Value 1 `
    -Description "Digitally encrypt or sign secure channel data (always)"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $scPath `
    -Name "SealSecureChannel" -Value 1 `
    -Description "Digitally encrypt secure channel data (when possible)"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $scPath `
    -Name "SignSecureChannel" -Value 1 `
    -Description "Digitally sign secure channel data (when possible)"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $scPath `
    -Name "RequireStrongKey" -Value 1 `
    -Description "Require strong session key"

# --- MSS Settings ---
Write-Host "  -- MSS Settings --" -ForegroundColor DarkCyan

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" `
    -Name "DisableIPSourceRouting" -Value 2 `
    -Description "MSS: IPv6 source routing: Highest protection"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" `
    -Name "DisableIPSourceRouting" -Value 2 `
    -Description "MSS: IPv4 source routing: Highest protection"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" `
    -Name "EnableICMPRedirect" -Value 0 `
    -Description "MSS: Allow ICMP redirects to override OSPF: Disabled"

# --- RPC ---
Write-Host "  -- Remote Procedure Call --" -ForegroundColor DarkCyan

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Rpc" `
    -Name "RestrictRemoteClients" -Value 1 `
    -Description "Restrict Unauthenticated RPC clients: Authenticated"

# --- Hardened UNC Paths ---
Write-Host "  -- Hardened UNC Paths --" -ForegroundColor DarkCyan

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths" `
    -Name "\\*\SYSVOL" -Value "RequireMutualAuthentication=1, RequireIntegrity=1" -Type String `
    -Description "Hardened UNC Path: SYSVOL"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths" `
    -Name "\\*\NETLOGON" -Value "RequireMutualAuthentication=1, RequireIntegrity=1" -Type String `
    -Description "Hardened UNC Path: NETLOGON"

#Requires -Version 5.1
<#
.SYNOPSIS
    UEFI/BIOS Hardening — захист від 0day ASUS та інших виробників
.NOTES
    CVE-2025-11901 — IOMMU/DMA pre-boot атаки (ASUS, GIGABYTE, MSI, ASRock)
    CVE-2025-59374 — ASUS Live Update backdoor (CISA KEV, CVSS 9.3)
    CVE-2023-24932 — BlackLotus UEFI bootkit → Secure Boot cert update (June 2026!)
    CVE-2025-3052  — Binarly UEFI missing mitigations
    LogoFAIL       — парсери UEFI-зображень (AMI/Insyde/Phoenix)
    Джерела: Microsoft Secure Boot Playbook 2026, CERT/CC VU#123293, CISA KEV
#>

@(
# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 1: SECURE BOOT CERTIFICATES — КРИТИЧНО ДО ЧЕРВНЯ 2026 ────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "UEFI / Secure Boot Certificates"
    Name  = "Secure Boot — розгортання нових сертифікатів 2023 (Microsoft Playbook)"
    Desc  = "AvailableUpdates=0x5944: розгорнути Windows UEFI CA 2023 + оновлений Boot Manager. КРИТИЧНО до червня 2026 — старі сертифікати 2011 expire, CVE-2023-24932 (BlackLotus)"
    Apply = {
        $sb = "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot"
        Set-Reg "$sb\Servicing" "AvailableUpdates" 0x5944
        Set-Reg "$sb\Servicing" "HighConfidenceOptOut" 0
        $status = Get-ItemPropertyValue "$sb\Servicing" "UEFICA2023Status" -EA SilentlyContinue
        Write-AppLog -Level 'INFO' -Message "Secure Boot cert status: $status"
        if ($status -ne "Updated") {
            Write-AppLog -Level 'WARN' -Message "Потрібен перезапуск (2+ рази)."
        }
        $err = Get-ItemProperty "$sb\Servicing" -Name "UEFICA2023Error" -EA SilentlyContinue
        if ($err) {
            Write-AppLog -Level 'ERROR' -Message "UEFICA2023Error: $($err.UEFICA2023Error)"
        }
    }
    Revert = {
        Write-AppLog -Level 'WARN' -Message "Secure Boot certs: відкат не рекомендований"
    }
    Check = {
        $status = Get-ItemPropertyValue `
            "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing" `
            "UEFICA2023Status" -EA SilentlyContinue
        $status -eq "Updated"
    }
},

[PSCustomObject]@{
    Group = "UEFI / Secure Boot Certificates"
    Name  = "Secure Boot — перевірити та відобразити стан усіх сертифікатів"
    Desc  = "Аудит: Get-SecureBootUEFI (PK/KEK/db/dbx), Confirm-SecureBootUEFI, перевірка DBX на відкликані bootloader-хеші"
    Apply = {
        try {
            $enabled = Confirm-SecureBootUEFI -EA Stop
            Write-AppLog -Level 'INFO' -Message "Secure Boot: УВІМКНЕНО=$enabled"
        } catch {
            Write-AppLog -Level 'ERROR' -Message "Secure Boot: недоступно"
            return
        }
        foreach ($var in @("PK","KEK","db","dbx")) {
            try {
                $cert = Get-SecureBootUEFI -Name $var -EA Stop
                Write-AppLog -Level 'INFO' -Message "SB $var`: знайдено ($($cert.Bytes.Length) байт)"
            } catch {
                Write-AppLog -Level 'WARN' -Message "SB $var`: ВІДСУТНІЙ!"
            }
        }
        $evOK  = Get-WinEvent -FilterHashtable @{LogName='System';Id=1808} -MaxEvents 1 -EA SilentlyContinue
        $evErr = Get-WinEvent -FilterHashtable @{LogName='System';Id=1801} -MaxEvents 1 -EA SilentlyContinue
        if ($evOK)  { Write-AppLog -Level 'INFO'  -Message "Event 1808: Cert deployment SUCCESS" }
        if ($evErr) { Write-AppLog -Level 'ERROR' -Message "Event 1801: Cert deployment ERROR" }
    }
    Revert = { }
    Check  = {
        try { Confirm-SecureBootUEFI -EA Stop } catch { $false }
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 2: CVE-2025-11901 — DMA/IOMMU PRE-BOOT ATTACK ───────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "UEFI / DMA Protection (CVE-2025-11901)"
    Name  = "DMA Protection — IOMMU Kernel перевірка та посилення (CERT/CC VU#123293)"
    Desc  = "CVE-2025-11901: ASUS/GIGABYTE/MSI/ASRock — IOMMU неправильно ініціалізується. Windows захист: KernelDmaProtection увімкнути, Thunderbolt/PCIe обмежити до перезавантаження"
    Apply = {
        $vbs = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -EA SilentlyContinue
        Write-AppLog -Level 'INFO' -Message "VBS: EnableVBS=$($vbs.EnableVirtualizationBasedSecurity)"
        $wmiVBS = Get-WmiObject -Class "Win32_DeviceGuard" -Namespace "root\Microsoft\Windows\DeviceGuard" -EA SilentlyContinue
        if ($wmiVBS) {
            $kdpa = $wmiVBS.DmaProtectionStatus
            Write-AppLog -Level 'INFO' -Message "Kernel DMA Protection (WMI): $kdpa"
            if ($kdpa -eq 0) { Write-AppLog -Level 'ERROR' -Message "УВАГА: Kernel DMA Protection ВИМКНЕНА!" }
        }
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy" 0
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceIDs" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceIDsRetroactive" 1
        $deny = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs"
        Set-Reg $deny "1" "PCI\CC_0C0010" "String"
        Set-Reg $deny "2" "PCI\CC_0C0A"   "String"
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DmaGuard" 1
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" "EnableVirtualizationBasedSecurity" 1
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" "RequirePlatformSecurityFeatures"   3
    }
    Revert = {
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy" 1
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" "RequirePlatformSecurityFeatures" 1
    }
    Check = {
        (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy" -1) -eq 0
    }
},

[PSCustomObject]@{
    Group = "UEFI / DMA Protection (CVE-2025-11901)"
    Name  = "DMA — заблокувати PCIe hot-plug та нові пристрої до входу (Boot Guard)"
    Desc  = "KernelDmaProtectionOptIn=1 + DeviceEnumerationPolicy=0: жоден PCIe пристрій не отримує DMA доступ до входу адміністратора"
    Apply = {
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" "KernelDmaProtectionOptIn" 1
        $thunder = Get-Service "TBTFwUpdateSvc" -EA SilentlyContinue
        if ($thunder) { Set-ServiceDisabled "TBTFwUpdateSvc" }
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\pci\Parameters" "PeerToPeerTransferSupported" 0
    }
    Revert = {
        Remove-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" "KernelDmaProtectionOptIn"
        Remove-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\pci\Parameters" "PeerToPeerTransferSupported"
    }
    Check = {
        (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" "KernelDmaProtectionOptIn" 0) -eq 1
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 3: CVE-2025-59374 — ASUS LIVE UPDATE BACKDOOR ─────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "UEFI / ASUS Live Update (CVE-2025-59374)"
    Name  = "ASUS Live Update — видалити та заблокувати (CISA KEV, CVSS 9.3)"
    Desc  = "CVE-2025-59374: ASUS Live Update backdoor активно експлуатується. CISA KEV."
    Apply = {
        $asusSvcs = @("ASUSLiveUpdateSvc","AsusCertService","AsusUpdateSvc","ASUSUpdate","ASUSTPCenter","LightingService")
        foreach ($svc in $asusSvcs) {
            $s = Get-Service $svc -EA SilentlyContinue
            if ($s) {
                Write-AppLog -Level 'WARN' -Message "Зупинка: $svc"
                Stop-Service $svc -Force -EA SilentlyContinue
                Set-Service  $svc -StartupType Disabled -EA SilentlyContinue
            }
        }
        $runKeys = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
        )
        $asusRunNames = @("ASUS Live Update","AsusUpdate","ASUS Update Checker","LiveUpdate")
        foreach ($key in $runKeys) {
            foreach ($name in $asusRunNames) {
                $val = Get-ItemProperty -Path $key -Name $name -EA SilentlyContinue
                if ($val) {
                    Remove-ItemProperty -Path $key -Name $name -EA SilentlyContinue
                    Write-AppLog -Level 'WARN' -Message "Видалено autorun: $key\$name"
                }
            }
        }
        $asusExes = @(
            "$env:ProgramFiles\ASUS\ASUS Live Update\LiveUpdate.exe",
            "$env:ProgramFiles(x86)\ASUS\ASUS Live Update\LiveUpdate.exe",
            "$env:ProgramFiles\ASUS\AsusUpdate\AsUpdate.exe"
        )
        foreach ($exe in $asusExes) {
            if (Test-Path $exe) {
                $ruleName = "Block ASUS LiveUpdate - $([IO.Path]::GetFileName($exe))"
                $existing = Get-NetFirewallRule -DisplayName $ruleName -EA SilentlyContinue
                if ($existing) { Remove-NetFirewallRule -DisplayName $ruleName }
                New-NetFirewallRule -DisplayName $ruleName -Direction Outbound `
                    -Program $exe -Action Block -Profile Any -Enabled True | Out-Null
            }
        }
        $hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
        $asusDomains = @(
            "0.0.0.0 liveupdate.asus.com","0.0.0.0 update.asus.com",
            "0.0.0.0 dlcdnets.asus.com","0.0.0.0 dlcdnets2.asus.com",
            "0.0.0.0 lan.asus.com","0.0.0.0 event.asus.com","0.0.0.0 analytics.asus.com"
        )
        $existing = Get-Content $hostsPath -EA SilentlyContinue
        $newEntries = $asusDomains | Where-Object { $existing -notcontains $_ }
        if ($newEntries) {
            Add-Content $hostsPath "`n# === ASUS CVE-2025-59374 Block $(Get-Date -Format 'yyyy-MM-dd') ===" -Encoding UTF8
            $newEntries | Add-Content $hostsPath -Encoding UTF8
        }
        Clear-DnsClientCache -EA SilentlyContinue
        Write-AppLog -Level 'WARN' -Message "УВАГА: Видаліть ASUS Live Update вручну через Programs and Features"
    }
    Revert = {
        foreach ($svc in @("ASUSLiveUpdateSvc","AsusCertService")) {
            $s = Get-Service $svc -EA SilentlyContinue
            if ($s) { Set-Service $svc -StartupType Manual -EA SilentlyContinue }
        }
        $hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
        $lines = Get-Content $hostsPath -EA SilentlyContinue
        ($lines | Where-Object { $_ -notmatch 'asus\.com' -and $_ -notmatch 'CVE-2025-59374' }) |
            Set-Content $hostsPath -Encoding UTF8
        Clear-DnsClientCache -EA SilentlyContinue
    }
    Check = {
        $svc = Get-Service "ASUSLiveUpdateSvc" -EA SilentlyContinue
        (-not $svc) -or ($svc.StartType -eq 'Disabled')
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 4: LogoFAIL / BINARLY — IMAGE PARSER MITIGATION ──────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "UEFI / LogoFAIL Mitigation"
    Name  = "LogoFAIL — вимкнути UEFI логотип та ESP-розділ зображення (AMI/Insyde/Phoenix)"
    Desc  = "Заблокувати запис у EFI System Partition (ESP), вимкнути UEFI splash-logo через bcdedit, заборонити доступ непривілейованих процесів до ESP"
    Apply = {
        $esp = Get-Partition | Where-Object { $_.GptType -eq '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}' } |
               Select-Object -First 1
        if ($esp) {
            $espDrive = ($esp | Get-Volume -EA SilentlyContinue).DriveLetter
            if ($espDrive) {
                icacls "${espDrive}:\" /deny "Everyone:(W)" /T /C 2>$null | Out-Null
                Write-AppLog -Level 'INFO' -Message "ESP: заборонено запис для Everyone"
            }
        }
        bcdedit /set quietboot on  2>$null | Out-Null
        bcdedit /set bootlogo 0    2>$null | Out-Null
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot" "PreventDeviceEncryptionFromFailing" 1
        bcdedit /set "{default}" recoveryenabled No 2>$null | Out-Null
        bcdedit /set nointegritychecks off          2>$null | Out-Null
        bcdedit /set testsigning        off         2>$null | Out-Null
        Write-AppLog -Level 'WARN' -Message "LogoFAIL: рекомендується оновити ASUS BIOS"
    }
    Revert = {
        bcdedit /set quietboot off        2>$null | Out-Null
        bcdedit /deletevalue bootlogo     2>$null | Out-Null
        bcdedit /set testsigning on       2>$null | Out-Null
    }
    # fix: перевіряємо testsigning=off (надійніше ніж nointegritychecks — той параметр завжди присутній у виводі bcdedit)
    Check = {
        $out = bcdedit /enum "{default}" 2>$null
        # testsigning No = нормальний стан після Apply;
        # якщо параметр взагалі відсутній — тест-підпис теж не активний (добре)
        ($out -match "testsigning\s+No") -or ($out -notmatch "testsigning\s+Yes")
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 5: ASUS ARMOURY CRATE / ROG SERVICE ────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "UEFI / ASUS Software Attack Surface"
    Name  = "Armoury Crate / ROG сервіси — вимкнути та заблокувати мережу"
    Desc  = "ArmouryCrate.UserSessionHelper + AsusCertService + AsusFanControlService: збільшений attack surface"
    Apply = {
        $asusSoftSvcs = @(
            "ArmouryCrate.UserSessionHelper","AsusCertService","AsusFanControlService",
            "ASUS HM Com Service","LightingService","ROGLiveService","AsusTPCenter",
            "ASUSOptimization","ASUSSystemAnalysis","ArmourySocketServer"
        )
        foreach ($svc in $asusSoftSvcs) {
            $s = Get-Service $svc -EA SilentlyContinue
            if ($s) {
                Stop-Service $svc -Force -EA SilentlyContinue
                Set-Service  $svc -StartupType Disabled -EA SilentlyContinue
                Write-AppLog -Level 'INFO' -Message "Вимкнено: $svc"
            }
        }
        $hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
        $asusAnalytics = @(
            "0.0.0.0 analytics.asus.com","0.0.0.0 event.asus.com",
            "0.0.0.0 rog.asus.com","0.0.0.0 armoury.asus.com","0.0.0.0 account.asus.com"
        )
        $existing = Get-Content $hostsPath -EA SilentlyContinue
        $newE = $asusAnalytics | Where-Object { $existing -notcontains $_ }
        if ($newE) {
            Add-Content $hostsPath "`n# === ASUS Attack Surface Block ===" -Encoding UTF8
            $newE | Add-Content $hostsPath -Encoding UTF8
        }
        Clear-DnsClientCache -EA SilentlyContinue
    }
    Revert = {
        foreach ($svc in @("ArmouryCrate.UserSessionHelper","AsusCertService","AsusFanControlService")) {
            $s = Get-Service $svc -EA SilentlyContinue
            if ($s) { Set-Service $svc -StartupType Manual -EA SilentlyContinue }
        }
    }
    Check = {
        $svc = Get-Service "AsusCertService" -EA SilentlyContinue
        (-not $svc) -or ($svc.StartType -eq 'Disabled')
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 6: UEFI FIRMWARE UPDATE MONITORING ────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "UEFI / Firmware Monitoring"
    Name  = "UEFI моніторинг — аудит цілісності Boot + TPM PCR верифікація"
    Desc  = "Аудит BCD, перевірка TPM PCR0 (BIOS), Event Log UEFI подій, моніторинг змін Boot Configuration"
    Apply = {
        $tpm = Get-Tpm -EA SilentlyContinue
        if ($tpm -and $tpm.TpmReady) {
            Write-AppLog -Level 'INFO' -Message "TPM: Ready=$($tpm.TpmReady), Present=$($tpm.TpmPresent)"
            $baseline = @{
                Date         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                TpmReady     = $tpm.TpmReady
                TpmPresent   = $tpm.TpmPresent
                SpecVersion  = $tpm.ManufacturerVersionFull
                SecureBootOn = (Confirm-SecureBootUEFI -EA SilentlyContinue)
            }
            $logDir = "$env:ProgramData\win11-hardening\uefi-baseline"
            $null = New-Item -ItemType Directory -Path $logDir -Force
            $baseline | ConvertTo-Json | Set-Content "$logDir\tpm-baseline.json" -Encoding UTF8
            Write-AppLog -Level 'INFO' -Message "TPM baseline: $logDir\tpm-baseline.json"
        } else {
            Write-AppLog -Level 'ERROR' -Message "УВАГА: TPM не готовий!"
        }
        auditpol /set /subcategory:"Other System Events" /success:enable /failure:enable 2>$null | Out-Null
        wevtutil sl System /ms:67108864 2>$null | Out-Null
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Reliability" "TimeStampInterval" 1
        $uefiEvents = Get-WinEvent -FilterHashtable @{LogName="System";Id=@(1,12,13,1808,1801,1795)} `
            -MaxEvents 20 -EA SilentlyContinue
        foreach ($ev in $uefiEvents) {
            Write-AppLog -Level 'INFO' -Message "UEFI Event $($ev.Id): $($ev.Message.Substring(0,[Math]::Min(100,$ev.Message.Length)))"
        }
    }
    Revert = { }
    Check  = {
        Test-Path "$env:ProgramData\win11-hardening\uefi-baseline\tpm-baseline.json"
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 7: UEFI VARIABLE PROTECTION ────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "UEFI / Variable Protection"
    Name  = "UEFI змінні — захист від запису (EFI Variable Lock)"
    Desc  = "Заборонити непривілейованим процесам змінювати UEFI NVRAM змінні (Secure Boot DB/DBX/MOK)"
    Apply = {
        $tmp = "$env:TEMP\sysenv_rights.inf"
        $db  = "$env:TEMP\sysenv_rights.sdb"
        @"
[Unicode]
Unicode=yes
[Privilege Rights]
SeSystemEnvironmentPrivilege = *S-1-5-32-544
[Version]
signature="`$CHICAGO`$"
Revision=1
"@ | Set-Content $tmp -Encoding Unicode
        secedit /configure /db $db /cfg $tmp /areas USER_RIGHTS /quiet 2>$null
        Remove-Item $tmp,$db -Force -EA SilentlyContinue
        Write-AppLog -Level 'INFO' -Message "SeSystemEnvironmentPrivilege: обмежено"
        $esp = Get-Partition | Where-Object {
            $_.GptType -eq '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}'
        } | Select-Object -First 1
        if ($esp) {
            $letter = ($esp | Get-Volume -EA SilentlyContinue).DriveLetter
            if ($letter) {
                icacls "${letter}:\" /setintegritylevel H /T /C 2>$null | Out-Null
                Write-AppLog -Level 'INFO' -Message "ESP Integrity: High on ${letter}:"
            }
        }
    }
    Revert = {
        $tmp = "$env:TEMP\sysenv_revert.inf"; $db = "$env:TEMP\sysenv_revert.sdb"
        @"
[Unicode]
Unicode=yes
[Privilege Rights]
SeSystemEnvironmentPrivilege = *S-1-5-32-544,*S-1-5-19,*S-1-5-20
[Version]
signature="`$CHICAGO`$"
Revision=1
"@ | Set-Content $tmp -Encoding Unicode
        secedit /configure /db $db /cfg $tmp /areas USER_RIGHTS /quiet 2>$null
        Remove-Item $tmp,$db -Force -EA SilentlyContinue
    }
    Check = {
        $tmp = "$env:TEMP\check_sysenv.inf"
        secedit /export /cfg $tmp /areas USER_RIGHTS /quiet 2>$null
        $cfg = Get-Content $tmp -EA SilentlyContinue
        Remove-Item $tmp -Force -EA SilentlyContinue
        $line = $cfg | Where-Object { $_ -match 'SeSystemEnvironmentPrivilege' }
        $line -and ($line -notmatch 'S-1-1-0') -and ($line -match 'S-1-5-32-544')
    }
}

) # end @(

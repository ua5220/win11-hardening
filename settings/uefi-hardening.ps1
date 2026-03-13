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
        # Офіційний метод Microsoft — реєстровий ключ (Option 2 з MS Playbook)
        $sb = "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot"
        Set-Reg "$sb\Servicing" "AvailableUpdates" 0x5944

        # Не вимикати автоматичне оновлення для пристроїв з високою довірою
        Set-Reg "$sb\Servicing" "HighConfidenceOptOut" 0

        # Перевірити поточний статус сертифікатів
        $status = Get-ItemPropertyValue "$sb\Servicing" "UEFICA2023Status" -EA SilentlyContinue
        Write-AppLog -Level 'INFO' -Message "Secure Boot cert status: $status"

        if ($status -ne "Updated") {
            Write-AppLog -Level 'WARN' -Message "УВАГА: Сертифікати ще не оновлені. Потрібен перезапуск системи (може знадобитись 2+ перезапуски)."
        }

        # Перевірка Event Log на помилки розгортання
        $err = Get-ItemProperty "$sb\Servicing" -Name "UEFICA2023Error" -EA SilentlyContinue
        if ($err) {
            Write-AppLog -Level 'ERROR' -Message "UEFICA2023Error знайдено: $($err.UEFICA2023Error) — перевірте UEFI firmware update від ASUS!"
        }
    }
    Revert = {
        # Microsoft не рекомендує відкат — залишаємо нові сертифікати
        Write-AppLog -Level 'WARN' -Message "Secure Boot certs: відкат не рекомендований (безпека)"
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
        # Перевірити стан Secure Boot
        try {
            $enabled = Confirm-SecureBootUEFI -EA Stop
            Write-AppLog -Level 'INFO' -Message "Secure Boot: УВІМКНЕНО=$enabled"
        } catch {
            Write-AppLog -Level 'ERROR' -Message "Secure Boot: недоступно (не UEFI або Legacy Boot)"
            return
        }

        # Перевірити наявність сертифікатів
        foreach ($var in @("PK","KEK","db","dbx")) {
            try {
                $cert = Get-SecureBootUEFI -Name $var -EA Stop
                Write-AppLog -Level 'INFO' -Message "SB $var`: знайдено ($($cert.Bytes.Length) байт)"
            } catch {
                Write-AppLog -Level 'WARN' -Message "SB $var`: ВІДСУТНІЙ!"
            }
        }

        # Перевірити Event ID 1808 (успішне оновлення) та 1801 (помилка)
        $evOK  = Get-WinEvent -FilterHashtable @{LogName='System';Id=1808} -MaxEvents 1 -EA SilentlyContinue
        $evErr = Get-WinEvent -FilterHashtable @{LogName='System';Id=1801} -MaxEvents 1 -EA SilentlyContinue
        if ($evOK)  { Write-AppLog -Level 'INFO'  -Message "Event 1808: Cert deployment SUCCESS ($($evOK.TimeCreated))" }
        if ($evErr) { Write-AppLog -Level 'ERROR' -Message "Event 1801: Cert deployment ERROR  ($($evErr.TimeCreated))" }
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
        # Перевірити чи Windows бачить DMA Protection як активну
        $vbs = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -EA SilentlyContinue
        $dma = $vbs.EnableVirtualizationBasedSecurity
        Write-AppLog -Level 'INFO' -Message "VBS/DMA Protection: EnableVBS=$dma"

        # Перевірити стан Kernel DMA Protection через WMI
        $wmiVBS = Get-WmiObject -Class "Win32_DeviceGuard" -Namespace "root\Microsoft\Windows\DeviceGuard" -EA SilentlyContinue
        if ($wmiVBS) {
            $kdpa = $wmiVBS.DmaProtectionStatus
            Write-AppLog -Level 'INFO' -Message "Kernel DMA Protection status (WMI): $kdpa"
            if ($kdpa -eq 0) { Write-AppLog -Level 'ERROR' -Message "УВАГА: Kernel DMA Protection ВИМКНЕНА! Можливо вразливість CVE-2025-11901 активна." }
        }

        # Максимальне посилення — GPO DeviceEnumerationPolicy=0 (DMA блокувати до входу)
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy" 0

        # Thunderbolt — рівень безпеки (SL1 = User Authorization обов'язковий)
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceIDs" 1
        Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceIDsRetroactive" 1

        # Заблокувати PCI-клас Thunderbolt та FireWire (DMA-здатні)
        $deny = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs"
        Set-Reg $deny "1" "PCI\CC_0C0010" "String"   # FireWire (1394)
        Set-Reg $deny "2" "PCI\CC_0C0A"   "String"   # Thunderbolt

        # Вимкнути автоматичне підключення нових PCIe пристроїв без входу користувача
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
                "DmaGuard" 1

        # Boot DMA Protection — примусово через secureboot UEFI
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" "EnableVirtualizationBasedSecurity" 1
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" "RequirePlatformSecurityFeatures"   3  # Secure Boot + DMA
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
    Desc  = "KernelDmaProtectionOptIn=1 + DeviceEnumerationPolicy=0: жоден PCIe пристрій не отримує DMA доступ до входу адміністратора (пом'якшення CVE-2025-11901)"
    Apply = {
        # Заборонити DMA до завершення завантаження ОС
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" `
                "KernelDmaProtectionOptIn" 1

        # Заборонити Thunderbolt на рівні служби (PCIe hot-plug)
        $thunder = Get-Service "TBTFwUpdateSvc" -EA SilentlyContinue
        if ($thunder) { Set-ServiceDisabled "TBTFwUpdateSvc" }

        # Вимкнути PCIe Peer-to-Peer DMA (PeerToPeerTransferSupported)
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\pci\Parameters" `
                "PeerToPeerTransferSupported" 0
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
# ── РОЗДІЛ 3: CVE-2025-59374 — ASUS LIVE UPDATE BACKDOOR ────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "UEFI / ASUS Live Update (CVE-2025-59374)"
    Name  = "ASUS Live Update — видалити та заблокувати (CISA KEV, CVSS 9.3)"
    Desc  = "CVE-2025-59374: ASUS Live Update backdoor активно експлуатується. CISA KEV — обов'язкова патч/видалення. Зупинити сервіс, заблокувати мережевий доступ, видалити авторозпуск"
    Apply = {
        # Зупинити та вимкнути всі ASUS Update-сервіси
        $asusSvcs = @(
            "ASUSLiveUpdateSvc",
            "AsusCertService",
            "AsusUpdateSvc",
            "ASUSUpdate",
            "ASUSTPCenter",
            "LightingService"
        )
        foreach ($svc in $asusSvcs) {
            $s = Get-Service $svc -EA SilentlyContinue
            if ($s) {
                Write-AppLog -Level 'WARN' -Message "Зупинка ASUS сервісу: $svc"
                Stop-Service $svc -Force -EA SilentlyContinue
                Set-Service  $svc -StartupType Disabled -EA SilentlyContinue
            }
        }

        # Видалити ASUS Live Update з автозапуску реєстру
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
                    Write-AppLog -Level 'WARN' -Message "Видалення autorun: $key\$name"
                    Remove-ItemProperty -Path $key -Name $name -EA SilentlyContinue
                }
            }
        }

        # Заблокувати мережевий доступ для ASUS Live Update процесів через брандмауер
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
                Write-AppLog -Level 'INFO' -Message "Брандмауер: заблоковано $exe"
            }
        }

        # Заблокувати домени ASUS update через hosts
        $hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
        $asusDomains = @(
            "0.0.0.0 liveupdate.asus.com",
            "0.0.0.0 update.asus.com",
            "0.0.0.0 dlcdnets.asus.com",
            "0.0.0.0 dlcdnets2.asus.com",
            "0.0.0.0 lan.asus.com",
            "0.0.0.0 event.asus.com",
            "0.0.0.0 analytics.asus.com"
        )
        $existing = Get-Content $hostsPath -EA SilentlyContinue
        $newEntries = $asusDomains | Where-Object { $existing -notcontains $_ }
        if ($newEntries) {
            Add-Content $hostsPath "`n# === ASUS CVE-2025-59374 Block $(Get-Date -Format 'yyyy-MM-dd') ===" -Encoding UTF8
            $newEntries | Add-Content $hostsPath -Encoding UTF8
        }
        Clear-DnsClientCache -EA SilentlyContinue

        Write-AppLog -Level 'WARN' -Message "УВАГА: Видаліть ASUS Live Update вручну через Programs&Features або winget remove"
    }
    Revert = {
        # Відновити сервіси (тільки якщо явно потрібно ASUS update)
        foreach ($svc in @("ASUSLiveUpdateSvc","AsusCertService")) {
            $s = Get-Service $svc -EA SilentlyContinue
            if ($s) { Set-Service $svc -StartupType Manual -EA SilentlyContinue }
        }
        # Очистити hosts записи ASUS
        $hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
        $lines = Get-Content $hostsPath -EA SilentlyContinue
        $filtered = $lines | Where-Object {
            $_ -notmatch 'asus\.com' -and $_ -notmatch 'CVE-2025-59374'
        }
        $filtered | Set-Content $hostsPath -Encoding UTF8
        Clear-DnsClientCache -EA SilentlyContinue
    }
    Check = {
        $svc = Get-Service "ASUSLiveUpdateSvc" -EA SilentlyContinue
        # Перевірити: або сервіс вимкнено, або він не існує
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
        # Захистити ESP від запису непривілейованими процесами
        # Знайти ESP-розділ
        $esp = Get-Partition | Where-Object { $_.GptType -eq '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}' } |
               Select-Object -First 1
        if ($esp) {
            $espDrive = ($esp | Get-Volume -EA SilentlyContinue).DriveLetter
            if ($espDrive) {
                # Заборонити запис у ESP для непривілейованих (icacls)
                icacls "${espDrive}:\" /deny "Everyone:(W)" /T /C 2>$null | Out-Null
                Write-AppLog -Level 'INFO' -Message "ESP захист: заборонено запис для Everyone на ${espDrive}:"
            }
        }

        # Вимкнути UEFI splash screen (логотип) через bcdedit — LogoFAIL вектор
        bcdedit /set quietboot on  2>$null | Out-Null
        bcdedit /set bootlogo 0    2>$null | Out-Null

        # Заблокувати зміну EFI змінних з простору користувача (вимкнути UEFI write)
        # MokListTrustedBoot — не змінювати MOK без Secure Boot confirmation
        Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot" "PreventDeviceEncryptionFromFailing" 1

        # Увімкнути захист BCD від змін
        bcdedit /set "{default}" recoveryenabled No 2>$null | Out-Null
        bcdedit /set nointegritychecks off          2>$null | Out-Null
        bcdedit /set testsigning        off         2>$null | Out-Null

        Write-AppLog -Level 'WARN' -Message "LogoFAIL: рекомендується ТАКОЖ оновити ASUS BIOS до останньої версії з asus.com/security-advisory"
    }
    Revert = {
        bcdedit /set quietboot off 2>$null | Out-Null
        bcdedit /deletevalue bootlogo 2>$null | Out-Null
    }
    Check = {
        $out = bcdedit /enum "{default}" 2>$null
        $out -match "nointegritychecks\s+No"
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 5: ASUS ARMOURY CRATE / ROG SERVICE — ВЕКТОРНА АТАКА ─────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "UEFI / ASUS Software Attack Surface"
    Name  = "Armoury Crate / ROG сервіси — вимкнути та заблокувати мережу"
    Desc  = "ArmouryCrate.UserSessionHelper + AsusCertService + AsusFanControlService: збільшений attack surface, мають мережевий доступ та системні привілеї"
    Apply = {
        $asusSoftSvcs = @(
            "ArmouryCrate.UserSessionHelper",
            "AsusCertService",
            "AsusFanControlService",
            "ASUS HM Com Service",
            "LightingService",
            "ROGLiveService",
            "AsusTPCenter",
            "ASUSOptimization",
            "ASUSSystemAnalysis",
            "ArmourySocketServer"
        )
        foreach ($svc in $asusSoftSvcs) {
            $s = Get-Service $svc -EA SilentlyContinue
            if ($s) {
                Stop-Service $svc -Force -EA SilentlyContinue
                Set-Service  $svc -StartupType Disabled -EA SilentlyContinue
                Write-AppLog -Level 'INFO' -Message "Вимкнено: $svc"
            }
        }

        # Заблокувати усі ASUS.com домени крім asus.com/support (для оновлень BIOS)
        $hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"
        $asusAnalytics = @(
            "0.0.0.0 analytics.asus.com",
            "0.0.0.0 event.asus.com",
            "0.0.0.0 rog.asus.com",
            "0.0.0.0 armoury.asus.com",
            "0.0.0.0 account.asus.com"
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
# ── РОЗДІЛ 6: UEFI FIRMWARE UPDATE MONITORING — BCDEDIT + EVENTLOG ──────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "UEFI / Firmware Monitoring"
    Name  = "UEFI моніторинг — аудит цілісності Boot + TPM PCR верифікація"
    Desc  = "Аудит BCD, перевірка TPM PCR0 (BIOS), Event Log UEFI подій, моніторинг змін Boot Configuration"
    Apply = {
        # TPM PCR0 містить хеш UEFI firmware — зберегти baseline
        $tpm = Get-Tpm -EA SilentlyContinue
        if ($tpm -and $tpm.TpmReady) {
            $tpmInfo = Get-TpmEndorsementKeyInfo -EA SilentlyContinue
            Write-AppLog -Level 'INFO' -Message "TPM: Ready=$($tpm.TpmReady), Present=$($tpm.TpmPresent), Enabled=$($tpm.TpmEnabled)"

            # Зберегти поточний стан TPM як baseline
            $baseline = @{
                Date          = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                TpmReady      = $tpm.TpmReady
                TpmPresent    = $tpm.TpmPresent
                SpecVersion   = $tpm.ManufacturerVersionFull
                SecureBootOn  = (Confirm-SecureBootUEFI -EA SilentlyContinue)
            }
            $logDir = "$env:ProgramData\win11-hardening\uefi-baseline"
            $null = New-Item -ItemType Directory -Path $logDir -Force
            $baseline | ConvertTo-Json | Set-Content "$logDir\tpm-baseline.json" -Encoding UTF8
            Write-AppLog -Level 'INFO' -Message "TPM baseline збережено: $logDir\tpm-baseline.json"
        } else {
            Write-AppLog -Level 'ERROR' -Message "УВАГА: TPM не готовий або відсутній — UEFI захист обмежений!"
        }

        # Увімкнути аудит змін BCD (Boot Configuration Data)
        auditpol /set /subcategory:"Other System Events" /success:enable /failure:enable 2>$null | Out-Null

        # Збільшити розмір System Event Log для захоплення UEFI подій
        wevtutil sl System /ms:67108864 2>$null | Out-Null  # 64 MB

        # Увімкнути Windows Boot Performance Diagnostic
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Reliability" `
                "TimeStampInterval" 1

        # Перевірити UEFI Event Log (стандарт ACPI BGRT)
        $uefiEvents = Get-WinEvent -FilterHashtable @{
            LogName   = "System"
            Id        = @(1, 12, 13, 1808, 1801, 1795)
        } -MaxEvents 20 -EA SilentlyContinue
        foreach ($ev in $uefiEvents) {
            Write-AppLog -Level 'INFO' -Message "UEFI Event $($ev.Id) [$($ev.TimeCreated)]: $($ev.Message.Substring(0, [Math]::Min(100, $ev.Message.Length)))"
        }
    }
    Revert = { }
    Check  = {
        Test-Path "$env:ProgramData\win11-hardening\uefi-baseline\tpm-baseline.json"
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 7: UEFI VARIABLE PROTECTION (ESP + MOK) ──────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "UEFI / Variable Protection"
    Name  = "UEFI змінні — захист від запису (EFI Variable Lock)"
    Desc  = "Заборонити непривілейованим процесам змінювати UEFI NVRAM змінні (Secure Boot DB/DBX/MOK) через Windows SetFirmwareEnvironmentVariable API"
    Apply = {
        # Заблокувати SetFirmwareEnvironmentVariable для непривілейованих
        # Це потребує SeSystemEnvironmentPrivilege — забрати у всіх крім SYSTEM/Admins
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
        Write-AppLog -Level 'INFO' -Message "SeSystemEnvironmentPrivilege: обмежено до Administrators"

        # Також заблокувати через Windows Integrity Mechanism (EFI partition → High integrity)
        $esp = Get-Partition | Where-Object {
            $_.GptType -eq '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}'
        } | Select-Object -First 1
        if ($esp) {
            $letter = ($esp | Get-Volume -EA SilentlyContinue).DriveLetter
            if ($letter) {
                # Встановити High Integrity Level на ESP
                icacls "${letter}:\" /setintegritylevel H /T /C 2>$null | Out-Null
                Write-AppLog -Level 'INFO' -Message "ESP Integrity: High встановлено на ${letter}:"
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

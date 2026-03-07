<#
.SYNOPSIS
    Windows 11 Hardening GUI v2 — усі скрипти, параметри та ACSC-налаштування в одному файлі
.NOTES
    Вимоги: PowerShell 5.1+, права адміністратора
    Джерела: HardeningGUI.ps1 + scripts/01..40 (26 ACSC-скриптів)
    Запуск: Right-click → Run with PowerShell (або через Run.bat)
#>

# ── Самопідвищення прав ────────────────────────────────────────────────────
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ══════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ══════════════════════════════════════════════════════════════════════════

function Set-Reg {
    param([string]$Path, [string]$Name, $Value, [string]$Type = 'DWord')
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction SilentlyContinue
}

function Get-Reg {
    param([string]$Path, [string]$Name, $Default = $null)
    try { return (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name }
    catch { return $Default }
}

function Set-ServiceDisabled {
    param([string]$Name)
    $s = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($s) {
        Stop-Service  -Name $Name -Force -ErrorAction SilentlyContinue
        Set-Service   -Name $Name -StartupType Disabled -ErrorAction SilentlyContinue
    }
}

function Set-ServiceManual {
    param([string]$Name)
    $s = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($s) { Set-Service -Name $Name -StartupType Manual -ErrorAction SilentlyContinue }
}

function Disable-Task { param([string]$Path,[string]$Name)
    Get-ScheduledTask -TaskPath $Path -TaskName $Name -ErrorAction SilentlyContinue |
        Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null }

function Enable-Task { param([string]$Path,[string]$Name)
    Get-ScheduledTask -TaskPath $Path -TaskName $Name -ErrorAction SilentlyContinue |
        Enable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null }

# ══════════════════════════════════════════════════════════════════════════
# SETTINGS DEFINITIONS
# Кожен запис: Group, Name, Desc, Apply{}, Revert{}, Check{}
# ══════════════════════════════════════════════════════════════════════════

$Settings = @(

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 1: UAC / ВХІД ДО СИСТЕМИ ────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "UAC / Вхід до системи"
        Name  = "UAC рівень 5 — підтвердження без пароля (зручний)"
        Desc  = "ConsentPromptBehaviorAdmin=5: сповіщення без запиту пароля, без secure desktop"
        Apply = {
            $p = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            Set-Reg $p "EnableLUA"                    1
            Set-Reg $p "ConsentPromptBehaviorAdmin"   5
            Set-Reg $p "ConsentPromptBehaviorUser"    3
            Set-Reg $p "PromptOnSecureDesktop"        0
            Set-Reg $p "EnableInstallerDetection"     1
            Set-Reg $p "FilterAdministratorToken"     0
        }
        Revert = {
            $p = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            Set-Reg $p "ConsentPromptBehaviorAdmin"   1
            Set-Reg $p "PromptOnSecureDesktop"        1
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ConsentPromptBehaviorAdmin" -1) -eq 5 }
    },

    [PSCustomObject]@{
        Group = "UAC / Вхід до системи"
        Name  = "UAC суворий — запит пароля на secure desktop (ACSC)"
        Desc  = "FilterAdministratorToken=1, ConsentPromptBehaviorAdmin=1, ConsentPromptBehaviorUser=0"
        Apply = {
            $p = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            Set-Reg $p "FilterAdministratorToken"     1
            Set-Reg $p "ConsentPromptBehaviorAdmin"   1
            Set-Reg $p "ConsentPromptBehaviorUser"    0
            Set-Reg $p "EnableInstallerDetection"     1
            Set-Reg $p "EnableSecureUIAPaths"         1
            Set-Reg $p "EnableLUA"                    1
            Set-Reg $p "EnableVirtualization"         1
            Set-Reg $p "PromptOnSecureDesktop"        1
        }
        Revert = {
            $p = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            Set-Reg $p "FilterAdministratorToken"     0
            Set-Reg $p "ConsentPromptBehaviorAdmin"   5
            Set-Reg $p "ConsentPromptBehaviorUser"    3
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "FilterAdministratorToken" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "UAC / Вхід до системи"
        Name  = "Вимкнути Ctrl+Alt+Del на екрані входу"
        Desc  = "DisableCAD=1: не вимагати натискання Ctrl+Alt+Del перед входом"
        Apply  = { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableCAD" 1 }
        Revert = { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableCAD" 0 }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableCAD" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "UAC / Вхід до системи"
        Name  = "Не показувати мережеве меню на екрані входу"
        Desc  = "DontDisplayNetworkSelectionUI=1"
        Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DontDisplayNetworkSelectionUI" 1 }
        Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DontDisplayNetworkSelectionUI" 0 }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DontDisplayNetworkSelectionUI" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "UAC / Вхід до системи"
        Name  = "Secure credential entry (ACSC 05)"
        Desc  = "DisablePasswordReveal=1, EnumerateAdministrators=0, SoftwareSASGeneration=0, DisableAutomaticRestartSignOn=1"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" "DisablePasswordReveal"        1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" "EnumerateAdministrators"      0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" "EnableSecureCredentialPrompting" 1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnumerateLocalUsers"          0
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "SoftwareSASGeneration"         0
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableMPR"                     0
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableAutomaticRestartSignOn" 1
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" "DisablePasswordReveal"   0
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableAutomaticRestartSignOn" 0
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" "DisablePasswordReveal" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "UAC / Вхід до системи"
        Name  = "Inactivity lock — 15 хв (ACSC 33)"
        Desc  = "InactivityTimeoutSecs=900, screensaver 900s + password, no lock screen camera/slideshow"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "InactivityTimeoutSecs" 900
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreenCamera"   1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreenSlideshow" 1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableLockScreenAppNotifications" 1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsActivateWithVoiceAboveLock" 2
            Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" "ScreenSaveActive"   "1" "String"
            Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" "ScreenSaverIsSecure" "1" "String"
            Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" "ScreenSaveTimeOut"  "900" "String"
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "InactivityTimeoutSecs" 0
            Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" "ScreenSaveActive" "0" "String"
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "InactivityTimeoutSecs" 0) -eq 900 }
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 2: ПАРОЛІ / ОБЛІКОВІ ЗАПИСИ ──────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Паролі / Облікові записи"
        Name  = "Мінімальна довжина пароля = 10"
        Desc  = "net accounts /minpwlen:10"
        Apply  = { net accounts /minpwlen:10 2>$null | Out-Null }
        Revert = { net accounts /minpwlen:0  2>$null | Out-Null }
        Check  = {
            $out  = net accounts 2>$null
            $line = $out | Where-Object { $_ -match 'Minimum password length|Мінімальна довжина' }
            if ($line) { $line -match ':\s*10\b' } else { $false }
        }
    },

    [PSCustomObject]@{
        Group = "Паролі / Облікові записи"
        Name  = "Мінімальна довжина пароля = 15 (ACSC)"
        Desc  = "net accounts /minpwlen:15 /maxpwage:unlimited — відповідно до вимог ACSC"
        Apply  = {
            net accounts /minpwlen:15 2>$null | Out-Null
            net accounts /maxpwage:unlimited 2>$null | Out-Null
        }
        Revert = { net accounts /minpwlen:0 2>$null | Out-Null }
        Check  = {
            $out  = net accounts 2>$null
            $line = $out | Where-Object { $_ -match 'Minimum password length|Мінімальна довжина' }
            if ($line) { $line -match ':\s*15\b' } else { $false }
        }
    },

    [PSCustomObject]@{
        Group = "Паролі / Облікові записи"
        Name  = "Заборонити порожні паролі (лише консоль)"
        Desc  = "LimitBlankPasswordUse=1"
        Apply  = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LimitBlankPasswordUse" 1 }
        Revert = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LimitBlankPasswordUse" 0 }
        Check  = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LimitBlankPasswordUse" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "Паролі / Облікові записи"
        Name  = "Account Lockout: поріг 5, тривалість 0 (ACSC 20)"
        Desc  = "Блокування після 5 невдалих спроб, тільки ручне розблокування"
        Apply = {
            net accounts /lockoutthreshold:5 2>$null | Out-Null
            $r = net accounts /lockoutduration:0 2>&1
            if ($r -match "error|incorrect") {
                $tmp = "$env:TEMP\acsc_lockout.inf"; $db = "$env:TEMP\acsc_lockout.sdb"
                "[Unicode]`r`nUnicode=yes`r`n[System Access]`r`nLockoutBadCount = 5`r`nResetLockoutCount = 15`r`nLockoutDuration = 0`r`n[Version]`r`nsignature=""`$CHICAGO`$""`r`nRevision=1" | Set-Content $tmp -Encoding Unicode
                secedit /configure /db $db /cfg $tmp /areas SECURITYPOLICY /quiet 2>$null
                Remove-Item $tmp,$db -Force -ErrorAction SilentlyContinue
            } else { net accounts /lockoutwindow:15 2>$null | Out-Null }
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "AllowAdministratorLockout" 1
        }
        Revert = {
            net accounts /lockoutthreshold:0 2>$null | Out-Null
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "AllowAdministratorLockout" 0
        }
        Check = {
            $out = net accounts 2>$null
            $line = $out | Where-Object { $_ -match 'Lockout threshold|Поріг блокування' }
            if ($line) { $line -match ':\s*5\b' } else { $false }
        }
    },

    [PSCustomObject]@{
        Group = "Паролі / Облікові записи"
        Name  = "Вимкнути гостьовий обліковий запис"
        Desc  = "EnableGuestAccount=0"
        Apply  = { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableGuestAccount" 0 }
        Revert = { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableGuestAccount" 1 }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableGuestAccount" 1) -eq 0 }
    },

    [PSCustomObject]@{
        Group = "Паролі / Облікові записи"
        Name  = "LAPS — локальний адмін з автоматичним паролем (ACSC 08)"
        Desc  = "AdmPwdEnabled=1, довжина 30, складний пароль, шифрування в AD"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft Services\AdmPwd" "AdmPwdEnabled" 1
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "BackupDirectory"              1
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordComplexity"           4
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordLength"               30
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordAgeDays"              365
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "ADPasswordEncryptionEnabled"  1
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "LocalAccountTokenFilterPolicy" 0
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft Services\AdmPwd" "AdmPwdEnabled" 0
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "LocalAccountTokenFilterPolicy" 1
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft Services\AdmPwd" "AdmPwdEnabled" 0) -eq 1 }
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 3: DEFENDER / ANTIVIRUS ──────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Defender / Antivirus"
        Name  = "Вимкнути Real-Time моніторинг Defender"
        Desc  = "DisableRealtimeMonitoring=1 (для тестових середовищ)"
        Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableRealtimeMonitoring" 1 }
        Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableRealtimeMonitoring" 0 }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableRealtimeMonitoring" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "Defender / Antivirus"
        Name  = "Defender ACSC — повна безпечна конфігурація (ACSC 22)"
        Desc  = "PUA Block, MAPS Advanced, Block at First Sight, хмарна перевірка 50с, сканування email/USB/архівів"
        Apply = {
            $d = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
            Set-Reg $d "PUAProtection"              1
            Set-Reg $d "DisableLocalAdminMerge"     1
            Set-Reg $d "HideExclusionsFromLocalAdmins" 1
            Set-Reg $d "DisableAntiSpyware"         0
            Set-Reg $d "DisableRoutinelyTakingAction" 0
            Set-Reg "$d\Spynet" "LocalSettingOverrideSpynetReporting" 0
            Set-Reg "$d\Spynet" "DisableBlockAtFirstSeen"             0
            Set-Reg "$d\Spynet" "SpynetReporting"                     2
            Set-Reg "$d\Spynet" "SubmitSamplesConsent"                1
            Set-Reg "$d\MpEngine" "MpBafsExtendedTimeout"             50
            Set-Reg "$d\MpEngine" "EnableFileHashComputation"         1
            Set-Reg "$d\MpEngine" "MpCloudBlockLevel"                 2
            Set-Reg "$d\Quarantine" "PurgeItemsAfterDelay"            0
            $rt = "$d\Real-Time Protection"
            Set-Reg $rt "DisableIOAVProtection"        0
            Set-Reg $rt "DisableRealtimeMonitoring"    0
            Set-Reg $rt "DisableBehaviorMonitoring"    0
            Set-Reg $rt "DisableScanOnRealtimeEnable"  0
            Set-Reg $rt "DisableScriptScanning"        0
            $sc = "$d\Scan"
            Set-Reg $sc "DisablePauseOnIdleTask"       1
            Set-Reg $sc "CheckForSignaturesBeforeRunningScan" 1
            Set-Reg $sc "DisableArchiveScanning"       0
            Set-Reg $sc "DisablePackedExeScanning"     0
            Set-Reg $sc "DisableRemovableDriveScanning" 0
            Set-Reg $sc "DisableEmailScanning"         0
            Set-Reg $sc "DisableHeuristics"            0
        }
        Revert = {
            $d = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
            Set-Reg $d "PUAProtection" 0
            Set-Reg "$d\Spynet" "SpynetReporting" 0
            Set-Reg "$d\Spynet" "SubmitSamplesConsent" 2
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" "PUAProtection" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "Defender / Antivirus"
        Name  = "Вимкнути Cloud Protection (MAPS)"
        Desc  = "SpynetReporting=0, SubmitSamplesConsent=2 — вимкнути хмарну перевірку"
        Apply  = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "SpynetReporting"      0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "SubmitSamplesConsent" 2
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "SpynetReporting"      2
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "SubmitSamplesConsent" 1
        }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "SpynetReporting" -1) -eq 0 }
    },

    [PSCustomObject]@{
        Group = "Defender / Antivirus"
        Name  = "ASR Rules — 16 правил Attack Surface Reduction (ACSC 02)"
        Desc  = "Всі 16 ASR-правил у режимі Block: захист від Office-макросів, LSASS, WMI, скриптів, USB тощо"
        Apply = {
            $rp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR"
            $ru = "$rp\Rules"
            Set-Reg $rp "ExploitGuard_ASR_Rules" 1
            if (-not (Test-Path $ru)) { New-Item -Path $ru -Force | Out-Null }
            $guids = @(
                "56a863a9-875e-4185-98a7-b882c64b5ce5","7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c",
                "d4f940ab-401b-4efc-aadc-ad5f3c50688a","9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2",
                "be9ba2d9-53ea-4cdc-84e5-9b1eeee46550","01443614-cd74-433a-b99e-2ecdc07bfc25",
                "5beb7efe-fd9a-4556-801d-275e5ffc04cc","d3e037e1-3eb8-44c8-a917-57927947596d",
                "3b576869-a4ec-4529-8536-b80a7769e899","75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84",
                "26190899-1602-49e8-8b27-eb1d0a1ce869","e6db77e5-3df2-4cf1-b95a-636979351e5b",
                "d1e49aac-8f56-4280-b9ba-993a6d77406c","b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4",
                "92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b","c1db55ab-c21a-4637-bb3f-a12568109d35"
            )
            foreach ($g in $guids) { Set-Reg $ru $g 1 }
            try {
                Set-MpPreference -AttackSurfaceReductionRules_Ids ([string[]]$guids) `
                    -AttackSurfaceReductionRules_Actions (@(1)*$guids.Count) -ErrorAction SilentlyContinue
            } catch {}
        }
        Revert = {
            $ru = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules"
            if (Test-Path $ru) { Remove-Item $ru -Recurse -Force -ErrorAction SilentlyContinue }
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR" "ExploitGuard_ASR_Rules" 0
        }
        Check = {
            $rp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR"
            (Get-Reg $rp "ExploitGuard_ASR_Rules" 0) -eq 1
        }
    },

    [PSCustomObject]@{
        Group = "Defender / Antivirus"
        Name  = "Controlled Folder Access — захист від ransomware (ACSC 04)"
        Desc  = "EnableControlledFolderAccess=1 через реєстр та Set-MpPreference"
        Apply = {
            $p = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access"
            Set-Reg $p "EnableControlledFolderAccess" 1
            try { Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction SilentlyContinue } catch {}
        }
        Revert = {
            $p = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access"
            Set-Reg $p "EnableControlledFolderAccess" 0
            try { Set-MpPreference -EnableControlledFolderAccess Disabled -ErrorAction SilentlyContinue } catch {}
        }
        Check = {
            $p = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access"
            (Get-Reg $p "EnableControlledFolderAccess" 0) -eq 1
        }
    },

    [PSCustomObject]@{
        Group = "Defender / Antivirus"
        Name  = "Exploit Protection — DEP, SEHOP, ASLR (ACSC 03)"
        Desc  = "DisallowExploitProtectionOverride=1, SEHOP увімкнено, DEP для Explorer"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection" "DisallowExploitProtectionOverride" 1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoDataExecutionPrevention" 0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoTurnOffSPIAndSAI"       1
            Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "DisableExceptionChainValidation" 0
            try { Set-ProcessMitigation -System -Enable DEP,EmulateAtlThunks,SEHOP,ForceRelocateImages,BottomUp,HighEntropy,CFG -ErrorAction SilentlyContinue } catch {}
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection" "DisallowExploitProtectionOverride" 0
        }
        Check = {
            (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection" "DisallowExploitProtectionOverride" 0) -eq 1
        }
    },

    [PSCustomObject]@{
        Group = "Defender / Antivirus"
        Name  = "Early Launch Antimalware — ELAM (ACSC 07)"
        Desc  = "DriverLoadPolicy=3: завантажувати good, unknown та bad-but-critical драйвери"
        Apply  = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch" "DriverLoadPolicy" 3 }
        Revert = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch" "DriverLoadPolicy" 7 }
        Check  = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch" "DriverLoadPolicy" -1) -eq 3 }
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 4: SMARTSCREEN / RECALL / ТЕЛЕМЕТРІЯ ─────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "SmartScreen / Recall / Телеметрія"
        Name  = "Вимкнути SmartScreen (Explorer)"
        Desc  = "EnableSmartScreen=0 — вимкнути перевірку завантажень у провіднику"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableSmartScreen" 0
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" "SmartScreenEnabled" "Off" "String"
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableSmartScreen" 1
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" "SmartScreenEnabled" "Warn" "String"
        }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableSmartScreen" 1) -eq 0 }
    },

    [PSCustomObject]@{
        Group = "SmartScreen / Recall / Телеметрія"
        Name  = "SmartScreen ACSC — увімкнути та заблокувати обхід (ACSC 34)"
        Desc  = "EnableSmartScreen=1, ShellSmartScreenLevel=Block — не дозволяти обхід"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableSmartScreen"     1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "ShellSmartScreenLevel" "Block" "String"
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "ShellSmartScreenLevel" "Warn" "String"
        }
        Check = {
            $v = Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "ShellSmartScreenLevel" ""
            $v -eq "Block"
        }
    },

    [PSCustomObject]@{
        Group = "SmartScreen / Recall / Телеметрія"
        Name  = "Вимкнути Windows Recall (AIX сервіс)"
        Desc  = "Вимкнути сервіс AiXHostService + DisableAIDataAnalysis=1"
        Apply = {
            Set-ServiceDisabled "AiXHostService"
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" 1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "AllowRecallEnablement" 0
        }
        Revert = {
            Set-ServiceManual "AiXHostService"
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" 0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "AllowRecallEnablement" 1
        }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "SmartScreen / Recall / Телеметрія"
        Name  = "Вимкнути телеметрію (DiagTrack + AllowTelemetry=0)"
        Desc  = "AllowTelemetry=0, зупинити DiagTrack та dmwappushservice"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0
            Set-ServiceDisabled "DiagTrack"
            Set-ServiceDisabled "dmwappushservice"
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 1
            Set-ServiceManual "DiagTrack"
        }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" -1) -eq 0 }
    },

    [PSCustomObject]@{
        Group = "SmartScreen / Recall / Телеметрія"
        Name  = "Вимкнути SmartScreen сервіс (webthreatdefsvc)"
        Desc  = "Зупинити та вимкнути webthreatdefsvc + webthreatdefusersvc"
        Apply = {
            Set-ServiceDisabled "webthreatdefsvc"
            Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\webthreatdefsvc" "Start" 4
        }
        Revert = {
            Set-ServiceManual "webthreatdefsvc"
            Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\webthreatdefsvc" "Start" 3
        }
        Check  = {
            $s = Get-Service "webthreatdefsvc" -ErrorAction SilentlyContinue
            $s -and $s.StartType -eq 'Disabled'
        }
    },

    [PSCustomObject]@{
        Group = "SmartScreen / Recall / Телеметрія"
        Name  = "Вимкнути Microsoft Consumer Experiences + OneDrive"
        Desc  = "DisableWindowsConsumerFeatures=1, DisableFileSyncNGSC=1, DisableUserAuth=1"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"    "DisableWindowsConsumerFeatures" 1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"        "DisableFileSyncNGSC"            1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount"        "DisableUserAuth"                1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppRuntime"      "AllowMicrosoftAccountsToBeOptional" 1
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"     "DisableFileSyncNGSC"            0
        }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 0) -eq 1 }
    },

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
        Name  = "DMA Protection — заблокувати FireWire/Thunderbolt (ACSC 26)"
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
        Desc  = "EnableMulticast=0, RestrictRemoteClients=1, Hardened UNC paths SYSVOL/NETLOGON"
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
# ── РОЗДІЛ 6: ШИФРУВАННЯ / BITLOCKER / ПРИСТРОЇ ─────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Шифрування / BitLocker"
        Name  = "BitLocker — XTS-AES 128 + AD backup + мін PIN 15 (ACSC 27)"
        Desc  = "EncryptionMethod XTS-AES128, AD backup required, Full encryption, PIN min 15, DMA disabled when locked"
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
        Desc  = "EnableVirtualizationBasedSecurity=1, LsaCfgFlags=1 (UEFI lock), RunAsPPL=1, WDigest вимкнено"
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
        Desc  = "ProcessCreationIncludeCmdLine, event log sizes, advanced audit: logon/object/policy/system"
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
                $sf = if ($s -in @("Process Termination","Logoff","Group Membership","Process Creation")) { "enable" } else { "enable" }
                auditpol /set /subcategory:"$s" /success:enable /failure:enable 2>$null | Out-Null
            }
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" "ProcessCreationIncludeCmdLine_Enabled" 0
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" "ProcessCreationIncludeCmdLine_Enabled" 0) -eq 1 }
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
        Desc  = "DoSvc=Disabled, DODownloadMode=0, dnscache=Disabled"
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
        Desc  = "NoAutoUpdate=0, AUOptions=4 (auto download+install), AllowMUUpdateService=1"
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
    }

) # кінець $Settings

# ══════════════════════════════════════════════════════════════════════════
# GUI BUILDER
# ══════════════════════════════════════════════════════════════════════════

$form = New-Object System.Windows.Forms.Form
$form.Text          = "Windows 11 Hardening Control Panel v2"
$form.Size          = New-Object System.Drawing.Size(900, 760)
$form.MinimumSize   = New-Object System.Drawing.Size(800, 600)
$form.StartPosition = "CenterScreen"
$form.BackColor     = [System.Drawing.Color]::FromArgb(18, 18, 24)
$form.ForeColor     = [System.Drawing.Color]::FromArgb(220, 220, 230)
$form.Font          = New-Object System.Drawing.Font("Segoe UI", 9)

# ── Title bar ─────────────────────────────────────────────────────────────
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text      = "  Windows 11 Hardening Control Panel  v2  —  ACSC + Privacy"
$lblTitle.Dock      = "Top"
$lblTitle.Height    = 42
$lblTitle.Font      = New-Object System.Drawing.Font("Segoe UI Semibold", 13)
$lblTitle.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 40)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(100, 180, 255)
$lblTitle.TextAlign = "MiddleLeft"
$form.Controls.Add($lblTitle)

# ── Status bar ────────────────────────────────────────────────────────────
$statusBar = New-Object System.Windows.Forms.Label
$statusBar.Dock      = "Bottom"
$statusBar.Height    = 26
$statusBar.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 35)
$statusBar.ForeColor = [System.Drawing.Color]::FromArgb(160, 160, 170)
$statusBar.TextAlign = "MiddleLeft"
$statusBar.Text      = "  Готово. Налаштувань: $($Settings.Count)"
$statusBar.Font      = New-Object System.Drawing.Font("Segoe UI", 8.5)
$form.Controls.Add($statusBar)

# ── Bottom button panel ───────────────────────────────────────────────────
$btnPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$btnPanel.Dock          = "Bottom"
$btnPanel.Height        = 48
$btnPanel.BackColor     = [System.Drawing.Color]::FromArgb(22, 22, 32)
$btnPanel.FlowDirection = "LeftToRight"
$btnPanel.Padding       = New-Object System.Windows.Forms.Padding(10, 8, 0, 0)

function New-Btn {
    param([string]$Text, [string]$ColorHex, [string]$ToolTip = "")
    $b = New-Object System.Windows.Forms.Button
    $b.Text      = $Text
    $b.Height    = 30
    $b.Width     = 155
    $b.Margin    = New-Object System.Windows.Forms.Padding(0, 0, 8, 0)
    $b.FlatStyle = "Flat"
    $b.FlatAppearance.BorderSize = 1
    $b.BackColor = [System.Drawing.ColorTranslator]::FromHtml($ColorHex)
    $b.ForeColor = [System.Drawing.Color]::White
    $b.Font      = New-Object System.Drawing.Font("Segoe UI Semibold", 9)
    $b.Cursor    = "Hand"
    if ($ToolTip) {
        $tt = New-Object System.Windows.Forms.ToolTip
        $tt.SetToolTip($b, $ToolTip)
    }
    return $b
}

$btnApplyAll      = New-Btn "Застосувати все"     "#1a6b3a" "Застосувати всі параметри"
$btnApplySelected = New-Btn "Застосувати вибране" "#3a5a1a" "Застосувати відмічені параметри"
$btnRevertAll     = New-Btn "Скасувати все"       "#7a2020" "Повернути до стандарту Windows"
$btnRefresh       = New-Btn "Оновити стани"       "#1a3a6b" "Перечитати поточні значення"
$btnPanel.Controls.AddRange(@($btnApplyAll, $btnApplySelected, $btnRevertAll, $btnRefresh))
$form.Controls.Add($btnPanel)

# ── Main scroll panel ─────────────────────────────────────────────────────
$scroll = New-Object System.Windows.Forms.Panel
$scroll.Dock        = "Fill"
$scroll.AutoScroll  = $true
$scroll.BackColor   = [System.Drawing.Color]::FromArgb(18, 18, 24)
$form.Controls.Add($scroll)

$rowControls = [System.Collections.ArrayList]::new()

function Get-SettingStatus {
    param($setting)
    try { return [bool](& $setting.Check) }
    catch { return $false }
}

function Build-Rows {
    $scroll.Controls.Clear()
    $rowControls.Clear()

    $y = 8; $lastGroup = ""; $rowIndex = 0

    foreach ($s in $Settings) {
        if ($s.Group -ne $lastGroup) {
            $lbl = New-Object System.Windows.Forms.Label
            $lbl.Text      = "  " + $s.Group
            $lbl.Location  = New-Object System.Drawing.Point(10, $y)
            $lbl.Size      = New-Object System.Drawing.Size(860, 28)
            $lbl.Font      = New-Object System.Drawing.Font("Segoe UI Semibold", 10)
            $lbl.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 50)
            $lbl.ForeColor = [System.Drawing.Color]::FromArgb(130, 190, 255)
            $scroll.Controls.Add($lbl)
            $y += 32
            $lastGroup = $s.Group
        }

        $rowBg = if ($rowIndex % 2 -eq 0) { [System.Drawing.Color]::FromArgb(24,24,33) } else { [System.Drawing.Color]::FromArgb(28,28,38) }
        $row = New-Object System.Windows.Forms.Panel
        $row.Location  = New-Object System.Drawing.Point(10, $y)
        $row.Size      = New-Object System.Drawing.Size(860, 46)
        $row.BackColor = $rowBg

        $chk = New-Object System.Windows.Forms.CheckBox
        $chk.Location  = New-Object System.Drawing.Point(8, 14)
        $chk.Size      = New-Object System.Drawing.Size(20, 20)
        $chk.BackColor = $rowBg

        $active = Get-SettingStatus $s

        $statusDot = New-Object System.Windows.Forms.Label
        $statusDot.Location  = New-Object System.Drawing.Point(32, 8)
        $statusDot.Size      = New-Object System.Drawing.Size(10, 30)
        $statusDot.Text      = ""
        $statusDot.BackColor = if ($active) { [System.Drawing.Color]::FromArgb(40,180,80) } else { [System.Drawing.Color]::FromArgb(160,40,40) }

        $lblName = New-Object System.Windows.Forms.Label
        $lblName.Text      = "  " + $s.Name
        $lblName.Location  = New-Object System.Drawing.Point(46, 4)
        $lblName.Size      = New-Object System.Drawing.Size(520, 20)
        $lblName.Font      = New-Object System.Drawing.Font("Segoe UI", 9)
        $lblName.ForeColor = [System.Drawing.Color]::FromArgb(220,220,230)
        $lblName.BackColor = $rowBg

        $lblDesc = New-Object System.Windows.Forms.Label
        $lblDesc.Text      = "  " + $s.Desc
        $lblDesc.Location  = New-Object System.Drawing.Point(46, 24)
        $lblDesc.Size      = New-Object System.Drawing.Size(520, 18)
        $lblDesc.Font      = New-Object System.Drawing.Font("Segoe UI", 7.5)
        $lblDesc.ForeColor = [System.Drawing.Color]::FromArgb(130,130,150)
        $lblDesc.BackColor = $rowBg

        $statusLbl = New-Object System.Windows.Forms.Label
        $statusLbl.Location  = New-Object System.Drawing.Point(572, 14)
        $statusLbl.Size      = New-Object System.Drawing.Size(90, 18)
        $statusLbl.Font      = New-Object System.Drawing.Font("Segoe UI Semibold", 8)
        $statusLbl.TextAlign = "MiddleCenter"
        $statusLbl.BackColor = $rowBg
        if ($active) {
            $statusLbl.Text      = "УВІМКНЕНО"
            $statusLbl.ForeColor = [System.Drawing.Color]::FromArgb(60,200,100)
        } else {
            $statusLbl.Text      = "вимкнено"
            $statusLbl.ForeColor = [System.Drawing.Color]::FromArgb(160,160,180)
        }

        $toggleBtn = New-Object System.Windows.Forms.Button
        $toggleBtn.Location  = New-Object System.Drawing.Point(668, 9)
        $toggleBtn.Size      = New-Object System.Drawing.Size(90, 28)
        $toggleBtn.FlatStyle = "Flat"
        $toggleBtn.FlatAppearance.BorderSize = 1
        $toggleBtn.Font   = New-Object System.Drawing.Font("Segoe UI Semibold", 8.5)
        $toggleBtn.Cursor = "Hand"
        if ($active) {
            $toggleBtn.Text      = "Вимкнути"
            $toggleBtn.BackColor = [System.Drawing.Color]::FromArgb(90, 30, 30)
            $toggleBtn.ForeColor = [System.Drawing.Color]::FromArgb(255,140,140)
        } else {
            $toggleBtn.Text      = "Увімкнути"
            $toggleBtn.BackColor = [System.Drawing.Color]::FromArgb(20, 70, 30)
            $toggleBtn.ForeColor = [System.Drawing.Color]::FromArgb(120,220,140)
        }

        $infoBtn = New-Object System.Windows.Forms.Button
        $infoBtn.Location  = New-Object System.Drawing.Point(764, 9)
        $infoBtn.Size      = New-Object System.Drawing.Size(86, 28)
        $infoBtn.FlatStyle = "Flat"
        $infoBtn.FlatAppearance.BorderSize = 1
        $infoBtn.Text      = "Деталі"
        $infoBtn.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 55)
        $infoBtn.ForeColor = [System.Drawing.Color]::FromArgb(150,180,255)
        $infoBtn.Font      = New-Object System.Drawing.Font("Segoe UI", 8.5)
        $infoBtn.Cursor    = "Hand"

        $capturedS      = $s
        $capturedStatus = $statusDot
        $capturedSLbl   = $statusLbl
        $capturedToggle = $toggleBtn
        $capturedBar    = $statusBar
        $capturedRowBg  = $rowBg

        $toggleBtn.Add_Click({
            $isActive = Get-SettingStatus $capturedS
            try {
                if ($isActive) { & $capturedS.Revert; $capturedBar.Text = "  [OK] Скасовано: $($capturedS.Name)" }
                else           { & $capturedS.Apply;  $capturedBar.Text = "  [OK] Застосовано: $($capturedS.Name)" }
            } catch { $capturedBar.Text = "  [ПОМИЛКА] $($capturedS.Name): $_" }
            $now = Get-SettingStatus $capturedS
            if ($now) {
                $capturedStatus.BackColor = [System.Drawing.Color]::FromArgb(40,180,80)
                $capturedSLbl.Text        = "УВІМКНЕНО"
                $capturedSLbl.ForeColor   = [System.Drawing.Color]::FromArgb(60,200,100)
                $capturedToggle.Text      = "Вимкнути"
                $capturedToggle.BackColor = [System.Drawing.Color]::FromArgb(90,30,30)
                $capturedToggle.ForeColor = [System.Drawing.Color]::FromArgb(255,140,140)
            } else {
                $capturedStatus.BackColor = [System.Drawing.Color]::FromArgb(160,40,40)
                $capturedSLbl.Text        = "вимкнено"
                $capturedSLbl.ForeColor   = [System.Drawing.Color]::FromArgb(160,160,180)
                $capturedToggle.Text      = "Увімкнути"
                $capturedToggle.BackColor = [System.Drawing.Color]::FromArgb(20,70,30)
                $capturedToggle.ForeColor = [System.Drawing.Color]::FromArgb(120,220,140)
            }
        }.GetNewClosure())

        $infoBtn.Add_Click({
            [System.Windows.Forms.MessageBox]::Show(
                "Параметр: $($capturedS.Name)`n`n$($capturedS.Desc)`n`nГрупа: $($capturedS.Group)",
                "Деталі", [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
        }.GetNewClosure())

        $row.Controls.AddRange(@($chk, $statusDot, $lblName, $lblDesc, $statusLbl, $toggleBtn, $infoBtn))
        $scroll.Controls.Add($row)
        $null = $rowControls.Add([PSCustomObject]@{
            Checkbox  = $chk
            Toggle    = $toggleBtn
            Setting   = $s
            StatusDot = $statusDot
            StatusLbl = $statusLbl
        })
        $y += 50; $rowIndex++
    }

    $spacer = New-Object System.Windows.Forms.Panel
    $spacer.Location  = New-Object System.Drawing.Point(0, $y)
    $spacer.Size      = New-Object System.Drawing.Size(1, 20)
    $spacer.BackColor = [System.Drawing.Color]::FromArgb(18,18,24)
    $scroll.Controls.Add($spacer)
    $scroll.AutoScrollMinSize = New-Object System.Drawing.Size(860, ($y + 30))
}

Build-Rows

# ── Button handlers ───────────────────────────────────────────────────────
$btnRefresh.Add_Click({
    $statusBar.Text = "  Оновлення станів..."
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    foreach ($rc in $rowControls) {
        $active = Get-SettingStatus $rc.Setting
        if ($active) {
            $rc.StatusDot.BackColor = [System.Drawing.Color]::FromArgb(40,180,80)
            $rc.StatusLbl.Text      = "УВІМКНЕНО"
            $rc.StatusLbl.ForeColor = [System.Drawing.Color]::FromArgb(60,200,100)
            $rc.Toggle.Text         = "Вимкнути"
            $rc.Toggle.BackColor    = [System.Drawing.Color]::FromArgb(90,30,30)
            $rc.Toggle.ForeColor    = [System.Drawing.Color]::FromArgb(255,140,140)
        } else {
            $rc.StatusDot.BackColor = [System.Drawing.Color]::FromArgb(160,40,40)
            $rc.StatusLbl.Text      = "вимкнено"
            $rc.StatusLbl.ForeColor = [System.Drawing.Color]::FromArgb(160,160,180)
            $rc.Toggle.Text         = "Увімкнути"
            $rc.Toggle.BackColor    = [System.Drawing.Color]::FromArgb(20,70,30)
            $rc.Toggle.ForeColor    = [System.Drawing.Color]::FromArgb(120,220,140)
        }
    }
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
    $statusBar.Text = "  Стани оновлено."
})

$btnApplyAll.Add_Click({
    $res = [System.Windows.Forms.MessageBox]::Show(
        "Застосувати ВСІ $($Settings.Count) параметрів?`nЦе змінить налаштування системи.",
        "Підтвердження", "YesNo", "Warning")
    if ($res -ne "Yes") { return }
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    $ok = 0; $err = 0
    foreach ($s in $Settings) {
        try { & $s.Apply; $ok++ }
        catch { $err++; $statusBar.Text = "  [ПОМИЛКА] $($s.Name): $_" }
    }
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
    & $btnRefresh.PerformClick
    $statusBar.Text = "  Готово: застосовано $ok, помилок $err."
})

$btnApplySelected.Add_Click({
    $selected = @($rowControls | Where-Object { $_.Checkbox.Checked })
    if ($selected.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Не вибрано жодного параметру.","Увага","OK","Information") | Out-Null
        return
    }
    $res = [System.Windows.Forms.MessageBox]::Show(
        "Застосувати $($selected.Count) вибраних параметрів?",
        "Підтвердження", "YesNo", "Question")
    if ($res -ne "Yes") { return }
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    $ok = 0; $err = 0
    foreach ($rc in $selected) {
        try { & $rc.Setting.Apply; $ok++ } catch { $err++ }
        $rc.Checkbox.Checked = $false
    }
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
    & $btnRefresh.PerformClick
    $statusBar.Text = "  Вибране застосовано: $ok OK, $err помилок."
})

$btnRevertAll.Add_Click({
    $res = [System.Windows.Forms.MessageBox]::Show(
        "СКАСУВАТИ всі параметри і повернути до стандарту Windows?",
        "Підтвердження", "YesNo", "Warning")
    if ($res -ne "Yes") { return }
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    foreach ($s in $Settings) { try { & $s.Revert } catch {} }
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
    & $btnRefresh.PerformClick
    $statusBar.Text = "  Всі параметри скасовано."
})

# ── Launch ────────────────────────────────────────────────────────────────
[System.Windows.Forms.Application]::Run($form)

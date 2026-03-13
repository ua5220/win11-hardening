<#
.SYNOPSIS
    Hardening settings data for HardeningGUI_v2
.NOTES
    Dot-sourced by HardeningGUI_v2.ps1 after helpers.ps1.
    Exports: Get-HardeningSettings
    Does NOT contain any UI code or button handlers.
#>

function Get-HardeningSettings {
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
        Name  = "Hosts-файл — виключити зі сканування Defender"
        Desc  = "Додає hosts до Exclusions\Paths на policy-рівні (обходить DisableLocalAdminMerge=1 з ACSC-блоку)"
        Apply = {
            $hp = "$env:SystemRoot\System32\drivers\etc\hosts"
            $rp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths"
            if (-not (Test-Path $rp)) { New-Item -Path $rp -Force | Out-Null }
            Set-ItemProperty -Path $rp -Name $hp -Value 0 -Type DWord -ErrorAction SilentlyContinue
            try { Add-MpPreference -ExclusionPath $hp -ErrorAction SilentlyContinue } catch {}
        }
        Revert = {
            $hp = "$env:SystemRoot\System32\drivers\etc\hosts"
            $rp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths"
            Remove-ItemProperty -Path $rp -Name $hp -ErrorAction SilentlyContinue
            try { Remove-MpPreference -ExclusionPath $hp -ErrorAction SilentlyContinue } catch {}
        }
        Check = {
            $hp = "$env:SystemRoot\System32\drivers\etc\hosts"
            $rp = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths"
            (Test-Path $rp) -and ((Get-ItemProperty -Path $rp -ErrorAction SilentlyContinue).$hp -eq 0)
        }
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
            } catch { Write-AppLog -Level 'WARN' -Message "ASR Set-MpPreference :: $($_.Exception.Message)" }
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
            try { Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction SilentlyContinue } catch { Write-AppLog -Level 'WARN' -Message "CFA Enable :: $($_.Exception.Message)" }
        }
        Revert = {
            $p = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access"
            Set-Reg $p "EnableControlledFolderAccess" 0
            try { Set-MpPreference -EnableControlledFolderAccess Disabled -ErrorAction SilentlyContinue } catch { Write-AppLog -Level 'WARN' -Message "CFA Disable :: $($_.Exception.Message)" }
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
            try { Set-ProcessMitigation -System -Enable DEP,EmulateAtlThunks,SEHOP,ForceRelocateImages,BottomUp,HighEntropy,CFG -ErrorAction SilentlyContinue } catch { Write-AppLog -Level 'WARN' -Message "ExploitProtection :: $($_.Exception.Message)" }
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
        Desc  = "DriverLoadPolicy=1: завантажувати лише драйвери з позначкою Good (найсуворіший режим ACSC)"
        Apply  = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch" "DriverLoadPolicy" 1 }
        Revert = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch" "DriverLoadPolicy" 7 }
        Check  = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch" "DriverLoadPolicy" -1) -eq 1 }
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
        Desc  = "Вимкнути сервіс AiXHostService + DisableAIDataAnalysis=1 + AllowRecallEnablement=0 + EnableRecallOnDevice=0"
        Apply = {
            Set-ServiceDisabled "AiXHostService"
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis"  1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "AllowRecallEnablement"  0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "EnableRecallOnDevice"   0
        }
        Revert = {
            Set-ServiceManual "AiXHostService"
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "DisableAIDataAnalysis"  0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "AllowRecallEnablement"  1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" "EnableRecallOnDevice"   1
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
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 12: CREDENTIAL / LOGON HARDENING ───────────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Credential / Logon Hardening"
        Name  = "Logon cache — 1 попередній вхід (ACSC)"
        Desc  = "CachedLogonsCount=1: кешувати лише 1 останній вхід при недоступності контролера домену"
        Apply  = { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "CachedLogonsCount" "1" "String" }
        Revert = { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "CachedLogonsCount" "10" "String" }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "CachedLogonsCount" "10") -eq "1" }
    },

    [PSCustomObject]@{
        Group = "Credential / Logon Hardening"
        Name  = "Заборонити збереження мережевих паролів (ACSC)"
        Desc  = "DisableDomainCreds=1: не зберігати паролі та облікові дані для мережевої автентифікації"
        Apply  = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "DisableDomainCreds" 1 }
        Revert = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "DisableDomainCreds" 0 }
        Check  = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "DisableDomainCreds" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "Credential / Logon Hardening"
        Name  = "WDigest Authentication вимкнути (ACSC)"
        Desc  = "UseLogonCredential=0: вимкнути зберігання паролів у пам'яті WDigest (потребує KB2871997)"
        Apply  = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" "UseLogonCredential" 0 }
        Revert = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" "UseLogonCredential" 1 }
        Check  = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" "UseLogonCredential" 1) -eq 0 }
    },

    [PSCustomObject]@{
        Group = "Credential / Logon Hardening"
        Name  = "Вимкнути вхід через зображення (Picture password)"
        Desc  = "BlockDomainPicturePassword=1: заборонити вхід за допомогою жесту на зображенні"
        Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "BlockDomainPicturePassword" 1 }
        Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "BlockDomainPicturePassword" 0 }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "BlockDomainPicturePassword" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "Credential / Logon Hardening"
        Name  = "Trusted path для введення облікових даних (ACSC)"
        Desc  = "EnableSecureCredentialPrompting=1: вимагати trusted path для credential entry"
        Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" "EnableSecureCredentialPrompting" 1 }
        Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" "EnableSecureCredentialPrompting" 0 }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" "EnableSecureCredentialPrompting" 0) -eq 1 }
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 13: ПАРОЛІ — РОЗШИРЕНА ПОЛІТИКА ────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Паролі — розширена політика"
        Name  = "Password Policy — ACSC compliant (max age 0, relax min length)"
        Desc  = "MaxPwAge=Unlimited, RelaxMinLength, складність вимкнено, зворотне шифрування вимкнено"
        Apply = {
            net accounts /maxpwage:unlimited 2>$null | Out-Null
            Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\SAM" "RelaxMinimumPasswordLengthLimits" 1
            $tmp = "$env:TEMP\acsc_pwpol.inf"; $db = "$env:TEMP\acsc_pwpol.sdb"
            @"
[Unicode]
Unicode=yes
[System Access]
PasswordComplexity = 0
ClearTextPassword = 0
[Version]
signature="`$CHICAGO`$"
Revision=1
"@ | Set-Content $tmp -Encoding Unicode
            secedit /configure /db $db /cfg $tmp /areas SECURITYPOLICY /quiet 2>$null
            Remove-Item $tmp,$db -Force -ErrorAction SilentlyContinue
        }
        Revert = {
            net accounts /maxpwage:90 2>$null | Out-Null
            Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\SAM" "RelaxMinimumPasswordLengthLimits" 0
        }
        Check = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\SAM" "RelaxMinimumPasswordLengthLimits" 0) -eq 1 }
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 14: SECURE CHANNEL / ДОМЕН ─────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Secure Channel / Домен"
        Name  = "Domain member — цифровий підпис та шифрування каналу (ACSC)"
        Desc  = "RequireSignOrSeal=1, SealSecureChannel=1, SignSecureChannel=1, RequireStrongKey=1, DisablePasswordChange=0"
        Apply = {
            $np = "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
            Set-Reg $np "RequireSignOrSeal"    1
            Set-Reg $np "SealSecureChannel"    1
            Set-Reg $np "SignSecureChannel"    1
            Set-Reg $np "RequireStrongKey"     1
            Set-Reg $np "DisablePasswordChange" 0
        }
        Revert = {
            $np = "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
            Set-Reg $np "RequireSignOrSeal" 0
        }
        Check = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "RequireSignOrSeal" 0) -eq 1 }
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 15: MSS LEGACY ─────────────────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "MSS Legacy"
        Name  = "IP Source Routing — максимальний захист (ACSC)"
        Desc  = "DisableIPSourceRouting=2 (IPv4+IPv6): повністю вимкнути source routing для захисту від spoofing"
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
        Desc  = "EnableICMPRedirect=0: не дозволяти ICMP redirects перевизначати OSPF маршрути"
        Apply  = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "EnableICMPRedirect" 0 }
        Revert = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "EnableICMPRedirect" 1 }
        Check  = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "EnableICMPRedirect" 1) -eq 0 }
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 16: ЖИВЛЕННЯ — ДЕТАЛЬНІ НАЛАШТУВАННЯ ───────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Живлення — детальні"
        Name  = "Standby S1-S3 вимкнути + пароль при пробудженні (ACSC)"
        Desc  = "Заборонити standby states (S1-S3), вимагати пароль при пробудженні (батарея і мережа)"
        Apply = {
            $pw = "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings"
            # Allow standby states (S1-S3) = Disabled (0 = disabled)
            Set-Reg "$pw\abfc2519-3608-4c2a-94ea-171b0ed546ab" "DCSettingIndex" 0
            Set-Reg "$pw\abfc2519-3608-4c2a-94ea-171b0ed546ab" "ACSettingIndex" 0
            # Require password on wake
            Set-Reg "$pw\0e796bdb-100d-47d6-a2d5-f7d2daa51f51" "DCSettingIndex" 1
            Set-Reg "$pw\0e796bdb-100d-47d6-a2d5-f7d2daa51f51" "ACSettingIndex" 1
            # Hibernate timeout = 0
            Set-Reg "$pw\9d7815a6-7ee4-497e-8888-515a05f02364" "DCSettingIndex" 0
            Set-Reg "$pw\9d7815a6-7ee4-497e-8888-515a05f02364" "ACSettingIndex" 0
            # Sleep timeout = 0
            Set-Reg "$pw\29f6c1db-86da-48c5-9fdb-f2b67b1f44da" "DCSettingIndex" 0
            Set-Reg "$pw\29f6c1db-86da-48c5-9fdb-f2b67b1f44da" "ACSettingIndex" 0
            # Unattended sleep timeout = 0
            Set-Reg "$pw\7bc4a2f9-d8fc-4469-b07b-33eb785aaca0" "DCSettingIndex" 0
            Set-Reg "$pw\7bc4a2f9-d8fc-4469-b07b-33eb785aaca0" "ACSettingIndex" 0
            # Turn off hybrid sleep
            Set-Reg "$pw\94ac6d29-73ce-41a6-809f-6363ba21b47e" "DCSettingIndex" 0
            Set-Reg "$pw\94ac6d29-73ce-41a6-809f-6363ba21b47e" "ACSettingIndex" 0
            # Hide hibernate and sleep from power menu
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "ShowHibernateOption" 0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "ShowSleepOption"     0
            powercfg /hibernate off 2>$null
        }
        Revert = {
            $pw = "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings"
            Remove-RegValue "$pw\abfc2519-3608-4c2a-94ea-171b0ed546ab" "DCSettingIndex"
            Remove-RegValue "$pw\abfc2519-3608-4c2a-94ea-171b0ed546ab" "ACSettingIndex"
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "ShowHibernateOption" 1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "ShowSleepOption"     1
            powercfg /hibernate on 2>$null
        }
        Check = {
            $v = Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\abfc2519-3608-4c2a-94ea-171b0ed546ab" "DCSettingIndex" -1
            $v -eq 0
        }
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 17: ПРИНТЕРИ — HARDENING ───────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Принтери — Hardening"
        Name  = "Printer RPC/IPPS/TLS hardening (ACSC)"
        Desc  = "RPC over TCP, Redirection Guard, IPPS required, TLS policy, driver signing, queue files limit"
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
        }
        Revert = {
            $pr = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers"
            Remove-RegValue "$pr" "RequireIPPS"
            Remove-RegValue "$pr" "IPPTLSPolicy"
            Remove-RegValue "$pr" "RedirectionGuardPolicy"
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
        Desc  = "DisableLocalMachineRunOnce=1, DisableLocalMachineRun=1: заборонити автозапуск legacy програм"
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
# ── РОЗДІЛ 22: ПРИСТРОЇ — CD/WLAN/RSS/SEARCH ─────────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Пристрої — CD/WLAN/RSS/Search"
        Name  = "Вимкнути запис CD (ACSC)"
        Desc  = "NoCDBurning=1: заборонити функції запису CD/DVD у File Explorer"
        Apply  = { Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoCDBurning" 1 }
        Revert = { Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoCDBurning" 0 }
        Check  = { (Get-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoCDBurning" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "Пристрої — CD/WLAN/RSS/Search"
        Name  = "Device Installation — заблокувати FireWire/Thunderbolt класи (ACSC)"
        Desc  = "Заблокувати установку пристроїв IEEE 1394 класу {d48179be-ec20-11d1-b6b8-00c04fa372a7}"
        Apply = {
            $dr = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions"
            Set-Reg $dr "DenyDeviceClasses"  1
            Set-Reg $dr "DenyDeviceClassesRetroactive" 1
            $dc = "$dr\DenyDeviceClasses"
            if (-not (Test-Path $dc)) { New-Item -Path $dc -Force | Out-Null }
            Set-Reg $dc "1" "{d48179be-ec20-11d1-b6b8-00c04fa372a7}" "String"
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceClasses" 0
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceClasses" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "Пристрої — CD/WLAN/RSS/Search"
        Name  = "WLAN — вимкнути автоматичне підключення до hotspots (ACSC)"
        Desc  = "AutoConnectAllowedOEM=0: не підключатися до запропонованих відкритих точок доступу"
        Apply  = { Set-Reg "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" "AutoConnectAllowedOEM" 0 }
        Revert = { Set-Reg "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" "AutoConnectAllowedOEM" 1 }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" "AutoConnectAllowedOEM" 1) -eq 0 }
    },

    [PSCustomObject]@{
        Group = "Пристрої — CD/WLAN/RSS/Search"
        Name  = "RSS Feeds — заборонити завантаження вкладень (ACSC)"
        Desc  = "DisableEnclosureDownload=1: заборонити завантаження enclosures з RSS-стрічок"
        Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds" "DisableEnclosureDownload" 1 }
        Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds" "DisableEnclosureDownload" 0 }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds" "DisableEnclosureDownload" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "Пристрої — CD/WLAN/RSS/Search"
        Name  = "Search — вимкнути індексацію шифрованих файлів (ACSC)"
        Desc  = "AllowIndexingEncryptedStoresOrItems=0: заборонити індексацію зашифрованих файлів"
        Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowIndexingEncryptedStoresOrItems" 0 }
        Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowIndexingEncryptedStoresOrItems" 1 }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowIndexingEncryptedStoresOrItems" 1) -eq 0 }
    },

    [PSCustomObject]@{
        Group = "Пристрої — CD/WLAN/RSS/Search"
        Name  = "Web Search — вимкнути пошук у вебі (ACSC)"
        Desc  = "DisableWebSearch=1, ConnectedSearchUseWeb=0: не показувати веб-результати в пошуку"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch"      1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "ConnectedSearchUseWeb" 0
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch" 0
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "Пристрої — CD/WLAN/RSS/Search"
        Name  = "File Explorer — heap termination, shell protocol (ACSC)"
        Desc  = "NoHeapTerminationOnCorruption=0, PreXPSP2ShellProtocolBehavior=0: не вимикати DEP та shell protection"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoHeapTerminationOnCorruption"    0
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "PreXPSP2ShellProtocolBehavior" 0
        }
        Revert = {
            Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoHeapTerminationOnCorruption"
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoHeapTerminationOnCorruption" 1) -eq 0 }
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 23: NTLM LOGGING / PKU2U / LDAP ───────────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "NTLM / PKU2U / LDAP"
        Name  = "NTLM Enhanced Logging + Netlogon (ACSC)"
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
        Desc  = "AllowOnlineID=0 (for on-prem AD), LDAPClientIntegrity=1 (negotiate signing)"
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
        Desc  = "ProtectionMode=1: посилити default permissions для внутрішніх системних об'єктів"
        Apply  = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "ProtectionMode" 1 }
        Revert = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "ProtectionMode" 0 }
        Check  = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "ProtectionMode" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "NTLM / PKU2U / LDAP"
        Name  = "Audit SMB client SPN support (ACSC)"
        Desc  = "AuditSmb1Access=1: аудит спроб доступу через SMB1 SPN"
        Apply  = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "AuditSmb1Access" 1 }
        Revert = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "AuditSmb1Access" 0 }
        Check  = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "AuditSmb1Access" 0) -eq 1 }
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 24: LOCK SCREEN — ДЕТАЛЬНІ ─────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Lock Screen — детальні"
        Name  = "Lock Screen — вимкнути камеру, слайд-шоу, сповіщення, голос (ACSC)"
        Desc  = "NoLockScreenCamera, NoLockScreenSlideshow, DisableLockScreenAppNotifications, LetAppsActivateWithVoiceAboveLock=2"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreenCamera"    1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreenSlideshow" 1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableLockScreenAppNotifications" 1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsActivateWithVoiceAboveLock" 2
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreenCamera"    0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreenSlideshow" 0
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreenCamera" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "Lock Screen — детальні"
        Name  = "Toast notifications — вимкнути на lock screen (ACSC)"
        Desc  = "NoToastApplicationNotificationOnLockScreen=1: не показувати toast-сповіщення на екрані блокування"
        Apply  = { Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" "NoToastApplicationNotificationOnLockScreen" 1 }
        Revert = { Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" "NoToastApplicationNotificationOnLockScreen" 0 }
        Check  = { (Get-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" "NoToastApplicationNotificationOnLockScreen" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "Lock Screen — детальні"
        Name  = "Cloud Content — вимкнути сторонні пропозиції у Spotlight (ACSC)"
        Desc  = "DisableThirdPartySuggestions=1: не показувати сторонній контент у Windows spotlight"
        Apply  = { Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableThirdPartySuggestions" 1 }
        Revert = { Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableThirdPartySuggestions" 0 }
        Check  = { (Get-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableThirdPartySuggestions" 0) -eq 1 }
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 25: UAC NETWORK RESTRICTIONS / SEHOP ──────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "UAC Network / SEHOP"
        Name  = "UAC restrictions для локальних облікових записів на мережі (ACSC)"
        Desc  = "LocalAccountTokenFilterPolicy=0: застосовувати UAC обмеження для мережевих входів локальних акаунтів"
        Apply  = { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "LocalAccountTokenFilterPolicy" 0 }
        Revert = { Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "LocalAccountTokenFilterPolicy" 1 }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "LocalAccountTokenFilterPolicy" 1) -eq 0 }
    },

    [PSCustomObject]@{
        Group = "UAC Network / SEHOP"
        Name  = "SEHOP — Structured Exception Handling Overwrite Protection (ACSC)"
        Desc  = "DisableExceptionChainValidation=0: увімкнути SEHOP для захисту від exploit'ів"
        Apply  = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "DisableExceptionChainValidation" 0 }
        Revert = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "DisableExceptionChainValidation" 1 }
        Check  = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "DisableExceptionChainValidation" 1) -eq 0 }
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 26: BIOMETRICS / WINDOWS HELLO ENHANCED ────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Biometrics / Windows Hello"
        Name  = "Biometrics — enhanced anti-spoofing + hardware device (ACSC)"
        Desc  = "EnhancedAntiSpoofing=1, RequireSecurityDevice=1, ExcludeTPM12=1"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics\FacialFeatures" "EnhancedAntiSpoofing" 1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork" "RequireSecurityDevice"   1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork" "ExcludeTPM12"            1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork" "UseBiometrics"           1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork" "UsePassportForWork"      1
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics\FacialFeatures" "EnhancedAntiSpoofing" 0
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics\FacialFeatures" "EnhancedAntiSpoofing" 0) -eq 1 }
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 27: USER RIGHTS ASSIGNMENT ─────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "User Rights Assignment"
        Name  = "User Rights — обмеження привілеїв (ACSC)"
        Desc  = "Backup/Restore лише Administrators, Deny network/batch/local/service logon для Administrators, Debug=Admins"
        Apply = {
            $tmp = "$env:TEMP\acsc_rights.inf"; $db = "$env:TEMP\acsc_rights.sdb"
            @"
[Unicode]
Unicode=yes
[Privilege Rights]
SeBackupPrivilege = *S-1-5-32-544
SeRestorePrivilege = *S-1-5-32-544
SeDenyNetworkLogonRight = *S-1-5-32-544,*S-1-5-113
SeDenyBatchLogonRight = *S-1-5-32-544
SeDenyInteractiveLogonRight = *S-1-5-32-544
SeDenyServiceLogonRight = *S-1-5-32-544
SeDenyRemoteInteractiveLogonRight = *S-1-5-32-544,*S-1-5-113
SeDebugPrivilege = *S-1-5-32-544
SeTcbPrivilege =
SeCreateTokenPrivilege =
SeCreatePermanentPrivilege =
SeTrustedCredManAccessPrivilege =
SeLockMemoryPrivilege =
SeEnableDelegationPrivilege =
SeRemoteInteractiveLogonRight = *S-1-5-32-555
SeInteractiveLogonRight = *S-1-5-32-545
SeCreatePagefilePrivilege = *S-1-5-32-544
SeCreateGlobalPrivilege = *S-1-5-32-544,*S-1-5-19,*S-1-5-20,*S-1-5-6
SeLoadDriverPrivilege = *S-1-5-32-544
SeSystemEnvironmentPrivilege = *S-1-5-32-544
SeManageVolumePrivilege = *S-1-5-32-544
SeProfileSingleProcessPrivilege = *S-1-5-32-544
SeTakeOwnershipPrivilege = *S-1-5-32-544
SeImpersonatePrivilege = *S-1-5-32-544,*S-1-5-19,*S-1-5-20,*S-1-5-6
SeRemoteShutdownPrivilege = *S-1-5-32-544
SeNetworkLogonRight = *S-1-5-32-555
[Version]
signature="`$CHICAGO`$"
Revision=1
"@ | Set-Content $tmp -Encoding Unicode
            secedit /configure /db $db /cfg $tmp /areas USER_RIGHTS /quiet 2>$null
            Remove-Item $tmp,$db -Force -ErrorAction SilentlyContinue
        }
        Revert = {
            $tmp = "$env:TEMP\acsc_rights_revert.inf"; $db = "$env:TEMP\acsc_rights_revert.sdb"
            @"
[Unicode]
Unicode=yes
[Privilege Rights]
SeBackupPrivilege = *S-1-5-32-544,*S-1-5-32-551
SeRestorePrivilege = *S-1-5-32-544,*S-1-5-32-551
SeDenyNetworkLogonRight =
SeDenyBatchLogonRight =
SeDenyInteractiveLogonRight =
SeDenyServiceLogonRight =
SeDebugPrivilege = *S-1-5-32-544
[Version]
signature="`$CHICAGO`$"
Revision=1
"@ | Set-Content $tmp -Encoding Unicode
            secedit /configure /db $db /cfg $tmp /areas USER_RIGHTS /quiet 2>$null
            Remove-Item $tmp,$db -Force -ErrorAction SilentlyContinue
        }
        Check = {
            secedit /export /cfg "$env:TEMP\acsc_chk.inf" /quiet 2>$null | Out-Null
            $cfg = Get-Content "$env:TEMP\acsc_chk.inf" -ErrorAction SilentlyContinue
            Remove-Item "$env:TEMP\acsc_chk.inf" -Force -ErrorAction SilentlyContinue
            if (-not $cfg) { return $false }
            $line = $cfg | Where-Object { $_ -match 'SeDenyNetworkLogonRight' }
            ($null -ne $line) -and ($line -match 'S-1-5-32-544')
        }
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 28: SYSTEM CRYPTOGRAPHY ────────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "System Cryptography"
        Name  = "System Cryptography — FIPS + Force strong key protection (ACSC)"
        Desc  = "FIPSAlgorithmPolicy=1, ForceKeyProtection=2: FIPS та пароль при кожному використанні ключа"
        Apply = {
            Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" "Enabled"          1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography"                  "ForceKeyProtection" 2
        }
        Revert = {
            Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" "Enabled"          0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography"                  "ForceKeyProtection" 0
        }
        Check = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" "Enabled" 0) -eq 1 }
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 29: CREDENTIAL DELEGATION / RDP ENHANCED ───────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Credential Delegation / RDP"
        Name  = "Encryption Oracle Remediation — Force Updated Clients (ACSC)"
        Desc  = "AllowEncryptionOracle=0, AllowProtectedCreds=1: примусове оновлення CredSSP клієнтів"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters" "AllowEncryptionOracle" 0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation" "AllowProtectedCreds" 1
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters" "AllowEncryptionOracle" 2
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters" "AllowEncryptionOracle" 2) -eq 0 }
    },

    [PSCustomObject]@{
        Group = "Credential Delegation / RDP"
        Name  = "RDP — дозволити підключення + fDenyTSConnections=0 (ACSC)"
        Desc  = "fDenyTSConnections=0: дозволити підключення через Remote Desktop Services"
        Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDenyTSConnections" 0 }
        Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDenyTSConnections" 1 }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDenyTSConnections" 1) -eq 0 }
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
# ── РОЗДІЛ 32: KERNEL DMA PROTECTION ─────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Kernel DMA Protection"
        Name  = "DMA Protection — Block All зовнішніх пристроїв (ACSC)"
        Desc  = "DeviceEnumerationPolicy=0: блокувати всі зовнішні пристрої несумісні з Kernel DMA Protection"
        Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy" 0 }
        Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy" 1 }
        Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy" -1) -eq 0 }
    },


# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ: ВІДНОВЛЕННЯ / ЗРУЧНІСТЬ ─────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Відновлення / Зручність"
        Name  = "Windows Store — відновити доступ"
        Desc  = "RemoveWindowsStore=0; знімає GPO-блокування Microsoft Store і modern-застосунків (Notepad, SnippingTool тощо)"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" "RemoveWindowsStore" 0
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" "RemoveWindowsStore" 1
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" "RemoveWindowsStore" 1) -eq 0 }
    },

    [PSCustomObject]@{
        Group = "Відновлення / Зручність"
        Name  = "Snipping Tool — відновити"
        Desc  = "DisableSnippingTool=0 у HKLM і HKCU; повертає доступ до Snipping Tool / Snip & Sketch"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SnippingTool"     "DisableSnippingTool" 0
            Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer"         "DisableSnippingTool" 0
            Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DisabledHotkeys" "" "String"
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SnippingTool" "DisableSnippingTool" 1
            Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer"      "DisableSnippingTool" 1
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SnippingTool" "DisableSnippingTool" 1) -eq 0 }
    },

    [PSCustomObject]@{
        Group = "Відновлення / Зручність"
        Name  = "Notepad — відновити (system + Store)"
        Desc  = "Знімає DisableUAT/AppCompat-блок; Store Notepad стає доступним після відновлення WindowsStore"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableUAT"            0
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "AITEnable"             1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableProgramCompat"  0
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableUAT" 1
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" "DisableUAT" 1) -eq 0 }
    },

    [PSCustomObject]@{
        Group = "Відновлення / Зручність"
        Name  = "PowerShell + CMD — RemoteSigned замість AllSigned"
        Desc  = "ExecutionPolicy=RemoteSigned: локальні скрипти не вимагають підпису; знімає Authenticode SRP (AuthenticodeEnabled=0)"
        Apply = {
            $ps = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell"
            Set-Reg $ps "ExecutionPolicy" "RemoteSigned" "String"
            Set-Reg $ps "EnableScripts"   1
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Safer\CodeIdentifiers" "AuthenticodeEnabled" 0
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" `
                -Name "ExecutionPolicy" -Value "RemoteSigned" -ErrorAction SilentlyContinue
        }
        Revert = {
            $ps = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell"
            Set-Reg $ps "ExecutionPolicy" "AllSigned" "String"
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Safer\CodeIdentifiers" "AuthenticodeEnabled" 1
        }
        Check = {
            $ep = Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell" "ExecutionPolicy" "AllSigned"
            $ep -eq "RemoteSigned"
        }
    },

    [PSCustomObject]@{
        Group = "Відновлення / Зручність"
        Name  = "Windows Security — відновити іконку у systray"
        Desc  = "HideSystray=0, HideSCAHealth=0; повертає іконку щита Windows Security у панель сповіщень"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" "HideSystray"  0
            Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"           "HideSCAHealth" 0
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"           "HideSCAHealth" 0
        }
        Revert = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" "HideSystray"  1
            Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"           "HideSCAHealth" 1
        }
        Check = {
            (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" "HideSystray" 1) -eq 0
        }
    },

    [PSCustomObject]@{
        Group = "Відновлення / Зручність"
        Name  = "Windows Security Center — відновити сервіс і застосунок"
        Desc  = "SecurityHealthService та wscsvc у режимі Automatic; PerUserSecurityHealthAgent=1; перезапускає SecurityHealthSystray"
        Apply = {
            Set-Service -Name "SecurityHealthService" -StartupType Automatic -ErrorAction SilentlyContinue
            Start-Service -Name "SecurityHealthService"                       -ErrorAction SilentlyContinue
            Set-Service -Name "wscsvc"                -StartupType Automatic -ErrorAction SilentlyContinue
            Start-Service -Name "wscsvc"                                      -ErrorAction SilentlyContinue
            Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" `
                "SecurityHealth" "%windir%\system32\SecurityHealthSystray.exe" "ExpandString"
        }
        Revert = {
            Stop-Service -Name "SecurityHealthService" -Force     -ErrorAction SilentlyContinue
            Set-Service  -Name "SecurityHealthService" -StartupType Disabled -ErrorAction SilentlyContinue
        }
        Check = {
            $s = Get-Service -Name "SecurityHealthService" -ErrorAction SilentlyContinue
            $s -and $s.StartType -eq 'Automatic'
        }
    }

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
        Name  = "WPAD / Auto-Detect Proxy — вимкнути"
        Desc  = "HKCU AutoDetect=0 + WinHttpAutoProxySvc Disabled: заборонити автовиявлення проксі"
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
        Name  = "LetApps: Camera / Microphone / Location = Deny"
        Desc  = "ConsentStore webcam/microphone/location → Deny; LetAppsAccess* = 2 у AppPrivacy"
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
        Desc  = "XblGameSave, XblAuthManager, XboxNetApiSvc, XboxGipSvc → Disabled"
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
        Desc  = "RetailDemo, WMPNetworkSvc, WpcMonSvc, PeerDistSvc, PhoneSvc → Disabled"
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
        Desc  = "lfsvc (GPS), icssvc (hotspot), SharedAccess (ICS), TapiSrv (телефонія) → Disabled"
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
# ── РОЗДІЛ 39: SCHEDULED TASKS — ТЕЛЕМЕТРІЯ / CEIP ───────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Scheduled Tasks — телеметрія / CEIP"
        Name  = "CEIP tasks — вимкнути (Consolidator / KernelCeipTask / UsbCeip / FamilySafetyMonitor)"
        Desc  = "Завдання Customer Experience Improvement Program → Disabled"
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
        Desc  = "DmClient, DmClientOnScenarioDownload, MapsToastTask, MapsUpdateTask → Disabled"
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
# ── РОЗДІЛ 40: TCP/IP СТЕК — ЗАХИСТ ВІД АТАК ──────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "TCP/IP стек — захист від атак"
        Name  = "SYN Flood захист (SynAttackProtect + обмеження з'єднань)"
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
        Name  = "TCP Timestamps вимкнути (захист від OS fingerprinting)"
        Desc  = "Tcp1323Opts=0: вимкнути TCP timestamps щоб запобігти визначенню ОС через аналіз clock skew"
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
        Name  = "TIME_WAIT скорочення + розширений порт-діапазон"
        Desc  = "TcpTimedWaitDelay=30, MaxUserPort=61000: швидше звільнення портів + більший ephemeral range"
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
        Name  = "PMTU Discovery вимкнути + Black Hole Detection"
        Desc  = "EnablePMTUDiscovery=0, EnablePMTUBHDetect=1: відключити ICMP-based MTU, увімкнути BH-recovery"
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
        Name  = "ARP Spoofing захист (WeakHost вимкнути)"
        Desc  = "WeakHostSend=Disabled, WeakHostReceive=Disabled на всіх IPv4 інтерфейсах"
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
        Name  = "Firewall — увімкнути всі профілі + Block Inbound за замовчуванням"
        Desc  = "Увімкнути брандмауер Domain/Private/Public, DefaultInboundAction=Block, DefaultOutboundAction=Allow"
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
        Desc  = "EnableStealthModeForIPsec=True на всіх профілях: не відповідати на unsolicited трафік"
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
        Desc  = "LogAllowed=True, LogBlocked=True, LogMaxSizeKilobytes=16384 для Domain/Private/Public"
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
        Name  = "File & Printer Sharing binding — вимкнути на адаптерах"
        Desc  = "Вимкнути ms_server компонент (File and Printer Sharing) на Ethernet та Wi-Fi адаптерах"
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
        Desc  = "Зупинити WinRM, вимкнути PS Remoting, LocalAccountTokenFilterPolicy=0"
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
        Name  = "Null Sessions / Anonymous Pipes — розширений захист"
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
# ── РОЗДІЛ 43: ПАРОЛІ — ІСТОРІЯ ТА LOCKOUT (CIS) ──────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Паролі — історія та lockout (CIS)"
        Name  = "Password History — зберігати 24 останніх паролі (CIS 1.1.1)"
        Desc  = "Заборонити повторне використання 24 останніх паролів через secedit"
        Apply = {
            $tmp = "$env:TEMP\pwhistory.inf"; $db = "$env:TEMP\pwhistory.sdb"
            @"
[Unicode]
Unicode=yes
[System Access]
PasswordHistorySize = 24
[Version]
signature="`$CHICAGO`$"
Revision=1
"@ | Set-Content $tmp -Encoding Unicode
            secedit /configure /db $db /cfg $tmp /areas SECURITYPOLICY /quiet 2>$null
            Remove-Item $tmp,$db -Force -ErrorAction SilentlyContinue
        }
        Revert = {
            $tmp = "$env:TEMP\pwhistory.inf"; $db = "$env:TEMP\pwhistory.sdb"
            @"
[Unicode]
Unicode=yes
[System Access]
PasswordHistorySize = 0
[Version]
signature="`$CHICAGO`$"
Revision=1
"@ | Set-Content $tmp -Encoding Unicode
            secedit /configure /db $db /cfg $tmp /areas SECURITYPOLICY /quiet 2>$null
            Remove-Item $tmp,$db -Force -ErrorAction SilentlyContinue
        }
        Check = {
            $tmp = "$env:TEMP\secpol_check.inf"
            secedit /export /cfg $tmp /areas SECURITYPOLICY /quiet 2>$null
            $val = (Get-Content $tmp -ErrorAction SilentlyContinue | Where-Object { $_ -match 'PasswordHistorySize' }) -replace '.*=\s*', ''
            Remove-Item $tmp -Force -ErrorAction SilentlyContinue
            [int]$val -ge 24
        }
    },

    [PSCustomObject]@{
        Group = "Паролі — історія та lockout (CIS)"
        Name  = "Minimum Password Age — 1 день (CIS 1.1.3)"
        Desc  = "Мінімальний вік пароля 1 день: запобігти швидкій ротації паролів"
        Apply = { net accounts /minpwage:1 2>$null | Out-Null }
        Revert = { net accounts /minpwage:0 2>$null | Out-Null }
        Check = {
            $out = net accounts 2>$null
            $line = $out | Where-Object { $_ -match 'Minimum password age' -or $_ -match 'мін.*пароля' }
            if ($line) { ($line -replace '\D','') -ge 1 } else { $false }
        }
    },

    [PSCustomObject]@{
        Group = "Паролі — історія та lockout (CIS)"
        Name  = "Account Lockout Duration — 30 хвилин (CIS 1.2.1)"
        Desc  = "Тривалість блокування облікового запису 30 хв після перевищення спроб входу"
        Apply = { net accounts /lockoutduration:30 2>$null | Out-Null }
        Revert = { net accounts /lockoutduration:0 2>$null | Out-Null }
        Check = {
            $out = net accounts 2>$null
            $line = $out | Where-Object { $_ -match 'Lockout duration' -or $_ -match 'блокування' }
            if ($line) { ($line -replace '\D','') -ge 30 } else { $false }
        }
    },

    [PSCustomObject]@{
        Group = "Паролі — історія та lockout (CIS)"
        Name  = "Reset Lockout Counter — 15 хвилин (CIS 1.2.3)"
        Desc  = "Скинути лічильник невдалих спроб через 15 хв"
        Apply = { net accounts /lockoutwindow:15 2>$null | Out-Null }
        Revert = { net accounts /lockoutwindow:30 2>$null | Out-Null }
        Check = {
            $out = net accounts 2>$null
            $line = $out | Where-Object { $_ -match 'Lockout observation' -or $_ -match 'спостереження' }
            if ($line) { ($line -replace '\D','') -ge 15 } else { $false }
        }
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 44: IE / EDGE — ЗАХИСТ ──────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "IE / Edge — захист"
        Name  = "IE — 64-bit Tab Isolation + ActiveX захист"
        Desc  = "Isolation64Bit=1: 64-bit процес-ізоляція для IE; 270C=0: захист ActiveX від malware в Internet Zone"
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
        Desc  = "Isolation=PMEM, Enhanced Protected Mode, вимкнути Flash Player для IE"
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
        Desc  = "DoNotTrack=1, FormSuggest=no, PersonalizationReportingEnabled=0"
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
# ── РОЗДІЛ 45: РОЗШИРЕНИЙ АУДИТ (CIS / STIG) ──────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Розширений аудит (CIS / STIG)"
        Name  = "Audit — Account Logon та Group Management (CIS)"
        Desc  = "Credential Validation, Application/Security/Distribution Group Management — Success+Failure"
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
        Desc  = "File System, Registry, Handle Manipulation, SAM, Sensitive/Non-Sensitive Privilege Use"
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
        Desc  = "Network Policy Server, IPsec Main/Quick/Extended Mode, Detailed Tracking, NTLM Audit"
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
# ── РОЗДІЛ 46: ПРИВАТНІСТЬ — РОЗШИРЕНА (HKLM) ─────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Приватність — розширена (HKLM)"
        Name  = "Connected Devices Platform (CDP) — вимкнути"
        Desc  = "EnableCdp=0: вимкнути крос-девайсну синхронізацію, clipboard sharing, Continue on PC"
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
        Desc  = "AutoDownload=4, DisableOSUpgrade=1: обмежити автозавантаження, вимкнути upgrade через Store"
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
        Desc  = "DisableUserAuth=1, AllowMicrosoftAccountsToBeOptional=1: блокувати MSA auth на пристрої"
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
# ── РОЗДІЛ 47: ЗАХИСТ СЕРВІСІВ ТА ДРАЙВЕРІВ ───────────────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Захист сервісів та драйверів"
        Name  = "SNMP сервіс — вимкнути та видалити"
        Desc  = "Зупинити SNMP Service, вимкнути та деінсталювати Windows Feature SNMP-Service"
        Apply = {
            Set-ServiceDisabled "SNMP"
            Get-WindowsCapability -Online -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -like '*SNMP*' -and $_.State -eq 'Installed' } |
                ForEach-Object { Remove-WindowsCapability -Online -Name $_.Name -ErrorAction SilentlyContinue }
        }
        Revert = {
            Set-ServiceManual "SNMP"
        }
        Check = {
            $s = Get-Service "SNMP" -ErrorAction SilentlyContinue
            -not $s -or $s.StartType -eq 'Disabled'
        }
    },

    [PSCustomObject]@{
        Group = "Захист сервісів та драйверів"
        Name  = "Remote Registry — вимкнути"
        Desc  = "Зупинити та вимкнути Remote Registry сервіс (віддалений доступ до реєстру)"
        Apply  = { Set-ServiceDisabled "RemoteRegistry" }
        Revert = { Set-ServiceManual "RemoteRegistry" }
        Check  = { $s = Get-Service "RemoteRegistry" -ErrorAction SilentlyContinue; $s -and $s.StartType -eq 'Disabled' }
    },

    [PSCustomObject]@{
        Group = "Захист сервісів та драйверів"
        Name  = "Fax / XboxGipSvc / RetailDemo — вимкнути"
        Desc  = "Зупинити Fax, XboxGipSvc, XboxNetApiSvc, RetailDemo сервіси"
        Apply = {
            foreach ($svc in @("Fax","XboxGipSvc","XboxNetApiSvc","RetailDemo","MapsBroker")) {
                Set-ServiceDisabled $svc
            }
        }
        Revert = {
            foreach ($svc in @("Fax","XboxGipSvc","XboxNetApiSvc","RetailDemo","MapsBroker")) {
                Set-ServiceManual $svc
            }
        }
        Check = { $s = Get-Service "XboxGipSvc" -ErrorAction SilentlyContinue; $s -and $s.StartType -eq 'Disabled' }
    },

    [PSCustomObject]@{
        Group = "Захист сервісів та драйверів"
        Name  = "Bluetooth Support / SSDP Discovery — вимкнути"
        Desc  = "Зупинити bthserv (Bluetooth), SSDPSRV (SSDP Discovery), upnphost (UPnP)"
        Apply = {
            foreach ($svc in @("bthserv","SSDPSRV","upnphost")) {
                Set-ServiceDisabled $svc
            }
        }
        Revert = {
            foreach ($svc in @("bthserv","SSDPSRV","upnphost")) {
                Set-ServiceManual $svc
            }
        }
        Check = { $s = Get-Service "SSDPSRV" -ErrorAction SilentlyContinue; $s -and $s.StartType -eq 'Disabled' }
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 48: WINDOWS SANDBOX / VIRTUALIZATION SECURITY ───────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Windows Sandbox / Virtualization Security"
        Name  = "HVCI — Hypervisor-protected Code Integrity"
        Desc  = "HypervisorEnforcedCodeIntegrity=1, HVCIMATRequired=1: захист ядра від unsigned drivers"
        Apply = {
            $dg = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
            Set-Reg $dg "HypervisorEnforcedCodeIntegrity" 1
            Set-Reg $dg "HVCIMATRequired"                 1
        }
        Revert = {
            $dg = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
            Set-Reg $dg "HypervisorEnforcedCodeIntegrity" 0
            Set-Reg $dg "HVCIMATRequired"                 0
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" "HypervisorEnforcedCodeIntegrity" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "Windows Sandbox / Virtualization Security"
        Name  = "System Guard Secure Launch + Kernel Shadow Stacks"
        Desc  = "ConfigureSystemGuardLaunch=1, ConfigureKernelShadowStacksLaunch=1"
        Apply = {
            $dg = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
            Set-Reg $dg "ConfigureSystemGuardLaunch"            1
            Set-Reg $dg "ConfigureKernelShadowStacksLaunch"    1
        }
        Revert = {
            $dg = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard"
            Remove-RegValue $dg "ConfigureSystemGuardLaunch"
            Remove-RegValue $dg "ConfigureKernelShadowStacksLaunch"
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" "ConfigureSystemGuardLaunch" 0) -eq 1 }
    },

    [PSCustomObject]@{
        Group = "Windows Sandbox / Virtualization Security"
        Name  = "Заборонити Custom SSPs/APs (LSASS захист)"
        Desc  = "AllowCustomSSPsAPs=0: не дозволяти нестандартним SSP/AP підключатися до LSASS"
        Apply = {
            Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCustomSSPsAPs" 0
        }
        Revert = {
            Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCustomSSPsAPs"
        }
        Check = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCustomSSPsAPs" 1) -eq 0 }
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 49: МЕРЕЖЕВА ІЗОЛЯЦІЯ / DOMAIN HARDENING ───────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Мережева ізоляція / Domain Hardening"
        Name  = "Заблокувати підключення до non-domain мереж при domain з'єднанні"
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
        Name  = "UNC Hardened Paths — SYSVOL та NETLOGON"
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
        Name  = "Network Connections — приховати Shared Access UI"
        Desc  = "NC_ShowSharedAccessUI=0: заборонити Internet Connection Sharing UI"
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
        Name  = "Insecure Guest Auth — заборонити для SMB"
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
        Name  = "Input Personalization / Inking — вимкнути"
        Desc  = "RestrictImplicitInkCollection=1, RestrictImplicitTextCollection=1: не збирати дані рукопису/друку"
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
        Name  = "Clipboard Cloud Sync / History — вимкнути"
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
        Name  = "Diagnostic Data / Feedback — мінімізувати"
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
        Name  = "App Permissions — заборонити доступ до камери/мікрофона/локації"
        Desc  = "LetAppsAccessCamera=2, LetAppsAccessMicrophone=2, LetAppsAccessLocation=2 (Force Deny)"
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
    },

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 51: SCHEDULED TASKS — РОЗШИРЕНЕ ВІДКЛЮЧЕННЯ ─────────────────
# ════════════════════════════════════════════════════════════════════════

    [PSCustomObject]@{
        Group = "Scheduled Tasks — розширене відключення"
        Name  = "Telemetry Tasks — Office / Device Census / Cloud Experience"
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
        Name  = "Background Tasks — Defrag / WDI / Memory Diagnostic"
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


    ) # end $Settings

    return $Settings
}

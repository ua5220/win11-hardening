<#
.SYNOPSIS
    Безпека: UAC, паролі, облікові записи, біометрія, блокування екрану, криптографія
.NOTES
    Частина Get-HardeningSettings — підвантажується через settings.data.ps1
#>

@(

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 1: UAC / ВХІД ДО СИСТЕМИ ────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "UAC / Вхід до системи"
    Name  = "UAC рівень 5 — підтвердження без пароля (зручний)"
    Desc  = "ConsentPromptBehaviorAdmin=5: сповіщення без запиту пароля, без захищеного робочого столу"
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
    Name  = "UAC суворий — запит пароля на захищений робочий стіл (ACSC)"
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
    Name  = "Захищений ввід облікових даних (ACSC 05)"
    Desc  = "DisablePasswordReveal=1, EnumerateAdministrators=0, SoftwareSASGeneration=0, DisableAutomaticRestartSignOn=1 — приховати пароль, вимкнути перерахування адміністраторів та автоматичний вхід після перезапуску"
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
    Name  = "Блокування при бездіяльності — 15 хв (ACSC 33)"
    Desc  = "InactivityTimeoutSecs=900, заставка 900с + пароль, без камери/слайдшоу на екрані блокування"
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
    Name  = "Вимкнути вхід через зображення (графічний пароль)"
    Desc  = "BlockDomainPicturePassword=1: заборонити вхід за допомогою жесту на зображенні"
    Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "BlockDomainPicturePassword" 1 }
    Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "BlockDomainPicturePassword" 0 }
    Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "BlockDomainPicturePassword" 0) -eq 1 }
},

[PSCustomObject]@{
    Group = "Credential / Logon Hardening"
    Name  = "Довірений шлях для введення облікових даних (ACSC)"
    Desc  = "EnableSecureCredentialPrompting=1: вимагати довірений шлях для введення облікових даних"
    Apply  = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" "EnableSecureCredentialPrompting" 1 }
    Revert = { Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" "EnableSecureCredentialPrompting" 0 }
    Check  = { (Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" "EnableSecureCredentialPrompting" 0) -eq 1 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 13: ПАРОЛІ — РОЗШИРЕНА ПОЛІТИКА ────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Паролі — розширена політика"
    Name  = "Політика паролів — відповідає ACSC (макс. вік 0, послаблений мін. розмір)"
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
    Name  = "Спливні сповіщення — вимкнути на екрані блокування (ACSC)"
    Desc  = "NoToastApplicationNotificationOnLockScreen=1: не показувати спливні сповіщення на екрані блокування"
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
    Desc  = "DisableExceptionChainValidation=0: увімкнути SEHOP для захисту від експлойтів"
    Apply  = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "DisableExceptionChainValidation" 0 }
    Revert = { Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "DisableExceptionChainValidation" 1 }
    Check  = { (Get-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "DisableExceptionChainValidation" 1) -eq 0 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 26: BIOMETRICS / WINDOWS HELLO ENHANCED ────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Biometrics / Windows Hello"
    Name  = "Biometrics — розширений захист від підробки + апаратний пристрій (ACSC)"
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
    Desc  = "Backup/Restore лише Administrators, Заборонити мережевий/пакетний/локальний/сервісний вхід для Administrators, Debug=Admins"
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
    Name  = "Системна криптографія — FIPS + Примусовий захист ключів (ACSC)"
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
    Name  = "Усунення вразливості Encryption Oracle — Примусово оновлені клієнти (ACSC)"
    Desc  = "AllowEncryptionOracle=0, AllowProtectedCreds=1: примусове оновлення клієнтів CredSSP"
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
}

)

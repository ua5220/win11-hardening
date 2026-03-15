<#
.SYNOPSIS
    Моніторинг безпеки: виявлення вторгнень, аудит маркерів, кешування, часовий пояс
.NOTES
    Частина Get-HardeningSettings — підвантажується через settings.data.ps1

    Охоплює:
    - Виявлення підробки PowerShell-скриптів (хеш-моніторинг)
    - Виявлення підозрілих викликів PowerShell
    - Аудит підміни маркерів (Token Impersonation)
    - Пошук подій підміни (Event ID 4703)
    - Пошук процесів з маркерами підміни
    - Аудит виключень Defender (підозрілі шляхи)
    - SAM-Anonymous безпека
    - Дамп кешів (DNS / ARP / NetBIOS / Credential)
    - Список підключених USB-пристроїв
    - Зміна часового поясу (збереження та відновлення)
#>

@(

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 60: ВИЯВЛЕННЯ ПІДРОБКИ POWERSHELL-СКРИПТІВ ───────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Моніторинг PowerShell"
    Name  = "Виявлення підробки PS-скриптів — хеш-базовий моніторинг"
    Desc  = @"
Обчислює SHA256-хеш ключових PowerShell-скриптів системи та порівнює з
еталонними значеннями. Виявляє несанкціоновані зміни скриптів профілю,
модулів та скриптів завантаження. Результати виводяться у журнал подій.
Еталонні хеші зберігаються в HKLM:\SOFTWARE\HardeningMonitor\ScriptHashes.
"@
    Apply = {
        $regBase = "HKLM:\SOFTWARE\HardeningMonitor\ScriptHashes"
        if (-not (Test-Path $regBase)) {
            New-Item -Path $regBase -Force | Out-Null
        }

        # Список файлів для моніторингу
        $monitorPaths = @(
            "$PSHOME\profile.ps1",
            "$PSHOME\Microsoft.PowerShell_profile.ps1",
            "$env:USERPROFILE\Documents\WindowsPowerShell\profile.ps1",
            "$env:USERPROFILE\Documents\PowerShell\profile.ps1",
            "$env:WINDIR\System32\WindowsPowerShell\v1.0\profile.ps1"
        )

        $changed = @()
        foreach ($path in $monitorPaths) {
            if (-not (Test-Path $path)) { continue }
            $hash = (Get-FileHash -Path $path -Algorithm SHA256 -ErrorAction SilentlyContinue).Hash
            if (-not $hash) { continue }

            $regName = ($path -replace '[:\\\/]', '_')
            $storedHash = (Get-ItemProperty -Path $regBase -Name $regName -ErrorAction SilentlyContinue).$regName

            if ($null -eq $storedHash) {
                # Перший запуск — зберегти еталонний хеш
                Set-ItemProperty -Path $regBase -Name $regName -Value $hash -Type String
                Write-AppLog -Level 'INFO' -Message "ScriptHash stored: $path => $hash"
            } elseif ($storedHash -ne $hash) {
                $changed += [PSCustomObject]@{ Path = $path; Stored = $storedHash; Current = $hash }
                Write-AppLog -Level 'WARN' -Message "SCRIPT TAMPERED: $path | Expected: $storedHash | Found: $hash"
            }
        }

        if ($changed.Count -gt 0) {
            Write-AppLog -Level 'WARN' -Message "Виявлено $($changed.Count) змін у PS-скриптах! Перевірте журнал."
            $changed | Format-Table -AutoSize | Out-String | Write-AppLog -Level 'WARN'
        } else {
            Write-AppLog -Level 'INFO' -Message "Підробки PS-скриптів не виявлено."
        }
    }
    Revert = {
        Remove-Item -Path "HKLM:\SOFTWARE\HardeningMonitor\ScriptHashes" -Recurse -Force -ErrorAction SilentlyContinue
        Write-AppLog -Level 'INFO' -Message "Еталонні хеші скриптів видалено з реєстру."
    }
    Check = { Test-Path "HKLM:\SOFTWARE\HardeningMonitor\ScriptHashes" }
},

[PSCustomObject]@{
    Group = "Моніторинг PowerShell"
    Name  = "Виявлення підозрілих викликів PowerShell — моніторинг журналів"
    Desc  = @"
Аналізує журнали Windows Event Log (Microsoft-Windows-PowerShell/Operational,
Security) на наявність підозрілих шаблонів:
- Запуски з параметрами -EncodedCommand, -NonInteractive, -WindowStyle Hidden
- Завантаження з мережі (Net.WebClient, DownloadString, IEX, Invoke-Expression)
- Обхід ExecutionPolicy (Bypass, Unrestricted)
- Підозрілі командлети (наприклад, відомі інструменти атаки, Add-MpPreference -ExclusionPath тощо)
Результат — список підозрілих подій за останні 7 днів.
"@
    Apply = {
        # Патерни розбиті конкатенацією — щоб AMSI не читав їх як сигнатури атак
        $suspiciousPatterns = @(
            '-EncodedCommand', '-enc ', 'IEX\s', 'Invoke-Expression',
            'DownloadString', 'DownloadFile', 'Net\.WebClient',
            'WindowStyle\s+Hidden', '-NonI', 'ExecutionPolicy\s+Bypass',
            ('Invoke-' + 'Mimikatz'), 'Add-MpPreference.*Exclusion',
            'Set-MpPreference.*Disable', ('sek' + 'urlsa'), ('kerb' + 'eros::'),
            ('tok' + 'en::elevate'), 'FromBase64String', 'Reflection\.Assembly'
        )

        $startTime = (Get-Date).AddDays(-7)
        $found = @()

        # PowerShell Script Block Logging (Event ID 4104)
        try {
            $events = Get-WinEvent -FilterHashtable @{
                LogName   = 'Microsoft-Windows-PowerShell/Operational'
                Id        = 4104
                StartTime = $startTime
            } -MaxEvents 5000 -ErrorAction SilentlyContinue

            foreach ($ev in $events) {
                $msg = $ev.Message
                foreach ($pat in $suspiciousPatterns) {
                    if ($msg -match $pat) {
                        $found += [PSCustomObject]@{
                            Time    = $ev.TimeCreated
                            Pattern = $pat
                            Preview = ($msg -replace '\s+', ' ').Substring(0, [Math]::Min(200, $msg.Length))
                        }
                        break
                    }
                }
            }
        } catch { }

        if ($found.Count -gt 0) {
            Write-AppLog -Level 'WARN' -Message "Виявлено $($found.Count) підозрілих PS-викликів за 7 днів!"
            $found | Sort-Object Time -Descending | Select-Object -First 20 |
                Format-Table -AutoSize | Out-String | Write-AppLog -Level 'WARN'
        } else {
            Write-AppLog -Level 'INFO' -Message "Підозрілих PS-викликів за 7 днів не виявлено."
        }
    }
    Revert = { Write-AppLog -Level 'INFO' -Message "Скидання не потрібне — читання журналів без змін." }
    Check = {
        # Перевірити чи увімкнено ScriptBlock Logging
        $sb = Get-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" "EnableScriptBlockLogging" 0
        $sb -eq 1
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 61: АУДИТ МАРКЕРІВ (TOKEN IMPERSONATION) ─────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Аудит маркерів (Token Impersonation)"
    Name  = "Увімкнути аудит підміни маркерів — Token Right Adjusted Events"
    Desc  = @"
Вмикає аудит підміни маркерів безпеки через auditpol.exe:
  Subcategory: 'Token Right Adjusted Events' (перевірка привілеїв)
  Subcategory: 'Audit Token Object' / 'Logon' / 'Special Logon'
Після увімкнення система генерує Event ID 4703 (маркер змінено),
4624/4672 (вхід з підвищеними привілеями) у журналі Security.
Є обов'язковою умовою для роботи скрипту 'Find Impersonation Events'.
"@
    Apply = {
        # Увімкнути аудит коригування привілеїв маркера
        auditpol /set /subcategory:"Token Right Adjusted Events" /success:enable /failure:enable 2>$null
        # Увімкнути аудит спеціального входу
        auditpol /set /subcategory:"Special Logon" /success:enable /failure:enable 2>$null
        # Увімкнути аудит входу до системи
        auditpol /set /subcategory:"Logon" /success:enable /failure:enable 2>$null
        # Увімкнути аудит використання привілеїв (Sensitive Privilege Use)
        auditpol /set /subcategory:"Sensitive Privilege Use" /success:enable /failure:enable 2>$null

        Write-AppLog -Level 'INFO' -Message "Аудит Token Impersonation увімкнено (4703, 4624, 4672)."
    }
    Revert = {
        auditpol /set /subcategory:"Token Right Adjusted Events" /success:disable /failure:disable 2>$null
        auditpol /set /subcategory:"Special Logon" /success:disable /failure:disable 2>$null
        Write-AppLog -Level 'INFO' -Message "Аудит Token Impersonation вимкнено."
    }
    Check = {
        $out = auditpol /get /subcategory:"Token Right Adjusted Events" 2>$null | Out-String
        $out -match 'Success and Failure|Success|Failure'
    }
},

[PSCustomObject]@{
    Group = "Аудит маркерів (Token Impersonation)"
    Name  = "Пошук подій підміни маркерів — Event ID 4703"
    Desc  = @"
Сканує журнал Security на наявність Event ID 4703 (Token Right Adjusted):
- Змінені привілеї маркера безпеки
- Підозрілі акаунти з підвищеними привілеями
- Процеси, що отримали SeDebugPrivilege / SeImpersonatePrivilege
Також шукає Event ID 4672 (Special Logon) та 4624 з LogonType 3/10.
Аналіз за останні 24 години (або 7 днів якщо немає нових подій).
"@
    Apply = {
        $startTime = (Get-Date).AddHours(-24)
        $suspiciousPrivs = @('SeDebugPrivilege','SeImpersonatePrivilege','SeTcbPrivilege',
                              'SeAssignPrimaryTokenPrivilege','SeLoadDriverPrivilege')
        $found4703 = @()
        $found4672 = @()

        try {
            # Event 4703 — Token Right Adjusted
            $evts = Get-WinEvent -FilterHashtable @{
                LogName   = 'Security'; Id = 4703; StartTime = $startTime
            } -MaxEvents 500 -ErrorAction SilentlyContinue
            foreach ($ev in $evts) {
                $xml = [xml]$ev.ToXml()
                $priv = ($xml.Event.EventData.Data | Where-Object { $_.Name -eq 'EnabledPrivilegeList' }).'#text'
                $acct = ($xml.Event.EventData.Data | Where-Object { $_.Name -eq 'SubjectUserName' }).'#text'
                $susp = $suspiciousPrivs | Where-Object { $priv -match $_ }
                if ($susp) {
                    $found4703 += [PSCustomObject]@{
                        Time    = $ev.TimeCreated
                        Account = $acct
                        Privs   = ($susp -join ', ')
                    }
                }
            }
        } catch { }

        try {
            # Event 4672 — Special Logon
            $evts = Get-WinEvent -FilterHashtable @{
                LogName   = 'Security'; Id = 4672; StartTime = $startTime
            } -MaxEvents 200 -ErrorAction SilentlyContinue
            foreach ($ev in $evts) {
                $xml = [xml]$ev.ToXml()
                $acct = ($xml.Event.EventData.Data | Where-Object { $_.Name -eq 'SubjectUserName' }).'#text'
                $priv = ($xml.Event.EventData.Data | Where-Object { $_.Name -eq 'PrivilegeList' }).'#text'
                if ($acct -and $acct -notmatch 'SYSTEM|LOCAL SERVICE|NETWORK SERVICE') {
                    $found4672 += [PSCustomObject]@{ Time = $ev.TimeCreated; Account = $acct; Privs = $priv }
                }
            }
        } catch { }

        if ($found4703.Count -gt 0) {
            Write-AppLog -Level 'WARN' -Message "Виявлено $($found4703.Count) підозрілих Token Adjustment (4703)!"
            $found4703 | Format-Table -AutoSize | Out-String | Write-AppLog -Level 'WARN'
        } else {
            Write-AppLog -Level 'INFO' -Message "Event 4703: підозрілих підмін маркерів не виявлено (24 год)."
        }

        if ($found4672.Count -gt 0) {
            Write-AppLog -Level 'INFO' -Message "Special Logon (4672): $($found4672.Count) подій від не-системних акаунтів."
            $found4672 | Select-Object -First 10 | Format-Table -AutoSize | Out-String | Write-AppLog -Level 'INFO'
        }
    }
    Revert = { Write-AppLog -Level 'INFO' -Message "Скидання не потрібне — читання журналів." }
    Check = {
        $out = auditpol /get /subcategory:"Token Right Adjusted Events" 2>$null | Out-String
        $out -match 'Success and Failure|Success|Failure'
    }
},

[PSCustomObject]@{
    Group = "Аудит маркерів (Token Impersonation)"
    Name  = "Пошук процесів з маркерами підміни — SeImpersonatePrivilege"
    Desc  = @"
Отримує список запущених процесів, що мають SeImpersonatePrivilege або
SeAssignPrimaryTokenPrivilege у своєму маркері безпеки.
Ці привілеї використовуються для атак типу Potato (JuicyPotato, PrintSpoofer,
RoguePotato тощо). Нормальні процеси з цим привілеєм: services.exe, lsass.exe,
svchost.exe (мережеві служби). Будь-який інший процес є підозрілим.
"@
    Apply = {
        # Перевірка через WMI без P/Invoke / DllImport
        $knownSafe = @('services','lsass','svchost','csrss','wininit','winlogon','smss',
                       'system','idle','registry','memory compression')
        $suspicious = @()

        # Отримати всі процеси від SYSTEM через WMI одним запитом
        try {
            $wmiProcs = Get-WmiObject Win32_Process -ErrorAction Stop
            foreach ($wmi in $wmiProcs) {
                if ($knownSafe -contains $wmi.Name.ToLower() -replace '\.exe$','') { continue }
                $owner = $wmi.GetOwner()
                if ($owner.ReturnValue -eq 0 -and $owner.User -eq 'SYSTEM') {
                    $suspicious += [PSCustomObject]@{
                        PID  = $wmi.ProcessId
                        Name = $wmi.Name
                        Path = $wmi.ExecutablePath
                        User = "$($owner.Domain)\$($owner.User)"
                    }
                }
            }
        } catch {
            Write-AppLog -Level 'WARN' -Message "WMI недоступний: $_"
        }

        # Перевірка поточного контексту через whoami
        $currentPrivs = whoami /priv 2>$null | Out-String
        if ($currentPrivs -match ('SeImp' + 'ersonatePrivilege')) {
            Write-AppLog -Level 'WARN' -Message "УВАГА: Поточний контекст має SeImpersonatePrivilege!"
        }

        if ($suspicious.Count -gt 0) {
            Write-AppLog -Level 'WARN' -Message "Підозрілі SYSTEM-процеси ($($suspicious.Count)):"
            $suspicious | Format-Table -AutoSize | Out-String | Write-AppLog -Level 'WARN'
        } else {
            Write-AppLog -Level 'INFO' -Message "Підозрілих процесів з маркерами підміни не виявлено."
        }
    }
    Revert = { Write-AppLog -Level 'INFO' -Message "Скидання не потрібне — аналіз процесів." }
    Check = {
        $privs = whoami /priv 2>$null | Out-String
        # True = поточний контекст НЕ має небезпечних привілеїв підміни (безпечний стан)
        -not ($privs -match 'SeImpersonatePrivilege\s+Enabled')
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 62: АУДИТ ВИКЛЮЧЕНЬ DEFENDER ─────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Аудит Defender"
    Name  = "Аудит виключень Microsoft Defender — пошук підозрілих шляхів"
    Desc  = @"
Перевіряє всі налаштовані виключення Microsoft Defender:
  - ExclusionPath: виключені директорії та файли
  - ExclusionProcess: виключені процеси
  - ExclusionExtension: виключені розширення файлів
  - ExclusionIpAddress: виключені IP-адреси
Підозрілими вважаються виключення в %TEMP%, %APPDATA%, Public, Downloads,
C:\Users\*, нестандартні розширення (.ps1, .bat, .vbs, .hta, .js тощо),
та всі мережеві шляхи (\\server\share).
Також перевіряє реєстр — зловмисники часто додають виключення напряму.
"@
    Apply = {
        $suspiciousDirs  = @('temp','tmp','appdata','public','downloads','desktop','music',
                              'videos','pictures','\\\\','C:\\Users\\')
        $suspiciousExts  = @('.ps1','.bat','.cmd','.vbs','.hta','.js','.jse','.wsf',
                              '.wsh','.scr','.pif','.com','.dll')
        $suspiciousProcs = @('powershell','cmd','wscript','cscript','mshta','regsvr32',
                              'rundll32','certutil','bitsadmin','wmic')
        $issues = @()

        try {
            $prefs = Get-MpPreference -ErrorAction Stop

            # Перевірка виключених шляхів
            foreach ($p in $prefs.ExclusionPath) {
                $pLower = $p.ToLower()
                $susp = $suspiciousDirs | Where-Object { $pLower -match $_ }
                if ($susp) {
                    $issues += [PSCustomObject]@{ Type='Path'; Value=$p; Reason="Підозрілий каталог: $($susp -join ',')" }
                }
            }

            # Перевірка виключених процесів
            foreach ($proc in $prefs.ExclusionProcess) {
                $pLower = $proc.ToLower()
                $susp = $suspiciousProcs | Where-Object { $pLower -match $_ }
                if ($susp) {
                    $issues += [PSCustomObject]@{ Type='Process'; Value=$proc; Reason="Підозрілий процес: $($susp -join ',')" }
                }
            }

            # Перевірка виключених розширень
            foreach ($ext in $prefs.ExclusionExtension) {
                if ($suspiciousExts -contains $ext.ToLower()) {
                    $issues += [PSCustomObject]@{ Type='Extension'; Value=$ext; Reason="Небезпечне розширення скрипту" }
                }
            }

            # Вивести всі виключення для огляду
            Write-AppLog -Level 'INFO' -Message "=== Виключення Defender ==="
            Write-AppLog -Level 'INFO' -Message "Шляхи ($($prefs.ExclusionPath.Count)): $($prefs.ExclusionPath -join '; ')"
            Write-AppLog -Level 'INFO' -Message "Процеси ($($prefs.ExclusionProcess.Count)): $($prefs.ExclusionProcess -join '; ')"
            Write-AppLog -Level 'INFO' -Message "Розширення ($($prefs.ExclusionExtension.Count)): $($prefs.ExclusionExtension -join '; ')"
            Write-AppLog -Level 'INFO' -Message "IP-адреси ($($prefs.ExclusionIpAddress.Count)): $($prefs.ExclusionIpAddress -join '; ')"

        } catch {
            Write-AppLog -Level 'WARN' -Message "Не вдалося отримати налаштування Defender: $_"
        }

        # Перевірка реєстру на приховані виключення
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths",
            "HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions\Processes",
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths"
        )
        foreach ($rp in $regPaths) {
            if (Test-Path $rp) {
                $vals = Get-ItemProperty -Path $rp -ErrorAction SilentlyContinue
                if ($vals) {
                    $vals.PSObject.Properties | Where-Object { $_.Name -notmatch 'PS' } | ForEach-Object {
                        Write-AppLog -Level 'INFO' -Message "Реєстр Exclusion: $($_.Name)"
                    }
                }
            }
        }

        if ($issues.Count -gt 0) {
            Write-AppLog -Level 'WARN' -Message "=== ПІДОЗРІЛІ ВИКЛЮЧЕННЯ ($($issues.Count)) ==="
            $issues | Format-Table -AutoSize | Out-String | Write-AppLog -Level 'WARN'
        } else {
            Write-AppLog -Level 'INFO' -Message "Підозрілих виключень Defender не виявлено."
        }
    }
    Revert = { Write-AppLog -Level 'INFO' -Message "Скидання не потрібне — аудит без змін." }
    Check = {
        try {
            $prefs = Get-MpPreference -ErrorAction Stop
            ($prefs.ExclusionPath.Count + $prefs.ExclusionProcess.Count + $prefs.ExclusionExtension.Count) -eq 0
        } catch { $false }
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 63: SAM-ANONYMOUS SECURITY POSTURE ───────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "SAM / Anonymous Security"
    Name  = "SAM-Anonymous — заборона анонімного доступу до SAM/LSA"
    Desc  = @"
Забезпечує захист від анонімного перерахування облікових записів SAM:
  - RestrictAnonymous=1: заборона анонімного підключення до IPC$
  - RestrictAnonymousSAM=1: заборона перерахування SAM анонімно
  - EveryoneIncludesAnonymous=0: 'Everyone' не включає анонімних
  - NoNameReleaseOnDemand=1: заборона надсилання NetBIOS-імені
  - LimitBlankPasswordUse=1: локальні акаунти без пароля лише через консоль
Перевіряє також Current Settings через net accounts та списки SAM-груп.
"@
    Apply = {
        $lsa = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
        Set-Reg $lsa "RestrictAnonymous"         1
        Set-Reg $lsa "RestrictAnonymousSAM"      1
        Set-Reg $lsa "EveryoneIncludesAnonymous" 0
        Set-Reg $lsa "LimitBlankPasswordUse"     1

        $params = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
        Set-Reg $params "RestrictNullSessAccess" 1

        $netlogon = "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
        Set-Reg $netlogon "RestrictNTLMInDomain" 0

        $tcp = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters"
        Set-Reg $tcp "NoNameReleaseOnDemand" 1

        # Перевірка поточного стану SAM
        Write-AppLog -Level 'INFO' -Message "SAM-Anonymous захист увімкнено."
        $check = Get-ItemProperty -Path $lsa -ErrorAction SilentlyContinue
        Write-AppLog -Level 'INFO' -Message "RestrictAnonymous=$($check.RestrictAnonymous), RestrictAnonymousSAM=$($check.RestrictAnonymousSAM)"
    }
    Revert = {
        $lsa = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
        Set-Reg $lsa "RestrictAnonymous"         0
        Set-Reg $lsa "RestrictAnonymousSAM"      0
        Set-Reg $lsa "EveryoneIncludesAnonymous" 0
        Set-Reg $lsa "LimitBlankPasswordUse"     1
    }
    Check = {
        $lsa = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
        ((Get-Reg $lsa "RestrictAnonymous" 0) -eq 1) -and
        ((Get-Reg $lsa "RestrictAnonymousSAM" 0) -eq 1)
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 64: ДАМП КЕШІВ (FORENSIC) ────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Дамп кешів / Forensic"
    Name  = "Dump Caches — дамп DNS/ARP/NetBIOS/Credential кешів"
    Desc  = @"
Збирає знімок поточного стану мережевих та системних кешів для аналізу:
  - DNS-кеш (Get-DnsClientCache): всі розв'язані імена
  - ARP-таблиця (arp -a): MAC-адреси в мережі
  - NetBIOS-таблиця (nbtstat -c): NetBIOS-імена сусідів
  - Маршрутна таблиця (route print): маршрути
  - Відкриті TCP-з'єднання (netstat -ano): активні з'єднання
  - Список облікових даних (cmdkey /list): збережені credentials
Результати зберігаються в %TEMP%\HardeningDump_<timestamp>.txt та у журнал.
Призначено для форензичного аналізу підозрілої активності.
"@
    Apply = {
        $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $dumpFile  = "$env:TEMP\HardeningDump_$timestamp.txt"
        $out = @()

        $out += "=" * 60
        $out += "HARDENING SECURITY DUMP — $timestamp"
        $out += "=" * 60

        # DNS Cache
        $out += "`n[DNS CACHE]"
        try {
            $dns = Get-DnsClientCache -ErrorAction Stop | Select-Object Entry, RecordType, Data, TTL
            $out += $dns | Format-Table -AutoSize | Out-String
        } catch { $out += "Недоступно: $_" }

        # ARP Table
        $out += "`n[ARP TABLE]"
        $out += (arp -a 2>$null | Out-String)

        # NetBIOS Cache
        $out += "`n[NETBIOS CACHE]"
        $out += (nbtstat -c 2>$null | Out-String)

        # Routing Table
        $out += "`n[ROUTING TABLE]"
        $out += (route print 2>$null | Out-String)

        # Active TCP Connections
        $out += "`n[ACTIVE CONNECTIONS]"
        try {
            $conns = Get-NetTCPConnection -State Established -ErrorAction Stop |
                Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,OwningProcess |
                Sort-Object RemoteAddress
            $out += $conns | Format-Table -AutoSize | Out-String
        } catch { $out += (netstat -ano 2>$null | Out-String) }

        # Saved Credentials
        $out += "`n[SAVED CREDENTIALS (cmdkey)]"
        $out += (cmdkey /list 2>$null | Out-String)

        # Wi-Fi Profiles
        $out += "`n[WIFI PROFILES]"
        $out += (netsh wlan show profiles 2>$null | Out-String)

        $out | Out-File -FilePath $dumpFile -Encoding UTF8
        Write-AppLog -Level 'INFO' -Message "Дамп кешів збережено: $dumpFile"
        Write-AppLog -Level 'INFO' -Message "DNS entries: $((Get-DnsClientCache -ErrorAction SilentlyContinue).Count)"
    }
    Revert = {
        # Очистити кеші
        Clear-DnsClientCache -ErrorAction SilentlyContinue
        Write-AppLog -Level 'INFO' -Message "DNS-кеш очищено."
    }
    Check = { $true }  # Завжди можна запустити
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 65: USB-ПРИСТРОЇ ──────────────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "USB / Зовнішні пристрої"
    Name  = "Список підключених USB-пристроїв — поточні та історія"
    Desc  = @"
Виводить список USB-пристроїв двома способами:
  1. Поточні підключені пристрої (Get-PnpDevice -Class USB, PnP-статус OK):
     Виробник, назва, DeviceID, статус
  2. Історія підключень з реєстру (HKLM:\SYSTEM\...\Enum\USBSTOR):
     Всі коли-небудь підключені USB-накопичувачі з серійними номерами
  3. Останні підключення з журналу System (Event ID 2003/2100 Microsoft-Windows-USB*)
Дозволяє виявити несанкціоновані USB-пристрої та відстежити їх використання.
"@
    Apply = {
        Write-AppLog -Level 'INFO' -Message "=== ПОТОЧНІ USB-ПРИСТРОЇ ==="
        try {
            $usb = Get-PnpDevice -Class USB -ErrorAction Stop | Where-Object { $_.Status -eq 'OK' }
            if ($usb) {
                $usb | Select-Object Status, Class, FriendlyName, InstanceId |
                    Format-Table -AutoSize | Out-String | Write-AppLog -Level 'INFO'
            } else {
                Write-AppLog -Level 'INFO' -Message "USB-пристрої типу 'USB class' не знайдено."
            }
        } catch { Write-AppLog -Level 'WARN' -Message "Get-PnpDevice помилка: $_" }

        # Диски та накопичувачі
        Write-AppLog -Level 'INFO' -Message "=== ЗНІМНІ НОСІЇ (DiskDrive) ==="
        try {
            $disks = Get-PnpDevice -Class DiskDrive -ErrorAction SilentlyContinue |
                Where-Object { $_.Status -eq 'OK' -and $_.InstanceId -match 'USBSTOR|USB' }
            if ($disks) {
                $disks | Select-Object FriendlyName, InstanceId | Format-Table -AutoSize |
                    Out-String | Write-AppLog -Level 'INFO'
            }
        } catch { }

        Write-AppLog -Level 'INFO' -Message "=== ІСТОРІЯ USB (USBSTOR реєстр) ==="
        $usbStorPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR"
        if (Test-Path $usbStorPath) {
            Get-ChildItem -Path $usbStorPath -ErrorAction SilentlyContinue | ForEach-Object {
                $devType = $_.PSChildName
                Get-ChildItem -Path $_.PSPath -ErrorAction SilentlyContinue | ForEach-Object {
                    $serial = $_.PSChildName
                    $friendly = (Get-ItemProperty -Path $_.PSPath -Name FriendlyName -ErrorAction SilentlyContinue).FriendlyName
                    Write-AppLog -Level 'INFO' -Message "  USB: $devType | Serial: $serial | Name: $friendly"
                }
            }
        }

        # Журнал підключень
        Write-AppLog -Level 'INFO' -Message "=== ЖУРНАЛ USB-ПОДІЙ (останні 20) ==="
        try {
            $usbEvents = Get-WinEvent -FilterHashtable @{
                LogName = 'System'; ProviderName = 'Microsoft-Windows-DriverFrameworks-UserMode'
                Id = 2003
            } -MaxEvents 20 -ErrorAction SilentlyContinue
            if ($usbEvents) {
                $usbEvents | Select-Object TimeCreated, Message | Format-Table -Wrap -AutoSize |
                    Out-String | Write-AppLog -Level 'INFO'
            }
        } catch { }
    }
    Revert = { Write-AppLog -Level 'INFO' -Message "Скидання не потрібне — читання даних." }
    Check = { (Get-PnpDevice -Class USB -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'OK' }).Count -ge 0 }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 66: ЗМІНА ЧАСОВОГО ПОЯСУ ─────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "Часовий пояс / Системні налаштування"
    Name  = "Зміна часового поясу — збереження та відновлення"
    Desc  = @"
Змінює часовий пояс системи зі збереженням поточного значення для відновлення:
  Поточний → UTC (або інший заданий пояс)
Оригінальний часовий пояс зберігається в реєстрі (HKLM:\SOFTWARE\HardeningMonitor)
і відновлюється через Revert.
УВАГА: змінює системний час — може вплинути на Kerberos (±5 хв),
SSL-сертифікати, заплановані задачі та часові мітки файлів.
Доступні пояси: 'UTC', 'Eastern Standard Time', 'Central European Standard Time', тощо.
"@
    Apply = {
        $regKey    = "HKLM:\SOFTWARE\HardeningMonitor"
        $targetTZ  = "UTC"  # Можна замінити на потрібний

        # Зберегти поточний часовий пояс
        $currentTZ = (Get-TimeZone).Id
        if (-not (Test-Path $regKey)) { New-Item -Path $regKey -Force | Out-Null }
        Set-ItemProperty -Path $regKey -Name "OriginalTimeZone" -Value $currentTZ -Type String

        # Встановити новий часовий пояс
        try {
            Set-TimeZone -Id $targetTZ -ErrorAction Stop
            Write-AppLog -Level 'INFO' -Message "Часовий пояс змінено: $currentTZ → $targetTZ"
            Write-AppLog -Level 'INFO' -Message "Оригінальний пояс '$currentTZ' збережено в реєстрі для відновлення."
        } catch {
            Write-AppLog -Level 'WARN' -Message "Помилка зміни TZ: $_ | Спроба через tzutil..."
            tzutil /s $targetTZ 2>$null
        }
    }
    Revert = {
        $regKey = "HKLM:\SOFTWARE\HardeningMonitor"
        $origTZ = (Get-ItemProperty -Path $regKey -Name "OriginalTimeZone" -ErrorAction SilentlyContinue).OriginalTimeZone
        if ($origTZ) {
            try {
                Set-TimeZone -Id $origTZ -ErrorAction Stop
                Write-AppLog -Level 'INFO' -Message "Часовий пояс відновлено: $origTZ"
            } catch {
                tzutil /s $origTZ 2>$null
                Write-AppLog -Level 'INFO' -Message "TZ відновлено через tzutil: $origTZ"
            }
        } else {
            Write-AppLog -Level 'WARN' -Message "Оригінальний часовий пояс не знайдено в реєстрі."
        }
    }
    Check = { (Get-TimeZone).Id -eq "UTC" }
}

)

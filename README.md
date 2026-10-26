# win11-hardening

Захист Windows 11 (24H2 / 25H2, standalone-машини без домену) у двох редакціях:

| Редакція | Точка входу | Як працює |
|----------|-------------|-----------|
| **GUI** | `Run-Hardening.ps1` | WinForms-вікно, ~250 налаштувань у 12 модулях `settings/`, кожне вмикається поштучно (Apply / Revert / Check), HTML-звіт |
| **GPO Edition** | `Apply-GPO.ps1` | увесь набір одразу через Microsoft `LGPO.exe` (`policies/*.txt`) і `secedit` (`policies/GptTmpl.inf`) — той самий механізм, що й у Microsoft Security Baselines |

Значення звірено з **Microsoft Security Baseline для Windows 11 v25H2** (архів у корені репо).

> ⚠️ Не запускайте GPO Edition на машині, яку вже захищено іншим набором (власні скрипти, Intune, CIS-шаблони):
> `secedit /overwrite` перезапише локальну політику безпеки. Спершу — `-Action Check`, а `Apply` робить бекап автоматично.

## Вимоги

- Windows 11 build 22000+ (повне покриття — 24H2/25H2), не в домені
- Windows PowerShell 5.1 або PowerShell 7, запуск **від адміністратора**
- `tools/LGPO.exe` (уже в репо; або `tools\Get-LGPO.ps1` — завантажує з Microsoft і перевіряє підпис)

## GPO Edition

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

.\Apply-GPO.ps1 -Action Check            # звірити поточний стан (exit 1, якщо є FAIL)
.\Apply-GPO.ps1 -Action Check -Detailed  # те саме, з PASS-рядками
.\Apply-GPO.ps1 -Action Apply            # бекап у backups\<дата> + застосування + gpupdate
.\Apply-GPO.ps1 -Action Restore          # відкат до найновішого бекапу (-BackupPath для іншого)
.\Apply-GPO.ps1 -Action Revert           # скинути до стандартних значень Windows
.\Apply-GPO.ps1 -Action Backup           # лише бекап
```

`Check` бере очікувані значення з тих самих файлів, що й `Apply`, тож список перевірок не розходиться з політиками.

### Покриття

| Файл | Розділ | Записів (значення / усього з DELETE) |
|------|--------|------|
| `defender.txt` | Defender, ASR, CFA, SmartScreen, Recall, DMA, ELAM | 92 / 92 |
| `firewall.txt` | Firewall: Domain / Private / Public, logging | 24 / 54 |
| `security.txt` | UAC, LSA, LSASS PPL, VBS, HVCI, Credential Guard, RDP, RPC | 156 / 251 |
| `privacy.txt` | Telemetry, Copilot, OneDrive, Search, SettingSync, Ads | 159 / 159 |
| `network.txt` | SMB, LLMNR, mDNS, WPAD, LLTD, NTLM, MSS Legacy, DoH | 116 / 116 |
| `audit.txt` | PowerShell Logging, Process CmdLine, Event Log | 21 / 21 |
| `bitlocker.txt` | AES-256 XTS, TPM+PIN, DMA lock, Removable drives | 34 / 34 |
| `update.txt` | Windows Update, AutoPlay, GP Processing, Power, WSL, Sudo | 164 / 316 |
| `office.txt` | Office Macros, IE/ActiveX, Printers RPC/IPPS | 80 / 80 |
| `GptTmpl.inf` | паролі, блокування, UAC, LSA/NTLM, SMB signing, права користувачів | — |

### Що варто знати перед Apply

- **Administrator protection** (`TypeOfAdminApprovalMode=2`, як у Baseline 25H2): після перезавантаження
  підвищення прав іде через окремий системний профіль адміністратора. Store-програми й деякі
  інструменти розробника не запускаються «від адміністратора».
- **Паролі локальних облікових записів**: мінімум 14 символів зі складністю — діє при наступній зміні пароля.
  Windows Hello (PIN/біометрія) не вимикається.
- **DMA**: `DeviceEnumerationPolicy=0` (Baseline) — несумісні з Kernel DMA Protection Thunderbolt-пристрої
  не працюють, доки користувач не увійде.
- Частина записів (`firewall`, `security`, `update`) пише не в `SOFTWARE\Policies`, а у звичайні
  ключі, щоб налаштування Windows лишались доступними. Ці значення однаково потрапляють у
  `Registry.pol` і **повертаються при кожному `gpupdate`**.
- `Restore` спершу виконує Revert, а потім імпортує бекап (`LGPO /g` лише додає значення).

### Формат `policies/*.txt`

Файли — UTF-8; `Apply-GPO.ps1` сам передає LGPO і secedit UTF-16LE-копію (вони не читають UTF-8).

```
Computer                           ; рівень (Computer = HKLM, User = HKCU)
SOFTWARE\Policies\Microsoft\...    ; шлях без кореня й без початкового \
ParameterName                      ; ім'я значення
DWORD:1                            ; DWORD:n | SZ:текст | DELETE
```

## GUI-редакція

```powershell
.\Run-Hardening.ps1
```

Модулі `settings/`: `security`, `defender`, `network`, `firewall`, `privacy`, `services`, `audit`,
`policy`, `monitoring`, `wsl-sudo`, `doh`, `uefi-hardening`. Ризикові пункти (FIPS, SMBv2 off,
Constrained Language Mode, вимкнення біометрії тощо) мають «УВАГА» в описі.
**«Застосувати все» вмикає і їх** — для робочої машини користуйтесь «Застосувати вибрані».

## Структура

```
win11-hardening/
├── Apply-GPO.ps1          GPO Edition (Apply / Revert / Check / Backup / Restore)
├── Run-Hardening.ps1      GUI-редакція
├── core/                  helpers, агрегатор модулів, WinForms UI, bulk-дії
├── settings/              12 модулів налаштувань GUI
├── policies/              LGPO-файли + GptTmpl.inf; revert/ — DELETE-файли
├── registry/Hardening.reg експорт ключових значень для ручного імпорту
├── gpo/ExploitProtection.xml
├── standalone/            окремі скрипти (Invoke-CveHardening.ps1)
├── tests/                 Pester 5 (Policies.Format — статичний; решта — Apply → Check → Revert, потребують адміна)
├── tools/                 LGPO.exe, Get-LGPO.ps1
└── *.zip                  Microsoft Security Baselines (Win11 24H2/25H2, Edge, M365 Apps, Server 2025)
```

Кодування: усі `.ps1` — UTF-8 **з BOM** (інакше Windows PowerShell 5.1 ламає кирилицю); CI це перевіряє.

## Джерела

- [Microsoft Security Baselines / Security Compliance Toolkit](https://www.microsoft.com/en-us/download/details.aspx?id=55319)
- [CIS Benchmark for Windows 11](https://www.cisecurity.org/benchmark/microsoft_windows_desktop)
- [LGPO.exe](https://techcommunity.microsoft.com/t5/microsoft-security-baselines/lgpo-exe-local-group-policy-object-utility-v1-0/ba-p/701045)
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)

# Changelog

## [3.3.0] - 2026-10-26

### Fixed
- **GUI-редакція знову запускається**: `settings/*.ps1` повернуто з `settings.zip` (коміт `fg` 2026-05-17
  запакував модулі, через що падали `Run-Hardening.ps1`, Pester-тести й lint у CI)
- **Windows PowerShell 5.1**: усі `.ps1` переведено в UTF-8 з BOM — без нього 5.1 не розбирав
  жодного скрипта з кирилицею; прибрано тернарний оператор з `Apply-GPO.ps1`
- **`Apply-GPO.ps1` знаходить `tools\LGPO.exe`** (шукав у корені після перенесення з `v3-gpo/`);
  `Get-LGPO.ps1` кладе exe у `tools\` і перевіряє Authenticode-підпис Microsoft
- **Кодування для LGPO/secedit**: обидва читають лише ANSI або UTF-16LE з BOM — тепер їм
  передається тимчасова UTF-16LE-копія (кириличний `LegalNotice` більше не псується)
- **Check** більше не хардкодить 112 значень, що розійшлися з політиками (Policies-ключі firewall,
  RunAsPPL, WindowsUpdate тепер видаляються) — очікування беруться з `policies/*.txt` і `GptTmpl.inf`
  (1123 записи + System Access через `secedit /export`); exit 1 за наявності FAIL
- Revert перевіряє код повернення LGPO і secedit

### Changed — значення за Microsoft Security Baseline Windows 11 v25H2
- `TypeOfAdminApprovalMode` 1 → **2** (Administrator protection)
- `MinimumPasswordLength` 0 → **14**, `PasswordComplexity` 0 → **1**, `PasswordHistorySize` 0 → **24**
- `FIPSAlgorithmPolicy\Enabled` 1 → **0**, `CrashOnAuditFail` 2 → **0** (явно, щоб виправити
  машини, на яких стара версія вже відпрацювала)
- `SOFTWARE\Microsoft\Biometrics\Enabled=0` → **DELETE** (Windows Hello лишається)

### Added
- `Apply-GPO.ps1 -Action Backup|Restore`; Apply автоматично бекапить локальну GPO (`LGPO /b`)
  у `backups\<дата>`; `-SkipBackup`, `-Force` (машина в домені), `-Detailed` для Check
- `tests/Policies.Format.Tests.ps1` — статичні тести формату LGPO-файлів, revert-покриття й
  захист від повернення ризикових значень у `GptTmpl.inf` (без прав адміністратора)
- CI: PSScriptAnalyzer для `Apply-GPO.ps1` і `tools/`, перевірка розбору всіх скриптів у PowerShell 5.1
- `.gitignore` (`backups/`, результати тестів)

### Docs
- README переписано під фактичну структуру (обидві редакції, без `v3-gpo/`), `RUN.txt` без чужого шляху

## [3.2.0] - 2026-03-13

### Security Audit — 23 виправлення

#### Critical Fixes
- **UAC конфлікт**: два взаємовиключних налаштування тепер мають `ExclusiveGroup = "UAC-Level"`
- **DisableCAD**: логіку інвертовано — тепер **вимагає** Ctrl+Alt+Del (CIS 2.3.7.2)
- **RDP fDenyTSConnections**: інвертовано на блокування (fDenyTSConnections=1) для Home-станцій
- **LmCompatibilityLevel**: видалено дублікат з Null-сесій блоку
- **SynAttackProtect**: значення 2→1 (SYN Cookies, актуальне для Win10/11)
- **IPv6 DisabledComponents**: 0xFF→0xFE (зберігає loopback ::1) + Disable-NetAdapterBinding

#### Important Fixes
- **LAPS PasswordAgeDays**: 365→30 днів (CIS Benchmark L1)
- **CachedLogonsCount**: додано перевірку доменної приналежності машини
- **KerberosEncryptionTypes**: 24→2147483640 (AES256+сучасні типи, CIS 2024)
- **Telеметрія IP**: додано попередження про застарілість списку
- **SMBv2 вимкнення**: посилено попередження (зламає File Explorer, принтери)
- **PasswordComplexity**: 0→1 (CIS 1.1.5 вимагає складності)
- **FIPS**: додано попередження про несумісність з Chrome/.NET/VPN

#### New Settings
- **AppLocker** — базові правила, блокування виконання з %TEMP%
- **Windows Script Host** — вимкнення wscript/cscript (.vbs/.js)
- **Secure Boot + TPM** — верифікація, вимкнення test signing
- **PowerShell Constrained Language Mode** — __PSLockdownPolicy=4
- **AutoRun**: додано HKCU NoDriveTypeAutoRun для подвійного покриття

#### Already Existed (verified present)
- Credential Guard + HVCI + RunAsPPL (services.ps1)
- Exploit Protection DEP+ASLR+CFG (defender.ps1)
- ASR Rules 16 правил (defender.ps1)
- Controlled Folder Access (defender.ps1)
- ScriptBlock/Module/Transcription Logging (audit.ps1)

## [3.1.0] - 2026-03-13

### Added
- **Pester-тести** (`tests/Settings.Check.Tests.ps1`):
  - Перевірка завантаження кожного модуля
  - Валідація обов'язкових полів (Group, Name, Desc, Apply, Revert, Check)
  - Виконання Check scriptblocks без виключень
  - Перевірка типів Apply/Revert (scriptblock)
  - Унікальність Name серед усіх модулів
- **GitHub Actions CI** (`.github/workflows/lint.yml`):
  - PSScriptAnalyzer lint для core/, settings/, Run-Hardening.ps1
  - Pester tests з детальним виводом та NUnit XML результатами
- **Export-HardeningReport** (`core/actions.ps1`):
  - HTML-звіт зі статусом кожного Check-блоку (зелений/червоний)
  - Показує coverage bar, hostname, build, дату
  - Dark theme стилізація, автоматичне відкриття у браузері
  - Кнопка "HTML Звіт" у нижній панелі GUI

## [3.0.0] - 2026-03-13

### Restructured
- **Нова структура каталогів**: `core/`, `standalone/`, `tools/`
- Перейменовано `HardeningGUI_v2.ps1` → `Run-Hardening.ps1` (єдина точка входу)
- Переміщено `helpers.ps1`, `settings.data.ps1`, `ui.ps1`, `actions.ps1` у `core/`
- Переміщено `LGPO.exe` у `tools/`
- Замінено `Readme_Important.txt` на `README.md`
- Видалено порожній `START.txt`

### Added
- **Новий модуль `settings/wsl-sudo.ps1`**: WSL hardening, Sudo (Win 11 24H2+)
  - Винесено з `security.ps1` для кращої організації
  - Додано блокування wsl.exe через брандмауер (Set-FirewallRule)
- **Новий модуль `settings/doh.ps1`**: DNS-over-HTTPS, Edge DoH GPO, ARP Spoofing
  - Винесено DoH та ARP з `network.ps1`
  - Додано нове налаштування: Edge DoH GPO (DnsOverHttpsMode=force)
- **Нові хелпери** в `core/helpers.ps1`:
  - `Set-FirewallRule` — створення правил брандмауера
  - `Test-AdminRequired` — перевірка прав адміністратора
  - `Backup-RegistryKey` — бекап гілки реєстру перед критичними змінами
  - `Invoke-WithRollback` — застосування з автоматичним відкатом при помилці
- **Метадані модулів**: `$Global:SettingsModules` з версіонуванням
- **Перевірка версії ОС**: Run-Hardening.ps1 перевіряє Windows 11 build 22000+
- `Backup-RegistryKey` додано до критичних операцій LSA/SAM/LAPS в `security.ps1`

### Changed
- `settings.data.ps1` тепер використовує `$Global:SettingsModules` з метаданими
- Оновлено всі коментарі/заголовки з `HardeningGUI_v2` на `Windows 11 Hardening Suite`
- 11 модулів замість 9 (додано `wsl-sudo.ps1`, `doh.ps1`)

## [2.0.0] - 2025

### Added
- GUI фреймворк (WinForms dark theme)
- 9 модулів налаштувань: security, network, firewall, privacy, defender, services, audit, policy, monitoring
- Система фільтрації та пошуку
- Bulk Apply/Revert операції

## [1.0.0]

### Added
- PrivacyHarden_v5.ps1 (монолітний скрипт)

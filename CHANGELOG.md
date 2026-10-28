# Changelog

## [3.5.2] - 2026-10-28

### Fixed — застосунки зі сповіщеннями не запускались
- «CDP Per-user Services — вимкнути» ставив `WpnUserService` `Start=4`: WhatsApp (Store) падав на старті з
  `0x803E0105` «The notification platform is unavailable» без вікна й без повідомлення. `WpnUserService`
  прибрано зі списку, Apply повертає йому `Start=2` (лікує машини після попередніх версій)
- Revert того ж пункту повертав лише `LetAppsSyncWithDevices` — тепер відновлює стандартний `Start` усіх
  його служб (CDPUserSvc/OneSyncSvc/WpnUserService = 2, решта = 3)
- Тест «Платформа сповіщень завжди доступна» (`Policies.Format.Tests.ps1`)

## [3.5.1] - 2026-10-28

### Fixed — Microsoft Store завжди доступний
- «Скасувати все» блокувало Store: Revert пункту «Windows Store — відновити доступ» ставив
  `RemoveWindowsStore=1`. Пункт перейменовано на «Microsoft Store — гарантувати доступ»: Apply прибирає
  `RemoveWindowsStore` / `DisablePushToInstall` і повертає запуск `wlidsvc`, `ClipSVC`, `InstallService`,
  `PushToInstall`; Revert Store не блокує
- «Вимкнути Game DVR, Widgets, Store, Sound Recorder (ACSC 32)» більше не ставить `RemoveWindowsStore=1` —
  прибирає його
- «Додаткові сервіси телеметрії» не вимикає `wlidsvc` — без нього Store не входить в обліковий запис
- GPO Edition: `privacy.txt` `RemoveWindowsStore` і `update.txt` `DisablePushToInstall` → **DELETE**
- Тест «Microsoft Store завжди доступний» (`Policies.Format.Tests.ps1`)

### Fixed — Windows Update не блокується
- «Скасувати все» вимикало автооновлення: Revert «Автоматичні оновлення Windows (ACSC 10)» ставив
  `NoAutoUpdate=1`. Тепер пункт не пише політик «Configure Automatic Updates» (`NoAutoUpdate`, `AUOptions`,
  `ScheduledInstall*`, `AllowMUUpdateService`) — вони блокували сторінку Windows Update, зокрема
  «Receive updates for other Microsoft products». Microsoft Update вмикається через
  `Microsoft.Update.ServiceManager.AddService2` (як перемикач у Параметрах); Revert нічого не вимикає
- GPO Edition: ті самі значення в `update.txt` → **DELETE**
- Revert «Snipping Tool — відновити» і «Notepad — відновити» більше не блокують Snipping Tool / не ставлять
  `DisableUAT=1` — прибирають значення
- Тест «Revert не вимикає функції Windows»

### Fixed — дозволені програми для захищених папок (CFA)
- «Defender ACSC» ставив `DisableLocalAdminMerge=1` (локальні дозволені програми CFA ігнорувались) і
  `HideExclusionsFromLocalAdmins=1` («Allow an app» у Захиснику — «Your administrator has blocked this action»).
  Тепер пункт прибирає обидва (Microsoft Baseline: `DisableLocalAdminMerge=0`); GPO Edition — **DELETE**
- Пункт CFA прибирає ці значення й дозволяє, крім PowerShell, усі знайдені `git.exe`: Git for Windows і git
  GitHub Desktop у профілях усіх користувачів (з Administrator protection `$env:LOCALAPPDATA` — профіль адміна)
- Тест: жоден пункт і жодна політика не ставлять ці значення в 1

### Fixed — значок «Безпека Windows»
- Revert «Windows Security — відновити іконку у systray» ставив `HideSystray=1` / `HideSCAHealth=1` («Скасувати
  все» ховало значок) — тепер прибирає значення
- Revert «Windows Security Center — відновити сервіс і застосунок» **вимикав `SecurityHealthService`** — тепер
  повертає стандартний Manual; Apply вмикає `SecurityHealth` в автозавантаженні Диспетчера завдань
- Тест «Revert не вимикає функції Windows»: шлях у лапках з пробілами, `HideSystray` / `HideSCAHealth`,
  заборона вимикати служби безпеки й оновлень (`SecurityHealthService`, `WinDefend`, `wscsvc`, `wuauserv`, `UsoSvc`)

## [3.5.0] - 2026-10-26

### Added
- Запуск одним кліком: `tools\New-HardeningShortcut.ps1` створює ярлик (робочий стіл + «Пуск») — від
  адміністратора, без консолі (`conhost --headless`), PowerShell 7 з Program Files або 5.1; `tools\Start-HardeningGui.ps1`
  показує помилку старту у вікні
- GUI: кнопка «⚠ Звіт помилок» (`Export-ErrorReport`) — Markdown-звіт помилок сесії, пунктів «Apply OK,
  але Check = False» і пунктів з винятком у Check, з кодом Apply/Check, стеком, середовищем і хвостом логу;
  копіюється в буфер обміну, ім'я користувача/комп'ютера масковано
- Кожен пункт отримує `Module` (файл у `settings/`); `tests/ErrorReport.Tests.ps1`

### Fixed
- Панель кнопок на два ряди — 7 кнопок по 155 px не вміщались у вікно 900 px
- Check «Hosts-файл — виключити зі сканування» падав під StrictMode, доки пункт не застосовано
- Check «Password History» падав, якщо в експорті secedit кілька збігів

## [3.4.1] - 2026-10-26

### Fixed
- GUI приховував збої: обробники кнопок (GetNewClosure) не бачили `ErrorActionPreference=Stop` —
  нефатальні помилки логувались як «Apply OK»
- `Write-AppLog` приймає конвеєр — `... | Out-String | Write-AppLog` змушував PowerShell чекати
  введення в консолі (GUI «зависав» на пунктах моніторингу, напр. Event ID 4703)
- SYN Flood: Check чекав `SynAttackProtect=2`, Apply пише 1; HPING3 переписував на 2
- RTP/RTSP/Remote Assistance: порти масивом (рядок з комою був невалідним); Remote Assistance — блок за `msra.exe`
- Delivery Optimization: лише політика `DODownloadMode=0`, без вимкнення DoSvc
- Defender Advanced: явна помилка, якщо `DisableRestorePoint` задано політикою; `defender.txt` 1 → 0
- `Get-WmiObject` → `Get-CimInstance` (немає в PowerShell 7)

## [3.4.0] - 2026-10-26

### Fixed
- **VBS, HVCI, Credential Guard, LSA PPL, RDP, Windows Update знову застосовуються**: `security.txt` і
  `update.txt` повернуто до стану перед 56d666a (2026-03-17), де політики пишуться в `SOFTWARE\Policies\…`.
  Перенесення в `SOFTWARE\Microsoft\…` робило 245 значень no-op (ці шляхи не читає жоден ADMX), а крок 1
  видаляв справжні політики, зокрема виставлені іншими файлами (GameDVR, WMDRM, IE Feeds, DMA).
  56d666a нових налаштувань не додавав — лише переносив. Firewall лишився на `FirewallPolicy` (коректно).
  Ціна: ці пункти в Налаштуваннях Windows позначені «керується організацією»
- **Revert**: у `revert/{audit,bitlocker,network,office,privacy}.txt` бракувало 124 DELETE — дописано
- Звірка з Baseline 25H2 після змін: 84 збігаються (було 56), 8 відрізняються

### Changed — GptTmpl.inf за Baseline (з дельтою для машин без домену)
- `SeDenyNetworkLogonRight`: `Everyone, Guests, Console Logon` → **Guests** (Baseline для non-domain-joined
  очищає це право; Everyone блокував будь-який мережевий вхід)
- `ForceKeyProtection=2` прибрано; `security.txt` робить DELETE (раніше flip-flop LGPO DELETE ↔ secedit)
- `MaximumPasswordAge` 42 → **-1** (без примусової зміни пароля)

### GUI
- `Risky = $true` у 7 пунктах (FIPS, Constrained Language Mode, SMBv2 off, біометрія off, Whitelist
  Outbound, зміна часового поясу, статичний ARP) — «Застосувати все» їх пропускає й показує список
- `ExclusiveGroup` (рівні UAC) — «Застосувати все» бере лише останній пункт (Administrator Protection);
  раніше застосовувались усі три поспіль

### Tests
- `tests/ApplyAll.Tests.ps1` — відбір пунктів для «Застосувати все»
- `Policies.Format.Tests.ps1`: revert покриває кожне значення; заборона шляхів
  `SOFTWARE\Microsoft\Windows\{DeviceGuard,WindowsUpdate,System}`; нові перевірки GptTmpl.inf
- Локально (Pester 6.2): 79/79 статичних тестів пройшли

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
  (System Access — через `secedit /export`); exit 1 за наявності FAIL. Останній запис виграє
  в межах усіх файлів у порядку Apply, а значення з `GptTmpl.inf` — після них (як при застосуванні);
  REG_BINARY від secedit звіряється як число
- **DMA (Baseline)**: `security.txt` видаляв `Kernel DMA Protection\DeviceEnumerationPolicy`, який
  ставить `defender.txt`, — DELETE прибрано
- `defender.txt`: `MicrosoftEdge\PhishingFilter\EnabledV9` 0 → 1 (суперечило `office.txt`)
- Revert і Restore явно скидають `TypeOfAdminApprovalMode`/`ConsentPromptBehaviorEnhancedAdmin` —
  `defltbase.inf` їх не містить, і Administrator protection лишався б увімкненим
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

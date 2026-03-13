# Changelog

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

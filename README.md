# Windows 11 Hardening Suite

> Комплексний інструмент для захисту Windows 11 з GUI-інтерфейсом

**Джерела:**
[PrivacyHarden_v5](standalone/) |
[dev-sec/windows-baseline](https://github.com/dev-sec) |
[troennes/private-secure-windows](https://github.com/troennes/private-secure-windows) |
[SaneRelapse/PSHardening](https://github.com/SaneRelapse/PSHardening)

## Запуск

```powershell
# GUI-режим (рекомендовано)
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Run-Hardening.ps1
```

Вимоги: PowerShell 5.1+, права адміністратора, Windows 11 (build 22000+).

## Структура проєкту

```
win11-hardening/
├── Run-Hardening.ps1           # Єдина точка входу
│
├── core/                       # Ядро фреймворку
│   ├── helpers.ps1             # Реєстр, сервіси, логування, бекап, відкат
│   ├── settings.data.ps1       # Агрегатор модулів налаштувань
│   ├── ui.ps1                  # WinForms UI (dark theme, 900x760)
│   └── actions.ps1             # Bulk operations, event wiring
│
├── settings/                   # Модулі налаштувань (11 файлів)
│   ├── security.ps1            # UAC, паролі, LAPS, SEHOP, біометрія
│   ├── network.ps1             # NTLM, SMB, WinRM, TCP/IP, NetBIOS
│   ├── firewall.ps1            # Брандмауер, порти, Pivot, TOR
│   ├── privacy.ps1             # Телеметрія, OneDrive, Xbox, Edge
│   ├── defender.ps1            # Windows Defender, ASR, SmartScreen
│   ├── services.ps1            # Відключення зайвих служб
│   ├── audit.ps1               # auditpol, Event Log, CIS/STIG
│   ├── monitoring.ps1          # PowerShell logging, Token Impersonation
│   ├── policy.ps1              # CIS/ACSC Group Policy
│   ├── wsl-sudo.ps1            # WSL, Sudo (Win 11 24H2+)
│   └── doh.ps1                 # DNS-over-HTTPS, Edge DoH, ARP захист
│
├── standalone/                 # Автономні скрипти
├── tools/                      # Утиліти
│   └── LGPO.exe                # Microsoft Group Policy CLI tool
│
├── gpo/                        # GPO конфігурації
│   └── ExploitProtection.xml
├── registry/                   # Registry файли
│   └── Hardening.reg
│
├── LICENSE
└── CHANGELOG.md
```

## Модулі налаштувань

| Файл | Зміст |
|------|-------|
| `security.ps1` | UAC, паролі, облікові записи, LAPS, SEHOP, FIPS, secedit |
| `network.ps1` | NTLM, SMB, WinRM, TCP/IP стек, NetBIOS, протоколи |
| `firewall.ps1` | Брандмауер, блокування портів, Pivot detection, TOR, Pineapple |
| `privacy.ps1` | Телеметрія, активність, дозволи, OneDrive, Xbox, Edge |
| `defender.ps1` | Windows Defender, ASR rules, SmartScreen, DMA, sandbox |
| `services.ps1` | Відключення зайвих служб, журнали, бекап |
| `audit.ps1` | auditpol, Event Log, CIS/STIG контролі |
| `monitoring.ps1` | PowerShell logging, Token Impersonation, Defender audit, USB |
| `policy.ps1` | MSS Legacy, принтери, RPC, Group Policy |
| `wsl-sudo.ps1` | WSL hardening, Sudo (Win 11 24H2+) |
| `doh.ps1` | DNS-over-HTTPS, Edge DoH GPO, ARP Spoofing Mitigation |

## Архітектура

Кожен модуль у `settings/` повертає масив `[PSCustomObject]` з полями:

- **Group** — назва групи для відображення в UI
- **Name** — назва параметра
- **Desc** — опис
- **Apply** — scriptblock для застосування
- **Revert** — scriptblock для відкату до стандарту Windows
- **Check** — scriptblock для перевірки поточного стану

## Хелпери (core/helpers.ps1)

| Функція | Призначення |
|---------|------------|
| `Set-Reg` / `Get-Reg` / `Remove-RegValue` | Робота з реєстром |
| `Set-ServiceDisabled` / `Set-ServiceManual` | Керування сервісами |
| `Disable-Task` / `Enable-Task` | Scheduled tasks |
| `Write-AppLog` / `Write-AppError` | Логування |
| `Set-FirewallRule` | Створення правил брандмауера |
| `Backup-RegistryKey` | Бекап гілки реєстру перед змінами |
| `Invoke-WithRollback` | Застосування з автоматичним відкатом |
| `Test-AdminRequired` | Перевірка прав адміністратора |

## HTML-звіт

Кнопка **"HTML Звіт"** у GUI генерує повний HTML-звіт зі статусом кожного налаштування:
- Зелений / червоний статус для кожного Check-блоку
- Coverage bar з відсотком застосованих налаштувань
- Інформація про host, build, дату

Звіти зберігаються у `%ProgramData%\win11-hardening\hardening-report-*.html`.

## Тестування

```powershell
# Встановити Pester (якщо ще не встановлено)
Install-Module Pester -Force -Scope CurrentUser -MinimumVersion 5.0

# Запустити тести
Invoke-Pester ./tests/Settings.Check.Tests.ps1 -Output Detailed
```

Тести перевіряють: завантаження модулів, обов'язкові поля, виконання Check-блоків, унікальність Name.

## CI/CD

GitHub Actions автоматично запускає PSScriptAnalyzer та Pester при кожному push `.ps1` файлів.

## Логування

Всі операції логуються у `%ProgramData%\HardeningGUI\hardeninggui.log`.
Бекапи реєстру зберігаються у `%ProgramData%\win11-hardening\backup\`.

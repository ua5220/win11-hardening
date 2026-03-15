# win11-hardening — GPO Edition 3.0

Ця директорія містить **GPO Edition 3.0** — версію захисту Windows 11, що застосовує виключно параметри **Administrative Templates** та реєстрові GPO-налаштування через офіційний інструмент Microsoft **LGPO.exe**.

## Що це?

GPO Edition — це standalone-еквівалент групових політик Active Directory для машин **без домену**. Всі налаштування застосовуються через `LGPO.exe /t`, що є тим самим механізмом, який використовують **Microsoft Security Baselines** та **CIS Benchmarks**.

## Покриття

| Файл | Розділ | Кількість параметрів |
|------|--------|---------------------|
| `defender.txt` | Defender + ASR (16 правил) + CFA + SmartScreen + Recall + DMA + ELAM | ~70 |
| `firewall.txt` | Firewall: Domain / Private / Public профілі + logging | ~30 |
| `security.txt` | UAC + LSA + LSASS PPL + VBS + HVCI + Credential Guard + RDP + RPC + Biometrics | ~50 |
| `privacy.txt` | Telemetry + Copilot + OneDrive + Cortana + Search + SettingSync + Ads + DRM | ~65 |
| `network.txt` | SMB + LLMNR + mDNS + WPAD + LLTD + WCN + NTLM + MSS Legacy + Edge DoH | ~35 |
| `audit.txt` | PowerShell Logging + Process CmdLine + Event Log sizes + Transcription | ~15 |
| `bitlocker.txt` | AES-256 XTS + TPM+PIN + Recovery + DMA lock + Removable drives | ~30 |
| `update.txt` | Windows Update + Autoplay/AutoRun + GP Processing + Power/Sleep + WSL + Sudo | ~25 |
| `office.txt` | Office Macros + IE/ActiveX + Printer RPC/IPPS/TLS hardening | ~25 |

**Загалом: ~345 GPO-параметрів** по всіх розділах.

## Структура

```
v3-gpo/
├── README.md                  ← цей файл
├── Apply-GPO.ps1              ← головний скрипт (Apply / Revert / Check)
├── LGPO.exe                   ← Microsoft LGPO tool
├── policies/
│   ├── defender.txt           ← Microsoft Defender + ASR + CFA + SmartScreen
│   ├── firewall.txt           ← Windows Defender Firewall
│   ├── security.txt           ← UAC, LSA, VBS, Credential Guard, RDP, RPC
│   ├── privacy.txt            ← Telemetry, Copilot, OneDrive, Cortana, Search
│   ├── network.txt            ← SMB, LLMNR, WPAD, NTLM, MSS Legacy, Edge DoH
│   ├── audit.txt              ← PowerShell Logging, Audit Process Creation
│   ├── bitlocker.txt          ← BitLocker Drive Encryption
│   ├── update.txt             ← Windows Update, Autoplay, GP Processing
│   ├── office.txt             ← Office Macros, IE/ActiveX, Printers
│   └── revert/
│       └── *.txt              ← DELETE-файли для відкочення кожного розділу
└── tools/
    └── Get-LGPO.ps1           ← авто-завантаження LGPO з Microsoft
```

## Вимоги

- Windows 11 (standalone, без домену)
- PowerShell 5.1+ (запуск від Адміністратора)
- `LGPO.exe` в папці `v3-gpo/` (вже присутній або завантажити через `tools\Get-LGPO.ps1`)

## Використання

```powershell
# Застосувати всі GPO-політики
.\Apply-GPO.ps1 -Action Apply

# Перевірити поточний стан (80+ перевірок)
.\Apply-GPO.ps1 -Action Check

# Скасувати (відкотити до стандартних значень)
.\Apply-GPO.ps1 -Action Revert
```

## Формат LGPO .txt

Кожен запис у `.txt`-файлах дотримується офіційного формату `LGPO.exe /t`:

```
Computer                           ; рівень (Computer = HKLM)
\SOFTWARE\Policies\Microsoft\...   ; шлях реєстру без HKLM
ParameterName                      ; ім'я значення
DWORD:1                            ; тип і значення (або DELETE для revert)
```

## Джерела

- [Microsoft Security Baselines](https://www.microsoft.com/en-us/download/details.aspx?id=55319)
- [CIS Benchmark for Windows 11](https://www.cisecurity.org/benchmark/microsoft_windows_desktop)
- [LGPO.exe documentation](https://techcommunity.microsoft.com/t5/microsoft-security-baselines/lgpo-exe-local-group-policy-object-utility-v1-0/ba-p/701045)
- [ACSC Essential Eight](https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/essential-eight)
- [win11-hardening v2 scripts](https://github.com/ua5220/win11-hardening)

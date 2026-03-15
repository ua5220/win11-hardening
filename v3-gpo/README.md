# win11-hardening — GPO Edition 3.0

Ця директорія містить **GPO Edition 3.0** — версію захисту Windows 11, що застосовує виключно параметри **Administrative Templates** через офіційний інструмент Microsoft **LGPO.exe**.

## Структура

```
v3-gpo/
├── README.md              ← цей файл
├── Apply-GPO.ps1          ← головний скрипт (Apply / Revert / Check)
├── LGPO.exe               ← Microsoft LGPO tool (завантажено вручну)
├── policies/
│   ├── defender.txt       ← Microsoft Defender + ASR + CFA
│   ├── firewall.txt       ← Windows Defender Firewall
│   ├── security.txt       ← UAC, LSA, Credential Guard, LSASS
│   ├── privacy.txt        ← Telemetry, Data Collection
│   ├── network.txt        ← SMB, LLMNR, WPAD, DNS
│   ├── audit.txt          ← Audit Process Creation
│   └── bitlocker.txt      ← BitLocker Drive Encryption
```

## Вимоги

- Windows 11 (standalone, без домену)
- PowerShell 5.1+ (запуск від Адміністратора)
- `LGPO.exe` в папці `v3-gpo/` (вже присутній)

## Використання

```powershell
# Застосувати всі GPO-політики
.\Apply-GPO.ps1 -Action Apply

# Перевірити поточний стан
.\Apply-GPO.ps1 -Action Check

# Скасувати (відкотити до стандартних значень)
.\Apply-GPO.ps1 -Action Revert
```

## Джерела

- [Microsoft Security Baselines](https://www.microsoft.com/en-us/download/details.aspx?id=55319)
- [CIS Benchmark for Windows 11](https://www.cisecurity.org/benchmark/microsoft_windows_desktop)
- [LGPO.exe documentation](https://techcommunity.microsoft.com/t5/microsoft-security-baselines/lgpo-exe-local-group-policy-object-utility-v1-0/ba-p/701045)

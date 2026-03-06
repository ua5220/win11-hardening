# ASD Windows 11 Hardening Toolkit

Автоматизований набір інструментів для захисту робочих станцій Windows 11
на основі публікації **Australian Signals Directorate (ASD/ACSC)**
"Hardening Microsoft Windows 11 workstations" (January 2026).

## Структура проекту

```
win11-hardening/
├── Deploy-Hardening.ps1          # Головний скрипт розгортання
├── Audit-Compliance.ps1          # Аудит відповідності (без змін)
├── README.md                     # Цей файл
├── registry/
│   └── Hardening.reg             # Реєстровий файл (прямий імпорт)
└── scripts/
    ├── HardeningHelpers.psm1     # Допоміжний модуль
    │
    │   === ВИСОКИЙ ПРІОРИТЕТ ===
    ├── 01-CredentialProtection.ps1    # Захист облікових даних, Credential Guard
    ├── 02-ASRRules.ps1                # 16 правил Attack Surface Reduction
    ├── 03-ExploitProtection.ps1       # DEP, SEHOP, CFG, ASLR
    ├── 04-ControlledFolderAccess.ps1  # Захист від ransomware
    ├── 05-CredentialEntry.ps1         # Secure Desktop, UAC login
    ├── 06-ElevatingPrivileges.ps1     # Налаштування UAC
    ├── 07-ELAM.ps1                    # Early Launch Antimalware
    ├── 08-LocalAdmin.ps1              # LAPS, локальні адміністратори
    ├── 09-MFA.ps1                     # Windows Hello for Business
    ├── 10-OSPatching.ps1              # Windows Update конфігурація
    │
    │   === СЕРЕДНІЙ ПРІОРИТЕТ ===
    ├── 20-AccountLockout.ps1          # Політика блокування облікових записів
    ├── 21-AnonymousConnections.ps1    # Анонімні з'єднання
    ├── 22-Antivirus.ps1               # Microsoft Defender Antivirus
    ├── 23-AttachmentManager.ps1       # Менеджер вкладень
    ├── 24-AuditPolicy.ps1             # Політика аудиту (20+ категорій)
    ├── 25-AutoplayAutorun.ps1         # Autoplay/AutoRun
    ├── 26-NetworkSecurity.ps1         # SMB, Auth, DMA, Bridging, MSS, RPC
    ├── 27-DriveEncryption.ps1         # BitLocker конфігурація
    ├── 28-EndpointDeviceControl.ps1   # USB/Removable storage
    ├── 29-RemoteServices.ps1          # RDP, Remote Assistance, WinRM
    ├── 30-PowerManagement.ps1         # Sleep/Hibernate вимкнення
    ├── 31-PowerShell.ps1              # PowerShell hardening + logging
    ├── 32-SecurityPolicies.ps1        # DNS, WLAN, crypto, паролі, OS func
    ├── 33-SessionLocking.ps1          # Блокування сесії (15 хв)
    ├── 34-MiscMedium.ps1              # CMD, regedit, Safe Mode, SmartScreen
    │
    │   === НИЗЬКИЙ ПРІОРИТЕТ ===
    └── 40-LowPriority.ps1            # Розширення файлів, Store, RSOP
```

## Вимоги

- Windows 11 Enterprise або Education (версія 25H2+)
- PowerShell 5.1 або новіше
- Запуск від імені адміністратора
- Рекомендовано: доменне середовище з Active Directory

## Використання

### 1. Аудит (без змін)
```powershell
# Перевірити поточний стан відповідності
.\Audit-Compliance.ps1

# Або через головний скрипт
.\Deploy-Hardening.ps1 -AuditOnly
```

### 2. Повне розгортання
```powershell
# Застосувати ВСІ рівні пріоритету
.\Deploy-Hardening.ps1 -Priority All

# Тільки високий пріоритет
.\Deploy-Hardening.ps1 -Priority High

# Тільки середній пріоритет
.\Deploy-Hardening.ps1 -Priority Medium
```

### 3. Імпорт реєстру (альтернативний метод)
```cmd
reg import registry\Hardening.reg
```

## Покриття рекомендацій ASD

| Категорія | Кількість налаштувань | Скрипт |
|-----------|----------------------|--------|
| Attack Surface Reduction | 16 правил | 02-ASRRules.ps1 |
| Credential Guard/VBS | 7 параметрів | 01-CredentialProtection.ps1 |
| UAC | 7 параметрів | 06-ElevatingPrivileges.ps1 |
| BitLocker | 25+ параметрів | 27-DriveEncryption.ps1 |
| Antivirus (Defender) | 20+ параметрів | 22-Antivirus.ps1 |
| Audit Policy | 20+ категорій | 24-AuditPolicy.ps1 |
| Network Security | 25+ параметрів | 26-NetworkSecurity.ps1 |
| Remote Services | 20+ параметрів | 29-RemoteServices.ps1 |
| Інші | 50+ параметрів | Решта скриптів |

**Загалом: ~250+ індивідуальних налаштувань безпеки**

## Важливі зауваження

1. **ТЕСТУВАННЯ**: Завжди тестуйте в непродуктивному середовищі перед розгортанням
2. **БЕКАП**: Створіть точку відновлення системи перед застосуванням
3. **GPO**: Для доменного середовища рекомендується використовувати Group Policy
4. **ПЕРЕЗАВАНТАЖЕННЯ**: Після застосування потрібне перезавантаження
5. **LAPS**: Потребує окремого налаштування інфраструктури AD
6. **BitLocker**: Потребує TPM та попереднього планування відновлення ключів
7. **MS Security Guide**: Деякі GPO (SEHOP, SMBv1, UAC network) потребують
   завантаження Microsoft Security Compliance Toolkit

## Ліцензія

Базовий документ ASD: © Commonwealth of Australia 2025, CC BY 4.0
Скрипти: вільне використання

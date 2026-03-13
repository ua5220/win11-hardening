<#
.SYNOPSIS
    WSL, Sudo та ARP Spoofing Mitigation — hardening-модуль
.NOTES
    Частина Get-HardeningSettings — підвантажується через settings.data.ps1
    Джерела: SaneRelapse/PSHardening, PrivacyHarden_v5
    Покриття: WSL, Sudo (Win 11 24H2+), ARP захист
#>

@(

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 1: WSL HARDENING ──────────────────────────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "WSL / Sudo"
    Name  = "WSL Hardening — вимкнення Windows Subsystem for Linux"
    Desc  = @"
Вимикає Windows Subsystem for Linux (WSL) та Virtual Machine Platform:
  - Disable-WindowsOptionalFeature Microsoft-Windows-Subsystem-Linux
  - Disable-WindowsOptionalFeature VirtualMachinePlatform
  - GPO: AllowDevelopmentWithoutDevLicense=0 (HKLM Policies)
  - Блокування wsl.exe через брандмауер (Outbound)
WSL є вектором обходу захисту Windows: eBPF, bypass AV/EDR через Linux-бінари,
доступ до файлової системи Windows з-під Linux без аудиту Windows.
УВАГА: потребує перезавантаження для повного вимкнення.
"@
    Apply = {
        # GPO вимкнення WSL
        $wslPolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsSubsystemForLinux"
        Set-Reg $wslPolicy "AllowDevelopmentWithoutDevLicense" 0

        # Вимкнення через реєстр (AppModel)
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" "AllowDevelopmentWithoutDevLicense" 0
        Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" "AllowAllTrustedApps" 0

        # Вимкнення Windows Features (потребує перезавантаження)
        $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -ErrorAction SilentlyContinue
        if ($wslFeature -and $wslFeature.State -eq 'Enabled') {
            Disable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -ErrorAction SilentlyContinue
            Write-AppLog -Level 'INFO' -Message "WSL feature вимкнено (потрібне перезавантаження)."
        }

        $vmpFeature = Get-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -ErrorAction SilentlyContinue
        if ($vmpFeature -and $vmpFeature.State -eq 'Enabled') {
            Disable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -NoRestart -ErrorAction SilentlyContinue
            Write-AppLog -Level 'INFO' -Message "VirtualMachinePlatform feature вимкнено."
        }

        # Зупинити LxssManager (WSL service)
        Set-ServiceDisabled "LxssManager"

        # Заблокувати wsl.exe через брандмауер
        Set-FirewallRule -Name "Block WSL Outbound" -Direction Outbound -Protocol TCP -Action Block

        Write-AppLog -Level 'INFO' -Message "WSL Hardening застосовано. Перезавантажте для повного ефекту."
    }
    Revert = {
        $wslPolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsSubsystemForLinux"
        Remove-RegValue $wslPolicy "AllowDevelopmentWithoutDevLicense"

        Remove-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" "AllowDevelopmentWithoutDevLicense"
        Remove-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" "AllowAllTrustedApps"

        Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -ErrorAction SilentlyContinue
        Set-ServiceManual "LxssManager"

        Remove-NetFirewallRule -DisplayName "Block WSL Outbound" -ErrorAction SilentlyContinue

        Write-AppLog -Level 'INFO' -Message "WSL відновлено (потрібне перезавантаження)."
    }
    Check = {
        $feat = Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -ErrorAction SilentlyContinue
        $feat -and $feat.State -eq 'Disabled'
    }
},

# ════════════════════════════════════════════════════════════════════════
# ── РОЗДІЛ 2: SUDO HARDENING (Windows 11 24H2+) ─────────────────────────
# ════════════════════════════════════════════════════════════════════════

[PSCustomObject]@{
    Group = "WSL / Sudo"
    Name  = "Sudo Hardening — вимкнення Windows 11 Sudo (24H2+)"
    Desc  = @"
Вимикає функцію Sudo, введену у Windows 11 24H2 (build 26045+):
  HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Sudo Enabled=0
Windows Sudo дозволяє запускати команди з підвищеними правами без UAC-
підтвердження в тому ж вікні терміналу. Це знижує захист UAC та може
використовуватися зловмисним ПЗ для приховано привілейованого виконання.
Також вимикає режим 'inline' (найнебезпечніший) через SudoMode=1 (ForceNewWindow).
Режими: 0=вимкнено, 1=нове вікно (безпечніший), 2=введення в новому вікні, 3=inline.
"@
    Apply = {
        $sudoKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Sudo"

        # Повне вимкнення Sudo
        Set-Reg $sudoKey "Enabled" 0

        Write-AppLog -Level 'INFO' -Message "Windows Sudo вимкнено (Enabled=0)."

        # Перевірити чи Sudo взагалі доступний на цій версії
        $sudoExe = "$env:WINDIR\System32\sudo.exe"
        if (Test-Path $sudoExe) {
            Write-AppLog -Level 'INFO' -Message "sudo.exe знайдено: $sudoExe"
        } else {
            Write-AppLog -Level 'INFO' -Message "sudo.exe не знайдено — Windows версія не підтримує Sudo (до 24H2)."
        }
    }
    Revert = {
        $sudoKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Sudo"
        Remove-RegValue $sudoKey "Enabled"
        Write-AppLog -Level 'INFO' -Message "Windows Sudo відновлено до стандартного стану."
    }
    Check = {
        $sudoKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Sudo"
        (Get-Reg $sudoKey "Enabled" -1) -eq 0
    }
}

)

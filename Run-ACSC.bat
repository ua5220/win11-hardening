@echo off
:: ACSC Windows 11 Hardening — Launcher
:: Australian Cyber Security Centre recommendations

:: ── Request Administrator privileges ────────────────────────────────────────
net session >nul 2>&1
if %errorLevel% == 0 goto :run

echo Requesting Administrator privileges...
powershell.exe -NoProfile -Command ^
    "Start-Process -FilePath '%~f0' -Verb RunAs"
exit /b

:run
:: ── Run hardening script ─────────────────────────────────────────────────────
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ACSC-Win11-Hardening.ps1"
pause

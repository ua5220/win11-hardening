@echo off
:: Windows 11 Hardening GUI Launcher
:: Запускати від імені Адміністратора (або скрипт сам підвищить права)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0HardeningGUI.ps1"

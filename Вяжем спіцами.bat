# Перевірка прав адміністратора
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Host "[i] Запускаю з підвищеними правами..."
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Функція очищення тимчасових файлів
function Clear-TempFiles {
    Write-Host "[i] Очищення системних кешів..."
    $targets = @(
        $env:TEMP,
        (Join-Path $env:WINDIR "Temp")
    )
    foreach ($t in $targets) {
        if (Test-Path $t) {
            Get-ChildItem -LiteralPath $t -Force -Recurse -ErrorAction SilentlyContinue |
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
    Write-Host "[✓] Тимчасові файли очищено."
}

# Очищення історії PowerShell
function Clear-PSHistory {
    Write-Host "[i] Очищення історії PowerShell..."
    $hist = Join-Path $env:APPDATA "Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    if (Test-Path $hist) { Remove-Item $hist -Force -ErrorAction SilentlyContinue }
    Write-Host "[✓] Історія PowerShell очищена."
}

# Скидання DNS кешу
function Flush-DNSCache {
    Write-Host "[i] Скидання DNS-кешу..."
    Clear-DnsClientCache
    Write-Host "[✓] DNS кеш очищено."
}

# Видалення тіньових копій
function Delete-ShadowCopies {
    Write-Host "[i] Видалення тіньових копій..."
    vssadmin delete shadows /all /quiet >nul 2>&1
    Write-Host "[✓] Тіньові копії видалено."
}

# Очищення журналів подій
function Clear-EventLogs {
    Write-Host "[i] Очищення журналів подій..."
    wevtutil el | ForEach-Object { wevtutil cl $_ }
    Write-Host "[✓] Журнали подій очищено."
}

# Основна частина скрипту
Write-Host "[i] Початок очищення системи..."

Clear-TempFiles
Clear-PSHistory
Flush-DNSCache
Delete-ShadowCopies
Clear-EventLogs

Write-Host "[✓] Очищення системи завершено."
Read-Host "Натисніть Enter для виходу"
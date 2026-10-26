<#
.SYNOPSIS
    Запуск GUI без консолі (ціль ярлика, створеного tools\New-HardeningShortcut.ps1)
.NOTES
    Ярлик запускає цей файл через `conhost.exe --headless`, тож консолі не видно.
    Помилку старту, яку інакше ніхто б не побачив, показуємо у вікні повідомлення.
#>

$ErrorActionPreference = 'Stop'
try {
    & (Join-Path (Split-Path $PSScriptRoot -Parent) 'Run-Hardening.ps1')
} catch {
    Add-Type -AssemblyName System.Windows.Forms
    $log = Join-Path $env:ProgramData 'HardeningGUI\hardeninggui.log'
    [void][System.Windows.Forms.MessageBox]::Show(
        "Не вдалося запустити Windows 11 Hardening:`r`n`r`n$($_.Exception.Message)`r`n`r`n$($_.InvocationInfo.PositionMessage)`r`n`r`nЛог: $log",
        'win11-hardening',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
}

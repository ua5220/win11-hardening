<#
.SYNOPSIS
    Pester-тести «Звіту помилок» (Export-ErrorReport)
.NOTES
    Запуск:   Invoke-Pester ./tests/ErrorReport.Tests.ps1
    Вимоги:   Pester 5+, PowerShell 5.1+. Права адміністратора НЕ потрібні.

    Тести НЕ змінюють систему: виконують лише Check-блоки (читання), лог і звіт пишуться
    в TestDrive, буфер обміну підмінено.
#>

BeforeAll {
    $rootDir = Split-Path $PSScriptRoot -Parent
    . (Join-Path $rootDir 'core\helpers.ps1')
    $script:_logPath = Join-Path $TestDrive 'hardeninggui.log'
    function Set-Clipboard { param($Value) $script:Clipboard = $Value }
    . (Join-Path $rootDir 'core\settings.data.ps1')
    . (Join-Path $rootDir 'core\actions.ps1')
    $Global:Win11Track = '25H2'

    $script:Settings = @(Get-HardeningSettings)
    try { throw "Тестова помилка для $env:USERNAME" } catch {
        Write-AppError -Context "Apply FAILED :: $($script:Settings[0].Name)" -ErrorRecord $_
    }
    $script:Result = Export-ErrorReport -Settings $script:Settings
    $script:Text   = Get-Content $script:Result.Path -Raw -Encoding UTF8
}

Describe 'Export-ErrorReport' {
    It 'створює файл звіту' {
        $script:Result.Path | Should -Exist
    }

    It 'містить усі розділи' {
        foreach ($h in '## Середовище', '## 1. Помилки Apply / Revert', '## 2. Застосовано без помилки', '## 3. Check падає', '## 4. Лог сесії') {
            $script:Text | Should -Match ([regex]::Escape($h))
        }
    }

    It 'включає помилку сесії з кодом пункту' {
        $script:Result.Errors | Should -BeGreaterOrEqual 1
        $script:Text | Should -Match ([regex]::Escape("Apply FAILED :: $($script:Settings[0].Name)"))
        $script:Text | Should -Match '\*\*Apply\*\*'
    }

    It 'маскує ім''я користувача й комп''ютера' {
        $script:Text | Should -Not -Match ([regex]::Escape($env:USERNAME))
        $script:Text | Should -Not -Match ([regex]::Escape($env:COMPUTERNAME))
        $script:Text | Should -Match '<user>'
    }

    It 'копіює той самий текст у буфер обміну' {
        $script:Clipboard | Should -Be $script:Text
    }

    It 'кожен пункт має Module' {
        @($script:Settings | Where-Object { -not $_.PSObject.Properties['Module'] }) | Should -BeNullOrEmpty
    }
}

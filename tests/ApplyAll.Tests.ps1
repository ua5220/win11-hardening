<#
.SYNOPSIS
    Pester-тести відбору пунктів для «Застосувати все» (Get-ApplyAllItems)
.NOTES
    Запуск:   Invoke-Pester ./tests/ApplyAll.Tests.ps1
    Вимоги:   Pester 5+, PowerShell 5.1+. Права адміністратора НЕ потрібні.

    Тести НЕ змінюють систему — вони лише завантажують модулі settings/ і перевіряють, що:
      1) Пункти з Risky = $true не потрапляють у «Застосувати все»
      2) З кожної ExclusiveGroup застосовується рівно один (останній) пункт
#>

BeforeAll {
    $rootDir = Split-Path $PSScriptRoot -Parent
    . (Join-Path $rootDir 'core\helpers.ps1')
    . (Join-Path $rootDir 'core\actions.ps1')

    $script:All = @()
    foreach ($file in Get-ChildItem (Join-Path $rootDir 'settings') -Filter *.ps1) {
        $script:All += @(. $file.FullName)
    }
    $script:Plan = Get-ApplyAllItems -Settings $script:All
}

Describe 'Get-ApplyAllItems' {
    It 'кожен пункт або застосовується, або пропускається' {
        ($script:Plan.Apply.Count + $script:Plan.Skipped.Count) | Should -Be $script:All.Count
    }

    It 'ризикові пункти пропускаються' {
        $risky = @($script:All | Where-Object { $_.PSObject.Properties['Risky'] -and $_.Risky })
        $risky.Count | Should -BeGreaterThan 0
        foreach ($r in $risky) { $script:Plan.Apply | Should -Not -Contain $r }
    }

    It 'FIPS і Constrained Language Mode не застосовуються' {
        @($script:Plan.Apply | Where-Object { $_.Name -match 'FIPS|Constrained Language' }) | Should -BeNullOrEmpty
    }

    It 'з групи <_> застосовується рівно один пункт' -ForEach @('UAC-Level') {
        $group = $_
        @($script:Plan.Apply | Where-Object { $_.PSObject.Properties['ExclusiveGroup'] -and $_.ExclusiveGroup -eq $group }).Count | Should -Be 1
    }

    It 'для UAC обрано Administrator Protection (Baseline 25H2)' {
        $uac = $script:Plan.Apply | Where-Object { $_.PSObject.Properties['ExclusiveGroup'] -and $_.ExclusiveGroup -eq 'UAC-Level' }
        $uac.Name | Should -Match 'Administrator Protection'
    }
}

<#
.SYNOPSIS
    Pester-тести для Check-блоків усіх settings-модулів
.NOTES
    Запуск:   Invoke-Pester ./tests/Settings.Check.Tests.ps1
    Вимоги:   Pester 5+, PowerShell 5.1+

    Тести НЕ змінюють систему — вони лише перевіряють, що:
      1) Кожен модуль завантажується без помилок
      2) Кожен setting має обов'язкові поля (Group, Name, Desc, Apply, Revert, Check)
      3) Кожен Check scriptblock виконується без виключень (повертає $true або $false)
      4) Немає дублікатів Name серед усіх модулів
#>

BeforeAll {
    $rootDir     = Split-Path $PSScriptRoot -Parent
    $coreDir     = Join-Path $rootDir 'core'
    $settingsDir = Join-Path $rootDir 'settings'

    # Завантажити helpers для Set-Reg, Get-Reg, etc.
    . (Join-Path $coreDir 'helpers.ps1')

    # Зібрати всі settings-файли
    $script:ModuleFiles = @(
        'security.ps1', 'defender.ps1', 'network.ps1', 'firewall.ps1',
        'privacy.ps1',  'services.ps1', 'audit.ps1',   'policy.ps1',
        'monitoring.ps1', 'wsl-sudo.ps1', 'doh.ps1'
    )

    # Завантажити всі settings
    $script:AllSettings = @()
    $script:ModuleSettings = @{}

    foreach ($file in $script:ModuleFiles) {
        $path = Join-Path $settingsDir $file
        if (Test-Path $path) {
            try {
                $items = @(. $path)
                $script:ModuleSettings[$file] = $items
                $script:AllSettings += $items
            } catch {
                $script:ModuleSettings[$file] = @()
            }
        }
    }
}

# ── Тест 1: Кожен модуль завантажується ──────────────────────────────────

Describe 'Settings module loading' {
    foreach ($file in $script:ModuleFiles) {
        It "Module <file> loads without errors" -TestCases @(@{ file = $file }) {
            $path = Join-Path $settingsDir $file
            $path | Should -Exist
            { @(. $path) } | Should -Not -Throw
        }

        It "Module <file> returns at least one setting" -TestCases @(@{ file = $file }) {
            $script:ModuleSettings[$file].Count | Should -BeGreaterThan 0
        }
    }
}

# ── Тест 2: Обов'язкові поля ─────────────────────────────────────────────

Describe 'Settings required properties' {
    $requiredProps = @('Group', 'Name', 'Desc', 'Apply', 'Revert', 'Check')

    foreach ($file in $script:ModuleFiles) {
        Context "Module: $file" {
            $settings = $script:ModuleSettings[$file]
            if (-not $settings) { continue }

            $index = 0
            foreach ($s in $settings) {
                foreach ($prop in $requiredProps) {
                    It "<file>[<index>] '<settingName>' has property '<prop>'" -TestCases @(@{
                        file        = $file
                        index       = $index
                        settingName = ($s.Name -replace '(.{40}).*', '$1...')
                        prop        = $prop
                        setting     = $s
                    }) {
                        $setting.PSObject.Properties[$prop] | Should -Not -BeNullOrEmpty
                    }
                }
                $index++
            }
        }
    }
}

# ── Тест 3: Check-блоки виконуються без виключень ─────────────────────────

Describe 'Settings Check scriptblocks execute without exceptions' {
    foreach ($file in $script:ModuleFiles) {
        Context "Module: $file" {
            $settings = $script:ModuleSettings[$file]
            if (-not $settings) { continue }

            $index = 0
            foreach ($s in $settings) {
                It "<file>[<index>] '<settingName>' Check returns bool" -TestCases @(@{
                    file        = $file
                    index       = $index
                    settingName = ($s.Name -replace '(.{40}).*', '$1...')
                    setting     = $s
                }) {
                    $result = $null
                    { $result = & $setting.Check } | Should -Not -Throw
                    $result | Should -BeOfType [bool]
                }
                $index++
            }
        }
    }
}

# ── Тест 4: Apply та Revert є scriptblock ────────────────────────────────

Describe 'Settings Apply/Revert are scriptblocks' {
    foreach ($file in $script:ModuleFiles) {
        Context "Module: $file" {
            $settings = $script:ModuleSettings[$file]
            if (-not $settings) { continue }

            $index = 0
            foreach ($s in $settings) {
                It "<file>[<index>] '<settingName>' Apply is ScriptBlock" -TestCases @(@{
                    file        = $file
                    index       = $index
                    settingName = ($s.Name -replace '(.{40}).*', '$1...')
                    setting     = $s
                }) {
                    $setting.Apply | Should -BeOfType [scriptblock]
                }

                It "<file>[<index>] '<settingName>' Revert is ScriptBlock" -TestCases @(@{
                    file        = $file
                    index       = $index
                    settingName = ($s.Name -replace '(.{40}).*', '$1...')
                    setting     = $s
                }) {
                    $setting.Revert | Should -BeOfType [scriptblock]
                }
                $index++
            }
        }
    }
}

# ── Тест 5: Унікальність Name ─────────────────────────────────────────────

Describe 'Settings Name uniqueness' {
    It 'All setting Names are unique across modules' {
        $names = $script:AllSettings | Select-Object -ExpandProperty Name
        $duplicates = $names | Group-Object | Where-Object { $_.Count -gt 1 }
        $duplicates | Should -BeNullOrEmpty -Because "Duplicate names found: $($duplicates.Name -join ', ')"
    }
}

# ── Тест 6: Group не порожній ─────────────────────────────────────────────

Describe 'Settings Group values' {
    It 'All settings have non-empty Group' {
        $empty = $script:AllSettings | Where-Object { [string]::IsNullOrWhiteSpace($_.Group) }
        $empty | Should -BeNullOrEmpty
    }

    It 'All settings have non-empty Desc' {
        $empty = $script:AllSettings | Where-Object { [string]::IsNullOrWhiteSpace($_.Desc) }
        $empty | Should -BeNullOrEmpty
    }
}

<#
.SYNOPSIS
    Статичні Pester-тести файлів GPO Edition (policies\*.txt, policies\revert\*.txt, GptTmpl.inf)
.NOTES
    Запуск:   Invoke-Pester ./tests/Policies.Format.Tests.ps1
    Вимоги:   Pester 5+, PowerShell 5.1+. Права адміністратора НЕ потрібні.

    Тести НЕ змінюють систему — вони лише перевіряють, що:
      1) Кожен файл політик складається з цілих 4-рядкових записів LGPO /t
      2) Рівень — Computer або User, значення — DWORD/SZ/DELETE
      3) Для кожного файлу політик є revert-файл
      4) У GptTmpl.inf немає повернення ризикових значень (FIPS, CrashOnAuditFail,
         слабкі паролі, вимкнений Administrator protection)
#>

BeforeDiscovery {
    $policiesDir = Join-Path (Split-Path $PSScriptRoot -Parent) 'policies'
    $script:PolicyFiles = @(Get-ChildItem $policiesDir -Filter *.txt | ForEach-Object { @{ Name = $_.Name; Path = $_.FullName } })
    $script:RevertFiles = @(Get-ChildItem (Join-Path $policiesDir 'revert') -Filter *.txt | ForEach-Object { @{ Name = "revert\$($_.Name)"; Path = $_.FullName } })
}

BeforeAll {
    $script:PoliciesDir = Join-Path (Split-Path $PSScriptRoot -Parent) 'policies'

    function Get-RecordLines {
        param([string]$Path)
        @(Get-Content -LiteralPath $Path -Encoding UTF8 |
            Where-Object { $_.Trim() -ne '' -and $_ -notmatch '^\s*;' })
    }
}

Describe 'Формат LGPO /t: <Name>' -ForEach ($script:PolicyFiles + $script:RevertFiles) {
    BeforeAll {
        $script:Lines = Get-RecordLines -Path $Path
    }

    It 'має цілу кількість 4-рядкових записів' {
        $script:Lines.Count % 4 | Should -Be 0
        $script:Lines.Count | Should -BeGreaterThan 0
    }

    It 'кожен запис має рівень Computer/User і коректне значення' {
        for ($i = 0; $i -lt $script:Lines.Count; $i += 4) {
            $script:Lines[$i].Trim() | Should -BeIn @('Computer', 'User') -Because "рядок запису #$($i / 4)"
            $script:Lines[$i + 1].Trim() | Should -Not -Match '^(HKLM|HKCU|\\)' -Because 'шлях без кореня і без початкового \'
            $script:Lines[$i + 3].Trim() | Should -Match '^(DWORD:\d+|SZ:.*|EXSZ:.*|MULTISZ:.*|DELETE|DELETEALLVALUES|CREATEKEY)$' -Because "значення запису #$($i / 4)"
        }
    }
}

Describe 'Revert-покриття' {
    It 'для <Name> існує revert-файл' -ForEach $script:PolicyFiles {
        Join-Path (Join-Path $script:PoliciesDir 'revert') $Name | Should -Exist
    }

    It 'revert\<Name> видаляє кожне значення з <Name>' -ForEach $script:PolicyFiles {
        $ids = {
            param($lines)
            for ($i = 0; $i -lt $lines.Count; $i += 4) { "$($lines[$i])|$($lines[$i + 1])|$($lines[$i + 2])".Trim().ToLower() }
        }
        $reverted = @{}
        & $ids (Get-RecordLines -Path (Join-Path (Join-Path $script:PoliciesDir 'revert') $Name)) | ForEach-Object { $reverted[$_] = $true }
        $missing = @(& $ids (Get-RecordLines -Path $Path) | Where-Object { -not $reverted.ContainsKey($_) })
        $missing | Should -BeNullOrEmpty
    }
}

Describe 'Шляхи політик читаються Windows' {
    # Перенесення SOFTWARE\Policies\Microsoft\X → SOFTWARE\Microsoft\X робило політики no-op (3.3.0)
    It 'у <Name> немає записів у SOFTWARE\Microsoft\Windows\{DeviceGuard,WindowsUpdate,System}' -ForEach $script:PolicyFiles {
        $lines = Get-RecordLines -Path $Path
        $bad = for ($i = 1; $i -lt $lines.Count; $i += 4) {
            if ($lines[$i].Trim() -match '^SOFTWARE\\Microsoft\\Windows\\(DeviceGuard|WindowsUpdate|System)(\\|$)') { $lines[$i].Trim() }
        }
        @($bad) | Should -BeNullOrEmpty
    }
}

Describe 'Microsoft Store завжди доступний' {
    BeforeAll {
        $script:RootDir = Split-Path $PSScriptRoot -Parent
    }

    It '<Name> не блокує Store (RemoveWindowsStore / DisablePushToInstall лише DELETE)' -ForEach $script:PolicyFiles {
        $lines = Get-RecordLines -Path $Path
        for ($i = 0; $i -lt $lines.Count; $i += 4) {
            if ($lines[$i + 2].Trim() -in 'RemoveWindowsStore', 'DisablePushToInstall') {
                $lines[$i + 3].Trim() | Should -Be 'DELETE' -Because "$($lines[$i + 1].Trim())\$($lines[$i + 2].Trim())"
            }
        }
    }

    It 'GUI-пункти не ставлять RemoveWindowsStore=1 і не вимикають wlidsvc' {
        $files = Get-ChildItem (Join-Path $script:RootDir 'settings') -Filter *.ps1
        foreach ($f in $files) {
            $text = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
            $text | Should -Not -Match '"RemoveWindowsStore"\s+1' -Because $f.Name
            $text | Should -Not -Match '(?m)^\s*"wlidsvc"\s*(#.*)?$' -Because "$($f.Name): wlidsvc у списку на вимкнення"
        }
    }
}

Describe 'Платформа сповіщень завжди доступна' {
    # Вимкнений WpnUserService — WhatsApp та інші застосунки падають на старті з 0x803E0105 (3.5.2)
    It 'GUI-пункти не вимикають WpnUserService' {
        $files = Get-ChildItem (Join-Path (Split-Path $PSScriptRoot -Parent) 'settings') -Filter *.ps1
        foreach ($f in $files) {
            $text = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
            $text | Should -Not -Match '\$svcs\s*=\s*@\([^)]*"WpnUserService"' -Because "$($f.Name): WpnUserService у списку на вимкнення"
            $text | Should -Not -Match '"WpnUserService"[^\r\n]*"Start"\s+4' -Because $f.Name
        }
    }
}

Describe 'Revert не вимикає функції Windows' {
    # «Скасувати все» відкочує всі пункти — відкат «увімкнути/відновити» не має нічого блокувати
    # (2026-10-26: Revert вимкнув автооновлення NoAutoUpdate=1 і Store RemoveWindowsStore=1)
    BeforeAll {
        $script:Blocking = 'NoAutoUpdate|RemoveWindowsStore|DisableSnippingTool|DisableUAT|DisablePushToInstall'
        $script:Reverts = foreach ($f in Get-ChildItem (Join-Path (Split-Path $PSScriptRoot -Parent) 'settings') -Filter *.ps1) {
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($f.FullName, [ref]$null, [ref]$null)
            foreach ($h in $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.HashtableAst] }, $true)) {
                $rev = $h.KeyValuePairs | Where-Object { $_.Item1.Extent.Text -eq 'Revert' } | Select-Object -First 1
                if ($rev) { [pscustomobject]@{ File = $f.Name; Line = $h.Extent.StartLineNumber; Text = $rev.Item2.Extent.Text } }
            }
        }
    }

    It 'жоден Revert не ставить блокуючих значень' {
        $bad = @($script:Reverts | Where-Object { $_.Text -match "Set-Reg\s+\S+\s+`"($script:Blocking)`"\s+1\b" } |
            ForEach-Object { "$($_.File):$($_.Line)" })
        $bad | Should -BeNullOrEmpty
    }

    It 'дозволені програми CFA не блокуються (DisableLocalAdminMerge / HideExclusionsFromLocalAdmins ≠ 1)' {
        $settingsDir = Join-Path (Split-Path $PSScriptRoot -Parent) 'settings'
        foreach ($f in Get-ChildItem $settingsDir -Filter *.ps1) {
            Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8 |
                Should -Not -Match '"(DisableLocalAdminMerge|HideExclusionsFromLocalAdmins)"\s+1\b' -Because $f.Name
        }
        foreach ($p in Get-ChildItem $script:PoliciesDir -Filter *.txt) {
            $lines = Get-RecordLines -Path $p.FullName
            for ($i = 0; $i -lt $lines.Count; $i += 4) {
                if ($lines[$i + 2].Trim() -in 'DisableLocalAdminMerge', 'HideExclusionsFromLocalAdmins') {
                    $lines[$i + 3].Trim() | Should -Be 'DELETE' -Because "$($p.Name): $($lines[$i + 2].Trim())"
                }
            }
        }
    }

    It 'GPO Edition не вимикає автооновлення' {
        $lines = Get-RecordLines -Path (Join-Path $script:PoliciesDir 'update.txt')
        for ($i = 0; $i -lt $lines.Count; $i += 4) {
            if ($lines[$i + 2].Trim() -eq 'NoAutoUpdate') { $lines[$i + 3].Trim() | Should -Not -Be 'DWORD:1' }
        }
    }
}

Describe 'GptTmpl.inf — значення Microsoft Security Baseline' {
    BeforeAll {
        $script:Inf = Get-Content -LiteralPath (Join-Path $script:PoliciesDir 'GptTmpl.inf') -Encoding UTF8
        function Get-InfValue([string]$Name) {
            $line = $script:Inf | Where-Object { $_ -match "^\s*$([regex]::Escape($Name))\s*=" } | Select-Object -First 1
            if ($line) { ($line -split '=', 2)[1].Trim() }
        }
    }

    It 'FIPS не вмикається' {
        $script:Inf | Where-Object { $_ -match 'FIPSAlgorithmPolicy\\Enabled=4,1' } | Should -BeNullOrEmpty
    }

    It 'CrashOnAuditFail не вмикається' {
        $script:Inf | Where-Object { $_ -match 'CrashOnAuditFail=4,[12]' } | Should -BeNullOrEmpty
    }

    It 'мінімальна довжина пароля ≥ 14' {
        [int](Get-InfValue 'MinimumPasswordLength') | Should -BeGreaterOrEqual 14
    }

    It 'складність пароля увімкнена' {
        Get-InfValue 'PasswordComplexity' | Should -Be '1'
    }

    It 'мережевий вхід не заборонено для Everyone/локальних облікових записів (машина без домену)' {
        Get-InfValue 'SeDenyNetworkLogonRight' | Should -Not -Match '\*S-1-1-0|\*S-1-5-113'
    }

    It 'ForceKeyProtection не задається' {
        $script:Inf | Where-Object { $_ -match 'ForceKeyProtection=' } | Should -BeNullOrEmpty
    }

    It 'пароль не має примусового терміну дії (MaximumPasswordAge = -1)' {
        Get-InfValue 'MaximumPasswordAge' | Should -Be '-1'
    }

    It 'Administrator protection (TypeOfAdminApprovalMode=2)' {
        $script:Inf | Where-Object { $_ -match 'TypeOfAdminApprovalMode=4,2' } | Should -Not -BeNullOrEmpty
    }
}

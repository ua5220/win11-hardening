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

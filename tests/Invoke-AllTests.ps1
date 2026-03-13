<#
.SYNOPSIS
    Єдина точка запуску всіх Pester-тестів
.NOTES
    Запуск: .\tests\Invoke-AllTests.ps1
    Вимоги: Pester 5+, PowerShell 5.1+, права адміністратора
    Результати зберігаються у NUnitXml (сумісно з GitHub Actions)
#>

#Requires -RunAsAdministrator
#Requires -Modules Pester

param([string]$OutputPath = "$PSScriptRoot\TestResults.xml")

$config = New-PesterConfiguration
$config.Run.Path             = $PSScriptRoot
$config.Output.Verbosity     = "Detailed"
$config.TestResult.Enabled   = $true
$config.TestResult.OutputPath = $OutputPath
$config.TestResult.OutputFormat = "NUnitXml"

Invoke-Pester -Configuration $config

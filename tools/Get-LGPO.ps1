#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Downloads LGPO.exe from Microsoft Security Compliance Toolkit.
.DESCRIPTION
    Автоматично завантажує Microsoft LGPO.exe з офіційного Security Compliance Toolkit
    та розміщує його в кореневій папці v3-gpo/.
.NOTES
    GPO Edition 3.0 — win11-hardening
#>

[CmdletBinding()]
param(
    [string]$DestinationPath = (Split-Path -Parent $PSScriptRoot)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$lgpoPath = Join-Path $DestinationPath 'LGPO.exe'

if (Test-Path $lgpoPath) {
    Write-Host "[OK] LGPO.exe already exists: $lgpoPath" -ForegroundColor Green
    return
}

# Microsoft Security Compliance Toolkit 1.0 download URL
$downloadUrl = 'https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023BBF5CBD/LGPO.zip'
$tempZip     = Join-Path $env:TEMP 'LGPO_download.zip'
$tempExtract = Join-Path $env:TEMP 'LGPO_extract'

try {
    Write-Host '[1/3] Downloading LGPO.zip from Microsoft...' -ForegroundColor Cyan
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip -UseBasicParsing

    Write-Host '[2/3] Extracting archive...' -ForegroundColor Cyan
    if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
    Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force

    # LGPO.exe is inside a subfolder in the ZIP
    $found = Get-ChildItem -Path $tempExtract -Filter 'LGPO.exe' -Recurse | Select-Object -First 1
    if (-not $found) {
        throw 'LGPO.exe not found inside the downloaded archive.'
    }

    Write-Host '[3/3] Copying LGPO.exe...' -ForegroundColor Cyan
    Copy-Item -Path $found.FullName -Destination $lgpoPath -Force

    Write-Host "[OK] LGPO.exe saved to: $lgpoPath" -ForegroundColor Green
}
catch {
    Write-Error "Failed to download LGPO.exe: $_"
    Write-Host @"

Manual download:
  1. Go to https://www.microsoft.com/en-us/download/details.aspx?id=55319
  2. Download "LGPO.zip" from Security Compliance Toolkit
  3. Extract LGPO.exe and place it in: $DestinationPath
"@ -ForegroundColor Yellow
}
finally {
    if (Test-Path $tempZip)     { Remove-Item $tempZip -Force -ErrorAction SilentlyContinue }
    if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue }
}

<#
.SYNOPSIS
    Common helper functions for ASD Windows 11 Hardening scripts
#>

function Set-RegistryValue {
    [CmdletBinding()]
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = "DWord",
        [switch]$AuditOnly,
        [string]$Description = ""
    )

    $exists = $false
    $current = $null

    try {
        if (Test-Path $Path) {
            $current = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
            if ($null -ne $current) {
                $exists = $true
                $current = $current.$Name
            }
        }
    } catch {}

    if ($AuditOnly) {
        if ($exists -and $current -eq $Value) {
            Write-Host "  [OK] $Description ($Path\$Name = $Value)" -ForegroundColor Green
        } else {
            $msg = if ($exists) { "Current: $current, Expected: $Value" } else { "NOT SET, Expected: $Value" }
            Write-Host "  [FAIL] $Description ($Path\$Name) - $msg" -ForegroundColor Red
        }
        return
    }

    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
        Write-Host "  [SET] $Description = $Value" -ForegroundColor Cyan
    } catch {
        Write-Host "  [ERROR] $Description - $_" -ForegroundColor Red
    }
}

function Set-SecurityPolicy {
    [CmdletBinding()]
    param(
        [string]$Section,
        [string]$Key,
        [string]$Value,
        [switch]$AuditOnly,
        [string]$Description = ""
    )

    if ($AuditOnly) {
        Write-Host "  [AUDIT] Security Policy: $Description ($Section\$Key)" -ForegroundColor Yellow
        return
    }

    $tempFile = [System.IO.Path]::GetTempFileName()
    $tempDb = [System.IO.Path]::GetTempFileName()

    try {
        secedit /export /cfg $tempFile /quiet
        $content = Get-Content $tempFile

        $sectionFound = $false
        $keyFound = $false
        $newContent = @()

        foreach ($line in $content) {
            if ($line -match "^\[$Section\]") {
                $sectionFound = $true
            }
            if ($sectionFound -and $line -match "^$Key\s*=") {
                $newContent += "$Key = $Value"
                $keyFound = $true
                continue
            }
            if ($sectionFound -and -not $keyFound -and $line -match "^\[" -and $line -notmatch "^\[$Section\]") {
                $newContent += "$Key = $Value"
                $keyFound = $true
            }
            $newContent += $line
        }

        $newContent | Set-Content $tempFile
        secedit /configure /db $tempDb /cfg $tempFile /quiet
        Write-Host "  [SET] Security Policy: $Description = $Value" -ForegroundColor Cyan
    } catch {
        Write-Host "  [ERROR] Security Policy: $Description - $_" -ForegroundColor Red
    } finally {
        Remove-Item $tempFile, $tempDb -Force -ErrorAction SilentlyContinue
    }
}

function Set-AuditPolicy {
    [CmdletBinding()]
    param(
        [string]$Subcategory,
        [ValidateSet("Success", "Failure", "Success and Failure", "No Auditing")]
        [string]$AuditFlag,
        [switch]$AuditOnly
    )

    if ($AuditOnly) {
        $current = auditpol /get /subcategory:"$Subcategory" 2>$null
        Write-Host "  [AUDIT] Audit: $Subcategory -> $AuditFlag" -ForegroundColor Yellow
        return
    }

    $flags = switch ($AuditFlag) {
        "Success"             { "/success:enable /failure:disable" }
        "Failure"             { "/success:disable /failure:enable" }
        "Success and Failure" { "/success:enable /failure:enable" }
        "No Auditing"         { "/success:disable /failure:disable" }
    }

    $cmd = "auditpol /set /subcategory:`"$Subcategory`" $flags"
    Invoke-Expression $cmd 2>&1 | Out-Null
    Write-Host "  [SET] Audit: $Subcategory = $AuditFlag" -ForegroundColor Cyan
}

Export-ModuleMember -Function Set-RegistryValue, Set-SecurityPolicy, Set-AuditPolicy

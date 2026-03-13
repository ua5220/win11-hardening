<#
.SYNOPSIS
    Bulk actions and event wiring for Windows 11 Hardening Suite
.NOTES
    Dot-sourced by Run-Hardening.ps1 after ui.ps1.
    Exports: Set-BusyState, Refresh-AllRows,
             Invoke-ApplyAllSettings, Invoke-ApplySelectedSettings,
             Invoke-RevertAllSettings, Connect-RowActions,
             Connect-HardeningActions, Export-HardeningReport
#>

# ── MinBuild фільтрація (25H2/26H1) ──────────────────────────────────────

function Get-ApplicableSettings {
    param([Parameter(Mandatory)]$AllSettings)

    $currentBuild = [System.Environment]::OSVersion.Version.Build
    $AllSettings | Where-Object {
        # Якщо MinBuild не задано — застосовується до всіх версій
        if ($null -eq $_.MinBuild) { return $true }
        $currentBuild -ge $_.MinBuild
    }
}

function Set-BusyState {
    param(
        [Parameter(Mandatory)]$Context,
        [Parameter(Mandatory)][bool]$Busy
    )
    $Context.Form.Cursor = if ($Busy) {
        [System.Windows.Forms.Cursors]::WaitCursor
    } else {
        [System.Windows.Forms.Cursors]::Default
    }
}

function Refresh-AllRows {
    param([Parameter(Mandatory)]$Context)

    $Context.StatusBar.Text = '  Оновлення станів...'
    Set-BusyState -Context $Context -Busy $true
    foreach ($rc in $Context.RowControls) {
        Refresh-RowState -Context $Context -RowRecord $rc
    }
    Set-BusyState -Context $Context -Busy $false
    $Context.StatusBar.Text = '  Стани оновлено.'
}

# ── Shared bulk-action runner ─────────────────────────────────────────────

function Invoke-BulkAction {
    param(
        [Parameter(Mandatory)]$Context,
        [Parameter(Mandatory)][System.Collections.IEnumerable]$Items,
        [Parameter(Mandatory)][string]$ActionKey,
        [Parameter(Mandatory)][string]$Label
    )

    Write-AppLog -Level 'INFO' -Message "$Label :: start"
    Set-BusyState -Context $Context -Busy $true
    $ok  = 0
    $err = 0

    foreach ($item in $Items) {
        $setting = if ($item.PSObject.Properties['Setting']) { $item.Setting } else { $item }
        try {
            & $setting.$ActionKey
            $ok++
            Write-AppLog -Level 'INFO' -Message "$Label OK :: $($setting.Name)"
        } catch {
            $err++
            Write-AppError -Context "$Label FAILED :: $($setting.Name)" -ErrorRecord $_
            $Context.StatusBar.Text = "  [ПОМИЛКА] $($setting.Name): $($_.Exception.Message)"
        }
    }

    Set-BusyState -Context $Context -Busy $false
    Refresh-AllRows -Context $Context
    Write-AppLog -Level 'INFO' -Message "$Label :: done (ok=$ok, err=$err)"
    $Context.StatusBar.Text = "  $Label завершено: $ok OK, $err помилок."
}

# ── Bulk commands ─────────────────────────────────────────────────────────

function Invoke-ApplyAllSettings {
    param([Parameter(Mandatory)]$Context)

    $res = [System.Windows.Forms.MessageBox]::Show(
        "Застосувати ВСІ $($Context.AllSettings.Count) параметрів?`nЦе змінить налаштування системи.",
        'Підтвердження',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    if ($res -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    Invoke-BulkAction -Context $Context -Items $Context.AllSettings -ActionKey 'Apply' -Label 'Apply All'
}

function Invoke-ApplySelectedSettings {
    param([Parameter(Mandatory)]$Context)

    $selected = @($Context.RowControls | Where-Object { $_.Checkbox.Checked })

    if ($selected.Count -eq 0) {
        [void][System.Windows.Forms.MessageBox]::Show(
            'Не вибрано жодного параметру.',
            'Увага',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        return
    }

    $res = [System.Windows.Forms.MessageBox]::Show(
        "Застосувати $($selected.Count) вибраних параметрів?",
        'Підтвердження',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    if ($res -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    Invoke-BulkAction -Context $Context -Items $selected -ActionKey 'Apply' -Label 'Apply Selected'

    foreach ($rc in $selected) { $rc.Checkbox.Checked = $false }
}

function Invoke-RevertAllSettings {
    param([Parameter(Mandatory)]$Context)

    $res = [System.Windows.Forms.MessageBox]::Show(
        'СКАСУВАТИ всі параметри і повернути до стандарту Windows?',
        'Підтвердження',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    if ($res -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    Invoke-BulkAction -Context $Context -Items $Context.AllSettings -ActionKey 'Revert' -Label 'Revert All'
}

# ── Row toggle wiring ─────────────────────────────────────────────────────

function Connect-RowActions {
    param([Parameter(Mandatory)]$Context)

    # Capture function references so GetNewClosure() closures can find them;
    # closures run in a dynamic module that loses session-level function visibility.
    $fnWriteAppLog     = ${function:Write-AppLog}
    $fnWriteAppError   = ${function:Write-AppError}
    $fnRefreshRowState = ${function:Refresh-RowState}

    foreach ($rc in $Context.RowControls) {
        $capturedCtx = $Context
        $capturedRec = $rc

        $capturedRec.BtnApply.Add_Click({
            try {
                & $capturedRec.Setting.Apply
                $capturedCtx.StatusBar.Text = "  [OK] Застосовано: $($capturedRec.Setting.Name)"
                & $fnWriteAppLog -Level 'INFO' -Message "Apply OK :: $($capturedRec.Setting.Name)"
            } catch {
                & $fnWriteAppError -Context "Apply FAILED :: $($capturedRec.Setting.Name)" -ErrorRecord $_
                $capturedCtx.StatusBar.Text = "  [ПОМИЛКА] $($capturedRec.Setting.Name): $($_.Exception.Message)"
            }
            & $fnRefreshRowState -Context $capturedCtx -RowRecord $capturedRec
        }.GetNewClosure())

        $capturedRec.BtnRevert.Add_Click({
            try {
                & $capturedRec.Setting.Revert
                $capturedCtx.StatusBar.Text = "  [OK] Скасовано: $($capturedRec.Setting.Name)"
                & $fnWriteAppLog -Level 'INFO' -Message "Revert OK :: $($capturedRec.Setting.Name)"
            } catch {
                & $fnWriteAppError -Context "Revert FAILED :: $($capturedRec.Setting.Name)" -ErrorRecord $_
                $capturedCtx.StatusBar.Text = "  [ПОМИЛКА] $($capturedRec.Setting.Name): $($_.Exception.Message)"
            }
            & $fnRefreshRowState -Context $capturedCtx -RowRecord $capturedRec
        }.GetNewClosure())
    }
}

# ── HTML Report ───────────────────────────────────────────────────────────

function Export-HardeningReport {
    param([Parameter(Mandatory)]$Settings)

    $ts       = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $hostname = $env:COMPUTERNAME
    $build    = [System.Environment]::OSVersion.Version.Build

    $rows = [System.Text.StringBuilder]::new()
    $ok   = 0
    $fail = 0
    $lastGroup = ''

    foreach ($s in $Settings) {
        # Group header row
        if ($s.Group -ne $lastGroup) {
            [void]$rows.AppendLine("<tr class='group'><td colspan='3'>$([System.Net.WebUtility]::HtmlEncode($s.Group))</td></tr>")
            $lastGroup = $s.Group
        }

        $status = $false
        try { $status = [bool](& $s.Check) } catch {}

        if ($status) { $ok++ } else { $fail++ }

        $dot   = if ($status) { "<span class='dot on'></span> Applied" } else { "<span class='dot off'></span> Not Applied" }
        $cls   = if ($status) { 'ok' } else { 'fail' }
        $name  = [System.Net.WebUtility]::HtmlEncode($s.Name)
        $desc  = [System.Net.WebUtility]::HtmlEncode($s.Desc) -replace "`n", '<br>'

        [void]$rows.AppendLine("<tr class='$cls'><td>$name</td><td>$dot</td><td class='desc'>$desc</td></tr>")
    }

    $total = $ok + $fail
    $pct   = if ($total -gt 0) { [math]::Round(($ok / $total) * 100) } else { 0 }

    $html = @"
<!DOCTYPE html>
<html lang="uk">
<head>
<meta charset="utf-8">
<title>Hardening Report - $hostname</title>
<style>
  body { font-family: 'Segoe UI', sans-serif; background: #121218; color: #ddd; margin: 20px; }
  h1 { color: #64b4ff; }
  .summary { background: #1e1e2e; padding: 16px 24px; border-radius: 8px; margin-bottom: 20px; }
  .summary span { margin-right: 32px; }
  .ok-count { color: #28b84a; font-weight: bold; }
  .fail-count { color: #d44; font-weight: bold; }
  table { width: 100%; border-collapse: collapse; }
  th { background: #1e1e2e; text-align: left; padding: 10px; color: #8ab4ff; }
  td { padding: 8px 10px; border-bottom: 1px solid #2a2a3a; }
  tr.group td { background: #23233a; color: #82b6ff; font-weight: 600; font-size: 1.05em; padding: 10px; }
  tr.ok td { background: #141e14; }
  tr.fail td { background: #1e1414; }
  .dot { display: inline-block; width: 10px; height: 10px; border-radius: 50%; margin-right: 6px; }
  .dot.on { background: #28b84a; }
  .dot.off { background: #a02828; }
  .desc { color: #888; font-size: 0.85em; max-width: 400px; }
  .bar { background: #2a2a3a; border-radius: 4px; height: 22px; margin-top: 8px; overflow: hidden; }
  .bar-fill { background: #28b84a; height: 100%; transition: width 0.3s; }
</style>
</head>
<body>
<h1>Windows 11 Hardening Report</h1>
<div class="summary">
  <span>Host: <b>$hostname</b></span>
  <span>Build: <b>$build</b></span>
  <span>Date: <b>$ts</b></span><br><br>
  <span class="ok-count">Applied: $ok</span>
  <span class="fail-count">Not Applied: $fail</span>
  <span>Total: $total</span>
  <span>Coverage: <b>$pct%</b></span>
  <div class="bar"><div class="bar-fill" style="width:${pct}%"></div></div>
</div>
<table>
<tr><th>Setting</th><th>Status</th><th>Description</th></tr>
$($rows.ToString())
</table>
</body>
</html>
"@

    $reportDir = Join-Path $env:ProgramData 'win11-hardening'
    if (-not (Test-Path $reportDir)) {
        New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
    }
    $reportFile = Join-Path $reportDir "hardening-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
    $html | Set-Content -Path $reportFile -Encoding UTF8 -Force

    Write-AppLog -Level 'INFO' -Message "Report exported: $reportFile (Applied=$ok, NotApplied=$fail, Coverage=$pct%)"

    return $reportFile
}

# ── Filter helper ─────────────────────────────────────────────────────────

function Invoke-Filter {
    param([Parameter(Mandatory)]$Context)
    Update-FilteredSettings -Context $Context
    Build-SettingRows       -Context $Context
    Connect-RowActions      -Context $Context
}

# ── Master wiring ─────────────────────────────────────────────────────────

function Connect-HardeningActions {
    param([Parameter(Mandatory)]$Context)

    Connect-RowActions -Context $Context

    # Capture function reference so GetNewClosure() closures can find it.
    $fnApplyFilter = ${function:Invoke-Filter}

    # Filter events
    $Context.Controls.SearchBox.Add_TextChanged({
        $Context.Filters.SearchText = $Context.Controls.SearchBox.Text
        & $fnApplyFilter -Context $Context
    }.GetNewClosure())

    $Context.Controls.GroupFilter.Add_SelectedIndexChanged({
        $Context.Filters.SelectedGroup = [string]$Context.Controls.GroupFilter.SelectedItem
        & $fnApplyFilter -Context $Context
    }.GetNewClosure())

    $Context.Controls.ResetFilter.Add_Click({
        $Context.Controls.SearchBox.Text = ''
        $Context.Controls.GroupFilter.SelectedIndex = 0
        $Context.Filters.SearchText    = ''
        $Context.Filters.SelectedGroup = 'Усі групи'
        & $fnApplyFilter -Context $Context
    }.GetNewClosure())

    # Button events
    $Context.Buttons.Refresh.Add_Click({      Refresh-AllRows             -Context $Context })
    $Context.Buttons.ApplyAll.Add_Click({     Invoke-ApplyAllSettings     -Context $Context })
    $Context.Buttons.ApplySelected.Add_Click({ Invoke-ApplySelectedSettings -Context $Context })
    $Context.Buttons.RevertAll.Add_Click({    Invoke-RevertAllSettings     -Context $Context })

    # Export report
    $fnExport = ${function:Export-HardeningReport}
    $Context.Buttons.Export.Add_Click({
        $Context.StatusBar.Text = '  Генерація HTML-звіту...'
        try {
            $file = & $fnExport -Settings $Context.AllSettings
            $Context.StatusBar.Text = "  Звіт збережено: $file"
            [System.Diagnostics.Process]::Start($file) | Out-Null
        } catch {
            $Context.StatusBar.Text = "  [ПОМИЛКА] Звіт: $($_.Exception.Message)"
        }
    }.GetNewClosure())
}

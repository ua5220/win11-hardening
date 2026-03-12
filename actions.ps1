<#
.SYNOPSIS
    Bulk actions and event wiring for HardeningGUI_v2
.NOTES
    Dot-sourced by HardeningGUI_v2.ps1 after ui.ps1.
    Exports: Set-BusyState, Refresh-AllRows,
             Invoke-ApplyAllSettings, Invoke-ApplySelectedSettings,
             Invoke-RevertAllSettings, Connect-RowActions,
             Connect-HardeningActions
#>

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
    $Context.StatusBar.Text = "  $Label\ завершено: $ok OK, $err помилок."
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

# ── Filter helper ─────────────────────────────────────────────────────────

function Apply-Filter {
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
    $fnApplyFilter = ${function:Apply-Filter}

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
}

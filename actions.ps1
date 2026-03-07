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

function Invoke-ApplyAllSettings {
    param([Parameter(Mandatory)]$Context)

    $res = [System.Windows.Forms.MessageBox]::Show(
        "Застосувати ВСІ $($Context.AllSettings.Count) параметрів?`nЦе змінить налаштування системи.",
        'Підтвердження',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if ($res -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    Set-BusyState -Context $Context -Busy $true
    $ok = 0
    $err = 0

    foreach ($s in $Context.AllSettings) {
        try {
            & $s.Apply
            $ok++
        }
        catch {
            $err++
            $Context.StatusBar.Text = "  [ПОМИЛКА] $($s.Name): $_"
        }
    }

    Set-BusyState -Context $Context -Busy $false
    Refresh-AllRows -Context $Context
    $Context.StatusBar.Text = "  Готово: застосовано $ok, помилок $err."
}

function Invoke-ApplySelectedSettings {
    param([Parameter(Mandatory)]$Context)

    $selected = @($Context.RowControls | Where-Object { $_.Checkbox.Checked })

    if ($selected.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            'Не вибрано жодного параметру.',
            'Увага',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
        return
    }

    $res = [System.Windows.Forms.MessageBox]::Show(
        "Застосувати $($selected.Count) вибраних параметрів?",
        'Підтвердження',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($res -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    Set-BusyState -Context $Context -Busy $true
    $ok = 0
    $err = 0

    foreach ($rc in $selected) {
        try {
            & $rc.Setting.Apply
            $ok++
        }
        catch {
            $err++
        }

        $rc.Checkbox.Checked = $false
    }

    Set-BusyState -Context $Context -Busy $false
    Refresh-AllRows -Context $Context
    $Context.StatusBar.Text = "  Вибране застосовано: $ok OK, $err помилок."
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

    Set-BusyState -Context $Context -Busy $true

    foreach ($s in $Context.AllSettings) {
        try { & $s.Revert } catch {}
    }

    Set-BusyState -Context $Context -Busy $false
    Refresh-AllRows -Context $Context
    $Context.StatusBar.Text = '  Всі параметри скасовано.'
}

function Connect-RowActions {
    param([Parameter(Mandatory)]$Context)

    foreach ($rc in $Context.RowControls) {
        $capturedContext = $Context
        $capturedRecord  = $rc

        $capturedRecord.Toggle.Add_Click({
            $isActive = Test-SettingEnabled -Setting $capturedRecord.Setting

            try {
                if ($isActive) {
                    & $capturedRecord.Setting.Revert
                    $capturedContext.StatusBar.Text = "  [OK] Скасовано: $($capturedRecord.Setting.Name)"
                }
                else {
                    & $capturedRecord.Setting.Apply
                    $capturedContext.StatusBar.Text = "  [OK] Застосовано: $($capturedRecord.Setting.Name)"
                }
            }
            catch {
                $capturedContext.StatusBar.Text = "  [ПОМИЛКА] $($capturedRecord.Setting.Name): $_"
            }

            Refresh-RowState -Context $capturedContext -RowRecord $capturedRecord
        }.GetNewClosure())
    }
}

function Connect-HardeningActions {
    param([Parameter(Mandatory)]$Context)

    Connect-RowActions -Context $Context

    # ── Filter events ───────────────────────────────────────────────────
    $Context.Controls.SearchBox.Add_TextChanged({
        $Context.Filters.SearchText = $Context.Controls.SearchBox.Text
        Update-FilteredSettings -Context $Context
        Build-SettingRows -Context $Context
        Connect-RowActions -Context $Context
    }.GetNewClosure())

    $Context.Controls.GroupFilter.Add_SelectedIndexChanged({
        $Context.Filters.SelectedGroup = [string]$Context.Controls.GroupFilter.SelectedItem
        Update-FilteredSettings -Context $Context
        Build-SettingRows -Context $Context
        Connect-RowActions -Context $Context
    }.GetNewClosure())

    $Context.Controls.ResetFilter.Add_Click({
        $Context.Controls.SearchBox.Text = ''
        $Context.Controls.GroupFilter.SelectedIndex = 0
        $Context.Filters.SearchText    = ''
        $Context.Filters.SelectedGroup = 'Усі групи'
        Update-FilteredSettings -Context $Context
        Build-SettingRows -Context $Context
        Connect-RowActions -Context $Context
    }.GetNewClosure())

    # ── Button events ───────────────────────────────────────────────────
    $Context.Buttons.Refresh.Add_Click({
        Refresh-AllRows -Context $Context
    })

    $Context.Buttons.ApplyAll.Add_Click({
        Invoke-ApplyAllSettings -Context $Context
    })

    $Context.Buttons.ApplySelected.Add_Click({
        Invoke-ApplySelectedSettings -Context $Context
    })

    $Context.Buttons.RevertAll.Add_Click({
        Invoke-RevertAllSettings -Context $Context
    })
}

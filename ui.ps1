<#
.SYNOPSIS
    WinForms UI factory and row rendering for HardeningGUI_v2
.NOTES
    Dot-sourced by HardeningGUI_v2.ps1 after helpers.ps1.
    Exports: New-AppTheme, New-AppButton, New-HardeningUi,
             Set-RowVisualState, Refresh-RowState,
             Show-SettingInfo, Build-SettingRows,
             Update-FilteredSettings
#>

function New-AppTheme {
    return @{
        FormBackground        = [System.Drawing.Color]::FromArgb(18, 18, 24)
        Foreground            = [System.Drawing.Color]::FromArgb(220, 220, 230)
        TitleBackground       = [System.Drawing.Color]::FromArgb(30, 30, 40)
        TitleForeground       = [System.Drawing.Color]::FromArgb(100, 180, 255)
        StatusBackground      = [System.Drawing.Color]::FromArgb(25, 25, 35)
        StatusForeground      = [System.Drawing.Color]::FromArgb(160, 160, 170)
        BottomPanelBackground = [System.Drawing.Color]::FromArgb(22, 22, 32)
        GroupBackground       = [System.Drawing.Color]::FromArgb(35, 35, 50)
        GroupForeground       = [System.Drawing.Color]::FromArgb(130, 190, 255)
        RowBackgroundA        = [System.Drawing.Color]::FromArgb(24, 24, 33)
        RowBackgroundB        = [System.Drawing.Color]::FromArgb(28, 28, 38)
        StatusOnDot           = [System.Drawing.Color]::FromArgb(40, 180, 80)
        StatusOffDot          = [System.Drawing.Color]::FromArgb(160, 40, 40)
        StatusOnText          = [System.Drawing.Color]::FromArgb(60, 200, 100)
        StatusOffText         = [System.Drawing.Color]::FromArgb(160, 160, 180)
        ToggleOffBackground   = [System.Drawing.Color]::FromArgb(90, 30, 30)
        ToggleOffForeground   = [System.Drawing.Color]::FromArgb(255, 140, 140)
        ToggleOnBackground    = [System.Drawing.Color]::FromArgb(20, 70, 30)
        ToggleOnForeground    = [System.Drawing.Color]::FromArgb(120, 220, 140)
        InfoButtonBackground  = [System.Drawing.Color]::FromArgb(30, 30, 55)
        InfoButtonForeground  = [System.Drawing.Color]::FromArgb(150, 180, 255)
        DescriptionForeground = [System.Drawing.Color]::FromArgb(130, 130, 150)
    }
}

function New-AppButton {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$ColorHex,
        [string]$ToolTip = ''
    )

    $b = New-Object System.Windows.Forms.Button
    $b.Text      = $Text
    $b.Height    = 30
    $b.Width     = 155
    $b.Margin    = New-Object System.Windows.Forms.Padding(0, 0, 8, 0)
    $b.FlatStyle = 'Flat'
    $b.FlatAppearance.BorderSize = 1
    $b.BackColor = [System.Drawing.ColorTranslator]::FromHtml($ColorHex)
    $b.ForeColor = [System.Drawing.Color]::White
    $b.Font      = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
    $b.Cursor    = 'Hand'

    if ($ToolTip) {
        $tt = New-Object System.Windows.Forms.ToolTip
        $tt.SetToolTip($b, $ToolTip)
    }

    return $b
}

function New-HardeningUi {
    param([Parameter(Mandatory)]$Settings)

    $theme = New-AppTheme

    $form = New-Object System.Windows.Forms.Form
    $form.Text          = 'Windows 11 Hardening Control Panel v2'
    $form.Size          = New-Object System.Drawing.Size(900, 760)
    $form.MinimumSize   = New-Object System.Drawing.Size(800, 600)
    $form.StartPosition = 'CenterScreen'
    $form.BackColor     = $theme.FormBackground
    $form.ForeColor     = $theme.Foreground
    $form.Font          = New-Object System.Drawing.Font('Segoe UI', 9)

    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text      = '  Windows 11 Hardening Control Panel  v2  —  ACSC + Privacy'
    $lblTitle.Dock      = 'Top'
    $lblTitle.Height    = 42
    $lblTitle.Font      = New-Object System.Drawing.Font('Segoe UI Semibold', 13)
    $lblTitle.BackColor = $theme.TitleBackground
    $lblTitle.ForeColor = $theme.TitleForeground
    $lblTitle.TextAlign = 'MiddleLeft'
    $form.Controls.Add($lblTitle)

    $statusBar = New-Object System.Windows.Forms.Label
    $statusBar.Dock      = 'Bottom'
    $statusBar.Height    = 26
    $statusBar.BackColor = $theme.StatusBackground
    $statusBar.ForeColor = $theme.StatusForeground
    $statusBar.TextAlign = 'MiddleLeft'
    $statusBar.Text      = "  Готово. Налаштувань: $($Settings.Count)"
    $statusBar.Font      = New-Object System.Drawing.Font('Segoe UI', 8.5)
    $form.Controls.Add($statusBar)

    $btnPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $btnPanel.Dock          = 'Bottom'
    $btnPanel.Height        = 48
    $btnPanel.BackColor     = $theme.BottomPanelBackground
    $btnPanel.FlowDirection = 'LeftToRight'
    $btnPanel.Padding       = New-Object System.Windows.Forms.Padding(10, 8, 0, 0)

    $btnApplyAll      = New-AppButton 'Застосувати все'     '#1a6b3a' 'Застосувати всі параметри'
    $btnApplySelected = New-AppButton 'Застосувати вибране' '#3a5a1a' 'Застосувати відмічені параметри'
    $btnRevertAll     = New-AppButton 'Скасувати все'       '#7a2020' 'Повернути до стандарту Windows'
    $btnRefresh       = New-AppButton 'Оновити стани'       '#1a3a6b' 'Перечитати поточні значення'

    $btnPanel.Controls.AddRange(@($btnApplyAll, $btnApplySelected, $btnRevertAll, $btnRefresh))
    $form.Controls.Add($btnPanel)

    # ── Filter toolbar ──────────────────────────────────────────────────
    $filterBar = New-Object System.Windows.Forms.Panel
    $filterBar.Dock      = 'Top'
    $filterBar.Height    = 36
    $filterBar.BackColor = $theme.BottomPanelBackground

    $lblSearch = New-Object System.Windows.Forms.Label
    $lblSearch.Text      = 'Пошук:'
    $lblSearch.Location  = New-Object System.Drawing.Point(12, 9)
    $lblSearch.Size      = New-Object System.Drawing.Size(50, 20)
    $lblSearch.ForeColor = $theme.Foreground
    $lblSearch.Font      = New-Object System.Drawing.Font('Segoe UI', 8.5)
    $filterBar.Controls.Add($lblSearch)

    $txtSearch = New-Object System.Windows.Forms.TextBox
    $txtSearch.Location  = New-Object System.Drawing.Point(64, 6)
    $txtSearch.Size      = New-Object System.Drawing.Size(300, 24)
    $txtSearch.BackColor = $theme.FormBackground
    $txtSearch.ForeColor = $theme.Foreground
    $txtSearch.Font      = New-Object System.Drawing.Font('Segoe UI', 9)
    $filterBar.Controls.Add($txtSearch)

    $lblGroup = New-Object System.Windows.Forms.Label
    $lblGroup.Text      = 'Група:'
    $lblGroup.Location  = New-Object System.Drawing.Point(380, 9)
    $lblGroup.Size      = New-Object System.Drawing.Size(46, 20)
    $lblGroup.ForeColor = $theme.Foreground
    $lblGroup.Font      = New-Object System.Drawing.Font('Segoe UI', 8.5)
    $filterBar.Controls.Add($lblGroup)

    $cmbGroups = New-Object System.Windows.Forms.ComboBox
    $cmbGroups.Location      = New-Object System.Drawing.Point(428, 5)
    $cmbGroups.Size          = New-Object System.Drawing.Size(300, 24)
    $cmbGroups.DropDownStyle = 'DropDownList'
    $cmbGroups.BackColor     = $theme.FormBackground
    $cmbGroups.ForeColor     = $theme.Foreground
    $cmbGroups.Font          = New-Object System.Drawing.Font('Segoe UI', 9)

    $groups = @('Усі групи') + @($Settings | ForEach-Object { $_.Group } | Select-Object -Unique)
    foreach ($g in $groups) { [void]$cmbGroups.Items.Add($g) }
    $cmbGroups.SelectedIndex = 0
    $filterBar.Controls.Add($cmbGroups)

    $btnResetFilter = New-Object System.Windows.Forms.Button
    $btnResetFilter.Text      = 'Скинути'
    $btnResetFilter.Location  = New-Object System.Drawing.Point(740, 4)
    $btnResetFilter.Size      = New-Object System.Drawing.Size(70, 26)
    $btnResetFilter.FlatStyle = 'Flat'
    $btnResetFilter.FlatAppearance.BorderSize = 1
    $btnResetFilter.BackColor = $theme.InfoButtonBackground
    $btnResetFilter.ForeColor = $theme.InfoButtonForeground
    $btnResetFilter.Font      = New-Object System.Drawing.Font('Segoe UI', 8.5)
    $btnResetFilter.Cursor    = 'Hand'
    $filterBar.Controls.Add($btnResetFilter)

    $form.Controls.Add($filterBar)

    # ── Scroll panel ────────────────────────────────────────────────────
    $scroll = New-Object System.Windows.Forms.Panel
    $scroll.Dock       = 'Fill'
    $scroll.AutoScroll = $true
    $scroll.BackColor  = $theme.FormBackground
    $form.Controls.Add($scroll)

    return [PSCustomObject]@{
        Form             = $form
        Theme            = $theme
        AllSettings      = @($Settings)
        FilteredSettings = @($Settings)
        Scroll           = $scroll
        StatusBar        = $statusBar
        RowControls      = [System.Collections.ArrayList]::new()
        Filters          = [PSCustomObject]@{
            SearchText    = ''
            SelectedGroup = 'Усі групи'
        }
        Controls         = [PSCustomObject]@{
            SearchBox   = $txtSearch
            GroupFilter = $cmbGroups
            ResetFilter = $btnResetFilter
        }
        Buttons          = [PSCustomObject]@{
            ApplyAll      = $btnApplyAll
            ApplySelected = $btnApplySelected
            RevertAll     = $btnRevertAll
            Refresh       = $btnRefresh
        }
    }
}

function Set-RowVisualState {
    param(
        [Parameter(Mandatory)]$Context,
        [Parameter(Mandatory)]$RowRecord,
        [Parameter(Mandatory)][bool]$IsActive
    )

    $theme = $Context.Theme

    if ($IsActive) {
        $RowRecord.StatusDot.BackColor = $theme.StatusOnDot
        $RowRecord.StatusLbl.Text      = 'УВІМКНЕНО'
        $RowRecord.StatusLbl.ForeColor = $theme.StatusOnText
        $RowRecord.Toggle.Text         = 'Вимкнути'
        $RowRecord.Toggle.BackColor    = $theme.ToggleOffBackground
        $RowRecord.Toggle.ForeColor    = $theme.ToggleOffForeground
    }
    else {
        $RowRecord.StatusDot.BackColor = $theme.StatusOffDot
        $RowRecord.StatusLbl.Text      = 'вимкнено'
        $RowRecord.StatusLbl.ForeColor = $theme.StatusOffText
        $RowRecord.Toggle.Text         = 'Увімкнути'
        $RowRecord.Toggle.BackColor    = $theme.ToggleOnBackground
        $RowRecord.Toggle.ForeColor    = $theme.ToggleOnForeground
    }
}

function Refresh-RowState {
    param(
        [Parameter(Mandatory)]$Context,
        [Parameter(Mandatory)]$RowRecord
    )

    $isActive = Test-SettingEnabled -Setting $RowRecord.Setting
    Set-RowVisualState -Context $Context -RowRecord $RowRecord -IsActive $isActive
}

function Show-SettingInfo {
    param([Parameter(Mandatory)]$Setting)

    [System.Windows.Forms.MessageBox]::Show(
        "Параметр: $($Setting.Name)`n`n$($Setting.Desc)`n`nГрупа: $($Setting.Group)",
        'Деталі',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}

function Update-FilteredSettings {
    param([Parameter(Mandatory)]$Context)

    $search = "$($Context.Filters.SearchText)".Trim().ToLowerInvariant()
    $group  = $Context.Filters.SelectedGroup

    $items = @($Context.AllSettings)

    if ($group -and $group -ne 'Усі групи') {
        $items = @($items | Where-Object { $_.Group -eq $group })
    }

    if ($search) {
        $items = @($items | Where-Object {
            $_.Name.ToLowerInvariant().Contains($search) -or
            $_.Desc.ToLowerInvariant().Contains($search) -or
            $_.Group.ToLowerInvariant().Contains($search)
        })
    }

    $Context.FilteredSettings = $items
    $Context.StatusBar.Text = "  Показано: $($items.Count) із $($Context.AllSettings.Count)"
}

function Build-SettingRows {
    param([Parameter(Mandatory)]$Context)

    $Context.Scroll.Controls.Clear()
    $Context.RowControls.Clear()

    $y = 8
    $lastGroup = ''
    $rowIndex = 0

    foreach ($s in $Context.FilteredSettings) {
        if ($s.Group -ne $lastGroup) {
            $lbl = New-Object System.Windows.Forms.Label
            $lbl.Text      = "  $($s.Group)"
            $lbl.Location  = New-Object System.Drawing.Point(10, $y)
            $lbl.Size      = New-Object System.Drawing.Size(860, 28)
            $lbl.Font      = New-Object System.Drawing.Font('Segoe UI Semibold', 10)
            $lbl.BackColor = $Context.Theme.GroupBackground
            $lbl.ForeColor = $Context.Theme.GroupForeground
            $Context.Scroll.Controls.Add($lbl)

            $y += 32
            $lastGroup = $s.Group
        }

        $rowBg = if (($rowIndex % 2) -eq 0) { $Context.Theme.RowBackgroundA } else { $Context.Theme.RowBackgroundB }
        $active = Test-SettingEnabled -Setting $s

        $row = New-Object System.Windows.Forms.Panel
        $row.Location  = New-Object System.Drawing.Point(10, $y)
        $row.Size      = New-Object System.Drawing.Size(860, 46)
        $row.BackColor = $rowBg

        $chk = New-Object System.Windows.Forms.CheckBox
        $chk.Location  = New-Object System.Drawing.Point(8, 14)
        $chk.Size      = New-Object System.Drawing.Size(20, 20)
        $chk.BackColor = $rowBg

        $statusDot = New-Object System.Windows.Forms.Label
        $statusDot.Location = New-Object System.Drawing.Point(32, 8)
        $statusDot.Size     = New-Object System.Drawing.Size(10, 30)
        $statusDot.Text     = ''

        $lblName = New-Object System.Windows.Forms.Label
        $lblName.Text      = "  $($s.Name)"
        $lblName.Location  = New-Object System.Drawing.Point(46, 4)
        $lblName.Size      = New-Object System.Drawing.Size(520, 20)
        $lblName.Font      = New-Object System.Drawing.Font('Segoe UI', 9)
        $lblName.ForeColor = $Context.Theme.Foreground
        $lblName.BackColor = $rowBg

        $lblDesc = New-Object System.Windows.Forms.Label
        $lblDesc.Text      = "  $($s.Desc)"
        $lblDesc.Location  = New-Object System.Drawing.Point(46, 24)
        $lblDesc.Size      = New-Object System.Drawing.Size(520, 18)
        $lblDesc.Font      = New-Object System.Drawing.Font('Segoe UI', 7.5)
        $lblDesc.ForeColor = $Context.Theme.DescriptionForeground
        $lblDesc.BackColor = $rowBg

        $statusLbl = New-Object System.Windows.Forms.Label
        $statusLbl.Location  = New-Object System.Drawing.Point(572, 14)
        $statusLbl.Size      = New-Object System.Drawing.Size(90, 18)
        $statusLbl.Font      = New-Object System.Drawing.Font('Segoe UI Semibold', 8)
        $statusLbl.TextAlign = 'MiddleCenter'
        $statusLbl.BackColor = $rowBg

        $toggleBtn = New-Object System.Windows.Forms.Button
        $toggleBtn.Location  = New-Object System.Drawing.Point(668, 9)
        $toggleBtn.Size      = New-Object System.Drawing.Size(90, 28)
        $toggleBtn.FlatStyle = 'Flat'
        $toggleBtn.FlatAppearance.BorderSize = 1
        $toggleBtn.Font   = New-Object System.Drawing.Font('Segoe UI Semibold', 8.5)
        $toggleBtn.Cursor = 'Hand'

        $infoBtn = New-Object System.Windows.Forms.Button
        $infoBtn.Location  = New-Object System.Drawing.Point(764, 9)
        $infoBtn.Size      = New-Object System.Drawing.Size(86, 28)
        $infoBtn.FlatStyle = 'Flat'
        $infoBtn.FlatAppearance.BorderSize = 1
        $infoBtn.Text      = 'Деталі'
        $infoBtn.BackColor = $Context.Theme.InfoButtonBackground
        $infoBtn.ForeColor = $Context.Theme.InfoButtonForeground
        $infoBtn.Font      = New-Object System.Drawing.Font('Segoe UI', 8.5)
        $infoBtn.Cursor    = 'Hand'

        $row.Controls.AddRange(@($chk, $statusDot, $lblName, $lblDesc, $statusLbl, $toggleBtn, $infoBtn))
        $Context.Scroll.Controls.Add($row)

        $record = [PSCustomObject]@{
            Checkbox  = $chk
            Toggle    = $toggleBtn
            Info      = $infoBtn
            Setting   = $s
            StatusDot = $statusDot
            StatusLbl = $statusLbl
        }

        Set-RowVisualState -Context $Context -RowRecord $record -IsActive $active

        $capturedSetting = $s
        $infoBtn.Add_Click({
            Show-SettingInfo -Setting $capturedSetting
        }.GetNewClosure())

        [void]$Context.RowControls.Add($record)

        $y += 50
        $rowIndex++
    }

    $spacer = New-Object System.Windows.Forms.Panel
    $spacer.Location  = New-Object System.Drawing.Point(0, $y)
    $spacer.Size      = New-Object System.Drawing.Size(1, 20)
    $spacer.BackColor = $Context.Theme.FormBackground
    $Context.Scroll.Controls.Add($spacer)

    $Context.Scroll.AutoScrollMinSize = New-Object System.Drawing.Size(860, ($y + 30))
}

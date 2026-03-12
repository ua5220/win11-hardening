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
    $C = [System.Drawing.Color]
    return [ordered]@{
        FormBackground        = $C::FromArgb(18,  18,  24)
        Foreground            = $C::FromArgb(220, 220, 230)
        TitleBackground       = $C::FromArgb(30,  30,  40)
        TitleForeground       = $C::FromArgb(100, 180, 255)
        StatusBackground      = $C::FromArgb(25,  25,  35)
        StatusForeground      = $C::FromArgb(160, 160, 170)
        BottomPanelBackground = $C::FromArgb(22,  22,  32)
        GroupBackground       = $C::FromArgb(35,  35,  50)
        GroupForeground       = $C::FromArgb(130, 190, 255)
        RowBackgroundA        = $C::FromArgb(24,  24,  33)
        RowBackgroundB        = $C::FromArgb(28,  28,  38)
        StatusOnDot           = $C::FromArgb(40,  180,  80)
        StatusOffDot          = $C::FromArgb(160,  40,  40)
        StatusOnText          = $C::FromArgb(60,  200, 100)
        StatusOffText         = $C::FromArgb(160, 160, 180)
        ToggleOffBackground   = $C::FromArgb(90,   30,  30)
        ToggleOffForeground   = $C::FromArgb(255, 140, 140)
        ToggleOnBackground    = $C::FromArgb(20,   70,  30)
        ToggleOnForeground    = $C::FromArgb(120, 220, 140)
        InfoButtonBackground  = $C::FromArgb(30,   30,  55)
        InfoButtonForeground  = $C::FromArgb(150, 180, 255)
        DescriptionForeground = $C::FromArgb(130, 130, 150)
    }
}

function New-AppButton {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][System.Drawing.Color]$BackColor,
        [string]$ToolTip = ''
    )

    $b = [System.Windows.Forms.Button]::new()
    $b.Text      = $Text
    $b.Height    = 30
    $b.Width     = 155
    $b.Margin    = [System.Windows.Forms.Padding]::new(0, 0, 8, 0)
    $b.FlatStyle = 'Flat'
    $b.FlatAppearance.BorderSize = 1
    $b.BackColor = $BackColor
    $b.ForeColor = [System.Drawing.Color]::White
    $b.Font      = [System.Drawing.Font]::new('Segoe UI Semibold', 9)
    $b.Cursor    = 'Hand'

    if ($ToolTip) {
        $tt = [System.Windows.Forms.ToolTip]::new()
        $tt.SetToolTip($b, $ToolTip)
    }

    return $b
}

function New-HardeningUi {
    param([Parameter(Mandatory)]$Settings)

    $theme = New-AppTheme
    $C     = [System.Drawing.Color]

    # ── Form ────────────────────────────────────────────────────────────
    $form = [System.Windows.Forms.Form]::new()
    $form.Text          = 'Windows 11 Hardening Control Panel v2'
    $form.Size          = [System.Drawing.Size]::new(900, 760)
    $form.MinimumSize   = [System.Drawing.Size]::new(800, 600)
    $form.StartPosition = 'CenterScreen'
    $form.BackColor     = $theme.FormBackground
    $form.ForeColor     = $theme.Foreground
    $form.Font          = [System.Drawing.Font]::new('Segoe UI', 9)

    # ── Title ───────────────────────────────────────────────────────────
    $lblTitle = [System.Windows.Forms.Label]::new()
    $lblTitle.Text      = '  Windows 11 Hardening Control Panel  v2  —  ACSC + Privacy'
    $lblTitle.Dock      = 'Top'
    $lblTitle.Height    = 42
    $lblTitle.Font      = [System.Drawing.Font]::new('Segoe UI Semibold', 13)
    $lblTitle.BackColor = $theme.TitleBackground
    $lblTitle.ForeColor = $theme.TitleForeground
    $lblTitle.TextAlign = 'MiddleLeft'
    $form.Controls.Add($lblTitle)

    # ── Status bar ──────────────────────────────────────────────────────
    $statusBar = [System.Windows.Forms.Label]::new()
    $statusBar.Dock      = 'Bottom'
    $statusBar.Height    = 26
    $statusBar.BackColor = $theme.StatusBackground
    $statusBar.ForeColor = $theme.StatusForeground
    $statusBar.TextAlign = 'MiddleLeft'
    $statusBar.Text      = "  Готово. Налаштувань: $($Settings.Count)"
    $statusBar.Font      = [System.Drawing.Font]::new('Segoe UI', 8.5)
    $form.Controls.Add($statusBar)

    # ── Bottom button panel ──────────────────────────────────────────────
    $btnPanel = [System.Windows.Forms.FlowLayoutPanel]::new()
    $btnPanel.Dock          = 'Bottom'
    $btnPanel.Height        = 48
    $btnPanel.BackColor     = $theme.BottomPanelBackground
    $btnPanel.FlowDirection = 'LeftToRight'
    $btnPanel.Padding       = [System.Windows.Forms.Padding]::new(10, 8, 0, 0)

    $btnApplyAll      = New-AppButton 'Застосувати все'     $C::FromArgb(26, 107, 58)  'Застосувати всі параметри'
    $btnApplySelected = New-AppButton 'Застосувати вибране' $C::FromArgb(58,  90, 26)  'Застосувати відмічені параметри'
    $btnRevertAll     = New-AppButton 'Скасувати все'       $C::FromArgb(122, 32, 32)  'Повернути до стандарту Windows'
    $btnRefresh       = New-AppButton 'Оновити стани'       $C::FromArgb(26,  58, 107) 'Перечитати поточні значення'

    $btnPanel.Controls.AddRange([System.Windows.Forms.Control[]]@($btnApplyAll, $btnApplySelected, $btnRevertAll, $btnRefresh))
    $form.Controls.Add($btnPanel)

    # ── Filter toolbar ──────────────────────────────────────────────────
    $filterBar = [System.Windows.Forms.Panel]::new()
    $filterBar.Dock      = 'Top'
    $filterBar.Height    = 36
    $filterBar.BackColor = $theme.BottomPanelBackground

    $lblSearch = [System.Windows.Forms.Label]::new()
    $lblSearch.Text      = 'Пошук:'
    $lblSearch.Location  = [System.Drawing.Point]::new(12, 9)
    $lblSearch.Size      = [System.Drawing.Size]::new(50, 20)
    $lblSearch.ForeColor = $theme.Foreground
    $lblSearch.Font      = [System.Drawing.Font]::new('Segoe UI', 8.5)

    $txtSearch = [System.Windows.Forms.TextBox]::new()
    $txtSearch.Location  = [System.Drawing.Point]::new(64, 6)
    $txtSearch.Size      = [System.Drawing.Size]::new(300, 24)
    $txtSearch.BackColor = $theme.FormBackground
    $txtSearch.ForeColor = $theme.Foreground
    $txtSearch.Font      = [System.Drawing.Font]::new('Segoe UI', 9)

    $lblGroup = [System.Windows.Forms.Label]::new()
    $lblGroup.Text      = 'Група:'
    $lblGroup.Location  = [System.Drawing.Point]::new(380, 9)
    $lblGroup.Size      = [System.Drawing.Size]::new(46, 20)
    $lblGroup.ForeColor = $theme.Foreground
    $lblGroup.Font      = [System.Drawing.Font]::new('Segoe UI', 8.5)

    $cmbGroups = [System.Windows.Forms.ComboBox]::new()
    $cmbGroups.Location      = [System.Drawing.Point]::new(428, 5)
    $cmbGroups.Size          = [System.Drawing.Size]::new(300, 24)
    $cmbGroups.DropDownStyle = 'DropDownList'
    $cmbGroups.BackColor     = $theme.FormBackground
    $cmbGroups.ForeColor     = $theme.Foreground
    $cmbGroups.Font          = [System.Drawing.Font]::new('Segoe UI', 9)

    $groups = @('Усі групи') + @($Settings | Select-Object -ExpandProperty Group -Unique)
    [void]$cmbGroups.Items.AddRange($groups)
    $cmbGroups.SelectedIndex = 0

    $btnResetFilter = [System.Windows.Forms.Button]::new()
    $btnResetFilter.Text      = 'Скинути'
    $btnResetFilter.Location  = [System.Drawing.Point]::new(740, 4)
    $btnResetFilter.Size      = [System.Drawing.Size]::new(70, 26)
    $btnResetFilter.FlatStyle = 'Flat'
    $btnResetFilter.FlatAppearance.BorderSize = 1
    $btnResetFilter.BackColor = $theme.InfoButtonBackground
    $btnResetFilter.ForeColor = $theme.InfoButtonForeground
    $btnResetFilter.Font      = [System.Drawing.Font]::new('Segoe UI', 8.5)
    $btnResetFilter.Cursor    = 'Hand'

    $filterBar.Controls.AddRange([System.Windows.Forms.Control[]]@($lblSearch, $txtSearch, $lblGroup, $cmbGroups, $btnResetFilter))
    $form.Controls.Add($filterBar)

    # ── Scroll panel ────────────────────────────────────────────────────
    $scroll = [System.Windows.Forms.Panel]::new()
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

    $t = $Context.Theme

    if ($IsActive) {
        $RowRecord.StatusDot.BackColor = $t.StatusOnDot
        $RowRecord.StatusLbl.Text      = 'УВІМКНЕНО'
        $RowRecord.StatusLbl.ForeColor = $t.StatusOnText
        $RowRecord.Toggle.Text         = 'Вимкнути'
        $RowRecord.Toggle.BackColor    = $t.ToggleOffBackground
        $RowRecord.Toggle.ForeColor    = $t.ToggleOffForeground
    } else {
        $RowRecord.StatusDot.BackColor = $t.StatusOffDot
        $RowRecord.StatusLbl.Text      = 'вимкнено'
        $RowRecord.StatusLbl.ForeColor = $t.StatusOffText
        $RowRecord.Toggle.Text         = 'Увімкнути'
        $RowRecord.Toggle.BackColor    = $t.ToggleOnBackground
        $RowRecord.Toggle.ForeColor    = $t.ToggleOnForeground
    }
}

function Refresh-RowState {
    param(
        [Parameter(Mandatory)]$Context,
        [Parameter(Mandatory)]$RowRecord
    )
    Set-RowVisualState -Context $Context -RowRecord $RowRecord `
        -IsActive (Test-SettingEnabled -Setting $RowRecord.Setting)
}

function Show-SettingInfo {
    param([Parameter(Mandatory)]$Setting)

    [void][System.Windows.Forms.MessageBox]::Show(
        "Параметр: $($Setting.Name)`n`n$($Setting.Desc)`n`nГрупа: $($Setting.Group)",
        'Деталі',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )
}

function Update-FilteredSettings {
    param([Parameter(Mandatory)]$Context)

    $search = $Context.Filters.SearchText.Trim().ToLowerInvariant()
    $group  = $Context.Filters.SelectedGroup
    $all    = $Context.AllSettings

    $items = @($all | Where-Object {
        ($group -eq 'Усі групи' -or $_.Group -eq $group) -and
        (-not $search -or
            $_.Name.ToLowerInvariant().Contains($search) -or
            $_.Desc.ToLowerInvariant().Contains($search) -or
            $_.Group.ToLowerInvariant().Contains($search))
    })

    $Context.FilteredSettings = $items
    $Context.StatusBar.Text   = "  Показано: $($items.Count) із $($all.Count)"
}

function Build-SettingRows {
    param([Parameter(Mandatory)]$Context)

    $scroll = $Context.Scroll
    $scroll.SuspendLayout()
    $scroll.Controls.Clear()
    $Context.RowControls.Clear()

    $y         = 8
    $lastGroup = ''
    $rowIndex  = 0
    $font9     = [System.Drawing.Font]::new('Segoe UI', 9)
    $fontSB10  = [System.Drawing.Font]::new('Segoe UI Semibold', 10)
    $fontSB8   = [System.Drawing.Font]::new('Segoe UI Semibold', 8)
    $font75    = [System.Drawing.Font]::new('Segoe UI', 7.5)
    $font85    = [System.Drawing.Font]::new('Segoe UI', 8.5)
    $t         = $Context.Theme

    foreach ($s in $Context.FilteredSettings) {

        # ── Group header ────────────────────────────────────────────────
        if ($s.Group -ne $lastGroup) {
            $lbl = [System.Windows.Forms.Label]::new()
            $lbl.Text      = "  $($s.Group)"
            $lbl.Location  = [System.Drawing.Point]::new(10, $y)
            $lbl.Size      = [System.Drawing.Size]::new(860, 28)
            $lbl.Font      = $fontSB10
            $lbl.BackColor = $t.GroupBackground
            $lbl.ForeColor = $t.GroupForeground
            $scroll.Controls.Add($lbl)
            $y        += 32
            $lastGroup = $s.Group
        }

        # ── Row ─────────────────────────────────────────────────────────
        $rowBg = if (($rowIndex % 2) -eq 0) { $t.RowBackgroundA } else { $t.RowBackgroundB }
        $active = Test-SettingEnabled -Setting $s

        $row = [System.Windows.Forms.Panel]::new()
        $row.Location  = [System.Drawing.Point]::new(10, $y)
        $row.Size      = [System.Drawing.Size]::new(860, 46)
        $row.BackColor = $rowBg

        $chk = [System.Windows.Forms.CheckBox]::new()
        $chk.Location  = [System.Drawing.Point]::new(8, 14)
        $chk.Size      = [System.Drawing.Size]::new(20, 20)
        $chk.BackColor = $rowBg

        $statusDot = [System.Windows.Forms.Label]::new()
        $statusDot.Location = [System.Drawing.Point]::new(32, 8)
        $statusDot.Size     = [System.Drawing.Size]::new(10, 30)
        $statusDot.Text     = ''

        $lblName = [System.Windows.Forms.Label]::new()
        $lblName.Text      = "  $($s.Name)"
        $lblName.Location  = [System.Drawing.Point]::new(46, 4)
        $lblName.Size      = [System.Drawing.Size]::new(520, 20)
        $lblName.Font      = $font9
        $lblName.ForeColor = $t.Foreground
        $lblName.BackColor = $rowBg

        $lblDesc = [System.Windows.Forms.Label]::new()
        $lblDesc.Text      = "  $($s.Desc)"
        $lblDesc.Location  = [System.Drawing.Point]::new(46, 24)
        $lblDesc.Size      = [System.Drawing.Size]::new(520, 18)
        $lblDesc.Font      = $font75
        $lblDesc.ForeColor = $t.DescriptionForeground
        $lblDesc.BackColor = $rowBg

        $statusLbl = [System.Windows.Forms.Label]::new()
        $statusLbl.Location  = [System.Drawing.Point]::new(572, 14)
        $statusLbl.Size      = [System.Drawing.Size]::new(90, 18)
        $statusLbl.Font      = $fontSB8
        $statusLbl.TextAlign = 'MiddleCenter'
        $statusLbl.BackColor = $rowBg

        $toggleBtn = [System.Windows.Forms.Button]::new()
        $toggleBtn.Location  = [System.Drawing.Point]::new(668, 9)
        $toggleBtn.Size      = [System.Drawing.Size]::new(90, 28)
        $toggleBtn.FlatStyle = 'Flat'
        $toggleBtn.FlatAppearance.BorderSize = 1
        $toggleBtn.Font   = $fontSB8
        $toggleBtn.Cursor = 'Hand'

        $infoBtn = [System.Windows.Forms.Button]::new()
        $infoBtn.Location  = [System.Drawing.Point]::new(764, 9)
        $infoBtn.Size      = [System.Drawing.Size]::new(86, 28)
        $infoBtn.FlatStyle = 'Flat'
        $infoBtn.FlatAppearance.BorderSize = 1
        $infoBtn.Text      = 'Деталі'
        $infoBtn.BackColor = $t.InfoButtonBackground
        $infoBtn.ForeColor = $t.InfoButtonForeground
        $infoBtn.Font      = $font85
        $infoBtn.Cursor    = 'Hand'

        $row.Controls.AddRange([System.Windows.Forms.Control[]]@($chk, $statusDot, $lblName, $lblDesc, $statusLbl, $toggleBtn, $infoBtn))
        $scroll.Controls.Add($row)

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
        $infoBtn.Add_Click({ Show-SettingInfo -Setting $capturedSetting }.GetNewClosure())

        [void]$Context.RowControls.Add($record)
        $y += 50
        $rowIndex++
    }

    # Spacer at bottom for comfortable scrolling
    $spacer = [System.Windows.Forms.Panel]::new()
    $spacer.Location  = [System.Drawing.Point]::new(0, $y)
    $spacer.Size      = [System.Drawing.Size]::new(1, 20)
    $spacer.BackColor = $t.FormBackground
    $scroll.Controls.Add($spacer)

    $scroll.AutoScrollMinSize = [System.Drawing.Size]::new(860, $y + 30)
    $scroll.ResumeLayout($false)
}

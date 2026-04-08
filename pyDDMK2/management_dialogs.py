"""
Management UI dialogs.
"""
import wx
from datetime import date, timedelta
from typing import Optional

from management import ManagementManager
from calendar import CalendarManager, MONTHS_GR
from people import PatientManager
from translations import translate_en_to_gr as T


class DailyStatisticsDialog(wx.Dialog):
    """Dialog showing daily statistics."""

    def __init__(self, parent):
        super().__init__(parent, title=T("Daily Statistics"), size=(600, 450))

        self.current_date = date.today()

        panel = wx.Panel(self)
        main_sizer = wx.BoxSizer(wx.VERTICAL)

        # Date selection
        header_sizer = wx.BoxSizer(wx.HORIZONTAL)
        header_sizer.Add(wx.StaticText(panel, label=T("Date") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.date_picker = wx.DatePickerCtrl(panel, value=self.current_date)
        header_sizer.Add(self.date_picker, 0, wx.ALL, 5)

        self.refresh_btn = wx.Button(panel, label=T("Refresh"))
        self.refresh_btn.Bind(wx.EVT_BUTTON, self._on_refresh)
        header_sizer.Add(self.refresh_btn, 0, wx.ALL, 5)

        header_sizer.AddStretchSpacer()
        main_sizer.Add(header_sizer, 0, wx.EXPAND | wx.ALL, 5)

        # Statistics display
        self.stats_text = wx.TextCtrl(
            panel,
            style=wx.TE_MULTILINE | wx.TE_READONLY,
            size=(-1, 300)
        )
        main_sizer.Add(self.stats_text, 1, wx.EXPAND | wx.ALL, 5)

        # Buttons
        btn_sizer = wx.BoxSizer(wx.HORIZONTAL)
        self.close_btn = wx.Button(panel, label=T("Close"))
        self.close_btn.Bind(wx.EVT_BUTTON, self._on_close)
        btn_sizer.AddStretchSpacer()
        btn_sizer.Add(self.close_btn, 0, wx.ALL, 5)
        main_sizer.Add(btn_sizer, 0, wx.ALIGN_RIGHT)

        panel.SetSizer(main_sizer)

        self._refresh_stats()

    def _refresh_stats(self):
        """Refresh statistics display."""
        selected_date = date(
            self.date_picker.GetValue().GetYear(),
            self.date_picker.GetValue().GetMonth() + 1,
            self.date_picker.GetValue().GetDay()
        )

        stats = ManagementManager.get_daily_statistics(selected_date)
        report = ManagementManager.format_daily_statistics_report(stats)

        self.stats_text.SetValue(report)

    def _on_refresh(self, event):
        """Handle refresh button click."""
        self._refresh_stats()

    def _on_close(self, event):
        """Close the dialog."""
        self.EndModal(wx.ID_OK)


class MonthlyReportDialog(wx.Dialog):
    """Dialog showing monthly report."""

    def __init__(self, parent):
        super().__init__(parent, title=T("Monthly Report"), size=(700, 550))

        self.current_date = date.today()

        panel = wx.Panel(self)
        main_sizer = wx.BoxSizer(wx.VERTICAL)

        # Month/Year selection
        header_sizer = wx.BoxSizer(wx.HORIZONTAL)
        header_sizer.Add(wx.StaticText(panel, label=T("Month") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)

        self.month_combo = wx.ComboBox(
            panel,
            choices=[f"{i}: {MONTHS_GR[i]}" for i in range(1, 13)],
            value=f"{self.current_date.month}: {MONTHS_GR[self.current_date.month]}",
            style=wx.CB_DROPDOWN
        )
        header_sizer.Add(self.month_combo, 0, wx.ALL, 2)

        header_sizer.Add(wx.StaticText(panel, label=T("Year") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.year_combo = wx.ComboBox(
            panel,
            choices=[str(y) for y in range(self.current_date.year - 5, self.current_date.year + 6)],
            value=str(self.current_date.year),
            style=wx.CB_DROPDOWN,
            size=(70, -1)
        )
        header_sizer.Add(self.year_combo, 0, wx.ALL, 2)

        self.refresh_btn = wx.Button(panel, label=T("Generate"))
        self.refresh_btn.Bind(wx.EVT_BUTTON, self._on_generate)
        header_sizer.Add(self.refresh_btn, 0, wx.ALL, 5)

        header_sizer.AddStretchSpacer()
        main_sizer.Add(header_sizer, 0, wx.EXPAND | wx.ALL, 5)

        # Report display
        self.report_text = wx.TextCtrl(
            panel,
            style=wx.TE_MULTILINE | wx.TE_READONLY,
            size=(-1, 350)
        )
        main_sizer.Add(self.report_text, 1, wx.EXPAND | wx.ALL, 5)

        # Appointments list
        wx.StaticLine(panel)
        main_sizer.Add(wx.StaticLine(panel), 0, wx.EXPAND | wx.ALL, 5)

        wx.StaticText(panel, label=T("Appointments by Day"))

        self.appointments_list = wx.ListCtrl(
            panel,
            style=wx.LC_REPORT | wx.BORDER_SUNKEN
        )
        self.appointments_list.InsertColumn(0, T("Date"), width=100)
        self.appointments_list.InsertColumn(1, T("Count"), width=60)
        main_sizer.Add(self.appointments_list, 1, wx.EXPAND | wx.ALL, 5)

        # Buttons
        btn_sizer = wx.BoxSizer(wx.HORIZONTAL)
        self.export_btn = wx.Button(panel, label=T("Export"))
        self.close_btn = wx.Button(panel, label=T("Close"))

        self.export_btn.Bind(wx.EVT_BUTTON, self._on_export)
        self.close_btn.Bind(wx.EVT_BUTTON, self._on_close)

        btn_sizer.AddStretchSpacer()
        btn_sizer.Add(self.export_btn, 0, wx.ALL, 5)
        btn_sizer.Add(self.close_btn, 0, wx.ALL, 5)
        main_sizer.Add(btn_sizer, 0, wx.ALIGN_RIGHT)

        panel.SetSizer(main_sizer)

        self._generate_report()

    def _generate_report(self):
        """Generate monthly report."""
        month = int(self.month_combo.GetValue().split(':')[0])
        year = int(self.year_combo.GetValue())

        report = ManagementManager.get_monthly_report(year, month)
        report_text = ManagementManager.format_monthly_report(report)

        self.report_text.SetValue(report_text)

        # Fill appointments list
        self.appointments_list.DeleteAllItems()
        for day_str, count in sorted(report['appointments_by_day'].items()):
            idx = self.appointments_list.InsertItem(self.appointments_list.GetItemCount(), day_str)
            self.appointments_list.SetItem(idx, 1, str(count))

    def _on_generate(self, event):
        """Handle generate button click."""
        self._generate_report()

    def _on_export(self, event):
        """Export report to file."""
        with wx.FileDialog(
            self,
            message=T("Save report as"),
            wildcard="Text files (*.txt)|*.txt|CSV files (*.csv)|*.csv",
            style=wx.FD_SAVE | wx.FD_OVERWRITE_PROMPT
        ) as dialog:
            if dialog.ShowModal() == wx.ID_OK:
                filepath = dialog.GetPath()
                report_text = self.report_text.GetValue()
                try:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(report_text)
                    wx.MessageBox(T("Report exported successfully"), T("Success"), wx.OK | wx.ICON_INFORMATION)
                except Exception as e:
                    wx.MessageBox(f"Error exporting report: {e}", T("Error"), wx.OK | wx.ICON_ERROR)

    def _on_close(self, event):
        """Close the dialog."""
        self.EndModal(wx.ID_OK)


class BackupDialog(wx.Dialog):
    """Dialog for backing up the database."""

    def __init__(self, parent):
        super().__init__(parent, title=T("Backup Database"), size=(500, 300))

        panel = wx.Panel(self)
        main_sizer = wx.BoxSizer(wx.VERTICAL)

        # Instructions
        info_text = wx.StaticText(
            panel,
            label=(
                T("Backup your patient database.\n\n") +
                T("The backup will copy all .dat files from the Database folder.\n") +
                T("Store the backup in a safe location.")
            )
        )
        main_sizer.Add(info_text, 0, wx.ALL, 10)

        # Backup location
        location_sizer = wx.BoxSizer(wx.HORIZONTAL)
        location_sizer.Add(wx.StaticText(panel, label=T("Backup location") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.location_text = wx.TextCtrl(panel, value="")
        location_sizer.Add(self.location_text, 1, wx.EXPAND | wx.ALL, 2)
        self.browse_btn = wx.Button(panel, label="...")
        self.browse_btn.Bind(wx.EVT_BUTTON, self._on_browse)
        location_sizer.Add(self.browse_btn, 0, wx.ALL, 2)
        main_sizer.Add(location_sizer, 0, wx.EXPAND | wx.ALL, 5)

        # Progress
        self.progress_bar = wx.Gauge(panel, range=100)
        main_sizer.Add(self.progress_bar, 0, wx.EXPAND | wx.ALL, 10)

        self.status_text = wx.StaticText(panel, label="")
        main_sizer.Add(self.status_text, 0, wx.ALL, 5)

        # Buttons
        btn_sizer = wx.BoxSizer(wx.HORIZONTAL)
        self.backup_btn = wx.Button(panel, label=T("Backup"))
        self.cancel_btn = wx.Button(panel, label=T("Cancel"))

        self.backup_btn.Bind(wx.EVT_BUTTON, self._on_backup)
        self.cancel_btn.Bind(wx.EVT_BUTTON, self._on_cancel)

        btn_sizer.AddStretchSpacer()
        btn_sizer.Add(self.backup_btn, 0, wx.ALL, 5)
        btn_sizer.Add(self.cancel_btn, 0, wx.ALL, 5)
        main_sizer.Add(btn_sizer, 0, wx.ALIGN_RIGHT)

        panel.SetSizer(main_sizer)

    def _on_browse(self, event):
        """Browse for backup location."""
        with wx.DirDialog(
            self,
            message=T("Select backup location"),
            style=wx.DD_DEFAULT_STYLE | wx.DD_NEW_DIR_ALLOWED
        ) as dialog:
            if dialog.ShowModal() == wx.ID_OK:
                self.location_text.SetValue(dialog.GetPath())

    def _on_backup(self, event):
        """Perform backup."""
        from pathlib import Path
        import shutil

        backup_path = Path(self.location_text.GetValue().strip())
        if not backup_path:
            wx.MessageBox(T("Please select a backup location"), T("Error"), wx.OK | wx.ICON_ERROR)
            return

        # Get database directory
        from tools import get_app_path
        database_dir = get_app_path() / "Database"

        if not database_dir.exists():
            wx.MessageBox(T("Database folder not found"), T("Error"), wx.OK | wx.ICON_ERROR)
            return

        try:
            # Create backup directory
            backup_name = f"backup_{date.today().strftime('%Y%m%d_%H%M%S')}"
            backup_dir = backup_path / backup_name
            backup_dir.mkdir(parents=True, exist_ok=True)

            # Copy files
            files = list(database_dir.glob("*.dat"))
            total = len(files)

            for i, filepath in enumerate(files):
                shutil.copy2(filepath, backup_dir / filepath.name)
                self.progress_bar.SetValue(int((i + 1) / total * 100))
                self.status_text.SetLabel(f"Copying {filepath.name}... ({i + 1}/{total})")
                wx.Yield()

            wx.MessageBox(
                f"{T('Backup completed successfully')}!\n\n" +
                f"{T('Location')}: {backup_dir}\n" +
                f"{T('Files backed up')}: {total}",
                T("Success"),
                wx.OK | wx.ICON_INFORMATION
            )
            self.EndModal(wx.ID_OK)

        except Exception as e:
            wx.MessageBox(f"{T('Backup failed')}: {e}", T("Error"), wx.OK | wx.ICON_ERROR)

    def _on_cancel(self, event):
        """Cancel the dialog."""
        self.EndModal(wx.ID_CANCEL)


class SettingsDialog(wx.Dialog):
    """Dialog for application settings."""

    def __init__(self, parent):
        super().__init__(parent, title=T("Settings"), size=(500, 400))

        panel = wx.Panel(self)
        main_sizer = wx.BoxSizer(wx.VERTICAL)

        # Application title
        title_sizer = wx.BoxSizer(wx.HORIZONTAL)
        title_sizer.Add(wx.StaticText(panel, label=T("Application title") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.title_text = wx.TextCtrl(panel)
        title_sizer.Add(self.title_text, 1, wx.EXPAND | wx.ALL, 2)
        main_sizer.Add(title_sizer, 0, wx.EXPAND | wx.ALL, 5)

        # Working hours
        hours_label = wx.StaticText(panel, label=T("Working hours") + ":")
        main_sizer.Add(hours_label, 0, wx.ALL, 5)

        hours_sizer = wx.BoxSizer(wx.HORIZONTAL)

        start_sizer = wx.BoxSizer(wx.HORIZONTAL)
        start_sizer.Add(wx.StaticText(panel, label=T("Start") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.start_hour = wx.ComboBox(
            panel,
            choices=[f"{h:02d}" for h in range(24)],
            value="09",
            size=(60, -1)
        )
        start_sizer.Add(self.start_hour, 0, wx.ALL, 2)
        start_sizer.Add(wx.StaticText(panel, label=":"), 0, wx.ALL, 2)
        self.start_min = wx.ComboBox(
            panel,
            choices=["00", "15", "30", "45"],
            value="00",
            size=(50, -1)
        )
        start_sizer.Add(self.start_min, 0, wx.ALL, 2)
        hours_sizer.Add(start_sizer, 0, wx.ALL, 5)

        end_sizer = wx.BoxSizer(wx.HORIZONTAL)
        end_sizer.Add(wx.StaticText(panel, label=T("End") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.end_hour = wx.ComboBox(
            panel,
            choices=[f"{h:02d}" for h in range(24)],
            value="18",
            size=(60, -1)
        )
        end_sizer.Add(self.end_hour, 0, wx.ALL, 2)
        end_sizer.Add(wx.StaticText(panel, label=":"), 0, wx.ALL, 2)
        self.end_min = wx.ComboBox(
            panel,
            choices=["00", "15", "30", "45"],
            value="00",
            size=(50, -1)
        )
        end_sizer.Add(self.end_min, 0, wx.ALL, 2)
        hours_sizer.Add(end_sizer, 0, wx.ALL, 5)

        main_sizer.Add(hours_sizer, 0, wx.ALL, 5)

        # Default appointment duration
        duration_sizer = wx.BoxSizer(wx.HORIZONTAL)
        duration_sizer.Add(wx.StaticText(panel, label=T("Default appointment duration") + " (min):"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.duration_combo = wx.ComboBox(
            panel,
            choices=["15", "30", "45", "60"],
            value="30",
            size=(80, -1)
        )
        duration_sizer.Add(self.duration_combo, 0, wx.ALL, 2)
        main_sizer.Add(duration_sizer, 0, wx.ALL, 5)

        # Buttons
        btn_sizer = wx.BoxSizer(wx.HORIZONTAL)
        self.save_btn = wx.Button(panel, label=T("Save"))
        self.cancel_btn = wx.Button(panel, label=T("Cancel"))

        self.save_btn.Bind(wx.EVT_BUTTON, self._on_save)
        self.cancel_btn.Bind(wx.EVT_BUTTON, self._on_cancel)

        btn_sizer.AddStretchSpacer()
        btn_sizer.Add(self.save_btn, 0, wx.ALL, 5)
        btn_sizer.Add(self.cancel_btn, 0, wx.ALL, 5)
        main_sizer.Add(btn_sizer, 0, wx.ALIGN_RIGHT)

        panel.SetSizer(main_sizer)

        # Load current settings
        from settings import SettingsManager
        self.title_text.SetValue(SettingsManager.get("app_title_gr", "Οδοντιατρική Βάση Δεδομένων MK2"))

    def _on_save(self, event):
        """Save settings."""
        from settings import SettingsManager

        SettingsManager.set("app_title_gr", self.title_text.GetValue())
        SettingsManager.set("work_start_hour", self.start_hour.GetValue())
        SettingsManager.set("work_start_min", self.start_min.GetValue())
        SettingsManager.set("work_end_hour", self.end_hour.GetValue())
        SettingsManager.set("work_end_min", self.end_min.GetValue())
        SettingsManager.set("default_appointment_duration", self.duration_combo.GetValue())

        wx.MessageBox(T("Settings saved successfully"), T("Success"), wx.OK | wx.ICON_INFORMATION)
        self.EndModal(wx.ID_OK)

    def _on_cancel(self, event):
        """Cancel the dialog."""
        self.EndModal(wx.ID_CANCEL)

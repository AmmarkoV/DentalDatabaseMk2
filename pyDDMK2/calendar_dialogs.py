"""
Calendar UI dialogs.
"""
import wx
from datetime import datetime, date, timedelta
from typing import Optional

from calendar import CalendarManager, MONTHS_GR, DAYS_GR
from people import PatientManager
from patients_dialogs import SearchPatientDialog
from translations import translate_en_to_gr as T


class CalendarDialog(wx.Dialog):
    """Main calendar dialog showing monthly view with appointments."""

    def __init__(self, parent):
        super().__init__(parent, title=T("Calendar"), size=(900, 700))

        self.current_date = date.today()
        self.selected_date = None

        panel = wx.Panel(self)
        main_sizer = wx.BoxSizer(wx.VERTICAL)

        # Header with navigation
        header_sizer = wx.BoxSizer(wx.HORIZONTAL)

        self.prev_btn = wx.Button(panel, label="< " + T("Previous"))
        self.next_btn = wx.Button(panel, label=T("Next") + " >")
        self.today_btn = wx.Button(panel, label=T("Today"))

        self.prev_btn.Bind(wx.EVT_BUTTON, self._on_prev_month)
        self.next_btn.Bind(wx.EVT_BUTTON, self._on_next_month)
        self.today_btn.Bind(wx.EVT_BUTTON, self._on_today)

        header_sizer.Add(self.prev_btn, 0, wx.ALL, 5)
        header_sizer.Add(self.next_btn, 0, wx.ALL, 5)
        header_sizer.Add(self.today_btn, 0, wx.ALL, 5)
        header_sizer.AddStretchSpacer()

        self.month_label = wx.StaticText(panel, label="")
        header_sizer.Add(self.month_label, 0, wx.ALIGN_CENTER | wx.ALL, 5)
        header_sizer.AddStretchSpacer()

        main_sizer.Add(header_sizer, 0, wx.EXPAND | wx.ALL, 5)

        # Calendar grid
        self.calendar_grid = wx.GridBagSizer(5, 5)

        # Day headers
        for i, day_name in enumerate(DAYS_GR[1:] + [DAYS_GR[0]]):  # Start with Monday
            day_header = wx.StaticText(panel, label=day_name[:3])
            self.calendar_grid.Add(day_header, (0, i), flag=wx.ALIGN_CENTER | wx.ALL, border=2)

        # Date cells
        self.date_cells = {}
        calendar_data = CalendarManager.get_month_calendar(
            self.current_date.year, self.current_date.month
        )

        row = 1
        for week in calendar_data:
            for col, day_date in enumerate(week):
                if day_date is not None:
                    cell_btn = wx.Button(panel, label="")
                    cell_btn.SetMinSize((40, 40))
                    cell_btn.SetLabel(str(day_date.day))
                    self.date_cells[day_date] = cell_btn
                    cell_btn.Bind(wx.EVT_BUTTON, lambda e, d=day_date: self._on_date_selected(d))
                    self.calendar_grid.Add(cell_btn, (row, col), flag=wx.EXPAND | wx.ALL, border=1)
                row += 1
                if row > 1 and col == 6:
                    row = 1
                    break

        main_sizer.Add(self.calendar_grid, 0, wx.EXPAND | wx.ALL, 5)

        # Appointments list
        wx.StaticLine(panel)
        main_sizer.Add(wx.StaticLine(panel), 0, wx.EXPAND | wx.ALL, 5)

        apt_header = wx.StaticText(panel, label=T("Appointments") + ":")
        main_sizer.Add(apt_header, 0, wx.ALL, 5)

        self.appointments_list = wx.ListCtrl(
            panel,
            style=wx.LC_REPORT | wx.BORDER_SUNKEN
        )
        self.appointments_list.InsertColumn(0, T("Time"), width=80)
        self.appointments_list.InsertColumn(1, T("Patient"), width=250)
        self.appointments_list.InsertColumn(2, T("Type"), width=150)
        self.appointments_list.InsertColumn(3, T("Status"), width=100)

        main_sizer.Add(self.appointments_list, 1, wx.EXPAND | wx.ALL, 5)

        # Buttons
        btn_sizer = wx.BoxSizer(wx.HORIZONTAL)
        self.new_apt_btn = wx.Button(panel, label=T("New Appointment"))
        self.close_btn = wx.Button(panel, label=T("Close"))

        self.new_apt_btn.Bind(wx.EVT_BUTTON, self._on_new_appointment)
        self.close_btn.Bind(wx.EVT_BUTTON, self._on_close)

        btn_sizer.AddStretchSpacer()
        btn_sizer.Add(self.new_apt_btn, 0, wx.ALL, 5)
        btn_sizer.Add(self.close_btn, 0, wx.ALL, 5)
        main_sizer.Add(btn_sizer, 0, wx.ALIGN_RIGHT)

        panel.SetSizer(main_sizer)

        self._update_calendar_display()
        self._highlight_today()

    def _update_calendar_display(self):
        """Update the calendar display for current month."""
        month_name = MONTHS_GR[self.current_date.month]
        self.month_label.SetLabel(f"{month_name} {self.current_date.year}")

        # Clear existing date cells
        for cell in self.date_cells.values():
            cell.Destroy()
        self.date_cells = {}

        # Create new calendar grid
        grid_sizer = wx.GridBagSizer(5, 5)

        # Day headers
        for i, day_name in enumerate(DAYS_GR[1:] + [DAYS_GR[0]]):
            day_header = wx.StaticText(self.appointments_list.GetParent(), label=day_name[:3])
            grid_sizer.Add(day_header, (0, i), flag=wx.ALIGN_CENTER | wx.ALL, border=2)

        # Date cells
        calendar_data = CalendarManager.get_month_calendar(
            self.current_date.year, self.current_date.month
        )

        row = 1
        for week in calendar_data:
            for col, day_date in enumerate(week):
                if day_date is not None:
                    cell_btn = wx.Button(self.appointments_list.GetParent(), label="")
                    cell_btn.SetMinSize((40, 40))
                    cell_btn.SetLabel(str(day_date.day))
                    self.date_cells[day_date] = cell_btn
                    cell_btn.Bind(wx.EVT_BUTTON, lambda e, d=day_date: self._on_date_selected(d))
                    grid_sizer.Add(cell_btn, (row, col), flag=wx.EXPAND | wx.ALL, border=1)
                row += 1
                if row > 1 and col == 6:
                    row = 1
                    break

        self.calendar_grid.Replace(self.calendar_grid.GetItems()[0], grid_sizer)
        self._highlight_today()

    def _highlight_today(self):
        """Highlight today's date and appointments."""
        today = date.today()
        for day_date, cell in self.date_cells.items():
            if day_date == today:
                cell.SetBackgroundColour("#FFD700")  # Gold
            elif CalendarManager.is_weekend(day_date):
                cell.SetBackgroundColour("#FFE4E1")  # Light pink
            else:
                cell.SetBackgroundColour(wx.Colour(255, 255, 255))

            # Check if day has appointments
            appointments = CalendarManager.get_appointments_by_date(day_date)
            if appointments:
                cell.SetLabel(f"{day_date.day}\u2022")  # Add bullet for appointments

        self.Refresh()

    def _on_prev_month(self, event):
        """Go to previous month."""
        if self.current_date.month == 1:
            self.current_date = date(self.current_date.year - 1, 12, 1)
        else:
            self.current_date = date(self.current_date.year, self.current_date.month - 1, 1)
        self._update_calendar_display()

    def _on_next_month(self, event):
        """Go to next month."""
        if self.current_date.month == 12:
            self.current_date = date(self.current_date.year + 1, 1, 1)
        else:
            self.current_date = date(self.current_date.year, self.current_date.month + 1, 1)
        self._update_calendar_display()

    def _on_today(self, event):
        """Jump to today's date."""
        self.current_date = date.today()
        self._update_calendar_display()

    def _on_date_selected(self, day_date: date):
        """Handle date cell selection."""
        self.selected_date = day_date
        self._show_appointments_for_date(day_date)

    def _show_appointments_for_date(self, day_date: date):
        """Show appointments for selected date."""
        self.appointments_list.DeleteAllItems()
        appointments = CalendarManager.get_appointments_by_date(day_date)

        for i, apt in enumerate(appointments):
            patient = PatientManager.get_patient(apt.patient_code)
            patient_name = f"{patient.surname} {patient.name}" if patient else apt.patient_code

            self.appointments_list.InsertItem(i, apt.date_time.strftime("%H:%M"))
            self.appointments_list.SetItem(i, 1, patient_name)
            self.appointments_list.SetItem(i, 2, apt.appointment_type)
            self.appointments_list.SetItem(i, 3, apt.status)

    def _on_new_appointment(self, event):
        """Open new appointment dialog."""
        if not self.selected_date:
            wx.MessageBox(T("Please select a date first"), T("Error"), wx.OK | wx.ICON_ERROR)
            return

        dialog = NewAppointmentDialog(self, self.selected_date)
        if dialog.ShowModal() == wx.ID_OK:
            self._show_appointments_for_date(self.selected_date)
        dialog.Destroy()

    def _on_close(self, event):
        """Close the calendar dialog."""
        self.EndModal(wx.ID_OK)


class NewAppointmentDialog(wx.Dialog):
    """Dialog for creating a new appointment."""

    def __init__(self, parent, selected_date: date = None):
        super().__init__(parent, title=T("New Appointment"), size=(500, 450))

        self.selected_date = selected_date or date.today()
        self.selected_patient_code = None

        panel = wx.Panel(self)
        main_sizer = wx.BoxSizer(wx.VERTICAL)

        # Date selection
        date_sizer = wx.BoxSizer(wx.HORIZONTAL)
        date_sizer.Add(wx.StaticText(panel, label=T("Date") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.date_picker = wx.DatePickerCtrl(
            panel,
            value=self.selected_date,
            style=wx.DP_DROPDOWNCLASSIC | wx.DP_SHOWLABEL
        )
        date_sizer.Add(self.date_picker, 1, wx.EXPAND)
        main_sizer.Add(date_sizer, 0, wx.EXPAND | wx.ALL, 5)

        # Time selection
        time_sizer = wx.BoxSizer(wx.HORIZONTAL)
        time_sizer.Add(wx.StaticText(panel, label=T("Time") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.hour_combo = wx.ComboBox(
            panel,
            choices=[f"{h:02d}" for h in range(8, 21)],
            value="09",
            size=(60, -1)
        )
        time_sizer.Add(self.hour_combo, 0, wx.ALL, 2)
        time_sizer.Add(wx.StaticText(panel, label=":"), 0, wx.ALL, 2)
        self.minute_combo = wx.ComboBox(
            panel,
            choices=[f"{m:02d}" for m in range(0, 60, 5)],
            value="00",
            size=(60, -1)
        )
        time_sizer.Add(self.minute_combo, 0, wx.ALL, 2)
        main_sizer.Add(time_sizer, 0, wx.EXPAND | wx.ALL, 5)

        # Patient selection
        patient_sizer = wx.BoxSizer(wx.HORIZONTAL)
        patient_sizer.Add(wx.StaticText(panel, label=T("Patient") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.patient_text = wx.TextCtrl(panel)
        self.patient_text.Bind(wx.EVT_TEXT, self._on_patient_search)
        patient_sizer.Add(self.patient_text, 1, wx.EXPAND)
        self.patient_btn = wx.Button(panel, label="...")
        self.patient_btn.Bind(wx.EVT_BUTTON, self._on_select_patient)
        patient_sizer.Add(self.patient_btn, 0, wx.ALL, 2)
        main_sizer.Add(patient_sizer, 0, wx.EXPAND | wx.ALL, 5)

        # Appointment type
        type_sizer = wx.BoxSizer(wx.HORIZONTAL)
        type_sizer.Add(wx.StaticText(panel, label=T("Type") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.type_combo = wx.ComboBox(
            panel,
            choices=["consultation", "checkup", "treatment", "surgery", "cleaning", "other"],
            value="consultation",
            style=wx.CB_DROPDOWN
        )
        type_sizer.Add(self.type_combo, 1, wx.EXPAND)
        main_sizer.Add(type_sizer, 0, wx.EXPAND | wx.ALL, 5)

        # Duration
        duration_sizer = wx.BoxSizer(wx.HORIZONTAL)
        duration_sizer.Add(wx.StaticText(panel, label=T("Duration") + " (min):"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.duration_combo = wx.ComboBox(
            panel,
            choices=["15", "30", "45", "60", "90", "120"],
            value="30",
            size=(80, -1)
        )
        duration_sizer.Add(self.duration_combo, 0, wx.ALL, 2)
        main_sizer.Add(duration_sizer, 0, wx.ALL, 5)

        # Notes
        notes_sizer = wx.BoxSizer(wx.HORIZONTAL)
        notes_sizer.Add(wx.StaticText(panel, label=T("Notes") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.notes_text = wx.TextCtrl(panel)
        notes_sizer.Add(self.notes_text, 1, wx.EXPAND)
        main_sizer.Add(notes_sizer, 0, wx.EXPAND | wx.ALL, 5)

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

        # Populate patient search results
        self.patient_results = wx.ListCtrl(
            panel,
            size=(-1, 100),
            style=wx.LC_REPORT | wx.LC_SINGLE_SEL | wx.BORDER_SUNKEN
        )
        self.patient_results.InsertColumn(0, T("Code"), width=60)
        self.patient_results.InsertColumn(1, T("Name"), width=200)
        main_sizer.Insert(6, self.patient_results, 0, wx.EXPAND | wx.ALL, 5)

        self.patient_results.Bind(wx.EVT_LIST_ITEM_ACTIVATED, self._on_patient_double_click)

    def _on_patient_search(self, event):
        """Search for patients as user types."""
        query = self.patient_text.GetValue().strip()
        self.patient_results.DeleteAllItems()

        if query:
            patients = PatientManager.search_by_name(query)
            for i, patient in enumerate(patients[:10]):  # Limit to 10 results
                self.patient_results.InsertItem(i, patient.code)
                self.patient_results.SetItem(i, 1, f"{patient.surname} {patient.name}")

    def _on_select_patient(self, event):
        """Open patient selection dialog."""
        dialog = SearchPatientDialog(self)
        if dialog.ShowModal() == wx.ID_OK:
            patient = dialog.get_selected_patient()
            if patient:
                self.selected_patient_code = patient.code
                self.patient_text.SetValue(f"{patient.surname} {patient.name}")
        dialog.Destroy()

    def _on_patient_double_click(self, event):
        """Handle double-click on patient search result."""
        selection = self.patient_results.GetFirstSelected()
        if selection != -1:
            code = self.patient_results.GetItem(selection, 0).GetText()
            patient = PatientManager.get_patient(code)
            if patient:
                self.selected_patient_code = patient.code
                self.patient_text.SetValue(f"{patient.surname} {patient.name}")

    def _on_save(self, event):
        """Save the new appointment."""
        if not self.selected_patient_code:
            wx.MessageBox(T("Please select a patient"), T("Error"), wx.OK | wx.ICON_ERROR)
            return

        # Parse date and time
        selected_date = self.date_picker.GetValue()
        py_date = date(selected_date.GetYear(), selected_date.GetMonth() + 1, selected_date.GetDay())
        hour = int(self.hour_combo.GetValue())
        minute = int(self.minute_combo.GetValue())
        date_time = datetime(py_date.year, py_date.month, py_date.day, hour, minute)

        duration = int(self.duration_combo.GetValue())
        apt_type = self.type_combo.GetValue()
        notes = self.notes_text.GetValue().strip()

        # Check for conflicts
        if CalendarManager.has_conflict(date_time, duration):
            if not wx.MessageBoxYesNo(
                T("There is a scheduling conflict. Continue anyway?"),
                T("Conflict"),
                wx.YES_NO | wx.ICON_WARNING
            ):
                return

        # Create appointment
        appointment = CalendarManager.create_appointment(
            patient_code=self.selected_patient_code,
            date_time=date_time,
            duration_minutes=duration,
            appointment_type=apt_type,
            notes=notes
        )

        if appointment:
            wx.MessageBox(T("Appointment created successfully"), T("Success"), wx.OK | wx.ICON_INFORMATION)
            self.new_appointment = appointment
            self.EndModal(wx.ID_OK)
        else:
            wx.MessageBox(T("Failed to create appointment"), T("Error"), wx.OK | wx.ICON_ERROR)

    def _on_cancel(self, event):
        """Cancel the dialog."""
        self.EndModal(wx.ID_CANCEL)

    def get_appointment(self):
        """Get the created appointment."""
        return getattr(self, 'new_appointment', None)


class AppointmentListDialog(wx.Dialog):
    """Dialog showing list of appointments with filters."""

    def __init__(self, parent):
        super().__init__(parent, title=T("Appointments"), size=(700, 500))

        panel = wx.Panel(self)
        main_sizer = wx.BoxSizer(wx.VERTICAL)

        # Filter options
        filter_sizer = wx.BoxSizer(wx.HORIZONTAL)
        filter_sizer.Add(wx.StaticText(panel, label=T("From") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.from_picker = wx.DatePickerCtrl(panel, value=date.today() - timedelta(days=7))
        filter_sizer.Add(self.from_picker, 0, wx.ALL, 2)

        filter_sizer.Add(wx.StaticText(panel, label=T("To") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.to_picker = wx.DatePickerCtrl(panel, value=date.today() + timedelta(days=7))
        filter_sizer.Add(self.to_picker, 0, wx.ALL, 2)

        self.filter_btn = wx.Button(panel, label=T("Filter"))
        self.filter_btn.Bind(wx.EVT_BUTTON, self._on_filter)
        filter_sizer.Add(self.filter_btn, 0, wx.ALL, 5)

        main_sizer.Add(filter_sizer, 0, wx.EXPAND | wx.ALL, 5)

        # Appointments list
        self.appointments_list = wx.ListCtrl(
            panel,
            style=wx.LC_REPORT | wx.BORDER_SUNKEN
        )
        self.appointments_list.InsertColumn(0, T("Date"), width=100)
        self.appointments_list.InsertColumn(1, T("Time"), width=70)
        self.appointments_list.InsertColumn(2, T("Patient"), width=200)
        self.appointments_list.InsertColumn(3, T("Type"), width=120)
        self.appointments_list.InsertColumn(4, T("Status"), width=100)

        main_sizer.Add(self.appointments_list, 1, wx.EXPAND | wx.ALL, 5)

        # Buttons
        btn_sizer = wx.BoxSizer(wx.HORIZONTAL)
        self.close_btn = wx.Button(panel, label=T("Close"))
        self.close_btn.Bind(wx.EVT_BUTTON, self._on_close)
        btn_sizer.AddStretchSpacer()
        btn_sizer.Add(self.close_btn, 0, wx.ALL, 5)
        main_sizer.Add(btn_sizer, 0, wx.ALIGN_RIGHT)

        panel.SetSizer(main_sizer)

        self._refresh_list()

    def _refresh_list(self):
        """Refresh the appointments list."""
        self.appointments_list.DeleteAllItems()

        from_date = date(
            self.from_picker.GetValue().GetYear(),
            self.from_picker.GetValue().GetMonth() + 1,
            self.from_picker.GetValue().GetDay()
        )
        to_date = date(
            self.to_picker.GetValue().GetYear(),
            self.to_picker.GetValue().GetMonth() + 1,
            self.to_picker.GetValue().GetDay()
        )

        appointments = []
        current_date = from_date
        while current_date <= to_date:
            appointments.extend(CalendarManager.get_appointments_by_date(current_date))
            current_date += timedelta(days=1)

        for i, apt in enumerate(sorted(appointments, key=lambda a: a.date_time)):
            patient = PatientManager.get_patient(apt.patient_code)
            patient_name = f"{patient.surname} {patient.name}" if patient else apt.patient_code

            self.appointments_list.InsertItem(i, apt.date_time.strftime("%Y-%m-%d"))
            self.appointments_list.SetItem(i, 1, apt.date_time.strftime("%H:%M"))
            self.appointments_list.SetItem(i, 2, patient_name)
            self.appointments_list.SetItem(i, 3, apt.appointment_type)
            self.appointments_list.SetItem(i, 4, apt.status)

    def _on_filter(self, event):
        """Apply filter and refresh list."""
        self._refresh_list()

    def _on_close(self, event):
        """Close the dialog."""
        self.EndModal(wx.ID_OK)

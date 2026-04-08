#!/usr/bin/env python3
"""
Patient management dialogs.
"""
import wx
from datetime import datetime
from typing import Optional, List

from people import PatientManager, Patient
from works_parser import WorksParser
from teeth import TeethManager
from translations import translate_en_to_gr as T


class SearchPatientDialog(wx.Dialog):
    """Dialog for searching patients."""

    def __init__(self, parent):
        super().__init__(parent, title=T("Search Patient"), size=(500, 350))

        # Search field
        panel = wx.Panel(self)
        sizer = wx.BoxSizer(wx.VERTICAL)

        label = wx.StaticText(panel, label=T("Search") + ":")
        self.search_text = wx.TextCtrl(panel)
        self.search_text.Bind(wx.EVT_TEXT, self._on_search)

        search_sizer = wx.BoxSizer(wx.HORIZONTAL)
        search_sizer.Add(label, 0, wx.ALL | wx.ALIGN_CENTER_VERTICAL, 5)
        search_sizer.Add(self.search_text, 1, wx.EXPAND | wx.ALL, 5)
        sizer.Add(search_sizer, 0, wx.EXPAND)

        # Results list
        self.results_list = wx.ListCtrl(
            panel,
            style=wx.LC_REPORT | wx.LC_SINGLE_SEL | wx.BORDER_SUNKEN
        )
        self.results_list.InsertColumn(0, T("Code"), width=80)
        self.results_list.InsertColumn(1, T("Surname"), width=150)
        self.results_list.InsertColumn(2, T("Name"), width=150)
        self.results_list.InsertColumn(3, T("Telephone"), width=120)

        # Bind double-click to open patient
        self.results_list.Bind(wx.EVT_LIST_ITEM_ACTIVATED, self._on_double_click)

        sizer.Add(self.results_list, 1, wx.EXPAND | wx.ALL, 5)

        # Buttons
        btn_sizer = wx.BoxSizer(wx.HORIZONTAL)
        self.open_btn = wx.Button(panel, label=T("Open"))
        self.close_btn = wx.Button(panel, label=T("Close"))

        self.open_btn.Bind(wx.EVT_BUTTON, self._on_open)
        self.close_btn.Bind(wx.EVT_BUTTON, self._on_close)

        btn_sizer.AddStretchSpacer()
        btn_sizer.Add(self.open_btn, 0, wx.ALL, 5)
        btn_sizer.Add(self.close_btn, 0, wx.ALL, 5)
        sizer.Add(btn_sizer, 0, wx.ALIGN_RIGHT)

        panel.SetSizer(sizer)

        # Initial search (show all)
        self._refresh_results()

    def _on_search(self, event):
        self._refresh_results()

    def _refresh_results(self):
        query = self.search_text.GetValue().strip()
        patients = PatientManager.search_by_name(query) if query else PatientManager.get_all_patients()

        self.results_list.DeleteAllItems()
        for i, patient in enumerate(patients):
            self.results_list.InsertItem(i, patient.code)
            self.results_list.SetItem(i, 1, patient.surname)
            self.results_list.SetItem(i, 2, patient.name)
            self.results_list.SetItem(i, 3, patient.telephone)

    def _on_open(self, event):
        selection = self.results_list.GetFirstSelected()
        if selection == -1:
            wx.MessageBox(T("Please select a patient"), T("Error"), wx.OK | wx.ICON_ERROR)
            return

        # Get the selected item's data
        item = self.results_list.GetItem(selection, 0)
        code = item.GetText()

        # Fetch the full patient object
        patient = PatientManager.get_patient(code)
        if patient:
            self.selected_patient = patient
            self.EndModal(wx.ID_OK)
        else:
            wx.MessageBox(T("Patient not found"), T("Error"), wx.OK | wx.ICON_ERROR)

    def _on_double_click(self, event):
        """Handle double-click on list item."""
        self._on_open(event)

    def _on_close(self, event):
        self.EndModal(wx.ID_CANCEL)

    def get_selected_patient(self) -> Optional[Patient]:
        return getattr(self, 'selected_patient', None)


class NewPatientDialog(wx.Dialog):
    """Dialog for creating a new patient."""

    def __init__(self, parent):
        super().__init__(parent, title=T("New Patient"), size=(600, 550))

        panel = wx.Panel(self)
        main_sizer = wx.BoxSizer(wx.VERTICAL)

        # Create grid sizer for form
        grid_sizer = wx.FlexGridSizer(8, 3, 5, 10)

        # Row 1: Surname
        grid_sizer.Add(wx.StaticText(panel, label=T("Surname") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.surname_text = wx.TextCtrl(panel)
        grid_sizer.Add(self.surname_text, 1, wx.EXPAND)

        # Row 2: Name
        grid_sizer.Add(wx.StaticText(panel, label=T("Name") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.name_text = wx.TextCtrl(panel)
        grid_sizer.Add(self.name_text, 1, wx.EXPAND)

        # Row 3: Father Name
        grid_sizer.Add(wx.StaticText(panel, label=T("Father") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.father_text = wx.TextCtrl(panel)
        grid_sizer.Add(self.father_text, 1, wx.EXPAND)

        # Row 4: Area
        grid_sizer.Add(wx.StaticText(panel, label=T("Area") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.area_text = wx.TextCtrl(panel)
        grid_sizer.Add(self.area_text, 1, wx.EXPAND)

        # Row 5: Telephone
        grid_sizer.Add(wx.StaticText(panel, label=T("Telephone") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.telephone_text = wx.TextCtrl(panel)
        grid_sizer.Add(self.telephone_text, 1, wx.EXPAND)

        # Row 6: Cell Phone
        grid_sizer.Add(wx.StaticText(panel, label=T("Cell Phone") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.cell_text = wx.TextCtrl(panel)
        grid_sizer.Add(self.cell_text, 1, wx.EXPAND)

        # Row 7: Address
        grid_sizer.Add(wx.StaticText(panel, label=T("Address") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.address_text = wx.TextCtrl(panel)
        grid_sizer.Add(self.address_text, 1, wx.EXPAND)

        # Row 8: Profession
        grid_sizer.Add(wx.StaticText(panel, label=T("Profession") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.profession_text = wx.TextCtrl(panel)
        grid_sizer.Add(self.profession_text, 1, wx.EXPAND)

        main_sizer.Add(grid_sizer, 0, wx.EXPAND | wx.ALL, 10)

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

        # Focus on surname
        self.surname_text.SetFocus()

    def _on_save(self, event):
        surname = self.surname_text.GetValue().strip()
        name = self.name_text.GetValue().strip()

        if not surname or not name:
            wx.MessageBox(T("Please enter surname and name"), T("Error"), wx.OK | wx.ICON_ERROR)
            return

        patient = PatientManager.create_patient(
            surname=surname,
            name=name,
            father_name=self.father_text.GetValue().strip(),
            area=self.area_text.GetValue().strip(),
            telephone=self.telephone_text.GetValue().strip(),
            cell_phone=self.cell_text.GetValue().strip(),
            address=self.address_text.GetValue().strip(),
            profession=self.profession_text.GetValue().strip()
        )

        if patient:
            wx.MessageBox(
                f"{T('Patient created successfully')}\n{T('Code')}: {patient.code}",
                T("Success"),
                wx.OK | wx.ICON_INFORMATION
            )
            self.new_patient = patient
            self.EndModal(wx.ID_OK)
        else:
            wx.MessageBox(T("Failed to create patient"), T("Error"), wx.OK | wx.ICON_ERROR)

    def _on_cancel(self, event):
        self.EndModal(wx.ID_CANCEL)

    def get_new_patient(self) -> Optional[Patient]:
        return getattr(self, 'new_patient', None)


class OpenPatientDialog(wx.Dialog):
    """Dialog for opening/editing a patient with tabs for works, teeth, and payments."""

    def __init__(self, parent, patient: Patient):
        super().__init__(parent, title=f"{T('Patient')}: {patient.surname} {patient.name}", size=(700, 600))
        self.patient = patient

        panel = wx.Panel(self)
        main_sizer = wx.BoxSizer(wx.VERTICAL)

        # Patient code display
        code_sizer = wx.BoxSizer(wx.HORIZONTAL)
        code_sizer.Add(wx.StaticText(panel, label=f"{T('Code')}: "), 0, wx.ALIGN_CENTER_VERTICAL)
        code_sizer.Add(wx.StaticText(panel, label=patient.code), 0, wx.ALIGN_CENTER_VERTICAL | wx.ALL, 5)
        main_sizer.Add(code_sizer, 0, wx.ALL, 5)

        main_sizer.Add(wx.StaticLine(panel), 0, wx.EXPAND | wx.ALL, 2)

        # Notebook with tabs
        self.notebook = wx.Notebook(panel)

        # Tab 1: Personal Data
        self._create_personal_tab(self.notebook)

        # Tab 2: Works/History
        self._create_works_tab(self.notebook)

        # Tab 3: Teeth
        self._create_teeth_tab(self.notebook)

        # Tab 4: Payments
        self._create_payments_tab(self.notebook)

        main_sizer.Add(self.notebook, 1, wx.EXPAND | wx.ALL, 5)

        # Buttons
        btn_sizer = wx.BoxSizer(wx.HORIZONTAL)
        self.save_btn = wx.Button(panel, label=T("Save"))
        self.close_btn = wx.Button(panel, label=T("Close"))

        self.save_btn.Bind(wx.EVT_BUTTON, self._on_save)
        self.close_btn.Bind(wx.EVT_BUTTON, self._on_close)

        btn_sizer.AddStretchSpacer()
        btn_sizer.Add(self.save_btn, 0, wx.ALL, 5)
        btn_sizer.Add(self.close_btn, 0, wx.ALL, 5)
        main_sizer.Add(btn_sizer, 0, wx.ALIGN_RIGHT)

        panel.SetSizer(main_sizer)

    def _create_personal_tab(self, notebook):
        """Create the personal data tab."""
        panel = wx.Panel(notebook)
        main_sizer = wx.BoxSizer(wx.VERTICAL)

        # Create grid sizer for form
        grid_sizer = wx.FlexGridSizer(8, 3, 5, 10)

        # Row 1: Surname
        grid_sizer.Add(wx.StaticText(panel, label=T("Surname") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.surname_text = wx.TextCtrl(panel, value=self.patient.surname)
        grid_sizer.Add(self.surname_text, 1, wx.EXPAND)

        # Row 2: Name
        grid_sizer.Add(wx.StaticText(panel, label=T("Name") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.name_text = wx.TextCtrl(panel, value=self.patient.name)
        grid_sizer.Add(self.name_text, 1, wx.EXPAND)

        # Row 3: Father Name
        grid_sizer.Add(wx.StaticText(panel, label=T("Father") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.father_text = wx.TextCtrl(panel, value=self.patient.father_name)
        grid_sizer.Add(self.father_text, 1, wx.EXPAND)

        # Row 4: Area
        grid_sizer.Add(wx.StaticText(panel, label=T("Area") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.area_text = wx.TextCtrl(panel, value=self.patient.area)
        grid_sizer.Add(self.area_text, 1, wx.EXPAND)

        # Row 5: Telephone
        grid_sizer.Add(wx.StaticText(panel, label=T("Telephone") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.telephone_text = wx.TextCtrl(panel, value=self.patient.telephone)
        grid_sizer.Add(self.telephone_text, 1, wx.EXPAND)

        # Row 6: Cell Phone
        grid_sizer.Add(wx.StaticText(panel, label=T("Cell Phone") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.cell_text = wx.TextCtrl(panel, value=self.patient.cell_phone)
        grid_sizer.Add(self.cell_text, 1, wx.EXPAND)

        # Row 7: Address
        grid_sizer.Add(wx.StaticText(panel, label=T("Address") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.address_text = wx.TextCtrl(panel, value=self.patient.address)
        grid_sizer.Add(self.address_text, 1, wx.EXPAND)

        # Row 8: Profession
        grid_sizer.Add(wx.StaticText(panel, label=T("Profession") + ":"), 0, wx.ALIGN_CENTER_VERTICAL)
        self.profession_text = wx.TextCtrl(panel, value=self.patient.profession)
        grid_sizer.Add(self.profession_text, 1, wx.EXPAND)

        main_sizer.Add(grid_sizer, 0, wx.EXPAND | wx.ALL, 10)
        panel.SetSizer(main_sizer)

        notebook.AddPage(panel, T("Personal Data"))

    def _create_works_tab(self, notebook):
        """Create the works/history tab."""
        panel = wx.Panel(notebook)
        main_sizer = wx.BoxSizer(wx.VERTICAL)

        # Works list
        self.works_list = wx.ListCtrl(
            panel,
            style=wx.LC_REPORT | wx.LC_SINGLE_SEL | wx.BORDER_SUNKEN
        )
        self.works_list.InsertColumn(0, T("Work ID"), width=80)
        self.works_list.InsertColumn(1, T("Description"), width=200)
        self.works_list.InsertColumn(2, T("Price"), width=80)
        self.works_list.InsertColumn(3, T("Paid"), width=80)
        self.works_list.InsertColumn(4, T("Outstanding"), width=80)
        self.works_list.InsertColumn(5, T("Date"), width=100)

        main_sizer.Add(self.works_list, 1, wx.EXPAND | wx.ALL, 5)

        # Summary
        summary_sizer = wx.BoxSizer(wx.HORIZONTAL)
        summary_sizer.Add(wx.StaticText(panel, label=T("Total Price") + ":"), 0, wx.ALIGN_CENTER_VERTICAL | wx.ALL, 5)
        self.total_price_label = wx.StaticText(panel, label="0.00")
        summary_sizer.Add(self.total_price_label, 0, wx.ALIGN_CENTER_VERTICAL | wx.ALL, 5)

        summary_sizer.Add(wx.StaticText(panel, label=T("Total Paid") + ":"), 0, wx.ALIGN_CENTER_VERTICAL | wx.ALL, 5)
        self.total_paid_label = wx.StaticText(panel, label="0.00")
        summary_sizer.Add(self.total_paid_label, 0, wx.ALIGN_CENTER_VERTICAL | wx.ALL, 5)

        summary_sizer.Add(wx.StaticText(panel, label=T("Outstanding") + ":"), 0, wx.ALIGN_CENTER_VERTICAL | wx.ALL, 5)
        self.outstanding_label = wx.StaticText(panel, label="0.00")
        summary_sizer.Add(self.outstanding_label, 0, wx.ALIGN_CENTER_VERTICAL | wx.ALL, 5)

        summary_sizer.AddStretchSpacer()
        main_sizer.Add(summary_sizer, 0, wx.EXPAND)

        panel.SetSizer(main_sizer)
        notebook.AddPage(panel, T("Works/History"))

        # Load works
        self._load_works()

    def _load_works(self):
        """Load works from patient data."""
        # Get raw data from patient's .dat file
        data = PatientManager._read_dat_file(PatientManager.get_patient_filepath(self.patient.code))
        works = WorksParser.parse_works_from_data(data)

        self.works_list.DeleteAllItems()

        total_price = 0.0
        total_paid = 0.0

        for i, work in enumerate(works):
            self.works_list.InsertItem(i, work.work_id)
            self.works_list.SetItem(i, 1, work.comments if work.comments else work.work_id)
            self.works_list.SetItem(i, 2, f"{work.price:.2f}")
            self.works_list.SetItem(i, 3, f"{work.paid:.2f}")
            self.works_list.SetItem(i, 4, f"{work.outstanding:.2f}")

            # Format date
            if work.year and work.month and work.day:
                date_str = f"{work.day:02d}/{work.month:02d}/{work.year}"
            else:
                date_str = ""
            self.works_list.SetItem(i, 5, date_str)

            total_price += work.price
            total_paid += work.paid

        self.total_price_label.SetLabel(f"{total_price:.2f}")
        self.total_paid_label.SetLabel(f"{total_paid:.2f}")
        self.outstanding_label.SetLabel(f"{total_price - total_paid:.2f}")

    def _create_teeth_tab(self, notebook):
        """Create the teeth diagram tab."""
        panel = wx.Panel(notebook)
        main_sizer = wx.BoxSizer(wx.VERTICAL)

        # Teeth diagram
        self._create_teeth_diagram(panel, main_sizer)

        # Selected tooth info
        info_sizer = wx.BoxSizer(wx.VERTICAL)
        self.tooth_info_label = wx.StaticText(panel, label="Click a tooth to see details")
        info_sizer.Add(self.tooth_info_label, 0, wx.ALL, 5)

        self.tooth_details_text = wx.TextCtrl(
            panel,
            style=wx.TE_MULTILINE | wx.TE_READONLY,
            size=(-1, 120)
        )
        info_sizer.Add(self.tooth_details_text, 1, wx.EXPAND | wx.ALL, 5)

        main_sizer.Add(info_sizer, 0, wx.EXPAND)

        panel.SetSizer(main_sizer)
        notebook.AddPage(panel, T("Teeth"))

    def _create_teeth_diagram(self, parent, parent_sizer):
        """Create the teeth diagram buttons."""
        diagram_sizer = wx.BoxSizer(wx.VERTICAL)

        # Upper jaw
        upper_sizer = wx.BoxSizer(wx.HORIZONTAL)

        # Upper right (18-11)
        for tooth_num in [18, 17, 16, 15, 14, 13, 12, 11]:
            btn = self._create_tooth_button(parent, tooth_num)
            upper_sizer.Add(btn, 0, wx.ALL | wx.ALIGN_CENTER, 2)

        # Upper left (21-28)
        for tooth_num in [21, 22, 23, 24, 25, 26, 27, 28]:
            btn = self._create_tooth_button(parent, tooth_num)
            upper_sizer.Add(btn, 0, wx.ALL | wx.ALIGN_CENTER, 2)

        diagram_sizer.Add(upper_sizer, 0, wx.ALIGN_CENTER)

        # Separator
        diagram_sizer.Add(wx.StaticLine(parent), 0, wx.EXPAND | wx.ALL, 5)

        # Lower jaw
        lower_sizer = wx.BoxSizer(wx.HORIZONTAL)

        # Lower right (48-41) - reversed for display
        for tooth_num in [48, 47, 46, 45, 44, 43, 42, 41]:
            btn = self._create_tooth_button(parent, tooth_num)
            lower_sizer.Add(btn, 0, wx.ALL | wx.ALIGN_CENTER, 2)

        # Lower left (31-38)
        for tooth_num in [31, 32, 33, 34, 35, 36, 37, 38]:
            btn = self._create_tooth_button(parent, tooth_num)
            lower_sizer.Add(btn, 0, wx.ALL | wx.ALIGN_CENTER, 2)

        diagram_sizer.Add(lower_sizer, 0, wx.ALIGN_CENTER)

        parent_sizer.Add(diagram_sizer, 0, wx.ALIGN_CENTER | wx.ALL, 10)

    def _create_tooth_button(self, parent, tooth_num: int) -> wx.Button:
        """Create a button for a tooth."""
        btn = wx.Button(parent, label=str(tooth_num), size=(35, 30))
        btn.Bind(wx.EVT_BUTTON, lambda e, t=tooth_num: self._on_tooth_click(t))

        # Load teeth data and style accordingly
        aux_list, data_list = TeethManager.get_patient_teeth(self.patient.code)
        aux = TeethManager.get_tooth_aux(tooth_num, aux_list)
        if aux:
            self._style_tooth_for_aux(btn, aux.aux_code)

        return btn

    def _style_tooth_for_aux(self, btn: wx.Button, aux_code: str):
        """Apply visual style based on auxiliary code."""
        aux_upper = aux_code.upper()

        if aux_upper == 'VIDA':  # Crown
            btn.SetBackgroundColour(wx.Colour(200, 200, 200))
        elif aux_upper == 'X' or aux_upper == 'O.O.' or aux_upper == 'M.O.':  # Missing/Extracted
            btn.SetBackgroundColour(wx.Colour(180, 180, 180))
            btn.SetLabel('X')
        elif aux_upper == 'SEALANT':  # Sealant
            btn.SetBackgroundColour(wx.Colour(150, 200, 150))
        elif 'RIZA' in aux_upper or 'ENDODONTIKI' in aux_upper:  # Root canal
            btn.SetBackgroundColour(wx.Colour(255, 200, 150))

    def _on_tooth_click(self, tooth_num: int):
        """Handle tooth button click."""
        aux_list, data_list = TeethManager.get_patient_teeth(self.patient.code)

        # Get aux data
        aux = TeethManager.get_tooth_aux(tooth_num, aux_list)

        # Get surface data
        surfaces = TeethManager.get_tooth_surfaces(tooth_num, data_list)

        # Build details text
        lines = [
            f"Tooth: {tooth_num}",
            f"Type: {TeethManager.get_tooth_type(tooth_num)}",
            f"Quadrant: {TeethManager.get_quadrant(tooth_num)}",
            ""
        ]

        if aux:
            desc = TeethManager.get_aux_description(aux.aux_code)
            lines.append(f"Status: {aux.aux_code} ({desc})")
        else:
            lines.append("Status: Healthy")

        lines.append("")
        lines.append("Surfaces:")

        if surfaces:
            for surface in surfaces:
                surface_name = TeethManager.get_surface_name(surface.part)
                line = f"  {surface_name}:"
                if surface.status:
                    line += f" {surface.status}"
                if surface.work:
                    line += f" [{surface.work}]"
                lines.append(line)
        else:
            lines.append("  No work recorded")

        self.tooth_info_label.SetLabel(f"Details for tooth {tooth_num}")
        self.tooth_details_text.SetValue('\n'.join(lines))

    def _create_payments_tab(self, notebook):
        """Create the payments summary tab."""
        panel = wx.Panel(notebook)
        main_sizer = wx.BoxSizer(wx.VERTICAL)

        # Payments info
        info_text = wx.StaticText(
            panel,
            label=T("Payment information is tracked per work/treatment.\n" +
                    "See the Works/History tab for detailed payment records.")
        )
        main_sizer.Add(info_text, 0, wx.ALL, 10)

        main_sizer.Add(wx.StaticLine(panel), 0, wx.EXPAND | wx.ALL, 5)

        # Summary from works
        summary_sizer = wx.BoxSizer(wx.VERTICAL)

        summary_sizer.Add(wx.StaticText(panel, label=f"{T('Total Price')}: {self.total_price_label.GetLabel()}"), 0, wx.ALL, 5)
        summary_sizer.Add(wx.StaticText(panel, label=f"{T('Total Paid')}: {self.total_paid_label.GetLabel()}"), 0, wx.ALL, 5)
        summary_sizer.Add(wx.StaticText(panel, label=f"{T('Outstanding Balance')}: {self.outstanding_label.GetLabel()}"), 0, wx.ALL, 5)

        main_sizer.Add(summary_sizer, 0, wx.EXPAND | wx.ALL, 10)

        main_sizer.AddStretchSpacer()
        panel.SetSizer(main_sizer)

        notebook.AddPage(panel, T("Payments"))

    def _on_save(self, event):
        success = PatientManager.update_patient(
            code=self.patient.code,
            surname=self.surname_text.GetValue().strip(),
            name=self.name_text.GetValue().strip(),
            father_name=self.father_text.GetValue().strip(),
            area=self.area_text.GetValue().strip(),
            telephone=self.telephone_text.GetValue().strip(),
            cell_phone=self.cell_text.GetValue().strip(),
            address=self.address_text.GetValue().strip(),
            profession=self.profession_text.GetValue().strip()
        )

        if success:
            # Refresh patient data
            self.patient = PatientManager.get_patient(self.patient.code)
            wx.MessageBox(T("Patient updated successfully"), T("Success"), wx.OK | wx.ICON_INFORMATION)
        else:
            wx.MessageBox(T("Failed to update patient"), T("Error"), wx.OK | wx.ICON_ERROR)

    def _on_close(self, event):
        self.EndModal(wx.ID_OK)

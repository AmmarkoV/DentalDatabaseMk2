#!/usr/bin/env python3
"""
Teeth diagram dialog for displaying patient dental status.
"""
import wx
from typing import List, Optional

from teeth import TeethManager, ToothData, ToothAux
from translations import translate_en_to_gr as T


class TeethDiagramPanel(wx.Panel):
    """Panel displaying the teeth diagram."""

    # FDI tooth numbering: quadrants 1-4, teeth 1-8
    # Upper: 11-18 (right), 21-28 (left)
    # Lower: 41-48 (right), 31-38 (left)

    TOOTH_POSITIONS = [
        # Upper jaw
        (18, 17, 16, 15, 14, 13, 12, 11),  # Upper right to midline
        (21, 22, 23, 24, 25, 26, 27, 28),  # Upper midline to left
        # Lower jaw
        (41, 42, 43, 44, 45, 46, 47, 48),  # Lower midline to right
        (31, 32, 33, 34, 35, 36, 37, 38),  # Lower left to midline
    ]

    def __init__(self, parent, patient_code: str):
        super().__init__(parent)
        self.patient_code = patient_code
        self.selected_tooth: Optional[int] = None

        # Load teeth data
        self.aux_list, self.data_list = TeethManager.get_patient_teeth(patient_code)

        self._create_ui()

    def _create_ui(self):
        """Create the teeth diagram UI."""
        main_sizer = wx.BoxSizer(wx.VERTICAL)

        # Teeth diagram area
        diagram_sizer = wx.BoxSizer(wx.VERTICAL)

        # Upper jaw
        upper_sizer = wx.BoxSizer(wx.HORIZONTAL)

        # Upper right (18-11)
        for tooth_num in [18, 17, 16, 15, 14, 13, 12, 11]:
            btn = self._create_tooth_button(self, tooth_num)
            upper_sizer.Add(btn, 0, wx.ALL | wx.ALIGN_CENTER, 2)

        # Upper left (21-28)
        for tooth_num in [21, 22, 23, 24, 25, 26, 27, 28]:
            btn = self._create_tooth_button(self, tooth_num)
            upper_sizer.Add(btn, 0, wx.ALL | wx.ALIGN_CENTER, 2)

        diagram_sizer.Add(upper_sizer, 0, wx.ALIGN_CENTER)

        # Separator
        diagram_sizer.Add(wx.StaticLine(self), 0, wx.EXPAND | wx.ALL, 5)

        # Lower jaw
        lower_sizer = wx.BoxSizer(wx.HORIZONTAL)

        # Lower right (41-48) - reversed for display
        for tooth_num in [48, 47, 46, 45, 44, 43, 42, 41]:
            btn = self._create_tooth_button(self, tooth_num)
            lower_sizer.Add(btn, 0, wx.ALL | wx.ALIGN_CENTER, 2)

        # Lower left (31-38)
        for tooth_num in [31, 32, 33, 34, 35, 36, 37, 38]:
            btn = self._create_tooth_button(self, tooth_num)
            lower_sizer.Add(btn, 0, wx.ALL | wx.ALIGN_CENTER, 2)

        diagram_sizer.Add(lower_sizer, 0, wx.ALIGN_CENTER)

        main_sizer.Add(diagram_sizer, 0, wx.ALIGN_CENTER | wx.ALL, 10)

        # Selected tooth info
        info_sizer = wx.BoxSizer(wx.VERTICAL)
        self.info_label = wx.StaticText(self, label="Click a tooth to see details")
        info_sizer.Add(self.info_label, 0, wx.ALL, 5)

        self.details_text = wx.TextCtrl(
            self,
            style=wx.TE_MULTILINE | wx.TE_READONLY,
            size=(400, 150)
        )
        info_sizer.Add(self.details_text, 1, wx.EXPAND | wx.ALL, 5)

        main_sizer.Add(info_sizer, 1, wx.EXPAND)

        self.SetSizer(main_sizer)

    def _create_tooth_button(self, parent, tooth_num: int) -> wx.Button:
        """Create a button for a tooth."""
        btn = wx.Button(parent, label=str(tooth_num), size=(40, 35))
        btn.Bind(wx.EVT_BUTTON, lambda e, t=tooth_num: self._on_tooth_click(t))

        # Check for aux data and style accordingly
        aux = TeethManager.get_tooth_aux(tooth_num, self.aux_list)
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
        self.selected_tooth = tooth_num
        self._show_tooth_details(tooth_num)

    def _show_tooth_details(self, tooth_num: int):
        """Show details for selected tooth."""
        # Get aux data
        aux = TeethManager.get_tooth_aux(tooth_num, self.aux_list)

        # Get surface data
        surfaces = TeethManager.get_tooth_surfaces(tooth_num, self.data_list)

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

        self.info_label.SetLabel(f"Details for tooth {tooth_num}")
        self.details_text.SetValue('\n'.join(lines))


class TeethDialog(wx.Dialog):
    """Dialog showing teeth diagram for a patient."""

    def __init__(self, parent, patient_code: str):
        super().__init__(parent, title=f"{T('Teeth')}: Patient {patient_code}", size=(550, 500))

        panel = wx.Panel(self)
        main_sizer = wx.BoxSizer(wx.VERTICAL)

        # Teeth diagram panel
        self.teeth_panel = TeethDiagramPanel(panel, patient_code)
        main_sizer.Add(self.teeth_panel, 1, wx.EXPAND)

        # Close button
        btn_sizer = wx.BoxSizer(wx.HORIZONTAL)
        close_btn = wx.Button(panel, label=T("Close"))
        close_btn.Bind(wx.EVT_BUTTON, self._on_close)
        btn_sizer.AddStretchSpacer()
        btn_sizer.Add(close_btn, 0, wx.ALL, 5)
        main_sizer.Add(btn_sizer, 0, wx.ALIGN_RIGHT)

        panel.SetSizer(main_sizer)

    def _on_close(self, event):
        self.EndModal(wx.ID_OK)

"""
Custom GUI framework using wxPython.
Ported from ammargui.pas
"""
import wx
from typing import Optional, Callable, Any
from dataclasses import dataclass
from enum import IntEnum
import sys


class Align(IntEnum):
    """Alignment constants."""
    LEFT = 0
    CENTER = 1
    RIGHT = 2
    TOP = 3
    BOTTOM = 4


class EventType(IntEnum):
    """Event types."""
    NONE = 0
    CLICK = 1
    DOUBLE_CLICK = 2
    KEY_PRESS = 3
    TEXT_CHANGE = 4
    SELECTION_CHANGE = 5


@dataclass
class Point:
    """2D Point."""
    x: int = 0
    y: int = 0


@dataclass
class Size:
    """Size."""
    width: int = 0
    height: int = 0


@dataclass
class Rect:
    """Rectangle."""
    x: int = 0
    y: int = 0
    width: int = 0
    height: int = 0

    @property
    def right(self) -> int:
        return self.x + self.width

    @property
    def bottom(self) -> int:
        return self.y + self.height


class GUIControl:
    """Base class for GUI controls."""

    def __init__(self, parent: Any = None):
        self.parent = parent
        self.visible = True
        self.enabled = True
        self.x = 0
        self.y = 0
        self.width = 100
        self.height = 25
        self.control: wx.Window = None

    def show(self):
        if self.control:
            self.control.Show()

    def hide(self):
        if self.control:
            self.control.Hide()

    def enable(self):
        if self.control:
            self.control.Enable(True)

    def disable(self):
        if self.control:
            self.control.Enable(False)

    def set_position(self, x: int, y: int):
        self.x = x
        self.y = y
        if self.control:
            self.control.SetPosition((x, y))

    def set_size(self, width: int, height: int):
        self.width = width
        self.height = height
        if self.control:
            self.control.SetSize((width, height))

    def set_rect(self, rect: Rect):
        self.set_position(rect.x, rect.y)
        self.set_size(rect.width, rect.height)


class Button(GUIControl):
    """Button control."""

    def __init__(self, parent: Any, label: str = "Button", x: int = 0, y: int = 0, width: int = 100, height: int = 25):
        super().__init__(parent)
        self.label = label
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.on_click: Optional[Callable] = None

        self.control = wx.Button(parent, label=label, pos=(x, y), size=(width, height))
        self.control.Bind(wx.EVT_BUTTON, self._on_click)

    def _on_click(self, event: wx.Event):
        if self.on_click:
            self.on_click(self)
        event.Skip()

    def set_label(self, label: str):
        self.label = label
        if self.control:
            self.control.SetLabel(label)


class TextBox(GUIControl):
    """Text input control."""

    def __init__(self, parent: Any, text: str = "", x: int = 0, y: int = 0, width: int = 200, height: int = 25,
                 password: bool = False, multiline: bool = False):
        super().__init__(parent)
        self.text = text
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.password = password
        self.multiline = multiline
        self.read_only = False
        self.on_change: Optional[Callable] = None

        style = wx.TE_MULTILINE if multiline else wx.TE_PROCESS_ENTER
        if password:
            style |= wx.TE_PASSWORD

        self.control = wx.TextCtrl(parent, value=text, pos=(x, y), size=(width, height), style=style)
        self.control.Bind(wx.EVT_TEXT, self._on_change)

    def _on_change(self, event: wx.Event):
        self.text = self.control.GetValue()
        if self.on_change:
            self.on_change(self)
        event.Skip()

    def set_text(self, text: str):
        self.text = text
        if self.control:
            self.control.SetValue(text)

    def get_text(self) -> str:
        return self.control.GetValue() if self.control else self.text

    def clear(self):
        self.set_text("")

    def set_read_only(self, read_only: bool):
        self.read_only = read_only
        if self.control:
            self.control.SetReadOnly(read_only)

    def focus(self):
        if self.control:
            self.control.SetFocus()


class Label(GUIControl):
    """Static text label."""

    def __init__(self, parent: Any, text: str = "", x: int = 0, y: int = 0, width: int = 100, height: int = 20,
                 alignment: Align = Align.LEFT):
        super().__init__(parent)
        self.text = text
        self.x = x
        self.y = y
        self.width = width
        self.height = height

        style = 0
        if alignment == Align.CENTER:
            style = wx.ALIGN_CENTER
        elif alignment == Align.RIGHT:
            style = wx.ALIGN_RIGHT

        self.control = wx.StaticText(parent, label=text, pos=(x, y), size=(width, height), style=style)

    def set_text(self, text: str):
        self.text = text
        if self.control:
            self.control.SetLabel(text)


class CheckBox(GUIControl):
    """Checkbox control."""

    def __init__(self, parent: Any, label: str = "", checked: bool = False, x: int = 0, y: int = 0):
        super().__init__(parent)
        self.label = label
        self.checked = checked
        self.x = x
        self.y = y
        self.on_change: Optional[Callable] = None

        self.control = wx.CheckBox(parent, label=label, pos=(x, y), value=checked)
        self.control.Bind(wx.EVT_CHECKBOX, self._on_change)

    def _on_change(self, event: wx.Event):
        self.checked = self.control.GetValue()
        if self.on_change:
            self.on_change(self)
        event.Skip()

    def set_checked(self, checked: bool):
        self.checked = checked
        if self.control:
            self.control.SetValue(checked)

    def is_checked(self) -> bool:
        return self.control.GetValue() if self.control else self.checked


class ComboBox(GUIControl):
    """Dropdown combobox."""

    def __init__(self, parent: Any, items: list = None, x: int = 0, y: int = 0, width: int = 150, height: int = 25):
        super().__init__(parent)
        self.items = items or []
        self.x = x
        self.y = y
        self.width = width
        self.on_change: Optional[Callable] = None

        self.control = wx.ComboBox(parent, pos=(x, y), size=(width, height), choices=self.items, style=wxxCB_SIMPLE)
        self.control.Bind(wx.EVT_COMBOBOX, self._on_change)

    def _on_change(self, event: wx.Event):
        if self.on_change:
            self.on_change(self)
        event.Skip()

    def add_item(self, item: str):
        self.items.append(item)
        if self.control:
            self.control.Append(item)

    def set_items(self, items: list):
        self.items = items
        if self.control:
            self.control.Set(items)

    def get_selected(self) -> str:
        return self.control.GetValue() if self.control else ""

    def get_selected_index(self) -> int:
        return self.control.GetSelection() if self.control else -1

    def set_selection(self, index: int):
        if self.control:
            self.control.SetSelection(index)


class ProgressBar(GUIControl):
    """Progress bar."""

    def __init__(self, parent: Any, x: int = 0, y: int = 0, width: int = 200, height: int = 20, maximum: int = 100):
        super().__init__(parent)
        self.x = x
        self.y = y
        self.width = width
        self.maximum = maximum
        self.value = 0

        self.control = wx.Gauge(parent, range=maximum, pos=(x, y), size=(width, height))

    def set_value(self, value: int):
        self.value = max(0, min(value, self.maximum))
        if self.control:
            self.control.SetValue(self.value)

    def set_maximum(self, maximum: int):
        self.maximum = maximum
        if self.control:
            self.control.SetRange(maximum)


class Window(wx.Frame):
    """Main window/frame."""

    def __init__(self, title: str = "Window", width: int = 800, height: int = 600, centered: bool = True):
        pos = wx.DefaultPosition if centered else (100, 100)
        super().__init__(None, title=title, pos=pos, size=(width, height))

        self.controls: list = []
        self.on_close: Optional[Callable] = None

        self.Bind(wx.EVT_CLOSE, self._on_close)

    def _on_close(self, event: wx.Event):
        if self.on_close:
            if not self.on_close(self):
                event.Veto()
                return
        event.Skip()

    def add_control(self, control: GUIControl):
        self.controls.append(control)

    def center_on_screen(self):
        self.Center()

    def set_title(self, title: str):
        self.SetTitle(title)

    def bring_to_front(self):
        self.Raise()
        self.SetFocus()


def message_box(message: str, caption: str = "Message", style: int = wx.OK | wx.ICON_INFORMATION) -> int:
    """Show a message box."""
    return wx.MessageBox(message, caption, style)


def message_box_yes_no(message: str, caption: str = "Confirm") -> bool:
    """Show yes/no confirmation dialog."""
    result = wx.MessageBox(message, caption, wx.YES_NO | wx.ICON_QUESTION)
    return result == wx.YES


def message_box_ok_cancel(message: str, caption: str = "Confirm") -> bool:
    """Show ok/cancel dialog."""
    result = wx.MessageBox(message, caption, wx.OK_CANCEL | wx.ICON_INFORMATION)
    return result == wx.OK


def get_file_name(filter: str = "All files|*.*", default_path: str = "") -> Optional[str]:
    """Show file open dialog."""
    with wx.FileDialog(None, "Open File", defaultPath=default_path, wildcard=filter, style=wx.FD_OPEN) as dialog:
        if dialog.ShowModal() == wx.ID_OK:
            return dialog.GetPath()
    return None


def get_save_file_name(filter: str = "All files|*.*", default_path: str = "") -> Optional[str]:
    """Show file save dialog."""
    with wx.FileDialog(None, "Save File", defaultPath=default_path, wildcard=filter, style=wx.FD_SAVE | wx.FD_OVERWRITE_PROMPT) as dialog:
        if dialog.ShowModal() == wx.ID_OK:
            return dialog.GetPath()
    return None


def get_directory(default_path: str = "") -> Optional[str]:
    """Show directory selection dialog."""
    with wx.DirDialog(None, "Select Directory", defaultPath=default_path) as dialog:
        if dialog.ShowModal() == wx.ID_OK:
            return dialog.GetPath()
    return None

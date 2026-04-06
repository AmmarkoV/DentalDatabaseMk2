"""
Main application entry point.
Ported from ddatabase.pas
"""
import sys
import wx
from pathlib import Path

# Add project directory to path
project_dir = Path(__file__).parent
sys.path.insert(0, str(project_dir))

from ammargui import Window, Button, TextBox, Label, message_box, message_box_yes_no
from userlogin import Authentication, UserManager
from settings import SettingsManager
from the_works import WorkTypeManager


class LoginFrame(wx.Dialog):
    """Login dialog window."""

    def __init__(self):
        super().__init__(None, title="Login - Dental Database MK2", size=(350, 180))

        # Username field
        wx.StaticText(self, label="Username:", pos=(20, 20))
        self.username_text = wx.TextCtrl(self, pos=(100, 18), size=(200, 22))

        # Password field
        wx.StaticText(self, label="Password:", pos=(20, 55))
        self.password_text = wx.TextCtrl(self, pos=(100, 53), size=(200, 22), style=wx.TE_PASSWORD)

        # Login button
        self.login_button = wx.Button(self, label="Login", pos=(100, 95), size=(80, 28))
        self.login_button.Bind(wx.EVT_BUTTON, self._on_login)

        # Cancel button
        self.cancel_button = wx.Button(self, label="Cancel", pos=(195, 95), size=(80, 28))
        self.cancel_button.Bind(wx.EVT_BUTTON, self._on_cancel)

        self.username_text.SetFocus()

    def _on_login(self, event):
        username = self.username_text.GetValue().strip()
        password = self.password_text.GetValue()

        if not username or not password:
            wx.MessageBox("Please enter username and password", "Error", wx.OK | wx.ICON_ERROR)
            return

        success, message = Authentication.login(username, password)
        if success:
            self.EndModal(wx.ID_OK)
        else:
            wx.MessageBox(message, "Login Failed", wx.OK | wx.ICON_ERROR)

    def _on_cancel(self, event):
        self.EndModal(wx.ID_CANCEL)


class MainFrame(Window):
    """Main application window."""

    def __init__(self):
        super().__init__(
            title=SettingsManager.get("app_title_gr", "Οδοντιατρική Βάση Δεδομένων MK2"),
            width=1000,
            height=700
        )

        self._create_menu()
        self._create_toolbar()
        self._create_status_bar()

        # Welcome message
        self.welcome_label = Label(
            self,
            "Welcome to Dental Database MK2\n\nPlease select an option from the menu.",
            x=50, y=100, width=400, height=100
        )

        self.Show()

    def _create_menu(self):
        """Create menu bar."""
        menubar = wx.MenuBar()

        # Patient menu
        patient_menu = wx.Menu()
        patient_menu.Append(101, "New Patient\tCtrl+N", "Create new patient")
        patient_menu.Append(102, "Open Patient\tCtrl+O", "Open existing patient")
        patient_menu.AppendSeparator()
        patient_menu.Append(103, "Search Patient\tCtrl+F", "Search for patient")
        menubar.Append(patient_menu, "&Patients")

        # Calendar menu
        calendar_menu = wx.Menu()
        calendar_menu.Append(201, "Calendar\tCtrl+C", "Open calendar")
        calendar_menu.Append(202, "New Appointment\tCtrl+A", "Create appointment")
        menubar.Append(calendar_menu, "&Calendar")

        # Management menu
        management_menu = wx.Menu()
        management_menu.Append(301, "Daily Statistics", "View daily statistics")
        management_menu.Append(302, "Monthly Report", "Generate monthly report")
        menubar.Append(management_menu, "&Management")

        # Settings menu
        settings_menu = wx.Menu()
        settings_menu.Append(401, "Settings", "Application settings")
        settings_menu.Append(402, "Backup Database", "Create database backup")
        settings_menu.AppendSeparator()
        settings_menu.Append(403, "Logout", "Logout current user")
        settings_menu.Append(404, "Exit\tCtrl+Q", "Exit application")
        menubar.Append(settings_menu, "&Settings")

        self.SetMenuBar(menubar)

        # Bind menu events
        self.Bind(wx.EVT_MENU, self._on_new_patient, id=101)
        self.Bind(wx.EVT_MENU, self._on_open_patient, id=102)
        self.Bind(wx.EVT_MENU, self._on_search_patient, id=103)
        self.Bind(wx.EVT_MENU, self._on_calendar, id=201)
        self.Bind(wx.EVT_MENU, self._on_new_appointment, id=202)
        self.Bind(wx.EVT_MENU, self._on_daily_statistics, id=301)
        self.Bind(wx.EVT_MENU, self._on_monthly_report, id=302)
        self.Bind(wx.EVT_MENU, self._on_settings, id=401)
        self.Bind(wx.EVT_MENU, self._on_backup, id=402)
        self.Bind(wx.EVT_MENU, self._on_logout, id=403)
        self.Bind(wx.EVT_MENU, self._on_exit, id=404)

    def _create_toolbar(self):
        """Create toolbar."""
        self.CreateToolBar(wx.TB_TEXT | wx.TB_VERTICAL)

    def _create_status_bar(self):
        """Create status bar."""
        self.CreateStatusBar()
        self.SetStatusText("Ready")

    def _on_new_patient(self, event):
        self.SetStatusText("New Patient - Feature in development")
        message_box("New Patient feature - Coming soon!", "Info")

    def _on_open_patient(self, event):
        self.SetStatusText("Open Patient - Feature in development")
        message_box("Open Patient feature - Coming soon!", "Info")

    def _on_search_patient(self, event):
        self.SetStatusText("Search Patient - Feature in development")
        message_box("Search Patient feature - Coming soon!", "Info")

    def _on_calendar(self, event):
        self.SetStatusText("Calendar - Feature in development")
        message_box("Calendar feature - Coming soon!", "Info")

    def _on_new_appointment(self, event):
        self.SetStatusText("New Appointment - Feature in development")
        message_box("New Appointment feature - Coming soon!", "Info")

    def _on_daily_statistics(self, event):
        self.SetStatusText("Daily Statistics - Feature in development")
        message_box("Daily Statistics feature - Coming soon!", "Info")

    def _on_monthly_report(self, event):
        self.SetStatusText("Monthly Report - Feature in development")
        message_box("Monthly Report feature - Coming soon!", "Info")

    def _on_settings(self, event):
        self.SetStatusText("Settings - Feature in development")
        message_box("Settings feature - Coming soon!", "Info")

    def _on_backup(self, event):
        self.SetStatusText("Backup - Feature in development")
        message_box("Backup feature - Coming soon!", "Info")

    def _on_logout(self, event):
        if message_box_yes_no("Are you sure you want to logout?", "Confirm Logout"):
            Authentication.logout()
            self.Close()

    def _on_exit(self, event):
        if message_box_yes_no("Are you sure you want to exit?", "Confirm Exit"):
            self.Close()

    def _on_close(self):
        """Handle window close."""
        return True


def create_demo_admin():
    """Create a demo admin user if none exists."""
    admin = UserManager.get_user("admin")
    if not admin:
        UserManager.create_user(
            username="admin",
            password="admin123",
            full_name="Administrator",
            is_admin=True
        )
        print("Created demo admin user: admin / admin123")


def initialize_database():
    """Initialize database with default data."""
    # Initialize work types
    count = WorkTypeManager.initialize_default_types()
    print(f"Initialized {count} default work types")


def main():
    """Main entry point."""
    print("Dental Database MK2 - Python Port")
    print("=" * 40)

    # Initialize database
    initialize_database()

    # Create demo admin
    create_demo_admin()

    # Create wx application
    app = wx.App(False)

    # Check if already logged in
    if Authentication.is_logged_in():
        frame = MainFrame()
    else:
        # Show login dialog
        login_frame = LoginFrame()
        login_frame.ShowModal()

        # If login successful, show main frame
        if Authentication.is_logged_in():
            frame = MainFrame()
        else:
            return

    app.MainLoop()


if __name__ == "__main__":
    main()
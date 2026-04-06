"""
Application settings module.
Ported from settings.pas
"""
from typing import Any, Dict, Optional

from database import db


class SettingsManager:
    """Manages application settings."""

    # Default settings
    DEFAULT_SETTINGS = {
        "app_title": "Dental Database MK2",
        "app_title_gr": "Οδοντιατρική Βάση Δεδομένων MK2",
        "language": "el",  # el=Greek, en=English
        "currency_symbol": "€",
        "date_format": "dd/mm/yyyy",
        "time_format": "24h",
        "working_hours_start": "09:00",
        "working_hours_end": "18:00",
        "appointment_duration_default": "30",
        "show_greek_labels": "true",
        "auto_save": "true",
        "backup_before_update": "true",
        "reminder_days_before": "1",
        "theme": "light",
    }

    @classmethod
    def initialize_defaults(cls):
        """Initialize default settings if not exists."""
        for key, value in cls.DEFAULT_SETTINGS.items():
            current = db.get_setting(key)
            if not current:
                db.set_setting(key, str(value), "general")

    @classmethod
    def get(cls, key: str, default: str = "") -> str:
        """Get a setting value."""
        return db.get_setting(key, default)

    @classmethod
    def set(cls, key: str, value: Any, category: str = "general") -> bool:
        """Set a setting value."""
        return db.set_setting(key, str(value), category)

    @classmethod
    def get_int(cls, key: str, default: int = 0) -> int:
        """Get setting as integer."""
        try:
            return int(cls.get(key, str(default)))
        except ValueError:
            return default

    @classmethod
    def get_float(cls, key: str, default: float = 0.0) -> float:
        """Get setting as float."""
        try:
            return float(cls.get(key, str(default)))
        except ValueError:
            return default

    @classmethod
    def get_bool(cls, key: str, default: bool = False) -> bool:
        """Get setting as boolean."""
        value = cls.get(key, "" if default else "false").lower()
        return value in ("true", "1", "yes", "on")

    @classmethod
    def get_all(cls) -> Dict[str, str]:
        """Get all settings."""
        return db.get_all_settings()

    @classmethod
    def get_by_category(cls, category: str) -> Dict[str, str]:
        """Get settings by category."""
        all_settings = cls.get_all()
        # Filter by category prefix (key format: category_setting)
        return {k: v for k, v in all_settings.items() if k.startswith(f"{category}_")}

    @classmethod
    def delete(cls, key: str) -> bool:
        """Delete a setting."""
        return db.set_setting(key, "")

    @classmethod
    def reset_to_defaults(cls) -> bool:
        """Reset all settings to defaults."""
        try:
            all_settings = cls.get_all()
            for key in all_settings:
                if key in cls.DEFAULT_SETTINGS:
                    cls.set(key, cls.DEFAULT_SETTINGS[key])
            return True
        except Exception:
            return False


# Convenience accessors
def get_setting(key: str, default: str = "") -> str:
    return SettingsManager.get(key, default)


def set_setting(key: str, value: Any, category: str = "general") -> bool:
    return SettingsManager.set(key, value, category)


def get_int(key: str, default: int = 0) -> int:
    return SettingsManager.get_int(key, default)


def get_bool(key: str, default: bool = False) -> bool:
    return SettingsManager.get_bool(key, default)


# Initialize defaults on import
SettingsManager.initialize_defaults()

"""
pyDDMK2 - Python port of Dental Database MK2
A dental practice management system.
"""

__version__ = "1.0.0"
__author__ = "Ported from FreePascal"

from .translations import EN_TO_GR, GR_TO_EN, translate_en_to_gr, translate_gr_to_en, greek_equal
from .string_stuff import trim, uppercase, lowercase, extract, left, right, pos
from .tools import get_app_path, get_data_path, file_exists, read_file, write_file
from .settings import SettingsManager, get_setting, set_setting
from .database import db, Database

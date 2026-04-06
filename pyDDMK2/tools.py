"""
File operations and utility functions.
Ported from tools.pas
"""
import os
import shutil
from pathlib import Path
from datetime import datetime
from typing import List, Optional

# Base path for the application
BASE_PATH = Path(__file__).parent.parent

def get_app_path() -> Path:
    """Get application base directory."""
    return BASE_PATH

def get_data_path() -> Path:
    """Get data directory path."""
    data_dir = BASE_PATH / "data"
    data_dir.mkdir(exist_ok=True)
    return data_dir

def get_backup_path() -> Path:
    """Get backup directory path."""
    backup_dir = BASE_PATH / "backups"
    backup_dir.mkdir(exist_ok=True)
    return backup_dir

def get_temp_path() -> Path:
    """Get temporary directory path."""
    temp_dir = BASE_PATH / "temp"
    temp_dir.mkdir(exist_ok=True)
    return temp_dir

def file_exists(path: str) -> bool:
    """Check if file exists."""
    return Path(path).is_file()

def directory_exists(path: str) -> bool:
    """Check if directory exists."""
    return Path(path).is_dir()

def create_directory(path: str) -> bool:
    """Create directory if it doesn't exist."""
    try:
        Path(path).mkdir(parents=True, exist_ok=True)
        return True
    except Exception:
        return False

def delete_file(path: str) -> bool:
    """Delete a file."""
    try:
        Path(path).unlink(missing_ok=True)
        return True
    except Exception:
        return False

def delete_directory(path: str) -> bool:
    """Delete a directory and its contents."""
    try:
        shutil.rmtree(path, ignore_errors=True)
        return True
    except Exception:
        return False

def copy_file(src: str, dst: str) -> bool:
    """Copy a file."""
    try:
        shutil.copy2(src, dst)
        return True
    except Exception:
        return False

def move_file(src: str, dst: str) -> bool:
    """Move a file."""
    try:
        shutil.move(src, dst)
        return True
    except Exception:
        return False

def read_file(path: str, encoding: str = 'utf-8') -> str:
    """Read entire file contents."""
    try:
        with open(path, 'r', encoding=encoding) as f:
            return f.read()
    except Exception:
        return ""

def write_file(path: str, content: str, encoding: str = 'utf-8') -> bool:
    """Write content to file."""
    try:
        Path(path).parent.mkdir(parents=True, exist_ok=True)
        with open(path, 'w', encoding=encoding) as f:
            f.write(content)
        return True
    except Exception:
        return False

def read_file_binary(path: str) -> bytes:
    """Read file as binary data."""
    try:
        with open(path, 'rb') as f:
            return f.read()
    except Exception:
        return b""

def write_file_binary(path: str, data: bytes) -> bool:
    """Write binary data to file."""
    try:
        Path(path).parent.mkdir(parents=True, exist_ok=True)
        with open(path, 'wb') as f:
            f.write(data)
        return True
    except Exception:
        return False

def list_files(directory: str, pattern: str = "*") -> List[str]:
    """List files in directory matching pattern."""
    try:
        path = Path(directory)
        return [str(p) for p in path.glob(pattern) if p.is_file()]
    except Exception:
        return []

def list_directories(directory: str) -> List[str]:
    """List subdirectories."""
    try:
        path = Path(directory)
        return [str(p) for p in path.iterdir() if p.is_dir()]
    except Exception:
        return []

def get_file_size(path: str) -> int:
    """Get file size in bytes."""
    try:
        return Path(path).stat().st_size
    except Exception:
        return 0

def get_file_modified_time(path: str) -> datetime:
    """Get file modified time."""
    try:
        return datetime.fromtimestamp(Path(path).stat().st_mtime)
    except Exception:
        return datetime.now()

def get_current_datetime() -> datetime:
    """Get current date and time."""
    return datetime.now()

def format_datetime(dt: datetime, format_str: str = "%Y-%m-%d %H:%M:%S") -> str:
    """Format datetime to string."""
    return dt.strftime(format_str)

def parse_datetime(date_str: str, format_str: str = "%Y-%m-%d %H:%M:%S") -> Optional[datetime]:
    """Parse string to datetime."""
    try:
        return datetime.strptime(date_str, format_str)
    except Exception:
        return None

def format_date_gr(date: datetime) -> str:
    """Format date in Greek format (DD/MM/YYYY)."""
    return date.strftime("%d/%m/%Y")

def parse_date_gr(date_str: str) -> Optional[datetime]:
    """Parse Greek date format (DD/MM/YYYY)."""
    try:
        return datetime.strptime(date_str, "%d/%m/%Y")
    except Exception:
        return None

def timestamp_now() -> int:
    """Get current timestamp in milliseconds."""
    return int(datetime.now().timestamp() * 1000)

def sleep(milliseconds: int):
    """Sleep for specified milliseconds."""
    import time
    time.sleep(milliseconds / 1000.0)

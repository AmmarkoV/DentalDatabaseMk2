"""
String manipulation utilities for Greek text processing.
Ported from string_stuff.pas
"""

def trim(s: str) -> str:
    """Remove leading and trailing whitespace."""
    return s.strip()

def ltrim(s: str) -> str:
    """Remove leading whitespace."""
    return s.lstrip()

def rtrim(s: str) -> str:
    """Remove trailing whitespace."""
    return s.rstrip()

def uppercase(s: str) -> str:
    """Convert string to uppercase."""
    return s.upper()

def lowercase(s: str) -> str:
    """Convert string to lowercase."""
    return s.lower()

def extract(s: str, start: int, length: int) -> str:
    """Extract substring (1-indexed, Pascal-style)."""
    if start < 1:
        start = 1
    py_start = start - 1
    if py_start >= len(s):
        return ""
    return s[py_start:py_start + length]

def left(s: str, length: int) -> str:
    """Get leftmost characters."""
    return s[:length]

def right(s: str, length: int) -> str:
    """Get rightmost characters."""
    if length <= 0:
        return ""
    return s[-length:] if length < len(s) else s

def pos(sub: str, s: str) -> int:
    """Find position of substring (1-indexed, returns 0 if not found)."""
    idx = s.find(sub)
    return idx + 1 if idx != -1 else 0

def copy_pos(s: str, pos_num: int, delimiter: str = ';') -> str:
    """Get the pos_num-th delimited part (1-indexed)."""
    parts = s.split(delimiter)
    if 0 < pos_num <= len(parts):
        return parts[pos_num - 1]
    return ""

def copy_count(s: str, delimiter: str = ';') -> int:
    """Count number of delimited parts."""
    if not s:
        return 0
    return len([p for p in s.split(delimiter) if p])

def replace_all(s: str, old: str, new: str) -> str:
    """Replace all occurrences of old with new."""
    return s.replace(old, new)

def contains(s: str, sub: str) -> bool:
    """Check if s contains sub."""
    return sub in s

def starts_with(s: str, prefix: str) -> bool:
    """Check if s starts with prefix."""
    return s.startswith(prefix)

def ends_with(s: str, suffix: str) -> bool:
    """Check if s ends with suffix."""
    return s.endswith(suffix)

def repeat(s: str, count: int) -> str:
    """Repeat string count times."""
    return s * count

def pad_right(s: str, total_length: int, pad_char: str = ' ') -> str:
    """Pad string on the right."""
    return s.ljust(total_length, pad_char)

def pad_left(s: str, total_length: int, pad_char: str = ' ') -> str:
    """Pad string on the left."""
    return s.rjust(total_length, pad_char)

def is_empty(s: str) -> bool:
    """Check if string is empty or whitespace only."""
    return not s or not s.strip()

def is_numeric(s: str) -> bool:
    """Check if string represents a number."""
    try:
        float(s)
        return True
    except (ValueError, TypeError):
        return False

def is_integer(s: str) -> bool:
    """Check if string represents an integer."""
    try:
        int(s)
        return True
    except (ValueError, TypeError):
        return False

def to_integer(s: str, default: int = 0) -> int:
    """Convert string to integer with default on failure."""
    try:
        return int(float(s))
    except (ValueError, TypeError):
        return default

def to_float(s: str, default: float = 0.0) -> float:
    """Convert string to float with default on failure."""
    try:
        return float(s.replace(',', '.'))
    except (ValueError, TypeError):
        return default

def format_float(value: float, decimals: int = 2) -> str:
    """Format float with fixed decimal places."""
    return f"{value:.{decimals}f}"

def join_strings(parts: list, delimiter: str = ',') -> str:
    """Join list of strings with delimiter."""
    return delimiter.join(parts)

def split_string(s: str, delimiter: str = ',') -> list:
    """Split string by delimiter."""
    return s.split(delimiter) if s else []

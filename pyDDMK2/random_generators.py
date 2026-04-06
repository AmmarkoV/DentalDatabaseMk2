"""
Random number generation utilities.
Ported from random_generators.pas
"""
import random
import secrets
import string

# Seed the random generator
random.seed()

def random_range(min_val: int, max_val: int) -> int:
    """Generate random integer in range [min_val, max_val]."""
    if min_val > max_val:
        min_val, max_val = max_val, min_val
    return random.randint(min_val, max_val)

def random_bool(probability: float = 0.5) -> bool:
    """Generate random boolean with given probability of True."""
    return random.random() < probability

def random_choice(items: list):
    """Select random item from list."""
    if not items:
        return None
    return random.choice(items)

def random_shuffle(items: list) -> list:
    """Return shuffled copy of list."""
    result = items.copy()
    random.shuffle(result)
    return result

def generate_random_string(length: int, charset: str = string.ascii_letters + string.digits) -> str:
    """Generate random string of specified length."""
    return ''.join(random.choice(charset) for _ in range(length))

def generate_random_alphanumeric(length: int) -> str:
    """Generate random alphanumeric string."""
    return generate_random_string(length, string.ascii_letters + string.digits)

def generate_random_hex(length: int) -> str:
    """Generate random hexadecimal string."""
    return ''.join(random.choice('0123456789ABCDEF') for _ in range(length))

def generate_uuid_like() -> str:
    """Generate UUID-like string."""
    return f"{generate_random_hex(8)}-{generate_random_hex(4)}-{generate_random_hex(4)}-{generate_random_hex(4)}-{generate_random_hex(12)}"

def secure_random_bytes(length: int) -> bytes:
    """Generate cryptographically secure random bytes."""
    return secrets.token_bytes(length)

def secure_random_hex(length: int) -> str:
    """Generate cryptographically secure random hex string."""
    return secrets.token_hex(length)

def weighted_choice(items: list, weights: list) -> any:
    """Select item based on weights."""
    if not items or not weights or len(items) != len(weights):
        return random_choice(items)
    return random.choices(items, weights=weights, k=1)[0]

"""
Encryption utilities.
Ported from pumacrypt.pas
"""
import hashlib
import base64
import hmac
from typing import Optional

# Simple XOR-based encryption (for legacy compatibility)
def xor_encrypt(data: bytes, key: bytes) -> bytes:
    """XOR encrypt/decrypt data with key."""
    if not key:
        return data
    result = bytearray(len(data))
    for i, byte in enumerate(data):
        result[i] = byte ^ key[i % len(key)]
    return bytes(result)

def simple_encrypt(text: str, key: str = "default") -> str:
    """Simple encryption for storage."""
    if not text:
        return ""
    data = text.encode('utf-8')
    encrypted = xor_encrypt(data, key.encode('utf-8'))
    return base64.b64encode(encrypted).decode('ascii')

def simple_decrypt(encrypted: str, key: str = "default") -> str:
    """Simple decryption for storage."""
    if not encrypted:
        return ""
    try:
        data = base64.b64decode(encrypted.encode('ascii'))
        decrypted = xor_encrypt(data, key.encode('utf-8'))
        return decrypted.decode('utf-8')
    except Exception:
        return ""

def md5_hash(data: str) -> str:
    """Generate MD5 hash."""
    return hashlib.md5(data.encode('utf-8')).hexdigest()

def sha256_hash(data: str) -> str:
    """Generate SHA256 hash."""
    return hashlib.sha256(data.encode('utf-8')).hexdigest()

def sha512_hash(data: str) -> str:
    """Generate SHA512 hash."""
    return hashlib.sha512(data.encode('utf-8')).hexdigest()

def hash_password(password: str, salt: str = "") -> str:
    """Hash password with optional salt."""
    data = (salt + password).encode('utf-8')
    return hashlib.pbkdf2_hmac('sha256', data, b'pumacrypt', 100000).hex()

def verify_password(password: str, hashed: str, salt: str = "") -> bool:
    """Verify password against hash."""
    return hash_password(password, salt) == hashed

def hmac_sign(data: str, key: str) -> str:
    """Generate HMAC signature."""
    return hmac.new(
        key.encode('utf-8'),
        data.encode('utf-8'),
        hashlib.sha256
    ).hexdigest()

def verify_hmac(data: str, signature: str, key: str) -> bool:
    """Verify HMAC signature."""
    expected = hmac_sign(data, key)
    return hmac.compare_digest(expected, signature)

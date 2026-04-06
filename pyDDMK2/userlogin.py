"""
User authentication module.
Ported from userlogin.pas
"""
from datetime import datetime
from typing import Optional, Tuple

from models import User
from database import db
from pumacrypt import hash_password, verify_password, md5_hash


class UserManager:
    """Manages user accounts."""

    @staticmethod
    def create_user(
        username: str,
        password: str,
        full_name: str = "",
        email: str = "",
        is_admin: bool = False
    ) -> Optional[User]:
        """Create a new user account."""
        # Check if username already exists
        existing = db.get_user(username)
        if existing:
            return None

        password_hash = hash_password(password)

        user = User(
            username=username.lower().strip(),
            password_hash=password_hash,
            full_name=full_name.strip(),
            email=email.lower().strip(),
            is_admin=is_admin,
            is_active=True
        )

        if db.create_user(user):
            return user
        return None

    @staticmethod
    def get_user(username: str) -> Optional[User]:
        """Get user by username."""
        return db.get_user(username)

    @staticmethod
    def update_user(
        username: str,
        full_name: str = None,
        email: str = None,
        is_admin: bool = None,
        is_active: bool = None
    ) -> bool:
        """Update user details."""
        user = db.get_user(username)
        if not user:
            return False

        if full_name is not None:
            user.full_name = full_name
        if email is not None:
            user.email = email
        if is_admin is not None:
            user.is_admin = is_admin
        if is_active is not None:
            user.is_active = is_active

        return db.update_user(user)

    @staticmethod
    def change_password(username: str, old_password: str, new_password: str) -> bool:
        """Change user password."""
        user = db.get_user(username)
        if not user:
            return False

        if not verify_password(old_password, user.password_hash):
            return False

        user.password_hash = hash_password(new_password)
        return db.update_user(user)

    @staticmethod
    def delete_user(username: str) -> bool:
        """Delete user account."""
        return db.delete_user(username)

    @staticmethod
    def get_all_users() -> list:
        """Get all users."""
        return db.get_all_users()

    @staticmethod
    def activate_user(username: str) -> bool:
        """Activate a user account."""
        return UserManager.update_user(username, is_active=True)

    @staticmethod
    def deactivate_user(username: str) -> bool:
        """Deactivate a user account."""
        return UserManager.update_user(username, is_active=False)

    @staticmethod
    def make_admin(username: str) -> bool:
        """Grant admin privileges."""
        return UserManager.update_user(username, is_admin=True)

    @staticmethod
    def revoke_admin(username: str) -> bool:
        """Revoke admin privileges."""
        return UserManager.update_user(username, is_admin=False)


class Authentication:
    """Handles user authentication."""

    _current_user: Optional[User] = None
    _login_time: Optional[datetime] = None

    @staticmethod
    def login(username: str, password: str) -> Tuple[bool, str]:
        """
        Authenticate user.
        Returns (success, message)
        """
        user = db.get_user(username)

        if not user:
            return False, "Invalid username or password"

        if not user.is_active:
            return False, "Account is deactivated"

        if not verify_password(password, user.password_hash):
            return False, "Invalid username or password"

        # Set current user
        Authentication._current_user = user
        Authentication._login_time = datetime.now()

        # Update last login
        user.last_login = datetime.now()
        db.update_user(user)

        return True, f"Welcome, {user.full_name or username}!"

    @staticmethod
    def logout() -> bool:
        """Log out current user."""
        Authentication._current_user = None
        Authentication._login_time = None
        return True

    @staticmethod
    def is_logged_in() -> bool:
        """Check if a user is currently logged in."""
        return Authentication._current_user is not None

    @staticmethod
    def get_current_user() -> Optional[User]:
        """Get currently logged in user."""
        return Authentication._current_user

    @staticmethod
    def get_current_username() -> str:
        """Get currently logged in username."""
        if Authentication._current_user:
            return Authentication._current_user.username
        return ""

    @staticmethod
    def is_admin() -> bool:
        """Check if current user is admin."""
        if Authentication._current_user:
            return Authentication._current_user.is_admin
        return False

    @staticmethod
    def get_login_time() -> Optional[datetime]:
        """Get current session login time."""
        return Authentication._login_time

    @staticmethod
    def requires_auth(func):
        """Decorator to require authentication."""
        def wrapper(*args, **kwargs):
            if not Authentication.is_logged_in():
                raise PermissionError("Authentication required")
            return func(*args, **kwargs)
        return wrapper

    @staticmethod
    def requires_admin(func):
        """Decorator to require admin privileges."""
        def wrapper(*args, **kwargs):
            if not Authentication.is_logged_in():
                raise PermissionError("Authentication required")
            if not Authentication.is_admin():
                raise PermissionError("Admin privileges required")
            return func(*args, **kwargs)
        return wrapper


# Convenience functions
def login(username: str, password: str) -> Tuple[bool, str]:
    """Login convenience function."""
    return Authentication.login(username, password)

def logout() -> bool:
    """Logout convenience function."""
    return Authentication.logout()

def is_logged_in() -> bool:
    """Check if logged in."""
    return Authentication.is_logged_in()

def get_current_user() -> Optional[User]:
    """Get current user."""
    return Authentication.get_current_user()

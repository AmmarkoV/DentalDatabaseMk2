# pyDDMK2 - Python Port of Dental Database MK2

A modern Python implementation of the Dental Database MK2 practice management system, originally written in FreePascal.

## Features

- **Patient Management**: Create, search, and manage patient records
- **Dental Records**: Track teeth treatments and procedures
- **Work/Procedures**: Manage dental work types and track patient treatments
- **Payments**: Record and report on patient payments
- **Calendar**: Schedule and manage appointments
- **User Authentication**: Secure login system with admin privileges
- **Bilingual Support**: Greek and English interface support

## Architecture

```
pyDDMK2/
├── __init__.py      # Package initialization
├── ddatabase.py     # Main application entry point
├── ammargui.py      # wxPython GUI framework
├── models.py        # Data models (dataclasses)
├── database.py      # SQLite database layer
├── translations.py  # Greek/English translations & Greeklish
├── string_stuff.py  # String utilities
├── tools.py         # File system utilities
├── random_generators.py  # Random number generation
├── pumacrypt.py     # Encryption utilities
├── people.py        # Patient management
├── teeth.py         # Dental teeth data
├── the_works.py     # Dental procedures
├── payments.py      # Payment tracking
├── calendar.py      # Appointment scheduling
├── userlogin.py     # User authentication
├── settings.py      # Application settings
└── requirements.txt # Python dependencies
```

## Installation

```bash
# Install dependencies
pip install -r requirements.txt
```

## Usage

```bash
# Run the application
python -m pyDDMK2.ddatabase
```

### Demo Credentials

- **Username**: admin
- **Password**: admin123

## Module Descriptions

### Core Modules

| Module | Description |
|--------|-------------|
| `models.py` | Data class definitions for all entities |
| `database.py` | SQLite database persistence layer |
| `translations.py` | Greek/English translations and Greeklish support |

### Business Logic

| Module | Description |
|--------|-------------|
| `people.py` | Patient record management |
| `teeth.py` | Dental teeth data and treatments |
| `the_works.py` | Dental procedures catalog and tracking |
| `payments.py` | Payment recording and reporting |
| `calendar.py` | Appointment scheduling |
| `userlogin.py` | User authentication |
| `settings.py` | Application configuration |

### Utilities

| Module | Description |
|--------|-------------|
| `string_stuff.py` | String manipulation utilities |
| `tools.py` | File system operations |
| `random_generators.py` | Random number generation |
| `pumacrypt.py` | Encryption and hashing |

### GUI

| Module | Description |
|--------|-------------|
| `ammargui.py` | wxPython-based GUI framework |
| `ddatabase.py` | Main application window |

## Database Schema

The application uses SQLite with the following tables:

- `users` - User accounts
- `patients` - Patient records
- `teeth` - Dental teeth data
- `work_types` - Procedure catalog
- `works` - Patient treatments
- `payments` - Payment records
- `appointments` - Scheduled appointments
- `settings` - Application settings

## License

This is a port of the original FreePascal application.

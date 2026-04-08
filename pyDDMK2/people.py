"""
Patient management module - works directly with legacy .dat files.
Ported from people.pas
"""
import re
import os
from datetime import datetime
from pathlib import Path
from typing import List, Optional, Dict, Any

from models import Patient, PatientStatus
from random_generators import generate_random_alphanumeric
from string_stuff import trim, uppercase
from translations import greek_equal
from tools import get_app_path

# Field name mappings for .dat files
FIELD_MAP = {
    'code': 'CODE',
    'surname': 'SURNAME',
    'name': 'NAME',
    'father_name': 'FATHER_NAME',
    'mother_name': 'MOTHER_NAME',
    'area': 'AREA',
    'telephone': 'TELEPHONE',
    'cell_phone': 'CELLPHONE',
    'address': 'ADDRESS',
    'profession': 'PROFESSION',
    'email': 'EMAIL',
    'birth_date': 'BIRTH',
    'next_visit': 'NEXT_APPOINTMENT',
    'comments': 'COMMENTS',
}

class PatientManager:
    """Manages patient operations using .dat files directly."""

    @staticmethod
    def get_database_dir() -> Path:
        """Get the Database directory path."""
        return get_app_path() / "Database"

    @staticmethod
    def get_patient_filepath(code: str) -> Path:
        """Get the filepath for a patient's .dat file."""
        return PatientManager.get_database_dir() / f"{code}.dat"

    @staticmethod
    def _parse_date(date_str: str) -> Optional[datetime]:
        """Parse date from DAT format (DD,MM,YYYY)."""
        if not date_str:
            return None
        try:
            parts = date_str.split(',')
            if len(parts) == 3:
                day = int(parts[0])
                month = int(parts[1])
                year = int(parts[2])
                return datetime(year, month, day)
        except (ValueError, IndexError):
            pass
        return None

    @staticmethod
    def _format_date(dt: datetime) -> str:
        """Format datetime to DAT format (DD,MM,YYYY)."""
        if not dt:
            return ""
        return f"{dt.day},{dt.month},{dt.year}"

    @staticmethod
    def _read_dat_file(filepath: Path) -> Dict[str, Any]:
        """Read a .dat file and return parsed data."""
        data = {'works': []}

        for encoding in ['windows-1253', 'utf-8']:
            try:
                with open(filepath, 'r', encoding=encoding) as f:
                    for line in f:
                        line = line.strip()
                        if not line:
                            continue

                        # Parse KEY(value) format
                        match = re.match(r'^(\w+)\((.*)\)$', line)
                        if match:
                            key = match.group(1).upper()
                            value = match.group(2)

                            if key == 'WORK':
                                parts = value.split(',')
                                if len(parts) >= 9:
                                    data['works'].append({
                                        'description': parts[0],
                                        'price': float(parts[1].replace(',', '.')) if parts[1] else 0,
                                        'discount': float(parts[2].replace(',', '.')) if parts[2] else 0,
                                        'paid': float(parts[3].replace(',', '.')) if parts[3] else 0,
                                        'comments': parts[4] if len(parts) > 4 else '',
                                        'user': parts[5] if len(parts) > 5 else '',
                                        'day': int(parts[6]) if parts[6].isdigit() else 0,
                                        'month': int(parts[7]) if parts[7].isdigit() else 0,
                                        'year': int(parts[8]) if parts[8].isdigit() else 0,
                                    })
                            else:
                                data[key] = value
                return data
            except UnicodeDecodeError:
                continue
            except FileNotFoundError:
                return data

        return data

    @staticmethod
    def _dat_key_to_field(key: str) -> str:
        """Convert DAT file key to Python field name."""
        mapping = {
            'CODE': 'code',
            'SURNAME': 'surname',
            'NAME': 'name',
            'FATHER_NAME': 'father_name',
            'MOTHER_NAME': 'mother_name',
            'AREA': 'area',
            'TELEPHONE': 'telephone',
            'CELLPHONE': 'cell_phone',
            'ADDRESS': 'address',
            'PROFESSION': 'profession',
            'EMAIL': 'email',
            'BIRTH': 'birth_date',
            'NEXT_APPOINTMENT': 'next_visit',
            'COMMENTS': 'comments',
        }
        return mapping.get(key, key.lower())

    @staticmethod
    def _field_to_dat_key(field: str) -> str:
        """Convert Python field name to DAT file key."""
        return FIELD_MAP.get(field, field.upper())

    @staticmethod
    def _data_to_patient(data: Dict[str, Any]) -> Patient:
        """Convert parsed data dict to Patient object."""
        return Patient(
            code=trim(data.get('CODE', '')),
            surname=trim(data.get('SURNAME', '')),
            name=trim(data.get('NAME', '')),
            father_name=trim(data.get('FATHER_NAME', '')),
            mother_name=trim(data.get('MOTHER_NAME', '')),
            area=trim(data.get('AREA', '')),
            telephone=trim(data.get('TELEPHONE', '')),
            cell_phone=trim(data.get('CELLPHONE', '')),
            address=trim(data.get('ADDRESS', '')),
            profession=trim(data.get('PROFESSION', '')),
            email=trim(data.get('EMAIL', '')),
            birth_date=PatientManager._parse_date(data.get('BIRTH', '')),
            next_visit=PatientManager._parse_date(data.get('NEXT_APPOINTMENT', '')),
            comments=trim(data.get('COMMENTS', '')),
            works=data.get('works', [])
        )

    @staticmethod
    def generate_patient_code() -> str:
        """Generate a unique patient code."""
        attempts = 0
        while attempts < 100:
            code = generate_random_alphanumeric(6).upper()
            if not PatientManager.get_patient(code):
                return code
            attempts += 1
        # Fallback: add timestamp
        return f"PAT{datetime.now().timestamp():.0f}"[:6].upper()

    @staticmethod
    def _write_dat_file(filepath: Path, patient: Patient) -> bool:
        """Write patient data to .dat file."""
        try:
            lines = []

            # Write basic fields
            for field, value in [
                ('code', patient.code),
                ('surname', patient.surname),
                ('name', patient.name),
                ('father_name', patient.father_name),
                ('mother_name', patient.mother_name),
                ('area', patient.area),
                ('telephone', patient.telephone),
                ('cell_phone', patient.cell_phone),
                ('address', patient.address),
                ('profession', patient.profession),
                ('email', patient.email),
                ('comments', patient.comments),
            ]:
                key = PatientManager._field_to_dat_key(field)
                if value:
                    lines.append(f"{key}({value})")

            # Write dates
            if patient.birth_date:
                lines.append(f"BIRTH({PatientManager._format_date(patient.birth_date)})")
            if patient.next_visit:
                lines.append(f"NEXT_APPOINTMENT({PatientManager._format_date(patient.next_visit)})")

            # Write works
            if hasattr(patient, 'works') and patient.works:
                for work in patient.works:
                    work_str = ','.join(str(v) for v in [
                        work.get('description', ''),
                        work.get('price', 0),
                        work.get('discount', 0),
                        work.get('paid', 0),
                        work.get('comments', ''),
                        work.get('user', ''),
                        work.get('day', 0),
                        work.get('month', 0),
                        work.get('year', 0),
                    ])
                    lines.append(f"WORK({work_str})")

            # Ensure directory exists
            filepath.parent.mkdir(parents=True, exist_ok=True)

            with open(filepath, 'w', encoding='utf-8') as f:
                f.write('\n'.join(lines))
                f.write('\n')

            return True
        except Exception as e:
            print(f"Error writing patient file: {e}")
            return False

    @staticmethod
    def create_patient(
        surname: str,
        name: str,
        father_name: str = "",
        mother_name: str = "",
        area: str = "",
        telephone: str = "",
        cell_phone: str = "",
        address: str = "",
        profession: str = "",
        email: str = "",
        birth_date: datetime = None,
        next_visit: datetime = None,
        comments: str = ""
    ) -> Optional[Patient]:
        """Create a new patient record in .dat file."""
        code = PatientManager.generate_patient_code()

        patient = Patient(
            code=code,
            surname=trim(surname),
            name=trim(name),
            father_name=trim(father_name),
            mother_name=trim(mother_name),
            area=trim(area),
            telephone=trim(telephone),
            cell_phone=trim(cell_phone),
            address=trim(address),
            profession=trim(profession),
            email=trim(email),
            birth_date=birth_date,
            next_visit=next_visit,
            comments=trim(comments),
            works=[]
        )

        filepath = PatientManager.get_patient_filepath(code)
        if PatientManager._write_dat_file(filepath, patient):
            return patient
        return None

    @staticmethod
    def get_patient(code: str) -> Optional[Patient]:
        """Retrieve patient by code from .dat files.

        Legacy .dat files are named {surname}_{name}.dat, not {code}.dat,
        so we must search through all patients and match by CODE field.
        """
        # First try direct lookup (for new patients created by this app)
        filepath = PatientManager.get_patient_filepath(code)
        if filepath.exists():
            data = PatientManager._read_dat_file(filepath)
            if data.get('CODE') == code:
                return PatientManager._data_to_patient(data)

        # Search through all patients (for legacy files)
        all_patients = PatientManager.get_all_patients()
        for patient in all_patients:
            if patient.code == code:
                return patient

        return None

    @staticmethod
    def update_patient(
        code: str,
        surname: str = None,
        name: str = None,
        father_name: str = None,
        mother_name: str = None,
        area: str = None,
        telephone: str = None,
        cell_phone: str = None,
        address: str = None,
        profession: str = None,
        email: str = None,
        birth_date: datetime = None,
        next_visit: datetime = None,
        comments: str = None
    ) -> bool:
        """Update patient record in .dat file."""
        patient = PatientManager.get_patient(code)
        if not patient:
            return False

        # Update fields
        if surname is not None:
            patient.surname = trim(surname)
        if name is not None:
            patient.name = trim(name)
        if father_name is not None:
            patient.father_name = trim(father_name)
        if mother_name is not None:
            patient.mother_name = trim(mother_name)
        if area is not None:
            patient.area = trim(area)
        if telephone is not None:
            patient.telephone = trim(telephone)
        if cell_phone is not None:
            patient.cell_phone = trim(cell_phone)
        if address is not None:
            patient.address = trim(address)
        if profession is not None:
            patient.profession = trim(profession)
        if email is not None:
            patient.email = trim(email)
        if birth_date is not None:
            patient.birth_date = birth_date
        if next_visit is not None:
            patient.next_visit = next_visit
        if comments is not None:
            patient.comments = trim(comments)

        filepath = PatientManager.get_patient_filepath(code)
        return PatientManager._write_dat_file(filepath, patient)

    @staticmethod
    def delete_patient(code: str) -> bool:
        """Delete patient .dat file."""
        filepath = PatientManager.get_patient_filepath(code)
        if filepath.exists():
            try:
                filepath.unlink()
                return True
            except Exception:
                return False
        return False

    @staticmethod
    def search_by_name(query: str) -> List[Patient]:
        """Search patients by name or surname from .dat files."""
        all_patients = PatientManager.get_all_patients()
        results = []
        query_lower = query.lower().strip()

        for patient in all_patients:
            search_text = f"{patient.surname} {patient.name} {patient.father_name}".lower()
            if query_lower in search_text or greek_equal(query_lower, search_text):
                results.append(patient)

        return results

    @staticmethod
    def search_by_code(query: str) -> List[Patient]:
        """Search patients by code from .dat files."""
        all_patients = PatientManager.get_all_patients()
        results = []
        query_upper = uppercase(trim(query))

        for patient in all_patients:
            if query_upper in uppercase(patient.code):
                results.append(patient)

        return results

    @staticmethod
    def search_fuzzy(query: str) -> List[Patient]:
        """Fuzzy search with Greek tolerance from .dat files."""
        all_patients = PatientManager.get_all_patients()
        results = []
        query_normalized = query.lower().strip()

        for patient in all_patients:
            search_text = f"{patient.surname} {patient.name} {patient.father_name} {patient.telephone} {patient.cell_phone}".lower()
            if greek_equal(query_normalized, search_text) or query_normalized in search_text:
                results.append(patient)

        return results

    @staticmethod
    def get_all_patients() -> List[Patient]:
        """Get all patients from .dat files."""
        patients = []
        database_dir = PatientManager.get_database_dir()

        if not database_dir.exists():
            return patients

        for dat_file in database_dir.glob("*.dat"):
            try:
                data = PatientManager._read_dat_file(dat_file)
                if data.get('CODE'):
                    patient = PatientManager._data_to_patient(data)
                    patients.append(patient)
            except Exception as e:
                print(f"Error reading {dat_file}: {e}")
                continue

        return patients

    @staticmethod
    def get_patient_count() -> int:
        """Get total patient count."""
        return len(PatientManager.get_all_patients())

    @staticmethod
    def validate_telephone(phone: str) -> bool:
        """Validate telephone number format."""
        digits = re.sub(r'\D', '', phone)
        return len(digits) >= 6 and len(digits) <= 15

    @staticmethod
    def validate_email(email: str) -> bool:
        """Validate email format."""
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return bool(re.match(pattern, email))

    @staticmethod
    def format_patient_display(patient: Patient) -> str:
        """Format patient information for display."""
        lines = [
            f"Code: {patient.code}",
            f"Name: {patient.surname} {patient.name}",
            f"Father: {patient.father_name}" if patient.father_name else None,
            f"Telephone: {patient.telephone}" if patient.telephone else None,
            f"Cell: {patient.cell_phone}" if patient.cell_phone else None,
            f"Area: {patient.area}" if patient.area else None,
        ]
        return "\n".join(line for line in lines if line)

    @staticmethod
    def calculate_age(birth_date: datetime) -> int:
        """Calculate age from birth date."""
        if not birth_date:
            return 0
        today = datetime.now()
        age = today.year - birth_date.year
        if (today.month, today.day) < (birth_date.month, birth_date.day):
            age -= 1
        return age

    @staticmethod
    def export_patients_csv(filepath: str) -> bool:
        """Export patients to CSV file."""
        try:
            patients = PatientManager.get_all_patients()
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write("Code,Surname,Name,Father Name,Telephone,Cell Phone,Area,Email\n")
                for p in patients:
                    f.write(f'"{p.code}","{p.surname}","{p.name}","{p.father_name}","{p.telephone}","{p.cell_phone}","{p.area}","{p.email}"\n')
            return True
        except Exception:
            return False

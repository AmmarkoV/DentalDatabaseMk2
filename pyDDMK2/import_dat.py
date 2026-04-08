"""
Import patients from legacy .dat files.
"""
import re
import os
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

from people import PatientManager, Patient
from database import db
from translations import translate_en_to_gr as T


class DATImporter:
    """Imports patients from legacy .dat files."""

    def __init__(self, database_dir: str = None):
        if database_dir:
            self.database_dir = Path(database_dir)
        else:
            from tools import get_app_path
            self.database_dir = get_app_path() / "Database"

    def parse_dat_file(self, filepath: Path) -> Dict:
        """Parse a .dat file and return patient data."""
        data = {}
        works = []

        try:
            with open(filepath, 'r', encoding='windows-1253') as f:
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
                            # Parse WORK entries: desc,price,discount,paid,comments,user,day,month,year
                            parts = value.split(',')
                            if len(parts) >= 9:
                                works.append({
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

        except UnicodeDecodeError:
            # Try UTF-8 as fallback
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    for line in f:
                        line = line.strip()
                        if not line:
                            continue
                        match = re.match(r'^(\w+)\((.*)\)$', line)
                        if match:
                            key = match.group(1).upper()
                            value = match.group(2)
                            if key == 'WORK':
                                parts = value.split(',')
                                if len(parts) >= 9:
                                    works.append({
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
            except Exception as e:
                raise Exception(f"Could not decode file: {e}")

        data['works'] = works
        return data

    def parse_date(self, date_str: str) -> Optional[datetime]:
        """Parse date from DAT format (DD,MM,YYYY)."""
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

    def import_patient(self, filepath: Path) -> Optional[Patient]:
        """Import a single patient from a .dat file."""
        data = self.parse_dat_file(filepath)

        # Extract fields
        code = data.get('CODE', '').strip()
        surname = data.get('SURNAME', '').strip()
        name = data.get('NAME', '').strip()
        area = data.get('AREA', '').strip()
        telephone = data.get('TELEPHONE', '').strip()
        profession = data.get('PROFESSION', '').strip()
        cellphone = data.get('CELLPHONE', '').strip()
        address = data.get('ADDRESS', '').strip()
        email = data.get('EMAIL', '').strip()
        birth_str = data.get('BIRTH', '')
        next_str = data.get('NEXT_APPOINTMENT', '')

        # Parse dates
        birth_date = self.parse_date(birth_str) if birth_str else None
        next_visit = self.parse_date(next_str) if next_str else None

        # Check if patient already exists
        existing = db.get_patient(code) if code else None
        if existing:
            return None  # Skip existing patients

        # Create patient
        patient = PatientManager.create_patient(
            surname=surname,
            name=name,
            area=area,
            telephone=telephone,
            cell_phone=cellphone,
            address=address,
            profession=profession,
            email=email,
            birth_date=birth_date,
            next_visit=next_visit
        )

        return patient

    def import_all_patients(self) -> Tuple[int, int, List[str]]:
        """Import all patients from .dat files in database directory."""
        imported = 0
        skipped = 0
        errors = []

        if not self.database_dir.exists():
            errors.append(f"Database directory not found: {self.database_dir}")
            return imported, skipped, errors

        dat_files = list(self.database_dir.glob("*.dat"))

        for dat_file in dat_files:
            try:
                patient = self.import_patient(dat_file)
                if patient:
                    imported += 1
                else:
                    skipped += 1  # Already exists or empty
            except Exception as e:
                errors.append(f"Error importing {dat_file.name}: {str(e)}")
                skipped += 1

        return imported, skipped, errors

    def get_patient_list(self) -> List[Tuple[str, str, str]]:
        """Get list of patients in .dat files as (code, surname, name)."""
        patients = []

        if not self.database_dir.exists():
            return patients

        for dat_file in self.database_dir.glob("*.dat"):
            try:
                data = self.parse_dat_file(dat_file)
                code = data.get('CODE', '')
                surname = data.get('SURNAME', '')
                name = data.get('NAME', '')
                if code and surname:
                    patients.append((code, surname, name))
            except Exception:
                pass

        return sorted(patients, key=lambda x: x[1])  # Sort by surname

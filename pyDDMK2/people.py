"""
Patient management module.
Ported from people.pas
"""
import re
from datetime import datetime
from typing import List, Optional

from models import Patient, PatientStatus
from database import db
from random_generators import generate_random_alphanumeric
from string_stuff import trim, uppercase
from translations import greek_equal

class PatientManager:
    """Manages patient operations."""

    @staticmethod
    def generate_patient_code() -> str:
        """Generate a unique patient code."""
        while True:
            code = generate_random_alphanumeric(6).upper()
            if not db.get_patient(code):
                return code

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
        comments: str = ""
    ) -> Optional[Patient]:
        """Create a new patient record."""
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
            comments=trim(comments)
        )

        if db.create_patient(patient):
            return patient
        return None

    @staticmethod
    def get_patient(code: str) -> Optional[Patient]:
        """Retrieve patient by code."""
        return db.get_patient(code)

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
        status: PatientStatus = None,
        comments: str = None
    ) -> bool:
        """Update patient record."""
        patient = db.get_patient(code)
        if not patient:
            return False

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
        if status is not None:
            patient.status = status
        if comments is not None:
            patient.comments = trim(comments)

        return db.update_patient(patient)

    @staticmethod
    def delete_patient(code: str) -> bool:
        """Delete patient record."""
        return db.delete_patient(code)

    @staticmethod
    def search_by_name(query: str) -> List[Patient]:
        """Search patients by name or surname."""
        return db.search_patients(query)

    @staticmethod
    def search_by_code(query: str) -> List[Patient]:
        """Search patients by code."""
        all_patients = db.get_all_patients()
        results = []
        query_upper = uppercase(trim(query))
        for patient in all_patients:
            if query_upper in uppercase(patient.code):
                results.append(patient)
        return results

    @staticmethod
    def search_fuzzy(query: str) -> List[Patient]:
        """Fuzzy search with Greek tolerance."""
        all_patients = db.get_all_patients()
        results = []
        query_normalized = query.lower().strip()

        for patient in all_patients:
            search_text = patient.search_text()
            if greek_equal(query_normalized, search_text) or query_normalized in search_text:
                results.append(patient)

        return results

    @staticmethod
    def get_all_patients() -> List[Patient]:
        """Get all patients."""
        return db.get_all_patients()

    @staticmethod
    def get_patient_count() -> int:
        """Get total patient count."""
        return len(db.get_all_patients())

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
            patients = db.get_all_patients()
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write("Code,Surname,Name,Father Name,Telephone,Cell Phone,Area,Email\n")
                for p in patients:
                    f.write(f'"{p.code}","{p.surname}","{p.name}","{p.father_name}","{p.telephone}","{p.cell_phone}","{p.area}","{p.email}"\n')
            return True
        except Exception:
            return False

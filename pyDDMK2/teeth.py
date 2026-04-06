"""
Dental teeth data management.
Ported from teeth.pas
"""
from datetime import datetime
from typing import List, Optional

from models import Tooth
from database import db

# Tooth surface designations (Universal/FDI notation)
SURFACE_CODES = {
    'M': 'Mesial',
    'D': 'Distal',
    'O': 'Occlusal',
    'B': 'Buccal',
    'L': 'Lingual',
    'I': 'Incisal',
}

# Tooth categories by number (FDI notation)
TOOTH_TYPES = {
    1: 'Central Incisor',
    2: 'Lateral Incisor',
    3: 'Canine',
    4: 'First Premolar',
    5: 'Second Premolar',
    6: 'First Molar',
    7: 'Second Molar',
    8: 'Third Molar',
}

class TeethManager:
    """Manages dental teeth data."""

    @staticmethod
    def get_all_teeth(patient_code: str) -> List[Tooth]:
        """Get all teeth records for a patient."""
        # Note: Database layer needs teeth queries added
        # This is a placeholder implementation
        return []

    @staticmethod
    def get_tooth(patient_code: str, tooth_number: int, surface: str = "") -> Optional[Tooth]:
        """Get specific tooth record."""
        teeth = TeethManager.get_all_teeth(patient_code)
        for tooth in teeth:
            if tooth.tooth_number == tooth_number and tooth.surface == surface:
                return tooth
        return None

    @staticmethod
    def create_tooth(
        patient_code: str,
        tooth_number: int,
        surface: str = "",
        treatment_type: str = "",
        notes: str = "",
        treatment_date: datetime = None,
        doctor_code: str = ""
    ) -> Optional[Tooth]:
        """Create a new tooth record."""
        tooth = Tooth(
            patient_code=patient_code,
            tooth_number=tooth_number,
            surface=surface,
            notes=notes,
            treatment_date=treatment_date or datetime.now(),
            doctor_code=doctor_code
        )

        # Set treatment type flags
        treatment_lower = treatment_type.lower()
        if 'filling' in treatment_lower or 'συμπλήρωμα' in treatment_lower:
            tooth.filling = True
        if 'crown' in treatment_lower or 'στέμμα' in treatment_lower:
            tooth.crown = True
        if 'bridge' in treatment_lower or 'γέφυρα' in treatment_lower:
            tooth.bridge = True
        if 'implant' in treatment_lower or ' εμφύτευμα' in treatment_lower:
            tooth.implant = True
        if 'extraction' in treatment_lower or 'εκχύλιση' in treatment_lower:
            tooth.extraction = True
        if 'root canal' in treatment_lower or 'ρίζα' in treatment_lower:
            tooth.root_canal = True
        if 'scaling' in treatment_lower or 'κλίμακα' in treatment_lower:
            tooth.scaling = True

        # TODO: Add database insert
        return tooth

    @staticmethod
    def update_tooth(
        patient_code: str,
        tooth_number: int,
        surface: str = "",
        **kwargs
    ) -> bool:
        """Update tooth record."""
        tooth = TeethManager.get_tooth(patient_code, tooth_number, surface)
        if not tooth:
            return False

        for key, value in kwargs.items():
            if hasattr(tooth, key):
                setattr(tooth, key, value)

        # TODO: Add database update
        return True

    @staticmethod
    def delete_tooth(patient_code: str, tooth_number: int, surface: str = "") -> bool:
        """Delete tooth record."""
        # TODO: Add database delete
        return True

    @staticmethod
    def mark_tooth_missing(patient_code: str, tooth_number: int) -> bool:
        """Mark tooth as missing."""
        return TeethManager.update_tooth(
            patient_code, tooth_number,
            missing=True
        )

    @staticmethod
    def mark_tooth_impacted(patient_code: str, tooth_number: int) -> bool:
        """Mark tooth as impacted."""
        return TeethManager.update_tooth(
            patient_code, tooth_number,
            impacted=True
        )

    @staticmethod
    def mark_tooth_decayed(patient_code: str, tooth_number: int) -> bool:
        """Mark tooth as having decay."""
        return TeethManager.update_tooth(
            patient_code, tooth_number,
            decayed=True
        )

    @staticmethod
    def get_tooth_type_name(tooth_number: int) -> str:
        """Get human-readable tooth type name."""
        # Extract tooth type from FDI notation
        # FDI: first digit = quadrant, second digit = tooth type (1-8)
        if tooth_number < 10:
            tooth_type = tooth_number
        else:
            tooth_type = tooth_number % 10

        return TOOTH_TYPES.get(tooth_type, "Unknown")

    @staticmethod
    def get_quadrant_name(fdi_number: int) -> str:
        """Get quadrant name from FDI number."""
        if fdi_number < 10:
            quadrant = fdi_number
        else:
            quadrant = fdi_number // 10

        quadrants = {
            1: "Upper Right",
            2: "Upper Left",
            3: "Lower Left",
            4: "Lower Right",
        }
        return quadrants.get(quadrant, "Unknown")

    @staticmethod
    def get_surface_name(code: str) -> str:
        """Get surface name from code."""
        return SURFACE_CODES.get(code, code)

    @staticmethod
    def format_tooth_display(tooth: Tooth) -> str:
        """Format tooth information for display."""
        lines = [
            f"Tooth: {tooth.tooth_number} ({TeethManager.get_tooth_type_name(tooth.tooth_number)})",
            f"Surface: {tooth.surface}" if tooth.surface else None,
        ]

        treatments = []
        if tooth.filling:
            treatments.append("Filling")
        if tooth.crown:
            treatments.append("Crown")
        if tooth.bridge:
            treatments.append("Bridge")
        if tooth.implant:
            treatments.append("Implant")
        if tooth.root_canal:
            treatments.append("Root Canal")
        if tooth.extraction:
            treatments.append("Extraction")

        if treatments:
            lines.append(f"Treatments: {', '.join(treatments)}")

        if tooth.missing:
            lines.append("Status: Missing")
        if tooth.impacted:
            lines.append("Status: Impacted")
        if tooth.decayed:
            lines.append("Status: Decayed")

        if tooth.notes:
            lines.append(f"Notes: {tooth.notes}")

        return "\n".join(line for line in lines if line)

    @staticmethod
    def get_patient_teeth_summary(patient_code: str) -> dict:
        """Get summary of patient's dental status."""
        teeth = TeethManager.get_all_teeth(patient_code)

        summary = {
            'total_treated': 0,
            'fillings': 0,
            'crowns': 0,
            'bridges': 0,
            'implants': 0,
            'extractions': 0,
            'root_canals': 0,
            'missing': 0,
            'impacted': 0,
            'decayed': 0,
        }

        for tooth in teeth:
            summary['total_treated'] += 1
            if tooth.filling:
                summary['fillings'] += 1
            if tooth.crown:
                summary['crowns'] += 1
            if tooth.bridge:
                summary['bridges'] += 1
            if tooth.implant:
                summary['implants'] += 1
            if tooth.extraction:
                summary['extractions'] += 1
            if tooth.root_canal:
                summary['root_canals'] += 1
            if tooth.missing:
                summary['missing'] += 1
            if tooth.impacted:
                summary['impacted'] += 1
            if tooth.decayed:
                summary['decayed'] += 1

        return summary

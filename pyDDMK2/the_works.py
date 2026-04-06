"""
Dental procedures/works management.
Ported from the_works.pas
"""
from datetime import datetime
from typing import List, Optional
import uuid

from models import Work, WorkType, Payment
from database import db
from people import PatientManager


class WorksManager:
    """Manages dental works/procedures."""

    @staticmethod
    def generate_work_id() -> str:
        """Generate unique work ID."""
        return f"W{datetime.now().strftime('%Y%m%d%H%M%S')}{uuid.uuid4().hex[:4].upper()}"

    @staticmethod
    def create_work(
        patient_code: str,
        work_type_code: str,
        tooth_number: int = 0,
        surfaces: str = "",
        price: float = 0.0,
        discount: float = 0.0,
        status: str = "planned",
        date_planned: datetime = None,
        doctor_code: str = "",
        comments: str = ""
    ) -> Optional[Work]:
        """Create a new work record."""
        work_type = db.get_work_type(work_type_code)
        if not work_type:
            # Use base price if work type not found
            base_price = price
        else:
            base_price = work_type.base_price if price == 0 else price

        final_price = base_price - discount

        work = Work(
            id=WorksManager.generate_work_id(),
            patient_code=patient_code,
            work_type_code=work_type_code,
            tooth_number=tooth_number,
            surfaces=surfaces,
            price=base_price,
            discount=discount,
            final_price=final_price,
            status=status,
            date_planned=date_planned or datetime.now(),
            doctor_code=doctor_code,
            comments=comments
        )

        if db.create_work(work):
            return work
        return None

    @staticmethod
    def get_work(work_id: str) -> Optional[Work]:
        """Get work by ID."""
        works = db.get_works_by_patient("")  # This needs fixing
        for work in works:
            if work.id == work_id:
                return work
        return None

    @staticmethod
    def get_works_by_patient(patient_code: str) -> List[Work]:
        """Get all works for a patient."""
        return db.get_works_by_patient(patient_code)

    @staticmethod
    def update_work(
        work_id: str,
        work_type_code: str = None,
        tooth_number: int = None,
        surfaces: str = None,
        price: float = None,
        discount: float = None,
        status: str = None,
        date_planned: datetime = None,
        date_completed: datetime = None,
        doctor_code: str = None,
        comments: str = None
    ) -> bool:
        """Update work record."""
        # TODO: Implement update
        return False

    @staticmethod
    def delete_work(work_id: str) -> bool:
        """Delete work record."""
        # TODO: Implement delete
        return False

    @staticmethod
    def complete_work(work_id: str, doctor_code: str = "") -> bool:
        """Mark work as completed."""
        # TODO: Implement
        return False

    @staticmethod
    def cancel_work(work_id: str) -> bool:
        """Cancel a work."""
        # TODO: Implement
        return False

    @staticmethod
    def get_works_by_status(patient_code: str, status: str) -> List[Work]:
        """Get works filtered by status."""
        works = WorksManager.get_works_by_patient(patient_code)
        return [w for w in works if w.status == status]

    @staticmethod
    def get_pending_works(patient_code: str) -> List[Work]:
        """Get pending/planned works for a patient."""
        return WorksManager.get_works_by_status(patient_code, "planned")

    @staticmethod
    def get_completed_works(patient_code: str) -> List[Work]:
        """Get completed works for a patient."""
        return WorksManager.get_works_by_status(patient_code, "completed")

    @staticmethod
    def calculate_patient_total(patient_code: str, status: str = None) -> float:
        """Calculate total cost of works for a patient."""
        works = WorksManager.get_works_by_patient(patient_code)
        if status:
            works = [w for w in works if w.status == status]
        return sum(w.final_price - w.discount for w in works)

    @staticmethod
    def format_work_display(work: Work) -> str:
        """Format work information for display."""
        work_type = db.get_work_type(work.work_type_code)
        desc = work_type.description_gr if work_type else work.work_type_code

        lines = [
            f"Work ID: {work.id}",
            f"Procedure: {desc}",
        ]

        if work.tooth_number > 0:
            lines.append(f"Tooth: {work.tooth_number}")
        if work.surfaces:
            lines.append(f"Surfaces: {work.surfaces}")

        lines.extend([
            f"Price: €{work.price:.2f}",
            f"Discount: €{work.discount:.2f}",
            f"Final: €{work.final_price - work.discount:.2f}",
            f"Status: {work.status}",
        ])

        if work.date_planned:
            lines.append(f"Planned: {work.date_planned.strftime('%Y-%m-%d')}")
        if work.date_completed:
            lines.append(f"Completed: {work.date_completed.strftime('%Y-%m-%d')}")

        return "\n".join(lines)


class WorkTypeManager:
    """Manages work type catalog."""

    # Default work types (Greek/English)
    DEFAULT_WORK_TYPES = [
        ("FILLING", "Filling", "Απόφραξη/Γέμισμα", 30.0, "Restorative"),
        ("CROWN", "Crown", "Στέμμα", 150.0, "Restorative"),
        ("BRIDGE", "Bridge", "Γέφυρα", 200.0, "Restorative"),
        ("IMPLANT", "Implant", "Εμφύτευμα", 500.0, "Surgical"),
        ("EXTRACTION", "Extraction", "Εκχύλιση", 40.0, "Surgical"),
        ("ROOT_CANAL", "Root Canal Treatment", "Αγωγή Ρίζας", 80.0, "Endodontics"),
        ("SCALING", "Scaling/Polishing", "Τακτοποίηση/Πολίρισμα", 50.0, "Preventive"),
        ("WHITENING", "Teeth Whitening", "Λευκαντικό Οδόντων", 100.0, "Cosmetic"),
        ("SEALANT", "Sealant", "Σφράγιση", 20.0, "Preventive"),
        ("EXAM", "Examination", "Εξέταση", 25.0, "Consultation"),
        ("XRAY_SINGLE", "X-Ray Single", "Ακτινογραφία Μία", 15.0, "Diagnostic"),
        ("XRAY_FULL", "X-Ray Full Mouth", "Πλήρης Ακτινογραφία", 60.0, "Diagnostic"),
        ("PANORAMIC", "Panoramic X-Ray", "Πανοραμική", 30.0, "Diagnostic"),
        ("EMERGENCY", "Emergency Visit", "Επείγουσα Επίσκεψη", 50.0, "Consultation"),
    ]

    @staticmethod
    def initialize_default_types() -> int:
        """Initialize database with default work types. Returns count added."""
        added = 0
        for code, desc_en, desc_gr, price, category in WorkTypeManager.DEFAULT_WORK_TYPES:
            existing = db.get_work_type(code)
            if not existing:
                work_type = WorkType(
                    code=code,
                    description_en=desc_en,
                    description_gr=desc_gr,
                    base_price=price,
                    is_active=True,
                    category=category
                )
                if db.add_work_type(work_type):
                    added += 1
        return added

    @staticmethod
    def get_all_work_types() -> List[WorkType]:
        """Get all active work types."""
        return db.get_all_work_types()

    @staticmethod
    def get_work_types_by_category(category: str) -> List[WorkType]:
        """Get work types by category."""
        all_types = WorkTypeManager.get_all_work_types()
        return [wt for wt in all_types if wt.category == category]

    @staticmethod
    def add_work_type(
        code: str,
        description_en: str,
        description_gr: str,
        base_price: float = 0.0,
        category: str = ""
    ) -> bool:
        """Add a new work type."""
        work_type = WorkType(
            code=code.upper(),
            description_en=description_en,
            description_gr=description_gr,
            base_price=base_price,
            is_active=True,
            category=category
        )
        return db.add_work_type(work_type)

    @staticmethod
    def update_work_type(
        code: str,
        description_en: str = None,
        description_gr: str = None,
        base_price: float = None,
        is_active: bool = None,
        category: str = None
    ) -> bool:
        """Update work type."""
        # TODO: Implement
        return False

    @staticmethod
    def delete_work_type(code: str) -> bool:
        """Delete work type."""
        # TODO: Implement
        return False

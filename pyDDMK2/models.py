"""
Data models for the dental database.
Ported from various .pas record definitions
"""
from dataclasses import dataclass, field
from datetime import datetime, date
from typing import List, Optional, Dict, Any
from enum import Enum

class PatientStatus(Enum):
    ACTIVE = "active"
    INACTIVE = "inactive"
    ARCHIVED = "archived"

class PaymentStatus(Enum):
    UNPAID = "unpaid"
    PARTIAL = "partial"
    PAID = "paid"
    CANCELLED = "cancelled"

@dataclass
class User:
    """User account model."""
    username: str
    password_hash: str
    full_name: str = ""
    email: str = ""
    is_admin: bool = False
    is_active: bool = True
    created_at: datetime = field(default_factory=datetime.now)
    last_login: Optional[datetime] = None

@dataclass
class Patient:
    """Patient record model."""
    code: str = ""  # Unique patient code
    surname: str = ""
    name: str = ""
    father_name: str = ""
    mother_name: str = ""
    area: str = ""
    telephone: str = ""
    cell_phone: str = ""
    address: str = ""
    profession: str = ""
    email: str = ""
    birth_date: Optional[datetime] = None
    next_visit: Optional[datetime] = None
    status: PatientStatus = PatientStatus.ACTIVE
    comments: str = ""
    works: List[Dict[str, Any]] = field(default_factory=list)  # Legacy works from .dat files
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: Optional[datetime] = None

    def get_full_name(self) -> str:
        return f"{self.surname} {self.name}"

    def search_text(self) -> str:
        """Return searchable text for this patient."""
        return f"{self.surname} {self.name} {self.father_name} {self.code}".lower()

@dataclass
class Tooth:
    """Dental tooth data model."""
    patient_code: str
    tooth_number: int  # 1-32 for permanent, FDI notation
    surface: str = ""  # Surface designation

    # Treatment types
    filling: bool = False
    crown: bool = False
    bridge: bool = False
    implant: bool = False
    extraction: bool = False
    root_canal: bool = False
    scaling: bool = False
    other: bool = False

    # Status
    missing: bool = False
    impacted: bool = False
    decayed: bool = False

    # Notes
    notes: str = ""
    treatment_date: Optional[datetime] = None
    doctor_code: str = ""

@dataclass
class WorkType:
    """Dental procedure/work type catalog."""
    code: str
    description_en: str
    description_gr: str
    base_price: float = 0.0
    is_active: bool = True
    category: str = ""

@dataclass
class Work:
    """Dental work/procedure record."""
    id: str
    patient_code: str
    work_type_code: str
    tooth_number: int = 0  # 0 if not tooth-specific
    surfaces: str = ""  # Affected surfaces
    price: float = 0.0
    discount: float = 0.0
    final_price: float = 0.0
    status: str = "planned"  # planned, in_progress, completed, cancelled
    date_planned: Optional[datetime] = None
    date_completed: Optional[datetime] = None
    doctor_code: str = ""
    comments: str = ""
    created_at: datetime = field(default_factory=datetime.now)

    @property
    def net_price(self) -> float:
        return self.final_price - self.discount

@dataclass
class Payment:
    """Payment record."""
    id: str
    patient_code: str
    work_id: str = ""  # Optional linked work
    amount: float = 0.0
    payment_method: str = "cash"  # cash, card, insurance
    reference: str = ""  # Reference number or description
    status: PaymentStatus = PaymentStatus.PAID
    date: datetime = field(default_factory=datetime.now)
    doctor_code: str = ""
    comments: str = ""

@dataclass
class Appointment:
    """Calendar appointment model."""
    id: str
    patient_code: str
    date_time: datetime
    duration_minutes: int = 30
    appointment_type: str = "consultation"
    status: str = "scheduled"  # scheduled, confirmed, completed, cancelled, no_show
    notes: str = ""
    doctor_code: str = ""
    created_at: datetime = field(default_factory=datetime.now)

@dataclass
class Setting:
    """Application setting."""
    key: str
    value: str
    category: str = "general"
    description: str = ""


@dataclass
class PatientWork:
    """A work/treatment record for a patient."""
    work_id: str
    price: float = 0.0
    discount: float = 0.0
    paid: float = 0.0
    comments: str = ""
    user: str = ""
    day: int = 0
    month: int = 0
    year: int = 0

    @property
    def date(self) -> Optional[date]:
        """Return work date if valid."""
        if self.year and self.month and self.day:
            try:
                return date(self.year, self.month, self.day)
            except ValueError:
                return None
        return None

    @property
    def outstanding(self) -> float:
        """Amount still owed."""
        return self.price - self.paid


@dataclass
class ToothData:
    """Data for a single tooth surface."""
    tooth_number: int
    part: int  # 1-6: root, lingual, mesial, distal, occlusal, palatal/buccal
    doctor: str = ""
    work: str = ""
    comments: str = ""
    technical: str = ""
    status: str = ""
    color_r: int = 0
    color_g: int = 0
    color_b: int = 0


@dataclass
class ToothAux:
    """Auxiliary tooth data (crown, extraction, etc.)."""
    tooth_number: int
    aux_code: str  # VIDA, SEALANT, X, O.O., etc.

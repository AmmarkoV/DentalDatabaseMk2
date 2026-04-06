"""
Database layer for data persistence.
Ported from ddatabase.pas and related database modules
"""
import json
import sqlite3
from pathlib import Path
from typing import List, Optional, Dict, Any
from datetime import datetime
from contextlib import contextmanager

from models import (
    User, Patient, Tooth, Work, WorkType, Payment, Appointment, Setting,
    PatientStatus, PaymentStatus
)
from tools import get_data_path

# Database file path
DB_PATH = get_data_path() / "dental_database.db"

class Database:
    """Database manager using SQLite for persistence."""

    _instance: Optional['Database'] = None

    def __new__(cls):
        """Singleton pattern."""
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._initialized = False
        return cls._instance

    def __init__(self):
        if self._initialized:
            return
        self._initialized = True
        self._conn: Optional[sqlite3.Connection] = None
        self._init_database()

    def _get_connection(self) -> sqlite3.Connection:
        """Get database connection."""
        if self._conn is None:
            self._conn = sqlite3.connect(str(DB_PATH))
            self._conn.row_factory = sqlite3.Row
        return self._conn

    @contextmanager
    def transaction(self):
        """Context manager for database transactions."""
        conn = self._get_connection()
        try:
            yield conn
            conn.commit()
        except Exception:
            conn.rollback()
            raise

    def _init_database(self):
        """Initialize database schema."""
        conn = self._get_connection()
        cursor = conn.cursor()

        # Users table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                username TEXT PRIMARY KEY,
                password_hash TEXT NOT NULL,
                full_name TEXT,
                email TEXT,
                is_admin INTEGER DEFAULT 0,
                is_active INTEGER DEFAULT 1,
                created_at TEXT,
                last_login TEXT
            )
        ''')

        # Patients table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS patients (
                code TEXT PRIMARY KEY,
                surname TEXT NOT NULL,
                name TEXT NOT NULL,
                father_name TEXT,
                mother_name TEXT,
                area TEXT,
                telephone TEXT,
                cell_phone TEXT,
                address TEXT,
                profession TEXT,
                email TEXT,
                birth_date TEXT,
                next_visit TEXT,
                status TEXT DEFAULT 'active',
                comments TEXT,
                created_at TEXT,
                updated_at TEXT
            )
        ''')

        # Teeth table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS teeth (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                patient_code TEXT NOT NULL,
                tooth_number INTEGER NOT NULL,
                surface TEXT,
                filling INTEGER DEFAULT 0,
                crown INTEGER DEFAULT 0,
                bridge INTEGER DEFAULT 0,
                implant INTEGER DEFAULT 0,
                extraction INTEGER DEFAULT 0,
                root_canal INTEGER DEFAULT 0,
                scaling INTEGER DEFAULT 0,
                other INTEGER DEFAULT 0,
                missing INTEGER DEFAULT 0,
                impacted INTEGER DEFAULT 0,
                decayed INTEGER DEFAULT 0,
                notes TEXT,
                treatment_date TEXT,
                doctor_code TEXT,
                UNIQUE(patient_code, tooth_number, surface)
            )
        ''')

        # Work types catalog
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS work_types (
                code TEXT PRIMARY KEY,
                description_en TEXT,
                description_gr TEXT,
                base_price REAL DEFAULT 0,
                is_active INTEGER DEFAULT 1,
                category TEXT
            )
        ''')

        # Works table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS works (
                id TEXT PRIMARY KEY,
                patient_code TEXT NOT NULL,
                work_type_code TEXT,
                tooth_number INTEGER DEFAULT 0,
                surfaces TEXT,
                price REAL DEFAULT 0,
                discount REAL DEFAULT 0,
                final_price REAL DEFAULT 0,
                status TEXT DEFAULT 'planned',
                date_planned TEXT,
                date_completed TEXT,
                doctor_code TEXT,
                comments TEXT,
                created_at TEXT,
                FOREIGN KEY (patient_code) REFERENCES patients(code)
            )
        ''')

        # Payments table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS payments (
                id TEXT PRIMARY KEY,
                patient_code TEXT NOT NULL,
                work_id TEXT,
                amount REAL DEFAULT 0,
                payment_method TEXT DEFAULT 'cash',
                reference TEXT,
                status TEXT DEFAULT 'paid',
                date TEXT,
                doctor_code TEXT,
                comments TEXT,
                FOREIGN KEY (patient_code) REFERENCES patients(code)
            )
        ''')

        # Appointments table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS appointments (
                id TEXT PRIMARY KEY,
                patient_code TEXT NOT NULL,
                date_time TEXT NOT NULL,
                duration_minutes INTEGER DEFAULT 30,
                appointment_type TEXT DEFAULT 'consultation',
                status TEXT DEFAULT 'scheduled',
                notes TEXT,
                doctor_code TEXT,
                created_at TEXT,
                FOREIGN KEY (patient_code) REFERENCES patients(code)
            )
        ''')

        # Settings table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS settings (
                key TEXT PRIMARY KEY,
                value TEXT,
                category TEXT DEFAULT 'general',
                description TEXT
            )
        ''')

        # Create indexes
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_patients_surname ON patients(surname)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_patients_name ON patients(name)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_teeth_patient ON teeth(patient_code)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_works_patient ON works(patient_code)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_payments_patient ON payments(patient_code)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_appointments_datetime ON appointments(date_time)')

        conn.commit()

    # ============ USER OPERATIONS ============

    def create_user(self, user: User) -> bool:
        """Create a new user."""
        conn = self._get_connection()
        cursor = conn.cursor()
        try:
            cursor.execute('''
                INSERT INTO users (username, password_hash, full_name, email, is_admin, is_active, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', (
                user.username, user.password_hash, user.full_name, user.email,
                1 if user.is_admin else 0, 1 if user.is_active else 0,
                user.created_at.isoformat() if user.created_at else datetime.now().isoformat()
            ))
            conn.commit()
            return True
        except Exception as e:
            return False

    def get_user(self, username: str) -> Optional[User]:
        """Get user by username."""
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM users WHERE username = ?', (username,))
        row = cursor.fetchone()
        if row:
            return User(
                username=row['username'],
                password_hash=row['password_hash'],
                full_name=row['full_name'] or '',
                email=row['email'] or '',
                is_admin=bool(row['is_admin']),
                is_active=bool(row['is_active']),
                created_at=datetime.fromisoformat(row['created_at']) if row['created_at'] else None,
                last_login=datetime.fromisoformat(row['last_login']) if row['last_login'] else None
            )
        return None

    def update_user(self, user: User) -> bool:
        """Update user."""
        conn = self._get_connection()
        cursor = conn.cursor()
        try:
            cursor.execute('''
                UPDATE users SET password_hash=?, full_name=?, email=?, is_admin=?, is_active=?, last_login=?
                WHERE username=?
            ''', (
                user.password_hash, user.full_name, user.email,
                1 if user.is_admin else 0, 1 if user.is_active else 0,
                user.last_login.isoformat() if user.last_login else None,
                user.username
            ))
            conn.commit()
            return True
        except Exception:
            return False

    def delete_user(self, username: str) -> bool:
        """Delete user."""
        conn = self._get_connection()
        cursor = conn.cursor()
        try:
            cursor.execute('DELETE FROM users WHERE username = ?', (username,))
            conn.commit()
            return True
        except Exception:
            return False

    def get_all_users(self) -> List[User]:
        """Get all users."""
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM users ORDER BY full_name')
        rows = cursor.fetchall()
        return [
            User(
                username=row['username'],
                password_hash=row['password_hash'],
                full_name=row['full_name'] or '',
                email=row['email'] or '',
                is_admin=bool(row['is_admin']),
                is_active=bool(row['is_active']),
                created_at=datetime.fromisoformat(row['created_at']) if row['created_at'] else None,
                last_login=datetime.fromisoformat(row['last_login']) if row['last_login'] else None
            )
            for row in rows
        ]

    # ============ PATIENT OPERATIONS ============

    def create_patient(self, patient: Patient) -> bool:
        """Create a new patient."""
        conn = self._get_connection()
        cursor = conn.cursor()
        try:
            cursor.execute('''
                INSERT INTO patients (
                    code, surname, name, father_name, mother_name, area,
                    telephone, cell_phone, address, profession, email,
                    birth_date, next_visit, status, comments, created_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                patient.code, patient.surname, patient.name, patient.father_name,
                patient.mother_name, patient.area, patient.telephone, patient.cell_phone,
                patient.address, patient.profession, patient.email,
                patient.birth_date.isoformat() if patient.birth_date else None,
                patient.next_visit.isoformat() if patient.next_visit else None,
                patient.status.value, patient.comments,
                patient.created_at.isoformat() if patient.created_at else datetime.now().isoformat()
            ))
            conn.commit()
            return True
        except Exception:
            return False

    def get_patient(self, code: str) -> Optional[Patient]:
        """Get patient by code."""
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM patients WHERE code = ?', (code,))
        row = cursor.fetchone()
        if row:
            return Patient(
                code=row['code'],
                surname=row['surname'],
                name=row['name'],
                father_name=row['father_name'] or '',
                mother_name=row['mother_name'] or '',
                area=row['area'] or '',
                telephone=row['telephone'] or '',
                cell_phone=row['cell_phone'] or '',
                address=row['address'] or '',
                profession=row['profession'] or '',
                email=row['email'] or '',
                birth_date=datetime.fromisoformat(row['birth_date']) if row['birth_date'] else None,
                next_visit=datetime.fromisoformat(row['next_visit']) if row['next_visit'] else None,
                status=PatientStatus(row['status']) if row['status'] else PatientStatus.ACTIVE,
                comments=row['comments'] or '',
                created_at=datetime.fromisoformat(row['created_at']) if row['created_at'] else None,
                updated_at=datetime.fromisoformat(row['updated_at']) if row['updated_at'] else None
            )
        return None

    def update_patient(self, patient: Patient) -> bool:
        """Update patient."""
        conn = self._get_connection()
        cursor = conn.cursor()
        try:
            cursor.execute('''
                UPDATE patients SET
                    surname=?, name=?, father_name=?, mother_name=?, area=?,
                    telephone=?, cell_phone=?, address=?, profession=?, email=?,
                    birth_date=?, next_visit=?, status=?, comments=?, updated_at=?
                WHERE code=?
            ''', (
                patient.surname, patient.name, patient.father_name, patient.mother_name,
                patient.area, patient.telephone, patient.cell_phone, patient.address,
                patient.profession, patient.email,
                patient.birth_date.isoformat() if patient.birth_date else None,
                patient.next_visit.isoformat() if patient.next_visit else None,
                patient.status.value, patient.comments, datetime.now().isoformat(),
                patient.code
            ))
            conn.commit()
            return True
        except Exception:
            return False

    def delete_patient(self, code: str) -> bool:
        """Delete patient."""
        conn = self._get_connection()
        cursor = conn.cursor()
        try:
            cursor.execute('DELETE FROM patients WHERE code = ?', (code,))
            conn.commit()
            return True
        except Exception:
            return False

    def search_patients(self, query: str) -> List[Patient]:
        """Search patients by name, surname, or code."""
        conn = self._get_connection()
        cursor = conn.cursor()
        search_term = f"%{query.lower()}%"
        cursor.execute('''
            SELECT * FROM patients
            WHERE LOWER(surname) LIKE ? OR LOWER(name) LIKE ? OR LOWER(code) LIKE ?
            ORDER BY surname, name
        ''', (search_term, search_term, search_term))
        rows = cursor.fetchall()
        return self._rows_to_patients(rows)

    def get_all_patients(self) -> List[Patient]:
        """Get all patients."""
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM patients ORDER BY surname, name')
        return self._rows_to_patients(cursor.fetchall())

    def _rows_to_patients(self, rows) -> List[Patient]:
        """Convert database rows to Patient objects."""
        patients = []
        for row in rows:
            patients.append(Patient(
                code=row['code'],
                surname=row['surname'],
                name=row['name'],
                father_name=row['father_name'] or '',
                mother_name=row['mother_name'] or '',
                area=row['area'] or '',
                telephone=row['telephone'] or '',
                cell_phone=row['cell_phone'] or '',
                address=row['address'] or '',
                profession=row['profession'] or '',
                email=row['email'] or '',
                birth_date=datetime.fromisoformat(row['birth_date']) if row['birth_date'] else None,
                next_visit=datetime.fromisoformat(row['next_visit']) if row['next_visit'] else None,
                status=PatientStatus(row['status']) if row['status'] else PatientStatus.ACTIVE,
                comments=row['comments'] or '',
                created_at=datetime.fromisoformat(row['created_at']) if row['created_at'] else None,
                updated_at=datetime.fromisoformat(row['updated_at']) if row['updated_at'] else None
            ))
        return patients

    # ============ WORK TYPE OPERATIONS ============

    def get_all_work_types(self) -> List[WorkType]:
        """Get all work types."""
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM work_types WHERE is_active = 1 ORDER BY category, description_en')
        return [
            WorkType(
                code=row['code'],
                description_en=row['description_en'] or '',
                description_gr=row['description_gr'] or '',
                base_price=row['base_price'] or 0.0,
                is_active=bool(row['is_active']),
                category=row['category'] or ''
            )
            for row in cursor.fetchall()
        ]

    def get_work_type(self, code: str) -> Optional[WorkType]:
        """Get work type by code."""
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM work_types WHERE code = ?', (code,))
        row = cursor.fetchone()
        if row:
            return WorkType(
                code=row['code'],
                description_en=row['description_en'] or '',
                description_gr=row['description_gr'] or '',
                base_price=row['base_price'] or 0.0,
                is_active=bool(row['is_active']),
                category=row['category'] or ''
            )
        return None

    def add_work_type(self, work_type: WorkType) -> bool:
        """Add a new work type."""
        conn = self._get_connection()
        cursor = conn.cursor()
        try:
            cursor.execute('''
                INSERT INTO work_types (code, description_en, description_gr, base_price, is_active, category)
                VALUES (?, ?, ?, ?, ?, ?)
            ''', (
                work_type.code, work_type.description_en, work_type.description_gr,
                work_type.base_price, 1 if work_type.is_active else 0, work_type.category
            ))
            conn.commit()
            return True
        except Exception:
            return False

    # ============ WORK OPERATIONS ============

    def create_work(self, work: Work) -> bool:
        """Create a new work record."""
        conn = self._get_connection()
        cursor = conn.cursor()
        try:
            cursor.execute('''
                INSERT INTO works (
                    id, patient_code, work_type_code, tooth_number, surfaces,
                    price, discount, final_price, status, date_planned, date_completed,
                    doctor_code, comments, created_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                work.id, work.patient_code, work.work_type_code, work.tooth_number,
                work.surfaces, work.price, work.discount, work.final_price, work.status,
                work.date_planned.isoformat() if work.date_planned else None,
                work.date_completed.isoformat() if work.date_completed else None,
                work.doctor_code, work.comments,
                work.created_at.isoformat() if work.created_at else datetime.now().isoformat()
            ))
            conn.commit()
            return True
        except Exception:
            return False

    def get_works_by_patient(self, patient_code: str) -> List[Work]:
        """Get all works for a patient."""
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute('''
            SELECT w.*, wt.description_en, wt.description_gr
            FROM works w
            LEFT JOIN work_types wt ON w.work_type_code = wt.code
            WHERE w.patient_code = ?
            ORDER BY w.date_planned DESC
        ''', (patient_code,))
        return self._rows_to_works(cursor.fetchall())

    def _rows_to_works(self, rows) -> List[Work]:
        """Convert database rows to Work objects."""
        works = []
        for row in rows:
            works.append(Work(
                id=row['id'],
                patient_code=row['patient_code'],
                work_type_code=row['work_type_code'] or '',
                tooth_number=row['tooth_number'] or 0,
                surfaces=row['surfaces'] or '',
                price=row['price'] or 0.0,
                discount=row['discount'] or 0.0,
                final_price=row['final_price'] or 0.0,
                status=row['status'] or 'planned',
                date_planned=datetime.fromisoformat(row['date_planned']) if row['date_planned'] else None,
                date_completed=datetime.fromisoformat(row['date_completed']) if row['date_completed'] else None,
                doctor_code=row['doctor_code'] or '',
                comments=row['comments'] or '',
                created_at=datetime.fromisoformat(row['created_at']) if row['created_at'] else None
            ))
        return works

    # ============ PAYMENT OPERATIONS ============

    def create_payment(self, payment: Payment) -> bool:
        """Create a new payment record."""
        conn = self._get_connection()
        cursor = conn.cursor()
        try:
            cursor.execute('''
                INSERT INTO payments (
                    id, patient_code, work_id, amount, payment_method,
                    reference, status, date, doctor_code, comments
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                payment.id, payment.patient_code, payment.work_id, payment.amount,
                payment.payment_method, payment.reference, payment.status.value,
                payment.date.isoformat() if payment.date else datetime.now().isoformat(),
                payment.doctor_code, payment.comments
            ))
            conn.commit()
            return True
        except Exception:
            return False

    def get_payments_by_patient(self, patient_code: str) -> List[Payment]:
        """Get all payments for a patient."""
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute('''
            SELECT * FROM payments WHERE patient_code = ?
            ORDER BY date DESC
        ''', (patient_code,))
        return self._rows_to_payments(cursor.fetchall())

    def _rows_to_payments(self, rows) -> List[Payment]:
        """Convert database rows to Payment objects."""
        payments = []
        for row in rows:
            payments.append(Payment(
                id=row['id'],
                patient_code=row['patient_code'],
                work_id=row['work_id'] or '',
                amount=row['amount'] or 0.0,
                payment_method=row['payment_method'] or 'cash',
                reference=row['reference'] or '',
                status=PaymentStatus(row['status']) if row['status'] else PaymentStatus.PAID,
                date=datetime.fromisoformat(row['date']) if row['date'] else datetime.now(),
                doctor_code=row['doctor_code'] or '',
                comments=row['comments'] or ''
            ))
        return payments

    def get_total_payments(self, start_date: datetime = None, end_date: datetime = None) -> float:
        """Get total payments in date range."""
        conn = self._get_connection()
        cursor = conn.cursor()
        if start_date and end_date:
            cursor.execute('''
                SELECT COALESCE(SUM(amount), 0) as total
                FROM payments
                WHERE status = 'paid'
                AND date >= ? AND date <= ?
            ''', (start_date.isoformat(), end_date.isoformat()))
        else:
            cursor.execute('SELECT COALESCE(SUM(amount), 0) as total FROM payments WHERE status = \'paid\'')
        row = cursor.fetchone()
        return row['total'] or 0.0

    # ============ APPOINTMENT OPERATIONS ============

    def create_appointment(self, appointment: Appointment) -> bool:
        """Create a new appointment."""
        conn = self._get_connection()
        cursor = conn.cursor()
        try:
            cursor.execute('''
                INSERT INTO appointments (
                    id, patient_code, date_time, duration_minutes,
                    appointment_type, status, notes, doctor_code, created_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                appointment.id, appointment.patient_code,
                appointment.date_time.isoformat() if appointment.date_time else datetime.now().isoformat(),
                appointment.duration_minutes, appointment.appointment_type,
                appointment.status, appointment.notes, appointment.doctor_code,
                appointment.created_at.isoformat() if appointment.created_at else datetime.now().isoformat()
            ))
            conn.commit()
            return True
        except Exception:
            return False

    def get_appointments_by_date(self, date: datetime) -> List[Appointment]:
        """Get all appointments for a specific date."""
        conn = self._get_connection()
        cursor = conn.cursor()
        date_str = date.strftime('%Y-%m-%d')
        cursor.execute('''
            SELECT a.*, p.surname, p.name
            FROM appointments a
            LEFT JOIN patients p ON a.patient_code = p.code
            WHERE date(a.date_time) = ?
            ORDER BY a.date_time
        ''', (date_str,))
        return self._rows_to_appointments(cursor.fetchall())

    def _rows_to_appointments(self, rows) -> List[Appointment]:
        """Convert database rows to Appointment objects."""
        appointments = []
        for row in rows:
            appointments.append(Appointment(
                id=row['id'],
                patient_code=row['patient_code'],
                date_time=datetime.fromisoformat(row['date_time']) if row['date_time'] else datetime.now(),
                duration_minutes=row['duration_minutes'] or 30,
                appointment_type=row['appointment_type'] or 'consultation',
                status=row['status'] or 'scheduled',
                notes=row['notes'] or '',
                doctor_code=row['doctor_code'] or '',
                created_at=datetime.fromisoformat(row['created_at']) if row['created_at'] else None
            ))
        return appointments

    # ============ SETTING OPERATIONS ============

    def set_setting(self, key: str, value: str, category: str = "general", description: str = "") -> bool:
        """Set a configuration value."""
        conn = self._get_connection()
        cursor = conn.cursor()
        try:
            cursor.execute('''
                INSERT OR REPLACE INTO settings (key, value, category, description)
                VALUES (?, ?, ?, ?)
            ''', (key, value, category, description))
            conn.commit()
            return True
        except Exception:
            return False

    def get_setting(self, key: str, default: str = "") -> str:
        """Get a configuration value."""
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT value FROM settings WHERE key = ?', (key,))
        row = cursor.fetchone()
        return row['value'] if row else default

    def get_all_settings(self) -> Dict[str, str]:
        """Get all settings as a dictionary."""
        conn = self._get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT key, value FROM settings')
        return {row['key']: row['value'] for row in cursor.fetchall()}


# Singleton instance
db = Database()

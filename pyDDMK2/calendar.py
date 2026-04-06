"""
Appointment scheduling module.
Ported from calender.pas
"""
from datetime import datetime, date, timedelta
from typing import List, Optional
import uuid

from models import Appointment
from database import db
from people import PatientManager

# Greek month names
MONTHS_GR = [
    "", "Ιανουάριος", "Φεβρουάριος", "Μάρτιος", "Απρίλιος", "Μάιος", "Ιούνιος",
    "Ιούλιος", "Αύγουστος", "Σεπτέμβριος", "Οκτώβριος", "Νόεμβριος", "Δεκέμβριος"
]

# Greek day names
DAYS_GR = ["Κυριακή", "Δευτέρα", "Τρίτη", "Τετάρτη", "Πέμπτη", "Παρασκευή", "Σάββατο"]


class CalendarManager:
    """Manages appointments and calendar operations."""

    @staticmethod
    def generate_appointment_id() -> str:
        """Generate unique appointment ID."""
        return f"A{datetime.now().strftime('%Y%m%d%H%M%S')}{uuid.uuid4().hex[:4].upper()}"

    @staticmethod
    def create_appointment(
        patient_code: str,
        date_time: datetime,
        duration_minutes: int = 30,
        appointment_type: str = "consultation",
        notes: str = "",
        doctor_code: str = ""
    ) -> Optional[Appointment]:
        """Create a new appointment."""
        appointment = Appointment(
            id=CalendarManager.generate_appointment_id(),
            patient_code=patient_code,
            date_time=date_time,
            duration_minutes=duration_minutes,
            appointment_type=appointment_type,
            status="scheduled",
            notes=notes,
            doctor_code=doctor_code
        )

        if db.create_appointment(appointment):
            return appointment
        return None

    @staticmethod
    def get_appointments_by_date(display_date: date) -> List[Appointment]:
        """Get all appointments for a specific date."""
        return db.get_appointments_by_date(display_date)

    @staticmethod
    def get_appointments_by_patient(
        patient_code: str,
        start_date: date = None,
        end_date: date = None
    ) -> List[Appointment]:
        """Get appointments for a patient within date range."""
        if not start_date:
            start_date = date.today()
        if not end_date:
            end_date = start_date + timedelta(days=365)

        appointments = []
        current_date = start_date
        while current_date <= end_date:
            day_appointments = CalendarManager.get_appointments_by_date(current_date)
            for apt in day_appointments:
                if apt.patient_code == patient_code:
                    appointments.append(apt)
            current_date += timedelta(days=1)

        return sorted(appointments, key=lambda a: a.date_time)

    @staticmethod
    def get_appointment(appointment_id: str) -> Optional[Appointment]:
        """Get appointment by ID."""
        # Search through recent dates
        for days_offset in range(365):
            check_date = date.today() + timedelta(days=days_offset - 180)
            appointments = CalendarManager.get_appointments_by_date(check_date)
            for apt in appointments:
                if apt.id == appointment_id:
                    return apt
        return None

    @staticmethod
    def update_appointment(
        appointment_id: str,
        date_time: datetime = None,
        duration_minutes: int = None,
        appointment_type: str = None,
        status: str = None,
        notes: str = None
    ) -> bool:
        """Update appointment."""
        # TODO: Implement
        return False

    @staticmethod
    def delete_appointment(appointment_id: str) -> bool:
        """Delete appointment."""
        # TODO: Implement
        return False

    @staticmethod
    def cancel_appointment(appointment_id: str) -> bool:
        """Cancel an appointment."""
        return CalendarManager.update_appointment(appointment_id, status="cancelled")

    @staticmethod
    def confirm_appointment(appointment_id: str) -> bool:
        """Confirm an appointment."""
        return CalendarManager.update_appointment(appointment_id, status="confirmed")

    @staticmethod
    def mark_completed(appointment_id: str) -> bool:
        """Mark appointment as completed."""
        return CalendarManager.update_appointment(appointment_id, status="completed")

    @staticmethod
    def mark_no_show(appointment_id: str) -> bool:
        """Mark appointment as no-show."""
        return CalendarManager.update_appointment(appointment_id, status="no_show")

    @staticmethod
    def has_conflict(
        date_time: datetime,
        duration_minutes: int = 30,
        exclude_appointment_id: str = None
    ) -> bool:
        """Check if there's a scheduling conflict."""
        appointments = CalendarManager.get_appointments_by_date(date_time.date())

        start_time = date_time.time()
        end_time = (date_time + timedelta(minutes=duration_minutes)).time()

        for apt in appointments:
            if exclude_appointment_id and apt.id == exclude_appointment_id:
                continue

            apt_start = apt.date_time.time()
            apt_end = (apt.date_time + timedelta(minutes=apt.duration_minutes)).time()

            # Check for overlap
            if not (end_time <= apt_start or start_time >= apt_end):
                return True

        return False

    @staticmethod
    def get_available_slots(
        target_date: date,
        start_hour: int = 9,
        end_hour: int = 18,
        slot_minutes: int = 30
    ) -> List[datetime]:
        """Get available appointment slots for a date."""
        appointments = CalendarManager.get_appointments_by_date(target_date)

        slots = []
        current_time = datetime.combine(target_date, datetime.min.time().replace(hour=start_hour))
        end_time = datetime.combine(target_date, datetime.min.time().replace(hour=end_hour))

        while current_time < end_time:
            slot_end = current_time + timedelta(minutes=slot_minutes)
            if not CalendarManager.has_conflict(current_time, slot_minutes):
                slots.append(current_time)
            current_time = slot_end

        return slots

    @staticmethod
    def get_upcoming_appointments(days_ahead: int = 7) -> List[Appointment]:
        """Get upcoming appointments."""
        appointments = []
        today = date.today()

        for i in range(days_ahead):
            check_date = today + timedelta(days=i)
            appointments.extend(CalendarManager.get_appointments_by_date(check_date))

        return sorted(
            [a for a in appointments if a.status in ("scheduled", "confirmed")],
            key=lambda a: a.date_time
        )

    @staticmethod
    def format_date_gr(d: date) -> str:
        """Format date in Greek style."""
        return f"{d.day} {MONTHS_GR[d.month].lower()} {d.year}"

    @staticmethod
    def format_datetime_gr(dt: datetime) -> str:
        """Format datetime in Greek style."""
        return f"{DAYS_GR[dt.weekday()]}, {CalendarManager.format_date_gr(dt.date())} {dt.strftime('%H:%M')}"

    @staticmethod
    def get_month_calendar(year: int, month: int) -> List[List[Optional[date]]]:
        """Get calendar grid for a month (weeks x days)."""
        calendar_grid = []

        # Get first day of month
        first_day = date(year, month, 1)
        # Get last day of month
        if month == 12:
            last_day = date(year + 1, 1, 1) - timedelta(days=1)
        else:
            last_day = date(year, month + 1, 1) - timedelta(days=1)

        # Start from Sunday (Monday in Greece, but we'll use Sunday for compatibility)
        start_weekday = first_day.weekday()
        # Adjust for Sunday start (Python uses Monday=0)
        start_weekday = (start_weekday + 1) % 7

        # First week - pad with empty days
        first_week = [None] * start_weekday
        day = 1
        while day <= last_day.day:
            first_week.append(date(year, month, day))
            day += 1
            if len(first_week) == 7:
                break

        calendar_grid.append(first_week)

        # Remaining weeks
        while day <= last_day.day:
            week = []
            for _ in range(7):
                if day <= last_day.day:
                    week.append(date(year, month, day))
                    day += 1
                else:
                    week.append(None)
            calendar_grid.append(week)

        return calendar_grid

    @staticmethod
    def get_appointments_for_day(day_date: date) -> List[Appointment]:
        """Get appointments for a specific day."""
        if day_date is None:
            return []
        return CalendarManager.get_appointments_by_date(day_date)

    @staticmethod
    def format_appointment_display(appointment: Appointment) -> str:
        """Format appointment for display."""
        patient = PatientManager.get_patient(appointment.patient_code)
        patient_name = f"{patient.surname} {patient.name}" if patient else appointment.patient_code

        lines = [
            f"Time: {appointment.date_time.strftime('%H:%M')}",
            f"Patient: {patient_name}",
            f"Type: {appointment.appointment_type}",
            f"Duration: {appointment.duration_minutes} min",
            f"Status: {appointment.status}",
        ]

        if appointment.notes:
            lines.append(f"Notes: {appointment.notes}")

        return "\n".join(lines)

    @staticmethod
    def is_weekend(d: date) -> bool:
        """Check if date is weekend."""
        return d.weekday() >= 5  # Saturday=5, Sunday=6

    @staticmethod
    def is_today(d: date) -> bool:
        """Check if date is today."""
        return d == date.today()

    @staticmethod
    def is_past(d: date) -> bool:
        """Check if date is in the past."""
        return d < date.today()

    @staticmethod
    def days_in_month(year: int, month: int) -> int:
        """Get number of days in a month."""
        if month == 12:
            return 31
        if month == 2:
            return 29 if (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0) else 28
        return 31 if month in (1, 3, 5, 7, 8, 10) else 30

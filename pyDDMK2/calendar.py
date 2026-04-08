"""
Appointment scheduling module - stores appointments in .dat files.
Ported from calender.pas
"""
import os
import re
from datetime import datetime, date, timedelta
from pathlib import Path
from typing import List, Optional, Dict, Any
import uuid

from models import Appointment
from people import PatientManager
from tools import get_app_path

# Greek month names
MONTHS_GR = [
    "", "Ιανουάριος", "Φεβρουάριος", "Μάρτιος", "Απρίλιος", "Μάιος", "Ιούνιος",
    "Ιούλιος", "Αύγουστος", "Σεπτέμβριος", "Οκτώβριος", "Νόεμβριος", "Δεκέμβριος"
]

# Greek day names
DAYS_GR = ["Κυριακή", "Δευτέρα", "Τρίτη", "Τετάρτη", "Πέμπτη", "Παρασκευή", "Σάββατο"]


class CalendarManager:
    """Manages appointments stored in .dat files alongside patient records."""

    @staticmethod
    def get_database_dir() -> Path:
        """Get the Database directory path."""
        return get_app_path() / "Database"

    @staticmethod
    def get_patient_filepath(code: str) -> Path:
        """Get the filepath for a patient's .dat file."""
        return CalendarManager.get_database_dir() / f"{code}.dat"

    @staticmethod
    def generate_appointment_id() -> str:
        """Generate unique appointment ID."""
        return f"A{datetime.now().strftime('%Y%m%d%H%M%S')}{uuid.uuid4().hex[:4].upper()}"

    @staticmethod
    def _parse_date(date_str: str) -> Optional[date]:
        """Parse date from DAT format (DD,MM,YYYY)."""
        if not date_str:
            return None
        try:
            parts = date_str.split(',')
            if len(parts) == 3:
                day = int(parts[0])
                month = int(parts[1])
                year = int(parts[2])
                return date(year, month, day)
        except (ValueError, IndexError):
            pass
        return None

    @staticmethod
    def _parse_datetime(dt_str: str) -> Optional[datetime]:
        """Parse datetime from DAT format (DD,MM,YYYY,HH,MM)."""
        if not dt_str:
            return None
        try:
            parts = dt_str.split(',')
            if len(parts) >= 6:
                day = int(parts[0])
                month = int(parts[1])
                year = int(parts[2])
                hour = int(parts[3])
                minute = int(parts[4])
                second = int(parts[5]) if len(parts) > 5 else 0
                return datetime(year, month, day, hour, minute, second)
        except (ValueError, IndexError):
            pass
        return None

    @staticmethod
    def _format_date(d: date) -> str:
        """Format date to DAT format (DD,MM,YYYY)."""
        if not d:
            return ""
        return f"{d.day},{d.month},{d.year}"

    @staticmethod
    def _format_datetime(dt: datetime) -> str:
        """Format datetime to DAT format (DD,MM,YYYY,HH,MM,SS)."""
        if not dt:
            return ""
        return f"{dt.day},{dt.month},{dt.year},{dt.hour},{dt.minute},{dt.second}"

    @staticmethod
    def _read_patient_file(code: str) -> Dict[str, Any]:
        """Read a patient's .dat file."""
        filepath = CalendarManager.get_patient_filepath(code)
        data = {'appointments': []}

        if not filepath.exists():
            return data

        for encoding in ['windows-1253', 'utf-8']:
            try:
                with open(filepath, 'r', encoding=encoding) as f:
                    for line in f:
                        line = line.strip()
                        if not line:
                            continue

                        match = re.match(r'^(\w+)\((.*)\)$', line)
                        if match:
                            key = match.group(1).upper()
                            value = match.group(2)

                            if key == 'APPOINTMENT':
                                # Format: id,date_time,duration,type,status,notes,doctor
                                parts = value.split(',')
                                if len(parts) >= 6:
                                    data['appointments'].append({
                                        'id': parts[0],
                                        'date_time': ','.join(parts[1:6]),  # DD,MM,YYYY,HH,MM,SS
                                        'duration': int(parts[6]) if len(parts) > 6 and parts[6].isdigit() else 30,
                                        'type': parts[7] if len(parts) > 7 else 'consultation',
                                        'status': parts[8] if len(parts) > 8 else 'scheduled',
                                        'notes': parts[9] if len(parts) > 9 else '',
                                        'doctor': parts[10] if len(parts) > 10 else '',
                                    })
                            else:
                                data[key] = value
                return data
            except UnicodeDecodeError:
                continue

        return data

    @staticmethod
    def _write_patient_file(code: str, data: Dict[str, Any]) -> bool:
        """Write data to patient's .dat file."""
        filepath = CalendarManager.get_patient_filepath(code)

        try:
            lines = []

            # Write basic fields
            for key in ['CODE', 'SURNAME', 'NAME', 'FATHER_NAME', 'MOTHER_NAME',
                       'AREA', 'TELEPHONE', 'CELLPHONE', 'ADDRESS', 'PROFESSION',
                       'EMAIL', 'COMMENTS']:
                if key in data and data[key]:
                    lines.append(f"{key}({data[key]})")

            # Write BIRTH
            if 'BIRTH' in data and data['BIRTH']:
                lines.append(f"BIRTH({data['BIRTH']})")

            # Write NEXT_APPOINTMENT
            if 'NEXT_APPOINTMENT' in data and data['NEXT_APPOINTMENT']:
                lines.append(f"NEXT_APPOINTMENT({data['NEXT_APPOINTMENT']})")

            # Write WORK entries
            if 'works' in data:
                for work in data['works']:
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

            # Write APPOINTMENT entries
            for apt in data.get('appointments', []):
                apt_str = ','.join(str(v) for v in [
                    apt.get('id', ''),
                    apt.get('date_time', ''),
                    apt.get('duration', 30),
                    apt.get('type', 'consultation'),
                    apt.get('status', 'scheduled'),
                    apt.get('notes', ''),
                    apt.get('doctor', ''),
                ])
                lines.append(f"APPOINTMENT({apt_str})")

            with open(filepath, 'w', encoding='utf-8') as f:
                f.write('\n'.join(lines))
                f.write('\n')

            return True
        except Exception as e:
            print(f"Error writing patient file: {e}")
            return False

    @staticmethod
    def _data_to_appointment(data: Dict[str, Any], patient_code: str) -> Appointment:
        """Convert appointment data dict to Appointment object."""
        return Appointment(
            id=data.get('id', ''),
            patient_code=patient_code,
            date_time=CalendarManager._parse_datetime(data.get('date_time', '')),
            duration_minutes=data.get('duration', 30),
            appointment_type=data.get('type', 'consultation'),
            status=data.get('status', 'scheduled'),
            notes=data.get('notes', ''),
            doctor_code=data.get('doctor', '')
        )

    @staticmethod
    def create_appointment(
        patient_code: str,
        date_time: datetime,
        duration_minutes: int = 30,
        appointment_type: str = "consultation",
        notes: str = "",
        doctor_code: str = ""
    ) -> Optional[Appointment]:
        """Create a new appointment in patient's .dat file."""
        # Read existing patient data
        data = CalendarManager._read_patient_file(patient_code)

        # Create appointment
        appointment_id = CalendarManager.generate_appointment_id()
        appointment_data = {
            'id': appointment_id,
            'date_time': CalendarManager._format_datetime(date_time),
            'duration': duration_minutes,
            'type': appointment_type,
            'status': 'scheduled',
            'notes': notes,
            'doctor': doctor_code,
        }

        # Add to appointments list
        if 'appointments' not in data:
            data['appointments'] = []
        data['appointments'].append(appointment_data)

        # Write back to file
        if CalendarManager._write_patient_file(patient_code, data):
            return CalendarManager._data_to_appointment(appointment_data, patient_code)
        return None

    @staticmethod
    def get_appointments_by_date(target_date: date) -> List[Appointment]:
        """Get all appointments for a specific date by scanning all patient files."""
        appointments = []
        patients = PatientManager.get_all_patients()

        for patient in patients:
            data = CalendarManager._read_patient_file(patient.code)
            for apt_data in data.get('appointments', []):
                apt_date = CalendarManager._parse_date(apt_data.get('date_time', '')[:10])
                if apt_date == target_date:
                    appointment = CalendarManager._data_to_appointment(apt_data, patient.code)
                    appointments.append(appointment)

        return sorted(appointments, key=lambda a: a.date_time)

    @staticmethod
    def get_appointments_by_patient(
        patient_code: str,
        start_date: date = None,
        end_date: date = None
    ) -> List[Appointment]:
        """Get appointments for a patient within date range."""
        data = CalendarManager._read_patient_file(patient_code)
        appointments = []

        for apt_data in data.get('appointments', []):
            appointment = CalendarManager._data_to_appointment(apt_data, patient_code)

            if start_date and appointment.date_time.date() < start_date:
                continue
            if end_date and appointment.date_time.date() > end_date:
                continue

            appointments.append(appointment)

        return sorted(appointments, key=lambda a: a.date_time)

    @staticmethod
    def get_appointment(appointment_id: str) -> Optional[Appointment]:
        """Get appointment by ID."""
        patients = PatientManager.get_all_patients()

        for patient in patients:
            data = CalendarManager._read_patient_file(patient.code)
            for apt_data in data.get('appointments', []):
                if apt_data.get('id') == appointment_id:
                    return CalendarManager._data_to_appointment(apt_data, patient.code)

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
        """Update appointment in patient's .dat file."""
        patients = PatientManager.get_all_patients()

        for patient in patients:
            data = CalendarManager._read_patient_file(patient.code)
            for apt_data in data.get('appointments', []):
                if apt_data.get('id') == appointment_id:
                    # Update fields
                    if date_time is not None:
                        apt_data['date_time'] = CalendarManager._format_datetime(date_time)
                    if duration_minutes is not None:
                        apt_data['duration'] = duration_minutes
                    if appointment_type is not None:
                        apt_data['type'] = appointment_type
                    if status is not None:
                        apt_data['status'] = status
                    if notes is not None:
                        apt_data['notes'] = notes

                    return CalendarManager._write_patient_file(patient.code, data)

        return False

    @staticmethod
    def delete_appointment(appointment_id: str) -> bool:
        """Delete appointment from patient's .dat file."""
        patients = PatientManager.get_all_patients()

        for patient in patients:
            data = CalendarManager._read_patient_file(patient.code)
            appointments = data.get('appointments', [])

            for i, apt_data in enumerate(appointments):
                if apt_data.get('id') == appointment_id:
                    appointments.pop(i)
                    data['appointments'] = appointments
                    return CalendarManager._write_patient_file(patient.code, data)

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

        # Start from Monday (standard in Greece)
        start_weekday = first_day.weekday()

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

"""
Management and reporting module.
Ported from management.pas
"""
from datetime import datetime, date, timedelta
from typing import List, Dict, Any, Optional
from collections import defaultdict

from people import PatientManager
from calendar import CalendarManager
from translations import translate_en_to_gr as T


class ManagementManager:
    """Handles management reports and statistics."""

    @staticmethod
    def get_daily_statistics(target_date: date = None) -> Dict[str, Any]:
        """Get daily statistics for a specific date."""
        if target_date is None:
            target_date = date.today()

        # Get appointments for the day
        appointments = CalendarManager.get_appointments_by_date(target_date)

        # Get all patients
        all_patients = PatientManager.get_all_patients()

        # Calculate statistics
        stats = {
            'date': target_date,
            'total_patients': len(all_patients),
            'appointments_count': len(appointments),
            'scheduled_appointments': len([a for a in appointments if a.status == 'scheduled']),
            'confirmed_appointments': len([a for a in appointments if a.status == 'confirmed']),
            'completed_appointments': len([a for a in appointments if a.status == 'completed']),
            'cancelled_appointments': len([a for a in appointments if a.status == 'cancelled']),
            'no_show_appointments': len([a for a in appointments if a.status == 'no_show']),
        }

        # Group appointments by type
        type_counts = defaultdict(int)
        for apt in appointments:
            type_counts[apt.appointment_type] += 1
        stats['appointments_by_type'] = dict(type_counts)

        # Calculate expected revenue (placeholder - would need works data)
        stats['expected_revenue'] = 0.0
        stats['actual_revenue'] = 0.0

        return stats

    @staticmethod
    def get_monthly_report(year: int, month: int) -> Dict[str, Any]:
        """Generate monthly report."""
        # Calculate date range
        if month == 12:
            first_day = date(year, month, 1)
            last_day = date(year + 1, 1, 1) - timedelta(days=1)
        else:
            first_day = date(year, month, 1)
            last_day = date(year, month + 1, 1) - timedelta(days=1)

        # Gather data
        all_appointments = []
        current_date = first_day
        while current_date <= last_day:
            all_appointments.extend(CalendarManager.get_appointments_by_date(current_date))
            current_date += timedelta(days=1)

        all_patients = PatientManager.get_all_patients()

        # Calculate statistics
        report = {
            'year': year,
            'month': month,
            'first_day': first_day,
            'last_day': last_day,
            'total_patients': len(all_patients),
            'total_appointments': len(all_appointments),
            'appointments_by_status': {
                'scheduled': len([a for a in all_appointments if a.status == 'scheduled']),
                'confirmed': len([a for a in all_appointments if a.status == 'confirmed']),
                'completed': len([a for a in all_appointments if a.status == 'completed']),
                'cancelled': len([a for a in all_appointments if a.status == 'cancelled']),
                'no_show': len([a for a in all_appointments if a.status == 'no_show']),
            },
            'appointments_by_type': defaultdict(int),
            'appointments_by_day': {},
        }

        # Group by type
        for apt in all_appointments:
            report['appointments_by_type'][apt.appointment_type] += 1
        report['appointments_by_type'] = dict(report['appointments_by_type'])

        # Group by day
        for apt in all_appointments:
            day_str = apt.date_time.strftime('%Y-%m-%d')
            if day_str not in report['appointments_by_day']:
                report['appointments_by_day'][day_str] = 0
            report['appointments_by_day'][day_str] += 1

        # Calculate totals
        report['total_revenue'] = 0.0
        report['total_discount'] = 0.0
        report['total_paid'] = 0.0
        report['total_outstanding'] = 0.0

        return report

    @staticmethod
    def get_patient_statistics(patient_code: str) -> Dict[str, Any]:
        """Get statistics for a specific patient."""
        patient = PatientManager.get_patient(patient_code)
        if not patient:
            return {}

        # Get patient appointments
        appointments = CalendarManager.get_appointments_by_patient(
            patient_code,
            start_date=date(2020, 1, 1)
        )

        stats = {
            'patient': patient,
            'total_appointments': len(appointments),
            'appointments_by_status': defaultdict(int),
            'appointments_by_type': defaultdict(int),
            'last_appointment': None,
            'next_appointment': None,
        }

        # Group appointments
        for apt in appointments:
            stats['appointments_by_status'][apt.status] += 1
            stats['appointments_by_type'][apt.appointment_type] += 1

            if not stats['last_appointment'] or apt.date_time > stats['last_appointment']:
                stats['last_appointment'] = apt.date_time

            if apt.status in ('scheduled', 'confirmed'):
                if not stats['next_appointment'] or apt.date_time < stats['next_appointment']:
                    stats['next_appointment'] = apt.date_time

        stats['appointments_by_status'] = dict(stats['appointments_by_status'])
        stats['appointments_by_type'] = dict(stats['appointments_by_type'])

        return stats

    @staticmethod
    def get_revenue_report(
        start_date: date = None,
        end_date: date = None
    ) -> Dict[str, Any]:
        """Generate revenue report for a date range."""
        if start_date is None:
            start_date = date.today().replace(day=1)
        if end_date is None:
            end_date = date.today()

        report = {
            'start_date': start_date,
            'end_date': end_date,
            'total_revenue': 0.0,
            'total_discount': 0.0,
            'total_paid': 0.0,
            'total_outstanding': 0.0,
            'revenue_by_day': {},
            'revenue_by_type': defaultdict(float),
        }

        # Note: Actual revenue calculation would require works data
        # This is a placeholder structure

        return report

    @staticmethod
    def get_upcoming_appointments_summary(days_ahead: int = 7) -> List[Dict[str, Any]]:
        """Get summary of upcoming appointments."""
        appointments = CalendarManager.get_upcoming_appointments(days_ahead)

        summary = []
        for apt in appointments:
            patient = PatientManager.get_patient(apt.patient_code)
            summary.append({
                'appointment': apt,
                'patient_name': f"{patient.surname} {patient.name}" if patient else apt.patient_code,
                'days_until': (apt.date_time.date() - date.today()).days,
            })

        return sorted(summary, key=lambda x: x['appointment'].date_time)

    @staticmethod
    def get_no_show_report(days_back: int = 30) -> List[Dict[str, Any]]:
        """Get report of no-show appointments."""
        no_shows = []
        end_date = date.today()
        start_date = end_date - timedelta(days=days_back)

        current_date = start_date
        while current_date <= end_date:
            appointments = CalendarManager.get_appointments_by_date(current_date)
            for apt in appointments:
                if apt.status == 'no_show':
                    patient = PatientManager.get_patient(apt.patient_code)
                    no_shows.append({
                        'appointment': apt,
                        'patient': patient,
                        'patient_name': f"{patient.surname} {patient.name}" if patient else apt.patient_code,
                    })
            current_date += timedelta(days=1)

        return sorted(no_shows, key=lambda x: x['appointment'].date_time, reverse=True)

    @staticmethod
    def format_daily_statistics_report(stats: Dict[str, Any]) -> str:
        """Format daily statistics as a readable report."""
        lines = [
            f"Daily Statistics - {stats['date'].strftime('%Y-%m-%d')}",
            "=" * 50,
            f"Total Patients: {stats['total_patients']}",
            f"Total Appointments: {stats['appointments_count']}",
            "",
            "Appointments by Status:",
            f"  Scheduled: {stats['scheduled_appointments']}",
            f"  Confirmed: {stats['confirmed_appointments']}",
            f"  Completed: {stats['completed_appointments']}",
            f"  Cancelled: {stats['cancelled_appointments']}",
            f"  No-show: {stats['no_show_appointments']}",
        ]

        if stats['appointments_by_type']:
            lines.append("")
            lines.append("Appointments by Type:")
            for apt_type, count in stats['appointments_by_type'].items():
                lines.append(f"  {apt_type}: {count}")

        return "\n".join(lines)

    @staticmethod
    def format_monthly_report(report: Dict[str, Any]) -> str:
        """Format monthly report as a readable report."""
        from calendar import MONTHS_GR

        month_name = MONTHS_GR[report['month']]
        lines = [
            f"Monthly Report - {month_name} {report['year']}",
            "=" * 50,
            f"Period: {report['first_day'].strftime('%Y-%m-%d')} to {report['last_day'].strftime('%Y-%m-%d')}",
            f"Total Patients: {report['total_patients']}",
            f"Total Appointments: {report['total_appointments']}",
            "",
            "Appointments by Status:",
            f"  Scheduled: {report['appointments_by_status'].get('scheduled', 0)}",
            f"  Confirmed: {report['appointments_by_status'].get('confirmed', 0)}",
            f"  Completed: {report['appointments_by_status'].get('completed', 0)}",
            f"  Cancelled: {report['appointments_by_status'].get('cancelled', 0)}",
            f"  No-show: {report['appointments_by_status'].get('no_show', 0)}",
        ]

        if report['appointments_by_type']:
            lines.append("")
            lines.append("Appointments by Type:")
            for apt_type, count in report['appointments_by_type'].items():
                lines.append(f"  {apt_type}: {count}")

        return "\n".join(lines)

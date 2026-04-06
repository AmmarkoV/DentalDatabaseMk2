"""
Payment management module.
Ported from payments.pas
"""
from datetime import datetime, date, timedelta
from typing import List, Optional, Tuple
import uuid

from models import Payment, PaymentStatus
from database import db
from people import PatientManager


class PaymentsManager:
    """Manages payment operations."""

    @staticmethod
    def generate_payment_id() -> str:
        """Generate unique payment ID."""
        return f"P{datetime.now().strftime('%Y%m%d%H%M%S')}{uuid.uuid4().hex[:4].upper()}"

    @staticmethod
    def create_payment(
        patient_code: str,
        amount: float,
        payment_method: str = "cash",
        reference: str = "",
        work_id: str = "",
        doctor_code: str = "",
        comments: str = "",
        payment_date: datetime = None
    ) -> Optional[Payment]:
        """Create a new payment record."""
        payment = Payment(
            id=PaymentsManager.generate_payment_id(),
            patient_code=patient_code,
            work_id=work_id,
            amount=amount,
            payment_method=payment_method.lower(),
            reference=reference,
            status=PaymentStatus.PAID,
            date=payment_date or datetime.now(),
            doctor_code=doctor_code,
            comments=comments
        )

        if db.create_payment(payment):
            return payment
        return None

    @staticmethod
    def get_payments_by_patient(patient_code: str) -> List[Payment]:
        """Get all payments for a patient."""
        return db.get_payments_by_patient(patient_code)

    @staticmethod
    def get_payment(payment_id: str) -> Optional[Payment]:
        """Get payment by ID."""
        # Search across all patient payments
        all_patients = PatientManager.get_all_patients()
        for patient in all_patients:
            payments = PaymentsManager.get_payments_by_patient(patient.code)
            for payment in payments:
                if payment.id == payment_id:
                    return payment
        return None

    @staticmethod
    def update_payment(
        payment_id: str,
        amount: float = None,
        payment_method: str = None,
        reference: str = None,
        status: PaymentStatus = None,
        comments: str = None
    ) -> bool:
        """Update payment record."""
        # TODO: Implement
        return False

    @staticmethod
    def delete_payment(payment_id: str) -> bool:
        """Delete payment record."""
        # TODO: Implement
        return False

    @staticmethod
    def void_payment(payment_id: str) -> bool:
        """Void/cancel a payment."""
        # TODO: Implement
        return False

    @staticmethod
    def get_payments_by_date_range(
        start_date: date,
        end_date: date,
        patient_code: str = None
    ) -> List[Payment]:
        """Get payments within date range."""
        if patient_code:
            payments = PaymentsManager.get_payments_by_patient(patient_code)
        else:
            # Get all payments - need to iterate patients
            payments = []
            all_patients = PatientManager.get_all_patients()
            for patient in all_patients:
                payments.extend(PaymentsManager.get_payments_by_patient(patient.code))

        start_dt = datetime.combine(start_date, datetime.min.time())
        end_dt = datetime.combine(end_date, datetime.max.time())

        return [
            p for p in payments
            if start_dt <= p.date <= end_dt and p.status == PaymentStatus.PAID
        ]

    @staticmethod
    def get_daily_income(payment_date: date) -> float:
        """Get total income for a specific day."""
        payments = PaymentsManager.get_payments_by_date_range(payment_date, payment_date)
        return sum(p.amount for p in payments)

    @staticmethod
    def get_monthly_income(year: int, month: int) -> float:
        """Get total income for a month."""
        start_date = date(year, month, 1)
        if month == 12:
            end_date = date(year + 1, 1, 1)
        else:
            end_date = date(year, month + 1, 1)

        payments = PaymentsManager.get_payments_by_date_range(start_date, end_date)
        return sum(p.amount for p in payments)

    @staticmethod
    def get_yearly_income(year: int) -> float:
        """Get total income for a year."""
        start_date = date(year, 1, 1)
        end_date = date(year, 12, 31)
        payments = PaymentsManager.get_payments_by_date_range(start_date, end_date)
        return sum(p.amount for p in payments)

    @staticmethod
    def get_patient_total_paid(patient_code: str) -> float:
        """Get total amount paid by a patient."""
        payments = PaymentsManager.get_payments_by_patient(patient_code)
        return sum(p.amount for p in payments if p.status == PaymentStatus.PAID)

    @staticmethod
    def get_payments_by_method(patient_code: str, method: str) -> List[Payment]:
        """Get payments filtered by payment method."""
        payments = PaymentsManager.get_payments_by_patient(patient_code)
        return [p for p in payments if p.payment_method.lower() == method.lower()]

    @staticmethod
    def get_payment_summary_by_method(patient_code: str) -> dict:
        """Get payment summary grouped by method."""
        payments = PaymentsManager.get_payments_by_patient(patient_code)
        summary = {}

        for payment in payments:
            if payment.status != PaymentStatus.PAID:
                continue
            method = payment.payment_method
            if method not in summary:
                summary[method] = {'count': 0, 'total': 0.0}
            summary[method]['count'] += 1
            summary[method]['total'] += payment.amount

        return summary

    @staticmethod
    def format_payment_display(payment: Payment) -> str:
        """Format payment information for display."""
        patient = PatientManager.get_patient(payment.patient_code)
        patient_name = f"{patient.surname} {patient.name}" if patient else payment.patient_code

        lines = [
            f"Payment ID: {payment.id}",
            f"Patient: {patient_name}",
            f"Amount: €{payment.amount:.2f}",
            f"Method: {payment.payment_method}",
            f"Date: {payment.date.strftime('%Y-%m-%d %H:%M')}",
            f"Status: {payment.status.value}",
        ]

        if payment.reference:
            lines.append(f"Reference: {payment.reference}")
        if payment.comments:
            lines.append(f"Comments: {payment.comments}")

        return "\n".join(lines)

    @staticmethod
    def generate_daily_report(report_date: date) -> str:
        """Generate daily income report."""
        income = PaymentsManager.get_daily_income(report_date)
        payments = PaymentsManager.get_payments_by_date_range(report_date, report_date)

        lines = [
            f"DAILY INCOME REPORT",
            f"Date: {report_date.strftime('%Y-%m-%d')}",
            f"=" * 40,
            f"Total Payments: {len(payments)}",
            f"Total Income: €{income:.2f}",
            f"",
            f"Payment Details:",
        ]

        for payment in sorted(payments, key=lambda p: p.date):
            patient = PatientManager.get_patient(payment.patient_code)
            name = f"{patient.surname} {patient.name}" if patient else payment.patient_code
            lines.append(f"  {payment.date.strftime('%H:%M')} - {name}: €{payment.amount:.2f} ({payment.payment_method})")

        return "\n".join(lines)

    @staticmethod
    def generate_monthly_report(year: int, month: int) -> str:
        """Generate monthly income report."""
        # TODO: Implement
        return ""

    @staticmethod
    def export_payments_csv(
        filepath: str,
        patient_code: str = None,
        start_date: date = None,
        end_date: date = None
    ) -> bool:
        """Export payments to CSV file."""
        try:
            if patient_code:
                payments = PaymentsManager.get_payments_by_patient(patient_code)
            else:
                all_patients = PatientManager.get_all_patients()
                payments = []
                for patient in all_patients:
                    payments.extend(PaymentsManager.get_payments_by_patient(patient.code))

            if start_date and end_date:
                start_dt = datetime.combine(start_date, datetime.min.time())
                end_dt = datetime.combine(end_date, datetime.max.time())
                payments = [p for p in payments if start_dt <= p.date <= end_dt]

            with open(filepath, 'w', encoding='utf-8') as f:
                f.write("ID,Date,Patient Code,Amount,Method,Reference,Status\n")
                for p in sorted(payments, key=lambda x: x.date):
                    f.write(f'"{p.id}","{p.date.isoformat()}","{p.patient_code}",{p.amount},"{p.payment_method}","{p.reference}","{p.status.value}"\n')

            return True
        except Exception:
            return False

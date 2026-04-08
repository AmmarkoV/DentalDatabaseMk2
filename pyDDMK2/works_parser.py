#!/usr/bin/env python3
"""
Works parser module - parses WORK lines from patient .dat files.
Ported from people.pas work handling
"""
import re
from typing import List, Optional
from datetime import date

from models import PatientWork


class WorksParser:
    """Parser for WORK lines in patient .dat files."""

    WORK_PATTERN = re.compile(r'^WORK\((.*)\)$')

    @staticmethod
    def parse_work_line(line: str) -> Optional[PatientWork]:
        """Parse a WORK line into a PatientWork object."""
        match = WorksParser.WORK_PATTERN.match(line.strip())
        if not match:
            return None

        content = match.group(1)
        parts = content.split(',')

        # WORK(work_id,price,discount,payed,comments,user,day,month,year)
        # Comments may contain commas, so we need careful parsing
        if len(parts) < 6:
            return None

        work_id = parts[0].strip()

        # Parse numeric fields
        try:
            price = float(parts[1].replace(',', '.')) if parts[1].strip() else 0.0
        except ValueError:
            price = 0.0

        try:
            discount = float(parts[2].replace(',', '.')) if parts[2].strip() else 0.0
        except ValueError:
            discount = 0.0

        try:
            paid = float(parts[3].replace(',', '.')) if parts[3].strip() else 0.0
        except ValueError:
            paid = 0.0

        # Remaining parts: comments, user, day, month, year
        # Comments may contain commas, so join middle parts
        remaining = parts[4:]
        if len(remaining) >= 4:
            # Last 4 should be: user, day, month, year
            year_str = remaining[-1].strip()
            month_str = remaining[-2].strip()
            day_str = remaining[-3].strip()
            user = remaining[-4].strip()
            # Everything before user is comments
            comments = ','.join(remaining[:-4])
        elif len(remaining) == 3:
            # No user, just day, month, year
            year_str = remaining[-1].strip()
            month_str = remaining[-2].strip()
            day_str = remaining[-3].strip()
            user = ""
            comments = ""
        else:
            # Just comments
            comments = ','.join(remaining)
            user = ""
            year_str = ""
            month_str = ""
            day_str = ""

        # Parse date fields
        try:
            day = int(day_str) if day_str else 0
        except ValueError:
            day = 0

        try:
            month = int(month_str) if month_str else 0
        except ValueError:
            month = 0

        try:
            year = int(year_str) if year_str else 0
        except ValueError:
            year = 0

        return PatientWork(
            work_id=work_id,
            price=price,
            discount=discount,
            paid=paid,
            comments=comments,
            user=user,
            day=day,
            month=month,
            year=year
        )

    @staticmethod
    def parse_works_from_data(data: dict) -> List[PatientWork]:
        """Extract works from parsed .dat file data."""
        works = []
        works_raw = data.get('works', [])
        for work_raw in works_raw:
            work = PatientWork(
                work_id=str(work_raw.get('description', '')),
                price=work_raw.get('price', 0.0),
                discount=work_raw.get('discount', 0.0),
                paid=work_raw.get('paid', 0.0),
                comments=work_raw.get('comments', ''),
                user=work_raw.get('user', ''),
                day=work_raw.get('day', 0),
                month=work_raw.get('month', 0),
                year=work_raw.get('year', 0)
            )
            works.append(work)
        return works

    @staticmethod
    def format_work_line(work: PatientWork) -> str:
        """Format a PatientWork as a WORK line for .dat file."""
        date_part = f",{work.day},{work.month},{work.year}" if work.year else ""
        return f"WORK({work.work_id},{work.price},{work.discount},{work.paid},{work.comments},{work.user}{date_part})"


# Convenience functions
def parse_work_line(line: str) -> Optional[PatientWork]:
    """Parse a single WORK line."""
    return WorksParser.parse_work_line(line)


def format_work_line(work: PatientWork) -> str:
    """Format a work as a WORK line."""
    return WorksParser.format_work_line(work)

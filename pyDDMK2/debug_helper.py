#!/usr/bin/env python3
"""
Debug helper script for Dental Database MK2.
Tests and diagnoses functionality issues.
"""
import sys
from pathlib import Path
from datetime import date

# Add project directory to path
project_dir = Path(__file__).parent
sys.path.insert(0, str(project_dir))

from people import PatientManager
from calendar import CalendarManager
from settings import SettingsManager
from the_works import WorkTypeManager
from userlogin import UserManager


def print_section(title: str):
    print(f"\n{'='*60}")
    print(f" {title}")
    print(f"{'='*60}")


def test_patient_manager():
    """Test patient management functionality."""
    print_section("PATIENT MANAGER TESTS")

    # Test 1: Get database directory
    print("\n[1] Database Directory:")
    db_dir = PatientManager.get_database_dir()
    print(f"    Path: {db_dir}")
    print(f"    Exists: {db_dir.exists()}")

    if db_dir.exists():
        dat_files = list(db_dir.glob("*.dat"))
        print(f"    .dat files found: {len(dat_files)}")
        for f in dat_files[:5]:  # Show first 5
            print(f"      - {f.name}")
        if len(dat_files) > 5:
            print(f"      ... and {len(dat_files) - 5} more")

    # Test 2: Get all patients
    print("\n[2] Get All Patients:")
    patients = PatientManager.get_all_patients()
    print(f"    Total patients: {len(patients)}")
    for p in patients[:3]:  # Show first 3
        print(f"      - {p.code}: {p.surname} {p.name}")
    if len(patients) > 3:
        print(f"      ... and {len(patients) - 3} more")

    # Test 3: Search patients
    print("\n[3] Search Patients (query='qammaz'):")
    results = PatientManager.search_by_name("qammaz")
    print(f"    Results: {len(results)}")
    for p in results:
        print(f"      - {p.code}: {p.surname} {p.name}")

    # Test 4: Get specific patient
    if patients:
        test_code = patients[0].code
        print(f"\n[4] Get Patient by Code ({test_code}):")
        patient = PatientManager.get_patient(test_code)
        if patient:
            print(f"    Found: {patient.surname} {patient.name}")
            print(f"    Telephone: {patient.telephone}")
            print(f"    Cell: {patient.cell_phone}")
        else:
            print("    ERROR: Patient not found!")

    # Test 5: Generate code
    print("\n[5] Generate Patient Code:")
    code = PatientManager.generate_patient_code()
    print(f"    Generated code: {code}")


def test_calendar_manager():
    """Test calendar/appointment functionality."""
    print_section("CALENDAR MANAGER TESTS")

    # Test 1: Get appointments by date
    print("\n[1] Appointments for Today:")
    today = date.today()
    appointments = CalendarManager.get_appointments_by_date(today)
    print(f"    Found: {len(appointments)}")
    for apt in appointments:
        print(f"      {apt.date_time} - {apt.patient_code} - {apt.appointment_type}")

    # Test 3: Get appointments by patient
    if 'patients' in dir():
        if patients:
            test_code = patients[0].code
            print(f"\n[3] Appointments for Patient {test_code}:")
            apt_list = CalendarManager.get_appointments_by_patient(test_code, start_date=date(2020, 1, 1))
            print(f"    Found: {len(apt_list)}")
            for apt in apt_list[:5]:
                print(f"      {apt.date_time} - {apt.appointment_type} ({apt.status})")


def test_work_types():
    """Test work type management."""
    print_section("WORK TYPE MANAGER TESTS")

    print("\n[1] Get All Work Types:")
    work_types = WorkTypeManager.get_all_work_types()
    print(f"    Total: {len(work_types)}")
    for wt in work_types[:5]:
        print(f"      {wt.code}: {wt.description_en} ({wt.base_price})")
    if len(work_types) > 5:
        print(f"      ... and {len(work_types) - 5} more")

    print("\n[2] Search Work Type by Code (FILLING):")
    wt = None
    for w in work_types:
        if w.code == "FILLING":
            wt = w
            break
    if wt:
        print(f"    Found: {wt.description_en} - {wt.base_price}")
    else:
        print("    Not found")


def test_settings():
    """Test settings management."""
    print_section("SETTINGS MANAGER TESTS")

    print("\n[1] Get All Settings:")
    settings = SettingsManager.get_all()
    print(f"    Total: {len(settings)}")
    for key, value in list(settings.items())[:10]:
        print(f"      {key}: {value}")
    if len(settings) > 10:
        print(f"      ... and {len(settings) - 10} more")


def test_user_manager():
    """Test user management."""
    print_section("USER MANAGER TESTS")

    print("\n[1] Users:")
    users = UserManager.get_all_users()
    print(f"    Total: {len(users)}")
    for user in users:
        print(f"      {user.username} ({user.full_name}) - Admin: {user.is_admin}")

    print("\n[2] Get Admin User:")
    admin = UserManager.get_user("admin")
    if admin:
        print(f"    Found: {admin.full_name}")
    else:
        print("    Not found")


def diagnose_patient_lookup(patient_code: str):
    """Diagnose why a specific patient lookup might fail."""
    print_section(f"DIAGNOSE PATIENT LOOKUP: {patient_code}")

    # Check if file exists
    db_dir = PatientManager.get_database_dir()
    dat_file = db_dir / f"{patient_code}.dat"

    print(f"\n[1] Checking file: {dat_file}")
    print(f"    Exists: {dat_file.exists()}")

    if dat_file.exists():
        print("\n[2] File contents (raw):")
        try:
            content = dat_file.read_bytes()
            print(f"    Size: {len(content)} bytes")
            # Try different encodings
            for encoding in ['windows-1253', 'utf-8', 'latin-1']:
                try:
                    text = content.decode(encoding)
                    print(f"    Decoded with {encoding}:")
                    for line in text.split('\n')[:10]:
                        print(f"      {repr(line)}")
                    break
                except:
                    continue
        except Exception as e:
            print(f"    Error: {e}")

        print("\n[3] Parsing attempt:")
        try:
            data = PatientManager._read_dat_file(dat_file)
            print(f"    Parsed successfully:")
            for key, value in list(data.items())[:10]:
                print(f"      {key}: {value}")
        except Exception as e:
            print(f"    Error: {e}")
            import traceback
            traceback.print_exc()

    print("\n[4] PatientManager.get_patient() result:")
    patient = PatientManager.get_patient(patient_code)
    if patient:
        print(f"    SUCCESS: {patient.surname} {patient.name}")
    else:
        print("    FAILED: None returned")


def main():
    """Run all tests."""
    print("\n" + "#"*60)
    print("# DENTAL DATABASE MK2 - DEBUG HELPER")
    print("#"*60)

    # Parse arguments
    if len(sys.argv) > 1:
        if sys.argv[1] == "patient":
            if len(sys.argv) > 2:
                diagnose_patient_lookup(sys.argv[2])
            else:
                print("Usage: python debug_helper.py patient <patient_code>")
            return
        elif sys.argv[1] == "patients":
            test_patient_manager()
            return
        elif sys.argv[1] == "calendar":
            test_calendar_manager()
            return
        elif sys.argv[1] == "worktypes":
            test_work_types()
            return
        elif sys.argv[1] == "settings":
            test_settings()
            return
        elif sys.argv[1] == "users":
            test_user_manager()
            return

    # Run all tests
    test_patient_manager()
    test_calendar_manager()
    test_work_types()
    test_settings()
    test_user_manager()

    print("\n" + "="*60)
    print(" ALL TESTS COMPLETED")
    print("="*60)


if __name__ == "__main__":
    main()

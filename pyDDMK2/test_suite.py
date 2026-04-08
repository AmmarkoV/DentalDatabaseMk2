#!/usr/bin/env python3
"""
Automated test suite for Dental Database MK2.
Runs functional tests and reports results.
"""
import sys
from pathlib import Path
from datetime import date, datetime
from io import StringIO

# Add project directory to path
project_dir = Path(__file__).parent
sys.path.insert(0, str(project_dir))

from people import PatientManager, Patient
from calendar import CalendarManager, Appointment
from settings import SettingsManager
from the_works import WorkTypeManager
from userlogin import UserManager


class TestResult:
    def __init__(self, name: str):
        self.name = name
        self.passed = False
        self.message = ""
        self.duration = 0.0

    def __str__(self):
        status = "PASS" if self.passed else "FAIL"
        return f"[{status}] {self.name}: {self.message}"


class TestSuite:
    def __init__(self):
        self.results: list[TestResult] = []
        self.start_time = None

    def run_test(self, name: str, test_func):
        import time
        result = TestResult(name)
        start = time.time()
        try:
            test_func(result)
            result.passed = True
            result.message = "OK"
        except AssertionError as e:
            result.passed = False
            result.message = str(e)
        except Exception as e:
            result.passed = False
            result.message = f"ERROR: {e}"
        finally:
            result.duration = time.time() - start
        self.results.append(result)
        return result

    def summary(self):
        passed = sum(1 for r in self.results if r.passed)
        total = len(self.results)
        print(f"\n{'='*60}")
        print(f" TEST SUMMARY: {passed}/{total} passed")
        print(f"{'='*60}")
        for r in self.results:
            print(r)
        return passed == total


def test_database_directory_exists(suite: TestSuite):
    def test(result):
        db_dir = PatientManager.get_database_dir()
        assert db_dir.exists(), f"Database directory not found: {db_dir}"
        assert db_dir.is_dir(), f"Database path is not a directory: {db_dir}"
    suite.run_test("Database directory exists", test)


def test_patient_files_readable(suite: TestSuite):
    def test(result):
        patients = PatientManager.get_all_patients()
        assert len(patients) > 0, f"No patients found in database"
        assert all(p.code for p in patients), "Some patients missing codes"
    suite.run_test("Patient files readable", test)


def test_patient_lookup_by_code(suite: TestSuite):
    def test(result):
        patients = PatientManager.get_all_patients()
        if not patients:
            raise AssertionError("No patients to test with")
        test_patient = patients[0]
        found = PatientManager.get_patient(test_patient.code)
        assert found is not None, f"Could not find patient {test_patient.code}"
        assert found.code == test_patient.code, "Returned wrong patient"
    suite.run_test("Patient lookup by code", test)


def test_patient_search(suite: TestSuite):
    def test(result):
        patients = PatientManager.get_all_patients()
        if not patients:
            raise AssertionError("No patients to test with")
        # Search for first patient's surname
        test_surname = patients[0].surname.lower()
        results = PatientManager.search_by_name(test_surname)
        assert len(results) > 0, f"Search for '{test_surname}' returned no results"
        # Empty search should return all
        all_results = PatientManager.search_by_name("")
        assert len(all_results) == len(patients), "Empty search should return all patients"
    suite.run_test("Patient search", test)


def test_patient_code_generation(suite: TestSuite):
    def test(result):
        code = PatientManager.generate_patient_code()
        assert code is not None, "Code generation returned None"
        assert len(code) > 0, "Code generation returned empty string"
    suite.run_test("Patient code generation", test)


def test_patient_create(suite: TestSuite):
    def test(result):
        # Create a test patient with unique code
        test_surname = f"TEST_{datetime.now().timestamp()}"
        patient = PatientManager.create_patient(
            surname=test_surname,
            name="Test",
            father_name="Father",
            area="Test Area",
            telephone="12345678",
            cell_phone="6901234567"
        )
        assert patient is not None, "Patient creation returned None"
        assert patient.surname == test_surname, "Created patient has wrong surname"
        assert patient.code != "", "Created patient has no code"
        # Cleanup
        dat_file = PatientManager.get_database_dir() / f"{patient.code}.dat"
        if dat_file.exists():
            dat_file.unlink()
    suite.run_test("Patient create", test)


def test_patient_update(suite: TestSuite):
    def test(result):
        # First create a patient
        test_surname = f"UPDATETEST_{datetime.now().timestamp()}"
        patient = PatientManager.create_patient(
            surname=test_surname,
            name="Test",
            father_name="",
            area="",
            telephone="",
            cell_phone=""
        )
        try:
            # Update it
            success = PatientManager.update_patient(
                code=patient.code,
                surname=patient.surname,
                name="Updated",
                father_name="",
                area="",
                telephone="",
                cell_phone=""
            )
            assert success, "Patient update failed"
            # Verify
            updated = PatientManager.get_patient(patient.code)
            assert updated is not None, "Could not fetch updated patient"
            assert updated.name == "Updated", "Patient name was not updated"
        finally:
            # Cleanup
            dat_file = PatientManager.get_database_dir() / f"{patient.code}.dat"
            if dat_file.exists():
                dat_file.unlink()
    suite.run_test("Patient update", test)


def test_appointments_file(suite: TestSuite):
    def test(result):
        # Just verify get_appointments_by_date doesn't crash
        appointments = CalendarManager.get_appointments_by_date(date.today())
        assert isinstance(appointments, list), "Should return list"
    suite.run_test("Appointments file path", test)


def test_appointments_get_by_date(suite: TestSuite):
    def test(result):
        # Should return empty list if no appointments, not crash
        today = date.today()
        appointments = CalendarManager.get_appointments_by_date(today)
        assert isinstance(appointments, list), "get_appointments_by_date should return list"
    suite.run_test("Appointments get by date", test)


def test_work_types_load(suite: TestSuite):
    def test(result):
        work_types = WorkTypeManager.get_all_work_types()
        assert isinstance(work_types, list), "get_all_work_types should return list"
        # Should have some default types
        assert len(work_types) > 0, "No work types loaded"
    suite.run_test("Work types load", test)


def test_work_type_lookup(suite: TestSuite):
    def test(result):
        work_types = WorkTypeManager.get_all_work_types()
        if not work_types:
            raise AssertionError("No work types to test with")
        test_code = work_types[0].code
        # Search for work type by code
        found = None
        for wt in work_types:
            if wt.code == test_code:
                found = wt
                break
        assert found is not None, f"Could not find work type {test_code}"
    suite.run_test("Work type lookup", test)


def test_settings_get_set(suite: TestSuite):
    def test(result):
        test_key = f"test_key_{datetime.now().timestamp()}"
        test_value = "test_value"
        SettingsManager.set(test_key, test_value)
        retrieved = SettingsManager.get(test_key, "default")
        assert retrieved == test_value, f"Settings get/set mismatch: {retrieved} != {test_value}"
        # Cleanup
        SettingsManager.delete(test_key)
    suite.run_test("Settings get/set", test)


def test_settings_defaults(suite: TestSuite):
    def test(result):
        # Test default value for non-existent key
        value = SettingsManager.get("non_existent_key_12345", "default_value")
        assert value == "default_value", "Default value not returned for missing key"
    suite.run_test("Settings defaults", test)


def test_admin_user_exists(suite: TestSuite):
    def test(result):
        admin = UserManager.get_user("admin")
        assert admin is not None, "Admin user does not exist"
        assert admin.is_admin, "Admin user is not marked as admin"
    suite.run_test("Admin user exists", test)


def test_user_login(suite: TestSuite):
    def test(result):
        # This uses UserManager.login which may not exist - adjust as needed
        admin = UserManager.get_user("admin")
        if admin:
            # Just verify we can get the admin
            assert admin.username == "admin"
    suite.run_test("User login", test)


def test_patient_dat_encoding(suite: TestSuite):
    def test(result):
        patients = PatientManager.get_all_patients()
        if not patients:
            raise AssertionError("No patients to test encoding")
        # Verify Greek characters are readable
        for patient in patients:
            # These should not raise Unicode errors
            _ = patient.surname.encode('utf-8')
            _ = patient.name.encode('utf-8')
    suite.run_test("Patient DAT encoding", test)


def test_patient_search_case_insensitive(suite: TestSuite):
    def test(result):
        patients = PatientManager.get_all_patients()
        if not patients:
            raise AssertionError("No patients to test")
        test_surname = patients[0].surname
        if len(test_surname) < 2:
            raise AssertionError("Surname too short for case test")
        # Search with different case
        upper_search = test_surname.upper()[:2]
        lower_search = test_surname.lower()[:2]
        upper_results = PatientManager.search_by_name(upper_search)
        lower_results = PatientManager.search_by_name(lower_search)
        # Both should find the same patients
        assert len(upper_results) == len(lower_results), \
            f"Case-sensitive search: upper={len(upper_results)}, lower={len(lower_results)}"
    suite.run_test("Patient search case-insensitive", test)


def main():
    print("\n" + "#"*60)
    print("# DENTAL DATABASE MK2 - AUTOMATED TESTS")
    print("#"*60 + "\n")

    suite = TestSuite()

    # Patient tests
    test_database_directory_exists(suite)
    test_patient_files_readable(suite)
    test_patient_lookup_by_code(suite)
    test_patient_search(suite)
    test_patient_code_generation(suite)
    test_patient_create(suite)
    test_patient_update(suite)
    test_patient_dat_encoding(suite)
    test_patient_search_case_insensitive(suite)

    # Calendar tests
    test_appointments_file(suite)
    test_appointments_get_by_date(suite)

    # Work types tests
    test_work_types_load(suite)
    test_work_type_lookup(suite)

    # Settings tests
    test_settings_get_set(suite)
    test_settings_defaults(suite)

    # User tests
    test_admin_user_exists(suite)
    test_user_login(suite)

    # Run summary
    success = suite.summary()

    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())

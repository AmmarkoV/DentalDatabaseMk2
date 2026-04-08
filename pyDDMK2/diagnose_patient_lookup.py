#!/usr/bin/env python3
"""
Diagnose the patient lookup issue for "Open" button.
"""
import sys
from pathlib import Path

project_dir = Path(__file__).parent
sys.path.insert(0, str(project_dir))

from people import PatientManager

print("\n" + "="*60)
print(" PATIENT LOOKUP DIAGNOSTIC")
print("="*60)

# Get database directory
db_dir = PatientManager.get_database_dir()
print(f"\nDatabase directory: {db_dir}")
print(f"Exists: {db_dir.exists()}")

# List .dat files
if db_dir.exists():
    dat_files = list(db_dir.glob("*.dat"))
    print(f"\n.dat files found: {len(dat_files)}")
    for f in dat_files:
        print(f"  - {f.name}")

# Get all patients
print("\n" + "-"*60)
print("GETTING ALL PATIENTS")
patients = PatientManager.get_all_patients()
print(f"Total patients: {len(patients)}")

for i, p in enumerate(patients[:10]):
    print(f"\n[{i+1}] Patient:")
    print(f"    Code: {p.code}")
    print(f"    Surname: {p.surname}")
    print(f"    Name: {p.name}")
    print(f"    Telephone: {p.telephone}")

if len(patients) > 10:
    print(f"\n... and {len(patients) - 10} more")

# Test lookup for first patient
if patients:
    test_patient = patients[0]
    print("\n" + "-"*60)
    print(f"TESTING LOOKUP FOR: {test_patient.code}")

    # Direct lookup
    found = PatientManager.get_patient(test_patient.code)
    print(f"\nPatientManager.get_patient('{test_patient.code}'):")
    if found:
        print(f"  SUCCESS: {found.surname} {found.name}")
    else:
        print(f"  FAILED: None returned")

        # Try to find the file
        dat_file = db_dir / f"{test_patient.code}.dat"
        print(f"\nChecking file: {dat_file}")
        print(f"  Exists: {dat_file.exists()}")

        if dat_file.exists():
            print(f"\nFile contents (first 500 chars):")
            try:
                content = dat_file.read_text(encoding='windows-1253')
                print(content[:500])
            except Exception as e:
                print(f"Error reading: {e}")
else:
    print("\nNo patients found to test with!")

print("\n" + "="*60)

"""
Greeklish Transliteration and Translation Module
"""

# Greek to Latin transliteration table
GREEK_TO_LATIN = {
    'Α': 'A', 'Ά': 'A', 'Β': 'B', 'Γ': 'G', 'Δ': 'D',
    'Ε': 'E', 'Έ': 'E', 'Ζ': 'Z', 'Η': 'H', 'Ή': 'H',
    'Θ': '8', 'Ι': 'I', 'Ί': 'I', 'Κ': 'K', 'Λ': 'L',
    'Μ': 'M', 'Ν': 'N', 'Ξ': 'KS', 'Ο': 'O', 'Ό': 'O',
    'Π': 'P', 'Ρ': 'R', 'Σ': 'S', 'ς': 'S', 'Τ': 'T',
    'Υ': 'Y', 'Ύ': 'Y', 'Φ': 'F', 'Χ': 'X', 'Ψ': 'PS',
    'Ω': 'W', 'Ώ': 'W',
}

def remove_tones(text: str) -> str:
    """Remove Greek tonos (accent marks)."""
    tone_mapping = {'Ά': 'Α', 'Ϊ': 'Ι', 'Έ': 'Ε', 'Ή': 'Η', 'Ί': 'Ι',
                    'Ό': 'Ο', 'Ύ': 'Υ', 'Ώ': 'Ω'}
    return ''.join(tone_mapping.get(c, c) for c in text)

def simplify_diphthongs(text: str) -> str:
    """Simplify Greek diphthongs (AI->A, EI->E, etc)."""
    result = text.upper()
    for diph, single in [('ΑΙ', 'Α'), ('ΕΙ', 'Ε'), ('ΟΙ', 'Ο'), ('ΥΙ', 'Υ'), ('ΗΙ', 'Η')]:
        result = result.replace(diph, single)
    return result

def greeklish(text: str) -> str:
    """Convert Greek to Greeklish (Latin transliteration)."""
    result = []
    for char in text.upper():
        result.append(GREEK_TO_LATIN.get(char, char))
    return ''.join(result).lower()

def greek_equal(str1: str, str2: str) -> bool:
    """Compare strings with Greek tolerance."""
    def normalize(s: str) -> str:
        s = s.upper()
        s = remove_tones(s)
        s = simplify_diphthongs(s)
        s = greeklish(s)
        return s
    return normalize(str1) == normalize(str2)

# English to Greek translation dictionary
EN_TO_GR = {
    "New Patient": "Νέος ασθενής",
    "Open Patient": "Άνοιγμα ασθενή",
    "Search Patient": "Αναζήτηση ασθενούς",
    "Save": "Αποθήκευση",
    "Exit": "Έξοδος",
    "OK": "ΟΚ",
    "Cancel": "Άκυρο",
    "Close": "Κλείσιμο",
    "Yes": "ΝΑΙ",
    "No": "ΟΧΙ",
    "Delete": "Διαγραφή",
    "Send": "Αποστολή",
    "Code": "Κωδικός",
    "Name": "Όνομα",
    "Surname": "Επίθετο",
    "Area": "Περιοχή",
    "Telephone": "Τηλέφωνο",
    "Cell Phone": "Κινητό",
    "Address": "Διεύθυνση",
    "Profession": "Επάγγελμα",
    "Email": "Email",
    "Birth Date": "Ημερομηνία Γέννησης",
    "Next Visit": "Επόμενη Επισκέψεις",
    "Works": "Εργασίες",
    "Price": "Τιμή",
    "Discount": "Έκπτωση",
    "Paid": "Πληρώθηκε",
    "Comments": "Σχόλια",
    "Status": "Κατάσταση",
    "Doctor": "Ιατρός",
    "Description": "Περιγραφή",
    "Teeth": "Οδόντοι",
    "Calendar": "Ημερολόγιο",
    "Date": "Ημερομηνία",
    "Payment": "Πληρωμή",
    "Income": "Έσοδα",
    "User": "Χρήστης",
    "Users": "Χρήστες",
    "Login": "Σύνδεση",
    "Password": "Κωδικός Πρόσβασης",
    "Message": "Μήνυμα",
    "Search": "Αναζήτηση",
    "Filter": "Φίλτρο",
    "System": "Σύστημα",
    "Settings": "Ρυθμίσεις",
    "Database": "Βάση Δεδομένων",
    "Backup": "Αντίγραφο Ασφαλείας",
    "Report": "Έκθεση",
    "Print": "Εκτύπωση",
    "Success": "Επιτυχία",
    "Error": "Σφάλμα",
    "Warning": "Προειδοποίηση",
    "Father": "Πατέρας",
    "Question": "Ερώτηση",
    "Patient": "Ασθενής",
    "Patient created successfully": "Ασθενής δημιουργήθηκε επιτυχώς",
    "Please enter surname and name": "Παρακαλώ εισάγετε επίθετο και όνομα",
    "Failed to create patient": "Αποτυχία δημιουργίας ασθενούς",
    "Please select a patient": "Παρακαλώ επιλέξτε ασθενή",
    "Patient not found": "Ασθενής δεν βρέθηκε",
    "Patient updated successfully": "Ασθενής ενημερώθηκε επιτυχώς",
    "Failed to update patient": "Αποτυχία ενημέρωσης ασθενούς",
    "Personal Data": "Προσωπικά Στοιχεία",
    "Works/History": "Εργασίες/Ιστορικό",
    "Work ID": "Κωδικός Εργασίας",
    "Total Price": "Συνολική Τιμή",
    "Total Paid": "Συνολικά Πληρωμένα",
    "Outstanding": "Οφειλόμενα",
    "Outstanding Balance": "Υπόλοιπο Οφειλής",
    "Payment information is tracked per work/treatment.\nSee the Works/History tab for detailed payment records.": "Οι πληρωμές καταγράφονται ανά εργασία/θεραπεία.\nΔείτε τη καρτέλα Εργασίες/Ιστορικό για αναλυτικά αρχεία πληρωμών.",
    "Payments": "Πληρωμές",
}

GR_TO_EN = {v: k for k, v in EN_TO_GR.items()}

def translate_en_to_gr(text: str) -> str:
    return EN_TO_GR.get(text, text)

def translate_gr_to_en(text: str) -> str:
    return GR_TO_EN.get(text, text)

def trim_spaces(text: str) -> str:
    return text.strip()

def remove_spaces(text: str) -> str:
    return text.replace(' ', '')

def first_capital(text: str) -> str:
    if not text:
        return text
    return text[0].upper() + text[1:]

def is_filesystem_safe(text: str) -> bool:
    invalid_chars = set('\\/?*:"><>|')
    return not any(c in invalid_chars for c in text)

def sanitize_filename(text: str) -> str:
    invalid_chars = set('\\/?*:"><>|')
    return ''.join(c for c in text if c not in invalid_chars)

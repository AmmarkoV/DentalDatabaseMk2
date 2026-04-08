#!/usr/bin/env python3
"""
Dental teeth data management.
Ported from teeth.pas
"""
import re
from pathlib import Path
from typing import List, Optional, Dict
from datetime import datetime

from models import Tooth, ToothData, ToothAux
from tools import get_app_path

# Surface names (Greek)
SURFACE_NAMES = {
    1: "ρίζα",    # Root
    2: "5y",     # Lingual (lower)
    3: "2e",     # Mesial
    4: "2a",     # Distal
    5: "1",      # Occlusal
    6: "5p",     # Palatal/Buccal
}

# Auxiliary tooth codes
AUX_CODES = {
    'VIDA': 'Crown',
    'SEALANT': 'Sealant',
    'X': 'Extraction',
    'O.O.': 'Missing',
    'M.O.': 'Missing',
    'RIZ_APOKSISI': 'Root Resorption',
    'RIZA': 'Root Canal',
    'ENDODONTIKI_THERAPEIA': 'Root Canal',
    'ARROW': 'Bridge',
}


class TeethManager:
    """Manages teeth data from .teeth files."""

    @staticmethod
    def get_teeth_file_path(patient_code: str) -> Path:
        """Get path to patient's .teeth file."""
        database_dir = get_app_path() / "Database"
        return database_dir / f"{patient_code}.teeth"

    @staticmethod
    def parse_teeth_file(filepath: Path) -> tuple[List[ToothAux], List[ToothData]]:
        """Parse a .teeth file and return aux and data lists."""
        aux_list: List[ToothAux] = []
        data_list: List[ToothData] = []

        if not filepath.exists():
            return aux_list, data_list

        try:
            content = filepath.read_text(encoding='utf-8')
        except UnicodeDecodeError:
            try:
                content = filepath.read_text(encoding='windows-1253')
            except:
                return aux_list, data_list

        for line in content.strip().split('\n'):
            line = line.strip()
            if not line:
                continue

            # TEETH_AUX(tooth_num,aux_code)
            aux_match = re.match(r'^TEETH_AUX\((\d+),([^,]+)\)$', line)
            if aux_match:
                tooth_num = int(aux_match.group(1))
                aux_code = aux_match.group(2)
                aux_list.append(ToothAux(tooth_number=tooth_num, aux_code=aux_code))
                continue

            # TEETH_DATA(tooth_num,part_num,doctor,work,comments,technical,status)
            data_match = re.match(r'^TEETH_DATA\((\d+),(\d+),([^,]*),([^,]*),([^,]*),([^,]*),(.*)\)$', line)
            if data_match:
                tooth_num = int(data_match.group(1))
                part_num = int(data_match.group(2))
                doctor = data_match.group(3)
                work = data_match.group(4)
                comments = data_match.group(5)
                technical = data_match.group(6)
                status = data_match.group(7)
                data_list.append(ToothData(
                    tooth_number=tooth_num,
                    part=part_num,
                    doctor=doctor,
                    work=work,
                    comments=comments,
                    technical=technical,
                    status=status
                ))
                continue

            # TEETH_COLOR(tooth_num,part_num,R,G,B)
            color_match = re.match(r'^TEETH_COLOR\((\d+),(\d+),(\d+),(\d+),(\d+)\)$', line)
            if color_match:
                tooth_num = int(color_match.group(1))
                part_num = int(color_match.group(2))
                r = int(color_match.group(3))
                g = int(color_match.group(4))
                b = int(color_match.group(5))
                # Find existing tooth data and update color
                for td in data_list:
                    if td.tooth_number == tooth_num and td.part == part_num:
                        td.color_r = r
                        td.color_g = g
                        td.color_b = b
                        break

        return aux_list, data_list

    @staticmethod
    def get_patient_teeth(patient_code: str) -> tuple[List[ToothAux], List[ToothData]]:
        """Get all teeth data for a patient."""
        teeth_file = TeethManager.get_teeth_file_path(patient_code)
        return TeethManager.parse_teeth_file(teeth_file)

    @staticmethod
    def get_tooth_aux(tooth_number: int, aux_list: List[ToothAux]) -> Optional[ToothAux]:
        """Get auxiliary data for a tooth."""
        for aux in aux_list:
            if aux.tooth_number == tooth_number:
                return aux
        return None

    @staticmethod
    def get_tooth_surfaces(tooth_number: int, data_list: List[ToothData]) -> List[ToothData]:
        """Get all surface data for a tooth."""
        return [td for td in data_list if td.tooth_number == tooth_number]

    @staticmethod
    def get_aux_description(aux_code: str) -> str:
        """Get human-readable description for aux code."""
        return AUX_CODES.get(aux_code.upper(), aux_code)

    @staticmethod
    def get_surface_name(part: int) -> str:
        """Get surface name for part number."""
        return SURFACE_NAMES.get(part, f"Part {part}")

    @staticmethod
    def get_quadrant(tooth_number: int) -> str:
        """Get quadrant for FDI tooth number."""
        if tooth_number < 10:
            quadrant = tooth_number
        else:
            quadrant = tooth_number // 10

        quadrants = {
            1: "Upper Right",
            2: "Upper Left",
            3: "Lower Left",
            4: "Lower Right",
        }
        return quadrants.get(quadrant, "Unknown")

    @staticmethod
    def get_tooth_type(tooth_number: int) -> str:
        """Get tooth type for FDI tooth number."""
        if tooth_number < 10:
            tooth_type = tooth_number
        else:
            tooth_type = tooth_number % 10

        types = {
            1: "Central Incisor",
            2: "Lateral Incisor",
            3: "Canine",
            4: "First Premolar",
            5: "Second Premolar",
            6: "First Molar",
            7: "Second Molar",
            8: "Third Molar",
        }
        return types.get(tooth_type, "Unknown")

    @staticmethod
    def save_teeth_file(
        patient_code: str,
        aux_list: List[ToothAux],
        data_list: List[ToothData]
    ) -> bool:
        """Save teeth data to .teeth file."""
        teeth_file = TeethManager.get_teeth_file_path(patient_code)

        try:
            lines = []

            # Write aux data
            for aux in aux_list:
                lines.append(f"TEETH_AUX({aux.tooth_number},{aux.aux_code})")

            # Write surface data
            for td in data_list:
                line = f"TEETH_DATA({td.tooth_number},{td.part},{td.doctor},{td.work},{td.comments},{td.technical},{td.status})"
                lines.append(line)

                # Write color if set
                if td.color_r > 0 or td.color_g > 0 or td.color_b > 0:
                    lines.append(f"TEETH_COLOR({td.tooth_number},{td.part},{td.color_r},{td.color_g},{td.color_b})")

            teeth_file.write_text('\n'.join(lines) + '\n', encoding='utf-8')
            return True
        except Exception as e:
            print(f"Error saving teeth file: {e}")
            return False


# Legacy compatibility - keep old TeethManager methods for Tooth model
# These are placeholders for future SQLite integration

import os
import re
import io
import logging
from typing import Dict, Any, Optional, Tuple, List

logger = logging.getLogger('SoilReportParser')

try:
    import pdfplumber
    PDFPLUMBER_AVAILABLE = True
except ImportError:
    PDFPLUMBER_AVAILABLE = False

try:
    import pypdf
    PYPDF_AVAILABLE = True
except ImportError:
    PYPDF_AVAILABLE = False

try:
    from PIL import Image
    PILLOW_AVAILABLE = True
except ImportError:
    PILLOW_AVAILABLE = False


class SoilReportParser:
    """
    Enterprise-Grade Agronomic Document Analysis Engine for Soil Health Cards & Lab Reports.
    Supports multi-page text-based and table-based PDFs as well as image reports.
    Extracts all primary, secondary, micronutrients, physical soil properties, and metadata.
    Normalizes units, calculates confidence scores, flags review requirements, and constructs
    a unified Canonical Soil Profile without fabricating fake values.
    """

    ALLOWED_EXTENSIONS = {'.pdf', '.jpg', '.jpeg', '.png'}

    # Supported parameters definition: keys, search patterns, standard unit, and biological bounds
    PARAMETER_SPECS = {
        'ph': {
            'display_name': 'Soil Reaction (pH)',
            'patterns': [
                r'(?:soil\s*)?(?:reaction\s*)?\(?\bph\b\)?(?:\s*\(1:2\.5\))?',
                r'\bph\b\s*(?:value|level)?',
                r'soil\s*reaction'
            ],
            'standard_unit': 'pH',
            'min_val': 3.0,
            'max_val': 11.0,
            'is_numeric': True,
        },
        'electrical_conductivity': {
            'display_name': 'Electrical Conductivity (EC)',
            'patterns': [
                r'electrical\s*conductivity',
                r'\bec\b(?:\s*\(1:2\.5\))?',
                r'specific\s*conductance',
                r'salinity'
            ],
            'standard_unit': 'dS/m',
            'min_val': 0.0,
            'max_val': 30.0,
            'is_numeric': True,
        },
        'organic_carbon': {
            'display_name': 'Organic Carbon (OC)',
            'patterns': [
                r'organic\s*carbon',
                r'\boc\b',
                r'soil\s*organic\s*carbon',
                r'organic\s*matter'
            ],
            'standard_unit': '%',
            'min_val': 0.01,
            'max_val': 15.0,
            'is_numeric': True,
        },
        'nitrogen': {
            'display_name': 'Available Nitrogen (N)',
            'patterns': [
                r'(?:available\s*)?nitrogen',
                r'\bavail(?:able)?\.?\s*n\b',
                r'total\s*nitrogen',
                r'\bn\b(?:\s*\(n\))?'
            ],
            'standard_unit': 'kg/ha',
            'min_val': 10.0,
            'max_val': 1500.0,
            'is_numeric': True,
        },
        'phosphorus': {
            'display_name': 'Available Phosphorus (P)',
            'patterns': [
                r'(?:available\s*)?(?:phosphorus|phosphate)',
                r'\bavail(?:able)?\.?\s*p\b',
                r'\bp2o5\b',
                r'\bp\b(?:\s*\(p\))?'
            ],
            'standard_unit': 'kg/ha',
            'min_val': 0.5,
            'max_val': 400.0,
            'is_numeric': True,
        },
        'potassium': {
            'display_name': 'Available Potassium (K)',
            'patterns': [
                r'(?:available\s*)?(?:potassium|potash)',
                r'\bavail(?:able)?\.?\s*k\b',
                r'\bk2o\b',
                r'\bk\b(?:\s*\(k\))?'
            ],
            'standard_unit': 'kg/ha',
            'min_val': 5.0,
            'max_val': 2000.0,
            'is_numeric': True,
        },
        'sulfur': {
            'display_name': 'Available Sulphur (S)',
            'patterns': [
                r'(?:available\s*)?sulphur',
                r'(?:available\s*)?sulfur',
                r'\bavail(?:able)?\.?\s*s\b',
                r'\bso4-s\b',
                r'\bs\b(?:\s*\(s\))?'
            ],
            'standard_unit': 'ppm',
            'min_val': 0.1,
            'max_val': 300.0,
            'is_numeric': True,
        },
        'calcium': {
            'display_name': 'Exchangeable Calcium (Ca)',
            'patterns': [
                r'(?:exchangeable\s*|available\s*)?calcium',
                r'\bex(?:ch)?\.?\s*ca\b',
                r'\bca\b(?:\s*\(ca\))?'
            ],
            'standard_unit': 'meq/100g',
            'min_val': 0.1,
            'max_val': 3000.0,
            'is_numeric': True,
        },
        'magnesium': {
            'display_name': 'Exchangeable Magnesium (Mg)',
            'patterns': [
                r'(?:exchangeable\s*|available\s*)?magnesium',
                r'\bex(?:ch)?\.?\s*mg\b',
                r'\bmg\b(?:\s*\(mg\))?'
            ],
            'standard_unit': 'meq/100g',
            'min_val': 0.1,
            'max_val': 1500.0,
            'is_numeric': True,
        },
        'zinc': {
            'display_name': 'Available Zinc (Zn)',
            'patterns': [
                r'(?:available\s*|dtpa-?\s*)?zinc',
                r'\bavail(?:able)?\.?\s*zn\b',
                r'\bzn\b(?:\s*\(zn\))?'
            ],
            'standard_unit': 'ppm',
            'min_val': 0.02,
            'max_val': 60.0,
            'is_numeric': True,
        },
        'iron': {
            'display_name': 'Available Iron (Fe)',
            'patterns': [
                r'(?:available\s*|dtpa-?\s*)?iron',
                r'\bavail(?:able)?\.?\s*fe\b',
                r'\bfe\b(?:\s*\(fe\))?'
            ],
            'standard_unit': 'ppm',
            'min_val': 0.1,
            'max_val': 200.0,
            'is_numeric': True,
        },
        'boron': {
            'display_name': 'Available Boron (B)',
            'patterns': [
                r'(?:available\s*|hot\s*water\s*soluble\s*)?boron',
                r'\bavail(?:able)?\.?\s*b\b',
                r'\bb\b(?:\s*\(b\))?'
            ],
            'standard_unit': 'ppm',
            'min_val': 0.01,
            'max_val': 30.0,
            'is_numeric': True,
        },
        'copper': {
            'display_name': 'Available Copper (Cu)',
            'patterns': [
                r'(?:available\s*|dtpa-?\s*)?copper',
                r'\bavail(?:able)?\.?\s*cu\b',
                r'\bcu\b(?:\s*\(cu\))?'
            ],
            'standard_unit': 'ppm',
            'min_val': 0.01,
            'max_val': 40.0,
            'is_numeric': True,
        },
        'manganese': {
            'display_name': 'Available Manganese (Mn)',
            'patterns': [
                r'(?:available\s*|dtpa-?\s*)?manganese',
                r'\bavail(?:able)?\.?\s*mn\b',
                r'\bmn\b(?:\s*\(mn\))?'
            ],
            'standard_unit': 'ppm',
            'min_val': 0.1,
            'max_val': 150.0,
            'is_numeric': True,
        },
        'soil_moisture': {
            'display_name': 'Soil Moisture',
            'patterns': [
                r'(?:soil\s*)?moisture(?:\s*content)?',
                r'\bmoisture\b'
            ],
            'standard_unit': '%',
            'min_val': 0.0,
            'max_val': 100.0,
            'is_numeric': True,
        },
        'soil_type': {
            'display_name': 'Soil Type',
            'patterns': [
                r'soil\s*type',
                r'soil\s*classification',
                r'soil\s*order'
            ],
            'standard_unit': 'type',
            'is_numeric': False,
            'allowed_values': ['Sandy', 'Loamy', 'Clayey', 'Black Soil', 'Red Soil', 'Alluvial', 'Laterite', 'Saline']
        },
        'soil_texture': {
            'display_name': 'Soil Textural Class',
            'patterns': [
                r'soil\s*texture',
                r'textural\s*class',
                r'texture'
            ],
            'standard_unit': 'textural_class',
            'is_numeric': False,
            'allowed_values': ['Sandy', 'Sandy Loam', 'Loam', 'Silt Loam', 'Clay Loam', 'Clay', 'Silty Clay']
        },
    }

    @classmethod
    def validate_file(cls, filename: str, file_bytes: bytes) -> Tuple[bool, str]:
        ext = os.path.splitext(filename.lower())[1]
        if ext not in cls.ALLOWED_EXTENSIONS:
            return False, f"Unsupported file format '{ext}'. Please upload a PDF, JPG, JPEG, or PNG soil test report."
        if not file_bytes or len(file_bytes) < 50:
            return False, "Uploaded file appears empty or corrupted."
        if len(file_bytes) > 15 * 1024 * 1024:
            return False, "File size exceeds the 15 MB limit."
        return True, ""

    @classmethod
    def extract_document_content(cls, filename: str, file_bytes: bytes) -> Tuple[str, List[List[List[str]]], Optional[str]]:
        """
        Extracts both plain text and structured tabular matrices across all pages of the document.
        Returns: (full_text, all_tables, error_message)
        """
        ext = os.path.splitext(filename.lower())[1]
        full_text = ""
        all_tables: List[List[List[str]]] = []

        if ext == '.pdf':
            # Priority 1: pdfplumber for high-fidelity text and table extraction
            if PDFPLUMBER_AVAILABLE:
                try:
                    with pdfplumber.open(io.BytesIO(file_bytes)) as pdf:
                        if len(pdf.pages) == 0:
                            return "", [], "The uploaded PDF report has no readable pages."
                        for i, page in enumerate(pdf.pages):
                            page_text = page.extract_text(layout=False) or ""
                            full_text += f"\n--- Page {i+1} ---\n" + page_text
                            tables = page.extract_tables()
                            if tables:
                                for table in tables:
                                    cleaned_table = []
                                    for row in table:
                                        if row:
                                            cleaned_row = [str(cell).strip() if cell is not None else "" for cell in row]
                                            cleaned_table.append(cleaned_row)
                                    if cleaned_table:
                                        all_tables.append(cleaned_table)
                except Exception as e:
                    logger.warning(f"pdfplumber extraction encountered error: {e}. Falling back to pypdf.")

            # Priority 2 fallback: pypdf if pdfplumber didn't yield text
            if not full_text.strip() and PYPDF_AVAILABLE:
                try:
                    reader = pypdf.PdfReader(io.BytesIO(file_bytes))
                    for i, page in enumerate(reader.pages):
                        extracted = page.extract_text() or ""
                        full_text += f"\n--- Page {i+1} ---\n" + extracted
                except Exception as e:
                    logger.error(f"pypdf extraction failed for {filename}: {e}")
                    return "", [], f"Corrupted or password-protected PDF: {str(e)}"

        elif ext in {'.jpg', '.jpeg', '.png'}:
            if not PILLOW_AVAILABLE:
                return "", [], "Image processing library (Pillow) not installed on server."
            try:
                img = Image.open(io.BytesIO(file_bytes))
                try:
                    import pytesseract
                    full_text = pytesseract.image_to_string(img)
                except Exception:
                    pass
            except Exception as e:
                return "", [], f"Unreadable image file: {str(e)}"

        # Check for scanned PDF / image without OCR
        cleaned_text = full_text.strip()
        if len(cleaned_text) < 30 and not all_tables:
            # Check OCR fallback
            ocr_text = cls._attempt_ocr_fallback(file_bytes, ext)
            if ocr_text:
                full_text = ocr_text
                cleaned_text = full_text.strip()
            else:
                return "", [], "This document appears to be a scanned image without selectable text. Please ensure OCR text is accessible or upload a digitally generated PDF."

        return cleaned_text, all_tables, None

    @classmethod
    def _attempt_ocr_fallback(cls, file_bytes: bytes, ext: str) -> Optional[str]:
        """Tries pytesseract OCR if available on the host machine."""
        try:
            import pytesseract
            if ext == '.pdf':
                try:
                    import pypdfium2
                    pdf = pypdfium2.PdfDocument(file_bytes)
                    text_parts = []
                    for page in pdf:
                        pil_image = page.render().to_pil()
                        text_parts.append(pytesseract.image_to_string(pil_image))
                    return "\n".join(text_parts)
                except Exception:
                    return None
            elif ext in {'.jpg', '.jpeg', '.png'}:
                img = Image.open(io.BytesIO(file_bytes))
                return pytesseract.image_to_string(img)
        except Exception:
            return None
        return None

    @classmethod
    def extract_metadata(cls, text: str) -> Dict[str, Any]:
        """Extracts report metadata such as sample date, laboratory, location, farmer name."""
        meta = {
            'sample_date': None,
            'laboratory': None,
            'location': None,
            'farmer_name': None,
        }

        # Date pattern (YYYY-MM-DD or DD/MM/YYYY or DD-Month-YYYY)
        date_match = re.search(r'(?:sample\s*date|date\s*of\s*(?:testing|collection|sampling|issue)|date)\s*[:=-]?\s*([0-9]{1,4}[-/.][0-9]{1,2}[-/.][0-9]{1,4}|[0-9]{1,2}\s+[A-Za-z]{3,9}\s+[0-9]{4})', text, re.IGNORECASE)
        if date_match:
            meta['sample_date'] = date_match.group(1).strip()

        # Lab pattern
        lab_match = re.search(r'(?:laboratory|testing\s*lab(?:oratory)?|soil\s*testing\s*lab)\s*[:=-]?\s*([^\n\r,;]{3,50})', text, re.IGNORECASE)
        if lab_match:
            meta['laboratory'] = lab_match.group(1).strip()
        elif 'icar' in text.lower():
            meta['laboratory'] = 'ICAR Soil Testing Laboratory'

        # Location / District
        loc_match = re.search(r'(?:location|village|district|state)\s*[:=-]?\s*([^\n\r,;]{3,40})', text, re.IGNORECASE)
        if loc_match:
            meta['location'] = loc_match.group(1).strip()

        # Farmer name
        name_match = re.search(r'(?:farmer\s*name|name\s*of\s*farmer|farmer)\s*[:=-]?\s*([^\n\r,;]{3,40})', text, re.IGNORECASE)
        if name_match:
            meta['farmer_name'] = name_match.group(1).strip()

        return meta

    @classmethod
    def parse_soil_parameters(cls, raw_text: str, tables: List[List[List[str]]], filename: str = "") -> Dict[str, Any]:
        """
        Executes parameter identification, unit identification, normalization, range validation,
        and constructs both extracted_parameters (with confidence/status) and canonical_soil_profile.
        """
        extracted_parameters: Dict[str, Any] = {}
        canonical_soil_profile: Dict[str, Any] = {}

        # 1. Parse from structured tables first
        for table in tables:
            cls._extract_from_table(table, extracted_parameters)

        # 2. Parse from raw text for any remaining unextracted parameters
        cls._extract_from_text(raw_text, extracted_parameters)

        # 3. Post-process: Validate bounds, normalize units, assign confidence and status
        cls._normalize_and_validate(extracted_parameters, canonical_soil_profile)

        # 4. Extract metadata
        metadata = cls.extract_metadata(raw_text)

        # 5. Check critical requirements
        critical_nutrients = ['ph', 'nitrogen', 'phosphorus', 'potassium']
        missing_critical = [k for k in critical_nutrients if k not in canonical_soil_profile]
        is_sufficient = len(missing_critical) == 0

        return {
            'original_filename': filename,
            'metadata': metadata,
            'extracted_parameters': extracted_parameters,
            'canonical_soil_profile': canonical_soil_profile,
            'is_sufficient': is_sufficient,
            'missing_critical_parameters': missing_critical,
            'total_detected': len(canonical_soil_profile)
        }

    @classmethod
    def _extract_from_table(cls, table: List[List[str]], extracted: Dict[str, Any]):
        """Inspects table rows for agronomic parameter names, values, units, and ratings."""
        if not table or len(table) < 2:
            return

        for row in table:
            if not row or len(row) < 2:
                continue

            row_str = " ".join(row).lower()

            for param_key, spec in cls.PARAMETER_SPECS.items():
                if param_key in extracted:
                    continue  # Already extracted

                # Check if this row mentions the parameter
                matched = False
                for pat in spec['patterns']:
                    if re.search(pat, row_str, re.IGNORECASE):
                        matched = True
                        break

                if not matched:
                    continue

                # Search row cells for candidate values and units
                if spec['is_numeric']:
                    val_candidate, unit_candidate, src_cell = cls._find_numeric_in_row(row, param_key)
                    if val_candidate is not None:
                        extracted[param_key] = {
                            'raw_value': str(val_candidate),
                            'detected_unit': unit_candidate or '',
                            'source_text': f"Table row: {' | '.join(row)}",
                            'source': 'table'
                        }
                else:
                    # String property (soil type / texture)
                    str_candidate = cls._find_categorical_in_row(row, spec.get('allowed_values', []))
                    if str_candidate:
                        extracted[param_key] = {
                            'raw_value': str_candidate,
                            'detected_unit': spec['standard_unit'],
                            'source_text': f"Table row: {' | '.join(row)}",
                            'source': 'table'
                        }

    @classmethod
    def _find_numeric_in_row(cls, row: List[str], param_key: str) -> Tuple[Optional[float], Optional[str], Optional[str]]:
        """Finds the most plausible numeric reading and unit inside a table row."""
        for cell in row:
            # Look for number in cell
            m = re.search(r'\b(\d+(?:\.\d+)?)\b', cell)
            if m:
                try:
                    num = float(m.group(1))
                    # Avoid row index numbers (like 1, 2, 3 in first column)
                    if cell.strip() == str(int(num)) and int(num) in range(1, 25) and row.index(cell) == 0:
                        continue
                    
                    # Detect unit in cell or adjacent cells
                    unit = cls._detect_unit_string(" ".join(row))
                    return num, unit, cell
                except ValueError:
                    continue
        return None, None, None

    @classmethod
    def _find_categorical_in_row(cls, row: List[str], allowed: List[str]) -> Optional[str]:
        row_text = " ".join(row).lower()
        # Check longer matches first (e.g., 'Sandy Loam' before 'Sandy')
        for cat in sorted(allowed, key=len, reverse=True):
            if cat.lower() in row_text:
                return cat
        return None

    @classmethod
    def _extract_from_text(cls, text: str, extracted: Dict[str, Any]):
        """Extracts parameters from unstructured/semi-structured text using regex."""
        lines = text.split('\n')

        for param_key, spec in cls.PARAMETER_SPECS.items():
            if param_key in extracted:
                continue

            for pat in spec['patterns']:
                if spec['is_numeric']:
                    # Look for pattern followed by value and optional unit
                    full_pattern = rf'{pat}\s*(?:\([^)]*\))?\s*[:=-]?\s*(\d+(?:\.\d+)?)\s*([a-zA-Z/%]+)?'
                    m = re.search(full_pattern, text, re.IGNORECASE)
                    if m:
                        try:
                            val = float(m.group(1))
                            unit = m.group(2) if m.group(2) else cls._detect_unit_string(m.group(0))
                            extracted[param_key] = {
                                'raw_value': str(val),
                                'detected_unit': unit or '',
                                'source_text': m.group(0).strip(),
                                'source': 'text_pattern'
                            }
                            break
                        except ValueError:
                            pass
                else:
                    # Categorical soil type or texture
                    for allowed in sorted(spec.get('allowed_values', []), key=len, reverse=True):
                        if re.search(rf'{pat}\s*[:=-]?\s*.*\b{re.escape(allowed)}\b', text, re.IGNORECASE):
                            extracted[param_key] = {
                                'raw_value': allowed,
                                'detected_unit': spec['standard_unit'],
                                'source_text': f"Detected {allowed}",
                                'source': 'text_pattern'
                            }
                            break
                    if param_key in extracted:
                        break

    @classmethod
    def _detect_unit_string(cls, text: str) -> str:
        text_lower = text.lower()
        if 'kg/ha' in text_lower or 'kgha' in text_lower or 'kg / ha' in text_lower:
            return 'kg/ha'
        if 'kg/acre' in text_lower:
            return 'kg/acre'
        if 'ppm' in text_lower:
            return 'ppm'
        if 'mg/kg' in text_lower:
            return 'mg/kg'
        if 'ds/m' in text_lower:
            return 'dS/m'
        if 'ms/cm' in text_lower:
            return 'mS/cm'
        if 'meq/100g' in text_lower:
            return 'meq/100g'
        if 'cmol/kg' in text_lower:
            return 'cmol/kg'
        if '%' in text_lower:
            return '%'
        return ''

    @classmethod
    def _normalize_and_validate(cls, extracted: Dict[str, Any], canonical: Dict[str, Any]):
        """
        Normalizes detected units to canonical standards and applies agronomic validation rules.
        Assigns confidence (0.0 - 1.0) and status ('HIGH_CONFIDENCE', 'REVIEW_REQUIRED', 'INVALID_VALUE').
        """
        for key, item in list(extracted.items()):
            spec = cls.PARAMETER_SPECS.get(key)
            if not spec:
                continue

            raw_val = item['raw_value']
            detected_unit = item.get('detected_unit', '').strip()
            source = item.get('source', 'text')

            if spec['is_numeric']:
                try:
                    val = float(raw_val)
                except (ValueError, TypeError):
                    item['status'] = 'INVALID_VALUE'
                    item['confidence'] = 0.0
                    item['normalized_value'] = None
                    item['normalized_unit'] = spec['standard_unit']
                    continue

                norm_val = val
                norm_unit = spec['standard_unit']
                confidence = 0.94 if source == 'table' else 0.88

                # 1. Unit Normalization
                if norm_unit == 'kg/ha':
                    # Convert ppm or mg/kg to kg/ha (factor: 2.24 for 15cm soil depth)
                    if detected_unit.lower() in ['ppm', 'mg/kg']:
                        norm_val = round(val * 2.24, 2)
                        detected_unit = 'ppm'
                    elif detected_unit.lower() == 'kg/acre':
                        norm_val = round(val * 2.47, 2)
                        detected_unit = 'kg/acre'
                    else:
                        norm_val = round(val, 2)
                        detected_unit = detected_unit or 'kg/ha'

                elif norm_unit == 'dS/m':
                    # 1 mS/cm = 1 dS/m; 1 mmhos/cm = 1 dS/m
                    norm_val = round(val, 2)
                    detected_unit = detected_unit or 'dS/m'

                elif norm_unit == '%':
                    norm_val = round(val, 2)
                    detected_unit = detected_unit or '%'

                else:
                    norm_val = round(val, 2)
                    detected_unit = detected_unit or norm_unit

                # 2. Biological / Agronomic Range Validation
                min_v = spec.get('min_val', 0.0)
                max_v = spec.get('max_val', 99999.0)

                if norm_val < min_v or norm_val > max_v:
                    status = 'INVALID_VALUE'
                    confidence = 0.25
                elif not detected_unit:
                    status = 'REVIEW_REQUIRED'
                    confidence = max(0.60, confidence - 0.20)
                else:
                    status = 'HIGH_CONFIDENCE'

                item['normalized_value'] = norm_val
                item['normalized_unit'] = norm_unit
                item['detected_unit'] = detected_unit
                item['confidence'] = confidence
                item['status'] = status

                # Add to canonical profile only if valid
                if status in ['HIGH_CONFIDENCE', 'REVIEW_REQUIRED']:
                    canonical[key] = norm_val

            else:
                # Categorical parameter (soil type / texture)
                norm_val = raw_val.strip()
                item['normalized_value'] = norm_val
                item['normalized_unit'] = spec['standard_unit']
                item['confidence'] = 0.95
                item['status'] = 'HIGH_CONFIDENCE'
                canonical[key] = norm_val

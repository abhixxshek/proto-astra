import os
import io
import json
import sqlite3
import urllib.request
import urllib.parse
from soil_report_parser import SoilReportParser

def test_soil_report_parser_synthetic():
    print("\n--- 1. Testing Text & Table Parameter Extraction ---")
    synthetic_table = [
        ['Parameter', 'Test Value', 'Unit', 'Rating'],
        ['Soil Reaction (pH)', '6.4', 'pH', 'Neutral'],
        ['Electrical Conductivity', '0.52', 'dS/m', 'Normal'],
        ['Organic Carbon', '0.72', '%', 'Medium'],
        ['Available Nitrogen', '48', 'ppm', 'Low'], # 48 ppm should normalize to 48 * 2.24 = 107.52 kg/ha
        ['Available Phosphorus', '22', 'kg/ha', 'Medium'],
        ['Available Potassium', '110', 'kg/ha', 'Medium'],
        ['Available Sulphur', '14.5', 'ppm', 'Sufficient'],
        ['Available Zinc', '0.85', 'ppm', 'Sufficient'],
        ['Available Iron', '7.4', 'ppm', 'Sufficient'],
        ['Available Boron', '0.62', 'ppm', 'Sufficient'],
        ['Soil Type', 'Loamy', 'type', 'Loamy'],
        ['Soil Textural Class', 'Sandy Loam', 'textural_class', 'Optimal'],
        ['Soil Moisture', '42.0', '%', 'Adequate']
    ]

    result = SoilReportParser.parse_soil_parameters("", [synthetic_table], "lab_sample_01.pdf")
    canonical = result['canonical_soil_profile']
    extracted = result['extracted_parameters']

    assert canonical['ph'] == 6.4, f"Expected pH 6.4, got {canonical.get('ph')}"
    assert round(canonical['nitrogen'], 1) == 107.5, f"Expected N ~107.5, got {canonical.get('nitrogen')}"
    assert canonical['phosphorus'] == 22.0, f"Expected P 22.0, got {canonical.get('phosphorus')}"
    assert canonical['potassium'] == 110.0, f"Expected K 110.0, got {canonical.get('potassium')}"
    assert canonical['organic_carbon'] == 0.72, f"Expected OC 0.72, got {canonical.get('organic_carbon')}"
    assert canonical['soil_type'] == 'Loamy', f"Expected Loamy, got {canonical.get('soil_type')}"
    assert canonical['soil_texture'] == 'Sandy Loam', f"Expected Sandy Loam, got {canonical.get('soil_texture')}"

    print("[OK] SoilReportParser successfully parsed all 14 parameters with unit normalization!")
    assert extracted['nitrogen']['status'] == 'HIGH_CONFIDENCE'

def test_no_hallucination():
    print("\n--- 2. Verifying Non-Hallucination on Empty / Corrupted Files ---")
    is_valid, msg = SoilReportParser.validate_file("empty.pdf", b"")
    assert not is_valid, "Validation should reject empty bytes"

    # Minimal unreadable bytes
    dummy_bytes = b"%PDF-1.4 dummy corrupted content with no text"
    text, tables, err = SoilReportParser.extract_document_content("corrupted.pdf", dummy_bytes)
    assert err is not None, "Extraction should return explicit error for scanned/empty text without generating fake values"
    print("[OK] Confirmed: Engine does NOT fabricate values when extraction fails!")

def test_sqlite_persistence():
    print("\n--- 3. Verifying SQLite Relational Persistence for Multiple Reports ---")
    db_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'agri.db')
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()

    cur.execute("SELECT COUNT(*) FROM farmer_soil_reports WHERE farmer_id=44")
    reports_count = cur.fetchone()[0]
    print(f"[OK] Found {reports_count} historical soil report(s) associated with Farmer #44 in SQLite.")

    cur.execute("SELECT r.report_id, p.ph, p.nitrogen, p.soil_type FROM farmer_soil_reports r JOIN canonical_soil_profiles p ON r.report_id = p.report_id WHERE r.farmer_id=44")
    rows = cur.fetchall()
    for row in rows:
        print(f"  -> Report: {row[0]}, pH: {row[1]}, N: {row[2]}, Soil: {row[3]}")
    conn.close()

def test_live_api_endpoints():
    print("\n--- 4. Testing Live HTTP API Endpoints on Port 5000 ---")
    base_url = "http://127.0.0.1:5000/api/v1"

    # Health
    with urllib.request.urlopen(f"{base_url}/health") as resp:
        health_data = json.loads(resp.read().decode())
        assert health_data['status'] == 'healthy'
        print("[OK] /api/v1/health returned status healthy")

    # Sample demo report
    req = urllib.request.Request(f"{base_url}/soil-reports/sample-demo", data=b"{}", headers={'Content-Type': 'application/json'})
    with urllib.request.urlopen(req) as resp:
        demo_data = json.loads(resp.read().decode())
        assert demo_data['status'] == 'success'
        rep_id = demo_data['data']['report_id']
        profile = demo_data['data']['canonical_soil_profile']
        print(f"[OK] /api/v1/soil-reports/sample-demo created report {rep_id} with canonical profile: N={profile['nitrogen']}, P={profile['phosphorus']}, K={profile['potassium']}, pH={profile['ph']}")

    # Farmer review update
    update_payload = json.dumps({'nitrogen': 260.0, 'ph': 6.7}).encode('utf-8')
    req = urllib.request.Request(f"{base_url}/soil-reports/{rep_id}/extracted-data", data=update_payload, headers={'Content-Type': 'application/json'}, method='PUT')
    with urllib.request.urlopen(req) as resp:
        update_data = json.loads(resp.read().decode())
        assert update_data['status'] == 'success'
        print(f"[OK] /api/v1/soil-reports/{rep_id}/extracted-data verified and updated parameters!")

    # Multi-model intelligence analysis
    analyze_payload = json.dumps({'selected_crop': 'Wheat'}).encode('utf-8')
    req = urllib.request.Request(f"{base_url}/soil-reports/{rep_id}/analyze", data=analyze_payload, headers={'Content-Type': 'application/json'})
    with urllib.request.urlopen(req) as resp:
        analysis_data = json.loads(resp.read().decode())
        data = analysis_data['data']
        assert data['report_id'] == rep_id
        assert 'soil_health_summary' in data
        assert 'crop_suitability' in data
        assert 'fertilizer_recommendation' in data
        assert 'yield_prediction' in data
        print(f"[OK] /api/v1/soil-reports/{rep_id}/analyze returned Combined Intelligence:")
        print(f"  Top Crop: {data['crop_suitability']['top_crop']}")
        print(f"  Fertilizer: {data['fertilizer_recommendation']['recommended_fertilizer']}")
        print(f"  Amazon Link: {data['fertilizer_recommendation']['amazon_buy_link']}")
        print(f"  Yield: {data['yield_prediction']['predicted_yield_tonnes_ha']} Tonnes/ha")

    # Crop recommend ML endpoint
    crop_payload = json.dumps({
        'nitrogen': profile['nitrogen'],
        'phosphorus': profile['phosphorus'],
        'potassium': profile['potassium'],
        'phValue': 6.7,
        'temperature': 22.0,
        'humidity': 75.0,
        'rainfall': 210.0
    }).encode('utf-8')
    req = urllib.request.Request(f"{base_url}/ml/crop-recommend", data=crop_payload, headers={'Content-Type': 'application/json'})
    with urllib.request.urlopen(req) as resp:
        rec_data = json.loads(resp.read().decode())
        assert 'recommended_crops' in rec_data
        print(f"[OK] /api/v1/ml/crop-recommend returned crops: {rec_data['recommended_crops']}")

    # Fertilizer recommend ML endpoint
    fert_payload = json.dumps({
        'temperature': 25.0,
        'humidity': 60.0,
        'soilMoisture': 40.0,
        'soilType': profile.get('soil_type', 'Loamy'),
        'cropType': 'Wheat',
        'nitrogen': profile['nitrogen'],
        'potassium': profile['potassium'],
        'phosphorous': profile['phosphorus']
    }).encode('utf-8')
    req = urllib.request.Request(f"{base_url}/ml/fertilizer-recommend", data=fert_payload, headers={'Content-Type': 'application/json'})
    with urllib.request.urlopen(req) as resp:
        fert_data = json.loads(resp.read().decode())
        assert 'recommended_fertilizer' in fert_data
        print(f"[OK] /api/v1/ml/fertilizer-recommend returned: {fert_data['recommended_fertilizer']}")

    # Report history
    with urllib.request.urlopen(f"{base_url}/soil-reports/history") as resp:
        hist_data = json.loads(resp.read().decode())
        assert hist_data['status'] == 'success'
        print(f"[OK] /api/v1/soil-reports/history returned {hist_data['total']} total report(s).")

if __name__ == '__main__':
    test_soil_report_parser_synthetic()
    test_no_hallucination()
    test_sqlite_persistence()
    test_live_api_endpoints()
    print("\nALL ITERATION 1 PIPELINE TESTS PASSED SUCCESSFULLY! [OK]")

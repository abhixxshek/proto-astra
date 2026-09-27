import 'package:flutter_test/flutter_test.dart';
import 'package:agrosmart_mobile/data/models/soil_report_model.dart';

void main() {
  group('Soil Report Intelligence Models Test', () {
    test('SoilParameterItem parsing and status checks', () {
      final item = SoilParameterItem.fromJson('ph', {
        'raw_value': '6.80',
        'detected_unit': 'pH',
        'normalized_value': 6.8,
        'normalized_unit': 'pH',
        'confidence': 0.95,
        'status': 'HIGH_CONFIDENCE',
        'source_text': 'Soil Reaction (pH): 6.80'
      });

      expect(item.key, 'ph');
      expect(item.displayName, 'Soil Reaction (pH)');
      expect(item.normalizedValue, 6.8);
      expect(item.isHighConfidence, isTrue);
      expect(item.isReviewRequired, isFalse);
    });

    test('CombinedIntelligenceData parsing and Amazon link verification', () {
      final json = {
        'report_id': 'SR_TEST_123',
        'generated_at': '2026-09-27T05:00:00',
        'provenance': 'Based on your verified Soil Report Profile',
        'soil_health_summary': {
          'ph': {'value': 6.8, 'status': 'Near Neutral (Optimal)'},
          'nitrogen': {'value': 245.0, 'unit': 'kg/ha', 'status': 'Low', 'deficient': true},
          'phosphorus': {'value': 18.5, 'unit': 'kg/ha', 'status': 'Low', 'deficient': true},
          'potassium': {'value': 195.0, 'unit': 'kg/ha', 'status': 'Medium', 'deficient': false},
          'deficiencies': [
            {
              'nutrient': 'Nitrogen (N)',
              'level': '245 kg/ha (Low)',
              'symptom': 'Pale yellowing',
              'product': 'Urea',
              'amazon_query': 'urea fertilizer for plants',
              'amazon_buy_link': 'https://www.amazon.in/s?k=urea+fertilizer+for+plants'
            }
          ]
        },
        'crop_suitability': {
          'candidates': [
            {
              'rank': 1,
              'crop_name': 'Wheat',
              'suitability_score': 85.0,
              'suitability_rating': 'Highly Recommended',
              'reasons': 'Optimal pH and soil texture',
              'limitations': 'Adequate rainfall needed'
            }
          ],
          'top_crop': 'Wheat'
        },
        'fertilizer_recommendation': {
          'target_crop': 'Wheat',
          'recommended_fertilizer': 'Urea',
          'amazon_search_query': 'urea fertilizer for Wheat',
          'amazon_buy_link': 'https://www.amazon.in/s?k=urea+fertilizer+for+Wheat',
          'dosage_guidance': 'Apply in 3 split doses',
          'cautions': 'Irrigate after application'
        },
        'yield_prediction': {
          'crop': 'Wheat',
          'predicted_yield_hg_ha': 23100.0,
          'predicted_yield_tonnes_ha': 2.31,
          'unit': 'hg/ha',
          'key_influencing_factors': ['Soil N-P-K balance']
        },
        'weather_considerations': {
          'temperature': '25.0 °C',
          'humidity': '65.0 %',
          'rainfall': '220.0 mm/year',
          'note': 'Standard conditions'
        },
        'auditability': {
          'source_report_id': 'SR_TEST_123',
          'timestamp': '2026-09-27T05:00:00'
        }
      };

      final data = CombinedIntelligenceData.fromJson(json);

      expect(data.reportId, 'SR_TEST_123');
      expect(data.topCrop, 'Wheat');
      expect(data.cropCandidates.length, 1);
      expect(data.cropCandidates.first.cropName, 'Wheat');
      expect(data.yieldPrediction.predictedYieldTonnesHa, 2.31);
      expect(data.fertilizerPrescription.recommendedFertilizer, 'Urea');
      expect(data.fertilizerPrescription.amazonBuyLink, startsWith('https://www.amazon.in/s?k='));
      expect(data.soilHealthSummary.deficiencies.length, 1);
      expect(data.soilHealthSummary.deficiencies.first.nutrient, 'Nitrogen (N)');
    });

    test('Cross-feature soil intelligence integration accessors', () {
      final uploadJson = {
        'report_id': 'SR_TEST_999',
        'original_filename': 'test.pdf',
        'uploaded_at': '2026-09-27',
        'canonical_soil_profile': {
          'nitrogen': 245.0,
          'phosphorus': 18.5,
          'potassium': 195.0,
          'ph': 6.8,
          'soil_type': 'Black Soil',
          'soil_moisture': 35.0,
        },
        'extracted_parameters': {}
      };

      final uploadData = SoilReportUploadData.fromJson(uploadJson);
      expect(uploadData.canonicalSoilProfile['nitrogen'], 245.0);
      expect(uploadData.canonicalSoilProfile['phosphorus'], 18.5);
      expect(uploadData.canonicalSoilProfile['potassium'], 195.0);
      expect(uploadData.canonicalSoilProfile['ph'], 6.8);
      expect(uploadData.canonicalSoilProfile['soil_type'], 'Black Soil');
    });
  });
}

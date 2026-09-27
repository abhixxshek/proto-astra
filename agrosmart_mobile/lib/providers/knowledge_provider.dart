import 'package:flutter/foundation.dart';
import '../data/models/article_models.dart';

class KnowledgeProvider extends ChangeNotifier {
  final List<KnowledgeArticleModel> _articles = [
    KnowledgeArticleModel(
      id: 'k1',
      title: 'Wheat Cultivation & High-Yield Package of Practices (गेहूं खेती)',
      category: 'Crops',
      imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=600',
      description: 'Wheat is the premier Rabi cereal crop in India. Well-drained fertile loamy soils with optimal NPK balance produce up to 55-60 quintals per hectare.',
      soilRequirements: 'Loamy to clay loam soils with pH 6.0 - 7.5. Good drainage is essential.',
      climateTemperature: 'Optimal temperature during sowing: 20°C - 25°C. At grain filling: 14°C - 15°C.',
      irrigationDetails: '5-6 irrigations required: 1st at CRI stage (21 days), 2nd at tillering (42 days), 3rd at jointing (65 days), 4th at flowering (85 days), 5th at milk stage (105 days).',
      fertilizerGuide: 'NPK ratio 120:60:40 kg/ha. Apply full P and K + 50% N at sowing; remaining 50% N in 2 split top dressings.',
      harvestingDetails: 'Harvest when leaves turn yellow and grains become hard with less than 15% moisture.',
    ),
    KnowledgeArticleModel(
      id: 'k2',
      title: 'PM-Kisan & PMFBY Agricultural Insurance Schemes 2026 (सरकारी योजनाएं)',
      category: 'Government Schemes',
      imageUrl: 'https://images.unsplash.com/photo-1592417817098-8f3d6910985c?w=600',
      description: 'Overview of Pradhan Mantri Kisan Samman Nidhi (₹6,000 annual direct income support) and PM Fasal Bima Yojana crop loss compensation enrollment.',
      soilRequirements: 'Applicable to all landholding farmers across all agro-climatic zones in India.',
      climateTemperature: 'Covers localized calamities like hail, landslide, inundation, and seasonal drought.',
      irrigationDetails: 'No specific irrigation dependency for scheme registration.',
      fertilizerGuide: 'Subsidized neem-coated urea and nano-DAP distribution via PM-Kisan Samriddhi Kendras.',
      harvestingDetails: 'Submit crop loss intimation within 72 hours of damage via PMFBY App or CSC center.',
    ),
    KnowledgeArticleModel(
      id: 'k3',
      title: 'Soybean Organic Pest Management & Yellow Mosaic Virus Control',
      category: 'Plant Protection',
      imageUrl: 'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?w=600',
      description: 'Integrated pest management (IPM) guidelines for whitefly vector control, stem fly prevention, and organic bio-pesticide spray schedule.',
      soilRequirements: 'Deep black soils (Vertisols) or rich loamy soil rich in organic carbon.',
      climateTemperature: 'Warm humid climate with 26°C - 32°C and well-distributed 750-900mm rainfall.',
      irrigationDetails: 'Critical irrigation at pod initiation and grain filling stages if dry spells exceed 10 days.',
      fertilizerGuide: 'NPK 20:60:40 kg/ha + 20 kg Sulfur per hectare at sowing.',
      harvestingDetails: 'Harvest when 95% pods turn golden yellow-brown to minimize pod shattering losses.',
    ),
  ];

  List<KnowledgeArticleModel> get articles => _articles;

  KnowledgeArticleModel? getById(String id) {
    try {
      return _articles.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}

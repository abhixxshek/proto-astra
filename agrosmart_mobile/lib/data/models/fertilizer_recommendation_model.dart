class FertilizerRecommendationRequest {
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final String soilType;
  final String cropType;
  final double nitrogen;
  final double potassium;
  final double phosphorous;

  FertilizerRecommendationRequest({
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.soilType,
    required this.cropType,
    required this.nitrogen,
    required this.potassium,
    required this.phosphorous,
  });

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'soilMoisture': soilMoisture,
      'soilType': soilType,
      'cropType': cropType,
      'nitrogen': nitrogen,
      'potassium': potassium,
      'phosphorous': phosphorous,
    };
  }
}

class FertilizerRecommendationResponse {
  final String recommendedFertilizer;
  final String productName;
  final String buyLink;
  final String amazonBuyLink;
  final String amazonSearchQuery;
  final String productDescription;
  final String productImageUrl;

  FertilizerRecommendationResponse({
    required this.recommendedFertilizer,
    this.productName = '',
    this.buyLink = '',
    this.amazonBuyLink = '',
    this.amazonSearchQuery = '',
    this.productDescription = '',
    this.productImageUrl = '',
  });

  factory FertilizerRecommendationResponse.fromJson(Map<String, dynamic> json) {

    final fertilizerName = (json['recommended_fertilizer'] ?? json['recommendation'] ?? 'Urea').toString();
    final defaultAmazonQuery = '$fertilizerName fertilizer for plants';
    final defaultAmazonLink = 'https://www.amazon.in/s?k=${Uri.encodeComponent(defaultAmazonQuery)}';

    // Direct verified agricultural e-commerce product links
    final Map<String, Map<String, String>> directLinks = {
      'Urea': {
        'product': 'IFFCO Nano Urea Liquid / Granular Nitrogen Fertilizer',
        'link': 'https://www.amazon.in/s?k=urea+fertilizer+for+plants',
        'amazon_link': 'https://www.amazon.in/s?k=urea+fertilizer+for+plants',
        'amazon_query': 'urea fertilizer for plants',
        'desc': 'High Nitrogen (46% N) source for rapid vegetative leaf growth and green canopy development.',
        'image': 'https://www.iffcobazar.in/images/product/nano-urea-500ml.png',
      },
      'DAP': {
        'product': 'IFFCO Nano DAP Liquid / Di-Ammonium Phosphate 18:46:0',
        'link': 'https://www.amazon.in/s?k=dap+fertilizer+for+plants',
        'amazon_link': 'https://www.amazon.in/s?k=dap+fertilizer+for+plants',
        'amazon_query': 'dap fertilizer for plants',
        'desc': 'Rich in Phosphorus (46% P2O5) and Nitrogen (18% N) for vigorous root system and early growth.',
        'image': 'https://www.iffcobazar.in/images/product/nano-dap-500ml.png',
      },
      '14-35-14': {
        'product': 'Gromor NPK 14-35-14 Complex Fertilizer',
        'link': 'https://www.amazon.in/s?k=npk+14+35+14+fertilizer',
        'amazon_link': 'https://www.amazon.in/s?k=npk+14+35+14+fertilizer',
        'amazon_query': 'npk 14 35 14 fertilizer',
        'desc': 'High phosphate complex fertilizer ideal for root branching, flowering, and uniform maturity.',
        'image': 'https://agribegri.com/images/products/npk-14-35-14.jpg',
      },
      '28-28': {
        'product': 'Gromor NPK 28-28-0 Complex Fertilizer',
        'link': 'https://www.amazon.in/s?k=npk+28+28+0+fertilizer',
        'amazon_link': 'https://www.amazon.in/s?k=npk+28+28+0+fertilizer',
        'amazon_query': 'npk 28 28 0 fertilizer',
        'desc': 'High nitrogen & phosphate with sulfur for vigorous vegetative shoot growth and high crop yields.',
        'image': 'https://agribegri.com/images/products/npk-28-28-0.jpg',
      },
      '17-17-17': {
        'product': 'Suphala NPK 17-17-17 Balanced Complex Fertilizer',
        'link': 'https://www.amazon.in/s?k=npk+17+17+17+fertilizer',
        'amazon_link': 'https://www.amazon.in/s?k=npk+17+17+17+fertilizer',
        'amazon_query': 'npk 17 17 17 fertilizer',
        'desc': 'Equal balance of Nitrogen, Phosphorus, and Potassium for all-round crop health and balanced nutrition.',
        'image': 'https://agribegri.com/images/products/npk-17-17-17.jpg',
      },
      '20-20': {
        'product': 'IFFCO NPK 20-20-0:13 Ammonium Phosphate Sulphate',
        'link': 'https://www.amazon.in/s?k=npk+20+20+fertilizer',
        'amazon_link': 'https://www.amazon.in/s?k=npk+20+20+fertilizer',
        'amazon_query': 'npk 20 20 fertilizer',
        'desc': 'Enriched with 13% Sulfur to improve protein content in pulses and oil content in oilseed crops.',
        'image': 'https://www.iffcobazar.in/images/product/npk-20-20.png',
      },
      '10-26-26': {
        'product': 'IFFCO NPK 10-26-26 High Potash Complex Fertilizer',
        'link': 'https://www.amazon.in/s?k=npk+10+26+26+fertilizer',
        'amazon_link': 'https://www.amazon.in/s?k=npk+10+26+26+fertilizer',
        'amazon_query': 'npk 10 26 26 fertilizer',
        'desc': 'High Potash (26% K2O) and Phosphate (26% P2O5) to strengthen plant stems and maximize grain weight.',
        'image': 'https://www.iffcobazar.in/images/product/npk-10-26-26.png',
      },
    };

    final defaultInfo = directLinks[fertilizerName] ?? {
      'product': '$fertilizerName Fertilizer',
      'link': defaultAmazonLink,
      'amazon_link': defaultAmazonLink,
      'amazon_query': defaultAmazonQuery,
      'desc': 'Nutritional fertilizer formulation for optimal crop yields.',
      'image': '',
    };

    final amazonLink = json['amazon_buy_link']?.toString() ?? defaultInfo['amazon_link'] ?? defaultAmazonLink;
    final amazonQuery = json['amazon_search_query']?.toString() ?? defaultInfo['amazon_query'] ?? defaultAmazonQuery;

    return FertilizerRecommendationResponse(
      recommendedFertilizer: fertilizerName,
      productName: json['product_name']?.toString() ?? defaultInfo['product']!,
      buyLink: json['buy_link']?.toString() ?? amazonLink,
      amazonBuyLink: amazonLink,
      amazonSearchQuery: amazonQuery,
      productDescription: json['product_description']?.toString() ?? defaultInfo['desc']!,
      productImageUrl: json['product_image_url']?.toString() ?? defaultInfo['image']!,
    );
  }
}


class KnowledgeArticleModel {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final String description;
  final String soilRequirements;
  final String climateTemperature;
  final String irrigationDetails;
  final String fertilizerGuide;
  final String harvestingDetails;

  KnowledgeArticleModel({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.description,
    required this.soilRequirements,
    required this.climateTemperature,
    required this.irrigationDetails,
    required this.fertilizerGuide,
    required this.harvestingDetails,
  });
}

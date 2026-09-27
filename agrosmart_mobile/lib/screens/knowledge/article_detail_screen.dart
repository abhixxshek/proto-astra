import 'package:flutter/material.dart';
import '../../data/models/article_models.dart';

class ArticleDetailScreen extends StatelessWidget {
  final KnowledgeArticleModel article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: Text(article.category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              article.imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.green.shade50, height: 200, child: const Icon(Icons.school, size: 64, color: Color(0xFF2E7D32))),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                  const SizedBox(height: 10),
                  Text(article.description, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
                  const SizedBox(height: 16),
                  _buildSection('🌱 Soil Requirements', article.soilRequirements),
                  _buildSection('☀️ Climate & Temperature', article.climateTemperature),
                  _buildSection('💧 Irrigation Schedule', article.irrigationDetails),
                  _buildSection('🧪 Fertilizer & NPK Dosage', article.fertilizerGuide),
                  _buildSection('🌾 Harvesting & Post-Harvest', article.harvestingDetails),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.35)),
        ],
      ),
    );
  }
}

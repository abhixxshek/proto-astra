import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes/app_routes.dart';
import '../../core/utils/url_launcher_util.dart';
import '../../core/widgets/app_drawer.dart';
import '../../providers/language_provider.dart';

class NewsArticle {
  final String title;
  final String summary;
  final String source;
  final String time;
  final String imageUrl;
  final String url;

  NewsArticle({
    required this.title,
    required this.summary,
    required this.source,
    required this.time,
    required this.imageUrl,
    required this.url,
  });
}

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  static const String englishNewsUrl = "https://krishijagran.com/news";
  static const String hindiNewsUrl = "https://hindi.krishijagran.com/news";

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isHindi = lang.isHindi;
    final articles = isHindi ? _hindiNews : _englishNews;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isHindi ? "कृषि लाइव समाचार" : "Live Farming News",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            Text(
              isHindi ? "कृषि जागरण एवं मंडी अपडेट्स" : "Krishi Jagran Portal Feed",
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            tooltip: isHindi ? "Switch to English" : "हिंदी में बदलें",
            onPressed: () => lang.toggleLanguage(),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded, color: Colors.white),
            tooltip: "Open Krishi Jagran Portal",
            onPressed: () {
              UrlLauncherUtil.launchEcommerceUrl(
                context,
                isHindi ? hindiNewsUrl : englishNewsUrl,
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.news),
      body: Column(
        children: [
          // Live Portal Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFE8F5E9),
            child: Row(
              children: [
                const Icon(Icons.rss_feed_rounded, size: 18, color: Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isHindi
                        ? "लाइव स्रोत: कृषि जागरण पोर्टल (krishijagran.com)"
                        : "Live Source: Krishi Jagran Agricultural Portal",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                  ),
                ),
                GestureDetector(
                  onTap: () => lang.toggleLanguage(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isHindi ? "ENG" : "हिंदी",
                      style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              itemCount: articles.length,
              itemBuilder: (ctx, index) {
                final article = articles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                  child: InkWell(
                    onTap: () => UrlLauncherUtil.launchEcommerceUrl(context, article.url),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              article.imageUrl,
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 150,
                                color: Colors.green.shade50,
                                child: const Icon(Icons.newspaper_rounded, color: Color(0xFF2E7D32), size: 48),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  article.source,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                              Text(
                                article.time,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            article.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            article.summary,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade800,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                isHindi ? "पूरा समाचार पढ़ें" : "Read Full Story",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF2E7D32)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static final List<NewsArticle> _englishNews = [
    NewsArticle(
      title: "Government hikes Minimum Support Price (MSP) for Rabi crops for 2026-27 season",
      summary: "Cabinet Committee on Economic Affairs approves significant MSP increase for wheat, mustard, and gram to boost farmer earnings.",
      source: "Krishi Jagran",
      time: "2 hours ago",
      imageUrl: "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=600",
      url: englishNewsUrl,
    ),
    NewsArticle(
      title: "PM-Kisan 19th Installment of ₹2,000 released directly to 9.5 crore farmers",
      summary: "Prime Minister DBT transfer credited directly to Aadhaar-seeded bank accounts across all states.",
      source: "AgriNews Live",
      time: "5 hours ago",
      imageUrl: "https://images.unsplash.com/photo-1592417817098-8f3d6910985c?w=600",
      url: englishNewsUrl,
    ),
    NewsArticle(
      title: "Monsoon rainfall forecast update: Good soil moisture in Western & Central Maharashtra",
      summary: "IMD predicts favorable meteorological conditions for early Rabi sowing with adequate reservoir levels.",
      source: "Weather & Farm",
      time: "1 day ago",
      imageUrl: "https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=600",
      url: englishNewsUrl,
    ),
    NewsArticle(
      title: "Drones & AI Soil Cards revolutonize fertilizer management across Indian districts",
      summary: "Precision agriculture initiative reports 20% reduction in chemical fertilizer cost with optimized soil test cards.",
      source: "Krishi Vigyan",
      time: "2 days ago",
      imageUrl: "https://images.unsplash.com/photo-1586771107445-d3ca888129ff?w=600",
      url: englishNewsUrl,
    ),
  ];

  static final List<NewsArticle> _hindiNews = [
    NewsArticle(
      title: "रबी फसलों के लिए न्यूनतम समर्थन मूल्य (MSP) में भारी बढ़ोतरी, गेहूं के दाम बढ़े",
      summary: "केंद्र सरकार ने किसानों की आय बढ़ाने के लिए गेहूं, चना और सरसों के न्यूनतम समर्थन मूल्य में रिकॉर्ड इजाफा किया।",
      source: "कृषि जागरण हिंदी",
      time: "२ घंटे पहले",
      imageUrl: "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=600",
      url: hindiNewsUrl,
    ),
    NewsArticle(
      title: "पीएम किसान योजना की 19वीं किस्त जारी, करोड़ों किसानों के खाते में पहुंचे 2000 रुपये",
      summary: "डीबीटी के माध्यम से सीधे किसानों के बैंक खातों में आर्थिक सहायता भेजी गई, ऐसे चेक करें अपनी स्थिति।",
      source: "कृषि जागरण हिंदी",
      time: "५ घंटे पहले",
      imageUrl: "https://images.unsplash.com/photo-1592417817098-8f3d6910985c?w=600",
      url: hindiNewsUrl,
    ),
    NewsArticle(
      title: "ड्रोन और मृदा स्वास्थ्य कार्ड तकनीक से फसल पैदावार में रिकॉर्ड उछाल",
      summary: "मिट्टी जांच के आधार पर सटीक खाद प्रयोग से किसानों की लागत 25 प्रतिशत घटी और फसल गुणवत्ता सुधरी।",
      source: "किसान एक्सप्रेस",
      time: "१ दिन पहले",
      imageUrl: "https://images.unsplash.com/photo-1586771107445-d3ca888129ff?w=600",
      url: hindiNewsUrl,
    ),
  ];
}

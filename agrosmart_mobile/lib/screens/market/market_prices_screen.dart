import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes/app_routes.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/app_drawer.dart';
import '../../providers/language_provider.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  final _searchController = TextEditingController();
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  List<Map<String, dynamic>> _prices = [];
  String _selectedState = 'All';

  final List<String> _states = [
    'All',
    'Maharashtra',
    'Punjab',
    'Haryana',
    'Gujarat',
    'Madhya Pradesh',
    'Rajasthan',
    'Uttar Pradesh',
    'Karnataka',
    'Bihar'
  ];

  @override
  void initState() {
    super.initState();
    _fetchMarketPrices();
  }

  Future<void> _fetchMarketPrices() async {
    setState(() => _isLoading = true);
    try {
      final queryParams = <String, String>{};
      if (_selectedState != 'All') queryParams['state'] = _selectedState;
      if (_searchController.text.trim().isNotEmpty) {
        queryParams['commodity'] = _searchController.text.trim();
      }

      final response = await _apiClient.get('/market/prices', queryParams: queryParams);
      final rawList = response['market_prices'] as List<dynamic>? ?? [];
      setState(() {
        _prices = rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = Provider.of<LanguageProvider>(context).isHindi;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isHindi ? "कृषि मंडी भाव (Live Rates)" : "APMC Mandi Market Prices",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            Text(
              isHindi ? "दैनिक मंडी जिन्स न्यूनतम/अधिकतम भाव" : "Daily APMC Commodity Spot Prices",
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.marketPrices),
      body: Column(
        children: [
          // Filter & Search Header
          Container(
            padding: const EdgeInsets.all(14),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _fetchMarketPrices(),
                  decoration: InputDecoration(
                    hintText: isHindi ? "फसल या मंडी खोजें (उदा. गेहूं, सोयाबीन)..." : "Search commodity or mandi yard...",
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _fetchMarketPrices();
                            },
                          )
                        : null,
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _states.map((st) {
                      final isSelected = _selectedState == st;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(st, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black87)),
                          selected: isSelected,
                          selectedColor: const Color(0xFF2E7D32),
                          backgroundColor: Colors.grey.shade100,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedState = st);
                              _fetchMarketPrices();
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                : _prices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.storefront_outlined, size: 54, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              isHindi ? "कोई मंडी भाव उपलब्ध नहीं है" : "No Mandi Commodity Prices Found",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchMarketPrices,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(14),
                          itemCount: _prices.length,
                          itemBuilder: (context, index) {
                            final item = _prices[index];
                            final isUp = item['trend'] == 'up';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['commodity']?.toString() ?? '',
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isUp ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isUp ? Icons.trending_up : Icons.trending_down,
                                              size: 14,
                                              color: isUp ? const Color(0xFF2E7D32) : Colors.red,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${item['modal_price']} ${item['unit']}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isUp ? const Color(0xFF2E7D32) : Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${item['mandi']}, ${item['state']}',
                                        style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Min: ₹${item['min_price']} | Max: ₹${item['max_price']}',
                                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                                      ),
                                      Text(
                                        'Updated: ${item['updated']}',
                                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

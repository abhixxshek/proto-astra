import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes/app_routes.dart';
import '../../core/widgets/app_drawer.dart';
import '../../data/models/product_model.dart';
import '../../providers/shopping_provider.dart';
import '../../providers/language_provider.dart';
import 'cart_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shopping = context.watch<ShoppingProvider>();
    final isHindi = context.watch<LanguageProvider>().isHindi;

    final categories = ['All', 'Seeds', 'Fertilizers', 'Tools'];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isHindi ? "कृषि बाज़ार (Certified Seeds & Fertilizer)" : "Agri Seeds & Inputs Store",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            Text(
              isHindi ? "प्रमाणित बीज, जैविक उर्वरक एवं उपकरण" : "Direct Doorstep Agri Delivery",
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                },
              ),
              if (shopping.cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${shopping.cartCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.shopping),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.all(14),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => shopping.search(val),
                  decoration: InputDecoration(
                    hintText: isHindi ? "बीज, खाद या उपकरण खोजें..." : "Search certified seeds, fertilizers, sprayers...",
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
                    suffixIcon: shopping.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => shopping.search(''),
                          )
                        : null,
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: categories.map((cat) {
                    final isSelected = shopping.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black87)),
                        selected: isSelected,
                        selectedColor: const Color(0xFF2E7D32),
                        backgroundColor: Colors.grey.shade100,
                        onSelected: (_) => shopping.setCategory(cat),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: shopping.filteredProducts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 54, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('No Agri Products Found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(14),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: shopping.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = shopping.filteredProducts[index];
                      return _buildProductCard(context, shopping, product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ShoppingProvider shopping, ProductModel product) {
    return Container(
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
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(product.purchaseUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    product.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.green.shade50,
                      child: const Center(child: Icon(Icons.grass, color: Color(0xFF2E7D32), size: 40)),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, height: 1.2),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text('${product.rating}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Text('(${product.reviewsCount})', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                        ),
                        if (product.originalPrice > 0)
                          Text(
                            '₹${product.originalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough),
                          ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        shopping.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.title} added to cart'),
                            backgroundColor: const Color(0xFF2E7D32),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: const Size(36, 28),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Icon(Icons.add_shopping_cart, size: 14, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

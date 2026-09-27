import 'package:flutter/foundation.dart';
import '../data/models/product_model.dart';

enum ProductSortOption { none, lowToHigh, highToLow }

class ShoppingProvider extends ChangeNotifier {
  final List<ProductModel> _allProducts = [
    ProductModel(
      id: 'p1',
      title: 'Certified Hybrid Wheat Seeds (HD-3086)',
      category: 'Seeds',
      description: 'High-yielding, rust-resistant wheat seed variety suitable for irrigated fertile soils across North and Central India.',
      price: 1450.0,
      originalPrice: 1700.0,
      imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=500',
      rating: 4.8,
      reviewsCount: 124,
      purchaseUrl: 'https://www.amazon.in/s?k=hybrid+wheat+seeds',
    ),
    ProductModel(
      id: 'p2',
      title: 'Organic NPK Bio-Fertilizer (1 Liter)',
      category: 'Fertilizers',
      description: '100% natural bio-fertilizer enriched with Nitrogen fixing & Phosphate solubilizing micro-organisms.',
      price: 680.0,
      originalPrice: 850.0,
      imageUrl: 'https://images.unsplash.com/photo-1628352081506-83c43123ed6d?w=500',
      rating: 4.6,
      reviewsCount: 89,
      purchaseUrl: 'https://www.amazon.in/s?k=organic+npk+fertilizer',
    ),
    ProductModel(
      id: 'p3',
      title: 'Neem-Coated Urea Gold (50kg Bag)',
      category: 'Fertilizers',
      description: 'Slow-release nitrogen fertilizer ensuring maximum plant absorption and reduced leaching losses.',
      price: 380.0,
      originalPrice: 420.0,
      imageUrl: 'https://images.unsplash.com/photo-1585314062340-f1a5a7c9328d?w=500',
      rating: 4.9,
      reviewsCount: 310,
      purchaseUrl: 'https://www.amazon.in/s?k=neem+coated+urea',
    ),
    ProductModel(
      id: 'p4',
      title: 'High Performance Battery Knapsack Sprayer (16L)',
      category: 'Tools',
      description: 'Dual-nozzle rechargeable battery sprayer for efficient pesticide and liquid fertilizer field spraying.',
      price: 2850.0,
      originalPrice: 3500.0,
      imageUrl: 'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?w=500',
      rating: 4.7,
      reviewsCount: 64,
      purchaseUrl: 'https://www.amazon.in/s?k=knapsack+sprayer',
    ),
    ProductModel(
      id: 'p5',
      title: 'Hybrid Maize / Corn Seeds (Pioneer 3396)',
      category: 'Seeds',
      description: 'Drought-tolerant hybrid corn seed with strong root structure and heavy cob grain weight.',
      price: 1890.0,
      originalPrice: 2200.0,
      imageUrl: 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=500',
      rating: 4.7,
      reviewsCount: 95,
      purchaseUrl: 'https://www.amazon.in/s?k=hybrid+maize+seeds',
    ),
    ProductModel(
      id: 'p6',
      title: 'Micronutrient Soil Tonic (Zinc + Boron + Iron)',
      category: 'Fertilizers',
      description: 'Complete soil health booster addressing micronutrient deficiencies in yellowing or stunted crops.',
      price: 540.0,
      originalPrice: 650.0,
      imageUrl: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=500',
      rating: 4.5,
      reviewsCount: 48,
      purchaseUrl: 'https://www.amazon.in/s?k=micronutrient+fertilizer',
    ),
  ];

  final List<ProductModel> _cart = [];
  String _searchQuery = '';
  ProductSortOption _currentSort = ProductSortOption.none;
  String _selectedCategory = 'All';

  List<ProductModel> get cart => _cart;
  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal => _cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  String get searchQuery => _searchQuery;
  ProductSortOption get currentSort => _currentSort;
  String get selectedCategory => _selectedCategory;

  List<ProductModel> get filteredProducts {
    var list = _allProducts.where((p) {
      final matchesSearch = p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    if (_currentSort == ProductSortOption.lowToHigh) {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_currentSort == ProductSortOption.highToLow) {
      list.sort((a, b) => b.price.compareTo(a.price));
    }

    return list;
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSortOption(ProductSortOption sort) {
    _currentSort = sort;
    notifyListeners();
  }

  void addToCart(ProductModel product, [int qty = 1]) {
    final index = _cart.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _cart[index].quantity += qty;
    } else {
      final item = ProductModel.fromJson(product.toJson());
      item.quantity = qty;
      _cart.add(item);
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int delta) {
    final index = _cart.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      _cart[index].quantity += delta;
      if (_cart[index].quantity <= 0) {
        _cart.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}

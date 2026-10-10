import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/app_drawer.dart';
import '../../providers/transport_provider.dart';
import '../../providers/language_provider.dart';
import '../../data/models/vehicle_model.dart';
import 'widgets/vehicle_card.dart';
import 'widgets/list_vehicle_banner.dart';
import 'widgets/equipment_booking_sheet.dart';
import 'widgets/transport_booking_sheet.dart';
import 'widgets/vehicle_form_dialog.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/my_bookings_view.dart';
import 'widgets/owner_dashboard_view.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'key': 'All', 'labelEn': 'All', 'labelHi': 'सभी'},
    {'key': 'Tractors', 'labelEn': 'Tractors', 'labelHi': 'ट्रैक्टर'},
    {'key': 'Transport', 'labelEn': 'Transport', 'labelHi': 'परिवहन'},
    {'key': 'Harvesters', 'labelEn': 'Harvesters', 'labelHi': 'हार्वेस्टर'},
    {'key': 'Power Tillers', 'labelEn': 'Power Tillers', 'labelHi': 'पॉवर टिलर'},
    {'key': 'Rotavators', 'labelEn': 'Rotavators', 'labelHi': 'रोटावेटर'},
    {'key': 'Sprayers', 'labelEn': 'Sprayers', 'labelHi': 'स्प्रेयर'},
  ];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 3, vsync: this);
    _mainTabController.addListener(() {
      if (!_mainTabController.indexIsChanging) {
        context.read<TransportProvider>().setSelectedTabIndex(_mainTabController.index);
      }
    });
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openBookingSheet(VehicleModel vehicle, bool isHindi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        if (vehicle.category == 'transport') {
          return TransportBookingSheet(vehicle: vehicle, isHindi: isHindi);
        } else {
          return EquipmentBookingSheet(vehicle: vehicle, isHindi: isHindi);
        }
      },
    );
  }

  void _openFilterSheet(bool isHindi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FilterBottomSheet(isHindi: isHindi),
    );
  }

  void _openListVehicleDialog(bool isHindi) {
    showDialog(
      context: context,
      builder: (ctx) => VehicleFormDialog(isHindi: isHindi),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transportProv = context.watch<TransportProvider>();
    final isHindi = context.watch<LanguageProvider>().isHindi;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isHindi ? 'कृषि परिवहन एवं उपकरण किराया' : 'Transport & Equipment Rental',
          style: AppTypography.title3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _mainTabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          labelStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: [
            Tab(
              icon: const Icon(Icons.storefront_rounded, size: 20),
              text: isHindi ? 'मार्केटप्लेस' : 'Rent Marketplace',
            ),
            Tab(
              icon: const Icon(Icons.receipt_long_rounded, size: 20),
              text: isHindi ? 'मेरी बुकिंग' : 'My Bookings',
            ),
            Tab(
              icon: const Icon(Icons.space_dashboard_rounded, size: 20),
              text: isHindi ? 'मालिक डैशबोर्ड' : 'Owner Hub',
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.transport),
      body: TabBarView(
        controller: _mainTabController,
        children: [
          // Tab 1: Marketplace
          _buildMarketplaceTab(transportProv, isHindi),

          // Tab 2: My Bookings View
          MyBookingsView(isHindi: isHindi),

          // Tab 3: Owner Dashboard View
          OwnerDashboardView(isHindi: isHindi),
        ],
      ),
    );
  }

  Widget _buildMarketplaceTab(TransportProvider prov, bool isHindi) {
    final vehicles = prov.filteredVehicles;

    return Column(
      children: [
        // Top Search Bar & Filter Button
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => prov.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: isHindi
                        ? 'ट्रैक्टर, हार्वेस्टर या मिनी ट्रक खोजें...'
                        : 'Search tractors, harvesters, trucks, location...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              prov.setSearchQuery('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: const Color(0xFFF2F6F3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Filter Button
              InkWell(
                onTap: () => _openFilterSheet(isHindi),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                ),
              ),
            ],
          ),
        ),

        // Horizontal Category Chips Selector
        Container(
          height: 46,
          color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = prov.selectedCategory == cat['key'];
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(
                    isHindi ? cat['labelHi']! : cat['labelEn']!,
                    style: AppTypography.caption.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: const Color(0xFFF0F4F1),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onSelected: (selected) {
                    if (selected) {
                      prov.setSelectedCategory(cat['key']!);
                    }
                  },
                ),
              );
            },
          ),
        ),

        const Divider(height: 1, thickness: 1, color: Color(0x14000000)),

        // Main List Content
        Expanded(
          child: prov.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    // Compact Promotional "List Your Vehicle" Card
                    ListVehicleBanner(
                      isHindi: isHindi,
                      onListPressed: () => _openListVehicleDialog(isHindi),
                    ),
                    const SizedBox(height: 10),

                    // Section Heading & Result Count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isHindi ? 'उपलब्ध वाहन और मशीनरी' : 'Available Vehicles & Machinery',
                          style: AppTypography.headline.copyWith(fontSize: 15),
                        ),
                        Text(
                          '${vehicles.length} ${isHindi ? "परिणाम" : "found"}',
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // List of Vehicle Cards or Empty State
                    if (vehicles.isEmpty) ...[
                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textTertiary),
                            const SizedBox(height: 12),
                            Text(
                              isHindi ? 'कोई वाहन नहीं मिला' : 'No Vehicles Found',
                              style: AppTypography.title3.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isHindi
                                  ? 'कृपया अपनी खोज या फ़िल्टर मानदंड बदलें।'
                                  : 'Try adjusting your search keywords or active filters.',
                              style: AppTypography.footnote,
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: () => prov.resetFilters(),
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: Text(isHindi ? 'फ़िल्टर रीसेट करें' : 'Reset Filters'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ...vehicles.map((v) => VehicleCard(
                            vehicle: v,
                            isHindi: isHindi,
                            onBookPressed: () => _openBookingSheet(v, isHindi),
                          )),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

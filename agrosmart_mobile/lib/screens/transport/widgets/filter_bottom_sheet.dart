import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../providers/transport_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  final bool isHindi;

  const FilterBottomSheet({
    super.key,
    required this.isHindi,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _maxDistanceKm;
  late double _maxPrice;
  late bool _onlyWithOperator;
  late bool _onlyAvailable;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    final prov = context.read<TransportProvider>();
    _maxDistanceKm = prov.maxDistanceKm;
    _maxPrice = prov.maxPrice;
    _onlyWithOperator = prov.onlyWithOperator;
    _onlyAvailable = prov.onlyAvailable;
    _sortBy = prov.sortBy;
  }

  void _applyFilters() {
    context.read<TransportProvider>().updateFilters(
          maxDistanceKm: _maxDistanceKm,
          maxPrice: _maxPrice,
          onlyWithOperator: _onlyWithOperator,
          onlyAvailable: _onlyAvailable,
          sortBy: _sortBy,
        );
    Navigator.pop(context);
  }

  void _resetFilters() {
    context.read<TransportProvider>().resetFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isHindi ? 'फ़िल्टर और क्रमबद्धता' : 'Filters & Sorting',
                style: AppTypography.title2.copyWith(fontSize: 18),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: Text(
                  widget.isHindi ? 'रीसेट करें' : 'Reset All',
                  style: AppTypography.callout.copyWith(color: AppColors.error, fontSize: 13),
                ),
              ),
            ],
          ),
          const Divider(height: 16),

          // Sort Options
          Text(widget.isHindi ? 'इसके अनुसार क्रमबद्ध करें' : 'Sort Listings By', style: AppTypography.headline.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSortChip('distance', widget.isHindi ? '📍 सबसे नजदीक (Nearest)' : '📍 Distance: Nearest'),
              _buildSortChip('price_low', widget.isHindi ? '💰 मूल्य: कम से अधिक' : '💰 Price: Low to High'),
              _buildSortChip('price_high', widget.isHindi ? '💰 मूल्य: अधिक से कम' : '💰 Price: High to Low'),
              _buildSortChip('rating', widget.isHindi ? '⭐ सर्वोत्तम रेटिंग' : '⭐ Highest Rating'),
            ],
          ),
          const SizedBox(height: 16),

          // Max Distance Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isHindi ? 'अधिकतम दूरी (किमी)' : 'Max Distance Radius',
                style: AppTypography.headline.copyWith(fontSize: 14),
              ),
              Text(
                '${_maxDistanceKm.toInt()} km',
                style: AppTypography.callout.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: _maxDistanceKm,
            min: 5.0,
            max: 100.0,
            divisions: 19,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _maxDistanceKm = val),
          ),
          const SizedBox(height: 12),

          // Max Price Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isHindi ? 'अधिकतम दर (₹)' : 'Max Rental Price Filter',
                style: AppTypography.headline.copyWith(fontSize: 14),
              ),
              Text(
                '₹${_maxPrice.toInt()}',
                style: AppTypography.callout.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: _maxPrice,
            min: 200.0,
            max: 5000.0,
            divisions: 24,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _maxPrice = val),
          ),
          const SizedBox(height: 12),

          // Toggles
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppColors.primary,
            title: Text(widget.isHindi ? 'केवल उपलब्ध वाहन दिखाएं' : 'Show Only Available Vehicles'),
            value: _onlyAvailable,
            onChanged: (val) => setState(() => _onlyAvailable = val),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppColors.primary,
            title: Text(widget.isHindi ? 'केवल चालक सहित वाले वाहन' : 'Must Include Operator / Driver'),
            value: _onlyWithOperator,
            onChanged: (val) => setState(() => _onlyWithOperator = val),
          ),
          const SizedBox(height: 18),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                widget.isHindi ? 'फ़िल्टर लागू करें' : 'Apply Filters',
                style: AppTypography.button.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey.shade100,
      onSelected: (selected) {
        if (selected) setState(() => _sortBy = value);
      },
    );
  }
}

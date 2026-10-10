import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_glass.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/models/vehicle_model.dart';

class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final bool isHindi;
  final VoidCallback onBookPressed;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.isHindi,
    required this.onBookPressed,
  });

  Future<void> _makeCall(BuildContext context, String phone) async {
    final Uri callUri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${isHindi ? "फोन कॉल उपलब्ध नहीं है:" : "Calling Owner:"} ${vehicle.ownerName} ($phone)'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isHindi ? "फोन नंबर:" : "Call owner at:"} ${vehicle.ownerName} ($phone)'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  Widget _buildImageHeader() {
    bool isAsset = vehicle.imageUrl.startsWith('assets/');
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          child: Container(
            height: 160,
            width: double.infinity,
            color: const Color(0xFFE8F0EA),
            child: isAsset
                ? Image.asset(
                    vehicle.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => _buildImagePlaceholder(),
                  )
                : Image.network(
                    vehicle.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => _buildImagePlaceholder(),
                  ),
          ),
        ),
        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Category Badge
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: vehicle.category == 'transport'
                  ? AppColors.iosBlue
                  : AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppGlass.softShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  vehicle.category == 'transport'
                      ? Icons.local_shipping_rounded
                      : Icons.agriculture_rounded,
                  color: Colors.white,
                  size: 13,
                ),
                const SizedBox(width: 4),
                Text(
                  vehicle.category == 'transport'
                      ? (isHindi ? 'परिवहन' : 'Transport')
                      : (isHindi ? 'कृषि उपकरण' : 'Equipment'),
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Availability Pill Badge
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: vehicle.isAvailable
                  ? const Color(0xE62E7D32)
                  : const Color(0xE6D32F2F),
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppGlass.softShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  vehicle.isAvailable
                      ? (isHindi ? 'उपलब्ध' : 'Available')
                      : (isHindi ? 'अनुपलब्ध' : 'In Use'),
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Rating and Distance bottom overlay on image
        Positioned(
          bottom: 10,
          left: 12,
          right: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14),
                    const SizedBox(width: 3),
                    Text(
                      '${vehicle.rating} (${vehicle.reviewCount})',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Distance
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.near_me_rounded, color: Colors.white, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      '${vehicle.distanceKm} km',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFE1ECE3),
      child: Center(
        child: Icon(
          vehicle.category == 'transport'
              ? Icons.local_shipping_outlined
              : Icons.agriculture_outlined,
          size: 48,
          color: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppGlass.cardDecoration(
        borderRadius: BorderRadius.circular(18),
        fillColor: Colors.white,
        shadows: AppGlass.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageHeader(),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Rate Tag
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        vehicle.modelName,
                        style: AppTypography.title3.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        '₹${vehicle.rate.toInt()} ${vehicle.rateUnit}',
                        style: AppTypography.callout.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Specifications / HP / Capacity Chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (vehicle.hpRating != null && vehicle.hpRating!.isNotEmpty)
                      _buildSpecChip(Icons.flash_on_rounded, vehicle.hpRating!),
                    if (vehicle.loadCapacity != null && vehicle.loadCapacity!.isNotEmpty)
                      _buildSpecChip(Icons.scale_rounded, 'Cap: ${vehicle.loadCapacity}'),
                    _buildSpecChip(
                      vehicle.hasOperator ? Icons.person_rounded : Icons.person_off_rounded,
                      vehicle.hasOperator
                          ? (isHindi ? 'चालक सहित' : 'With Operator')
                          : (isHindi ? 'केवल उपकरण' : 'Without Operator'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Owner & Location info
                Row(
                  children: [
                    const Icon(Icons.account_circle_outlined, size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      vehicle.ownerName,
                      style: AppTypography.subhead.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        vehicle.location,
                        style: AppTypography.footnote.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Action Buttons Row: Call Owner & Book Now
                Row(
                  children: [
                    // Call Button
                    Expanded(
                      flex: 4,
                      child: OutlinedButton.icon(
                        onPressed: () => _makeCall(context, vehicle.phone),
                        icon: const Icon(Icons.phone_outlined, size: 16, color: AppColors.primary),
                        label: Text(
                          isHindi ? 'कॉल करें' : 'Call Owner',
                          style: AppTypography.button.copyWith(
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: const BorderSide(color: AppColors.primary, width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Book Now Button
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: AppGlass.buttonGlassDecoration(isPrimary: vehicle.isAvailable),
                        child: ElevatedButton.icon(
                          onPressed: vehicle.isAvailable ? onBookPressed : null,
                          icon: Icon(
                            vehicle.category == 'transport'
                                ? Icons.local_shipping
                                : Icons.calendar_month_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            isHindi ? 'बुक करें' : 'Book Now',
                            style: AppTypography.button.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

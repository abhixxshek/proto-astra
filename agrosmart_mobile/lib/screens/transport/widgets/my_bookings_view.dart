import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_glass.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/models/booking_model.dart';
import '../../../providers/transport_provider.dart';
import '../../../providers/auth_provider.dart';

class MyBookingsView extends StatefulWidget {
  final bool isHindi;

  const MyBookingsView({
    super.key,
    required this.isHindi,
  });

  @override
  State<MyBookingsView> createState() => _MyBookingsViewState();
}

class _MyBookingsViewState extends State<MyBookingsView> {
  String _statusFilter = 'all'; // 'all', 'pending', 'accepted', 'ongoing', 'completed', 'cancelled'

  Future<void> _makeCall(String phone) async {
    final Uri callUri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      }
    } catch (_) {}
  }

  void _showCancelDialog(BuildContext context, BookingModel booking) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(widget.isHindi ? 'बुकिंग रद्द करें?' : 'Cancel Rental Booking?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isHindi
                  ? 'क्या आप निश्चित रूप से ${booking.vehicleName} की बुकिंग रद्द करना चाहते हैं?'
                  : 'Are you sure you want to cancel booking for ${booking.vehicleName}?',
              style: AppTypography.bodyMuted,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: widget.isHindi ? 'रद्द करने का कारण दर्ज करें (ऐच्छिक)' : 'Enter cancellation reason (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(widget.isHindi ? 'वापस जाएं' : 'Go Back'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<TransportProvider>().cancelBooking(
                    booking.id,
                    reason: reasonController.text.trim().isNotEmpty
                        ? reasonController.text.trim()
                        : 'Cancelled by farmer',
                  );
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(widget.isHindi ? 'बुकिंग रद्द कर दी गई है' : 'Booking has been cancelled'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            child: Text(widget.isHindi ? 'रद्द करें' : 'Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transportProv = context.watch<TransportProvider>();
    final currentUser = context.watch<AuthProvider>().currentUser;
    final farmerId = currentUser?.id?.toString() ?? 'farmer_current';

    final allBookings = transportProv.getUserBookings(farmerId);
    final filteredBookings = allBookings.where((b) {
      if (_statusFilter == 'all') return true;
      return b.status.name.toLowerCase() == _statusFilter;
    }).toList();

    return Column(
      children: [
        // Status Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip('all', widget.isHindi ? 'सभी (${allBookings.length})' : 'All (${allBookings.length})'),
              _buildFilterChip('pending', widget.isHindi ? 'लंबित (Pending)' : 'Pending'),
              _buildFilterChip('accepted', widget.isHindi ? 'स्वीकृत (Accepted)' : 'Accepted'),
              _buildFilterChip('ongoing', widget.isHindi ? 'जारी (Ongoing)' : 'Ongoing'),
              _buildFilterChip('completed', widget.isHindi ? 'पूर्ण (Completed)' : 'Completed'),
              _buildFilterChip('cancelled', widget.isHindi ? 'रद्द (Cancelled)' : 'Cancelled'),
            ],
          ),
        ),

        // Bookings List or Empty State
        Expanded(
          child: filteredBookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.textTertiary),
                      const SizedBox(height: 12),
                      Text(
                        widget.isHindi ? 'कोई बुकिंग नहीं मिली' : 'No Bookings Found',
                        style: AppTypography.title3.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.isHindi
                            ? 'किराए पर उपकरण या वाहन बुक करने के लिए बाज़ार ब्राउज़ करें।'
                            : 'Browse the marketplace tab to rent tractors or transport vehicles.',
                        style: AppTypography.footnote,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = filteredBookings[index];
                    return _buildBookingCard(booking);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        onSelected: (selected) {
          if (selected) setState(() => _statusFilter = value);
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final DateFormat formatter = DateFormat('dd MMM, hh:mm a');

    Color statusColor;
    IconData statusIcon;
    switch (booking.status) {
      case BookingStatus.pending:
        statusColor = AppColors.warning;
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case BookingStatus.accepted:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case BookingStatus.ongoing:
        statusColor = AppColors.iosBlue;
        statusIcon = Icons.agriculture_rounded;
        break;
      case BookingStatus.completed:
        statusColor = AppColors.primary;
        statusIcon = Icons.verified_rounded;
        break;
      case BookingStatus.rejected:
      case BookingStatus.cancelled:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: AppGlass.cardDecoration(
        fillColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Vehicle name & Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      booking.category == 'transport'
                          ? Icons.local_shipping_rounded
                          : Icons.agriculture_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.vehicleName,
                        style: AppTypography.callout.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      widget.isHindi ? booking.status.labelHindi : booking.status.label,
                      style: AppTypography.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 16),

          // Owner & Date details
          Row(
            children: [
              const Icon(Icons.person_outline, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('Owner: ${booking.ownerName}', style: AppTypography.subhead),
              const Spacer(),
              Text('₹${booking.estimatedCost.toInt()}', style: AppTypography.title3.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Start: ${formatter.format(booking.startDate)}',
                style: AppTypography.footnote,
              ),
            ],
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  booking.deliveryLocation,
                  style: AppTypography.footnote,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          if (booking.cancellationReason != null && booking.cancellationReason!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Reason: ${booking.cancellationReason}',
              style: AppTypography.caption.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 12),

          // Action Buttons: Call Owner / Cancel Booking
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _makeCall(booking.ownerPhone),
                  icon: const Icon(Icons.phone, size: 14, color: AppColors.primary),
                  label: Text(
                    widget.isHindi ? 'मालिक से संपर्क करें' : 'Call Owner',
                    style: AppTypography.button.copyWith(color: AppColors.primary, fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              if (booking.status == BookingStatus.pending || booking.status == BookingStatus.accepted) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelDialog(context, booking),
                    icon: const Icon(Icons.cancel_outlined, size: 14, color: AppColors.error),
                    label: Text(
                      widget.isHindi ? 'रद्द करें' : 'Cancel Booking',
                      style: AppTypography.button.copyWith(color: AppColors.error, fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

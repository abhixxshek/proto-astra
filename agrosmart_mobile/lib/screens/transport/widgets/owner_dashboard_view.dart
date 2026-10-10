import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_glass.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../providers/transport_provider.dart';
import '../../../providers/auth_provider.dart';
import 'vehicle_form_dialog.dart';

class OwnerDashboardView extends StatefulWidget {
  final bool isHindi;

  const OwnerDashboardView({
    super.key,
    required this.isHindi,
  });

  @override
  State<OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends State<OwnerDashboardView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _makeCall(String phone) async {
    final Uri callUri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      }
    } catch (_) {}
  }

  void _openAddVehicleDialog() {
    showDialog(
      context: context,
      builder: (ctx) => VehicleFormDialog(isHindi: widget.isHindi),
    );
  }

  void _openEditVehicleDialog(VehicleModel vehicle) {
    showDialog(
      context: context,
      builder: (ctx) => VehicleFormDialog(vehicleToEdit: vehicle, isHindi: widget.isHindi),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transportProv = context.watch<TransportProvider>();
    final currentUser = context.watch<AuthProvider>().currentUser;
    final String ownerId = currentUser?.id?.toString() ?? 'owner_suresh';

    final metrics = transportProv.getOwnerMetrics(ownerId);
    final ownerVehicles = transportProv.getOwnerVehicles(ownerId);
    final ownerBookings = transportProv.getOwnerBookings(ownerId);

    return Column(
      children: [
        // Metrics Summary Header Banner
        Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppGlass.emeraldGlow,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isHindi ? 'कुल आय (Total Earnings)' : 'Total Rental Earnings',
                        style: AppTypography.caption.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${(metrics['totalEarnings'] as double).toInt()}',
                        style: AppTypography.largeTitle.copyWith(color: Colors.white, fontSize: 26),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _openAddVehicleDialog,
                    icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                    label: Text(
                      widget.isHindi ? '+ नया वाहन' : '+ Add Vehicle',
                      style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Metrics Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricStat('${metrics['listedCount']}', widget.isHindi ? 'सूचीबद्ध' : 'Listings'),
                  _buildMetricStat('${metrics['pendingCount']}', widget.isHindi ? 'लंबित' : 'Pending'),
                  _buildMetricStat('${metrics['activeCount']}', widget.isHindi ? 'सक्रिय' : 'Active'),
                  _buildMetricStat('${metrics['completedCount']}', widget.isHindi ? 'पूर्ण' : 'Completed'),
                ],
              ),
            ],
          ),
        ),

        // Sub Tab Bar: My Listed Vehicles vs Booking Requests
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: widget.isHindi ? 'मेरे वाहन (${ownerVehicles.length})' : 'My Vehicles (${ownerVehicles.length})'),
            Tab(text: widget.isHindi ? 'प्राप्त अनुरोध (${ownerBookings.length})' : 'Incoming Requests (${ownerBookings.length})'),
          ],
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // 1. My Vehicles List
              _buildOwnerVehiclesList(ownerVehicles, transportProv),

              // 2. Incoming Booking Requests List
              _buildOwnerBookingsList(ownerBookings, transportProv),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTypography.title2.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: AppTypography.footnote.copyWith(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildOwnerVehiclesList(List<VehicleModel> vehicles, TransportProvider provider) {
    if (vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.agriculture_outlined, size: 56, color: AppColors.textTertiary),
            const SizedBox(height: 8),
            Text(
              widget.isHindi ? 'कोई पंजीकृत वाहन नहीं है' : 'No Listed Vehicles Yet',
              style: AppTypography.title3.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _openAddVehicleDialog,
              child: Text(widget.isHindi ? 'अपना पहला वाहन सूचीबद्ध करें' : 'List Your First Vehicle'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: AppGlass.cardDecoration(fillColor: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(vehicle.modelName, style: AppTypography.callout.copyWith(fontWeight: FontWeight.bold)),
                        Text('${vehicle.vehicleType} • ₹${vehicle.rate.toInt()} ${vehicle.rateUnit}', style: AppTypography.footnote),
                      ],
                    ),
                  ),
                  // Availability Switch
                  Row(
                    children: [
                      Text(
                        vehicle.isAvailable ? (widget.isHindi ? 'सक्रिय' : 'Active') : (widget.isHindi ? 'निष्क्रिय' : 'Inactive'),
                        style: AppTypography.caption.copyWith(
                          color: vehicle.isAvailable ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: vehicle.isAvailable,
                        activeTrackColor: AppColors.primary,
                        onChanged: (_) => provider.toggleVehicleAvailability(vehicle.id),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Reg: ${vehicle.registrationNumber.isEmpty ? "N/A" : vehicle.registrationNumber}', style: AppTypography.caption),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                        onPressed: () => _openEditVehicleDialog(vehicle),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        onPressed: () {
                          provider.deleteVehicle(vehicle.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(widget.isHindi ? 'सूची हटा दी गई' : 'Listing deleted')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOwnerBookingsList(List<BookingModel> bookings, TransportProvider provider) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 56, color: AppColors.textTertiary),
            const SizedBox(height: 8),
            Text(
              widget.isHindi ? 'कोई बुकिंग अनुरोध प्राप्त नहीं हुआ है' : 'No Incoming Rental Requests',
              style: AppTypography.title3.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final DateFormat formatter = DateFormat('dd MMM, hh:mm a');

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: AppGlass.cardDecoration(fillColor: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Farmer: ${booking.farmerName}',
                      style: AppTypography.callout.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '₹${booking.estimatedCost.toInt()}',
                    style: AppTypography.title3.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Vehicle: ${booking.vehicleName}', style: AppTypography.footnote.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
              Text('Dates: ${formatter.format(booking.startDate)}', style: AppTypography.footnote),
              Text('Location: ${booking.deliveryLocation}', style: AppTypography.footnote),
              const SizedBox(height: 10),

              // Status Actions
              if (booking.status == BookingStatus.pending) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                        onPressed: () => provider.updateBookingStatus(booking.id, BookingStatus.accepted),
                        child: Text(widget.isHindi ? 'स्वीकार करें' : 'Accept Request'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                        onPressed: () => provider.updateBookingStatus(booking.id, BookingStatus.rejected, cancellationReason: 'Rejected by owner'),
                        child: Text(widget.isHindi ? 'अस्वीकार करें' : 'Reject'),
                      ),
                    ),
                  ],
                ),
              ] else if (booking.status == BookingStatus.accepted) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.iosBlue),
                        onPressed: () => provider.updateBookingStatus(booking.id, BookingStatus.ongoing),
                        child: Text(widget.isHindi ? 'शुरू करें (Start)' : 'Mark Ongoing'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.phone, color: AppColors.primary),
                      onPressed: () => _makeCall(booking.farmerPhone),
                    ),
                  ],
                ),
              ] else if (booking.status == BookingStatus.ongoing) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () => provider.updateBookingStatus(booking.id, BookingStatus.completed),
                  child: Center(child: Text(widget.isHindi ? 'पूर्ण के रूप में चिह्नित करें' : 'Mark Completed')),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Status: ${booking.status.label}',
                    style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

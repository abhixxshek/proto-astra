import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../providers/transport_provider.dart';
import '../../../providers/auth_provider.dart';

class TransportBookingSheet extends StatefulWidget {
  final VehicleModel vehicle;
  final bool isHindi;

  const TransportBookingSheet({
    super.key,
    required this.vehicle,
    required this.isHindi,
  });

  @override
  State<TransportBookingSheet> createState() => _TransportBookingSheetState();
}

class _TransportBookingSheetState extends State<TransportBookingSheet> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  final _goodsController = TextEditingController();

  DateTime _startDate = DateTime.now().add(const Duration(hours: 3));
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  double _estimatedDistanceKm = 25.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pickupController.text = 'Hadapsar Farm Gate, Pune';
    _destinationController.text = 'Gultekdi Market Yard (APMC), Pune';
    _goodsController.text = '50 Bags Wheat Grain (2.5 Tons)';
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _goodsController.dispose();
    super.dispose();
  }

  double get _estimatedTotalCost {
    if (widget.vehicle.rateUnit.contains('Km')) {
      return widget.vehicle.rate * _estimatedDistanceKm;
    } else if (widget.vehicle.rateUnit.contains('Trip')) {
      return widget.vehicle.rate;
    } else {
      return widget.vehicle.rate * 4.0; // 4 hours fallback
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() {
        _startDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _startTime.hour,
          _startTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        _startDate = DateTime(
          _startDate.year,
          _startDate.month,
          _startDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _submitTransportBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final currentUser = context.read<AuthProvider>().currentUser;
    final farmerName = currentUser?.username ?? 'Farmer User';
    final farmerPhone = currentUser?.email ?? '+91 98989 12345';

    final endDate = _startDate.add(const Duration(hours: 4));

    final booking = BookingModel(
      id: 'b_${DateTime.now().millisecondsSinceEpoch}',
      vehicleId: widget.vehicle.id,
      vehicleName: widget.vehicle.modelName,
      vehicleType: widget.vehicle.vehicleType,
      category: 'transport',
      vehicleImageUrl: widget.vehicle.imageUrl,
      farmerId: currentUser?.id?.toString() ?? 'farmer_current',
      farmerName: farmerName,
      farmerPhone: farmerPhone,
      ownerId: widget.vehicle.ownerId,
      ownerName: widget.vehicle.ownerName,
      ownerPhone: widget.vehicle.phone,
      startDate: _startDate,
      endDate: endDate,
      duration: _estimatedDistanceKm,
      durationUnit: widget.vehicle.rateUnit.contains('Trip') ? 'Trips' : 'Km',
      deliveryLocation: _destinationController.text.trim(),
      pickupLocation: _pickupController.text.trim(),
      destinationLocation: _destinationController.text.trim(),
      goodsDescription: _goodsController.text.trim(),
      withOperator: true,
      estimatedCost: _estimatedTotalCost,
      status: BookingStatus.pending,
    );

    final transportProv = context.read<TransportProvider>();
    final success = await transportProv.createBooking(booking);

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isHindi
                  ? 'परिवहन अनुरोध भेजा गया! (स्थिति: लंबित)'
                  : 'Transport booking request sent! (Status: Pending)',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              transportProv.errorMessage ??
                  (widget.isHindi
                      ? 'वाहन इस समय सीमा के लिए अनुपलब्ध है'
                      : 'Vehicle unavailable for selected time window.'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('EEE, dd MMM yyyy');

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Drag Handle & Title
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isHindi ? 'कृषि परिवहन बुक करें' : 'Book Agri Transport',
                          style: AppTypography.title2.copyWith(fontSize: 18),
                        ),
                        Text(
                          '${widget.vehicle.modelName} • Cap: ${widget.vehicle.loadCapacity ?? "Standard"}',
                          style: AppTypography.subhead.copyWith(color: AppColors.iosBlue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Rate Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, color: AppColors.iosBlue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rate: ₹${widget.vehicle.rate.toInt()} ${widget.vehicle.rateUnit} • Includes professional driver',
                        style: AppTypography.footnote.copyWith(
                          color: AppColors.iosBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Pickup Location
              Text(
                widget.isHindi ? 'पिकअप स्थान (फार्म/गोदाम)' : 'Pickup Location (Farm / Warehouse)',
                style: AppTypography.headline.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _pickupController,
                decoration: const InputDecoration(
                  hintText: 'Enter pickup farm gate or village address',
                  prefixIcon: Icon(Icons.my_location_rounded, color: AppColors.primary),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter pickup location';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Destination Location
              Text(
                widget.isHindi ? 'गंतव्य स्थान (मंडी/बाजार)' : 'Destination Location (Mandi / Market)',
                style: AppTypography.headline.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  hintText: 'Enter APMC market yard or delivery address',
                  prefixIcon: Icon(Icons.location_on_rounded, color: AppColors.iosRed),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter destination location';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Goods Description
              Text(
                widget.isHindi ? 'परिवहन की जाने वाली सामग्री' : 'Goods / Crops to Transport',
                style: AppTypography.headline.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _goodsController,
                decoration: const InputDecoration(
                  hintText: 'e.g., 50 Bags Wheat, 2 Tons Tomatoes, Sugarcane',
                  prefixIcon: Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please describe goods';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Transport Date & Time
              Text(
                widget.isHindi ? 'परिवहन तिथि एवं समय' : 'Transport Date & Time',
                style: AppTypography.headline.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              formatter.format(_startDate),
                              style: AppTypography.callout.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              _startTime.format(context),
                              style: AppTypography.callout.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Estimated Distance slider (for per KM rates)
              if (widget.vehicle.rateUnit.contains('Km')) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.isHindi ? 'अनुमानित दूरी (किमी)' : 'Estimated Route Distance',
                      style: AppTypography.headline.copyWith(fontSize: 14),
                    ),
                    Text(
                      '${_estimatedDistanceKm.toInt()} Km',
                      style: AppTypography.callout.copyWith(color: AppColors.iosBlue, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: _estimatedDistanceKm,
                  min: 5.0,
                  max: 200.0,
                  divisions: 39,
                  activeColor: AppColors.iosBlue,
                  onChanged: (val) => setState(() => _estimatedDistanceKm = val),
                ),
                const SizedBox(height: 12),
              ],

              // Cost Summary
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F6FC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.iosBlue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isHindi ? 'अनुमानित भाड़ा' : 'Estimated Freight Fare',
                          style: AppTypography.callout.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.vehicle.rateUnit.contains('Km')
                              ? '₹${widget.vehicle.rate.toInt()}/Km × ${_estimatedDistanceKm.toInt()} Km'
                              : 'Fixed Trip Fare',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                    Text(
                      '₹${_estimatedTotalCost.toInt()}',
                      style: AppTypography.title2.copyWith(color: AppColors.iosBlue, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitTransportBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.iosBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          widget.isHindi ? 'वाहन का अनुरोध करें' : 'Request Vehicle',
                          style: AppTypography.button.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

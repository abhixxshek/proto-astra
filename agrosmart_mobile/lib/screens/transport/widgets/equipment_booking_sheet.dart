import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../providers/transport_provider.dart';
import '../../../providers/auth_provider.dart';

class EquipmentBookingSheet extends StatefulWidget {
  final VehicleModel vehicle;
  final bool isHindi;

  const EquipmentBookingSheet({
    super.key,
    required this.vehicle,
    required this.isHindi,
  });

  @override
  State<EquipmentBookingSheet> createState() => _EquipmentBookingSheetState();
}

class _EquipmentBookingSheetState extends State<EquipmentBookingSheet> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();

  DateTime _startDate = DateTime.now().add(const Duration(hours: 2));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  double _duration = 4.0; // default 4 hours / 4 days / 4 acres
  String _durationUnit = 'Hours'; // 'Hours', 'Days', 'Acres'
  bool _withOperator = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.vehicle.rateUnit.contains('Day')) {
      _durationUnit = 'Days';
    } else if (widget.vehicle.rateUnit.contains('Acre')) {
      _durationUnit = 'Acres';
    } else {
      _durationUnit = 'Hours';
    }
    _locationController.text = 'Plot 12, Green Agro Farm, Hadapsar, Pune';
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  double get _estimatedTotalCost {
    double base = widget.vehicle.rate * _duration;
    if (_withOperator && widget.vehicle.operatorRateExtra > 0) {
      base += widget.vehicle.operatorRateExtra * _duration;
    }
    return base;
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

  DateTime get _calculatedEndDate {
    if (_durationUnit == 'Days') {
      return _startDate.add(Duration(days: _duration.toInt()));
    } else if (_durationUnit == 'Hours') {
      return _startDate.add(Duration(minutes: (_duration * 60).toInt()));
    } else {
      // Acres estimate ~2 hours per acre
      return _startDate.add(Duration(hours: (_duration * 2).toInt()));
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final currentUser = context.read<AuthProvider>().currentUser;
    final farmerName = currentUser?.username ?? 'Farmer User';
    final farmerPhone = currentUser?.email ?? '+91 98989 12345';

    final booking = BookingModel(
      id: 'b_${DateTime.now().millisecondsSinceEpoch}',
      vehicleId: widget.vehicle.id,
      vehicleName: widget.vehicle.modelName,
      vehicleType: widget.vehicle.vehicleType,
      category: widget.vehicle.category,
      vehicleImageUrl: widget.vehicle.imageUrl,
      farmerId: currentUser?.id?.toString() ?? 'farmer_current',
      farmerName: farmerName,
      farmerPhone: farmerPhone,
      ownerId: widget.vehicle.ownerId,
      ownerName: widget.vehicle.ownerName,
      ownerPhone: widget.vehicle.phone,
      startDate: _startDate,
      endDate: _calculatedEndDate,
      duration: _duration,
      durationUnit: _durationUnit,
      deliveryLocation: _locationController.text.trim(),
      withOperator: _withOperator,
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
                  ? 'बुकिंग अनुरोध सफलतापूर्वक भेजा गया! (स्थिति: लंबित)'
                  : 'Booking request sent successfully! (Status: Pending)',
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
                      ? 'बुकिंग विफल: इस समय के लिए वाहन पहले से बुक है।'
                      : 'Booking failed: Vehicle unavailable for selected time.'),
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
                          widget.isHindi ? 'उपकरण बुकिंग' : 'Book Equipment',
                          style: AppTypography.title2.copyWith(fontSize: 18),
                        ),
                        Text(
                          widget.vehicle.modelName,
                          style: AppTypography.subhead.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
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

              // Rate Info Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Base Rate: ₹${widget.vehicle.rate.toInt()} ${widget.vehicle.rateUnit} • ${widget.vehicle.hasOperator ? "Includes Operator option" : "Equipment only"}',
                        style: AppTypography.footnote.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Date & Time Picker Row
              Text(
                widget.isHindi ? 'प्रारंभ तिथि एवं समय' : 'Start Date & Time',
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

              // Duration Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isHindi ? 'अवधि ($_durationUnit)' : 'Duration ($_durationUnit)',
                    style: AppTypography.headline.copyWith(fontSize: 14),
                  ),
                  Text(
                    '${_duration.toStringAsFixed(_durationUnit == 'Hours' ? 1 : 0)} $_durationUnit',
                    style: AppTypography.callout.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Slider(
                value: _duration,
                min: 1.0,
                max: _durationUnit == 'Hours' ? 24.0 : 15.0,
                divisions: _durationUnit == 'Hours' ? 23 : 14,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => _duration = val),
              ),
              const SizedBox(height: 12),

              // Operator Switch (If supported by vehicle)
              if (widget.vehicle.hasOperator) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: AppColors.primary,
                  title: Text(
                    widget.isHindi ? 'चालक/ऑपरेटर शामिल करें' : 'Include Experienced Operator',
                    style: AppTypography.callout.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    widget.vehicle.operatorRateExtra > 0
                        ? '+₹${widget.vehicle.operatorRateExtra.toInt()}/$_durationUnit extra fee'
                        : widget.isHindi ? 'बिना किसी अतिरिक्त शुल्क के शामिल' : 'Included at no extra charge',
                    style: AppTypography.caption,
                  ),
                  value: _withOperator,
                  onChanged: (val) => setState(() => _withOperator = val),
                ),
                const SizedBox(height: 12),
              ],

              // Farm / Delivery Location Input
              Text(
                widget.isHindi ? 'खेत / वितरण का स्थान' : 'Farm / Delivery Location',
                style: AppTypography.headline.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: widget.isHindi ? 'गाँव, ब्लॉक, जिला या भूखंड नंबर दर्ज करें' : 'Enter village, survey no., or address',
                  prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.primary),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return widget.isHindi ? 'कृपया डिलीवरी स्थान दर्ज करें' : 'Please enter delivery location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Summary Cost Breakdown Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Base Rate (${_duration.toStringAsFixed(0)} $_durationUnit)',
                          style: AppTypography.subhead,
                        ),
                        Text(
                          '₹${(widget.vehicle.rate * _duration).toInt()}',
                          style: AppTypography.subhead.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (_withOperator && widget.vehicle.operatorRateExtra > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Operator Fee', style: AppTypography.subhead),
                          Text(
                            '₹${(widget.vehicle.operatorRateExtra * _duration).toInt()}',
                            style: AppTypography.subhead.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.isHindi ? 'अनुमानित कुल लागत' : 'Estimated Total Cost',
                          style: AppTypography.callout.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          '₹${_estimatedTotalCost.toInt()}',
                          style: AppTypography.title2.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Confirm Booking Request Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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
                          widget.isHindi ? 'बुकिंग अनुरोध भेजें' : 'Send Booking Request',
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../providers/transport_provider.dart';
import '../../../providers/auth_provider.dart';

class VehicleFormDialog extends StatefulWidget {
  final VehicleModel? vehicleToEdit;
  final bool isHindi;

  const VehicleFormDialog({
    super.key,
    this.vehicleToEdit,
    required this.isHindi,
  });

  @override
  State<VehicleFormDialog> createState() => _VehicleFormDialogState();
}

class _VehicleFormDialogState extends State<VehicleFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late String _category;
  late String _vehicleType;
  final _modelNameController = TextEditingController();
  final _regNumController = TextEditingController();
  final _rateController = TextEditingController();
  late String _rateUnit;
  final _hpRatingController = TextEditingController();
  final _loadCapacityController = TextEditingController();
  final _specificationsController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  double _serviceRadiusKm = 25.0;
  bool _hasOperator = true;
  double _operatorExtraFee = 0.0;
  bool _isSubmitting = false;

  final List<String> _equipmentTypes = [
    'Tractor',
    'Harvester',
    'Power Tiller',
    'Rotavator',
    'Ploughing Equipment',
    'Seed Drill',
    'Sprayer',
    'Other Machinery',
  ];

  final List<String> _transportTypes = [
    'Tractors with Trailer',
    'Mini Truck',
    'Pickup Truck',
    'Goods Carrier',
    'Trailer',
    'Other Transport',
  ];

  final List<String> _rateUnits = [
    '/ Hour',
    '/ Day',
    '/ Acre',
    '/ Km',
    '/ Trip',
  ];

  final List<Map<String, String>> _sampleImages = [
    {'label': 'Tractor', 'url': 'assets/images/tractor.jpg'},
    {'label': 'Harvester', 'url': 'assets/images/harvester.jpg'},
    {'label': 'Pickup Truck', 'url': 'assets/images/pickup.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.vehicleToEdit != null) {
      final v = widget.vehicleToEdit!;
      _category = v.category;
      _vehicleType = v.vehicleType;
      _modelNameController.text = v.modelName;
      _regNumController.text = v.registrationNumber;
      _rateController.text = v.rate.toInt().toString();
      _rateUnit = v.rateUnit;
      _hpRatingController.text = v.hpRating ?? '';
      _loadCapacityController.text = v.loadCapacity ?? '';
      _specificationsController.text = v.specifications;
      _locationController.text = v.location;
      _phoneController.text = v.phone;
      _descriptionController.text = v.description;
      _imageUrlController.text = v.imageUrl;
      _serviceRadiusKm = v.serviceRadiusKm;
      _hasOperator = v.hasOperator;
      _operatorExtraFee = v.operatorRateExtra;
    } else {
      _category = 'equipment';
      _vehicleType = 'Tractor';
      _rateUnit = '/ Hour';
      _imageUrlController.text = 'assets/images/tractor.jpg';
      _locationController.text = 'Pune, Maharashtra';
      _phoneController.text = '+91 98765 43210';
      _specificationsController.text = 'Diesel Engine, High Torque, Well Maintained';
    }
  }

  @override
  void dispose() {
    _modelNameController.dispose();
    _regNumController.dispose();
    _rateController.dispose();
    _hpRatingController.dispose();
    _loadCapacityController.dispose();
    _specificationsController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final currentUser = context.read<AuthProvider>().currentUser;
    final ownerId = currentUser?.id?.toString() ?? 'owner_suresh';
    final ownerName = currentUser?.username ?? 'Suresh Patil';

    final vehicle = VehicleModel(
      id: widget.vehicleToEdit?.id ?? 'v_${DateTime.now().millisecondsSinceEpoch}',
      ownerId: ownerId,
      ownerName: ownerName,
      phone: _phoneController.text.trim(),
      category: _category,
      vehicleType: _vehicleType,
      modelName: _modelNameController.text.trim(),
      registrationNumber: _regNumController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? (_category == 'transport' ? 'assets/images/pickup.jpg' : 'assets/images/tractor.jpg')
          : _imageUrlController.text.trim(),
      rate: double.tryParse(_rateController.text.trim()) ?? 500.0,
      rateUnit: _rateUnit,
      hpRating: _hpRatingController.text.trim().isNotEmpty ? _hpRatingController.text.trim() : null,
      loadCapacity: _loadCapacityController.text.trim().isNotEmpty ? _loadCapacityController.text.trim() : null,
      specifications: _specificationsController.text.trim(),
      location: _locationController.text.trim(),
      serviceRadiusKm: _serviceRadiusKm,
      distanceKm: 2.5,
      isAvailable: true,
      hasOperator: _hasOperator,
      operatorRateExtra: _operatorExtraFee,
      rating: widget.vehicleToEdit?.rating ?? 5.0,
      reviewCount: widget.vehicleToEdit?.reviewCount ?? 1,
      description: _descriptionController.text.trim(),
    );

    final transportProv = context.read<TransportProvider>();
    if (widget.vehicleToEdit != null) {
      await transportProv.updateVehicle(vehicle);
    } else {
      await transportProv.addVehicle(vehicle);
    }

    setState(() => _isSubmitting = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isHindi
                ? 'वाहन सफलतापूर्वक सूचीबद्ध हुआ! (Vehicle Listed Successfully)'
                : 'Vehicle listed successfully on marketplace!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableTypes = _category == 'transport' ? _transportTypes : _equipmentTypes;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.agriculture_rounded, color: AppColors.primary, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          widget.vehicleToEdit != null
                              ? (widget.isHindi ? 'वाहन संपादित करें' : 'Edit Vehicle Listing')
                              : (widget.isHindi ? 'वाहन सूचीबद्ध करें' : 'List Your Vehicle'),
                          style: AppTypography.title2.copyWith(fontSize: 17),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Text(
                  widget.isHindi
                      ? 'अपनी कृषि मशीनरी या वाहन से अतिरिक्त आय कमाएं।'
                      : 'Earn income by renting out your tractor or transport vehicle.',
                  style: AppTypography.footnote.copyWith(color: AppColors.textSecondary),
                ),
                const Divider(height: 20),

                // Category Selection Segmented Toggle
                Text(widget.isHindi ? 'श्रेणी चुनें' : 'Select Category', style: AppTypography.headline.copyWith(fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Center(
                          child: Text(
                            widget.isHindi ? 'कृषि उपकरण' : 'Agricultural Equipment',
                            style: AppTypography.caption.copyWith(
                              fontWeight: _category == 'equipment' ? FontWeight.bold : FontWeight.normal,
                              color: _category == 'equipment' ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        selected: _category == 'equipment',
                        selectedColor: AppColors.primary,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _category = 'equipment';
                              _vehicleType = _equipmentTypes.first;
                              _rateUnit = '/ Hour';
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: Center(
                          child: Text(
                            widget.isHindi ? 'परिवहन वाहन' : 'Transport Vehicle',
                            style: AppTypography.caption.copyWith(
                              fontWeight: _category == 'transport' ? FontWeight.bold : FontWeight.normal,
                              color: _category == 'transport' ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        selected: _category == 'transport',
                        selectedColor: AppColors.iosBlue,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _category = 'transport';
                              _vehicleType = _transportTypes.first;
                              _rateUnit = '/ Km';
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Vehicle Type Dropdown
                Text(widget.isHindi ? 'वाहन / मशीनरी का प्रकार' : 'Vehicle / Machine Type', style: AppTypography.headline.copyWith(fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: availableTypes.contains(_vehicleType) ? _vehicleType : availableTypes.first,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.tune_rounded, color: AppColors.primary)),
                  items: availableTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t, style: AppTypography.body.copyWith(fontSize: 14))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _vehicleType = val);
                  },
                ),
                const SizedBox(height: 12),

                // Model Name & Registration Number Row
                Text(widget.isHindi ? 'मशीन का नाम और मॉडल' : 'Vehicle Model Name', style: AppTypography.headline.copyWith(fontSize: 13)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _modelNameController,
                  decoration: InputDecoration(
                    hintText: _category == 'equipment' ? 'e.g. Mahindra 575 DI (45 HP)' : 'e.g. Tata Yodha Pickup (1.7T)',
                    prefixIcon: const Icon(Icons.directions_car_rounded, color: AppColors.primary),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter model name' : null,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.isHindi ? 'पंजीकरण संख्या' : 'Registration No.', style: AppTypography.headline.copyWith(fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _regNumController,
                            decoration: const InputDecoration(
                              hintText: 'MH 12 AB 1234',
                              prefixIcon: Icon(Icons.badge_outlined, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _category == 'equipment' ? 'Horsepower (HP)' : 'Load Capacity',
                            style: AppTypography.headline.copyWith(fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _category == 'equipment' ? _hpRatingController : _loadCapacityController,
                            decoration: InputDecoration(
                              hintText: _category == 'equipment' ? '45 HP' : '1.5 Tons',
                              prefixIcon: Icon(_category == 'equipment' ? Icons.flash_on : Icons.scale, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Rental Pricing Row (Price + Rate Unit)
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.isHindi ? 'किराया मूल्य (₹)' : 'Rental Price (₹)', style: AppTypography.headline.copyWith(fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _rateController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '600',
                              prefixIcon: Icon(Icons.currency_rupee_rounded, color: AppColors.primary),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Enter rate';
                              if (double.tryParse(val) == null) return 'Invalid price';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.isHindi ? 'दर की इकाई' : 'Pricing Unit', style: AppTypography.headline.copyWith(fontSize: 13)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _rateUnit,
                            decoration: const InputDecoration(),
                            items: _rateUnits
                                .map((u) => DropdownMenuItem(value: u, child: Text(u, style: AppTypography.body.copyWith(fontSize: 13))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _rateUnit = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Location & Phone Number
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.isHindi ? 'स्थान / शहर' : 'Location / City', style: AppTypography.headline.copyWith(fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              hintText: 'Pune, Maharashtra',
                              prefixIcon: Icon(Icons.location_on_outlined, size: 18),
                            ),
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter location' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.isHindi ? 'सम्पर्क नंबर' : 'Contact Phone', style: AppTypography.headline.copyWith(fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: '+91 9876543210',
                              prefixIcon: Icon(Icons.phone_outlined, size: 18),
                            ),
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter phone' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Operator Options
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: AppColors.primary,
                  title: Text(
                    _category == 'transport'
                      ? (widget.isHindi ? 'चालक सहित (With Driver)' : 'Provide With Driver')
                      : (widget.isHindi ? 'ऑपरेटर सुविधा उपलब्ध है' : 'Provide With Operator'),
                    style: AppTypography.callout.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    widget.isHindi ? 'क्या आप वाहन के साथ चालक भेजते हैं?' : 'Does rental include a driver/operator?',
                    style: AppTypography.caption,
                  ),
                  value: _hasOperator,
                  onChanged: (val) => setState(() => _hasOperator = val),
                ),
                const SizedBox(height: 12),

                // Specifications & Details
                Text(widget.isHindi ? 'विशेष विवरण / विनिर्देश' : 'Specifications & Attachments', style: AppTypography.headline.copyWith(fontSize: 13)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _specificationsController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'e.g., 4WD, Rotavator & Plough attachments available',
                  ),
                ),
                const SizedBox(height: 14),

                // Image Sample Picker / URL
                Text(widget.isHindi ? 'वाहन की फोटो चुनें' : 'Vehicle Image Asset', style: AppTypography.headline.copyWith(fontSize: 13)),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _sampleImages.map((img) {
                      bool isSelected = _imageUrlController.text == img['url'];
                      return InkWell(
                        onTap: () => setState(() => _imageUrlController.text = img['url']!),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryMuted : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.grey.shade300,
                              width: isSelected ? 1.8 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.image_outlined,
                                color: isSelected ? AppColors.primary : Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                img['label']!,
                                style: AppTypography.caption.copyWith(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _saveListing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            widget.vehicleToEdit != null
                                ? (widget.isHindi ? 'अद्यतन करें' : 'Update Listing')
                                : (widget.isHindi ? 'सूचीबद्ध करें और प्रकाशित करें' : 'Submit & Publish Listing'),
                            style: AppTypography.button.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

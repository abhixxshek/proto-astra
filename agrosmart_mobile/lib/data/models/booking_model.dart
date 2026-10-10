
enum BookingStatus {
  pending,
  accepted,
  rejected,
  ongoing,
  completed,
  cancelled,
}

extension BookingStatusExtension on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.ongoing:
        return 'Ongoing';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get labelHindi {
    switch (this) {
      case BookingStatus.pending:
        return 'लंबित (Pending)';
      case BookingStatus.accepted:
        return 'स्वीकृत (Accepted)';
      case BookingStatus.rejected:
        return 'अस्वीकृत (Rejected)';
      case BookingStatus.ongoing:
        return 'जारी है (Ongoing)';
      case BookingStatus.completed:
        return 'पूर्ण (Completed)';
      case BookingStatus.cancelled:
        return 'रद्द (Cancelled)';
    }
  }
}

class BookingModel {
  final String id;
  final String vehicleId;
  final String vehicleName;
  final String vehicleType;
  final String category; // 'equipment' or 'transport'
  final String vehicleImageUrl;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String ownerId;
  final String ownerName;
  final String ownerPhone;
  final DateTime startDate;
  final DateTime endDate;
  final double duration;
  final String durationUnit; // 'Hours', 'Days', 'Acres', 'Km', 'Trips'
  final String deliveryLocation;
  final String? pickupLocation;
  final String? destinationLocation;
  final String? goodsDescription;
  final bool withOperator;
  final double estimatedCost;
  final BookingStatus status;
  final String? cancellationReason;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.vehicleId,
    required this.vehicleName,
    required this.vehicleType,
    required this.category,
    required this.vehicleImageUrl,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhone,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.durationUnit,
    required this.deliveryLocation,
    this.pickupLocation,
    this.destinationLocation,
    this.goodsDescription,
    required this.withOperator,
    required this.estimatedCost,
    this.status = BookingStatus.pending,
    this.cancellationReason,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'vehicleName': vehicleName,
      'vehicleType': vehicleType,
      'category': category,
      'vehicleImageUrl': vehicleImageUrl,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerPhone': farmerPhone,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'duration': duration,
      'durationUnit': durationUnit,
      'deliveryLocation': deliveryLocation,
      'pickupLocation': pickupLocation,
      'destinationLocation': destinationLocation,
      'goodsDescription': goodsDescription,
      'withOperator': withOperator,
      'estimatedCost': estimatedCost,
      'status': status.name,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      vehicleName: json['vehicleName'] ?? 'Vehicle',
      vehicleType: json['vehicleType'] ?? 'Tractor',
      category: json['category'] ?? 'equipment',
      vehicleImageUrl: json['vehicleImageUrl'] ?? 'assets/images/tractor.jpg',
      farmerId: json['farmerId'] ?? 'user_1',
      farmerName: json['farmerName'] ?? 'Farmer',
      farmerPhone: json['farmerPhone'] ?? '',
      ownerId: json['ownerId'] ?? 'owner_1',
      ownerName: json['ownerName'] ?? 'Owner',
      ownerPhone: json['ownerPhone'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate']) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate']) ?? DateTime.now().add(const Duration(hours: 4))
          : DateTime.now().add(const Duration(hours: 4)),
      duration: (json['duration'] as num?)?.toDouble() ?? 1.0,
      durationUnit: json['durationUnit'] ?? 'Hours',
      deliveryLocation: json['deliveryLocation'] ?? '',
      pickupLocation: json['pickupLocation'],
      destinationLocation: json['destinationLocation'],
      goodsDescription: json['goodsDescription'],
      withOperator: json['withOperator'] ?? true,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      status: _parseStatus(json['status']),
      cancellationReason: json['cancellationReason'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static BookingStatus _parseStatus(String? statusStr) {
    if (statusStr == null) return BookingStatus.pending;
    return BookingStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == statusStr.toLowerCase(),
      orElse: () => BookingStatus.pending,
    );
  }

  BookingModel copyWith({
    String? id,
    String? vehicleId,
    String? vehicleName,
    String? vehicleType,
    String? category,
    String? vehicleImageUrl,
    String? farmerId,
    String? farmerName,
    String? farmerPhone,
    String? ownerId,
    String? ownerName,
    String? ownerPhone,
    DateTime? startDate,
    DateTime? endDate,
    double? duration,
    String? durationUnit,
    String? deliveryLocation,
    String? pickupLocation,
    String? destinationLocation,
    String? goodsDescription,
    bool? withOperator,
    double? estimatedCost,
    BookingStatus? status,
    String? cancellationReason,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleType: vehicleType ?? this.vehicleType,
      category: category ?? this.category,
      vehicleImageUrl: vehicleImageUrl ?? this.vehicleImageUrl,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmerPhone: farmerPhone ?? this.farmerPhone,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      duration: duration ?? this.duration,
      durationUnit: durationUnit ?? this.durationUnit,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      goodsDescription: goodsDescription ?? this.goodsDescription,
      withOperator: withOperator ?? this.withOperator,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

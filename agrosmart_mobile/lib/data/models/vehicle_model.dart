
class VehicleModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String phone;
  final String category; // 'equipment' or 'transport'
  final String vehicleType; // 'Tractor', 'Harvester', 'Power Tiller', 'Rotavator', 'Ploughing Equipment', 'Seed Drill', 'Sprayer', 'Mini Truck', 'Pickup Truck', 'Goods Carrier', 'Trailer', 'Other'
  final String modelName;
  final String registrationNumber;
  final String imageUrl;
  final double rate;
  final String rateUnit; // '/ Hour', '/ Day', '/ Acre', '/ Km', '/ Trip'
  final String? loadCapacity; // e.g. '1.5 Tons', '3.0 Tons'
  final String? hpRating; // e.g. '45 HP', '75 HP'
  final String specifications;
  final String location;
  final double serviceRadiusKm;
  final double distanceKm;
  final bool isAvailable;
  final bool hasOperator;
  final double operatorRateExtra;
  final double rating;
  final int reviewCount;
  final String description;
  final DateTime createdAt;

  VehicleModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.phone,
    required this.category,
    required this.vehicleType,
    required this.modelName,
    this.registrationNumber = '',
    required this.imageUrl,
    required this.rate,
    required this.rateUnit,
    this.loadCapacity,
    this.hpRating,
    required this.specifications,
    required this.location,
    this.serviceRadiusKm = 25.0,
    this.distanceKm = 4.5,
    this.isAvailable = true,
    this.hasOperator = true,
    this.operatorRateExtra = 0.0,
    this.rating = 4.8,
    this.reviewCount = 12,
    this.description = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'phone': phone,
      'category': category,
      'vehicleType': vehicleType,
      'modelName': modelName,
      'registrationNumber': registrationNumber,
      'imageUrl': imageUrl,
      'rate': rate,
      'rateUnit': rateUnit,
      'loadCapacity': loadCapacity,
      'hpRating': hpRating,
      'specifications': specifications,
      'location': location,
      'serviceRadiusKm': serviceRadiusKm,
      'distanceKm': distanceKm,
      'isAvailable': isAvailable,
      'hasOperator': hasOperator,
      'operatorRateExtra': operatorRateExtra,
      'rating': rating,
      'reviewCount': reviewCount,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? 'user_default',
      ownerName: json['ownerName'] ?? 'Unknown Owner',
      phone: json['phone'] ?? '',
      category: json['category'] ?? 'equipment',
      vehicleType: json['vehicleType'] ?? 'Tractor',
      modelName: json['modelName'] ?? 'Agri Machine',
      registrationNumber: json['registrationNumber'] ?? '',
      imageUrl: json['imageUrl'] ?? 'assets/images/tractor.jpg',
      rate: (json['rate'] as num?)?.toDouble() ?? 500.0,
      rateUnit: json['rateUnit'] ?? '/ Hour',
      loadCapacity: json['loadCapacity'],
      hpRating: json['hpRating'],
      specifications: json['specifications'] ?? '',
      location: json['location'] ?? 'Location N/A',
      serviceRadiusKm: (json['serviceRadiusKm'] as num?)?.toDouble() ?? 25.0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 5.0,
      isAvailable: json['isAvailable'] ?? true,
      hasOperator: json['hasOperator'] ?? true,
      operatorRateExtra: (json['operatorRateExtra'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: json['reviewCount'] ?? 10,
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  VehicleModel copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? phone,
    String? category,
    String? vehicleType,
    String? modelName,
    String? registrationNumber,
    String? imageUrl,
    double? rate,
    String? rateUnit,
    String? loadCapacity,
    String? hpRating,
    String? specifications,
    String? location,
    double? serviceRadiusKm,
    double? distanceKm,
    bool? isAvailable,
    bool? hasOperator,
    double? operatorRateExtra,
    double? rating,
    int? reviewCount,
    String? description,
    DateTime? createdAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      category: category ?? this.category,
      vehicleType: vehicleType ?? this.vehicleType,
      modelName: modelName ?? this.modelName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      rate: rate ?? this.rate,
      rateUnit: rateUnit ?? this.rateUnit,
      loadCapacity: loadCapacity ?? this.loadCapacity,
      hpRating: hpRating ?? this.hpRating,
      specifications: specifications ?? this.specifications,
      location: location ?? this.location,
      serviceRadiusKm: serviceRadiusKm ?? this.serviceRadiusKm,
      distanceKm: distanceKm ?? this.distanceKm,
      isAvailable: isAvailable ?? this.isAvailable,
      hasOperator: hasOperator ?? this.hasOperator,
      operatorRateExtra: operatorRateExtra ?? this.operatorRateExtra,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

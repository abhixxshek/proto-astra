class VehicleModel {
  final String id;
  final String ownerName;
  final String vehicleType;
  final String modelName;
  final String rate;
  final String location;
  final String phone;
  final bool isAvailable;

  VehicleModel({
    required this.id,
    required this.ownerName,
    required this.vehicleType,
    required this.modelName,
    required this.rate,
    required this.location,
    required this.phone,
    this.isAvailable = true,
  });
}

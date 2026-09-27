import 'package:flutter/foundation.dart';
import '../data/models/vehicle_model.dart';

class TransportProvider extends ChangeNotifier {
  final List<VehicleModel> _vehicles = [
    VehicleModel(
      id: 'v1',
      ownerName: 'Suresh Patil',
      vehicleType: 'Tractor',
      modelName: 'Mahindra 575 DI (45 HP)',
      rate: '₹600 / Hour',
      location: 'Pune, Maharashtra',
      phone: '+919876543210',
      isAvailable: true,
    ),
    VehicleModel(
      id: 'v2',
      ownerName: 'Balwant Singh',
      vehicleType: 'Harvester',
      modelName: 'Preet Combine Harvester',
      rate: '₹1,800 / Mile',
      location: 'Ludhiana, Punjab',
      phone: '+919812345678',
      isAvailable: true,
    ),
    VehicleModel(
      id: 'v3',
      ownerName: 'Ramesh Pawar',
      vehicleType: 'Transport Truck',
      modelName: 'Tata Yodha Pickup (1.7T)',
      rate: '₹35 / Km',
      location: 'Nashik, Maharashtra',
      phone: '+919765432109',
      isAvailable: true,
    ),
  ];

  List<VehicleModel> get vehicles => _vehicles;
}

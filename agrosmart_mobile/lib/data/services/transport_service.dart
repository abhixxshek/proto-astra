import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle_model.dart';
import '../models/booking_model.dart';

class TransportService {
  static const String _vehiclesKey = 'agrosmart_vehicles_v2';
  static const String _bookingsKey = 'agrosmart_bookings_v2';

  // Seed default vehicles if none exist in SharedPreferences
  List<VehicleModel> _getInitialSeedVehicles() {
    return [
      VehicleModel(
        id: 'v1',
        ownerId: 'owner_suresh',
        ownerName: 'Suresh Patil',
        phone: '+91 98765 43210',
        category: 'equipment',
        vehicleType: 'Tractor',
        modelName: 'Mahindra 575 DI (45 HP)',
        registrationNumber: 'MH 12 AB 4589',
        imageUrl: 'assets/images/tractor.jpg',
        rate: 600.0,
        rateUnit: '/ Hour',
        hpRating: '45 HP',
        specifications: '4 Cylinder, High Torque, Rotavator & Plough Attachment Ready',
        location: 'Pune, Maharashtra',
        serviceRadiusKm: 30.0,
        distanceKm: 3.8,
        isAvailable: true,
        hasOperator: true,
        operatorRateExtra: 100.0,
        rating: 4.9,
        reviewCount: 38,
        description: 'Heavy duty tractor suitable for deep ploughing, rotavating, and agricultural haulage across Pune region.',
      ),
      VehicleModel(
        id: 'v2',
        ownerId: 'owner_balwant',
        ownerName: 'Balwant Singh',
        phone: '+91 98123 45678',
        category: 'equipment',
        vehicleType: 'Harvester',
        modelName: 'Preet Combine Harvester 987',
        registrationNumber: 'PB 10 CT 7712',
        imageUrl: 'assets/images/harvester.jpg',
        rate: 1800.0,
        rateUnit: '/ Acre',
        hpRating: '101 HP',
        specifications: 'Wheat & Paddy Dual Cutter, Straw Management System',
        location: 'Ludhiana, Punjab',
        serviceRadiusKm: 50.0,
        distanceKm: 8.2,
        isAvailable: true,
        hasOperator: true,
        operatorRateExtra: 0.0,
        rating: 4.8,
        reviewCount: 52,
        description: 'High capacity self-propelled combine harvester for wheat, paddy, and soybean harvesting.',
      ),
      VehicleModel(
        id: 'v3',
        ownerId: 'owner_ramesh',
        ownerName: 'Ramesh Pawar',
        phone: '+91 97654 32109',
        category: 'transport',
        vehicleType: 'Pickup Truck',
        modelName: 'Tata Yodha Pickup (1.7T)',
        registrationNumber: 'MH 15 BR 9001',
        imageUrl: 'assets/images/pickup.jpg',
        rate: 35.0,
        rateUnit: '/ Km',
        loadCapacity: '1.7 Tons',
        specifications: 'BS6 Diesel, High Deck Body, Weather-proof Tarpaulins Included',
        location: 'Nashik, Maharashtra',
        serviceRadiusKm: 100.0,
        distanceKm: 4.1,
        isAvailable: true,
        hasOperator: true,
        operatorRateExtra: 0.0,
        rating: 4.7,
        reviewCount: 29,
        description: 'Reliable pickup truck for transport of fresh vegetables, grains, and agricultural goods to APMC markets.',
      ),
      VehicleModel(
        id: 'v4',
        ownerId: 'owner_ganesh',
        ownerName: 'Ganesh Deshmukh',
        phone: '+91 98220 11223',
        category: 'equipment',
        vehicleType: 'Power Tiller',
        modelName: 'VST Shakti 135 DI Power Tiller',
        registrationNumber: 'MH 14 DF 2210',
        imageUrl: 'assets/images/tractor.jpg',
        rate: 350.0,
        rateUnit: '/ Hour',
        hpRating: '13 HP',
        specifications: 'Rotary Tiller & Ridge Maker Attachments Included',
        location: 'Satara, Maharashtra',
        serviceRadiusKm: 20.0,
        distanceKm: 6.5,
        isAvailable: true,
        hasOperator: true,
        operatorRateExtra: 50.0,
        rating: 4.6,
        reviewCount: 19,
        description: 'Compact power tiller ideally suited for paddy field puddling and small orchard cultivation.',
      ),
      VehicleModel(
        id: 'v5',
        ownerId: 'owner_vikram',
        ownerName: 'Vikram Rathore',
        phone: '+91 94140 88990',
        category: 'transport',
        vehicleType: 'Mini Truck',
        modelName: 'Mahindra Supro Profit Truck',
        registrationNumber: 'RJ 14 CC 5543',
        imageUrl: 'assets/images/pickup.jpg',
        rate: 1200.0,
        rateUnit: '/ Trip',
        loadCapacity: '1.0 Ton',
        specifications: 'Compact size for narrow farm roads, experienced driver',
        location: 'Jaipur, Rajasthan',
        serviceRadiusKm: 40.0,
        distanceKm: 11.0,
        isAvailable: true,
        hasOperator: true,
        operatorRateExtra: 0.0,
        rating: 4.9,
        reviewCount: 41,
        description: 'Agile mini truck for inter-village and local market crop distribution.',
      ),
      VehicleModel(
        id: 'v6',
        ownerId: 'owner_anand',
        ownerName: 'Anand Shinde',
        phone: '+91 98901 33445',
        category: 'equipment',
        vehicleType: 'Sprayer',
        modelName: 'ASPEE Tractor Mounted Boom Sprayer',
        registrationNumber: 'MH 09 EQ 1122',
        imageUrl: 'assets/images/tractor.jpg',
        rate: 500.0,
        rateUnit: '/ Hour',
        hpRating: '500 Liter Capacity',
        specifications: '12-Meter Folding Boom, Nozzle Flow Adjustment',
        location: 'Kolhapur, Maharashtra',
        serviceRadiusKm: 25.0,
        distanceKm: 9.3,
        isAvailable: true,
        hasOperator: true,
        operatorRateExtra: 75.0,
        rating: 4.7,
        reviewCount: 16,
        description: 'Precision crop protection sprayer for uniform pesticide and liquid fertilizer spraying.',
      ),
    ];
  }

  // Load vehicles from local storage
  Future<List<VehicleModel>> loadVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? vehiclesJsonStr = prefs.getString(_vehiclesKey);
    if (vehiclesJsonStr != null && vehiclesJsonStr.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(vehiclesJsonStr);
        final storedVehicles = jsonList.map((j) => VehicleModel.fromJson(j)).toList();
        if (storedVehicles.isNotEmpty) {
          return storedVehicles;
        }
      } catch (e) {
        // Fallback to seed data on decode error
      }
    }
    // Save seed data first time
    final seeds = _getInitialSeedVehicles();
    await saveVehicles(seeds);
    return seeds;
  }

  // Save vehicles list to local storage
  Future<void> saveVehicles(List<VehicleModel> vehicles) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = vehicles.map((v) => v.toJson()).toList();
    await prefs.setString(_vehiclesKey, jsonEncode(jsonList));
  }

  // Load bookings from local storage
  Future<List<BookingModel>> loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? bookingsJsonStr = prefs.getString(_bookingsKey);
    if (bookingsJsonStr != null && bookingsJsonStr.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(bookingsJsonStr);
        return jsonList.map((j) => BookingModel.fromJson(j)).toList();
      } catch (e) {
        return [];
      }
    }
    // Seed initial booking demo
    final initialBooking = BookingModel(
      id: 'b_demo_1',
      vehicleId: 'v1',
      vehicleName: 'Mahindra 575 DI (45 HP)',
      vehicleType: 'Tractor',
      category: 'equipment',
      vehicleImageUrl: 'assets/images/tractor.jpg',
      farmerId: 'farmer_current',
      farmerName: 'Kisan Kumar',
      farmerPhone: '+91 99887 76655',
      ownerId: 'owner_suresh',
      ownerName: 'Suresh Patil',
      ownerPhone: '+91 98765 43210',
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 1, hours: 4)),
      duration: 4.0,
      durationUnit: 'Hours',
      deliveryLocation: 'Plot 14, Green Valley Farm, Hadapsar, Pune',
      withOperator: true,
      estimatedCost: 2800.0,
      status: BookingStatus.accepted,
    );
    await saveBookings([initialBooking]);
    return [initialBooking];
  }

  // Save bookings list to local storage
  Future<void> saveBookings(List<BookingModel> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = bookings.map((b) => b.toJson()).toList();
    await prefs.setString(_bookingsKey, jsonEncode(jsonList));
  }
}

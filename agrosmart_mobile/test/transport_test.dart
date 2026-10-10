import 'package:flutter_test/flutter_test.dart';
import 'package:agrosmart_mobile/data/models/vehicle_model.dart';
import 'package:agrosmart_mobile/data/models/booking_model.dart';
import 'package:agrosmart_mobile/providers/transport_provider.dart';
import 'package:agrosmart_mobile/data/services/transport_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Agricultural Transport & Equipment Rental Module Tests', () {
    late TransportProvider transportProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      transportProvider = TransportProvider(service: TransportService());
    });

    test('VehicleModel serialization and properties', () {
      final vehicle = VehicleModel(
        id: 'v_test',
        ownerId: 'owner_1',
        ownerName: 'Ramesh Kumar',
        phone: '+91 98765 00000',
        category: 'equipment',
        vehicleType: 'Tractor',
        modelName: 'Mahindra 575 DI',
        imageUrl: 'assets/images/tractor.jpg',
        rate: 600.0,
        rateUnit: '/ Hour',
        hpRating: '45 HP',
        specifications: 'High torque engine',
        location: 'Pune, Maharashtra',
      );

      final json = vehicle.toJson();
      expect(json['id'], 'v_test');
      expect(json['vehicleType'], 'Tractor');

      final deserialized = VehicleModel.fromJson(json);
      expect(deserialized.modelName, 'Mahindra 575 DI');
      expect(deserialized.rate, 600.0);
    });

    test('BookingModel status extensions and serialization', () {
      final booking = BookingModel(
        id: 'b_test',
        vehicleId: 'v_1',
        vehicleName: 'Mahindra 575 DI',
        vehicleType: 'Tractor',
        category: 'equipment',
        vehicleImageUrl: 'assets/images/tractor.jpg',
        farmerId: 'farmer_1',
        farmerName: 'Kisan',
        farmerPhone: '+91 99999 88888',
        ownerId: 'owner_1',
        ownerName: 'Ramesh',
        ownerPhone: '+91 98765 00000',
        startDate: DateTime(2026, 10, 1, 9, 0),
        endDate: DateTime(2026, 10, 1, 13, 0),
        duration: 4.0,
        durationUnit: 'Hours',
        deliveryLocation: 'Plot 10, Farm Gate',
        withOperator: true,
        estimatedCost: 2400.0,
        status: BookingStatus.pending,
      );

      expect(booking.status.label, 'Pending');
      expect(booking.status.labelHindi, 'लंबित (Pending)');

      final json = booking.toJson();
      final deserialized = BookingModel.fromJson(json);
      expect(deserialized.estimatedCost, 2400.0);
      expect(deserialized.status, BookingStatus.pending);
    });

    test('TransportProvider filtering and double booking prevention', () async {
      await transportProvider.init();

      // Check default seed listings loaded
      expect(transportProvider.vehicles.isNotEmpty, true);

      // Search filter test
      transportProvider.setSearchQuery('Mahindra');
      final filtered = transportProvider.filteredVehicles;
      expect(filtered.every((v) => v.modelName.toLowerCase().contains('mahindra')), true);

      // Reset filters
      transportProvider.resetFilters();
      expect(transportProvider.filteredVehicles.length, transportProvider.vehicles.length);

      // Create booking
      final newBooking = BookingModel(
        id: 'b_unique_1',
        vehicleId: 'v1',
        vehicleName: 'Mahindra 575 DI',
        vehicleType: 'Tractor',
        category: 'equipment',
        vehicleImageUrl: 'assets/images/tractor.jpg',
        farmerId: 'farmer_current',
        farmerName: 'Kisan',
        farmerPhone: '+91 99999 88888',
        ownerId: 'owner_suresh',
        ownerName: 'Suresh Patil',
        ownerPhone: '+91 98765 43210',
        startDate: DateTime(2026, 11, 10, 10, 0),
        endDate: DateTime(2026, 11, 10, 14, 0),
        duration: 4.0,
        durationUnit: 'Hours',
        deliveryLocation: 'Farm Plot 15',
        withOperator: true,
        estimatedCost: 2400.0,
        status: BookingStatus.accepted,
      );

      final result = await transportProvider.createBooking(newBooking);
      expect(result, true);

      // Double booking attempt on overlapping time window
      final conflictingBooking = BookingModel(
        id: 'b_conflict',
        vehicleId: 'v1',
        vehicleName: 'Mahindra 575 DI',
        vehicleType: 'Tractor',
        category: 'equipment',
        vehicleImageUrl: 'assets/images/tractor.jpg',
        farmerId: 'farmer_2',
        farmerName: 'Other Farmer',
        farmerPhone: '+91 99999 00000',
        ownerId: 'owner_suresh',
        ownerName: 'Suresh Patil',
        ownerPhone: '+91 98765 43210',
        startDate: DateTime(2026, 11, 10, 11, 0), // Overlaps with 10:00 to 14:00!
        endDate: DateTime(2026, 11, 10, 15, 0),
        duration: 4.0,
        durationUnit: 'Hours',
        deliveryLocation: 'Farm Plot 20',
        withOperator: true,
        estimatedCost: 2400.0,
        status: BookingStatus.pending,
      );

      final conflictResult = await transportProvider.createBooking(conflictingBooking);
      expect(conflictResult, false); // Must block double booking!
      expect(transportProvider.errorMessage, contains('already booked'));
    });
  });
}

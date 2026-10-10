import 'package:flutter/foundation.dart';
import '../data/models/vehicle_model.dart';
import '../data/models/booking_model.dart';
import '../data/services/transport_service.dart';

class TransportProvider extends ChangeNotifier {
  final TransportService _service;

  List<VehicleModel> _vehicles = [];
  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Navigation & Filtering state
  int _selectedTabIndex = 0; // 0: Explore Marketplace, 1: My Bookings, 2: Owner Dashboard
  String _selectedCategory = 'All'; // 'All', 'Transport', 'Tractors', 'Harvesters', 'Power Tillers', 'Rotavators', 'Sprayers'
  String _searchQuery = '';
  double _maxDistanceKm = 100.0;
  double _maxPrice = 5000.0;
  bool _onlyWithOperator = false;
  bool _onlyAvailable = false;
  String _sortBy = 'distance'; // 'distance', 'price_low', 'price_high', 'rating'

  TransportProvider({TransportService? service})
      : _service = service ?? TransportService() {
    init();
  }

  // Getters
  List<VehicleModel> get vehicles => _vehicles;
  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get selectedTabIndex => _selectedTabIndex;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  double get maxDistanceKm => _maxDistanceKm;
  double get maxPrice => _maxPrice;
  bool get onlyWithOperator => _onlyWithOperator;
  bool get onlyAvailable => _onlyAvailable;
  String get sortBy => _sortBy;

  // Initialize data from persistence storage
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      _vehicles = await _service.loadVehicles();
      _bookings = await _service.loadBookings();
    } catch (e) {
      _errorMessage = 'Failed to load transport data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Setters for filters
  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateFilters({
    double? maxDistanceKm,
    double? maxPrice,
    bool? onlyWithOperator,
    bool? onlyAvailable,
    String? sortBy,
  }) {
    if (maxDistanceKm != null) _maxDistanceKm = maxDistanceKm;
    if (maxPrice != null) _maxPrice = maxPrice;
    if (onlyWithOperator != null) _onlyWithOperator = onlyWithOperator;
    if (onlyAvailable != null) _onlyAvailable = onlyAvailable;
    if (sortBy != null) _sortBy = sortBy;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _maxDistanceKm = 100.0;
    _maxPrice = 5000.0;
    _onlyWithOperator = false;
    _onlyAvailable = false;
    _sortBy = 'distance';
    notifyListeners();
  }

  // Filtered vehicles getter for farmer marketplace view
  List<VehicleModel> get filteredVehicles {
    return _vehicles.where((v) {
      // Category filter
      if (_selectedCategory != 'All') {
        if (_selectedCategory == 'Transport') {
          if (v.category != 'transport') return false;
        } else if (_selectedCategory == 'Tractors') {
          if (v.vehicleType != 'Tractor') return false;
        } else if (_selectedCategory == 'Harvesters') {
          if (v.vehicleType != 'Harvester') return false;
        } else if (_selectedCategory == 'Power Tillers') {
          if (v.vehicleType != 'Power Tiller') return false;
        } else if (_selectedCategory == 'Rotavators') {
          if (v.vehicleType != 'Rotavator') return false;
        } else if (_selectedCategory == 'Sprayers') {
          if (v.vehicleType != 'Sprayer') return false;
        }
      }

      // Search query filter (matches modelName, ownerName, vehicleType, location)
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchModel = v.modelName.toLowerCase().contains(q);
        final matchOwner = v.ownerName.toLowerCase().contains(q);
        final matchType = v.vehicleType.toLowerCase().contains(q);
        final matchLoc = v.location.toLowerCase().contains(q);
        if (!matchModel && !matchOwner && !matchType && !matchLoc) return false;
      }

      // Distance filter
      if (v.distanceKm > _maxDistanceKm) return false;

      // Price filter
      if (v.rate > _maxPrice) return false;

      // Operator filter
      if (_onlyWithOperator && !v.hasOperator) return false;

      // Availability filter
      if (_onlyAvailable && !v.isAvailable) return false;

      return true;
    }).toList()
      ..sort((a, b) {
        switch (_sortBy) {
          case 'price_low':
            return a.rate.compareTo(b.rate);
          case 'price_high':
            return b.rate.compareTo(a.rate);
          case 'rating':
            return b.rating.compareTo(a.rating);
          case 'distance':
          default:
            return a.distanceKm.compareTo(b.distanceKm);
        }
      });
  }

  // Double Booking validation check
  bool isVehicleAvailableForDates({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
    String? excludeBookingId,
  }) {
    for (final booking in _bookings) {
      if (booking.vehicleId == vehicleId) {
        if (excludeBookingId != null && booking.id == excludeBookingId) continue;
        // Ignore cancelled or rejected bookings
        if (booking.status == BookingStatus.cancelled ||
            booking.status == BookingStatus.rejected) {
          continue;
        }

        // Check date overlap: (StartA < EndB) and (EndA > StartB)
        if (startDate.isBefore(booking.endDate) && endDate.isAfter(booking.startDate)) {
          return false; // Conflict found!
        }
      }
    }
    return true;
  }

  // Create new rental booking
  Future<bool> createBooking(BookingModel booking) async {
    _errorMessage = null;

    // Validate availability & check double bookings
    final isAvailable = isVehicleAvailableForDates(
      vehicleId: booking.vehicleId,
      startDate: booking.startDate,
      endDate: booking.endDate,
    );

    if (!isAvailable) {
      _errorMessage =
          'This vehicle/equipment is already booked for the selected time window. Please choose another date or time.';
      notifyListeners();
      return false;
    }

    _bookings.insert(0, booking);
    await _service.saveBookings(_bookings);
    notifyListeners();
    return true;
  }

  // Cancel booking (Farmer action)
  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.cancelled,
        cancellationReason: reason ?? 'Cancelled by farmer',
      );
      await _service.saveBookings(_bookings);
      notifyListeners();
    }
  }

  // Update booking status (Owner action: accept, reject, complete)
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus, {
    String? cancellationReason,
  }) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: newStatus,
        cancellationReason: cancellationReason,
      );
      await _service.saveBookings(_bookings);
      notifyListeners();
    }
  }

  // Owner Vehicle Management (Add, Edit, Delete, Toggle Availability)
  Future<void> addVehicle(VehicleModel vehicle) async {
    _vehicles.insert(0, vehicle);
    await _service.saveVehicles(_vehicles);
    notifyListeners();
  }

  Future<void> updateVehicle(VehicleModel vehicle) async {
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      _vehicles[index] = vehicle;
      await _service.saveVehicles(_vehicles);
      notifyListeners();
    }
  }

  Future<void> toggleVehicleAvailability(String vehicleId) async {
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index != -1) {
      final current = _vehicles[index];
      _vehicles[index] = current.copyWith(isAvailable: !current.isAvailable);
      await _service.saveVehicles(_vehicles);
      notifyListeners();
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    _vehicles.removeWhere((v) => v.id == vehicleId);
    await _service.saveVehicles(_vehicles);
    notifyListeners();
  }

  // Helper getters for specific roles
  List<BookingModel> getUserBookings(String farmerId) {
    return _bookings.where((b) => b.farmerId == farmerId || farmerId == 'farmer_current' || farmerId == 'all').toList();
  }

  List<BookingModel> getOwnerBookings(String ownerId) {
    return _bookings.where((b) => b.ownerId == ownerId || ownerId == 'owner_suresh' || ownerId == 'all').toList();
  }

  List<VehicleModel> getOwnerVehicles(String ownerId) {
    return _vehicles.where((v) => v.ownerId == ownerId || ownerId == 'owner_suresh' || ownerId == 'all').toList();
  }

  // Owner earnings metrics
  Map<String, dynamic> getOwnerMetrics(String ownerId) {
    final ownerVehicles = getOwnerVehicles(ownerId);
    final ownerRequests = getOwnerBookings(ownerId);

    double totalEarnings = 0.0;
    int completedCount = 0;
    int activeCount = 0;
    int pendingCount = 0;

    for (final b in ownerRequests) {
      if (b.status == BookingStatus.completed) {
        totalEarnings += b.estimatedCost;
        completedCount++;
      } else if (b.status == BookingStatus.accepted || b.status == BookingStatus.ongoing) {
        activeCount++;
      } else if (b.status == BookingStatus.pending) {
        pendingCount++;
      }
    }

    return {
      'totalEarnings': totalEarnings,
      'listedCount': ownerVehicles.length,
      'completedCount': completedCount,
      'activeCount': activeCount,
      'pendingCount': pendingCount,
    };
  }
}

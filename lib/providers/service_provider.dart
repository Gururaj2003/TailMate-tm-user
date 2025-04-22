import 'package:flutter/foundation.dart';
import 'package:tailmate/models/booking.dart';
import 'package:tailmate/models/service.dart';
import 'package:tailmate/models/service_provider_model.dart';
import 'package:tailmate/services/supabase_service.dart';
import 'package:uuid/uuid.dart';

class ServiceProvider with ChangeNotifier {
  final List<Service> _services = [];
  final List<ServiceProviderModel> _serviceProviders = [];
  final List<Booking> _bookings = [];
  final SupabaseService _supabaseService = SupabaseService();

  List<Service> get services => List.unmodifiable(_services);
  List<ServiceProviderModel> get serviceProviders => List.unmodifiable(_serviceProviders);
  List<Booking> get bookings => List.unmodifiable(_bookings);

  Future<void> loadServices() async {
    try {
      print('Loading services from Supabase...');
      final services = await _supabaseService.getServices();
      print('Raw services data received: $services');
      
      _services.clear();
      if (services.isNotEmpty) {
        for (var service in services) {
          try {
            print('Converting service: ${service['name']}');
            print('Service data: $service');
            final model = Service.fromMap(service);
            print('Converted service model: ${model.title} (ID: ${model.id})');
            _services.add(model);
          } catch (e) {
            print('Error converting service: $e');
          }
        }
      }
      print('Total services loaded: ${_services.length}');
      notifyListeners();
    } catch (e) {
      print('Error loading services: $e');
      rethrow;
    }
  }

  Future<void> loadServiceProviders() async {
    try {
      print('Loading service providers...');
      _serviceProviders.clear();
      
      final providers = await _supabaseService.getServiceProviders();
      print('Raw providers data received: $providers');
      
      for (var provider in providers) {
        try {
          print('Converting provider: ${provider['name']}');
          print('Provider data: $provider');
          print('Service IDs: ${provider['service_ids']}');
          print('Specialties: ${provider['specialties']}');
          
          final model = ServiceProviderModel.fromMap(provider);
          print('Converted model: ${model.name} (ID: ${model.id})');
          print('Model Service IDs: ${model.serviceIds}');
          print('Model Specialties: ${model.specialties}');
          _serviceProviders.add(model);
        } catch (e) {
          print('Error converting provider ${provider['name']}: $e');
        }
      }
      
      print('Total providers loaded: ${_serviceProviders.length}');
      notifyListeners();
    } catch (e) {
      print('Error loading service providers: $e');
      throw Exception('Failed to load service providers');
    }
  }

  Future<void> loadBookings() async {
    try {
      final bookings = await _supabaseService.getUserBookings();
      _bookings.clear();
      _bookings.addAll(bookings.map((data) => Booking.fromMap(data)));
      notifyListeners();
    } catch (e) {
      print('Error loading bookings: $e');
      rethrow;
    }
  }

  List<ServiceProviderModel> getProvidersForService(String serviceId) {
    print('Getting providers for service ID: $serviceId');
    print('Total providers available: ${_serviceProviders.length}');
    
    final providers = _serviceProviders
        .where((provider) {
          print('Checking provider: ${provider.name}');
          print('Provider service IDs: ${provider.serviceIds}');
          final contains = provider.serviceIds.contains(serviceId);
          print('Contains service ID $serviceId: $contains');
          return contains;
        })
        .toList();
        
    print('Found ${providers.length} providers for service $serviceId');
    return providers;
  }

  List<Booking> getBookingsByStatus(BookingStatus status) {
    return _bookings.where((booking) => booking.status == status).toList();
  }

  Future<void> addBooking({
    required String providerId,
    required String serviceId,
    required String petId,
    required DateTime dateTime,
    required double amount,
    String? notes,
  }) async {
    try {
      final booking = await _supabaseService.createBooking(
        providerId: providerId,
        serviceId: serviceId,
        petId: petId,
        bookingDate: dateTime.toIso8601String().split('T')[0],
        bookingTime: dateTime.toIso8601String().split('T')[1].substring(0, 5),
        amount: amount,
        notes: notes,
      );

      _bookings.add(Booking.fromMap(booking));
      notifyListeners();
    } catch (e) {
      print('Error creating booking: $e');
      rethrow;
    }
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus) async {
    try {
      await _supabaseService.updateBookingStatus(bookingId, newStatus);
      final index = _bookings.indexWhere((booking) => booking.id == bookingId);
      if (index >= 0) {
        _bookings[index] = _bookings[index].copyWith(status: newStatus);
        notifyListeners();
      }
    } catch (e) {
      print('Error updating booking status: $e');
      rethrow;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  Service getServiceById(String id) {
    return _services.firstWhere((service) => service.id == id);
  }

  ServiceProviderModel getProviderById(String id) {
    return _serviceProviders.firstWhere((provider) => provider.id == id);
  }

  List<Booking> getBookingsForPet(String petId) {
    return _bookings.where((booking) => booking.petId == petId).toList();
  }
} 
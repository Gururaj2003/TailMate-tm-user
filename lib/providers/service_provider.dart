import 'package:flutter/foundation.dart';
import 'package:postgrest/postgrest.dart';
import 'package:tailmate/models/booking.dart';
import 'package:tailmate/models/service.dart';
import 'package:tailmate/models/service_provider_model.dart';
import 'package:tailmate/services/supabase_service.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceProvider extends ChangeNotifier {
  final SupabaseClient _supabase;
  List<Service> _services = [];
  final List<ServiceProviderModel> _serviceProviders = [];
  final List<Booking> _bookings = [];
  String? _error;
  bool _isLoading = false;

  ServiceProvider(this._supabase) {
    _initialize();
  }

  List<Service> get services => _services;
  List<ServiceProviderModel> get serviceProviders => List.unmodifiable(_serviceProviders);
  List<Booking> get bookings => List.unmodifiable(_bookings);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('services')
          .select()
          .order('created_at', ascending: false);

      _services = (response as List)
          .map((data) => Service.fromMap(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addService(Service service) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('services')
          .insert(service.toMap())
          .select()
          .single();

      final newService = Service.fromMap(response as Map<String, dynamic>);
      _services.add(newService);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateService(Service service) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('services')
          .update(service.toMap())
          .eq('id', service.id)
          .select()
          .single();

      final updatedService = Service.fromMap(response as Map<String, dynamic>);
      final index = _services.indexWhere((s) => s.id == service.id);
      if (index != -1) {
        _services[index] = updatedService;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteService(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.from('services').delete().eq('id', id);
      _services.removeWhere((service) => service.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadServiceProviders() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Loading service providers...');
      _serviceProviders.clear();
      
      final providers = await _supabase.from('service_providers').select();
      print('Raw providers data received: $providers');
      
      if (providers.isNotEmpty) {
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
            continue;
          }
        }
      } else {
        print('No service providers found in the database');
      }
      
      print('Total providers loaded: ${_serviceProviders.length}');
    } catch (e) {
      print('Error loading service providers: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
        _error = 'Unable to connect to the server. Please check your internet connection.';
      } else {
        _error = 'Failed to load service providers. Please try again later.';
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBookings() async {
    try {
      print('Starting to load bookings...');
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      // First, load all service providers
      await loadServiceProviders();

      // Then load bookings with services and pets
      final bookings = await _supabase
          .from('bookings')
          .select('*, services(*), pets(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('Raw bookings data received: $bookings');
      
      _bookings.clear();
      if (bookings != null && bookings.isNotEmpty) {
        for (var booking in bookings) {
          try {
            print('Processing booking: ${booking['id']}');
            
            // Safely extract nested data with null checks
            final serviceData = booking['services'] as Map<String, dynamic>?;
            final petData = booking['pets'] as Map<String, dynamic>?;
            
            if (serviceData == null || petData == null) {
              print('Warning: Missing nested data for booking ${booking['id']}');
              print('Service data: $serviceData');
              print('Pet data: $petData');
              continue;
            }
            
            // Get the provider ID from the service
            final providerId = serviceData['provider_id']?.toString();
            if (providerId == null) {
              print('Warning: Service ${serviceData['id']} has no provider ID');
              continue;
            }

            // Find the provider in our loaded providers list
            final provider = _serviceProviders.firstWhere(
              (p) => p.id == providerId,
              orElse: () {
                print('Warning: Provider $providerId not found in loaded providers');
                return ServiceProviderModel(
                  id: providerId,
                  name: 'Unknown Provider',
                  email: '',
                  phone: '',
                  address: '',
                  rating: 0.0,
                  totalRatings: 0,
                  profileImage: '',
                  isVerified: false,
                  serviceIds: [],
                  specialties: [],
                  description: '',
                  priceMultiplier: 1.0,
                  location: '',
                  latitude: null,
                  longitude: null,
                );
              },
            );
            
            // Create a new map with the required fields
            final bookingData = {
              'id': booking['id']?.toString() ?? '',
              'user_id': booking['user_id']?.toString() ?? '',
              'provider_id': providerId,
              'service_id': serviceData['id']?.toString() ?? '',
              'pet_id': petData['id']?.toString() ?? '',
              'booking_date': booking['booking_date']?.toString() ?? '',
              'booking_time': booking['booking_time']?.toString() ?? '',
              'status': booking['status']?.toString() ?? 'pending',
              'payment_status': booking['payment_status']?.toString() ?? 'pending',
              'amount': (booking['amount'] as num?)?.toDouble() ?? 0.0,
              'notes': booking['notes']?.toString(),
              'created_at': booking['created_at']?.toString() ?? DateTime.now().toIso8601String(),
              'updated_at': booking['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
            };
            
            print('Processed booking data: $bookingData');
            
            // Create DateTime from booking_date and booking_time
            final dateParts = (bookingData['booking_date'] as String).split('-');
            final timeParts = (bookingData['booking_time'] as String).split(':');
            
            if (dateParts.length != 3 || timeParts.length != 2) {
              print('Invalid date or time format for booking ${bookingData['id']}');
              continue;
            }
            
            final dateTime = DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
            );
            
            // Create the booking model
            final model = Booking(
              id: bookingData['id'] as String,
              userId: bookingData['user_id'] as String,
              providerId: bookingData['provider_id'] as String,
              serviceId: bookingData['service_id'] as String,
              petId: bookingData['pet_id'] as String,
              dateTime: dateTime,
              status: BookingStatus.values.firstWhere(
                (e) => e.toString().split('.').last == bookingData['status'],
                orElse: () => BookingStatus.pending,
              ),
              paymentStatus: PaymentStatus.values.firstWhere(
                (e) => e.toString().split('.').last == bookingData['payment_status'],
                orElse: () => PaymentStatus.pending,
              ),
              amount: bookingData['amount'] as double,
              notes: bookingData['notes'] as String?,
              createdAt: DateTime.parse(bookingData['created_at'] as String),
              updatedAt: DateTime.parse(bookingData['updated_at'] as String),
            );
            
            print('Successfully converted booking: ${model.id}');
            _bookings.add(model);
          } catch (e, stackTrace) {
            print('Error processing booking: $e');
            print('Stack trace: $stackTrace');
            print('Raw booking data: $booking');
            continue;
          }
        }
      } else {
        print('No bookings found in the database');
      }
      
      print('Successfully loaded ${_bookings.length} bookings');
      print('Pending bookings: ${getBookingsByStatus(BookingStatus.pending).length}');
      print('Confirmed bookings: ${getBookingsByStatus(BookingStatus.confirmed).length}');
      
      // Force a UI update
      notifyListeners();
    } catch (e, stackTrace) {
      print('Error loading bookings: $e');
      print('Stack trace: $stackTrace');
      
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
        _error = 'Unable to connect to the server. Please check your internet connection.';
      } else if (e.toString().contains('No user logged in')) {
        _error = 'Please sign in to view your bookings.';
      } else if (e.toString().contains('network')) {
        _error = 'Please check your internet connection and try again.';
      } else {
        _error = 'Failed to load bookings. Please try again later.';
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ServiceProviderModel> getProvidersForService(String serviceId) {
    print('Getting providers for service ID: $serviceId');
    print('Total providers available: ${_serviceProviders.length}');
    
    // First, get the service to find its provider_id
    final service = _services.firstWhere(
      (s) => s.id == serviceId,
      orElse: () => throw Exception('Service not found'),
    );
    
    print('Found service: ${service.title} with provider ID: ${service.providerId}');
    
    // Then find providers that match the service's provider_id
    final providers = _serviceProviders
        .where((provider) {
          print('Checking provider: ${provider.name}');
          print('Provider ID: ${provider.id}');
          final matches = provider.id == service.providerId;
          print('Matches service provider ID: $matches');
          return matches;
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
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Creating new booking...');
      print('Provider ID: $providerId');
      print('Service ID: $serviceId');
      print('Pet ID: $petId');
      print('Date/Time: $dateTime');
      print('Amount: $amount');
      print('Notes: $notes');

      // Format the date and time according to the database schema
      final bookingDate = dateTime.toIso8601String().split('T')[0];
      final bookingTime = dateTime.toIso8601String().split('T')[1].substring(0, 5);

      // Get the current user ID
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      // Create the booking data with proper types
      final bookingData = {
        'user_id': userId,
        'provider_id': providerId,
        'service_id': serviceId,
        'pet_id': petId,
        'booking_date': bookingDate,
        'booking_time': bookingTime,
        'status': 'pending',
        'payment_status': 'pending',
        'amount': amount,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('Booking data to insert: $bookingData');

      // Verify the provider exists
      try {
        final provider = await _supabase
            .from('service_providers')
            .select()
            .eq('id', providerId)
            .single();
        print('Found provider: ${provider['name']}');
      } catch (e) {
        print('Error verifying provider: $e');
        throw Exception('Invalid service provider');
      }

      // Verify the service exists
      try {
        final service = await _supabase
            .from('services')
            .select()
            .eq('id', serviceId)
            .single();
        print('Found service: ${service['name']}');
      } catch (e) {
        print('Error verifying service: $e');
        throw Exception('Invalid service');
      }

      // Verify the pet exists and belongs to the user
      try {
        final pet = await _supabase
            .from('pets')
            .select()
            .eq('id', petId)
            .eq('owner_id', userId)
            .single();
        print('Found pet: ${pet['name']}');
      } catch (e) {
        print('Error verifying pet: $e');
        throw Exception('Invalid pet or pet does not belong to you');
      }

      // Create the booking
      print('Inserting booking into database...');
      final response = await _supabase
          .from('bookings')
          .insert(bookingData)
          .select()
          .single();

      print('Booking created successfully: ${response['id']}');
      print('Full booking response: $response');

      // Refresh the bookings list
      await loadBookings();
    } catch (e) {
      print('Error creating booking: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
        _error = 'Unable to connect to the server. Please check your internet connection.';
      } else {
        _error = 'Failed to create booking. Please try again later.';
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Updating booking status...');
      print('Booking ID: $bookingId');
      print('New status: $status');

      await _supabase.from('bookings').update({
        'status': status.toString(),
      }).eq('id', bookingId).select().single();

      print('Booking status updated successfully');
      
      // Refresh the bookings list
      await loadBookings();
    } catch (e) {
      print('Error updating booking status: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
        _error = 'Unable to connect to the server. Please check your internet connection.';
      } else {
        _error = 'Failed to update booking status. Please try again later.';
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePaymentStatus(String bookingId, PaymentStatus status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Updating payment status...');
      print('Booking ID: $bookingId');
      print('New status: $status');

      await _supabase.from('bookings').update({
        'payment_status': status.toString().split('.').last,
      }).eq('id', bookingId).select().single();

      print('Payment status updated successfully');
      
      // Refresh the bookings list
      await loadBookings();
    } catch (e) {
      print('Error updating payment status: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
        _error = 'Unable to connect to the server. Please check your internet connection.';
      } else {
        _error = 'Failed to update payment status. Please try again later.';
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Cancelling booking...');
      print('Booking ID: $bookingId');

      await _supabase.from('bookings').delete().eq('id', bookingId);

      print('Booking cancelled successfully');
      
      // Refresh the bookings list
      await loadBookings();
    } catch (e) {
      print('Error cancelling booking: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
        _error = 'Unable to connect to the server. Please check your internet connection.';
      } else {
        _error = 'Failed to cancel booking. Please try again later.';
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  // Add this method for backward compatibility
  Future<void> loadServices() async {
    await _initialize();
  }
} 
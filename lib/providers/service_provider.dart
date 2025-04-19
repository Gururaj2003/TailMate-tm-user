import 'package:flutter/foundation.dart';
import 'package:tailmate/models/booking.dart';
import 'package:tailmate/models/service.dart';
import 'package:tailmate/models/service_provider_model.dart';
import 'package:uuid/uuid.dart';

class ServiceProvider with ChangeNotifier {
  final List<Service> _services = [
    Service(
      id: '1',
      title: 'Pet Walking',
      description: 'Professional dog walking service. We ensure your pet gets the exercise they need.',
      price: 25.0,
      imageUrl: '',
      category: 'Walking',
      duration: const Duration(minutes: 30),
    ),
    Service(
      id: '2',
      title: 'Pet Sitting',
      description: 'In-home pet sitting service. We take care of your pet while you\'re away.',
      price: 45.0,
      imageUrl: '',
      category: 'Sitting',
      duration: const Duration(hours: 4),
    ),
    Service(
      id: '3',
      title: 'Grooming',
      description: 'Professional grooming service including bath, haircut, and nail trimming.',
      price: 55.0,
      imageUrl: '',
      category: 'Grooming',
      duration: const Duration(hours: 2),
    ),
    Service(
      id: '4',
      title: 'Vet Visit',
      description: 'Regular check-up and vaccination service with our partner veterinarians.',
      price: 75.0,
      imageUrl: '',
      category: 'Healthcare',
      duration: const Duration(hours: 1),
    ),
  ];

  final List<ServiceProviderModel> _serviceProviders = [
    ServiceProviderModel(
      id: '1',
      name: 'Happy Paws Services',
      description: 'Professional pet care services with over 5 years of experience.',
      rating: 4.8,
      reviewCount: 156,
      serviceIds: ['1', '2'],
      imageUrl: '',
      location: 'Downtown',
      priceMultiplier: 1.0,
      specialties: ['Dogs', 'Cats'],
    ),
    ServiceProviderModel(
      id: '2',
      name: 'Pawsome Groomers',
      description: 'Expert grooming services for all breeds. Certified professional groomers.',
      rating: 4.9,
      reviewCount: 203,
      serviceIds: ['3'],
      imageUrl: '',
      location: 'Westside',
      priceMultiplier: 1.2,
      specialties: ['All Breeds', 'Show Grooming'],
    ),
    ServiceProviderModel(
      id: '3',
      name: 'Dr. Smith\'s Veterinary Clinic',
      description: 'Full-service veterinary clinic with emergency care available.',
      rating: 4.7,
      reviewCount: 312,
      serviceIds: ['4'],
      imageUrl: '',
      location: 'Eastside',
      priceMultiplier: 1.1,
      specialties: ['Emergency Care', 'Surgery', 'Dental'],
    ),
    ServiceProviderModel(
      id: '4',
      name: 'Elite Pet Care',
      description: 'Premium pet sitting and walking services. Insured and bonded.',
      rating: 4.6,
      reviewCount: 89,
      serviceIds: ['1', '2'],
      imageUrl: '',
      location: 'Northside',
      priceMultiplier: 1.3,
      specialties: ['Luxury Care', 'Overnight Stays'],
    ),
    ServiceProviderModel(
      id: '5',
      name: 'Gentle Touch Grooming',
      description: 'Specialized in handling anxious and senior pets. Calm environment.',
      rating: 4.9,
      reviewCount: 167,
      serviceIds: ['3'],
      imageUrl: '',
      location: 'Southside',
      priceMultiplier: 1.1,
      specialties: ['Senior Pets', 'Anxious Pets'],
    ),
  ];

  final List<Booking> _bookings = [];

  List<Service> get services => List.unmodifiable(_services);
  List<ServiceProviderModel> get serviceProviders => List.unmodifiable(_serviceProviders);
  List<Booking> get bookings => List.unmodifiable(_bookings);

  List<ServiceProviderModel> getProvidersForService(String serviceId) {
    return _serviceProviders
        .where((provider) => provider.serviceIds.contains(serviceId))
        .toList();
  }

  List<Booking> getBookingsByStatus(BookingStatus status) {
    return _bookings.where((booking) => booking.status == status).toList();
  }

  void addBooking(Booking booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  void updateBookingStatus(String bookingId, BookingStatus newStatus) {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index >= 0) {
      _bookings[index] = _bookings[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  void cancelBooking(String bookingId) {
    updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  Service getServiceById(String id) {
    return _services.firstWhere((service) => service.id == id);
  }

  ServiceProviderModel getProviderById(String id) {
    return _serviceProviders.firstWhere((provider) => provider.id == id);
  }

  List<Booking> getBookingsForPet(String petId) {
    return _bookings.where((booking) => booking.pet.id == petId).toList();
  }
} 
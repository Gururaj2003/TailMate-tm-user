class ServiceProvider {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final double rating;
  final int totalRatings;
  final bool isVerified;
  final List<String> specialties;
  final String description;
  final double priceMultiplier;
  final String location;
  final List<String> serviceIds;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.rating,
    required this.totalRatings,
    required this.isVerified,
    required this.specialties,
    required this.description,
    required this.priceMultiplier,
    required this.location,
    required this.serviceIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'rating': rating,
      'total_ratings': totalRatings,
      'is_verified': isVerified,
      'specialties': specialties,
      'description': description,
      'price_multiplier': priceMultiplier,
      'location': location,
      'service_ids': serviceIds,
    };
  }

  factory ServiceProvider.fromMap(Map<String, dynamic> map) {
    print('Creating ServiceProvider from map: $map');
    try {
      final provider = ServiceProvider(
        id: map['id'] as String,
        name: map['name'] as String,
        email: map['email'] as String,
        phone: map['phone'] as String,
        address: map['address'] as String,
        rating: (map['rating'] as num).toDouble(),
        totalRatings: map['total_ratings'] as int,
        isVerified: map['is_verified'] as bool,
        specialties: List<String>.from(map['specialties'] ?? []),
        description: map['description'] as String,
        priceMultiplier: (map['price_multiplier'] as num).toDouble(),
        location: map['location'] as String,
        serviceIds: List<String>.from(map['service_ids'] ?? []),
      );
      print('Created provider: ${provider.name} (ID: ${provider.id})');
      return provider;
    } catch (e) {
      print('Error creating ServiceProvider: $e');
      print('Map data: $map');
      rethrow;
    }
  }
} 
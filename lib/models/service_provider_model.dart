class ServiceProviderModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String address;
  final double? latitude;
  final double? longitude;
  final double rating;
  final int totalRatings;
  final String? profileImage;
  final bool isVerified;
  final List<String> serviceIds;
  final List<String> specialties;
  final String description;
  final double priceMultiplier;
  final String location;

  ServiceProviderModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.address,
    this.latitude,
    this.longitude,
    required this.rating,
    required this.totalRatings,
    this.profileImage,
    required this.isVerified,
    required this.serviceIds,
    required this.specialties,
    required this.description,
    required this.priceMultiplier,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'total_ratings': totalRatings,
      'profile_image': profileImage,
      'is_verified': isVerified,
      'service_ids': serviceIds,
      'specialties': specialties,
      'description': description,
      'price_multiplier': priceMultiplier,
      'location': location,
    };
  }

  factory ServiceProviderModel.fromMap(Map<String, dynamic> map) {
    print('Creating ServiceProviderModel from map: $map');
    try {
      final serviceIds = (map['service_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      print('Raw service_ids from map: ${map['service_ids']}');
      print('Processed service IDs: $serviceIds');
      
      return ServiceProviderModel(
        id: map['id'] as String,
        name: map['name'] as String,
        email: map['email'] as String,
        phone: map['phone'] as String?,
        address: map['address'] as String? ?? '',
        latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
        longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
        rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
        totalRatings: (map['total_ratings'] as num?)?.toInt() ?? 0,
        profileImage: map['profile_image'] as String?,
        isVerified: map['is_verified'] as bool? ?? false,
        serviceIds: serviceIds,
        specialties: (map['specialties'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        description: map['description'] as String? ?? '',
        priceMultiplier: (map['price_multiplier'] as num?)?.toDouble() ?? 1.0,
        location: map['location'] as String? ?? '',
      );
    } catch (e) {
      print('Error creating ServiceProviderModel: $e');
      print('Map data: $map');
      rethrow;
    }
  }
} 
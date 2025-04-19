class ServiceProviderModel {
  final String id;
  final String name;
  final String description;
  final double rating;
  final int reviewCount;
  final List<String> serviceIds;
  final String imageUrl;
  final String location;
  final double priceMultiplier;
  final bool isAvailable;
  final List<String> specialties;

  ServiceProviderModel({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.serviceIds,
    required this.imageUrl,
    required this.location,
    required this.priceMultiplier,
    this.isAvailable = true,
    required this.specialties,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rating': rating,
      'reviewCount': reviewCount,
      'serviceIds': serviceIds,
      'imageUrl': imageUrl,
      'location': location,
      'priceMultiplier': priceMultiplier,
      'isAvailable': isAvailable,
      'specialties': specialties,
    };
  }

  factory ServiceProviderModel.fromMap(Map<String, dynamic> map) {
    return ServiceProviderModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      rating: map['rating'],
      reviewCount: map['reviewCount'],
      serviceIds: List<String>.from(map['serviceIds']),
      imageUrl: map['imageUrl'],
      location: map['location'],
      priceMultiplier: map['priceMultiplier'],
      isAvailable: map['isAvailable'] ?? true,
      specialties: List<String>.from(map['specialties']),
    );
  }
} 
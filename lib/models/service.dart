class Service {
  final String id;
  final String title;
  final String description;
  final double price;
  final String? imageUrl;
  final String category;
  final Duration duration;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': title,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'duration': duration.inMinutes,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    print('Creating Service from map: $map');
    try {
      final service = Service(
        id: map['id'] as String,
        title: map['name'] as String,
        description: map['description'] as String,
        price: (map['price'] as num).toDouble(),
        imageUrl: map['image_url'] as String?,
        category: map['category'] as String,
        duration: Duration(minutes: (map['duration'] as num).toInt()),
      );
      print('Created service: ${service.title} (ID: ${service.id})');
      return service;
    } catch (e) {
      print('Error creating Service: $e');
      print('Map data: $map');
      rethrow;
    }
  }
} 
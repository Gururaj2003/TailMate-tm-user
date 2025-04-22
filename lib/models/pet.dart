class Pet {
  final String id;
  final String name;
  final String species;
  final String? breed;
  final DateTime? birthDate;
  final double? weight;
  final String? gender;
  String? imageUrl;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.birthDate,
    this.weight,
    this.gender,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'birth_date': birthDate?.toIso8601String(),
      'weight': weight,
      'gender': gender,
      'image_url': imageUrl,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    print('Creating Pet from map: $map');
    try {
      return Pet(
        id: map['id'] as String,
        name: map['name'] as String,
        species: map['species'] as String,
        breed: map['breed'] as String?,
        birthDate: map['birth_date'] != null ? DateTime.parse(map['birth_date']) : null,
        weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
        gender: map['gender'] as String?,
        imageUrl: map['image_url'] as String?,
      );
    } catch (e) {
      print('Error creating Pet: $e');
      print('Map data: $map');
      rethrow;
    }
  }

  Pet copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    DateTime? birthDate,
    double? weight,
    String? gender,
    String? imageUrl,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
} 
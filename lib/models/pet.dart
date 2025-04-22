class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final DateTime birthDate;
  final double weight;
  final String gender;
  String? imageUrl;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.birthDate,
    required this.weight,
    required this.gender,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'birth_date': birthDate.toIso8601String(),
      'weight': weight,
      'gender': gender,
      'image_url': imageUrl,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'],
      name: map['name'],
      species: map['species'],
      breed: map['breed'],
      birthDate: DateTime.parse(map['birth_date']),
      weight: map['weight'],
      gender: map['gender'],
      imageUrl: map['image_url'],
    );
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
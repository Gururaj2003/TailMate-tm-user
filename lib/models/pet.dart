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
      'birthDate': birthDate.toIso8601String(),
      'weight': weight,
      'gender': gender,
      'imageUrl': imageUrl,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'],
      name: map['name'],
      species: map['species'],
      breed: map['breed'],
      birthDate: DateTime.parse(map['birthDate']),
      weight: map['weight'],
      gender: map['gender'],
      imageUrl: map['imageUrl'],
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
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
    );
  }
} 
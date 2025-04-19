import 'package:flutter/foundation.dart';
import '../models/pet.dart';

class PetProvider with ChangeNotifier {
  List<Pet> _pets = [];

  List<Pet> get pets => [..._pets];

  void addPet(Pet pet) {
    _pets.add(pet);
    notifyListeners();
  }

  void updatePet(Pet pet) {
    final index = _pets.indexWhere((p) => p.id == pet.id);
    if (index >= 0) {
      _pets[index] = pet;
      notifyListeners();
    }
  }

  void deletePet(String id) {
    _pets.removeWhere((pet) => pet.id == id);
    notifyListeners();
  }

  Pet? getPetById(String id) {
    try {
      return _pets.firstWhere((pet) => pet.id == id);
    } catch (e) {
      return null;
    }
  }
} 
import 'package:flutter/foundation.dart';
import '../models/pet.dart';
import '../services/supabase_service.dart';

class PetProvider with ChangeNotifier {
  List<Pet> _pets = [];
  final SupabaseService _supabaseService = SupabaseService();

  List<Pet> get pets => [..._pets];

  Future<void> loadPets() async {
    try {
      print('Loading pets from Supabase');
      final petsData = await _supabaseService.getPets();
      _pets = petsData.map((petData) => Pet.fromMap(petData)).toList();
      print('Loaded ${_pets.length} pets');
      notifyListeners();
    } catch (e) {
      print('Error loading pets: $e');
      rethrow;
    }
  }

  Future<void> addPet({
    required String name,
    required String species,
    String? breed,
    DateTime? birthDate,
    double? weight,
    String? gender,
    String? imageUrl,
  }) async {
    try {
      print('Adding new pet to Supabase');
      final petData = await _supabaseService.addPet(
        name: name,
        species: species,
        breed: breed,
        birthDate: birthDate,
        weight: weight,
        gender: gender,
        imageUrl: imageUrl,
      );
      final newPet = Pet.fromMap(petData);
      _pets.add(newPet);
      print('Added new pet: ${newPet.name}');
      notifyListeners();
    } catch (e) {
      print('Error adding pet: $e');
      rethrow;
    }
  }

  Future<void> updatePet(Pet pet) async {
    try {
      print('Updating pet in Supabase');
      final petData = await _supabaseService.updatePet(
        petId: pet.id,
        name: pet.name,
        species: pet.species,
        breed: pet.breed,
        birthDate: pet.birthDate,
        weight: pet.weight,
        gender: pet.gender,
        imageUrl: pet.imageUrl,
      );
      final updatedPet = Pet.fromMap(petData);
      final index = _pets.indexWhere((p) => p.id == updatedPet.id);
      if (index >= 0) {
        _pets[index] = updatedPet;
        print('Updated pet: ${updatedPet.name}');
        notifyListeners();
      }
    } catch (e) {
      print('Error updating pet: $e');
      rethrow;
    }
  }

  Future<void> deletePet(String id) async {
    try {
      print('Deleting pet from Supabase');
      await _supabaseService.deletePet(id);
      _pets.removeWhere((pet) => pet.id == id);
      print('Deleted pet with ID: $id');
      notifyListeners();
    } catch (e) {
      print('Error deleting pet: $e');
      rethrow;
    }
  }

  Pet? getPetById(String id) {
    try {
      return _pets.firstWhere((pet) => pet.id == id);
    } catch (e) {
      return null;
    }
  }
} 
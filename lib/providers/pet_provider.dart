import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet.dart';

class PetProvider extends ChangeNotifier {
  final SupabaseClient _supabase;
  List<Pet> _pets = [];
  bool _isLoading = false;
  String? _error;

  PetProvider(this._supabase) {
    _initialize();
  }

  List<Pet> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      print('Fetching pets from Supabase...');
      final response = await _supabase
          .from('pets')
          .select()
          .order('created_at', ascending: false);

      print('Raw response from Supabase: $response');
      
      if (response != null) {
        _pets = (response as List)
            .map((data) => Pet.fromMap(data as Map<String, dynamic>))
            .toList();
        print('Successfully loaded ${_pets.length} pets');
      } else {
        print('No pets found in the database');
        _pets = [];
      }
    } catch (e) {
      print('Error initializing pets: $e');
      _error = e.toString();
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
        _error = 'Database error: ${e.message}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPet(Pet pet) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('Adding new pet to Supabase...');
      print('Pet data: ${pet.toMap()}');

      final response = await _supabase
          .from('pets')
          .insert(pet.toMap())
          .select()
          .single();

      print('Supabase response: $response');

      if (response != null) {
        final newPet = Pet.fromMap(response as Map<String, dynamic>);
        _pets.add(newPet);
        print('Successfully added pet: ${newPet.name}');
      } else {
        throw Exception('Failed to add pet: No response from server');
      }
    } catch (e) {
      print('Error adding pet: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
        throw Exception('Database error: ${e.message}');
      }
      throw Exception('Failed to add pet: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePet(Pet pet) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('Updating pet in Supabase...');
      print('Pet data: ${pet.toMap()}');

      final response = await _supabase
          .from('pets')
          .update(pet.toMap())
          .eq('id', pet.id)
          .select()
          .single();

      print('Supabase response: $response');

      if (response != null) {
        final updatedPet = Pet.fromMap(response as Map<String, dynamic>);
        final index = _pets.indexWhere((p) => p.id == pet.id);
        if (index != -1) {
          _pets[index] = updatedPet;
          print('Successfully updated pet: ${updatedPet.name}');
        }
      } else {
        throw Exception('Failed to update pet: No response from server');
      }
    } catch (e) {
      print('Error updating pet: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
        throw Exception('Database error: ${e.message}');
      }
      throw Exception('Failed to update pet: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePet(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('Deleting pet from Supabase...');
      print('Pet ID: $id');

      await _supabase.from('pets').delete().eq('id', id);
      _pets.removeWhere((pet) => pet.id == id);
      
      print('Successfully deleted pet with ID: $id');
    } catch (e) {
      print('Error deleting pet: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
        throw Exception('Database error: ${e.message}');
      }
      throw Exception('Failed to delete pet: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Pet? getPetById(String id) {
    try {
      return _pets.firstWhere((pet) => pet.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadPets() async {
    await _initialize();
  }
} 
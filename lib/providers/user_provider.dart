import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailmate/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:tailmate/models/user_model.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String? phoneNumber;
  final String? address;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.phoneNumber,
    this.address,
  });

  factory User.fromSupabase(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      profileImage: data['profile_image'],
      phoneNumber: data['phone_number'],
      address: data['address'],
    );
  }
}

class UserProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isEmailVerified => _supabaseService.isEmailVerified;

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabaseService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (response.user != null) {
        // Get the latest user data to check verification status
        final refreshedUser = await _supabaseService.getCurrentUser();
        if (refreshedUser?.emailConfirmedAt == null) {
          _error = 'Please verify your email before signing in. Check your inbox for the verification link.';
          notifyListeners();
          return false;
        }

        final profile = await _supabaseService.getUserProfile();
        if (profile != null) {
          _currentUser = UserModel.fromJson(profile);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      print('Starting registration process...');
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Calling SupabaseService.registerWithEmailAndPassword...');
      final response = await _supabaseService.registerWithEmailAndPassword(
        email,
        password,
        name,
      );

      print('Registration response received: ${response.user != null}');
      if (response.user != null) {
        print('Registration successful, user created');
        print('Verification email has been sent to $email');
        return true;
      }
      print('Registration failed, no user created');
      _error = 'Registration failed. Please try again.';
      notifyListeners();
      return false;
    } catch (e) {
      print('Error during registration: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _supabaseService.signInWithGoogle();
      if (success) {
        final profile = await _supabaseService.getUserProfile();
        if (profile != null) {
          _currentUser = UserModel.fromJson(profile);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabaseService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? address,
    String? profileImage,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabaseService.updateUserProfile(
        name: name,
        phoneNumber: phoneNumber,
        address: address,
        profileImage: profileImage,
      );

      final profile = await _supabaseService.getUserProfile();
      if (profile != null) {
        _currentUser = UserModel.fromJson(profile);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabaseService.resendVerificationEmail(email);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailmate/services/supabase_service.dart';
import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String? phoneNumber;
  final String? address;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.phoneNumber,
    this.address,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profile_image'],
      phoneNumber: json['phone_number'],
      address: json['address'],
    );
  }
}

class UserProvider extends ChangeNotifier {
  final SupabaseClient _supabase;
  User? _currentUser;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  UserProvider(this._supabase) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _supabase.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;
        
        if (event == AuthChangeEvent.signedIn) {
          _currentUser = session?.user;
          _loadUserProfile();
        } else if (event == AuthChangeEvent.signedOut) {
          _currentUser = null;
          _userProfile = null;
          notifyListeners();
        }
      });

      // Check for existing session
      final session = _supabase.auth.currentSession;
      if (session != null) {
        _currentUser = session.user;
        await _loadUserProfile();
      }
    } catch (e) {
      print('Error initializing UserProvider: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      if (_currentUser == null) return;
      
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', _currentUser!.id)
          .single();
      
      _userProfile = UserProfile.fromJson(response);
      notifyListeners();
    } catch (e) {
      print('Error loading user profile: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  // Getters
  User? get currentUser => _currentUser;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isEmailVerified => _currentUser?.emailConfirmedAt != null;

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Failed to sign in. Please check your credentials.');
      }

      _currentUser = response.user;
      await _loadUserProfile();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Register with email and password
  Future<bool> register(String email, String password, String name) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user == null) {
        throw Exception('Failed to create account. Please try again.');
      }

      _currentUser = response.user;
      await _loadUserProfile();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.tailmate://login-callback/',
      );

      if (response == null) {
        throw Exception('Failed to sign in with Google.');
      }

      _currentUser = _supabase.auth.currentUser;
      await _loadUserProfile();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.signOut();
      _currentUser = null;
      _userProfile = null;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update user profile
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

      if (_currentUser == null) {
        throw Exception('No user logged in');
      }

      final updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (address != null) updates['address'] = address;
      if (profileImage != null) updates['profile_image'] = profileImage;

      await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', _currentUser!.id);

      await _loadUserProfile();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Resend verification email
  Future<bool> resendVerificationEmail(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: 'io.supabase.tailmate://login-callback/verification',
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 
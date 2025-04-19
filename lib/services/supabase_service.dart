import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Check if user is verified
  bool get isEmailVerified => _supabase.auth.currentUser?.emailConfirmedAt != null;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      print('Attempting to sign in user: $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Failed to sign in. Please check your credentials.');
      }

      // Check if email is verified
      if (response.user?.emailConfirmedAt == null) {
        print('User email not verified: ${response.user!.email}');
        // Sign out the user since they're not verified
        await _supabase.auth.signOut();
        throw Exception('Please verify your email before signing in. Check your inbox for the verification link.');
      }

      // Try to get the user's profile
      try {
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .single();
        print('Found existing profile');
      } catch (e) {
        print('Profile not found, creating new profile');
        // If profile doesn't exist, create one
        try {
          await _supabase.from('profiles').upsert({
            'id': response.user!.id,
            'email': response.user!.email,
            'name': response.user!.userMetadata?['name'] ?? response.user!.email?.split('@')[0],
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          print('Created new profile for user');
        } catch (profileError) {
          print('Error creating profile: $profileError');
          // Don't throw here, allow login even if profile creation fails
        }
      }
      
      print('Sign in successful for user: ${response.user!.email}');
      return response;
    } on AuthException catch (e) {
      print('Auth error during sign in: ${e.message}');
      if (e.message.contains('Invalid login credentials')) {
        throw Exception('Invalid email or password. Please try again.');
      } else if (e.message.contains('Email not confirmed')) {
        throw Exception('Please verify your email before signing in. Check your inbox for the verification link.');
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      print('Error during sign in: $e');
      throw Exception('An error occurred during sign in. Please try again.');
    }
  }

  // Register with email and password
  Future<AuthResponse> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      print('Starting registration process for $email');
      
      // First, create the user in Supabase Auth
      print('Creating user in Supabase Auth...');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
        emailRedirectTo: 'io.supabase.tailmate://login-callback/verification'
      );

      print('Auth signup response received: ${response.user != null}');
      if (response.user == null) {
        print('Failed to create user account');
        throw Exception('Failed to create user account. Please try again.');
      }

      print('Auth signup successful for user: ${response.user!.email}');
      
      // Then create the profile in the profiles table
      print('Creating user profile in database...');
      try {
        final profileResponse = await _supabase.from('profiles').upsert({
          'id': response.user!.id,
          'name': name,
          'email': email,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }).select();

        print('Profile creation response: $profileResponse');
        
        if (profileResponse.isEmpty) {
          print('Failed to create profile');
          throw Exception('Failed to create user profile. Please try again.');
        }

        print('Profile created successfully');
        print('Registration process completed successfully');
        print('Verification email has been sent to $email');
        return response;
      } catch (e) {
        print('Error creating profile: $e');
        // If profile creation fails, we should still return the auth response
        // since the user was created successfully
        return response;
      }
    } on AuthException catch (e) {
      print('Auth error during registration: ${e.message}');
      if (e.message.contains('already registered')) {
        throw Exception('This email is already registered. Please try logging in instead.');
      } else if (e.message.contains('password')) {
        throw Exception('Password must be at least 6 characters long.');
      } else if (e.message.contains('email')) {
        throw Exception('Please enter a valid email address.');
      } else {
        throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      print('Error during registration: $e');
      throw Exception('An error occurred during registration. Please try again.');
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: 'io.supabase.tailmate://login-callback/verification'
      );
      print('Verification email resent to: $email');
    } catch (e) {
      print('Error resending verification email: $e');
      throw Exception('Failed to resend verification email. Please try again.');
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.tailmate://login-callback/',
      );
      return response;
    } on AuthException catch (e) {
      print('Auth error during Google sign in: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('Error during Google sign in: $e');
      throw Exception('An error occurred during Google sign in. Please try again.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Error during sign out: $e');
      throw Exception('An error occurred during sign out. Please try again.');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? address,
    String? profileImage,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('No user logged in');

      final updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (address != null) updates['address'] = address;
      if (profileImage != null) updates['profile_image'] = profileImage;

      final response = await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select();

      if (response.isEmpty) {
        throw Exception('Failed to update profile');
      }
      
      print('Profile updated successfully');
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('An error occurred while updating your profile. Please try again.');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('No user logged in');

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      print('Profile retrieved successfully');
      return response;
    } catch (e) {
      print('Error getting profile: $e');
      throw Exception('An error occurred while retrieving your profile. Please try again.');
    }
  }

  // Get current user data
  Future<User?> getCurrentUser() async {
    try {
      final response = await _supabase.auth.getUser();
      return response.user;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Get all pets for current user
  Future<List<Map<String, dynamic>>> getPets() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('No user logged in');

      final response = await _supabase
          .from('pets')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      print('Retrieved ${response.length} pets');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting pets: $e');
      throw Exception('An error occurred while retrieving your pets. Please try again.');
    }
  }

  // List all pets for current user
  Future<List<Map<String, dynamic>>> listPets() async {
    try {
      print('Fetching all pets for current user');
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('Error: No user logged in');
        throw Exception('No user logged in');
      }
      print('Current user ID: $userId');

      final response = await _supabase
          .from('pets')
          .select('*')
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      print('Found ${response.length} pets');
      for (var pet in response) {
        print('Pet: ${pet['name']} (ID: ${pet['id']})');
      }
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error listing pets: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
      }
      throw Exception('An error occurred while fetching your pets. Please try again.');
    }
  }

  // Add a new pet
  Future<Map<String, dynamic>> addPet({
    required String name,
    required String type,
    String? breed,
    int? age,
    double? weight,
    String? gender,
    String? color,
    String? medicalHistory,
    String? specialInstructions,
    String? profileImage,
  }) async {
    try {
      print('Starting to add new pet: $name');
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('Error: No user logged in');
        throw Exception('No user logged in');
      }
      print('Current user ID: $userId');

      // First verify the user has a profile
      try {
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', userId)
            .single();
        print('Found user profile: ${profile['name']}');
      } catch (e) {
        print('Error finding user profile: $e');
        // Create a basic profile if it doesn't exist
        try {
          final user = _supabase.auth.currentUser;
          await _supabase.from('profiles').insert({
            'id': userId,
            'email': user?.email,
            'name': user?.userMetadata?['name'] ?? user?.email?.split('@')[0],
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          print('Created new profile for user');
        } catch (profileError) {
          print('Error creating profile: $profileError');
          throw Exception('Failed to create user profile. Please try again.');
        }
      }

      final pet = {
        'owner_id': userId,
        'name': name,
        'type': type,
        'breed': breed,
        'age': age,
        'weight': weight,
        'gender': gender,
        'color': color,
        'medical_history': medicalHistory,
        'special_instructions': specialInstructions,
        'profile_image': profileImage,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('Pet data to insert: $pet');

      // First insert without select to verify the insert works
      await _supabase.from('pets').insert(pet);
      print('Pet inserted successfully');

      // Then fetch the inserted pet
      final response = await _supabase
          .from('pets')
          .select()
          .eq('owner_id', userId)
          .eq('name', name)
          .single();

      print('Successfully added new pet: ${response['name']} (ID: ${response['id']})');
      return response;
    } catch (e) {
      print('Error adding pet: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
      }
      throw Exception('An error occurred while adding your pet. Please try again.');
    }
  }

  // Update a pet
  Future<Map<String, dynamic>> updatePet({
    required String petId,
    String? name,
    String? type,
    String? breed,
    int? age,
    double? weight,
    String? gender,
    String? color,
    String? medicalHistory,
    String? specialInstructions,
    String? profileImage,
  }) async {
    try {
      print('Starting pet update for ID: $petId');
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('No user logged in');
        throw Exception('No user logged in');
      }
      print('Current user ID: $userId');

      final updates = {
        if (name != null) 'name': name,
        if (type != null) 'type': type,
        if (breed != null) 'breed': breed,
        if (age != null) 'age': age,
        if (weight != null) 'weight': weight,
        if (gender != null) 'gender': gender,
        if (color != null) 'color': color,
        if (medicalHistory != null) 'medical_history': medicalHistory,
        if (specialInstructions != null) 'special_instructions': specialInstructions,
        if (profileImage != null) 'profile_image': profileImage,
      };

      print('Update data: $updates');

      // First verify the pet exists and belongs to the user
      final existingPet = await _supabase
          .from('pets')
          .select()
          .eq('id', petId)
          .eq('owner_id', userId)
          .single();

      print('Found existing pet: ${existingPet['name']}');

      // Perform the update
      final response = await _supabase
          .from('pets')
          .update(updates)
          .eq('id', petId)
          .eq('owner_id', userId)
          .select()
          .single();

      print('Update successful. Updated pet: ${response['name']}');
      return response;
    } catch (e) {
      print('Error updating pet: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
      }
      throw Exception('An error occurred while updating your pet. Please try again.');
    }
  }

  // Delete a pet
  Future<void> deletePet(String petId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('No user logged in');

      await _supabase
          .from('pets')
          .delete()
          .eq('id', petId)
          .eq('owner_id', userId);

      print('Deleted pet with ID: $petId');
    } catch (e) {
      print('Error deleting pet: $e');
      throw Exception('An error occurred while deleting your pet. Please try again.');
    }
  }
} 
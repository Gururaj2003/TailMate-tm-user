import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailmate/models/booking.dart';
import 'package:tailmate/models/service_provider.dart';

class SupabaseService {
  final SupabaseClient _supabase;

  SupabaseService(this._supabase);

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
    print('Attempting to sign in user: $email');
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    print('Sign in response: ${response.user?.id}');
    return response;
  }

  // Register with email and password
  Future<AuthResponse> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
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

      final response = await _supabase.from('profiles')
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

      final response = await _supabase.from('profiles')
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
      print('Starting to fetch pets');
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('Error: No user logged in');
        throw Exception('No user logged in');
      }
      print('Current user ID: $userId');

      final response = await _supabase.from('pets')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      print('Retrieved ${response.length} pets');
      for (var pet in response) {
        print('Pet: ${pet['name']} (ID: ${pet['id']})');
      }
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting pets: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
      }
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

      final response = await _supabase.from('pets')
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
    required String species,
    String? breed,
    DateTime? birthDate,
    double? weight,
    String? gender,
    String? imageUrl,
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
        final profile = await _supabase.from('profiles')
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
        'species': species,
        'breed': breed,
        'birth_date': birthDate?.toIso8601String(),
        'weight': weight,
        'gender': gender,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('Pet data to insert: $pet');

      // First insert without select to verify the insert works
      final insertResponse = await _supabase.from('pets').insert(pet);
      print('Insert response: $insertResponse');

      // Then fetch the inserted pet
      final response = await _supabase.from('pets')
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
    String? species,
    String? breed,
    DateTime? birthDate,
    double? weight,
    String? gender,
    String? imageUrl,
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
        if (species != null) 'species': species,
        if (breed != null) 'breed': breed,
        if (birthDate != null) 'birth_date': birthDate.toIso8601String(),
        if (weight != null) 'weight': weight,
        if (gender != null) 'gender': gender,
        if (imageUrl != null) 'image_url': imageUrl,
      };

      print('Update data: $updates');

      // First verify the pet exists and belongs to the user
      final existingPet = await _supabase.from('pets')
          .select()
          .eq('id', petId)
          .eq('owner_id', userId)
          .single();

      print('Found existing pet: ${existingPet['name']}');

      // Perform the update
      final response = await _supabase.from('pets')
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

      await _supabase.from('pets')
          .delete()
          .eq('id', petId)
          .eq('owner_id', userId);

      print('Deleted pet with ID: $petId');
    } catch (e) {
      print('Error deleting pet: $e');
      throw Exception('An error occurred while deleting your pet. Please try again.');
    }
  }

  // Service Provider Operations
  Future<List<Map<String, dynamic>>> getServiceProviders() async {
    print('Fetching service providers from Supabase...');
    try {
      // Check if Supabase client is initialized
      if (_supabase == null) {
        print('Error: Supabase client is not initialized');
        throw Exception('Unable to connect to the server. Please try again later.');
      }

      // Check internet connection
      try {
        print('Checking database connection...');
        await _supabase.from('service_providers').select('count').limit(1);
        print('Database connection successful');
      } catch (e) {
        print('Error connecting to database: $e');
        throw Exception('Unable to connect to the server. Please check your internet connection.');
      }

      final response = await _supabase.from('service_providers')
          .select('*')
          .order('name');
          
      print('Successfully fetched ${response.length} service providers');
      print('First provider data: ${response.isNotEmpty ? response.first : 'No providers found'}');
      return response;
    } catch (e) {
      print('Error fetching service providers: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
        throw Exception('Unable to connect to the server. Please check your internet connection.');
      } else {
        throw Exception('Failed to fetch service providers. Please try again later.');
      }
    }
  }

  Future<Map<String, dynamic>> getServiceProvider(String providerId) async {
    try {
      final response = await _supabase.from('service_providers')
          .select()
          .eq('id', providerId)
          .single();
      return response;
    } catch (e) {
      print('Error getting service provider: $e');
      throw Exception('Failed to fetch service provider details');
    }
  }

  // Services Operations
  Future<List<Map<String, dynamic>>> getServices() async {
    print('Fetching services from Supabase...');
    try {
      // Check if Supabase client is initialized
      if (_supabase == null) {
        print('Error: Supabase client is not initialized');
        throw Exception('Unable to connect to the server. Please try again later.');
      }

      // Check internet connection
      try {
        print('Checking database connection...');
        await _supabase.from('services').select('count').limit(1);
        print('Database connection successful');
      } catch (e) {
        print('Error connecting to database: $e');
        throw Exception('Unable to connect to the server. Please check your internet connection.');
      }

      // Fetch services with their providers
      final response = await _supabase.from('services')
          .select('''
            *,
            service_providers!provider_id(
              id,
              name,
              email,
              phone,
              address,
              rating,
              total_ratings,
              is_verified,
              specialties,
              description,
              price_multiplier,
              location
            )
          ''')
          .order('name');
          
      print('Successfully fetched ${response.length} services');
      print('First service data: ${response.isNotEmpty ? response.first : 'No services found'}');
      
      // Process the response to ensure proper data structure
      final processedResponse = response.map((service) {
        // Ensure provider data is properly structured
        if (service['service_providers'] != null) {
          service['provider'] = service['service_providers'];
          service.remove('service_providers');
        }
        return service;
      }).toList();
      
      return processedResponse;
    } catch (e) {
      print('Error fetching services: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
        throw Exception('Unable to connect to the server. Please check your internet connection.');
      } else {
        throw Exception('Failed to fetch services. Please try again later.');
      }
    }
  }

  Future<List<Map<String, dynamic>>> getServicesByProvider(String providerId) async {
    try {
      final response = await _supabase.from('services')
          .select()
          .eq('provider_id', providerId)
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting services: $e');
      throw Exception('Failed to fetch services');
    }
  }

  // Booking Operations
  Future<Map<String, dynamic>> createBooking({
    required String providerId,
    required String serviceId,
    required String petId,
    required String bookingDate,
    required String bookingTime,
    required double amount,
    String? notes,
  }) async {
    try {
      print('Starting to create booking...');
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('Error: No user logged in');
        throw Exception('No user logged in');
      }
      print('Current user ID: $userId');

      final booking = {
        'user_id': userId,
        'provider_id': providerId,
        'service_id': serviceId,
        'pet_id': petId,
        'booking_date': bookingDate,
        'booking_time': bookingTime,
        'status': 'pending',
        'payment_status': 'pending',
        'amount': amount,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('Booking data to insert: $booking');

      // First verify the provider exists
      try {
        final provider = await _supabase.from('service_providers')
            .select()
            .eq('id', providerId)
            .single();
        print('Found provider: ${provider['name']}');
      } catch (e) {
        print('Error verifying provider: $e');
        throw Exception('Invalid service provider');
      }

      // Verify the service exists
      try {
        final service = await _supabase.from('services')
            .select()
            .eq('id', serviceId)
            .single();
        print('Found service: ${service['name']}');
      } catch (e) {
        print('Error verifying service: $e');
        throw Exception('Invalid service');
      }

      // Verify the pet exists and belongs to the user
      try {
        final pet = await _supabase.from('pets')
            .select()
            .eq('id', petId)
            .eq('owner_id', userId)
            .single();
        print('Found pet: ${pet['name']}');
      } catch (e) {
        print('Error verifying pet: $e');
        throw Exception('Invalid pet or pet does not belong to you');
      }

      // Create the booking
      print('Inserting booking into database...');
      final response = await _supabase.from('bookings')
          .insert(booking)
          .select()
          .single();

      print('Booking created successfully: ${response['id']}');
      print('Full booking response: $response');

      // Verify the booking exists in the database
      try {
        final verifyBooking = await _supabase.from('bookings')
            .select('''
              *,
              services!service_id(*),
              service_providers!provider_id(*),
              pets!pet_id(*)
            ''')
            .eq('id', response['id'])
            .single();
        print('Verified booking exists in database: $verifyBooking');
      } catch (e) {
        print('Error verifying booking in database: $e');
      }

      return response;
    } catch (e) {
      print('Error creating booking: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
      }
      throw Exception('Failed to create booking. Please try again.');
    }
  }

  // Get user bookings with improved error handling
  Future<List<Map<String, dynamic>>> getUserBookings() async {
    try {
      print('Starting getUserBookings...');
      
      // Check if Supabase client is initialized
      if (_supabase == null) {
        print('Error: Supabase client not initialized');
        throw Exception('Unable to connect to the server');
      }

      // Check if user is logged in
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('Error: No user logged in');
        throw Exception('No user logged in');
      }
      print('Current user ID: $userId');

      // Test database connection
      try {
        print('Testing database connection...');
        await _supabase.from('bookings').select('count').limit(1);
        print('Database connection successful');
      } catch (e) {
        print('Error testing database connection: $e');
        throw Exception('Unable to connect to the server. Please check your internet connection');
      }

      print('Fetching bookings...');
      final response = await _supabase.from('bookings')
          .select('''
            *,
            services!service_id(*),
            service_providers!provider_id(*),
            pets!pet_id(*)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('Raw response from Supabase: $response');
      
      if (response == null) {
        print('Error: Null response from Supabase');
        throw Exception('Failed to load bookings');
      }

      final bookings = List<Map<String, dynamic>>.from(response);
      print('Successfully parsed ${bookings.length} bookings');
      
      if (bookings.isEmpty) {
        print('No bookings found for user');
        return [];
      }

      // Log each booking for debugging
      for (var booking in bookings) {
        print('Booking ID: ${booking['id']}');
        print('Service: ${booking['services']}');
        print('Provider: ${booking['service_providers']}');
        print('Pet: ${booking['pets']}');
      }

      return bookings;
    } catch (e) {
      print('Error in getUserBookings: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
        throw Exception('Unable to connect to the server. Please check your internet connection');
      } else if (e.toString().contains('No user logged in')) {
        throw Exception('Please sign in to view your bookings');
      } else if (e.toString().contains('network')) {
        throw Exception('Please check your internet connection and try again');
      } else {
        print('Stack trace: ${StackTrace.current}');
        throw Exception('Failed to load bookings. Please try again later');
      }
    }
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      await _supabase.from('bookings')
          .update({
            'status': status.toString().split('.').last,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);
    } catch (e) {
      print('Error updating booking status: $e');
      throw Exception('Failed to update booking status');
    }
  }

  // Chat Operations
  Future<List<Map<String, dynamic>>> getChatHistory(String providerId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('No user logged in');

      final response = await _supabase.from('chat_history')
          .select()
          .or('sender_id.eq.${userId},receiver_id.eq.${userId}')
          .eq('receiver_id', providerId)
          .order('created_at');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting chat history: $e');
      throw Exception('Failed to fetch chat history');
    }
  }

  Future<void> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('No user logged in');

      await _supabase.from('chat_history').insert({
        'sender_id': userId,
        'receiver_id': receiverId,
        'message': message,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message');
    }
  }

  Future<void> markMessagesAsRead(String providerId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('No user logged in');

      await _supabase.from('chat_history')
          .update({'is_read': true})
          .eq('receiver_id', userId)
          .eq('sender_id', providerId)
          .eq('is_read', false);
    } catch (e) {
      print('Error marking messages as read: $e');
      throw Exception('Failed to mark messages as read');
    }
  }

  Future<void> updatePaymentStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      print('Starting to update payment status...');
      print('Booking ID: $bookingId');
      print('New status: $status');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('Error: No user logged in');
        throw Exception('No user logged in');
      }

      // Verify the booking exists and belongs to the user
      try {
        final booking = await _supabase.from('bookings')
            .select()
            .eq('id', bookingId)
            .eq('user_id', userId)
            .single();
        print('Found booking: ${booking['id']}');
      } catch (e) {
        print('Error verifying booking: $e');
        throw Exception('Invalid booking or booking does not belong to you');
      }

      // Update the payment status
      print('Updating payment status...');
      final response = await _supabase.from('bookings')
          .update({
            'payment_status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId)
          .select()
          .single();

      print('Payment status updated successfully: $response');
    } catch (e) {
      print('Error updating payment status: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
      }
      throw Exception('Failed to update payment status. Please try again.');
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      print('Starting to cancel booking...');
      print('Booking ID: $bookingId');

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('Error: No user logged in');
        throw Exception('No user logged in');
      }

      // Verify the booking exists and belongs to the user
      try {
        final booking = await _supabase.from('bookings')
            .select()
            .eq('id', bookingId)
            .eq('user_id', userId)
            .single();
        print('Found booking: ${booking['id']}');
      } catch (e) {
        print('Error verifying booking: $e');
        throw Exception('Invalid booking or booking does not belong to you');
      }

      // Update the booking status to cancelled
      print('Updating booking status to cancelled...');
      final response = await _supabase.from('bookings')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId)
          .select()
          .single();

      print('Booking cancelled successfully: $response');
    } catch (e) {
      print('Error cancelling booking: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
      }
      throw Exception('Failed to cancel booking. Please try again.');
    }
  }

  Future<List<ServiceProvider>> getProvidersForService(String serviceId) async {
    print('Getting providers for service ID: $serviceId');
    try {
      if (_supabase == null) {
        throw Exception('Supabase client not initialized');
      }

      // If it's a default service ID, get all providers
      if (serviceId == 'default') {
        print('Default service ID detected, fetching all providers');
        final response = await _supabase.from('service_providers')
            .select('*')
            .order('name');

        print('Raw response for default service: $response');

        if (response.isEmpty) {
          print('No providers found');
          return [];
        }

        final providers = response.map((data) {
          print('Processing provider data: $data');
          try {
            final provider = ServiceProvider.fromMap(data);
            print('Successfully created provider: ${provider.name} (ID: ${provider.id})');
            return provider;
          } catch (e) {
            print('Error creating provider from data: $e');
            print('Problematic data: $data');
            rethrow;
          }
        }).toList();

        print('Successfully processed ${providers.length} providers for default service');
        return providers;
      }

      // For specific service IDs, get providers that offer that service
      print('Fetching providers for specific service: $serviceId');
      final response = await _supabase.from('service_providers')
          .select('*, services!service_id(*)')
          .eq('service_id', serviceId);

      print('Raw response for specific service: $response');

      if (response.isEmpty) {
        print('No providers found for service $serviceId');
        return [];
      }

      final providers = response.map((data) {
        print('Processing provider data: $data');
        try {
          final provider = ServiceProvider.fromMap(data);
          print('Successfully created provider: ${provider.name} (ID: ${provider.id})');
          return provider;
        } catch (e) {
          print('Error creating provider from data: $e');
          print('Problematic data: $data');
          rethrow;
        }
      }).toList();

      print('Successfully processed ${providers.length} providers for service $serviceId');
      return providers;
    } catch (e) {
      print('Error in getProvidersForService: $e');
      if (e is PostgrestException) {
        print('Postgrest error details: ${e.message}');
        print('Postgrest error code: ${e.code}');
        print('Postgrest error details: ${e.details}');
        throw Exception('Database error: ${e.message}');
      } else if (e.toString().contains('network')) {
        throw Exception('Please check your internet connection and try again');
      } else {
        throw Exception('Failed to load providers: ${e.toString()}');
      }
    }
  }
} 
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Replace these with your actual Supabase credentials
  static const String url = 'https://vbbjpxjubbfjcgtiituc.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZiYmpweGp1YmJmamNndGlpdHVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEyNDE2ODIsImV4cCI6MjA1NjgxNzY4Mn0.cU73zqfgob-Ho0SZzZTwtuv_BVbphwb4bzV6LdjNUQk';

  static void validateConfig() {
    print('Validating Supabase configuration...');
    print('URL: $url');
    print('Anon Key length: ${anonKey.length}');

    if (url.isEmpty) {
      print('Error: Supabase URL is empty');
      throw Exception('Invalid Supabase URL: URL is empty');
    }

    if (!url.startsWith('https://')) {
      print('Error: Supabase URL must start with https://');
      throw Exception('Invalid Supabase URL: Must start with https://');
    }

    if (anonKey.isEmpty) {
      print('Error: Supabase anon key is empty');
      throw Exception('Invalid Supabase anon key: Key is empty');
    }

    if (!anonKey.startsWith('eyJ')) {
      print('Error: Supabase anon key format is invalid');
      throw Exception('Invalid Supabase anon key: Invalid format');
    }

    print('Supabase configuration validation successful');
  }
} 
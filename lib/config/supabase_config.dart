class SupabaseConfig {
  // TODO: Replace these with your actual Supabase credentials
  static const String url = 'https://vbbjpxjubbfjcgtiituc.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZiYmpweGp1YmJmamNndGlpdHVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEyNDE2ODIsImV4cCI6MjA1NjgxNzY4Mn0.cU73zqfgob-Ho0SZzZTwtuv_BVbphwb4bzV6LdjNUQk';

  static void validateConfig() {
    if (url.isEmpty || !url.startsWith('https://')) {
      throw Exception('Invalid Supabase URL');
    }
    if (anonKey.isEmpty) {
      throw Exception('Invalid Supabase anon key');
    }
  }
} 
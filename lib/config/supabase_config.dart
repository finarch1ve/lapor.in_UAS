import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://nrzoueszzjkhywvxsxby.supabase.co';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5yem91ZXN6empraHl3dnhzeGJ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIxMzQ0ODgsImV4cCI6MjA5NzcxMDQ4OH0.V_ZLkExPuWZx4yLS2hLREb5_7KksukQ6zDenjHRqCwY';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,  // Gunakan anonKey, bukan publishableKey
      debug: true,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static bool get isConfigured =>
      supabaseUrl != 'YOUR_SUPABASE_URL_HERE' &&
      supabaseKey != 'YOUR_SUPABASE_ANON_KEY_HERE';
}
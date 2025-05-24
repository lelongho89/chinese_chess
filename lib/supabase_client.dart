import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'global.dart';

/// Singleton class for managing Supabase client
class SupabaseClientWrapper {
  static SupabaseClientWrapper? _instance;
  static SupabaseClientWrapper get instance => _instance ??= SupabaseClientWrapper._();

  late final Supabase _supabase;

  /// Get the Supabase client
  GoTrueClient get auth => _supabase.client.auth;

  /// Get the Supabase database client
  SupabaseClient get database => _supabase.client;

  /// Get the Supabase storage client
  SupabaseStorageClient get storage => _supabase.client.storage;

  /// Initialize Supabase
  static Future<void> initialize() async {
    try {
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl?.isEmpty != false || supabaseAnonKey?.isEmpty != false) {
        throw Exception('Supabase URL or Anon Key not found');
      }

      await Supabase.initialize(
        url: supabaseUrl!,
        anonKey: supabaseAnonKey!,
        debug: false, // Set to true for development
      );

      _instance = SupabaseClientWrapper._();
      logger.info('Supabase initialized successfully');
    } catch (e) {
      logger.severe('Failed to initialize Supabase: $e');
      rethrow;
    }
  }

  SupabaseClientWrapper._() {
    _supabase = Supabase.instance;
  }
}

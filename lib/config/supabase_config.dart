import 'package:flutter_dotenv/flutter_dotenv.dart';
class SupabaseConfig {
  static String get url {
    return dotenv.env['SUPABASE_URL'] ?? 'http://127.0.0.1:54321';
  }

  static String get anonKey {
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  static Future<void> loadEnv() async {
    await dotenv.load(fileName: '.env');
  }
}

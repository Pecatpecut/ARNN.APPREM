import 'package:flutter_dotenv/flutter_dotenv.dart';
class AppConstants {
  /// APP
  static const String appName = "Aetheric Flux";

  /// PADDING
  static const double padding = 16.0;

  /// RADIUS
  static const double radius = 16.0;

  /// API
  static String get supabaseUrl => dotenv.env['SUPABASE_URL']!;
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;

  /// DEFAULT IMAGE
  static const String defaultImage =
      "https://via.placeholder.com/150";
}
// lib/utils/constants.dart
import '../config/api_config.dart';

// Use ApiConfig for proper platform support (Android emulator, iOS simulator, etc.)
final String kApiUrl = ApiConfig.apiBaseUrl.replaceAll(RegExp(r'/$'), '');

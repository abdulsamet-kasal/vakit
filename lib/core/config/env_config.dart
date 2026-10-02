import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Ortam değişkenleri yönetim sınıfı.
/// .env dosyası bulunamazsa veya anahtarlar boşsa uygulamanın çökmesini engeller;
/// offline-first gömülü asset moduna sorunsuz geçiş sağlar.
abstract final class EnvConfig {
  static bool _isLoaded = false;

  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
      _isLoaded = true;
    } catch (e) {
      // .env dosyası eksik veya okunamazsa çökme, offline devam et
      debugPrint('Uyarı: .env dosyası yüklenemedi ($e). Offline/gömülü modda devam ediliyor.');
      _isLoaded = false;
    }
  }

  static String get supabaseUrl {
    if (!_isLoaded) return '';
    return dotenv.env['SUPABASE_URL']?.trim() ?? '';
  }

  static String get supabaseAnonKey {
    if (!_isLoaded) return '';
    return dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';
  }

  /// Supabase için geçerli ve dolu kimlik bilgisi olup olmadığını kontrol eder.
  static bool get hasSupabaseConfig {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Ortam değişkenleri yönetim sınıfı.
///
/// Yükleme sırası:
/// 1. `.env` (gitignore'da, geliştiricinin kendi anahtarları) — varsa bu kullanılır.
/// 2. `assets/env/env.properties` (pubspec'te asset olarak tanımlı boş şablon) —
///    taze klonda `.env` bulunmasa bile asset hatası vermeden uygulama açılır ve
///    offline gömülü asset moduna geçilir.
///
/// Hiçbir anahtar bulunamazsa uygulama çökmez; offline-first gömülü veri modu ile devam eder.
abstract final class EnvConfig {
  static bool _isLoaded = false;

  static Future<void> init() async {
    // 1) Önce gerçek .env dene (geliştirici kendi anahtarlarını buraya koyar).
    try {
      await dotenv.load(fileName: '.env');
      _isLoaded = true;
      return;
    } catch (_) {
      // .env yok veya okunamadı; asset şablonuna düş.
    }

    // 2) Asset içindeki şablon dosyayı yükle (anahtarlar boş olabilir).
    try {
      final raw = await rootBundle.loadString('assets/env/env.properties');
      // flutter_dotenv v6'da loadFromString sync (void) döner.
      dotenv.loadFromString(envString: raw, isOptional: true);
      _isLoaded = true;
    } catch (e) {
      debugPrint('Uyarı: env dosyaları yüklenemedi ($e). Offline/gömülü modda devam ediliyor.');
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

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/env_config.dart';
import 'models/hadith_model.dart';
import 'models/verse_model.dart';

/// Günlük Âyet ve Hadis veri katmanı.
/// Katı öncelik sırası:
/// 1. Yerel Önbellek (SharedPreferences)
/// 2. Supabase (Çevrimiçi ise çekip yerel önbelleğe yazar)
/// 3. Gömülü Varlık (assets/data/*.json)
/// İnternet yoksa veya .env boşsa uygulama asla çökmez.
class DailyContentRepository {
  static const int totalSeedCount = 30;

  /// Belirli bir tarihin yılın kaçıncı günü olduğunu ve 30'luk döngüdeki indeksini hesaplar (1-30)
  static int getSeedDayOfYear(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return ((dayOfYear - 1) % totalSeedCount) + 1;
  }

  /// Günün Âyetini getirir
  Future<VerseModel> getDailyVerse(DateTime date) async {
    final targetDay = getSeedDayOfYear(date);
    final cacheKey = 'cached_verse_v2_$targetDay';

    // 1. ADIM: Yerel Önbellek Kontrolü
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(cacheKey);
      if (cachedJson != null) {
        final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
        return VerseModel.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('Önbellek okuma hatası: $e');
    }

    // 2. ADIM: Supabase'den Çekmeyi Dene (Çevrimiçi & Anon)
    if (EnvConfig.hasSupabaseConfig) {
      try {
        final response = await Supabase.instance.client
            .from('daily_verses')
            .select()
            .eq('day_of_year', targetDay)
            .maybeSingle();

        if (response != null) {
          final verse = VerseModel.fromJson(response);
          // Gelecek sefer için yerel önbelleğe yaz
          _saveToCache(cacheKey, verse.toJson());
          return verse;
        }
      } catch (e) {
        debugPrint('Supabase ayet çekme hatası (offline fallback devreye giriyor): $e');
      }
    }

    // 3. ADIM: Gömülü Asset'ten Oku (Kesin güvence)
    return _loadVerseFromAssets(targetDay);
  }

  /// Günün Hadisini getirir
  Future<HadithModel> getDailyHadith(DateTime date) async {
    final targetDay = getSeedDayOfYear(date);
    final cacheKey = 'cached_hadith_v2_$targetDay';

    // 1. ADIM: Yerel Önbellek Kontrolü
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(cacheKey);
      if (cachedJson != null) {
        final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
        return HadithModel.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('Önbellek okuma hatası: $e');
    }

    // 2. ADIM: Supabase'den Çekmeyi Dene (Çevrimiçi & Anon)
    if (EnvConfig.hasSupabaseConfig) {
      try {
        final response = await Supabase.instance.client
            .from('daily_hadiths')
            .select()
            .eq('day_of_year', targetDay)
            .maybeSingle();

        if (response != null) {
          final hadith = HadithModel.fromJson(response);
          _saveToCache(cacheKey, hadith.toJson());
          return hadith;
        }
      } catch (e) {
        debugPrint('Supabase hadis çekme hatası (offline fallback devreye giriyor): $e');
      }
    }

    // 3. ADIM: Gömülü Asset'ten Oku (Kesin güvence)
    return _loadHadithFromAssets(targetDay);
  }

  /// Önümüzdeki N günün ayet ve hadislerini Home Widget için topluca önbellekten/assetten çeker
  Future<List<VerseModel>> getVerseRange(DateTime startDate, {int days = 7}) async {
    final list = <VerseModel>[];
    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      list.add(await getDailyVerse(date));
    }
    return list;
  }

  Future<List<HadithModel>> getHadithRange(DateTime startDate, {int days = 7}) async {
    final list = <HadithModel>[];
    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      list.add(await getDailyHadith(date));
    }
    return list;
  }

  Future<void> _saveToCache(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(data));
    } catch (_) {}
  }

  Future<VerseModel> _loadVerseFromAssets(int targetDay) async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/daily_verses.json');
      final list = jsonDecode(jsonString) as List<dynamic>;
      for (final item in list) {
        if (item['day_of_year'] == targetDay) {
          return VerseModel.fromJson(item as Map<String, dynamic>);
        }
      }
      if (list.isNotEmpty) {
        return VerseModel.fromJson(list.first as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Asset ayet yükleme hatası: $e');
    }

    // Nihai güvenli yedek (Fallback)
    return const VerseModel(
      id: 2,
      dayOfYear: 2,
      surahNo: 2,
      ayahNo: 152,
      arabic: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      mealTr: 'Öyleyse yalnız beni anın ki ben de sizi anayım. Bana şükredin ve nankörlük etmeyin.',
      sourceName: 'Bakara Sûresi, 152',
      shortText: 'Beni anın ki ben de sizi anayım; bana şükredin, nankörlük etmeyin.',
    );
  }

  Future<HadithModel> _loadHadithFromAssets(int targetDay) async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/daily_hadiths.json');
      final list = jsonDecode(jsonString) as List<dynamic>;
      for (final item in list) {
        if (item['day_of_year'] == targetDay) {
          return HadithModel.fromJson(item as Map<String, dynamic>);
        }
      }
      if (list.isNotEmpty) {
        return HadithModel.fromJson(list.first as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Asset hadis yükleme hatası: $e');
    }

    // Nihai güvenli yedek (Fallback)
    return const HadithModel(
      id: 1,
      dayOfYear: 1,
      arabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      textTr: 'Ameller niyetlere göredir; herkesin niyeti ne ise eline geçecek olan odur.',
      narrator: 'Hz. Ömer (r.a.)',
      sourceBook: 'Buhârî',
      sourceNo: 'Bed\'ü\'l-Vahy 1',
      shortText: 'Ameller niyetlere göredir; herkes için ancak niyet ettiği şey vardır.',
    );
  }
}

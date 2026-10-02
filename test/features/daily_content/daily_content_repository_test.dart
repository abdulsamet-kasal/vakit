import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakit/features/daily_content/data/daily_content_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DailyContentRepository & İçerik Doğrulama Testleri', () {
    final repo = DailyContentRepository();

    test('getSeedDayOfYear 1-30 aralığında deterministik sonuç üretmeli', () {
      final date1 = DateTime(2026, 1, 1);
      final date2 = DateTime(2026, 1, 31);
      final date3 = DateTime(2026, 10, 2);

      final seed1 = DailyContentRepository.getSeedDayOfYear(date1);
      final seed2 = DailyContentRepository.getSeedDayOfYear(date2);
      final seed3 = DailyContentRepository.getSeedDayOfYear(date3);

      expect(seed1, inInclusiveRange(1, 30));
      expect(seed2, inInclusiveRange(1, 30));
      expect(seed3, inInclusiveRange(1, 30));
      expect(seed1, 1);
      expect(seed2, 1); // 31. gün döngüde tekrar 1. indekse gelir
    });

    test('Offline / Asset modunda Günün Âyeti başarıyla yüklenmeli', () async {
      final testDate = DateTime(2026, 10, 2);
      final verse = await repo.getDailyVerse(testDate);

      expect(verse.arabic.isNotEmpty, isTrue);
      expect(verse.mealTr.isNotEmpty, isTrue);
      expect(verse.sourceName.isNotEmpty, isTrue);
    });

    test('Offline / Asset modunda Günün Hadisi başarıyla yüklenmeli', () async {
      final testDate = DateTime(2026, 10, 2);
      final hadith = await repo.getDailyHadith(testDate);

      expect(hadith.textTr.isNotEmpty, isTrue);
      expect(hadith.narrator.isNotEmpty, isTrue);
      expect(hadith.sourceBook.isNotEmpty, isTrue);
    });
  });
}

# Vakit • Geliştirme ve İlerleme Günlüğü (agent.md)

Bu dosya, "Vakit" namaz vakti mobil uygulamasının aşama aşama gelişimini, mimari kararlarını, tamamlanan hedefleri ve release durumunu takip eder.

---

## 📌 Proje Özeti
- **Uygulama Adı:** Vakit
- **Teknoloji Yığını:** Flutter 3.47+ (stable), Dart 3.13+, Riverpod (modern `NotifierProvider`), go_router, Supabase (anon read-only), adhan, home_widget.
- **Tasarım Dili:** Cami avlusu huzuru, el yazması mushaf dokusu, derin orman yeşili (#0F3D2E), yosun yeşili (#2F6B4F), adaçayı (#A9C4B0), parşömen (#F3EEE0), mat pirinç (#B8934A), kerahat kili/amberi (#C27A3E).
- **İmza Şekiller:** Sivri/Ogee Mihrap Kemeri (`MihrapClipper`), Güneş Yayı (`SunArcPainter`), Sekizgen Selçuklu Yıldızı & Girih Doku (`IslamicPatternPainter`), Açık Mushaf Sayfası (`MushafCard`).
- **Mimari:** Feature-first (`features/prayer_times`, `features/qibla`, `features/daily_content`, `features/settings`, `features/widgets_bridge`, `core/`).
- **GitHub Deposu:** [abdulsamet-kasal/vakit](https://github.com/abdulsamet-kasal/vakit)

---

## 🚀 Aşama Durumları

### ✅ Aşama 0: Proje Kurulumu, Mimari, Tema & Bileşen Önizleme Ekranı
- [x] Flutter projesi oluşturuldu, CachyOS 8GB RAM ve Gradle JVM sınırları (`-Xmx1536M`) uygulandı.
- [x] Feature-first klasör mimarisi oluşturuldu.
- [x] Tasarım tokenları (`AppColors`, `AppTypography`) tanımlandı.
- [x] `Newsreader` (başlık/saatler), `Source Sans 3` (gövde), `Amiri` (Arapça) ve eşit aralıklı rakamlar (`tabularFigures`) entegre edildi.
- [x] `MihrapClipper` ve `MihrapContainer` çift pirinç kılcal kenarlıkla geliştirildi.
- [x] `SunArcPainter` (gündoğumu-günbatımı yayı, hareketli güneş, kerahat aralıkları) çizildi.
- [x] `PrayerTimelineList` (dikey şerit, aktif vakit pirinç çizgisi, soluk geçmiş vakitler) tamamlandı.
- [x] `MushafCard` (el yazması mushaf dokusu, 4 köşe rozeti ve ayet sonu motifi) hazırlandı.
- [x] `KerahatBadge` ve `KerahatConfig` tanımlandı.
- [x] `DesignPreviewScreen` ve `appRouter` ile önizleme ekranı devreye alındı.
- [x] `flutter analyze` 0 hata ile temizlendi.
- [x] GitHub üzerinde `abdulsamet-kasal/vakit` deposu açıldı.

### ✅ Aşama 1: Konum, Vakit Hesabı, Kerahat Hesabı, Ana Ekran & Unit Testler
- [x] `CityModel` ile Türkiye'nin 81 ili çevrimdışı koordinatlarıyla tanımlandı.
- [x] `LocationService` (geolocator + geocoding) ile çökme korumalı GPS ve ters geocoding eklendi.
- [x] `PrayerCalculator` ile `adhan` Diyanet yöntemi cihaz üstünde internetsiz hesaplama tamamlandı.
- [x] 3 Kerahat vakti (Doğuş ~45dk, İstiva ~40dk, Batış ~45dk) ve canlı durum tespiti bağlandı.
- [x] Modern Riverpod `PrayerTimesNotifier` ile 1 saniyelik canlı geri sayım, aktif vakit, sonraki vakit ve güneş konumu takip edildi.
- [x] `CitySelectorSheet` ile aranabilir 81 il seçimi ve GPS ile konum bulma arayüzü yazıldı.
- [x] `PrayerTimesScreen` ana ekranı tamamlandı: Mihrap geri sayım kartı, sakin kerahat etiketi, güneş yayı, dikey zaman şeridi, gün değiştirme çubuğu.
- [x] `MainScaffoldShell` ile 5 sekmeli zarif alt menü (Vakitler, Kıble, Âyet, Hadis, Ayarlar) bağlandı.
- [x] `DateTimeUtils` ile Türkçe Miladi ve Hicri takvim desteği sağlandı.
- [x] Unit testler (`prayer_calculation_test.dart`): İstanbul ve Ankara için Diyanet takvimiyle ±2 dk uyumu, kronolojik sıra, kerahat aralıkları ve 7 günlük veri hesabı %100 doğrulandı.
- [x] `flutter analyze` 0 hata, testler başarıyla geçti.

### ✅ Aşama 2: Supabase Kurulumu, SQL Migration'lar, Veri Katmanı & Ayarlar Ekranı
- [x] Supabase veritabanında `daily_verses` ve `daily_hadiths` tabloları RLS (Row Level Security) açık ve `anon` okumaya izinli şekilde oluşturuldu (`20261002000000_create_daily_content.sql`).
- [x] 30 otantik Âyet ve 30 muteber Hadis (Buhari, Müslim, Tirmizi vb. tam kaynaklı) hazırlanıp `assets/data/` içine gömüldü ve Supabase veritabanına seed edildi (`20261002000001_seed_daily_content.sql`).
- [x] `DailyContentRepository` ile katı öncelik sırası uygulandı: `Yerel Önbellek → Supabase (Çevrimiçi) → Gömülü Varlık (assets/data/*.json)`.
- [x] `EnvConfig` ve `main.dart` entegrasyonu ile `.env` boş olsa veya ağ kopuk olsa bile sıfır çökme garantisi sağlandı.
- [x] `AppSettingsModel`, `SettingsRepository` (shared_preferences) ve `SettingsNotifier` modern Riverpod ile bağlandı.
- [x] `SettingsScreen` arayüzü tamamlandı: Hesaplama yöntemi diyaloğu, ikindi mezhep seçimi, kerahat süreleri slider'ları, tema anahtarı, Supabase bağlantı rozeti.
- [x] `daily_content_repository_test.dart` ile deterministik günlük seçim ve offline asset güvencesi test edildi.
- [x] `flutter analyze` ve tüm testler (8 test) 0 hata ile geçti.

### ✅ Aşama 3: Günün Âyeti ve Hadisi Ekranları, Paylaşım Kartı & Çevrimdışı Güvence
- [x] `DailyContentNotifier` modern Riverpod ile gün bazlı asenkron veri yükleme ve gün değiştirme mantığı kuruldu.
- [x] `ShareCardExporter` ile `RepaintBoundary` üzerinden 3.0 pixelRatio yüksek çözünürlüklü PNG görsel kart oluşturma ve `share_plus` üzerinden paylaşma servisi yazıldı.
- [x] `DailyVerseScreen`: Amiri hat tipografisi, bol satır aralığı, Türkçe meâl, ayet sonu rozeti (`AyahEndRosette`), kopyalama, metin paylaşımı ve görsel kart paylaşımı tamamlandı.
- [x] `DailyHadithScreen`: Arapça metin, Türkçe hadis metni, ravi, tam kitap kaynağı, kopyalama, metin ve görsel kart paylaşımı tamamlandı.
- [x] Her iki ekranda da önceki/sonraki güne kaydırma (< Önceki Gün | Bugün | Sonraki Gün >) eklendi.
- [x] `flutter analyze` 0 hata, testler sorunsuz çalıştı.

---

### ⏳ Sıradaki Aşamalar
- **Aşama 4:** Kıble ekranı (flutter_compass, büyük daire formülü, düşük geçiren filtre, haptik titreşim).
- **Aşama 5:** Ana ekran widget'ları (Android RemoteViews + Chronometer, 2x2, 4x2, Ayet/Hadis 4x2, 7 günlük veri köprüsü).
- **Aşama 6:** Cilalama, hata durumları, uygulama ikonu ve açılış ekranı, APK derlemesi ve GitHub Release yayını.

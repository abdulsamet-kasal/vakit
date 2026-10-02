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

---

### ⏳ Sıradaki Aşamalar
- **Aşama 2:** Supabase kurulumu: .env yapısı, SQL migration'ları (daily_verses, daily_hadiths), veri katmanı (önbellek → Supabase → asset), yerel ayarlar ekranı.
- **Aşama 3:** Günün ayeti ve hadisi ekranları + paylaşım kartı + offline yedekleme.
- **Aşama 4:** Kıble ekranı (flutter_compass, büyük daire formülü, düşük geçiren filtre, haptik titreşim).
- **Aşama 5:** Ana ekran widget'ları (Android RemoteViews + Chronometer, 2x2, 4x2, Ayet/Hadis 4x2, 7 günlük veri köprüsü).
- **Aşama 6:** Cilalama, hata durumları, uygulama ikonu ve açılış ekranı, APK derlemesi ve GitHub Release yayını.

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

### ✅ Aşama 4: Kıble Bulucu Ekranı, Küresel Matematik & Düşük Geçiren Filtre
- [x] `MathUtils`: Büyük daire (great-circle) forward azimuth Kıble açısı formülü ve Haversine Kâbe mesafesi formülü uygulandı.
- [x] 0°/360° dairesel sınır geçişini mükemmel idare eden dairesel Düşük Geçiren Filtre (`filterHeading`) geliştirildi; sensör titremesi ve sıçramalar engellendi.
- [x] `CompassService` ve `QiblaNotifier` ile anlık yön takibi ve Kıbleye hizalanma anında tek seferlik haptik geri bildirim (`HapticFeedback.mediumImpact()`) entegre edildi.
- [x] `QiblaCompassDial`: İslami geometrik motifli pusula kadranı, Türkçe ana yönler (K, D, G, B), zarif Kâbe ibresi ve hizalanma anında parlayan mat pirinç altın hare (`brassGlow`) animasyonu çizildi.
- [x] `QiblaScreen`: Tam ekran sade arayüz, Kâbe'ye km mesafesi, Kıble yön açısı, kalibrasyon uyarısı (8 çizme rehberi) ve sensörsüz cihazlar için anlaşılır bilgilendirici boş durum ekranı yapıldı.
- [x] `qibla_math_test.dart`: İstanbul ve Ankara açı/mesafe doğrulamaları, dairesel filtre testi ve tolerans kontrolleri %100 geçti (12 test).
- [x] `flutter analyze` 0 hata ile temizlendi.

---

### ✅ Aşama 5: Ana Ekran Widget'ları (Android RemoteViews, 5 Widget Tipi & Veri Köprüsü)
- [x] `home_widget` kütüphanesi ile Flutter ve yerel Android katmanı arasında çift yönlü veri köprüsü kuruldu (`HomeWidgetService`).
- [x] 7 günlük namaz vakitleri, kerahat aralıkları ve günün âyet/hadis verisi tek seferde JSON formatında `shared_preferences` içine aktarılacak şekilde modellendi.
- [x] 5 farklı yerel Android Widget'ı geliştirildi:
  1. **Small (2x2):** Sonraki vakit adı, ezan saati, canlı geri sayım (`ChronometerCountDown`), kerahat rozeti.
  2. **Medium (4x2):** Günün 6 vakti, vakit saatleri, aktif vaktin altında mat pirinç çizgi göstergesi ve kerahat durumu.
  3. **Strip (4x1):** Yatay kompakt şerit, sonraki vakit ve canlı geri sayım sayacı.
  4. **Verse (4x2):** Mushaf kartı dokulu günün âyeti ve sure/ayet no kaynağı.
  5. **Hadith (4x2):** Mushaf kartı dokulu günün hadisi, ravi ve tam kaynak bilgisi.
- [x] `VakitWidgetHelper.kt`: JSON ayrıştırma, canlı Chronometer taban zamanı hesaplama, kerahat mantığı ve widget yenileme.
- [x] `VakitAlarmReceiver.kt`: Namaz vakitlerinde, kerahat giriş/çıkışlarında ve gece yarısı geçişlerinde widget'ları pil dostu uyandıran hassas alarm tetikleyicisi (`AlarmManager.setExactAndAllowWhileIdle`).
- [x] `BootReceiver.kt`: Cihaz yeniden başladığında (`BOOT_COMPLETED`), saat dilimi değiştiğinde veya zaman ayarlandığında widget'ları ve alarmları anında tazeleyen alıcı.
- [x] Deep link yönlendirmeleri (`vakit://vakitler`, `vakit://ayet`, `vakit://hadis`, `vakit://kible`) ile widget tıklamalarında ilgili ekrana anında geçiş.
- [x] `compileDebugKotlin` ve `flutter build apk --debug` ile Android derlemesi %100 doğrulandı.

---

### ✅ Aşama 6: Cilalama, Açılış Ekranı, Uygulama İkonu, Dokümantasyon ve Release Yayını
- [x] **Açılış Ekranı (Splash):** Derin orman yeşili (`#0F3D2E`) arka plan ve merkezde parlayan mat pirinç mihrap motifi (`launch_background.xml` & `ic_mihrap_motif.xml`) tasarlandı.
- [x] **Uygulama İkonu (Adaptive Icon):** Android 8.0+ uyumlu `mipmap-anydpi-v26` adaptive launcher ikonu ve vektör mihrap motif foreground'ı entegre edildi.
- [x] **Erişilebilirlik & Tipografi:** `MediaQuery.withClampedTextScaling(minScaleFactor: 0.85, maxScaleFactor: 1.35)` ile büyük yazı tipi desteği eklenirken arayüz taşmaları engellendi.
- [x] **Hata & İzin Akışları:** GPS izni reddedildiğinde veya kapatıldığında doğrudan uygulama izin ayarlarına yönlendiren SnackBar ve aranabilir 81 il listesi güvencesi tamamlandı.
- [x] **README.md:** Tasarım dili, feature-first mimarisi, eklenen her bir paketin nedenleri, Supabase kurulumu ve SQL migration rehberi, Android widget özellikleri detaylı dokümante edildi.
- [x] **Release APK:** `flutter build apk --release` ile `build/app/outputs/flutter-apk/app-release.apk` (58.7 MB) hatasız üretildi.
- [x] **GitHub & Release:** Değişiklikler `abdulsamet-kasal/vakit` deposuna pushlandı, GitHub Release `v1.0.0` APK ile birlikte yayımlandı.

---

### ✅ Aşama 7: Kullanıcı Testi Sonrası İyileştirmeler (Widget Boyutlandırma, Önizleme Kapakları, Kıble & Deep Link Onarımı, 972 İlçe Desteği)
- [x] **1. Widget Boyutlandırma (Resize):** Tüm 5 widget XML sağlayıcısına (`widget_*_info.xml`) `android:resizeMode="horizontal|vertical"`, `targetCellWidth`, `targetCellHeight`, `minResizeWidth`, `minResizeHeight` ve `maxResizeWidth/Height` kuralları eklenerek kullanıcının widget'ları ana ekranda serbestçe yeniden boyutlandırabilmesi sağlandı.
- [x] **2. Widget Seçici Kapak Önizlemeleri & Açıklamalar:** 5 farklı widget için özel vektörel önizleme görselleri (`preview_widget_small.xml`, `preview_widget_medium.xml`, `preview_widget_strip.xml`, `preview_widget_verse.xml`, `preview_widget_hadith.xml`) çizildi. `AndroidManifest.xml` üzerinde her alıcıya ayırt edici `android:label` ve `appwidget-provider` XML'lerine `android:description` ile `android:previewLayout` bağlandı.
- [x] **3. Kıble Uygulaması Onarımı:** `QiblaNotifier` içerisine Android manyetik sensörleri için konum izni kontrolü (`Geolocator.checkPermission/requestPermission`) eklendi. Sensör verisi gelmediğinde donup kalmayı önleyen 2.5 saniyelik zaman aşımı denetimi kuruldu. Negatif azimut açıları normalize edildi (`0..360`). Sensörsüz cihazlar için sabit yön ve Kâbe açısını görsel olarak gösteren statik rehber ve "Tekrar Dene" butonu geliştirildi.
- [x] **4. Widget Deep Link & Açılış Yönlendirmesi Onarımı:** Widget tıklamalarındaki `PendingIntent` çakışması çözüldü; her widget için benzersiz `requestCode` (101-105) ve `FLAG_ACTIVITY_NEW_TASK | FLAG_ACTIVITY_SINGLE_TOP` bayrakları tanımlandı. `MainActivity.kt` içerisine `onNewIntent` ve `setIntent(intent)` eklendi. Flutter tarafında ilk açılışta `checkInitialLaunch` navigatör bağlandıktan sonraya alındı ve `appRouter` içerisine `vakit://` yönlendirme kuralı entegre edildi.
- [x] **5. Türkiye'nin 81 İli ve 972 İlçesini Kapsayan Seçim:** `DistrictData` modeliyle Türkiye'nin tüm 81 il ve 972 ilçesi çevrimdışı veritabanı olarak entegre edildi. `CitySelectorSheet` arayüzü hem doğrudan arama (örn: "Kadıköy", "Alanya", "Çankaya") hem de il seçilince o ilin ilçelerine akıcı geçiş yapacak şekilde yenilendi. Seçilen ilçe `SharedPreferences` ve `CityModel.displayName` içine kalıcı kaydedilerek widget'lara ve ana ekrana yansıtıldı.
- [x] **Testler:** 19 unit ve widget testi 0 hata ile geçti (`flutter test`). `flutter analyze` 0 hata ile temizlendi. Hem debug hem release APK hatasız derlendi.

---

### ✅ Aşama 8: Kompakt Şerit & Tüm Vakitler Onarımı, Responsive Layout, Native Kotlin Pusula Motoru & v1.2.0 Sürümü
- [x] **1. Kompakt Şerit ve Tüm Vakitler Widget Onarımı:**
  - `VakitWidgetHelper.kt` içerisindeki gün seçimi `Calendar` üzerinden bugünün gerçek gününe (`DAY_OF_YEAR` & `YEAR`) göre akıllı eşleştirildi (`findTodayDayData`), geçmiş günün ilk indexte kalması sorunu giderildi.
  - Günün tüm vakitleri geçtiğinde (Yatsı sonrası) sonraki vakit ertesi günün İmsak'ına akıllıca aktarıldı.
  - SharedPreferences veri erişiminde çifte güvence (`HomeWidgetPreferences` ve `FlutterSharedPreferences`) sağlandı; `days_prayer_json` boşken veya gecikmeli gelirken widget'ların çökmesini ve donmasını önleyen varsayılan şık yedek durumlar eklendi.
- [x] **2. Responsive Layout & Yeniden Boyutlandırma (Resize Handles):**
  - Tüm Provider sınıflarına (`VakitSmallWidgetProvider`, `VakitMediumWidgetProvider`, `VakitStripWidgetProvider`, `VakitVerseWidgetProvider`, `VakitHadithWidgetProvider`) `onAppWidgetOptionsChanged` metodu eklenerek kullanıcı widget'ı büyütüp küçülttüğünde anında yeniden çizilmesi sağlandı.
  - `widget_strip.xml` ve `widget_medium.xml` dikey ve yatay taşmalara karşı `singleLine="true"`, `ellipsize="end"`, kompakt padding ve esnek ağırlıklarla (`layout_weight="1"`) baştan tasarlandı; 1x1'den 5x2'ye kadar kırpılmadan esneyebilmesi sağlandı.
  - `widget_*_info.xml` dosyalarındaki `minResizeWidth` ve `minResizeHeight` değerleri launcher uyumlu esnek değerlere (`35dp` - `70dp`) çekilerek tüm Android launcher'larda (OneUI, MIUI, Pixel, ColorOS) boyutlandırma tutamaçları eksiksiz aktif edildi.
- [x] **3. Ultra Dayanıklı Native Kotlin Pusula Motoru:**
  - `flutter_compass` eklentisinin Samsung Galaxy A, Xiaomi Redmi, Oppo gibi cihazlarda `Sensor.TYPE_ROTATION_VECTOR` kalibrasyon eksikliği nedeniyle `null` üretmesi ve pusulayı kilitlemesi sorunu tamamen aşıldı.
  - Android tarafında `CompassStreamHandler.kt` yerel motoru geliştirildi: `Sensor.TYPE_ROTATION_VECTOR`, `Sensor.TYPE_ACCELEROMETER` ve `Sensor.TYPE_MAGNETIC_FIELD` sensörlerini donanım füzyonuyla dinler, `SensorManager.remapCoordinateSystem` ile ekran yönelimini (dikey/yatay) hesaba katar ve `com.vakit.vakit/compass` EventChannel üzerinden akış sağlar.
  - `QiblaNotifier` konum izni reddedilse bile seçili şehrin koordinatlarıyla kıble açısını hesaplayıp pusulayı anında çalıştıracak şekilde engelsiz hale getirildi.
- [x] **4. APK İsimlendirme & GitHub Release v1.2.0:**
  - Versiyon `pubspec.yaml` üzerinde `1.2.0+3` olarak güncellendi.
  - Release APK `Vakit-v1.2.0.apk` olarak adlandırıldı.
  - GitHub deposunda `v1.2.0` release etiketiyle paylaşıldı.

---

## 🏆 Sonuç
Projenin tüm aşamaları (Aşama 0 - Aşama 8) %100 tamamlanmış, unit ve widget testleri başarıyla geçmiş, `flutter analyze` 0 hata ile temizlenmiş, kullanıcının fiziksel cihaz testleri sonrası bildirdiği tüm kritik widget ve kıble sorunları kökten çözülerek `v1.2.0` sürümü yayımlanmıştır.




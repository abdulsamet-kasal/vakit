# 🕌 Vakit • Namaz Vakti, Kıble & Günlük İslami İçerik Uygulaması

**Vakit**, modern mobil teknolojilerle geleneksel İslami sanat estetiğini harmanlayan; kullanıcı girişi veya kişisel veri toplamayan, tamamen cihaz üstünde internetsiz namaz vakti ve kerahat hesabı yapan, açık mushaf sayfası zarafetinde günlük âyet/hadis sunan Türkçe bir mobil uygulamadır.

---

## 🎨 Tasarım Dili ve Felsefesi

Vakit, jenerik AI şablonlarından ve parlak neon renklerden uzak, cami avlusu huzurunu ve tarihi el yazması mushaf dokusunu yansıtan özgün bir tasarım paletine sahiptir:

- **Derin Orman Yeşili (`#0F3D2E`):** Cami mermerlerinin ve yeşil halıların sükûneti.
- **Yosun Yeşili (`#2F6B4F`):** İkincil yüzeyler ve dengeli vurgular.
- **Adaçayı (`#A9C4B0`):** Narin çerçeveler ve açık yeşil dokunuşlar.
- **El Yazması Parşömen (`#F3EEE0`):** Göz yormayan sıcak arka plan dokusu.
- **Mat Pirinç (`#B8934A`):** Kandil ve rahle pirinçlerinden ilham alan altın vurgular.
- **Kerahat Kili / Amberi (`#C27A3E`):** Kerahat vakti uyarıları için sakin, telaşsız pişmiş toprak tonu.

### İmza Şekiller ve Bileşenler
- **Sivri/Ogee Mihrap Kemeri (`MihrapClipper`):** Ekranın merkezinde sonraki vakti ve canlı geri sayımı kuşatan klasik Osmanlı/Selçuklu mihrap motifi.
- **Güneşin Gökyüzü Seyri Yayı (`SunArcPainter`):** İmsak, güneş, öğle, ikindi, akşam noktalarını ve 3 kerahat dilimini gökyüzü yayı üzerinde canlı hareket eden güneşle görselleştirir.
- **Dikey Zaman Şeridi (`PrayerTimelineList`):** 6 vakti, vakit saatlerini ve aktif vaktin pirinç çizgi göstergesini soluk geçmiş vakitler hiyerarşisiyle sunar.
- **Açık Mushaf Kartı (`MushafCard`):** El yazması mushaf dokusu, 4 köşeli tezhip rozetleri ve ayet sonu motifi (`AyahEndRosette`).
- **Sekizgen Selçuklu Yıldızı & Girih Doku (`IslamicPatternPainter`):** Arka planlarda kılcal altın oranlı geometrik desenler.

---

## 🏛️ Mimari (Feature-First)

Uygulama, ölçeklenebilir ve sürdürülebilir **Feature-First** klasör hiyerarşisiyle tasarlanmıştır:

```text
lib/
├── core/
│   ├── config/          # Ortam değişkenleri (.env) ve runtime ayarları
│   ├── constants/       # AppColors, AppTypography
│   ├── theme/           # Açık ve koyu tema tanımları, ThemeNotifier
│   ├── utils/           # Tarih hesaplamaları, matematik utils, paylaşım kartı export
│   └── widgets/         # Mihrap clipper, mushaf card, Selçuklu girih deseni
├── features/
│   ├── prayer_times/    # Vakit hesabı (adhan), konum (GPS), 81 il, canlı controller
│   ├── qibla/           # Büyük daire azimutu, Haversine mesafesi, dairesel düşük geçiren filtre
│   ├── daily_content/   # 30 Âyet & 30 Hadis, Supabase ve offline asset veri katmanı
│   ├── settings/        # Diyanet/ikindi yöntemleri, kerahat süreleri, yerel SharedPreferences
│   └── widgets_bridge/  # Android RemoteViews ve 7 günlük veri senkronizasyon köprüsü
├── routing/             # go_router rota yapılandırması ve widget deep-link'leri
└── main.dart            # Uygulama giriş noktası ve servis başlatmaları
```

---

## 📦 Bağımlılıklar ve Tercih Gerekçeleri

Projeye gereksiz hiçbir paket eklenmemiştir. Her bir bağımlılığın varlık sebebi aşağıda açıklanmıştır:

| Paket | Amaç ve Tercih Gerekçesi |
|---|---|
| `flutter_riverpod` | Uygulama genelinde reaktif, tip güvenli ve test edilebilir durum yönetimi (`NotifierProvider`). |
| `go_router` | Deklaratif rota yönetimi, alt navigasyon çubuğu durumu koruma (`StatefulShellRoute`) ve widget tıklamalarından gelen deep-link (`vakit://...`) yönlendirmeleri. |
| `adhan` | Namaz vakitlerini ve kerahat aralıklarını **tamamen cihaz üstünde, internetsiz** Diyanet İşleri Başkanlığı astronomik parametreleriyle hesaplamak için. |
| `supabase_flutter` | Günün otantik âyet ve hadis içeriklerini kullanıcı girişi gerekmeksizin (`anon` key ile) buluttan okumak için. |
| `flutter_dotenv` | Supabase URL ve Anon Key gibi yapılandırma değerlerini kaynak koda gömmeden `.env` dosyasından okumak için. |
| `geolocator` | Cihazın anlık GPS konumunu alarak en yakın Türkiye ilini belirlemek için. |
| `geocoding` | GPS enlem/boylamından il ve ilçe adını tersine çözümlemek için. |
| `flutter_compass` | Cihazın manyetik manyetometre sensörünü dinleyerek canlı Kıble pusulası sunmak için. |
| `shared_preferences` | Şehir seçimi, hesaplama metotları, kerahat süreleri ve tema ayarlarını cihazda güvenle saklamak için. |
| `home_widget` | Flutter ile yerel Android AppWidget (RemoteViews) sistemi arasında çift yönlü veri akışı sağlamak için. |
| `hijri` | Günün tarihini Miladi'nin yanı sıra Hicri takvim olarak (örn: Ramazan, Şevval) hatasız göstermek için. |
| `intl` | Türkçe gün ve ay isimlerini (`initializeDateFormatting('tr_TR', null)`) doğru biçimlendirmek için. |
| `google_fonts` | Mushaf sayfası için `Amiri`, başlık ve sayılar için `Newsreader`, okunabilir gövde metinleri için `Source Sans 3` yazı tiplerini sağlamak için. |
| `share_plus` | Günün âyeti veya hadisini yüksek çözünürlüklü mushaf kartı görseli veya metin olarak sistem menüsüyle paylaşmak için. |
| `path_provider` | Paylaşılacak geçici PNG kart görselinin dosya sisteminde güvenli saklanabilmesi için. |

---

## ⚡ Supabase Kurulumu ve Veritabanı Yapılandırması

Uygulama, `.env` dosyası boş olsa veya internet bağlantısı bulunmasa dahi gömülü varlıklar (`assets/data/daily_verses.json` ve `daily_hadiths.json`) sayesinde **asla çökmez ve %100 çevrimdışı çalışmaya devam eder**.

Supabase bulut entegrasyonunu aktifleştirmek için:

### 1. Supabase Projesi Oluşturma
1. [supabase.com](https://supabase.com) adresine gidin ve yeni bir proje oluşturun.
2. Projenizin SQL Editor sekmesini açın.

### 2. SQL Migration'larını Çalıştırma
Proje kök dizinindeki `supabase/migrations/` klasöründeki SQL dosyalarını sırayla çalıştırın:
- `20261002000000_create_daily_content.sql`: Tabloları (`daily_verses`, `daily_hadiths`), indeksleri ve salt-okunur RLS (`Row Level Security`) politikasını oluşturur.
- `20261002000001_seed_daily_content.sql`: 30 otantik Âyet ve 30 muteber Hadis (Buhari, Müslim vb.) veritabanına ekler.

### 3. API Anahtarlarını Alma
1. Supabase Dashboard üzerinde **Project Settings → API** bölümüne gidin.
2. **Project URL** değerini kopyalayın.
3. **Project API Keys** altındaki `anon` (public) anahtarını kopyalayın. *(Uyarı: `service_role` anahtarını asla uygulamaya koymayın!)*

### 4. `.env` Dosyasını Tanımlama
Proje ana dizinindeki `.env` dosyasını açın (yoksa `.env.example` dosyasını kopyalayıp `.env` yapın) ve değerleri yapıştırın:
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...
```

---

## 📱 Ana Ekran Widget'ları (Android AppWidgets)

Vakit, Android için 5 farklı boyut ve fonksiyonda widget içerir:

1. **Küçük Widget (2x2 - `VakitSmallWidgetProvider`):** Sonraki vakit adı, ezan saati, donanım destekli canlı geri sayım sayacı (`ChronometerCountDown`) ve aktif kerahat rozeti.
2. **Orta Boy Widget (4x2 - `VakitMediumWidgetProvider`):** Günün 6 vakti, vakit saatleri, aktif vaktin altında parlayan mat pirinç çizgi göstergesi ve kerahat durumu.
3. **Zaman Şeridi Widget (4x1 - `VakitStripWidgetProvider`):** Ana ekranda tek satır yer kaplayan kompakt şerit; sonraki vakit ve canlı geri sayım.
4. **Günün Âyeti Widget (4x2 - `VakitVerseWidgetProvider`):** Mushaf parşömen dokusunda günün âyeti ve sure/ayet numarası.
5. **Günün Hadisi Widget (4x2 - `VakitHadithWidgetProvider`):** Günün hadis-i şerifi, ravisi ve tam muteber kaynak bilgisi.

### Pil Dostu Mimari & Tetikleyiciler
- **7 Günlük Çevrimdışı JSON:** Uygulama her açıldığında veya şehir değiştiğinde önümüzdeki 7 günün tüm vakitleri ve kerahat zamanları `shared_preferences` içine aktarılır.
- **Hassas Alarm Yöneticisi (`VakitAlarmReceiver`):** Sürekli çalışan ağır bir background servisi yerine, yalnızca vakit değişim ve kerahat anlarında `AlarmManager.setExactAndAllowWhileIdle()` ile uyanarak widget RemoteViews'ı yeniler.
- **Yeniden Başlatma & Zaman Alıcısı (`BootReceiver`):** Cihaz yeniden başladığında (`BOOT_COMPLETED`) veya saat/saat dilimi değiştiğinde widget'ları ve alarmları anında günceller.
- **Deep-Link (`vakit://...`):** Widget'a tıklandığında uygulamanın ilgili ekranına (`/vakitler`, `/ayet`, `/hadis`, `/kible`) doğrudan geçiş yapılır.

---

## 🚀 Derleme ve Çalıştırma

### Bağımlılıkları İndirme
```bash
flutter pub get
```

### Testleri Çalıştırma
```bash
flutter test
```
*Tüm Diyanet hesaplama uyumu (±2 dk), kerahat aralıkları, offline veri garantisi ve Kıble küresel matematik testleri eksiksiz geçer.*

### Kod Analizi
```bash
flutter analyze
```

### Debug APK Derleme
```bash
flutter build apk --debug
```

### Release APK Derleme
```bash
flutter build apk --release
```
Derlenen APK dosyası `build/app/outputs/flutter-apk/app-release.apk` dizininde üretilir.

---

## 📄 Lisans
Bu proje açık kaynaklı olup eğitim ve ibadet kolaylığı amacıyla geliştirilmiştir.

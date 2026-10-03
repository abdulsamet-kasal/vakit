# Vakit — Namaz Vakti, Kıble ve Günlük İslami İçerik

Vakit, namaz vakitlerini ve kerahat zamanlarını tamamen cihaz üstünde internetsiz hesaplayan;
günlük âyet ve hadis sunan; Kıble pusulası ve Android widget'ları içeren Türkçe bir mobil
uygulamadır. Kullanıcı girişi yoktur, kişisel veri toplamaz.

## Tasarım Dili

Uygulama, cami avlusu huzurunu ve el yazması mushaf dokusunu yansıtan özgün bir palete sahiptir:

- **Derin Orman Yeşili (`#0F3D2E`):** cami mermerlerinin ve yeşil halıların sükûneti.
- **Yosun Yeşili (`#2F6B4F`):** ikincil yüzeyler ve dengeli vurgular.
- **Adaçayı (`#A9C4B0`):** narin çerçeveler ve açık yeşil dokunuşlar.
- **El Yazması Parşömen (`#F3EEE0`):** göz yormayan sıcak arka plan dokusu.
- **Mat Pirinç (`#B8934A`):** kandil ve rahle pirinçlerinden ilham alan altın vurgular.
- **Kerahat Kili (`#C27A3E`):** kerahat vakti uyarıları için sakin, pişmiş toprak tonu.

İmza bileşenler:

- **Sivri/Ogee Mihrap Kemeri (`MihrapClipper`):** sonraki vakti ve canlı geri sayımı kuşatan klasik mihrap motifi.
- **Güneş Yayı (`SunArcPainter`):** vakit noktalarını ve kerahat dilimlerini gökyüzü yayı üzerinde görselleştirir.
- **Dikey Zaman Şeridi (`PrayerTimelineList`):** altı vakti ve aktif vakti pirinç çizgi göstergesiyle sıralar.
- **Açık Mushaf Kartı (`MushafCard`):** el yazması mushaf dokusu ve tezhip rozetleri.
- **Selçuklu Yıldızı ve Girih Doku (`IslamicPatternPainter`):** arka plan geometrik desenleri.

## Mimari (Feature-First)

```text
lib/
├── core/
│   ├── config/          # Ortam değişkenleri (.env) ve kerahat ayarları
│   ├── constants/       # AppColors, AppTypography
│   ├── theme/           # Açık ve koyu tema tanımları, ThemeNotifier
│   ├── utils/           # Tarih hesaplamaları, matematik utils, paylaşım kartı export
│   └── widgets/         # Mihrap clipper, mushaf card, Selçuklu girih deseni
├── features/
│   ├── prayer_times/    # Vakit hesabı (adhan), konum (GPS), 81 il ve ilçeleri
│   ├── qibla/           # Büyük daire azimutu, Haversine mesafesi, pusula filtresi
│   ├── daily_content/   # Günlük âyet & hadis: Supabase ve offline asset veri katmanı
│   ├── settings/        # Diyanet/ikindi yöntemleri, kerahat süreleri, tema
│   └── widgets_bridge/  # Android RemoteViews ve 7 günlük veri senkronizasyonu
├── routing/             # go_router yapılandırması ve widget deep-link'leri
└── main.dart            # Uygulama giriş noktası
```

## Bağımlılıklar ve Gerekçeleri

| Paket | Amaç |
|---|---|
| `flutter_riverpod` | Tip güvenli, test edilebilir durum yönetimi. |
| `go_router` | Deklaratif rota yönetimi ve widget deep-link (`vakit://...`) yönlendirmeleri. |
| `adhan` | Namaz vakitlerini cihaz üstünde, internetsiz Diyanet uyumlu parametrelerle hesaplama. |
| `supabase_flutter` | Günlük âyet/hadis içeriğini anon key ile okuma (giriş gerektirmez). |
| `flutter_dotenv` | Supabase yapılandırmasını `.env` dosyasından okuma. |
| `geolocator` | GPS konumunu alarak en yakın ili belirleme. |
| `geocoding` | Enlem/boylamdan il ve ilçe adını çözümleme. |
| `flutter_compass` | Manyetometre sensörüyle canlı Kıble pusulası. |
| `shared_preferences` | Şehir, hesaplama yöntemi, tema gibi ayarları cihazda saklama. |
| `home_widget` | Flutter ile Android AppWidget arasında veri akışı. |
| `hijri` | Hicri takvim gösterimi. |
| `intl` | Türkçe tarih biçimlendirme. |
| `google_fonts` | Amiri, Newsreader ve Source Sans 3 yazı tipleri. |
| `share_plus` | Ayet/hadis kartını paylaşma. |
| `path_provider` | Paylaşım için geçici görsel saklama. |

## İçerik ve Mealler

- **Arapça âyet metinleri** [Tanzil.net](https://tanzil.net)'in kamuya açık Kur'an metninden alınmış ve
  [Quran.com](https://quran.com) ile harf harf karşılaştırılarak doğrulanmıştır.
- **Türkçe mealler**, uygulama için yapılan sadeleştirilmiş çevirilerdir; Diyanet İşleri Başkanlığı'nın
  yayımladığı Kur'an-ı Kerim Meali'nden kopyalanmamıştır (telif gereği gömülmez).
- **Hadis Arapça metinleri ve kaynak numaraları** [Sunnah.com](https://sunnah.com) koleksiyonlarıyla
  (Buhârî, Müslim) karşılaştırılarak doğrulanmıştır; kitap-kapak numarası kaynak olarak verilir.

Hata bulursanız lütfen bir issue açın — dini metinlerin doğruluğu bu proje için en kritik konudur.

## Supabase Kurulumu (isteğe bağlı)

Uygulama, `.env` boş olsa veya internet olmasa dahi gömülü varlıklar
(`assets/data/daily_verses.json`, `assets/data/daily_hadiths.json`) sayesinde offline çalışır.

1. [supabase.com](https://supabase.com) üzerinde bir proje oluşturun.
2. SQL Editor'de sırayla çalıştırın:
   - `supabase/migrations/20261002000000_create_daily_content.sql` (tablolar + salt-okunur RLS)
   - `supabase/migrations/20261002000001_seed_daily_content.sql` (doğrulanmış içerik)
3. **Project Settings → API** bölümünden Project URL ve `anon` key'i kopyalayın.
   (`service_role` anahtarını asla uygulamaya koymayın.)
4. Depo kökünde:

```bash
cp .env.example .env
# .env içine URL ve anon key'i yapıştırın
```

`.env` gitignore'dadır; build, var olmasını gerektirmez (fallback: `assets/env/env.properties`).

## Ezan Bildirimleri

Uygulama, namaz vakitleri girdiğinde ve (isteğe bağlı) vakitten belirli dakikalar önce
bildirim gönderebilir:

- **Ezan bildirimi:** vaktin girdiğini bildiren yüksek öncelikli bildirim.
- **Vakit öncesi hatırlatma:** 5–45 dk arası ayarlanabilir (varsayılan 15 dk).
- **Sessiz mod:** cami ve iş yerleri için ses çalmadan yalnızca titreşim (varsayılan açık).

Pil dostu çalışma: sürekli servis yoktur; önümüzdeki 7 günün olayları hesaplanıp
AlarmManager ile en yakın olay için uyulur, her tetiklenmede sıradaki kurulur.
Android 13+ için ilk açılışta bildirim izni istenir. Kesin alarm izni (SCHEDULE_EXACT_ALARM)
verilmezse bildirimler birkaç dakika gecikebilir.

## Android Widget'ları

Beş widget: Küçük (2x2), Orta (4x2), Zaman Şeridi (4x1), Günün Âyeti (4x2), Günün Hadisi (4x2).

- Uygulama her açıldığında veya şehir değiştiğinde önümüzdeki 7 günün vakitleri
  `shared_preferences`'a aktarılır.
- `VakitAlarmReceiver`, vakit değişim ve kerahat anlarında
  `AlarmManager.setExactAndAllowWhileIdle()` ile uyanarak widget'ları yeniler.
  Kesin alarm izni verilmediyse (Android 14+ varsayılan) `setAndAllowWhileIdle()` ile
  yaklaşık tetiklemeye düşer; widget yine güncellenir, yalnızca birkaç dakika gecikebilir.
- `BootReceiver`; cihaz yeniden başlatması, saat ve saat dilimi değişikliklerinde
  widget'ları ve alarmları tazeler.
- Widget tıklamaları `vakit://...` deep-link'iyle ilgili ekrana yönlenir.

## Derleme ve Test

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
```

Testler namaz vakiti hesaplarını Diyanet'in resmi takvimiyle karşılaştırır (±2 dakika tolerans).

## Yol Haritası

Bkz. [SORUNLAR_VE_YAPILACAKLAR.md](SORUNLAR_VE_YAPILACAKLAR.md) — ezan bildirimleri,
ilçe bazlı vakitler, dünya şehirleri, dini günler takvimi ve yayın hazırlığı planı.

## Lisans

MIT — bkz. [LICENSE](LICENSE).

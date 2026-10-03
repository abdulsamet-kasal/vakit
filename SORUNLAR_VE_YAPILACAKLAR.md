# Vakit — Düzeltme Listesi ve Yol Haritası

> Bu dosya projenin mevcut durumu, tespit edilen sorunlar ve yapılacak işlerin sırası için
> çalışma listesidir. Her madde bittiğinde üstünü çiz (`~~madde~~`) veya tamamlandı olarak işaretle.

## Durum Özeti (03.10.2026 çalışması)

- `flutter analyze` temiz, `flutter test` 27/27 geçiyor (yeni Diyanet geniş-uyum testi dahil).
- Taze klonda build hatası giderildi (asset env fallback).
- 30/30 âyet Tanzil metniyle birebir doğrulandı; 3 yarım âyet tam metne çevrildi.
- 8 hadiste Arapça/çeviri/kaynak düzeltmesi yapıldı (bkz. 2.1).
- Manifest'ten USE_EXACT_ALARM kaldırıldı; exact alarm fallback netleştirildi.
- linux/macos/windows/web klasörleri silindi.
- LICENSE (MIT) eklendi, README sadeleştirildi.

---

## 1. İyi Olan Kısımlar (dokunma)

- **Mimari düzenli:** feature-first yapı, Riverpod, go_router.
- **Offline-first mantığı doğru:** önbellek → Supabase → gömülü asset sırası.
- **Widget mimarisi doğru:** 7 günlük veri shared_preferences'a aktarılıp
  AlarmManager ile tetikleniyor; Chronometer ile canlı geri sayım.
- **Paket gerekçeleri ve Supabase kurulum anlatımı** README'de mevcut.
- **`service_role` uyarısı ve `.env.example`** yerinde.

---

## 2. Kritik Düzeltmeler

### 2.1. Ayet ve hadis doğruluğu (EN KRİTİK) — ✅ tamamlandı (03.10.2026)
- [x] Tüm 30 âyetin Arapça metni Tanzil (Imlaei) metniyle harf harf karşılaştırıldı (normalize
      ederek): **30/30 birebir uyumlu**. Düzeltmeler:
      - id=3 (Bakara 186), id=4 (Bakara 286), id=8 (Tevbe 129), id=13 (Tâhâ 114), id=18 (Zümer 53):
        yarım/kırpılmış metinler tam âyetle değiştirildi.
      - id=28, 29, 30 (Asr, İhlâs, Nâs): kaynak verideki Basmala öndeki âyet metniyle
        birleştirilerek tam sure metni kuruldu; kaynak adları "1-3"/"1-4"/"1-6" olarak düzeltildi.
      - Not: Mushaf'ta İhlâs'in 2. âyeti "Allahü's-Samed" diye okunur; Tanzil imlâ metninde
        "Allahü'l-Samed" yazılır (aynı kıraat, farklı imlâ). Uygulama Tanzil imlâsını kullanır.
- [x] Hadis düzeltmeleri (Sunnah.com/ilmify.net koleksiyon numaralarıyla karşılaştırıldı):
      - id=6: "Namaz nurdur..." Buhârî Enbiyâ değil, Müslim Müsâfirûn 265'tir; tam metin yazıldı.
      - id=7: eksik "lâ tenâceşû ve lâ tedâberû" cümleleri eklendi.
      - id=8: eksik "ve hâlikin-nâse bi-hulukin hasen" cümlesi eklendi (Tirmizî Birr 55).
      - id=10: eksik ikinci zikir "Sübhânallâhi'l-azîm" eklendi.
      - id=23: ravi düzeltildi (Tirmizî Zühd 11 rivayeti Ebû Hüreyre'dendir).
      - id=25: Arapça metin mealin anlattığı tam hadisle (Müslim Îmân 93) eşleştirildi.
      - id=26: yarım Arapça tamamlandı (beş hak listesi, Buhârî Cenâiz 2).
      - id=28: eksik "ve tedfeu mîyete's-sû" eklendi; mealdeki Arapçada olmayan "gizlice"
        ifadesi kaldırıldı (Tirmizî Zekât 28).
- [x] Meal telifi: README'ye "mealler uygulama içi sadeleştirilmiş çeviridir, Diyanet mealinden
      kopyalanmamıştır" notu eklendi; LICENSE'e de ek not yazıldı.
- [x] Veriler güncellendi: `assets/data/*.json` ve `supabase/migrations/20261002000001_seed_daily_content.sql`
      (seed artık JSON'dan otomatik üretiliyor; tekrar üretmek için repo kökünde Python betiği kullanılabilir).

### 2.2. Taze klonda derleme hatası (.env / pubspec) — ✅ tamamlandı
- [x] `pubspec.yaml`'da `- .env` → `- assets/env/` yapıldı.
- [x] `lib/core/config/env_config.dart`: önce gerçek `.env`, yoksa `assets/env/env.properties`
      (boş şablon) yüklenir; ikisi de olamazsa offline moda sessiz geçer.
- [x] `assets/env/env.properties` eklendi, `.env.example` açıklamalandı, README'ye kopyalama adımı yazıldı.

### 2.3. Android 12+ kesin alarm izni — ✅ çekirdek düzeltme tamam, UI uyarısı kaldı
- [x] Manifest'ten `USE_EXACT_ALARM` kaldırıldı (uygulama alarm/saat uygulaması olmadığı için
      Play politikası gereği uygun değil). `SCHEDULE_EXACT_ALARM` bırakıldı, gerekçe yorum olarak yazıldı.
- [x] `POST_NOTIFICATIONS` izni eklendi (Android 13+ bildirimler için; ezan bildirimi özelliğinin ön şartı).
- [x] Kotlin `scheduleNextAlarm`: Android 12+ önce `canScheduleExactAlarms()` kontrolü yapar;
      izin varsa `setExactAndAllowWhileIdle`, yoksa `setAndAllowWhileIdle` (widget birkaç dk
      gecikebilir ama güncellenir); SecurityException durumunda da inexact fallback var.
- [ ] Kalan: Ayarlar ekranında "kesin alarm izni yok" uyarısı + `ACTION_REQUEST_SCHEDULE_EXACT_ALARM`
      ile ayarlara yönlendirme.
- [ ] Kalan: Android 13+ için çalışma zamanında `POST_NOTIFICATIONS` izin akışı.

### 2.4. Test ve analiz doğrulaması — ✅ tamamlandı
- [x] `flutter analyze`: **0 sorun**.
- [x] `flutter test`: **27/27 geçiyor**.
- [x] Diyanet uyumu 7 ilde bağımsız referansla karşılaştırıldı: İstanbul, Ankara, Erzurum,
      İzmir, Diyarbakır, Hakkâri, Edirne (02.10.2026, AlAdhan API method=13 = Diyanet yöntemi).
      **Tüm vakitler ±2 dk içinde uyumlu.** Yeni test:
      `test/features/prayer_times/diyanet_turkey_wide_test.dart`
      (not: ilk denemede kullanılan uydurma/elle yazma referans değerler API'den doğrulanmış
      gerçek değerlerle değiştirildi; test verileri artık izlenebilir kaynaktan geliyor).

### 2.5. Gereksiz platform klasörleri — ✅ tamamlandı
- [x] `linux/`, `macos/`, `windows/`, `web/` silindi.

### 2.6. Lisans — ✅ tamamlandı
- [x] MIT LICENSE eklendi (dini içerik notuyla birlikte).
- [x] README emoji ve abartılı ifadelerden arındırıldı; iç doğruluk notları eklendi.

---

## 3. Eklenecek Özellikler (önem sırasıyla)

### Öncelik 1 — Neredeyse şart
- [ ] **Ezan bildirimi ve vakit öncesi hatırlatma** (örn. 15 dk kala).
      Namaz uygulamalarında en çok kullanılan özellik.
- [ ] **Ezan sesi seçimi ve bildirim kanalı ayarları.**
- [ ] **Sessize alma / titreşim modu önerisi** (cami ve iş saatleri için).
- [ ] **Aylık vakit takvimi ekranı.**

### Öncelik 2 — Değer katacaklar
- [ ] Dini günler ve geceler takvimi (kandiller, bayramlar, Ramazan başlangıcı, hicri yıl).
- [ ] Ramazan modu: imsakiye, iftara kalan süre, sahur bildirimi.
- [ ] Namaz takibi ve kaza borcu sayacı, haftalık seri görünümü.
- [ ] Cuma hatırlatması ve Cuma günü özel ana ekran görünümü.
- [ ] Dua ve Esmaül Hüsna bölümü, zikirmatik.
- [ ] Favori ayet/hadis kaydetme ve geçmiş günlere bakma.
- [ ] Widget yapılandırması: tema (açık/koyu/şeffaf) ve şehir seçimi.
- [ ] Kıble: harita üzerinde gösterme, sensör doğruluğu uyarısı (mevcut),
      isteğe bağlı kamera/AR görünümü.

### Öncelik 3 — Teknik iyileştirmeler
- [ ] Supabase içeriğini 366 güne çıkarmak (şu an 30 → yılın günü modulo ile tekrar ediyor).
- [ ] Uzaktan içerik güncellemesi: yeni ayet/hadis eklemek uygulama güncellemesi gerektirmesin.
- [ ] GitHub Actions: her push'ta `flutter analyze` + `flutter test`.
- [ ] Hata takibi: Crashlytics veya Sentry (gizlilik politikasına yaz).
- [ ] Çoklu dil: en azından İngilizce ve Arapça (ayet/hadis arayüzü).
- [ ] Erişilebilirlik: büyük yazı boyutu, TalkBack etiketleri, kontrast testi.
- [ ] Widget testleri ve golden testler (özellikle mihrap paneli ve güneş yayı).

### Öncelik 4 — Yayın hazırlığı
- [ ] Release keystore + signing config.
- [ ] applicationId gözden geçirme (`com.vakit.vakit`).
- [ ] Uygulama ikonu ve açılış ekranı.
- [ ] Gizlilik politikası sayfası.
- [ ] Mağaza görselleri (ekran görüntüleri, öne çıkan görsel).
- [ ] iOS widget (WidgetKit) — iOS'a çıkılacaksa ayrı bir iş.

---

## 4. Önerilen Çalışma Sırası

1. ~~**Ayet/hadis doğrulaması** → alarm izni → `.env` build sorunu~~ ✅ **(03.10.2026'da yapıldı)**
2. **Ezan bildirimleri** ← *sıradaki*
3. **İlçe seçimi ve dünya şehirleri**
4. **Dini günler takvimi ve aylık takvim**
5. **Yayın hazırlığı** (ikon, keystore, gizlilik politikası)

---

## 5. Notlar

- Konum/district altyapısı hazır (`DistrictData`, ilçe seçim UI var) — dünya şehirleri
  için `CityModel`'in genişletilmesi yeterli olabilir.
- `adhan` paketi Diyanet parametrelerini içeriyor; Diyanet'in resmi takvimiyle yapılan
  karşılaştırmada ±2 dk üzerinde sapma görülürse custom `CalculationParameters`
  ile düzeltme değerleri (offset) eklenmeli.

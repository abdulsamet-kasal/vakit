import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../widgets_bridge/home_widget_service.dart';
import '../../data/location_service.dart';
import '../../data/prayer_calculator.dart';
import '../../domain/city_model.dart';
import '../../domain/prayer_times_model.dart';
import '../widgets/kerahat_badge.dart';

class PrayerTimesState {
  final DateTime selectedDate;
  final CityModel selectedCity;
  final PrayerTimesModel times;
  final PrayerTimesModel tomorrowTimes;
  final DateTime currentTime;
  final String countdownString;
  final PrayerName currentPrayer;
  final PrayerName nextPrayer;
  final String nextPrayerTimeFormatted;
  final KerahatType activeKerahat;
  final double? sunProgress;
  final bool isLoadingLocation;

  const PrayerTimesState({
    required this.selectedDate,
    required this.selectedCity,
    required this.times,
    required this.tomorrowTimes,
    required this.currentTime,
    required this.countdownString,
    required this.currentPrayer,
    required this.nextPrayer,
    required this.nextPrayerTimeFormatted,
    required this.activeKerahat,
    required this.sunProgress,
    this.isLoadingLocation = false,
  });

  bool get isToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  PrayerTimesState copyWith({
    DateTime? selectedDate,
    CityModel? selectedCity,
    PrayerTimesModel? times,
    PrayerTimesModel? tomorrowTimes,
    DateTime? currentTime,
    String? countdownString,
    PrayerName? currentPrayer,
    PrayerName? nextPrayer,
    String? nextPrayerTimeFormatted,
    KerahatType? activeKerahat,
    double? sunProgress,
    bool? isLoadingLocation,
  }) {
    return PrayerTimesState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedCity: selectedCity ?? this.selectedCity,
      times: times ?? this.times,
      tomorrowTimes: tomorrowTimes ?? this.tomorrowTimes,
      currentTime: currentTime ?? this.currentTime,
      countdownString: countdownString ?? this.countdownString,
      currentPrayer: currentPrayer ?? this.currentPrayer,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      nextPrayerTimeFormatted: nextPrayerTimeFormatted ?? this.nextPrayerTimeFormatted,
      activeKerahat: activeKerahat ?? this.activeKerahat,
      sunProgress: sunProgress ?? this.sunProgress,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
    );
  }
}

/// Namaz vakitlerini ve saniye saniye canlı geri sayımı yöneten modern Riverpod [Notifier].
class PrayerTimesNotifier extends Notifier<PrayerTimesState> {
  Timer? _tickerTimer;
  static const _prefCityIdKey = 'selected_city_id';
  static const _prefCityNameKey = 'selected_city_name';
  static const _prefCityLatKey = 'selected_city_lat';
  static const _prefCityLngKey = 'selected_city_lng';

  @override
  PrayerTimesState build() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const initialCity = CityModel.defaultCity;

    final initialTimes = PrayerCalculator.calculate(
      city: initialCity,
      date: today,
    );
    final tomorrow = today.add(const Duration(days: 1));
    final tomorrowTimes = PrayerCalculator.calculate(
      city: initialCity,
      date: tomorrow,
    );

    final (next, nextTime) = initialTimes.getNextPrayer(now, tomorrowTimes: tomorrowTimes);
    final remaining = initialTimes.getTimeUntilNext(now, tomorrowTimes: tomorrowTimes);

    // 1 saniyelik canlı sayaç başlat
    _startTicker();

    // Kayıtlı şehri arka planda yükle
    _loadSavedCity();

    // Widget senkronizasyonunu ilk açılışta tetikle
    Future.microtask(() => HomeWidgetService.syncAllWidgets(city: initialCity));

    ref.onDispose(() {
      _tickerTimer?.cancel();
    });

    return PrayerTimesState(
      selectedDate: today,
      selectedCity: initialCity,
      times: initialTimes,
      tomorrowTimes: tomorrowTimes,
      currentTime: now,
      countdownString: DateTimeUtils.formatCountdown(remaining),
      currentPrayer: initialTimes.getCurrentPrayer(now),
      nextPrayer: next,
      nextPrayerTimeFormatted: DateTimeUtils.formatTime(nextTime),
      activeKerahat: initialTimes.getActiveKerahat(now),
      sunProgress: initialTimes.getSunProgress(now),
    );
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });
  }

  void _tick() {
    final now = DateTime.now();
    // Geri sayım sadece bugün seçiliyken gerçek zamanlı akar
    final isViewingToday = state.isToday;
    final referenceTime = isViewingToday ? now : state.times.imsak;

    final (next, nextTime) = state.times.getNextPrayer(
      referenceTime,
      tomorrowTimes: state.tomorrowTimes,
    );
    final remaining = state.times.getTimeUntilNext(
      referenceTime,
      tomorrowTimes: state.tomorrowTimes,
    );

    state = state.copyWith(
      currentTime: now,
      countdownString: DateTimeUtils.formatCountdown(remaining),
      currentPrayer: state.times.getCurrentPrayer(referenceTime),
      nextPrayer: next,
      nextPrayerTimeFormatted: DateTimeUtils.formatTime(nextTime),
      activeKerahat: state.times.getActiveKerahat(referenceTime),
      sunProgress: state.times.getSunProgress(referenceTime),
    );
  }

  Future<void> _loadSavedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cityId = prefs.getInt(_prefCityIdKey);
      final cityName = prefs.getString(_prefCityNameKey);
      final lat = prefs.getDouble(_prefCityLatKey);
      final lng = prefs.getDouble(_prefCityLngKey);

      if (cityName != null && lat != null && lng != null) {
        final savedCity = CityModel(
          id: cityId ?? 0,
          name: cityName,
          latitude: lat,
          longitude: lng,
        );
        changeCity(savedCity, saveToPrefs: false);
      }
    } catch (_) {}
  }

  Future<void> changeCity(CityModel city, {bool saveToPrefs = true}) async {
    final newTimes = PrayerCalculator.calculate(
      city: city,
      date: state.selectedDate,
    );
    final tomorrow = state.selectedDate.add(const Duration(days: 1));
    final newTomorrowTimes = PrayerCalculator.calculate(
      city: city,
      date: tomorrow,
    );

    state = state.copyWith(
      selectedCity: city,
      times: newTimes,
      tomorrowTimes: newTomorrowTimes,
    );
    _tick();

    if (saveToPrefs) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_prefCityIdKey, city.id);
        await prefs.setString(_prefCityNameKey, city.name);
        await prefs.setDouble(_prefCityLatKey, city.latitude);
        await prefs.setDouble(_prefCityLngKey, city.longitude);
      } catch (_) {}
    }

    // Şehir değişiminde widget'ları anında güncelle
    HomeWidgetService.syncAllWidgets(city: city);
  }

  void changeDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final newTimes = PrayerCalculator.calculate(
      city: state.selectedCity,
      date: normalized,
    );
    final tomorrow = normalized.add(const Duration(days: 1));
    final newTomorrowTimes = PrayerCalculator.calculate(
      city: state.selectedCity,
      date: tomorrow,
    );

    state = state.copyWith(
      selectedDate: normalized,
      times: newTimes,
      tomorrowTimes: newTomorrowTimes,
    );
    _tick();
  }

  void previousDay() {
    changeDate(state.selectedDate.subtract(const Duration(days: 1)));
  }

  void nextDay() {
    changeDate(state.selectedDate.add(const Duration(days: 1)));
  }

  void goToToday() {
    final now = DateTime.now();
    changeDate(DateTime(now.year, now.month, now.day));
  }

  Future<bool> detectGpsLocation() async {
    state = state.copyWith(isLoadingLocation: true);
    final city = await LocationService.getCurrentCity();
    state = state.copyWith(isLoadingLocation: false);

    if (city != null) {
      await changeCity(city);
      return true;
    }
    return false;
  }
}

final prayerTimesProvider =
    NotifierProvider<PrayerTimesNotifier, PrayerTimesState>(
  PrayerTimesNotifier.new,
);

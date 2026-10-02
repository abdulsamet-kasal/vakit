import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/utils/math_utils.dart';
import '../../../prayer_times/presentation/controllers/prayer_times_controller.dart';
import '../../data/compass_service.dart';

class QiblaState {
  final bool hasSensor;
  final bool isLoading;
  final bool isLiveTracking;
  final double heading;
  final double qiblaBearing;
  final double distanceKm;
  final bool isAligned;
  final double? accuracy;
  final bool needsCalibration;

  const QiblaState({
    required this.hasSensor,
    this.isLoading = false,
    this.isLiveTracking = false,
    required this.heading,
    required this.qiblaBearing,
    required this.distanceKm,
    required this.isAligned,
    this.accuracy,
    this.needsCalibration = false,
  });

  /// Kadranın dönmesi gereken açı (Kıbleyi tepeye almak için)
  double get dialRotationDegrees => (360.0 - heading) % 360.0;

  /// Kıble ibresinin pusula halkasındaki mutlak açısı
  double get qiblaAngleOffset => (qiblaBearing - heading + 360.0) % 360.0;

  QiblaState copyWith({
    bool? hasSensor,
    bool? isLoading,
    bool? isLiveTracking,
    double? heading,
    double? qiblaBearing,
    double? distanceKm,
    bool? isAligned,
    double? accuracy,
    bool? needsCalibration,
  }) {
    return QiblaState(
      hasSensor: hasSensor ?? this.hasSensor,
      isLoading: isLoading ?? this.isLoading,
      isLiveTracking: isLiveTracking ?? this.isLiveTracking,
      heading: heading ?? this.heading,
      qiblaBearing: qiblaBearing ?? this.qiblaBearing,
      distanceKm: distanceKm ?? this.distanceKm,
      isAligned: isAligned ?? this.isAligned,
      accuracy: accuracy ?? this.accuracy,
      needsCalibration: needsCalibration ?? this.needsCalibration,
    );
  }
}

class QiblaNotifier extends Notifier<QiblaState> {
  final _compassService = CompassService();
  StreamSubscription? _compassSubscription;
  Timer? _calibrationPromptTimer;
  bool _wasAligned = false;
  bool _firstHeadingReceived = false;
  bool _disposed = false;

  // Yeniden kurulumlar arasında korunacak sensör durumu.
  // Böylece kontrolcü yeniden kurulsa bile pusula akışı ve açılar bozulmaz.
  double _lastHeading = 0.0;
  double? _lastAccuracy;
  bool _isLiveTracking = false;
  bool _needsCalibration = false;
  bool _isLoading = false;
  double? _activeBearing;

  @override
  QiblaState build() {
    // KRİTİK DÜZELTME: prayerTimesProvider'ın tamamı watch edilemez; state
    // 1 saniyelik canlı sayaç nedeniyle sürekli değişir ve bu kontrolcüyü
    // saniyede bir yeniden kurup pusulayı sürekli 0°'a sıfırlayan hataya
    // yol açıyordu. Yalnızca seçili şehir (kıble açısını etkileyen tek
    // değer) select ile izlenir; rebuild yalnızca şehir değişince olur.
    final city = ref.watch(
      prayerTimesProvider.select((s) => s.selectedCity),
    );

    final bearing = MathUtils.calculateQiblaBearing(
      city.latitude,
      city.longitude,
    );
    final distance = MathUtils.calculateKaabaDistanceKm(
      city.latitude,
      city.longitude,
    );

    ref.onDispose(() {
      _disposed = true;
      _calibrationPromptTimer?.cancel();
      _compassSubscription?.cancel();
      _compassSubscription = null;
      _activeBearing = null;
    });

    // Sensör akışı yalnızca ilk kurulumda veya kıble açısı (şehir)
    // değiştiğinde baştan kurulur; aksi halde mevcut akış olduğu gibi akar.
    if (_compassSubscription == null || _activeBearing != bearing) {
      _activeBearing = bearing;
      _firstHeadingReceived = false;
      _initCompass(bearing);
    }

    return QiblaState(
      hasSensor: true,
      isLoading: _isLoading,
      isLiveTracking: _isLiveTracking,
      heading: _lastHeading,
      qiblaBearing: bearing,
      distanceKm: distance,
      isAligned:
          _isLiveTracking && MathUtils.isQiblaAligned(_lastHeading, bearing),
      accuracy: _lastAccuracy,
      needsCalibration: _needsCalibration,
    );
  }

  Future<void> _initCompass(double bearing) async {
    await _requestPermissionIfNeeded();

    // İzin akışı sürerken şehir değiştiyse veya ekran kapandıysa baştan kurma
    if (_disposed || _activeBearing != bearing) return;

    _startCompassListener(bearing);
  }

  Future<void> _requestPermissionIfNeeded() async {
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    } catch (_) {}
  }

  void _startCompassListener(double qiblaBearing) {
    _compassSubscription?.cancel();
    _compassSubscription = null;
    _calibrationPromptTimer?.cancel();
    _firstHeadingReceived = false;

    // 4 saniye içinde veri gelmezse kullanıcıya 8 çizme kalibrasyon rehberi göster
    _calibrationPromptTimer = Timer(const Duration(milliseconds: 4000), () {
      if (!_firstHeadingReceived && !_disposed) {
        _needsCalibration = true;
        state = state.copyWith(needsCalibration: true);
      }
    });

    try {
      _compassSubscription = _compassService.compassStream.listen(
        (CompassHeading headingData) {
          if (_disposed) return;
          final rawHeading = headingData.heading;

          _firstHeadingReceived = true;
          _calibrationPromptTimer?.cancel();

          // 0..360 aralığına normalize et
          final normalized = (rawHeading % 360.0 + 360.0) % 360.0;
          final smoothed = MathUtils.filterHeading(_lastHeading, normalized);
          final aligned = MathUtils.isQiblaAligned(smoothed, state.qiblaBearing);

          if (aligned && !_wasAligned) {
            HapticFeedback.mediumImpact();
          }
          _wasAligned = aligned;

          final acc = headingData.accuracy;
          final needsCalib = acc != null && acc > 25.0;

          _lastHeading = smoothed;
          _lastAccuracy = acc;
          _isLiveTracking = true;
          _needsCalibration = needsCalib;
          _isLoading = false;

          state = state.copyWith(
            hasSensor: true,
            isLoading: false,
            isLiveTracking: true,
            heading: smoothed,
            isAligned: aligned,
            accuracy: acc,
            needsCalibration: needsCalib,
          );
        },
        onError: (_) {
          if (_disposed) return;
          _needsCalibration = true;
          _isLiveTracking = false;
          state = state.copyWith(isLiveTracking: false, needsCalibration: true);
        },
      );
    } catch (_) {
      if (_disposed) return;
      _isLiveTracking = false;
      _needsCalibration = true;
      state = state.copyWith(isLiveTracking: false, needsCalibration: true);
    }
  }

  void updateManualHeading(double degrees) {
    final normalized = (degrees % 360.0 + 360.0) % 360.0;
    final aligned = MathUtils.isQiblaAligned(normalized, state.qiblaBearing);
    _lastHeading = normalized;
    _isLiveTracking = true;
    state = state.copyWith(
      heading: normalized,
      isAligned: aligned,
    );
  }

  Future<void> retrySensors() async {
    _isLoading = true;
    _needsCalibration = false;
    _isLiveTracking = false;
    state = state.copyWith(
      isLoading: true,
      needsCalibration: false,
      isLiveTracking: false,
    );

    await _requestPermissionIfNeeded();
    if (_disposed) return;

    _startCompassListener(state.qiblaBearing);
  }
}

final qiblaProvider = NotifierProvider<QiblaNotifier, QiblaState>(
  QiblaNotifier.new,
);

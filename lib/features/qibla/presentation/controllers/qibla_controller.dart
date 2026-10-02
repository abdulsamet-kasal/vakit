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

  @override
  QiblaState build() {
    final prayerState = ref.watch(prayerTimesProvider);
    final lat = prayerState.selectedCity.latitude;
    final lng = prayerState.selectedCity.longitude;

    final bearing = MathUtils.calculateQiblaBearing(lat, lng);
    final distance = MathUtils.calculateKaabaDistanceKm(lat, lng);

    ref.onDispose(() {
      _disposed = true;
      _compassSubscription?.cancel();
      _calibrationPromptTimer?.cancel();
    });

    _initCompass(bearing);

    return QiblaState(
      hasSensor: true,
      isLoading: false,
      isLiveTracking: false,
      heading: 0.0,
      qiblaBearing: bearing,
      distanceKm: distance,
      isAligned: false,
    );
  }

  Future<void> _initCompass(double bearing) async {
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    } catch (_) {}

    _startCompassListener(bearing);
  }

  void _startCompassListener(double qiblaBearing) {
    _compassSubscription?.cancel();
    _calibrationPromptTimer?.cancel();
    _firstHeadingReceived = false;

    // 4 saniye içinde veri gelmezse kullanıcıya 8 çizme kalibrasyon rehberi göster
    _calibrationPromptTimer = Timer(const Duration(milliseconds: 4000), () {
      if (!_firstHeadingReceived && !_disposed) {
        state = state.copyWith(needsCalibration: true);
      }
    });

    try {
      _compassSubscription = _compassService.compassStream.listen(
        (CompassHeading headingData) {
          final rawHeading = headingData.heading;

          _firstHeadingReceived = true;
          _calibrationPromptTimer?.cancel();

          // 0..360 aralığına normalize et
          final normalized = (rawHeading % 360.0 + 360.0) % 360.0;
          final smoothed = MathUtils.filterHeading(state.heading, normalized);
          final aligned = MathUtils.isQiblaAligned(smoothed, state.qiblaBearing);

          if (aligned && !_wasAligned) {
            HapticFeedback.mediumImpact();
          }
          _wasAligned = aligned;

          final acc = headingData.accuracy;
          final needsCalib = acc != null && acc > 25.0;

          if (!_disposed) {
            state = state.copyWith(
              hasSensor: true,
              isLoading: false,
              isLiveTracking: true,
              heading: smoothed,
              isAligned: aligned,
              accuracy: acc,
              needsCalibration: needsCalib,
            );
          }
        },
        onError: (_) {
          if (!_disposed) {
            state = state.copyWith(isLiveTracking: false, needsCalibration: true);
          }
        },
      );
    } catch (_) {
      if (!_disposed) {
        state = state.copyWith(isLiveTracking: false, needsCalibration: true);
      }
    }
  }

  void updateManualHeading(double degrees) {
    final normalized = (degrees % 360.0 + 360.0) % 360.0;
    final aligned = MathUtils.isQiblaAligned(normalized, state.qiblaBearing);
    state = state.copyWith(
      heading: normalized,
      isAligned: aligned,
    );
  }

  Future<void> retrySensors() async {
    state = state.copyWith(isLoading: true);
    _startCompassListener(state.qiblaBearing);
  }
}

final qiblaProvider = NotifierProvider<QiblaNotifier, QiblaState>(
  QiblaNotifier.new,
);

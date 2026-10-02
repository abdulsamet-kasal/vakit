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
  final bool permissionDenied;
  final double heading;
  final double qiblaBearing;
  final double distanceKm;
  final bool isAligned;
  final double? accuracy;
  final bool needsCalibration;

  const QiblaState({
    required this.hasSensor,
    this.isLoading = false,
    this.permissionDenied = false,
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
    bool? permissionDenied,
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
      permissionDenied: permissionDenied ?? this.permissionDenied,
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
  Timer? _sensorTimeoutTimer;
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
      _sensorTimeoutTimer?.cancel();
    });

    _initCompass(bearing);

    return QiblaState(
      hasSensor: true,
      isLoading: true,
      permissionDenied: false,
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
        final req = await Geolocator.requestPermission();
        if (req == LocationPermission.denied || req == LocationPermission.deniedForever) {
          if (!_disposed) {
            state = state.copyWith(isLoading: false, permissionDenied: true);
          }
          return;
        }
      } else if (perm == LocationPermission.deniedForever) {
        if (!_disposed) {
          state = state.copyWith(isLoading: false, permissionDenied: true);
        }
        return;
      }
    } catch (_) {}

    _startCompassListener(bearing);
  }

  void _startCompassListener(double qiblaBearing) {
    _compassSubscription?.cancel();
    _sensorTimeoutTimer?.cancel();
    _firstHeadingReceived = false;

    // 2.5 saniye içinde hiçbir sensör verisi gelmezse sensör yok moduna geç
    _sensorTimeoutTimer = Timer(const Duration(milliseconds: 2500), () {
      if (!_firstHeadingReceived && !_disposed) {
        state = state.copyWith(hasSensor: false, isLoading: false);
      }
    });

    final stream = _compassService.compassStream;
    if (stream == null) {
      if (!_disposed) {
        state = state.copyWith(hasSensor: false, isLoading: false);
      }
      return;
    }

    _compassSubscription = stream.listen(
      (event) {
        final rawHeading = event.heading;
        if (rawHeading == null) {
          if (!_firstHeadingReceived && !_disposed) {
            state = state.copyWith(hasSensor: false, isLoading: false);
          }
          return;
        }

        _firstHeadingReceived = true;
        _sensorTimeoutTimer?.cancel();

        // 0..360 aralığına normalize et
        final normalized = (rawHeading % 360.0 + 360.0) % 360.0;
        final smoothed = MathUtils.filterHeading(state.heading, normalized);
        final aligned = MathUtils.isQiblaAligned(smoothed, state.qiblaBearing);

        if (aligned && !_wasAligned) {
          HapticFeedback.mediumImpact();
        }
        _wasAligned = aligned;

        final acc = event.accuracy;
        final needsCalib = acc != null && acc > 25.0;

        if (!_disposed) {
          state = state.copyWith(
            hasSensor: true,
            isLoading: false,
            permissionDenied: false,
            heading: smoothed,
            isAligned: aligned,
            accuracy: acc,
            needsCalibration: needsCalib,
          );
        }
      },
      onError: (_) {
        if (!_disposed) {
          state = state.copyWith(hasSensor: false, isLoading: false);
        }
      },
    );
  }

  Future<void> retryOrRequestPermission() async {
    state = state.copyWith(isLoading: true, permissionDenied: false);
    try {
      final perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
      }
    } catch (_) {}
    _startCompassListener(state.qiblaBearing);
  }
}

final qiblaProvider = NotifierProvider<QiblaNotifier, QiblaState>(
  QiblaNotifier.new,
);

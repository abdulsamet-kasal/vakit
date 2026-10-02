import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/math_utils.dart';
import '../../../prayer_times/presentation/controllers/prayer_times_controller.dart';
import '../../data/compass_service.dart';

class QiblaState {
  final bool hasSensor;
  final double heading;
  final double qiblaBearing;
  final double distanceKm;
  final bool isAligned;
  final double? accuracy;
  final bool needsCalibration;

  const QiblaState({
    required this.hasSensor,
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
    double? heading,
    double? qiblaBearing,
    double? distanceKm,
    bool? isAligned,
    double? accuracy,
    bool? needsCalibration,
  }) {
    return QiblaState(
      hasSensor: hasSensor ?? this.hasSensor,
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
  bool _wasAligned = false;

  @override
  QiblaState build() {
    final prayerState = ref.watch(prayerTimesProvider);
    final lat = prayerState.selectedCity.latitude;
    final lng = prayerState.selectedCity.longitude;

    final bearing = MathUtils.calculateQiblaBearing(lat, lng);
    final distance = MathUtils.calculateKaabaDistanceKm(lat, lng);
    final hasSensor = CompassService.hasCompassSensor;

    ref.onDispose(() {
      _compassSubscription?.cancel();
    });

    if (hasSensor) {
      _startCompassListener(bearing);
    }

    return QiblaState(
      hasSensor: hasSensor,
      heading: 0.0,
      qiblaBearing: bearing,
      distanceKm: distance,
      isAligned: false,
    );
  }

  void _startCompassListener(double qiblaBearing) {
    _compassSubscription?.cancel();
    _compassSubscription = _compassService.compassStream?.listen((event) {
      final rawHeading = event.heading;
      if (rawHeading == null) return;

      // Düşük geçiren filtre ile yumuşat
      final smoothed = MathUtils.filterHeading(state.heading, rawHeading);
      final aligned = MathUtils.isQiblaAligned(smoothed, state.qiblaBearing);

      // Hizalanma anında tek seferlik haptik titreşim
      if (aligned && !_wasAligned) {
        HapticFeedback.mediumImpact();
      }
      _wasAligned = aligned;

      final acc = event.accuracy;
      final needsCalib = acc != null && acc > 20.0;

      state = state.copyWith(
        heading: smoothed,
        isAligned: aligned,
        accuracy: acc,
        needsCalibration: needsCalib,
      );
    });
  }
}

final qiblaProvider = NotifierProvider<QiblaNotifier, QiblaState>(
  QiblaNotifier.new,
);

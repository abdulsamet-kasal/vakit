import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';

/// Pusula sensör servis sarmalayıcısı.
class CompassService {
  /// Cihazda pusula sensörü bulunup bulunmadığı
  static bool get hasCompassSensor => FlutterCompass.events != null;

  /// Pusula olayları akışı
  Stream<CompassEvent>? get compassStream => FlutterCompass.events;
}

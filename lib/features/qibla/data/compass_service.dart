import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';

/// Pusula yön ve hassasiyet veri modeli.
class CompassHeading {
  final double heading;
  final double? accuracy;

  const CompassHeading({
    required this.heading,
    this.accuracy,
  });
}

/// Ultra dayanıklı pusula servisi.
/// Android için özel yazılmış native EventChannel sensör motorunu kullanır.
/// Bu motor `Sensor.TYPE_ROTATION_VECTOR`, `Sensor.TYPE_ACCELEROMETER` ve `Sensor.TYPE_MAGNETIC_FIELD`
/// sensörlerini birleştirerek ekran oryantasyonunu da hesaba katar.
/// Diğer platformlarda (veya kanal hatasında) standart `flutter_compass` eklentisine geri döner.
class CompassService {
  static const EventChannel _nativeCompassChannel =
      EventChannel('com.vakit.vakit/compass');

  /// Pusula olayları akışı
  Stream<CompassHeading> get compassStream {
    late StreamController<CompassHeading> controller;
    StreamSubscription? nativeSub;
    StreamSubscription? pluginSub;

    controller = StreamController<CompassHeading>.broadcast(
      onListen: () {
        // 1. Önce native kanalı dene
        try {
          nativeSub = _nativeCompassChannel
              .receiveBroadcastStream()
              .listen(
            (dynamic event) {
              if (event is Map) {
                final headingRaw = event['heading'];
                final accRaw = event['accuracy'];
                final heading = (headingRaw is num) ? headingRaw.toDouble() : 0.0;
                final acc = (accRaw is num) ? accRaw.toDouble() : null;
                controller.add(CompassHeading(heading: heading, accuracy: acc));
              }
            },
            onError: (dynamic error) {
              debugPrint('Native compass channel error: $error. Falling back to FlutterCompass.');
              pluginSub ??= _listenPlugin(controller);
            },
          );
        } catch (e) {
          debugPrint('Native compass setup exception: $e. Falling back.');
          pluginSub ??= _listenPlugin(controller);
        }
      },
      onCancel: () {
        nativeSub?.cancel();
        pluginSub?.cancel();
      },
    );

    return controller.stream;
  }

  StreamSubscription? _listenPlugin(
    StreamController<CompassHeading> controller,
  ) {
    try {
      final stream = FlutterCompass.events;
      if (stream != null) {
        return stream.listen(
          (event) {
            final h = event.heading;
            if (h != null) {
              controller.add(CompassHeading(
                heading: h,
                accuracy: event.accuracy,
              ));
            }
          },
          onError: (dynamic e) {
            controller.addError(e);
          },
        );
      } else {
        controller.addError('FlutterCompass stream is null');
      }
    } catch (e) {
      controller.addError(e);
    }
    return null;
  }
}

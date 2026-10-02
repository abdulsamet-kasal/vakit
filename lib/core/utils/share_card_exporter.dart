import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Kartları yüksek çözünürlüklü PNG görseli olarak dışa aktarma ve paylaşma aracı.
abstract final class ShareCardExporter {
  /// Bir widget'ın [GlobalKey] referansını kullanarak yüksek çözünürlüklü görsel kart paylaşır
  static Future<bool> shareWidgetAsImage({
    required GlobalKey repaintBoundaryKey,
    required String shareSubject,
    String? fallbackText,
  }) async {
    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        if (fallbackText != null) {
          await SharePlus.instance.share(ShareParams(text: fallbackText, subject: shareSubject));
          return true;
        }
        return false;
      }

      // Net ve kaliteli bir kart için 3.0 pixel ratio
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return false;

      final pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/vakit_paylasim_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: shareSubject,
          text: fallbackText,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Görsel kart dışa aktarma hatası: $e');
      if (fallbackText != null) {
        await SharePlus.instance.share(ShareParams(text: fallbackText, subject: shareSubject));
        return true;
      }
      return false;
    }
  }

  /// Sade metin olarak paylaşır
  static Future<void> shareText({
    required String text,
    String? subject,
  }) async {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }
}

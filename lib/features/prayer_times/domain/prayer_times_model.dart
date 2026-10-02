import 'package:flutter/foundation.dart';
import '../../../../core/config/kerahat_config.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../presentation/widgets/kerahat_badge.dart';
import '../presentation/widgets/prayer_timeline_list.dart';

enum PrayerName {
  imsak('İmsak'),
  gunes('Güneş'),
  ogle('Öğle'),
  ikindi('İkindi'),
  aksam('Akşam'),
  yatsi('Yatsı');

  final String displayName;
  const PrayerName(this.displayName);
}

@immutable
class PrayerTimesModel {
  final DateTime date;
  final String cityName;
  final DateTime imsak;
  final DateTime gunes;
  final DateTime ogle;
  final DateTime ikindi;
  final DateTime aksam;
  final DateTime yatsi;
  final KerahatConfig kerahatConfig;

  const PrayerTimesModel({
    required this.date,
    required this.cityName,
    required this.imsak,
    required this.gunes,
    required this.ogle,
    required this.ikindi,
    required this.aksam,
    required this.yatsi,
    this.kerahatConfig = KerahatConfig.defaults,
  });

  // --- Kerahat Aralıkları ---
  DateTime get sunriseKerahatEnd =>
      gunes.add(Duration(minutes: kerahatConfig.sunriseDurationMinutes));

  DateTime get middayKerahatStart =>
      ogle.subtract(Duration(minutes: kerahatConfig.middayBeforeMinutes));

  DateTime get sunsetKerahatStart =>
      aksam.subtract(Duration(minutes: kerahatConfig.sunsetBeforeMinutes));

  /// Şu an bir kerahat vakti içinde miyiz?
  KerahatType getActiveKerahat(DateTime now) {
    if (now.isAfter(gunes) && now.isBefore(sunriseKerahatEnd)) {
      return KerahatType.sunrise;
    }
    if (now.isAfter(middayKerahatStart) && now.isBefore(ogle)) {
      return KerahatType.midday;
    }
    if (now.isAfter(sunsetKerahatStart) && now.isBefore(aksam)) {
      return KerahatType.sunset;
    }
    return KerahatType.none;
  }

  /// Güneşin gündüz gökyüzündeki ilerleme oranı (0.0 = Doğuş, 1.0 = Batış)
  /// Gece ise null döner.
  double? getSunProgress(DateTime now) {
    if (now.isBefore(gunes) || now.isAfter(aksam)) {
      return null;
    }
    final totalDaylight = aksam.difference(gunes).inMilliseconds;
    if (totalDaylight <= 0) return 0.0;
    final elapsed = now.difference(gunes).inMilliseconds;
    return (elapsed / totalDaylight).clamp(0.0, 1.0);
  }

  /// Öğle ve İkindi vakitlerinin yay üzerindeki oranları
  double get dhuhrRatio {
    final total = aksam.difference(gunes).inMilliseconds;
    if (total <= 0) return 0.5;
    return (ogle.difference(gunes).inMilliseconds / total).clamp(0.0, 1.0);
  }

  double get asrRatio {
    final total = aksam.difference(gunes).inMilliseconds;
    if (total <= 0) return 0.72;
    return (ikindi.difference(gunes).inMilliseconds / total).clamp(0.0, 1.0);
  }

  double get sunriseKerahatRatio {
    final total = aksam.difference(gunes).inMilliseconds;
    if (total <= 0) return 0.09;
    return ((kerahatConfig.sunriseDurationMinutes * 60 * 1000) / total).clamp(0.0, 0.2);
  }

  (double, double) get middayKerahatRange {
    final total = aksam.difference(gunes).inMilliseconds;
    if (total <= 0) return (0.44, 0.50);
    final end = dhuhrRatio;
    final duration = (kerahatConfig.middayBeforeMinutes * 60 * 1000) / total;
    return ((end - duration).clamp(0.0, 1.0), end);
  }

  (double, double) get sunsetKerahatRange {
    final total = aksam.difference(gunes).inMilliseconds;
    if (total <= 0) return (0.91, 1.0);
    final duration = (kerahatConfig.sunsetBeforeMinutes * 60 * 1000) / total;
    return ((1.0 - duration).clamp(0.0, 1.0), 1.0);
  }

  /// Şu an içinde bulunulan vakit
  PrayerName getCurrentPrayer(DateTime now) {
    if (now.isBefore(imsak)) {
      return PrayerName.yatsi; // Gece yarısından imsağa kadar yatsı vakti
    } else if (now.isBefore(gunes)) {
      return PrayerName.imsak;
    } else if (now.isBefore(ogle)) {
      return PrayerName.gunes;
    } else if (now.isBefore(ikindi)) {
      return PrayerName.ogle;
    } else if (now.isBefore(aksam)) {
      return PrayerName.ikindi;
    } else if (now.isBefore(yatsi)) {
      return PrayerName.aksam;
    } else {
      return PrayerName.yatsi;
    }
  }

  /// Sıradaki vakit adı ve saati
  (PrayerName, DateTime) getNextPrayer(
    DateTime now, {
    PrayerTimesModel? tomorrowTimes,
  }) {
    if (now.isBefore(imsak)) {
      return (PrayerName.imsak, imsak);
    } else if (now.isBefore(gunes)) {
      return (PrayerName.gunes, gunes);
    } else if (now.isBefore(ogle)) {
      return (PrayerName.ogle, ogle);
    } else if (now.isBefore(ikindi)) {
      return (PrayerName.ikindi, ikindi);
    } else if (now.isBefore(aksam)) {
      return (PrayerName.aksam, aksam);
    } else if (now.isBefore(yatsi)) {
      return (PrayerName.yatsi, yatsi);
    } else {
      // Yatsıdan sonra sıradaki vakit yarının İmsak vaktidir
      final tomorrowImsak = tomorrowTimes?.imsak ?? imsak.add(const Duration(days: 1));
      return (PrayerName.imsak, tomorrowImsak);
    }
  }

  /// Sıradaki vakte kalan süre
  Duration getTimeUntilNext(
    DateTime now, {
    PrayerTimesModel? tomorrowTimes,
  }) {
    final (_, nextTime) = getNextPrayer(now, tomorrowTimes: tomorrowTimes);
    final diff = nextTime.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Dikey zaman şeridi (Timeline) için hazır liste elemanları
  List<PrayerTimelineItemData> toTimelineItems(
    DateTime now, {
    PrayerTimesModel? tomorrowTimes,
  }) {
    final current = getCurrentPrayer(now);
    final (next, _) = getNextPrayer(now, tomorrowTimes: tomorrowTimes);

    return [
      PrayerTimelineItemData(
        name: PrayerName.imsak.displayName,
        time: DateTimeUtils.formatTime(imsak),
        isPast: now.isAfter(imsak),
        isActive: current == PrayerName.imsak,
        isNext: next == PrayerName.imsak && current != PrayerName.imsak,
      ),
      PrayerTimelineItemData(
        name: PrayerName.gunes.displayName,
        time: DateTimeUtils.formatTime(gunes),
        isPast: now.isAfter(gunes),
        isActive: current == PrayerName.gunes,
        isNext: next == PrayerName.gunes && current != PrayerName.gunes,
      ),
      PrayerTimelineItemData(
        name: PrayerName.ogle.displayName,
        time: DateTimeUtils.formatTime(ogle),
        isPast: now.isAfter(ogle),
        isActive: current == PrayerName.ogle,
        isNext: next == PrayerName.ogle && current != PrayerName.ogle,
      ),
      PrayerTimelineItemData(
        name: PrayerName.ikindi.displayName,
        time: DateTimeUtils.formatTime(ikindi),
        isPast: now.isAfter(ikindi),
        isActive: current == PrayerName.ikindi,
        isNext: next == PrayerName.ikindi && current != PrayerName.ikindi,
      ),
      PrayerTimelineItemData(
        name: PrayerName.aksam.displayName,
        time: DateTimeUtils.formatTime(aksam),
        isPast: now.isAfter(aksam),
        isActive: current == PrayerName.aksam,
        isNext: next == PrayerName.aksam && current != PrayerName.aksam,
      ),
      PrayerTimelineItemData(
        name: PrayerName.yatsi.displayName,
        time: DateTimeUtils.formatTime(yatsi),
        isPast: now.isAfter(yatsi),
        isActive: current == PrayerName.yatsi,
        isNext: next == PrayerName.yatsi && current != PrayerName.yatsi,
      ),
    ];
  }
}

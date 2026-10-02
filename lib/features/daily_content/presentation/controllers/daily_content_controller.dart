import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/daily_content_repository.dart';
import '../../data/models/hadith_model.dart';
import '../../data/models/verse_model.dart';
import '../../../widgets_bridge/home_widget_service.dart';

class DailyContentState {
  final DateTime selectedDate;
  final AsyncValue<VerseModel> verse;
  final AsyncValue<HadithModel> hadith;

  const DailyContentState({
    required this.selectedDate,
    required this.verse,
    required this.hadith,
  });

  bool get isToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  DailyContentState copyWith({
    DateTime? selectedDate,
    AsyncValue<VerseModel>? verse,
    AsyncValue<HadithModel>? hadith,
  }) {
    return DailyContentState(
      selectedDate: selectedDate ?? this.selectedDate,
      verse: verse ?? this.verse,
      hadith: hadith ?? this.hadith,
    );
  }
}

class DailyContentNotifier extends Notifier<DailyContentState> {
  final _repository = DailyContentRepository();

  @override
  DailyContentState build() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // İlk yüklemeyi tetikle
    Future.microtask(() => loadForDate(today));

    return DailyContentState(
      selectedDate: today,
      verse: const AsyncValue.loading(),
      hadith: const AsyncValue.loading(),
    );
  }

  Future<void> loadForDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    state = state.copyWith(
      selectedDate: normalized,
      verse: const AsyncValue.loading(),
      hadith: const AsyncValue.loading(),
    );

    try {
      final verse = await _repository.getDailyVerse(normalized);
      final hadith = await _repository.getDailyHadith(normalized);

      state = state.copyWith(
        verse: AsyncValue.data(verse),
        hadith: AsyncValue.data(hadith),
      );

      if (state.isToday) {
        HomeWidgetService.updateDailyContent(verse: verse, hadith: hadith);
      }
    } catch (e, st) {
      state = state.copyWith(
        verse: AsyncValue.error(e, st),
        hadith: AsyncValue.error(e, st),
      );
    }
  }

  void previousDay() {
    loadForDate(state.selectedDate.subtract(const Duration(days: 1)));
  }

  void nextDay() {
    loadForDate(state.selectedDate.add(const Duration(days: 1)));
  }

  void goToToday() {
    final now = DateTime.now();
    loadForDate(DateTime(now.year, now.month, now.day));
  }
}

final dailyContentProvider =
    NotifierProvider<DailyContentNotifier, DailyContentState>(
  DailyContentNotifier.new,
);

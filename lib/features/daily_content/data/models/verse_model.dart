/// Günün Âyeti veri modeli.
class VerseModel {
  final int id;
  final int dayOfYear;
  final int surahNo;
  final int ayahNo;
  final String arabic;
  final String mealTr;
  final String sourceName;
  final String shortText;

  const VerseModel({
    required this.id,
    required this.dayOfYear,
    required this.surahNo,
    required this.ayahNo,
    required this.arabic,
    required this.mealTr,
    required this.sourceName,
    required this.shortText,
  });

  factory VerseModel.fromJson(Map<String, dynamic> json) {
    return VerseModel(
      id: json['id'] as int? ?? 0,
      dayOfYear: json['day_of_year'] as int? ?? 1,
      surahNo: json['surah_no'] as int? ?? 1,
      ayahNo: json['ayah_no'] as int? ?? 1,
      arabic: json['arabic'] as String? ?? '',
      mealTr: json['meal_tr'] as String? ?? '',
      sourceName: json['source_name'] as String? ?? '',
      shortText: json['short_text'] as String? ?? json['meal_tr'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day_of_year': dayOfYear,
      'surah_no': surahNo,
      'ayah_no': ayahNo,
      'arabic': arabic,
      'meal_tr': mealTr,
      'source_name': sourceName,
      'short_text': shortText,
    };
  }
}

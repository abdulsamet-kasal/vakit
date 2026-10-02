/// Günün Hadisi veri modeli.
class HadithModel {
  final int id;
  final int dayOfYear;
  final String? arabic;
  final String textTr;
  final String narrator;
  final String sourceBook;
  final String? sourceNo;
  final String shortText;

  const HadithModel({
    required this.id,
    required this.dayOfYear,
    this.arabic,
    required this.textTr,
    required this.narrator,
    required this.sourceBook,
    this.sourceNo,
    required this.shortText,
  });

  String get fullSource =>
      sourceNo != null ? '$sourceBook, $sourceNo' : sourceBook;

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    return HadithModel(
      id: json['id'] as int? ?? 0,
      dayOfYear: json['day_of_year'] as int? ?? 1,
      arabic: json['arabic'] as String?,
      textTr: json['text_tr'] as String? ?? '',
      narrator: json['narrator'] as String? ?? '',
      sourceBook: json['source_book'] as String? ?? '',
      sourceNo: json['source_no'] as String?,
      shortText: json['short_text'] as String? ?? json['text_tr'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day_of_year': dayOfYear,
      'arabic': arabic,
      'text_tr': textTr,
      'narrator': narrator,
      'source_book': sourceBook,
      'source_no': sourceNo,
      'short_text': shortText,
    };
  }
}

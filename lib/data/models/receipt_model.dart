import '../../core/constants/vibe_phrases.dart';
import 'vibe_data.dart';

class ReceiptModel {
  final VibeData data;
  final VibeMood mood;
  final String phrase;
  final String receiptNumber;

  const ReceiptModel({
    required this.data,
    required this.mood,
    required this.phrase,
    required this.receiptNumber,
  });

  VibeMoodStyle get style => vibeMoodStyles[mood]!;

  ReceiptModel copyWith({VibeData? data}) => ReceiptModel(
        data: data ?? this.data,
        mood: mood,
        phrase: phrase,
        receiptNumber: receiptNumber,
      );

  Map<String, dynamic> toJson() => {
        'data': data.toJson(),
        'mood': mood.name,
        'phrase': phrase,
        'receiptNumber': receiptNumber,
      };

  static ReceiptModel fromJson(Map<String, dynamic> j) => ReceiptModel(
        data: VibeData.fromJson(j['data'] as Map<String, dynamic>),
        mood: VibeMood.values.firstWhere((m) => m.name == j['mood']),
        phrase: j['phrase'] as String,
        receiptNumber: j['receiptNumber'] as String,
      );
}

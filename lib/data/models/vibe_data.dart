import 'dart:io';

class VibeData {
  final String placeName;
  final double lux;
  final double decibel;
  final DateTime measuredAt;
  final File? photo;
  final String? comment;

  const VibeData({
    required this.placeName,
    required this.lux,
    required this.decibel,
    required this.measuredAt,
    this.photo,
    this.comment,
  });

  VibeData copyWith({
    String? placeName,
    double? lux,
    double? decibel,
    DateTime? measuredAt,
    File? photo,
    String? comment,
  }) {
    return VibeData(
      placeName: placeName ?? this.placeName,
      lux: lux ?? this.lux,
      decibel: decibel ?? this.decibel,
      measuredAt: measuredAt ?? this.measuredAt,
      photo: photo ?? this.photo,
      comment: comment ?? this.comment,
    );
  }

  Map<String, dynamic> toJson() => {
        'placeName': placeName,
        'lux': lux,
        'decibel': decibel,
        'measuredAt': measuredAt.toIso8601String(),
        'photoPath': photo?.path,
        'comment': comment,
      };

  static VibeData fromJson(Map<String, dynamic> j) => VibeData(
        placeName: j['placeName'] as String,
        lux: (j['lux'] as num).toDouble(),
        decibel: (j['decibel'] as num).toDouble(),
        measuredAt: DateTime.parse(j['measuredAt'] as String),
        photo: j['photoPath'] != null ? File(j['photoPath'] as String) : null,
        comment: j['comment'] as String?,
      );
}

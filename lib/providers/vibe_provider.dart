import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/permission_helper.dart';
import '../data/models/receipt_model.dart';
import '../data/models/vibe_data.dart';
import '../data/services/light_service.dart';
import '../data/services/noise_service.dart';
import '../data/services/notification_service.dart';
import '../data/services/vibe_matcher.dart';
import 'history_provider.dart';

enum MeasureStatus { idle, measuring, success, error }

class VibeState {
  final MeasureStatus status;
  final String placeName;
  final File? photo;
  final String comment;
  final ReceiptModel? receipt;
  final String? errorMessage;

  const VibeState({
    this.status = MeasureStatus.idle,
    this.placeName = '',
    this.photo,
    this.comment = '',
    this.receipt,
    this.errorMessage,
  });

  VibeState copyWith({
    MeasureStatus? status,
    String? placeName,
    File? photo,
    bool clearPhoto = false,
    String? comment,
    ReceiptModel? receipt,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VibeState(
      status: status ?? this.status,
      placeName: placeName ?? this.placeName,
      photo: clearPhoto ? null : (photo ?? this.photo),
      comment: comment ?? this.comment,
      receipt: receipt ?? this.receipt,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class VibeNotifier extends StateNotifier<VibeState> {
  final LightService _lightService;
  final NoiseService _noiseService;
  final VibeMatcher _matcher;
  final HistoryNotifier _history;

  VibeNotifier(
      this._lightService, this._noiseService, this._matcher, this._history)
      : super(const VibeState());

  void setPlaceName(String value) => state = state.copyWith(placeName: value);
  void setPhoto(File? file) =>
      state = state.copyWith(photo: file, clearPhoto: file == null);
  void setComment(String value) => state = state.copyWith(comment: value);

  void reset() => state = const VibeState();

  Future<void> startMeasure() async {
    if (state.placeName.trim().isEmpty) {
      state = state.copyWith(
        status: MeasureStatus.error,
        errorMessage: '장소 이름을 입력해 주세요.',
      );
      return;
    }

    final mic = await PermissionHelper.ensureMicrophone();

    state = state.copyWith(status: MeasureStatus.measuring, clearError: true);

    try {
      double lux;
      double decibel;

      if (mic) {
        final results = await Future.wait([
          _lightService.measureAverage(duration: const Duration(seconds: 3)),
          _noiseService.measureAverage(duration: const Duration(seconds: 4)),
        ]);
        lux = results[0];
        decibel = results[1];
      } else {
        // mic permission denied — measure light only, treat noise as silent
        lux = await _lightService.measureAverage(
            duration: const Duration(seconds: 3));
        decibel = -1;
      }

      final data = VibeData(
        placeName: state.placeName.trim(),
        lux: lux,
        decibel: decibel,
        measuredAt: DateTime.now(),
        photo: state.photo,
        comment:
            state.comment.trim().isEmpty ? null : state.comment.trim(),
      );

      final receipt = _matcher.buildReceipt(data);
      state = state.copyWith(status: MeasureStatus.success, receipt: receipt);
      await _history.add(receipt);
      try {
        await NotificationService.onMeasuredToday();
      } catch (_) {}
    } catch (e) {
      state = state.copyWith(
        status: MeasureStatus.error,
        errorMessage: '측정 중 오류가 발생했습니다: $e',
      );
    }
  }
}

final lightServiceProvider = Provider((_) => LightService());
final noiseServiceProvider = Provider((_) => NoiseService());
final vibeMatcherProvider = Provider((_) => VibeMatcher());

final vibeNotifierProvider =
    StateNotifierProvider<VibeNotifier, VibeState>((ref) {
  return VibeNotifier(
    ref.read(lightServiceProvider),
    ref.read(noiseServiceProvider),
    ref.read(vibeMatcherProvider),
    ref.read(historyProvider.notifier),
  );
});

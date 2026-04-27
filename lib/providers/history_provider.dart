import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/receipt_model.dart';
import '../data/services/history_service.dart';

class HistoryNotifier extends StateNotifier<List<ReceiptModel>> {
  final HistoryService _service;

  HistoryNotifier(this._service) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _service.loadAll();
  }

  Future<void> add(ReceiptModel receipt) async {
    await _service.save(receipt);
    await _load();
  }

  Future<void> remove(String receiptNumber) async {
    await _service.delete(receiptNumber);
    state = state.where((r) => r.receiptNumber != receiptNumber).toList();
  }
}

final historyServiceProvider = Provider((_) => HistoryService());

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<ReceiptModel>>(
  (ref) => HistoryNotifier(ref.read(historyServiceProvider)),
);

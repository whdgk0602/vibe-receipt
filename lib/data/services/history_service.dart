import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/receipt_model.dart';

class HistoryService {
  static const _key = 'vibe_history';
  static const _maxEntries = 50;

  Future<List<ReceiptModel>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final results = <ReceiptModel>[];
    for (final s in raw.reversed) {
      try {
        results.add(ReceiptModel.fromJson(
          jsonDecode(s) as Map<String, dynamic>,
        ));
      } catch (_) {}
    }
    return results;
  }

  Future<void> save(ReceiptModel receipt) async {
    ReceiptModel toSave = receipt;
    if (receipt.data.photo != null) {
      final newPath = await _copyPhoto(receipt.data.photo!.path);
      if (newPath != null) {
        toSave = receipt.copyWith(
          data: receipt.data.copyWith(photo: File(newPath)),
        );
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(toSave.toJson()));

    final trimmed = raw.length > _maxEntries
        ? raw.sublist(raw.length - _maxEntries)
        : raw;
    await prefs.setStringList(_key, trimmed);
  }

  Future<void> delete(String receiptNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final filtered = raw.where((s) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        return m['receiptNumber'] != receiptNumber;
      } catch (_) {
        return true;
      }
    }).toList();
    await prefs.setStringList(_key, filtered);
  }

  Future<String?> _copyPhoto(String srcPath) async {
    try {
      final src = File(srcPath);
      if (!await src.exists()) return null;
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(docs.path, 'history_photos'));
      await dir.create(recursive: true);
      final dest = p.join(dir.path, p.basename(srcPath));
      await src.copy(dest);
      return dest;
    } catch (_) {
      return null;
    }
  }
}

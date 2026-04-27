import 'dart:io';
import 'dart:typed_data';

import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/time_helper.dart';
import '../models/receipt_model.dart';

class ImageExportService {
  Future<bool> saveToGallery(Uint8List bytes, {String? name}) async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) return false;
      }
      await Gal.putImageBytes(
        bytes,
        name: name ?? 'vibe_receipt_${DateTime.now().millisecondsSinceEpoch}',
        album: 'Vibe Receipt',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> share(Uint8List bytes, {String? text}) async {
    final tempDir = await getTemporaryDirectory();
    final filename =
        'vibe_receipt_${DateTime.now().millisecondsSinceEpoch}.png';
    final path = p.join(tempDir.path, filename);
    await File(path).writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(path, mimeType: 'image/png')],
      text: text ?? '나의 오늘 공간 바이브 🧾 #VibeReceipt',
    );
  }

  Future<void> shareAsText(ReceiptModel receipt) async {
    await Share.share(_buildTextCard(receipt));
  }

  static String _buildTextCard(ReceiptModel receipt) {
    final d = receipt.data;
    final style = receipt.style;
    final date = DateFormat('yyyy.MM.dd HH:mm').format(d.measuredAt);
    final timeBand = TimeHelper.labelOf(TimeHelper.bandOf(d.measuredAt));
    final lux = d.lux < 0 ? '--' : '${d.lux.toStringAsFixed(0)} lux';
    final db =
        d.decibel < 0 ? '--' : '${d.decibel.toStringAsFixed(1)} dB';

    final buf = StringBuffer()
      ..writeln('🧾 VIBE RECEIPT')
      ..writeln('━━━━━━━━━━━━━━━━━━━━')
      ..writeln('📍 ${d.placeName}')
      ..writeln('🕐 $date ($timeBand)')
      ..writeln('━━━━━━━━━━━━━━━━━━━━')
      ..writeln('💡 빛   $lux')
      ..writeln('🔊 소음  $db')
      ..writeln('━━━━━━━━━━━━━━━━━━━━')
      ..writeln('✨ ${style.label.toUpperCase()} MOOD')
      ..writeln()
      ..writeln('"${receipt.phrase}"');

    if (d.comment != null && d.comment!.isNotEmpty) {
      buf
        ..writeln()
        ..writeln('* ${d.comment} *');
    }

    buf
      ..writeln('━━━━━━━━━━━━━━━━━━━━')
      ..writeln('NO. ${receipt.receiptNumber}')
      ..writeln()
      ..write('#VibeReceipt #바이브영수증');

    return buf.toString();
  }
}

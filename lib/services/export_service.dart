import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }
}

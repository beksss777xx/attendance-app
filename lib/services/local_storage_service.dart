import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_data.dart';

class LocalStorageService {
  static const _storageKey = 'attendance_app_data_v1';

  Future<AppData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return AppData.empty();
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AppData.fromJson(map);
    } catch (_) {
      return AppData.empty();
    }
  }

  Future<void> save(AppData data) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(data.toJson());
    await prefs.setString(_storageKey, encoded);
  }
}

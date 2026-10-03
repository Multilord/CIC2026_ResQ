import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class RecoveryRepository {
  Future<Map<String, dynamic>?> load();
  Future<void> save(Map<String, dynamic> data);
}

class LocalRecoveryRepository implements RecoveryRepository {
  static const key = 'resq_flutter_v2';
  @override
  Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Future<void> save(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(key, jsonEncode(data))) {
      throw StateError('Unable to save demo on this device.');
    }
  }
}

class MemoryRecoveryRepository implements RecoveryRepository {
  Map<String, dynamic>? data;
  @override
  Future<Map<String, dynamic>?> load() async => data;
  @override
  Future<void> save(Map<String, dynamic> data) async {
    this.data = jsonDecode(jsonEncode(data));
  }
}

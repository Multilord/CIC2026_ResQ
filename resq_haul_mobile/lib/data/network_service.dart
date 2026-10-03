import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Sessions stay in memory. Restarting the app requires signing in again.
class NetworkService extends ChangeNotifier {
  NetworkService({String? baseUrl})
    : baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'http://127.0.0.1:4175',
          );
  final String baseUrl;
  String? token;
  Map<String, dynamic>? state;
  String? error;
  int _revision = 0;
  double clockOffset = 0;
  double get now => DateTime.now().millisecondsSinceEpoch / 1000 + clockOffset;
  Timer? timer;
  bool _refreshing = false;
  Map<String, dynamic> get user => state?['user'] ?? <String, dynamic>{};
  String get role => user['role'] ?? '';
  List<Map<String, dynamic>> get batches =>
      List<Map<String, dynamic>>.from(state?['batches'] ?? []);
  Future<Map<String, dynamic>> request(
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final uri = Uri.parse('$baseUrl$path');
    final response =
        await (body == null
                ? http.get(uri, headers: headers)
                : http.post(uri, headers: headers, body: jsonEncode(body)))
            .timeout(const Duration(seconds: 15));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      if (response.statusCode == 401 && path != '/login') {
        token = null;
        state = null;
        timer?.cancel();
      }
      throw Exception(data['error'] ?? 'Request failed');
    }
    return data;
  }

  Future<void> login(String email, String password) async {
    final data = await request('/login', {
      'email': email,
      'password': password,
    });
    token = data['token'];
    await refresh();
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 10), (_) => refresh());
  }

  Future<void> refresh() async {
    if (token == null || _refreshing) return;
    _refreshing = true;
    final revision = _revision;
    try {
      final fresh = await request('/state');
      if (_revision != revision || token == null) return;
      state = fresh;
      clockOffset =
          (fresh['serverTime'] as num).toDouble() -
          DateTime.now().millisecondsSinceEpoch / 1000;
      error = null;
    } catch (e) {
      error = 'Connection interrupted. Retry to get the latest state.';
    } finally {
      _refreshing = false;
      notifyListeners();
    }
  }

  Future<void> command(
    String action, {
    Map<String, dynamic>? batch,
    Map<String, dynamic> fields = const {},
  }) async {
    _revision++;
    state = await request('/command', {
      'action': action,
      if (batch != null) 'id': batch['id'],
      if (batch != null) 'version': batch['version'],
      ...fields,
    });
    error = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await request('/logout', {});
    timer?.cancel();
    _revision++;
    token = null;
    state = null;
    notifyListeners();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_constant.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 10);

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- AUTH ---
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse(ApiConstant.login),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);

      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user_name', data['user']['name']);
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': data['message'] ?? 'Login gagal'};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse(ApiConstant.register),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(_timeout);

      final data = jsonDecode(res.body);
      if (res.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user_name', data['user']['name']);
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': data['message'] ?? 'Register gagal'};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  static Future<void> logout() async {
    try {
      await http
          .post(
            Uri.parse(ApiConstant.logout),
            headers: await _authHeaders(),
          )
          .timeout(_timeout);
    } catch (_) {
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }

  // --- PUBLIC API (DUMMYJSON) ---
  static Future<List<dynamic>> fetchPublicPosts() async {
    final res = await http
        .get(Uri.parse(ApiConstant.dummyPosts))
        .timeout(_timeout);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['posts'] ?? [];
    }
    throw Exception('Gagal memuat artikel publik');
  }

  // --- TABEL 1: TOPICS ---
  static Future<List<dynamic>> getTopics() async {
    final res = await http
        .get(
          Uri.parse(ApiConstant.topics),
          headers: await _authHeaders(),
        )
        .timeout(_timeout);
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? [];
    }
    throw Exception('Gagal memuat topik');
  }

  static Future<bool> createTopic(String name) async {
    try {
      final res = await http
          .post(
            Uri.parse(ApiConstant.topics),
            headers: await _authHeaders(),
            body: jsonEncode({'name': name}),
          )
          .timeout(_timeout);
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateTopic(int id, String name) async {
    try {
      final res = await http
          .put(
            Uri.parse('${ApiConstant.topics}/$id'),
            headers: await _authHeaders(),
            body: jsonEncode({'name': name}),
          )
          .timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteTopic(int id) async {
    try {
      final res = await http
          .delete(
            Uri.parse('${ApiConstant.topics}/$id'),
            headers: await _authHeaders(),
          )
          .timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // --- TABEL 2: BOOKMARKS ---
  static Future<List<dynamic>> getBookmarks() async {
    final res = await http
        .get(
          Uri.parse(ApiConstant.bookmarks),
          headers: await _authHeaders(),
        )
        .timeout(_timeout);
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'] ?? [];
    }
    throw Exception('Gagal memuat bookmark');
  }

  static Future<bool> createBookmark({
    required int topicId,
    required String title,
    required String summary,
    required String keyPoints,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse(ApiConstant.bookmarks),
            headers: await _authHeaders(),
            body: jsonEncode({
              'topic_id': topicId,
              'title': title,
              'summary': summary,
              'key_points': keyPoints,
            }),
          )
          .timeout(_timeout);
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateBookmark({
    required int id,
    required int topicId,
    required String title,
    required String summary,
    required String keyPoints,
  }) async {
    try {
      final res = await http
          .put(
            Uri.parse('${ApiConstant.bookmarks}/$id'),
            headers: await _authHeaders(),
            body: jsonEncode({
              'topic_id': topicId,
              'title': title,
              'summary': summary,
              'key_points': keyPoints,
            }),
          )
          .timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteBookmark(int id) async {
    try {
      final res = await http
          .delete(
            Uri.parse('${ApiConstant.bookmarks}/$id'),
            headers: await _authHeaders(),
          )
          .timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
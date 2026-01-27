import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl =
      'https://rapip.tif-lbj.my.id/api_project_uas_mobut';

  Uri uri(String path, {Map<String, String>? query}) {
    return Uri.parse('$baseUrl/$path').replace(queryParameters: query);
  }

  /// ✅ GET request
  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final res = await http.get(uri(path, query: query));
    return handleResponse(res);
  }

  /// ✅ POST JSON request
  Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return handleResponse(res);
  }

  /// ✅ PUBLIC handler (dipakai ApiService juga)
  dynamic handleResponse(http.Response res) {
    dynamic parsed;
    try {
      parsed = jsonDecode(res.body);
    } catch (_) {
      throw Exception('Response bukan JSON (${res.statusCode}): ${res.body}');
    }

    if (parsed is Map && parsed['success'] == true) {
      return parsed['data'];
    }

    final msg = (parsed is Map
        ? (parsed['message'] ?? 'Unknown error')
        : 'Unknown error')
        .toString();
    throw Exception(msg);
  }
}

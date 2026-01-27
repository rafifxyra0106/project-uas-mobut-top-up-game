import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class ApiService {
  final ApiClient _client = ApiClient();

  // ==========================================================
  // AUTH
  // ==========================================================

  /// ✅ Login pakai username ATAU email
  /// POST JSON: login.php {login, password}
  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    final data = await _client.postJson('login.php', {
      'login': login,
      'password': password,
    });
    return Map<String, dynamic>.from(data as Map);
  }

  /// ✅ Register user
  /// POST JSON: register.php {name, username, email, password}
  Future<Map<String, dynamic>> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final data = await _client.postJson('register.php', {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
    });
    return Map<String, dynamic>.from(data as Map);
  }

  // ==========================================================
  // GAMES (PUBLIC)
  // ==========================================================

  /// ✅ GET: games.php
  Future<List<dynamic>> fetchGames() async {
    final data = await _client.get('games.php');
    return List<dynamic>.from(data as List);
  }

  // ==========================================================
  // USER - TRANSACTIONS
  // ==========================================================

  /// ✅ POST JSON: transactions_create.php {user_id, game_id, nominal}
  Future<Map<String, dynamic>> createTransaction({
    required int userId,
    required int gameId,
    required int nominal,
  }) async {
    final data = await _client.postJson('transactions_create.php', {
      'user_id': userId,
      'game_id': gameId,
      'nominal': nominal,
    });
    return Map<String, dynamic>.from(data as Map);
  }

  /// ✅ GET: transactions_list.php?user_id=...
  Future<List<dynamic>> listTransactions({required int userId}) async {
    final data = await _client.get(
      'transactions_list.php',
      query: {'user_id': userId.toString()},
    );
    return List<dynamic>.from(data as List);
  }

  // ==========================================================
  // ADMIN - GAMES CRUD (ROLE BASED: pakai user_id, TANPA admin_key)
  // ==========================================================

  /// ✅ Admin tambah game + upload image
  /// POST multipart: user_id, name, image
  Future<Map<String, dynamic>> createGame({
    required int userId,
    required String name,
    required File imageFile,
  }) async {
    final uri = _client.uri('games_create.php');

    final req = http.MultipartRequest('POST', uri);
    req.fields['user_id'] = userId.toString();
    req.fields['name'] = name;

    req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    final data = _client.handleResponse(res);
    return Map<String, dynamic>.from(data as Map);
  }

  /// ✅ Admin update game (image optional)
  /// POST multipart: user_id, id, name, (image?)
  Future<Map<String, dynamic>> updateGame({
    required int userId,
    required int id,
    required String name,
    File? imageFile,
  }) async {
    final uri = _client.uri('games_update.php');

    final req = http.MultipartRequest('POST', uri);
    req.fields['user_id'] = userId.toString();
    req.fields['id'] = id.toString();
    req.fields['name'] = name;

    if (imageFile != null) {
      req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    final data = _client.handleResponse(res);
    return Map<String, dynamic>.from(data as Map);
  }

  /// ✅ Admin delete game
  /// POST JSON: games_delete.php {user_id, id}
  Future<Map<String, dynamic>> deleteGame({
    required int userId,
    required int id,
  }) async {
    final data = await _client.postJson('games_delete.php', {
      'user_id': userId,
      'id': id,
    });
    return Map<String, dynamic>.from(data as Map);
  }

  // ==========================================================
  // ADMIN - TRANSACTIONS (ALL)
  // ==========================================================

  /// ✅ Admin lihat semua transaksi
  /// POST JSON: transactions_all.php {user_id}
  Future<List<dynamic>> listAllTransactions({required int userId}) async {
    final data = await _client.postJson('transactions_all.php', {
      'user_id': userId,
    });
    return List<dynamic>.from(data as List);
  }
}

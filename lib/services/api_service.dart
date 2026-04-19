import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supervisi/pages/models/ItemPenilaianModel.dart';

const String baseUrl = "http://localhost:8000/api";

// ================ AUTH ================
class ApiLoginService {
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Accept": "application/json"},
      body: {"username": username, "password": password},
    );

    return jsonDecode(response.body);
  }

  // 🔥 TAMBAHAN
}

class ApiLogoutService {
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Hapus token di lokal
      await prefs.remove('token');
    } else {
      throw Exception('Failed to logout');
    }
  }
}

// ================ USER ================

class ApiGetUserService {
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/user"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }
}

// ================ ITEM PENILAIAN ================
class ApiItemPenilaianService {
  Future<List<ItemPenilaianModel>> getItemPenilaian() async {
    final response = await http.get(Uri.parse('$baseUrl/item-penilaian'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((item) => ItemPenilaianModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load item penilaian');
    }
  }
}

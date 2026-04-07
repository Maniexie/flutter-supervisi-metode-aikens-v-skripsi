import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "http://10.0.2.2/api"; 
  // 10.0.2.2 = localhost dari emulator

  static Future login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login.php"),
      body: {
        "username": username,
        "password": password,
      },
    );

    return jsonDecode(response.body);
  }
}
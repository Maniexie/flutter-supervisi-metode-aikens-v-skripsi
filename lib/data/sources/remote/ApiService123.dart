import 'dart:convert';
import 'package:http/http.dart' as http;

class Apiservice {
  final String baseUrl = "https://jsonplaceholder.typicode.com/";

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    return jsonDecode(response.body);
  }
}

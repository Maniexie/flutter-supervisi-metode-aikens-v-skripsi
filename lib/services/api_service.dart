import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supervisi/pages/models/ItemPenilaianModel.dart';
import 'package:supervisi/pages/models/KategoriPenilaianModel.dart';

const String baseUrl = "http://localhost:8000/api";

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

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

    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return json;
    } else {
      throw Exception(json['message']);
    }
  }
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

// ================ KATEGORI PENILAIAN ================
class ApiKategoriPenilaianService {
  Future<List<KategoriPenilaianModel>> getKategoriPenilaian() async {
    final response = await http.get(
      Uri.parse('$baseUrl/kategori-penilaian'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((item) => KategoriPenilaianModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load kategori');
    }
  }
}

// ================ ITEM PENILAIAN ================
class ApiItemPenilaianService {
  // GET ALL DATA ITEM PENILAIAN
  Future<List<ItemPenilaianModel>> getItemPenilaian() async {
    final response = await http.get(Uri.parse('$baseUrl/item-penilaian'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((item) => ItemPenilaianModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load item penilaian');
    }
  }

  // 🔥 TAMBAH ITEM PENILAIAN
  Future<void> tambahItemPenilaian(
    String kodeKategori,
    String pernyataan,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/item-penilaian'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'kode_kategori_penilaian': kodeKategori,
        'pernyataan': pernyataan,
      }),
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Berhasil disimpan');
    } else {
      throw Exception('Gagal simpan');
    }
  }

  //EDIT ITEM PENILAIAN
  Future<void> editItemPenilaian(
    int id,
    String kodeKategori,
    String pernyataan,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/item-penilaian/$id'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_item_penilaian': id,
        'kode_kategori_penilaian': kodeKategori,
        'pernyataan': pernyataan,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Berhasil disimpan');
    } else {
      throw Exception('Gagal simpan');
    }
  }

  //DELETE ITEM PENILAIAN
  Future<void> deleteItemPenilaian(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/item-penilaian/$id'),
      headers: {'Accept': 'application/json'},
    );

    print("DELETE STATUS: ${response.statusCode}");
    print("DELETE BODY: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal hapus');
    }
  }
}

class ApiAikenService {
  // 🔥 GET LIST VERSI
  Future<List<int>> getVersiList() async {
    final response = await http.get(
      Uri.parse('$baseUrl/item-penilaian/get-versi-item'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final List data = json['data'];

      return data.map<int>((e) => e['versi'] as int).toList();
    } else {
      throw Exception("Gagal load versi");
    }
  }

  // 🔥 GET KUESIONER BY VERSI
  Future<List<dynamic>> getKuesionerByVersi(int versi) async {
    final response = await http.get(
      Uri.parse('$baseUrl/item-penilaian/group-by-versi'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final List data = json['data'];

      // 🔥 FILTER DI FLUTTER
      final result = data.firstWhere(
        (e) => e['versi'] == versi,
        orElse: () => null,
      );

      if (result == null) return [];

      return result['items'];
    } else {
      throw Exception("Gagal load kuesioner");
    }
  }

  Future<Map<String, dynamic>> getDetailKuesionerByVersi(int versi) async {
    final response = await http.get(
      Uri.parse('$baseUrl/item-penilaian/group-by-versi'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final List data = json['data'];

      // 🔥 FILTER DI FLUTTER
      final result = data.cast<Map<String, dynamic>?>().firstWhere(
        (e) => e?['versi'] == versi,
        orElse: () => null,
      );

      if (result == null) return {};

      return result;
    } else {
      throw Exception("Gagal load detail kuesioner");
    }
  }
}

class JawabanValidatorService {
  Future<bool> submitJawabanValidator(
    int versi,
    List<Map<String, dynamic>> jawaban,
  ) async {
    final token = await getToken(); // 🔥 ambil token

    final response = await http.post(
      Uri.parse('$baseUrl/jawaban-validator/submit'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 🔥 WAJIB
      },
      body: jsonEncode({
        'versi': versi,
        'jawaban': jawaban
            .map((e) => {'id_item_penilaian': e['id'], 'jawaban': e['nilai']})
            .toList(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception(response.body);
    }
  }

  Future<List<int>> getStatusJawaban() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/jawaban-validator/status-pengujian'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Gagal ambil status");
    }

    final json = jsonDecode(response.body);

    // 🔥 FIX DISINI
    final data = json['data'];

    if (data == null) return []; // ⛑️ HANDLE NULL

    return List<int>.from(data);
  }
}

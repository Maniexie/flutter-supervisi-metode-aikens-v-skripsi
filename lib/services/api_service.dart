import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supervisi/pages/models/ItemPenilaianModel.dart';
import 'package:supervisi/pages/models/KategoriPenilaianModel.dart';
import 'package:supervisi/pages/models/GuruModel.dart';

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

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");
    print("JSON: $json");

    if (response.statusCode == 200) {
      return json; // 🔥 langsung return semua
    } else {
      throw Exception(json['message']);
    }
  }

  static Future<bool> getIsValidator() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isValidator') ?? false;
  }

  static Future<void> saveLoginData(
    String token,
    String role,
    bool isValidator,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', token);
    await prefs.setString('role', role);
    await prefs.setBool('isValidator', isValidator);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
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

// ================ GURU ================
class ApiGuruService {
  Future<List<GuruModel>> getGuru() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse("$baseUrl/guru"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("RESPONSE GURU: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      /// 🔥 HANDLE 2 KEMUNGKINAN FORMAT API
      List data;

      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map && decoded.containsKey('data')) {
        data = decoded['data'];
      } else {
        throw Exception("Format response tidak dikenali");
      }

      return data.map((e) => GuruModel.fromJson(e)).toList();
    } else {
      throw Exception("Gagal load guru");
    }
  }

  Future<List<dynamic>> listHasilSupervisiByGuru(int guruId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/supervisi/hasil-supervisi/$guruId"),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return json['data'];
    } else {
      print(res.statusCode);
      throw Exception("Gagal load supervisi");
    }
  }

  Future<List<dynamic>> detailHasilSupervisiGurubyJadwal(
    int jadwalId,
    int guruId,
  ) async {
    final res = await http.get(
      Uri.parse("$baseUrl/supervisi/hasil-supervisi/$jadwalId/$guruId"),
    );

    final json = jsonDecode(res.body);
    return json['data'];
  }

  Future<List<dynamic>> getStatistikGuru(int guruId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/supervisi/statistik-guru/$guruId"),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return json['data'];
    } else {
      throw Exception("Gagal load statistik");
    }
  }

  Future<void> tambahGuru({
    required String nama,
    required String email,
    required String password,
    required String nip,
    required String username,
    required String nomorHp,
    required String alamat,
    required String role,
    required bool isValidator,
    required String jenisKelamin,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/guru"),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nama': nama,
        'email': email,
        'password': password,
        'nip': nip,
        'username': username,
        'nomor_hp': nomorHp,
        'alamat': alamat,
        'jenis_kelamin': jenisKelamin,
        'role': role,
        'isValidator': isValidator,
      }),
    );

    print(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Gagal tambah guru");
    }
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

  Future<void> tambahKategoriPenilaian(
    String kodeKategori,
    String namaKategori,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/kategori-penilaian'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'kode_kategori_penilaian': kodeKategori,
        'nama_kategori_penilaian': namaKategori,
      }),
    );

    if (response.statusCode == 200) {
      print('Kategori Penilaian berhasil ditambahkan');
    } else {
      throw Exception('Failed to add kategori penilaian');
    }
  }

  Future editKategoriPenilaian(String kode, String nama) async {
    final res = await http.put(
      Uri.parse('$baseUrl/kategori-penilaian/$kode'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nama_kategori_penilaian': nama}),
    );

    if (res.statusCode != 200) {
      throw Exception("Gagal edit");
    }
  }

  Future deleteKategoriPenilaian(String kode) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/kategori-penilaian/$kode'),
    );

    if (res.statusCode != 200) {
      throw Exception("Gagal hapus");
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
    String versi,
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
        'versi': versi,
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
    String versi,
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
        'versi': versi,
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

  Future<bool> toggleDigunakan(int id) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/item-penilaian/toggle/$id"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['isDigunakan'];
    } else {
      throw Exception("Gagal toggle");
    }
  }

  Future<Map<String, dynamic>> getItemDigunakan() async {
    final response = await http.get(
      Uri.parse('$baseUrl/item-penilaian/digunakan'),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      /// 🔥 pastikan selalu Map
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        return {};
      }
    } else {
      throw Exception('Gagal ambil data');
    }
  }

  Future<List<ItemPenilaianModel>> getItemUntukSupervisi() async {
    try {
      final res = await getItemDigunakan();

      print("RAW RESPONSE: $res");

      List data = [];

      /// 🔥 VALIDASI SUPER AMAN
      if (res != null &&
          res is Map<String, dynamic> &&
          res['data'] != null &&
          res['data'] is List) {
        data = List.from(res['data']); // 🔥 pakai List.from biar aman
      }

      /// 🔥 JIKA KOSONG → fallback
      if (data.isEmpty) {
        print("PAKAI FALLBACK");
        return await getItemPenilaian();
      }

      /// 🔥 PARSING AMAN
      return data
          .where((e) => e != null)
          .map((e) => ItemPenilaianModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      print("ERROR getItemUntukSupervisi: $e");
      return [];
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

class ApiSupervisiService {
  Future<Map<String, dynamic>> submitSupervisi({
    required int idGuru,
    required int idJadwal,
    required Map<int, int> jawaban,
  }) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/supervisi/simpan-jawaban"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "id_guru": idGuru,
        "id_jadwal_supervisi": idJadwal,
        "jawaban": jawaban.entries.map((e) {
          return {"id_item": e.key, "nilai": e.value};
        }).toList(),
      }),
    );
    final result = jsonDecode(response.body);

    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.body);
      print(response.statusCode);
      return jsonDecode(response.body); // 🔥 PENTING
    } else {
      print(response.body);
      print(response.statusCode);
      throw Exception("Gagal kirim");
    }
  }

  Future<void> simpanHasilSupervisi({
    required int guruId,
    required int idJadwal,
    required int nilai,
    required String tindakLanjut,
    required String umpanBalik,
  }) async {
    final token = await getToken();

    await http.post(
      Uri.parse("$baseUrl/supervisi/simpan-hasil-supervisi"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "id_guru": guruId,
        "id_jadwal_supervisi": idJadwal, // 🔥 WAJIB
        "nilai": nilai,
        "kode_tindak_lanjut": tindakLanjut,
        "umpan_balik": umpanBalik,
      }),
    );
  }

  Future<List<dynamic>> getGuruByJadwalSupervisi(int idJadwal) async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/supervisi/get-list-guru/$idJadwal"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal ambil data guru");
    }

    final json = jsonDecode(response.body);
    return json['data'];
  }

  Future<void> tambahJadwal({
    required String namaPeriode,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String deskripsi,
  }) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/supervisi/tambah-jadwal-supervisi"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "nama_periode": namaPeriode,
        "tanggal_mulai": tanggalMulai,
        "tanggal_selesai": tanggalSelesai,
        "deskripsi": deskripsi,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal tambah jadwal");
    }
  }

  Future<List<dynamic>> getJadwalSupervisi() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/supervisi/get-list-jadwal-supervisi"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal ambil jadwal");
    }

    final json = jsonDecode(response.body);
    return json['data'];
  }

  Future<void> editJadwal({
    required int idJadwal,
    required String namaPeriode,
    required String deskripsi,
    required String tanggalMulai,
    required String tanggalSelesai,
  }) async {
    final token = await getToken();

    final response = await http.post(
      // 🔥 GANTI POST
      Uri.parse("$baseUrl/supervisi/edit-jadwal-supervisi/$idJadwal"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "nama_periode": namaPeriode,
        "deskripsi": deskripsi,
        "tanggal_mulai": tanggalMulai,
        "tanggal_selesai": tanggalSelesai,
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Gagal update jadwal");
    }
  }

  Future<Map<String, dynamic>> getDetailJadwalSupervisi(int id) async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/supervisi/detail-jadwal-supervisi/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    final json = jsonDecode(response.body);
    return json['data'];
  }

  Future<void> deleteJadwal(int idJadwal) async {
    final token = await getToken();

    final response = await http.delete(
      Uri.parse("$baseUrl/supervisi/delete-jadwal-supervisi/$idJadwal"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal hapus jadwal");
    }
  }
}

class ApiTindakLanjutHasilSupervisiService {
  Future<List<dynamic>> getKodeTindakLanjutHasilSupervisi() async {
    final response = await http.get(
      Uri.parse("$baseUrl/kode-tindak-lanjut-hasil-supervisi"),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // ✅ sekarang benar
    } else {
      throw Exception("Gagal load data");
    }
  }

  Future<void> deleteTindakLanjut(String kode) async {
    await http.delete(
      Uri.parse("$baseUrl/kode-tindak-lanjut-hasil-supervisi/$kode"),
    );
  }

  Future<void> updateTindakLanjut({
    required String kode,
    required String nama,
  }) async {
    await http.put(
      Uri.parse("$baseUrl/kode-tindak-lanjut-hasil-supervisi/$kode"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nama_tindak_lanjut": nama}),
    );
  }

  Future<void> createTindakLanjut({
    required String kode,
    required String nama,
  }) async {
    await http.post(
      Uri.parse("$baseUrl/kode-tindak-lanjut-hasil-supervisi"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "kode_tindak_lanjut": kode,
        "nama_tindak_lanjut": nama,
      }),
    );
  }
}

class ApiKodeGolonganService {
  Future<List<dynamic>> getAllKodeGolongan() async {
    final response = await http.get(Uri.parse("$baseUrl/kode-golongan"));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // ✅ sekarang benar
    } else {
      throw Exception("Gagal load data");
    }
  }

  Future<void> getKodeGolonganByKode(String kode) async {
    final response = await http.get(Uri.parse("$baseUrl/kode-golongan/$kode"));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // ✅ sekarang benar
    } else {
      throw Exception("Gagal load data");
    }
  }

  Future<void> createKodeGolongan({
    required String kode,
    required String nama,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/kode-golongan"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"kode_golongan": kode, "nama_golongan": nama}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // ✅ sekarang benar
    } else {
      throw Exception("Gagal load data");
    }
  }

  Future<void> updateKodeGolongan({
    required String kode,
    required String nama,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/kode-golongan/$kode"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nama_golongan": nama}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // ✅ sekarang benar
    } else {
      throw Exception("Gagal load data");
    }
  }

  Future<void> deleteKodeGolongan(String kode) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/kode-golongan/$kode"),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // ✅ sekarang benar
    } else {
      throw Exception("Gagal load data");
    }
  }
}

class ApiKodeJabatanService {
  Future<List<dynamic>> getAllKodeJabatan() async {
    final response = await http.get(Uri.parse("$baseUrl/kode-jabatan"));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // ✅ sekarang benar
    } else {
      throw Exception("Gagal load data");
    }
  }

  Future<void> getKodeJabatanByKode(String kode) async {
    final response = await http.get(Uri.parse("$baseUrl/kode-jabatan/$kode"));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // ✅ sekarang benar
    } else {
      throw Exception("Gagal load data");
    }
  }

  Future<void> createKodeJabatan({
    required String kode,
    required String nama,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/kode-jabatan"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"kode_jabatan": kode, "nama_jabatan": nama}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // ✅ sekarang benar
    } else {
      throw Exception("Gagal load data");
    }
  }

  Future<void> updateKodeJabatan({
    required String kode,
    required String nama,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/kode-jabatan/$kode"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nama_jabatan": nama}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // ✅ sekarang benar
    } else {
      throw Exception("Gagal load data");
    }
  }

  Future<void> deleteKodeJabatan(String kode) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/kode-jabatan/$kode"),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // ✅ sekarang benar
    } else {
      throw Exception("Gagal load data");
    }
  }
}

class ApiKodeStatusPegawaiService {
  Future<List<dynamic>> getAllKodeStatusPegawai() async {
    final response = await http.get(Uri.parse("$baseUrl/kode-status-pegawai"));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // ✅ sekarang benar
    } else {
      throw Exception("Gagal load data");
    }
  }

  Future<void> getKodeStatusPegawaiByKode(String kode) async {
    final response = await http.get(
      Uri.parse("$baseUrl/kode-status-pegawai/$kode"),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // ✅ sekarang benar
    } else {
      throw Exception("Gagal load data");
    }
  }

  Future<void> createKodeStatusPegawai({
    required String kode,
    required String nama,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/kode-status-pegawai"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "kode_status_pegawai": kode,
        "nama_status_pegawai": nama,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // ✅ sekarang benar
    } else {
      throw Exception("Gagal load data");
    }
  }

  Future<void> updateKodeStatusPegawai({
    required String kode,
    required String nama,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/kode-status-pegawai/$kode"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nama_status_pegawai": nama}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // ✅ sekarang benar
    } else {
      throw Exception("Gagal load data");
    }
  }

  Future<void> deleteKodeStatusPegawai(String kode) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/kode-status-pegawai/$kode"),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // ✅ sekarang benar
    } else {
      throw Exception("Gagal load data");
    }
  }
}

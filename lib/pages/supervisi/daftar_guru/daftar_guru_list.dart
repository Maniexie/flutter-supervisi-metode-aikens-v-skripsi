import 'package:flutter/material.dart';
import 'package:supervisi/pages/models/GuruModel.dart';
import 'package:supervisi/pages/supervisi/daftar_guru/daftar_guru_detail.dart';
import 'package:supervisi/services/api_service.dart';

class DaftarGuruListPage extends StatefulWidget {
  const DaftarGuruListPage({super.key});

  @override
  State<DaftarGuruListPage> createState() => _DaftarGuruListPageState();
}

class _DaftarGuruListPageState extends State<DaftarGuruListPage> {
  List<GuruModel> guruList = [];
  bool isLoading = true;

  List<Map<String, dynamic>> kodeJabatanList = [];
  List<Map<String, dynamic>> kodeGolonganList = [];
  List<Map<String, dynamic>> kodeStatusList = [];

  String getRoleLabel(String role) {
    switch (role) {
      case "guru":
        return "Guru";
      case "kepala_sekolah":
        return "Kepala Sekolah";
      case "operator":
        return "Operator";
      default:
        return "-";
    }
  }

  @override
  void initState() {
    super.initState();
    loadGuru();
    loadMasterData();
  }

  Future<void> loadGuru() async {
    try {
      final data = await ApiGuruService().getGuru();
      setState(() {
        guruList = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loadGuru: $e");
    }
  }

  Future<void> loadMasterData() async {
    try {
      final jabatan = await ApiKodeJabatanService().getAllKodeJabatan();
      final golongan = await ApiKodeGolonganService().getAllKodeGolongan();
      final status = await ApiKodeStatusPegawaiService()
          .getAllKodeStatusPegawai();

      setState(() {
        kodeJabatanList = List<Map<String, dynamic>>.from(jabatan);
        kodeGolonganList = List<Map<String, dynamic>>.from(golongan);
        kodeStatusList = List<Map<String, dynamic>>.from(status);
      });
    } catch (e) {
      debugPrint("Error loadMasterData: $e");
    }
  }

  void showTambahGuru() {
    final formKey = GlobalKey<FormState>();

    final nama = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    final nip = TextEditingController();
    final hp = TextEditingController();
    final alamat = TextEditingController();
    final username = TextEditingController();

    String role = "guru";
    String selectedJenisKelamin = "laki-laki";
    bool isValidator = false;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Tambah Guru"),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nama,
                        decoration: const InputDecoration(labelText: "Nama"),
                        validator: (v) =>
                            v!.isEmpty ? "Tidak boleh kosong" : null,
                      ),
                      TextFormField(
                        controller: email,
                        decoration: const InputDecoration(labelText: "Email"),
                      ),
                      TextFormField(
                        controller: username,
                        decoration: const InputDecoration(
                          labelText: "Username",
                        ),
                      ),
                      TextFormField(
                        controller: password,
                        decoration: const InputDecoration(
                          labelText: "Password",
                        ),
                        obscureText: true,
                      ),
                      TextFormField(
                        controller: nip,
                        decoration: const InputDecoration(labelText: "NIP"),
                      ),

                      /// 🔥 JABATAN

                      /// 🔥 GOLONGAN

                      /// 🔥 STATUS
                      TextFormField(
                        controller: hp,
                        decoration: const InputDecoration(labelText: "No HP"),
                      ),
                      TextFormField(
                        controller: alamat,
                        decoration: const InputDecoration(labelText: "Alamat"),
                      ),

                      const SizedBox(height: 10),

                      /// 🔥 ROLE
                      DropdownButtonFormField<String>(
                        value: role,
                        decoration: const InputDecoration(labelText: "Role"),
                        items: const [
                          DropdownMenuItem(value: "guru", child: Text("Guru")),
                          DropdownMenuItem(
                            value: "operator",
                            child: Text("Operator"),
                          ),
                          DropdownMenuItem(
                            value: "kepala_sekolah",
                            child: Text("Kepala Sekolah"),
                          ),
                        ],
                        onChanged: (value) {
                          setStateDialog(() {
                            role = value!;
                          });
                        },
                      ),

                      /// 🔥 JENIS KELAMIN
                      DropdownButtonFormField<String>(
                        value: selectedJenisKelamin,
                        items: const [
                          DropdownMenuItem(
                            value: 'laki-laki',
                            child: Text('Laki-laki'),
                          ),
                          DropdownMenuItem(
                            value: 'perempuan',
                            child: Text('Perempuan'),
                          ),
                        ],
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedJenisKelamin = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Jenis Kelamin",
                        ),
                      ),

                      /// 🔥 VALIDATOR
                      SwitchListTile(
                        title: const Text("Sebagai Validator"),
                        value: isValidator,
                        onChanged: (val) {
                          setStateDialog(() {
                            isValidator = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              /// 🔥 ACTION BUTTON
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    try {
                      await ApiGuruService().tambahGuru(
                        nama: nama.text,
                        email: email.text,
                        password: password.text,
                        nip: nip.text,
                        username: username.text,
                        nomorHp: hp.text,
                        alamat: alamat.text,
                        role: role,
                        jenisKelamin: selectedJenisKelamin,
                        isValidator: isValidator,
                      );

                      Navigator.pop(context);
                      loadGuru();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Berhasil ditambahkan")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
                    }
                  },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Guru")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: guruList.length,
              itemBuilder: (context, index) {
                final guru = guruList[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        (guru.nama?.isNotEmpty ?? false) ? guru.nama![0] : "?",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(guru.nama ?? "-"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("NIP: ${guru.nip ?? '-'}"),
                        Text("Email: ${guru.email ?? '-'}"),
                        Text("HP: ${guru.nomorHp ?? '-'}"),
                        Text("Role: ${guru.role ?? '-'}"),
                      ],
                    ),
                    trailing: Icon(
                      Icons.verified,
                      color: guru.isValidator ? Colors.green : Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DaftarGuruDetailPage(guru: guru),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showTambahGuru,
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
  String? selectedJenisKelamin;
  List kodeJabatanList = [];
  List kodeGolonganList = [];
  List kodeStatusList = [];

  String role = "guru";
  bool isValidator = false;
  String? selectedJabatan;
  String? selectedGolongan;
  String? selectedStatus;

  void showTambahGuru() {
    final nama = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    final nip = TextEditingController();
    final hp = TextEditingController();
    final alamat = TextEditingController();
    final username = TextEditingController();

    String role = "guru";
    String? selectedJenisKelamin = "laki-laki";
    bool isValidator = false;
    String? selectedJabatan;
    String? selectedGolongan;
    String? selectedStatus;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Tambah Guru"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nama,
                      decoration: const InputDecoration(labelText: "Nama"),
                    ),
                    TextField(
                      controller: email,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                    TextField(
                      controller: username,
                      decoration: const InputDecoration(labelText: "username"),
                    ),
                    TextField(
                      controller: password,
                      decoration: const InputDecoration(labelText: "Password"),
                    ),
                    TextField(
                      controller: nip,
                      decoration: const InputDecoration(labelText: "NIP"),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedJabatan,
                      decoration: const InputDecoration(labelText: "Jabatan"),
                      items: kodeJabatanList.map<DropdownMenuItem<String>>((
                        item,
                      ) {
                        return DropdownMenuItem(
                          value: item['kode_jabatan'],
                          child: Text(item['nama_jabatan']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedJabatan = value;
                        });
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedGolongan,
                      decoration: const InputDecoration(labelText: "Golongan"),
                      items: kodeGolonganList.map<DropdownMenuItem<String>>((
                        item,
                      ) {
                        return DropdownMenuItem(
                          value: item['kode_golongan'],
                          child: Text(item['nama_golongan']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedJabatan = value;
                        });
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: "Status Pegawai",
                      ),
                      items: kodeStatusList.map<DropdownMenuItem<String>>((
                        item,
                      ) {
                        return DropdownMenuItem(
                          value: item['kode_status_pegawai'],
                          child: Text(item['nama_status_pegawai']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedJabatan = value;
                        });
                      },
                    ),
                    TextField(
                      controller: hp,
                      decoration: const InputDecoration(labelText: "No HP"),
                    ),
                    TextField(
                      controller: alamat,
                      decoration: const InputDecoration(labelText: "Alamat"),
                    ),

                    const SizedBox(height: 10),

                    // 🔥 ROLE
                    DropdownButtonFormField(
                      value: role,
                      items: ["guru", "operator"].map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedJabatan = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: "Role"),
                    ),

                    const SizedBox(height: 10),

                    // 🔥 JENIS KELAMIN
                    DropdownButtonFormField<String>(
                      value: selectedJenisKelamin,
                      decoration: const InputDecoration(
                        labelText: "Jenis Kelamin",
                      ),

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
                          selectedJabatan = value;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    // 🔥 VALIDATOR SWITCH
                    SwitchListTile(
                      title: const Text("Sebagai Validator"),
                      value: isValidator,
                      onChanged: (val) {
                        setStateDialog(() => isValidator = val);
                      },
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedJabatan == null ||
                        selectedGolongan == null ||
                        selectedStatus == null ||
                        selectedJenisKelamin == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Lengkapi semua data")),
                      );
                      return;
                    }

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

                        kodeJabatan: selectedJabatan,
                        kodeGolongan: selectedGolongan,
                        kodeStatusPegawai: selectedStatus,
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
      print(e);
    }
  }

  Future<void> loadMasterData() async {
    try {
      final jabatan = await ApiKodeJabatanService().getAllKodeJabatan();
      final golongan = await ApiKodeGolonganService().getAllKodeGolongan();
      final status = await ApiKodeStatusPegawaiService()
          .getAllKodeStatusPegawai();

      setState(() {
        kodeJabatanList = jabatan;
        kodeGolonganList = golongan;
        kodeStatusList = status;
      });
    } catch (e) {
      print(e);
    }
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
                        guru.nama != null && guru.nama!.isNotEmpty
                            ? guru.nama![0]
                            : "?",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    title: Text(guru.nama ?? "-"),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("NIP: ${guru.nip ?? '-'}"),
                        Text("Email: ${guru.email}"),
                        Text("HP: ${guru.nomorHp}"),
                        Text("Role: ${guru.role}"),
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
        child: const Icon(Icons.add),
        onPressed: showTambahGuru,
      ),
    );
  }
}

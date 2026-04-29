import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supervisi/pages/models/ItemPenilaianModel.dart';
import 'package:supervisi/pages/supervisi/daftar_guru/daftar_guru_list.dart';
import 'package:supervisi/pages/supervisi/supervisi_jadwal.dart';
import 'package:supervisi/services/api_service.dart';

class SupervisiHomePage extends StatefulWidget {
  const SupervisiHomePage({super.key});

  @override
  State<SupervisiHomePage> createState() => _SupervisiHomePageState();
}

class _SupervisiHomePageState extends State<SupervisiHomePage> {
  final getGuruByJadwalSupervisi =
      ApiSupervisiService().getGuruByJadwalSupervisi;

  final List<FlSpot> spots = [
    FlSpot(0, 3.5),
    FlSpot(1, 3.8),
    FlSpot(2, 4.0),
    FlSpot(3, 3.7),
    FlSpot(4, 4.2),
  ];

  final List<String> months = ["Jan", "Feb", "Mar", "Apr", "Mei"];

  List<ItemPenilaianModel> supervisiItems = [];

  void showTambahJadwalDialog() {
    final namaController = TextEditingController();
    final deskripsiController = TextEditingController();

    DateTime? tglMulai;
    DateTime? tglSelesai;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Tambah Jadwal Supervisi"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: "Nama Periode",
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: deskripsiController,
                      decoration: const InputDecoration(labelText: "Deskripsi"),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setStateDialog(() => tglMulai = picked);
                        }
                      },
                      child: Text(
                        tglMulai == null
                            ? "Pilih Tanggal Mulai"
                            : tglMulai.toString().split(' ')[0],
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setStateDialog(() => tglSelesai = picked);
                        }
                      },
                      child: Text(
                        tglSelesai == null
                            ? "Pilih Tanggal Selesai"
                            : tglSelesai.toString().split(' ')[0],
                      ),
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
                    if (namaController.text.isEmpty ||
                        deskripsiController.text.isEmpty ||
                        tglMulai == null ||
                        tglSelesai == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Semua field wajib diisi"),
                        ),
                      );
                      return;
                    }

                    try {
                      await ApiSupervisiService().tambahJadwal(
                        namaPeriode: namaController.text,
                        tanggalMulai: tglMulai.toString().split(' ')[0],
                        tanggalSelesai: tglSelesai.toString().split(' ')[0],
                        deskripsi: deskripsiController.text,
                      );

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Berhasil tambah jadwal")),
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
      appBar: AppBar(title: Text("")),

      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // SizedBox(height: 20),

          // 🔹 FITUR TAMBAHAN
          Card(
            child: ListTile(
              leading: Icon(Icons.people),
              title: Text("Daftar Guru"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DaftarGuruListPage()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.assignment),
              title: Text("Daftar Jadwal Supervisi"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupervisiJadwalPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showTambahJadwalDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

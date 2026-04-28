import 'package:flutter/material.dart';
import 'package:supervisi/pages/supervisi/supervisi_kuesioner.dart';
import 'package:supervisi/services/api_service.dart';

class SupervisiListGuruPage extends StatefulWidget {
  final int idJadwal;

  const SupervisiListGuruPage({super.key, required this.idJadwal});

  @override
  State<SupervisiListGuruPage> createState() => _SupervisiListGuruPageState();
}

class _SupervisiListGuruPageState extends State<SupervisiListGuruPage> {
  List guruList = [];
  bool isLoading = true;

  String namaPeriode = '';

  int get totalGuru => guruList.length;

  int get totalSudah =>
      guruList.where((g) => g['sudah_disupervisi'] == 1).length;

  double get progress => totalGuru == 0 ? 0 : totalSudah / totalGuru;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // 🔥 LOAD SEMUA DATA SEKALIGUS
  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      final guru = await ApiSupervisiService().getGuruByJadwalSupervisi(
        widget.idJadwal,
      );

      final jadwal = await ApiSupervisiService().getDetailJadwalSupervisi(
        widget.idJadwal,
      );

      setState(() {
        guruList = guru;
        namaPeriode = jadwal['nama_periode'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  void goToKuesioner(int idGuru, bool sudah) async {
    if (sudah) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Guru sudah disupervisi")));
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SupervisiKuesionerPage(idGuru: idGuru, idJadwal: widget.idJadwal),
      ),
    );

    if (result == true) {
      loadData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Supervisi berhasil disimpan")),
      );
    }
  }

  void showEditJadwalDialog() {
    final namaController = TextEditingController(text: namaPeriode);
    final deskripsiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Jadwal Supervisi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: "Nama Periode"),
              ),
              TextField(
                controller: deskripsiController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ApiSupervisiService().editJadwal(
                    idJadwal: widget.idJadwal,
                    namaPeriode: namaController.text,
                    deskripsi: deskripsiController.text,
                  );

                  Navigator.pop(context);
                  loadData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Berhasil update")),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(namaPeriode.isEmpty ? "Loading..." : namaPeriode),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: showEditJadwalDialog,
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔥 SUMMARY
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: ListTile(
                            title: const Text("Total Guru"),
                            trailing: Text("$totalGuru"),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          child: ListTile(
                            title: const Text("Sudah"),
                            trailing: Text("$totalSudah"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔥 PROGRESS BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Progress ${(progress * 100).toStringAsFixed(0)}%"),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        color: progress == 1 ? Colors.green : Colors.blue,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 🔥 LIST GURU
                Expanded(
                  child: ListView.builder(
                    itemCount: guruList.length,
                    itemBuilder: (context, index) {
                      final guru = guruList[index];
                      final sudah = guru['sudah_disupervisi'] == 1;

                      return Card(
                        color: sudah ? Colors.grey[200] : Colors.white,
                        child: ListTile(
                          enabled: !sudah,
                          title: Text(guru['nama']),
                          subtitle: Text(
                            sudah ? "Sudah disupervisi" : "Belum disupervisi",
                            style: TextStyle(
                              color: sudah ? Colors.green : Colors.red,
                            ),
                          ),
                          trailing: Icon(
                            sudah ? Icons.check_circle : Icons.arrow_forward,
                            color: sudah ? Colors.green : Colors.blue,
                          ),
                          onTap: sudah
                              ? null
                              : () => goToKuesioner(guru['id_guru'], sudah),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

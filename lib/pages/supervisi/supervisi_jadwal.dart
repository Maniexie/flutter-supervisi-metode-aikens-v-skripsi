import 'package:flutter/material.dart';
import 'package:supervisi/pages/supervisi/supervisi_list_guru.dart';
import 'package:supervisi/services/api_service.dart';

class SupervisiJadwalPage extends StatefulWidget {
  const SupervisiJadwalPage({super.key});

  @override
  State<SupervisiJadwalPage> createState() => _SupervisiJadwalPageState();
}

class _SupervisiJadwalPageState extends State<SupervisiJadwalPage> {
  List jadwalList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadJadwal();
  }

  Future<void> loadJadwal() async {
    try {
      final data = await ApiSupervisiService().getJadwalSupervisi();

      setState(() {
        jadwalList = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  void goToGuru(int idJadwal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupervisiListGuruPage(idJadwal: idJadwal),
      ),
    );
  }

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

  void confirmDelete(int idJadwal) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text("Apakah yakin ingin menghapus jadwal ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                try {
                  await ApiSupervisiService().deleteJadwal(idJadwal);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Berhasil dihapus")),
                  );

                  loadJadwal(); // 🔥 refresh list
                } catch (e) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
                }
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Jadwal Supervisi")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : jadwalList.isEmpty
          ? const Center(child: Text("Belum ada jadwal"))
          : ListView.builder(
              itemCount: jadwalList.length,
              itemBuilder: (context, index) {
                final item = jadwalList[index];
                bool isActive =
                    DateTime.now().isAfter(
                      DateTime.parse(item['tanggal_mulai']),
                    ) &&
                    DateTime.now().isBefore(
                      DateTime.parse(item['tanggal_selesai']),
                    );

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(item['nama_periode']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${item['tanggal_mulai']} - ${item['tanggal_selesai']}",
                        ),
                        Text(
                          isActive ? "Aktif" : "Selesai",
                          style: TextStyle(
                            color: isActive ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    // 🔥 MULTI ICON (DETAIL + DELETE)
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              confirmDelete(item['id_jadwal_supervisi']),
                        ),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),

                    onTap: () => goToGuru(item['id_jadwal_supervisi']),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showTambahJadwalDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

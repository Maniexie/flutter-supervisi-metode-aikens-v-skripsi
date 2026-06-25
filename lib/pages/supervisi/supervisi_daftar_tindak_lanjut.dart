import 'package:flutter/material.dart';
import 'package:supervisi/services/api_service.dart';

class SupervisiDaftarTindakLanjutPage extends StatefulWidget {
  const SupervisiDaftarTindakLanjutPage({super.key});

  @override
  State<SupervisiDaftarTindakLanjutPage> createState() =>
      _SupervisiDaftarTindakLanjutPageState();
}

class _SupervisiDaftarTindakLanjutPageState
    extends State<SupervisiDaftarTindakLanjutPage> {
  List<dynamic> tindakLanjutList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDaftarTindakLanjut();
  }

  Future<void> loadDaftarTindakLanjut() async {
    try {
      final data = await ApiTindakLanjutHasilSupervisiService()
          .getKodeTindakLanjutHasilSupervisi();

      setState(() {
        tindakLanjutList = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  void showEditDialog(dynamic item) {
    final namaController = TextEditingController(
      text: item['nama_tindak_lanjut'],
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Tindak Lanjut"),
        content: TextField(
          controller: namaController,
          decoration: const InputDecoration(labelText: "Nama"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiTindakLanjutHasilSupervisiService().updateTindakLanjut(
                  kode: item['kode_tindak_lanjut'],
                  nama: namaController.text,
                );

                Navigator.pop(context);
                loadDaftarTindakLanjut();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Berhasil diupdate")),
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
      ),
    );
  }

  void confirmDelete(String kode) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Yakin ingin menghapus?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiTindakLanjutHasilSupervisiService().deleteTindakLanjut(
                  kode,
                );

                Navigator.pop(context);
                loadDaftarTindakLanjut();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Berhasil dihapus")),
                );
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
      ),
    );
  }

  void showTambahDialog() {
    final kodeController = TextEditingController();
    final namaController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Tindak Lanjut"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: kodeController,
              decoration: const InputDecoration(labelText: "Kode"),
            ),
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: "Nama"),
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
                await ApiTindakLanjutHasilSupervisiService().createTindakLanjut(
                  kode: kodeController.text,
                  nama: namaController.text,
                );

                Navigator.pop(context);
                loadDaftarTindakLanjut();

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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Tindak Lanjut")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tindakLanjutList.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "Belum Ada Daftar Tindak Lanjut Supervisi",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Rencana Tindak Lanjut",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: tindakLanjutList.length,
                    itemBuilder: (context, index) {
                      final item = tindakLanjutList[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.assignment),

                          title: Text(item['nama_tindak_lanjut'] ?? '-'),

                          subtitle: Text("Kode: ${item['kode_tindak_lanjut']}"),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  showEditDialog(item);
                                },
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  confirmDelete(item['kode_tindak_lanjut']);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showTambahDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

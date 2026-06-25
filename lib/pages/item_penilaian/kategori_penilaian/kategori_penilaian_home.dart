import 'package:flutter/material.dart';
import 'package:supervisi/pages/models/KategoriPenilaianModel.dart';
import 'package:supervisi/services/api_service.dart';

class KategoriPenilaianHomePage extends StatefulWidget {
  const KategoriPenilaianHomePage({super.key});

  @override
  State<KategoriPenilaianHomePage> createState() =>
      _KategoriPenilaianHomePageState();
}

class _KategoriPenilaianHomePageState extends State<KategoriPenilaianHomePage> {
  List<KategoriPenilaianModel> kategoriList = []; // ✅ FIX
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadKategori();
  }

  // ================= LOAD =================
  Future<void> loadKategori() async {
    try {
      final data = await ApiKategoriPenilaianService().getKategoriPenilaian();

      setState(() {
        kategoriList = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  // ================= TAMBAH =================
  void tambahKategori() {
    final kodeKategori = TextEditingController();
    final namaKategori = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Kategori"),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: kodeKategori,
              decoration: const InputDecoration(
                labelText: "Kode Kategori",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: namaKategori,
              decoration: const InputDecoration(
                labelText: "Nama Kategori",
                border: OutlineInputBorder(),
              ),
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
              // 🔴 VALIDASI
              if (kodeKategori.text.isEmpty || namaKategori.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Semua field wajib diisi")),
                );
                return;
              }

              try {
                await ApiKategoriPenilaianService().tambahKategoriPenilaian(
                  kodeKategori.text,
                  namaKategori.text,
                );

                Navigator.pop(context);
                loadKategori();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Berhasil tambah")),
                );
              } catch (e) {
                print(e);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ================= EDIT =================
  void editKategori(KategoriPenilaianModel item) {
    final kodeKategori = TextEditingController(
      text: item.kodeKategoriPenilaian,
    );
    final namaKategori = TextEditingController(
      text: item.namaKategoriPenilaian,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Kategori"),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: kodeKategori,
              readOnly: true, // 🔥 biasanya kode tidak boleh diubah
              decoration: const InputDecoration(
                labelText: "Kode Kategori",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: namaKategori,
              decoration: const InputDecoration(
                labelText: "Nama Kategori",
                border: OutlineInputBorder(),
              ),
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
              if (namaKategori.text.isEmpty) return;

              await ApiKategoriPenilaianService().editKategoriPenilaian(
                item.kodeKategoriPenilaian,
                namaKategori.text,
              );

              Navigator.pop(context);
              loadKategori();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // ================= HAPUS =================
  void hapusKategori(KategoriPenilaianModel item) {
    // ✅ FIX
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: Text(
          "Hapus kategori?\n\n${item.namaKategoriPenilaian}", // ✅ FIX
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);

              await ApiKategoriPenilaianService().deleteKategoriPenilaian(
                item.kodeKategoriPenilaian, // ✅ FIX
              );

              loadKategori();
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kategori Penilaian")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : kategoriList.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey),
                  Text(
                    "Belum ada kategori penilaian",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text("Silahkan tambah terlebih dahulu"),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Kategori Penilaian",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: kategoriList.length,
                    itemBuilder: (context, index) {
                      final item = kategoriList[index];

                      return Card(
                        child: ListTile(
                          title: Text(item.namaKategoriPenilaian),
                          subtitle: Text(item.kodeKategoriPenilaian),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => editKategori(item),
                                icon: const Icon(Icons.edit),
                                color: Colors.blue,
                              ),
                              IconButton(
                                onPressed: () => hapusKategori(item),
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
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
        onPressed: tambahKategori,
        child: const Icon(Icons.add),
      ),
    );
  }
}

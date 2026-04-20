import 'package:flutter/material.dart';
import 'package:supervisi/pages/aiken/item_penilaian_detail.dart';
import 'package:supervisi/pages/models/ItemPenilaianModel.dart';
import 'package:supervisi/pages/models/KategoriPenilaianModel.dart';
import 'package:supervisi/services/api_service.dart';

class ItemPenilaian extends StatefulWidget {
  const ItemPenilaian({super.key});

  @override
  State<ItemPenilaian> createState() => _ItemPenilaianState();
}

String formatStatus(String status) {
  switch (status) {
    case "valid":
      return "Valid";
    case "tidak_valid":
      return "Tidak Valid";
    default:
      return "-";
  }
}

class _ItemPenilaianState extends State<ItemPenilaian> {
  List<ItemPenilaianModel> kategoriList = [];
  String? selectedKategori;
  bool isLoadingKategori = true;

  @override
  late Future<List<ItemPenilaianModel>> futureItems;

  @override
  void initState() {
    super.initState();
    futureItems = ApiItemPenilaianService().getItemPenilaian();
  }

  void refreshData() {
    setState(() {
      futureItems = ApiItemPenilaianService().getItemPenilaian();
    });
  }

  void tambahItem() {
    TextEditingController pernyataanController = TextEditingController();

    String? selectedKategori;
    bool isLoading = false;
    bool isLoadingKategori = true;
    List<KategoriPenilaianModel> kategoriList = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // 🔥 LOAD DATA SAAT DIALOG DIBUKA
            if (isLoadingKategori) {
              ApiKategoriPenilaianService().getKategoriPenilaian().then((data) {
                setStateDialog(() {
                  kategoriList = data;
                  isLoadingKategori = false;
                });
              });
            }

            return AlertDialog(
              title: const Text("Tambah Item Penilaian"),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔽 DROPDOWN
                  isLoadingKategori
                      ? const CircularProgressIndicator()
                      : DropdownButtonFormField<String>(
                          value: selectedKategori,
                          hint: const Text("Pilih Kategori"),
                          items: kategoriList.map((item) {
                            return DropdownMenuItem<String>(
                              key: Key(item.kodeKategoriPenilaian),
                              value: item.kodeKategoriPenilaian,
                              child: Text(
                                "${item.kodeKategoriPenilaian} - ${item.namaKategoriPenilaian}",
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setStateDialog(() {
                              selectedKategori = value;
                            });
                          },
                        ),

                  const SizedBox(height: 12),

                  // ✍️ INPUT
                  TextField(
                    minLines: 1,
                    maxLines: 5,
                    controller: pernyataanController,
                    decoration: const InputDecoration(
                      labelText: "Pernyataan",
                      hintText: "Masukkan pernyataan",
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      contentPadding: EdgeInsets.all(12),
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
                  onPressed: isLoading
                      ? null
                      : () async {
                          // 🔴 VALIDASI
                          if (selectedKategori == null ||
                              pernyataanController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Semua field wajib diisi"),
                              ),
                            );
                            return;
                          }

                          setStateDialog(() => isLoading = true);

                          try {
                            await ApiItemPenilaianService().tambahItemPenilaian(
                              selectedKategori!,
                              pernyataanController.text,
                            );

                            Navigator.pop(context);
                            refreshData(); // reload list
                          } catch (e) {
                            print(e);
                          }

                          setStateDialog(() => isLoading = false);
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Simpan"),
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
      appBar: AppBar(title: const Text("Item Penilaian"), centerTitle: true),

      body: FutureBuilder<List<ItemPenilaianModel>>(
        future: futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Data kosong"));
          }

          final items = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              final isValid = item.status == "valid";

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                // CONTENT ( Pernyataan, Kategori, Versi, Status )
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),

                  title: Text(
                    item.pernyataan,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kategori: ${item.kodeKategori} | V: ${item.nilaiAiken} | Versi: ${item.versi}",
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isValid ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            formatStatus(item.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ICON EDIT DAN DELETE ITEM PENILAIAN
                  trailing: Row(
                    mainAxisSize:
                        MainAxisSize.min, // 🔥 penting biar tidak full lebar
                    children: [
                      // ✏️ EDIT
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // editItem(item); // nanti kita buat function-nya
                        },
                      ),

                      // 🗑 DELETE
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // hapusItem(item.id); // sesuaikan id
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ItemPenilaianDetail(),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      // 👇 TOMBOL TAMBAH ITEM PENILAIAN
      floatingActionButton: FloatingActionButton(
        onPressed: tambahItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}

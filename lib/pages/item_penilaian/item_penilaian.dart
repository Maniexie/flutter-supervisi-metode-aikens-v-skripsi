import 'package:flutter/material.dart';
import 'package:supervisi/pages/item_penilaian/kategori_penilaian/kategori_penilaian_home.dart';
import 'package:supervisi/pages/models/ItemPenilaianModel.dart';
import 'package:supervisi/pages/models/KategoriPenilaianModel.dart';
import 'package:supervisi/services/api_service.dart';
import 'package:flutter/services.dart';

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
  int totalDigunakan = 0;
  bool sudahLoad = false;

  @override
  List<ItemPenilaianModel> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
    loadTotalDigunakan();
  }

  Future<void> loadData() async {
    try {
      final data = await ApiItemPenilaianService().getItemPenilaian();
      setState(() {
        items = data;
        isLoading = false;
        print(data.first.isDigunakan);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadTotalDigunakan() async {
    try {
      final res = await ApiItemPenilaianService().getItemDigunakan();

      setState(() {
        totalDigunakan = res['total'];
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void tambahItem() {
    TextEditingController pernyataanController = TextEditingController();
    TextEditingController versiController = TextEditingController();

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
            if (!sudahLoad) {
              sudahLoad = true;
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
                  const SizedBox(height: 12),

                  TextField(
                    controller: versiController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: "Versi",
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

                          if (versiController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Versi wajib diisi"),
                              ),
                            );
                            return;
                          }

                          if (int.tryParse(versiController.text) == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Versi wajib berupa angka"),
                              ),
                            );
                            return;
                          }

                          setStateDialog(() => isLoading = true);

                          try {
                            await ApiItemPenilaianService().tambahItemPenilaian(
                              selectedKategori!,
                              pernyataanController.text,
                              versiController.text, // 🔥 TAMBAHAN
                            );

                            Navigator.pop(context);
                            loadData(); // reload list
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

  void editItem(ItemPenilaianModel item) {
    TextEditingController pernyataanController = TextEditingController(
      text: item.pernyataan,
    );
    TextEditingController versiController = TextEditingController(
      text: item.versi.toString(),
    );

    String? selectedKategori = item.kodeKategori;

    bool isLoading = false;
    bool isLoadingKategori = true;
    List<KategoriPenilaianModel> kategoriList = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // 🔥 LOAD kategori
            if (!sudahLoad) {
              sudahLoad = true;
              ApiKategoriPenilaianService().getKategoriPenilaian().then((data) {
                setStateDialog(() {
                  kategoriList = data;
                  isLoadingKategori = false;
                });
              });
            }

            return AlertDialog(
              title: const Text("Edit Item Penilaian"),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🔽 DROPDOWN
                  isLoadingKategori
                      ? const CircularProgressIndicator()
                      : DropdownButtonFormField<String>(
                          value: selectedKategori,
                          hint: const Text("Pilih Kategori"),
                          items: kategoriList.map((k) {
                            return DropdownMenuItem<String>(
                              value: k.kodeKategoriPenilaian,
                              child: Text(
                                "${k.kodeKategoriPenilaian} - ${k.namaKategoriPenilaian}",
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

                  // ✍️ PERNYATAAN
                  TextField(
                    controller: pernyataanController,
                    minLines: 1,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: "Pernyataan",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: versiController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: "Versi",
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
                          if (versiController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Versi wajib diisi"),
                              ),
                            );
                            return;
                          }

                          if (int.tryParse(versiController.text) == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Versi wajib berupa angka"),
                              ),
                            );
                            return;
                          }
                          setStateDialog(() => isLoading = true);

                          try {
                            await ApiItemPenilaianService().editItemPenilaian(
                              item.id, // 🔥 ambil id dari item
                              selectedKategori!,
                              pernyataanController.text,
                              versiController.text,
                            );

                            Navigator.pop(context);
                            loadData();
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
                      : const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void hapusItem(ItemPenilaianModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: Text("Yakin ingin menghapus?\n\n${item.pernyataan}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);

              try {
                await ApiItemPenilaianService().deleteItemPenilaian(item.id);

                // 🔥 LANGSUNG HAPUS DARI LIST (TANPA REFRESH)
                setState(() {
                  items.removeWhere((i) => i.id == item.id);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Berhasil dihapus")),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Gagal hapus: $e")));
              }
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Penilaian"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$totalDigunakan Item",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text("Data kosong"))
          : ListView.separated(
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

                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),

                    title: Text(
                      item.pernyataan,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kategori: ${item.kodeKategori} | V: ${item.nilaiAiken} | Versi: ${item.versi}",
                        ),
                        const SizedBox(height: 6),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: item.status == "valid"
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.status == "valid" ? "VALID" : "TIDAK VALID",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.status == "valid")
                          Switch(
                            value: item.isDigunakan,
                            onChanged: (value) async {
                              try {
                                final newValue = await ApiItemPenilaianService()
                                    .toggleDigunakan(item.id);

                                setState(() {
                                  item.isDigunakan = newValue;
                                  print(item.isDigunakan);
                                });
                                await loadTotalDigunakan(); // 🔥 update count
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Gagal update")),
                                );
                              }
                            },
                          )
                        else
                          const Icon(Icons.block, color: Colors.grey),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editItem(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => hapusItem(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      // 👇 TOMBOL TAMBAH ITEM PENILAIAN
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: "add",
            onPressed: tambahItem,
            icon: const Icon(Icons.add),
            label: const Text("Item Penilaian"),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: "refresh",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KategoriPenilaianHomePage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text("Kategori Penilaian"),
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }
}

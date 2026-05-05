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

Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 16),
        const Text(
          "Data Item Penilaian Kosong",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          "Silakan tambahkan data baru",
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    ),
  );
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
      });

      /// 🔥 pindahkan ke luar setState + cek kosong
      if (data.isNotEmpty) {
        print(data.first.isDigunakan);
      }
    } catch (e) {
      print("ERROR loadData: $e");

      /// 🔥 WAJIB biar loading berhenti
      setState(() {
        isLoading = false;
      });
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

  Future<void> showItemDigunakanDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final res = await ApiItemPenilaianService().getItemDigunakan();
      Navigator.pop(context); // tutup loading

      final List data = res['data'] ?? [];
      final List kategori = (res['perKategori'] as List?) ?? [];

      // ListView.builder(
      //   itemCount: kategori.length,
      //   itemBuilder: (context, index) {
      //     final k = kategori[index];

      //     return ListTile(
      //       title: Text(k['nama_kategori_penilaian']),
      //       trailing: Text("${k['total']} item"),
      //     );
      //   },
      // );
      // print(res['perKategori'] ?? []);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(
            "Item Digunakan",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          titlePadding: const EdgeInsets.all(16),
          titleTextStyle: const TextStyle(fontWeight: FontWeight.bold),
          content: SizedBox(
            width: double.maxFinite,
            child: data.isEmpty
                ? const Text("Tidak ada item digunakan")
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (_, i) {
                      final item = data[i];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔢 NOMOR BULAT
                            Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                "${i + 1}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // 📄 CONTENT
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['nama_kategori_penilaian'] ?? '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['pernyataan'] ?? '-',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
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
            ApiKategoriPenilaianService().getKategoriPenilaian().then((data) {
              setStateDialog(() {
                kategoriList = data;
                isLoadingKategori = false;
              });
            });
            return AlertDialog(
              title: const Text("Tambah Item Penilaian"),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔽 DROPDOWN
                  isLoadingKategori
                      ? const CircularProgressIndicator()
                      : DropdownButtonFormField<String>(
                          value:
                              kategoriList.any(
                                (k) =>
                                    k.kodeKategoriPenilaian == selectedKategori,
                              )
                              ? selectedKategori
                              : null,
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
    bool sudahLoad = false;
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
                child: InkWell(
                  onTap: showItemDigunakanDialog,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Text(
                      "$totalDigunakan Items",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? _buildEmptyState()
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
                            value: item.isDigunakan ?? false,
                            onChanged: (value) async {
                              try {
                                final newValue = await ApiItemPenilaianService()
                                    .toggleDigunakan(item.id);

                                setState(() {
                                  item.isDigunakan = newValue;
                                });

                                await loadData(); // 🔥 reload dari server
                                await loadTotalDigunakan();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Gagal update")),
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
            heroTag: "addItem",
            onPressed: tambahItem,
            icon: const Icon(Icons.add),
            label: const Text("I"),
          ),
          const SizedBox(height: 5),
          FloatingActionButton.extended(
            heroTag: "addKategori",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KategoriPenilaianHomePage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text("K"),
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supervisi/pages/aiken/item_penilaian_detail.dart';
import 'package:supervisi/pages/models/ItemPenilaianModel.dart';
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
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Item Penilaian"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Masukkan item penilaian",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  // TODO: kirim ke API (kalau sudah dibuat POST)
                  refreshData();
                  Navigator.pop(context);
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
      appBar: AppBar(title: const Text("Item Penilaian"), centerTitle: true),

      body: FutureBuilder<List<ItemPenilaianModel>>(
        future: futureItems,
        builder: (context, snapshot) {
          // 🔄 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Error
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // 📦 Empty
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Data kosong"));
          }

          final items = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
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

                  // // 🔵 ICON KATEGORI
                  // leading: CircleAvatar(
                  //   backgroundColor: Colors.blue.shade100,
                  //   child: Text(
                  //     item.kodeKategori,
                  //     style: const TextStyle(
                  //       fontSize: 10,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),

                  // 📌 JUDUL
                  title: Text(
                    item.pernyataan,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // 📊 SUBTITLE
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kategori: ${item.kodeKategori} | Versi: ${item.versi}",
                        ),
                        const SizedBox(height: 4),

                        // 🟢 STATUS BADGE
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

                  // ➡️ ICON
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ItemPenilaianDetail(),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      // ➕ FLOATING BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: tambahItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}

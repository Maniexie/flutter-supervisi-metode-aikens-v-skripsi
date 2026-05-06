import 'package:flutter/material.dart';
import 'package:supervisi/services/api_service.dart';

class DataSupervisiRiwayatPage extends StatefulWidget {
  final int idJadwalSupervisi;
  final int guruId;

  const DataSupervisiRiwayatPage({
    super.key,
    required this.idJadwalSupervisi,
    required this.guruId,
  });

  @override
  State<DataSupervisiRiwayatPage> createState() =>
      _DataSupervisiRiwayatPageState();
}

class _DataSupervisiRiwayatPageState extends State<DataSupervisiRiwayatPage> {
  List detail = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      final res = await ApiGuruService().detailHasilSupervisiGurubyJadwal(
        widget.idJadwalSupervisi,
        widget.guruId,
      );

      setState(() {
        detail = res;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Supervisi HASIL KUISIONER")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : detail.isEmpty
          ? const Center(child: Text("Tidak ada data"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: detail.length,
              itemBuilder: (context, index) {
                final item = detail[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📌 PERNYATAAN
                        Text(
                          item['pernyataan'] ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 10),

                        // 📊 JAWABAN (CHIP BIAR BAGUS)
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(
                              label: Text(item['label'] ?? '-'),
                              backgroundColor: Colors.blue.shade100,
                            ),
                            Chip(label: Text("Nilai: ${item['nilai']}")),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // 📂 KATEGORI
                        Text(
                          "Kategori: ${item['nama_kategori_penilaian'] ?? '-'}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

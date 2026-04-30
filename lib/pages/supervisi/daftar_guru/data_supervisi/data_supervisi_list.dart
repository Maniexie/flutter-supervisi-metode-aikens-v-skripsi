import 'package:flutter/material.dart';
import 'package:supervisi/pages/supervisi/daftar_guru/data_supervisi/data_supervisi_detail.dart';
import 'package:supervisi/services/api_service.dart';

class DataSupervisiListPage extends StatefulWidget {
  final int guruId;

  const DataSupervisiListPage({super.key, required this.guruId});

  @override
  State<DataSupervisiListPage> createState() => _DataSupervisiListPageState();
}

class _DataSupervisiListPageState extends State<DataSupervisiListPage> {
  List data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final res = await ApiGuruService().listHasilSupervisiByGuru(
        widget.guruId,
      );

      setState(() {
        data = res;
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Supervisi")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
          ? const Center(child: Text("Belum ada supervisi"))
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.assignment),

                    title: Text("${item['nama_periode']}"),
                    subtitle: Text(
                      " Mulai: ${item['tanggal_mulai']}"
                      " - Selesai: ${item['tanggal_selesai']} | Nilai: ${item['total_nilai']}",
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DataSupervisiDetailPage(
                            item: item,
                            guruId: widget.guruId, // ✅ TAMBAHKAN INI
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

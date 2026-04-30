import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supervisi/services/api_service.dart';

class DataSupervisiDetailPage extends StatefulWidget {
  final Map item;
  final int guruId;

  const DataSupervisiDetailPage({
    super.key,
    required this.item,
    required this.guruId,
  });

  @override
  State<DataSupervisiDetailPage> createState() =>
      _DataSupervisiDetailPageState();
}

class _DataSupervisiDetailPageState extends State<DataSupervisiDetailPage> {
  List detail = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  Future<void> loadDetail() async {
    try {
      final res = await ApiGuruService().detailHasilSupervisiGurubyJadwal(
        widget.item['id_jadwal_supervisi'],
        widget.guruId,
      );

      setState(() {
        detail = res;
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    double totalNilai = double.tryParse(item['total_nilai'].toString()) ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text("Detail Supervisi")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔵 HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mulai: ${item['tanggal_mulai']}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Selesai: ${item['tanggal_selesai']}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Total Nilai: $totalNilai",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📊 CHART
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [BarChartRodData(toY: totalNilai)],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📋 DETAIL LIST
            isLoading
                ? const CircularProgressIndicator()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: detail.length,
                    itemBuilder: (context, index) {
                      final d = detail[index];

                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.check),
                          title: Text(
                            "Item Penilaian: ${d['id_item_penilaian']}",
                          ),
                          trailing: Text("${d['jawaban']}"),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

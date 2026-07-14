import 'package:flutter/material.dart';
import 'package:supervisi/pages/supervisi/daftar_guru/data_supervisi/data_supervisi_riwayat.dart';
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
  int idJadwalSupervisi = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print("DATA SUPERVISI DETAIL PAGE INIT STATE");
    print("guruId: ${widget.guruId}");
    print("idJadwalSupervisi: ${widget.item['id_jadwal_supervisi']}");
    print(" init state - detail $detail");
    loadDetail();
    // loadGetHasilSupervisiById();
  }

  Future<void> loadDetail() async {
    try {
      final res = await ApiGuruService().detailHasilSupervisiGurubyJadwal(
        widget.item['id_jadwal_supervisi'],
        widget.guruId,
      );
      print("DATA SUPERVISI DETAIL PAGE LOAD DETAIL");
      print("guruId: ${widget.guruId}");
      print("idJadwalSupervisi: ${widget.item['id_jadwal_supervisi']}");
      print(" load detail - detail $detail");

      setState(() {
        detail = res;
        idJadwalSupervisi = widget.item['id_jadwal_supervisi'];
        isLoading = false;
        print(" load detail - set state - detail $detail");
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    // double nilaiAkhir = double.tryParse(item['nilai_akhir'].toString()) ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text("Detail observasi kelas")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Hasil Rencana Tindak Lanjut",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
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
                    "Jadwal Supervisi: ${item['nama_periode']}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Mulai: ${item['tanggal_mulai']}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Selesai: ${item['tanggal_selesai']}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "nilai: ${item['nilai_akhir']}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Tindak Lanjut: ${item['kode_tindak_lanjut']} | ${item['nama_tindak_lanjut']}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📊 CHART
            // SizedBox(
            //   height: 250,
            //   child: LineChart(
            //     LineChartData(
            //       minY: 0,
            //       maxY: 5, // sesuaikan skala nilai supervisi kamu

            //       gridData: FlGridData(show: true),
            //       borderData: FlBorderData(show: true),

            //       titlesData: FlTitlesData(
            //         bottomTitles: AxisTitles(
            //           sideTitles: SideTitles(
            //             showTitles: true,
            //             interval: 1,
            //             getTitlesWidget: (value, meta) {
            //               // hanya 1 titik (karena 1 supervisi)
            //               if (value == 0) {
            //                 return const Text("Nilai");
            //               }
            //               return const SizedBox();
            //             },
            //           ),
            //         ),
            //         leftTitles: AxisTitles(
            //           sideTitles: SideTitles(showTitles: true),
            //         ),
            //       ),

            //       lineBarsData: [
            //         LineChartBarData(
            //           spots: [
            //             FlSpot(0, nilaiAkhir), // 👈 data utama kamu
            //           ],
            //           isCurved: true,
            //           color: Colors.blue,
            //           barWidth: 4,
            //           dotData: FlDotData(show: true),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            const SizedBox(height: 20),
            // Card(
            //   child: ListTile(
            //     leading: const Icon(Icons.history),
            //     title: Text("Riwayat Kuesioner Penilaian"),
            //     onTap: () => Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => DataSupervisiRiwayatPage(
            //           idJadwalSupervisi: idJadwalSupervisi,
            //           guruId: widget.guruId,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supervisi/pages/supervisi/daftar_guru/data_supervisi/data_supervisi_riwayat.dart';
import 'package:supervisi/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';

class DataSupervisiDetailPage extends StatefulWidget {
  final Map item;
  final int guruId;
  final String namaGuru;

  const DataSupervisiDetailPage({
    super.key,
    required this.item,
    required this.guruId,
    required this.namaGuru,
  });

  @override
  State<DataSupervisiDetailPage> createState() =>
      _DataSupervisiDetailPageState();
}

class _DataSupervisiDetailPageState extends State<DataSupervisiDetailPage> {
  List detail = [];
  int idJadwalSupervisi = 1;
  bool isLoading = true;
  List kategori = [];

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

  Future<void> downloadDataPdf() async {
    try {
      // String url =
      //     "$baseUrl/download-periode-pdf/${widget.guruId}/$idJadwalSupervisi";
      String url =
          "$baseUrl/download-periode-pdf/${widget.guruId}/${widget.item['id_jadwal_supervisi']}";

      // 🌐 ================= WEB =================
      if (kIsWeb) {
        final anchor = html.AnchorElement(href: url)
          ..setAttribute(
            "download",
            "laporan_observasi_kelas_${widget.guruId}.pdf",
          )
          ..click();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Download PDF dimulai")));

        return;
      }

      // 📱 ================= MOBILE =================
      var status = await Permission.storage.request();

      if (!status.isGranted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Izin storage ditolak")));
        return;
      }

      // loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final dir = await getExternalStorageDirectory();
      final filePath =
          "${dir!.path}/laporan_observasi_kelas_${widget.guruId}.pdf";

      await Dio().download(url, filePath);

      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Download berhasil")));

      OpenFile.open(filePath);
    } catch (e) {
      print("ERROR: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal download: $e")));
    }
  }

  Future<void> downloadData() async {
    try {
      // String url =
      //     "http://localhost:8000/api/download-supervisi-pdf/${widget.guruId}";
      String url =
          "$baseUrl/download-periode-pdf/${widget.guruId}/${widget.item['id_jadwal_supervisi']}";
      // 🌐 ================= WEB =================
      if (kIsWeb) {
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "supervisi_${widget.guruId}.pdf")
          ..click();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Download dimulai")));

        return;
      }

      // 📱 ================= MOBILE =================
      var status = await Permission.storage.request();

      if (!status.isGranted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Izin storage ditolak")));
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final dir = await getExternalStorageDirectory();
      final filePath = "${dir!.path}/supervisi_${widget.guruId}.csv";

      await Dio().download(url, filePath);

      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Download berhasil")));

      OpenFile.open(filePath);
    } catch (e) {
      print("ERROR: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal download: $e")));
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

            // Column(
            //   children: kategori.map((item) {
            //     return Card(
            //       margin: const EdgeInsets.only(bottom: 10),
            //       child: ListTile(
            //         leading: const Icon(Icons.assessment),
            //         title: Text(item['nama_kategori']),
            //         trailing: Text(
            //           item['nilai'].toString(),
            //           style: const TextStyle(fontWeight: FontWeight.bold),
            //         ),
            //       ),
            //     );
            //   }).toList(),
            // ),

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
            // const SizedBox(height: 3),
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
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.download, color: Colors.green),
                title: const Text("Download Periode Observasi Kelas"),
                // subtitle: const Text(""),
                trailing: const Icon(Icons.arrow_downward),
                onTap: () {
                  downloadDataPdf(); // 🔥 panggil function
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supervisi/pages/models/GuruModel.dart';
import 'package:supervisi/pages/supervisi/daftar_guru/data_supervisi/data_supervisi_list.dart';
import 'package:supervisi/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // 🔥 penting (kIsWeb)
import 'dart:html' as html;

import 'package:flutter/foundation.dart'; // kIsWeb

class DaftarGuruDetailPage extends StatefulWidget {
  final GuruModel guru;

  const DaftarGuruDetailPage({super.key, required this.guru});

  @override
  State<DaftarGuruDetailPage> createState() => _DaftarGuruDetailPageState();
}

class _DaftarGuruDetailPageState extends State<DaftarGuruDetailPage> {
  List statistik = [];
  bool isLoadingChart = true;

  List chartData = [];

  String getRoleLabel(String role) {
    switch (role) {
      case "guru":
        return "Guru";
      case "kepala_sekolah":
        return "Kepala Sekolah";
      case "operator":
        return "Operator";
      default:
        return "-";
    }
  }

  @override
  void initState() {
    super.initState();
    loadChart();
    loadStatistik();
  }

  Future<void> loadChart() async {
    try {
      final res = await ApiGuruService().getLineChartSupervisi(widget.guru.id);

      setState(() {
        chartData = res;
        isLoadingChart = false;
      });

      print(chartData); // debug
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadStatistik() async {
    try {
      final res = await ApiGuruService().getStatistikGuru(widget.guru.id);

      setState(() {
        statistik = res;
        isLoadingChart = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> downloadDataPdf() async {
    try {
      String url = "$baseUrl/download-supervisi-pdf/${widget.guru.id}";

      // 🌐 ================= WEB =================
      if (kIsWeb) {
        final anchor = html.AnchorElement(href: url)
          ..setAttribute(
            "download",
            "laporan_supervisi_${widget.guru.nama}.pdf",
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
      final filePath = "${dir!.path}/laporan_supervisi_${widget.guru.nama}.pdf";

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
      String url =
          "http://localhost:8000/api/download-supervisi-pdf/${widget.guru.id}";

      // 🌐 ================= WEB =================
      if (kIsWeb) {
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "supervisi_${widget.guru.nama}.pdf")
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
      final filePath = "${dir!.path}/supervisi_${widget.guru.nama}.csv";

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
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Guru")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔵 HEADER PROFILE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      widget.guru.nama![0], // inisial
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.guru.nama ?? "-",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "NIP: ${widget.guru.nip}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📋 DETAIL INFO
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(widget.guru.username ?? "-"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(widget.guru.email),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(widget.guru.nomorHp),
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(widget.guru.alamat),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text("Role: ${getRoleLabel(widget.guru.role!)}"),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.verified,
                      color:
                          (widget.guru.isValidator == true ||
                              widget.guru.isValidator == "Validator")
                          ? Colors.green
                          : const Color.fromARGB(255, 201, 201, 201),
                    ),
                    title: Text(
                      (widget.guru.isValidator == true ||
                              widget.guru.isValidator == "Validator")
                          ? "Validator"
                          : "-",
                    ),
                  ),
                ],
              ),
            ),
            // 🚀 MENU KE SUPERVISI
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.analytics, color: Colors.blue),
                title: const Text("Riwayat Supervisi"),
                subtitle: const Text("Lihat hasil supervisi guru"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DataSupervisiListPage(
                        guruId: widget.guru.id, // 🔥 kirim ID
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 GRAFI K
            SizedBox(
              height: 250,
              child: isLoadingChart
                  ? const Center(child: CircularProgressIndicator())
                  : chartData.isEmpty
                  ? const Center(child: Text("Belum ada data supervisi"))
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 5, // sesuaikan nilai kamu

                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),

                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();

                                if (index >= 0 && index < chartData.length) {
                                  String label =
                                      chartData[index]['nama_periode'] ?? '';

                                  // 🔥 potong biar tidak panjang
                                  if (label.length > 20) {
                                    label = label.substring(0, 8);
                                  }

                                  return Transform.rotate(
                                    angle: -0.3,
                                    child: Text(
                                      label,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }

                                return const SizedBox();
                              },
                            ),
                          ),

                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 20,
                            ),
                          ),
                        ),

                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(chartData.length, (index) {
                              double nilai =
                                  double.tryParse(
                                    chartData[index]['nilai'].toString(),
                                  ) ??
                                  0;

                              return FlSpot(index.toDouble(), nilai);
                            }),

                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 4,
                            dotData: FlDotData(show: true),

                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.download, color: Colors.green),
                title: const Text("Download Data Supervisi"),
                subtitle: const Text("Export ke PDF / Excel"),
                trailing: const Icon(Icons.arrow_downward),
                onTap: () {
                  downloadDataPdf(); // 🔥 panggil function
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: () {},
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: () {},
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}

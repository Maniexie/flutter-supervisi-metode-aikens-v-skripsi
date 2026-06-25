import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supervisi/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart'; // 🔥 penting (kIsWeb)
import 'dart:html' as html;

class SupervisiGuruHomePage extends StatefulWidget {
  const SupervisiGuruHomePage({super.key});

  @override
  State<SupervisiGuruHomePage> createState() => _SupervisiGuruHomePageState();
}

class _SupervisiGuruHomePageState extends State<SupervisiGuruHomePage> {
  int? idUser;
  String? nama;

  List jadwalList = [];

  double rataRataNilai = 0;
  List<FlSpot> chartSpots = [];

  @override
  void initState() {
    super.initState();
    loadUser();
    loadJadwal();
  }

  Future<void> loadJadwal() async {
    final data = await ApiJadwalSupervisiService.getJadwalGuru();

    print("DATA JADWAL:");
    print(data);

    double totalNilai = 0;
    List<FlSpot> spots = [];

    for (int i = 0; i < data.length; i++) {
      double nilai = double.tryParse(data[i]['nilai'].toString()) ?? 0;

      totalNilai += nilai;

      spots.add(FlSpot(i.toDouble(), nilai));
    }

    setState(() {
      jadwalList = data;
      chartSpots = spots;

      rataRataNilai = data.isNotEmpty ? totalNilai / data.length : 0;
    });

    print("TOTAL DATA: ${jadwalList.length}");
    print("RATA RATA: $rataRataNilai");
    print("CHART: $chartSpots");
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      idUser = prefs.getInt('id_user');
      nama = prefs.getString('nama');
    });
  }

  Future<void> downloadDataPdf() async {
    try {
      String url = "$baseUrl/download-supervisi-pdf/$idUser";

      // 🌐 ================= WEB =================
      if (kIsWeb) {
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "laporan_supervisi_$nama.pdf")
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
      final filePath = "${dir!.path}/laporan_supervisi_$nama.pdf";

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

  void showDetailJadwal(dynamic item) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(item['nama_periode']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              infoTile("Tanggal Mulai", item['tanggal_mulai']),
              infoTile("Tanggal Selesai", item['tanggal_selesai']),
              const SizedBox(height: 10),
              Text(item['deskripsi'] ?? "-", textAlign: TextAlign.justify),
            ],
          ),
        );
      },
    );
  }

  Widget infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget detailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.indigo),

        const SizedBox(width: 10),

        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87),
              children: [
                TextSpan(
                  text: "$title : ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color getNilaiColor(double nilai) {
    if (nilai >= 4) {
      return Colors.green;
    } else if (nilai >= 3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void showDetailHasilSupervisi(dynamic item) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(
                      Icons.assignment_turned_in,
                      size: 60,
                      color: Colors.indigo,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      item['nama_periode'] ?? "-",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 25),

                  detailRow(
                    Icons.star,
                    "Nilai Supervisi",
                    item['nilai'].toString(),
                  ),

                  const SizedBox(height: 15),

                  detailRow(
                    Icons.calendar_today,
                    "Tanggal Mulai",
                    item['tanggal_mulai'] ?? "-",
                  ),

                  const SizedBox(height: 15),

                  detailRow(
                    Icons.calendar_month,
                    "Tanggal Selesai",
                    item['tanggal_selesai'] ?? "-",
                  ),

                  const SizedBox(height: 15),

                  detailRow(
                    Icons.feedback,
                    "Umpan Balik",
                    item['umpan_balik'] ?? "-",
                  ),

                  const SizedBox(height: 15),

                  detailRow(
                    Icons.description,
                    "Deskripsi",
                    item['deskripsi'] ?? "-",
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),

                      child: const Text("Tutup"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Dashboard Guru"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await loadJadwal();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // HEADER PROFILE
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Colors.indigo, Colors.blue],
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Text(
                      nama != null ? nama![0].toUpperCase() : "G",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nama ?? "-",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Guru Aktif",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CARD STATISTIK
            Row(
              children: [
                Expanded(
                  child: dashboardCard(
                    "Total Supervisi",
                    "${jadwalList.length}",
                    Icons.assignment,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: dashboardCard(
                    "Nilai Rata-rata",
                    rataRataNilai.toStringAsFixed(1),
                    Icons.bar_chart,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // CHART
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Grafik Supervisi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: 5,

                            gridData: FlGridData(show: true),

                            borderData: FlBorderData(show: false),

                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                ),
                              ),

                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();

                                    if (index >= jadwalList.length) {
                                      return const SizedBox();
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        "${index + 1}",
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            lineBarsData: [
                              LineChartBarData(
                                spots: chartSpots,
                                isCurved: true,
                                barWidth: 4,
                                color: Colors.indigo,

                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.indigo.withOpacity(0.2),
                                ),

                                dotData: FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: downloadDataPdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Download Laporan PDF"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // RIWAYAT SUPERVISI
            const Text(
              "Riwayat Observasi Kelas",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...jadwalList.map((item) {
              double nilai = double.tryParse(item['nilai'].toString()) ?? 0;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),

                  childrenPadding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),

                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    child: const Icon(Icons.assignment, color: Colors.indigo),
                  ),

                  // NAMA PERIODE
                  title: InkWell(
                    onTap: () {
                      showDetailHasilSupervisi(item);
                    },
                    child: Text(
                      item['nama_periode'] ?? "-",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.indigo,
                      ),
                    ),
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['tanggal_mulai'] ?? "-"),

                        const SizedBox(height: 6),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: getNilaiColor(nilai).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            "Nilai: $nilai",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: getNilaiColor(nilai),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  children: [
                    // DETAIL DROPDOWN
                    detailRow(
                      Icons.calendar_month,
                      "Tanggal Selesai",
                      item['tanggal_selesai'] ?? "-",
                    ),

                    const SizedBox(height: 10),

                    detailRow(
                      Icons.feedback,
                      "Umpan Balik",
                      item['umpan_balik'] ?? "-",
                    ),

                    const SizedBox(height: 10),

                    detailRow(
                      Icons.description,
                      "Deskripsi",
                      item['deskripsi'] ?? "-",
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDetailHasilSupervisi(item);
                        },

                        icon: const Icon(Icons.visibility),

                        label: const Text("Lihat Detail Supervisis"),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget dashboardCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(title),
          ],
        ),
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supervisi/pages/models/GuruModel.dart';
import 'package:supervisi/pages/supervisi/daftar_guru/data_supervisi/data_supervisi_list.dart';
import 'package:supervisi/services/api_service.dart';

class DaftarGuruDetailPage extends StatefulWidget {
  final GuruModel guru;

  const DaftarGuruDetailPage({super.key, required this.guru});

  @override
  State<DaftarGuruDetailPage> createState() => _DaftarGuruDetailPageState();
}

class _DaftarGuruDetailPageState extends State<DaftarGuruDetailPage> {
  List statistik = [];
  bool isLoadingChart = true;

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
    loadStatistik();
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

            const SizedBox(height: 20),

            // 📊 CHART STATISTIK
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();

                          if (index >= 0 && index < statistik.length) {
                            return Text(
                              statistik[index]['nama_periode'],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),

                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                      spots: statistik.asMap().entries.map((e) {
                        int index = e.key;

                        double nilai =
                            double.tryParse(
                              e.value['total_nilai'].toString(),
                            ) ??
                            0;

                        return FlSpot(index.toDouble(), nilai);
                      }).toList(),
                    ),
                  ],
                  minY: 0,
                  maxY: 100,
                ),
              ),
            ),

            const SizedBox(height: 10),
            // 🚀 MENU KE SUPERVISI
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.analytics, color: Colors.blue),
                title: const Text("Riwayat Supervisi"),
                subtitle: const Text("Lihat hasil supervisi guru ini"),
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

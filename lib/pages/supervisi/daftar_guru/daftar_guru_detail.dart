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
                    title: Text("Role: ${widget.guru.role}"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.verified),
                    title: Text(
                      widget.guru.isValidator ? "Validator" : "Bukan Validator",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📊 CHART STATISTIK
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Statistik Supervisi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    isLoadingChart
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            height: 300,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                barGroups: statistik.asMap().entries.map((e) {
                                  int index = e.key + 1;
                                  var item = e.value;

                                  double nilai =
                                      double.tryParse(
                                        item['total_nilai'].toString(),
                                      ) ??
                                      0;

                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [BarChartRodData(toY: nilai)],
                                  );
                                }).toList(),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        int index = value.toInt();
                                        if (index < statistik.length) {
                                          return Text(
                                            statistik[index]['nama_periode'],
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
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

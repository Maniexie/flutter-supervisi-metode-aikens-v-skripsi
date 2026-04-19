import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SupervisiHomePage extends StatefulWidget {
  const SupervisiHomePage({super.key});

  @override
  State<SupervisiHomePage> createState() => _SupervisiHomePageState();
}

class _SupervisiHomePageState extends State<SupervisiHomePage> {
  final List<FlSpot> spots = [
    FlSpot(0, 3.5),
    FlSpot(1, 3.8),
    FlSpot(2, 4.0),
    FlSpot(3, 3.7),
    FlSpot(4, 4.2),
  ];

  final List<String> months = ["Jan", "Feb", "Mar", "Apr", "Mei"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Supervisi")),

      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            "Supervisi Periode ${DateTime.now().toString().split(' ')[0]} - ${DateTime.timestamp().toString().split(' ')[0]}",
          ),
          //  CARD SUMMARY
          Card(
            child: ListTile(title: Text("Total Guru"), trailing: Text("25")),
          ),

          SizedBox(height: 10),

          Card(
            child: ListTile(title: Text("Sudah Dinilai"), trailing: Text("18")),
          ),

          SizedBox(height: 20),

          // 🔹 JUDUL GRAFIK
          Text(
            "Grafik Penilaian",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 10),

          // 🔹 GRAFIK
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 5,

                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(months[value.toInt()]);
                      },
                    ),
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 4,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // 🔹 FITUR TAMBAHAN
          Card(
            child: ListTile(
              leading: Icon(Icons.people),
              title: Text("Data Guru"),
              onTap: () {},
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.assignment),
              title: Text("Penilaian"),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

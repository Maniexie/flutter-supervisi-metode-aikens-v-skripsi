import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      appBar: AppBar(title: Text("Dashboard")),

      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
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
        ],
      ),
    );
  }
}

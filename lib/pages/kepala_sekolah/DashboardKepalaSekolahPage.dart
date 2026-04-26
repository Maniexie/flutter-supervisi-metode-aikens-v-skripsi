import 'package:flutter/material.dart';

class DashboardKepalaSekolahPage extends StatefulWidget {
  const DashboardKepalaSekolahPage({super.key});

  @override
  State<DashboardKepalaSekolahPage> createState() =>
      _DashboardKepalaSekolahPageState();
}

class _DashboardKepalaSekolahPageState
    extends State<DashboardKepalaSekolahPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Dashboard Kepala Sekolah")));
  }
}

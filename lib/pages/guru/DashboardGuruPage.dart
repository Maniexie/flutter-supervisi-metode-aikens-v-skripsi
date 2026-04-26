import 'package:flutter/material.dart';

class DashboardGuruPage extends StatefulWidget {
  const DashboardGuruPage({super.key});

  @override
  State<DashboardGuruPage> createState() => _DashboardGuruPageState();
}

class _DashboardGuruPageState extends State<DashboardGuruPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Dashboard Guru")));
  }
}

import 'package:flutter/material.dart';

class DashboardOperatorPage extends StatefulWidget {
  const DashboardOperatorPage({super.key});

  @override
  State<DashboardOperatorPage> createState() => _DashboardOperatorPageState();
}

class _DashboardOperatorPageState extends State<DashboardOperatorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Dashboard Operator")));
  }
}

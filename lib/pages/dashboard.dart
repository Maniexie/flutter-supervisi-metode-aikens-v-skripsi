import 'package:flutter/material.dart';
import 'package:supervisi/widgets/drawer.dart';

class DashboardPage extends StatelessWidget {
  static const routeName = "/dashboard";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerPage(),
      appBar: AppBar(title: Text("Dashboard")),
      body: Center(child: Text("Dashboard Page")),
    );
  }
}

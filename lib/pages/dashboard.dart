import 'package:flutter/material.dart';
import 'package:supervisi/pages/aiken/item_penilaian.dart';
import 'package:supervisi/pages/profile.dart';
import 'package:supervisi/widgets/bottom_navigation.dart';
import 'package:supervisi/widgets/drawer.dart';

class DashboardPage extends StatefulWidget {
  static const routeName = "/dashboard";

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentPageIndex = 0;
  final List<String> titles = [
    "Home",
    "Notifications567",
    "Messages",
    "Item Penilaian",
    "Profil",
  ];

  final List<Widget> pages = [
    Center(child: Text("Home")),
    Center(child: Text("Notifications")),
    Center(child: Text("Messages")),
    ItemPenilaian(), // <-- INI HALAMAN KAMU
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titles[currentPageIndex])),
      drawer: DrawerPage(),
      body: pages[currentPageIndex],
      bottomNavigationBar: BottomNavigation(
        currentIndex: currentPageIndex,
        onTap: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supervisi/pages/aiken/aiken_home.dart';
import 'package:supervisi/pages/item_penilaian/item_penilaian.dart';
import 'package:supervisi/pages/home.dart';
import 'package:supervisi/pages/profile.dart';
import 'package:supervisi/pages/supervisi/supervisi_home.dart';
import 'package:supervisi/widgets/bottom_navigation.dart';
import 'package:supervisi/widgets/drawer.dart';

class DashboardPage extends StatefulWidget {
  static const routeName = "/dashboard";

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentPageIndex = 0;
  final List<String> titles = ["", "", "", "", ""];

  final List<Widget> pages = [
    HomePage(),
    SupervisiHomePage(),
    ItemPenilaian(),
    AikenHomePage(),
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

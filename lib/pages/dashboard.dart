import 'package:flutter/material.dart';
import 'package:supervisi/pages/aiken/aiken_home.dart';
import 'package:supervisi/pages/guru/DashboardGuruPage.dart';
import 'package:supervisi/pages/guru/SupervisiGuruHomePage.dart';

import 'package:supervisi/pages/item_penilaian/item_penilaian.dart';
import 'package:supervisi/pages/home.dart';
import 'package:supervisi/pages/profile.dart';
import 'package:supervisi/pages/supervisi/supervisi_home.dart';
import 'package:supervisi/services/api_service.dart';
import 'package:supervisi/widgets/bottom_navigation.dart';
import 'package:supervisi/widgets/drawer.dart';

class DashboardPage extends StatefulWidget {
  static const routeName = "/dashboard";

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentPageIndex = 0;

  List<Widget> pages = [];
  List<String> titles = [];
  List<NavigationDestination> navItems = [];

  int idUser = 0;
  String nama = '';
  String role = '';
  bool isValidator = false;

  @override
  void initState() {
    super.initState();
    loadRole();
  }

  void loadRole() async {
    final getRole = await ApiLoginService.getRole();
    final getIsValidator = await ApiLoginService.getIsValidator();
    final getIdUser = await ApiLoginService.getIdUser();
    final getNama = await ApiLoginService.getNama();

    setState(() {
      role = getRole ?? '';
      idUser = getIdUser ?? 0;
      nama = getNama ?? '';
      isValidator = getIsValidator;
      setupMenu();
    });
  }

  void setupMenu() {
    pages = [];
    titles = [];
    navItems = [];

    if (role == 'kepala_sekolah') {
      pages = [
        HomePage(idUser: idUser, nama: nama),
        SupervisiHomePage(),
        ItemPenilaian(),
        if (isValidator) AikenHomePage(),
        ProfilePage(),
      ];

      titles = [
        "Home",
        "Observasi Kelas",
        "Item Penilaian",
        if (isValidator) "Aiken",
        "Profile",
      ];

      navItems = [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const NavigationDestination(
          icon: Icon(Icons.assignment_add),
          label: 'Observasi',
        ),
        const NavigationDestination(icon: Icon(Icons.message), label: 'Item'),
        if (isValidator)
          const NavigationDestination(
            icon: Icon(Icons.computer_rounded),
            label: 'Aiken',
          ),
        const NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ];
    } else if (role == 'guru') {
      pages = [
        DashboardGuruPage(),
        SupervisiGuruHomePage(),
        if (isValidator) AikenHomePage(),
        ProfilePage(),
      ];

      titles = [
        "Dashboard",
        "Observasi Guru",
        if (isValidator) "Aiken",
        "Profile",
      ];

      navItems = [
        const NavigationDestination(icon: Icon(Icons.home), label: 'Dashboard'),
        const NavigationDestination(
          icon: Icon(Icons.assignment_add),
          label: 'Observasi Guru',
        ),
        if (isValidator)
          const NavigationDestination(
            icon: Icon(Icons.computer_rounded),
            label: 'Aiken',
          ),
        const NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ];
    } else if (role == 'operator') {
      pages = [
        HomePage(idUser: idUser, nama: nama),
        SupervisiHomePage(),
        ItemPenilaian(),
        if (isValidator) AikenHomePage(),
        ProfilePage(),
      ];

      titles = [
        "Home",
        "Observasi Kelas",
        "Item Penilaian",
        if (isValidator) "Aiken",
        "Profile",
      ];

      navItems = [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const NavigationDestination(
          icon: Icon(Icons.assignment_add),
          label: 'Observasi',
        ),
        const NavigationDestination(icon: Icon(Icons.message), label: 'Item'),
        if (isValidator)
          const NavigationDestination(
            icon: Icon(Icons.computer_rounded),
            label: 'Aiken',
          ),
        const NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pages.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
        destinations: navItems, // 🔥 kirim ke widget
      ),
    );
  }
}

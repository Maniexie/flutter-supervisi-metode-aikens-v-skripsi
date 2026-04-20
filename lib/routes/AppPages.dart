import 'package:flutter/material.dart';

import 'AppRoutes.dart';

import 'package:supervisi/pages/dashboard.dart';
import 'package:supervisi/pages/auth/login.dart';
import 'package:supervisi/pages/item_penilaian/item_penilaian.dart';

class AppPages {
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.login: (context) => LoginPage(),
    AppRoutes.dashboard: (context) => DashboardPage(),
    AppRoutes.item_penilaian: (context) => ItemPenilaian(),
  };
}

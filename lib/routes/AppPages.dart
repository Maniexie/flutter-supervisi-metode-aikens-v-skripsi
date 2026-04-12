import 'package:flutter/material.dart';

import 'AppRoutes.dart';

import 'package:supervisi/pages/dashboard.dart';
import 'package:supervisi/pages/login.dart';

class AppPages {
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.login: (context) => LoginPage(),
    AppRoutes.dashboard: (context) => DashboardPage(),
  };
}

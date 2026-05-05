import 'package:flutter/material.dart';

import 'package:supervisi/routes/AppPages.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  initializeDateFormatting('id_ID', null); // ✅ WAJIB
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('id', 'ID'),
      debugShowCheckedModeBanner: false,
      routes: AppPages.routes,
      initialRoute: '/login',
    );
  }
}

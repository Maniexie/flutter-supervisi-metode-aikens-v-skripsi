import 'package:flutter/material.dart';

import 'package:supervisi/routes/AppPages.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: AppPages.routes,
      initialRoute: '/login',
    );
  }
}

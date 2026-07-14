import 'package:flutter/material.dart';

class SupervisiIntroPage extends StatelessWidget {
  const SupervisiIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Observasi Kelas")),
      body: Center(
        child: Column(children: [Text("Selamat Datang di Observasi Kelas")]),
      ),
    );
  }
}

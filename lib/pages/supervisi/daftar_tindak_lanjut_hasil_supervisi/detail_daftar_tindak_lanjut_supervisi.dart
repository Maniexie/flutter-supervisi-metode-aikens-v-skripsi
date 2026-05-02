import 'package:flutter/material.dart';

class DetailDaftarTindakLanjutSupervisiPage extends StatefulWidget {
  const DetailDaftarTindakLanjutSupervisiPage({super.key});

  @override
  State<DetailDaftarTindakLanjutSupervisiPage> createState() =>
      _DetailDaftarTindakLanjutSupervisiPageState();
}

class _DetailDaftarTindakLanjutSupervisiPageState
    extends State<DetailDaftarTindakLanjutSupervisiPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Daftar Tindak Lanjut Supervisi"),
      ),
    );
  }
}

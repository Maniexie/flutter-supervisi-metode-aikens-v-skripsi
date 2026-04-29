import 'package:flutter/material.dart';
import 'package:supervisi/pages/models/GuruModel.dart';

class DaftarGuruDetailPage extends StatelessWidget {
  final GuruModel guru;

  const DaftarGuruDetailPage({super.key, required this.guru});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Guru")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama: ${guru.nama}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("NIP: ${guru.nip}"),
            Text("Email: ${guru.email}"),
            Text("No HP: ${guru.nomorHp}"),
            Text("Alamat: ${guru.alamat}"),
            Text("Role: ${guru.role}"),
          ],
        ),
      ),
    );
  }
}

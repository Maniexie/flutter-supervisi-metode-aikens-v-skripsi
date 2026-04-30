import 'package:flutter/material.dart';
import 'package:supervisi/pages/models/GuruModel.dart';
import 'package:supervisi/pages/supervisi/daftar_guru/data_supervisi/data_supervisi_list.dart';

class DaftarGuruDetailPage extends StatelessWidget {
  final GuruModel guru;

  const DaftarGuruDetailPage({super.key, required this.guru});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Guru")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔵 HEADER PROFILE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      guru.nama![0], // inisial
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guru.nama ?? "-",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "NIP: ${guru.nip}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📋 DETAIL INFO
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(guru.email),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(guru.nomorHp),
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(guru.alamat),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text("Role: ${guru.role}"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.verified),
                    title: Text(
                      guru.isValidator ? "Validator" : "Bukan Validator",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🚀 MENU KE SUPERVISI
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.analytics, color: Colors.blue),
                title: const Text("Riwayat Supervisi"),
                subtitle: const Text("Lihat hasil supervisi guru ini"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DataSupervisiListPage(
                        guruId: guru.id, // 🔥 kirim ID
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: () {},
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: () {},
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}

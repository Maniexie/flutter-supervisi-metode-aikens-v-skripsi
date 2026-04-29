import 'package:flutter/material.dart';
import 'package:supervisi/pages/models/GuruModel.dart';
import 'package:supervisi/pages/supervisi/daftar_guru/daftar_guru_detail.dart';
import 'package:supervisi/services/api_service.dart';

class DaftarGuruListPage extends StatefulWidget {
  const DaftarGuruListPage({super.key});

  @override
  State<DaftarGuruListPage> createState() => _DaftarGuruListPageState();
}

class _DaftarGuruListPageState extends State<DaftarGuruListPage> {
  List<GuruModel> guruList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadGuru();
  }

  Future<void> loadGuru() async {
    try {
      final data = await ApiGuruService().getGuru();
      setState(() {
        guruList = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Guru")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: guruList.length,
              itemBuilder: (context, index) {
                final guru = guruList[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(guru.nama ?? "-"),
                    subtitle: Text(guru.nip ?? "-"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DaftarGuruDetailPage(guru: guru),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

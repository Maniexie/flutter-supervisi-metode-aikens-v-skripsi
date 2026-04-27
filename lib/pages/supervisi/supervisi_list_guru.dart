import 'package:flutter/material.dart';
import 'package:supervisi/pages/supervisi/supervisi_kuesioner.dart';
import 'package:supervisi/services/api_service.dart';

class SupervisiListGuruPage extends StatefulWidget {
  final int idJadwal;

  const SupervisiListGuruPage({super.key, required this.idJadwal});

  @override
  State<SupervisiListGuruPage> createState() => _SupervisiListGuruPageState();
}

class _SupervisiListGuruPageState extends State<SupervisiListGuruPage> {
  List guruList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadGuru();
  }

  Future<void> loadGuru() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await ApiSupervisiService().getGuruByJadwalSupervisi(
        widget.idJadwal,
      );

      setState(() {
        guruList = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  void goToKuesioner(int idGuru, bool sudah) async {
    if (sudah) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Guru sudah disupervisi")));
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SupervisiKuesionerPage(idGuru: idGuru, idJadwal: widget.idJadwal),
      ),
    );

    // 🔥 JIKA KEMBALI DENGAN SUCCESS → REFRESH DATA
    if (result == true) {
      loadGuru();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Supervisi berhasil disimpan")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List Guru Supervisi")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: guruList.length,
              itemBuilder: (context, index) {
                final guru = guruList[index];
                final sudah = guru['sudah_disupervisi'] == 1;

                return Card(
                  color: sudah
                      ? Colors.grey[200]
                      : Colors.white, // 🔥 beda warna
                  child: ListTile(
                    enabled: !sudah, // 🔥 disable klik ripple

                    title: Text(guru['nama']),

                    subtitle: Text(
                      sudah ? "Sudah disupervisi" : "Belum disupervisi",
                      style: TextStyle(
                        color: sudah ? Colors.green : Colors.red,
                      ),
                    ),

                    trailing: Icon(
                      sudah ? Icons.check_circle : Icons.arrow_forward,
                      color: sudah ? Colors.green : Colors.blue,
                    ),

                    onTap: sudah
                        ? null // 🔥 BENAR-BENAR DISABLE
                        : () => goToKuesioner(guru['id_guru'], sudah),
                  ),
                );
              },
            ),
    );
  }
}

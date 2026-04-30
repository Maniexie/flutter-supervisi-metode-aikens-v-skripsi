import 'package:flutter/material.dart';
import 'package:supervisi/pages/supervisi/supervisi_home.dart';
import 'package:supervisi/pages/supervisi/supervisi_jadwal.dart';
import 'package:supervisi/pages/supervisi/supervisi_list_guru.dart';
import 'package:supervisi/services/api_service.dart';

class SupervisiHasilTindakLanjutPage extends StatefulWidget {
  final int totalNilai;
  final String tindakLanjut;
  final int guruId;
  final int idJadwal;

  const SupervisiHasilTindakLanjutPage({
    super.key,
    required this.totalNilai,
    required this.tindakLanjut,
    required this.guruId,
    required this.idJadwal,
  });

  @override
  State<SupervisiHasilTindakLanjutPage> createState() =>
      _SupervisiHasilTindakLanjutPageState();
}

class _SupervisiHasilTindakLanjutPageState
    extends State<SupervisiHasilTindakLanjutPage> {
  String? selectedTindakLanjut;
  List<dynamic> tindakLanjutList = [];
  bool isLoadingTindakLanjut = true;

  @override
  void initState() {
    super.initState();
    loadTindakLanjut();
  }

  Future<void> loadTindakLanjut() async {
    try {
      final res = await ApiKodeTindakLanjutHasilSupervisiService()
          .getKodeTindakLanjutHasilSupervisi();

      setState(() {
        tindakLanjutList = res;

        if (res.isNotEmpty) {
          selectedTindakLanjut = res[0]['kode_tindak_lanjut'];
        }

        isLoadingTindakLanjut = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color warna;

    if (widget.totalNilai <= 50) {
      warna = Colors.red;
    } else if (widget.totalNilai <= 75) {
      warna = Colors.orange;
    } else {
      warna = Colors.green;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Hasil Supervisi")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔵 NILAI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: warna,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    "Total Nilai",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "${widget.totalNilai}",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 DROPDOWN
            isLoadingTindakLanjut
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<String>(
                    value: selectedTindakLanjut,
                    decoration: const InputDecoration(
                      labelText: "Rencana Tindak Lanjut",
                      border: OutlineInputBorder(),
                    ),
                    items: tindakLanjutList.map<DropdownMenuItem<String>>((e) {
                      return DropdownMenuItem<String>(
                        value: e['kode_tindak_lanjut'],
                        child: Text(e['nama_tindak_lanjut']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedTindakLanjut = val;
                      });
                    },
                  ),

            const SizedBox(height: 20),

            // 🔥 SIMPAN
            ElevatedButton(
              onPressed: selectedTindakLanjut == null
                  ? null
                  : () async {
                      await ApiSupervisiService().simpanHasilSupervisi(
                        guruId: widget.guruId,
                        nilai: widget.totalNilai,
                        tindakLanjut: selectedTindakLanjut!,
                        idJadwal: widget.idJadwal, // 🔥 TAMBAH INI
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Berhasil disimpan")),
                      );

                      await Future.delayed(const Duration(milliseconds: 800));

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SupervisiListGuruPage(
                            idJadwal: widget.idJadwal, // 🔥 kirim ulang
                          ),
                        ),
                        (route) => false, // 🔥 hapus semua stack sebelumnya
                      );
                    },
              child: const Text("Simpan Tindak Lanjut"),
            ),
          ],
        ),
      ),
    );
  }
}

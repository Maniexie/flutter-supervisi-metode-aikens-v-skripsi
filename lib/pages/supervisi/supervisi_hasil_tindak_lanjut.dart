import 'package:flutter/material.dart';
import 'package:supervisi/pages/supervisi/supervisi_list_guru.dart';
import 'package:supervisi/services/api_service.dart';

class SupervisiHasilTindakLanjutPage extends StatefulWidget {
  final double totalNilai;
  final String tindakLanjut;
  final int guruId;
  final String namaGuru;
  final int idJadwal;
  final String umpanBalik;

  const SupervisiHasilTindakLanjutPage({
    super.key,
    required this.totalNilai,
    required this.tindakLanjut,
    required this.guruId,
    required this.namaGuru,
    required this.idJadwal,
    required this.umpanBalik,
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
      final res = await ApiTindakLanjutHasilSupervisiService()
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

    if (widget.totalNilai * 20 <= 50) {
      warna = Colors.red;
    } else if (widget.totalNilai * 20 <= 75) {
      warna = Colors.orange;
    } else {
      warna = Colors.green;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Hasil Observasi Kelas")),

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "HASIL OBSERVASI KELAS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Text(
                          "Nama Guru",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(": ", style: TextStyle(color: Colors.white)),
                      Expanded(
                        child: Text(
                          widget.namaGuru,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Text(
                          "Nilai Akhir",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(": ", style: TextStyle(color: Colors.white)),
                      Expanded(
                        child: Text(
                          "${(widget.totalNilai * 20).toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🔵 TINDAK LANJUT
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
                        idJadwal: widget.idJadwal,
                        umpanBalik: widget.umpanBalik,
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

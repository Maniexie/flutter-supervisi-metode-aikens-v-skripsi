import 'package:flutter/material.dart';
import 'package:supervisi/pages/models/ItemPenilaianModel.dart';
import 'package:supervisi/pages/supervisi/supervisi_hasil_tindak_lanjut.dart';
import 'package:supervisi/services/api_service.dart';

class SupervisiKuesionerPage extends StatefulWidget {
  final int idGuru;
  final int idJadwal;
  final String? tindakLanjut;
  final int? nilai;

  const SupervisiKuesionerPage({
    super.key,
    required this.idGuru,
    required this.idJadwal,
    this.tindakLanjut,
    this.nilai,
  });

  @override
  State<SupervisiKuesionerPage> createState() => _SupervisiKuesionerPageState();
}

class _SupervisiKuesionerPageState extends State<SupervisiKuesionerPage> {
  List<ItemPenilaianModel> supervisiItems = [];
  bool isLoading = true;
  String? errorMessage;
  Map<int, int> jawaban = {};

  @override
  void initState() {
    super.initState();
    _loadSupervisi();
  }

  Future<void> _loadSupervisi() async {
    try {
      // Memanggil service API yang mengembalikan List<ItemPenilaianModel>
      final List<ItemPenilaianModel> data = await ApiItemPenilaianService()
          .getItemUntukSupervisi();

      setState(() {
        supervisiItems = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Gagal memuat data: $e";
        isLoading = false;
      });
    }
  }

  void submitJawaban() async {
    if (jawaban.length != supervisiItems.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua pertanyaan wajib diisi")),
      );
      return;
    }

    try {
      final result = await ApiSupervisiService().submitSupervisi(
        idGuru: widget.idGuru,
        idJadwal: widget.idJadwal,
        jawaban: jawaban,
      );

      // 🔥 KIRIM DATA KE HALAMAN BERIKUTNYA
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SupervisiHasilTindakLanjutPage(
            totalNilai: result['total_nilai'],
            tindakLanjut: result['tindak_lanjut'],
            guruId: widget.idGuru,
            idJadwal: widget.idJadwal,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Supervisi Kuesioner")),
      body: Builder(
        builder: (context) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (errorMessage != null) {
            return Center(child: Text(errorMessage!));
          }

          if (supervisiItems.isEmpty) {
            return const Center(child: Text("Tidak ada data supervisi"));
          }

          return ListView.builder(
            itemCount: supervisiItems.length,
            itemBuilder: (context, index) {
              final item = supervisiItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.pernyataan,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // 🔥 PILIHAN NILAI
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (i) {
                          int nilai = i + 1;

                          return Row(
                            children: [
                              Radio<int>(
                                value: nilai,
                                groupValue: jawaban[item.id],
                                onChanged: (val) {
                                  setState(() {
                                    jawaban[item.id] = val!;
                                  });
                                },
                              ),
                              Text("$nilai"),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(height: 8),

                      // 🔥 BUTTON SIMPAN
                      ElevatedButton(
                        onPressed: submitJawaban,
                        child: const Text(
                          "Submit",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

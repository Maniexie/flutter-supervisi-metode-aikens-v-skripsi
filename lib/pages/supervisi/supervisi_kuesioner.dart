import 'package:flutter/material.dart';
import 'package:supervisi/pages/models/ItemPenilaianModel.dart';
import 'package:supervisi/pages/supervisi/supervisi_hasil_tindak_lanjut.dart';
import 'package:supervisi/services/api_service.dart';

class SupervisiKuesionerPage extends StatefulWidget {
  final int idGuru;
  final int idJadwal;
  final String namaGuru;
  final String? tindakLanjut;
  final int? nilai;

  const SupervisiKuesionerPage({
    super.key,
    required this.idGuru,
    required this.namaGuru,
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

  Map<String, List<ItemPenilaianModel>> groupByKategori() {
    Map<String, List<ItemPenilaianModel>> grouped = {};

    for (var item in supervisiItems) {
      if (!grouped.containsKey(item.namaKategori)) {
        grouped[item.namaKategori] = [];
      }
      grouped[item.namaKategori]!.add(item);
    }

    return grouped;
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
        namaGuru: widget.namaGuru,
        idJadwal: widget.idJadwal,
        jawaban: jawaban,
      );

      // 🔥 KIRIM DATA KE HALAMAN BERIKUTNYA
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SupervisiHasilTindakLanjutPage(
            totalNilai: result['nilai'],
            tindakLanjut: result['tindak_lanjut'],
            guruId: widget.idGuru,
            namaGuru: widget.namaGuru ?? '',
            idJadwal: widget.idJadwal,
            umpanBalik: result['umpan_balik'] ?? '',
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
      appBar: AppBar(
        title: const Text("Kuesioner Observasi Kelas"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Builder(
        builder: (context) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (errorMessage != null) {
            return Center(child: Text(errorMessage!));
          }

          if (supervisiItems.isEmpty) {
            return const Center(child: Text("Tidak ada data observasi kelas"));
          }
          final grouped = groupByKategori();
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: grouped.entries.map((entry) {
                    String kategori = entry.key;
                    List<ItemPenilaianModel> items = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔥 HEADER KATEGORI
                        // Padding(
                        //   padding: const EdgeInsets.all(12),
                        //   child: Text(
                        //     kategori,
                        //     style: const TextStyle(
                        //       fontSize: 18,
                        //       fontWeight: FontWeight.bold,
                        //       color: Colors.red,
                        //     ),
                        //   ),
                        // ),

                        // 🔥 LIST ITEM DALAM KATEGORI
                        ...items.map((item) {
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.namaKategori,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      backgroundColor: Color.fromARGB(
                                        255,
                                        248,
                                        211,
                                        211,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  // 🔥 PERNYATAAN
                                  Text(
                                    item.pernyataan,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 2),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ),
              ),

              // 🔥 SUBMIT
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: submitJawaban,
                    child: const Text("Submit"),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

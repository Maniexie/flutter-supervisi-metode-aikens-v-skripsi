import 'package:flutter/material.dart';
import 'package:supervisi/pages/aiken/aiken_home.dart';
import 'package:supervisi/services/api_service.dart';

class AikenKuesionerPage extends StatefulWidget {
  final int versi;

  const AikenKuesionerPage({super.key, required this.versi});

  @override
  State<AikenKuesionerPage> createState() => _AikenKuesionerPageState();
}

class _ProgressHeader extends SliverPersistentHeaderDelegate {
  final double value;
  final String text;

  _ProgressHeader({required this.value, required this.text});

  @override
  double get minExtent => 70;

  @override
  double get maxExtent => 70;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFFF5F7FB),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade300,
            color: Colors.blue,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ProgressHeader oldDelegate) {
    return oldDelegate.value != value || oldDelegate.text != text;
  }
}

class _AikenKuesionerPageState extends State<AikenKuesionerPage> {
  final service = ApiAikenService();

  List<Map<String, dynamic>> penilaian = [];
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> skala = const [
    {"label": "STS", "value": 1},
    {"label": "TS", "value": 2},
    {"label": "ATS", "value": 3},
    {"label": "N", "value": 4},
    {"label": "AS", "value": 5},
    {"label": "S", "value": 6},
    {"label": "SS", "value": 7},
  ];

  int get jumlahTerisi {
    return penilaian.where((e) => e["nilai"] != null).length;
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final data = await service.getKuesionerByVersi(widget.versi);

    setState(() {
      penilaian = data.map<Map<String, dynamic>>((e) {
        return {
          "id": e["id_item_penilaian"],
          "pernyataan": e["pernyataan"],
          "kode_kategori_penilaian": e["kode_kategori_penilaian"],
          "nama_kategori_penilaian": e["nama_kategori_penilaian"],
          "nilai": null,
        };
      }).toList();

      isLoading = false;
    });
  }

  void submit() async {
    bool lengkap = penilaian.every((e) => e["nilai"] != null);

    if (!lengkap) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua item harus dinilai")));

      scrollKeBelumDiisi(); // 🔥 otomatis lompat
      return;
    }

    try {
      final service = JawabanValidatorService();

      await service.submitJawabanValidator(widget.versi, penilaian);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Berhasil disimpan")));

      // Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AikenHomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Map<String, List<Map<String, dynamic>>> get grouped {
    Map<String, List<Map<String, dynamic>>> map = {};

    for (var item in penilaian) {
      final key = item["nama_kategori_penilaian"] ?? "-";

      if (!map.containsKey(key)) {
        map[key] = [];
      }

      map[key]!.add(item);
    }

    return map;
  }

  int get indexBelumDiisi {
    return penilaian.indexWhere((e) => e["nilai"] == null);
  }

  void scrollKeBelumDiisi() {
    final index = indexBelumDiisi;

    if (index != -1) {
      _scrollController.animateTo(
        index * 180.0, // estimasi tinggi card
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text("Kuesioner Versi ${widget.versi}"),
        centerTitle: true,
        elevation: 0,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                // 🔥 STICKY PROGRESS BAR
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _ProgressHeader(
                    value: penilaian.isEmpty
                        ? 0
                        : jumlahTerisi / penilaian.length,
                    text: "$jumlahTerisi / ${penilaian.length} selesai",
                  ),
                ),

                // 📄 CONTENT
                SliverList(
                  delegate: SliverChildListDelegate(
                    grouped.entries.map((entry) {
                      final kategori = entry.key;
                      final items = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 📌 HEADER KATEGORI
                          Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            padding: const EdgeInsets.all(10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              kategori,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // 📄 ITEM
                          ...items.map((item) {
                            return Container(
                              margin: const EdgeInsets.only(
                                bottom: 12,
                                left: 12,
                                right: 12,
                              ),
                              child: Card(
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item["pernyataan"],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 6,
                                        children: skala.map((s) {
                                          final selected =
                                              item["nilai"] == s["value"];

                                          return ChoiceChip(
                                            label: Text(s["label"]),
                                            selected: selected,
                                            onSelected: (_) {
                                              setState(() {
                                                item["nilai"] = s["value"];
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: submit,
            child: const Text(
              "Submit Penilaian",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

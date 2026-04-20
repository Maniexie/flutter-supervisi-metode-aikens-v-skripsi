import 'package:flutter/material.dart';
import 'package:supervisi/services/api_service.dart';

class AikenKuesionerPage extends StatefulWidget {
  final int versi;

  const AikenKuesionerPage({super.key, required this.versi});

  @override
  State<AikenKuesionerPage> createState() => _AikenKuesionerPageState();
}

class _AikenKuesionerPageState extends State<AikenKuesionerPage> {
  final service = ApiAikenService();

  List<Map<String, dynamic>> penilaian = [];
  bool isLoading = true;

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
          "nilai": null,
        };
      }).toList();

      isLoading = false;
    });
  }

  void submit() {
    bool lengkap = penilaian.every((e) => e["nilai"] != null);

    if (!lengkap) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua item harus dinilai")));
      return;
    }

    print(penilaian);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Berhasil disimpan")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kuesioner Versi ${widget.versi}")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: penilaian.length,
              itemBuilder: (context, index) {
                final item = penilaian[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["pernyataan"],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 10),

                        Wrap(
                          spacing: 10,
                          children: [1, 2, 3, 4, 5, 6, 7].map((val) {
                            return ChoiceChip(
                              label: Text(val.toString()),
                              selected: item["nilai"] == val,
                              onSelected: (selected) {
                                setState(() {
                                  item["nilai"] = val;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: submit,
          child: const Text("Submit Penilaian"),
        ),
      ),
    );
  }
}

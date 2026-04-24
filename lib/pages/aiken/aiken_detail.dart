import 'package:flutter/material.dart';
import 'package:supervisi/pages/aiken/aiken_kuesioner.dart';
import 'package:supervisi/services/api_service.dart';

class AikenDetailPage extends StatefulWidget {
  final int id;

  const AikenDetailPage({super.key, required this.id});

  @override
  State<AikenDetailPage> createState() => _AikenDetailPageState();
}

class _AikenDetailPageState extends State<AikenDetailPage> {
  final service = ApiAikenService();

  late Future<Map<String, dynamic>> futureDetailAiken;

  @override
  void initState() {
    super.initState();
    futureDetailAiken = service.getDetailKuesionerByVersi(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aiken DETAIL")),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: futureDetailAiken,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;

          if (data == null || data.isEmpty) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          final versi = data['versi'];
          final totalItem = data['total_item'];
          final items = data['items'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 FORM (READ ONLY)
                Card(
                  child: ListTile(
                    title: Text("Versi Aiken"),
                    trailing: Text("$versi"),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Total Item",
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: totalItem.toString()),
                ),

                const SizedBox(height: 20),

                // 🔥 PETUNJUK
                const Text(
                  "Petunjuk Pengisian Aiken's V",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Berikan penilaian terhadap setiap item berdasarkan relevansi. "
                  "Gunakan skala yang telah ditentukan untuk menentukan tingkat validitas setiap pernyataan.",
                ),

                const SizedBox(height: 20),

                // 🔥 LIST ITEM
                const Text(
                  "Daftar Pernyataan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                const SizedBox(height: 10),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return Card(
                      child: ListTile(
                        leading: Text("${index + 1}"),
                        title: Text(item['pernyataan']),
                        subtitle: Text("Status: ${item['status']}"),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 🔥 BUTTON AIKEN KUESIONER BY VERSI
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AikenKuesionerPage(versi: versi),
                        ),
                      );
                    },
                    label: const Text("Mulai Pengujian"),
                    icon: const Icon(Icons.rocket_launch_outlined),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

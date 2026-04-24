import 'package:flutter/material.dart';
import 'package:supervisi/pages/aiken/aiken_detail.dart';
import 'package:supervisi/services/api_service.dart';

class AikenHomePage extends StatefulWidget {
  const AikenHomePage({super.key});

  @override
  State<AikenHomePage> createState() => _AikenHomePageState();
}

class _AikenHomePageState extends State<AikenHomePage> {
  final service = ApiAikenService();
  final serviceJawaban = JawabanValidatorService();

  late Future<List<dynamic>> futureAll;

  @override
  void initState() {
    super.initState();

    futureAll = Future.wait([
      service.getVersiList(),
      serviceJawaban.getStatusJawaban(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kuesioner Aiken's V"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureAll,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("ERROR: ${snapshot.error}"));
          }

          final versiList = snapshot.data![0] as List<int>;
          final versiSudahDijawab = snapshot.data![1] as List<int>;

          print("VERSI: $versiList");
          print("SUDAH: $versiSudahDijawab");

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: versiList.length,
            itemBuilder: (context, index) {
              final versi = versiList[index];
              final sudahDijawab = versiSudahDijawab.contains(versi);

              return Card(
                color: sudahDijawab ? Colors.grey[300] : Colors.white,
                child: ListTile(
                  title: Text(
                    "Kuesioner Versi $versi",
                    style: TextStyle(
                      color: sudahDijawab ? Colors.grey : Colors.black,
                    ),
                  ),
                  leading: Icon(
                    sudahDijawab ? Icons.check_circle : Icons.cancel,
                    color: sudahDijawab ? Colors.green : Colors.red,
                  ),
                  onTap: sudahDijawab
                      ? null
                      : () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AikenDetailPage(id: versi),
                            ),
                          );

                          setState(() {
                            futureAll = Future.wait([
                              service.getVersiList(),
                              serviceJawaban.getStatusJawaban(),
                            ]);
                          });
                        },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

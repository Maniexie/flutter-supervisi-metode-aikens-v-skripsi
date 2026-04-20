import 'package:flutter/material.dart';
import 'package:supervisi/pages/aiken/aiken_kuesioner.dart';
import 'package:supervisi/services/api_service.dart';

class AikenHomePage extends StatefulWidget {
  const AikenHomePage({super.key});

  @override
  State<AikenHomePage> createState() => _AikenHomePageState();
}

class _AikenHomePageState extends State<AikenHomePage> {
  final service = ApiAikenService();

  late Future<List<int>> futureVersi;

  @override
  void initState() {
    super.initState();
    futureVersi = service.getVersiList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kuesioner Aiken's V"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<int>>(
        future: futureVersi,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final versiList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: versiList.length,
            itemBuilder: (context, index) {
              final versi = versiList[index];

              return Card(
                child: ListTile(
                  title: Text("Kuesioner Versi $versi"),
                  trailing: const Icon(Icons.arrow_forward_ios),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AikenKuesionerPage(versi: versi),
                      ),
                    );
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

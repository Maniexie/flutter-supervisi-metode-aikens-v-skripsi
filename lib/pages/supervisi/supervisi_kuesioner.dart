import 'package:flutter/material.dart';
import 'package:supervisi/pages/models/ItemPenilaianModel.dart';
import 'package:supervisi/services/api_service.dart';

class SupervisiKuesionerPage extends StatefulWidget {
  const SupervisiKuesionerPage({super.key});

  @override
  State<SupervisiKuesionerPage> createState() => _SupervisiKuesionerPageState();
}

class _SupervisiKuesionerPageState extends State<SupervisiKuesionerPage> {
  List<ItemPenilaianModel> supervisiItems = [];
  bool isLoading = true;
  String? errorMessage;

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
              return ListTile(
                title: Text(item.pernyataan),
                subtitle: Text("Kategori: ${item.kodeKategori}"),
              );
            },
          );
        },
      ),
    );
  }
}

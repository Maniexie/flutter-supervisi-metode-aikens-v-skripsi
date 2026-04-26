class ItemPenilaianModel {
  final int id;
  final String kodeKategori;
  final String pernyataan;
  final int versi;
  final double nilaiAiken;
  final String status;
  bool isDigunakan = false;

  ItemPenilaianModel({
    required this.id,
    required this.kodeKategori,
    required this.pernyataan,
    required this.versi,
    required this.nilaiAiken,
    required this.status,
    required this.isDigunakan,
  });

  factory ItemPenilaianModel.fromJson(Map<String, dynamic> json) {
    return ItemPenilaianModel(
      id: int.tryParse(json['id_item_penilaian'].toString()) ?? 0,
      kodeKategori: json['kode_kategori_penilaian']?.toString() ?? '-',
      pernyataan: json['pernyataan']?.toString() ?? '-',
      versi: int.tryParse(json['versi'].toString()) ?? 0,
      nilaiAiken: double.tryParse(json['nilai_aiken'].toString()) ?? 0.0,
      status: json['status']?.toString() ?? '-',
      isDigunakan: json['isDigunakan'] == 1 || json['isDigunakan'] == true,
    );
  }
}

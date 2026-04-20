class KategoriPenilaianModel {
  final String kodeKategoriPenilaian;
  final String namaKategoriPenilaian;

  KategoriPenilaianModel({
    required this.kodeKategoriPenilaian,
    required this.namaKategoriPenilaian,
  });

  factory KategoriPenilaianModel.fromJson(Map<String, dynamic> json) {
    return KategoriPenilaianModel(
      kodeKategoriPenilaian: json['kode_kategori_penilaian'],
      namaKategoriPenilaian: json['nama_kategori_penilaian'],
    );
  }
}

class GuruModel {
  final int id;
  final String? kodeJabatan;
  final String? kodeGolongan;
  final String? kodeStatusPegawai;
  final String? username;
  final String? nama;
  final String? nip;
  final String email;
  final String nomorHp;
  final String alamat;
  final String role;
  final bool isValidator;
  final String jenisKelamin;

  GuruModel({
    required this.id,
    this.kodeJabatan,
    this.kodeGolongan,
    this.kodeStatusPegawai,
    this.username,
    this.nama,
    this.nip,
    required this.email,
    required this.nomorHp,
    required this.alamat,
    required this.role,
    required this.isValidator,
    required this.jenisKelamin,
  });

  factory GuruModel.fromJson(Map<String, dynamic> json) {
    return GuruModel(
      id: json['id_user'],
      kodeJabatan: json['kode_jabatan'] ?? '',
      kodeGolongan: json['kode_golongan'] ?? '',
      kodeStatusPegawai: json['kode_status_pegawai'] ?? '',
      username: json['username'] ?? '',
      nama: json['nama'] ?? '',
      nip: json['nip'] ?? '',
      email: json['email'] ?? '',
      nomorHp: json['nomor_hp'] ?? '',
      alamat: json['alamat'] ?? '',
      role: json['role'] ?? '',
      isValidator:
          json['isValidator'] == 1 ||
          json['isValidator'] == true, // 🔥 FIX DISINI
      jenisKelamin: json['jenis_kelamin'] ?? '',
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supervisi/pages/aiken/aiken_kuesioner.dart';
import 'package:supervisi/services/api_service.dart';
import 'package:intl/intl.dart';

class AikenDetailPage extends StatefulWidget {
  final int id;

  const AikenDetailPage({super.key, required this.id});

  @override
  State<AikenDetailPage> createState() => _AikenDetailPageState();
}

class _AikenDetailPageState extends State<AikenDetailPage> {
  String nama = "";
  String nip = "";

  final service = ApiAikenService();
  late Future<Map<String, dynamic>> futureDetailAiken;

  late TextEditingController namaController;
  late TextEditingController nipController;
  late TextEditingController tanggalController;

  String _tanggalIndonesia() {
    final now = DateTime.now();
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
  }

  @override
  void initState() {
    super.initState();
    futureDetailAiken = service.getDetailKuesionerByVersi(widget.id);
    _loadUser();

    namaController = TextEditingController();
    nipController = TextEditingController();
    tanggalController = TextEditingController(
      text: _tanggalIndonesia(),
    ); // ✅ BENAR
  }

  void _loadUser() async {
    final data = await ApiGetUserService.getUser();

    if (data != null) {
      setState(() {
        nama = data['nama'] ?? 'No Name';
        nip = data['nip'] ?? 'No nip';
        print('NAMA: $nama |' + ' NIP: $nip');
      });
    }

    setState(() {
      namaController.text = nama;
      nipController.text = nip;
      tanggalController = TextEditingController(text: _tanggalIndonesia());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Intro Kuesioner Pengujian Validitas")),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 12),
                _dividerText(),
                _sectionTitle("IDENTITAS RESPONDEN AHLI"),
                const SizedBox(height: 12),
                _identitasForm(),
                const SizedBox(height: 20),
                _sectionTitle(
                  "Kuesioner Pengujian Validitas Aiken's Versi $versi",
                ),
                const SizedBox(height: 12),
                _petunjuk(),
                const SizedBox(height: 20),
                _startButton(context, versi),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🔵 HEADER
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        "SUPERVISI AKADEMIK KINERJA GURU UPT SDN 035 TARAI BANGUN UNTUK MENGUJI VALIDITAS ITEM PENILAIAN",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _dividerText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Center(
        child: Text(
          "----------------------------------------------------------------------------------------",
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.2),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            // letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  // 🧾 IDENTITAS
  Widget _identitasForm() {
    return Column(
      children: [
        _inputField("Nama Lengkap", controller: namaController),
        const SizedBox(height: 8),
        _inputField("NIP", controller: nipController),
        const SizedBox(height: 8),
        _inputField(
          "Tanggal Pengisian",
          readOnly: true,
          controller: tanggalController,
        ),
      ],
    );
  }

  Widget _inputField(
    String label, {
    bool readOnly = false,
    TextEditingController? controller,
  }) {
    return TextField(
      readOnly: readOnly,
      controller: controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ).copyWith(labelText: label),
    );
  }

  // 📘 PETUNJUK
  Widget _petunjuk() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "*Petunjuk",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          "1. Peneliti sangat berharap pada bantuan bapak/ibu untuk berkenan memberikan tanggapan terhadap setiap pernyataan dengan memberikan tanda centang (√) pada setiap kolom pilihan jawaban yang tersedia.",
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 4),
        Text(
          "2. Dalam respon yang bapak/ibu berikan tidak ada nilai benar atau salah dalam memberi centang (√) pada setiap kolom jawaban yang tersedia dan hasil tanggapan tidak ada kaitannya dengan karir bapak/ibu .",
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 4),
        Text(
          "3. Arti singkatan pada kolom pilihan jawaban yang tersedia:",
          textAlign: TextAlign.justify,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("a. STS  = Sangat Tidak Setuju"),
              Text("b. TS    = Tidak Setuju"),
              Text("c. ATS  = Agak Tidak Setuju"),
              Text("d. N      = Netral"),
              Text("e. AS    = Agak Setuju"),
              Text("f. S       = Setuju"),
              Text("g. SS    = Sangat Setuju"),
            ],
          ),
        ),
        SizedBox(height: 4),
        Text(
          "4. Sebelum bapak/ibu mengisi item pernyataan, peneliti mengucapkan terimakasih atas bantuan dan partisipasi yang diberikan.",
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  // 🚀 BUTTON
  Widget _startButton(BuildContext context, int versi) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AikenKuesionerPage(versi: versi),
            ),
          );
        },
        icon: const Icon(Icons.rocket_launch_outlined),
        label: const Text("Mulai Pengujian"),
      ),
    );
  }
}

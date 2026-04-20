class KuesionerAikenModel {
  final int id;
  final String pernyataan;
  int? nilai; // jawaban expert

  KuesionerAikenModel({required this.id, required this.pernyataan, this.nilai});
}

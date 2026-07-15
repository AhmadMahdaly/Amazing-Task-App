class TafsirModel {
  TafsirModel({
    required this.id,
    required this.sura,
    required this.aya,
    required this.text,
  });

  factory TafsirModel.fromJson(Map<String, dynamic> json) {
    return TafsirModel(
      id: json['id'] as int,
      sura: json['sura'] as int,
      aya: json['aya'] as int,
      text: json['text'] as String,
    );
  }

  final int id;
  final int sura;
  final int aya;
  final String text;
}

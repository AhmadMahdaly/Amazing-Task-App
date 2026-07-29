class ReciterModel {
  ReciterModel({
    required this.id,
    required this.name,
    required this.server,
  });

  factory ReciterModel.fromJson(Map<String, dynamic> json) {
    final moshafList = json['moshaf'] as List;
    final server = moshafList.isNotEmpty ? moshafList.first['server'] : '';

    return ReciterModel(
      id: json['id'] as int,
      name: json['name'] as String,
      server: server as String,
    );
  }
  final int id;
  final String name;
  final String server;
}

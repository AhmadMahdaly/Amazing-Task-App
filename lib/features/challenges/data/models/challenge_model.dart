class ChallengeModel {
  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.imagePath,
    this.completionDate,
  });

  factory ChallengeModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChallengeModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
      category: json['category'] as String? ?? '',
      level: ChallengeLevel.values.firstWhere(
        (element) => element.name == json['level'],
        orElse: () => ChallengeLevel.light,
      ),
      startDate:
          DateTime.tryParse(
            json['startDate'] as String? ?? '',
          ) ??
          DateTime.now(),
      endDate:
          DateTime.tryParse(
            json['endDate'] as String? ?? '',
          ) ??
          DateTime.now(),
      status: ChallengeStatus.values.firstWhere(
        (element) => element.name == json['status'],
        orElse: () => ChallengeStatus.active,
      ),
      completionDate: json['completionDate'] != null
          ? DateTime.tryParse(
              json['completionDate'] as String,
            )
          : null,
    );
  }

  final String id;
  final String title;
  final String description;
  final String? imagePath;
  final String category;
  final ChallengeLevel level;
  final DateTime startDate;
  final DateTime endDate;
  final ChallengeStatus status;
  final DateTime? completionDate;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'category': category,
      'level': level.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.name,
      'completionDate': completionDate?.toIso8601String(),
    };
  }

  ChallengeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imagePath,
    String? category,
    ChallengeLevel? level,
    DateTime? startDate,
    DateTime? endDate,
    ChallengeStatus? status,
    DateTime? completionDate,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      level: level ?? this.level,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      completionDate: completionDate ?? this.completionDate,
    );
  }
}

enum ChallengeLevel {
  light,
  medium,
  strong,
}

enum ChallengeStatus {
  active,
  success,
  failed,
}

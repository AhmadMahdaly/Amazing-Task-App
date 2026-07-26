import 'dart:convert';

class PlatformQuotaEntity {
  PlatformQuotaEntity({
    required this.platformId,
    required this.resetTime,
  });

  factory PlatformQuotaEntity.fromMap(Map<String, dynamic> map) {
    return PlatformQuotaEntity(
      platformId: map['platformId'] as String,
      resetTime: DateTime.parse(map['resetTime'] as String),
    );
  }
  final String platformId;
  final DateTime resetTime;

  Map<String, dynamic> toMap() {
    return {
      'platformId': platformId,
      'resetTime': resetTime.toIso8601String(),
    };
  }
}

class EmailAccountEntity {
  EmailAccountEntity({
    required this.id,
    required this.emailAddress,
    required this.quotas,
  });

  factory EmailAccountEntity.fromMap(Map<String, dynamic> map) {
    return EmailAccountEntity(
      id: map['id'] as String,
      emailAddress: map['emailAddress'] as String,
      quotas: map['quotas'] != null
          ? (map['quotas'] as List<dynamic>)
                .map(
                  (x) => PlatformQuotaEntity.fromMap(x as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }
  final String id;
  final String emailAddress;
  final List<PlatformQuotaEntity> quotas;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'emailAddress': emailAddress,
      'quotas': quotas.map((x) => x.toMap()).toList(),
    };
  }

  static String encode(List<EmailAccountEntity> emails) => json.encode(
    emails.map<Map<String, dynamic>>((email) => email.toMap()).toList(),
  );

  static List<EmailAccountEntity> decode(String emailsStr) =>
      (json.decode(emailsStr) as List<dynamic>)
          .map<EmailAccountEntity>(
            (item) => EmailAccountEntity.fromMap(item as Map<String, dynamic>),
          )
          .toList();
}

class AiPlatformEntity {
  AiPlatformEntity({
    required this.id,
    required this.name,
  });

  factory AiPlatformEntity.fromMap(Map<String, dynamic> map) {
    return AiPlatformEntity(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
    );
  }
  final String id;
  final String name;
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  static String encode(List<AiPlatformEntity> platforms) => json.encode(
    platforms.map<Map<String, dynamic>>((p) => p.toMap()).toList(),
  );

  static List<AiPlatformEntity> decode(String str) =>
      (json.decode(str) as List<dynamic>)
          .map<AiPlatformEntity>(
            (item) => AiPlatformEntity.fromMap(item as Map<String, dynamic>),
          )
          .toList();
}

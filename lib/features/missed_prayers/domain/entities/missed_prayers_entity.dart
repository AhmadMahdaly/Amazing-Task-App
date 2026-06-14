class MissedPrayersEntity {
  const MissedPrayersEntity({
    required this.birthDate,
    required this.commitmentDate,
    required this.doubtMonths,
    required this.totalTargetPerPrayer,
    required this.fajrLeft,
    required this.dhuhrLeft,
    required this.asrLeft,
    required this.maghribLeft,
    required this.ishaLeft,
  });
  final int totalTargetPerPrayer;
  final int fajrLeft;
  final int dhuhrLeft;
  final int asrLeft;
  final int maghribLeft;
  final int ishaLeft;
  final DateTime birthDate;
  final DateTime commitmentDate;
  final int doubtMonths;

  double getProgress(int prayerLeft) {
    if (totalTargetPerPrayer == 0) return 1;
    final completed = totalTargetPerPrayer - prayerLeft;
    return completed / totalTargetPerPrayer;
  }
}

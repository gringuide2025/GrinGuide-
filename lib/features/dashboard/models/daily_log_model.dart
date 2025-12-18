class DailyLogModel {
  final String date; // yyyy-MM-dd
  final String childId;
  final bool brushedMorning;
  final bool flossedMorning;
  final bool ateHealthy;
  final bool brushedNight;
  final bool flossedNight;

  DailyLogModel({
    required this.date,
    required this.childId,
    this.brushedMorning = false,
    this.flossedMorning = false,
    this.ateHealthy = false,
    this.brushedNight = false,
    this.flossedNight = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'childId': childId,
      'brushedMorning': brushedMorning,
      'flossedMorning': flossedMorning,
      'ateHealthy': ateHealthy,
      'brushedNight': brushedNight,
      'flossedNight': flossedNight,
    };
  }

  factory DailyLogModel.fromMap(Map<String, dynamic> map) {
    return DailyLogModel(
      date: map['date'] ?? '',
      childId: map['childId'] ?? '',
      brushedMorning: map['brushedMorning'] ?? false,
      flossedMorning: map['flossedMorning'] ?? false,
      ateHealthy: map['ateHealthy'] ?? false,
      brushedNight: map['brushedNight'] ?? false,
      flossedNight: map['flossedNight'] ?? false,
    );
  }
}

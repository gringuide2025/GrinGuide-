
class DailyChecklistModel {
  final String date; // YYYY-MM-DD
  final String childId;
  final bool brushMorning;
  final bool brushNight;
  final bool flossMorning;
  final bool flossNight;
  final bool healthyFood;
  final String healthyFoodItem;
  final String parentId;

  DailyChecklistModel({
    required this.date,
    required this.childId,
    required this.parentId,
    this.brushMorning = false,
    this.brushNight = false,
    this.flossMorning = false,
    this.flossNight = false,
    this.healthyFood = false,
    required this.healthyFoodItem,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'childId': childId,
      'brushMorning': brushMorning,
      'brushNight': brushNight,
      'flossMorning': flossMorning,
      'flossNight': flossNight,
      'healthyFood': healthyFood,
      'healthyFoodItem': healthyFoodItem,
      'parentId': parentId,
    };
  }

  factory DailyChecklistModel.fromMap(Map<String, dynamic> map) {
    return DailyChecklistModel(
      date: map['date'] ?? '',
      childId: map['childId'] ?? '',
      brushMorning: map['brushMorning'] ?? false,
      brushNight: map['brushNight'] ?? false,
      flossMorning: map['flossMorning'] ?? false,
      flossNight: map['flossNight'] ?? false,
      healthyFood: map['healthyFood'] ?? false,
      healthyFoodItem: map['healthyFoodItem'] ?? 'Banana',
      parentId: map['parentId'] ?? '',
    );
  }
  
  DailyChecklistModel copyWith({
    bool? brushMorning,
    bool? brushNight,
    bool? flossMorning,
    bool? flossNight,
    bool? healthyFood,
  }) {
    return DailyChecklistModel(
      date: date,
      childId: childId,
      healthyFoodItem: healthyFoodItem,
      brushMorning: brushMorning ?? this.brushMorning,
      brushNight: brushNight ?? this.brushNight,
      flossMorning: flossMorning ?? this.flossMorning,
      flossNight: flossNight ?? this.flossNight,
      healthyFood: healthyFood ?? this.healthyFood,
      parentId: parentId,
    );
  }
}

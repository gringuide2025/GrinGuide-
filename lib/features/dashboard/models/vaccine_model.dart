class VaccineModel {
  final String id;
  final String vaccineName;
  final DateTime scheduledDate;
  final DateTime? actualDate;
  final String? doctorName;
  final bool isDone;
  final String childId;

  VaccineModel({
    required this.id,
    required this.vaccineName,
    required this.scheduledDate,
    this.actualDate,
    this.isDone = false,
    required this.childId,
    this.doctorName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vaccineName': vaccineName,
      'scheduledDate': scheduledDate.toIso8601String(),
      'actualDate': actualDate?.toIso8601String(),
      'isDone': isDone,
      'childId': childId,
      'doctorName': doctorName,
    };
  }

  factory VaccineModel.fromMap(Map<String, dynamic> map) {
    return VaccineModel(
      id: map['id'] ?? '',
      vaccineName: map['vaccineName'] ?? '',
      scheduledDate: DateTime.parse(map['scheduledDate']),
      actualDate: map['actualDate'] != null ? DateTime.parse(map['actualDate']) : null,
      isDone: map['isDone'] ?? false,
      childId: map['childId'] ?? '',
      doctorName: map['doctorName'],
    );
  }
  
  VaccineModel copyWith({bool? isDone, DateTime? actualDate, String? doctorName}) {
    return VaccineModel(
      id: id,
      vaccineName: vaccineName,
      scheduledDate: scheduledDate,
      actualDate: actualDate ?? this.actualDate,
      isDone: isDone ?? this.isDone,
      childId: childId,
      doctorName: doctorName ?? this.doctorName,
    );
  }
}

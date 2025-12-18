class ChildModel {
  final String id;
  final String parentId;
  final String name;
  final DateTime dob;
  final double height; // in cm
  final double weight; // in kg
  final String? profilePhotoUrl;
  final String gender; // 'boy' or 'girl'

  ChildModel({
    required this.id,
    required this.parentId,
    required this.name,
    required this.dob,
    required this.height,
    required this.weight,
    this.profilePhotoUrl,
    this.gender = 'boy', // Default to boy
  });

  // Auto-calculate BMI
  double get bmi {
    if (height <= 0) return 0;
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }
  
  // Get default emoji based on gender
  String get defaultEmoji {
    return gender == 'girl' ? '👧' : '👦';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'name': name,
      'dob': dob.toIso8601String(),
      'height': height,
      'weight': weight,
      'profilePhotoUrl': profilePhotoUrl,
      'gender': gender,
    };
  }

  factory ChildModel.fromMap(Map<String, dynamic> map) {
    return ChildModel(
      id: map['id'] ?? '',
      parentId: map['parentId'] ?? '',
      name: map['name'] ?? '',
      dob: DateTime.tryParse(map['dob'] ?? '') ?? DateTime.now(),
      height: (map['height'] ?? 0).toDouble(),
      weight: (map['weight'] ?? 0).toDouble(),
      profilePhotoUrl: map['profilePhotoUrl'],
      gender: map['gender'] ?? 'boy',
    );
  }
}

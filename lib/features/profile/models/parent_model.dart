class ParentModel {
  final String uid;
  final String fatherName;
  final String motherName;
  final String email;
  final String? password; // Optional password field

  ParentModel({
    required this.uid,
    required this.fatherName,
    required this.motherName,
    required this.email,
    this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fatherName': fatherName,
      'motherName': motherName,
      'email': email,
      'password': password,
    };
  }

  factory ParentModel.fromMap(Map<String, dynamic> map) {
    return ParentModel(
      uid: map['uid'] ?? '',
      fatherName: map['fatherName'] ?? '',
      motherName: map['motherName'] ?? '',
      email: map['email'] ?? '',
      password: map['password'],
    );
  }
}

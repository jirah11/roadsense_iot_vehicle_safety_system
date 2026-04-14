class UserModel {
  final String uid;
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String createdAt;
  final String vehicleType;
  final String vehicleNickname;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
    required this.vehicleType,
    required this.vehicleNickname,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'vehicleType': vehicleType,
      'vehicleNickname': vehicleNickname,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: map['createdAt'] ?? '',
      vehicleType: map['vehicleType'] ?? 'sedan',
      vehicleNickname: map['vehicleNickname'] ?? 'My Vehicle',
    );
  }

  UserModel copyWith({
    String? uid,
    String? firstName,
    String? middleName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? createdAt,
    String? vehicleType,
    String? vehicleNickname,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNickname: vehicleNickname ?? this.vehicleNickname,
    );
  }
}

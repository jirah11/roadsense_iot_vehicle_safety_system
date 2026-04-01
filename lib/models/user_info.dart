// purpose neto, pang-cacall ko siya sa mga screens gets? gets
// warning feb 26, wala pang account signin login keme, dito lang muna to
class UserInfo {
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String createdAt;
  final String vehicleType;
  final String vehicleNickname;


  const UserInfo({
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
    this.email = '',
    this.phoneNumber = '',
    this.createdAt = '',
    this.vehicleType = 'sedan',
    this.vehicleNickname = 'My Vehicle',
  });


  UserInfo copyWith({
    String? firstName,
    String? middleName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? createdAt,
    String? vehicleType,
    String? vehicleNickname,
  }) {
    return UserInfo(
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

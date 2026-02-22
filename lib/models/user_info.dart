class UserInfo {
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String createdAt;

  const UserInfo({
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
    this.email = '',
    this.phoneNumber = '',
    this.createdAt = '',
  });

  UserInfo copyWith({
    String? firstName,
    String? middleName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? createdAt,
  }) {
    return UserInfo(
        firstName: firstName ?? this.firstName,
        middleName: middleName ?? this.middleName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        createdAt: createdAt ?? this.createdAt,
    );
  }
}
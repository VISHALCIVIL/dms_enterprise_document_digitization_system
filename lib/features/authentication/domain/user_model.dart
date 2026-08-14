enum UserRole { admin, supervisor, operator }

extension UserRoleExtension on UserRole {
  String get nameString {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.supervisor:
        return 'SUPERVISOR';
      case UserRole.operator:
        return 'OPERATOR';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'SUPERVISOR':
        return UserRole.supervisor;
      case 'OPERATOR':
      default:
        return UserRole.operator;
    }
  }
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String stationId;
  final String activeStatus; // ONLINE, SCANNING, IDLE, OFFLINE

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.stationId,
    this.activeStatus = 'ONLINE',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.nameString,
      'stationId': stationId,
      'activeStatus': activeStatus,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: UserRoleExtension.fromString(map['role'] as String? ?? 'OPERATOR'),
      stationId: map['stationId'] as String? ?? 'Station 1',
      activeStatus: map['activeStatus'] as String? ?? 'ONLINE',
    );
  }
}

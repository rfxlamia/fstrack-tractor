import 'package:equatable/equatable.dart';

/// User role enum for role-based access control
enum UserRole {
  kasie,
  operator,
  mandor,
  admin;

  String toApiString() {
    return name.toUpperCase();
  }

  static UserRole fromApiString(String value) {
    return values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => kasie,
    );
  }
}

/// User entity representing authenticated user data
class UserEntity extends Equatable {
  final String id;
  final String fullName;
  final UserRole role;
  final String? estateId;
  final bool isFirstTime;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.role,
    required this.estateId,
    required this.isFirstTime,
  });

  /// Create UserEntity from JSON (API response)
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      role: UserRole.fromApiString(json['role'] as String),
      estateId: json['estateId'] as String,
      isFirstTime: json['isFirstTime'] as bool,
    );
  }

  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'role': role.toApiString(),
      'estateId': estateId,
      'isFirstTime': isFirstTime,
    };
  }

  @override
  List<Object?> get props => [id, fullName, role, estateId, isFirstTime];

  @override
  bool get stringify => true;
}

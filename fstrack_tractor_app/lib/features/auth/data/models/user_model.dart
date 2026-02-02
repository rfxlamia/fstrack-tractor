import '../../domain/entities/user_entity.dart';

/// User model for data layer - converts between API JSON and domain entity
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.role,
    required super.estateId,
    required super.isFirstTime,
  });

  /// Create UserModel from JSON (API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json['id'].toString(),
        fullName: json['fullname'] as String,
        role: UserRole.fromApiString(json['roleId'] as String),
        estateId: json['plantationGroupId']?.toString(),
        isFirstTime: json['isFirstTime'] as bool,
      );
    } on ArgumentError catch (e) {
      // Stale localStorage with old role format (e.g., "KASIE")
      // Throw FormatException to trigger logout via global error handler
      throw FormatException('Invalid role format: ${e.message}. Please re-login.');
    }
  }

  /// Convert to UserEntity (domain model)
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      fullName: fullName,
      role: role,
      estateId: estateId,
      isFirstTime: isFirstTime,
    );
  }

  /// Create UserModel from UserEntity (for local storage)
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      fullName: entity.fullName,
      role: entity.role,
      estateId: entity.estateId,
      isFirstTime: entity.isFirstTime,
    );
  }
}

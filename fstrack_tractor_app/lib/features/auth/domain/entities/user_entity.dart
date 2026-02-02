import 'package:equatable/equatable.dart';

/// User role enum for role-based access control
///
/// Maps 15 production backend roles to 5 mobile app roles:
/// - kasiePg: KASIE_PG (CREATE permission)
/// - kasieFe: KASIE_FE (ASSIGN permission)
/// - operator: OPERATOR, OPERATOR_PG1
/// - mandor: MANDOR
/// - admin: SUPERADMIN + 10 other admin-level roles
enum UserRole {
  kasiePg,
  kasieFe,
  operator,
  mandor,
  admin;

  /// Permission helpers for clean UI checks
  ///
  /// MVP Phase (Fase 2): All roles can view work plans
  /// Future: May implement role-based filtering (operator sees assigned only)
  bool get isKasieType => this == UserRole.kasiePg || this == UserRole.kasieFe;
  bool get canCreateWorkPlan => this == UserRole.kasiePg;
  bool get canAssignWorkPlan => this == UserRole.kasieFe;
  bool get canViewWorkPlan => true; // All roles can view (MVP)

  /// Convert to API string format (matches backend roleId)
  String toApiString() {
    switch (this) {
      case UserRole.kasiePg:
        return 'KASIE_PG';
      case UserRole.kasieFe:
        return 'KASIE_FE';
      case UserRole.operator:
        return 'OPERATOR';
      case UserRole.mandor:
        return 'MANDOR';
      case UserRole.admin:
        return 'SUPERADMIN';
    }
  }

  /// Parse API roleId string to UserRole
  /// Maps 15 production roles to 5 mobile roles
  static UserRole fromApiString(String value) {
    final normalized = value.toUpperCase();
    switch (normalized) {
      case 'KASIE_PG':
        return UserRole.kasiePg;
      case 'KASIE_FE':
        return UserRole.kasieFe;
      case 'OPERATOR':
      case 'OPERATOR_PG1':
        return UserRole.operator;
      case 'MANDOR':
        return UserRole.mandor;
      case 'SUPERADMIN':
      case 'ADMINISTRASI':
      case 'ADMINISTRASI_PG':
      case 'ASSISTANT_MANAGER':
      case 'DEPUTY':
      case 'KABAG_FIELD_ESTABLISHMENT':
      case 'MANAGER':
      case 'MANAGER_FE_PG':
      case 'MASTER_LOKASI':
      case 'PG_MANAGER':
        return UserRole.admin;
      default:
        // SECURITY: Unknown roles throw error instead of becoming admin
        // Note: Don't include role value in error to prevent info disclosure
        throw ArgumentError('Role tidak dikenal. Silakan update aplikasi.');
    }
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
      id: json['id'].toString(),
      fullName: json['fullname'] as String,
      role: UserRole.fromApiString(json['roleId'] as String),
      estateId: json['plantationGroupId']?.toString(),
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

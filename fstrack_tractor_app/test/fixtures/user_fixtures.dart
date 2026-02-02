import 'package:fstrack_tractor/features/auth/domain/entities/user_entity.dart';

/// Test fixtures for User entity
class UserFixtures {
  static UserEntity kasiePgUser() => const UserEntity(
        id: 'user-123',
        fullName: 'Pak Suswanto',
        role: UserRole.kasiePg,
        estateId: 'estate-001',
        isFirstTime: false,
      );

  static UserEntity kasieFeUser() => const UserEntity(
        id: 'user-124',
        fullName: 'Pak Suswanto FE',
        role: UserRole.kasieFe,
        estateId: 'estate-001',
        isFirstTime: false,
      );

  static UserEntity operatorUser() => const UserEntity(
        id: 'user-456',
        fullName: 'Pak Siswanto',
        role: UserRole.operator,
        estateId: 'estate-001',
        isFirstTime: false,
      );

  static UserEntity mandorUser() => const UserEntity(
        id: 'user-789',
        fullName: 'Pak Mandor',
        role: UserRole.mandor,
        estateId: 'estate-001',
        isFirstTime: false,
      );

  static UserEntity firstTimeUser() => const UserEntity(
        id: 'user-new',
        fullName: 'New User',
        role: UserRole.operator,
        estateId: 'estate-001',
        isFirstTime: true,
      );

  static UserEntity adminUser() => const UserEntity(
        id: 'user-admin',
        fullName: 'Administrator',
        role: UserRole.admin,
        estateId: 'estate-001',
        isFirstTime: false,
      );

  static Map<String, dynamic> kasiePgUserJson() => {
        'id': 'user-123',
        'fullName': 'Pak Suswanto',
        'role': 'KASIE_PG',
        'estateId': 'estate-001',
        'isFirstTime': false,
      };

  static Map<String, dynamic> kasieFeUserJson() => {
        'id': 'user-124',
        'fullName': 'Pak Suswanto FE',
        'role': 'KASIE_FE',
        'estateId': 'estate-001',
        'isFirstTime': false,
      };
}

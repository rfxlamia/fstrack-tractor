import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserRole Enum', () {
    group('fromApiString - 15 Production Roles Mapping', () {
      test('maps KASIE_PG to kasiePg', () {
        expect(UserRole.fromApiString('KASIE_PG'), UserRole.kasiePg);
      });

      test('maps KASIE_FE to kasieFe', () {
        expect(UserRole.fromApiString('KASIE_FE'), UserRole.kasieFe);
      });

      test('maps OPERATOR to operator', () {
        expect(UserRole.fromApiString('OPERATOR'), UserRole.operator);
      });

      test('maps OPERATOR_PG1 to operator', () {
        expect(UserRole.fromApiString('OPERATOR_PG1'), UserRole.operator);
      });

      test('maps MANDOR to mandor', () {
        expect(UserRole.fromApiString('MANDOR'), UserRole.mandor);
      });

      test('maps SUPERADMIN to admin', () {
        expect(UserRole.fromApiString('SUPERADMIN'), UserRole.admin);
      });

      test('maps all 10 admin-level roles to admin', () {
        final adminRoles = [
          'ADMINISTRASI',
          'ADMINISTRASI_PG',
          'ASSISTANT_MANAGER',
          'DEPUTY',
          'KABAG_FIELD_ESTABLISHMENT',
          'MANAGER',
          'MANAGER_FE_PG',
          'MASTER_LOKASI',
          'PG_MANAGER',
        ];

        for (final role in adminRoles) {
          expect(
            UserRole.fromApiString(role),
            UserRole.admin,
            reason: '$role should map to UserRole.admin',
          );
        }
      });

      test('is case insensitive', () {
        expect(UserRole.fromApiString('kasie_pg'), UserRole.kasiePg);
        expect(UserRole.fromApiString('Kasie_Pg'), UserRole.kasiePg);
        expect(UserRole.fromApiString('superadmin'), UserRole.admin);
      });
    });

    group('fromApiString - Error Handling', () {
      test('throws ArgumentError for unknown role', () {
        expect(
          () => UserRole.fromApiString('UNKNOWN_ROLE'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Role tidak dikenal. Silakan update aplikasi.',
            ),
          ),
        );
      });

      test('throws ArgumentError for empty string', () {
        expect(
          () => UserRole.fromApiString(''),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('toApiString', () {
      test('kasiePg returns KASIE_PG', () {
        expect(UserRole.kasiePg.toApiString(), 'KASIE_PG');
      });

      test('kasieFe returns KASIE_FE', () {
        expect(UserRole.kasieFe.toApiString(), 'KASIE_FE');
      });

      test('operator returns OPERATOR', () {
        expect(UserRole.operator.toApiString(), 'OPERATOR');
      });

      test('mandor returns MANDOR', () {
        expect(UserRole.mandor.toApiString(), 'MANDOR');
      });

      test('admin returns SUPERADMIN', () {
        expect(UserRole.admin.toApiString(), 'SUPERADMIN');
      });
    });

    group('Permission Helpers', () {
      group('isKasieType', () {
        test('returns true for kasiePg', () {
          expect(UserRole.kasiePg.isKasieType, isTrue);
        });

        test('returns true for kasieFe', () {
          expect(UserRole.kasieFe.isKasieType, isTrue);
        });

        test('returns false for operator', () {
          expect(UserRole.operator.isKasieType, isFalse);
        });

        test('returns false for mandor', () {
          expect(UserRole.mandor.isKasieType, isFalse);
        });

        test('returns false for admin', () {
          expect(UserRole.admin.isKasieType, isFalse);
        });
      });

      group('canCreateWorkPlan', () {
        test('returns true only for kasiePg', () {
          expect(UserRole.kasiePg.canCreateWorkPlan, isTrue);
          expect(UserRole.kasieFe.canCreateWorkPlan, isFalse);
          expect(UserRole.operator.canCreateWorkPlan, isFalse);
          expect(UserRole.mandor.canCreateWorkPlan, isFalse);
          expect(UserRole.admin.canCreateWorkPlan, isFalse);
        });
      });

      group('canAssignWorkPlan', () {
        test('returns true only for kasieFe', () {
          expect(UserRole.kasiePg.canAssignWorkPlan, isFalse);
          expect(UserRole.kasieFe.canAssignWorkPlan, isTrue);
          expect(UserRole.operator.canAssignWorkPlan, isFalse);
          expect(UserRole.mandor.canAssignWorkPlan, isFalse);
          expect(UserRole.admin.canAssignWorkPlan, isFalse);
        });
      });

      group('canViewWorkPlan', () {
        test('returns true for all roles (MVP)', () {
          expect(UserRole.kasiePg.canViewWorkPlan, isTrue);
          expect(UserRole.kasieFe.canViewWorkPlan, isTrue);
          expect(UserRole.operator.canViewWorkPlan, isTrue);
          expect(UserRole.mandor.canViewWorkPlan, isTrue);
          expect(UserRole.admin.canViewWorkPlan, isTrue);
        });
      });
    });

    group('Round-trip Serialization', () {
      test('toApiString -> fromApiString returns original role', () {
        final roles = [
          UserRole.kasiePg,
          UserRole.kasieFe,
          UserRole.operator,
          UserRole.mandor,
          UserRole.admin,
        ];

        for (final role in roles) {
          final apiString = role.toApiString();
          final parsedRole = UserRole.fromApiString(apiString);
          expect(parsedRole, role, reason: 'Round-trip failed for $role');
        }
      });
    });
  });
}

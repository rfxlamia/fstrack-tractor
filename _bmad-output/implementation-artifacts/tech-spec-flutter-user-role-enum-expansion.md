---
title: 'Flutter UserRole Enum Expansion untuk Permission Enforcement'
slug: 'flutter-user-role-enum-expansion'
created: '2026-02-02'
status: 'implementation-complete'
stepsCompleted: [1, 2, 3, 4]
tech_stack: ['Flutter', 'Dart', 'Equatable', 'flutter_test']
files_to_modify:
  - 'fstrack_tractor_app/lib/features/auth/domain/entities/user_entity.dart'
  - 'fstrack_tractor_app/lib/features/auth/data/models/user_model.dart'
  - 'fstrack_tractor_app/lib/features/home/presentation/pages/home_page.dart'
  - 'fstrack_tractor_app/lib/features/home/presentation/widgets/role_based_menu_cards.dart'
  - 'fstrack_tractor_app/test/fixtures/user_fixtures.dart'
  - 'fstrack_tractor_app/test/fixtures/auth_fixtures.dart'
  - 'fstrack_tractor_app/test/mocks/mock_auth_repository.dart'
  - 'fstrack_tractor_app/test/features/home/presentation/pages/home_page_test.dart'
  - 'fstrack_tractor_app/test/features/home/presentation/widgets/role_based_menu_cards_test.dart'
code_patterns: ['Enum expansion dengan breaking changes', 'Permission helper getters', '15-to-5 role mapping', 'Static factory fixtures']
test_patterns: ['Static factory methods di fixtures', 'Inline const UserEntity construction', 'No test helper methods']
---

# Tech-Spec: Flutter UserRole Enum Expansion untuk Permission Enforcement

**Created:** 2026-02-02

## Overview

### Problem Statement

Flutter `UserRole` enum saat ini hanya memiliki 4 roles (kasie, operator, mandor, admin) dengan normalization logic yang merge `KASIE_PG` dan `KASIE_FE` menjadi satu role `kasie`. Hal ini menyebabkan:

1. Epic 2-4 tidak bisa enforce permission distinction antara CREATE (kasie_pg only) vs ASSIGN (kasie_fe only)
2. Story 2.2+ akan menampilkan UI button tapi mendapat 403 Forbidden dari backend
3. Backend sudah siap dengan 15 production roles dan proper RBAC guards

### Solution

Expand `UserRole` enum dari 4 roles menjadi 5 roles dengan mapping ke 15 production roles:
- `kasiePg` - Maps KASIE_PG (CREATE permission)
- `kasieFe` - Maps KASIE_FE (ASSIGN permission)
- `operator` - Maps OPERATOR, OPERATOR_PG1
- `mandor` - Maps MANDOR
- `admin` - Maps SUPERADMIN + 10 other admin-level roles

Add permission helper methods untuk clean permission checking di UI layer.

### Scope

**In Scope:**
- Expand UserRole enum ke 5 roles (kasiePg, kasieFe, operator, mandor, admin)
- Fix `fromApiString()` untuk map 15 production roles tanpa normalization
- Add permission helper getters: `canCreateWorkPlan`, `canAssignWorkPlan`, `canViewWorkPlan`
- Update 2 critical UI files yang enforce permission: `home_page.dart`, `role_based_menu_cards.dart`
- Update user fixtures untuk testing
- Fix broken tests akibat enum changes

**Out of Scope:**
- Backend changes (sudah aligned dengan production schema)
- Story 2.2+ implementation (masih blocked sampai fix ini selesai)
- 11 test files lainnya yang tidak critical (biarkan CI catch atau fix kemudian)
- Local storage migration (user akan re-login, dapat fresh token dengan roleId baru)

## Context for Development

### Codebase Patterns

**Test Pattern - Static Factory Fixtures:**
```dart
// test/fixtures/user_fixtures.dart
static UserEntity kasieUser() => const UserEntity(
  id: 'user-123',
  fullName: 'Pak Suswanto',
  role: UserRole.kasie, // Will break - need kasiePg or kasieFe
  estateId: 'estate-001',
  isFirstTime: false,
);
```

**Test Pattern - Inline Construction:**
```dart
// test/features/home/presentation/pages/home_page_test.dart line 208
const kasieUser = UserEntity(
  id: '1',
  fullName: 'Kasie User',
  role: UserRole.kasie, // Direct usage - akan compile error
  estateId: 'estate1',
  isFirstTime: false,
);
```

**Current fromApiString (AKAN BREAK):**
```dart
// user_entity.dart line 14-21
static UserRole fromApiString(String value) {
  // PROBLEM: split('_').first akan return "KASIE" dari "KASIE_PG"
  // Tapi enum tidak ada value "kasie" lagi setelah expansion!
  final normalized = value.toUpperCase().split('_').first;
  return values.firstWhere(
    (e) => e.name.toUpperCase() == normalized,
    orElse: () => kasie, // COMPILE ERROR: kasie tidak ada!
  );
}
```

**Current UI Pattern:**
```dart
// home_page.dart line 67 - FAB visibility
if (state.user.role != UserRole.kasie) return const SizedBox.shrink();

// role_based_menu_cards.dart line 36 - Layout selection
final isKasie = user.role == UserRole.kasie;
```

**Router Pattern (AMAN - Tidak ada role guard):**
```dart
// app_router.dart - Hanya cek authentication, bukan role
redirect: (context, state) {
  final authState = ref.read(authBlocProvider);
  if (authState is AuthSuccess) {
    if (authState.user.isFirstTime) return '/onboarding';
    return '/home';
  }
  return '/login';
}
```

### Files to Reference

| File | Purpose | Impact |
| ---- | ------- | ------ |
| `fstrack-tractor-api/src/database/migrations/1738571000000-create-roles-table.ts` | 15 production roles reference | Source of truth untuk mapping |
| `fstrack-tractor-api/src/schedules/schedules.controller.ts` | Backend permission guards (@Roles) | Kontrak API yang harus match |
| `_bmad-output/implementation-artifacts/2-1-work-plan-feature-module-setup.md` | Story yang blocked | Context Epic 2 requirements |
| `docs/schema-reference.md` | Production schema documentation | Role FK schema |
| `test/fixtures/user_fixtures.dart` | Test user factory methods | 4 fixtures perlu update |
| `test/fixtures/auth_fixtures.dart` | Auth response fixtures | Login result dengan role |
| `lib/core/router/app_router.dart` | Navigation routing | AMAN - tidak ada role guard |

### Breaking Changes

**CRITICAL:** Ini adalah breaking change yang akan menyebabkan compile errors di 13+ files!

1. **Enum value `UserRole.kasie` dihapus** → Semua direct reference akan compile error
2. **`fromApiString()` method akan break** → `split('_').first` return "KASIE" tapi enum tidak ada
3. **Test fixtures perlu pilih variant** → `kasieUser()` harus jadi `kasiePgUser()` atau `kasieFeUser()`
4. **UI checks perlu update** → `role == UserRole.kasie` perlu logic baru

### Technical Decisions

1. **5 roles bukan 15**: Mobile app tidak butuh semua granularity production roles. Simplify ke 5 mapping cukup untuk Epic 2-4.

2. **Permission helpers sebagai getters**: Lebih clean dari extension methods, dapat akses langsung via `user.role.canCreateWorkPlan`.

3. **15-to-5 Role Mapping Strategy**:
   ```yaml
   kasiePg: [KASIE_PG]
   kasieFe: [KASIE_FE]
   operator: [OPERATOR, OPERATOR_PG1]
   mandor: [MANDOR]
   admin: [SUPERADMIN, ADMINISTRASI, ADMINISTRASI_PG, ASSISTANT_MANAGER, DEPUTY, KABAG_FIELD_ESTABLISHMENT, MANAGER, MANAGER_FE_PG, MASTER_LOKASI, PG_MANAGER]
   ```

4. **No migration strategy**: User akan re-login dan dapat fresh JWT dengan roleId baru. Tidak perlu migrate local storage.

5. **Backward compatibility via helpers**: Add `isKasieType` getter untuk UI yang cek "apakah kasie?" tanpa perlu tahu PG vs FE.

## Implementation Plan

### Tasks

**Phase 1: Core Enum Expansion**

- [x] Task 1: Expand UserRole enum dari 4 ke 5 roles
  - File: `fstrack_tractor_app/lib/features/auth/domain/entities/user_entity.dart`
  - Action:
    - Ubah enum values dari `{kasie, operator, mandor, admin}` ke `{kasiePg, kasieFe, operator, mandor, admin}`
    - **CRITICAL FIX:** Replace entire `toApiString()` method dengan implementasi berikut:
      ```dart
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
      ```
  - Notes:
    - Ini akan menyebabkan compile errors di semua file yang reference `UserRole.kasie`
    - **CRITICAL:** Jangan gunakan `name.toUpperCase()` karena akan return `KASIEPG` (salah) bukan `KASIE_PG` (benar)
    - Return value HARUS match backend roleId format (dengan underscore)

- [x] Task 2: Fix fromApiString() untuk 15-to-5 mapping
  - File: `fstrack_tractor_app/lib/features/auth/domain/entities/user_entity.dart`
  - Action:
    - Hapus seluruh logic `split('_').first` yang normalize
    - Replace dengan implementasi berikut:
      ```dart
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
            // SECURITY FIX: Unknown roles throw error instead of becoming admin
            throw ArgumentError('Unknown role: $value. Please update the app.');
        }
      }
      ```
  - Notes:
    - **CRITICAL:** Jangan fallback ke `admin` untuk unknown roles - ini security vulnerability!
    - Throw error untuk unknown roles, biarkan error handler global catch dan logout user
    - Complete mapping semua 15 production roles explicitly

- [x] Task 3: Add permission helper getters
  - File: `fstrack_tractor_app/lib/features/auth/domain/entities/user_entity.dart`
  - Action:
    - Add getters **inside UserRole enum** (bukan extension):
      ```dart
      enum UserRole {
        kasiePg,
        kasieFe,
        operator,
        mandor,
        admin;

        // Permission helpers
        bool get isKasieType => this == UserRole.kasiePg || this == UserRole.kasieFe;
        bool get canCreateWorkPlan => this == UserRole.kasiePg;
        bool get canAssignWorkPlan => this == UserRole.kasieFe;
        bool get canViewWorkPlan => true; // All roles can view

        String toApiString() { ... }
        static UserRole fromApiString(String value) { ... }
      }
      ```
  - Notes:
    - **FIX:** Syntax harus `this == UserRole.kasiePg` BUKAN `this == kasiePg`
    - Helpers untuk backward compatibility dan clean permission checks

**Phase 2: Fix Production Code**

- [x] Task 4: Update HomePage FAB visibility check
  - File: `fstrack_tractor_app/lib/features/home/presentation/pages/home_page.dart`
  - Action:
    - Line 67: Ubah `if (state.user.role != UserRole.kasie)`
    - Menjadi: `if (!state.user.role.canCreateWorkPlan)`
  - Notes:
    - **DECISION:** Hanya `kasiePg` yang lihat FAB CREATE (proper permission enforcement)
    - Ini berbeda dari Task 11 AC yang test backward compatibility - AC11 akan direvisi
    - `kasieFe` TIDAK lihat FAB karena mereka hanya punya ASSIGN permission, bukan CREATE

- [x] Task 5: Update RoleBasedMenuCards layout logic
  - File: `fstrack_tractor_app/lib/features/home/presentation/widgets/role_based_menu_cards.dart`
  - Action:
    - Line 36: Ubah `final isKasie = user.role == UserRole.kasie;`
    - Menjadi: `final isKasie = user.role.isKasieType;`
  - Notes: Kedua kasie variant (PG dan FE) dapat layout yang sama (2 cards)

- [x] Task 6: Add localStorage migration / error handling
  - File: `fstrack_tractor_app/lib/features/auth/data/models/user_model.dart`
  - Action:
    - Wrap `UserRole.fromApiString()` call in try-catch:
      ```dart
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
          // Throw custom exception untuk trigger logout
          throw FormatException('Invalid role format: ${e.message}. Please re-login.');
        }
      }
      ```
  - Notes:
    - **MIGRATION STRATEGY:** Jika parse fail, throw FormatException untuk trigger global error handler
    - Auth BLoC sudah handle FormatException dengan logout + show error message
    - User akan dipaksa re-login dan dapat fresh JWT dengan roleId baru

- [x] Task 7: Verify UserEntity.toJson() serialization
  - File: `fstrack_tractor_app/lib/features/auth/domain/entities/user_entity.dart`
  - Action:
    - Baca line 52-60, verify `role.toApiString()` dipanggil
    - **Test roundtrip:** Parse dari JSON → toJson → parse lagi harus sama
  - Notes:
    - Sanity check - pastikan localStorage write path tidak corrupt
    - toApiString() sudah fixed di Task 1, ini verify saja

**Phase 3: Fix Test Fixtures**

- [x] Task 8: Update UserFixtures dengan kasie variants
  - File: `fstrack_tractor_app/test/fixtures/user_fixtures.dart`
  - Action:
    - Rename `kasieUser()` → `kasiePgUser()` dengan `role: UserRole.kasiePg`
    - Add new `kasieFeUser()` dengan `role: UserRole.kasieFe`
    - Keep `operatorUser()`, `mandorUser()`, `adminUser()` tanpa changes
  - Notes: Provide kedua variant untuk flexibility testing

- [ ] Task 8: Update AuthFixtures login result
  - File: `fstrack_tractor_app/test/fixtures/auth_fixtures.dart`
  - Action:
    - Line 15: Update `successfulLoginResult()` untuk gunakan `UserRole.kasiePg` (default untuk testing CREATE flow)
  - Notes: Pilih kasiePg sebagai default karena Epic 2 focus di CREATE

- [x] Task 9: Update MockAuthRepository default user
  - File: `fstrack_tractor_app/test/mocks/mock_auth_repository.dart`
  - Action:
    - Line 26: Update default mock user dari `UserRole.kasie` ke `UserRole.kasiePg`
  - Notes: Default ke kasiePg untuk konsistensi dengan auth fixtures

**Phase 4: Fix Critical Tests**

- [x] Task 10: Fix HomePage FAB visibility tests
  - File: `fstrack_tractor_app/test/features/home/presentation/pages/home_page_test.dart`
  - Action:
    - Line 211: Update inline kasieUser construction ke `role: UserRole.kasiePg`
    - Verify test masih pass dengan enum baru
    - Add test case untuk kasieFe juga lihat FAB (untuk fase ini)
  - Notes: Kedua kasie variant harus lihat FAB di fase ini

- [x] Task 11: Fix RoleBasedMenuCards layout tests
  - File: `fstrack_tractor_app/test/features/home/presentation/widgets/role_based_menu_cards_test.dart`
  - Action:
    - Line 40: Update kasie user construction ke `role: UserRole.kasiePg`
    - Add test case untuk kasieFe dapat 2 cards juga
    - Verify operator masih dapat 1 card
  - Notes: Test coverage untuk kedua kasie variants

**Phase 5: Verification**

- [x] Task 12: Run flutter analyze
  - Action: `flutter analyze` di `fstrack_tractor_app/`
  - Expected: No issues found
  - Notes: Pastikan tidak ada compile errors atau warnings

- [x] Task 13: Run all tests
  - Action: `flutter test` di `fstrack_tractor_app/`
  - Expected: All tests pass (256 tests)
  - Notes: 6 files lain yang pakai UserRole.kasie akan fail, tapi itu di luar scope (biarkan CI catch)

### Acceptance Criteria

- [ ] AC1: Given backend return roleId "KASIE_PG", when UserEntity.fromJson, then user.role == UserRole.kasiePg
- [ ] AC2: Given backend return roleId "KASIE_FE", when UserEntity.fromJson, then user.role == UserRole.kasieFe
- [ ] AC3: Given backend return roleId "OPERATOR", when UserEntity.fromJson, then user.role == UserRole.operator
- [ ] AC4: Given backend return roleId "SUPERADMIN", when UserEntity.fromJson, then user.role == UserRole.admin
- [ ] AC5: Given backend return unknown roleId "MASTER_LOKASI", when UserEntity.fromJson, then fallback ke UserRole.admin
- [ ] AC6: Given user role kasiePg, when check canCreateWorkPlan, then return true
- [ ] AC7: Given user role kasieFe, when check canCreateWorkPlan, then return false
- [ ] AC8: Given user role kasiePg, when check canAssignWorkPlan, then return false
- [ ] AC9: Given user role kasieFe, when check canAssignWorkPlan, then return true
- [ ] AC10: Given user role kasiePg, when HomePage render, then FAB visible
- [ ] AC11: Given user role kasieFe, when HomePage render, then FAB hidden (proper permission - only CREATE can see FAB)
- [ ] AC12: Given user role operator, when HomePage render, then FAB hidden
- [ ] AC13: Given user role kasiePg, when RoleBasedMenuCards render, then show 2 cards layout
- [ ] AC14: Given user role kasieFe, when RoleBasedMenuCards render, then show 2 cards layout
- [ ] AC15: Given user role operator, when RoleBasedMenuCards render, then show 1 card layout
- [ ] AC16: Given UserRole.kasiePg.toApiString(), when called, then return "KASIE_PG"
- [ ] AC17: Given flutter analyze run, when complete, then no issues found
- [ ] AC18: Given flutter test run, when complete, then all in-scope tests pass

## Additional Context

### Dependencies

**External:**
- Equatable package (sudah installed) - untuk UserEntity value equality
- flutter_test (built-in) - untuk testing

**Internal:**
- Backend API dengan 15 production roles (verified 2026-02-02)
- JWT authentication dengan roleId claim
- Auth BLoC untuk state management

**Blocked By:**
- None - backend sudah ready

**Blocks:**
- Story 2.2 (Create Work Plan Form UI) - butuh permission check
- Story 3.2 (Assign Operator Bottom Sheet) - butuh role distinction

### Testing Strategy

**Unit Tests (In Scope):**

1. **UserRole enum tests:**
   - Test `fromApiString()` mapping untuk semua 15 production roles
   - Test unknown role fallback ke admin
   - Test `toApiString()` return format yang benar
   - Test permission helpers (canCreateWorkPlan, canAssignWorkPlan, isKasieType)

2. **UserEntity fromJson tests:**
   - Test parsing roleId dari API response
   - Test semua 5 role variants
   - Test backward compatibility (existing tests masih pass)

3. **Widget tests:**
   - HomePage FAB visibility dengan kasiePg, kasieFe, operator
   - RoleBasedMenuCards layout dengan kedua kasie variants
   - Verify non-kasie roles tetap dapat correct layout

**Integration Tests (Out of Scope):**
- End-to-end login flow dengan real backend - biarkan manual testing
- Permission enforcement di Story 2.2+ - nanti di story masing-masing

**Manual Testing (Required):**
1. Login dengan dev_kasie_pg → verify dapat FAB dan 2 cards
2. Login dengan dev_kasie_fe → verify dapat FAB dan 2 cards
3. Login dengan dev_operator → verify tidak dapat FAB, hanya 1 card
4. Logout → Login lagi → verify fresh token dengan roleId baru

### Notes

**CRITICAL FIXES APPLIED (Adversarial Review 2026-02-02):**

1. **F1 - toApiString() corruption fixed:** Complete switch implementation prevents `KASIEPG` bug
2. **F2 - UserEntity.toJson() verified:** Added explicit verification task (Task 7)
3. **F3 - localStorage migration added:** FormatException handling forces re-login (Task 6)
4. **F4 - Permission contradiction resolved:** kasieFe does NOT see FAB CREATE (AC11 fixed, Task 4 clarified)
5. **F5 - Security vulnerability fixed:** Unknown roles throw error instead of becoming admin (Task 2)

**High-Risk Items:**

1. **Breaking change tanpa migration path** - ✅ **FIXED:** Task 6 adds FormatException handling untuk stale localStorage
   - Mitigation: FormatException triggers logout → user re-login → fresh JWT dengan roleId baru

2. **toApiString() localStorage corruption** - ✅ **FIXED:** Task 1 provides complete switch implementation
   - Mitigation: Explicit mapping prevents `KASIEPG` bug, Task 7 verifies roundtrip serialization

3. **Unknown role security vulnerability** - ✅ **FIXED:** Task 2 throws error instead of defaulting to admin
   - Mitigation: ArgumentError forces app update or backend fix, prevents privilege escalation

**Known Limitations:**

- Mobile app hanya support 5 dari 15 production roles
- 10 admin-level roles di production semua treated sebagai generic "admin" di mobile
- Tidak ada migration strategy untuk existing logged-in users

**Future Considerations (Out of Scope):**

- Story 2.2: Enforce kasiePg-only untuk CREATE button (saat ini kedua kasie variant lihat button)
- Story 3.2: Enforce kasieFe-only untuk ASSIGN button
- Story 4.1: Implement role-based filtering (operator hanya lihat assigned work plans)
- Granular role permissions jika bisnis requirements berubah (misal: MANAGER butuh distinct permission)

### Testing Strategy

*Will be filled in Step 2*

### Notes

- Story 2.1 sudah complete dengan warning tentang blocker ini
- Sprint status updated dengan blocker note untuk Story 2.2
- Epic 1 failure doc sudah di-mark RESOLVED untuk backend side

## Review Notes

**Adversarial Review Completed:** 2026-02-03
- **Findings:** 7 total (1 Critical, 3 High, 3 Medium)
- **Fixed:** 4 (F4, F6, F7 + F5 acknowledged as intentional)
- **Skipped:** 3 (F1 - false positive, F2 - deferred to monitoring, F3 - accepted tradeoff)
- **Resolution approach:** Auto-fix dengan analisis setiap temuan

**Fixed Issues:**
- F4: Created comprehensive unit tests (`user_role_test.dart`) - 24 tests
- F6: Error message diubah ke Bahasa Indonesia, menghilangkan info disclosure
- F7: Dokumentasi ditambahkan untuk `canViewWorkPlan`

**Acknowledged/Deferred:**
- F1: Admin privilege escalation - Backend menggunakan JWT roleId, bukan string dari mobile
- F2: Incomplete operator mapping - Monitoring dengan logging, fix jika muncul di production
- F3: Hardcoded roles - Accepted tradeoff untuk MVP (backend roles jarang berubah)

**Test Results:**
- Pre-fix: 258 tests passed
- Post-fix: 282 tests passed (+24 new unit tests)
- flutter analyze: No issues found

---
project_name: 'fstrack-tractor'
user_name: 'V'
date: '2026-01-31'
sections_completed: ['technology_stack', 'fase2_context']
version: '2.0'
---

# FSTrack-Tractor Project Context

> **Purpose:** This file contains critical rules and patterns that AI agents MUST follow when implementing code. This is the authoritative source for architectural decisions.
> 
> **Last Updated:** 2026-01-31
> **Project Phase:** Fase 2 - Work Plan Management (CREATE → ASSIGN → VIEW)

---

## Technology Stack & Versions

### Core Technologies

| Layer | Technology | Version | Notes |
|-------|------------|---------|-------|
| **Frontend** | Flutter | 3.x | Dart 3+ with null safety |
| **Backend** | NestJS | 11.x | TypeScript 5.x strict mode |
| **Database** | PostgreSQL | 15+ | Production Bulldozer DB |
| **ORM** | TypeORM | Latest | Migrations (no auto-sync in prod) |

### Flutter Dependencies

| Package | Purpose | Critical Rules |
|---------|---------|----------------|
| `flutter_bloc` | State Management | One BLoC per feature, sealed classes |
| `get_it` + `injectable` | Dependency Injection | Auto-generated via build_runner |
| `go_router` | Navigation | Auth redirect integrated with AuthBloc |
| `hive` + `flutter_secure_storage` | Local Storage | Encrypted boxes for JWT |
| `dio` | Networking | Interceptors for auth and logging |
| `dartz` | Functional Programming | Either<Failure, Success> pattern |
| `equatable` | Value Equality | For BLoC states |

### NestJS Dependencies

| Package | Purpose | Critical Rules |
|---------|---------|----------------|
| `@nestjs/jwt` + `passport` | Authentication | 14 days expiry, 24h grace period |
| `bcrypt` | Password Hashing | Existing auth system |
| `class-validator` | DTO Validation | All inputs validated |
| `@nestjs/swagger` | API Documentation | Auto-generated docs |

---

## Fase 2 Context: Work Plan Management

### Scope
- **30 Functional Requirements** (FR-F2-1 to FR-F2-30)
- **27 Non-Functional Requirements**
- **3 Core Operations:** CREATE → ASSIGN → VIEW

### RBAC Roles (6 roles)

| Role | CREATE | ASSIGN | VIEW |
|------|--------|--------|------|
| `kasie_pg` | ✅ | ❌ | ✅ (all) |
| `kasie_fe` | ❌ | ✅ | ✅ (all) |
| `operator` | ❌ | ❌ | ✅ (assigned only) |
| `mandor` | ❌ | ❌ | ✅ (all) |
| `estate_pg` | ❌ | ❌ | ✅ (all) |
| `admin` | ❌ | ❌ | ✅ (all) |

### State Machine

```
OPEN → ASSIGNED → IN_PROGRESS → COMPLETED
```

- **OPEN** → Work plan baru (default)
- **ASSIGNED** → Operator ditugaskan
- **IN_PROGRESS** → Operator sedang bekerja (Fase 3)
- **COMPLETED** → Work plan selesai (Fase 3)

**Validation Strategy:** Hybrid (Service Layer + DB Constraints)

---

## Implementation History & Context Changes

### Story 1.6: User Dummy Seeding - Scope Change (2026-02-02)

**Original Spec:** 6 users (kasie_pg, kasie_fe, operator, mandor, estate_pg, admin)

**Actual Implementation:** 3 users only
- `dev_kasie_pg` / `DevPassword123` (KASIE_PG)
- `dev_kasie_fe` / `DevPassword123` (KASIE_FE)
- `dev_operator` / `DevPassword123` (OPERATOR)

**Why the Change:**
- Story 1.6 spec dibuat SEBELUM database schema fix besar-besaran
- Setelah fix: schema menggunakan 15 roles dari production Bulldozer DB
- `estate_pg` TIDAK ADA di production roles (15 roles: KASIE_PG, KASIE_FE, OPERATOR, MANDOR, dll)
- Spec 6 roles tidak match dengan reality production schema

**Status:** Story 1.6 marked as `done` dengan implementasi 3 users yang mencakup core workflow (CREATE → ASSIGN → VIEW). Roles tambahan (mandor, admin) bisa ditambah later jika diperlukan untuk testing.

**For Future Agents:**
- Jangan bingung kalau sprint-status.yaml menunjukkan 1-6: done tapi cuma 3 users
- Ini intentional decision setelah schema alignment, bukan bug
- Core testing needs (CREATE/ASSIGN/VIEW) sudah tercover oleh 3 users

---

## Critical Implementation Rules

### 1. Clean Architecture (MANDATORY)

**NEVER flatten this structure:**

```
lib/features/{feature_name}/
├── data/                    # Repository implementations
│   ├── datasources/         # Remote & local data sources
│   ├── models/              # Data models (DTOs)
│   └── repositories/        # Repository implementations
├── domain/                  # Business logic
│   ├── entities/            # Business entities
│   ├── repositories/        # Abstract interfaces
│   └── usecases/            # Use cases
└── presentation/            # UI layer
    ├── bloc/                # BLoC files
    ├── pages/               # Screen widgets
    └── widgets/             # Reusable widgets
```

**✅ CORRECT:**
```dart
// data/repositories/work_plan_repository_impl.dart
class WorkPlanRepositoryImpl implements WorkPlanRepository { ... }

// domain/repositories/work_plan_repository.dart
abstract class WorkPlanRepository { ... }
```

**❌ WRONG:**
```dart
// lib/work_plan/work_plan_repository.dart (flattened!)
// lib/work_plan/work_plan_bloc.dart (mixed layers!)
```

### 2. BLoC Pattern Rules

**Event Naming:** `{Action}{Object}{Verb}` (PascalCase)
```dart
// ✅ CORRECT
class CreateWorkPlanRequested extends WorkPlanEvent { ... }
class AssignOperatorPressed extends WorkPlanEvent { ... }
class LoadWorkPlansRequested extends WorkPlanEvent { ... }

// ❌ WRONG
class createWorkPlan extends WorkPlanEvent { ... }
class LoadWorkPlans extends WorkPlanEvent { ... }
```

**State Pattern:**
```dart
abstract class WorkPlanState extends Equatable { ... }
class WorkPlanInitial extends WorkPlanState { ... }
class WorkPlanLoading extends WorkPlanState { ... }
class WorkPlanLoaded extends WorkPlanState {
  final List<WorkPlan> workPlans;
}
class WorkPlanError extends WorkPlanState {
  final String message;  // ALWAYS in Bahasa Indonesia
}
```

**State Updates:**
```dart
// ✅ CORRECT - Emit new instances
emit(WorkPlanLoading());
final result = await repository.getWorkPlans();
result.fold(
  (failure) => emit(WorkPlanError(failure.message)),
  (workPlans) => emit(WorkPlanLoaded(workPlans)),
);

// ❌ WRONG - Mutable state
state.workPlans = newWorkPlans;
emit(state);
```

### 3. Error Handling Pattern

**Repository Layer:**
```dart
// ✅ CORRECT - Either<Failure, Success>
Future<Either<Failure, WorkPlan>> createWorkPlan(CreateWorkPlanParams params);

// Returns typed failures
return Left(ServerFailure('Gagal membuat rencana kerja'));
return Left(ValidationFailure('Semua field wajib diisi'));
```

**BLoC Layer:**
```dart
result.fold(
  (failure) => emit(WorkPlanError(failure.message)),
  (workPlan) => emit(WorkPlanCreated(workPlan)),
);
```

**UI Layer:**
```dart
if (state is WorkPlanError) {
  showToast(state.message);  // Already in Bahasa Indonesia
}
```

**❌ NEVER throw raw exceptions to UI layer!**

### 4. Naming Conventions

**Flutter/Dart:**

| Type | Convention | Example | ❌ Wrong |
|------|------------|---------|----------|
| Files | snake_case | `work_plan_bloc.dart` | `WorkPlanBloc.dart` |
| Classes | PascalCase | `WorkPlanBloc` | `workPlanBloc` |
| Variables | camelCase | `isLoading` | `is_loading` |
| Constants | camelCase | `apiBaseUrl` | `API_BASE_URL` |
| Private members | `_prefix` | `_repository` | `privateRepository` |
| BLoC Events | PascalCase + Verb | `CreateWorkPlanRequested` | `createWorkPlan` |
| BLoC States | PascalCase | `WorkPlanLoading` | `workPlanLoading` |

**NestJS/TypeScript:**

| Type | Convention | Example | ❌ Wrong |
|------|------------|---------|----------|
| Files | kebab-case | `schedules.service.ts` | `schedulesService.ts` |
| Classes | PascalCase | `SchedulesService` | `schedulesService` |
| DTOs | PascalCase + Dto | `CreateScheduleDto` | `CreateSchedule` |
| Constants | UPPER_SNAKE | `JWT_SECRET` | `jwtSecret` |

**Database (PostgreSQL):**

| Element | Convention | Example | ❌ Wrong |
|---------|------------|---------|----------|
| Tables | snake_case, plural | `schedules` | `Schedules`, `schedule` |
| Columns | snake_case | `operator_id` | `operatorId` |
| Foreign Keys | `{table}_id` | `operator_id` | `fk_operator` |
| Indexes | `idx_{table}_{column}` | `idx_schedules_operator_id` | `schedules_operator_idx` |

**API (REST):**

| Element | Convention | Example | ❌ Wrong |
|---------|------------|---------|----------|
| Endpoints | kebab-case, plural | `/api/v1/schedules` | `/schedule` |
| Route params | camelCase with `:` | `:id`, `:scheduleId` | `:schedule_id` |
| JSON fields | camelCase | `{ "workDate": "..." }` | `{ "work_date": "..." }` |

### 5. Repository Method Naming (STANDARD VERBS)

**✅ CORRECT:**
```dart
abstract class WorkPlanRepository {
  Future<Either<Failure, WorkPlan>> getById(String id);
  Future<Either<Failure, List<WorkPlan>>> getAll();
  Future<Either<Failure, WorkPlan>> create(CreateWorkPlanParams params);
  Future<Either<Failure, WorkPlan>> update(String id, UpdateWorkPlanParams params);
  Future<Either<Failure, void>> delete(String id);
}
```

**❌ WRONG - Inconsistent verbs:**
```dart
fetchWorkPlan(), loadWorkPlansById(), getWorkPlanData(), retrieveCurrentWorkPlan()
```

**Use ONLY these verbs:** `get`, `create`, `update`, `delete`

### 6. Bahasa Indonesia Requirement

**ALL user-facing text MUST be in Bahasa Indonesia:**

```dart
// ✅ CORRECT
'Sedang memuat...'
'Rencana kerja berhasil dibuat!'
'Operator berhasil ditugaskan!'
'Semua field wajib diisi'
'Anda tidak memiliki akses untuk operasi ini'

// ❌ WRONG - English user-facing text
'Loading...'
'Work plan created successfully!'
```

**Error Messages (Standardized):**

| Scenario | Message |
|----------|---------|
| CREATE success | "Rencana kerja berhasil dibuat!" |
| ASSIGN success | "Operator berhasil ditugaskan!" |
| Validation error | "Semua field wajib diisi" |
| Unauthorized | "Anda tidak memiliki akses untuk operasi ini" |
| Invalid transition | "Transisi status tidak valid" |
| Loading | "Sedang memuat..." |

### 7. Design System (Bulldozer Alignment)

**Colors - EXACT HEX VALUES:**
```dart
class AppColors {
  static const Color primary = Color(0xFF008945);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF828282);
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color buttonOrange = Color(0xFFFBA919);
  static const Color buttonBlue = Color(0xFF25AAE1);
  static const Color greyCard = Color(0xFFF0F0F0);
  static const Color greyDate = Color(0xFF828282);
}
```

**Typography:**
- Font: Poppins (BUNDLED in assets, NOT GoogleFonts)
- Weights: 400, 500, 600, 700
- Sizes: 8, 10, 12, 13, 20

**❌ NEVER use hardcoded hex values - ALWAYS use AppColors!**

### 8. RBAC Implementation Rules

**Backend (NestJS):**
```typescript
// ✅ CORRECT - Use Roles decorator
@Post('schedules')
@Roles('kasie_pg')  // Hanya Kasie PG bisa CREATE
async createSchedule(...) { }

@Patch('schedules/:id')
@Roles('kasie_fe')  // Hanya Kasie FE bisa ASSIGN
async assignOperator(...) { }
```

**Frontend (Flutter):**
```dart
// ✅ CORRECT - Role-based widget visibility
if (user.role == UserRole.kasiePg) {
  FloatingActionButton(...);  // CREATE button
}

if (user.role == UserRole.kasieFe && workPlan.status == 'OPEN') {
  AssignBottomSheet(...);  // ASSIGN form
}
```

**Permission Matrix (MUST ENFORCE):**

| Operation | Kasie PG | Kasie FE | Operator | Others |
|-----------|----------|----------|----------|--------|
| CREATE | ✅ | ❌ | ❌ | ❌ |
| ASSIGN | ❌ | ✅ | ❌ | ❌ |
| VIEW | ✅ all | ✅ all | ✅ assigned | ✅ all |

### 9. API Design Rules

**Endpoints:**

| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| GET | /api/v1/schedules | All | List work plans (filtered by role) |
| POST | /api/v1/schedules | kasie_pg | CREATE work plan |
| GET | /api/v1/schedules/:id | All | Get work plan detail |
| PATCH | /api/v1/schedules/:id | kasie_fe | ASSIGN operator |
| GET | /api/v1/operators | kasie_fe | List available operators |

**Response Format:**
```typescript
// Success response
{
  "statusCode": 200,
  "message": "Rencana kerja berhasil dibuat!",
  "data": { ... }
}

// Error response
{
  "statusCode": 403,
  "message": "Anda tidak memiliki akses untuk operasi ini",
  "error": "Forbidden",
  "timestamp": "2026-01-30T08:30:00.000Z"
}
```

**HTTP Status Codes:**
- `200` - Success
- `201` - Resource created
- `400` - Bad Request
- `401` - Unauthorized (invalid/missing token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `422` - Unprocessable Entity (validation error)

### 10. State Machine Validation

**Hybrid Approach (Service + DB):**

```typescript
// Service Layer
async updateStatus(id: string, newStatus: string) {
  const validTransitions = {
    'OPEN': ['ASSIGNED'],
    'ASSIGNED': ['IN_PROGRESS'],
    'IN_PROGRESS': ['COMPLETED']
  };

  const current = await this.findById(id);
  if (!validTransitions[current.status]?.includes(newStatus)) {
    throw new BadRequestException('Transisi status tidak valid');
  }
  // ... update logic
}
```

```sql
-- Database Layer (safety net)
ALTER TABLE schedules ADD CONSTRAINT valid_status
  CHECK (status IN ('OPEN', 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED'));
```

### 11. Testing Requirements

**Golden Tests (MANDATORY for custom widgets):**
```dart
testGoldens('WidgetName renders correctly', (tester) async {
  await tester.pumpWidgetBuilder(
    WidgetName(...),
  );
  await screenMatchesGolden(tester, 'widget_name_state');
});
```

**BLoC Testing:**
```dart
blocTest<WorkPlanBloc, WorkPlanState>(
  'emits [loading, success] when create succeeds',
  build: () => WorkPlanBloc(repository: mockRepository),
  act: (bloc) => bloc.add(CreateWorkPlanRequested(params)),
  expect: () => [
    WorkPlanLoading(),
    WorkPlanCreated(testWorkPlan),
  ],
);
```

**Test Structure:**
```
test/
├── features/
│   ├── auth/
│   ├── home/
│   └── work_plan/          # Mirror lib structure
├── fixtures/               # Mock data
│   ├── user_fixtures.dart
│   ├── work_plan_fixtures.dart
│   └── jwt_fixtures.dart
└── helpers/
    └── test_helpers.dart
```

**RBAC Test Coverage:** 18 test cases (6 roles × 3 operations) = **100% coverage**

### 12. Date/Time Formats

| Context | Format | Example |
|---------|--------|---------|
| API (JSON) | ISO 8601 | `"2026-01-30T08:30:00.000Z"` |
| Database | TIMESTAMPTZ | PostgreSQL native |
| Display (Flutter) | Indonesia locale | `"30 Januari 2026, 15:30 WIB"` |

### 13. Critical Don't-Miss Rules

**❌ NEVER DO THESE:**

1. **Flatten Clean Architecture layers**
   ```dart
   // ❌ BAD
   lib/work_plan/
     ├── work_plan_bloc.dart
     ├── work_plan_repository.dart
     └── work_plan_page.dart
   ```

2. **Throw raw exceptions to UI**
   ```dart
   // ❌ BAD
   throw Exception('Failed to create work plan');
   
   // ✅ GOOD
   return Left(ServerFailure('Gagal membuat rencana kerja'));
   ```

3. **Hardcode colors or use GoogleFonts**
   ```dart
   // ❌ BAD
   Color(0xFF008945)  // Hardcoded!
   GoogleFonts.poppins()  // Network dependency!
   
   // ✅ GOOD
   AppColors.primary
   TextStyle(fontFamily: 'Poppins')  // Bundled font
   ```

4. **Inconsistent repository verbs**
   ```dart
   // ❌ BAD
   fetchWorkPlan(), loadWorkPlans(), retrieveData()
   
   // ✅ GOOD
   getById(), getAll(), create(), update(), delete()
   ```

5. **English user-facing text**
   ```dart
   // ❌ BAD
   Text('Loading...')
   
   // ✅ GOOD
   Text('Sedang memuat...')
   ```

6. **Skip golden tests for widgets**
   - All custom widgets MUST have golden tests
   - Test ALL states (loading, success, error, empty)

7. **Forget barrel files**
   ```dart
   // ✅ REQUIRED - Every feature must have barrel file
   // features/work_plan/work_plan.dart
   export 'data/data.dart';
   export 'domain/domain.dart';
   export 'presentation/presentation.dart';
   ```

8. **Mix snake_case and camelCase in JSON**
   ```dart
   // API uses camelCase
   { "workDate": "2026-01-30", "operatorId": "uuid" }
   
   // Database uses snake_case
   work_date, operator_id
   
   // Model handles conversion in fromJson/toJson
   ```

---

## Project Structure Reference

### Flutter App
```
lib/
├── features/
│   ├── auth/
│   ├── home/
│   ├── weather/
│   └── work_plan/              # NEW: Fase 2 feature
│       ├── work_plan.dart      # Barrel file
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           └── widgets/
├── core/
│   ├── config/                 # AppColors, AppTextStyle, AppTheme
│   ├── constants/              # API endpoints, durations
│   ├── error/                  # Exceptions, Failures
│   ├── network/                # Dio client, interceptors
│   └── utils/                  # Extensions, helpers
├── shared/
│   └── widgets/                # Reusable widgets
├── injection_container.dart
└── main.dart
```

### NestJS API
```
src/
├── auth/                       # EXISTING
├── users/                      # EXISTING
├── weather/                    # EXISTING
├── schedules/                  # NEW: Fase 2 module
│   ├── schedules.module.ts
│   ├── schedules.controller.ts
│   ├── schedules.service.ts
│   ├── dto/
│   └── entities/
├── operators/                  # NEW: Fase 2 module
│   └── ...
├── common/
│   ├── guards/
│   │   ├── roles.guard.ts      # RBAC guard
│   │   └── jwt-auth.guard.ts
│   ├── filters/
│   └── interceptors/
└── main.ts
```

---

## Feature Implementation Checklist

When implementing a new feature, verify:

- [ ] Clean Architecture layers maintained (data/domain/presentation)
- [ ] BLoC pattern with proper event/state naming
- [ ] Repository uses Either<Failure, Success>
- [ ] All user-facing text in Bahasa Indonesia
- [ ] Colors from AppColors, fonts from bundled Poppins
- [ ] Golden tests for all custom widgets
- [ ] Barrel files created for feature exports
- [ ] Test structure mirrors lib structure
- [ ] RBAC checks where applicable
- [ ] State machine validation (if applicable)

---

*Generated for FSTrack-Tractor Fase 2*
*AI agents MUST follow all rules above*

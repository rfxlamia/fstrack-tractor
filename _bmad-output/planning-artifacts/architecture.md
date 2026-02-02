---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7]
inputDocuments:
  - project-context.md
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/ux-design-specification.md
  - docs/planning-phase/architecture.md
  - docs/planning-phase/phase2.md
workflowType: 'architecture'
project_name: 'fstrack-tractor'
user_name: 'V'
date: '2026-01-30'
---

# Architecture Decision Document - Fase 2

**PRODUCTION SCHEMA UPDATE (2026-01-31):**
This document has been updated to reflect actual production database schema discovered in Story 1.1.
Key changes: `operator_id` is INTEGER, `location_id` is VARCHAR(32), `unit_id` is VARCHAR(16), status values are OPEN/CLOSED/CANCEL.
See `/home/v/work/fstrack-tractor/docs/schema-reference.md` for complete production schema.

_Dokumen ini dibangun secara kolaboratif melalui step-by-step discovery. Bagian-bagian ditambahkan saat kita bekerja melalui setiap keputusan arsitektur bersama._

---

## ✅ Step 1: Initialization Complete

**Status:** Dokumen architecture untuk Fase 2 telah diinisialisasi.

**Dokumen Input yang Diload:**
1. ✅ `project-context.md` - Aturan dan patterns untuk AI agents
2. ✅ `_bmad-output/planning-artifacts/prd.md` - PRD Fase 2 (Work Plan Management)
3. ✅ `_bmad-output/planning-artifacts/ux-design-specification.md` - UX Design Fase 2
4. ✅ `docs/planning-phase/architecture.md` - Architecture Fase 1 (referensi)
5. ✅ `docs/planning-phase/phase2.md` - Phase 2 draft requirements

**Konteks Proyek:**
- **Proyek:** FSTrack-Tractor Fase 2
- **Scope:** Work Plan Management (CREATE → ASSIGN → VIEW)
- **Tipe:** Brownfield extension dari Fase 1
- **Tech Stack:** Flutter (Android) + NestJS + PostgreSQL

---

---

## ✅ Step 2: Project Context Analysis

### Requirements Overview

**Functional Requirements:**

PRD Fase 2 mendefinisikan **30 Functional Requirements** yang diorganisasi dalam 3 kategori:

| Kategori | Count | FRs | Architectural Focus |
|----------|-------|-----|---------------------|
| **Work Plan Management** | 20 | FR-F2-1 to FR-F2-20 | Core business logic, state transitions |
| **User Management** | 5 | FR-F2-21 to FR-F2-25 | RBAC, authentication, testing setup |
| **Data Consistency** | 5 | FR-F2-26 to FR-F2-30 | Transaction integrity, audit logging |

**Key Functional Requirements:**
- **FR-F2-1 to FR-F2-6:** CREATE work plan (Kasie PG only) - Form validation, auto-fill tanggal, status default OPEN
- **FR-F2-7 to FR-F2-10:** ASSIGN work plan (Kasie FE only) - Operator selection, status transition OPEN→CLOSED
- **FR-F2-11 to FR-F2-20:** VIEW work plans (All roles) - Role-based filtering, detail view
- **FR-F2-21 to FR-F2-25:** User dummy setup - 6 users (1 per role) untuk real live testing

**Non-Functional Requirements:**

**27 NFRs** yang akan drive architectural decisions:

| Kategori | Count | Key Highlights |
|----------|-------|----------------|
| **Performance** | 5 | < 2s CREATE/ASSIGN, < 1s VIEW operations |
| **Security** | 4 | JWT validation, RBAC enforcement, 401/403 handling |
| **Reliability** | 3 | ACID transactions, graceful error handling |
| **Data Consistency** | 3 | State machine validation, FK constraints |
| **Integration** | 3 | Production DB connection, schema validation |
| **Scalability** | 2 | 6 concurrent users (MVP), 1000 work plans query |
| **Testing Automation** | 2 | 100% RBAC coverage, 80% DB integration test |
| **User Experience** | 3 | Bahasa Indonesia error messages, loading indicators |
| **Database Performance** | 2 | Index optimization, connection pool (max 10) |

**Scale & Complexity:**

| Indikator | Assessment |
|-----------|------------|
| **Primary Domain** | Mobile App (Flutter Android) + REST API (NestJS) |
| **Complexity Level** | Medium - Standard patterns dengan beberapa custom components |
| **Estimated Components** | 15-20 arsitektur components |
| **Real-time Features** | Status transitions (not real-time sync) |
| **Multi-tenancy** | Single-tenant (estate_id in schema untuk future) |
| **Integration Points** | Production PostgreSQL (existing schema) |

### Technical Constraints & Dependencies

**Tech Stack (Inherited dari Fase 1):**
- **Frontend:** Flutter dengan BLoC state management
- **Backend:** NestJS dengan modular architecture
- **Database:** PostgreSQL dengan schema schedules/operators/units
- **Auth:** JWT + bcrypt (existing)
- **Local Storage:** Hive + flutter_secure_storage

**Database Schema Constraints:**
- Tabel `schedules` sudah ada di production
- Foreign keys: `location_id` (VARCHAR(32)), `unit_id` (VARCHAR(16)), `operator_id` (INTEGER)
- Status values (production): OPEN, CLOSED, CANCEL
- Additional columns: start_time, end_time, report_id
- Tidak boleh mengubah schema existing

**Brownfield Constraints:**
- Harus mengikuti Clean Architecture pattern dari Fase 1
- BLoC state management (tidak boleh ganti pattern)
- Design system yang sudah established (Bulldozer alignment)
- project-context.md adalah single source of truth untuk AI agents

### UX Design Implications

**Dari UX Design Specification Fase 2:**

**Component Complexity:**
- **WorkPlanCard** - Extended dari TaskCard dengan status indicators
- **CreateBottomSheet** - Form dengan 4 field (tanggal, pola, shift, lokasi)
- **AssignBottomSheet** - Dropdown operator selection
- **StatusBadge** - Color-coded (Orange=OPEN, Blue=CLOSED, Red=CANCEL)

**Animation/Transition Requirements:**
- Bottom sheet slide-up (250ms)
- Status badge color transition
- Skeleton loading shimmer (V's signature)
- Toast messages untuk feedback

**Performance Expectations:**
- Time to clarity: < 3 detik dari login ke task visible
- Taps to CREATE: 4 taps
- Taps to ASSIGN: 3 taps
- Loading indicators untuk operations > 500ms

**Offline Capability:**
- Online-only untuk Fase 2 (documented limitation)
- Explicit offline banner dengan retry action
- JWT cache 14 hari untuk offline resilience

### Cross-Cutting Concerns Identified

**1. Authentication & Authorization (RBAC)**
- JWT token management dengan 14 hari expiry + 24 jam grace period
- Role extraction dari JWT payload
- 5 roles: kasie_pg, kasie_fe, operator, mandor, admin
- Permission matrix enforcement di semua layers

**2. State Management**
- **Auth State:** JWT token, user profile, role
- **Work Plan State:** OPEN → CLOSED → CANCEL (production values)
- **UI State:** Role-based visibility, bottom sheet state
- State transitions harus validated dan atomic

**3. Error Handling**
- Graceful degradation untuk network failures
- User-friendly messages dalam Bahasa Indonesia
- Structured logging untuk debugging
- Either<Failure, Success> pattern

**4. Database Integration**
- Production Bulldozer DB connection via TypeORM
- Schema validation on startup
- FK constraints enforcement
- Audit logging untuk status changes

**5. Testing Strategy**
- 100% RBAC test coverage (5 roles × 4 endpoints)
- Golden tests untuk custom widgets
- Integration tests untuk DB operations
- User dummy untuk real live testing

---

---

## ✅ Step 3: Starter Template Evaluation

### Primary Technology Domain

**Mobile App (Flutter Android) + REST API (NestJS)** - Dual Stack Brownfield Extension

Proyek Fase 2 adalah **brownfield extension** dari Fase 1, dimana tech stack dan project structure sudah established. Kita memperluas arsitektur yang sudah ada, bukan memilih starter baru.

### Existing Architecture (Fase 1 Foundation)

**Flutter App:**

```bash
# Original initialization (Fase 1)
flutter create --org com.fstrack --project-name fstrack_tractor fstrack_tractor_app
```

**Key Decisions Already Established:**

| Category | Decision | Package/Tool |
|----------|----------|--------------|
| **Language** | Dart 3.x | null safety enabled |
| **Architecture** | Clean Architecture | mandatory data/domain/presentation layers |
| **State Management** | BLoC pattern | flutter_bloc |
| **DI** | get_it + injectable | code generation via build_runner |
| **Navigation** | go_router | declarative routing dengan AuthBloc integration |
| **Local Storage** | Hive + flutter_secure_storage | encrypted boxes untuk JWT |
| **Networking** | Dio | dengan interceptors untuk auth dan logging |
| **Testing** | bloc_test, mocktail, golden_toolkit | comprehensive testing setup |
| **UI** | Material Design 3 | dengan custom theme (Bulldozer alignment) |

**NestJS API:**

```bash
# Original initialization (Fase 1)
nest new fstrack-tractor-api
```

**Key Decisions Already Established:**

| Category | Decision | Package/Tool |
|----------|----------|--------------|
| **Language** | TypeScript 5.x | strict mode enabled |
| **Architecture** | Modular | feature-based modules |
| **Database** | TypeORM | dengan PostgreSQL |
| **Auth** | JWT + Passport | bcrypt untuk password hashing |
| **Validation** | class-validator | DTO validation |
| **Testing** | Jest | dengan fake-timers untuk JWT expiry |
| **Documentation** | Swagger | @nestjs/swagger |

### Approach: Continue Existing Architecture

**Rationale:**

1. **Brownfield Consistency** - Fase 2 harus mengikuti pola yang sama dengan Fase 1 untuk maintainability
2. **No New Starters** - Project sudah diinisialisasi, kita memperluas bukan membuat baru
3. **Established Patterns** - Clean Architecture + BLoC sudah terbukti di Fase 1
4. **Team Familiarity** - Developer sudah familiar dengan codebase Fase 1
5. **Design System Alignment** - Bulldozer colors, Poppins font, spacing tokens sudah established

### Fase 2 Extension Components

**Flutter - New Feature Module:**

```
lib/features/work_plan/
├── data/
│   ├── datasources/
│   │   ├── work_plan_remote_datasource.dart
│   │   └── work_plan_local_datasource.dart
│   ├── models/
│   │   ├── work_plan_model.dart
│   │   └── operator_model.dart
│   └── repositories/
│       └── work_plan_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── work_plan_entity.dart
│   │   └── operator_entity.dart
│   ├── repositories/
│   │   └── work_plan_repository.dart
│   └── usecases/
│       ├── create_work_plan_usecase.dart
│       ├── assign_operator_usecase.dart
│       ├── get_work_plans_usecase.dart
│       └── get_operators_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── work_plan_bloc.dart
    │   ├── work_plan_event.dart
    │   └── work_plan_state.dart
    ├── pages/
    │   └── work_plan_list_page.dart
    └── widgets/
        ├── work_plan_card.dart
        ├── create_bottom_sheet.dart
        ├── assign_bottom_sheet.dart
        └── status_badge.dart
```

**NestJS - New Modules:**

```
src/
├── schedules/
│   ├── schedules.module.ts
│   ├── schedules.controller.ts
│   ├── schedules.service.ts
│   ├── dto/
│   │   ├── create-schedule.dto.ts
│   │   ├── assign-operator.dto.ts
│   │   └── schedule-response.dto.ts
│   └── entities/
│       └── schedule.entity.ts
├── operators/
│   ├── operators.module.ts
│   ├── operators.controller.ts
│   ├── operators.service.ts
│   └── dto/
│       └── operator-response.dto.ts
└── auth/
    └── guards/
        ├── roles.guard.ts          # NEW: RBAC for CREATE/ASSIGN
        └── kasie-pg.guard.ts       # NEW: Specific guard untuk CREATE
```

### Architectural Decisions Summary

**Flutter Extensions:**
- Feature-based module structure (sama dengan auth, home, weather)
- BLoC state management untuk WorkPlan feature
- Repository pattern dengan Either<Failure, Success>
- Golden tests untuk WorkPlanCard, StatusBadge
- Test fixtures untuk work plan states

**NestJS Extensions:**
- Modular architecture dengan SchedulesModule dan OperatorsModule
- DTO validation menggunakan class-validator
- RBAC Guards untuk permission enforcement
- TypeORM entities yang mengikuti existing schema

---

---

## ✅ Step 4: Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**

| # | Decision | Approach | Status |
|---|----------|----------|--------|
| 1 | State Machine Validation | Hybrid (Service + DB) | ✅ Decided |
| 2 | RBAC Implementation | Role-Based | ✅ Decided |
| 3 | API Endpoint Design | Resource-Focused REST | ✅ Decided |

**Validation Status:** All decisions validated via Party Mode (Winston, Murat, Amelia, John)

### Data Architecture

#### State Machine Validation Strategy

**Decision:** Hybrid Approach (Service Layer + Database Constraints)

**Rationale:**
- Service layer memberikan fleksibilitas untuk business rules kompleks dan clear error messages
- DB constraint sebagai safety net mencegah invalid states meski ada bypass API
- Double protection untuk data integrity

**Implementation:**

```typescript
// Service Layer (NestJS)
// schedules.service.ts
async updateStatus(id: string, newStatus: string) {
  const validTransitions = {
    'OPEN': ['CLOSED', 'CANCEL'],
    'CLOSED': [],  // Terminal state
    'CANCEL': []   // Terminal state
  };

  const current = await this.findById(id);
  if (!validTransitions[current.status]?.includes(newStatus)) {
    throw new BadRequestException('Transisi status tidak valid');
  }
  // ... update logic
}
```

```sql
-- Database Layer (PostgreSQL)
-- CHECK constraint sebagai safety net
ALTER TABLE schedules ADD CONSTRAINT valid_status
  CHECK (status IN ('OPEN', 'CLOSED', 'CANCEL'));
```

**Status Values (Production):**
- `OPEN` - Work plan baru dibuat (default)
- `CLOSED` - Work plan ditutup (completed or assigned)
- `CANCEL` - Work plan dibatalkan

**Party Mode Validation:**
- ✅ Winston: Pragmatic, flexible untuk future rules
- ✅ Murat: Test both layers, watch for skew
- ✅ Amelia: Clear implementation path
- ⚠️ John: Ensure error message consistency

### Authentication & Security

#### RBAC Implementation Strategy

**Decision:** Role-Based Access Control (simpler, sufficient for Fase 2)

**Rationale:**
- 6 role dengan permission yang clear-cut
- Pragmatic untuk MVP Fase 2
- Permission-based overkill untuk requirement saat ini

**Permission Matrix:**

| Operation | Kasie PG | Kasie FE | Operator | Mandor/Estate PG/Admin |
|-----------|----------|----------|----------|------------------------|
| CREATE | ✅ | ❌ | ❌ | ❌ |
| ASSIGN | ❌ | ✅ | ❌ | ❌ |
| VIEW | ✅ (all) | ✅ (all) | ✅ (assigned only) | ✅ (all) |

**Implementation:**

```typescript
// Backend (NestJS)
// roles.decorator.ts + roles.guard.ts
@Post('schedules')
@Roles('kasie_pg')  // Hanya Kasie PG bisa CREATE
async createSchedule(...) { }

@Patch('schedules/:id')
@Roles('kasie_fe')  // Hanya Kasie FE bisa ASSIGN
async assignOperator(...) { }
```

```dart
// Frontend (Flutter)
// Role-based widget visibility
if (user.role == UserRole.kasiePg) {
  FloatingActionButton(...);  // CREATE button
}

if (user.role == UserRole.kasieFe && workPlan.status == 'OPEN') {
  AssignBottomSheet(...);  // ASSIGN form
}
```

**Party Mode Validation:**
- ✅ Winston: Reusable base guard recommended
- ✅ Murat: 18 test cases (5 roles × 3 ops), manageable
- ✅ Amelia: Consistent dengan existing auth patterns
- ✅ John: Supports all user journeys

### API & Communication Patterns

#### API Endpoint Design

**Decision:** Resource-Focused REST API (RESTful convention)

**Rationale:**
- Standard REST convention, predictable
- Developer-friendly, maintainable
- HTTP methods + role guards sufficient untuk express intent

**Endpoints:**

| Method | Endpoint | Auth | Role | Description |
|--------|----------|------|------|-------------|
| GET | /api/v1/schedules | JWT | All | List work plans (filtered by role) |
| POST | /api/v1/schedules | JWT | kasie_pg | CREATE work plan |
| GET | /api/v1/schedules/:id | JWT | All | Get work plan detail |
| PATCH | /api/v1/schedules/:id | JWT | kasie_fe | ASSIGN operator (update operator_id) |
| GET | /api/v1/operators | JWT | kasie_fe | List available operators |

**Request/Response Format:**

```typescript
// POST /api/v1/schedules (CREATE)
// Request
{
  "work_date": "2026-01-30",
  "pattern": "Rotasi",
  "shift": "Pagi",
  "location_id": "LOC001",  // VARCHAR(32)
  "unit_id": "UNIT01"       // VARCHAR(16)
}

// Response 201
{
  "statusCode": 201,
  "message": "Rencana kerja berhasil dibuat!",
  "data": {
    "id": "uuid",
    "status": "OPEN",
    ...
  }
}
```

```typescript
// PATCH /api/v1/schedules/:id (ASSIGN)
// Request
{
  "operator_id": 123  // INTEGER not UUID
}

// Response 200
{
  "statusCode": 200,
  "message": "Operator berhasil ditugaskan!",
  "data": {
    "id": "uuid",
    "status": "CLOSED",
    "operator_id": 123,
    ...
  }
}
```

**Party Mode Validation:**
- ✅ Winston: RESTful, predictable
- ✅ Murat: Easier contract tests
- ✅ Amelia: Consistent dengan Fase 1 endpoints
- ✅ John: Supports CREATE → ASSIGN → VIEW flow

### Error Handling Standards

**HTTP Status Codes:**

| Code | Usage |
|------|-------|
| 200 | Success |
| 201 | Resource created |
| 400 | Bad Request - Invalid data |
| 401 | Unauthorized - Invalid/missing token |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource not found |
| 422 | Unprocessable Entity - Validation error |

**Error Messages (Bahasa Indonesia):**

| Scenario | Message |
|----------|---------|
| CREATE success | "Rencana kerja berhasil dibuat!" |
| ASSIGN success | "Operator berhasil ditugaskan!" |
| Validation error | "Semua field wajib diisi" |
| Unauthorized | "Anda tidak memiliki akses untuk operasi ini" |
| Invalid transition | "Transisi status tidak valid" |

### Decision Impact Analysis

**Implementation Sequence:**

1. Backend: SchedulesModule dengan state validation
2. Backend: RBAC Guards (Roles decorator)
3. Frontend: WorkPlanFeature module structure
4. Frontend: Role-based widget visibility
5. Integration: API client dengan error handling
6. Testing: RBAC matrix (18 test cases)

**Cross-Component Dependencies:**

```
AuthBloc (user role)
  → WorkPlanBloc (filtering logic)
    → WorkPlanRepository
      → API endpoints (RBAC guards)
        → Service (state validation)
          → DB (constraints)
```

**Risk Mitigation:**

| Risk | Mitigation |
|------|------------|
| Service/DB validation skew | Integration tests untuk invalid transitions |
| Query performance (Operator filter) | Index pada operator_id, work_date |
| Error message inconsistency | Centralized error messages (Bahasa Indonesia) |

---

---

## ✅ Step 5: Implementation Patterns & Consistency Rules

### Pattern Categories Defined

**Critical Conflict Points Identified:** 12 areas where AI agents could make different choices - all standardized to maintain Fase 1 consistency.

### Naming Patterns

**Database Naming Conventions (PostgreSQL):**

| Element | Convention | Example | Anti-Pattern |
|---------|------------|---------|--------------|
| **Tables** | snake_case, plural | `schedules`, `operators`, `users` | ❌ `Schedules`, `schedule` |
| **Columns** | snake_case | `operator_id`, `created_at`, `work_date` | ❌ `operatorId`, `createdAt` |
| **Foreign Keys** | `{referenced_table}_id` | `operator_id`, `location_id`, `unit_id` | ❌ `operatorId`, `fk_operator` |
| **Indexes** | `idx_{table}_{column}` | `idx_schedules_operator_id` | ❌ `schedules_operator_id_idx` |
| **Constraints** | `{type}_{table}_{column}` | `pk_schedules`, `uq_users_username` | ❌ `schedules_pk` |

**API Naming Conventions (NestJS REST):**

| Element | Convention | Example | Anti-Pattern |
|---------|------------|---------|--------------|
| **Endpoints** | kebab-case, plural | `/api/v1/schedules`, `/api/v1/operators` | ❌ `/schedule`, `/api/v1/Schedule` |
| **Route params** | camelCase dengan `:` | `:id`, `:scheduleId` | ❌ `:schedule_id` |
| **Query params** | camelCase | `?page=1&limit=10` | ❌ `?page_num=1` |
| **Response fields** | camelCase | `{ "scheduleId": "uuid", "createdAt": "..." }` | ❌ `{ "schedule_id": "..." }` |

**Code Naming Conventions (Flutter/Dart):**

| Type | Convention | Example | Anti-Pattern |
|------|------------|---------|--------------|
| **Files** | snake_case | `work_plan_bloc.dart`, `schedule_model.dart` | ❌ `WorkPlanBloc.dart` |
| **Classes** | PascalCase | `WorkPlanBloc`, `ScheduleModel` | ❌ `workPlanBloc` |
| **Variables** | camelCase | `workPlanList`, `isLoading` | ❌ `work_plan_list` |
| **Constants** | camelCase | `apiBaseUrl`, `defaultTimeout` | ❌ `API_BASE_URL` |
| **Private members** | `_prefix` | `_repository`, `_authBloc` | ❌ `privateRepository` |
| **BLoC Events** | PascalCase + verb | `CreateWorkPlanRequested`, `AssignOperatorPressed` | ❌ `createWorkPlan` |
| **BLoC States** | PascalCase | `WorkPlanLoading`, `WorkPlanLoaded` | ❌ `workPlanLoading` |

**Code Naming Conventions (NestJS/TypeScript):**

| Type | Convention | Example | Anti-Pattern |
|------|------------|---------|--------------|
| **Files** | kebab-case | `schedules.service.ts`, `roles.guard.ts` | ❌ `schedulesService.ts` |
| **Classes** | PascalCase | `SchedulesService`, `RolesGuard` | ❌ `schedulesService` |
| **Variables** | camelCase | `scheduleRepository`, `isValid` | ❌ `schedule_repository` |
| **Constants** | UPPER_SNAKE | `JWT_SECRET`, `DEFAULT_PAGE_SIZE` | ❌ `jwtSecret` |
| **DTOs** | PascalCase + Dto | `CreateScheduleDto`, `AssignOperatorDto` | ❌ `CreateSchedule` |

### Structure Patterns

**Project Organization (Flutter):**

```
lib/
├── features/
│   └── work_plan/                    # Feature-based organization
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
├── core/                             # Shared core
│   ├── config/
│   ├── error/
│   ├── network/
│   └── utils/
└── shared/                           # Shared widgets
    └── widgets/
```

**Project Organization (NestJS):**

```
src/
├── schedules/                        # Feature module
│   ├── schedules.module.ts
│   ├── schedules.controller.ts
│   ├── schedules.service.ts
│   ├── dto/
│   └── entities/
├── operators/
│   └── ...
├── auth/
│   └── guards/
│       ├── roles.guard.ts
│       └── jwt-auth.guard.ts
└── common/                           # Shared utilities
    ├── filters/
    ├── interceptors/
    └── pipes/
```

**Test File Location:**

| Stack | Convention | Example |
|-------|------------|---------|
| **Flutter** | `/test/` mirroring `/lib/` | `test/features/work_plan/bloc/work_plan_bloc_test.dart` |
| **NestJS** | Co-located `*.spec.ts` | `src/schedules/schedules.service.spec.ts` |

### Format Patterns

**API Response Format (NestJS):**

```typescript
// Success response
{
  "statusCode": 200,
  "message": "Rencana kerja berhasil dibuat!",
  "data": {
    "id": "uuid",
    "status": "OPEN",
    "workDate": "2026-01-30",
    ...
  }
}

// Error response
{
  "statusCode": 403,
  "message": "Anda tidak memiliki akses untuk operasi ini",
  "error": "Forbidden",
  "timestamp": "2026-01-30T08:30:00.000Z"
}
```

**Date/Time Formats:**

| Context | Format | Example |
|---------|--------|---------|
| **API (JSON)** | ISO 8601 | `"2026-01-30T08:30:00.000Z"` |
| **Database** | TIMESTAMPTZ | PostgreSQL native |
| **Display (Flutter)** | Indonesia locale | `"30 Januari 2026, 15:30 WIB"` |

**JSON Field Naming:**

| Layer | Convention | Example |
|-------|------------|---------|
| **API Request/Response** | camelCase | `{ "workDate": "...", "operatorId": "..." }` |
| **Database** | snake_case | `work_date`, `operator_id` |
| **Flutter Model** | camelCase (fromJson/toJson handles conversion) | `workDate`, `operatorId` |

### Communication Patterns

**BLoC Pattern (Flutter):**

```dart
// Event naming: {Action}{Object}{Verb}
abstract class WorkPlanEvent {}
class CreateWorkPlanRequested extends WorkPlanEvent { ... }
class AssignOperatorPressed extends WorkPlanEvent { ... }
class LoadWorkPlansRequested extends WorkPlanEvent { ... }

// State hierarchy
abstract class WorkPlanState extends Equatable {}
class WorkPlanInitial extends WorkPlanState {}
class WorkPlanLoading extends WorkPlanState {}
class WorkPlanLoaded extends WorkPlanState {
  final List<WorkPlan> workPlans;
}
class WorkPlanError extends WorkPlanState {
  final String message;
}
```

**State Update Pattern:**

```dart
// Emit new state instances (immutable)
emit(WorkPlanLoading());
final result = await repository.getWorkPlans();
result.fold(
  (failure) => emit(WorkPlanError(failure.message)),
  (workPlans) => emit(WorkPlanLoaded(workPlans)),
);
```

### Process Patterns

**Error Handling Pattern:**

```dart
// Repository returns Either<Failure, Success>
Future<Either<Failure, WorkPlan>> createWorkPlan(CreateWorkPlanParams params);

// BLoC folds to emit state
result.fold(
  (failure) => emit(WorkPlanError(failure.message)),
  (workPlan) => emit(WorkPlanCreated(workPlan)),
);

// Widget displays error
if (state is WorkPlanError) {
  showToast(state.message); // Already in Bahasa Indonesia
}
```

**Loading State Pattern:**

```dart
// Per-feature loading state, not global
class WorkPlanLoading extends WorkPlanState {}

// Skeleton loading untuk initial load
// Cached content untuk refresh
```

**Repository Method Naming:**

```dart
// STANDARD VERBS - Use consistently
abstract class WorkPlanRepository {
  Future<Either<Failure, WorkPlan>> getById(String id);
  Future<Either<Failure, List<WorkPlan>>> getAll();
  Future<Either<Failure, WorkPlan>> create(CreateWorkPlanParams params);
  Future<Either<Failure, WorkPlan>> update(String id, UpdateWorkPlanParams params);
  Future<Either<Failure, void>> delete(String id);
}

// ❌ AVOID: fetch, load, retrieve, find (use 'get' instead)
```

### Enforcement Guidelines

**All AI Agents MUST:**

1. **Follow naming conventions exactly** - Check table di atas sebelum membuat file/class/variable
2. **Maintain Clean Architecture layers** - data/domain/presentation, tidak boleh flatten
3. **Use Either<Failure, Success> pattern** - Never throw raw exceptions ke UI layer
4. **Write Bahasa Indonesia error messages** - User-facing text selalu dalam Bahasa Indonesia
5. **Create barrel files** - Setiap feature punya `feature_name.dart` untuk public exports
6. **Mirror test structure** - Flutter: `/test` mirrors `/lib`, NestJS: co-located `.spec.ts`

**Pattern Verification:**

- PR reviews check naming consistency
- Linter rules enforce import ordering
- Test coverage ensures Failure types handled
- project-context.md adalah single source of truth

### Pattern Examples

**Good Example - Feature Structure:**

```
lib/features/work_plan/
├── work_plan.dart                    # Barrel file ✅
├── data/
│   ├── datasources/
│   │   ├── work_plan_remote_datasource.dart  # snake_case ✅
│   │   └── work_plan_local_datasource.dart
│   ├── models/
│   │   └── work_plan_model.dart      # snake_case ✅
│   └── repositories/
│       └── work_plan_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── work_plan_entity.dart     # Entity (business logic) ✅
│   ├── repositories/
│   │   └── work_plan_repository.dart # Abstract interface ✅
│   └── usecases/
│       ├── create_work_plan_usecase.dart
│       └── get_work_plans_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── work_plan_bloc.dart
    │   ├── work_plan_event.dart
    │   └── work_plan_state.dart
    └── widgets/
        └── work_plan_card.dart
```

**Anti-Patterns to Avoid:**

```dart
// ❌ BAD: Inconsistent repository methods
fetchWorkPlan(), loadWorkPlansById(), getWorkPlanData(), retrieveCurrentWorkPlan()

// ✅ GOOD: Consistent 'get' verb
getById(), getAll(), create(), update(), delete()

// ❌ BAD: Raw exceptions to UI
throw Exception('Failed to create work plan');

// ✅ GOOD: Typed failures
return Left(ServerFailure('Gagal membuat rencana kerja'));

// ❌ BAD: English user-facing text
'Loading...'

// ✅ GOOD: Bahasa Indonesia
'Memuat data...'

// ❌ BAD: Flattened architecture
lib/work_plan/
  ├── work_plan_bloc.dart     # ❌ Mixed layers
  ├── work_plan_repository.dart
  └── work_plan_page.dart

// ✅ GOOD: Clean Architecture layers
lib/features/work_plan/
  ├── data/
  ├── domain/
  └── presentation/
```

---

## ✅ Step 6: Project Structure & Boundaries

> **CRITICAL:** Struktur berikut mengikuti existing codebase Fase 1 yang sudah ada di `/home/v/work/fstrack-tractor/fstrack-tractor-api` dan `/home/v/work/fstrack-tractor/fstrack_tractor_app`. Tidak ada file existing yang akan ditimpa.

### Existing Structure (Fase 1 - Verified from Actual Codebase)

**NestJS API (`fstrack-tractor-api/src/`):**
```
src/
├── auth/                           # EXISTING - JWT authentication
│   ├── guards/
│   │   ├── jwt-auth.guard.ts
│   │   ├── login-throttler.guard.ts
│   │   └── index.ts
│   ├── decorators/
│   │   ├── current-user.decorator.ts
│   │   └── index.ts
│   ├── dto/
│   │   ├── login.dto.ts
│   │   ├── auth-response.dto.ts
│   │   └── index.ts
│   ├── strategies/
│   │   └── jwt.strategy.ts
│   ├── auth.module.ts
│   ├── auth.service.ts
│   └── auth.controller.ts
├── users/                          # EXISTING - User management
│   ├── entities/
│   │   └── user.entity.ts
│   ├── dto/
│   │   ├── update-first-time.dto.ts
│   │   └── index.ts
│   ├── enums/
│   │   └── user-role.enum.ts
│   ├── users.module.ts
│   ├── users.service.ts
│   └── users.controller.ts
├── weather/                        # EXISTING - Weather service
│   ├── adapters/
│   │   ├── openweathermap.provider.ts
│   │   └── index.ts
│   ├── weather.module.ts
│   ├── weather.service.ts
│   └── weather.controller.ts
├── database/                       # EXISTING - TypeORM setup
│   ├── migrations/
│   └── database.module.ts
├── health/                         # EXISTING - Health checks
│   ├── health.module.ts
│   ├── health.controller.ts
│   └── health.service.ts
└── main.ts                         # EXISTING - App entry point
```

**Flutter App (`fstrack_tractor_app/lib/`):**
```
lib/
├── features/
│   ├── auth/                       # EXISTING - Authentication
│   │   ├── auth.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_datasource.dart
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   └── login_result.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   ├── services/
│   │   │   │   └── session_expiry_checker.dart
│   │   │   └── usecases/
│   │   │       ├── login_user_usecase.dart
│   │   │       ├── logout_user_usecase.dart
│   │   │       └── validate_token_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   ├── login_form.dart
│   │       │   └── password_field.dart
│   │       └── widgets/
│   │           └── session_warning_banner.dart
│   ├── home/                       # EXISTING - Home page
│   │   ├── home.dart
│   │   ├── data/
│   │   │   └── datasources/
│   │   │       └── first_time_local_data_source.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── first_time_hints_bloc.dart
│   │       │   ├── first_time_hints_event.dart
│   │       │   └── first_time_hints_state.dart
│   │       ├── pages/
│   │       │   └── home_page.dart
│   │       └── widgets/
│   │           ├── greeting_header.dart
│   │           ├── menu_card.dart
│   │           ├── menu_card_skeleton.dart
│   │           ├── role_based_menu_cards.dart
│   │           ├── clock_widget.dart
│   │           ├── first_time_hints_wrapper.dart
│   │           └── coming_soon_bottom_sheet.dart
│   ├── weather/                    # EXISTING - Weather widget
│   │   ├── weather.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── weather_remote_datasource.dart
│   │   │   │   └── weather_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── weather_model.dart
│   │   │   └── repositories/
│   │   │       └── weather_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── weather_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── weather_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_current_weather_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── weather_bloc.dart
│   │       │   ├── weather_event.dart
│   │       │   └── weather_state.dart
│   │       └── widgets/
│   │           ├── weather_widget.dart
│   │           ├── weather_widget_skeleton.dart
│   │           └── weather_icon_mapper.dart
│   └── onboarding/                 # EXISTING - Onboarding
│       └── presentation/
│           └── pages/
│               └── onboarding_page.dart
├── core/                           # EXISTING - Core utilities
│   └── location/
│       └── hardcoded_location_provider.dart
└── main.dart                       # EXISTING - App entry point
```

### Fase 2 Extensions (New Files Only - No Overwrites)

**NestJS API New Files:**
```
src/
├── auth/
│   └── guards/
│       └── roles.guard.ts           # NEW - RBAC enforcement
├── schedules/                       # NEW MODULE
│   ├── schedules.module.ts
│   ├── schedules.controller.ts
│   ├── schedules.service.ts
│   ├── dto/
│   │   ├── create-schedule.dto.ts
│   │   ├── assign-operator.dto.ts
│   │   ├── schedule-response.dto.ts
│   │   └── index.ts
│   └── entities/
│       └── schedule.entity.ts
└── operators/                       # NEW MODULE
    ├── operators.module.ts
    ├── operators.controller.ts
    ├── operators.service.ts
    ├── dto/
    │   ├── operator-response.dto.ts
    │   └── index.ts
    └── entities/
        └── operator.entity.ts

test/
├── fixtures/
│   ├── work-plan.fixtures.ts        # NEW
│   └── operator.fixtures.ts         # NEW
└── e2e/
    ├── schedules.e2e-spec.ts        # NEW
    └── operators.e2e-spec.ts        # NEW

scripts/
└── seed-dev-user.ts                 # MODIFY - Add 6 user dummy per role
```

**Flutter App New Files:**
```
lib/features/
└── work_plan/                       # NEW FEATURE
    ├── work_plan.dart               # Barrel file
    ├── data/
    │   ├── datasources/
    │   │   ├── work_plan_remote_datasource.dart
    │   │   └── work_plan_local_datasource.dart
    │   ├── models/
    │   │   ├── work_plan_model.dart
    │   │   └── operator_model.dart
    │   └── repositories/
    │       └── work_plan_repository_impl.dart
    ├── domain/
    │   ├── entities/
    │   │   ├── work_plan_entity.dart
    │   │   └── operator_entity.dart
    │   ├── repositories/
    │   │   └── work_plan_repository.dart
    │   └── usecases/
    │       ├── create_work_plan_usecase.dart
    │       ├── assign_operator_usecase.dart
    │       ├── get_work_plans_usecase.dart
    │       └── get_operators_usecase.dart
    └── presentation/
        ├── bloc/
        │   ├── work_plan_bloc.dart
        │   ├── work_plan_event.dart
        │   └── work_plan_state.dart
        ├── pages/
        │   └── work_plan_list_page.dart
        └── widgets/
            ├── work_plan_card.dart
            ├── create_bottom_sheet.dart
            ├── assign_bottom_sheet.dart
            └── status_badge.dart

test/
├── fixtures/
│   ├── work_plan_fixtures.dart      # NEW
│   └── operator_fixtures.dart       # NEW
└── features/
    └── work_plan/                   # NEW (mirror lib/features/work_plan/)
        ├── data/
        ├── domain/
        └── presentation/
```

### Architectural Boundaries

**API Boundaries:**

| Method | Endpoint | Layer Flow |
|--------|----------|------------|
| `GET` | `/api/v1/schedules` | Controller → Service → Repository → DB |
| `POST` | `/api/v1/schedules` | AuthGuard → RolesGuard → Service (validation) → DB |
| `PATCH` | `/api/v1/schedules/:id` | AuthGuard → RolesGuard → Service (state machine) → DB |
| `GET` | `/api/v1/operators` | AuthGuard → RolesGuard → Service → DB |

**Component Boundaries (Flutter):**

```
WorkPlanListPage
├── GreetingHeader              # EXISTING
├── WorkPlanList                # NEW
│   └── WorkPlanCard[]          # NEW
│       └── StatusBadge         # NEW
├── CreateBottomSheet           # NEW (Kasie PG only)
└── AssignBottomSheet           # NEW (Kasie FE only)
```

**Data Flow:**

```
User Tap "Simpan" (CREATE)
        ↓
CreateBottomSheet → WorkPlanBloc.add(CreateWorkPlanRequested)
        ↓
CreateWorkPlanUseCase → WorkPlanRepository.create()
        ↓
WorkPlanRemoteDataSource → POST /api/v1/schedules
        ↓
AuthGuard → RolesGuard (check kasie_pg)
        ↓
SchedulesService.create() → Validate input
        ↓
TypeORM Repository → INSERT INTO schedules
        ↓
Response 201 → WorkPlanBloc emits WorkPlanCreated
        ↓
Toast "Rencana kerja berhasil dibuat!"
```

### Requirements to Structure Mapping

| FR | Flutter File | NestJS File |
|----|--------------|-------------|
| FR-F2-1 (CREATE) | `create_bottom_sheet.dart` | `schedules.controller.ts` POST |
| FR-F2-8 (ASSIGN) | `assign_bottom_sheet.dart` | `schedules.controller.ts` PATCH |
| FR-F2-11 (VIEW) | `work_plan_list_page.dart` | `schedules.controller.ts` GET |
| FR-F2-21 (User dummy) | - | `scripts/seed-dev-user.ts` |
| NFR-F2-6 (RBAC) | Role checks in widgets | `roles.guard.ts` |

---

## ✅ Step 7: Architecture Validation & Completion

### Coherence Validation ✅

**Decision Compatibility:**
All architectural decisions work together seamlessly:

| Decision A | Decision B | Compatibility |
|------------|------------|---------------|
| **Hybrid State Validation** | **BLoC Pattern** | ✅ Service validation → BLoC emits state → UI feedback |
| **Role-Based RBAC** | **Clean Architecture** | ✅ Guards (data) → UseCases (domain) → BLoC (presentation) |
| **Resource-Focused API** | **Either<Failure, Success>** | ✅ REST endpoints return structured responses |
| **Existing Fase 1 Structure** | **Fase 2 Extensions** | ✅ New modules follow established patterns |

**Pattern Consistency:**
- **Naming Conventions:** snake_case (DB) ↔ camelCase (API/Flutter) - consistent dengan Fase 1
- **File Structure:** Feature-based modules dengan Clean Architecture layers
- **Error Handling:** Either pattern di semua layers
- **State Management:** BLoC pattern untuk semua features

**Structure Alignment:**
- Project structure supports all architectural decisions
- Integration points clearly specified (API endpoints, BLoC events)
- Component boundaries well-defined (widgets, guards, services)

### Requirements Coverage Validation ✅

**Functional Requirements Coverage:**

| FR Category | Count | Architectural Support |
|-------------|-------|----------------------|
| **Work Plan Management** | 20 FRs | ✅ SchedulesModule + WorkPlanFeature |
| **User Management** | 5 FRs | ✅ RBAC Guards + User dummy scripts |
| **Data Consistency** | 5 FRs | ✅ State machine + DB constraints |

**Non-Functional Requirements Coverage:**

| NFR Category | Key Requirements | Architectural Support |
|--------------|------------------|----------------------|
| **Performance** | < 2s response | ✅ Query optimization, indexing |
| **Security** | RBAC enforcement | ✅ Roles guard, JWT validation |
| **Reliability** | ACID transactions | ✅ TypeORM transactions |
| **Scalability** | 6 concurrent users | ✅ Connection pooling |
| **Testing** | 100% RBAC coverage | ✅ Testable architecture |

### Implementation Readiness Validation ✅

**Decision Completeness:** ✅ **HIGH**
- Semua critical decisions documented dengan rationale
- Technology versions compatible (NestJS, Flutter, TypeORM)
- Patterns comprehensive dengan concrete examples
- Consistency rules clear dan enforceable

**Structure Completeness:** ✅ **HIGH**
- Project structure specific (mengikuti existing Fase 1 codebase)
- Semua files dan directories defined
- Integration points clearly specified
- Boundaries well-defined

**Pattern Completeness:** ✅ **HIGH**
- All potential conflict points addressed
- Naming conventions comprehensive
- Communication patterns fully specified
- Process patterns complete

### Gap Analysis Results

| Priority | Finding | Status |
|----------|---------|--------|
| **Critical** | None identified | - |
| **P2** | Tooltip sequence untuk First-time UX | Deferred to implementation |
| **P3** | Performance monitoring hooks | Future enhancement |

### Architecture Completeness Checklist

**✅ Requirements Analysis**
- [x] Project context thoroughly analyzed
- [x] Scale and complexity assessed
- [x] Technical constraints identified
- [x] Cross-cutting concerns mapped

**✅ Architectural Decisions**
- [x] Critical decisions documented dengan versions
- [x] Technology stack fully specified
- [x] Integration patterns defined
- [x] Performance considerations addressed

**✅ Implementation Patterns**
- [x] Naming conventions established
- [x] Structure patterns defined
- [x] Communication patterns specified
- [x] Process patterns documented

**✅ Project Structure**
- [x] Complete directory structure defined
- [x] Component boundaries established
- [x] Integration points mapped
- [x] Requirements to structure mapping complete

### Architecture Readiness Assessment

**Overall Status:** ✅ **READY FOR IMPLEMENTATION**

**Confidence Level:** **HIGH**

**Key Strengths:**
1. **Brownfield Consistency** - Architecture extends Fase 1 dengan patterns yang sudah proven
2. **Clear Boundaries** - Component boundaries well-defined, prevents agent conflicts
3. **Comprehensive Patterns** - Naming, structure, dan communication patterns fully specified
4. **Requirements Coverage** - 100% FRs dan NFRs architecturally supported

**Areas for Future Enhancement:**
1. Performance monitoring hooks (post-MVP)
2. Advanced caching strategies (jika scale beyond 1000 work plans)

### Implementation Handoff

**AI Agent Guidelines:**

1. **Follow architectural decisions exactly** - State machine hybrid, RBAC role-based, REST API
2. **Use implementation patterns consistently** - Naming conventions, file structure, error handling
3. **Respect project structure** - New files follow existing Fase 1 patterns
4. **Refer to this document** - Architecture Decision Document adalah single source of truth

**First Implementation Priority:**

**Backend (NestJS):**
1. `src/auth/guards/roles.guard.ts` - RBAC foundation
2. `src/schedules/entities/schedule.entity.ts` - Database schema
3. `src/schedules/schedules.service.ts` - Business logic dengan state validation

**Frontend (Flutter):**
1. `lib/features/work_plan/domain/entities/work_plan_entity.dart` - Domain model
2. `lib/features/work_plan/data/repositories/work_plan_repository_impl.dart` - Data layer
3. `lib/features/work_plan/presentation/bloc/work_plan_bloc.dart` - State management

---

## ✅ Architecture Document Complete

**Status:** Architecture Decision Document untuk Fase 2 telah selesai dan siap untuk implementation.

**Document Location:** `_bmad-output/planning-artifacts/architecture.md`

**Next Step:** Proceed ke implementation phase dengan workflow `create-epics-and-stories` atau langsung `dev-story` jika sudah ada epics.


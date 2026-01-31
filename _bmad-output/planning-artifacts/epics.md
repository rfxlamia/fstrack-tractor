---
stepsCompleted: [1, 2, 3, 4]
inputDocuments:
  - /home/v/work/fstrack-tractor/_bmad-output/planning-artifacts/prd.md
  - /home/v/work/fstrack-tractor/_bmad-output/planning-artifacts/architecture.md
  - /home/v/work/fstrack-tractor/_bmad-output/planning-artifacts/ux-design-specification.md
  - /home/v/work/fstrack-tractor/project-context.md
---

# fstrack-tractor - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for fstrack-tractor Fase 2 (Work Plan Management), decomposing the requirements from the PRD, UX Design, and Architecture requirements into implementable stories.

**Scope:** CREATE → ASSIGN → VIEW work plan workflow
**Target Roles:** kasie_pg, kasie_fe, operator, mandor, estate_pg, admin

## Requirements Inventory

### Functional Requirements

**Work Plan Management (FR-F2-1 to FR-F2-20):**

| FR# | Requirement |
|-----|-------------|
| FR-F2-1 | User Kasie PG dapat CREATE work plan baru |
| FR-F2-2 | User Kasie PG dapat mengisi field: tanggal kerja, pola kerja, shift, lokasi, unit |
| FR-F2-3 | System auto-fill tanggal hari ini saat CREATE |
| FR-F2-4 | System validasi semua field required (kecuali catatan) |
| FR-F2-5 | System set status default: OPEN saat CREATE |
| FR-F2-6 | User Kasie PG dapat melihat work plan yang dibuat di list VIEW |
| FR-F2-7 | User Kasie FE dapat melihat work plan dengan status OPEN |
| FR-F2-8 | User Kasie FE dapat ASSIGN work plan OPEN ke operator |
| FR-F2-9 | User Kasie FE dapat memilih operator dari dropdown |
| FR-F2-10 | System update status: OPEN → ASSIGNED saat ASSIGN |
| FR-F2-11 | User Operator dapat melihat work plan yang di-assign ke dirinya |
| FR-F2-12 | User Operator dapat melihat detail work plan yang di-assign |
| FR-F2-13 | User semua role dapat melihat work plan list |
| FR-F2-14 | User Mandor/Estate PG/Admin hanya dapat VIEW (read-only) |
| FR-F2-15 | System filter work plan list berdasarkan role user |
| FR-F2-16 | System menampilkan status work plan dengan jelas |
| FR-F2-17 | User dapat melihat detail work plan lengkap |
| FR-F2-18 | System menampilkan toast message saat CREATE berhasil |
| FR-F2-19 | System menampilkan toast message saat ASSIGN berhasil |
| FR-F2-20 | System menampilkan error message yang jelas untuk gagal |

**User Management (FR-F2-21 to FR-F2-25):**

| FR# | Requirement |
|-----|-------------|
| FR-F2-21 | System memiliki user dummy untuk semua role (kasie_pg, kasie_fe, operator, mandor, estate_pg, admin) |
| FR-F2-22 | User dummy digunakan untuk real live testing |
| FR-F2-23 | User dummy memiliki password yang valid |
| FR-F2-24 | User dummy terdaftar di database |
| FR-F2-25 | User dummy dapat login dan mengakses fitur sesuai role |

**Data Consistency (FR-F2-26 to FR-F2-30):**

| FR# | Requirement |
|-----|-------------|
| FR-F2-26 | System menyimpan work plan ke tabel schedules |
| FR-F2-27 | System menjaga referential integrity (FK constraints) |
| FR-F2-28 | System update status work plan secara atomik |
| FR-F2-29 | System tidak mengizinkan status transition yang invalid |
| FR-F2-30 | System log semua perubahan status work plan |

### NonFunctional Requirements

**Performance (NFR-F2-1 to NFR-F2-5):**

| NFR# | Requirement | Target |
|------|-------------|--------|
| NFR-F2-1 | CREATE work plan response time | < 2 detik |
| NFR-F2-2 | ASSIGN work plan response time | < 2 detik |
| NFR-F2-3 | VIEW work plan list response time | < 1 detik |
| NFR-F2-4 | VIEW work plan detail response time | < 1 detik |
| NFR-F2-5 | UI responsiveness (tap feedback) | < 100ms |

**Security (NFR-F2-6 to NFR-F2-9):**

| NFR# | Requirement | Implementation |
|------|-------------|----------------|
| NFR-F2-6 | CREATE hanya untuk Kasie PG | Role-based permission |
| NFR-F2-7 | ASSIGN hanya untuk Kasie FE | Role-based permission |
| NFR-F2-8 | JWT validation untuk semua API | Existing from Fase 1 |
| NFR-F2-9 | Unauthorized access blocked | 401/403 response |

**Reliability & Availability (NFR-F2-10 to NFR-F2-12):**

| NFR# | Requirement | Target |
|------|-------------|--------|
| NFR-F2-10 | Database transaction integrity | ACID compliant |
| NFR-F2-11 | Graceful error handling | User-friendly messages |
| NFR-F2-12 | API retry mechanism | Max 3x |

**Data Consistency (NFR-F2-13 to NFR-F2-15):**

| NFR# | Requirement | Implementation |
|------|-------------|----------------|
| NFR-F2-13 | Status transitions valid | State machine validation |
| NFR-F2-14 | FK constraints enforced | Database schema |
| NFR-F2-15 | Audit log for changes | Log table |

**Integration (NFR-F2-16 to NFR-F2-18):**

| NFR# | Requirement | Validation |
|------|-------------|------------|
| NFR-F2-16 | Connection ke production Bulldozer DB | Integration test |
| NFR-F2-17 | Schema validation on startup | Manual test |
| NFR-F2-18 | Graceful DB error handling | Error simulation |

**Scalability (NFR-F2-19 to NFR-F2-20):**

| NFR# | Requirement | Target |
|------|-------------|--------|
| NFR-F2-19 | Support concurrent users | 6 users (MVP target) |
| NFR-F2-20 | Query performance dengan 1000 work plans | < 2s response |

**Testing Automation (NFR-F2-21 to NFR-F2-22):**

| NFR# | Requirement | Target |
|------|-------------|--------|
| NFR-F2-21 | RBAC test coverage | 100% (6 roles × 4 endpoints) |
| NFR-F2-22 | DB integration test coverage | 80% automation |

**User Experience (NFR-F2-23 to NFR-F2-25):**

| NFR# | Requirement | Implementation |
|------|-------------|----------------|
| NFR-F2-23 | User-friendly error messages | Bahasa Indonesia |
| NFR-F2-24 | Loading indicators | For operations > 500ms |
| NFR-F2-25 | Retry button | For transient errors |

**Database Performance (NFR-F2-26 to NFR-F2-27):**

| NFR# | Requirement | Implementation |
|------|-------------|----------------|
| NFR-F2-26 | Index optimization | operator_id, work_date, status |
| NFR-F2-27 | Connection pool configuration | Max 10 connections |

### Additional Requirements

**Architecture Requirements:**

- Clean Architecture pattern (data/domain/presentation layers) - MANDATORY
- BLoC state management untuk semua features
- Either<Failure, Success> error handling pattern
- Repository pattern dengan standard verbs (get, create, update, delete)
- Hybrid state machine validation (Service Layer + DB constraints)
- RBAC implementation dengan Roles Guard
- Resource-focused REST API design
- TypeORM entities mengikuti existing schema
- Brownfield extension - no overwrites of Fase 1 files

**UX Requirements:**

- Material Design 3 components (no custom modifications)
- Poppins font BUNDLED (NOT GoogleFonts)
- Skeleton loading (V's signature) bukan spinner
- Bottom sheet pattern untuk semua aksi (CREATE/ASSIGN/VIEW)
- Color-coded status badges:
  - OPEN: Orange (#FBA919)
  - ASSIGNED: Blue (#25AAE1)
  - COMPLETED: Green (#008945)
- Touch targets minimum 48dp, preferably 60dp
- Bahasa Indonesia untuk semua user-facing text
- Toast messages untuk success feedback
- Role-based widget visibility (FAB hanya Kasie PG)

**Technical Constraints:**

- Tabel schedules sudah ada di production (FK: location_id, unit_id, operator_id)
- Status enum: OPEN, ASSIGNED, IN_PROGRESS, COMPLETED
- Naming conventions: snake_case (DB), camelCase (API/Flutter), kebab-case (NestJS files)
- Online-only untuk Fase 2 (offline deferred to Fase 3+)
- Android portrait only
- Min screen 360dp width

### FR Coverage Map

| FR# | Epic | Story | Description |
|-----|------|-------|-------------|
| FR-F2-1 | Epic 2 | 2.2, 2.3 | User Kasie PG dapat CREATE work plan baru |
| FR-F2-2 | Epic 2 | 2.2 | User Kasie PG dapat mengisi field: tanggal, pola, shift, lokasi, unit |
| FR-F2-3 | Epic 2 | 2.2 | System auto-fill tanggal hari ini saat CREATE |
| FR-F2-4 | Epic 2 | 2.2 | System validasi semua field required |
| FR-F2-5 | Epic 1 | 1.2 | System set status default: OPEN saat CREATE |
| FR-F2-6 | Epic 2 | 2.4 | User Kasie PG dapat melihat work plan di list VIEW |
| FR-F2-7 | Epic 3 | 3.2 | User Kasie FE dapat melihat work plan status OPEN |
| FR-F2-8 | Epic 3 | 3.2, 3.3 | User Kasie FE dapat ASSIGN work plan ke operator |
| FR-F2-9 | Epic 3 | 3.1, 3.2 | User Kasie FE dapat memilih operator dari dropdown |
| FR-F2-10 | Epic 1, 3 | 1.5, 3.3 | System update status: OPEN → ASSIGNED |
| FR-F2-11 | Epic 4 | 4.1 | User Operator dapat melihat work plan assigned |
| FR-F2-12 | Epic 4 | 4.3 | User Operator dapat melihat detail work plan |
| FR-F2-13 | Epic 4 | 4.1, 4.4 | User semua role dapat melihat work plan list |
| FR-F2-14 | Epic 4 | 4.1 | User Mandor/Estate PG/Admin hanya VIEW |
| FR-F2-15 | Epic 4 | 4.1 | System filter work plan berdasarkan role |
| FR-F2-16 | Epic 4 | 4.2 | System menampilkan status dengan jelas |
| FR-F2-17 | Epic 4 | 4.3 | User dapat melihat detail work plan lengkap |
| FR-F2-18 | Epic 2 | 2.3 | System toast message saat CREATE berhasil |
| FR-F2-19 | Epic 3 | 3.3 | System toast message saat ASSIGN berhasil |
| FR-F2-20 | Epic 2 | 2.3 | System error message yang jelas untuk gagal |
| FR-F2-21 | Epic 1 | 1.6 | System memiliki user dummy untuk semua role |
| FR-F2-22 | Epic 1 | 1.6 | User dummy untuk real live testing |
| FR-F2-23 | Epic 1 | 1.6 | User dummy memiliki password valid |
| FR-F2-24 | Epic 1 | 1.6 | User dummy terdaftar di database |
| FR-F2-25 | Epic 1 | 1.6 | User dummy dapat login sesuai role |
| FR-F2-26 | Epic 1 | 1.1, 1.2 | System menyimpan work plan ke tabel schedules |
| FR-F2-27 | Epic 1 | 1.1, 1.2 | System menjaga referential integrity |
| FR-F2-28 | Epic 1 | 1.5 | System update status secara atomik |
| FR-F2-29 | Epic 1 | 1.5 | System tidak izinkan invalid status transition |
| FR-F2-30 | Epic 1 | 1.2 | System log semua perubahan status |

## Epic List

### Epic 1: Backend Foundation & RBAC System

Backend siap menerima dan memproses work plan requests dengan role-based access control yang benar.

**FRs covered:** FR-F2-21, FR-F2-22, FR-F2-23, FR-F2-24, FR-F2-25, FR-F2-26, FR-F2-27, FR-F2-28, FR-F2-29, FR-F2-30

**Implementation Notes:**
- SchedulesModule dan OperatorsModule di NestJS
- RolesGuard untuk RBAC enforcement
- User dummy seeding untuk testing
- State machine validation (Hybrid approach)
- Database entities dan migrations

**Standalone Value:** ✅ Backend dapat di-test secara independen via API (Postman/curl)

---

### Epic 2: Work Plan Creation (Kasie PG)

Kasie PG dapat membuat rencana kerja baru melalui mobile app dengan form yang user-friendly.

**FRs covered:** FR-F2-1, FR-F2-2, FR-F2-3, FR-F2-4, FR-F2-5, FR-F2-6, FR-F2-18, FR-F2-20

**Implementation Notes:**
- Flutter work_plan feature module (Clean Architecture)
- CreateBottomSheet widget dengan form validation
- WorkPlanBloc untuk state management
- FAB hanya visible untuk Kasie PG
- Toast messages dalam Bahasa Indonesia

**Standalone Value:** ✅ Kasie PG dapat CREATE dan VIEW work plans setelah epic ini selesai

---

### Epic 3: Work Plan Assignment (Kasie FE)

Kasie FE dapat menugaskan operator ke work plan yang berstatus OPEN.

**FRs covered:** FR-F2-7, FR-F2-8, FR-F2-9, FR-F2-10, FR-F2-19

**Implementation Notes:**
- AssignBottomSheet widget dengan operator dropdown
- GetOperatorsUseCase untuk fetch operator list
- Status transition OPEN → ASSIGNED
- Role-based visibility (ASSIGN section hanya untuk Kasie FE)

**Standalone Value:** ✅ Kasie FE dapat ASSIGN operators, building on Epic 2's CREATE capability

---

### Epic 4: Work Plan Viewing (All Roles)

Semua role dapat melihat work plans sesuai permission masing-masing dengan filtering yang tepat.

**FRs covered:** FR-F2-11, FR-F2-12, FR-F2-13, FR-F2-14, FR-F2-15, FR-F2-16, FR-F2-17

**Implementation Notes:**
- WorkPlanCard dengan StatusBadge (color-coded)
- Role-based filtering (Operator hanya lihat assigned-to-me)
- WorkPlanListPage dengan skeleton loading
- Detail bottom sheet untuk semua roles

**Standalone Value:** ✅ Complete view experience untuk semua 6 roles

---

## Epic Dependency Flow

```
Epic 1 (Backend Foundation)
    ↓
Epic 2 (CREATE) ──────────→ Epic 4 (VIEW)
    ↓                            ↑
Epic 3 (ASSIGN) ─────────────────┘
```

Setiap epic standalone dan enable epics berikutnya tanpa require future epics.

---

## Epic 1: Backend Foundation & RBAC System

Backend siap menerima dan memproses work plan requests dengan role-based access control yang benar.

### Story 1.1: Production Schema Discovery & Validation

As a **developer**,
I want **to inspect the production Bulldozer database schema**,
So that **entities and DTOs match the actual production structure**.

**Acceptance Criteria:**

**Given** access to production PostgreSQL database
**When** schema inspection is performed
**Then** the following tables are documented:
  - `schedules` - columns, types, constraints, FKs
  - `operators` - columns, types, constraints
  - `units` - columns, types, constraints
  - `locations` - columns, types, constraints
  - `users` - existing structure (from Fase 1)
**And** status enum values are confirmed: OPEN, ASSIGNED, IN_PROGRESS, COMPLETED
**And** FK relationships are mapped: schedules → operators, locations, units
**And** findings are documented in a schema reference file

**Given** schema inspection is complete
**When** TypeORM entities are created
**Then** entities exactly match production column names (snake_case)
**And** no migrations alter existing production tables
**And** only READ operations are performed during discovery (no writes)

**Technical Tasks:**
- Connect to production Bulldozer DB via psql
- Run `\d schedules`, `\d operators`, `\d units`, `\d locations`
- Document column types, nullable constraints, defaults
- Verify FK relationships
- Create schema reference doc for implementation

---

### Story 1.2: Schedule Entity & CRUD Endpoints

As a **developer**,
I want **the schedules module with CRUD endpoints**,
So that **work plans can be created, read, updated via REST API**.

**Acceptance Criteria:**

**Given** the NestJS backend is running
**When** a POST request is made to `/api/v1/schedules` with valid schedule data
**Then** a new schedule is created with status "OPEN" and saved to database
**And** the response returns 201 with the created schedule data

**Given** a schedule exists in database
**When** a GET request is made to `/api/v1/schedules/:id`
**Then** the schedule details are returned with 200 status

**Given** schedules exist in database
**When** a GET request is made to `/api/v1/schedules`
**Then** a list of schedules is returned with pagination support

**Technical Tasks:**
- Create `src/schedules/schedules.module.ts`
- Create `src/schedules/schedules.controller.ts` with GET, POST, PATCH endpoints
- Create `src/schedules/schedules.service.ts` with business logic
- Create `src/schedules/entities/schedule.entity.ts` matching production schema
- Create DTOs: `create-schedule.dto.ts`, `schedule-response.dto.ts`
- Add validation decorators using class-validator

---

### Story 1.3: Operators Module & List Endpoint

As a **developer**,
I want **the operators module with list endpoint**,
So that **Kasie FE can fetch available operators for assignment**.

**Acceptance Criteria:**

**Given** operators exist in database
**When** a GET request is made to `/api/v1/operators`
**Then** a list of active operators is returned
**And** each operator includes id, name, and availability status

**Technical Tasks:**
- Create `src/operators/operators.module.ts`
- Create `src/operators/operators.controller.ts` with GET endpoint
- Create `src/operators/operators.service.ts`
- Create `src/operators/entities/operator.entity.ts` matching production schema
- Create DTO: `operator-response.dto.ts`

---

### Story 1.4: RBAC Roles Guard Implementation

As a **system administrator**,
I want **role-based access control on endpoints**,
So that **only authorized roles can perform CREATE and ASSIGN operations**.

**Acceptance Criteria:**

**Given** a user with role "kasie_pg" is authenticated
**When** POST `/api/v1/schedules` is called
**Then** the request is allowed (201)

**Given** a user with role "operator" is authenticated
**When** POST `/api/v1/schedules` is called
**Then** the request is denied with 403 Forbidden
**And** message "Anda tidak memiliki akses untuk operasi ini"

**Given** a user with role "kasie_fe" is authenticated
**When** PATCH `/api/v1/schedules/:id` with operator_id is called
**Then** the request is allowed (200)

**Given** a user with role "kasie_pg" is authenticated
**When** PATCH `/api/v1/schedules/:id` with operator_id is called
**Then** the request is denied with 403 Forbidden

**Technical Tasks:**
- Create `src/auth/guards/roles.guard.ts`
- Create `src/auth/decorators/roles.decorator.ts`
- Apply @Roles('kasie_pg') to POST /schedules
- Apply @Roles('kasie_fe') to PATCH /schedules/:id (assign)
- Write unit tests for all 6 roles × 3 operations (18 test cases)

---

### Story 1.5: State Machine Validation

As a **developer**,
I want **state machine validation for schedule status transitions**,
So that **invalid status transitions are prevented**.

**Acceptance Criteria:**

**Given** a schedule with status "OPEN"
**When** PATCH is called to update status to "ASSIGNED" with operator_id
**Then** the transition is allowed and status updates

**Given** a schedule with status "OPEN"
**When** PATCH is called to update status to "COMPLETED" (skipping ASSIGNED)
**Then** the transition is denied with 400 Bad Request
**And** message "Transisi status tidak valid"

**Given** a schedule with status "ASSIGNED"
**When** PATCH is called to update status back to "OPEN"
**Then** the transition is denied (no backward transitions allowed)

**Technical Tasks:**
- Implement state machine in `schedules.service.ts`
- Define valid transitions: OPEN→ASSIGNED, ASSIGNED→IN_PROGRESS, IN_PROGRESS→COMPLETED
- Add CHECK constraint in database for status values
- Write unit tests for valid and invalid transitions

---

### Story 1.6: User Dummy Seeding

As a **QA tester**,
I want **dummy users for each role seeded in database**,
So that **real live testing can be performed for all roles**.

**Acceptance Criteria:**

**Given** the seed script is executed
**When** the database is checked
**Then** 6 users exist with roles: kasie_pg, kasie_fe, operator, mandor, estate_pg, admin
**And** each user has a valid hashed password
**And** each user can successfully login via `/api/v1/auth/login`

**Technical Tasks:**
- Update `scripts/seed-dev-user.ts` to add 6 role-specific users
- Use bcrypt for password hashing
- Usernames: suswanto.kasie_pg, siswanto.kasie_fe, budi.operator, citra.mandor, eko.estate_pg, admin
- Password: same pattern for testing (e.g., "Password123!")
- Verify login works for each user

---

## Epic 2: Work Plan Creation (Kasie PG)

Kasie PG dapat membuat rencana kerja baru melalui mobile app dengan form yang user-friendly.

### Story 2.1: Work Plan Feature Module Setup

As a **developer**,
I want **the work_plan feature module with Clean Architecture structure**,
So that **the foundation is ready for work plan functionality**.

**Acceptance Criteria:**

**Given** the Flutter project
**When** the work_plan feature is added
**Then** the folder structure follows Clean Architecture:
  - `lib/features/work_plan/data/` (datasources, models, repositories)
  - `lib/features/work_plan/domain/` (entities, repositories, usecases)
  - `lib/features/work_plan/presentation/` (bloc, pages, widgets)
**And** barrel file `work_plan.dart` exports public APIs
**And** DI registration is added to `injection_container.dart`

**Technical Tasks:**
- Create folder structure under `lib/features/work_plan/`
- Create `work_plan_entity.dart` in domain/entities
- Create `work_plan_repository.dart` (abstract) in domain/repositories
- Create `work_plan_model.dart` in data/models with fromJson/toJson
- Create `work_plan_remote_datasource.dart` in data/datasources
- Create `work_plan_repository_impl.dart` in data/repositories
- Create barrel files at each level
- Register in get_it DI container

---

### Story 2.2: Create Work Plan Form UI

As a **Kasie PG**,
I want **a form to create work plans via bottom sheet**,
So that **I can efficiently create daily work schedules**.

**Acceptance Criteria:**

**Given** Kasie PG is on home page
**When** FAB (+) is tapped
**Then** CreateBottomSheet appears with form fields:
  - Tanggal kerja (auto-filled with today, editable)
  - Pola kerja (dropdown)
  - Shift (dropdown)
  - Lokasi (dropdown)
  - Unit (dropdown)
**And** "Simpan" button (orange) and "Batal" button are visible

**Given** the create form is displayed
**When** a field is left empty and "Simpan" is tapped
**Then** inline validation error appears: "Field ini wajib diisi"

**Given** FAB is displayed
**When** user role is NOT kasie_pg
**Then** FAB is NOT visible

**Technical Tasks:**
- Create `create_bottom_sheet.dart` widget
- Implement date picker with today as default
- Create dropdowns for pola, shift, lokasi, unit
- Implement form validation with FormKey
- Style buttons with AppColors (orange for Simpan)
- Add role-based FAB visibility check using AuthBloc

---

### Story 2.3: Create Work Plan BLoC & Integration

As a **Kasie PG**,
I want **to submit the create form and see the result**,
So that **I know my work plan was created successfully**.

**Acceptance Criteria:**

**Given** all form fields are filled correctly
**When** "Simpan" is tapped
**Then** loading state is shown on button
**And** POST request is sent to `/api/v1/schedules`
**And** on success, toast appears: "Rencana kerja berhasil dibuat!"
**And** bottom sheet closes
**And** work plan list refreshes with new entry (status OPEN)

**Given** the API returns an error
**When** "Simpan" is tapped
**Then** error toast appears with message in Bahasa Indonesia
**And** form remains open for retry

**Technical Tasks:**
- Create `work_plan_bloc.dart`, `work_plan_event.dart`, `work_plan_state.dart`
- Implement `CreateWorkPlanRequested` event
- Create `CreateWorkPlanUseCase` in domain/usecases
- Implement Either<Failure, WorkPlan> return type
- Add toast messages using ScaffoldMessenger
- Implement list refresh after successful create

---

### Story 2.4: Work Plan List Display (Basic)

As a **Kasie PG**,
I want **to see the list of work plans I created**,
So that **I can track what has been scheduled**.

**Acceptance Criteria:**

**Given** work plans exist in database
**When** work plan list page loads
**Then** skeleton loading shimmer is shown first
**And** WorkPlanCard widgets display for each work plan
**And** each card shows: tanggal, pola, shift, lokasi, status badge
**And** OPEN status shows orange border and badge

**Technical Tasks:**
- Create `work_plan_list_page.dart` in presentation/pages
- Create `work_plan_card.dart` widget with status badge
- Implement skeleton loading shimmer (V's signature)
- Create `GetWorkPlansUseCase` in domain/usecases
- Implement `LoadWorkPlansRequested` event in BLoC
- Add navigation from home page to work plan list

---

## Epic 3: Work Plan Assignment (Kasie FE)

Kasie FE dapat menugaskan operator ke work plan yang berstatus OPEN.

### Story 3.1: Operator List Fetch & Cache

As a **developer**,
I want **to fetch and cache the operator list**,
So that **the assign dropdown loads quickly**.

**Acceptance Criteria:**

**Given** Kasie FE opens work plan detail
**When** operators are fetched
**Then** operators list is retrieved from `/api/v1/operators`
**And** list is cached locally for 5 minutes
**And** subsequent opens use cached data

**Technical Tasks:**
- Create `operator_entity.dart` in domain/entities
- Create `operator_model.dart` in data/models
- Create `GetOperatorsUseCase` in domain/usecases
- Implement local caching with Hive (5 min TTL)
- Add operator fetching to WorkPlanBloc or separate OperatorBloc

---

### Story 3.2: Assign Operator Bottom Sheet

As a **Kasie FE**,
I want **to assign an operator to a work plan**,
So that **the operator knows their assignment**.

**Acceptance Criteria:**

**Given** Kasie FE taps on a work plan card with status OPEN
**When** bottom sheet detail opens
**Then** work plan details are shown (read-only)
**And** operator dropdown is visible with available operators
**And** "Tugaskan Operator" button (blue) is visible

**Given** user role is NOT kasie_fe
**When** work plan detail bottom sheet opens
**Then** operator dropdown and assign button are NOT visible

**Technical Tasks:**
- Create `assign_bottom_sheet.dart` widget
- Display work plan details (read-only section)
- Create operator dropdown with fetched operators
- Style "Tugaskan Operator" button with AppColors.buttonBlue
- Add role-based visibility check for assign section

---

### Story 3.3: Assign Operator Submission

As a **Kasie FE**,
I want **to submit operator assignment**,
So that **the work plan status changes to ASSIGNED**.

**Acceptance Criteria:**

**Given** an operator is selected from dropdown
**When** "Tugaskan Operator" is tapped
**Then** loading state shows on button
**And** PATCH request is sent to `/api/v1/schedules/:id` with operator_id
**And** on success, toast appears: "Operator berhasil ditugaskan!"
**And** bottom sheet closes
**And** work plan card status badge changes from OPEN (orange) to ASSIGNED (blue)

**Given** assignment fails (e.g., operator already assigned elsewhere)
**When** API returns error
**Then** error toast shows with message in Bahasa Indonesia
**And** dropdown remains open for retry

**Technical Tasks:**
- Create `AssignOperatorUseCase` in domain/usecases
- Implement `AssignOperatorRequested` event in BLoC
- Handle PATCH /api/v1/schedules/:id API call
- Update local state after successful assignment
- Implement error handling with Bahasa Indonesia messages

---

## Epic 4: Work Plan Viewing (All Roles)

Semua role dapat melihat work plans sesuai permission masing-masing dengan filtering yang tepat.

### Story 4.1: Role-Based Work Plan Filtering

As an **operator**,
I want **to see only work plans assigned to me**,
So that **I know exactly what I need to do**.

**Acceptance Criteria:**

**Given** user is logged in as operator
**When** work plan list loads
**Then** only work plans where operator_id matches current user are shown

**Given** user is logged in as mandor, estate_pg, or admin
**When** work plan list loads
**Then** all work plans are visible (read-only)

**Given** user is logged in as kasie_pg
**When** work plan list loads
**Then** all work plans are visible

**Technical Tasks:**
- Update `GetWorkPlansUseCase` to accept role filter parameter
- Implement server-side filtering in backend (operator_id = current user)
- Add role check in Flutter to determine filter behavior
- Pass filter params in API request query string

---

### Story 4.2: Status Badge Component

As a **user**,
I want **clear visual status indicators**,
So that **I can quickly understand work plan status**.

**Acceptance Criteria:**

**Given** a work plan with status "OPEN"
**When** displayed in card
**Then** StatusBadge shows orange background (#FBA919) with white text "OPEN"
**And** card has 4dp orange left border

**Given** a work plan with status "ASSIGNED"
**When** displayed in card
**Then** StatusBadge shows blue background (#25AAE1) with white text "ASSIGNED"
**And** card has 4dp blue left border

**Given** a work plan with status "COMPLETED"
**When** displayed in card
**Then** StatusBadge shows green background (#008945) with white text "COMPLETED"
**And** card has 4dp green left border

**Technical Tasks:**
- Create `status_badge.dart` widget in presentation/widgets
- Implement color mapping: OPEN→orange, ASSIGNED→blue, COMPLETED→green
- Apply colored left border to WorkPlanCard
- Write golden tests for all status states

---

### Story 4.3: Work Plan Detail View

As a **user (any role)**,
I want **to view complete work plan details**,
So that **I have all information needed**.

**Acceptance Criteria:**

**Given** a work plan card is tapped
**When** detail bottom sheet opens
**Then** all details are displayed:
  - Tanggal kerja (formatted: "30 Januari 2026")
  - Pola kerja
  - Shift
  - Lokasi
  - Unit
  - Status (with colored badge)
  - Operator name (if assigned)
**And** detail view is read-only for non-action roles

**Technical Tasks:**
- Create `work_plan_detail_bottom_sheet.dart` widget
- Implement date formatting with Indonesia locale
- Display operator name when assigned
- Use StatusBadge component for status display
- Make entire view read-only (no action buttons) for non-Kasie roles

---

### Story 4.4: Work Plan List Page Integration

As a **user**,
I want **a polished work plan list experience**,
So that **the app feels professional and responsive**.

**Acceptance Criteria:**

**Given** user navigates to work plan list
**When** page loads
**Then** skeleton loading (shimmer) appears for 3-5 card placeholders
**And** real data replaces skeletons smoothly

**Given** no work plans exist
**When** list loads
**Then** empty state shows: "Belum ada rencana kerja"

**Given** pull-to-refresh gesture is performed
**When** list reloads
**Then** loading indicator appears
**And** data refreshes from API

**Technical Tasks:**
- Implement skeleton loading with shimmer effect
- Create empty state widget with illustration
- Implement RefreshIndicator for pull-to-refresh
- Add smooth transition from skeleton to real data
- Write golden tests for loading, empty, and loaded states

---

## Story Summary

| Epic | Stories | Description |
|------|---------|-------------|
| Epic 1 | 6 stories | Backend Foundation & RBAC System |
| Epic 2 | 4 stories | Work Plan Creation (Kasie PG) |
| Epic 3 | 3 stories | Work Plan Assignment (Kasie FE) |
| Epic 4 | 4 stories | Work Plan Viewing (All Roles) |
| **Total** | **17 stories** | Complete Fase 2 implementation |

---

## Definition of Done (Per Story)

Each story is complete when:
- [ ] All acceptance criteria pass
- [ ] Code follows project-context.md rules
- [ ] Unit tests written and passing
- [ ] Golden tests for UI components (if applicable)
- [ ] Code reviewed
- [ ] No flutter analyze warnings/errors
- [ ] Documentation updated if needed

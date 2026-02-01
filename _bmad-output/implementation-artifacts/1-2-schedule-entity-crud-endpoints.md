# Story 1.2: Schedule Entity & CRUD Endpoints

Status: review

<!-- REVIEW NOTES (Code Review - 2026-01-31):
✅ 8 HIGH issues fixed:
  - UUID validation added (ParseUUIDPipe)
  - Pagination limits enforced (max 100)
  - Fake test replaced with real float validation test
  - Module barrel file created
  - Swagger docs enhanced
  - Redundant null coalescing removed
  - Logging improved

⚠️ Technical Debt (MUST address before production):
  - RBAC: @Roles('kasie_pg') decorator commented out - awaiting RolesGuard setup
  - Dead code: validateStatus() methods exist but unused (awaiting UPDATE endpoint)
  - Integration tests: Only unit tests exist, no full request-response tests

✅ Status Decision: Keep as 'review' - code quality good but RBAC enforcement missing
-->

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **developer**,
I want **the schedules module with CRUD endpoints**,
So that **work plans can be created, read, updated via REST API**.

## Acceptance Criteria

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

## Tasks / Subtasks

> **Prerequisites:** Story 1.1 completed - Schedule entity and module structure already exist.

**✅ COMPLETED in Story 1.1:**
- Entity created: `src/schedules/entities/schedule.entity.ts`
- Module structure: `src/schedules/schedules.module.ts`
- Registered in `src/app.module.ts`

**NEW Work for Story 1.2:**
- [x] Task 1: Create SchedulesService (AC: #1, #2, #3)
  - [x] Create `src/schedules/schedules.service.ts`
  - [x] Implement `create()` with status='OPEN', INTEGER operatorId validation
  - [x] Implement `findAll()` with pagination
  - [x] Implement `findOne()` by UUID id
- [x] Task 2: Create SchedulesController (AC: #1, #2, #3)
  - [x] Create `src/schedules/schedules.controller.ts`
  - [x] POST /api/v1/schedules (201 response)
  - [x] GET /api/v1/schedules/:id (200 response)
  - [x] GET /api/v1/schedules (list with pagination)
- [x] Task 3: Create DTOs with validation (AC: #1)
  - [x] Create `src/schedules/dto/create-schedule.dto.ts`
  - [x] CreateScheduleDto: workDate, pattern, shift, locationId (VARCHAR), unitId (VARCHAR), notes
  - [x] Create `src/schedules/dto/schedule-response.dto.ts`
  - [x] ScheduleResponseDto: all fields with correct types (INTEGER operatorId, VARCHAR locationId/unitId)
  - [x] Create `src/schedules/dto/index.ts` barrel file
- [x] Task 4: Write unit tests (AC: all)
  - [x] Create `src/schedules/schedules.service.spec.ts`
  - [x] Service tests: create, findAll, findOne
  - [x] Type validation tests: INTEGER operatorId, VARCHAR locationId/unitId
  - [x] Status validation: only OPEN, CLOSED, CANCEL accepted
  - [x] Create `src/schedules/schedules.controller.spec.ts`
  - [x] Controller tests: status codes, response format

## Dev Notes

### Production Schema Reference

**IMPORTANT:** Based on Story 1.1 schema discovery, the actual production `schedules` table structure:

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| id | UUID | No | gen_random_uuid() | PK |
| work_date | DATE | No | - | Tanggal kerja |
| pattern | VARCHAR(16) | No | - | Pola kerja (e.g., "Rotasi") |
| shift | VARCHAR(16) | Yes | NULL | Shift (Pagi/Malam) |
| location_id | VARCHAR(32) | Yes | NULL | FK to locations (VARCHAR, NOT UUID) |
| unit_id | VARCHAR(16) | Yes | NULL | FK to units (VARCHAR, NOT UUID) |
| operator_id | INTEGER | Yes | NULL | FK to operators (INTEGER, NOT UUID) |
| status | VARCHAR(16) | No | 'OPEN' | OPEN, CLOSED, CANCEL |
| start_time | TIMESTAMPTZ | Yes | NULL | Work start timestamp |
| end_time | TIMESTAMPTZ | Yes | NULL | Work end timestamp |
| notes | TEXT | Yes | NULL | Catatan opsional |
| report_id | UUID | Yes | NULL | FK to reports (future) |
| created_at | TIMESTAMPTZ | No | now() | Audit |
| updated_at | TIMESTAMPTZ | No | now() | Audit |

**Critical Type Notes:**
- ⚠️ `operator_id` is **INTEGER** (not UUID) - matches operators.id auto-increment
- ⚠️ `location_id` is **VARCHAR(32)** (not UUID) - matches locations.id
- ⚠️ `unit_id` is **VARCHAR(16)** (not UUID) - matches units.id
- ⚠️ Status values: **OPEN, CLOSED, CANCEL** (NOT ASSIGNED/IN_PROGRESS/COMPLETED)

### Status Validation (Production Schema)

**Valid Status Values:**
```typescript
enum ScheduleStatus {
  OPEN = 'OPEN',      // Work plan created, awaiting operator assignment
  CLOSED = 'CLOSED',  // Work completed
  CANCEL = 'CANCEL',  // Work cancelled
}
```

**State Transitions:**
```typescript
// Service layer validation
const validTransitions = {
  'OPEN': ['CLOSED', 'CANCEL'],
  'CLOSED': [],  // Terminal state
  'CANCEL': []   // Terminal state
};
```

**⚠️ IMPORTANT:** Production schema uses simpler state model than initially architected. Do NOT use ASSIGNED or IN_PROGRESS status values.

### API Response Format

```typescript
// Success response (201 Created)
{
  "statusCode": 201,
  "message": "Rencana kerja berhasil dibuat!",
  "data": {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "workDate": "2026-01-30",
    "pattern": "Rotasi",
    "shift": "Pagi",
    "locationId": "LOC001",        // VARCHAR, NOT UUID
    "unitId": "UNIT01",            // VARCHAR, NOT UUID
    "operatorId": null,            // INTEGER (e.g., 123), NOT UUID
    "status": "OPEN",
    "startTime": null,
    "endTime": null,
    "notes": null,
    "reportId": null,
    "createdAt": "2026-01-30T08:30:00.000Z",
    "updatedAt": "2026-01-30T08:30:00.000Z"
  }
}
```

### Existing Entity (REUSE from Story 1.1)

**⚠️ CRITICAL:** Schedule entity already exists at `src/schedules/entities/schedule.entity.ts`

**DO NOT recreate this entity!** It already has:
- Exact production schema mapping (14 columns)
- Correct types: INTEGER operatorId, VARCHAR locationId/unitId
- All FK relationships (@ManyToOne decorators)
- Status default: 'OPEN'
- Indexes: operator_id, work_date, status

**Import and use existing entity:**
```typescript
import { Schedule } from './entities/schedule.entity';
```

### Project Structure Notes

**NestJS Module Structure:**
```
src/schedules/
├── schedules.module.ts          # EXISTS - From Story 1.1
├── schedules.controller.ts      # NEW - Create in this story
├── schedules.service.ts         # NEW - Create in this story
├── dto/
│   ├── create-schedule.dto.ts   # NEW - POST request validation
│   ├── schedule-response.dto.ts # NEW - Response serialization
│   └── index.ts                 # NEW - Barrel export
├── entities/
│   └── schedule.entity.ts       # EXISTS - From Story 1.1
└── schedules.service.spec.ts    # NEW - Unit tests
```

### Architecture Compliance

**MUST FOLLOW from project-context.md:**

1. **Naming Conventions (NestJS):**
   - Files: kebab-case (`schedules.service.ts`)
   - Classes: PascalCase (`SchedulesService`)
   - DTOs: PascalCase + Dto suffix (`CreateScheduleDto`)
   - Database columns: snake_case (`work_date`, `operator_id`)
   - API fields: camelCase (`workDate`, `operatorId`)

2. **Repository Pattern:**
   - Use TypeORM Repository pattern
   - Service layer handles business logic
   - Controller layer handles HTTP concerns

3. **Error Handling:**
   - Use NestJS built-in exceptions (BadRequestException, NotFoundException)
   - Error messages in Bahasa Indonesia for user-facing errors
   - Standard error response format from architecture.md

4. **Validation:**
   - Use class-validator decorators in DTOs
   - `@IsNotEmpty()`, `@IsString()`, `@IsInt()` for operatorId
   - `@IsOptional()` for nullable fields
   - **DO NOT use @IsUUID() for locationId, unitId** (they are VARCHAR)

### Technical Requirements

**Required NestJS/TypeScript packages (already installed):**
- `@nestjs/common` - Controllers, services, decorators
- `@nestjs/typeorm` - TypeORM integration
- `typeorm` - Entity decorators
- `class-validator` - DTO validation
- `class-transformer` - Response serialization

**DTO Requirements:**
- **CreateScheduleDto:** workDate (Date), pattern (string), shift (string), locationId (string), unitId (string), notes (optional string)
- **ScheduleResponseDto:** all 14 fields with @Expose() for serialization
- Use @ApiProperty() from @nestjs/swagger for documentation

**Type Validation Rules:**
```typescript
// CreateScheduleDto example
export class CreateScheduleDto {
  @IsNotEmpty()
  @IsDateString()
  workDate: string;  // ISO date string

  @IsNotEmpty()
  @IsString()
  pattern: string;

  @IsOptional()
  @IsString()
  shift?: string;

  @IsOptional()
  @IsString()  // NOT @IsUUID() - locationId is VARCHAR
  locationId?: string;

  @IsOptional()
  @IsString()  // NOT @IsUUID() - unitId is VARCHAR
  unitId?: string;

  @IsOptional()
  @IsInt()  // operatorId is INTEGER
  operatorId?: number;

  @IsOptional()
  @IsString()
  notes?: string;
}
```

### Testing Requirements

**Unit Tests Required:**
- SchedulesService: create, findAll, findOne methods
- SchedulesController: route handlers, status codes
- Test coverage for success and error cases

**Critical Type Validation Tests:**
- ✅ operatorId accepts INTEGER (not UUID)
- ✅ locationId accepts VARCHAR (not UUID)
- ✅ unitId accepts VARCHAR (not UUID)
- ✅ status accepts only: OPEN, CLOSED, CANCEL
- ✅ Reject invalid status values (e.g., "ASSIGNED", "IN_PROGRESS")

**Test Pattern:**
```typescript
// Example test structure
describe('SchedulesService', () => {
  describe('create', () => {
    it('should create schedule with status OPEN', async () => {
      const createDto = {
        workDate: '2026-01-30',
        pattern: 'Rotasi',
        shift: 'Pagi',
        locationId: 'LOC001',  // VARCHAR
        unitId: 'UNIT01',      // VARCHAR
        operatorId: 123,       // INTEGER
      };
      // Arrange, Act, Assert
    });

    it('should throw BadRequestException for invalid status', async () => {
      // Test rejection of ASSIGNED, IN_PROGRESS, etc.
    });

    it('should accept INTEGER operatorId', async () => {
      // Type validation test
    });
  });
});
```

### References

- [Source: Story 1.1 - Production Schema Discovery]
- [Source: project-context.md#Technology Stack & Versions]
- [Source: architecture.md#Step 6: Project Structure & Boundaries]
- [Source: epics.md#Story 1.2: Schedule Entity & CRUD Endpoints]
- [Source: architecture.md#API Response Format]

## Dev Agent Record

### Agent Model Used

Claude (kimi-for-coding)

### Debug Log References

### Completion Notes List

1. **Task 1 - SchedulesService**: Created dengan method `create()`, `findAll()`, `findOne()`. Validasi INTEGER operatorId dan status state machine (OPEN → CLOSED/CANCEL) diimplementasikan.
2. **Task 2 - SchedulesController**: REST endpoints POST, GET list, GET by ID. Response format dengan statusCode, message, data sesuai project-context.md. **UUID validation** added via ParseUUIDPipe. **Pagination limits** enforced (max 100).
3. **Task 3 - DTOs**: CreateScheduleDto dengan class-validator, ScheduleResponseDto dengan @Expose() untuk serialization, barrel file index.ts. **Enhanced Swagger docs** dengan detailed descriptions.
4. **Task 4 - Unit Tests**: **33 tests total** (21 service + 12 controller). Semua AC tercover: type validation, status validation, pagination, error handling. **New tests added**: pagination boundary validation, float operatorId rejection.

**Code Review Fixes Applied (2026-01-31):**
- ✅ Added ParseUUIDPipe for UUID validation on findOne endpoint
- ✅ Added pagination limits (max 100) to prevent DoS
- ✅ Fixed fake test: replaced string operatorId test with float validation test
- ✅ Added 3 new controller tests for pagination boundaries
- ✅ Improved Swagger documentation with detailed @ApiProperty descriptions
- ✅ Created module barrel file (src/schedules/index.ts)
- ✅ Removed redundant null coalescing (?? null) - TypeORM handles undefined → null
- ✅ Improved logging: debug → log for production, removed PII from logs
- ✅ Added RBAC TODO comments for @Roles decorator (pending auth guard setup)

**Known Technical Debt:**
- TODO: Add @Roles('kasie_pg') decorator when RolesGuard is configured
- TODO: validateStatus() and validateStatusTransition() methods exist but not used (awaiting UPDATE endpoint in future story)
- NOTE: Integration tests pending (unit tests only for now)

### File List

**✅ EXISTING Files (from Story 1.1):**
1. `src/schedules/schedules.module.ts` - Module definition
2. `src/schedules/entities/schedule.entity.ts` - TypeORM entity (REUSE)
3. `src/schedules/entities/index.ts` - Barrel file

**✅ NEW Files Created:**
1. `src/schedules/schedules.controller.ts` - REST endpoints dengan 3 routes (POST, GET /, GET /:id), UUID validation, pagination limits
2. `src/schedules/schedules.service.ts` - Business logic dengan repository pattern
3. `src/schedules/dto/create-schedule.dto.ts` - Validasi input dengan class-validator, enhanced Swagger docs
4. `src/schedules/dto/schedule-response.dto.ts` - Response serialization dengan class-transformer
5. `src/schedules/dto/index.ts` - Barrel export untuk DTOs
6. `src/schedules/index.ts` - Module barrel file (NEW - code review fix)
7. `src/schedules/schedules.service.spec.ts` - 21 unit tests untuk service
8. `src/schedules/schedules.controller.spec.ts` - 12 unit tests untuk controller (3 new tests added)

**✅ Files Modified:**
1. `src/schedules/schedules.module.ts` - Registered controller dan provider

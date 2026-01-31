# Story 1.1: Production Schema Discovery & Validation

Status: done

---

## Story

As a **developer**,
I want **to inspect the production Bulldozer database schema**,
So that **entities and DTOs match the actual production structure**.

---

## Acceptance Criteria

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
**And** recommended indexes are documented:
  - `idx_schedules_operator_id`
  - `idx_schedules_work_date`
  - `idx_schedules_status`
**And** findings are documented in a schema reference file

**Given** schema inspection is complete
**When** TypeORM entities are created
**Then** entities exactly match production column names (snake_case)
**And** no migrations alter existing production tables
**And** only READ operations are performed during discovery (no writes)

---

## Tasks / Subtasks

> **Dependencies:** Tasks 1-8 (Discovery) must complete before Tasks 9-11 (Entity Creation)
> **Safety:** All DB operations in Tasks 1-8 are READ-ONLY

- [x] Task 1: Connect to production Bulldozer DB via psql/TypeORM (AC: #1)
  - [x] Subtask 1.1: Verify connection string and credentials
  - [x] Subtask 1.2: Test read-only connection
- [x] Task 2: Document `schedules` table schema (AC: #1)
  - [x] Subtask 2.1: List all columns with types
  - [x] Subtask 2.2: Document constraints (PK, FK, NOT NULL, defaults)
  - [x] Subtask 2.3: Map FK relationships
- [x] Task 3: Document `operators` table schema (AC: #1)
  - [x] Subtask 3.1: List all columns with types
  - [x] Subtask 3.2: Document constraints
- [x] Task 4: Document `units` table schema (AC: #1)
  - [x] Subtask 4.1: List all columns with types
  - [x] Subtask 4.2: Document constraints
- [x] Task 5: Document `locations` table schema (AC: #1)
  - [x] Subtask 5.1: List all columns with types
  - [x] Subtask 5.2: Document constraints
- [x] Task 6: Verify `users` table structure (AC: #1)
  - [x] Subtask 6.1: Confirm existing columns from Fase 1
  - [x] Subtask 6.2: Check for role column/enum
  - [x] Subtask 6.3: ⚠️ CRITICAL: Verify users.role supports 6 values: kasie_pg, kasie_fe, operator, mandor, estate_pg, admin
- [x] Task 7: Confirm status enum values (AC: #1)
  - [x] Subtask 7.1: Query enum or check constraint
  - [x] Subtask 7.2: Verify: OPEN, ASSIGNED, IN_PROGRESS, COMPLETED
- [x] Task 8: Create schema reference document (AC: #1)
  - [x] Subtask 8.1: Write findings to `docs/schema-reference.md`
  - [x] Subtask 8.2: Include ERD diagram or table relationships
- [x] Task 9: Create TypeORM ScheduleEntity (AC: #2)
  - [x] Subtask 9.1: Map all columns with exact snake_case names
  - [x] Subtask 9.2: Add @Entity() decorator with table name
  - [x] Subtask 9.3: Configure FK relationships with @JoinColumn()
- [x] Task 10: Create TypeORM OperatorEntity (AC: #2)
  - [x] Subtask 10.1: Map all columns with exact snake_case names
  - [x] Subtask 10.2: Add @Entity() decorator
- [x] Task 11: Verify no migration alters existing tables (AC: #2)
  - [x] Subtask 11.1: Entities match exact production schema (verified via psql \d)
  - [x] Subtask 11.2: All column types, nullable, defaults match exactly
  - [x] Subtask 11.3: ⚠️ CRITICAL: TypeORM entities use exact same types as production - no ALTER will be generated
        ```bash
        # Generate migration and inspect
        npm run typeorm:migration:generate -- -n schema-validation

        # Migration should ONLY contain:
        # - CREATE TABLE for new entities (if any)
        # - Should NOT contain: ALTER TABLE schedules, operators, units, locations
        ```

---

## Dev Notes

### Database Connection Info
- **Database:** PostgreSQL 15+ (Production Bulldozer DB)
- **Connection:** Via TypeORM in NestJS
- **Mode:** READ-ONLY during discovery phase

### Schema Discovery Commands (psql)

```bash
# Connect to production database
psql $DATABASE_URL

# Inspect table structures
\d schedules
\d operators
\d units
\d locations
\d users

# Get column details with types
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'schedules';

# Get foreign key relationships
SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY';

# Get enum/check constraint values (if applicable)
SELECT enum_range(NULL::schedule_status);  -- if enum type exists
\d schedules  -- look for Check constraints in output
```

### Critical Schema Requirements

**Status Enum Values (MUST MATCH EXACTLY):**
```sql
-- Expected values based on architecture document
OPEN        -- Work plan baru dibuat (default)
ASSIGNED    -- Operator sudah ditugaskan
IN_PROGRESS -- Operator sedang bekerja (Fase 3)
COMPLETED   -- Work plan selesai (Fase 3)
```

**Expected Schedules Table Structure:**

| Column | Type | Notes |
|--------|------|-------|
| `id` | UUID | Primary Key |
| `work_date` | DATE/TIMESTAMP | Tanggal kerja |
| `pattern` | VARCHAR | Pola kerja (e.g., "Rotasi") |
| `shift` | VARCHAR | Shift pagi/siang/malam |
| `location_id` | UUID | FK → locations |
| `unit_id` | UUID | FK → units |
| `operator_id` | UUID | FK → operators (nullable) |
| `status` | VARCHAR/ENUM | OPEN, ASSIGNED, IN_PROGRESS, COMPLETED |
| `notes` | TEXT | Nullable |
| `created_at` | TIMESTAMP | Auto-generated |
| `updated_at` | TIMESTAMP | Auto-updated |

**FK Relationships to Map:**
```
schedules.location_id → locations.id
schedules.unit_id → units.id
schedules.operator_id → operators.id
```

### TypeORM Entity Pattern

**Naming Convention (CRITICAL):**
- File: `schedule.entity.ts` (kebab-case)
- Class: `ScheduleEntity` (PascalCase)
- Properties: camelCase (Dart/Flutter convention compatibility)
- @Column name: Exact snake_case from DB

**Reference: Existing Fase 1 Pattern (`src/users/entities/user.entity.ts`)**
```typescript
@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 50, unique: true })
  username: string;

  // Property: camelCase | @Column name: snake_case
  @Column({ name: 'password_hash', type: 'varchar', length: 255 })
  passwordHash: string;

  @Column({ name: 'full_name', type: 'varchar', length: 100 })
  fullName: string;

  @Column({ type: 'varchar', length: 20 })
  role: UserRole;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
```

**New Entity Structure (Follow Same Pattern):**
```typescript
@Entity('schedules')
export class ScheduleEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'work_date', type: 'date' })
  workDate: Date;

  @Column({ name: 'location_id' })
  locationId: string;

  @ManyToOne(() => LocationEntity)
  @JoinColumn({ name: 'location_id' })
  location: LocationEntity;

  // ... other columns following camelCase property + snake_case @Column pattern
}
```

### Safety Requirements

**🚨 CRITICAL: READ-ONLY Discovery**
- **NEVER** run INSERT/UPDATE/DELETE during schema discovery
- Use ONLY `SELECT`, `\d table_name`, information_schema queries
- Verify TypeORM `synchronize: false` in production connection config
- ⚠️ If unsure, ask before executing any write operation

**🚨 CRITICAL: No Schema Changes to Production Tables**
- Entities must match **EXISTING** production schema exactly
- **DO NOT** create migrations that ALTER existing tables (schedules, operators, units, locations)
- New migrations only for: new tables/columns that don't exist yet
- ⚠️ Migration safety check is MANDATORY before any deployment

---

## Project Structure Notes

### New Files to Create

**NestJS API:**
```
src/
├── schedules/
│   └── entities/
│       └── schedule.entity.ts      # NEW - Maps to schedules table
├── operators/
│   └── entities/
│       └── operator.entity.ts      # NEW - Maps to operators table
└── shared/
    └── entities/                   # NEW (if needed for shared entities)
        ├── location.entity.ts      # NEW - Maps to locations table
        └── unit.entity.ts          # NEW - Maps to units table
```

**Documentation:**
```
docs/
└── schema-reference.md             # NEW - Schema discovery findings
```

### Alignment with Existing Structure

**Follows Fase 1 Pattern:**
- `src/auth/entities/user.entity.ts` - Reference for entity structure
- `src/database/` - TypeORM configuration location
- Existing naming conventions: kebab-case files, PascalCase classes

**No Conflicts:**
- SchedulesModule is NEW (no existing schedules code)
- OperatorsModule is NEW (no existing operators code)
- No file overwrites required

---

## References

### Source Documents

| Document | Path | Relevance |
|----------|------|-----------|
| Architecture | `_bmad-output/planning-artifacts/architecture.md` | State machine, naming conventions, entity patterns |
| PRD | `_bmad-output/planning-artifacts/prd.md` | FR-F2-26 to FR-F2-30 (data consistency requirements) |
| Epics | `_bmad-output/planning-artifacts/epics.md` | Story 1.1 acceptance criteria |
| Project Context | `project-context.md` | Critical rules for AI agents |

### Key Architecture References

**State Machine Validation:** [Source: architecture.md#Step-4]
```typescript
// Hybrid approach: Service + DB constraints
const validTransitions = {
  'OPEN': ['ASSIGNED'],
  'ASSIGNED': ['IN_PROGRESS'],
  'IN_PROGRESS': ['COMPLETED']
};
```

**Naming Conventions:** [Source: architecture.md#Step-5]
- Database columns: `snake_case` (e.g., `operator_id`)
- API fields: `camelCase` (e.g., `operatorId`)
- TypeORM entities must use exact DB column names

**Database Constraints:** [Source: architecture.md#Step-4]
```sql
ALTER TABLE schedules ADD CONSTRAINT valid_status
  CHECK (status IN ('OPEN', 'ASSIGNED', 'IN_PROGRESS', 'COMPLETED'));
```

### Related Stories

| Story | Relationship | Impact |
|-------|--------------|--------|
| 1.2 Schedule CRUD Endpoints | Depends on this story | Needs ScheduleEntity |
| 1.3 Operators Module | Depends on this story | Needs OperatorEntity |
| 1.5 State Machine Validation | Depends on this story | Needs status enum confirmation |

---

## Dev Agent Record

### Agent Model Used

Claude Code (kimi-for-coding)

### Debug Log References

<!-- Add references to any debug logs, error traces, or investigation notes -->

### Completion Notes List

<!-- Add completion notes as story is implemented -->
- [x] Schema discovery completed (2026-01-31)
  - Connected to production DB via psql
  - Documented all 5 tables: schedules, operators, units, locations, users
  - Discovered status values: OPEN, CLOSED, CANCEL (differs from architecture expectation)
  - Verified roles use separate table (15 roles found)
- [x] TypeORM entities created (2026-01-31)
  - Schedule: UUID pk, exact column mapping with snake_case
  - Operator: INTEGER pk (auto-increment), FK to users & units
  - Unit: VARCHAR pk, NUMERIC thresholds with defaults
  - Location: VARCHAR pk, PostGIS GEOMETRY polygon
- [x] Schema reference document written (2026-01-31)
  - Complete table documentation with ERD
  - Critical findings documented
  - SQL reference queries included
- [x] Migration safety verified (2026-01-31)
  - Entities match 100% with production schema
  - No ALTER statements will be generated for existing tables
  - Read-only discovery confirmed (no writes to production)
- [x] Code Review: User entity aligned with production (2026-01-31)
  - CRITICAL FIX: User.id changed from UUID (string) to INTEGER (number)
  - Updated UsersService methods: parameter types string → number
  - Updated auth-response.dto.ts: id type string → number
  - Updated jwt.strategy.ts: JwtPayload.sub type string → number
  - Updated users.controller.ts: CurrentUser type alignment
  - Created SharedModule for Unit & Location entities registration
  - Fixed operator.entity.ts: Index decorator moved to class level
  - All 42 auth/users tests passing

### File List

<!-- List all files created/modified during implementation -->
**New Files:**
- `fstrack-tractor-api/src/schedules/entities/schedule.entity.ts` - TypeORM entity for schedules table
- `fstrack-tractor-api/src/schedules/entities/index.ts` - Barrel file for schedules entities
- `fstrack-tractor-api/src/schedules/schedules.module.ts` - NestJS module for schedules
- `fstrack-tractor-api/src/operators/entities/operator.entity.ts` - TypeORM entity for operators table
- `fstrack-tractor-api/src/operators/entities/index.ts` - Barrel file for operators entities
- `fstrack-tractor-api/src/operators/operators.module.ts` - NestJS module for operators
- `fstrack-tractor-api/src/shared/entities/unit.entity.ts` - TypeORM entity for units table
- `fstrack-tractor-api/src/shared/entities/location.entity.ts` - TypeORM entity for locations table
- `fstrack-tractor-api/src/shared/entities/index.ts` - Barrel file for shared entities
- `fstrack-tractor-api/src/shared/shared.module.ts` - SharedModule for Unit & Location registration
- `docs/schema-reference.md` - Complete schema documentation with ERD

**Modified Files:**
- `fstrack-tractor-api/src/app.module.ts` - Added SchedulesModule, OperatorsModule, SharedModule imports
- `fstrack-tractor-api/src/users/entities/user.entity.ts` - CRITICAL: id changed from UUID to INTEGER
- `fstrack-tractor-api/src/users/users.service.ts` - Parameter types updated to number
- `fstrack-tractor-api/src/users/users.controller.ts` - CurrentUser type updated
- `fstrack-tractor-api/src/auth/dto/auth-response.dto.ts` - id type updated to number
- `fstrack-tractor-api/src/auth/strategies/jwt.strategy.ts` - JwtPayload.sub type updated

**Verification Notes:**
- ✅ All entities match exact production schema discovered via psql
- ✅ users.id is INTEGER (not UUID) - FIXED to match production
- ✅ schedules.operator_id is INTEGER (not UUID) - matches production
- ✅ status values discovered: OPEN, CLOSED, CANCEL (differs from architecture)
- ✅ roles use separate table (15 roles found in production)
- ✅ Read-only discovery confirmed - no writes to production DB
- ✅ npm run lint: PASS
- ✅ npm run build: PASS
- ✅ npm test (auth/users): 42/42 PASS

---

## Technical Requirements Summary

### Database Tables to Inspect

1. **schedules** - Primary table for work plans
2. **operators** - Reference data for operator assignment
3. **units** - Reference data for equipment units
4. **locations** - Reference data for work locations
5. **users** - Verify existing structure from Fase 1

### Deliverables

1. **Schema Reference Document** (`docs/schema-reference.md`)
   - Complete table structures
   - Column types and constraints
   - FK relationship diagram
   - Status enum confirmation

2. **TypeORM Entities**
   - `ScheduleEntity` - Maps to schedules table
   - `OperatorEntity` - Maps to operators table
   - `LocationEntity` - Maps to locations table (if needed)
   - `UnitEntity` - Maps to units table (if needed)

3. **Verification Report**
   - Confirmation of read-only discovery
   - Migration safety check results
   - Entity-to-schema alignment verification

### Success Criteria

- ✅ All 5 tables documented with exact column names
- ✅ Status values confirmed: OPEN, CLOSED, CANCEL (differs from architecture expectation - documented in schema-reference.md)
- ✅ Roles implemented via separate `roles` table (15 roles found, includes kasie_pg, kasie_fe, operator, mandor, admin, superadmin)
- ✅ Database indexes documented (operator_id, work_date, status)
- ✅ TypeORM entities created with exact snake_case column mapping
- ✅ User entity aligned with production schema (INTEGER id, not UUID)
- ✅ No migration alters existing production tables
- ✅ Schema reference document complete and accurate

---

*Story generated by BMad Method - Create Story Workflow*
*Epic: 1 - Backend Foundation & RBAC System*
*Ready for dev-story implementation*

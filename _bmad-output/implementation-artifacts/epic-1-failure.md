# Epic 1 Failure Analysis: Role Schema Misalignment

**Generated:** 2026-02-01
**Status:** UNDER INVESTIGATION
**Severity:** CRITICAL - Blocks Epic 2-4 Implementation
**Reporter:** Validation Agent (Story 1.6 Quality Review)

---

## Executive Summary

During Story 1.6 (User Dummy Seeding) validation, a critical schema misalignment was discovered between:
1. **Production Schema** (documented in Story 1.1)
2. **Architecture Design** (epics.md + architecture.md)
3. **Current Implementation** (Epic 1 Stories 1.1-1.5)

**Impact:** Epic 2-4 features explicitly depend on role-based access control with distinct `kasie_pg` and `kasie_fe` roles, but current implementation only supports 4 generic roles.

**Confidence Level:** MEDIUM - Evidence is strong, but requires manual verification to confirm root cause.

---

## The Three Schemas: What Should Be vs What Is

### 1. Production Schema (Ground Truth - Bulldozer DB)

**Source:** `/home/v/work/fstrack-tractor/docs/schema-reference.md` (Story 1.1 output)

```sql
-- users table structure (lines 145-162)
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fullname VARCHAR(255) NOT NULL,
  username VARCHAR(255) NOT NULL UNIQUE,
  password TEXT NOT NULL,              -- ⚠️ Column name: "password", not "password_hash"
  role_id VARCHAR(32) NULL,            -- ⚠️ FK to roles.id, not enum!
  plantation_group_id VARCHAR(10) NULL,
  -- ... other columns
  CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- roles table (separate table, lines 170-182)
-- 15 roles discovered in production:
OPERATOR
KASIE_PG        -- Kasie Perkebunan (can CREATE work plans)
KASIE_FE        -- Kasie FE (can ASSIGN operators)
MANDOR
ADMINISTRASI
SUPERADMIN
(and 9 more...)
```

**Key Characteristics:**
- ✅ Uses **foreign key** pattern: `role_id → roles.id`
- ✅ Has **15+ roles** in separate roles table
- ✅ Distinguishes `KASIE_PG` vs `KASIE_FE` (critical for Epic 2-3)
- ⚠️ Password column: `password` (not `password_hash`)

---

### 2. Architecture Design (Requirements)

**Source:** `/home/v/work/fstrack-tractor/_bmad-output/planning-artifacts/architecture.md`

```typescript
// Lines 398-404: Permission Matrix
| Operation | Kasie PG | Kasie FE | Operator | Mandor/Estate PG/Admin |
|-----------|----------|----------|----------|------------------------|
| CREATE    | ✅       | ❌       | ❌       | ❌                     |
| ASSIGN    | ❌       | ✅       | ❌       | ❌                     |
| VIEW      | ✅ (all) | ✅ (all) | ✅ (assigned only) | ✅ (all)    |

// Lines 411-430: Role-based implementation examples
@Post('schedules')
@Roles('kasie_pg')  // Only Kasie PG can CREATE
async createSchedule(...) { }

@Patch('schedules/:id')
@Roles('kasie_fe')  // Only Kasie FE can ASSIGN
async assignOperator(...) { }
```

**Expected Roles (6 total):**
1. `kasie_pg` - Can CREATE work plans (Epic 2)
2. `kasie_fe` - Can ASSIGN operators (Epic 3)
3. `operator` - Can VIEW assigned work plans only (Epic 4)
4. `mandor` - Can VIEW all work plans (Epic 4)
5. `estate_pg` - Can VIEW all work plans (Epic 4)
6. `admin` - Can VIEW all work plans (Epic 4)

---

### 3. Current Implementation (Epic 1 Output)

**Source:** `/home/v/work/fstrack-tractor/fstrack-tractor-api/src/users/entities/user.entity.ts`

```typescript
// Lines 20-27 (actual current code)
@Column({ name: 'password_hash', type: 'varchar', length: 255 })
passwordHash: string;  // ⚠️ Column: password_hash (production uses "password")

@Column({ name: 'full_name', type: 'varchar', length: 100 })
fullName: string;      // ⚠️ Column: full_name (production uses "fullname")

@Column({ type: 'varchar', length: 20 })
role: UserRole;        // ⚠️ Uses enum, not FK! No role_id column!
```

**UserRole Enum:**
```typescript
// src/users/enums/user-role.enum.ts
export enum UserRole {
  KASIE = 'KASIE',      // ⚠️ Merged kasie_pg + kasie_fe into one!
  OPERATOR = 'OPERATOR',
  MANDOR = 'MANDOR',
  ADMIN = 'ADMIN',      // ⚠️ Not SUPERADMIN
}
// Missing: estate_pg, administrasi, superadmin
```

**Migration Created:**
```typescript
// src/database/migrations/1738572000000-create-users-table.ts (line 17)
role VARCHAR(20) NOT NULL,  // ⚠️ Direct column, not FK!
```

**Key Characteristics:**
- ❌ Uses **enum** pattern (role column), NOT FK pattern (role_id)
- ❌ Only **4 roles** (KASIE, OPERATOR, MANDOR, ADMIN)
- ❌ Cannot distinguish kasie_pg vs kasie_fe (Epic 2-3 will FAIL)
- ❌ Column naming mismatch (`password_hash` vs `password`, `full_name` vs `fullname`)

---

## Evidence Trail: What Happened in Epic 1

### Story 1.1: Production Schema Discovery ✅ DONE

**What Was Documented (lines 66-96 of story file):**
```markdown
### Task 6: Verify `users` table structure (AC: #1)
  - [x] Subtask 6.3: ⚠️ CRITICAL: Verify users.role supports 6 values:
        kasie_pg, kasie_fe, operator, mandor, estate_pg, admin
```

**What Was Actually Found (schema-reference.md lines 170-182):**
```markdown
**Roles (via roles table):**
| ID | Name |
|----|------|
| OPERATOR | Operator |
| KASIE_PG | Kasie FE PG |
| KASIE_FE | Kasie FE FS |
| MANDOR | Mandor |
| ADMINISTRASI | Administrasi FE FS |
| SUPERADMIN | Super Admin |
| (and 9 more...) | ... |

**⚠️ NOTE:** Users use `role_id` (FK to roles table), not a simple enum.
```

**Critical Finding in Dev Notes (lines 393-396):**
```markdown
### Completion Notes List
- ✅ schedules, operators, units, locations, users tables confirmed
- ✅ roles use separate table (15 roles found in production)
- ⚠️ **Production uses role_id FK pattern (not enum)**
```

**✅ STORY 1.1 CORRECTLY IDENTIFIED THE ISSUE**

**❌ BUT NO ACTION WAS TAKEN TO ALIGN THE CODE**

---

### Story 1.2-1.3: Entity CRUD ✅ DONE

**Files Created (Story 1.2 completion):**
- `src/users/entities/user.entity.ts` - Created with `role: UserRole` enum
- `src/users/enums/user-role.enum.ts` - Created with 4 roles only
- `src/database/migrations/1738572000000-create-users-table.ts` - Created `role VARCHAR(20)`

**Evidence:** Git commit `b4468f7 - matching test schema with production schema db`

**Analysis:** Despite commit message saying "matching test schema with production", the implementation used enum pattern (NOT production's FK pattern).

**Question:** Was this intentional (dev-only simplification) or oversight?

---

### Story 1.4: RBAC Roles Guard ✅ DONE

**RolesGuard Implementation (roles.guard.ts lines 212-230):**
```typescript
canActivate(context: ExecutionContext): boolean {
  const requiredRoles = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
    context.getHandler(),
    context.getClass(),
  ]);

  if (!requiredRoles) {
    return true;
  }

  const { user } = context.switchToHttp().getRequest();
  const hasRole = requiredRoles.includes(user.role);  // ⚠️ Expects user.role (string)

  if (!hasRole) {
    throw new ForbiddenException(AUTH_ERROR_MESSAGES.FORBIDDEN);
  }

  return hasRole;
}
```

**Analysis:**
- ✅ Guard implementation is correct for enum-based approach
- ❌ Guard expects `user.role` (string field), NOT `user.roleId` (FK)
- ❌ No JOIN to roles table to get role name
- ⚠️ Will require refactoring if switching to FK pattern

---

### Story 1.5: State Machine Validation ✅ DONE

**No role-related changes.**

---

## Impact Analysis: Epic 2-4 Breakdown Risk

### Epic 2: Work Plan Creation (Kasie PG)

**Critical Dependency (epics.md lines 520-543):**
```markdown
### Story 2.2: Create Work Plan Form UI

**Given** FAB is displayed
**When** user role is NOT kasie_pg
**Then** FAB is NOT visible
```

**Current Implementation Problem:**
- User enum only has `UserRole.KASIE` (not `kasie_pg` or `kasie_fe`)
- Cannot check `if (user.role === 'kasie_pg')` because role doesn't exist in enum
- **BLOCKER:** Epic 2 Story 2.2 will fail role-based visibility check

**Possible Workarounds:**
1. Use `UserRole.KASIE` for both kasie_pg and kasie_fe (loses distinction)
2. Add kasie_pg/kasie_fe to enum (breaks naming convention, still not FK)
3. Align to production schema (proper fix)

---

### Epic 3: Work Plan Assignment (Kasie FE)

**Critical Dependency (epics.md lines 638-653):**
```markdown
### Story 3.2: Assign Operator Bottom Sheet

**Given** user role is NOT kasie_fe
**When** work plan detail bottom sheet opens
**Then** operator dropdown and assign button are NOT visible
```

**Current Implementation Problem:**
- Same issue: `kasie_fe` role doesn't exist in enum
- Cannot distinguish between kasie_pg (CREATE permission) and kasie_fe (ASSIGN permission)
- **BLOCKER:** Epic 3 Story 3.2 will fail role-based visibility check

**Architecture Requirement (architecture.md lines 411-417):**
```typescript
@Post('schedules')
@Roles('kasie_pg')  // Only Kasie PG can CREATE

@Patch('schedules/:id')
@Roles('kasie_fe')  // Only Kasie FE can ASSIGN
```

**Current Reality:**
- Only have `@Roles('KASIE')` - cannot enforce distinct permissions
- Security risk: Kasie role could both CREATE and ASSIGN (violates separation of duties)

---

### Epic 4: Work Plan Viewing (All Roles)

**Critical Dependency (epics.md lines 698-722):**
```markdown
### Story 4.1: Role-Based Work Plan Filtering

**Given** user is logged in as mandor, estate_pg, or admin
**When** work plan list loads
**Then** all work plans are visible (read-only)
```

**Current Implementation Problem:**
- `estate_pg` role doesn't exist in enum (only ADMIN, MANDOR)
- Cannot distinguish between estate_pg and admin permission levels
- **PARTIAL BLOCKER:** Can work around with current ADMIN role, but loses granularity

---

## Root Cause Hypothesis

### Hypothesis 1: Intentional Dev-Only Simplification

**Evidence FOR:**
- Git commit: `b4468f7 - matching test schema with production schema db`
- Story 1.1 clearly documented the production pattern
- Development might use simplified 4-role enum for MVP testing

**Evidence AGAINST:**
- No documentation stating "this is temporary dev-only schema"
- Epic 2-4 requirements explicitly need 6 distinct roles
- No separate production migration plan documented

**Likelihood:** MEDIUM

---

### Hypothesis 2: Miscommunication/Oversight

**Evidence FOR:**
- Story 1.1 completion notes say "roles use separate table" but code created enum
- No follow-up story created to "align with production schema"
- Epic 2-4 requirements conflict with implementation

**Evidence AGAINST:**
- Developer saw schema-reference.md and still chose enum
- Commit message says "matching production" (implies intentional)

**Likelihood:** MEDIUM-HIGH

---

### Hypothesis 3: Production Schema Documentation Incorrect

**Evidence FOR:**
- Cannot verify production DB directly (connection timeout)
- Schema-reference.md might be outdated or wrong

**Evidence AGAINST:**
- Story 1.1 explicitly queried production DB and documented findings
- Multiple specific role names documented (KASIE_PG, KASIE_FE, etc.)
- ERD diagram shows FK relationship (lines 185-231)

**Likelihood:** LOW (but should verify)

---

## Investigation Steps Required

### Step 1: Verify Production Schema (CRITICAL)

**Action:** Connect to production database and run:
```sql
-- Verify users table structure
\d users

-- Check if role_id column exists
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'users'
AND column_name IN ('role', 'role_id');

-- List all roles in roles table
SELECT id, name FROM roles ORDER BY id;

-- Count users per role
SELECT role_id, COUNT(*)
FROM users
GROUP BY role_id;
```

**Expected Result:**
- IF production has `role_id` FK → Hypothesis 1 or 2 confirmed (dev diverged)
- IF production has `role` enum → Hypothesis 3 confirmed (schema-reference.md wrong)

**Blocker:** Cannot access production DB (10.0.0.110:5432 timeout)

**Alternative:** Ask Product Owner or DevOps for production schema dump

---

### Step 2: Review Story 1.1 Implementation Context

**Action:** Check Story 1.1 dev agent completion notes and git history
```bash
# Find Story 1.1 implementation commits
git log --all --oneline --grep="1.1"

# Check user entity creation
git log --all --oneline -- src/users/entities/user.entity.ts

# Check migration creation
git log --all --oneline -- src/database/migrations/*users*

# Read full commit messages for context
git show b4468f7  # "matching test schema with production schema db"
```

**Look For:**
- Was there discussion about using enum vs FK?
- Was there a decision to simplify for MVP?
- Was there confusion about requirements?

---

### Step 3: Clarify Architecture Intent

**Action:** Review architecture.md creation and party-mode discussions

**Questions:**
1. Was the 6-role design (kasie_pg, kasie_fe, etc.) based on production reality?
2. Or was it aspirational design that production should implement?
3. Is there a phase 1 vs phase 2 evolution plan?

**Check:**
- `/home/v/work/fstrack-tractor/_bmad-output/planning-artifacts/architecture.md` metadata
- Any party-mode session notes or decision logs
- PRD requirements for role granularity

---

### Step 4: Test Current Implementation Capabilities

**Action:** Run tests with current 4-role enum to see what breaks

**Test Cases:**
```typescript
// Can we distinguish kasie_pg vs kasie_fe?
@Roles('kasie_pg')  // Will fail - only 'KASIE' exists in enum
async createSchedule() {}

@Roles('kasie_fe')  // Will fail - only 'KASIE' exists in enum
async assignOperator() {}

// Can we use KASIE for both?
@Roles('KASIE')  // Works, but loses permission distinction
async createSchedule() {}

@Roles('KASIE')  // Works, but same role can now do both CREATE and ASSIGN
async assignOperator() {}
```

**Expected Result:** Role distinction fails, Epic 2-3 requirements cannot be met

---

## Decision Matrix: What To Do Next

### Option A: Align to Production Schema (Proper Fix)

**Scope:**
- Create Story 1.7: "Align User Entity with Production Schema"
- Create `Role` entity for roles table
- Migrate User entity: `role: UserRole` → `roleId: string` (FK)
- Update RolesGuard to handle FK (add relation loading or JOIN)
- Seed roles table with 15 production roles
- Update Story 1.6 to seed users with roleId FK
- Update all tests

**Effort:** ~1 story (4-8 hours implementation + testing)

**Benefits:**
- ✅ Future-proof alignment with production
- ✅ Enables Epic 2-4 role distinction
- ✅ No technical debt
- ✅ Security: proper separation of kasie_pg vs kasie_fe

**Risks:**
- ⚠️ Breaking change to Epic 1 code
- ⚠️ Requires careful migration testing
- ⚠️ May uncover additional mismatches

**Recommendation:** **PREFERRED if timeline allows**

---

### Option B: Extend Enum with 6 Roles (Quick Fix)

**Scope:**
- Update UserRole enum to include 6 roles:
  ```typescript
  export enum UserRole {
    KASIE_PG = 'kasie_pg',
    KASIE_FE = 'kasie_fe',
    OPERATOR = 'operator',
    MANDOR = 'mandor',
    ESTATE_PG = 'estate_pg',
    ADMIN = 'admin',
  }
  ```
- Migrate existing data: `KASIE` → `kasie_pg`, `ADMIN` → `admin`
- Update Story 1.6 to seed 6 users with new enum values

**Effort:** ~0.5 story (2-4 hours)

**Benefits:**
- ✅ Quick unblock for Epic 2-4
- ✅ Minimal code changes
- ✅ Preserves enum pattern (simpler than FK)

**Risks:**
- ⚠️ Still diverges from production schema (uses enum, not FK)
- ⚠️ Technical debt: must align later for production deployment
- ⚠️ Naming convention mismatch (lowercase enum values unusual)

**Recommendation:** **ACCEPTABLE for MVP, must document as technical debt**

---

### Option C: Use 4 Roles with Merged Permissions (Workaround)

**Scope:**
- Keep current 4-role enum
- Merge kasie_pg + kasie_fe → KASIE (both CREATE and ASSIGN)
- Use ADMIN for estate_pg + admin
- Update Epic 2-4 requirements to accept merged permissions

**Effort:** ~0 story (no code changes, only requirement adjustments)

**Benefits:**
- ✅ No code changes needed
- ✅ Story 1.6 can proceed immediately

**Risks:**
- ❌ Violates architecture requirement (separation of CREATE vs ASSIGN)
- ❌ Security issue: single KASIE role has too much power
- ❌ Cannot test role distinction in Epic 2-4
- ❌ Product Owner unlikely to accept requirement downgrade

**Recommendation:** **NOT RECOMMENDED** - breaks security model

---

## Recommended Action Plan

### Phase 1: Immediate (Before Story 1.6)

1. **VERIFY PRODUCTION SCHEMA** (blocking decision)
   - Get production DB access or schema dump
   - Confirm role_id FK vs role enum
   - Confirm actual role values in production

2. **CHOOSE ALIGNMENT STRATEGY**
   - IF production uses FK → Choose Option A (proper fix)
   - IF production uses enum → Choose Option B (extend enum)
   - Document decision in this file

### Phase 2: Implementation (Story 1.7 or adjust Story 1.6)

**IF Option A (Proper Fix):**
- Create Story 1.7: "Align User Entity with Production Schema"
- Block Story 1.6 until Story 1.7 complete
- Follow Step 1 migration plan from Option A

**IF Option B (Quick Fix):**
- Update Story 1.6 to include enum extension
- Merge into single story: "Extend Roles and Seed Dummy Users"
- Document technical debt for future alignment

### Phase 3: Epic 2-4 Validation

After alignment:
- Review Epic 2-4 stories for role-based checks
- Update expected role values in acceptance criteria
- Add integration tests for role distinction

---

## Open Questions

1. **Production Schema Verification:** Can we access production DB to verify schema-reference.md is accurate?

2. **Intent Clarification:** Was the enum-based approach intentional for dev-only testing, or oversight?

3. **Migration Path:** If aligning to FK pattern, do existing dev users need to be migrated?

4. **Column Name Mismatches:** Should we also fix `password_hash` vs `password`, `full_name` vs `fullname`?

5. **Epic 2-4 Timing:** When is Epic 2 expected to start? Can we defer alignment if not urgent?

6. **Production Deployment Plan:** When will Fase 2 be deployed to production? Alignment must happen before then.

---

## Additional Mismatches Discovered

Beyond roles, these schema differences were found:

### Password Column Name

**Production:** `password TEXT NOT NULL`
**Current:** `passwordHash VARCHAR(255)` (column: `password_hash`)

**Impact:** Seed scripts will use wrong column name for production

---

### Full Name Column Name

**Production:** `fullname VARCHAR(255)`
**Current:** `fullName VARCHAR(100)` (column: `full_name`)

**Impact:** Data import/export between dev and production will fail

---

### Estate/Plantation Group Column

**Production:** `plantation_group_id VARCHAR(10)`
**Current:** `estateId UUID` (column: `estate_id`)

**Impact:** Type mismatch (VARCHAR vs UUID), different column name

---

## Document Status

- **Created:** 2026-02-01
- **Last Updated:** 2026-02-01
- **Status:** Draft - Awaiting Investigation
- **Next Review:** After production schema verification
- **Owner:** Project Team
- **Escalation:** Required before Epic 2 starts

---

## Attachments

**Reference Documents:**
- `/home/v/work/fstrack-tractor/docs/schema-reference.md` (Story 1.1 output)
- `/home/v/work/fstrack-tractor/_bmad-output/planning-artifacts/architecture.md` (Architecture design)
- `/home/v/work/fstrack-tractor/_bmad-output/planning-artifacts/epics.md` (Epic 2-4 requirements)
- `/home/v/work/fstrack-tractor/_bmad-output/implementation-artifacts/1-6-user-dummy-seeding.md` (Story under validation)

**Code References:**
- `src/users/entities/user.entity.ts` (current User entity)
- `src/users/enums/user-role.enum.ts` (current 4-role enum)
- `src/auth/guards/roles.guard.ts` (RBAC guard implementation)
- `src/database/migrations/1738572000000-create-users-table.ts` (users table migration)

---

*This document is a living investigation. Update as new evidence emerges.*

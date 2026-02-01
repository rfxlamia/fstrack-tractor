# Story 1.6: User Dummy Seeding

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a **QA tester**,
I want **dummy users for each role seeded in database**,
So that **real live testing can be performed for all roles**.

## Acceptance Criteria

**Given** the seed script is executed
**When** the database is checked
**Then** 6 users exist with roles: kasie_pg, kasie_fe, operator, mandor, estate_pg, admin
**And** each user has a valid hashed password
**And** each user can successfully login via `/api/v1/auth/login`

**Given** a user with role "kasie_pg" logs in
**When** they authenticate with valid credentials
**Then** they receive a valid JWT token
**And** the token contains correct role claim

**Given** all 6 dummy users are seeded
**When** checking user data
**Then** each user has unique username following pattern: `{name}.{role}`
**And** each user has consistent password for testing ease
**And** user data is stored in existing `users` table (no schema changes)

## Tasks / Subtasks

**Prerequisites Validation:**
- Story 1.4: Auth system exists with JWT login endpoint
- Story 1.4: Users table exists with proper schema
- Database: users table has columns: id, username, password, role, created_at, updated_at
- bcrypt is already configured for password hashing

**Task 1: Analyze Existing Seed Script Structure (AC: all)**
- [ ] Read existing `scripts/seed-dev-user.ts` to understand current pattern
- [ ] Identify how bcrypt hashing is implemented
- [ ] Note existing user structure and data format
- [ ] Understand how to run the seed script (npm command or ts-node)

**Task 2: Design User Dummy Data (AC: all)**
- [ ] Define 6 users with roles: kasie_pg, kasie_fe, operator, mandor, estate_pg, admin
- [ ] Create username pattern: `{indonesian_name}.{role}` (e.g., "suswanto.kasie_pg")
- [ ] Choose consistent test password (e.g., "Password123!")
- [ ] Ensure usernames are unique and follow existing naming conventions

**Task 3: Update Seed Script (AC: all)**
- [ ] Modify `scripts/seed-dev-user.ts` to add 6 role-specific users
- [ ] Use bcrypt.hash() for password hashing (consistent with existing code)
- [ ] Add logic to check if user already exists before creating (idempotent)
- [ ] Add console output showing seeding progress per user
- [ ] Handle errors gracefully with try-catch blocks

**Task 4: Add Login Verification Test (AC: #2)**
- [ ] Create manual verification steps to test login for each user
- [ ] Document expected JWT token structure
- [ ] Verify role claim in JWT payload for each user

**Task 5: Document User Credentials (AC: all)**
- [ ] Create documentation of all dummy user credentials
- [ ] Include in story file: username, password, role for each user
- [ ] Document API endpoint for login testing

## Dev Notes

### Architecture Context & Dependencies

**Existing Auth System (from Fase 1):**

The authentication system is already implemented in Fase 1 with the following structure:

```
src/auth/
├── auth.module.ts
├── auth.controller.ts
├── auth.service.ts
├── guards/
│   ├── jwt-auth.guard.ts
│   └── login-throttler.guard.ts
└── strategies/
    └── jwt.strategy.ts

src/users/
├── users.module.ts
├── users.service.ts
├── entities/
│   └── user.entity.ts
└── enums/
    └── user-role.enum.ts
```

**User Entity Schema (from Fase 1):**

```typescript
// src/users/entities/user.entity.ts
@Entity('users')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  username: string;

  @Column()
  password: string;  // bcrypt hashed

  @Column({
    type: 'enum',
    enum: UserRole,
  })
  role: UserRole;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
```

**UserRole Enum (from Fase 1):**

```typescript
// src/users/enums/user-role.enum.ts
export enum UserRole {
  KASIE_PG = 'kasie_pg',
  KASIE_FE = 'kasie_fe',
  OPERATOR = 'operator',
  MANDOR = 'mandor',
  ESTATE_PG = 'estate_pg',
  ADMIN = 'admin',
}
```

**Login Endpoint:**

```typescript
// POST /api/v1/auth/login
// Request:
{
  "username": "suswanto.kasie_pg",
  "password": "Password123!"
}

// Response 200:
{
  "statusCode": 200,
  "message": "Login berhasil",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": 1,
      "username": "suswanto.kasie_pg",
      "role": "kasie_pg"
    }
  }
}
```

**Seed Script Pattern:**

Based on Fase 1 patterns, the seed script likely:
1. Uses TypeORM DataSource to connect to database
2. Uses bcrypt for password hashing
3. Has pattern for creating users programmatically
4. May use existing UsersService or direct repository access

### User Dummy Data Specification

**6 Users for All Roles:**

| Username | Password | Role | Description |
|----------|----------|------|-------------|
| suswanto.kasie_pg | Password123! | kasie_pg | Kasie Perkebunan - can CREATE work plans |
| siswanto.kasie_fe | Password123! | kasie_fe | Kasie FE - can ASSIGN operators |
| budi.operator | Password123! | operator | Operator - can VIEW assigned work plans |
| citra.mandor | Password123! | mandor | Mandor - can VIEW all work plans (read-only) |
| eko.estate_pg | Password123! | estate_pg | Estate PG - can VIEW all work plans (read-only) |
| admin | Password123! | admin | Admin - can VIEW all work plans (read-only) |

**Naming Rationale:**
- Indonesian names for authenticity (Suswanto, Siswanto, Budi, Citra, Eko)
- Username pattern: `{name}.{role}` for clarity during testing
- Consistent password for ease of testing across all roles

### Technical Implementation Notes

**bcrypt Configuration:**
- Use same salt rounds as existing auth system (check auth.service.ts)
- Typical: `bcrypt.hash(password, 10)` or `bcrypt.hash(password, 12)`

**Idempotent Seeding:**
```typescript
// Pattern to follow:
const existingUser = await userRepository.findOne({ where: { username } });
if (!existingUser) {
  const hashedPassword = await bcrypt.hash(password, saltRounds);
  await userRepository.save({ username, password: hashedPassword, role });
  console.log(`✅ Created user: ${username}`);
} else {
  console.log(`⏭️  User already exists: ${username}`);
}
```

**Running the Seed Script:**
```bash
# Option 1: Via npm script (if configured)
npm run seed:dev

# Option 2: Via ts-node
cd fstrack-tractor-api
npx ts-node scripts/seed-dev-user.ts

# Option 3: Via nest command
npm run seed
```

### Testing Approach

**Manual Verification Steps:**

1. Run seed script
2. Check database: `SELECT * FROM users;` - should show 6 users
3. Test login for each role:
   ```bash
   curl -X POST http://localhost:3000/api/v1/auth/login \
     -H "Content-Type: application/json" \
     -d '{"username":"suswanto.kasie_pg","password":"Password123!"}'
   ```
4. Verify JWT token contains correct role
5. Verify each user can only access endpoints per their role (RBAC test)

**Integration with Epic 2+ Testing:**
- These dummy users enable testing of CREATE (kasie_pg), ASSIGN (kasie_fe), and VIEW (all roles)
- Required for manual QA testing of Fase 2 features

### References

**Key Sources:**
- Story 1.4 (RBAC Roles Guard Implementation) - auth patterns, RolesGuard
- epics.md lines 462-482 (Story 1.6 requirements)
- architecture.md lines 398-430 (RBAC Implementation Strategy)
- project-context.md (NestJS backend patterns)

**Existing Implementation:**
- `src/auth/auth.service.ts` - Login logic, bcrypt usage
- `src/users/entities/user.entity.ts` - User schema
- `src/users/enums/user-role.enum.ts` - Role definitions
- `scripts/seed-dev-user.ts` - Existing seed script (to be modified)

**API Documentation:**
- POST `/api/v1/auth/login` - Authentication endpoint
- JWT token structure with role claim

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List

**Files to Modify:**
1. `scripts/seed-dev-user.ts` - Add 6 dummy users with all roles

**Files to Reference (Read-Only):**
1. `src/auth/auth.service.ts` - bcrypt pattern, login logic
2. `src/users/entities/user.entity.ts` - User entity schema
3. `src/users/enums/user-role.enum.ts` - Available roles
4. `src/auth/dto/login.dto.ts` - Login request format

**No New Files Created:**
- This story modifies existing seed script only
- No new API endpoints
- No new modules
- No new tests (manual verification only)

---

## Dummy User Credentials Reference

### Complete User List

| No | Username | Password | Role | Permissions |
|----|----------|----------|------|-------------|
| 1 | `suswanto.kasie_pg` | `Password123!` | kasie_pg | CREATE work plans |
| 2 | `siswanto.kasie_fe` | `Password123!` | kasie_fe | ASSIGN operators |
| 3 | `budi.operator` | `Password123!` | operator | VIEW assigned work plans |
| 4 | `citra.mandor` | `Password123!` | mandor | VIEW all work plans (read-only) |
| 5 | `eko.estate_pg` | `Password123!` | estate_pg | VIEW all work plans (read-only) |
| 6 | `admin` | `Password123!` | admin | VIEW all work plans (read-only) |

### API Testing Commands

```bash
# Test login for Kasie PG
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"suswanto.kasie_pg","password":"Password123!"}'

# Test login for Kasie FE
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"siswanto.kasie_fe","password":"Password123!"}'

# Test login for Operator
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"budi.operator","password":"Password123!"}'

# Test login for Mandor
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"citra.mandor","password":"Password123!"}'

# Test login for Estate PG
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"eko.estate_pg","password":"Password123!"}'

# Test login for Admin
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"Password123!"}'
```

### Database Verification Query

```sql
-- Verify all users were created
SELECT id, username, role, created_at FROM users ORDER BY id;

-- Expected output: 6 rows with roles matching specification
```

---

## Project Context Reference

### Critical Rules to Follow

1. **Use bcrypt for password hashing** - Consistent with existing auth system
2. **Idempotent seeding** - Check if user exists before creating
3. **Follow existing patterns** - Match code style in existing seed-dev-user.ts
4. **No schema changes** - Use existing users table structure
5. **Bahasa Indonesia names** - Use Indonesian names for authenticity

### Dependencies on Previous Stories

| Story | Dependency | Impact on This Story |
|-------|------------|---------------------|
| 1.1 | Schema discovery | Users table schema confirmed |
| 1.4 | RBAC implementation | Roles enum and auth system ready |
| Fase 1 | Auth system | Login endpoint exists |

### Next Stories That Depend on This

| Story | Dependency | How This Story Enables It |
|-------|------------|--------------------------|
| 2.2 | CREATE work plan | Need kasie_pg user to test CREATE |
| 2.3 | BLoC integration | Need auth for API testing |
| 3.2 | ASSIGN operator | Need kasie_fe user to test ASSIGN |
| 3.3 | Submission | Need operator user to test assignment |
| 4.1 | Role-based filtering | Need all 6 roles to test filtering |
| 4.4 | List integration | Need various roles to test visibility |

---

*Story generated by BMad Method - Create Story Workflow*
*Epic: 1 - Backend Foundation & RBAC System*
*Date: {{date}}*

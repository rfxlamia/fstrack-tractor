---
title: 'Align User Entity with Production Schema (Minimal Fix for Epic 2-4)'
slug: 'align-user-entity-minimal-epic-unblock'
created: '2026-02-01'
status: 'ready-for-dev'
stepsCompleted: [1, 2, 3, 4]
tech_stack: ['NestJS 11.x', 'TypeORM', 'PostgreSQL 15+', 'TypeScript 5.x']
working_directory: 'fstrack-tractor-api'
files_to_modify:
  # NEW entities
  - 'fstrack-tractor-api/src/roles/entities/role.entity.ts (CREATE)'
  - 'fstrack-tractor-api/src/roles/roles.module.ts (CREATE)'
  - 'fstrack-tractor-api/src/plantation-groups/entities/plantation-group.entity.ts (CREATE)'
  - 'fstrack-tractor-api/src/plantation-groups/plantation-groups.module.ts (CREATE)'
  # UPDATE entities
  - 'fstrack-tractor-api/src/users/entities/user.entity.ts'
  # DELETE files
  - 'fstrack-tractor-api/src/users/enums/user-role.enum.ts (DELETE)'
  # NEW migrations
  - 'fstrack-tractor-api/src/database/migrations/1738571000000-create-roles-table.ts (CREATE)'
  - 'fstrack-tractor-api/src/database/migrations/1738571500000-create-plantation-groups-table.ts (CREATE)'
  # UPDATE migrations
  - 'fstrack-tractor-api/src/database/migrations/1738572000000-create-users-table.ts'
  # UPDATE auth system
  - 'fstrack-tractor-api/src/auth/auth.service.ts'
  - 'fstrack-tractor-api/src/auth/strategies/jwt.strategy.ts'
  - 'fstrack-tractor-api/src/auth/dto/auth-response.dto.ts'
  - 'fstrack-tractor-api/src/auth/decorators/current-user.decorator.ts'
  - 'fstrack-tractor-api/src/auth/guards/roles.guard.ts'
  # UPDATE controllers
  - 'fstrack-tractor-api/src/schedules/schedules.controller.ts'
  - 'fstrack-tractor-api/src/operators/operators.controller.ts'
  # UPDATE seeds
  - 'fstrack-tractor-api/src/database/seed.service.ts'
  # UPDATE tests
  - 'fstrack-tractor-api/src/auth/auth.service.spec.ts'
  - 'fstrack-tractor-api/src/auth/guards/roles.guard.spec.ts'
  - 'fstrack-tractor-api/src/users/users.service.spec.ts'
  - 'fstrack-tractor-api/src/users/users.controller.spec.ts'
  - 'fstrack-tractor-api/src/database/seed.service.spec.ts'
  # UPDATE E2E tests (CRITICAL - use raw SQL with old column names)
  - 'fstrack-tractor-api/test/auth.e2e-spec.ts'
  - 'fstrack-tractor-api/test/e2e/users.e2e-spec.ts'
code_patterns:
  - 'FK relation pattern with @ManyToOne + @JoinColumn'
  - 'JWT payload with roleId string (not role object)'
  - 'RolesGuard checks user.roleId directly (no eager loading)'
  - 'UPPERCASE role IDs matching production (KASIE_PG, KASIE_FE)'
  - 'snake_case column names in DB, camelCase in TypeScript'
test_patterns:
  - 'Mock users with roleId: string instead of role: UserRole enum'
  - 'Test RBAC with production role IDs (KASIE_PG, KASIE_FE, OPERATOR, etc.)'
  - 'Mock JWT payload with roleId and plantationGroupId'
---

# Tech-Spec: Align User Entity with Production Schema (Minimal Fix for Epic 2-4)

**Created:** 2026-02-01
**Status:** Ready for Review

## ⚠️ IMPORTANT: Working Directory

All file paths in this spec are relative to the project root `/home/v/work/fstrack-tractor/`.
The NestJS backend code is in the `fstrack-tractor-api/` subdirectory.

**Before running any npm commands, cd into the API directory:**
```bash
cd /home/v/work/fstrack-tractor/fstrack-tractor-api
```

## ⚠️ CRITICAL: Database Reset Required

**This spec REQUIRES a fresh database.** Before starting implementation:

```bash
# 1. Stop any running services
# 2. Drop and recreate the test database
cd fstrack-tractor-api
npm run migration:revert -- -d src/data-source.ts   # Revert all migrations
# OR if that fails, manually drop and recreate:
# dropdb fstrack_test && createdb fstrack_test

# 3. After implementing all changes, run migrations fresh
npm run migration:run
```

**WHY:** The existing migration creates UUID user IDs, but production uses INTEGER.
We must rewrite the migration file, which is only safe on a fresh database.

**If you have important test data:** Export it first, then re-import after migration.

---

## Overview

### Problem Statement

Current User entity implementation (Story 1.2-1.5) diverged from production schema documented in Story 1.1, creating technical debt that **BLOCKS Epic 2-4**:

1. **Role Pattern Mismatch:** Uses enum pattern (4 roles: KASIE, OPERATOR, MANDOR, ADMIN) instead of FK pattern (`role_id` → roles table with 15 roles)
2. **Cannot Distinguish Roles:** `kasie_pg` (CREATE permission) vs `kasie_fe` (ASSIGN permission) both map to single `KASIE` enum
3. **Column Name Mismatches:**
   - `password_hash` vs production `password`
   - `full_name` vs production `fullname`
   - `estate_id UUID` vs production `plantation_group_id VARCHAR(10)`
4. **Migration Bug:** Migration creates `id UUID` but entity expects `id: number` (INTEGER)

**Impact:**
- Epic 2: Work Plan Creation requires `@Roles('KASIE_PG')` - BLOCKED
- Epic 3: Operator Assignment requires `@Roles('KASIE_FE')` - BLOCKED
- Epic 4: Role-based viewing requires role distinction - BLOCKED

### Solution

Minimal schema alignment focusing on role distinction and critical column names:

1. Create Role entity and roles table (15 production roles)
2. Create PlantationGroup entity (referenced by User)
3. Migrate User entity: `role` enum → `roleId` FK pattern
4. Fix critical column names: `password`, `fullname`, `plantation_group_id`
5. Fix migration: UUID → INTEGER (SERIAL) to match entity
6. Update JWT payload: `role` → `roleId`, `estateId` → `plantationGroupId`
7. Update RolesGuard to check `user.roleId` directly
8. Update @Roles decorators to use production role IDs (UPPERCASE)
9. Update all migrations, seeds, and tests

### Scope

**In Scope:**
- ✅ Role entity + roles table migration (15 roles from production)
- ✅ PlantationGroup entity + table migration
- ✅ User entity migration (enum → FK pattern)
- ✅ Fix migration UUID → INTEGER (entity is already correct)
- ✅ Column name fixes: `password`, `fullname`, `plantation_group_id VARCHAR(10)`
- ✅ RolesGuard refactor (check `user.roleId` directly, no eager loading)
- ✅ JWT payload update (`role` → `roleId`, `estateId` → `plantationGroupId`)
- ✅ Update @Roles decorators to UPPERCASE (KASIE_PG, KASIE_FE)
- ✅ Seed data for 15 production roles
- ✅ Update all migrations from Story 1.2-1.5
- ✅ Update all tests (~6 files)
- ✅ Keep extra columns: `is_first_time`, `failed_login_attempts`, `locked_until`, `last_login`
- ✅ Validation: `@Roles('KASIE_PG')` and `@Roles('KASIE_FE')` work correctly

**Out of Scope:**
- ❌ Missing columns: `email`, `phone`, `address`, `picture_url`, `device_token`, `index`, `is_active` (defer)
- ❌ Story 1.6 implementation (will rebuild after this fix)
- ❌ Epic 2-4 implementation (this only unblocks them)
- ❌ Production deployment

## Context for Development

### Codebase Patterns (from project-context.md)

1. **Entity Pattern:** TypeORM entities with decorators, snake_case column names mapped to camelCase properties
2. **FK Relations:** Use `@ManyToOne` with `@JoinColumn` for foreign key relationships
3. **JWT Pattern:** AuthService generates JWT with user info, payload stored as flat object
4. **RBAC Pattern:** RolesGuard reads `user` from request, checks against `@Roles()` decorator values
5. **Migration Pattern:** TypeORM migrations with `up()` and `down()` methods
6. **Naming:** kebab-case files, PascalCase classes, camelCase variables, UPPER_SNAKE constants
7. **Error Messages:** Bahasa Indonesia for user-facing text

### Technical Decisions

**Decision 1: User.id Type**
- Entity already uses `@PrimaryGeneratedColumn()` which is INTEGER ✅
- Migration incorrectly uses UUID - NEEDS FIX
- Operators entity uses `userId: number` - compatible with INTEGER

**Decision 2: Password Column Type**
- Current: `password_hash VARCHAR(255)`
- Production: `password TEXT`
- **Rationale:** Production uses TEXT type. bcrypt hashes are ~60 chars, but TEXT is production standard. Match production exactly.

**Decision 3: Roles Table Timestamps**
- **VERIFIED via psql 2026-02-01:** Production roles table HAS `created_at` and `updated_at` columns (TIMESTAMPTZ)
- Role entity includes timestamps ✅ - matches production

**Decision 2: JWT Payload Structure**
```typescript
// BEFORE (current)
{ sub: 1, username: 'x', role: 'KASIE', estateId: 'uuid' }

// AFTER (aligned)
{ sub: 1, username: 'x', roleId: 'KASIE_PG', plantationGroupId: 'PG001' }
```

**Decision 3: RolesGuard Implementation**
- No eager loading of role relation
- Guard reads `roleId` from JWT payload directly
- `@Roles('KASIE_PG')` matches against `user.roleId === 'KASIE_PG'`

**Decision 4: Role ID Format**
- Use UPPERCASE IDs matching production: `KASIE_PG`, `KASIE_FE`, `OPERATOR`, `MANDOR`, etc.
- All @Roles decorators updated to UPPERCASE

**Decision 5: Extra Columns**
- Keep security columns: `is_first_time`, `failed_login_attempts`, `locked_until`, `last_login`
- These are Fase 2 enhancements not in production schema

**Decision 6: PlantationGroup Reference**
- Unit entity already has `plantationGroupId: string | null` (fstrack-tractor-api/src/shared/entities/unit.entity.ts:55-60)
- User will use same pattern

---

## Implementation Plan

### Task 1: Create Role Entity and Module

- [ ] **Task 1.1: Create Role entity**
  - File: `fstrack-tractor-api/src/roles/entities/role.entity.ts` (CREATE)
  - Action: Create TypeORM entity matching production schema
  ```typescript
  import {
    Entity,
    PrimaryColumn,
    Column,
    CreateDateColumn,
    UpdateDateColumn,
  } from 'typeorm';

  @Entity('roles')
  export class Role {
    @PrimaryColumn({ type: 'varchar', length: 32 })
    id: string;  // e.g., 'KASIE_PG', 'KASIE_FE'

    @Column({ type: 'varchar', length: 255 })
    name: string;  // e.g., 'Kasie FE PG'

    @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
    createdAt: Date;

    @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
    updatedAt: Date;
  }
  ```

- [ ] **Task 1.2: Create RolesModule**
  - File: `fstrack-tractor-api/src/roles/roles.module.ts` (CREATE)
  - Action: Create module with TypeOrmModule.forFeature([Role])
  ```typescript
  import { Module } from '@nestjs/common';
  import { TypeOrmModule } from '@nestjs/typeorm';
  import { Role } from './entities/role.entity';

  @Module({
    imports: [TypeOrmModule.forFeature([Role])],
    exports: [TypeOrmModule],
  })
  export class RolesModule {}
  ```

- [ ] **Task 1.3: Create barrel files**
  - File: `fstrack-tractor-api/src/roles/entities/index.ts` (CREATE)
  - Content: `export * from './role.entity';`
  - File: `fstrack-tractor-api/src/roles/index.ts` (CREATE)
  - Content: `export * from './roles.module'; export * from './entities';`

---

### Task 2: Create PlantationGroup Entity and Module

- [ ] **Task 2.1: Create PlantationGroup entity**
  - File: `fstrack-tractor-api/src/plantation-groups/entities/plantation-group.entity.ts` (CREATE)
  - Action: Create TypeORM entity matching production schema
  - **NOTE:** Production plantation_groups table has NO timestamps - this is intentional, not an oversight
  ```typescript
  import { Entity, PrimaryColumn, Column } from 'typeorm';

  /**
   * PlantationGroup Entity
   * Maps to 'plantation_groups' table in production Bulldozer DB
   *
   * NOTE: No timestamps by design - matches production schema exactly
   */
  @Entity('plantation_groups')
  export class PlantationGroup {
    @PrimaryColumn({ type: 'varchar', length: 10 })
    id: string;  // e.g., 'PG001'

    @Column({ type: 'varchar', length: 100 })
    name: string;
  }
  ```

- [ ] **Task 2.2: Create PlantationGroupsModule**
  - File: `fstrack-tractor-api/src/plantation-groups/plantation-groups.module.ts` (CREATE)
  - Action: Create module with TypeOrmModule.forFeature([PlantationGroup])

- [ ] **Task 2.3: Create barrel files**
  - Files: `fstrack-tractor-api/src/plantation-groups/entities/index.ts`, `fstrack-tractor-api/src/plantation-groups/index.ts` (CREATE)

---

### Task 3: Create Database Migrations

- [ ] **Task 3.1: Create roles table migration**
  - File: `fstrack-tractor-api/src/database/migrations/1738571000000-create-roles-table.ts` (CREATE)
  - Action: Create roles table and seed 15 production roles
  ```typescript
  import { MigrationInterface, QueryRunner } from 'typeorm';

  export class CreateRolesTable1738571000000 implements MigrationInterface {
    name = 'CreateRolesTable1738571000000';

    public async up(queryRunner: QueryRunner): Promise<void> {
      await queryRunner.query(`
        CREATE TABLE roles (
          id VARCHAR(32) PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          created_at TIMESTAMPTZ DEFAULT NOW(),
          updated_at TIMESTAMPTZ DEFAULT NOW()
        )
      `);

      await queryRunner.query(`
        INSERT INTO roles (id, name) VALUES
          ('ADMINISTRASI', 'Administrasi FE FS'),
          ('ADMINISTRASI_PG', 'Administrasi FE PG'),
          ('ASSISTANT_MANAGER', 'SubDep Head FE FS'),
          ('DEPUTY', 'Deputy'),
          ('KABAG_FIELD_ESTABLISHMENT', 'SubDep Head FE PG'),
          ('KASIE_FE', 'Kasie FE FS'),
          ('KASIE_PG', 'Kasie FE PG'),
          ('MANAGER', 'Manager FE FS'),
          ('MANAGER_FE_PG', 'Manager FE PG'),
          ('MANDOR', 'Mandor'),
          ('MASTER_LOKASI', 'Master Lokasi'),
          ('OPERATOR', 'Operator'),
          ('OPERATOR_PG1', 'Operator PG 1'),
          ('PG_MANAGER', 'PG Manager'),
          ('SUPERADMIN', 'Super Admin')
      `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
      await queryRunner.query(`DROP TABLE IF EXISTS roles`);
    }
  }
  ```

- [ ] **Task 3.2: Create plantation_groups table migration**
  - File: `fstrack-tractor-api/src/database/migrations/1738571500000-create-plantation-groups-table.ts` (CREATE)
  - Action: Create plantation_groups table
  ```typescript
  import { MigrationInterface, QueryRunner } from 'typeorm';

  export class CreatePlantationGroupsTable1738571500000 implements MigrationInterface {
    name = 'CreatePlantationGroupsTable1738571500000';

    public async up(queryRunner: QueryRunner): Promise<void> {
      await queryRunner.query(`
        CREATE TABLE plantation_groups (
          id VARCHAR(10) PRIMARY KEY,
          name VARCHAR(100) NOT NULL
        )
      `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
      await queryRunner.query(`DROP TABLE IF EXISTS plantation_groups`);
    }
  }
  ```

- [ ] **Task 3.3: Update users table migration**
  - File: `fstrack-tractor-api/src/database/migrations/1738572000000-create-users-table.ts` (UPDATE)
  - Action: Complete rewrite - fix UUID→INTEGER and column names
  ```typescript
  import { MigrationInterface, QueryRunner } from 'typeorm';

  export class CreateUsersTable1738572000000 implements MigrationInterface {
    name = 'CreateUsersTable1738572000000';

    public async up(queryRunner: QueryRunner): Promise<void> {
      await queryRunner.query(`
        CREATE TABLE users (
          id SERIAL PRIMARY KEY,
          fullname VARCHAR(255) NOT NULL,
          username VARCHAR(50) UNIQUE NOT NULL,
          password TEXT NOT NULL,
          role_id VARCHAR(32) REFERENCES roles(id),
          plantation_group_id VARCHAR(10) REFERENCES plantation_groups(id),
          is_first_time BOOLEAN DEFAULT TRUE,
          failed_login_attempts INT DEFAULT 0,
          locked_until TIMESTAMP,
          last_login TIMESTAMP,
          created_at TIMESTAMP DEFAULT NOW(),
          updated_at TIMESTAMP DEFAULT NOW()
        )
      `);

      await queryRunner.query(
        `CREATE INDEX idx_users_username ON users(username)`,
      );
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
      await queryRunner.query(`DROP INDEX IF EXISTS idx_users_username`);
      await queryRunner.query(`DROP TABLE IF EXISTS users`);
    }
  }
  ```

- [ ] **Task 3.4: Verify operators table migration**
  - File: `fstrack-tractor-api/src/database/migrations/*-create-operators-table.ts` (VERIFY)
  - Action: Check that operators.user_id is INTEGER (not UUID)
  - Notes: The operators entity uses `userId: number` which expects INTEGER. If the operators migration uses UUID for user_id, update it to INTEGER.

---

### Task 4: Update User Entity

- [ ] **Task 4.1: Update User entity**
  - File: `fstrack-tractor-api/src/users/entities/user.entity.ts` (UPDATE)
  - Action: Complete rewrite to match production schema
  - **FULL REPLACEMENT CODE:**
  ```typescript
  import {
    Entity,
    Column,
    PrimaryGeneratedColumn,
    CreateDateColumn,
    UpdateDateColumn,
    Index,
  } from 'typeorm';

  @Entity('users')
  export class User {
    @PrimaryGeneratedColumn()
    id: number;

    @Column({ type: 'varchar', length: 50, unique: true })
    @Index('idx_users_username')
    username: string;

    @Column({ type: 'text' })
    password: string;  // was: passwordHash with column 'password_hash'

    @Column({ type: 'varchar', length: 255 })
    fullname: string;  // was: fullName with column 'full_name'

    @Column({ name: 'role_id', type: 'varchar', length: 32, nullable: true })
    roleId: string | null;  // was: role: UserRole (enum)

    @Column({ name: 'plantation_group_id', type: 'varchar', length: 10, nullable: true })
    plantationGroupId: string | null;  // was: estateId: string (UUID)

    @Column({ name: 'is_first_time', type: 'boolean', default: true })
    isFirstTime: boolean;

    @Column({ name: 'failed_login_attempts', type: 'int', default: 0 })
    failedLoginAttempts: number;

    @Column({ name: 'locked_until', type: 'timestamp', nullable: true })
    lockedUntil: Date | null;

    @Column({ name: 'last_login', type: 'timestamp', nullable: true })
    lastLogin: Date | null;

    @CreateDateColumn({ name: 'created_at' })
    createdAt: Date;

    @UpdateDateColumn({ name: 'updated_at' })
    updatedAt: Date;
  }
  ```

- [ ] **Task 4.2: Delete UserRole enum**
  - File: `fstrack-tractor-api/src/users/enums/user-role.enum.ts` (DELETE)
  - Action: Remove file completely - no longer needed

- [ ] **Task 4.3: Delete enums folder if empty**
  - Check: Does `fstrack-tractor-api/src/users/enums/` contain other files?
  - If only user-role.enum.ts: DELETE the entire enums folder
  - If other enums exist: Update index.ts to remove user-role.enum export

---

### Task 5: Update Auth System

- [ ] **Task 5.1: Update JwtPayload interface**
  - File: `fstrack-tractor-api/src/auth/strategies/jwt.strategy.ts` (UPDATE)
  - Action: Update JwtPayload interface and validate() method
  ```typescript
  export interface JwtPayload {
    sub: number;
    username: string;
    roleId: string;              // was: role
    plantationGroupId: string | null;  // was: estateId
  }

  // In validate() method:
  return {
    id: payload.sub,
    username: payload.username,
    roleId: payload.roleId,                    // was: role
    plantationGroupId: payload.plantationGroupId,  // was: estateId
  };
  ```

- [ ] **Task 5.2: Update AuthService**
  - File: `fstrack-tractor-api/src/auth/auth.service.ts` (UPDATE)
  - Changes:
    - Line ~45: `user.passwordHash` → `user.password`
    - Lines ~74-78: Update payload structure
    - Lines ~83-88: Update user response object
  ```typescript
  // validateUser method - update bcrypt.compare
  const isPasswordValid = await bcrypt.compare(password, user.password);

  // login method - update payload
  const payload = {
    sub: user.id,
    username: user.username,
    roleId: user.roleId,
    plantationGroupId: user.plantationGroupId,
  };

  // login method - update user response
  user: {
    id: user.id,
    fullname: user.fullname,
    roleId: user.roleId,
    plantationGroupId: user.plantationGroupId,
    isFirstTime: user.isFirstTime,
  }
  ```

- [ ] **Task 5.3: Update AuthResponseDto**
  - File: `fstrack-tractor-api/src/auth/dto/auth-response.dto.ts` (UPDATE)
  - Update UserResponseDto properties and @ApiProperty examples

- [ ] **Task 5.4: Update CurrentUser decorator**
  - File: `fstrack-tractor-api/src/auth/decorators/current-user.decorator.ts` (UPDATE)
  - Action: Update AuthenticatedRequest type
  - **BUG FIX:** Also change `id: string` to `id: number` (existing bug)
  ```typescript
  type AuthenticatedRequest = Request & {
    user: {
      id: number;  // FIX: was string, should be number
      username?: string;
      roleId?: string;
      plantationGroupId?: string | null;
    };
  };
  ```

- [ ] **Task 5.5: Update RolesGuard**
  - File: `fstrack-tractor-api/src/auth/guards/roles.guard.ts` (UPDATE)
  - Changes:
    - Update JwtUser interface: `role` → `roleId`
    - Update role check: `user?.role` → `user?.roleId`

---

### Task 6: Update Controllers with @Roles Decorators

- [ ] **Task 6.1: Update SchedulesController**
  - File: `fstrack-tractor-api/src/schedules/schedules.controller.ts` (UPDATE)
  - Action: Change @Roles to UPPERCASE
  - `@Roles('kasie_pg')` → `@Roles('KASIE_PG')`
  - `@Roles('kasie_fe')` → `@Roles('KASIE_FE')`
  - `@Roles('kasie_pg', 'kasie_fe')` → `@Roles('KASIE_PG', 'KASIE_FE')`

- [ ] **Task 6.2: Update OperatorsController**
  - File: `fstrack-tractor-api/src/operators/operators.controller.ts` (UPDATE)
  - Action: `@Roles('kasie_fe')` → `@Roles('KASIE_FE')`

---

### Task 7: Update UsersModule (NO UsersService changes needed)

- [ ] **Task 7.1: Update UsersModule**
  - File: `fstrack-tractor-api/src/users/users.module.ts` (UPDATE)
  - Action: Remove UserRole enum import if present
  - **NOTE:** UsersService does NOT need changes - it uses id-based operations only (findById, findByUsername, update by id). These work regardless of schema changes.

---

### Task 8: Update Seed Service

- [ ] **Task 8.1: Update SeedService**
  - File: `fstrack-tractor-api/src/database/seed.service.ts` (UPDATE)
  - Action: Remove UserRole import, update user creation, handle existing user migration
  - **IMPORTANT:** Handle existing `dev_kasie` user gracefully
  ```typescript
  // Remove: import { UserRole } from '../users/enums/user-role.enum';

  private async seedDevUser() {
    // Check for OLD dev_kasie user (from previous implementation)
    const oldDevUser = await this.usersRepository.findOne({
      where: { username: 'dev_kasie' },
    });
    if (oldDevUser) {
      this.logger.log('Found old dev_kasie user - will be replaced by new dev users');
      await this.usersRepository.delete({ username: 'dev_kasie' });
    }

    // Seed new dev users with distinct roles
    const devUsers = [
      { username: 'dev_kasie_pg', fullname: 'Dev Kasie PG User', roleId: 'KASIE_PG' },
      { username: 'dev_kasie_fe', fullname: 'Dev Kasie FE User', roleId: 'KASIE_FE' },
      { username: 'dev_operator', fullname: 'Dev Operator User', roleId: 'OPERATOR' },
    ];

    const passwordHash = await bcrypt.hash('DevPassword123', 10);

    for (const userData of devUsers) {
      const exists = await this.usersRepository.findOne({
        where: { username: userData.username },
      });
      if (exists) {
        this.logger.log(`Dev user already exists: ${userData.username}`);
        continue;
      }

      const user = this.usersRepository.create({
        ...userData,
        password: passwordHash,
        isFirstTime: true,
      });
      await this.usersRepository.save(user);
      this.logger.log(`Dev user seeded: ${userData.username}`);
    }
  }
  ```

---

### Task 9: Update AppModule

- [ ] **Task 9.1: Register new modules**
  - File: `fstrack-tractor-api/src/app.module.ts` (UPDATE)
  - Action: Import and add RolesModule, PlantationGroupsModule

---

### Task 10: Update All Tests

- [ ] **Task 10.1: Update auth.service.spec.ts**
  - File: `fstrack-tractor-api/src/auth/auth.service.spec.ts` (UPDATE)
  - Action: Update mockUser, remove UserRole import

- [ ] **Task 10.2: Update roles.guard.spec.ts**
  - File: `fstrack-tractor-api/src/auth/guards/roles.guard.spec.ts` (UPDATE)
  - Action: Update mock context to use roleId, update all role strings to UPPERCASE

- [ ] **Task 10.3: Update users.service.spec.ts**
  - File: `fstrack-tractor-api/src/users/users.service.spec.ts` (UPDATE)
  - Action: Update mock user schema

- [ ] **Task 10.4: Update seed.service.spec.ts**
  - File: `fstrack-tractor-api/src/database/seed.service.spec.ts` (UPDATE)
  - Action: Remove UserRole import, update test expectations

- [ ] **Task 10.5: Update operators.service.spec.ts**
  - File: `fstrack-tractor-api/src/operators/operators.service.spec.ts` (UPDATE)
  - Action: Update User mocks to use new schema
  - Change: `fullName` → `fullname`, `role` → `roleId`, `passwordHash` → `password`, `estateId` → `plantationGroupId`

- [ ] **Task 10.6: Update operators.controller.spec.ts**
  - File: `fstrack-tractor-api/src/operators/operators.controller.spec.ts` (UPDATE)
  - Action: Update any User mocks or RBAC test expectations
  - Change: If tests mock JWT user, update `role` → `roleId`

- [ ] **Task 10.7: Update users.controller.spec.ts**
  - File: `fstrack-tractor-api/src/users/users.controller.spec.ts` (UPDATE)
  - Action: Verify user mock uses `{ id: number }` (already correct, but verify no other schema refs)

---

### Task 11: Update E2E Tests (CRITICAL)

- [ ] **Task 11.1: Update auth.e2e-spec.ts**
  - File: `fstrack-tractor-api/test/auth.e2e-spec.ts` (UPDATE)
  - **CRITICAL CHANGES:**
    - Line 17: Change `id` from UUID string to INTEGER (e.g., `id: 1`)
    - Line 20-22: Change `fullName` → `fullname`, `role` → `roleId: 'KASIE_PG'`, `estateId` → `plantationGroupId`
    - Lines 64-78, 80-94: Update raw SQL INSERT statements:
      ```sql
      -- OLD (wrong)
      INSERT INTO users (id, username, password_hash, full_name, role, estate_id, ...)

      -- NEW (correct)
      INSERT INTO users (username, fullname, password, role_id, plantation_group_id, ...)
      VALUES ($1, $2, $3, $4, $5, ...)
      ```
    - **NOTE:** Remove `id` from INSERT - let SERIAL auto-generate
    - Use RETURNING clause if test needs the generated ID: `... RETURNING id`

- [ ] **Task 11.2: Update users.e2e-spec.ts**
  - File: `fstrack-tractor-api/test/e2e/users.e2e-spec.ts` (UPDATE)
  - **CRITICAL CHANGES:**
    - Line 17: Change `id` from UUID to omit (let DB generate)
    - Lines 61-75: Update raw SQL INSERT with correct column names
    - Line 80-82: Update any UPDATE queries using old column names

---

### Task 12: Verification and Testing

- [ ] **Task 12.1: Grep for missed @Roles decorators**
  - Command: `grep -rn "@Roles" fstrack-tractor-api/src --include="*.ts"`
  - Action: Verify ALL occurrences updated to UPPERCASE
  - **CRITICAL:** If any lowercase `@Roles('kasie_pg')` remain, they will cause 403 errors

- [ ] **Task 12.2: Run linting**
  - Command: `cd fstrack-tractor-api && npm run lint`
  - Expected: No errors

- [ ] **Task 12.3: Run build**
  - Command: `cd fstrack-tractor-api && npm run build`
  - Expected: Compiles successfully

- [ ] **Task 12.4: Run unit tests**
  - Command: `cd fstrack-tractor-api && npm test`
  - Expected: All tests pass

- [ ] **Task 12.5: Run E2E tests**
  - Command: `cd fstrack-tractor-api && npm run test:e2e`
  - Expected: All E2E tests pass

- [ ] **Task 12.6: Run migrations (on fresh test DB)**
  - Command: `cd fstrack-tractor-api && npm run migration:run`
  - Expected: All migrations apply successfully in order (roles → plantation_groups → users)

- [ ] **Task 12.7: Manual RBAC verification**
  - **Test 1:** Login as dev_kasie_pg
    ```bash
    curl -X POST http://localhost:3000/api/v1/auth/login \
      -H "Content-Type: application/json" \
      -d '{"username":"dev_kasie_pg","password":"DevPassword123"}'
    ```
    Save the accessToken.
  - **Test 2:** POST /schedules as kasie_pg (should succeed 201)
    ```bash
    curl -X POST http://localhost:3000/api/v1/schedules \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"workDate":"2026-02-15","pattern":"Rotasi","shift":"Pagi"}'
    ```
  - **Test 3:** POST /schedules as dev_operator (should fail 403)
    Login as dev_operator, attempt same POST, verify 403 Forbidden

---

## Acceptance Criteria

### AC1: Role FK Pattern Works
- [ ] **Given** the database has roles table with 15 production roles
- [ ] **When** a new user is created with roleId='KASIE_PG'
- [ ] **Then** the user is saved with role_id FK pointing to roles.id='KASIE_PG'

### AC2: JWT Contains Correct Payload
- [ ] **Given** a user with roleId='KASIE_PG' and plantationGroupId='PG001'
- [ ] **When** the user logs in successfully
- [ ] **Then** JWT payload contains `{ sub: number, username: string, roleId: 'KASIE_PG', plantationGroupId: 'PG001' }`

### AC3: RBAC Guards Work with UPPERCASE Role IDs
- [ ] **Given** an endpoint decorated with `@Roles('KASIE_PG')`
- [ ] **When** a request is made by user with roleId='KASIE_PG'
- [ ] **Then** the request is allowed (200/201)

- [ ] **Given** an endpoint decorated with `@Roles('KASIE_PG')`
- [ ] **When** a request is made by user with roleId='OPERATOR'
- [ ] **Then** the request is denied (403 Forbidden)

### AC4: kasie_pg vs kasie_fe Distinction Works
- [ ] **Given** POST /api/v1/schedules is decorated with `@Roles('KASIE_PG')`
- [ ] **When** user with roleId='KASIE_FE' makes request
- [ ] **Then** request is denied (403) - KASIE_FE cannot CREATE

- [ ] **Given** PATCH /api/v1/schedules/:id is decorated with `@Roles('KASIE_FE')`
- [ ] **When** user with roleId='KASIE_PG' makes request
- [ ] **Then** request is denied (403) - KASIE_PG cannot ASSIGN

### AC5: Column Names Match Production
- [ ] **Given** the User entity
- [ ] **When** data is saved to database
- [ ] **Then** column names are: `fullname`, `password`, `plantation_group_id`

### AC6: All Tests Pass
- [ ] **Given** all code changes are complete
- [ ] **When** `npm run lint && npm run build && npm test` is executed
- [ ] **Then** all commands complete successfully with zero errors

### AC7: Dev Users Seeded Correctly
- [ ] **Given** staging environment starts
- [ ] **When** SeedService runs
- [ ] **Then** dev users are created with correct roleId values (KASIE_PG, KASIE_FE, OPERATOR)

---

## Additional Context

### Production Schema Reference (Verified 2026-02-01 via psql)

**users table:**
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fullname VARCHAR(255) NOT NULL,
  username VARCHAR(255) NOT NULL UNIQUE,
  password TEXT NOT NULL,
  role_id VARCHAR(32) REFERENCES roles(id),
  plantation_group_id VARCHAR(10) REFERENCES plantation_groups(id),
  is_active BOOLEAN DEFAULT true,
  device_token TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

**roles table (15 roles verified):**
```
ADMINISTRASI, ADMINISTRASI_PG, ASSISTANT_MANAGER, DEPUTY, KABAG_FIELD_ESTABLISHMENT,
KASIE_FE, KASIE_PG, MANAGER, MANAGER_FE_PG, MANDOR, MASTER_LOKASI, OPERATOR,
OPERATOR_PG1, PG_MANAGER, SUPERADMIN
```

### Migration Order (Critical!)

```
1. CREATE roles table (1738571000000) - no dependencies
2. CREATE plantation_groups table (1738571500000) - no dependencies
3. CREATE users table (1738572000000) - depends on 1 and 2
4. VERIFY operators table migration - ensure user_id is INTEGER
```

### Risk Items (Pre-Mortem)

1. **Migration Ordering:** If migrations run out of order, FK constraints will fail
2. **Test Data:** All test mocks must be updated
3. **Operator FK:** Verify operators.user_id is INTEGER (not UUID)
4. **JWT Invalidation:** Existing dev JWTs will have old payload structure

### Notes

**Why This Happened:**
- Story 1.1 correctly documented production schema (FK pattern, 15 roles)
- Story 1.2 implementation chose enum pattern for "simplicity"
- No validation step between schema documentation and implementation

**Lesson Learned:**
- Add explicit schema validation checkpoint after entity creation
- Column names MUST match production exactly

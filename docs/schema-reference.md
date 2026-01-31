# Schema Reference - FsTrack Tractor

> **Generated:** 2026-01-31
> **Database:** PostgreSQL 15+
> **Purpose:** Production Bulldozer DB Schema Documentation for Fase 2 Development

---

## Overview

This document contains the discovered schema from production database for FsTrack Tractor Fase 2 implementation.

**Critical Findings:**
- ✅ All 5 core tables exist: `schedules`, `operators`, `units`, `locations`, `users`
- ⚠️ Status values differ from expectation (see [Schedules Table](#schedules-table))
- ℹ️ Roles implemented as separate table (not enum)
- ℹ️ FK relationships already established

---

## Tables

### schedules

Primary table for work plan management.

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NOT NULL | uuid_generate_v4() | Primary Key |
| `work_date` | date | NOT NULL | - | Tanggal kerja |
| `pattern` | varchar(16) | NOT NULL | - | Pola kerja (e.g., "Rotasi") |
| `shift` | varchar(16) | NULL | - | Shift pagi/siang/malam |
| `status` | varchar(16) | NOT NULL | 'OPEN' | Status work plan |
| `start_time` | timestamptz | NULL | - | Waktu mulai |
| `end_time` | timestamptz | NULL | - | Waktu selesai |
| `notes` | text | NULL | - | Catatan |
| `created_at` | timestamptz | NOT NULL | now() | Auto-generated |
| `updated_at` | timestamptz | NOT NULL | now() | Auto-updated |
| `location_id` | varchar(32) | NULL | - | FK → locations.id |
| `unit_id` | varchar(16) | NULL | - | FK → units.id |
| `operator_id` | integer | NULL | - | FK → operators.id |
| `report_id` | uuid | NULL | - | FK → reports.id |

**Constraints:**
- Primary Key: `id`
- Unique: `report_id`
- Foreign Keys:
  - `location_id` → `locations(id)`
  - `unit_id` → `units(id)`
  - `operator_id` → `operators(id)`
  - `report_id` → `reports(id)`

**Status Values (Discovered):**
| Value | Description |
|-------|-------------|
| `OPEN` | Work plan baru dibuat (default) |
| `CLOSED` | Work plan ditutup |
| `CANCEL` | Work plan dibatalkan |

**⚠️ NOTE:** Production status values (`OPEN`, `CLOSED`, `CANCEL`) differ from architecture expectation (`OPEN`, `ASSIGNED`, `IN_PROGRESS`, `COMPLETED`). This needs alignment discussion.

**Current Indexes:**
- `PK_7e33fc2ea755a5765e3564e66dd` (Primary Key on id)
- `REL_ad51a22c4b09f88b0f4e35d044` (Unique on report_id)
- `UQ_ad51a22c4b09f88b0f4e35d044c` (Unique on report_id)

**Recommended Indexes (Not Yet Created):**
- `idx_schedules_operator_id` - For filtering by operator
- `idx_schedules_work_date` - For date range queries
- `idx_schedules_status` - For status filtering

---

### operators

Reference data for operator assignment.

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | integer | NOT NULL | nextval('operators_id_seq') | Primary Key (auto-increment) |
| `user_id` | integer | NULL | - | FK → users.id |
| `unit_id` | varchar(16) | NULL | - | FK → units.id |

**Constraints:**
- Primary Key: `id`
- Unique: `user_id` (one operator per user)
- Foreign Keys:
  - `user_id` → `users(id)` ON DELETE CASCADE
  - `unit_id` → `units(id)` ON DELETE CASCADE

---

### units

Equipment/units reference data.

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | varchar(16) | NOT NULL | - | Primary Key (manual) |
| `name` | varchar(255) | NOT NULL | - | Nama unit |
| `brand` | varchar(255) | NOT NULL | - | Merek unit |
| `threshold_one` | numeric(6,2) | NOT NULL | 2.84 | Threshold 1 |
| `threshold_two` | numeric(6,2) | NOT NULL | 16.6 | Threshold 2 |
| `created_at` | timestamptz | NOT NULL | now() | Auto-generated |
| `updated_at` | timestamptz | NOT NULL | now() | Auto-updated |
| `plantation_group_id` | varchar(10) | NULL | - | FK → plantation_groups.id |
| `node_id` | varchar(16) | NULL | - | FK → nodes.id |

**Constraints:**
- Primary Key: `id`
- Unique: `node_id`
- Foreign Keys:
  - `plantation_group_id` → `plantation_groups(id)`
  - `node_id` → `nodes(id)` ON DELETE SET NULL

---

### locations

Work locations reference data.

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | varchar(32) | NOT NULL | - | Primary Key (manual) |
| `name` | varchar(100) | NOT NULL | - | Nama lokasi |
| `area` | numeric(10,6) | NOT NULL | - | Luas area |
| `polygon` | geometry(Polygon,4326) | NOT NULL | - | GeoJSON polygon |
| `type` | varchar(8) | NULL | - | Tipe lokasi |
| `region_id` | varchar(10) | NULL | - | FK → regions.id |

**Constraints:**
- Primary Key: `id`
- Foreign Keys:
  - `region_id` → `regions(id)`

**Spatial Index:**
- `IDX_ec7526f6817c8d50db2138630f` (GiST index on polygon)

---

### users

User accounts (existing from Fase 1).

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | integer | NOT NULL | nextval('users_id_seq') | Primary Key (auto-increment) |
| `fullname` | varchar(255) | NOT NULL | - | Nama lengkap |
| `username` | varchar(255) | NOT NULL | - | Username (unique) |
| `index` | varchar(255) | NULL | - | Index/nomor Induk |
| `email` | varchar(255) | NULL | - | Email |
| `phone` | varchar(16) | NULL | - | Nomor telepon |
| `address` | text | NULL | - | Alamat |
| `picture_url` | text | NULL | - | URL foto profil |
| `password` | text | NOT NULL | - | Password hash |
| `is_active` | boolean | NOT NULL | true | Status aktif |
| `device_token` | text | NULL | - | FCM device token |
| `created_at` | timestamptz | NOT NULL | now() | Auto-generated |
| `updated_at` | timestamptz | NOT NULL | now() | Auto-updated |
| `role_id` | varchar(32) | NULL | - | FK → roles.id |
| `plantation_group_id` | varchar(10) | NULL | - | FK → plantation_groups.id |

**Constraints:**
- Primary Key: `id`
- Unique: `username`
- Foreign Keys:
  - `role_id` → `roles(id)` ON DELETE RESTRICT
  - `plantation_group_id` → `plantation_groups(id)` ON DELETE RESTRICT

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

**⚠️ NOTE:** Users use `role_id` (FK to roles table), not a simple enum. This allows more flexible role management.

---

## Entity Relationship Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│     users       │     │    operators    │     │     units       │
├─────────────────┤     ├─────────────────┤     ├─────────────────┤
│ PK id (int)     │◄────┤ FK user_id      │     │ PK id (varchar) │
│    fullname     │     │ PK id (int)     │────►│    name         │
│    username     │     │ FK unit_id      │     │    brand        │
│ FK role_id ─────┼────►├─────────────────┘     ├─────────────────┤
└─────────────────┘     └─────────────────┐     └────────┬────────┘
                                          │              │
                                          │     ┌────────┘
                                          │     │
                                          ▼     ▼
                                   ┌─────────────────┐
                                   │    schedules    │
                                   ├─────────────────┤
                                   │ PK id (uuid)    │
                                   │    work_date    │
                                   │    pattern      │
                                   │    shift        │
                                   │    status       │
                                   │ FK operator_id ─┘
                                   │ FK unit_id ─────┐
                                   │ FK location_id  │
                                   ├─────────────────┤
                                   │    start_time   │
                                   │    end_time     │
                                   │    notes        │
                                   │    created_at   │
                                   │    updated_at   │
                                   └─────────────────┘
                                          │
                                          │
                                          ▼
                                   ┌─────────────────┐
                                   │    locations    │
                                   ├─────────────────┤
                                   │ PK id (varchar) │
                                   │    name         │
                                   │    area         │
                                   │    polygon      │
                                   │    type         │
                                   │ FK region_id    │
                                   └─────────────────┘
```

---

## Key Observations for Implementation

### 1. TypeORM Entity Mapping Notes

**schedules table:**
- `id`: UUID (use `@PrimaryGeneratedColumn('uuid')`)
- `operator_id`: INTEGER (not UUID!) - matches operators.id type
- `location_id`: VARCHAR(32) - matches locations.id type
- `unit_id`: VARCHAR(16) - matches units.id type
- `status`: VARCHAR(16) with default 'OPEN'

**operators table:**
- `id`: INTEGER auto-increment (use `@PrimaryGeneratedColumn()`)
- `user_id`: INTEGER (FK to users.id)

**units table:**
- `id`: VARCHAR(16) - manual PK, not auto-generated
- `threshold_one`, `threshold_two`: NUMERIC(6,2)

**locations table:**
- `id`: VARCHAR(32) - manual PK
- `polygon`: GEOMETRY(Polygon,4326) - PostGIS type
- `area`: NUMERIC(10,6)

### 2. Critical Differences from Architecture

| Aspect | Expected | Actual (Production) | Action Needed |
|--------|----------|---------------------|---------------|
| Status values | OPEN, ASSIGNED, IN_PROGRESS, COMPLETED | OPEN, CLOSED, CANCEL | ⚠️ Align with Product Owner |
| Role implementation | Enum on users table | Separate roles table | ℹ️ Use existing pattern |
| schedules.operator_id | Expected UUID | INTEGER (matches operators.id) | ℹ️ Use integer type |

### 3. Safety Reminders

**READ-ONLY Discovery:** ✅ All queries used were SELECT only

**No Migration Changes to Existing Tables:**
- schedules, operators, units, locations tables already exist
- Only create TypeORM entities - NO migrations should ALTER these tables
- TypeORM `synchronize: false` in production

---

## SQL Reference Queries

### Get schedules with related data
```sql
SELECT
    s.id, s.work_date, s.pattern, s.shift, s.status,
    l.name as location_name,
    u.name as unit_name,
    op.user_id as operator_user_id
FROM schedules s
LEFT JOIN locations l ON s.location_id = l.id
LEFT JOIN units u ON s.unit_id = u.id
LEFT JOIN operators op ON s.operator_id = op.id
WHERE s.status = 'OPEN';
```

### Get operators with user info
```sql
SELECT
    o.id,
    u.fullname as operator_name,
    u.username,
    r.name as role_name,
    un.name as assigned_unit
FROM operators o
JOIN users u ON o.user_id = u.id
LEFT JOIN roles r ON u.role_id = r.id
LEFT JOIN units un ON o.unit_id = un.id;
```

---

*Document generated by FsTrack Tractor Dev Team*
*Story: 1.1 - Production Schema Discovery & Validation*

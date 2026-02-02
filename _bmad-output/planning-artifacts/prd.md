---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7]
inputDocuments:
  - project-context.md
  - docs/planning-phase/phase2.md
  - docs/planning-phase/prd.md
  - docs/planning-phase/architecture.md
  - docs/planning-phase/epics.md
workflowType: 'prd'
project_name: 'fstrack-tractor'
user_name: 'V'
date: '2026-01-29'
documentCounts:
  briefs: 0
  research: 0
  brainstorming: 0
  projectDocs: 5
---

# Product Requirements Document - FSTrack-Tractor Fase 2

**PRODUCTION SCHEMA UPDATE (2026-01-31):**
This document has been updated to reflect actual production database schema discovered in Story 1.1.
Key changes:
- `operator_id` is **INTEGER** (not UUID!) - matches operators.id (auto-increment)
- `location_id` is **VARCHAR(32)** (not UUID!) - manual ID codes like "LOC001"
- `unit_id` is **VARCHAR(16)** (not UUID!) - manual ID codes like "UNIT01"
- Status values: OPEN/CLOSED/CANCEL (production), NOT ASSIGNED/IN_PROGRESS/COMPLETED
- API JSON uses **camelCase** (workDate, operatorId), database uses **snake_case** (work_date, operator_id)

See `/home/v/work/fstrack-tractor/docs/schema-reference.md` for complete production schema.

**Author:** V
**Date:** 2026-01-29
**Scope:** Fase 2 - Work Plan Management

---

## Executive Summary

FSTrack-Tractor Fase 2 adalah kelanjutan dari Fase 1 (Login & Main Page) yang berfokus pada **implementasi penuh fitur Work Plan Management**. Di Fase 1, menu "Rencana Kerja" masih placeholder. Fase 2 akan menyelesaikan alur lengkap CREATE, ASSIGN, dan VIEW work plan sesuai workflow operasional perkebunan.

### Scope PRD Fase 2

| In Scope | Out of Scope (Fase 3+) |
|----------|------------------------|
| Work Plan CREATE (Kasie PG) | Live GPS Tracking |
| Work Plan ASSIGN (Kasie FE) | Activity Result submission |
| Work Plan VIEW (All roles) | Check Location feature |
| Integrasi user dummy (all roles) | Notification system |
| Real live testing capability | Dashboard Analytics (Web) |
| Schedule CRUD operations | Biometric authentication |

### Fase 2 Roadmap Connection

Fase 2 adalah jembatan antara Fase 1 (foundation) dan Fase 3+ (tracking, activity, approval):
- Fase 1: Login + Main Page (✅ DONE)
- **Fase 2: Work Plan Management** (CURRENT) ← Fokus PRD ini
- Fase 3+: GPS Tracking + Activity + Approval (Future)

### What Makes This Special

1. **Role-Based Workflow** - Setiap role punya fungsi spesifik: Kasie PG CREATE, Kasie FE ASSIGN, semua role VIEW
2. **Production Schema Ready** - Menggunakan schema schedules/operators/units yang sudah ada di production DB
3. **Real Live Testing** - Integrasi dengan user dummy (semua role) untuk validasi end-to-end
4. **Proof of Finish Terukur** - Create → Assign → View flow harus working untuk semua role

### Tech Stack (Inherited from Fase 1)

- **Frontend:** Flutter (mobile) dengan BLoC state management
- **Backend:** NestJS dengan modular architecture
- **Database:** PostgreSQL dengan schema schedules/operators/units
- **Auth:** JWT + bcrypt (existing from Fase 1)
- **Roles:** kasie_pg, kasie_fe, operator, mandor, admin

---

## Project Classification

**Technical Type:** Mobile App (Flutter) + SaaS B2B Backend (NestJS)
**Domain:** General (Plantation Operations)
**Complexity:** Medium (Work Plan CRUD dengan role-based workflow)
**Project Context:** Brownfield - extending existing system (Fase 1 foundation)

### Target Roles (Same as Fase 1)

1. **Kasie PG** - Plantation Manager (CREATE work plan)
2. **Kasie FE** - Field Executive Manager (ASSIGN work plan to Operator)
3. **Operator** - Tractor operator (VIEW assigned work plans)
4. **Mandor** - Supervisor (VIEW only)
5. **Estate PG** - Estate manager (VIEW only)
6. **Admin** - System administrator (VIEW + testing)

### Schema Mapping

**Tabel schedules (work plan):**
- `id` (UUID) - Unique identifier
- `work_date` (date) - Tanggal kerja
- `pattern` (varchar) - Pola kerja
- `shift` (varchar) - Shift kerja
- `status` (varchar) - Status: OPEN/CLOSED/CANCEL (production values)
- `location_id` (VARCHAR(32) FK) - Lokasi kerja → locations.id
- `unit_id` (VARCHAR(16) FK) - Unit traktor → units.id
- `operator_id` (INTEGER FK) - Operator yang ditugaskan → operators.id
- `report_id` (UUID FK) - Report terkait (nullable di Fase 2)
- `start_time` (timestamptz) - Waktu mulai (nullable)
- `end_time` (timestamptz) - Waktu selesai (nullable)
- `notes` (text) - Catatan (nullable)

### Permission Matrix (Fase 2 Scope)

| Operation | Kasie PG | Kasie FE | Operator | Mandor | Estate PG | Admin |
|-----------|----------|----------|----------|--------|-----------|-------|
| CREATE work plan | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| ASSIGN work plan | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| VIEW work plans | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

### Risk Mitigations

| Risk | Mitigation |
|------|------------|
| Schema mismatch | Gunakan schema production yang sudah ada (schedules/operators/units) - VALIDATED in Story 1.1 |\
| User testing gap | Buat minimal 1 akun per role untuk real live testing |
| Role permission error | Validasi permission matrix dengan enum roles dari Fase 1 |
| State transition bug | Implement state machine: OPEN → CLOSED (status values match production) |

---

## Success Criteria

### User Success

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Workflow Completion** | Kasie PG can CREATE work plan successfully | Functional test |
| **Workflow Completion** | Kasie FE can ASSIGN work plan successfully | Functional test |
| **Workflow Completion** | Operator can VIEW assigned work plans | Functional test |
| **Data Consistency** | Work plan status updates correctly across roles | Database validation |
| **User Testing** | Min 1 user per role untuk real live testing | Test coverage |

**User Success Scenarios:**
- **Kasie PG:** Buka app → tap "Buat Rencana Kerja" → isi form → submit → work plan CREATED with status OPEN
- **Kasie FE:** Buka app → tap "Lihat Rencana Kerja" → pilih work plan OPEN → pilih operator & unit → submit → work plan status updated to CLOSED
- **Operator:** Buka app → tap "Lihat Rencana Kerja" → lihat work plan yang di-assign → ready untuk Fase 3

### Business Success

| Metric | Target | Phase |
|--------|--------|-------|
| **Workflow Ready** | CREATE → ASSIGN → VIEW flow working | Fase 2 |
| **Real Live Testing** | 6 users (1 per role) berhasil test | Pre-release |
| **Zero Critical Bugs** | No blocker bugs di workflow | Fase 2 Release |
| **Schema Compatibility** | 100% compatible dengan production schema | Validation |

### Technical Success

| Metric | Target | Validation |
|--------|--------|------------|
| **API Response Time** | < 2 detik untuk CRUD operations | Load testing |
| **State Consistency** | Status transitions always valid | Unit tests |
| **Role Validation** | 100% permission accuracy | Integration tests |
| **Database Integrity** | FK constraints enforced | Database tests |

---

## Product Scope

### MVP - Minimum Viable Product (Fase 2)

| Feature | Status | Priority |
|---------|--------|----------|
| Work Plan CREATE (Kasie PG) | ✅ In Scope | P0 |
| Work Plan ASSIGN (Kasie FE) | ✅ In Scope | P0 |
| Work Plan VIEW (All roles) | ✅ In Scope | P0 |
| User dummy integration (all roles) | ✅ In Scope | P0 |
| Real live testing | ✅ In Scope | P0 |

### Growth Features (Fase 3+)

| Feature | Priority | Dependency |
|---------|----------|------------|
| Live GPS Tracking | P0 | Requires Fase 2 |
| Activity Result submission | P0 | Requires Fase 2 |
| Notification system | P1 | Requires Activity |
| Dashboard Analytics (Web) | P1 | Requires Fase 2 |

### Vision (Future)

| Feature | Timeframe | Notes |
|---------|-----------|-------|
| Biometric authentication | Future | For audit trail security |
| Offline work plan sync | Future | For remote areas |
| Multi-estate support | Future | Enhanced scheduling |

---

## User Journeys

### Journey 1: Pak Suswanto - Kasie PG Membuat Rencana Kerja

**Persona:** Pak Suswanto, 45 tahun, Kasie PG di Estate Sungai Lilin. Sudah 15 tahun di perkebunan, familiar dengan teknologi dasar (WhatsApp, Excel). Bertanggung jawab membuat rencana kerja harian untuk tim traktor.

**Konteks:** Jam 5:30 pagi, Pak Suswanto duduk di teras rumahnya dengan secangkir kopi. Dia perlu membuat rencana kerja untuk hari ini sebelum operator mulai kerja.

---

**Opening Scene:**
Pak Suswanto buka FSTrack-Tractor di HP Android-nya. Dia login dan melihat greeting "Selamat pagi, Pak Suswanto! 👋" dan dua menu cards: "Buat Rencana Kerja" (prominent) dan "Lihat Rencana Kerja" (secondary).

**Rising Action:**
Pak Suswanto tap "Buat Rencana Kerja". Form pembuatan rencana kerja muncul:
- **Tanggal Kerja:** Auto-filled hari ini (bisa ubah)
- **Pola Kerja:** Dropdown (Rotasi, Pembersihan, dll)
- **Shift:** Dropdown (Pagi, Siang, Malam)
- **Lokasi:** Dropdown (Sungai Lilin A, Sungai Lilin B, dll)
- **Unit:** Dropdown (Unit 1, Unit 2, Unit 3)
- **Catatan:** Text field (opsional)

Dia mengisi form:
- Tanggal: 2026-01-29
- Pola Kerja: Rotasi
- Shift: Pagi
- Lokasi: Sungai Lilin A
- Unit: Unit 1
- Catatan: (kosong)

**Climax - Aha Moment:**
Pak Suswanto tap "Simpan". Loading indicator muncul sebentar... Kemudian toast muncul: "Rencana kerja berhasil dibuat!" Dia tap "Lihat Rencana Kerja" dan melihat work plan baru dengan status "OPEN".

**Resolution:**
Pak Suswanto berhasil membuat rencana kerja. Status "OPEN" berarti work plan siap untuk di-assign ke operator oleh Kasie FE. Dia selesai dengan cepat dan siap untuk aktivitas lain.

**Emotional Arc:** Focused (isi form) → Satisfied (berhasil) → Confident (siap assign)

---

**Journey Requirements Revealed:**
- CREATE work plan form dengan semua field yang diperlukan
- Auto-fill tanggal hari ini
- Validation: semua field required (kecuali catatan)
- Status default: OPEN
- Success feedback: toast message
- Redirect ke VIEW setelah CREATE

---

### Journey 2: Pak Siswanto - Kasie FE Menugaskan Operator

**Persona:** Pak Siswanto, 38 tahun, Kasie FE di Estate Sungai Lilin. Tugasnya menugaskan work plan ke operator berdasarkan rencana yang dibuat Kasie PG.

**Konteks:** Jam 6:00 pagi, Pak Siswanto di kantor estate. Dia perlu menugaskan operator untuk work plan hari ini sebelum operator mulai kerja.

---

**Opening Scene:**
Pak Siswanto login ke FSTrack-Tractor. Dia melihat greeting dan dua menu cards. Dia tap "Lihat Rencana Kerja".

**Rising Action:**
List work plan muncul. Pak Siswanto melihat work plan yang dibuat Pak Suswanto dengan status "OPEN". Dia tap work plan tersebut.

Detail work plan muncul:
- Tanggal: 2026-01-29
- Pola Kerja: Rotasi
- Shift: Pagi
- Lokasi: Sungai Lilin A
- Unit: Unit 1
- Status: OPEN
- **Assign Section:**
  - Operator: Dropdown (Pak Budi, Pak Ahmad, Pak Citra...)
  - **Simpan** button (hanya muncul untuk Kasie FE)

Pak Siswanto pilih operator "Pak Budi" dan tap "Simpan".

**Climax - Aha Moment:**
Loading indicator muncul sebentar... Toast muncul: "Operator berhasil ditugaskan!" Status work plan berubah dari "OPEN" ke "CLOSED".

**Resolution:**
Pak Budi sekarang bisa melihat work plan ini di app-nya. Pak Siswanto selesai menugaskan dan siap untuk work plan berikutnya.

**Emotional Arc:** Systematic (pilih work plan) → Efficient (assign operator) → Satisfied (workflow selesai)

---

**Journey Requirements Revealed:**
- VIEW work plan detail
- ASSIGN section hanya visible untuk Kasie FE
- Operator dropdown dari list operator yang available
- Status transition: OPEN → CLOSED (when operator assigned)
- Success feedback: toast message

---

### Journey 3: Pak Budi - Operator Melihat Tugas

**Persona:** Pak Budi, 28 tahun, Operator traktor di Estate Sungai Lilin. Tugasnya mengoperasikan traktor sesuai work plan yang diberikan.

**Konteks:** Jam 6:30 pagi, Pak Budi sampai di pool traktor. Dia perlu tahu tugas hari ini sebelum mulai kerja.

---

**Opening Scene:**
Pak Budi login ke FSTrack-Tractor. Dia melihat greeting "Selamat pagi, Pak Budi! 👋" dan satu menu card: "Lihat Rencana Kerja".

**Rising Action:**
Pak Budi tap menu card tersebut. List work plan muncul, tapi dia hanya melihat work plan yang di-assign ke dirinya:
- Work Plan #1: Rotasi, Shift Pagi, Sungai Lilin A, Unit 1 - Status: ASSIGNED

Dia tap work plan tersebut untuk melihat detail.

**Climax - Aha Moment:**
Detail work plan muncul dengan semua informasi yang jelas:
- Tanggal: 2026-01-29
- Pola Kerja: Rotasi
- Shift: Pagi
- Lokasi: Sungai Lilin A
- Unit: Unit 1
- Operator: Pak Budi (dirinya)
- Status: CLOSED (or OPEN if not yet completed)

Pak Budi tahu persis apa yang harus dilakukan hari ini.

**Resolution:**
Pak Budi siap untuk mulai kerja. Di Fase 3, dia bisa melaporkan progress dan menyelesaikan work plan.

**Emotional Arc:** Curious (tugas apa?) → Informed (detail jelas) → Ready (siap kerja)

---

**Journey Requirements Revealed:**
- VIEW work plan list filtered by assigned operator
- Detail view dengan semua informasi
- No ASSIGN section untuk operator (read-only)
- Status display yang jelas

---

### Journey 4: Pak Soswanti - Admin Validasi Workflow

**Persona:** Pak Soswanti, 35 tahun, Admin IT yang handle internal testing. Tugasnya memastikan semua role bisa menjalankan workflow dengan benar.

**Konteks:** Pre-release testing. Pak Soswanti perlu verify bahwa CREATE → ASSIGN → VIEW flow working untuk semua role.

---

**Opening Scene:**
Pak Soswanti di kantor IT dengan checklist testing. Dia akan test sebagai seluruh role.

**Rising Action:**
Test 1: Login sebagai "suswanto.kasie_pg" (role: kasie_pg)
- Tap "Buat Rencana Kerja" → Form muncul ✅
- Isi form → Simpan → Work plan CREATED ✅
- Tap "Lihat Rencana Kerja" → Work plan muncul dengan status OPEN ✅

Test 2: Login sebagai "siswanto.kasie_fe" (role: kasie_fe)
- Tap "Lihat Rencana Kerja" → Work plan OPEN muncul ✅
- Tap work plan → Assign section visible ✅
- Pilih operator → Simpan → Status berubah ke CLOSED ✅

Test 3: Login sebagai "budi.operator" (role: operator)
- Tap "Lihat Rencana Kerja" → Hanya work plan yang di-assign muncul ✅
- Tap work plan → Detail view, read-only ✅

Test 4: Login sebagai "citra.mandor" (role: mandor)
- Tap "Lihat Rencana Kerja" → Bisa lihat semua work plan ✅
- Tidak bisa CREATE atau ASSIGN ✅

Test 5: Login sebagai "admin" (role: admin)
- Tap "Lihat Rencana Kerja" → Bisa lihat semua work plan ✅
- Tidak bisa CREATE atau ASSIGN ✅

**Climax:**
Semua test berhasil! CREATE → ASSIGN → VIEW flow working untuk semua role sesuai permission matrix.

**Resolution:**
Pak Soswanti update status testing: "Fase 2 Ready for Internal Release". Checklist complete.

**Emotional Arc:** Methodical (testing step by step) → Confident (all tests pass) → Satisfied (ready to ship)

---

**Journey Requirements Revealed:**
- Role-based permission enforcement
- CREATE hanya untuk Kasie PG
- ASSIGN hanya untuk Kasie FE
- VIEW untuk semua role
- Admin/Mandor/Estate PG: VIEW only

---

## Functional Requirements

### Work Plan Management (FR-F2-1 to FR-F2-20)

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
| FR-F2-10 | System update status: OPEN → CLOSED saat ASSIGN (production behavior) |
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

### User Management (FR-F2-21 to FR-F2-25)

| FR# | Requirement |
|-----|-------------|
| FR-F2-21 | System memiliki user dummy untuk semua role (kasie_pg, kasie_fe, operator, mandor, admin) |
| FR-F2-22 | User dummy digunakan untuk real live testing |
| FR-F2-23 | User dummy memiliki password yang valid |
| FR-F2-24 | User dummy terdaftar di database |
| FR-F2-25 | User dummy dapat login dan mengakses fitur sesuai role |

### Data Consistency (FR-F2-26 to FR-F2-30)

| FR# | Requirement |
|-----|-------------|
| FR-F2-26 | System menyimpan work plan ke tabel schedules |
| FR-F2-27 | System menjaga referential integrity (FK constraints) |
| FR-F2-28 | System update status work plan secara atomik |
| FR-F2-29 | System tidak mengizinkan status transition yang invalid |
| FR-F2-30 | System log semua perubahan status work plan |

### FR Summary

| Category | Count | FRs |
|----------|-------|-----|
| Work Plan Management | 20 | FR-F2-1 to FR-F2-20 |
| User Management | 5 | FR-F2-21 to FR-F2-25 |
| Data Consistency | 5 | FR-F2-26 to FR-F2-30 |
| **Total** | **30** | |

---

## Non-Functional Requirements

### Performance

| NFR# | Requirement | Target | Validation |
|------|-------------|--------|------------|
| NFR-F2-1 | CREATE work plan response time | < 2 detik | Load testing |
| NFR-F2-2 | ASSIGN work plan response time | < 2 detik | Load testing |
| NFR-F2-3 | VIEW work plan list response time | < 1 detik | Load testing |
| NFR-F2-4 | VIEW work plan detail response time | < 1 detik | Load testing |
| NFR-F2-5 | UI responsiveness (tap feedback) | < 100ms | Manual testing |

### Security

| NFR# | Requirement | Implementation | Validation |
|------|-------------|----------------|------------|
| NFR-F2-6 | CREATE hanya untuk Kasie PG | Role-based permission | Integration test |
| NFR-F2-7 | ASSIGN hanya untuk Kasie FE | Role-based permission | Integration test |
| NFR-F2-8 | JWT validation untuk semua API | Existing from Fase 1 | Code review |
| NFR-F2-9 | Unauthorized access blocked | 401/403 response | Penetration test |

### Reliability & Availability

| NFR# | Requirement | Target | Validation |
|------|-------------|--------|------------|
| NFR-F2-10 | Database transaction integrity | ACID compliant | Database tests |
| NFR-F2-11 | Graceful error handling | User-friendly messages | Manual testing |
| NFR-F2-12 | API retry mechanism | Max 3x | Code review |

### Data Consistency

| NFR# | Requirement | Implementation |
|------|-------------|----------------|
| NFR-F2-13 | Status transitions valid | State machine validation |
| NFR-F2-14 | FK constraints enforced | Database schema |
| NFR-F2-15 | Audit log for changes | Log table |

### Integration (Production Database)

| NFR# | Requirement | Implementation | Validation |
|------|-------------|----------------|------------|
| NFR-F2-16 | Connection ke production Bulldozer DB | TypeORM connection pool | Integration test |
| NFR-F2-17 | Schema validation on startup | Auto-verify pada app start | Manual test |
| NFR-F2-18 | Graceful DB error handling | Fallback dengan user-friendly message | Error simulation |

### Scalability

| NFR# | Requirement | Target | Validation |
|------|-------------|--------|------------|
| NFR-F2-19 | Support concurrent users | 6 users (MVP target) | Load testing |
| NFR-F2-20 | Query performance dengan 1000 work plans | < 2s response | Performance test |

### Testing Automation

| NFR# | Requirement | Target | Validation |
|------|-------------|--------|------------|
| NFR-F2-21 | RBAC test coverage | 100% (5 roles × 4 endpoints) | Unit/Integration test |
| NFR-F2-22 | DB integration test coverage | 80% automation | Test coverage report |

### User Experience (Error Handling)

| NFR# | Requirement | Implementation |
|------|-------------|----------------|
| NFR-F2-23 | User-friendly error messages in Bahasa Indonesia | Localized error messages |
| NFR-F2-24 | Loading indicators for operations > 500ms | UI feedback mechanism |
| NFR-F2-25 | Retry button for transient errors | User-initiated retry |

### Database Performance

| NFR# | Requirement | Implementation |
|------|-------------|----------------|
| NFR-F2-26 | Index optimization for common queries | Index on status, operator_id, work_date |
| NFR-F2-27 | Connection pool configuration | Max 10 connections |

### NFR Summary

| Kategori | Count | Key Highlights |
|----------|-------|----------------|
| Performance | 5 | < 2s CREATE/ASSIGN |
| Security | 4 | Role-based permissions |
| Reliability | 3 | Transaction integrity |
| Data Consistency | 3 | State machine validation |
| Integration | 3 | Production DB integration |
| Scalability | 2 | 6 concurrent users |
| Testing Automation | 2 | 100% RBAC coverage |
| User Experience | 3 | Bahasa Indonesia error messages |
| Database Performance | 2 | Index optimization |
| **Total** | **27** | |

---

## Mobile App + Backend Specific Requirements

### Platform Requirements

| Aspect | Specification | Notes |
|--------|---------------|-------|
| **Primary Platform** | Android | Device pekerja lapangan |
| **Framework** | Flutter | Existing from Fase 1 |
| **Backend** | NestJS | Existing from Fase 1 |
| **Database** | PostgreSQL | Existing schema schedules/operators/units |

### API Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/api/v1/schedules` | JWT | List work plans (filtered by role) |
| `POST` | `/api/v1/schedules` | JWT | CREATE work plan (Kasie PG only) |
| `GET` | `/api/v1/schedules/:id` | JWT | Get work plan detail |
| `PATCH` | `/api/v1/schedules/:id` | JWT | UPDATE work plan (Kasie FE only for ASSIGN) |
| `GET` | `/api/v1/operators` | JWT | List available operators |

### Database Schema

**Note:** Production schema uses different data types than originally planned. See `/home/v/work/fstrack-tractor/docs/schema-reference.md` for complete details.

**Tabel schedules:**
```sql
CREATE TABLE schedules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  work_date DATE NOT NULL,
  pattern VARCHAR(50) NOT NULL,
  shift VARCHAR(20) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
  location_id VARCHAR(32),  -- FK to locations(id) - VARCHAR not UUID
  unit_id VARCHAR(16),      -- FK to units(id) - VARCHAR not UUID
  operator_id INTEGER,      -- FK to operators(id) - INTEGER not UUID
  report_id UUID,
  start_time TIMESTAMPTZ,
  end_time TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  FOREIGN KEY (location_id) REFERENCES locations(id),
  FOREIGN KEY (unit_id) REFERENCES units(id),
  FOREIGN KEY (operator_id) REFERENCES operators(id),
  FOREIGN KEY (report_id) REFERENCES reports(id)
);
```

**Status Values (Production):** OPEN, CLOSED, CANCEL

**Note:** Production status values differ from initial planning. The system uses OPEN/CLOSED/CANCEL instead of OPEN/ASSIGNED/IN_PROGRESS/COMPLETED.

### Error Messages (Bahasa Indonesia)

| Scenario | Message |
|----------|---------|
| CREATE berhasil | "Rencana kerja berhasil dibuat!" |
| ASSIGN berhasil | "Operator berhasil ditugaskan!" |
| Validation error | "Semua field wajib diisi" |
| Unauthorized | "Anda tidak memiliki akses untuk operasi ini" |
| Work plan not found | "Rencana kerja tidak ditemukan" |
| Operator already assigned | "Operator sudah memiliki tugas lain pada shift ini" |

---

## Project-Type Specific Requirements

### Project-Type Overview

FSTrack-Tractor Fase 2 adalah kombinasi project type:
- **Mobile App** (Flutter Android) - Primary frontend untuk pekerja lapangan
- **API Backend** (NestJS) - REST API service untuk work plan management

### Technical Architecture Considerations

**Mobile App (Flutter Android):**
- Primary Platform: Android (device pekerja lapangan)
- Framework: Flutter (existing from Fase 1)
- Online-only untuk Fase 2 (simplify MVP)
- Push notifications deferred ke Fase 3+
- Device permissions: Basic UI input (GPS/camera tidak diperlukan di Fase 2)
- Store compliance: Play Store guidelines untuk deployment

**API Backend (NestJS):**
- REST API dengan /api/v1/ prefix untuk versioning
- JWT authentication (existing from Fase 1)
- JSON request/response format
- Per-username rate limiting (throttling)
- Internal use only (no public SDK needed)

### API Endpoint Specifications

| Method | Endpoint | Auth | Role | Description |
|--------|----------|------|------|-------------|
| `GET` | `/api/v1/schedules` | JWT | All | List work plans (filtered by role) |
| `POST` | `/api/v1/schedules` | JWT | kasie_pg | CREATE work plan |
| `GET` | `/api/v1/schedules/:id` | JWT | All | Get work plan detail |
| `PATCH` | `/api/v1/schedules/:id` | JWT | kasie_fe | UPDATE work plan (ASSIGN only) |
| `GET` | `/api/v1/operators` | JWT | kasie_fe | List available operators |

### Authentication Model

**JWT Token Flow:**
1. User login → server validates credentials → returns JWT token
2. Client stores JWT token locally
3. All API requests include JWT in Authorization header
4. Server validates JWT and extracts user role
5. Role-based access control enforces permissions

**Role-Based Access Control (RBAC):**
- kasie_pg: CREATE + VIEW work plans
- kasie_fe: ASSIGN + VIEW work plans
- operator: VIEW assigned work plans only
- mandor, admin: VIEW all work plans

### Data Schemas

**Request: POST /api/v1/schedules**
```json
{
  "workDate": "2026-01-29",
  "pattern": "Rotasi",
  "shift": "Pagi",
  "locationId": "LOC001",  // VARCHAR(32)
  "unitId": "UNIT01"       // VARCHAR(16)
}
```

**Response: POST /api/v1/schedules**
```json
{
  "id": "uuid",
  "workDate": "2026-01-29",
  "pattern": "Rotasi",
  "shift": "Pagi",
  "status": "OPEN",
  "locationId": "LOC001",
  "unitId": "UNIT01",
  "operatorId": null,
  "createdAt": "2026-01-29T05:30:00Z"
}
```

**Request: PATCH /api/v1/schedules/:id**
```json
{
  "operatorId": 123  // INTEGER
}
```

### Rate Limits

| Endpoint | Rate Limit | Rationale |
|----------|------------|-----------|
| GET /api/v1/schedules | 100 req/min | Prevent abuse |
| POST /api/v1/schedules | 10 req/min | Limit creation rate |
| PATCH /api/v1/schedules/:id | 10 req/min | Limit assignment rate |

### Error Codes

| Code | Message (ID) | Scenario |
|------|--------------|----------|
| 200 | OK | Success |
| 201 | Created | Resource created |
| 400 | Bad Request | Invalid data |
| 401 | Unauthorized | Invalid/missing token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 422 | Unprocessable Entity | Validation error |
| 429 | Too Many Requests | Rate limit exceeded |

### Platform Requirements

| Aspect | Specification | Status |
|--------|---------------|--------|
| **Primary Platform** | Android | Fase 2 focus |
| **Framework** | Flutter | Existing from Fase 1 |
| **Backend** | NestJS | Existing from Fase 1 |
| **Database** | PostgreSQL | Existing schema |
| **Min SDK** | Android 5.0+ | Wide compatibility |
| **Target SDK** | Android 14 | Latest stable |

### Implementation Considerations

**Frontend (Flutter):**
- BLoC state management untuk consistent state handling
- Repository pattern untuk API communication
- Error boundary untuk graceful failure handling
- Loading indicators untuk async operations
- Toast messages untuk user feedback

**Backend (NestJS):**
- Modular architecture (SchedulesModule, AuthModule, UsersModule)
- DTO validation dengan class-validator
- Exception filters untuk consistent error responses
- Guards untuk JWT validation dan RBAC
- Logging untuk audit trail

---

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach:** Platform MVP - Build foundation untuk Fase 3+

**Rationale:**
- Fase 2 adalah jembatan antara Fase 1 (Login & Main Page) dan Fase 3+ (GPS Tracking, Activity, Approval)
- Focus pada core workflow: CREATE → ASSIGN → VIEW
- Platform foundation memungkinkan scale di Fase 3+

**Resource Requirements:**
- Tech stack sudah established (Flutter + NestJS dari Fase 1)
- Minimal team: 1 full-stack dev + 1 QA
- Estimated duration: 2-3 minggu

### MVP Feature Set (Phase 1)

**Core User Journeys Supported:**
1. Kasie PG - Create work plan
2. Kasie FE - Assign work plan ke operator
3. Operator - View work plan yang di-assign
4. Admin - Testing validation semua role

**Must-Have Capabilities:**
| Feature | Priority | Status |
|---------|----------|--------|
| Work Plan CREATE (Kasie PG) | P0 | ✅ In Scope |
| Work Plan ASSIGN (Kasie FE) | P0 | ✅ In Scope |
| Work Plan VIEW (All roles) | P0 | ✅ In Scope |
| RBAC enforcement (5 roles) | P0 | ✅ In Scope |
| User dummy setup (6 users) | P0 | ✅ In Scope |
| Production schema integration | P0 | ✅ In Scope |

### Post-MVP Features

**Phase 2 (Post-MVP):**
| Feature | Priority | Dependency |
|---------|----------|------------|
| Push notifications | P1 | Requires Activity |
| Offline mode | P2 | Requires sync mechanism |
| Dashboard Analytics (Web) | P1 | Requires Fase 2 data |

**Phase 3 (Expansion):**
| Feature | Priority | Notes |
|---------|----------|-------|
| Live GPS Tracking | P0 | Core feature |
| Activity Result submission | P0 | Core feature |
| Approval workflow | P1 | Multi-level approval |
| Multi-estate support | P2 | Enterprise feature |

### Risk Mitigation Strategy

**Technical Risks:**
| Risk | Mitigation |
|------|------------|
| Schema mismatch dengan production Bulldozer | Gunakan schema yang sudah ada, validasi di psql saat architecture phase |
| RBAC enforcement bug | Integration test untuk semua role × endpoint combinations |
| State transition bug | Implement state machine validation |

**Market Risks:**
| Risk | Mitigation |
|------|------------|
| User adoption gap | Real live testing dengan 6 user dummy (1 per role) |

**Resource Risks:**
| Risk | Mitigation |
|------|------------|
| Team size minimal | Tech stack established, no learning curve |

---

## Scoping Summary

### Scope Boundaries

| Boundary | Decision | Rationale |
|----------|----------|-----------|
| **Features** | CREATE, ASSIGN, VIEW only | MVP untuk workflow dasar |
| **Status Transitions** | OPEN → CLOSED only | Fase 2 scope, matches production DB (CLOSED/CANCEL in Fase 3) |
| **Offline Support** | Online-only untuk MVP | Simplify Fase 2 |
| **Real-time Updates** | Pull-to-refresh | Simplify Fase 2 |
| **User Testing** | 1 user per role | Minimum coverage |

### Definition of Done (Fase 2)

Fase 2 complete when:
- [ ] Kasie PG dapat CREATE work plan
- [ ] Kasie FE dapat ASSIGN work plan ke operator
- [ ] Operator dapat VIEW work plan yang di-assign
- [ ] Semua role dapat VIEW work plan list dengan filter yang benar
- [ ] Role-based permission enforced (CREATE/ASSIGN hanya untuk role yang tepat)
- [ ] Status transitions valid dan konsisten
- [ ] 6 user dummy (1 per role) siap untuk real live testing
- [ ] Zero critical bugs di workflow
- [ ] All 30 FRs dan 27 NFRs terpenuhi
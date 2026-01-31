---
scopeNote: "FASE 2: Work Plan Management - Full working main menu with CREATE, ASSIGN, and VIEW capabilities"
---

#  FSTrack-Tractor Fase 2

**Author:** V
**Date:** 2026-01-29

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
- **Roles:** kasie_pg, kasie_fe, operator, mandor, estate_pg, admin

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
- `status` (varchar) - Status: OPEN/ASSIGNED/IN_PROGRESS/COMPLETED
- `location_id` (FK) - Lokasi kerja
- `unit_id` (FK) - Unit traktor
- `operator_id` (FK) - Operator yang ditugaskan
- `report_id` (FK) - Report terkait (nullable di Fase 2)

### Permission Matrix (Fase 2 Scope)

| Operation | Kasie PG | Kasie FE | Operator | Mandor | Estate PG | Admin |
|-----------|----------|----------|----------|--------|-----------|-------|
| CREATE work plan | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| ASSIGN work plan | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| VIEW work plans | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

### Risk Mitigations

| Risk | Mitigation |
|------|------------|
| Schema mismatch | Gunakan schema production yang sudah ada (schedules/operators/units) |
| User testing gap | Buat minimal 1 akun per role untuk real live testing |
| Role permission error | Validasi permission matrix dengan enum roles dari Fase 1 |
| State transition bug | Implement state machine: OPEN → ASSIGNED → IN_PROGRESS → COMPLETED |
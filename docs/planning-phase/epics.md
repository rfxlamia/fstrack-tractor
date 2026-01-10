---
stepsCompleted: [1, 2, 3, 4]
completedDate: '2026-01-10'
inputDocuments:
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/architecture.md
  - _bmad-output/planning-artifacts/ux-design-specification.md
workflowType: 'epics-and-stories'
project_name: 'fstrack-tractor'
user_name: 'V'
date: '2026-01-10'
partyModeDate: '2026-01-10'
partyModeDecisions:
  - 'Epic 4 simplified - sync queue deferred to post-MVP'
  - 'Epic 5 keep - is_first_time for future feature discovery'
  - 'Epic 4 stays separate from Epic 3'
validationSummary:
  frCoverage: '35/35 (1 deferred: FR33)'
  nfrCoverage: '38/38'
  totalEpics: 6
  totalStories: 21
  allDependenciesValid: true
---

# FSTrack-Tractor - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for FSTrack-Tractor, decomposing the requirements from the PRD, UX Design, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

**Total: 35 FRs** ← *Updated: FR28-FR29 removed (onboarding slides replaced by contextual tooltips)*

#### Authentication (FR1-FR6, FR31-FR33) - 9 FRs
- FR1: User dapat login dengan username dan password
- FR2: User dapat toggle visibility password (show/hide)
- FR3: User dapat mengaktifkan "Ingat Saya" untuk persistent login
- FR4: System memvalidasi credentials terhadap database
- FR5: System mengeluarkan JWT token setelah login berhasil
- FR6: System menampilkan error message yang jelas untuk credentials tidak valid
- FR31: User dapat logout dari aplikasi
- FR32: System menghapus cached JWT saat logout
- FR33: Single session only - login baru di device lain invalidate session lama

#### Main Page Display (FR7-FR11) - 5 FRs
- FR7: User dapat melihat personalized greeting dengan nama mereka
- FR8: User dapat melihat informasi cuaca dan suhu saat ini
- FR9: User dapat melihat waktu saat ini dalam timezone WIB
- FR10: Role Kasie dapat melihat menu card "Buat Rencana Kerja"
- FR11: Semua role dapat melihat menu card "Lihat Rencana Kerja"

#### Role-Based Access (FR12-FR14) - 3 FRs
- FR12: System menampilkan layout UI berdasarkan role user
- FR13: Role Kasie melihat hybrid card layout (2 cards)
- FR14: Role non-Kasie melihat single full-width card

#### First-Time User Experience (FR15-FR17) - 3 FRs ← *Updated: UX Decision Override - Contextual Tooltips, NO MODAL*
- FR15: System mendeteksi first-time user via `is_first_time` flag
- FR16: First-time user melihat contextual tooltips saat login pertama ← *Updated: No onboarding modal*
- FR17: System mengupdate `is_first_time = FALSE` setelah user dismiss tooltips

*Note: FR28-FR29 (onboarding slides) REMOVED - replaced by contextual tooltips approach per UX Design decision*

#### Data Management Backend (FR18-FR21, FR27) - 5 FRs
- FR18: Admin dapat import users dari CSV ke PostgreSQL
- FR19: System memvalidasi format CSV sebelum import
- FR20: System meng-hash password dengan bcrypt saat import
- FR21: System menyimpan estate_id untuk setiap user
- FR27: System membaca role dari JWT token payload

#### Resilience & Offline (FR22-FR25, FR30, FR34-FR35) - 7 FRs
- FR22: System meng-cache JWT untuk offline access (14 hari) ← *Updated: Architecture override*
- FR23: System meng-cache data cuaca terakhir (30 menit) ← *Updated: Architecture override*
- FR24: System menampilkan graceful fallback saat weather API gagal
- FR25: System menampilkan warning saat JWT akan expired (hari ke-12, 2 hari sebelum expiry) ← *Updated: Aligned with 14-day JWT*
- FR30: System menampilkan offline indicator di header
- FR34: System otomatis retry request yang gagal (max 3x)
- FR35: System menampilkan error message yang actionable

#### Menu Card Behavior (FR26) - 1 FR
- FR26: System menampilkan placeholder/coming soon saat user tap menu card (MVP)

#### Loading States (FR36-FR37) - 2 FRs
- FR36: System menampilkan loading indicator saat proses login
- FR37: System menampilkan skeleton loading saat load main page

### NonFunctional Requirements

**Total: 38 NFRs**

#### Performance (NFR1-NFR8) - 8 NFRs
- NFR1: Login → Main Page load time < 3 detik (4G/WiFi)
- NFR2: Weather widget response time < 2 detik (async, non-blocking)
- NFR3: UI responsiveness (tap feedback) < 100ms
- NFR4: App startup time (cold start) < 5 detik
- NFR5: Memory usage < 50MB RAM
- NFR6: App functional di 4G low-signal (1 bar minimum)
- NFR7: Weather API non-blocking (main content loads first)
- NFR8: Login flow di 4G low-signal < 3 detik

#### Security (NFR9-NFR17) - 9 NFRs
- NFR9: Password storage - Bcrypt hash (cost factor 10+)
- NFR10: Data transmission - HTTPS/TLS 1.2+ mandatory
- NFR11: JWT token expiration - 14 hari
- NFR12: Input sanitization - Parameterized queries, no raw SQL
- NFR13: Session management - Single session per user
- NFR14: Credential storage (mobile) - Flutter secure_storage
- NFR15: Rate limiting login - Max 5 attempts per 15 menit per username
- NFR16: Account lockout - 30 menit setelah 10 failed attempts
- NFR17: Password minimum - 8 karakter, 1 angka

#### Reliability & Availability (NFR18-NFR26) - 9 NFRs
- NFR18: Offline login capability - JWT cache 14 hari ← *Confirmed: Architecture value*
- NFR19: Weather data cache - 30 menit ← *Confirmed: Architecture value*
- NFR20: API retry mechanism - Max 3x dengan exponential backoff
- NFR21: Backend uptime - 99% (MVP acceptable)
- NFR22: Graceful degradation - All external dependencies
- NFR23: Health check endpoint - Public /api/health (no auth)
- NFR24: Recovery Time Objective < 30 menit
- NFR25: JWT grace period - 24 jam offline-only setelah expiry
- NFR26: Session expiry warning - In-app banner < 2 hari tersisa

#### Data Freshness (NFR27-NFR29) - 3 NFRs
- NFR27: Weather timestamp visible - "Diperbarui: XX:XX WIB"
- NFR28: Weather auto-refresh - Setiap 30 menit saat app aktif
- NFR29: Weather disclaimer - "Prakiraan cuaca, dapat berubah"

#### Scalability (NFR30-NFR32) - 3 NFRs
- NFR30: Concurrent users - 30 users (MVP) → Ratusan users (future)
- NFR31: Database capacity - 500 users (MVP) → 5000+ users (future)
- NFR32: API rate limiting - Per-username throttling

#### Integration (NFR33-NFR35) - 3 NFRs
- NFR33: Weather API - Adapter pattern (swappable)
- NFR34: Weather API timeout - 5 detik max
- NFR35: Backend API versioning - v1 prefix

#### Maintainability (NFR36-NFR38) - 3 NFRs
- NFR36: Code documentation - Inline comments untuk complex logic
- NFR37: Error logging - Structured logs dengan context
- NFR38: Configuration - Environment-based (dev/staging/prod)

### Additional Requirements

#### From Architecture Document

**Starter Template Decision (Epic 1 Story 1):**
- Flutter: `flutter create` + manual Clean Architecture setup
- NestJS: `nest new` + manual modular setup
- Build from scratch with defined folder structure

**Core Technical Decisions:**
- Local Storage: Hive + flutter_secure_storage (encrypted)
- State Management: BLoC pattern
- Navigation: go_router with auth redirects
- Weather API: OpenWeatherMap with adapter pattern
- Rate Limiting: @nestjs/throttler (5 attempts/15 min per username)
- Hosting MVP: Railway (free tier)
- Hosting Production: Company Private AWS
- JWT Duration: 14 hari + 24 jam grace period
- Weather Cache: 30 menit

**Flutter Dependencies Required:**
- hive, hive_flutter, flutter_bloc, equatable, get_it, injectable, dio, dartz
- flutter_secure_storage, connectivity_plus, go_router, shimmer, cached_network_image

**NestJS Dependencies Required:**
- @nestjs/typeorm, typeorm, pg
- @nestjs/passport, @nestjs/jwt, passport, passport-jwt, bcrypt
- class-validator, class-transformer, @nestjs/throttler, @nestjs/swagger

**Project Structure Requirements:**
- Flutter: Clean Architecture with features/auth, features/home, features/weather
- NestJS: Modular with src/auth, src/users, src/weather, src/health

**Infrastructure & Setup Requirements (NEWLY CAPTURED):**
- Dev test account creation via `scripts/seed-dev-user.ts`
- Database migrations setup via TypeORM migrations (`src/database/migrations/`)
- Swagger/API documentation setup via `@nestjs/swagger`
- CI/CD pipeline via GitHub Actions (`.github/workflows/`)
- Hive encryption key management via initialization sequence (flutter_secure_storage → Hive)
- go_router + AuthBloc integration via refreshListenable redirect pattern

**15 Implementation Patterns Defined:**
1. Naming patterns (database, API, code)
2. Import ordering
3. Entity vs Model distinction
4. Repository method naming (use 'get' verb consistently)
5. UseCase naming pattern (VerbNounUseCase)
6. Standardized Failure types
7. API response format
8. Date/time formats
9. Test file naming
10. Mock/Fake naming
11. Fixture organization
12. User-facing text (Bahasa Indonesia)
13. Loading messages
14. Error message patterns
15. Button labels

#### From UX Design Document

**Design System:**
- Material Design 3 + Bulldozer exact color tokens
- Poppins font BUNDLED (offline support)
- Primary: #008945, Button Orange: #FBA919, Button Blue: #25AAE1

**4 Custom Components Required:**
1. WeatherWidget - Prominent weather display dengan skeleton loading
2. OfflineBanner - Tappable "Offline - Tap untuk sync"
3. GreetingHeader - Time-based personalized greeting
4. TaskCard - Summary rencana kerja dengan status variants

**Key UX Decisions:**
- First-time UX: Contextual tooltips (NOT onboarding modal)
- Loading: Skeleton shimmer (NOT CircularProgressIndicator)
- Offline: Explicit tappable banner
- Role-based UI: FAB visible only for Kasie roles
- Bottom sheet for all detail/create actions

**Accessibility Requirements:**
- WCAG AA compliance
- 48dp minimum touch targets
- High contrast (10.5:1)
- Semantic labels on all widgets

### FR Coverage Map

| FR | Epic | Description |
|----|------|-------------|
| FR1 | Epic 2 | Login dengan username/password |
| FR2 | Epic 2 | Toggle password visibility |
| FR3 | Epic 2 | Remember Me untuk persistent login |
| FR4 | Epic 2 | Validasi credentials |
| FR5 | Epic 2 | JWT token generation |
| FR6 | Epic 2 | Error message untuk invalid credentials |
| FR7 | Epic 3 | Personalized greeting |
| FR8 | Epic 3 | Weather dan suhu |
| FR9 | Epic 3 | Clock WIB timezone |
| FR10 | Epic 3 | Kasie: Menu card "Buat Rencana Kerja" |
| FR11 | Epic 3 | All: Menu card "Lihat Rencana Kerja" |
| FR12 | Epic 3 | Layout UI berdasarkan role |
| FR13 | Epic 3 | Kasie: 2 cards layout |
| FR14 | Epic 3 | Non-Kasie: 1 card layout |
| FR15 | Epic 5 | Detect first-time user |
| FR16 | Epic 5 | Show contextual tooltips |
| FR17 | Epic 5 | Update is_first_time flag |
| FR18 | Epic 6 | CSV import users |
| FR19 | Epic 6 | CSV validation |
| FR20 | Epic 6 | Bcrypt password hashing |
| FR21 | Epic 6 | Estate ID assignment |
| FR22 | Epic 2 | JWT cache 14 hari |
| FR23 | Epic 3 | Weather cache 30 menit |
| FR24 | Epic 3 | Weather fallback |
| FR25 | Epic 4 | JWT expiry warning |
| FR26 | Epic 3 | Menu card placeholder/coming soon |
| FR27 | Epic 6 | Read role from JWT |
| FR30 | Epic 4 | Offline indicator |
| FR31 | Epic 2 | Logout |
| FR32 | Epic 2 | Clear cached JWT on logout |
| FR33 | Epic 2 | Single session enforcement |
| FR34 | Epic 2 | Auto retry (3x) |
| FR35 | Epic 4 | Actionable error messages |
| FR36 | Epic 2 | Login loading indicator |
| FR37 | Epic 3 | Skeleton loading main page |

### NFR Coverage Map

| NFR Category | Epic | Key Requirements |
|--------------|------|------------------|
| Performance (NFR1-8) | Epic 2, 3 | < 3 detik load, 4G low-signal, weather non-blocking |
| Security (NFR9-17) | Epic 2 | bcrypt cost 10+, rate limit 5/15min, lockout 10→30min |
| Reliability (NFR18-26) | Epic 2, 3, 4 | JWT 14d + 24h grace, weather 30min cache, graceful degradation |
| Data Freshness (NFR27-29) | Epic 3 | Timestamp visible, auto-refresh 30min, disclaimer |
| Scalability (NFR30-32) | Epic 1 | 30→ratusan users, per-username throttling |
| Integration (NFR33-35) | Epic 3 | Adapter pattern, 5s timeout, v1 API prefix |
| Maintainability (NFR36-38) | Epic 1 | Structured logging, env-based config |

## Epic List

### Epic 1: Project Foundation & Infrastructure
**User Outcome:** Development team dapat memulai development dengan environment yang siap, consistent, dan production-ready

**Goal:** Setup Flutter + NestJS projects dengan Clean Architecture, dependencies, CI/CD, database, dev account, dan design system foundation.

**FRs Covered:** None directly (infrastructure enables all FRs)

**NFRs Addressed:**
- NFR23: Health check endpoint `/api/health`
- NFR30-32: Scalability foundation
- NFR35: API versioning v1 prefix
- NFR36-38: Maintainability (logging, env config, docs)

**Scope:**
- Flutter project setup (`flutter create` + Clean Architecture structure)
- NestJS project setup (`nest new` + modular structure)
- Database migrations (TypeORM)
- Health check endpoint (NFR23)
- Swagger/API docs (@nestjs/swagger)
- Dev test account (seed-dev-user.ts)
- CI/CD pipeline (GitHub Actions)
- **Design System Foundation:**
  - AppColors, AppTextStyle, AppSpacing (from Bulldozer)
  - Bundled Poppins font (offline support)
  - app_theme.dart consolidated
- **Hive Encryption Key Flow:**
  - 5-step initialization sequence
  - flutter_secure_storage → Hive encrypted boxes
- Environment configuration (dev/staging/prod)
- Structured logging setup

---

### Epic 2: User Authentication & Session
**User Outcome:** User dapat login dengan aman dan tetap terautentikasi bahkan saat offline di area sinyal lemah

**Goal:** Complete authentication flow dengan JWT, secure storage, rate limiting, account lockout, dan offline support.

**FRs Covered:** FR1, FR2, FR3, FR4, FR5, FR6, FR22, FR31, FR32, FR33, FR34, FR36

**NFRs Addressed:**
- NFR1, NFR3, NFR8: Performance (< 3s login, tap feedback, 4G support)
- NFR9-17: Security (bcrypt, HTTPS, JWT 14d, rate limit, lockout)
- NFR18, NFR20: Reliability (offline login, retry mechanism)

**Scope:**
- Login page UI (TextInputGlobal, password toggle, Remember Me)
- Login loading indicator (FR36)
- NestJS AuthModule with JWT strategy
- Password hashing with bcrypt (cost factor 10+)
- **Rate limiting:** 5 attempts per 15 min per username (NFR15)
- **Account lockout:** 30 min after 10 failed attempts (NFR16)
- JWT token generation (14 days expiry)
- **JWT 24-hour grace period** for offline validation (NFR25)
- Secure token storage (Hive encrypted box)
- **Hive initialization sequence** (must follow exact 5-step order)
- Logout with JWT cache clear (FR31, FR32)
- Single session enforcement (FR33)
- Auto retry mechanism (3x with exponential backoff) (FR34)
- go_router + AuthBloc integration (refreshListenable pattern)

---

### Epic 3: Main Dashboard & Weather Integration
**User Outcome:** User dapat melihat dashboard personal dengan informasi cuaca real-time untuk planning kerja lapangan

**Goal:** Main page dengan greeting, weather widget, clock, dan role-based menu cards dengan skeleton loading.

**FRs Covered:** FR7, FR8, FR9, FR10, FR11, FR12, FR13, FR14, FR23, FR24, FR26, FR37

**NFRs Addressed:**
- NFR1-2, NFR4-7: Performance (load time, weather async, non-blocking)
- NFR19: Weather cache 30 menit
- NFR27-29: Data freshness (timestamp, auto-refresh, disclaimer)
- NFR33-34: Integration (adapter pattern, 5s timeout)

**Scope:**
- **GreetingHeader widget:** Time-based personalized greeting
- **WeatherWidget:**
  - **Weather Adapter Pattern** (interface-first, swappable)
  - OpenWeatherMap integration
  - **Weather cache 30 menit** (Hive box)
  - **Weather timestamp display:** "Diperbarui: XX:XX WIB" (NFR27)
  - **Weather auto-refresh:** Setiap 30 menit saat app aktif (NFR28)
  - **Weather disclaimer:** "Prakiraan cuaca, dapat berubah" (NFR29)
  - **Graceful fallback:** "Cuaca tidak tersedia" (FR24)
  - 5 second timeout (NFR34)
- Clock widget (WIB timezone)
- Role-based menu cards:
  - Kasie: 2 cards layout (FR13)
  - Non-Kasie: 1 card layout (FR14)
  - Menu card placeholder/coming soon (FR26)
- **Skeleton loading pattern:**
  - Shimmer package (NOT CircularProgressIndicator)
  - WeatherWidgetSkeleton
  - MenuCardSkeleton
  - V's signature improvement

---

### Epic 4: Offline Resilience & Connectivity (MVP Simplified)
**User Outcome:** User dapat menggunakan app di area sinyal lemah dengan feedback yang jelas tentang status koneksi

**Goal:** Explicit offline indicator, JWT expiry warning, graceful degradation. *(Sync queue deferred to post-MVP)*

**FRs Covered:** FR25, FR30, FR35

**NFRs Addressed:**
- NFR6: 4G low-signal functionality
- NFR21-26: Reliability & availability (read-only for MVP)

**Scope (MVP):**
- **OfflineBanner widget:** Tappable "Offline - Tap untuk refresh"
- **Connectivity detection:** Basic online/offline state
- **Connectivity debounce:** 2 second delay untuk offline detection (no rapid flashing)
- JWT expiry warning (FR25): Banner < 2 hari tersisa
- Actionable error messages in Bahasa Indonesia (FR35)
- ConnectivityService with stream
- Graceful degradation for all external dependencies
- Read-only cached data display when offline

**Deferred to Post-MVP (when write operations added):**
- ~~Sync queue mechanism~~
- ~~Exponential backoff (2s, 4s, 8s)~~
- ~~Last-Write-Wins conflict resolution~~
- ~~Retry count per queued item~~

**Party Mode Decision:** Simplified karena MVP belum ada write operations (menu cards = placeholder)

---

### Epic 5: First-Time User Experience
**User Outcome:** User baru dapat memahami app tanpa training melalui contextual hints yang muncul saat interaksi pertama

**Goal:** Contextual tooltips untuk first-time users, is_first_time flag management, server sync. Foundation untuk future feature discovery.

**FRs Covered:** FR15, FR16, FR17

**Scope:**
- **tooltip_overlay.dart widget:** Reusable shared widget
- **Tooltip sequence logic:**
  - Contextual hints on first interaction
  - Weather widget hint
  - Menu card hint
  - No modal, learn-by-doing approach
- First-time detection via `is_first_time` flag (FR15)
- Show tooltips for first-time users (FR16)
- **Tooltip dismissal tracking:**
  - Update `is_first_time = FALSE` setelah dismiss (FR17)
  - PATCH `/api/v1/users/me/first-time` endpoint
  - Server sync for first-time status
- first_time_hints.dart in features/home/widgets

**Future-Ready Design (Party Mode Decision):**
- `is_first_time` schema akan digunakan untuk fitur-fitur baru di masa depan
- Setiap fitur baru bisa punya contextual tooltips sendiri
- Pattern: `feature_key` based tooltip system (extensible)
- Konsistensi UX untuk feature discovery across all future releases

---

### Epic 6: Admin Data Management
**User Outcome:** Admin dapat import dan manage user data untuk onboarding karyawan perusahaan

**Goal:** CSV import dengan validation, password hashing, estate assignment.

**FRs Covered:** FR18, FR19, FR20, FR21, FR27

**Scope:**
- CSV validation script (validate-csv.ts)
- CSV import script (import-csv.ts)
- Password hashing with bcrypt on import (FR20)
- Estate ID assignment (FR21)
- Role assignment and JWT payload (FR27)
- Users table with all required columns
- User entity with role enum

**Note:** Epic terakhir karena development menggunakan dev test account dari Epic 1

---

## Stories

### Epic 1 Stories

#### Story 1.1: Initialize Flutter Project with Clean Architecture

**User Story:** Sebagai developer, saya dapat memulai development Flutter dengan project structure yang sudah siap agar tidak perlu setup manual berulang.

**Scope:**
- `flutter create fstrack_tractor` dengan package name yang sesuai
- Clean Architecture folder structure (`lib/core/`, `lib/features/`)
- All dependencies di `pubspec.yaml`
- Hive 5-step encryption key initialization
- Dependency Injection dengan get_it + injectable
- go_router shell configuration

**Acceptance Criteria:**
- [ ] `flutter create` executed dengan package `com.company.fstrack_tractor`
- [ ] Folder structure exists:
  ```
  lib/
  ├── core/
  │   ├── di/
  │   ├── error/
  │   ├── network/
  │   ├── storage/
  │   └── theme/
  └── features/
      ├── auth/
      ├── home/
      └── weather/
  ```
- [ ] `pubspec.yaml` includes all dependencies:
  - hive, hive_flutter, flutter_bloc, equatable
  - get_it, injectable, injectable_generator
  - dio, dartz, flutter_secure_storage
  - connectivity_plus, go_router, shimmer
- [ ] Hive initialization sequence implemented:
  1. Check flutter_secure_storage for existing key
  2. Generate key if not exists
  3. Store key in secure storage
  4. Open Hive boxes with encryption cipher
  5. Verify box accessibility
- [ ] `injection.dart` configured with get_it
- [ ] `app_router.dart` shell with placeholder routes
- [ ] `flutter analyze` passes with no errors

**Test Requirement:** `flutter analyze` passes, Hive box opens without error

**Track:** A (Frontend)

---

#### Story 1.2: Initialize NestJS Project with Modular Architecture

**User Story:** Sebagai developer, saya dapat memulai development backend dengan NestJS project yang sudah terstruktur dan siap production.

**Scope:**
- `nest new fstrack-tractor-api`
- Modular folder structure
- Health check endpoint `/api/health`
- Swagger/OpenAPI documentation
- Environment configuration

**Acceptance Criteria:**
- [ ] `nest new` executed dengan struktur modular
- [ ] Folder structure exists:
  ```
  src/
  ├── auth/
  ├── users/
  ├── weather/
  ├── health/
  └── database/
      └── migrations/
  ```
- [ ] `package.json` includes all dependencies:
  - @nestjs/typeorm, typeorm, pg
  - @nestjs/passport, @nestjs/jwt, passport-jwt, bcrypt
  - class-validator, class-transformer
  - @nestjs/throttler, @nestjs/swagger
- [ ] Health endpoint implemented:
  - `GET /api/health` returns `{ status: 'ok', timestamp: '...' }`
  - No authentication required (NFR23)
- [ ] Swagger UI accessible at `/api/docs`
- [ ] Environment files configured (`.env.example`, `.env.development`)
- [ ] API versioning: all routes prefixed with `/api/v1/` (NFR35)
- [ ] `npm run lint` passes with no errors

**Test Requirement:** `GET /api/health` returns 200, Swagger UI accessible

**Track:** B (Backend)

---

#### Story 1.3: Setup Database with Users Table and Dev Seed

**User Story:** Sebagai developer, saya dapat menggunakan database PostgreSQL dengan schema users yang sudah ready dan test account untuk development.

**Scope:**
- TypeORM configuration
- Users table migration
- Dev seed script (`seed-dev-user.ts`)

**Acceptance Criteria:**
- [ ] TypeORM configured dengan PostgreSQL connection
- [ ] Migration file created: `create-users-table`
- [ ] Users table schema:
  ```sql
  CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL,
    estate_id UUID,
    is_first_time BOOLEAN DEFAULT TRUE,
    failed_login_attempts INT DEFAULT 0,
    locked_until TIMESTAMP,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
  );
  ```
- [ ] Role enum: `KASIE`, `OPERATOR`, `MANDOR`, `ADMIN`
- [ ] `npm run migration:run` succeeds
- [ ] Seed script exists: `scripts/seed-dev-user.ts`
- [ ] Dev user seeded:
  - Username: `dev_kasie`
  - Password: `DevPassword123` (bcrypt hashed)
  - Role: `KASIE`
  - is_first_time: `true`
- [ ] `npm run seed:dev` command available

**Test Requirement:** `npm run migration:run` succeeds, dev user exists in DB

**Track:** B (Backend, after 1.2)

---

#### Story 1.4: Setup CI/CD Pipeline with GitHub Actions

**User Story:** Sebagai developer, saya mendapat feedback otomatis saat push code agar masalah terdeteksi lebih awal.

**Scope:**
- GitHub Actions workflow file
- Flutter checks (analyze, test placeholder)
- NestJS checks (lint, test placeholder)

**Acceptance Criteria:**
- [ ] `.github/workflows/ci.yml` created
- [ ] Workflow triggers on:
  - Push to `main` branch
  - Pull request to `main` branch
- [ ] Flutter job includes:
  ```yaml
  - uses: subosito/flutter-action@v2
  - run: flutter pub get
  - run: flutter analyze
  - run: flutter test # placeholder, will add real tests later
  ```
- [ ] NestJS job includes:
  ```yaml
  - uses: actions/setup-node@v4
  - run: npm ci
  - run: npm run lint
  - run: npm run test # placeholder
  ```
- [ ] Both jobs run in parallel
- [ ] CI workflow passes on push to main branch
- [ ] Branch protection rule recommended (manual setup by admin)

**Test Requirement:** CI workflow passes on actual push to main

**Track:** B (Backend, parallel with 1.3)

---

#### Story 1.5: Setup Design System Foundation with Bundled Fonts

**User Story:** Sebagai developer, saya dapat menggunakan design tokens yang konsisten dengan Bulldozer app agar UI terlihat profesional dan seragam.

**Scope:**
- AppColors dengan exact Bulldozer hex values
- AppTextStyles dengan Poppins font
- Poppins font bundled (offline support)
- AppSpacing constants

**Acceptance Criteria:**
- [ ] Poppins font files added to `assets/fonts/`:
  - Poppins-Regular.ttf (w400)
  - Poppins-Medium.ttf (w500)
  - Poppins-SemiBold.ttf (w600)
  - Poppins-Bold.ttf (w700)
- [ ] `pubspec.yaml` font declaration:
  ```yaml
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
          weight: 400
        - asset: assets/fonts/Poppins-Medium.ttf
          weight: 500
        - asset: assets/fonts/Poppins-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
  ```
- [ ] `lib/core/theme/app_colors.dart`:
  ```dart
  static const primary = Color(0xFF008945);
  static const buttonOrange = Color(0xFFFBA919);
  static const buttonBlue = Color(0xFF25AAE1);
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const onPrimary = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  ```
- [ ] `lib/core/theme/app_text_styles.dart`:
  ```dart
  static final w400s10 = TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w400);
  static final w500s12 = TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500);
  static final w600s12 = TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600);
  static final w700s20 = TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700);
  ```
- [ ] `lib/core/theme/app_spacing.dart`:
  ```dart
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  ```
- [ ] `lib/core/theme/app_theme.dart` consolidates all tokens
- [ ] Font loads correctly without network (testable offline)

**Test Requirement:** `testWidgets` confirms Poppins font loads offline

**Track:** A (Frontend, after 1.1)

---

### Epic 1 Party Mode Decisions (2026-01-10)

| Issue | Decision | Rationale |
|-------|----------|-----------|
| Story 1.1 split? | ❌ Keep as-is | Use detailed AC checklist, folder structure is one coherent unit |
| Story 1.3 split? | ❌ Keep combined | Migrations + seed = quick win, satu PR lebih clean |
| Story 1.4 blocker? | ✅ Unblocked | GitHub repo already exists |
| Parallelization | ✅ 2 tracks | Track A (Flutter), Track B (NestJS) |

---

### Epic 2 Stories

#### Story 2.1: Backend Auth Module with JWT Strategy

**User Story:** Sebagai user, saya dapat login dengan username dan password agar mendapat akses ke aplikasi.

**Scope:**
- NestJS AuthModule dengan JWT strategy
- Login endpoint dengan bcrypt validation
- JWT token generation

**FRs Covered:** FR4 (validate credentials), FR5 (JWT generation), FR6 (error message)

**Acceptance Criteria:**
- [ ] AuthModule created dengan Passport JWT strategy
- [ ] `POST /api/v1/auth/login` endpoint implemented
- [ ] Request body validation: `{ username: string, password: string }`
- [ ] Success response (200):
  ```json
  {
    "accessToken": "eyJhbG...",
    "user": {
      "id": "uuid",
      "fullName": "Nama User",
      "role": "KASIE",
      "estateId": "uuid",
      "isFirstTime": true
    }
  }
  ```
- [ ] Password validation dengan `bcrypt.compare()` (cost factor 10+)
- [ ] JWT payload: `{ sub: userId, username, role, estateId }`
- [ ] JWT expiry: 14 days (NFR11)
- [ ] Error responses in Bahasa Indonesia:
  - [ ] 401: `{ message: 'Username atau password salah' }` (FR6)
  - [ ] 400: `{ message: 'Username dan password harus diisi' }`
- [ ] Unit tests untuk AuthService

**Test Requirement:** Integration test dengan actual bcrypt timing

**Track:** B (Backend)

---

#### Story 2.2: Backend Rate Limiting & Account Lockout

**User Story:** Sebagai system, saya membatasi percobaan login untuk mencegah brute force attack.

**Scope:**
- Per-username rate limiting
- Failed attempts tracking
- Account lockout mechanism

**NFRs Covered:** NFR15 (rate limit), NFR16 (lockout)

**Acceptance Criteria:**
- [ ] @nestjs/throttler configured dengan custom storage (per-username, NOT per-IP)
- [ ] Rate limit: Max 5 attempts per 15 minutes per username
- [ ] `failed_login_attempts` column incremented on failed login
- [ ] Reset `failed_login_attempts = 0` on successful login
- [ ] After 10 failed attempts:
  - [ ] Set `locked_until = NOW() + 30 minutes`
  - [ ] Return 423: `{ message: 'Akun terkunci selama 30 menit' }`
- [ ] Rate limited returns 429: `{ message: 'Terlalu banyak percobaan. Tunggu 15 menit.' }`
- [ ] Locked account check happens BEFORE password validation
- [ ] Auto-unlock after `locked_until` passed

**Test Requirement:** Integration test dengan 6+ sequential requests to verify throttle

**Track:** B (Backend, after 2.1)

**Test Strategy Note:** Use `jest.useFakeTimers()` atau test dengan reduced throttle window untuk CI speed.

---

#### Story 2.3: Flutter Login Page with AuthBloc

**User Story:** Sebagai user, saya dapat memasukkan username dan password di halaman login yang responsif.

**Scope:**
- Login page UI dengan semua elements
- AuthBloc untuk state management
- Login flow integration

**FRs Covered:** FR1 (login form), FR2 (password toggle), FR3 (remember me), FR6 (error), FR34 (retry), FR36 (loading)

**Acceptance Criteria:**

**UI Elements:**
- [ ] `lib/features/auth/presentation/pages/login_page.dart`
- [ ] Username TextField dengan label "Username"
- [ ] Password TextField dengan:
  - [ ] Label "Password"
  - [ ] Toggle visibility icon (eye/eye-off) (FR2)
  - [ ] Default: obscured text
- [ ] "Ingat Saya" checkbox dengan label (FR3)
- [ ] Login button:
  - [ ] Text: "Masuk"
  - [ ] Color: AppColors.buttonOrange
  - [ ] **Loading state: spinner inside button, button disabled** (FR36)
- [ ] Form validation: both fields required
- [ ] Error display: SnackBar dengan message dari API (FR6)

**AuthBloc:**
- [ ] `AuthBloc` dengan states: `Initial`, `Loading`, `Authenticated`, `Unauthenticated`, `Error`
- [ ] `AuthEvent`: `LoginRequested`, `LogoutRequested`, `CheckAuthStatus`
- [ ] `LoginUseCase` dengan `Either<Failure, AuthEntity>`
- [ ] `AuthRepository` interface + `AuthRepositoryImpl`

**Network & Retry:**
- [ ] Dio client configured
- [ ] Retry interceptor (FR34):
  - [ ] Max 3 retries
  - [ ] Exponential backoff: 1s, 2s, 4s
  - [ ] Only retry on network errors (timeout, connection refused)
  - [ ] Do NOT retry on 4xx errors
- [ ] Error handling:
  - [ ] 401 → "Username atau password salah"
  - [ ] 423 → "Akun terkunci selama 30 menit"
  - [ ] 429 → "Terlalu banyak percobaan"
  - [ ] Network error → "Tidak dapat terhubung ke server"

**Test Requirement:** Widget test for UI, unit test for AuthBloc

**Track:** A (Frontend)

---

#### Story 2.4: Secure Token Storage, Offline Login & ConnectivityService

**User Story:** Sebagai user, saya dapat tetap login meskipun offline selama token masih valid.

**Scope:**
- JWT storage di Hive encrypted box (USES existing Hive from Story 1.1)
- **ConnectivityService dengan debounced stream** ← NEW
- Offline validation logic
- Remember Me behavior
- JWT grace period

**FRs Covered:** FR22 (JWT cache 14 days), FR3 (remember me persistence)
**NFRs Covered:** NFR6 (4G low-signal), NFR18 (offline login), NFR25 (24h grace period)

**Note:** Story 1.1 sudah initialize Hive dengan encryption. Story ini HANYA menggunakan Hive yang sudah ready.

**Acceptance Criteria:**

**ConnectivityService (Shared Infrastructure):** ← NEW SECTION
- [ ] `lib/core/network/connectivity_checker.dart` - interface:
  ```dart
  abstract class ConnectivityChecker {
    Stream<ConnectivityStatus> get onConnectivityChanged;
    Future<bool> isOnline();
  }

  enum ConnectivityStatus { online, offline }
  ```
- [ ] `lib/core/network/connectivity_service.dart` - implementation:
  ```dart
  class ConnectivityService implements ConnectivityChecker {
    // Uses connectivity_plus package
    // Debounce: 2 second delay before emitting offline
    // Online → emit immediately
    // Offline → wait 2s, verify still offline, then emit
  }
  ```
- [ ] Debounce logic prevents rapid flashing saat signal fluctuates
- [ ] Registered di DI container sebagai singleton
- [ ] Unit test with `MockConnectivityChecker`

**Storage:**
- [ ] `AuthLocalDataSource` class
- [ ] Use existing encrypted Hive box from Story 1.1
- [ ] Auth box schema:
  ```dart
  {
    'token': String,
    'expiresAt': DateTime,  // token issue time + 14 days
    'user': UserModel,
    'rememberMe': bool
  }
  ```

**Remember Me Behavior:**
- [ ] `rememberMe = true`: persist token across app restarts
- [ ] `rememberMe = false`: clear token on app close/background (configurable)

**Offline Validation:**
- [ ] `isTokenValid()` method uses `ConnectivityChecker.isOnline()`:
  ```dart
  Future<bool> isTokenValid() async {
    if (token == null) return false;
    if (expiresAt > DateTime.now()) return true;  // Normal valid
    // Grace period: 24 hours after expiry for offline-only (NFR25)
    final isOffline = !(await connectivityChecker.isOnline());
    if (isOffline && expiresAt.add(Duration(hours: 24)) > DateTime.now()) {
      return true;
    }
    return false;
  }
  ```
- [ ] Grace period ONLY applies when device is offline
- [ ] Online + expired → redirect to login

**Tests:**
- [ ] Unit test: ConnectivityService debounce behavior
- [ ] Unit test: token valid → return true
- [ ] Unit test: token expired, online → return false
- [ ] Unit test: token expired < 24h, offline → return true (grace period)
- [ ] Unit test: token expired > 24h, offline → return false

**Test Requirement:** Unit tests with MockConnectivityChecker

**Track:** A (Frontend, after 2.3)

**Party Mode Update (2026-01-10):** ConnectivityService added here karena ini first consumer. Epic 4 fokus pada UI resilience (banners, warnings).

---

#### Story 2.5: Logout UseCase (Infrastructure Only)

**User Story:** Sebagai system, logout mechanism sudah siap untuk digunakan di post-MVP.

**Scope:**
- LogoutUseCase implementation
- Cache clearing logic
- NO UI implementation (deferred to post-MVP)

**FRs Covered:** FR31 (logout), FR32 (clear cache)

**Deferred to Post-MVP:**
- ❌ Logout button UI
- ❌ Logout menu/page
- ❌ FR33: Single session enforcement

**Acceptance Criteria:**
- [ ] `LogoutUseCase` class created
- [ ] Logout flow:
  1. Clear auth token from Hive box
  2. Clear cached user data
  3. Emit `Unauthenticated` state to AuthBloc
- [ ] `AuthRepository.logout()` method
- [ ] `AuthLocalDataSource.clearAuth()` method
- [ ] Unit test: logout clears all auth data
- [ ] Integration ready: can be called from any future UI

**Note:** Logout UI akan ditambahkan di post-MVP saat ada settings/profile page.

**Test Requirement:** Unit test verifying all auth data cleared

**Track:** A (Frontend, parallel with 2.4)

---

#### Story 2.6: go_router Auth Integration

**User Story:** Sebagai user, saya otomatis diarahkan ke halaman yang sesuai berdasarkan status login saya.

**Scope:**
- Router configuration dengan auth guards
- Automatic redirects berdasarkan auth state

**Acceptance Criteria:**

**User-Observable Behavior:**
- [ ] User belum login → melihat Login Page
- [ ] User sudah login → melihat Home Page
- [ ] User logout → redirect ke Login Page
- [ ] Deep link ke `/home` saat unauthenticated → redirect ke Login Page
- [ ] App restart dengan valid token → langsung ke Home Page
- [ ] Tidak ada flicker/flash saat redirect

**Technical Implementation:**
- [ ] `app_router.dart` dengan GoRouter
- [ ] Routes:
  - [ ] `/login` → LoginPage
  - [ ] `/home` → HomePage (placeholder untuk Epic 3)
- [ ] `refreshListenable` connected ke AuthBloc stream
- [ ] `redirect` function checks `AuthBloc.state`
- [ ] Initial route determined by `CheckAuthStatus` event

**Test Requirement:** Widget test for redirect behavior

**Track:** A (Frontend, after 2.4)

---

### Epic 2 Party Mode Decisions (2026-01-10)

| Issue | Decision | Rationale |
|-------|----------|-----------|
| Merge Story 2.3 + 2.4? | ✅ Merged | Login UI + BLoC = satu unit fungsional |
| Single Session (FR33)? | ❌ Deferred | Field workers = 1 device, simplify MVP |
| Logout UI? | ❌ Deferred | Single main page MVP, logout via settings post-MVP |
| Hive init di Story 2.4? | ✅ Clarified | Story 1.1 init, Story 2.4 only consumes |
| Login loading style? | ✅ Button state | Spinner inside button, form visible |

**Deferred to Post-MVP:**
- FR33: Single Session Enforcement
- Logout button/menu UI
- Settings/Profile page

---

### Epic 3 Stories

#### Story 3.1: HomePage Layout with GreetingHeader & Clock

**User Story:** Sebagai user, saya melihat sapaan personal dan waktu saat ini saat membuka dashboard.

**Scope:**
- HomePage structure
- GreetingHeader widget dengan time-based greeting
- Clock widget dengan WIB timezone

**FRs Covered:** FR7 (greeting), FR9 (clock WIB), FR12 (role-based layout base)

**Acceptance Criteria:**

**HomePage Structure:**
- [ ] `lib/features/home/presentation/pages/home_page.dart`
- [ ] SafeArea applied
- [ ] SingleChildScrollView untuk content
- [ ] Column layout: GreetingHeader → Clock → WeatherWidget (placeholder) → MenuCards (placeholder)

**GreetingHeader Widget:**
- [ ] `lib/features/home/presentation/widgets/greeting_header.dart`
- [ ] Time-based greeting logic:
  - 00:00-11:59 → "Selamat Pagi, {fullName}"
  - 12:00-14:59 → "Selamat Siang, {fullName}"
  - 15:00-17:59 → "Selamat Sore, {fullName}"
  - 18:00-23:59 → "Selamat Malam, {fullName}"
- [ ] User name dari AuthBloc state (`state.user.fullName`)
- [ ] Typography: AppTextStyles.w700s20
- [ ] **Auto-update:** Greeting recalculates on widget rebuild (no stale greeting across time boundaries)

**Clock Widget:**
- [ ] `lib/features/home/presentation/widgets/clock_widget.dart`
- [ ] Display format: "HH:mm WIB"
- [ ] Timezone: WIB (UTC+7) hardcoded
- [ ] Auto-update: StreamBuilder dengan `Stream.periodic(Duration(minutes: 1))`
- [ ] Typography: AppTextStyles.w500s12, color: AppColors.textSecondary

**Test Requirement:** Widget test for greeting logic at different times

**Track:** A (Frontend)

---

#### Story 3.2: Backend Weather Proxy with Adapter Pattern

**User Story:** Sebagai system, saya menyediakan data cuaca dari provider eksternal dengan pattern yang swappable.

**Scope:**
- NestJS WeatherModule
- OpenWeatherMap integration
- Adapter pattern untuk future provider swap
- Hardcoded location: Lampung Tengah

**NFRs Covered:** NFR33 (adapter pattern), NFR34 (5s timeout)

**Acceptance Criteria:**

**Location Constant (Lampung Tengah):**
- [ ] Hardcoded coordinates:
  ```typescript
  // src/weather/constants/location.constant.ts
  export const DEFAULT_LOCATION = {
    latitude: -4.8357,
    longitude: 105.0273,
    name: 'Lampung Tengah'
  };
  ```

**Adapter Pattern:**
- [ ] `WeatherProviderInterface`:
  ```typescript
  interface WeatherProviderInterface {
    getCurrentWeather(lat: number, lon: number): Promise<WeatherData>;
  }
  ```
- [ ] `OpenWeatherMapProvider` implements interface
- [ ] Provider registered as injectable, swappable via module config

**Weather Endpoint:**
- [ ] `GET /api/v1/weather` (no params needed, uses hardcoded location)
- [ ] Optional override: `GET /api/v1/weather?lat={lat}&lon={lon}`
- [ ] Timeout: 5 seconds (NFR34)
- [ ] Response format:
  ```json
  {
    "temperature": 28,
    "condition": "Cerah Berawan",
    "icon": "02d",
    "humidity": 75,
    "location": "Lampung Tengah",
    "timestamp": "2026-01-10T10:30:00+07:00"
  }
  ```

**Error Handling:**
- [ ] Provider timeout → 503: `{ message: 'Layanan cuaca tidak tersedia' }`
- [ ] Provider error → 503 with cached response if available
- [ ] Invalid API key → log error, return 503

**Environment:**
- [ ] `OPENWEATHERMAP_API_KEY` in `.env`
- [ ] API key documented in `.env.example`

**Test Requirement:** Unit test dengan mocked OpenWeatherMap response

**Track:** B (Backend)

---

#### Story 3.3: WeatherWidget with Cache & Auto-Refresh

**User Story:** Sebagai user, saya melihat informasi cuaca terkini untuk planning kerja lapangan.

**Scope:**
- WeatherWidget UI dengan skeleton loading
- WeatherBloc untuk state management
- Hive cache 30 menit
- Auto-refresh setiap 30 menit
- Graceful fallback
- LocationProvider interface (future-ready)

**FRs Covered:** FR8 (weather display), FR23 (cache 30min), FR24 (fallback), FR37 (skeleton)
**NFRs Covered:** NFR2 (async), NFR7 (non-blocking), NFR19 (cache), NFR27-29 (freshness)

**Acceptance Criteria:**

**LocationProvider Interface (Future-Ready):**
- [ ] `lib/core/location/location_provider.dart`:
  ```dart
  abstract class LocationProvider {
    Future<LocationResult> getCurrentLocation();
  }
  ```
- [ ] `HardcodedLocationProvider` implements interface:
  ```dart
  class HardcodedLocationProvider implements LocationProvider {
    static const double latitude = -4.8357;   // Lampung Tengah
    static const double longitude = 105.0273;

    Future<LocationResult> getCurrentLocation() async {
      return LocationResult(latitude: latitude, longitude: longitude);
    }
  }
  ```
- [ ] Registered di DI container

**WeatherWidget UI:**
- [ ] `lib/features/weather/presentation/widgets/weather_widget.dart`
- [ ] Display elements:
  - [ ] Temperature: "{temp}°C" (AppTextStyles.w700s20)
  - [ ] Condition: "{condition}" (AppTextStyles.w500s12)
  - [ ] Weather icon (mapped from OpenWeatherMap icon codes)
  - [ ] Location: "Lampung Tengah"
- [ ] **Timestamp:** "Diperbarui: HH:mm WIB" (NFR27)
- [ ] **Disclaimer:** "Prakiraan cuaca, dapat berubah" (NFR29)

**WeatherWidgetSkeleton:**
- [ ] `lib/features/weather/presentation/widgets/weather_widget_skeleton.dart`
- [ ] Shimmer effect untuk: temperature, condition, icon
- [ ] Same dimensions as actual widget

**WeatherBloc:**
- [ ] States: `WeatherInitial`, `WeatherLoading`, `WeatherLoaded`, `WeatherError`
- [ ] Events: `LoadWeather`, `RefreshWeather`
- [ ] `WeatherLoaded` contains: `WeatherEntity`, `DateTime lastUpdated`
- [ ] `WeatherError` contains: `String message`, `WeatherEntity? cachedData`

**Cache (NFR19):**
- [ ] `WeatherLocalDataSource` menggunakan Hive
- [ ] Cache duration: 30 menit
- [ ] Cache key: `weather_lampung_tengah`
- [ ] On load: show cached immediately → fetch in background → update if new data

**Auto-Refresh (NFR28):**
- [ ] Timer.periodic setiap 30 menit
- [ ] Only when app in foreground (use `WidgetsBindingObserver`)
- [ ] Cancel timer di `dispose()`
- [ ] Resume timer saat app resume

**Graceful Fallback (FR24):**
- [ ] On error with cache: show cached data + "Data terakhir tersedia"
- [ ] On error no cache: show "Cuaca tidak tersedia" + cloud-question icon
- [ ] Retry button: "Coba Lagi" (AppColors.buttonBlue)

**Non-Blocking (NFR7):**
- [ ] WeatherBloc loads independently
- [ ] Main page tidak menunggu weather selesai
- [ ] Skeleton shown while loading

**Test Requirement:** Unit tests for cache hit/miss/expired scenarios

**Track:** A (Frontend, depends on 3.2)

---

#### Story 3.4: Role-Based Menu Cards with HomePage Integration

**User Story:** Sebagai user, saya melihat menu yang sesuai dengan role saya.

**Scope:**
- TaskCard widget
- Role-based card layout
- Coming soon placeholder
- HomePage final assembly

**FRs Covered:** FR10 (Kasie: Buat Rencana), FR11 (All: Lihat Rencana), FR13 (2 cards), FR14 (1 card), FR26 (placeholder)

**Acceptance Criteria:**

**TaskCard Widget:**
- [ ] `lib/features/home/presentation/widgets/task_card.dart`
- [ ] Props: `title`, `subtitle`, `icon`, `onTap`
- [ ] Design per UX spec:
  - [ ] Rounded corners (12dp)
  - [ ] Elevation shadow
  - [ ] Icon on left (40x40)
  - [ ] Title + subtitle on right
- [ ] Touch feedback: InkWell with ripple
- [ ] Min height: 80dp
- [ ] 48dp touch target (accessibility)

**Card Icons:**
- [ ] "Buat Rencana Kerja" → `Icons.edit_note` atau `Icons.add_task`
- [ ] "Lihat Rencana Kerja" → `Icons.list_alt` atau `Icons.assignment`

**Role-Based Layout:**
- [ ] Read role dari AuthBloc: `context.read<AuthBloc>().state.user.role`
- [ ] **Role = KASIE:**
  ```dart
  Row(
    children: [
      Expanded(child: TaskCard(title: 'Buat Rencana Kerja', ...)),
      SizedBox(width: 12),
      Expanded(child: TaskCard(title: 'Lihat Rencana Kerja', ...)),
    ],
  )
  ```
- [ ] **Role ≠ KASIE:**
  ```dart
  TaskCard(
    title: 'Lihat Rencana Kerja',
    // Full width
  )
  ```

**Placeholder Behavior (FR26):**
- [ ] OnTap any card → show BottomSheet:
  ```dart
  showModalBottomSheet(
    child: Column(
      children: [
        Icon(Icons.construction, size: 64),
        Text('Fitur Segera Hadir'),
        Text('Fitur ini sedang dalam pengembangan'),
        ElevatedButton(onPressed: Navigator.pop, child: Text('Tutup')),
      ],
    ),
  )
  ```

**MenuCardSkeleton:**
- [ ] `lib/features/home/presentation/widgets/menu_card_skeleton.dart`
- [ ] Shimmer matching card dimensions
- [ ] Show if role not yet loaded (edge case)

**HomePage Final Assembly:**
- [ ] HomePage uses MultiBlocProvider (or inherits from app-level):
  - AuthBloc (from Epic 2)
  - WeatherBloc (from Story 3.3)
- [ ] BlocBuilder structure:
  ```dart
  Column(
    children: [
      GreetingHeader(),      // from AuthBloc
      ClockWidget(),         // standalone
      WeatherWidget(),       // from WeatherBloc
      SizedBox(height: 24),
      MenuCardsSection(),    // from AuthBloc (role)
    ],
  )
  ```
- [ ] No HomeBloc needed - direct consumption of existing BLoCs

**Test Requirement:** Widget test for role-based layout (KASIE vs non-KASIE)

**Track:** A (Frontend, depends on 3.1, 3.3)

---

### Epic 3 Party Mode Decisions (2026-01-10)

| Issue | Decision | Rationale |
|-------|----------|-----------|
| Weather location source | ✅ Hardcoded (Lampung Tengah) | MVP = single estate, GPS adds complexity |
| Coordinates | -4.8357, 105.0273 | Lampung Tengah, Sumatra |
| HomeBloc needed? | ❌ Removed | Redundant - use AuthBloc + WeatherBloc |
| Story count | 4 (was 5) | Leaner scope |
| Future GPS support | ✅ LocationProvider interface | Easy swap post-MVP |
| Greeting auto-update | ✅ Added | Recalculate on rebuild |

**Deferred to Post-MVP:**
- GPS-based location
- Multi-estate support
- GpsLocationProvider implementation

---

### Epic 4 Stories

**Note:** ConnectivityService infrastructure sudah di-cover di Story 2.4. Epic 4 fokus pada UI/UX resilience aspects.

#### Story 4.1: OfflineBanner Widget with Priority Manager

**User Story:** Sebagai user, saya tahu kapan device offline dan bisa mencoba refresh.

**Scope:**
- OfflineBanner UI widget
- Banner priority manager (session warning > offline)
- Tappable refresh action
- Integration dengan ConnectivityService dari Epic 2

**FRs Covered:** FR30 (offline indicator)

**Acceptance Criteria:**

**OfflineBanner Widget:**
- [ ] `lib/core/widgets/offline_banner.dart`
- [ ] Design per UX spec:
  - Background: `Color(0xFFFFA726)` (amber/warning)
  - Icon: `Icons.cloud_off`
  - Text: "Offline - Tap untuk refresh"
  - Full width, fixed height (48dp)
  - 48dp touch target (accessibility)
- [ ] Position: Top of screen dalam SafeArea (no AppBar in MVP)
- [ ] **Tappable:** OnTap triggers refresh callback
- [ ] Animation:
  - SlideTransition from top
  - Duration: 300ms
  - Curve: Curves.easeOut

**Banner Priority Manager:**
- [ ] `lib/core/widgets/banner_priority_manager.dart`
- [ ] Priority order (highest first):
  1. Session expiry warning (< 2 days)
  2. Offline banner
- [ ] Only ONE banner shown at a time
- [ ] Logic:
  ```dart
  Widget? getCurrentBanner() {
    if (shouldShowSessionWarning()) return SessionWarningBanner();
    if (isOffline) return OfflineBanner();
    return null;
  }
  ```

**BannerWrapper Widget:**
- [ ] `lib/core/widgets/banner_wrapper.dart`
- [ ] Wraps HomePage content
- [ ] Listens to:
  - `ConnectivityChecker.onConnectivityChanged`
  - `AuthLocalDataSource` for expiry check
- [ ] Uses BannerPriorityManager to decide which banner
- [ ] Smooth transition between banners (or to no banner)

**Integration:**
- [ ] OfflineBanner OnTap triggers:
  - `WeatherBloc.add(RefreshWeather())`
  - Any other pending refresh
- [ ] Hide banner when back online (with animation)

**Test Requirement:** Widget test for show/hide and priority logic

**Track:** A (Frontend, depends on Story 2.4 ConnectivityService)

---

#### Story 4.2: JWT Expiry Warning & Actionable Error Messages

**User Story:** Sebagai user, saya diberi peringatan sebelum session expired dan error message yang jelas saat ada masalah.

**Scope:**
- JWT expiry warning banner
- Rate-limited warning (once per day)
- Actionable error messages catalog
- Force logout on complete expiry

**FRs Covered:** FR25 (JWT warning), FR35 (actionable errors)
**NFRs Covered:** NFR26 (session expiry warning)

**Acceptance Criteria:**

**SessionWarningBanner Widget:**
- [ ] `lib/features/auth/presentation/widgets/session_warning_banner.dart`
- [ ] Show warning when JWT expires in < 2 days
- [ ] Design:
  - Background: `Color(0xFFFFA726)` (amber/warning)
  - Icon: `Icons.access_time`
  - Text: "Sesi berakhir dalam {X} hari. Login ulang saat online."
  - Full width, height 56dp (slightly taller for more text)
- [ ] **Dismissible:** Tap X to close
- [ ] **Rate limited:** Once per day max
  - Store `lastWarningShownAt` in Hive
  - Check: `DateTime.now().difference(lastShown).inHours >= 24`

**Expiry Check Logic:**
- [ ] Check on:
  - App foreground (WidgetsBindingObserver.didChangeAppLifecycleState)
  - Periodic: every 1 hour via Timer
- [ ] Calculation:
  ```dart
  int getDaysUntilExpiry() {
    final expiresAt = authLocalDataSource.getExpiresAt();
    return expiresAt.difference(DateTime.now()).inDays;
  }

  bool shouldShowWarning() {
    final days = getDaysUntilExpiry();
    final canShow = canShowWarningToday(); // rate limit check
    return days <= 2 && days >= 0 && canShow;
  }
  ```

**Force Logout on Complete Expiry:**
- [ ] When token expired AND grace period (24h) passed:
  - Clear auth data
  - Redirect to login
  - Show message: "Sesi telah berakhir. Silakan login kembali."
- [ ] This check runs on app start and periodic

**Actionable Error Messages (FR35):**
- [ ] `lib/core/error/error_messages.dart` - centralized catalog:
  ```dart
  class ErrorMessages {
    static const networkTimeout = 'Koneksi terputus. Periksa jaringan dan coba lagi.';
    static const serverError = 'Terjadi kesalahan server. Coba lagi nanti.';
    static const authFailed = 'Username atau password salah.';
    static const rateLimited = 'Terlalu banyak percobaan. Tunggu 15 menit.';
    static const accountLocked = 'Akun terkunci selama 30 menit.';
    static const weatherUnavailable = 'Cuaca tidak tersedia. Tap untuk coba lagi.';
    static const offline = 'Anda sedang offline. Data terakhir ditampilkan.';
    static const sessionExpiring = 'Sesi akan berakhir. Login ulang saat online.';
    static const sessionExpired = 'Sesi telah berakhir. Silakan login kembali.';
  }
  ```
- [ ] Pattern: "{Apa yang terjadi}. {Apa yang bisa dilakukan}."
- [ ] All in Bahasa Indonesia

**SnackBar Helper:**
- [ ] `lib/core/utils/snackbar_helper.dart`:
  ```dart
  void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }
  ```
- [ ] Used consistently across app

**Test Requirement:** Unit test for expiry calculation, rate limit logic

**Track:** A (Frontend, depends on Epic 2)

---

### Epic 4 Party Mode Decisions (2026-01-10)

| Issue | Decision | Rationale |
|-------|----------|-----------|
| ConnectivityService location | ✅ Moved to Epic 2.4 | First consumer is offline login |
| Epic 4 story count | 2 (was 3) | Focus on UI resilience only |
| Banner priority | ✅ Session warning > Offline | Session expiry more critical |
| Session warning frequency | ✅ Once per day | Avoid annoying field workers |
| Force logout | ✅ After grace period | Clear UX on complete expiry |

**Epic 4 Dependencies:**
- Story 2.4: ConnectivityService (infrastructure)
- Story 4.1: OfflineBanner (uses ConnectivityService)
- Story 4.2: SessionWarning (uses AuthLocalDataSource)

---

### Epic 5 Stories

#### Story 5.1: Backend First-Time Status Endpoint

**User Story:** Sebagai system, saya dapat track dan update status first-time user.

**Scope:**
- PATCH endpoint untuk update is_first_time
- First-time status included in login response (verify from Epic 2)

**FRs Covered:** FR15 (detect first-time), FR17 (update flag)

**Acceptance Criteria:**

**Endpoint:**
- [ ] `PATCH /api/v1/users/me/first-time`
- [ ] Request body:
  ```json
  {
    "isFirstTime": false
  }
  ```
- [ ] Response: `{ success: true, message: 'Status updated' }`
- [ ] Requires JWT authentication
- [ ] Updates `is_first_time` column in users table
- [ ] Validation: isFirstTime must be boolean

**Login Response Verification:**
- [ ] Verify `isFirstTime` included in user object from Story 2.1:
  ```json
  {
    "accessToken": "...",
    "user": {
      "id": "...",
      "fullName": "...",
      "role": "...",
      "isFirstTime": true
    }
  }
  ```

**Error Handling:**
- [ ] 401 if not authenticated
- [ ] 400 if invalid body

**Test Requirement:** Integration test for endpoint

**Track:** B (Backend)

---

#### Story 5.2: Contextual Tooltips for First-Time Users

**User Story:** Sebagai first-time user, saya melihat hints yang membantu memahami fitur tanpa training.

**Scope:**
- TooltipOverlay reusable widget
- First-time hint sequence (2 tooltips)
- Local persist for completion tracking
- Server sync best-effort (not critical)

**FRs Covered:** FR15 (detect), FR16 (show tooltips), FR17 (update flag)

**Acceptance Criteria:**

**TooltipOverlay Widget:**
- [ ] `lib/core/widgets/tooltip_overlay.dart`
- [ ] Reusable overlay for contextual hints
- [ ] Props:
  ```dart
  TooltipOverlay({
    required Widget child,
    required String message,
    required TooltipPosition position, // top, bottom
    required VoidCallback onDismiss,
  })
  ```
- [ ] Design:
  - Background: `Colors.black.withOpacity(0.5)` overlay
  - Tooltip bubble: white, rounded corners, arrow pointing to target
  - Text: AppTextStyles.w500s12
  - Button: "Mengerti" (AppColors.primary)
- [ ] Animation: FadeIn 300ms

**First-Time Detection:**
- [ ] Check `user.isFirstTime` dari AuthBloc state
- [ ] Check local `completedTooltips` dari Hive
- [ ] Show if: `user.isFirstTime == true && !locallyCompleted`

**Tooltip Sequence (2 tooltips):**
- [ ] **Tooltip 1: Weather Widget**
  - Key: `'weather'`
  - Target: WeatherWidget
  - Position: **bottom** (tooltip appears below widget)
  - Message: "Lihat prakiraan cuaca untuk merencanakan aktivitas lapangan"
  - Show: when HomePage loads (if first-time)

- [ ] **Tooltip 2: Menu Card**
  - Key: `'menu_card'`
  - Target: "Lihat Rencana Kerja" card
  - Position: **top** (tooltip appears above card)
  - Message: "Tap untuk melihat rencana kerja Anda"
  - Show: after Tooltip 1 dismissed

**Completion Tracking (Local Persist):**
- [ ] `lib/features/home/data/first_time_local_data_source.dart`
- [ ] Store in Hive: `completedTooltips: Set<String>` (e.g., `{'weather', 'menu_card'}`)
- [ ] Track by key (not index) - resilient to app kill mid-sequence
- [ ] On tooltip dismiss: add key to set, persist immediately
- [ ] All complete when: `completedTooltips.containsAll(['weather', 'menu_card'])`

**App Kill Recovery:**
- [ ] If app killed after Tooltip 1:
  - `completedTooltips = {'weather'}`
  - On restart: skip Tooltip 1, show Tooltip 2 only

**Server Sync (Best-Effort):**
- [ ] After ALL tooltips complete:
  - Update local AuthBloc: `user.isFirstTime = false`
  - If online: call `PATCH /api/v1/users/me/first-time`
  - If offline: **don't queue**, just skip sync
  - Next online login will get fresh `isFirstTime` from server
- [ ] Not critical - local state is source of truth for tooltip display

**Integration with HomePage:**
- [ ] `FirstTimeHintsWrapper` stateful widget
- [ ] Wraps HomePage content
- [ ] Manages tooltip sequence state
- [ ] Renders TooltipOverlay over target widgets using Overlay/Stack

**No Skip Button:**
- [ ] Sequential dismiss only (2 taps max)
- [ ] Simple and fast for MVP

**Test Requirement:** Widget test for sequence, unit test for local persist

**Track:** A (Frontend, depends on 5.1 and Epic 3)

---

### Epic 5 Party Mode Decisions (2026-01-10)

| Issue | Decision | Rationale |
|-------|----------|-----------|
| Offline sync handling | ✅ Local persist only | Simpler, no queue complexity |
| Server sync | ✅ Best-effort, not critical | Local state is truth for tooltip display |
| Skip all button | ❌ Not needed | 2 tooltips = 2 taps, fast enough |
| Future JSON schema | ❌ Removed | Keep simple boolean, extend post-MVP |
| Track by key vs index | ✅ By key | Resilient to app kill mid-sequence |
| Tooltip positions | ✅ Specified | Weather: bottom, Card: top |

**Deferred to Post-MVP:**
- Feature-based tooltip system (`feature_key` tracking)
- Pulse animation on target widgets
- More tooltips for new features

---

### Epic 6 Stories

**Note:** Epic 6 adalah scripts-only (no Flutter/UI). Dikerjakan last karena development pakai dev account dari Epic 1.

#### Story 6.1: CSV Validation Script

**User Story:** Sebagai admin, saya dapat memvalidasi file CSV sebelum import untuk menghindari error.

**Scope:**
- CLI script untuk validate CSV format
- Shared validation library
- Detailed error reporting dengan line numbers

**FRs Covered:** FR19 (CSV validation)

**Acceptance Criteria:**

**Shared Validation Library:**
- [ ] `scripts/lib/csv-validator.ts` - shared validation logic
- [ ] Used by both validate and import scripts
- [ ] Prevents drift between validation rules

**Script:**
- [ ] `scripts/validate-csv.ts`
- [ ] Usage: `npm run csv:validate -- --file=users.csv`
- [ ] Exit code 0 = valid, Exit code 1 = invalid

**Required Columns:**
- [ ] `username` - string, required, max 50 chars, alphanumeric + underscore
- [ ] `password` - string, required, min 8 chars, at least 1 digit (NFR17)
- [ ] `full_name` - string, required, max 100 chars
- [ ] `role` - enum: `KASIE`, `OPERATOR`, `MANDOR`, `ADMIN`
- [ ] `estate_id` - string (UUID format), optional (no FK constraint)

**Validation Rules:**
- [ ] Header row must match expected columns
- [ ] No empty required fields
- [ ] Username: `/^[a-zA-Z0-9_]+$/`
- [ ] Password: min 8 chars, `/\d/` (contains digit)
- [ ] Role: must be valid enum value
- [ ] Estate ID: valid UUID format or empty
- [ ] No duplicate usernames within file

**Error Report:**
- [ ] Error output format:
  ```
  ❌ Validation Failed

  Line 3: username 'john doe' contains invalid characters (use alphanumeric and underscore only)
  Line 5: password too short (minimum 8 characters)
  Line 7: role 'SUPERVISOR' is not valid (must be KASIE, OPERATOR, MANDOR, ADMIN)
  Line 12: duplicate username 'ahmad_kasie' (first occurrence at line 4)

  Total: 4 errors found
  ```
- [ ] Success output format:
  ```
  ✅ Validation Passed

  Total rows: 45
  Roles breakdown: KASIE (5), OPERATOR (30), MANDOR (8), ADMIN (2)
  Ready for import
  ```

**npm Script:**
- [ ] `package.json`:
  ```json
  "csv:validate": "ts-node scripts/validate-csv.ts"
  ```

**Test Fixtures:**
- [ ] `scripts/__tests__/fixtures/valid-users.csv`
- [ ] `scripts/__tests__/fixtures/invalid-password.csv`
- [ ] `scripts/__tests__/fixtures/invalid-role.csv`
- [ ] `scripts/__tests__/fixtures/duplicate-username.csv`

**Test Requirement:** Unit test for each validation rule

**Track:** B (Backend, scripts)

---

#### Story 6.2: CSV Import Script with Password Hashing

**User Story:** Sebagai admin, saya dapat import users dari CSV ke database dengan password yang sudah di-hash secara aman.

**Scope:**
- CLI script untuk import validated CSV
- Dry-run mode untuk preview
- Password hashing with bcrypt
- Transaction-based import
- Detailed import report

**FRs Covered:** FR18 (CSV import), FR20 (bcrypt hash), FR21 (estate ID), FR27 (role assignment)

**Acceptance Criteria:**

**Shared Database Connection:**
- [ ] `scripts/lib/db-connection.ts`
- [ ] Reuses TypeORM config from main app
- [ ] Handles connection lifecycle

**Script:**
- [ ] `scripts/import-csv.ts`
- [ ] Usage: `npm run csv:import -- --file=users.csv [options]`
- [ ] Options:
  - `--dry-run` - preview without changes
  - `--skip-validation` - skip validation step
  - `--update-existing` - update existing users (except password)
  - `--force-password` - also update password for existing

**Dry-Run Mode:**
- [ ] `--dry-run` flag outputs preview:
  ```
  🔍 Dry Run Mode (no changes will be made)

  Would create: 42 new users
  Would skip: 3 existing users

  Sample of new users:
    - ahmad_kasie (KASIE)
    - budi_operator (OPERATOR)
    - ...

  Run without --dry-run to execute import.
  ```

**Password Hashing (FR20):**
- [ ] Hash with bcrypt, cost factor 10 (NFR9)
- [ ] Never log or store plain text password
- [ ] Each password hashed individually (unique salt)

**Import Process:**
- [ ] Validate CSV first (unless --skip-validation)
- [ ] Begin database transaction
- [ ] For each row:
  1. Check if username exists
  2. If exists: skip (or update if --update-existing)
  3. If new: hash password, create user record
  4. Set defaults: `is_first_time=true`, `failed_login_attempts=0`
- [ ] Commit transaction on success
- [ ] Rollback on any error

**Estate ID Assignment (FR21):**
- [ ] Assign from CSV column (no FK constraint, just identifier)
- [ ] Validate UUID format if provided
- [ ] Allow null/empty for users without estate

**Import Report:**
- [ ] Success output:
  ```
  ✅ Import Complete

  New users created: 42
  Existing users skipped: 3
  Existing users updated: 0

  Total processed: 45
  Time elapsed: 2.3s
  ```
- [ ] Error output (with rollback):
  ```
  ❌ Import Failed at row 23

  Error: Database constraint violation
  Details: Username 'existing_user' already exists

  ⚠️ Transaction rolled back. No users imported.
  Fix the issue and try again.
  ```

**npm Scripts:**
- [ ] `package.json`:
  ```json
  "csv:validate": "ts-node scripts/validate-csv.ts",
  "csv:import": "ts-node scripts/import-csv.ts"
  ```

**Sample CSV & Documentation:**
- [ ] `scripts/README.md` with usage instructions
- [ ] Sample CSV format:
  ```csv
  username,password,full_name,role,estate_id
  ahmad_kasie,SecurePass123,Ahmad Sulaiman,KASIE,550e8400-e29b-41d4-a716-446655440000
  budi_operator,Password456,Budi Santoso,OPERATOR,
  citra_mandor,MyPass789,Citra Dewi,MANDOR,550e8400-e29b-41d4-a716-446655440000
  ```

**TypeScript Config:**
- [ ] Ensure scripts can run with ts-node
- [ ] Share types with main app where possible

**Test Requirement:** Integration test with test database, test rollback behavior

**Track:** B (Backend, scripts)

---

### Epic 6 Party Mode Decisions (2026-01-10)

| Issue | Decision | Rationale |
|-------|----------|-----------|
| Dry-run mode | ✅ Include in MVP | Low effort, prevents import mistakes |
| Estate ID FK | ❌ No FK constraint | Just identifier, estate managed externally |
| Shared validation | ✅ Extract to lib | Prevent drift between validate/import |
| Progress indicator | ❌ Deferred | Expected volume < 100 users for MVP |

**Deferred to Post-MVP:**
- Progress indicator for large imports (500+ users)
- Web UI for admin import
- Estate table with FK relationship

---

## Epic Dependencies

```
Epic 1: Foundation ──────────────────────────────────┐
    │                                                │
    ▼                                                │
Epic 2: Authentication ◄─────────────────────────────┤
    │                                                │
    ├────────────────┐                               │
    ▼                ▼                               │
Epic 3: Dashboard    Epic 4: Offline                 │
    │                    │                           │
    └────────┬───────────┘                           │
             ▼                                       │
         Epic 5: First-Time UX                       │
                                                     │
Epic 6: Admin Data ◄─────────────────────────────────┘
(Parallel/Last - uses dev account for testing)
```

**Dependency Rules:**
- Epic 1 → Foundation for all
- Epic 2 → Requires Epic 1 (Hive, design system)
- Epic 3 → Requires Epic 2 (authenticated user)
- Epic 4 → Requires Epic 2 (JWT, auth state)
- Epic 5 → Requires Epic 3 (main page context)
- Epic 6 → Independent, uses dev account from Epic 1

---

## Party Mode Decisions (2026-01-10)

**Participants:** Winston (Architect), John (PM), Sally (UX), Murat (Test Architect), Amelia (Dev), Bob (Scrum Master)

### Decision 1: Epic 4 Simplification ✅
**Issue:** Epic 4 terlalu complex dengan sync queue, exponential backoff, Last-Write-Wins
**Resolution:** Simplify untuk MVP - hanya read-only offline resilience
**Rationale:** MVP belum ada write operations (menu cards = placeholder/coming soon)
**Deferred:** Sync queue mechanism ke post-MVP saat ada actual data entry features

### Decision 2: Epic 5 Keep for MVP ✅
**Issue:** Sally questioned if first-time UX needed for simple app
**Resolution:** Keep Epic 5 - `is_first_time` schema diperlukan untuk masa depan
**Rationale:**
- Schema akan digunakan untuk contextual tooltips setiap fitur baru
- Foundation untuk consistent feature discovery UX
- Extensible pattern dengan `feature_key` based tooltips

### Decision 3: Epic 4 Tetap Terpisah ✅
**Issue:** Apakah Epic 4 merge dengan Epic 3?
**Resolution:** Tetap terpisah
**Rationale:** Separation of concerns - Dashboard vs Connectivity adalah domain berbeda


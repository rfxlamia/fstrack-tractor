# Product Requirements Document - FSTrack-Tractor

**Author:** V
**Date:** 2026-01-09

## Executive Summary

FSTrack-Tractor adalah aplikasi mobile untuk pelacakan lokasi traktor dan manajemen rencana kerja di perkebunan. PRD ini fokus pada **Fase 1: Login & Main Page** sebagai fondasi untuk fitur-fitur tracking dan approval yang lebih kompleks di masa depan.

### Scope PRD Ini

| In Scope | Out of Scope (Future PRD) |
|----------|---------------------------|
| Login page (username + password) | Live GPS Tracking |
| Authentication flow (JWT + bcrypt) | Activity Result submission |
| Main page dengan role-based UI | Check Location feature |
| Hybrid layout (primary + secondary cards) | Operator/Unit Management |
| Widget cuaca & suhu (adapter pattern) | Dashboard Analytics |
| Widget jam (WIB timezone) | Notification system |
| Menu "Buat Rencana Kerja" (Kasie only) | Biometric authentication |
| Menu "Lihat Rencana Kerja" (All roles) | |

### Future Roadmap

Fase 2 akan meliputi: Live GPS Tracking, Activity Submission, dan Approval Flow. Weather API akan di-upgrade ke company's AWS/satellite API.

### What Makes This Special

1. **Role-based Hybrid UI** - Kasie melihat primary card "Buat Rencana Kerja" yang prominent + secondary card "Lihat", sementara role lain hanya melihat single full-width card "Lihat Rencana Kerja"
2. **Secure authentication** - JWT tokens dengan bcrypt password hashing, HTTPS mandatory
3. **Contextual dashboard** - Widget cuaca, suhu, dan jam (WIB) memberikan konteks operasional untuk pekerjaan lapangan
4. **Swappable integrations** - Weather API menggunakan adapter pattern, siap diganti dengan company's AWS/satellite API

### Risk Mitigations

| Risk | Mitigation |
|------|------------|
| Login gagal di area sinyal lemah | Offline-first dengan JWT cache 7 hari |
| Password typo dari CSV | Validation saat import (trim, charset check) |
| Weather API failure | Graceful degradation + cache last known |
| Role tidak muncul dengan benar | Enum standardization + case-insensitive matching |
| Loading lambat | Single API call + skeleton loading, target < 3 detik |

### Technical Requirements

- **Login UX:** Show/hide password toggle, Remember Me checkbox
- **Error Handling:** Graceful degradation untuk semua external dependencies
- **Performance Target:** Login → Main Page ready dalam < 3 detik
- **Role System:** Enum-based roles, bukan free-text string

## Project Classification

**Technical Type:** Mobile App (Flutter) + SaaS B2B Backend (NestJS)
**Domain:** General (Plantation Operations)
**Complexity:** Low (MVP: Login + Main Page)
**Project Context:** Greenfield

### Tech Stack

- **Frontend:** Flutter (mobile)
- **Backend:** NestJS
- **Database:** PostgreSQL
- **Auth:** JWT + bcrypt
- **Weather:** Adapter pattern (free API for MVP → company API later)
- **Timezone:** WIB (Asia/Jakarta)

### Target Roles

1. Kasie PG - Plantation Manager (create + view work plans)
2. Kasie FE - Field Executive Manager (assign + view work plans)
3. Operator - Tractor operator (view assigned work plans)
4. Mandor - Supervisor (view only)
5. Estate PG - Estate manager (view only)
6. Admin - System administrator

### UI Layout Decision

**Hybrid Card Layout (Option C):**
- Kasie roles: Primary card (Buat) prominent + Secondary card (Lihat) slim
- Non-Kasie roles: Single full-width card (Lihat)
- Header: Weather widget + Clock (WIB)
- Greeting: Personalized with user name

## Success Criteria

### User Success

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Aha Moment** | User melihat nama mereka + info cuaca dalam < 3 detik | Time to first meaningful content |
| **Login Experience** | Smooth, tanpa friction | Zero retry needed untuk valid credentials |
| **Role-based UI** | Correct menu displayed per role | 100% accuracy role → UI mapping |
| **Contextual Value** | Cuaca/suhu/jam berguna untuk planning | Micro-survey setelah 3x login |

**User Success Scenarios:**
- **Kasie PG:** Login → langsung lihat "Buat Rencana Kerja" → merasa productive
- **Operator:** Login → lihat nama + cuaca → tahu kondisi hari ini → siap kerja
- **Semua Role:** App cepat, tidak ribet, informasi berguna

**Measurement Methods:**
- Micro-survey: "Apakah info cuaca membantu Anda hari ini? (Ya/Tidak)" - trigger setelah 3x login
- Heatmap tracking: First tap location setelah masuk main page

### Business Success

| Metric | Target | Phase |
|--------|--------|-------|
| **Internal Test Coverage** | 30 users berhasil login | Pre-launch |
| **Login Success Rate** | 99.9% untuk valid credentials | MVP |
| **Data Readiness** | Ratusan user dari CSV imported & validated | Pre-launch |
| **Zero Critical Bugs** | No blocker bugs di login flow | MVP Release |

**Phase Strategy:**
- **MVP (Current):** Login + Main Page only, internal test 30 orang
- **Field Pilot:** Setelah full features ready (Live Tracking, Activity, etc.)

### Technical Success

| Metric | Target | Validation |
|--------|--------|------------|
| **Performance** | Login → Main Page < 3 detik | Load testing |
| **Success Rate** | 99.9% untuk valid credentials | Monitoring + retry mechanism |
| **CSV Import** | 100% data imported with pre/post validation | Data validation script |
| **Offline Resilience** | JWT cache works 7 hari | Manual testing |
| **Role Mapping** | Enum-based, no mismatches | Unit tests |

### CSV Import Validation Checklist

**Pre-Import Validation:**
- [ ] CSV format valid (correct columns, encoding UTF-8)
- [ ] Required fields present (username, password, role, name)
- [ ] No duplicate usernames
- [ ] Role values match enum (kasie_pg, kasie_fe, operator, mandor, estate_pg, admin)
- [ ] Password meets minimum requirements

**Post-Import Verification:**
- [ ] Row count matches CSV row count
- [ ] All passwords properly hashed with bcrypt
- [ ] Role enum mapping verified for all users
- [ ] Sample login test (5 random users)

**Rollback Plan:**
- If import fails: Truncate users table, fix CSV, re-import
- Database backup before import

### Internal Test Scenario Table

| Test Scenario | Input | Expected Result | Pass Criteria |
|---------------|-------|-----------------|---------------|
| Valid login | Correct username + password | Main page loads | < 3 detik, correct role UI |
| Invalid password | Correct username, wrong password | Error message | "Password salah", no crash |
| Invalid username | Non-existent username | Error message | "User tidak ditemukan" |
| Role: Kasie PG | Login as Kasie PG | 2 menu cards | Buat + Lihat visible |
| Role: Operator | Login as Operator | 1 menu card | Only Lihat visible |
| Weather widget | Normal conditions | Weather data shown | Data atau graceful fallback |
| Clock widget | Any login | WIB time shown | Akurat ±1 menit |
| Remember Me | Check + login | Next open auto-login | No re-login needed |

### Negative Test Cases

| Scenario | Action | Expected Behavior |
|----------|--------|-------------------|
| Spam login button | Tap login 10x rapidly | Debounce, only 1 request sent |
| JWT expired mid-session | Token expires while on main page | Graceful redirect to login, no crash |
| Weather API timeout | API takes > 5 seconds | Show "Cuaca tidak tersedia" + cached data |
| Network offline | No internet connection | Show cached data, "Offline mode" indicator |
| SQL injection attempt | Username: `' OR 1=1 --` | Sanitized, login fails normally |

### Measurable Outcomes

**Week 1 Post-Internal Test:**
- [ ] 30/30 internal testers login successfully
- [ ] Success rate ≥ 99.9%
- [ ] Average load time < 3 seconds
- [ ] Zero login-related bugs reported
- [ ] All 6 roles display correct UI
- [ ] Negative test cases all pass

**Pre-Field Pilot Checklist:**
- [ ] All CSV data imported to PostgreSQL with validation
- [ ] Weather API integration stable (or graceful fallback working)
- [ ] Error handling graceful for all edge cases
- [ ] Micro-survey mechanism ready

## Product Scope

### MVP - Minimum Viable Product (Current PRD)

| Feature | Status | Priority |
|---------|--------|----------|
| Login page (username + password) | ✅ In Scope | P0 |
| JWT authentication with bcrypt | ✅ In Scope | P0 |
| Main page with role-based UI | ✅ In Scope | P0 |
| Hybrid card layout | ✅ In Scope | P0 |
| Weather/Suhu/Jam widgets | ✅ In Scope | P1 |
| CSV → PostgreSQL import script | ✅ In Scope | P0 |
| Retry mechanism for failed requests | ✅ In Scope | P1 |

### Growth Features (Post-MVP - Future PRD)

| Feature | Priority | Dependency |
|---------|----------|------------|
| Live GPS Tracking | P0 | Requires MVP complete |
| Activity Result submission | P0 | Requires GPS |
| Work Plan CRUD | P0 | Requires Auth |
| Notification system | P1 | Requires Activity |
| Check Location | P1 | Requires GPS |

### Vision (Future)

| Feature | Timeframe | Notes |
|---------|-----------|-------|
| Biometric authentication | Future | For audit trail security |
| Company Weather API integration | Future | Replace free API with AWS/satellite |
| Dashboard Analytics (Web) | Future | Separate web app |
| Offline full-sync | Future | For remote areas |

## User Journeys

### Journey 1: Pak Suswanto - Kasie PG Memulai Hari Kerja

**Persona:** Pak Suswanto, 45 tahun, Kasie PG di Estate Sungai Lilin. Sudah 15 tahun di perkebunan, familiar dengan teknologi dasar (WhatsApp, Excel). Bertanggung jawab membuat rencana kerja harian untuk tim traktor.

**Konteks:** Jam 5:30 pagi, Pak Suswanto bangun dan siap memulai hari. Sebelumnya, dia harus telepon beberapa orang untuk koordinasi rencana kerja. Sekarang, dia buka app FSTrack-Tractor.

---

**Opening Scene:**
Pak Suswanto duduk di teras rumahnya dengan secangkir kopi. Langit masih gelap, tapi dia perlu tahu cuaca hari ini untuk planning. Dia buka FSTrack-Tractor di HP Android-nya.

**Rising Action:**
Login screen muncul. Pak Suswanto ketik username "suswanto.pg" dan password yang sudah dia hafal. Tap "Masuk". Loading indicator muncul sebentar...

**Climax - Aha Moment:**
Dalam 2 detik, main page muncul. "Selamat pagi, Pak Suswanto! 👋" - dia tersenyum melihat namanya. Di header: "🌤️ Cerah, 26°C | 🕐 05:32 WIB". Cuaca bagus untuk kerja!

Dua card besar muncul:
- **📝 BUAT RENCANA KERJA** (card prominent dengan border tebal)
- **📋 LIHAT RENCANA KERJA** (card secondary)

**Resolution:**
Pak Suswanto langsung tahu hari ini bisa kerja maksimal. Dia siap tap "Buat Rencana Kerja" untuk assign tugas ke operator. (Fitur ini akan ready di fase 2, tapi UI sudah siap).

**Emotional Arc:** Anxious (cuaca?) → Relieved (info jelas) → Confident (siap kerja)

---

**Journey Requirements Revealed:**
- Login dengan username + password
- Greeting personalized dengan nama
- Weather + temperature widget
- Clock dengan WIB timezone
- 2 menu cards untuk role Kasie
- Visual hierarchy (primary vs secondary card)

---

### Journey 2: Pak Siswanto - Operator Cek Tugas Pagi

**Persona:** Pak Siswanto, 28 tahun, Operator traktor di Estate Sungai Lilin. Lulusan SMA, sangat familiar dengan smartphone. Tugasnya mengoperasikan traktor sesuai rencana kerja yang diberikan.

**Konteks:** Jam 6:00 pagi, Pak Siswanto sampai di pool traktor. Dia perlu tahu tugas hari ini sebelum mulai kerja.

---

**Opening Scene:**
Pak Siswanto parkir motor di pool traktor. Rekan-rekannya sudah mulai berdatangan. Sambil jalan ke pos, dia buka FSTrack-Tractor untuk cek ada tugas apa hari ini.

**Rising Action:**
Login screen muncul dengan logo app. Pak Siswanto ketik "siswanto.op" dan password-nya. Dia centang "Ingat Saya" supaya besok tidak perlu login lagi. Tap "Masuk".

**Climax - Aha Moment:**
Main page muncul cepat. "Selamat pagi, Pak Siswanto! 👋" - greeting yang ramah. Header menunjukkan "☀️ Cerah, 28°C | 🕐 06:02 WIB".

Satu card besar muncul di tengah layar:
- **📋 LIHAT RENCANA KERJA** (full-width card)

Berbeda dengan HP Pak Suswanto yang punya 2 card, Pak Siswanto hanya lihat 1 card karena dia Operator.

**Resolution:**
Pak Siswanto tap card tersebut untuk lihat tugas hari ini. (Fitur detail akan ready di fase 2). Dia sudah tahu cuaca cerah, jadi siap kerja penuh hari ini.

**Emotional Arc:** Curious (tugas apa?) → Informed (cuaca + waktu jelas) → Ready (siap kerja)

---

**Journey Requirements Revealed:**
- Remember Me checkbox untuk persistent login
- Role-based UI (1 card untuk non-Kasie)
- Full-width card layout untuk single menu
- Same header widgets (weather, clock, greeting)

---

### Journey 3: Pak Soswanti - Admin IT Verify Sistem

**Persona:** Pak Soswanti, 35 tahun, Admin IT yang handle internal testing. Tugasnya memastikan semua user bisa login dan melihat menu yang benar sesuai role mereka.

**Konteks:** Pre-launch testing. Pak Soswanti perlu verify bahwa 30 test users bisa login dengan benar.

---

**Opening Scene:**
Pak Soswanti di kantor IT dengan spreadsheet CSV di layar laptop-nya. Dia buka emulator Android untuk test login berbagai role.

**Rising Action:**
Test 1: Login sebagai "soswanti.admin" (role: admin). Main page muncul dengan 1 card "Lihat Rencana Kerja". ✅ Correct.

Test 2: Login sebagai "suswanto.pg" (role: kasie_pg). Main page muncul dengan 2 cards. ✅ Correct.

Test 3: Login sebagai "siswanto.op" (role: operator). Main page muncul dengan 1 card. ✅ Correct.

Test 4: Login dengan password salah. Error message "Password salah" muncul. ✅ Correct.

Test 5: Cek weather widget. Data cuaca muncul dengan lokasi estate. ✅ Correct.

**Climax:**
Semua 30 test users berhasil login. Role mapping 100% benar. Performance < 3 detik untuk semua login.

**Resolution:**
Pak Soswanti update status testing: "MVP Ready for Internal Release". Checklist complete.

**Emotional Arc:** Methodical (testing step by step) → Confident (all tests pass) → Satisfied (ready to ship)

---

**Journey Requirements Revealed:**
- CSV import harus benar (role mapping accurate)
- Error messages jelas dan informatif
- Consistent behavior across all roles
- Performance < 3 detik untuk semua users
- Weather widget works untuk semua lokasi

---

### Role Variations

| Primary Journey | Similar Roles | Behavior |
|-----------------|---------------|----------|
| Kasie PG (Pak Suswanto) | Kasie FE | 2 menu cards (Buat + Lihat) |
| Operator (Pak Siswanto) | Mandor, Estate PG | 1 menu card (Lihat only) |
| Admin (Pak Soswanti) | - | 1 menu card (Lihat) + testing access |

### Journey Requirements Summary

| Requirement | Source Journey | Priority |
|-------------|----------------|----------|
| Login dengan username + password | All | P0 |
| Remember Me checkbox | Operator | P1 |
| Personalized greeting dengan nama | All | P0 |
| Weather + temperature widget | Kasie PG, Operator | P1 |
| Clock widget (WIB) | All | P1 |
| Role-based menu display | All | P0 |
| 2 cards untuk Kasie roles | Kasie PG | P0 |
| 1 full-width card untuk non-Kasie | Operator, Admin | P0 |
| Error message yang jelas | Admin testing | P0 |
| Performance < 3 detik | Admin testing | P0 |

## Mobile App + Backend Specific Requirements

### Platform Requirements

| Aspect | Specification | Notes |
|--------|---------------|-------|
| **Primary Platform** | Android | Device pekerja lapangan |
| **Framework** | Flutter | Cross-platform ready untuk iOS future |
| **Min Android SDK** | API 26 (Android 8.0) | Coverage 95%+ devices |
| **Distribution** | APK direct install | Bypass Play Store untuk internal |
| **Target Devices** | Mid-range Android | Budget devices field workers |

### Offline Mode & Cache Strategy

| Data Type | Cache Duration | Fallback Behavior |
|-----------|----------------|-------------------|
| **JWT Token** | 7 hari | Auto-logout setelah expired |
| **User Profile** | Sampai logout | Nama + role untuk greeting & UI |
| **Weather Data** | 1 jam | Tampilkan last known + timestamp |
| **Estate Info** | Sampai logout | Embedded di user profile |

**First Launch tanpa Internet:**
- JWT: Redirect ke login (tidak bisa bypass)
- Weather: Tampilkan placeholder "Cuaca tidak tersedia" dengan icon generic
- User dapat login jika sudah pernah login sebelumnya (JWT cached)

**Subsequent Launch Offline:**
- JWT: Gunakan cached token jika belum expired
- Weather: Tampilkan "Terakhir update: [timestamp]" dengan data cached
- UI: Full functionality kecuali real-time data

### Multi-Estate Architecture

**Current State:** 4 PG/Estate dalam perusahaan

**MVP Approach: Single-Tenant per User**
- Setiap user di-assign ke 1 estate di CSV import
- Estate info embedded dalam user profile
- Tidak ada estate selector di UI
- Backend ready untuk multi-estate di future phase

**CSV Structure (dengan estate):**
```
username,password,name,role,estate_id
suswanto.pg,***,Pak Suswanto,kasie_pg,estate_sungai_lilin
siswanto.op,***,Pak Siswanto,operator,estate_sungai_lilin
```

**Future Consideration:**
- Phase 2+: User dengan akses multi-estate
- Estate selector dropdown di header
- Cross-estate reporting untuk management

### Integration Architecture

| Integration | MVP Implementation | Future Upgrade |
|-------------|-------------------|----------------|
| **Weather API** | Free tier (TBD via Context7 research) | Company AWS/satellite API |
| **Backend API** | REST (NestJS) | GraphQL optional |
| **Auth** | JWT + bcrypt | Biometric + 2FA |
| **Push Notifications** | Not in MVP | FCM for Android |

**Weather API Adapter Pattern:**
```
WeatherService (interface)
├── FreeWeatherAdapter (MVP)
└── CompanyWeatherAdapter (Future)
```

### Device Considerations

| Consideration | Approach |
|---------------|----------|
| **Screen Sizes** | Responsive layout, min 5" display |
| **Memory** | Lightweight, target < 50MB RAM usage |
| **Battery** | Efficient polling, no background GPS for MVP |
| **Storage** | Minimal local storage (< 10MB cache) |
| **Network** | Handle 2G/3G gracefully, retry mechanism |

### Failure Mode Mitigations

| Category | Critical Failures | Mitigation Strategy |
|----------|-------------------|---------------------|
| **Cache** | Token corruption, stale data | Validate on read, force refresh on reconnect |
| **Offline** | First launch blocked, token expiry | Clear messaging, day-6 warning notification |
| **Multi-Estate** | Wrong assignment, estate typo | Pre-import validation, estate existence check |
| **Integration** | API rate limit, downtime | Aggressive caching, graceful fallback, health checks |
| **Device** | Low storage, old Android | Pre-flight checks, clear requirements |

### Error Messages (Bahasa Indonesia)

| Scenario | Message |
|----------|---------|
| First launch offline | "Koneksi internet diperlukan untuk login pertama kali" |
| JWT expired | "Sesi Anda sudah berakhir. Silakan login kembali." |
| Token expiring soon | "Sesi akan berakhir dalam 1 hari. Hubungkan ke internet untuk memperpanjang." |
| Weather unavailable | "Cuaca tidak tersedia" |
| Weather cached | "Cuaca (terakhir update: 06:30 WIB)" |
| Backend unreachable | "Tidak dapat terhubung ke server. Periksa koneksi internet Anda." |
| Login timeout | "Koneksi lambat. Coba lagi?" |
| Invalid credentials | "Username atau password salah" |
| User not found | "User tidak ditemukan" |

## Scoping Summary

### MVP Strategy Confirmation

**MVP Philosophy:** Problem-Solving MVP
- Fokus pada core problem: Login + akses role-based ke main page
- Minimal features untuk validasi adoption oleh field workers
- Foundation untuk fitur tracking dan approval di fase berikutnya

**Resource Requirements:**
- 1 Flutter developer (frontend)
- 1 NestJS developer (backend)
- 1 QA/Tester (internal testing)
- CSV data sudah disiapkan oleh company

### Scope Boundaries 

| Boundary | Decision | Rationale |
|----------|----------|-----------|
| **Platform** | Android only | Field workers use Android devices |
| **Distribution** | APK direct | Faster iteration, no Play Store review |
| **Users** | 30 internal testers → ratusan | Phased rollout |
| **Estates** | Single-tenant per user | Simplicity for MVP |
| **Features** | Login + Main Page | Minimum viable foundation |
| **Weather API** | Free tier TBD | Research after PRD |

**Backend Note:** Schema includes `estate_id` column for future multi-estate support.

### Pre-Implementation Prerequisites

- [ ] CSV format validated against expected schema
- [ ] Sample data tested with import script (dry run)
- [ ] 30 test usernames confirmed and ready
- [ ] Test account created for development (before CSV import)

### Risk-Adjusted Scope

**De-risked by limiting scope:**
- No GPS tracking complexity for MVP
- No real-time sync requirements
- No multi-estate switching
- No push notifications
- No biometric auth

**Acceptable risks retained:**
- Weather API dependency (mitigated with fallback)
- Offline mode complexity (mitigated with clear messaging)
- CSV import quality (mitigated with validation)

### Definition of Done (MVP)

MVP complete when:
- [ ] 30 internal users can login successfully
- [ ] All 6 roles display correct UI
- [ ] Weather widget works or shows graceful fallback
- [ ] Performance < 3 seconds
- [ ] Zero critical bugs in login flow
- [ ] Error messages clear in Bahasa Indonesia
- [ ] First-time user dapat login tanpa bantuan (self-explanatory UI)
- [ ] First-time onboarding flow implemented (`isFirstTime` flag in DB)

### First-Time User Experience Pattern

**Database Schema Addition:**
```sql
users.is_first_time BOOLEAN DEFAULT TRUE
```

**Behavior:**
1. New user logs in → `is_first_time = TRUE` → Show onboarding
2. User completes onboarding → Set `is_first_time = FALSE`
3. Subsequent logins → Skip onboarding

**Future Pattern:** This `isFirstTime` check becomes **mandatory DoD for ALL new features** going forward.

### Epic Sequencing Note

**CSV Import → Last Epic**
- Development uses dedicated test account
- Allows app demo while CSV collection in progress
- Reduces blocking dependencies on company data

## Functional Requirements

*This is the CAPABILITY CONTRACT - setiap fitur yang tidak terdaftar di sini TIDAK akan dibangun.*

### Authentication (FR1-FR6, FR31-FR33)

| FR# | Requirement |
|-----|-------------|
| FR1 | User dapat login dengan username dan password |
| FR2 | User dapat toggle visibility password (show/hide) |
| FR3 | User dapat mengaktifkan "Ingat Saya" untuk persistent login |
| FR4 | System memvalidasi credentials terhadap database |
| FR5 | System mengeluarkan JWT token setelah login berhasil |
| FR6 | System menampilkan error message yang jelas untuk credentials tidak valid |
| FR31 | User dapat logout dari aplikasi |
| FR32 | System menghapus cached JWT saat logout |
| FR33 | Single session only - login baru di device lain invalidate session lama |

### Main Page Display (FR7-FR11)

| FR# | Requirement |
|-----|-------------|
| FR7 | User dapat melihat personalized greeting dengan nama mereka |
| FR8 | User dapat melihat informasi cuaca dan suhu saat ini |
| FR9 | User dapat melihat waktu saat ini dalam timezone WIB |
| FR10 | Role Kasie dapat melihat menu card "Buat Rencana Kerja" |
| FR11 | Semua role dapat melihat menu card "Lihat Rencana Kerja" |

### Role-Based Access (FR12-FR14)

| FR# | Requirement |
|-----|-------------|
| FR12 | System menampilkan layout UI berdasarkan role user |
| FR13 | Role Kasie melihat hybrid card layout (2 cards) |
| FR14 | Role non-Kasie melihat single full-width card |

### First-Time User Experience (FR15-FR17, FR28-FR29)

| FR# | Requirement |
|-----|-------------|
| FR15 | System mendeteksi first-time user via `is_first_time` flag |
| FR16 | First-time user melihat onboarding/tutorial saat login pertama |
| FR17 | System mengupdate `is_first_time = FALSE` setelah onboarding selesai |
| FR28 | Onboarding menampilkan maksimal 3 slide (Welcome, Menu, Cuaca) |
| FR29 | User dapat skip onboarding kapan saja |

### Data Management Backend (FR18-FR21, FR27)

| FR# | Requirement |
|-----|-------------|
| FR18 | Admin dapat import users dari CSV ke PostgreSQL |
| FR19 | System memvalidasi format CSV sebelum import |
| FR20 | System meng-hash password dengan bcrypt saat import |
| FR21 | System menyimpan estate_id untuk setiap user |
| FR27 | System membaca role dari JWT token payload |

### Resilience & Offline (FR22-FR25, FR30, FR34-FR35)

| FR# | Requirement |
|-----|-------------|
| FR22 | System meng-cache JWT untuk offline access (7 hari) |
| FR23 | System meng-cache data cuaca terakhir (1 jam) |
| FR24 | System menampilkan graceful fallback saat weather API gagal |
| FR25 | System menampilkan warning saat JWT akan expired (hari ke-6) |
| FR30 | System menampilkan offline indicator di header |
| FR34 | System otomatis retry request yang gagal (max 3x) |
| FR35 | System menampilkan error message yang actionable |

### Menu Card Behavior (FR26)

| FR# | Requirement |
|-----|-------------|
| FR26 | System menampilkan placeholder/coming soon saat user tap menu card (MVP) |

### Loading States (FR36-FR37)

| FR# | Requirement |
|-----|-------------|
| FR36 | System menampilkan loading indicator saat proses login |
| FR37 | System menampilkan skeleton loading saat load main page |

### FR Summary

| Category | Count | FRs |
|----------|-------|-----|
| Authentication | 9 | FR1-FR6, FR31-FR33 |
| Main Page Display | 5 | FR7-FR11 |
| Role-Based Access | 3 | FR12-FR14 |
| First-Time User Experience | 5 | FR15-FR17, FR28-FR29 |
| Data Management Backend | 5 | FR18-FR21, FR27 |
| Resilience & Offline | 7 | FR22-FR25, FR30, FR34-FR35 |
| Menu Card Behavior | 1 | FR26 |
| Loading States | 2 | FR36-FR37 |
| **Total** | **37** | |

## Non-Functional Requirements

*NFRs define HOW WELL the system must perform. Only relevant categories for FSTrack-Tractor MVP are documented.*

### Performance

| NFR# | Requirement | Target | Validation |
|------|-------------|--------|------------|
| NFR1 | Login → Main Page load time | < 3 detik (4G/WiFi) | Load testing |
| NFR2 | Weather widget response time | < 2 detik (async, non-blocking) | API monitoring |
| NFR3 | UI responsiveness (tap feedback) | < 100ms | Manual testing |
| NFR4 | App startup time (cold start) | < 5 detik | Device testing |
| NFR5 | Memory usage | < 50MB RAM | Profiling |
| NFR6 | App functional di 4G low-signal | 1 bar minimum | Field testing PG4 |
| NFR7 | Weather API non-blocking | Main content loads first | Code review |
| NFR8 | Login flow di 4G low-signal | < 3 detik | Field testing |

### Security

| NFR# | Requirement | Implementation | Validation |
|------|-------------|----------------|------------|
| NFR9 | Password storage | Bcrypt hash (cost factor 10+) | Code review |
| NFR10 | Data transmission | HTTPS/TLS 1.2+ mandatory | SSL check |
| NFR11 | JWT token expiration | 14 hari (internal app trust) | Token testing |
| NFR12 | Input sanitization | Parameterized queries, no raw SQL | Security audit |
| NFR13 | Session management | Single session per user (FR33) | Login testing |
| NFR14 | Credential storage (mobile) | Flutter secure_storage | Security review |
| NFR15 | Rate limiting login | Max 5 attempts per 15 menit per username | Penetration test |
| NFR16 | Account lockout | 30 menit setelah 10 failed attempts | Security test |
| NFR17 | Password minimum | 8 karakter, 1 angka (CSV import) | Validation script |

### Reliability & Availability

| NFR# | Requirement | Target | Fallback |
|------|-------------|--------|----------|
| NFR18 | Offline login capability | JWT cache 14 hari | Redirect to login after expire |
| NFR19 | Weather data cache | 30 menit (refresh saat app aktif) | "Cuaca tidak tersedia" |
| NFR20 | API retry mechanism | Max 3x dengan exponential backoff | Error message |
| NFR21 | Backend uptime | 99% (MVP acceptable) | Graceful error messages |
| NFR22 | Graceful degradation | All external dependencies | Fallback UI |
| NFR23 | Health check endpoint | Public /api/health (no auth) | Monitoring + debugging |
| NFR24 | Recovery Time Objective | < 30 menit | Incident response |
| NFR25 | JWT grace period | 24 jam offline-only setelah expiry | Cached data access |
| NFR26 | Session expiry warning | In-app banner < 2 hari tersisa | User awareness |

### Data Freshness

| NFR# | Requirement | Implementation |
|------|-------------|----------------|
| NFR27 | Weather timestamp visible | "Diperbarui: XX:XX WIB" |
| NFR28 | Weather auto-refresh | Setiap 30 menit saat app aktif |
| NFR29 | Weather disclaimer | "Prakiraan cuaca, dapat berubah" |

### Scalability

| NFR# | Requirement | MVP Target | Future Target |
|------|-------------|------------|---------------|
| NFR30 | Concurrent users | 30 users | Ratusan users |
| NFR31 | Database capacity | 500 users | 5000+ users |
| NFR32 | API rate limiting | Per-username throttling | Enhanced throttling |

### Integration

| NFR# | Requirement | Approach | Validation |
|------|-------------|----------|------------|
| NFR33 | Weather API | Adapter pattern (swappable) | Interface test |
| NFR34 | Weather API timeout | 5 detik max | Timeout testing |
| NFR35 | Backend API versioning | v1 prefix | Contract testing |

### Maintainability

| NFR# | Requirement | Standard |
|------|-------------|----------|
| NFR36 | Code documentation | Inline comments untuk complex logic |
| NFR37 | Error logging | Structured logs dengan context |
| NFR38 | Configuration | Environment-based (dev/staging/prod) |

### NFR Summary

| Kategori | Count | Key Highlights |
|----------|-------|----------------|
| Performance | 8 | 4G low-signal baseline, weather async |
| Security | 9 | 14 hari JWT, rate limit per username |
| Reliability | 9 | Public health check, grace period |
| Data Freshness | 3 | Timestamp + disclaimer |
| Scalability | 3 | 30 → ratusan users |
| Integration | 3 | Adapter pattern |
| Maintainability | 3 | Structured logging |
| **Total** | **38** | |


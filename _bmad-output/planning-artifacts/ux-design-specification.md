---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9, 11]
inputDocuments:
  - project-context.md
  - prd.md
  - docs/planning-phase/ux-design-specification.md
  - docs/planning-phase/ux-final-direction.html
workflowType: 'ux-design'
project_name: 'fstrack-tractor'
user_name: 'V'
date: '2026-01-29'
---

# UX Design Specification fstrack-tractor - Fase 2

**Author:** V
**Date:** 2026-01-29
**Scope:** Fase 2 - Work Plan Management (Extended dari Fase 1)

---

## Referensi Foundation Fase 1

Dokumen ini merupakan **extended UX** dari Fase 1. Semua patterns dan design system dari Fase 1 tetap berlaku:

| Aspect | Fase 1 Foundation | Status Fase 2 |
|--------|-------------------|---------------|
| Color Tokens | `#008945`, `#FBA919`, `#25AAE1` | ✅ Same |
| Typography | Poppins (bundled) | ✅ Same |
| Card Pattern | Tappable cards, no buttons | ✅ Same |
| Bottom Sheet | Primary interaction pattern | ✅ Extended |
| FAB | Kasie only | ✅ Same |
| Skeleton Loading | V's signature | ✅ Same |
| Offline Banner | Tappable | ✅ Same |

### Dokumen Fase 1 yang Berlaku

1. **Visual Design** - `docs/planning-phase/ux-final-direction.html`
2. **Component Patterns** - `docs/planning-phase/ux-design-specification.md`
3. **Design System** - Material Design 3 + Bulldozer alignment

---

## Fase 2 Extended Scope

Fase 2 fokus pada **Work Plan Management** dengan 3 operasi utama:

| Operation | Role | UI Pattern |
|-----------|------|------------|
| **CREATE** | Kasie PG | FAB → Bottom Sheet Form |
| **ASSIGN** | Kasie FE | List → Tap Card → Bottom Sheet + Operator Select |
| **VIEW** | All Roles | List dengan role-based filtering |

### Extended Components (Fase 2)

| New Component | Purpose | Based On |
|---------------|---------|----------|
| WorkPlanCard | Extended dari TaskCard dengan status ASSIGNED | TaskCard pattern |
| AssignBottomSheet | Form untuk assign operator | CreateBottomSheet pattern |
| StatusBadge | OPEN → ASSIGNED → IN_PROGRESS | Existing status badges |

---

<!-- UX design content akan ditambahkan secara sequential melalui collaborative workflow steps -->

---

## Executive Summary

### Project Vision

**FSTrack-Tractor Fase 2** adalah kelanjutan dari Fase 1 (Login + Main Page) yang berfokus pada **implementasi penuh fitur Work Plan Management**. Fase 2 akan menyelesaikan alur lengkap **CREATE → ASSIGN → VIEW** work plan sesuai workflow operasional perkebunan.

**Core Workflow:**
1. **CREATE** - Kasie PG membuat rencana kerja baru
2. **ASSIGN** - Kasie FE menugaskan operator ke work plan
3. **VIEW** - Semua role dapat melihat work plan sesuai permission

### Target Users

| Role | Persona | Fungsi Fase 2 | Teknical Context |
|------|---------|---------------|------------------|
| **Kasie PG** | Pak Suswanto, 45th, Plantation Manager | CREATE work plan | Familiar dengan teknologi dasar, menggunakan di pagi hari sebelum kerja |
| **Kasie FE** | Pak Siswanto, 38th, Field Executive | ASSIGN work plan ke operator | Decision maker, perlu context switching antar work plan |
| **Operator** | Pak Budi, 28th, Tractor Operator | VIEW assigned work plans | Field worker, perlu clarity instant tentang tugas |
| **Mandor** | Supervisor | VIEW only | Monitoring role, lihat progress tim |
| **Estate PG** | Estate Manager | VIEW only | Overview level, strategic decisions |
| **Admin** | IT Admin (Pak Soswanti) | Testing & verification | All-access untuk validasi workflow |

**User Context:**
- Field workers di area perkebunan dengan sinyal 4G lemah
- Perangkat mid-range Android
- Mix tech-savviness (45th Kasie vs 28th Operator)
- Penggunaan pagi hari sebelum kerja lapangan

### Key Design Challenges

| Challenge | Description | Impact |
|-----------|-------------|--------|
| **1. Role-Based Permission Clarity** | 6 roles dengan permission berbeda, user harus langsung paham apa yang bisa mereka lakukan | Tinggi - confusion = workflow failure |
| **2. Status Transition Visibility** | OPEN → ASSIGNED transition harus jelas terlihat oleh semua pihak untuk koordinasi | Tinggi - koordinasi antar-role |
| **3. Context Switching (Kasie FE)** | Kasie FE perlu lihat list → pilih work plan → assign operator, 3-step flow yang harus efisien | Medium - efficiency critical |
| **4. Field Environment Constraints** | Area perkebunan dengan sinyal 4G lemah, app harus tetap usable dengan feedback yang jelas | Tinggi - reliability |

### Design Opportunities

| Opportunity | Description | Value |
|-------------|-------------|-------|
| **1. Visual Status Indicators** | Color-coded status badges (Orange=OPEN, Blue=ASSIGNED, Green=COMPLETED) dengan border-left indicators | Instant recognition untuk semua role |
| **2. Smart Filtering** | Auto-filter list berdasarkan role (Operator hanya lihat assigned-to-me, Kasie FE lihat OPEN untuk assign) | Reduce cognitive load |
| **3. Bottom Sheet Pattern** | Consistent CREATE/ASSIGN/VIEW dalam bottom sheet, tidak full page navigation | Maintain context, predictable interactions |
| **4. Success Feedback** | Toast messages dalam Bahasa Indonesia saat CREATE/ASSIGN berhasil | Clear confirmation, build confidence |
| **5. Skeleton Loading** | V's signature - shimmer placeholders saat loading, bukan spinner | Perceived performance improvement |
| **6. Explicit Offline UX** | Tappable offline banner dengan retry mechanism | User control, clear status |

### Key Decisions from Party Mode Discussion

**Flow CREATE (Kasie PG):**
```
Tap FAB (+) → Bottom Sheet muncul → Isi 4 field (tanggal, pola, shift, lokasi) → Simpan → Toast "Rencana kerja berhasil dibuat!"
```
- FAB hanya visible untuk Kasie PG role
- Form minimalis, auto-fill tanggal hari ini
- Validation inline, semua field required

**Flow ASSIGN (Kasie FE):**
```
Lihat list work plan → Tap card OPEN → Bottom Sheet detail → Dropdown pilih Operator → Simpan → Status berubah ke ASSIGNED
```
- Operator list di-cache (5 menit) untuk performance
- Visual feedback immediate: status badge berubah warna
- Online-only untuk Fase 2 (simplify MVP)

**Technical Considerations:**
- Optimistic UI dengan cache untuk operator availability
- Thumbnail avatar 64x64px atau initials avatar (fallback)
- Online-only constraint untuk Fase 2 (documented as known limitation)

## Core User Experience

### Defining Experience

**Primary Actions by Role:**

| Role | Core Action | Flow |
|------|-------------|------|
| **Kasie PG** | CREATE work plan | Tap FAB (+) → Bottom Sheet → Isi 4 field → Submit |
| **Kasie FE** | ASSIGN operator | View list → Tap OPEN card → Select operator → Submit |
| **Operator** | VIEW assigned tasks | View filtered list → Tap for detail |

**Critical Insight:** Tiga role, tiga core actions yang berbeda—tapi semua harus merasa "ini untuk saya" dalam 3 detik pertama.

**Core Loop:**
```
User buka app → Login (auto kalau returning) → Lihat role-appropriate UI
→ Tap action card/bottom sheet → Submit → Feedback immediate
→ Kembali ke list dengan status updated
```

### Platform Strategy

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| **Platform** | Mobile Android (Flutter) | Field workers pakai Android |
| **Orientation** | Portrait only | Simplify MVP, phone grip natural |
| **Interaction** | Touch-based | Mid-range smartphones, gloves possible |
| **Offline** | Online-only Fase 2 | Simplify MVP, documented limitation |
| **Min Screen** | 360dp width | Standard Android phones |
| **Distribution** | APK direct install | Internal use, bypass Play Store |

### Effortless Interactions

**Magical Moments:**

| Interaction | Effortless How? |
|-------------|-----------------|
| **Auto-fill tanggal** | Hari ini pre-selected, editable kalau perlu |
| **Role-based visibility** | FAB hanya Kasie PG, tanpa setting |
| **Bottom sheet consistency** | Semua aksi (CREATE/ASSIGN/VIEW) pattern sama |
| **Skeleton loading** | Shimmer placeholder, bukan spinner |
| **One-tap feedback** | Toast immediate, tidak perlu cek status |
| **Visual status** | Color-coded, instant recognition |
| **Auto-login** | JWT cache 7 hari, 1 tap untuk returning users |

### Critical Success Moments

**Make-or-Break Points:**

| Moment | Success Criteria | Failure Mode |
|--------|------------------|--------------|
| **Login → Task visible** | < 3 detik | User bingung "saya harus ngapain?" |
| **CREATE success** | Toast + card muncul | User tidak tahu berhasil/tidak |
| **ASSIGN transition** | Status berubah OPEN→ASSIGNED | Koordinasi gagal, operator tidak tahu |
| **Role recognition** | UI correct tanpa confusion | Wrong permission = workflow failure |
| **Offline awareness** | Banner muncul < 1 detik | User bingung kenapa data tidak update |

### Experience Principles

**Guiding Framework:**

1. **Instant Task Clarity** - User langsung tahu tugas dalam < 3 detik
2. **Role Clarity** - UI langsung komunikasikan role via card layout dan visibility
3. **Friction-Free Return** - Auto-login untuk returning users
4. **Progressive Enhancement** - Core tetap jalan, weather = enhancement
5. **Contextual Feedback** - User tahu status aplikasi (online/offline, success/error)
6. **Predictable Patterns** - Bottom sheet untuk semua aksi, card tap untuk detail

## Desired Emotional Response

### Primary Emotional Goals

**Core Goal:** User merasa **"SIAP KERJA"** dalam 3 detik setelah login

| Target User | Desired Feeling | Why It Matters |
|-------------|-----------------|----------------|
| **Kasie PG** | Confident & Prepared | "Aku siap mulai hari ini" - bisa koordinasi tim dengan jelas |
| **Kasie FE** | Efficient & Systematic | "Aku bisa assign dengan cepat" - no wasted time |
| **Operator** | Clear & Ready | "Aku tahu tugasku" - tidak ada ambiguity |
| **First-time User** | Welcome & Capable | "App ini mudah" - low learning curve |

### Emotional Journey Mapping

| Stage | Desired Emotion | UX Support |
|-------|-----------------|------------|
| **App Open** | Anticipation | Fast splash, no delay |
| **Login** | Effortless | 1 tap untuk returning users |
| **Main Page** | Clarity | Immediate content, skeleton → real data |
| **Weather Widget** | Informed | Contextual info untuk planning |
| **CREATE/ASSIGN Action** | Confident | Clear form, validation inline |
| **Success** | Accomplished | Toast message, status update visible |
| **Error** | Calm | Friendly Bahasa Indonesia message, retry available |
| **Offline** | In-control | Tappable banner, cached data |

### Micro-Emotions

**Priority (Most Critical):**

1. **Confidence** - "Aku tahu cara pakai"
   - Supported by: Consistent patterns, clear labels, predictable flows

2. **Trust** - "Info ini reliable"
   - Supported by: Timestamps, status indicators, success feedback

3. **Efficiency** - "Tidak buang waktu"
   - Supported by: Auto-fill, 1-tap actions, minimal steps

**Secondary:**

4. **Belonging** - "Ini untuk saya"
   - Supported by: Personalized greeting, role-appropriate UI

5. **Calm** - "Aman kalau ada masalah"
   - Supported by: Graceful error handling, offline awareness

**Emotions to AVOID:**
- Confusion (ambiguous UI, unclear status)
- Frustration (slow loading, no feedback)
- Anxiety (unclear if action succeeded)
- Isolation (no indication of app state)

### Design Implications

| Emotion | Design Approach |
|---------|-----------------|
| **Confidence** | Clear labels, consistent bottom sheet pattern, role-based visibility |
| **Trust** | Timestamps ("Diperbarui 06:30 WIB"), reliable status transitions |
| **Efficiency** | Auto-fill tanggal, 1-tap login, skeleton loading |
| **Belonging** | Personalized greeting "Selamat pagi, Pak Suswanto!" |
| **Calm** | Friendly error messages in Bahasa Indonesia, tappable offline banner |

### Emotional Design Principles

1. **Familiarity First** - UI mirip app yang sudah dikenal (Bulldozer), transisi smooth
2. **No Surprises** - Predictable, consistent patterns (bottom sheet untuk semua aksi)
3. **Respectful of Time** - < 3 detik, always show feedback
4. **Human Touch** - Greeting dengan nama user, Bahasa Indonesia messages
5. **Graceful Failure** - Friendly error handling, never crash or blank screen

## UX Pattern Analysis & Inspiration

### Inspiring Products Analysis

#### **A. Bulldozer App (Fas-Track Subsoil) - Primary Reference**

| Aspect | Pattern | Transferability |
|--------|---------|-----------------|
| **Login** | Saved accounts dengan autocomplete dropdown | ✅ ADOPT - returning users butuh 1-tap login |
| **Remember Me** | Persistent credentials dengan secure storage | ✅ ADOPT - field workers butuh quick access |
| **Visual** | Tractor background image creates context | ✅ ADAPT - FSTrack bisa pakai gambar perkebunan |
| **Password** | Show/hide toggle | ✅ ADOPT - essential untuk field environment |
| **State** | BLoC pattern - clean state management | ✅ ADOPT - technical foundation |
| **Version** | Version number di login screen | ❌ AVOID - pindahkan ke Settings, cleaner UI |

**Key Lesson:** Familiarity untuk users yang sudah terbiasa dengan Bulldozer adalah asset. Transisi harus smooth.

#### **B. WhatsApp - Secondary Reference**

| Aspect | Pattern | Transferability |
|--------|---------|-----------------|
| **Startup** | Instant content load - no loading walls | ✅ ADAPT - skeleton loading untuk perceived speed |
| **Status** | Timestamp trust ("Last seen", "Diperbarui") | ✅ ADOPT - "Cuaca diperbarui 05:30 WIB" |
| **Connectivity** | "Connecting..." feedback | ✅ ADAPT - explicit offline banner |
| **Profile** | Simple nama + status di header | ✅ ADAPT - greeting dengan nama user |
| **Action Color** | Green = action | ✅ ADAPT - primary green #008945 dari brand |

**Key Lesson:** Clear status communication builds trust. Users harus tahu app state mereka anytime.

### Transferable UX Patterns

**ADOPT (langsung pakai):**
- ✅ Saved accounts autocomplete (Bulldozer)
- ✅ Show/hide password toggle (Bulldozer)
- ✅ Timestamp on data freshness (WhatsApp)
- ✅ Offline connectivity banner (WhatsApp-inspired)
- ✅ Card tappable tanpa separate buttons (Modern pattern)

**ADAPT (modifikasi):**
- 🔄 Skeleton loading (WhatsApp instant → shimmer placeholder) - **V's Signature**
- 🔄 Green action color (WhatsApp green → Brand green #008945)
- 🔄 Chat list → Work plan card list
- 🔄 Bottom nav → Simplified (no nav, single page dengan bottom sheet)

**AVOID:**
- ❌ Complex onboarding flows (field workers skip anyway)
- ❌ Full-screen blocking loaders (frustrating di slow connection)
- ❌ Hidden offline state (user bingung kenapa data lama)
- ❌ English-only error messages (target users prefer Bahasa)
- ❌ Frequent auto-logout (frustrating re-login untuk field workers)
- ❌ Hidden gestures (field workers pakai gloves, unreliable)

### Anti-Patterns to Avoid

| Anti-Pattern | Why Avoid | Instead Do |
|--------------|-----------|------------|
| **Full-screen loading** | Frustrating di slow connection | Skeleton loading, progressive reveal |
| **Complex onboarding** | Field workers skip anyway | Contextual tooltips on first interaction |
| **Hidden offline state** | User bingung kenapa data lama | Clear "Offline" indicator, tappable untuk sync |
| **English error messages** | Target users prefer Bahasa | All messages in Bahasa Indonesia |
| **Small touch targets** | Hard to tap with work gloves | Min 48dp touch targets, preferably 60dp |
| **Auto-logout frequent** | Frustrating re-login | 7 hari JWT cache + 24 jam grace period |
| **Hidden gestures** | Unreliable dengan gloves | Explicit buttons, large tap targets |
| **Generic error messages** | User tidak tahu harus apa | Actionable error: "Koneksi bermasalah. Tap untuk coba lagi." |

### Design Inspiration Strategy

**Validated dari Party Mode Discussion:**

| Decision | Rationale | Source |
|----------|-----------|--------|
| **Skeleton Loading** | V's signature - perceived speed improvement | UX best practice + Sally's advocacy |
| **JWT 7 hari + grace 24 jam** | Security/convenience balance | Winston's technical input |
| **Actionable Error Messages** | "Calm" emotion target | John's user-centric approach |
| **No Hidden Gestures** | Field worker constraint (gloves) | Sally's accessibility concern |
| **Bottom Sheet Pattern** | Keep context, predictable - dengan proper BLoC disposal | Winston's architecture guidance |

## Design System Foundation

### Design System Choice

**Selected: Material Design 3 dengan Custom Theme + Bulldozer Alignment**

### Rationale for Selection

| Factor | Decision | Rationale |
|--------|----------|-----------|
| **Bulldozer Alignment** | Material widgets consistency | Reference app sudah pakai Material, transisi smooth untuk users |
| **Flutter Native** | Zero additional dependencies | Fastest path to implementation, no learning curve |
| **MVP Timeline** | Proven components ready-to-use | Tidak perlu build dari nol, focus pada business logic |
| **User Familiarity** | Android Material patterns | Field workers familiar dengan pola Android standar |
| **Accessibility** | Built-in outdoor visibility | Touch targets, contrast ratios, screen reader support |

### Implementation Approach

**Foundation: Material Design 3 Components (Standard, No Modifikasi)**

| Component | Material Widget | Usage |
|-----------|-----------------|-------|
| Buttons | `ElevatedButton`, `TextButton`, `OutlinedButton` | Actions dalam bottom sheet |
| Text fields | `TextFormField` dengan `InputDecoration` | CREATE/ASSIGN forms |
| Cards | `Card` dengan elevation | Work plan list items |
| Bottom sheets | `showModalBottomSheet` | Detail view, CREATE form, ASSIGN form |
| App bar | `SliverAppBar` | Header dengan scroll behavior |
| Lists | `ListView`, `ListTile` | Work plan list |
| Dialogs | `AlertDialog`, `SimpleDialog` | Confirmation dialogs |
| Progress | `CircularProgressIndicator`, `LinearProgressIndicator` | Loading states |
| Snackbars | `SnackBar` | Toast messages |

**Reference:** [Material Design 3 Components](https://m3.material.io/components)

### Customization Strategy

| Layer | Source | Approach | Status |
|-------|--------|----------|--------|
| **Colors** | Bulldozer AppColors | Exact match tokens (#008945, #FBA919, #25AAE1) | ✅ Match |
| **Typography** | Poppins | BUNDLED fonts (assets/fonts/), NOT GoogleFonts | ✅ Bundled |
| **Spacing** | 8dp grid | `AppSpacing` constants (xs=8, sm=12, md=16, lg=24) | ✅ Standardized |
| **Components** | Material Design 3 | Use tanpa modifikasi signifikan | ✅ Native |
| **New Components** | FSTrack-specific | WeatherWidget, OfflineBanner, TaskCard, WorkPlanCard | 🆕 Custom |

### Design Tokens (from Bulldozer Reverse Engineering)

**Color Tokens:**
```dart
class AppColors {
  static const Color primary = Color(0xFF008945);        // Brand green
  static const Color secondary = Color(0xFF03DAC6);      // Teal accents
  static const Color background = Color(0xFFF5F5F5);     // Page backgrounds
  static const Color surface = Color(0xFFFFFFFF);        // Card backgrounds
  static const Color textPrimary = Color(0xFF333333);    // Primary text
  static const Color textSecondary = Color(0xFF828282);  // Captions
  static const Color error = Color(0xFFB00020);          // Error states
  static const Color buttonOrange = Color(0xFFFBA919);   // Primary actions
  static const Color buttonBlue = Color(0xFF25AAE1);     // Secondary actions
  static const Color greyCard = Color(0xFFF0F0F0);       // Card backgrounds
}
```

**Typography Tokens (Poppins - BUNDLED):**
```dart
class AppTextStyle {
  static const _fontFamily = 'Poppins';

  static TextStyle get w400s10 => TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w400, fontSize: 10);
  static TextStyle get w400s12 => TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w400, fontSize: 12);
  static TextStyle get w500s12 => TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w500, fontSize: 12);
  static TextStyle get w600s12 => TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600, fontSize: 12);
  static TextStyle get w700s20 => TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700, fontSize: 20);
}
```

**Spacing Tokens:**
```dart
class AppSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double buttonHeight = 60;
  static const double inputRadius = 8;
  static const double cardRadius = 12;
}
```

## Defining Core Experience

### The Defining Interaction

**One-liner:** "Login → Langsung tahu tugasku"

**User akan mengatakan:** "Buka app, langsung lihat apa yang harus dikerjakan hari ini"

**Why this matters:** Field workers di perkebunan butuh clarity, bukan complexity. Mereka buka app pagi-pagi, mau langsung tahu: cuaca bagus? Ada tugas apa? Siapa yang harus saya hubungi?

**Defining Interaction by Role:**

| Role | Defining Experience |
|------|---------------------|
| **Kasie PG** | "Buat rencana kerja dalam 4 tap" |
| **Kasie FE** | "Assign operator dalam 3 tap" |
| **Operator** | "Lihat tugas saya dalam 2 tap" |

### User Mental Model

**Current Solution (Before App):**
- Paper-based schedules
- Verbal instructions via WhatsApp
- No weather integration
- Manual tracking

**Pain Points:**
- Lost papers → "Rencana kerja kemana ya?"
- Forgotten instructions → "Shift pagi atau siang tadi?"
- No weather check → "Hujan gak ya hari ini?"
- Unclear assignments → "Saya tugas di lokasi mana?"

**User Mental Model:**

| User Type | Mental Model | Expectation |
|-----------|--------------|-------------|
| **Kasie PG** | "Saya yang buat rencana" | Prominent "Buat Rencana" button |
| **Kasie FE** | "Saya yang assign" | List rencana + assign action yang jelas |
| **Operator** | "Saya yang eksekusi" | Clear task assigned to me |
| **Mandor** | "Saya yang monitor" | Overview of team progress |

### Success Criteria

**"This just works" moments:**

| Criteria | Measurement | Target |
|----------|-------------|--------|
| **Time to clarity** | Stopwatch dari login ke task visible | < 3 detik |
| **Taps to CREATE** | Jumlah tap dari main page ke success | 4 taps |
| **Taps to ASSIGN** | Jumlah tap dari main page ke success | 3 taps |
| **Role recognition** | Correct cards displayed | 100% accuracy |
| **Status transition** | OPEN → ASSIGNED visible | Immediate feedback |

**Success Indicators:**
- ✅ User sees greeting dengan nama dalam < 2 detik
- ✅ User knows "what to do next" tanpa confusion
- ✅ Success toast muncul immediate setelah action
- ✅ Status badge berubah warna secara real-time

### Novel UX Patterns

**Pattern Classification:**

| Pattern | Type | Source | Rationale |
|---------|------|--------|-----------|
| **Saved accounts login** | Established | Bulldozer, banking apps | Familiar, no learning curve |
| **Card-based actions** | Established | Material Design | Industry standard |
| **Weather widget** | Established | Phone home screens | Common pattern |
| **Skeleton loading** | Modern Adaptation | Content apps | V's signature - perceived speed |
| **Tappable offline banner** | Novel Adaptation | WhatsApp-inspired | User control, explicit status |
| **Role-based UI** | Established | Enterprise apps | Permission-driven visibility |

**Innovation:** Kita combine familiar patterns dalam cara yang unique untuk field service context—bukan reinvent, tapi **curate** patterns yang tepat.

### Experience Mechanics

#### Kasie PG: CREATE Work Plan

**1. Initiation:**
- Trigger: User login sebagai Kasie PG
- Invitation: FAB (+) visible di kanan bawah

**2. Interaction:**
```
Tap FAB (+) → Bottom Sheet muncul
→ Isi 4 field (tanggal auto-filled, pola, shift, lokasi)
→ Tap "Simpan"
```

**3. Feedback:**
- Loading: Skeleton shimmer di background
- Success: Toast "Rencana kerja berhasil dibuat!"
- Visual: Card baru muncul di list dengan status OPEN (orange)

**4. Completion:**
- Bottom sheet dismiss
- User sees new card in list
- Ready untuk CREATE lagi atau ASSIGN

---

#### Kasie FE: ASSIGN Operator

**1. Initiation:**
- Trigger: User login sebagai Kasie FE
- Invitation: List work plan dengan status OPEN visible

**2. Interaction:**
```
Tap card OPEN → Bottom Sheet detail
→ Dropdown: Pilih Operator
→ Tap "Tugaskan Operator"
```

**3. Feedback:**
- Loading: Button spinner
- Success: Toast "Operator berhasil ditugaskan!"
- Visual: Status badge berubah OPEN (orange) → ASSIGNED (blue)

**4. Completion:**
- Bottom sheet dismiss
- Card tetap visible tapi status updated
- Operator now sees work plan di app mereka

---

#### Operator: VIEW Assigned Tasks

**1. Initiation:**
- Trigger: User login sebagai Operator
- Invitation: "Lihat Rencana Kerja" card (satu-satunya action)

**2. Interaction:**
```
Tap card → List filtered (hanya assigned-to-me)
→ Tap work plan → Bottom Sheet detail
```

**3. Feedback:**
- Loading: Skeleton shimmer
- Success: Detail view dengan semua info
- Read-only: No action buttons (view only)

**4. Completion:**
- User knows exactly: lokasi, shift, unit, status
- Ready untuk mulai kerja di lapangan

## Visual Design Foundation

### Color System

**Semantic Color Mapping (Inherited from Fase 1):**

| Semantic | Token | Hex | Usage |
|----------|-------|-----|-------|
| Primary | `primary` | `#008945` | Brand, success states, FAB |
| Primary Action | `buttonOrange` | `#FBA919` | CTAs, primary buttons |
| Secondary Action | `buttonBlue` | `#25AAE1` | Secondary buttons |
| Success | `primary` | `#008945` | Success feedback |
| Warning | `buttonOrange` | `#FBA919` | Warning states |
| Error | `error` | `#B00020` | Error states |
| Surface | `background` | `#F5F5F5` | Page backgrounds |
| Card | `greyCard` | `#F0F0F0` | Card backgrounds |
| On Surface | `textPrimary` | `#333333` | Text on light bg |
| Status: OPEN | `buttonOrange` | `#FBA919` | Border-left indicator |
| Status: ASSIGNED | `buttonBlue` | `#25AAE1` | Border-left indicator |
| Status: COMPLETED | `primary` | `#008945` | Border-left indicator |

**Fase 2 Extension:** Status colors untuk OPEN/ASSIGNED/COMPLETED menggunakan existing tokens.

### Typography System

**Font:** Poppins (BUNDLED in assets/fonts/)

| Level | Style | Usage |
|-------|-------|-------|
| H1 | `w700s20` | Screen titles |
| H2 | `w600s12` | Section headers |
| Body | `w500s12` | Primary content |
| Body Small | `w400s12` | Secondary content |
| Caption | `w400s10` | Timestamps, hints |

**Fase 2 Extension:** Same type scale, no new styles needed.

### Spacing & Layout Foundation

**Base Unit:** 8dp (Material Design standard)

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 8dp | Tight spacing |
| `sm` | 12dp | Between related elements |
| `md` | 16dp | Standard container padding |
| `lg` | 24dp | Section separation |
| `xl` | 32dp | Major section breaks |
| `buttonHeight` | 60dp | Touch-friendly buttons |
| `inputRadius` | 8dp | Input field corners |
| `cardRadius` | 12dp | Card corners |

**Layout:**
- Single column layout (portrait only)
- Cards stretch to full width dengan consistent padding (16dp horizontal)
- Bottom sheets always full width

### Accessibility Considerations

| Requirement | Target | Status |
|-------------|--------|--------|
| Text Contrast | WCAG AA (4.5:1) | ✅ Achieved (10.5:1) |
| Touch Targets | 48dp minimum | ✅ Achieved (60dp) |
| Font Legibility | 10px minimum | ✅ Achieved |
| Screen Reader | TalkBack compatible | ✅ Semantic labels |
| Color Independence | Info not by color alone | ✅ Icons + text labels |
| Offline Font | No network dependency | ✅ Poppins bundled |

**Note:** Fase 2 menggunakan visual foundation yang sama dengan Fase 1 untuk maintain consistency.

## Design Direction

### Design Directions Explored

**Fase 2 Extension:** Karena Fase 2 adalah extension dari Fase 1, design direction mengikuti pola yang sudah established:

| Direction | Approach | Status |
|-----------|----------|--------|
| **Bulldozer Evolution** | Maintain familiarity dengan Fase 1 | ✅ Selected |
| **Warm Friendly** | Rounded corners, soft shadows | ✅ Selected |
| **Card-Focused** | Tappable cards, no buttons | ✅ Selected |
| **Bottom Sheet Pattern** | Consistent untuk CREATE/ASSIGN/VIEW | ✅ Selected |

### Chosen Direction

**Hybrid: Bulldozer Evolution + Warm Friendly (Extended untuk Fase 2)**

**Visual Design HTML:** `_bmad-output/planning-artifacts/ux-final-direction-fase2.html`

**Key Screens:**
1. **Kasie PG Main** - FAB visible, CREATE capability
2. **CREATE Bottom Sheet** - Form pembuatan rencana kerja
3. **Kasie FE ASSIGN** - Assign operator ke work plan OPEN
4. **Operator VIEW** - No FAB, filtered list
5. **Detail View** - Read-only untuk semua roles
6. **Status Workflow** - OPEN → ASSIGNED → COMPLETED

### Design Rationale

**Why This Direction:**

1. **Consistency** - Users Fase 1 tidak perlu re-learn UI patterns
2. **Familiarity** - Bulldozer alignment memudahkan adopsi
3. **Clarity** - Status colors (Orange→Blue→Green) instant recognition
4. **Efficiency** - Bottom sheet pattern minimizes context switching

### Implementation Approach

**File Structure:**
```
lib/
├── features/
│   └── work_plan/
│       ├── data/
│       ├── domain/
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           └── widgets/
│               ├── work_plan_card.dart      # NEW Fase 2
│               ├── create_bottom_sheet.dart # NEW Fase 2
│               ├── assign_bottom_sheet.dart # NEW Fase 2
│               └── status_badge.dart        # NEW Fase 2
```

**Key Components:**
- `WorkPlanCard` - Extended dari TaskCard dengan status indicators
- `CreateBottomSheet` - Form untuk CREATE work plan
- `AssignBottomSheet` - Form untuk ASSIGN operator
- `StatusBadge` - Color-coded status (OPEN/ASSIGNED/COMPLETED)

## Component Strategy

### Design System Components (Material 3)

Fase 2 menggunakan **Material Design 3 components** tanpa modifikasi signifikan. Semua komponen adalah standard Material widgets:

| Component | Material Widget | Usage in Fase 2 |
|-----------|-----------------|-----------------|
| **Buttons** | `ElevatedButton`, `TextButton` | Submit actions, Cancel buttons |
| **Text Fields** | `TextFormField` | CREATE form (4 fields), ASSIGN dropdown |
| **Cards** | `Card` | WorkPlanCard container |
| **Bottom Sheets** | `showModalBottomSheet` | CREATE/ASSIGN/VIEW detail |
| **Lists** | `ListView`, `ListTile` | Work plan list |
| **Progress** | `CircularProgressIndicator` | Button loading states |
| **Snackbars** | `SnackBar` | Success/error toast messages |
| **Dividers** | `Divider` | Visual separation dalam lists |
| **Icons** | `Icons` (Material) | Status indicators, actions |

**Reference:** [Material Design 3 Components](https://m3.material.io/components)

### Custom Components (Fase 2)

Empat komponen custom yang harus diimplementasikan untuk Fase 2:

#### 1. WorkPlanCard

**Purpose:** Display work plan dengan status indicator

**Props:**
```dart
class WorkPlanCard extends StatelessWidget {
  final WorkPlan workPlan;
  final VoidCallback onTap;
  final bool showAssignButton; // true untuk Kasie FE
}
```

**Visual:**
- Card dengan border-left 4dp (color sesuai status)
- Status badge di kanan atas
- Info: Tanggal, Pola, Shift, Lokasi, Operator (jika assigned)
- Tap untuk detail bottom sheet

**Status Colors:**
- OPEN: Orange border (`#FBA919`)
- ASSIGNED: Blue border (`#25AAE1`)
- COMPLETED: Green border (`#008945`)

---

#### 2. CreateBottomSheet

**Purpose:** Form untuk CREATE work plan (Kasie PG only)

**Props:**
```dart
class CreateBottomSheet extends StatelessWidget {
  final VoidCallback onSubmit;
  final Function(WorkPlanFormData) onSave;
}
```

**Fields:**
1. Tanggal (Date picker, auto-fill today)
2. Pola (Dropdown: Pola A, Pola B, Pola C)
3. Shift (Dropdown: Shift 1, Shift 2)
4. Lokasi (Text field dengan auto-complete)

**Actions:**
- Primary: "Simpan" (ElevatedButton, orange)
- Secondary: "Batal" (TextButton)

---

#### 3. AssignBottomSheet

**Purpose:** Form untuk ASSIGN operator (Kasie FE only)

**Props:**
```dart
class AssignBottomSheet extends StatelessWidget {
  final WorkPlan workPlan;
  final List<Operator> availableOperators;
  final Function(String operatorId) onAssign;
}
```

**Content:**
- Work plan detail (read-only)
- Dropdown: Pilih Operator (dari cached list)
- Loading state saat fetch operator list

**Actions:**
- Primary: "Tugaskan Operator" (ElevatedButton, blue)
- Secondary: "Batal" (TextButton)

---

#### 4. StatusBadge

**Purpose:** Color-coded status indicator

**Props:**
```dart
class StatusBadge extends StatelessWidget {
  final WorkPlanStatus status; // open, assigned, completed
}
```

**Visual:**
- Pill-shaped badge dengan background color
- Text: "OPEN", "ASSIGNED", "COMPLETED"
- Color mapping:
  - OPEN: Orange background, white text
  - ASSIGNED: Blue background, white text
  - COMPLETED: Green background, white text

### Implementation Roadmap

#### Phase 1: Core Components (Week 1)

| Priority | Component | Dependencies | Effort |
|----------|-----------|--------------|--------|
| P0 | `StatusBadge` | None | 1 day |
| P0 | `WorkPlanCard` | StatusBadge | 2 days |
| P1 | `CreateBottomSheet` | Material forms | 3 days |
| P1 | `AssignBottomSheet` | Material dropdown | 3 days |

#### Phase 2: Integration (Week 2)

| Task | Description |
|------|-------------|
| List Integration | WorkPlanCard dalam ListView dengan proper spacing |
| State Management | BLoC pattern untuk CREATE/ASSIGN actions |
| Form Validation | Inline validation untuk semua fields |
| Loading States | Skeleton shimmer saat initial load |

#### Phase 3: Polish (Week 3)

| Task | Description |
|------|-------------|
| Animation | Bottom sheet transitions, status change animations |
| Edge Cases | Empty states, error states, offline handling |
| Accessibility | Semantic labels, screen reader support |
| Golden Tests | Screenshot tests untuk semua component states |

### Component Hierarchy

```
WorkPlanPage
├── GreetingHeader (existing Fase 1)
├── WeatherWidget (existing Fase 1)
├── WorkPlanList
│   └── WorkPlanCard[]
│       └── StatusBadge
├── CreateBottomSheet (Kasie PG only)
│   ├── DatePicker
│   ├── Dropdown (Pola)
│   ├── Dropdown (Shift)
│   └── TextField (Lokasi)
└── AssignBottomSheet (Kasie FE only)
    ├── WorkPlanDetail (read-only)
    └── OperatorDropdown
```

### Golden Test Requirements

Semua custom components harus memiliki golden tests:

| Component | States to Test |
|-----------|----------------|
| WorkPlanCard | OPEN, ASSIGNED, COMPLETED, loading |
| CreateBottomSheet | Empty form, filled form, validation error |
| AssignBottomSheet | Loading operators, operator selected, success |
| StatusBadge | OPEN, ASSIGNED, COMPLETED |

### File Organization

```
lib/features/work_plan/presentation/widgets/
├── work_plan_card.dart
├── create_bottom_sheet.dart
├── assign_bottom_sheet.dart
├── status_badge.dart
└── work_plan_list.dart
```

---

**UX Design Specification Fase 2 - Complete**

*Dokumen ini merupakan extension dari Fase 1. Semua patterns, colors, dan typography mengikuti foundation yang sudah established.*

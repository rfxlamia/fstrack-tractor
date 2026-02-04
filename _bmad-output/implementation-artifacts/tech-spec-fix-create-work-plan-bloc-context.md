---
title: 'Fix Create Work Plan Bottom Sheet BLoC Context Issue'
slug: 'fix-create-work-plan-bloc-context'
created: '2026-02-03'
status: 'ready-for-dev'
stepsCompleted: [1, 2, 3, 4]
tech_stack: ['Flutter 3.x', 'flutter_bloc 8.1.3', 'get_it + injectable', 'Dart 3+']
files_to_modify: ['fstrack_tractor_app/lib/features/home/presentation/pages/home_page.dart', 'fstrack_tractor_app/lib/features/work_plan/presentation/widgets/create_bottom_sheet.dart', 'fstrack_tractor_app/lib/features/work_plan/presentation/pages/work_plan_list_page.dart']
code_patterns: ['BlocProvider.value', 'showModalBottomSheet', 'BlocConsumer', 'MultiBlocProvider', 'Builder', 'Clean Architecture']
test_patterns: ['BlocProvider.value in test harness', 'MockBloc pattern', 'Golden tests with golden_toolkit']
---

# Tech-Spec: Fix Create Work Plan Bottom Sheet BLoC Context Issue

**Created:** 2026-02-03

## Overview

### Problem Statement

CreateBottomSheet muncul **fullscreen abu-abu kosong** tanpa form fields yang bisa diinteraksi ketika FAB diklik.

**Root Cause:**

Di `home_page.dart`, FAB berada **DILUAR** `MultiBlocProvider` tree:

```
HomePage.build(context)  ← Context A (TIDAK punya WorkPlanBloc)
└── Scaffold
    ├── body: MultiBlocProvider    ← Context B (punya WorkPlanBloc)
    │   ├── BlocProvider<WeatherBloc>
    │   ├── BlocProvider<WorkPlanBloc>  ← WorkPlanBloc di-provide di SINI (line 50-52)
    │   └── child: BannerWrapper → HomePageContent
    │
    └── floatingActionButton: _buildFab(context)  ← Pakai Context A! (line 63)
        └── CreateBottomSheet.show(context)       ← Context A tanpa WorkPlanBloc! (line 77)
```

Ketika `CreateBottomSheet.show(context)` dipanggil dari FAB, `context` tersebut adalah dari `HomePage.build()` - yang berada SEBELUM `MultiBlocProvider`. Akibatnya, modal tidak punya akses ke `WorkPlanBloc`.

**Secondary Issue:**
`work_plan_list_page.dart` juga memanggil `_showCreateBottomSheet()` (line 49-56) tanpa inject BLoC ke modal context.

**Error yang muncul:**
```
Error: Could not find the correct Provider<WorkPlanBloc> above this BlocConsumer<WorkPlanBloc, WorkPlanState> Widget
```

### Solution

**Approach: MultiBlocProvider + Builder pattern (dari Party Mode consensus)**

1. **Restructure `home_page.dart`:** Wrap `Scaffold` dengan `MultiBlocProvider`, lalu gunakan `Builder` widget untuk create new context yang punya akses ke BLoC. FAB menggunakan context dari Builder.

2. **Inject BLoC ke modal:** Di `CreateBottomSheet.show()` dan `_showCreateBottomSheet()`, wrap modal dengan `BlocProvider.value` untuk inject WorkPlanBloc instance dari parent context.

**Why Builder pattern:**
- `Builder` widget creates new `BuildContext` yang berada di bawah `MultiBlocProvider`
- Context baru ini punya akses ke semua BLoC yang di-provide
- Pattern ini "boring but works" - predictable dan maintainable

### Scope

**In Scope:**
- Fix `home_page.dart` dengan MultiBlocProvider + Builder pattern
- Fix `create_bottom_sheet.dart` CreateBottomSheet.show() dengan BlocProvider.value
- Fix `work_plan_list_page.dart` _showCreateBottomSheet() dengan BlocProvider.value
- Verify Epic 2 end-to-end flow: FAB → Form tampil → Submit → Success toast → Auto-refresh → List update
- Test semua 5 form fields visible dan interactable
- Ensure RBAC masih bekerja: FAB hanya visible untuk kasie_pg role
- Run flutter analyze dan flutter test untuk ensure zero regressions

**Out of Scope:**
- Placeholder di card detail (intentional untuk Epic 4)
- Backend API changes
- Form validation logic (sudah implemented dengan benar)
- Dropdown hardcoded values (MVP limitation)
- Testing framework changes

## Context for Development

### Codebase Patterns

**BLoC Context Pattern:**
- BLoC di-provide di page level via `BlocProvider` atau `MultiBlocProvider`
- Widget access BLoC via `context.read<T>()` atau `BlocConsumer<T>`
- Modal/Dialog yang butuh BLoC harus wrap dengan `BlocProvider.value`
- `Builder` widget digunakan untuk create new context setelah provider

**Clean Architecture:**
```
work_plan/
├── domain/          # Entities, repository interfaces, use cases
├── data/            # API implementation, models, datasources
└── presentation/    # BLoC, pages, widgets
```

**RBAC Pattern:**
FAB visibility menggunakan `BlocBuilder<AuthBloc, AuthState>` untuk check `user.role.canCreateWorkPlan`

### Files to Modify

| File | Line | Action |
| ---- | ---- | ------ |
| `home_page.dart` | 29-65 | Restructure dengan MultiBlocProvider + Builder |
| `create_bottom_sheet.dart` | 22-32 | Wrap modal dengan BlocProvider.value |
| `work_plan_list_page.dart` | 49-56 | Wrap modal dengan BlocProvider.value |

### Technical Decisions

**Decision: Use Builder widget (not move FAB to different widget)**
- `Builder` creates new context tanpa restructure widget hierarchy
- Minimal code changes, less invasive
- Pattern yang sudah proven di Flutter ecosystem

**Decision: Use BlocProvider.value (not BlocProvider)**
- `BlocProvider` creates NEW instance → wrong
- `BlocProvider.value` reuses EXISTING instance → correct
- Ensures modal dan parent share same BLoC state

**Decision: Keep BlocConsumer in CreateBottomSheet**
- BlocConsumer handles listening (toast) dan building (loading state)
- Pattern sudah correct, hanya perlu BLoC injection

## Implementation Plan

### Rollback Plan

**If something goes wrong:**
```bash
git checkout -- fstrack_tractor_app/lib/features/home/presentation/pages/home_page.dart
git checkout -- fstrack_tractor_app/lib/features/work_plan/presentation/widgets/create_bottom_sheet.dart
git checkout -- fstrack_tractor_app/lib/features/work_plan/presentation/pages/work_plan_list_page.dart
```

### Tasks

- [ ] **Task 1: Restructure HomePage dengan MultiBlocProvider + Builder**
  - File: `fstrack_tractor_app/lib/features/home/presentation/pages/home_page.dart`
  - Action: Wrap Scaffold dengan MultiBlocProvider + Builder
  - **IMPORTANT:** Preserve ALL existing code inside AppBar, BannerWrapper, etc. Only change the STRUCTURE as shown below.
  - **Changes Required:**
    1. Move `MultiBlocProvider` from wrapping `body` to wrapping entire `Scaffold`
    2. Add `Builder` widget between `MultiBlocProvider` and `Scaffold`
    3. Keep `_buildFab` method unchanged - just pass the new `context` from Builder
  - **Diff-style change:**
    ```dart
    // BEFORE (current structure):
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(...),  // KEEP ALL APPBAR CODE AS-IS
        body: MultiBlocProvider(  // <-- MOVE THIS UP
          providers: [...],
          child: BannerWrapper(...),  // KEEP AS-IS
        ),
        floatingActionButton: _buildFab(context),  // BUG: wrong context
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    }

    // AFTER (fixed structure):
    @override
    Widget build(BuildContext context) {
      return MultiBlocProvider(  // <-- MOVED TO TOP
        providers: [
          BlocProvider<WeatherBloc>(create: (_) => getIt<WeatherBloc>()),
          BlocProvider<WorkPlanBloc>(create: (_) => getIt<WorkPlanBloc>()),
        ],
        child: Builder(  // <-- NEW: Creates context with BLoC access
          builder: (context) => Scaffold(
            appBar: AppBar(...),  // KEEP ALL EXISTING APPBAR CODE
            body: BannerWrapper(...),  // KEEP ALL EXISTING BODY CODE (remove MultiBlocProvider wrapper)
            floatingActionButton: _buildFab(context),  // FIX: now uses correct context
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          ),
        ),
      );
    }
    ```
  - **DO NOT** modify `_buildFab()` method - it already works correctly, just needs proper context
  - **DO NOT** modify `HomePageContent` - it stays unchanged

- [ ] **Task 2: Fix CreateBottomSheet.show() dengan BlocProvider.value**
  - File: `fstrack_tractor_app/lib/features/work_plan/presentation/widgets/create_bottom_sheet.dart`
  - Location: Line 22-32 (static method `show()`)
  - Before:
    ```dart
    static Future<void> show(BuildContext context) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        builder: (context) => const CreateBottomSheet(),
      );
    }
    ```
  - After:
    ```dart
    static Future<void> show(BuildContext context) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        builder: (modalContext) => BlocProvider.value(
          value: context.read<WorkPlanBloc>(),
          child: const CreateBottomSheet(),
        ),
      );
    }
    ```

- [ ] **Task 3: Fix _showCreateBottomSheet() di work_plan_list_page.dart**
  - File: `fstrack_tractor_app/lib/features/work_plan/presentation/pages/work_plan_list_page.dart`
  - Location: Line 49-56 (method `_showCreateBottomSheet()`)
  - Before:
    ```dart
    void _showCreateBottomSheet() {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const CreateBottomSheet(),
      );
    }
    ```
  - After:
    ```dart
    void _showCreateBottomSheet() {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (modalContext) => BlocProvider.value(
          value: context.read<WorkPlanBloc>(),
          child: const CreateBottomSheet(),
        ),
      );
    }
    ```

- [ ] **Task 4: Run Quality Checks**
  - Run: `cd fstrack_tractor_app && flutter analyze`
  - Expected: "No issues found!"
  - Run: `cd fstrack_tractor_app && flutter test`
  - Expected: All existing tests pass (no regressions)

- [ ] **Task 5: Verify Epic 2 End-to-End Flow (Manual Testing)**
  - Hot restart app: `flutter run`
  - Login sebagai kasie_pg: **`dev_kasie_pg` / `DevPassword123`** (from project-context.md)
  - From HOME PAGE: Tap FAB (+)
  - Verify: Form muncul dengan 5 fields visible
  - Fill form dan tap "Simpan"
  - Verify: Success toast, modal close, navigate ke Work Plan list
  - Verify: New entry visible dengan status OPEN (orange border)
  - Logout, login sebagai operator: **`dev_operator` / `DevPassword123`**
  - Verify: FAB NOT visible

### Acceptance Criteria

- [ ] **AC1:** Given kasie_pg user pada home page, when tap FAB, then CreateBottomSheet muncul dengan semua form fields visible dan interactable
- [ ] **AC2:** Given kasie_pg user pada work plan list page, when tap FAB, then CreateBottomSheet muncul dengan semua form fields visible dan interactable
- [ ] **AC3:** Given form filled with valid data, when tap "Simpan", then loading indicator → success toast "Rencana kerja berhasil dibuat!" → modal close → list auto-refresh
- [ ] **AC4:** Given new work plan created, when view list, then entry visible dengan status OPEN (orange left border, orange badge)
- [ ] **AC5:** Given user is NOT kasie_pg, when view home page or work plan list, then FAB is NOT visible
- [ ] **AC6:** Given API error, when submit form, then error toast in Bahasa Indonesia, modal stays open
- [ ] **AC7:** flutter analyze shows "No issues found!"
- [ ] **AC8:** All existing tests pass (no regressions)

## Additional Context

### Dependencies

**No new dependencies required.** Fix menggunakan existing flutter_bloc patterns.

**BLoC Instances:**
- `WorkPlanBloc` - `@injectable` (creates new instance per request)
- `AuthBloc` - Global BLoC untuk authentication
- `WeatherBloc` - `@injectable`

### Testing Strategy

**Automated Testing:**
- Existing tests (397 total, 58+ for Epic 2) MUST pass
- No new tests required (fix is context injection, not business logic)
- Golden tests untuk CreateBottomSheet sudah exist dan harus tetap match

**Manual Testing:**
1. Hot restart app
2. Login sebagai **`dev_kasie_pg` / `DevPassword123`**
3. Tap FAB di home page → Verify form muncul
4. Fill form: pilih Pola, Shift, Lokasi, Unit
5. Tap "Simpan" → Verify success flow
6. Navigate ke "Lihat Rencana" → Verify new entry
7. Logout, login sebagai **`dev_operator` / `DevPassword123`** → Verify FAB NOT visible

**Regression Checks:**
- Epic 2 Story 2.2 acceptance criteria (form UI)
- Epic 2 Story 2.3 acceptance criteria (BLoC + auto-refresh)
- Epic 2 Story 2.4 acceptance criteria (list display)
- RBAC FAB visibility

### Notes

**Why This Bug Happened:**
- `MultiBlocProvider` wrapped `body` instead of entire `Scaffold`
- FAB dipanggil dengan context dari `build()` - sebelum provider
- Modal juga butuh explicit BLoC injection

**Prevention for Future:**
- Always wrap entire Scaffold with providers, not just body
- Use `Builder` when FAB needs access to provided BLoCs
- Always wrap modal with `BlocProvider.value` when accessing parent BLoC

**Risk Assessment:**
- LOW risk - pattern changes are localized
- Existing tests provide safety net
- No business logic changes

**Current git state:** `1ea78a8b79493c41ddb75909338513186019fb6d`

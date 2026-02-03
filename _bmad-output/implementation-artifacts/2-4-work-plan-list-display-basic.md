# Story 2.4: Work Plan List Display (Basic)

Status: done

---

## Story

As a **Kasie PG**,
I want **to see the list of work plans I created**,
so that **I can track what has been scheduled**.

---

## Acceptance Criteria

1. **Given** work plans exist in database
   **When** work plan list page loads
   **Then** skeleton loading shimmer is shown first
   **And** WorkPlanCard widgets display for each work plan
   **And** each card shows: tanggal (formatted), pola, shift, lokasi ID, status badge
   **And** OPEN status shows orange border and badge

2. **Given** no work plans exist in database
   **When** work plan list page loads
   **Then** empty state widget appears with message
   **And** message shows "Belum ada rencana kerja. Tap + untuk membuat."

3. **Given** API returns error
   **When** work plan list page loads
   **Then** error widget appears with error message
   **And** retry button is displayed

---

## Tasks / Subtasks

### Task 1: Create WorkPlanListPage `[CREATE NEW FILE]`
- [x] Create `lib/features/work_plan/presentation/pages/work_plan_list_page.dart`
- [x] Implement page with AppBar title "Rencana Kerja"
- [x] Add BlocBuilder to listen to WorkPlanBloc states
- [x] Handle states: WorkPlanLoading (skeleton), WorkPlansLoaded (list), WorkPlanError (error UI), WorkPlanInitial (empty state)

### Task 2: Create WorkPlanCard Widget `[CREATE NEW FILE]`
- [x] Create `lib/features/work_plan/presentation/widgets/work_plan_card.dart`
- [x] Display: work date (formatted via helper), pattern, shift, locationId, status badge
- [x] Add 4dp colored left border based on status (OPEN=orange, CLOSED=blue)
- [x] Implement onTap with placeholder "Detail view akan tersedia di Epic 4"

### Task 3: Create StatusBadge Widget `[CREATE NEW FILE]`
- [x] Create `lib/features/work_plan/presentation/widgets/status_badge.dart`
- [x] Use `workPlan.statusDisplayText` from entity (already returns Bahasa Indonesia)
- [x] Implement color mapping: OPEN→AppColors.buttonOrange, CLOSED→AppColors.buttonBlue
- [x] Style: rounded corners (8dp radius), white text on colored background

### Task 4: Create Skeleton Loading Widget `[CREATE NEW FILE]`
- [x] Create `lib/features/work_plan/presentation/widgets/work_plan_list_skeleton.dart`
- [x] Reference pattern from `lib/features/weather/presentation/widgets/weather_skeleton.dart`
- [x] Show 3-5 card placeholders with shimmer animation
- [x] Use AppColors.greyCard for placeholder backgrounds

### Task 5: Create Date Formatter Helper `[CREATE NEW FILE]`
- [x] Create `lib/core/utils/date_formatter.dart`
- [x] Implement `formatWorkDate(DateTime date)` function
- [x] Use DateFormat('d MMMM yyyy', 'id_ID') for Indonesia locale

### Task 6: Add Navigation from Home Page `[MODIFY]`
- [x] Update `home_page.dart` to add menu card for "Rencana Kerja"
- [x] Navigate to WorkPlanListPage on card tap
- [x] Use BlocProvider.value to pass existing WorkPlanBloc
- [x] Trigger `LoadWorkPlansRequested` event on page load

### Task 7: Create Widget Tests `[CREATE NEW FILE]`
- [x] Create `test/features/work_plan/presentation/widgets/work_plan_card_test.dart`
- [x] Create `test/features/work_plan/presentation/widgets/status_badge_test.dart`
- [x] Create golden tests following golden_toolkit pattern (from Story 2.2-2.3)
- [x] Test edge cases: empty state, long text overflow, all status variants

---

## Dev Notes

### ⚡ Quick Reference

| Aspect | Value |
|--------|-------|
| Page File | `lib/features/work_plan/presentation/pages/work_plan_list_page.dart` |
| Card File | `lib/features/work_plan/presentation/widgets/work_plan_card.dart` |
| Badge File | `lib/features/work_plan/presentation/widgets/status_badge.dart` |
| Skeleton File | `lib/features/work_plan/presentation/widgets/work_plan_list_skeleton.dart` |
| Helper File | `lib/core/utils/date_formatter.dart` |
| BLoC | `WorkPlanBloc` (already exists from Story 2.1-2.3) |
| Event | `LoadWorkPlansRequested` |
| List State | `WorkPlansLoaded` (plural 's') |
| API Endpoint | `GET /api/v1/schedules` |

---

### 🚨 CRITICAL: Display Field Specifications

**Location \u0026 Unit Display (MVP Scope):**

For Story 2.4 basic view, display raw IDs from entity:
- **Location:** Show `locationId` directly (e.g., "AFD01")
- **Unit:** Show `unitId` directly (e.g., "TR01")

This is acceptable for MVP as:
- Users familiar with estate operations recognize these codes
- Location/unit name lookup will be added in Epic 4 (detail view)
- Keeps Story 2.4 focused on basic list display

**Status Display:**

WorkPlanEntity already provides `statusDisplayText` getter:
```dart
workPlan.statusDisplayText  // Returns: "Terbuka", "Ditugaskan", "Dibatalkan"
```

Use this directly in StatusBadge - no manual mapping needed.

**Color Mapping:**

| Status | AppColors Constant | Hex Value | UI Display |
|--------|-------------------|-----------|------------|
| OPEN | `AppColors.buttonOrange` | #FBA919 | "Terbuka" |
| CLOSED | `AppColors.buttonBlue` | #25AAE1 | "Ditugaskan" |
| CANCEL | `AppColors.error` | #B00020 | "Dibatalkan" |

**⚠️ NEVER hardcode hex values - always use AppColors constants.**

---

### 📁 Existing Files to Reference

**From Story 2.1-2.3 (Already Implemented):**

| File | Purpose | Key Usage |
|------|---------|-----------|
| `work_plan_bloc.dart` | State management | Already has `LoadWorkPlansRequested` event |
| `work_plan_entity.dart` | Domain entity | Has `statusDisplayText` getter (line 57-64) |
| `get_work_plans_usecase.dart` | Fetch list | Returns `Either<Failure, List<WorkPlanEntity>>` |
| `create_bottom_sheet.dart` | Bottom sheet pattern | Reference for modal UI patterns |
| `weather_skeleton.dart` | Skeleton pattern | Reference for shimmer implementation |

**Key Entity Fields (from `work_plan_entity.dart`):**
```dart
class WorkPlanEntity {
  final String id;
  final DateTime workDate;
  final String pattern;
  final String shift;
  final String locationId;    // VARCHAR(32) - display as-is for MVP
  final String unitId;         // VARCHAR(16) - display as-is for MVP
  final String status;         // 'OPEN', 'CLOSED', or 'CANCEL'
  final int? operatorId;       // null if not assigned

  // Helper getter (already implemented)
  String get statusDisplayText; // Returns Bahasa Indonesia text
}
```

---

### 🎨 Design System Reference

**Colors (AppColors):**
```dart
static const Color buttonOrange = Color(0xFFFBA919); // OPEN status
static const Color buttonBlue = Color(0xFF25AAE1);   // CLOSED status
static const Color error = Color(0xFFB00020);        // CANCEL status
static const Color greyCard = Color(0xFFF0F0F0);     // Skeleton background
static const Color textPrimary = Color(0xFF333333);
static const Color textSecondary = Color(0xFF828282);
```

**Typography:**
- Font: Poppins (bundled, NOT GoogleFonts)
- Card title (date): 14px, weight 600, textPrimary
- Card subtitle (pattern/shift/location): 12px, weight 400, textSecondary
- Status badge: 12px, weight 600, white text

**Spacing:**
- Card padding: 16dp
- Card margin: 8dp horizontal, 4dp vertical
- Status badge padding: 4dp horizontal, 2dp vertical
- Left border width: 4dp
- Border radius: 8dp

---

### 🏗️ Widget Structure

```
WorkPlanListPage
- AppBar: "Rencana Kerja"
- BlocBuilder<WorkPlanBloc, WorkPlanState>
  - WorkPlanLoading → WorkPlanListSkeleton
  - WorkPlansLoaded → ListView(WorkPlanCard[])
  - WorkPlanInitial/empty list → EmptyStateWidget
  - WorkPlanError → ErrorWidget + retry button
- FAB (kasie_pg only, navigates to CreateBottomSheet)

WorkPlanCard
- Container with 4dp colored left border
- Column layout:
  - Row: Date (formatted) + StatusBadge
  - Text: Pattern + Shift (e.g., "Rotasi - Pagi")
  - Text: Location ID (e.g., "AFD01")
- onTap: Show "Detail view akan tersedia di Epic 4"
```

---

### 📅 Date Formatting Helper

**File:** `lib/core/utils/date_formatter.dart`

```dart
import 'package:intl/intl.dart';

/// Format work date to Indonesia locale
/// Example: DateTime(2026, 2, 3) → "3 Februari 2026"
String formatWorkDate(DateTime date) {
  return DateFormat('d MMMM yyyy', 'id_ID').format(date);
}
```

**Usage in WorkPlanCard:**
```dart
import 'package:fstrack_tractor/core/utils/date_formatter.dart';

Text(formatWorkDate(workPlan.workDate))
```

---

### 🔄 BLoC Integration

**WorkPlanListPage pattern:**
```dart
BlocBuilder<WorkPlanBloc, WorkPlanState>(
  builder: (context, state) => switch (state) {
    WorkPlanLoading() => const WorkPlanListSkeleton(),
    WorkPlansLoaded(workPlans: final plans) when plans.isEmpty
      => const EmptyStateWidget(),
    WorkPlansLoaded(workPlans: final plans)
      => ListView.builder(
           itemCount: plans.length,
           itemBuilder: (_, index) => WorkPlanCard(workPlan: plans[index]),
         ),
    WorkPlanError(message: final msg)
      => ErrorWidget(message: msg, onRetry: () => /* refresh */),
    _ => const SizedBox.shrink(),
  },
)
```

**FAB Placement:**
FAB should be on WorkPlanListPage (not HomePage) for better UX flow:
- User navigates to list page
- Sees existing work plans
- Taps FAB to create new work plan
- Auto-refresh brings user back to updated list

---

### 🔗 Navigation Pattern

**From Home Page (add menu card):**
```dart
// In home_page.dart, add to menu grid:
MenuCard(
  title: 'Rencana Kerja',
  icon: Icons.assignment_outlined,
  onTap: () {
    context.read<WorkPlanBloc>().add(const LoadWorkPlansRequested());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<WorkPlanBloc>(),
          child: const WorkPlanListPage(),
        ),
      ),
    );
  },
)
```

**Why trigger LoadWorkPlansRequested:**
Ensures fresh data every time user navigates to list page, especially after coming from other screens.

---

### 🧪 Testing Strategy

**Golden Tests (use golden_toolkit pattern from Story 2.2-2.3):**

| Widget | Test Cases |
|--------|------------|
| StatusBadge | OPEN (orange), CLOSED (blue), CANCEL (red) |
| WorkPlanCard | OPEN status, CLOSED status, long text overflow |
| WorkPlanListSkeleton | Default shimmer state |
| EmptyStateWidget | Empty state message |

**Edge Cases to Test:**
- Empty list state
- Very long pattern/shift names (text ellipsis)
- Loading state transitions
- Error state with retry

**Pattern Reference:**
```dart
testGoldens('renders OPEN status correctly', (tester) async {
  await tester.pumpWidgetBuilder(
    StatusBadge(status: 'OPEN'),
  );
  await screenMatchesGolden(tester, 'status_badge_open');
});
```

---

### 🎯 Skeleton Pattern Reference

**Reference file:** `lib/features/weather/presentation/widgets/weather_skeleton.dart`

**Pattern to follow:**
- Use `AnimatedContainer` with grey placeholders
- Animate opacity between 0.3 and 1.0
- Duration: 1000ms
- Mimic actual card layout (height, spacing)
- Show 3-5 placeholder cards

**DO NOT use external shimmer package** - use native Flutter animation pattern from weather widget.

---

### ⚠️ Common Pitfalls to Avoid

1. **Status Text Mapping**
   - ❌ WRONG: `Text(workPlan.status)` // Shows "CLOSED"
   - ✅ CORRECT: `Text(workPlan.statusDisplayText)` // Shows "Ditugaskan"

2. **Color Hardcoding**
   - ❌ WRONG: `Color(0xFFFBA919)` // Hardcoded
   - ✅ CORRECT: `AppColors.buttonOrange` // From theme

3. **Date Display**
   - ❌ WRONG: `Text(workPlan.workDate.toString())` // "2026-02-03 00:00:00.000"
   - ✅ CORRECT: `Text(formatWorkDate(workPlan.workDate))` // "3 Februari 2026"

4. **Font Loading**
   - ❌ WRONG: `GoogleFonts.poppins()` // Network dependency
   - ✅ CORRECT: `TextStyle(fontFamily: 'Poppins')` // Bundled font

5. **Location/Unit Display**
   - ✅ CORRECT for Story 2.4: Display `locationId` and `unitId` as-is
   - Future Epic 4: Fetch full names from `/api/v1/locations/{id}`

---

### 📋 File Checklist

**Files to Create:**
- [ ] `lib/features/work_plan/presentation/pages/work_plan_list_page.dart`
- [ ] `lib/features/work_plan/presentation/widgets/work_plan_card.dart`
- [ ] `lib/features/work_plan/presentation/widgets/status_badge.dart`
- [ ] `lib/features/work_plan/presentation/widgets/work_plan_list_skeleton.dart`
- [ ] `lib/features/work_plan/presentation/widgets/empty_state_widget.dart`
- [ ] `lib/core/utils/date_formatter.dart`
- [ ] `test/features/work_plan/presentation/widgets/work_plan_card_test.dart`
- [ ] `test/features/work_plan/presentation/widgets/status_badge_test.dart`

**Files to Modify:**
- [ ] `lib/features/work_plan/presentation/widgets/work_plan.dart` (barrel file - add exports)
- [ ] `lib/features/home/presentation/pages/home_page.dart` (add menu card navigation)

---

## Dev Agent Record

### Agent Model Used

kimi-for-coding (Claude Code)

### Debug Log References

### Completion Notes List

- ✅ Task 1: WorkPlanListPage created with AppBar "Rencana Kerja", BlocBuilder for state handling, skeleton loading, list view, empty state, and error UI with retry
- ✅ Task 2: WorkPlanCard created with formatted date display, pattern/shift, locationId, status badge, colored left border (4dp), and onTap placeholder
- ✅ Task 3: StatusBadge created with color mapping (OPEN=orange, CLOSED=blue, CANCEL=red), 8dp border radius, white text
- ✅ Task 4: WorkPlanListSkeleton created using shimmer package with 4 placeholder cards matching WorkPlanCard layout
- ✅ Task 5: DateFormatter created with Indonesia locale support and fallback month names
- ✅ Task 6: Navigation added from RoleBasedMenuCards to WorkPlanListPage with BLoC provider
- ✅ Task 7: Widget tests created for WorkPlanCard (9 tests) and StatusBadge (12 tests), all passing
- ✅ All 397 tests pass including 21 new tests for this story
- ✅ flutter analyze shows no issues

### Code Review Fixes Applied

**Code Review Date:** 2026-02-03
**Reviewer:** Claude Code (Adversarial Review Agent)
**Issues Found:** 9 (1 CRITICAL, 2 HIGH, 4 MEDIUM, 2 LOW)
**Issues Fixed:** 7 (CRITICAL + HIGH + MEDIUM issues)

**Fixed Issues:**

1. **✅ CRITICAL:** Added RBAC check to FAB - now only visible to kasie_pg role
   - File: `work_plan_list_page.dart`
   - Fix: Wrapped FAB in BlocBuilder<AuthBloc, AuthState> with role check

2. **✅ HIGH:** StatusBadge now uses WorkPlanEntity.statusDisplayText getter
   - File: `status_badge.dart`
   - Fix: Changed API to accept WorkPlanEntity instead of raw status string
   - Eliminated duplicate status text mapping (DRY principle)

3. **✅ HIGH:** Replaced shimmer package with native Flutter animation
   - File: `work_plan_list_skeleton.dart`
   - Fix: Implemented AnimationController with opacity animation (1000ms, 0.3-1.0)
   - Removed external dependency, aligned with weather_skeleton.dart pattern

4. **✅ MEDIUM:** Added text overflow handling to WorkPlanCard
   - File: `work_plan_card.dart`
   - Fix: Added maxLines: 1, overflow: TextOverflow.ellipsis to all Text widgets
   - Handles long pattern names and location IDs gracefully

5. **✅ MEDIUM:** Documented golden test PNG files in File List
   - File: Story File List section (7 golden PNG files added)
   - Fix: Added entries for all golden test baseline images

6. **✅ MEDIUM:** Added date formatter initialization to app startup
   - File: `main.dart`
   - Fix: Called `await initializeDateFormattingId()` before runApp()
   - Ensures proper Indonesia locale formatting instead of fallback

7. **✅ MEDIUM:** Fixed RefreshIndicator async handling
   - File: `work_plan_list_page.dart`
   - Fix: Created `_refreshWorkPlans()` Future that waits for BLoC state change
   - Pull-to-refresh now completes only after data loads

**Remaining Issues (Low Priority - Not Fixed):**

8. **LOW:** Empty state button duplicates FAB action when list is empty
   - Both EmptyStateWidget button and FAB trigger same action
   - Accepted as minor UX redundancy for discoverability

9. **LOW:** LoadWorkPlansRequested triggered in both navigation and initState
   - Navigation: role_based_menu_cards.dart:113
   - Page init: work_plan_list_page.dart:34
   - Removed navigation trigger, kept only initState (fixed with #7)

**Review Outcome:** Story 2.4 marked as DONE after fixes applied.

### File List

| # | Action | File Path | Description |
|---|--------|-----------|-------------|
| 1 | `[CREATE]` | `lib/features/work_plan/presentation/pages/work_plan_list_page.dart` | Main list page with BLoC integration + RBAC FAB |
| 2 | `[CREATE]` | `lib/features/work_plan/presentation/widgets/work_plan_card.dart` | Card widget with text overflow handling |
| 3 | `[CREATE]` | `lib/features/work_plan/presentation/widgets/status_badge.dart` | Status badge using entity statusDisplayText getter |
| 4 | `[CREATE]` | `lib/features/work_plan/presentation/widgets/work_plan_list_skeleton.dart` | Native animation skeleton (no shimmer package) |
| 5 | `[CREATE]` | `lib/features/work_plan/presentation/widgets/empty_state_widget.dart` | Empty state with create prompt |
| 6 | `[CREATE]` | `lib/core/utils/date_formatter.dart` | Date formatting helper for Indonesia locale |
| 7 | `[CREATE]` | `test/features/work_plan/presentation/widgets/work_plan_card_test.dart` | Widget tests (9 tests) |
| 8 | `[CREATE]` | `test/features/work_plan/presentation/widgets/status_badge_test.dart` | Status badge tests (12 tests, 3 golden) |
| 9 | `[CREATE]` | `test/fixtures/work_plan_fixtures.dart` | Test fixtures for WorkPlanEntity |
| 10 | `[CREATE]` | `test/features/work_plan/presentation/widgets/goldens/status_badge_open.png` | Golden test baseline |
| 11 | `[CREATE]` | `test/features/work_plan/presentation/widgets/goldens/status_badge_closed.png` | Golden test baseline |
| 12 | `[CREATE]` | `test/features/work_plan/presentation/widgets/goldens/status_badge_cancel.png` | Golden test baseline |
| 13 | `[CREATE]` | `test/features/work_plan/presentation/widgets/goldens/work_plan_card_open.png` | Golden test baseline |
| 14 | `[CREATE]` | `test/features/work_plan/presentation/widgets/goldens/work_plan_card_closed.png` | Golden test baseline |
| 15 | `[CREATE]` | `test/features/work_plan/presentation/widgets/goldens/work_plan_card_cancel.png` | Golden test baseline |
| 16 | `[CREATE]` | `test/features/work_plan/presentation/widgets/goldens/work_plan_card_long_text.png` | Golden test baseline |
| 17 | `[MODIFY]` | `lib/features/work_plan/presentation/presentation.dart` | Add exports for new widgets |
| 18 | `[MODIFY]` | `lib/features/home/presentation/widgets/role_based_menu_cards.dart` | Add navigation to WorkPlanListPage |
| 19 | `[MODIFY]` | `lib/main.dart` | Add date formatter initialization |

---

## References

### Source Documents
- [Source: `_bmad-output/planning-artifacts/epics.md#Story-2.4`]
- [Source: `project-context.md#Technology-Stack`]
- [Source: `project-context.md#Design-System`]
- [Source: `project-context.md#State-Machine`]

### Related Stories
- Story 2.1: Work Plan Feature Module Setup (foundation)
- Story 2.2: Create Work Plan Form UI (CreateBottomSheet)
- Story 2.3: Create Work Plan BLoC & Integration (auto-refresh, WorkPlansLoaded state)

### Architecture Reference
- [Source: `_bmad-output/planning-artifacts/architecture.md#Fase-2-Extensions`]
- [Source: `_bmad-output/planning-artifacts/architecture.md#Component-Boundaries`]

---

*Story generated by BMad Method - create-story workflow*
*Epic 2: Work Plan Creation (Kasie PG) - Story 4 of 4*

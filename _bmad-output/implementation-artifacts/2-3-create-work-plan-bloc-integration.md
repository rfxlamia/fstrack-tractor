# Story 2.3: Create Work Plan BLoC & Integration

Status: done
Validated: 2026-02-03 (Quality Review - 4 critical fixes, 3 enhancements applied)

<!-- Quality Review Summary:
  - Fix #1: Corrected BLoC provider pattern to match actual implementation
  - Fix #2: Added explicit instruction that auto-refresh MUST be implemented (not existing)
  - Fix #3: Clarified WorkPlansLoaded vs WorkPlanLoaded state naming
  - Fix #4: Documented BLoC context scope for CreateBottomSheet
  - Enhancement #1: Added test file creation instructions with dependencies
  - Enhancement #2: Clarified error handling already implemented in Story 2.2
  - Enhancement #3: Consolidated file references and reduced verbosity
-->

## Story

As a **Kasie PG**,
I want **to submit the create form and see the result**,
so that **I know my work plan was created successfully**.

## Acceptance Criteria

1. **Given** all form fields are filled correctly
   **When** "Simpan" is tapped
   **Then** loading state is shown on button
   **And** POST request is sent to `/api/v1/schedules`
   **And** on success, toast appears: "Rencana kerja berhasil dibuat!"
   **And** bottom sheet closes
   **And** work plan list refreshes with new entry (status OPEN)

2. **Given** the API returns an error
   **When** "Simpan" is tapped
   **Then** error toast appears with message in Bahasa Indonesia
   **And** form remains open for retry

## Tasks / Subtasks

### Task 1: Add Auto-Refresh to BLoC Event Handler `[MODIFY]`
- [x] Update `_onCreateWorkPlanRequested` in `work_plan_bloc.dart`
- [x] Add `add(LoadWorkPlansRequested())` after `emit(WorkPlanCreated(workPlan))`
- [x] Verify state sequence: Loading → Created → Loading → WorkPlansLoaded

### Task 2: Verify CreateBottomSheet Integration `[EXISTING - VERIFY]`
- [x] Confirm BlocConsumer is already connected (Story 2.2)
- [x] Confirm success/error handlers work with new auto-refresh
- [x] Test that bottom sheet closes on success

### Task 3: Create BLoC Unit Tests `[CREATE NEW FILE]`
- [x] Create `test/features/work_plan/presentation/bloc/work_plan_bloc_test.dart`
- [x] Test create success → auto-refresh sequence
- [x] Test create failure → error state

### Task 4: Add Loading State Golden Test `[MODIFY]`
- [x] Add golden test for loading state in `create_bottom_sheet_test.dart`

---

## Dev Notes

### ⚡ Quick Reference

| Aspect | Value |
|--------|-------|
| BLoC File | `lib/features/work_plan/presentation/bloc/work_plan_bloc.dart` |
| Event | `CreateWorkPlanRequested` (line 30-56 in event file) |
| Success State | `WorkPlanCreated` |
| List State | `WorkPlansLoaded` (note: plural 's') |
| API Endpoint | `POST /api/v1/schedules` |
| Success Toast | "Rencana kerja berhasil dibuat!" |

---

### 🚨 CRITICAL: What Needs to Be Implemented

**The auto-refresh feature is NOT YET IMPLEMENTED.** Current BLoC code at `work_plan_bloc.dart:69-88`:

```dart
// CURRENT STATE (missing auto-refresh)
Future<void> _onCreateWorkPlanRequested(...) async {
  emit(const WorkPlanLoading());
  final result = await _createWorkPlanUseCase(...);
  result.fold(
    (failure) => emit(WorkPlanError(failure.message)),
    (workPlan) => emit(WorkPlanCreated(workPlan)),  // ❌ No refresh!
  );
}
```

**REQUIRED CHANGE:**

```dart
// REQUIRED IMPLEMENTATION
Future<void> _onCreateWorkPlanRequested(
  CreateWorkPlanRequested event,
  Emitter<WorkPlanState> emit,
) async {
  emit(const WorkPlanLoading());

  final result = await _createWorkPlanUseCase(
    CreateWorkPlanParams(
      workDate: event.workDate,
      pattern: event.pattern,
      shift: event.shift,
      locationId: event.locationId,
      unitId: event.unitId,
      notes: event.notes,
    ),
  );

  result.fold(
    (failure) => emit(WorkPlanError(failure.message)),
    (workPlan) {
      emit(WorkPlanCreated(workPlan));
      add(const LoadWorkPlansRequested());  // ✅ ADD THIS LINE
    },
  );
}
```

---

### ⚠️ State Class Naming (IMPORTANT)

Actual state classes in `work_plan_state.dart`:

| State Class | Purpose | When to Use |
|-------------|---------|-------------|
| `WorkPlansLoaded` | List of work plans | After `LoadWorkPlansRequested` (plural 's') |
| `WorkPlanLoaded` | Single work plan | After `LoadWorkPlanByIdRequested` (no 's') |
| `WorkPlanCreated` | After successful create | Triggers UI success feedback |
| `WorkPlanError` | Any error | Message already in Bahasa Indonesia |

**State Sequence After Create:**
```
WorkPlanInitial/WorkPlansLoaded
    ↓ (user taps Simpan)
WorkPlanLoading
    ↓
WorkPlanCreated (success)
    ↓ (auto-refresh triggered)
WorkPlanLoading
    ↓
WorkPlansLoaded (with new data)  ← Note: plural 's'
```

---

### ✅ Already Implemented (Story 2.2)

The following are **already working** from Story 2.2 - do NOT reimplement:

1. **CreateBottomSheet form** - Complete with validation
2. **BlocConsumer integration** - Listens to state changes
3. **Success/error toast handlers** - Shows SnackBar with correct messages
4. **Loading state UI** - CircularProgressIndicator on button
5. **Enhanced error handling** - Parses 400/422 errors gracefully

**Current CreateBottomSheet listener (line 66-92):**
```dart
BlocConsumer<WorkPlanBloc, WorkPlanState>(
  listener: (context, state) {
    if (state is WorkPlanCreated) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(...success...);
    } else if (state is WorkPlanError) {
      ScaffoldMessenger.of(context).showSnackBar(...error...);
    }
  },
  // ... builder
)
```

---

### ⚠️ BLoC Provider Scope

**Actual pattern in `home_page.dart:45-53`:**

```dart
body: MultiBlocProvider(
  providers: [
    BlocProvider<WeatherBloc>(
      create: (context) => getIt<WeatherBloc>(),
    ),
    BlocProvider<WorkPlanBloc>(
      create: (context) => getIt<WorkPlanBloc>(),  // ✅ Using create, not value
    ),
  ],
  child: BannerWrapper(...),
)
```

**FAB calls CreateBottomSheet at line 77:**
```dart
onPressed: () => CreateBottomSheet.show(context),
```

The `context` passed to `CreateBottomSheet.show()` comes from within the `BlocBuilder<AuthBloc, AuthState>` which is inside `_buildFab`. Since `showModalBottomSheet` uses the root navigator, it inherits from `MaterialApp` context but the BLoC lookup uses the passed `context` which has access to the providers.

**Key Point:** The modal bottom sheet can access `WorkPlanBloc` because it uses `context.read<WorkPlanBloc>()` with the context that was passed from within the widget tree where `MultiBlocProvider` is an ancestor.

---

### 🧪 Testing Strategy

**BLoC Test File Setup (CREATE NEW):**

File: `test/features/work_plan/presentation/bloc/work_plan_bloc_test.dart`

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fstrack_tractor/core/error/failures.dart';
import 'package:fstrack_tractor/features/work_plan/domain/entities/work_plan_entity.dart';
import 'package:fstrack_tractor/features/work_plan/domain/usecases/create_work_plan_usecase.dart';
import 'package:fstrack_tractor/features/work_plan/domain/usecases/get_work_plans_usecase.dart';
// ... other imports

class MockCreateWorkPlanUseCase extends Mock implements CreateWorkPlanUseCase {}
class MockGetWorkPlansUseCase extends Mock implements GetWorkPlansUseCase {}
// ... other mocks

void main() {
  late WorkPlanBloc bloc;
  late MockCreateWorkPlanUseCase mockCreateUseCase;
  late MockGetWorkPlansUseCase mockGetWorkPlansUseCase;
  // ... other mocks

  setUp(() {
    mockCreateUseCase = MockCreateWorkPlanUseCase();
    mockGetWorkPlansUseCase = MockGetWorkPlansUseCase();
    // ... initialize all mocks

    bloc = WorkPlanBloc(
      mockGetWorkPlansUseCase,
      // ... all 5 use cases required by constructor
    );
  });

  group('CreateWorkPlanRequested', () {
    final testWorkPlan = WorkPlanEntity(
      id: '1',
      workDate: DateTime(2026, 2, 3),
      pattern: 'Rotasi',
      shift: 'Pagi',
      locationId: 'AFD01',
      unitId: 'TR01',
      status: 'OPEN',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    blocTest<WorkPlanBloc, WorkPlanState>(
      'emits [Loading, Created, Loading, WorkPlansLoaded] on success with auto-refresh',
      build: () {
        when(() => mockCreateUseCase(any()))
            .thenAnswer((_) async => Right(testWorkPlan));
        when(() => mockGetWorkPlansUseCase())
            .thenAnswer((_) async => Right([testWorkPlan]));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateWorkPlanRequested(
        workDate: DateTime(2026, 2, 3),
        pattern: 'Rotasi',
        shift: 'Pagi',
        locationId: 'AFD01',
        unitId: 'TR01',
      )),
      expect: () => [
        const WorkPlanLoading(),
        WorkPlanCreated(testWorkPlan),
        const WorkPlanLoading(),
        WorkPlansLoaded(workPlans: [testWorkPlan]),
      ],
    );

    blocTest<WorkPlanBloc, WorkPlanState>(
      'emits [Loading, Error] on failure',
      build: () {
        when(() => mockCreateUseCase(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Gagal membuat rencana kerja')));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateWorkPlanRequested(
        workDate: DateTime(2026, 2, 3),
        pattern: 'Rotasi',
        shift: 'Pagi',
        locationId: 'AFD01',
        unitId: 'TR01',
      )),
      expect: () => [
        const WorkPlanLoading(),
        const WorkPlanError('Gagal membuat rencana kerja'),
      ],
    );
  });
}
```

**Widget Test Additions (ADD TO EXISTING):**

File: `test/features/work_plan/presentation/widgets/create_bottom_sheet_test.dart`

Add golden test for loading state:

```dart
testGoldens('golden: loading state renders correctly', (tester) async {
  when(() => mockWorkPlanBloc.state).thenReturn(const WorkPlanLoading());

  await tester.pumpWidgetBuilder(
    createTestWidget(
      bloc: mockWorkPlanBloc,
      child: const CreateBottomSheet(),
    ),
  );

  await screenMatchesGolden(tester, 'create_bottom_sheet_loading');
});
```

---

### Error Messages (Reference)

Error messages dari `Failure.message` sudah dalam Bahasa Indonesia di repository layer. Tidak perlu mapping tambahan di UI kecuali untuk konteks spesifik.

| Scenario | Message |
|----------|---------|
| Network error | "Gagal terhubung ke server. Periksa koneksi internet Anda." |
| Validation error | "Semua field wajib diisi" |
| Unauthorized | "Anda tidak memiliki akses untuk operasi ini" |
| Server error | "Terjadi kesalahan server. Silakan coba lagi." |

---

## Dev Agent Record

### Agent Model Used

kimi-for-coding

### Debug Log References

- Auto-refresh implementation: Added `add(const LoadWorkPlansRequested())` after `emit(WorkPlanCreated(workPlan))` in `_onCreateWorkPlanRequested`
- State sequence verified: Loading → Created → Loading → WorkPlansLoaded
- BLoC tests: 16 tests passed covering all events and states
- Golden tests: Loading state golden file generated successfully

### Completion Notes List

1. **Task 1 - Auto-Refresh Implementation**: Modified `work_plan_bloc.dart` to trigger auto-refresh after successful work plan creation. The implementation adds `add(const LoadWorkPlansRequested())` inside the success callback of `result.fold()`, ensuring the work plan list is automatically refreshed with the new data.

2. **Task 2 - Integration Verification**: Verified that CreateBottomSheet already has proper BlocConsumer integration from Story 2.2. The success handler shows toast "Rencana kerja berhasil dibuat!" and closes the bottom sheet, while the error handler shows appropriate error messages.

3. **Task 3 - BLoC Unit Tests**: Created comprehensive unit tests covering:
   - LoadWorkPlansRequested (success and failure)
   - CreateWorkPlanRequested with auto-refresh verification (success, failure, validation failure)
   - LoadWorkPlanByIdRequested (success, not found)
   - AssignOperatorRequested (success, failure)
   - LoadOperatorsRequested (success, failure)
   - WorkPlanSelected and OperatorSelected state updates
   - WorkPlanReset

4. **Task 4 - Golden Test**: Added loading state golden test to `create_bottom_sheet_test.dart`. The golden file was generated at `test/features/work_plan/presentation/widgets/goldens/create_bottom_sheet_loading.png`.

### File List

**Files Modified/Created:**

| # | Action | File Path | What Was Done |
|---|--------|-----------|---------------|
| 1 | `[MODIFY]` | `lib/features/work_plan/presentation/bloc/work_plan_bloc.dart` | Added `add(const LoadWorkPlansRequested())` after `emit(WorkPlanCreated(workPlan))` in `_onCreateWorkPlanRequested` method to enable auto-refresh |
| 2 | `[CREATE]` | `test/features/work_plan/presentation/bloc/work_plan_bloc_test.dart` | Created comprehensive BLoC unit tests with 16 test cases covering all events, states, and auto-refresh sequence |
| 3 | `[MODIFY]` | `test/features/work_plan/presentation/widgets/create_bottom_sheet_test.dart` | Added loading state golden test using `matchesGoldenFile` with `--update-goldens` flag |
| 4 | `[CREATE]` | `test/features/work_plan/presentation/widgets/goldens/create_bottom_sheet_loading.png` | Generated golden file for loading state verification |
| 5 | `[MODIFY]` | `_bmad-output/implementation-artifacts/sprint-status.yaml` | Updated story status to `review` |

---

## Code Review Record (AI)

**Reviewed by:** Claude Code (Opus 4.5)
**Date:** 2026-02-03

### Review Summary
- **ACs Verified:** 2/2 ✅
- **Tasks Verified:** 4/4 ✅
- **Issues Found:** 0 High, 0 Medium (fixed), 4 Low (documented)

### Issues Fixed During Review
1. **M3 Fixed:** Added `sprint-status.yaml` to File List (documentation completeness)

### Remaining Low Issues (Acceptable)
- L1: `initialValue` parameter usage is correct for Flutter 3.33+ (NOT deprecated as initially thought)
- L2: Minor test readability (acceptable)
- L3: `notes` parameter not tested (optional field, acceptable)
- L4: WorkPlanRepository import used for CreateWorkPlanParams (NOT unused)

### Test Results
| Suite | Count | Status |
|-------|-------|--------|
| BLoC Unit Tests | 16 | ✅ Passed |
| Widget Tests | 12 | ✅ Passed |
| Flutter Analyze | - | ✅ No issues |

---

## Change Log

| Date | Change | Description |
|------|--------|-------------|
| 2026-02-03 | Implementation Complete | Story 2.3 implementation finished with all tasks completed |
| 2026-02-03 | Auto-Refresh Feature | Added `add(const LoadWorkPlansRequested())` to `_onCreateWorkPlanRequested` for automatic list refresh after work plan creation |
| 2026-02-03 | BLoC Tests Created | Created comprehensive unit tests (16 tests) covering all BLoC events and states |
| 2026-02-03 | Golden Test Added | Added loading state golden test with generated golden file |
| 2026-02-03 | Status Updated | Story status changed from `ready-for-dev` to `review` |
| 2026-02-03 | Code Review Complete | Adversarial review passed - all ACs verified, all tasks verified, 0 blocking issues |

**Files to Reference (Read-Only):**

| # | File Path | Why Reference |
|---|-----------|---------------|
| 1 | `work_plan_event.dart` | Verify CreateWorkPlanRequested signature |
| 2 | `work_plan_state.dart` | Verify state class names (WorkPlansLoaded vs WorkPlanLoaded) |
| 3 | `create_work_plan_usecase.dart` | Verify CreateWorkPlanParams structure |
| 4 | `create_bottom_sheet.dart` | Verify existing BlocConsumer implementation |

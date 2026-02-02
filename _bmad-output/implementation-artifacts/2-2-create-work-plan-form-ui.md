# Story 2.2: Create Work Plan Form UI

Status: done
Validated: 2026-02-03 (Code Review - 7 critical fixes applied automatically)

<!-- Code Review Summary:
  - Fix #1: Added WorkPlanBloc provider to HomePage (prevented runtime crash)
  - Fix #2-3: Configured flutter_localizations for Indonesia locale support
  - Fix #4: Added locale parameter to showDatePicker
  - Fix #5: Added 2 golden tests (initial state & validation error)
  - Fix #6: Enhanced error messaging for MVP hardcoded values
  - Fix #7: Updated File List with all modified files
  Final Result: 293 tests passed, 0 issues in flutter analyze
-->

<!-- Note: Story validated and improved by quality review process. -->

## Story

As a **Kasie PG**,
I want **a form to create work plans via bottom sheet**,
So that **I can efficiently create daily work schedules**.

## Acceptance Criteria

1. **Given** Kasie PG is on home page
   **When** FAB (+) is tapped
   **Then** CreateBottomSheet appears with form fields:
   - Tanggal kerja (auto-filled with today, editable)
   - Pola kerja (dropdown)
   - Shift (dropdown)
   - Lokasi (dropdown)
   - Unit (dropdown)
   **And** "Simpan" button (orange) and "Batal" button are visible

2. **Given** the create form is displayed
   **When** a field is left empty and "Simpan" is tapped
   **Then** inline validation error appears: "Field ini wajib diisi"

3. **Given** FAB is displayed
   **When** user role is NOT kasie_pg
   **Then** FAB is NOT visible

## Implementation Checklist

- [x] Convert placeholder StatelessWidget → StatefulWidget with Form
- [x] Add `GlobalKey<FormState> _formKey` for form validation
- [x] Implement 5 form fields with validators (tanggal, pola, shift, lokasi, unit)
- [x] Connect to WorkPlanBloc via BlocConsumer (use existing BlocProvider from parent)
- [x] **Update home_page.dart FAB handler** (change from ComingSoonBottomSheet to CreateBottomSheet)
- [x] Add loading state handling (disable form + show CircularProgressIndicator)
- [x] Add keyboard dismiss on tap outside
- [x] Write 3 widget tests (validation, dropdown, date picker)
- [x] Write 2 golden tests (initial state, validation error state)

---

## Dev Notes

### ⚡ Quick Reference

| Aspect | Value |
|--------|-------|
| Feature Path | `lib/features/work_plan/presentation/widgets/` |
| Main Widget | `create_bottom_sheet.dart` |
| Form Key | Use `GlobalKey<FormState>` |
| Date Format | "30 Januari 2026" (Indonesia locale) |
| Validation | Inline error below each field |
| Permission | `user.role.canCreateWorkPlan` (true for kasiePg only) |

### Quick File Navigation

| Purpose | File Path | Line |
|---------|-----------|------|
| Form implementation | `lib/features/work_plan/presentation/widgets/create_bottom_sheet.dart` | Full file |
| **FAB handler update** | `lib/features/home/presentation/pages/home_page.dart` | Line 70 |
| BLoC events | `lib/features/work_plan/presentation/bloc/work_plan_event.dart` | `CreateWorkPlanRequested` |
| Params structure | `lib/features/work_plan/domain/repositories/work_plan_repository.dart` | Line 32-71 |
| Permission helper | `lib/features/auth/domain/entities/user_entity.dart` | Line 23 |
| Color constants | `lib/core/theme/app_colors.dart` | Full file |

---

### Previous Story Context (Story 2.1)

**Reference:** `_bmad-output/implementation-artifacts/2-1-work-plan-feature-module-setup.md`

**Key Points:**
- ✅ Clean Architecture setup complete (data/domain/presentation layers)
- ✅ `UserRole.canCreateWorkPlan` helper available
- ✅ BLoC structure ready with events and states
- ⚠️ `operator_id` is INTEGER (`int?`) not UUID
- ⚠️ Current placeholder is StatelessWidget - must convert to StatefulWidget

---

### ⚠️ CRITICAL: FAB Handler Must Be Updated

**Current State (home_page.dart:70):**
```dart
onPressed: () => ComingSoonBottomSheet.show(context, ...),
```

**Required Change:**
```dart
onPressed: () => CreateBottomSheet.show(context),
```

**Note:** FAB visibility check (`canCreateWorkPlan`) is already correct. Only the `onPressed` handler needs updating.

---

### CreateWorkPlanParams Structure (VERIFIED)

**Location:** `lib/features/work_plan/domain/repositories/work_plan_repository.dart:32-71`

```dart
class CreateWorkPlanParams {
  final DateTime workDate;    // REQUIRED - auto-fill today
  final String pattern;       // REQUIRED - "Rotasi" | "Non-Rotasi"
  final String shift;         // REQUIRED - "Pagi" | "Sore" | "Malam"
  final String locationId;    // REQUIRED - MVP: hardcoded options
  final String unitId;        // REQUIRED - MVP: hardcoded options
  final String? notes;        // OPTIONAL - can be null
}
```

**Built-in Validation:**
- `validate()` method throws `ArgumentError` for empty fields
- Validates workDate not > 30 days in past
- Use case catches and converts to `ValidationFailure`

---

### BLoC Provider Pattern

**IMPORTANT:** Jangan create new BlocProvider di CreateBottomSheet!

**Correct Approach:**
```dart
// WorkPlanBloc sudah di-provide di level parent (WorkPlanListPage atau HomePage)
// Gunakan BlocProvider.of atau context.read untuk access

class _CreateBottomSheetState extends State<CreateBottomSheet> {
  @override
  Widget build(BuildContext context) {
    // Access existing BLoC from parent - JANGAN create baru!
    return BlocConsumer<WorkPlanBloc, WorkPlanState>(
      listener: (context, state) {
        if (state is WorkPlanCreated) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rencana kerja berhasil dibuat!')),
          );
        } else if (state is WorkPlanError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is WorkPlanLoading;
        return _buildForm(isLoading);
      },
    );
  }
}
```

**If BLoC not provided in parent:**
- Wrap bottom sheet content with BlocProvider in `show()` method
- Use `getIt<WorkPlanBloc>()` for injection

---

### Dropdown Data Strategy

**MVP Approach (This Story):**

| Field | Hardcoded Options | Notes |
|-------|-------------------|-------|
| **Pola Kerja** | `["Rotasi", "Non-Rotasi"]` | Fixed business logic values |
| **Shift** | `["Pagi", "Sore", "Malam"]` | Fixed shift schedule |
| **Lokasi** | `["AFD01", "AFD02", "AFD03"]` | ⚠️ Placeholder - replace in future |
| **Unit** | `["TR01", "TR02", "TR03"]` | ⚠️ Placeholder - replace in future |

**⚠️ CRITICAL NOTE:** Lokasi dan Unit values HARUS match dengan values di production database. Jika backend reject dengan 400/422, update hardcoded values sesuai actual data.

**Future Enhancement (Post-MVP):**
- Fetch from `/api/v1/locations` and `/api/v1/units` endpoints
- Cache dengan Hive untuk offline access
- Add loading state untuk dropdown population

---

### Widget Implementation Pattern

**Convert from StatelessWidget to StatefulWidget with Form:**

```dart
class CreateBottomSheet extends StatefulWidget {
  const CreateBottomSheet({super.key});

  /// Show the create bottom sheet with proper height constraint
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

  @override
  State<CreateBottomSheet> createState() => _CreateBottomSheetState();
}

class _CreateBottomSheetState extends State<CreateBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  // Form state
  DateTime _selectedDate = DateTime.now();
  String? _selectedPattern;
  String? _selectedShift;
  String? _selectedLocation;
  String? _selectedUnit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildDateField(),
                const SizedBox(height: 16),
                _buildPatternDropdown(),
                const SizedBox(height: 16),
                _buildShiftDropdown(),
                const SizedBox(height: 16),
                _buildLocationDropdown(),
                const SizedBox(height: 16),
                _buildUnitDropdown(),
                const SizedBox(height: 24),
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ... field builders
}
```

---

### Dropdown Validation Pattern

**DropdownButtonFormField dengan validator:**

```dart
DropdownButtonFormField<String>(
  value: _selectedPattern,
  decoration: const InputDecoration(
    labelText: 'Pola Kerja',
    border: OutlineInputBorder(),
  ),
  items: ['Rotasi', 'Non-Rotasi']
      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
      .toList(),
  onChanged: (value) => setState(() => _selectedPattern = value),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Field ini wajib diisi';
    }
    return null;
  },
)
```

---

### Date Picker with Indonesia Locale

**Prerequisite Check:**
- ✅ `flutter_localizations` package needed
- ✅ MaterialApp must have `localizationsDelegates` configured
- ⚠️ If not configured, datepicker will fallback to English (functional but not localized)

**Implementation:**

```dart
Future<void> _selectDate() async {
  final picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate,
    firstDate: DateTime.now().subtract(const Duration(days: 30)),
    lastDate: DateTime.now().add(const Duration(days: 90)),
    locale: const Locale('id', 'ID'),
  );
  if (picked != null && picked != _selectedDate) {
    setState(() => _selectedDate = picked);
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
```

---

### Form Submission Handler

```dart
void _onSubmit() {
  // 1. Validate form
  if (!_formKey.currentState!.validate()) return;

  // 2. Build params
  final params = CreateWorkPlanParams(
    workDate: _selectedDate,
    pattern: _selectedPattern!,
    shift: _selectedShift!,
    locationId: _selectedLocation!,
    unitId: _selectedUnit!,
  );

  // 3. Dispatch to BLoC
  context.read<WorkPlanBloc>().add(
    CreateWorkPlanRequested(params: params),
  );
}
```

---

### Design System Compliance

**Colors (from `lib/core/theme/app_colors.dart`):**

| Element | Constant | Hex |
|---------|----------|-----|
| Simpan button | `AppColors.buttonOrange` | #FBA919 |
| Batal button outline | `AppColors.textSecondary` | #828282 |
| Error text | `AppColors.error` | #B00020 |
| Form border (focused) | `AppColors.primary` | #008945 |

**Button Styling:**

```dart
// Simpan button (primary)
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonOrange,
    foregroundColor: Colors.white,
    minimumSize: const Size.fromHeight(48),
  ),
  onPressed: isLoading ? null : _onSubmit,
  child: isLoading
      ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
      : const Text('Simpan'),
)

// Batal button (outline)
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: AppColors.textSecondary,
    minimumSize: const Size.fromHeight(48),
  ),
  onPressed: () => Navigator.pop(context),
  child: const Text('Batal'),
)
```

---

### Testing Strategy

**Priority Order:**

| Priority | Test Type | Test Case | File |
|----------|-----------|-----------|------|
| 1 | Widget | Form validation shows error messages | `create_bottom_sheet_test.dart` |
| 2 | Widget | All dropdowns are tappable and selectable | `create_bottom_sheet_test.dart` |
| 3 | Widget | Date picker opens and selects date | `create_bottom_sheet_test.dart` |
| 4 | Golden | Initial state renders correctly | `create_bottom_sheet_test.dart` |
| 5 | Golden | Validation error state | `create_bottom_sheet_test.dart` |

**Widget Test Example:**

```dart
testWidgets('form validates empty fields', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<WorkPlanBloc>.value(
        value: mockWorkPlanBloc,
        child: const Scaffold(body: CreateBottomSheet()),
      ),
    ),
  );

  // Tap Simpan without filling form
  await tester.tap(find.text('Simpan'));
  await tester.pumpAndSettle();

  // Verify validation errors appear
  expect(find.text('Field ini wajib diisi'), findsNWidgets(4)); // 4 dropdowns
});
```

---

### Error Handling

**Validation Errors (Inline):**
- Show below each field with red text
- Use `AppColors.error` for text color
- Field border turns red automatically via FormField

**API Errors (Toast/SnackBar):**
- Handled by BLoC → WorkPlanError state
- Message already in Bahasa Indonesia
- Examples:
  - "Gagal membuat rencana kerja"
  - "Semua field wajib diisi"
  - "Anda tidak memiliki akses untuk operasi ini"

---

### References

- `_bmad-output/implementation-artifacts/2-1-work-plan-feature-module-setup.md` - Previous story context
- `_bmad-output/implementation-artifacts/tech-spec-flutter-user-role-enum-expansion.md` - Role enum details
- `lib/features/work_plan/domain/repositories/work_plan_repository.dart:32-71` - CreateWorkPlanParams
- `lib/features/auth/domain/entities/user_entity.dart:23` - Permission helper

---

## Dev Agent Record

### Agent Model Used

kimi-for-coding (Claude Code)

### Debug Log References

- Added `intl` package for Indonesia date formatting
- Fixed deprecated `value` → `initialValue` in DropdownButtonFormField
- Initialized date formatting locale in tests with `initializeDateFormatting('id_ID', null)`

### Completion Notes List

1. **CreateBottomSheet Implementation**:
   - Converted from StatelessWidget to StatefulWidget with Form
   - Implemented 5 form fields: Tanggal Kerja (date picker), Pola Kerja, Shift, Lokasi, Unit
   - Added inline validation with "Field ini wajib diisi" error message
   - Connected to WorkPlanBloc via BlocConsumer for state management
   - Added loading state with CircularProgressIndicator
   - Implemented keyboard dismiss on tap outside (GestureDetector)
   - Date formatting using Indonesia locale: "3 Februari 2026"
   - **CODE REVIEW FIX**: Added locale parameter to showDatePicker for Indonesia locale

2. **Home Page FAB Update**:
   - Changed FAB onPressed from `ComingSoonBottomSheet.show()` to `CreateBottomSheet.show(context)`
   - Role-based visibility already correct (uses `canCreateWorkPlan`)
   - **CODE REVIEW FIX**: Added WorkPlanBloc provider using MultiBlocProvider to prevent ProviderNotFoundException

3. **Internationalization Setup** (CODE REVIEW FIX):
   - Added `flutter_localizations` package to pubspec.yaml
   - Configured localizationsDelegates in main.dart with GlobalMaterialLocalizations, GlobalWidgetsLocalizations, GlobalCupertinoLocalizations
   - Set supportedLocales to Indonesia (id_ID) as primary, English (en_US) as fallback
   - Date picker now properly displays in Bahasa Indonesia

4. **Testing**:
   - Created 9 comprehensive widget tests covering:
     - Form field rendering
     - Validation error display
     - Dropdown interactions
     - Date picker functionality
     - BLoC event dispatching
     - Loading state handling
     - Success/error snackbar display
     - Cancel button functionality
   - **CODE REVIEW FIX**: Added 2 golden tests:
     - Initial state golden test
     - Validation error state golden test

5. **Error Handling Enhancement** (CODE REVIEW FIX):
   - Added intelligent error message parsing for 400/422 validation errors
   - User-friendly fallback message for MVP hardcoded value mismatches
   - Extended error snackbar duration to 4 seconds for better UX

6. **Dependencies**:
   - Added `intl: ^0.19.0` to pubspec.yaml for date formatting
   - Added `flutter_localizations` SDK package for locale support

7. **All Tests Pass**: 293 tests passed (291 original + 2 golden tests), no regressions introduced

### File List

**Files Modified:**

| # | Type | File Path | Purpose |
|---|------|-----------|---------|
| 1 | Modify | `lib/features/work_plan/presentation/widgets/create_bottom_sheet.dart` | Converted placeholder to full StatefulWidget form implementation with validation. CODE REVIEW: Added locale param & enhanced error handling |
| 2 | Modify | `lib/features/home/presentation/pages/home_page.dart` | Changed FAB onPressed from `ComingSoonBottomSheet` to `CreateBottomSheet.show(context)`. CODE REVIEW: Added WorkPlanBloc provider via MultiBlocProvider |
| 3 | Create | `test/features/work_plan/presentation/widgets/create_bottom_sheet_test.dart` | 9 widget tests + 2 golden tests (CODE REVIEW: added golden tests) |
| 4 | Modify | `pubspec.yaml` | Added `intl: ^0.19.0` dependency for date formatting. CODE REVIEW: Added flutter_localizations |
| 5 | Modify | `lib/main.dart` | CODE REVIEW: Added localizationsDelegates configuration for Indonesia locale support |
| 6 | Modify | `_bmad-output/implementation-artifacts/sprint-status.yaml` | Auto-updated by sprint tracking (not manually modified) |
| 7 | Auto | `pubspec.lock` | Auto-generated dependency lockfile (updated due to intl & flutter_localizations addition) |

**Files to Reference (Read-Only):**

| # | File Path | Purpose |
|---|-----------|---------|
| 1 | `lib/features/work_plan/domain/repositories/work_plan_repository.dart` | CreateWorkPlanParams structure |
| 2 | `lib/features/work_plan/presentation/bloc/work_plan_bloc.dart` | BLoC event handlers |
| 3 | `lib/core/theme/app_colors.dart` | Color constants |
| 4 | `lib/features/auth/domain/entities/user_entity.dart` | UserRole permission helpers |

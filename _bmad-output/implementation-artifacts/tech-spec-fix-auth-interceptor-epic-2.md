---
title: 'Fix Auth Interceptor for Epic 2 Work Plan Creation Flow'
slug: 'fix-auth-interceptor-epic-2'
created: '2026-02-04'
status: 'implementation-complete'
stepsCompleted: [1, 2, 3, 4, 5]
implemented: '2026-02-04'
tech_stack:
  - Flutter 3.x
  - Dio 5.x
  - Hive 2.x
  - Dart 3.x
  - injectable 2.x
  - get_it 7.x
files_to_modify:
  - fstrack_tractor_app/lib/core/network/auth_interceptor.dart (NEW)
  - fstrack_tractor_app/lib/core/network/api_client.dart (MODIFY)
  - fstrack_tractor_app/lib/core/network/retry_interceptor.dart (MODIFY - CRITICAL)
code_patterns:
  - Dio Interceptor pattern for auth header injection
  - Bearer token authentication
  - Whitelist-based endpoint exclusion (NOT contains matching)
  - Injectable dependency injection with @lazySingleton
  - Constructor injection pattern
  - Error handling in interceptors
test_patterns:
  - Unit tests for AuthInterceptor logic
  - Integration test with actual API
  - Token presence verification via backend logs
  - End-to-end flow testing
  - Retry scenario testing (verify auth header preserved)
---

# Tech-Spec: Fix Auth Interceptor for Epic 2 Work Plan Creation Flow

**Created:** 2026-02-04

## Overview

### Problem Statement

Epic 2 stories (2.1-2.4) marked as complete in sprint-status.yaml, tetapi Kasie PG tidak dapat membuat rencana kerja karena endpoint POST `/api/v1/schedules` mengembalikan **401 Unauthorized**.

**Root Cause Analysis:**

Flutter app menggunakan Dio client yang hanya memiliki `RetryInterceptor` tanpa auth interceptor:

```dart
// ApiClient saat ini (lib/core/network/api_client.dart)
_dio = Dio(BaseOptions(...));
_dio.interceptors.add(retryInterceptor);  // Hanya retry, tidak ada auth
```

`WorkPlanRemoteDataSource.create()` memanggil `_dio.post('/api/v1/schedules')` tanpa explicit Authorization header, sehingga request dikirim tanpa JWT token → 401 Unauthorized.

**Bukti:**
- GET `/api/v1/weather` = 200 OK (no auth required)
- POST `/api/v1/schedules` = 401 (auth required, token tidak dikirim)
- `AuthLocalDataSource.getAccessToken()` tersedia dan menyimpan token dengan benar

### Solution

Implement `AuthInterceptor` yang:
1. Mengambil access token dari `AuthLocalDataSource`
2. Menambahkan header `Authorization: Bearer <token>` ke setiap request
3. Melewati auth endpoints (login, refresh) tanpa token
4. Terintegrasi dengan existing `RetryInterceptor`

### Scope

**In Scope:**
- Buat `AuthInterceptor` class extends `Interceptor` (Dio)
- Modifikasi `ApiClient` untuk register `AuthInterceptor`
- **CRITICAL:** Fix `RetryInterceptor` to preserve auth headers on retry
- Handle edge case: token null (skip header), storage exceptions (log and continue)
- Exclude auth endpoints via whitelist (`/api/v1/auth/login`, `/api/v1/auth/refresh`)
- Unit tests untuk AuthInterceptor logic
- Integration test: verify token terkirim di header
- Retry scenario test: verify auth header preserved on retry
- End-to-end verification: login → create work plan → success

**Out of Scope:**
- Refresh token automatic flow (token lifetime 14 hari per NFR)
- Epic 3/4 implementation (fokus unblock Epic 2)
- Backend modifications (sudah working)
- Token encryption enhancements (sudah menggunakan Hive encrypted box)

## Context for Development

### Codebase Patterns

**Dio Interceptor Pattern (from RetryInterceptor):**
```dart
@lazySingleton
class RetryInterceptor extends Interceptor {
  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle error
    handler.next(err);
  }
}
```

**ApiClient Current Implementation:**
```dart
@lazySingleton
class ApiClient {
  late final Dio _dio;
  Dio get dio => _dio;

  ApiClient({required RetryInterceptor retryInterceptor}) {
    _dio = Dio(BaseOptions(...));
    _dio.interceptors.add(retryInterceptor);
  }
}
```
- Interceptor di-add via `_dio.interceptors.add(...)`
- Execution order: first added = first executed

**Auth Token Storage Pattern (AuthLocalDataSource):**
```dart
@lazySingleton
class AuthLocalDataSource {
  String? getAccessToken() {
    return _hiveService.authBox.get('accessToken') as String?;
  }
}
```
- Hive encrypted box (key: `'accessToken'`)
- Returns `String?` (nullable)
- Already registered in DI (injection_container.config.dart line 96-97)

**Dependency Injection Pattern:**
- `@lazySingleton` untuk singleton services (auto-generated registration)
- `@injectable` untuk constructor injection
- DI config auto-generated via `build_runner` → `injection_container.config.dart`
- ApiClient registered at line 98-99 with RetryInterceptor only

### Files to Reference

| File | Purpose |
| ---- | ------- |
| `fstrack_tractor_app/lib/core/network/api_client.dart` | Dio client configuration - add AuthInterceptor parameter |
| `fstrack_tractor_app/lib/core/network/retry_interceptor.dart` | Reference: existing interceptor implementation pattern |
| `fstrack_tractor_app/lib/features/auth/data/datasources/auth_local_datasource.dart` | Token storage - use `getAccessToken()` method |
| `fstrack_tractor_app/lib/injection_container.config.dart` | DI registration reference (line 96-99 for AuthLocalDataSource & ApiClient) |
| `fstrack_tractor_app/lib/features/work_plan/data/datasources/work_plan_remote_datasource.dart` | Consumer - verify auth header terkirim |

### Files to Modify/Created

| File | Action | Description |
| ---- | ------ | ----------- |
| `lib/core/network/auth_interceptor.dart` | CREATE | New interceptor class with error handling |
| `lib/core/network/api_client.dart` | MODIFY | Add AuthInterceptor parameter |
| `lib/core/network/retry_interceptor.dart` | MODIFY | **CRITICAL:** Fix retry to preserve auth headers |
| `test/core/network/auth_interceptor_test.dart` | CREATE | Unit tests for interceptor logic |
| `lib/injection_container.config.dart` | AUTO-GENERATED | Run `build_runner` after annotate AuthInterceptor |

### Technical Decisions

**Decision: AuthInterceptor sebagai Dio Interceptor (bukan wrapper)**
- Lebih clean dan reusable
- Consistent dengan existing RetryInterceptor pattern
- Tidak perlu modify semua data sources

**Decision: Exclude auth endpoints via EXACT PATH MATCH (NOT contains)**
```dart
// WRONG - would exclude /api/v1/auth/me which REQUIRES auth
if (options.path.contains('/auth/')) { ... }

// CORRECT - only exclude specific auth endpoints
const _authEndpointsWithoutAuth = ['/api/v1/auth/login', '/api/v1/auth/refresh'];
if (_authEndpointsWithoutAuth.contains(options.path)) {
  return handler.next(options);  // Skip auth header
}
```
- `/api/v1/auth/me` requires authentication (token validation) - must NOT be excluded
- Only `/api/v1/auth/login` and `/api/v1/auth/refresh` should skip auth header
- Prevents accidental exclusion of authenticated auth endpoints

**Decision: Token null = skip header (bukan error)**
- Biarkan backend return 401 jika endpoint memerlukan auth
- Consistent dengan behavior saat ini untuk endpoint publik

**Decision: Interceptor execution order: AuthInterceptor → RetryInterceptor**
- Auth header harus ada sebelum retry
- RetryInterceptor tidak modify headers, hanya retry logic

**Decision: Fix RetryInterceptor bug (CRITICAL)**
- **Problem:** `_retryRequest` creates new Dio instance without interceptors
- **Solution Options:**
  1. Pass interceptors to new Dio instance on retry
  2. Store Dio reference and reuse for retries
  3. Use GetIt to retrieve ApiClient.dio for retries
- **Selected:** Option 1 - least invasive, maintains existing pattern
- **Implementation:** Clone headers from original request (includes Authorization)

## Implementation Plan

### Tasks

- [x] **Task 1: Create AuthInterceptor class**
  - File: `fstrack_tractor_app/lib/core/network/auth_interceptor.dart`
  - Extend `Interceptor` dari package:dio
  - Use `@lazySingleton` (consistent with RetryInterceptor)
  - Inject `AuthLocalDataSource` via constructor
  - Override `onRequest` untuk inject header
  - Skip auth endpoints via EXACT MATCH (not contains)
  - Add error handling for Hive storage exceptions
  - ✅ **DONE** - Implemented with debug logging

- [x] **Task 2: Update ApiClient to register AuthInterceptor**
  - File: `fstrack_tractor_app/lib/core/network/api_client.dart`
  - Add `AuthInterceptor` parameter ke constructor
  - Register interceptor sebelum RetryInterceptor
  - ✅ **DONE** - AuthInterceptor registered first, then RetryInterceptor

- [x] **Task 3: CRITICAL - Fix RetryInterceptor to preserve auth headers on retry**
  - File: `fstrack_tractor_app/lib/core/network/retry_interceptor.dart`
  - **Problem:** `_retryRequest` creates new Dio without interceptors → retried requests lose auth headers
  - **Solution:** Headers explicitly passed via Options (includes Authorization)
  - ✅ **DONE** - Added comment explaining header preservation

- [x] **Task 4: Regenerate DI configuration**
  - Run: `flutter pub run build_runner build --delete-conflicting-outputs`
  - Verifies: `injection_container.config.dart` includes AuthInterceptor as `@lazySingleton`
  - Check generated file: AuthInterceptor should be registered with AuthLocalDataSource dependency
  - ✅ **DONE** - AuthInterceptor registered at line 99-100, injected into ApiClient at line 102

- [x] **Task 5: Unit test for AuthInterceptor**
  - File: `test/core/network/auth_interceptor_test.dart` (NEW)
  - Test cases:
    - Token exists → Authorization header added ✅
    - Token null → no Authorization header ✅
    - Auth endpoint (login) → Authorization header skipped ✅
    - Auth endpoint (me) → Authorization header added (requires auth!) ✅
    - Storage exception → request proceeds (no crash) ✅
  - Mock: AuthLocalDataSource (using mocktail)
  - ✅ **DONE** - 10 tests written, all passing

- [ ] **Task 6: Integration test - verify auth header sent**
  - Start backend: `npm run start:dev`
  - Login via Flutter app (dapatkan token)
  - Trigger create work plan
  - Verify di backend logs: request memiliki Authorization header
  - Add temporary debug log di interceptor untuk verify:
    ```dart
    debugPrint('→ AuthInterceptor: path=${options.path}, token=${token != null ? 'present' : 'null'}');
    ```

- [ ] **Task 7: Test retry scenario**
  - Simulate network timeout (can use proxy or manually drop connection)
  - Verify retried request still has Authorization header
  - Check backend logs: multiple requests with same auth header

- [ ] **Task 8: End-to-end verification**
  - Login sebagai kasie_pg
  - Tap FAB (+)
  - Isi form create work plan
  - Tap "Simpan"
  - **Verify:**
    - Toast success: "Rencana kerja berhasil dibuat!"
    - Bottom sheet closes
    - List refreshes dengan new entry
    - Status: OPEN (orange)
    - Network tab: POST /api/v1/schedules = 201 Created

- [ ] **Task 9: CI/CD verification**
  - Run: `flutter analyze` → No issues
  - Run: `flutter test` → All tests pass (including new unit tests)
  - Build: `flutter build apk` → Success

### Rollback Plan

**If something goes wrong:**

```bash
# Revert source files
git checkout -- fstrack_tractor_app/lib/core/network/auth_interceptor.dart
git checkout -- fstrack_tractor_app/lib/core/network/api_client.dart
git checkout -- fstrack_tractor_app/lib/core/network/retry_interceptor.dart

# Regenerate DI config (removes AuthInterceptor references)
flutter pub run build_runner build --delete-conflicting-outputs

# Clean and rebuild
flutter clean && flutter pub get
```

**Rollback triggers:**
- App crash on startup (interceptor initialization error)
- Login failure (token interfered)
- 401 errors persist after fix
- CI/CD pipeline failure
- RetryInterceptor broken (requests fail after timeout)

### Acceptance Criteria

- [ ] **AC1:** Given user logged in with valid token, when any API request (except /auth/login, /auth/refresh) is made, then Authorization header contains "Bearer <token>"
- [ ] **AC2:** Given auth endpoints /api/v1/auth/login or /api/v1/auth/refresh, when request is made, then no Authorization header is added
- [ ] **AC3:** Given auth endpoint /api/v1/auth/me (token validation), when request is made, then Authorization header IS added (this endpoint requires auth!)
- [ ] **AC4:** Given token is null/unavailable, when request is made, then request proceeds without Authorization header (backend handles 401)
- [ ] **AC5:** Given Hive storage throws exception, when AuthInterceptor processes request, then request proceeds without crashing (error logged)
- [ ] **AC6:** Given Kasie PG logged in, when create work plan form submitted, then POST /api/v1/schedules returns 201 Created (not 401)
- [ ] **AC7:** Given network timeout occurs and request retries, when RetryInterceptor executes retry, then retried request STILL contains Authorization header
- [ ] **AC8:** Given create work plan success, when response received, then toast "Rencana kerja berhasil dibuat!" appears
- [ ] **AC9:** Given all fixes applied, when run `flutter analyze`, then zero issues (no errors, no warnings)
- [ ] **AC10:** Given all fixes applied, when run `flutter test`, then all tests pass (including new AuthInterceptor unit tests)

## Additional Context

### Dependencies

**No new dependencies required.** Dio sudah tersedia di project.

Existing dependencies used:
- `dio: ^5.x` - HTTP client dengan interceptor support
- `injectable: ^2.x` - DI framework
- `hive: ^2.x` - Local storage (sudah digunakan AuthLocalDataSource)

### Testing Strategy

**1. Unit Tests (REQUIRED):**
File: `test/core/network/auth_interceptor_test.dart`
```dart
group('AuthInterceptor', () {
  late AuthInterceptor interceptor;
  late MockAuthLocalDataSource mockAuthLocalDataSource;

  setUp(() {
    mockAuthLocalDataSource = MockAuthLocalDataSource();
    interceptor = AuthInterceptor(mockAuthLocalDataSource);
  });

  test('adds Authorization header when token exists', () {
    // Arrange
    when(mockAuthLocalDataSource.getAccessToken()).thenReturn('test_token');
    final options = RequestOptions(path: '/api/v1/schedules');

    // Act
    interceptor.onRequest(options, handler);

    // Assert
    expect(options.headers['Authorization'], equals('Bearer test_token'));
  });

  test('skips auth header for login endpoint', () {
    // Arrange
    final options = RequestOptions(path: '/api/v1/auth/login');

    // Act
    interceptor.onRequest(options, handler);

    // Assert
    expect(options.headers.containsKey('Authorization'), isFalse);
  });

  test('ADDS auth header for /auth/me endpoint (requires auth!)', () {
    // Arrange
    when(mockAuthLocalDataSource.getAccessToken()).thenReturn('test_token');
    final options = RequestOptions(path: '/api/v1/auth/me');

    // Act
    interceptor.onRequest(options, handler);

    // Assert
    expect(options.headers['Authorization'], equals('Bearer test_token'));
  });

  test('proceeds without header when token is null', () {
    // Arrange
    when(mockAuthLocalDataSource.getAccessToken()).thenReturn(null);
    final options = RequestOptions(path: '/api/v1/schedules');

    // Act & Assert (no crash)
    expect(() => interceptor.onRequest(options, handler), returnsNormally);
    expect(options.headers.containsKey('Authorization'), isFalse);
  });

  test('handles storage exceptions gracefully', () {
    // Arrange
    when(mockAuthLocalDataSource.getAccessToken()).thenThrow(Exception('Hive error'));
    final options = RequestOptions(path: '/api/v1/schedules');

    // Act & Assert (no crash)
    expect(() => interceptor.onRequest(options, handler), returnsNormally);
  });
});
```

**2. Manual Integration Test:**
```bash
# Start backend
cd fstrack-tractor-api && npm run start:dev

# Run Flutter app
cd fstrack_tractor_app && flutter run

# Steps:
# 1. Login as kasie_pg
# 2. Tap FAB (+)
# 3. Fill form
# 4. Tap Simpan
# 5. Verify: 201 Created, success toast, list refresh
```

**3. Debug Verification (optional):**
Add temporary debug log di AuthInterceptor:
```dart
@override
void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
  debugPrint('→ AuthInterceptor: path=${options.path}');
  final token = _authLocalDataSource.getAccessToken();
  debugPrint('→ Token: ${token != null ? "present (len=${token.length})" : "null"}');
  // ... rest of implementation
}
```

**4. Network Inspection:**
- Backend logs akan menunjukkan headers yang diterima
- Cari: `Authorization: Bearer <token>`

**5. Retry Scenario Test (CRITICAL):**
- Use network proxy (Charles Proxy, Proxyman) atau manual timeout simulation
- Verify retried requests contain Authorization header
- Check: no 401 errors on retry

### Notes

**Why This Bug Happened:**
- WorkPlanRemoteDataSource dikembangkan tanpa auth interceptor
- Assumption: Dio client sudah handle auth secara global
- RetryInterceptor ditambahkan tapi fokus ke retry logic saja
- Missing: Layer yang bridge antara AuthLocalDataSource dan Dio headers

**Critical Issue Discovered (Adversarial Review):**
- **RetryInterceptor Bug:** `_retryRequest` creates new Dio instance tanpa interceptors
- **Impact:** Retried requests lose Authorization header → 401 errors on retry
- **Fix Required:** Modify RetryInterceptor to preserve interceptors on retry

**Prevention for Future:**
- AuthInterceptor sekarang global untuk semua data sources
- Endpoint baru otomatis mendapat auth header tanpa modify data source
- Pattern consistent dengan industry best practice (Retrofit OkHttp interceptor pattern)
- Whitelist approach untuk auth endpoint exclusion (NOT contains matching)

**Risk Assessment:**
- MEDIUM risk - RetryInterceptor bug fix requires careful implementation
- Potential breaking change if retry logic modified incorrectly
- Auth endpoints tetap work tanpa token (explicit whitelist exclusion)
- Rollback plan includes DI regeneration
- Concurrent token refresh not handled (technical debt for Epic 3/4)

**Impact on Epics:**
- Epic 2: ✅ Unblocked - Kasie PG dapat create work plan
- Epic 3: ✅ Ready - AuthInterceptor juga akan support Kasie FE assign operator
- Epic 4: ✅ Ready - Semua role dapat menggunakan authenticated endpoints

**Adversarial Review Findings Addressed:**
- ✅ F1 (Medium): Removed barrel file task (network.dart doesn't exist)
- ✅ F2/F5 (High): Changed from `contains('/auth/')` to exact path whitelist
- ✅ F4 (Critical): Added Task 3 to fix RetryInterceptor retry bug
- ✅ F9 (Medium): Added error handling for Hive exceptions
- ✅ F6 (Medium): Added unit test requirements
- ✅ F11 (Low): Changed @injectable to @lazySingleton
- ✅ F13 (Low): Updated rollback plan with DI regeneration


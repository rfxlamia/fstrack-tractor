---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7]
inputDocuments:
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/ux-design-specification.md
  - docs/fastrack-tractor-dashboard.md
workflowType: 'architecture'
project_name: 'fstrack-tractor'
user_name: 'V'
date: '2026-01-10'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:**
37 FRs diorganisasi dalam 8 kategori, dengan fokus utama pada:
- Authentication flow (login, logout, session management)
- Role-based UI display (hybrid card layout)
- Offline resilience (JWT cache, weather cache, retry mechanism)
- First-time user experience (onboarding, is_first_time flag)

**Non-Functional Requirements:**
38 NFRs yang akan drive architectural decisions:
- Performance: < 3 detik load time, 4G low-signal baseline
- Security: JWT 14 hari, bcrypt, HTTPS, rate limiting
- Reliability: 99% uptime, graceful degradation
- Scalability: 30 → ratusan users

**Scale & Complexity:**
- Primary domain: Mobile-first (Flutter Android) + REST API (NestJS)
- Complexity level: Low-Medium (MVP scope)
- Estimated architectural components: 15-20

### User Value Hierarchy

*Prioritized by architectural attention required:*

| Priority | Category | User Value | Architectural Weight |
|----------|----------|------------|---------------------|
| **P0** | Login Flow | Table stakes - harus flawless | High - security, offline, UX |
| **P0** | Role-based UI | Diferensiator dari paper system | Medium - feature flags per role |
| **P1** | Offline Support | Make-or-break untuk field adoption | High - caching, sync, state |
| **P1** | Weather Widget | Contextual value untuk planning | Low - adapter pattern, graceful fallback |
| **P2** | First-time UX | Onboarding tanpa training | Low - is_first_time flag |

**Design Philosophy:** Design for 30 users, ready for 300, aspirational for 3000.

### Technical Constraints & Dependencies

| Constraint | Detail |
|------------|--------|
| **Platform** | Android only (MVP), Flutter framework |
| **Backend** | NestJS + PostgreSQL |
| **Authentication** | JWT + bcrypt (no biometric for MVP) |
| **Weather API** | Free tier TBD → Company API future |
| **Distribution** | APK direct install (bypass Play Store) |
| **Offline Support** | JWT cache 14 hari, weather cache 30 menit |

### Architectural Decisions Preview

*Key decisions yang akan di-elaborate di steps selanjutnya:*

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **JWT Duration** | 14 hari + 24 jam grace period | Field workers, low signal, offline-first |
| **Token Validation** | Local + Server hybrid | Grace period requires local validation capability |
| **Weather API** | Adapter pattern interface | Swappable: Free API → Company AWS/satellite |
| **Multi-tenancy** | Schema ready, MVP single-tenant | estate_id in schema, single assignment per user |
| **State Management** | BLoC pattern | Consistency dengan Bulldozer reference app |
| **Feature Flags** | Role-based UI elements | FAB visibility, action buttons per role |

### Cross-Cutting Concerns Identified

**1. Authentication & Authorization**
- JWT token management across all API calls
- Role extraction from JWT payload
- Session expiry handling dengan 24 jam grace period
- **Stateful requirement:** Rate limiting 5 attempts/15 menit per username

**2. Offline Resilience**
- Caching strategy: JWT (14 hari), User Profile (sampai logout), Weather (30 menit)
- Queue mechanism untuk sync saat reconnect
- Explicit offline indicator dengan retry action

**3. Error Handling**
- Graceful degradation untuk external dependencies
- User-friendly messages in Bahasa Indonesia
- Structured logging untuk debugging

**4. State Management Scope**
- **Auth State:** JWT token, user profile, role, is_first_time
- **Connectivity State:** Online/offline status, last sync time, pending queue
- **Loading State:** Per-component skeleton states, not global blocking
- **UI State:** Role-based feature visibility, bottom sheet state

**5. Design System Consistency**
- Material Design 3 foundation
- Bulldozer color tokens exact match
- Bundled Poppins font untuk offline

### Testability Considerations

*Architectural decisions yang affect testing strategy:*

| Concern | Testing Challenge | Architectural Support Needed |
|---------|-------------------|------------------------------|
| **JWT 14 hari expiry** | Time manipulation untuk expiry scenarios | Clock abstraction / time provider |
| **24 jam grace period** | Edge case testing | Configurable grace period duration |
| **Weather API** | External dependency isolation | Adapter interface untuk mocking |
| **Offline mode** | Integration test complexity | Connectivity provider abstraction |
| **Rate limiting** | Stateful behavior testing | Resettable rate limit store |
| **Role-based UI** | All 6 role variations | Test fixtures per role |
| **Skeleton loading** | Loading state verification | Explicit loading state exposure |

**Testing Architecture Principles:**
- All external dependencies behind interfaces (mockable)
- Time-dependent logic uses injectable clock
- State accessible untuk assertion
- Feature flags testable in isolation

## Starter Template Evaluation

### Primary Technology Domain

**Mobile-first (Flutter Android) + REST API (NestJS)** - dual-stack project requiring coordinated architecture decisions.

### Starter Options Considered

#### Flutter Frontend

| Option | Verdict | Rationale |
|--------|---------|-----------|
| Very Good CLI | Not selected | Over-engineered untuk learning curve |
| flutter create + manual setup | **Selected** | Full control, Clean Architecture |
| Community boilerplates | Not selected | Dependency debt risk |

#### NestJS Backend

| Option | Verdict | Rationale |
|--------|---------|-----------|
| nest new + manual modules | **Selected** | Clean baseline, exactly what needed |
| Community boilerplates | Not selected | Outdated dependencies risk |

### Selected Starters

#### 1. Flutter App - Clean Architecture + BLoC

**Initialization Commands:**

```bash
# Create project
flutter create --org com.fstrack --project-name fstrack_tractor fstrack_tractor_app
cd fstrack_tractor_app

# Core dependencies
flutter pub add flutter_bloc equatable get_it injectable dio dartz
flutter pub add shared_preferences connectivity_plus

# Dev dependencies
flutter pub add --dev build_runner injectable_generator bloc_test mocktail golden_toolkit
```

**Architecture Pattern:** Clean Architecture with mandatory data/domain/presentation layers per feature.

**Dependency Injection:** get_it + injectable (codegen via build_runner)

#### 2. NestJS Backend - Modular REST API

**Initialization Commands:**

```bash
# Create project
npm i -g @nestjs/cli
nest new fstrack-tractor-api
cd fstrack-tractor-api

# Core dependencies
npm install @nestjs/typeorm typeorm pg
npm install @nestjs/passport @nestjs/jwt passport passport-jwt bcrypt
npm install class-validator class-transformer

# Dev dependencies
npm install --save-dev @types/passport-jwt @types/bcrypt
npm install --save-dev @sinonjs/fake-timers @types/sinonjs__fake-timers
```

**Architecture Pattern:** Modular with feature-based modules.

### Architectural Decisions Provided by Starters

| Category | Flutter | NestJS |
|----------|---------|--------|
| **Language** | Dart 3.x (null safety) | TypeScript 5.x (strict) |
| **State/Pattern** | BLoC + Clean Architecture | Modular + DI |
| **DI** | get_it + injectable | Built-in NestJS DI |
| **Testing** | bloc_test, mocktail, golden_toolkit | Jest + fake-timers |
| **HTTP Client** | Dio | Axios (via NestJS HttpModule) |

### Testing Infrastructure

**Flutter:**
- `bloc_test` for BLoC unit tests
- `mocktail` for mocking
- `golden_toolkit` for visual regression tests
- Test fixtures in `/test/fixtures/`

**NestJS:**
- Jest (default)
- `@sinonjs/fake-timers` for JWT expiry testing
- Test fixtures in `/test/fixtures/`

### Project Context Documentation

**Created:** `project-context.md` at project root containing:
- Architecture patterns and rules
- Design system tokens (Bulldozer alignment)
- Testing requirements
- Code standards
- Critical rules for AI agents

**Note:** All AI agents MUST read `project-context.md` before implementing any code.

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
- ✅ Local Storage: Hive (type-safe, encrypted for JWT)
- ✅ Weather API: OpenWeatherMap (free tier, 60 calls/min)
- ✅ JWT Storage: Hive encrypted box + flutter_secure_storage
- ✅ Rate Limiting: @nestjs/throttler (per-username)
- ✅ Navigation: go_router (declarative routing)

**Important Decisions (Shape Architecture):**
- ✅ API Documentation: Swagger via @nestjs/swagger
- ✅ Skeleton Loading: shimmer package
- ✅ Image Caching: cached_network_image

**Infrastructure Decisions:**
- ✅ MVP Hosting: Railway (free, easy)
- ✅ Production Hosting: Company Private AWS
- ✅ CI/CD: GitHub Actions
- ✅ APK Distribution: Manual (MVP), Firebase/MDM (future)

### Data Architecture

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Flutter Local Storage** | Hive + hive_flutter | Type-safe, fast, encrypted box support |
| **NestJS ORM** | TypeORM | Stable, well-documented |
| **Migrations** | TypeORM migrations only | No auto-sync, version controlled |
| **JWT Storage** | Hive encrypted + flutter_secure_storage | AES-256 encryption |
| **Weather Cache** | Hive box | 30 min TTL, type-safe |

### Authentication & Security

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Password Hashing** | bcrypt (cost 10) | Balance security/performance |
| **Token Duration** | 14 days + 24h grace | Offline-first field workers |
| **Rate Limiting** | 5 attempts/15 min per username | Prevent brute force |
| **HTTPS** | Mandatory | PRD requirement |
| **Helmet** | Enabled | Security headers |

### API & Communication Patterns

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **API Style** | REST with /api/v1 prefix | Simple, versioned |
| **Documentation** | Swagger (@nestjs/swagger) | Auto-generated |
| **Weather API** | OpenWeatherMap | 60 calls/min free, reliable |
| **Error Format** | Structured JSON (Bahasa Indonesia) | User-friendly |
| **API Key Management** | Backend proxy (don't expose to client) | Security best practice |

### Frontend Architecture

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **State Management** | BLoC | PRD requirement, Bulldozer alignment |
| **Navigation** | go_router | Declarative, deep linking ready |
| **Connectivity** | connectivity_plus (stream) | Reactive offline detection |
| **Skeleton Loading** | shimmer | Per-component, UX spec aligned |
| **Images** | cached_network_image | Standard caching |

### Infrastructure & Deployment

| Decision | MVP | Production |
|----------|-----|------------|
| **Backend Hosting** | Railway (free) | Company AWS |
| **Database** | Railway PostgreSQL | AWS RDS |
| **CI/CD** | GitHub Actions | AWS Pipeline |
| **APK Distribution** | Manual share | Firebase/MDM |
| **Monitoring** | Railway logs | AWS CloudWatch |

### Updated Flutter Dependencies (Enhanced by Party Mode)

```bash
# Create project
flutter create --org com.fstrack --project-name fstrack_tractor fstrack_tractor_app
cd fstrack_tractor_app

# Core dependencies
flutter pub add hive hive_flutter flutter_bloc equatable get_it injectable dio dartz
flutter pub add flutter_secure_storage connectivity_plus go_router shimmer cached_network_image

# Dev dependencies
flutter pub add --dev build_runner injectable_generator hive_generator bloc_test mocktail golden_toolkit
```

### Hive Initialization Sequence

**Startup flow (MUST follow this order):**

```dart
// 1. Get/generate encryption key from flutter_secure_storage
final secureStorage = FlutterSecureStorage();
String? encryptionKey = await secureStorage.read(key: 'hive_key');
if (encryptionKey == null) {
  final key = Hive.generateSecureKey();
  await secureStorage.write(key: 'hive_key', value: base64UrlEncode(key));
  encryptionKey = base64UrlEncode(key);
}

// 2. Initialize Hive
await Hive.initFlutter();

// 3. Register adapters
Hive.registerAdapter(UserModelAdapter());
Hive.registerAdapter(WeatherCacheAdapter());

// 4. Open encrypted boxes
final encryptionKeyBytes = base64Url.decode(encryptionKey);
await Hive.openBox('auth', encryptionCipher: HiveAesCipher(encryptionKeyBytes));
await Hive.openBox('weather_cache');

// 5. Proceed with app initialization
```

### go_router + BLoC Auth Redirect Pattern

```dart
final router = GoRouter(
  refreshListenable: authBloc.stream.asBroadcastStream(),
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isLoggedIn = authState is AuthAuthenticated;
    final isLoggingIn = state.matchedLocation == '/login';
    final isOnboarding = state.matchedLocation == '/onboarding';

    // Not logged in, redirect to login
    if (!isLoggedIn && !isLoggingIn) return '/login';

    // Logged in but on login page, redirect to home
    if (isLoggedIn && isLoggingIn) {
      // Check first-time user
      final user = (authState as AuthAuthenticated).user;
      if (user.isFirstTime) return '/onboarding';
      return '/home';
    }

    return null; // No redirect
  },
  routes: [...],
);
```

### Page Transition Patterns

| Navigation Type | Transition | Duration |
|----------------|------------|----------|
| **Page push** | Slide from right | 300ms |
| **Modal/Bottom sheet** | Slide from bottom | 250ms |
| **Auth redirects** | No animation | Instant |
| **Tab switch** | Fade | 200ms |

### Connectivity Debounce Strategy

```dart
// Don't flash offline/online rapidly
class ConnectivityService {
  final _debouncer = Debouncer(duration: Duration(seconds: 2));

  void onConnectivityChanged(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      // Delay showing offline banner
      _debouncer.run(() => emit(ConnectivityOffline()));
    } else {
      // Immediately show online (cancel any pending offline)
      _debouncer.cancel();
      emit(ConnectivityOnline());
    }
  }
}
```

### Weather API Timeout Handling

| Scenario | Timeout | Behavior |
|----------|---------|----------|
| **API call** | 5 seconds | Show cached data |
| **Skeleton loading** | Max 5 seconds | Then show fallback |
| **No cache available** | After timeout | "Cuaca tidak tersedia" |

### Testing Helpers

**Hive Test Initialization:**

```dart
// test/helpers/test_helpers.dart
Future<void> initHiveForTesting() async {
  final tempDir = await Directory.systemTemp.createTemp();
  Hive.init(tempDir.path);
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(WeatherCacheAdapter());
}

Future<void> cleanupHiveForTesting() async {
  await Hive.deleteFromDisk();
}
```

### Weather Repository Interface-First Pattern

```dart
// domain/repositories/weather_repository.dart
abstract class WeatherRepository {
  Future<Either<Failure, Weather>> getCurrentWeather(String estateId);
  Future<Weather?> getCachedWeather(String estateId);
  Future<void> cacheWeather(String estateId, Weather weather);
}

// data/repositories/weather_repository_impl.dart
@Injectable(as: WeatherRepository)
class WeatherRepositoryImpl implements WeatherRepository {
  final OpenWeatherMapDataSource _remoteDataSource;
  final WeatherLocalDataSource _localDataSource;
  // ...implementation
}

// For testing
class MockWeatherRepository extends Mock implements WeatherRepository {}
```

### Decision Impact Analysis

**Implementation Sequence:**
1. Project initialization (Flutter + NestJS starters)
2. Hive setup with encryption (follow initialization sequence)
3. Core infrastructure (DI, routing, connectivity)
4. Authentication module (JWT, bcrypt, rate limiting)
5. Weather integration (OpenWeatherMap with repository pattern)
6. Main page features (greeting, weather widget, menu cards)
7. Offline resilience (caching, connectivity handling)
8. Testing & deployment pipeline

**Cross-Component Dependencies:**
- flutter_secure_storage → Hive encryption key → Hive boxes → All cached data
- go_router ← AuthBloc.stream → Auth redirects → Protected routes
- OpenWeatherMap → WeatherRepository → WeatherBloc → WeatherWidget
- connectivity_plus → ConnectivityService → OfflineBanner + API retry logic

## Implementation Patterns & Consistency Rules

### Pattern Categories Defined

**Critical Conflict Points Identified:** 15 areas where AI agents could make different choices - all now standardized.

### Naming Patterns

#### Database Naming (PostgreSQL)

| Element | Convention | Example |
|---------|------------|---------|
| **Tables** | snake_case, plural | `users`, `work_plans`, `weather_cache` |
| **Columns** | snake_case | `user_id`, `created_at`, `is_first_time` |
| **Foreign Keys** | referenced_table + `_id` | `user_id`, `estate_id` |
| **Indexes** | `idx_` + table + column | `idx_users_username` |
| **Constraints** | type_prefix + table + column | `pk_users`, `uq_users_username` |

#### API Naming (NestJS REST)

| Element | Convention | Example |
|---------|------------|---------|
| **Endpoints** | Plural, kebab-case | `/api/v1/users`, `/api/v1/work-plans` |
| **Route params** | `:paramName` | `/users/:id` |
| **Query params** | camelCase | `?page=1&limit=10` |
| **Response fields** | camelCase | `{ "userId": 1, "isFirstTime": true }` |

#### Code Naming (Flutter/Dart)

| Element | Convention | Example |
|---------|------------|---------|
| **Files** | snake_case | `auth_bloc.dart`, `user_model.dart` |
| **Classes** | PascalCase | `AuthBloc`, `UserModel` |
| **Functions** | camelCase | `getCurrentUser()` |
| **Variables** | camelCase | `isLoading`, `currentUser` |
| **Constants** | camelCase | `apiBaseUrl` |
| **Private members** | `_prefix` | `_repository` |
| **BLoC Events** | PascalCase + verb | `LoginRequested`, `LogoutPressed` |
| **BLoC States** | PascalCase | `AuthInitial`, `AuthLoading` |

#### Code Naming (NestJS/TypeScript)

| Element | Convention | Example |
|---------|------------|---------|
| **Files** | kebab-case | `auth.service.ts` |
| **Classes** | PascalCase | `AuthService` |
| **Functions** | camelCase | `validateUser()` |
| **Constants** | UPPER_SNAKE | `JWT_SECRET` |
| **DTOs** | PascalCase + Dto | `LoginDto`, `CreateUserDto` |

#### Widget Naming (Flutter)

| Type | Convention | Example |
|------|------------|---------|
| **Pages** | `*Page` | `LoginPage`, `HomePage` |
| **Widgets** | Descriptive name | `WeatherWidget`, `TaskCard` |
| **Screen** | ❌ AVOID | Use `Page` instead |

### Structure Patterns

#### Import Ordering (Flutter/Dart)

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter SDK
import 'package:flutter/material.dart';

// 3. External packages (alphabetical)
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 4. Project imports (relative, feature-first)
import '../../core/network/api_client.dart';
import '../domain/entities/user.dart';
```

#### Barrel Files

Each feature MUST have a barrel file for public APIs:

```dart
// features/auth/auth.dart
export 'domain/entities/user.dart';
export 'presentation/bloc/auth_bloc.dart';
export 'presentation/pages/login_page.dart';
```

#### Test File Location

| Stack | Convention | Example |
|-------|------------|---------|
| **Flutter** | `/test/` mirroring `/lib/` | `test/features/auth/auth_bloc_test.dart` |
| **NestJS** | Co-located `*.spec.ts` | `src/auth/auth.service.spec.ts` |

### Clean Architecture Patterns

#### Entity vs Model Distinction

| Layer | Suffix | Purpose | Example |
|-------|--------|---------|---------|
| **Domain** | `Entity` | Business logic | `UserEntity` |
| **Data** | `Model` | JSON serialization | `UserModel` |

`Model` extends/maps to `Entity`. Only `Model` has `fromJson`/`toJson`.

#### Repository Method Naming

```dart
// STANDARD VERBS - Use these consistently
abstract class UserRepository {
  Future<Either<Failure, User>> getById(String id);
  Future<Either<Failure, User>> getByUsername(String username);
  Future<Either<Failure, List<User>>> getAll();
  Future<Either<Failure, User>> create(UserEntity user);
  Future<Either<Failure, User>> update(String id, UserEntity user);
  Future<Either<Failure, void>> delete(String id);
}

// ❌ AVOID: fetch, load, retrieve, find (use 'get' instead)
```

#### UseCase Naming

```dart
// Pattern: VerbNounUseCase
class LoginUserUseCase { ... }
class GetCurrentWeatherUseCase { ... }
class ValidateTokenUseCase { ... }
class RefreshAuthTokenUseCase { ... }
```

#### Standardized Failure Types

```dart
abstract class Failure {
  String get message;
}

class ServerFailure extends Failure {
  @override final String message;
  ServerFailure(this.message);
}

class CacheFailure extends Failure {
  @override final String message;
  CacheFailure(this.message);
}

class NetworkFailure extends Failure {
  @override String get message => 'Tidak dapat terhubung ke server';
}

class AuthFailure extends Failure {
  @override final String message;
  AuthFailure(this.message);
}

class ValidationFailure extends Failure {
  final Map<String, String> errors;
  ValidationFailure(this.errors);
  @override String get message => errors.values.first;
}
```

### Format Patterns

#### API Response Format

```typescript
// Success response
{
  "statusCode": 200,
  "message": "Login berhasil",
  "data": { /* payload */ }
}

// Error response
{
  "statusCode": 401,
  "message": "Username atau password salah",
  "error": "Unauthorized",
  "timestamp": "2026-01-10T08:30:00.000Z"
}
```

#### Date/Time Formats

| Context | Format | Example |
|---------|--------|---------|
| **API (JSON)** | ISO 8601 | `"2026-01-10T08:30:00.000Z"` |
| **Database** | TIMESTAMPTZ | PostgreSQL native |
| **Display** | Indonesia locale | `"10 Januari 2026, 15:30 WIB"` |

### Testing Patterns

#### Test File Naming

```
// Flutter - snake_case + _test suffix
user_repository_test.dart  ✅
test_user_repository.dart  ❌

// NestJS - kebab-case + .spec suffix
auth.service.spec.ts       ✅
auth.service.test.ts       ❌
```

#### Test Description Pattern (BDD Style)

```dart
// Flutter (bloc_test)
group('AuthBloc', () {
  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () => authBloc,
      act: (bloc) => bloc.add(LoginRequested(username: 'test', password: 'pass')),
      expect: () => [AuthLoading(), isA<AuthAuthenticated>()],
    );
  });
});
```

```typescript
// NestJS (Jest)
describe('AuthService', () => {
  describe('validateUser', () => {
    it('should return user when credentials are valid', async () => {
      // ...
    });
  });
});
```

#### Mock/Fake Naming Convention

```dart
// Mock: For behavior verification
class MockUserRepository extends Mock implements UserRepository {}

// Fake: For simple substitution
class FakeUser extends Fake implements User {}

// Pattern: Mock/Fake + ClassName
```

#### Fixture Organization

```dart
// test/fixtures/user_fixtures.dart
class UserFixtures {
  static User kasieUser() => User(
    id: '1',
    name: 'Pak Suswanto',
    role: UserRole.kasiePg,
    isFirstTime: false,
  );

  static User operatorUser() => User(
    id: '2',
    name: 'Pak Siswanto',
    role: UserRole.operator,
    isFirstTime: false,
  );

  static User firstTimeUser() => User(
    id: '3',
    name: 'New User',
    role: UserRole.operator,
    isFirstTime: true,
  );
}
```

### User-Facing Text Patterns (Bahasa Indonesia)

#### Loading Messages

| State | Message |
|-------|---------|
| **Login** | `Memproses login...` |
| **Data loading** | `Memuat data...` |
| **Saving** | `Menyimpan...` |
| **Refreshing** | `Memperbarui...` |
| **Syncing** | `Sinkronisasi...` |

#### Error Message Patterns

| Type | Pattern | Example |
|------|---------|---------|
| **Validation** | `[Field] [issue]` | `Password minimal 8 karakter` |
| **Auth** | Direct statement | `Username atau password salah` |
| **Network** | Problem + action | `Tidak dapat terhubung. Periksa koneksi internet Anda.` |
| **Server** | Apologetic + retry | `Terjadi kesalahan. Silakan coba lagi.` |

#### Button Labels

| Action | Label |
|--------|-------|
| **Submit/Login** | `Masuk` |
| **Save** | `Simpan` |
| **Send** | `Kirim` |
| **Cancel** | `Batal` |
| **Retry** | `Coba Lagi` |
| **Confirm** | `Ya`, `Konfirmasi` |
| **Dismiss** | `Tutup`, `OK` |

#### Empty State Messages

| Context | Message |
|---------|---------|
| **No data** | `Belum ada data` |
| **No results** | `Tidak ditemukan` |
| **Offline** | `Anda sedang offline` |
| **No tasks** | `Tidak ada tugas hari ini` |

### Enforcement Guidelines

**All AI Agents MUST:**

1. Follow import ordering rules exactly as specified
2. Use standardized Failure types (never throw raw exceptions to UI)
3. Apply consistent naming conventions (Entity vs Model, UseCase pattern)
4. Write tests with BDD-style descriptions
5. Use Bahasa Indonesia for all user-facing text
6. Create barrel files for each feature's public API
7. Mirror lib/ structure in test/ folder (Flutter)

**Pattern Verification:**

- PR reviews should check naming consistency
- Linter rules enforce import ordering
- Test coverage ensures Failure types are handled
- project-context.md is the single source of truth

### Pattern Examples

**Good Example - Auth Feature:**

```
lib/features/auth/
├── auth.dart                    # Barrel file
├── data/
│   ├── datasources/
│   │   ├── auth_local_datasource.dart
│   │   └── auth_remote_datasource.dart
│   ├── models/
│   │   └── user_model.dart      # Has fromJson/toJson
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── user_entity.dart     # Pure business object
│   ├── repositories/
│   │   └── auth_repository.dart # Abstract interface
│   └── usecases/
│       ├── login_user_usecase.dart
│       └── logout_user_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── auth_bloc.dart
    │   ├── auth_event.dart
    │   └── auth_state.dart
    ├── pages/
    │   └── login_page.dart
    └── widgets/
        └── login_form.dart
```

**Anti-Patterns to Avoid:**

```dart
// ❌ BAD: Inconsistent repository methods
fetchUser(), loadUserById(), getUserData(), retrieveCurrentUser()

// ✅ GOOD: Consistent 'get' verb
getById(), getByUsername(), getCurrentUser()

// ❌ BAD: Raw exceptions to UI
throw Exception('Login failed');

// ✅ GOOD: Typed failures
return Left(AuthFailure('Username atau password salah'));

// ❌ BAD: English user-facing text
'Loading...'

// ✅ GOOD: Bahasa Indonesia
'Memuat data...'

// ❌ BAD: Screen suffix
LoginScreen, HomeScreen

// ✅ GOOD: Page suffix
LoginPage, HomePage
```

## Project Structure & Boundaries

### FR Categories to Structure Mapping

| FR Category | Flutter Location | NestJS Location |
|-------------|------------------|-----------------|
| **Authentication (FR1-FR6, FR31-FR33)** | `features/auth/` | `src/auth/` |
| **Main Page Display (FR7-FR11)** | `features/home/` | - (client-side only) |
| **Role-Based Access (FR12-FR14)** | `core/guards/`, `features/home/` | `src/auth/guards/` |
| **First-Time UX (FR15-FR17, FR28-FR29)** | `shared/widgets/tooltip_overlay.dart` | `src/users/` (is_first_time) |
| **Data Management (FR18-FR21)** | - | `src/users/`, `src/common/` |
| **Resilience & Offline (FR22-FR25, FR30, FR34-FR35)** | `core/network/`, `core/services/` | `src/common/` |
| **Weather Widget** | `features/weather/` | `src/weather/` |

**Note:** First-time UX menggunakan contextual tooltips (bukan onboarding modal) - controlled by `is_first_time` flag.

### Complete Project Directory Structure

#### Flutter App: `fstrack_tractor_app/`

```
fstrack_tractor_app/
├── README.md
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── .gitignore
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── build-apk.yml
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── res/
│   │           └── values/
│   │               └── styles.xml
│   └── build.gradle
├── assets/
│   └── fonts/
│       ├── Poppins-Regular.ttf
│       ├── Poppins-Medium.ttf
│       ├── Poppins-SemiBold.ttf
│       └── Poppins-Bold.ttf
├── lib/
│   ├── main.dart
│   ├── injection_container.dart
│   ├── injection_container.config.dart          # Generated
│   ├── core/
│   │   ├── config/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   ├── app_theme.dart
│   │   │   ├── api_constants.dart               # API URLs, keys
│   │   │   └── app_durations.dart               # Timeouts, cache TTL
│   │   ├── error/
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   ├── extensions/                          # Dart extensions
│   │   │   ├── context_extensions.dart          # Theme, MediaQuery
│   │   │   ├── string_extensions.dart           # Validation helpers
│   │   │   └── datetime_extensions.dart         # WIB formatting
│   │   ├── models/                              # Shared models
│   │   │   ├── api_response.dart
│   │   │   └── paginated_response.dart
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   ├── api_endpoints.dart
│   │   │   └── dio_interceptors.dart
│   │   ├── services/
│   │   │   ├── connectivity_service.dart
│   │   │   ├── hive_service.dart
│   │   │   └── hive_adapters/                   # Hive type adapters
│   │   │       ├── user_model_adapter.dart
│   │   │       └── weather_cache_adapter.dart
│   │   ├── utils/
│   │   │   ├── date_formatter.dart
│   │   │   └── validators.dart
│   │   └── router/
│   │       ├── router_config.dart               # GoRouter setup
│   │       ├── routes.dart                      # Route path constants
│   │       └── route_guards.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── auth.dart                        # Barrel file
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   ├── auth_local_datasource.dart
│   │   │   │   │   └── auth_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── user_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── user_entity.dart
│   │   │   │   │   └── user_role.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── login_user_usecase.dart
│   │   │   │       ├── logout_user_usecase.dart
│   │   │   │       └── validate_token_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── auth_bloc.dart
│   │   │       │   ├── auth_event.dart
│   │   │       │   └── auth_state.dart
│   │   │       ├── pages/
│   │   │       │   └── login_page.dart
│   │   │       └── widgets/
│   │   │           ├── login_form.dart
│   │   │           └── password_field.dart
│   │   ├── home/
│   │   │   ├── home.dart                        # Barrel file
│   │   │   ├── data/
│   │   │   │   └── repositories/
│   │   │   │       └── home_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   └── repositories/
│   │   │   │       └── home_repository.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── home_bloc.dart
│   │   │       │   ├── home_event.dart
│   │   │       │   └── home_state.dart
│   │   │       ├── pages/
│   │   │       │   └── home_page.dart
│   │   │       └── widgets/
│   │   │           ├── greeting_header.dart
│   │   │           ├── menu_card.dart
│   │   │           ├── clock_widget.dart
│   │   │           └── first_time_hints.dart    # Contextual tooltips
│   │   └── weather/
│   │       ├── weather.dart                     # Barrel file
│   │       ├── data/
│   │       │   ├── datasources/
│   │       │   │   ├── weather_local_datasource.dart
│   │       │   │   └── weather_remote_datasource.dart
│   │       │   ├── models/
│   │       │   │   └── weather_model.dart
│   │       │   └── repositories/
│   │       │       └── weather_repository_impl.dart
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   │   └── weather_entity.dart
│   │       │   ├── repositories/
│   │       │   │   └── weather_repository.dart
│   │       │   └── usecases/
│   │       │       └── get_current_weather_usecase.dart
│   │       └── presentation/
│   │           ├── bloc/
│   │           │   ├── weather_bloc.dart
│   │           │   ├── weather_event.dart
│   │           │   └── weather_state.dart
│   │           └── widgets/
│   │               └── weather_widget.dart
│   └── shared/
│       └── widgets/
│           ├── text_input_global.dart
│           ├── custom_checkbox.dart
│           ├── offline_banner.dart
│           ├── loading_shimmer.dart
│           ├── primary_button.dart
│           └── tooltip_overlay.dart             # First-time tooltip system
├── test/
│   ├── fixtures/
│   │   ├── user_fixtures.dart
│   │   ├── weather_fixtures.dart
│   │   └── jwt_fixtures.dart
│   ├── mocks/                                   # Mock implementations
│   │   ├── mock_auth_repository.dart
│   │   ├── mock_weather_repository.dart
│   │   └── mock_connectivity_service.dart
│   ├── helpers/
│   │   └── test_helpers.dart
│   ├── golden/                                  # Visual regression tests
│   │   ├── weather_widget_test.dart
│   │   ├── offline_banner_test.dart
│   │   ├── greeting_header_test.dart
│   │   └── goldens/                             # Generated images
│   │       └── .gitkeep
│   └── features/
│       ├── auth/
│       │   ├── data/
│       │   │   └── repositories/
│       │   │       └── auth_repository_impl_test.dart
│       │   ├── domain/
│       │   │   └── usecases/
│       │   │       └── login_user_usecase_test.dart
│       │   └── presentation/
│       │       └── bloc/
│       │           └── auth_bloc_test.dart
│       ├── home/
│       │   └── presentation/
│       │       └── bloc/
│       │           └── home_bloc_test.dart
│       └── weather/
│           └── presentation/
│               └── bloc/
│                   └── weather_bloc_test.dart
└── integration_test/
    └── app_test.dart
```

#### NestJS API: `fstrack-tractor-api/`

```
fstrack-tractor-api/
├── README.md
├── package.json
├── package-lock.json
├── tsconfig.json
├── tsconfig.build.json
├── nest-cli.json
├── jest.config.js
├── .env
├── .env.example
├── .gitignore
├── .eslintrc.js
├── .prettierrc
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── deploy-railway.yml
├── docker-compose.yml
├── Dockerfile
├── src/
│   ├── main.ts
│   ├── app.module.ts
│   ├── config/
│   │   ├── configuration.ts
│   │   ├── database.config.ts
│   │   └── jwt.config.ts
│   ├── health/                                  # Public health endpoint
│   │   ├── health.module.ts
│   │   ├── health.controller.ts
│   │   └── health.service.ts
│   ├── auth/
│   │   ├── auth.module.ts
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   ├── auth.service.spec.ts
│   │   ├── strategies/
│   │   │   └── jwt.strategy.ts
│   │   ├── guards/
│   │   │   ├── jwt-auth.guard.ts
│   │   │   └── roles.guard.ts
│   │   ├── decorators/
│   │   │   ├── current-user.decorator.ts
│   │   │   └── roles.decorator.ts
│   │   └── dto/
│   │       ├── login.dto.ts
│   │       └── auth-response.dto.ts
│   ├── users/
│   │   ├── users.module.ts
│   │   ├── users.service.ts
│   │   ├── users.service.spec.ts
│   │   ├── entities/
│   │   │   └── user.entity.ts
│   │   ├── dto/
│   │   │   ├── create-user.dto.ts
│   │   │   └── user-response.dto.ts
│   │   └── enums/
│   │       └── user-role.enum.ts
│   ├── weather/
│   │   ├── weather.module.ts
│   │   ├── weather.controller.ts
│   │   ├── weather.service.ts
│   │   ├── weather.service.spec.ts
│   │   ├── adapters/
│   │   │   ├── weather-adapter.interface.ts
│   │   │   └── openweathermap.adapter.ts
│   │   └── dto/
│   │       └── weather-response.dto.ts
│   ├── common/
│   │   ├── decorators/
│   │   │   └── api-response.decorator.ts
│   │   ├── filters/
│   │   │   └── http-exception.filter.ts
│   │   ├── interceptors/
│   │   │   ├── response-transform.interceptor.ts
│   │   │   └── logging.interceptor.ts
│   │   ├── pipes/
│   │   │   └── validation.pipe.ts
│   │   └── dto/
│   │       └── api-response.dto.ts
│   └── database/
│       ├── database.module.ts
│       └── migrations/
│           ├── 1704844800000-CreateUsersTable.ts
│           └── 1704844900000-AddEstateIdToUsers.ts
├── test/
│   ├── jest-e2e.json
│   ├── test-app.module.ts                       # E2E test module
│   ├── fixtures/
│   │   ├── user.fixtures.ts
│   │   └── jwt.fixtures.ts
│   ├── utils/
│   │   └── time-manipulation.ts
│   └── e2e/
│       └── auth.e2e-spec.ts
└── scripts/
    ├── validate-csv.ts                          # Pre-import validation
    ├── import-csv.ts                            # CSV → PostgreSQL
    └── seed-dev-user.ts                         # Dev account for testing
```

### Environment Variables

#### Flutter (via --dart-define)

```bash
# Development
flutter run \
  --dart-define=API_BASE_URL=http://localhost:3000/api/v1 \
  --dart-define=ENVIRONMENT=development

# Staging (Railway)
flutter run \
  --dart-define=API_BASE_URL=https://fstrack-api.railway.app/api/v1 \
  --dart-define=ENVIRONMENT=staging

# Production
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.fstrack.company.com/api/v1 \
  --dart-define=ENVIRONMENT=production
```

#### NestJS (.env)

```bash
# .env.example
NODE_ENV=development
PORT=3000

# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=fstrack_tractor
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=

# JWT
JWT_SECRET=your-super-secret-key-change-in-production
JWT_EXPIRES_IN=14d

# Weather API
OPENWEATHERMAP_API_KEY=your-api-key

# Rate Limiting
THROTTLE_TTL=900
THROTTLE_LIMIT=5
```

### Architectural Boundaries

#### API Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/api/v1/health` | No | Health check |
| `POST` | `/api/v1/auth/login` | No | User login |
| `GET` | `/api/v1/users/me` | JWT | Get current user |
| `PATCH` | `/api/v1/users/me/first-time` | JWT | Mark onboarding complete |
| `GET` | `/api/v1/weather` | JWT | Get weather for user's estate |

#### Component Boundaries (Flutter)

```
┌─────────────────────────────────────────────────────────────┐
│                        Presentation                          │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐                      │
│  │AuthBloc │  │HomeBloc │  │WeatherB │   Pages + Widgets    │
│  └────┬────┘  └────┬────┘  └────┬────┘                      │
└───────┼────────────┼────────────┼───────────────────────────┘
        │            │            │
┌───────┼────────────┼────────────┼───────────────────────────┐
│       ▼            ▼            ▼                   Domain  │
│  ┌─────────────────────────────────────┐                    │
│  │              UseCases                │                    │
│  └─────────────────┬───────────────────┘                    │
│                    │                                         │
│  ┌─────────────────┴───────────────────┐                    │
│  │        Repository Interfaces         │                    │
│  └─────────────────┬───────────────────┘                    │
└────────────────────┼────────────────────────────────────────┘
                     │
┌────────────────────┼────────────────────────────────────────┐
│                    ▼                                  Data  │
│  ┌─────────────────────────────────────┐                    │
│  │      Repository Implementations      │                    │
│  └─────────────────┬───────────────────┘                    │
│                    │                                         │
│  ┌────────────┬────┴────┬──────────────┐                    │
│  │  Remote    │  Local  │   Adapters   │                    │
│  │  (Dio)     │ (Hive)  │  (Weather)   │                    │
│  └────────────┴─────────┴──────────────┘                    │
└─────────────────────────────────────────────────────────────┘
```

#### Data Flow: Login

```
User Tap "Masuk"
      │
      ▼
LoginPage → LoginForm.onSubmit()
      │
      ▼
AuthBloc.add(LoginRequested(username, password))
      │
      ▼
LoginUserUseCase.call()
      │
      ▼
AuthRepository.login() [interface]
      │
      ▼
AuthRepositoryImpl.login()
      │
      ├──► AuthRemoteDataSource ──► Dio ──► NestJS /auth/login
      │                                              │
      │                                              ▼
      │                                    AuthService.validateUser()
      │                                              │
      │                                              ▼
      │                                    JWT generated, returned
      │                                              │
      ◄──────────────────────────────────────────────┘
      │
      ▼
AuthLocalDataSource.saveToken() ──► Hive (encrypted box)
      │
      ▼
Either<Failure, User> returned
      │
      ▼
AuthBloc emits AuthAuthenticated(user)
      │
      ▼
go_router observes state change
      │
      ├── if user.isFirstTime → HomePage (with tooltips visible)
      └── else → HomePage (tooltips hidden)
```

### Integration Points

#### Internal Communication

| From | To | Method |
|------|----|--------|
| BLoC → Repository | Dependency Injection (get_it) | Interface-based |
| Repository → DataSource | Constructor injection | Direct call |
| Page → BLoC | `context.read<Bloc>()` | Flutter context |
| BLoC → BLoC | `BlocListener` | Event-driven |

#### External Integrations

| Service | Integration Point | Fallback |
|---------|-------------------|----------|
| **NestJS API** | `core/network/api_client.dart` | Cached data |
| **OpenWeatherMap** | `src/weather/adapters/` | Cached + "tidak tersedia" |
| **Hive Storage** | `core/services/hive_service.dart` | In-memory (emergency) |

### File Organization Summary

| Category | Flutter | NestJS |
|----------|---------|--------|
| **Entry** | `lib/main.dart` | `src/main.ts` |
| **DI Setup** | `lib/injection_container.dart` | `src/app.module.ts` |
| **Config** | `lib/core/config/` | `src/config/` |
| **Features** | `lib/features/{name}/` | `src/{name}/` |
| **Shared** | `lib/shared/widgets/` | `src/common/` |
| **Tests** | `test/` (mirrored) | Co-located `*.spec.ts` |
| **E2E** | `integration_test/` | `test/e2e/` |

## Party Mode Validation Enhancements

*Recommendations dari multi-agent review (Winston, Murat, Sally, Amelia) untuk meningkatkan implementation readiness.*

### Offline Conflict Resolution Strategy

**Strategy:** Last-Write-Wins (LWW) dengan audit trail

```dart
// Conflict resolution for offline edits
class SyncConflictResolver {
  /// Resolves conflicts using last-write-wins strategy
  /// Server timestamp is authoritative
  Future<SyncResult> resolve(LocalEntity local, RemoteEntity remote) {
    if (local.updatedAt.isAfter(remote.updatedAt)) {
      // Local is newer - push to server
      return SyncResult.pushLocal(local);
    } else if (remote.updatedAt.isAfter(local.updatedAt)) {
      // Remote is newer - overwrite local
      return SyncResult.pullRemote(remote);
    } else {
      // Same timestamp - server wins (deterministic)
      return SyncResult.pullRemote(remote);
    }
  }
}
```

**Rationale:** MVP scope menggunakan simple strategy. Future enhancement bisa add merge logic untuk complex conflicts.

**Queue Mechanism:**
- Pending changes stored in Hive `sync_queue` box
- Each item has: `action`, `payload`, `timestamp`, `retryCount`
- Max 3 retries dengan exponential backoff (2s, 4s, 8s)
- Failed after 3 retries → marked for manual resolution

### Hive Testing Approach

**Mock Box Pattern:**

```dart
// test/mocks/mock_hive_box.dart
class MockHiveBox<T> extends Mock implements Box<T> {
  final Map<dynamic, T> _data = {};

  @override
  T? get(dynamic key, {T? defaultValue}) => _data[key] ?? defaultValue;

  @override
  Future<void> put(dynamic key, T value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _data.remove(key);
  }

  @override
  Iterable<T> get values => _data.values;

  void clear() => _data.clear();
}
```

**flutter_secure_storage Test Stub:**

```dart
// test/mocks/mock_secure_storage.dart
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<String?> read({required String key, ...}) async => _storage[key];

  @override
  Future<void> write({required String key, required String value, ...}) async {
    _storage[key] = value;
  }
}
```

**Test Setup:**

```dart
// test/helpers/hive_test_setup.dart
Future<void> setUpHiveForTest() async {
  // Use temp directory for isolation
  final tempDir = await Directory.systemTemp.createTemp('hive_test_');
  Hive.init(tempDir.path);

  // Register adapters (no encryption in tests for simplicity)
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(WeatherCacheAdapter());
}

Future<void> tearDownHiveForTest() async {
  await Hive.close();
  await Hive.deleteFromDisk();
}
```

### Error Transformation Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         DATA LAYER                                   │
│                                                                       │
│   DataSource (Dio/Hive)                                              │
│         │                                                             │
│         ▼ Throws Exception                                           │
│   ┌─────────────────────────────────────────────────────┐           │
│   │ DioException        → ServerException               │           │
│   │ HiveError           → CacheException                │           │
│   │ SocketException     → NetworkException              │           │
│   │ FormatException     → ParseException                │           │
│   └─────────────────────────────────────────────────────┘           │
│                                                                       │
│   RepositoryImpl                                                     │
│         │                                                             │
│         ▼ Catches Exception, returns Either<Failure, T>             │
│   ┌─────────────────────────────────────────────────────┐           │
│   │ ServerException     → Left(ServerFailure(msg))      │           │
│   │ CacheException      → Left(CacheFailure(msg))       │           │
│   │ NetworkException    → Left(NetworkFailure())        │           │
│   │ AuthException       → Left(AuthFailure(msg))        │           │
│   └─────────────────────────────────────────────────────┘           │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        DOMAIN LAYER                                  │
│                                                                       │
│   UseCase receives Either<Failure, T>                                │
│         │                                                             │
│         ▼ Passes through (no transformation)                        │
│   Returns Either<Failure, T> to Presentation                        │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                               │
│                                                                       │
│   BLoC receives Either<Failure, T>                                   │
│         │                                                             │
│         ▼ fold() to emit state                                       │
│   ┌─────────────────────────────────────────────────────┐           │
│   │ Left(failure)  → emit(ErrorState(failure.message))  │           │
│   │ Right(data)    → emit(SuccessState(data))           │           │
│   └─────────────────────────────────────────────────────┘           │
│                                                                       │
│   Widget displays failure.message (already in Bahasa Indonesia)     │
└─────────────────────────────────────────────────────────────────────┘
```

**Key Rule:** Exceptions NEVER propagate beyond Repository. BLoC only sees Failures.

### BLoC Cross-Feature State Access

**Pattern 1: BlocListener for Side Effects**

```dart
// HomePage listens to AuthBloc for logout
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthUnauthenticated) {
      // Clear weather cache on logout
      context.read<WeatherBloc>().add(ClearWeatherCache());
    }
  },
  child: ...
)
```

**Pattern 2: BlocProvider.of for Read-Only Access**

```dart
// WeatherBloc needs user's estate_id from AuthBloc
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final AuthBloc authBloc;

  WeatherBloc({required this.authBloc}) : super(WeatherInitial());

  Future<void> _onFetchWeather(FetchWeather event, Emitter emit) async {
    final authState = authBloc.state;
    if (authState is AuthAuthenticated) {
      final estateId = authState.user.estateId;
      // Fetch weather for this estate
    }
  }
}
```

**Pattern 3: StreamSubscription for Reactive Updates**

```dart
// ConnectivityBloc notifies other BLoCs
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  late StreamSubscription _connectivitySubscription;

  HomeBloc({required ConnectivityBloc connectivityBloc}) {
    _connectivitySubscription = connectivityBloc.stream.listen((state) {
      if (state is ConnectivityOnline) {
        add(SyncPendingChanges());
      }
    });
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}
```

**DI Registration (get_it):**

```dart
// injection_container.dart
void configureDependencies() {
  // AuthBloc singleton (app-wide state)
  getIt.registerLazySingleton(() => AuthBloc(...));

  // ConnectivityBloc singleton
  getIt.registerLazySingleton(() => ConnectivityBloc(...));

  // Feature BLoCs (factory - new instance per route)
  getIt.registerFactory(() => WeatherBloc(authBloc: getIt()));
  getIt.registerFactory(() => HomeBloc(connectivityBloc: getIt()));
}
```

### Deferred to Implementation Stories

*These details akan di-define saat story implementation:*

| Item | Deferred Reason | Story Reference |
|------|-----------------|-----------------|
| **Tooltip Sequence & Timing** | Requires user testing | First-Time UX Story |
| **Loading Timeout Thresholds** | Requires performance profiling | Performance Story |
| **Weather Adapter Contract Tests** | Implementation detail | Weather Integration Story |
| **Tooltip Re-discovery Mechanism** | UX decision | Settings Feature Story |

## Architecture Validation

### Validation Summary

**Validation Date:** 2026-01-10
**Reviewer:** Party Mode (Winston, Murat, Sally, Amelia)

| Criteria | Status | Notes |
|----------|--------|-------|
| **Coherence** | ✅ PASS | All decisions compatible |
| **FR Coverage** | ✅ 37/37 | 100% requirements mapped |
| **NFR Coverage** | ✅ 38/38 | 100% requirements addressed |
| **Implementation Readiness** | ✅ HIGH | AI agents can implement consistently |

### Coherence Check

| Decision A | Decision B | Compatibility |
|------------|------------|---------------|
| Hive (local) | BLoC (state) | ✅ HiveService injected to DataSources |
| go_router | AuthBloc | ✅ refreshListenable pattern defined |
| Clean Architecture | injectable | ✅ Interface-first registration |
| OpenWeatherMap | Adapter pattern | ✅ Swappable implementation |
| Contextual tooltips | is_first_time flag | ✅ Server-driven, client-rendered |

### Gap Analysis

| Gap Type | Finding |
|----------|---------|
| **Critical Gaps** | None identified |
| **Minor Gaps** | Tooltip sequence deferred to implementation |
| **Recommendations Applied** | 4 patterns added from Party Mode review |

### Readiness Confidence

**Overall: HIGH**

- ✅ All technology choices have explicit initialization patterns
- ✅ Error handling flow fully documented
- ✅ Cross-feature state access patterns defined
- ✅ Offline sync strategy documented
- ✅ Testing infrastructure patterns provided
- ✅ Bahasa Indonesia user-facing text standards established


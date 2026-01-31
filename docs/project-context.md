# FSTrack-Tractor Project Context

> **Purpose:** This file contains critical rules and patterns that AI agents MUST follow when implementing code. This is the authoritative source for architectural decisions.

## Project Overview

- **Project:** FSTrack-Tractor
- **Type:** Mobile App (Flutter Android) + REST API (NestJS)
- **MVP Scope:** Login + Main Page
- **Reference App:** Bulldozer (vat-soil/frontend-vat-subsoil-tracker_apps-main)

---

## Flutter App Architecture

### Pattern: Clean Architecture + BLoC

**Mandatory Layers per Feature:**
```
features/
└── feature_name/
    ├── data/           # Repository implementations, data sources, models
    ├── domain/         # Entities, repository interfaces, use cases
    └── presentation/   # BLoC, pages, widgets
```

**DO NOT flatten this structure.** Every feature MUST have all three layers.

### State Management

- **Required:** flutter_bloc
- **Pattern:** One BLoC per feature (not per screen)
- **States:** Use sealed classes (Dart 3+) or Equatable

### Dependency Injection

- **Packages:** get_it + injectable
- **Registration:** Auto-generated via build_runner
- **File:** `lib/injection_container.dart` with `@InjectableInit`

### Local Storage

- **Package:** Hive + hive_flutter (NOT shared_preferences)
- **Encryption:** flutter_secure_storage for Hive encryption key
- **Boxes:** `auth` (encrypted), `weather_cache` (normal)

### Navigation

- **Package:** go_router
- **Auth Redirect:** Integrated with AuthBloc.stream
- **Transitions:** Slide right (push), slide bottom (modal), none (auth redirect)

### Project Structure

```
lib/
├── core/
│   ├── config/              # AppColors, AppTextStyle, AppTheme
│   ├── constants/           # API endpoints, durations, feature flags
│   ├── error/               # Exceptions, Failures
│   ├── network/             # Dio client, interceptors, ApiClient
│   └── utils/               # Extensions, helpers
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   ├── home/
│   │   └── ... (same structure)
│   └── weather/
│       └── ... (same structure)
├── shared/
│   └── widgets/             # Reusable widgets across features
├── injection_container.dart
├── injection_container.config.dart  # Generated
└── main.dart
```

---

## Design System (Bulldozer Alignment)

### Colors (EXACT MATCH REQUIRED)

```dart
class AppColors {
  static const Color primary = Color(0xFF008945);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF828282);
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color buttonOrange = Color(0xFFFBA919);
  static const Color buttonBlue = Color(0xFF25AAE1);
  static const Color greyCard = Color(0xFFF0F0F0);
  static const Color greyDate = Color(0xFF828282);
}
```

### Typography

- **Font:** Poppins (BUNDLED in assets, not GoogleFonts)
- **Weights:** 400, 500, 600, 700
- **Sizes:** 8, 10, 12, 13, 20

### Components to Copy from Bulldozer

- `TextInputGlobal` - Input field styling
- `CustomCheckbox` - Checkbox with label

### New Components (FSTrack-specific)

- `WeatherWidget` - Weather display with states
- `OfflineBanner` - Tappable offline indicator
- `GreetingHeader` - Time-based greeting
- `TaskCard` - Work plan card with status

---

## Testing Requirements

### Release Build Verification (MANDATORY)

At the end of each epic, generate a **release** APK (not debug) to validate the epic's capabilities in realistic conditions. Use the staging API base URL and run smoke tests against the epic's delivered scope.

**Rules:**
- Do not rely on debug APK for UX/performance validation.
- Record the release APK build artifact and the smoke test results per epic.

### Golden Tests (MANDATORY)

All custom widgets MUST have golden tests:

```dart
// test/widgets/weather_widget_test.dart
testGoldens('WeatherWidget renders correctly', (tester) async {
  await tester.pumpWidgetBuilder(
    WeatherWidget(temperature: 26, condition: WeatherCondition.sunny),
  );
  await screenMatchesGolden(tester, 'weather_widget_sunny');
});
```

**Widgets requiring golden tests:**
- WeatherWidget (all states: loading, success, cached, error)
- OfflineBanner (all states: offline, syncing, sync_failed)
- GreetingHeader (all time periods)
- TaskCard (all status variants: open, assigned, closed)

### Test Fixtures

All mock data in dedicated fixtures folder:

```
test/
├── features/
│   ├── auth/
│   └── home/
├── widgets/
├── fixtures/
│   ├── user_fixtures.dart      # Mock users per role
│   ├── weather_fixtures.dart   # Mock weather responses
│   └── jwt_fixtures.dart       # Mock JWT tokens
└── helpers/
    └── test_helpers.dart       # Common test utilities
```

### BLoC Testing

```dart
blocTest<AuthBloc, AuthState>(
  'emits [loading, success] when login succeeds',
  build: () => AuthBloc(authRepository: mockAuthRepository),
  act: (bloc) => bloc.add(LoginRequested(username: 'test', password: 'pass')),
  expect: () => [AuthLoading(), AuthSuccess(user: testUser)],
);
```

---

## NestJS Backend Architecture

### Pattern: Modular Architecture

```
src/
├── auth/
│   ├── auth.module.ts
│   ├── auth.controller.ts
│   ├── auth.service.ts
│   ├── strategies/
│   │   └── jwt.strategy.ts
│   ├── guards/
│   │   └── jwt-auth.guard.ts
│   └── dto/
├── users/
│   ├── users.module.ts
│   ├── users.service.ts
│   ├── entities/
│   │   └── user.entity.ts
│   └── dto/
├── weather/
│   ├── weather.module.ts
│   ├── weather.controller.ts
│   ├── weather.service.ts
│   └── adapters/
│       ├── weather-adapter.interface.ts
│       └── free-weather.adapter.ts
├── common/
│   ├── decorators/
│   ├── guards/
│   ├── filters/
│   └── interceptors/
└── main.ts
```

### Database

- **ORM:** TypeORM
- **Database:** PostgreSQL
- **Migrations:** TypeORM migrations (not auto-sync in production)

### Authentication

- **Strategy:** JWT with bcrypt password hashing
- **Token Duration:** 14 days
- **Grace Period:** 24 hours (local validation)
- **Rate Limiting:** 5 attempts per 15 minutes per username

### Weather API

- **Pattern:** Adapter interface for swappable implementations
- **MVP:** Free tier API (TBD)
- **Future:** Company AWS/satellite API

---

## Code Standards

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | snake_case | `auth_bloc.dart` |
| Classes | PascalCase | `AuthBloc` |
| Variables | camelCase | `isLoading` |
| Constants | camelCase | `apiBaseUrl` |
| BLoC Events | PascalCase + Past tense | `LoginRequested` |
| BLoC States | PascalCase | `AuthLoading` |

### Error Handling

- All external dependencies behind interfaces (mockable)
- Failures use `Either<Failure, Success>` pattern (dartz)
- User-facing errors in Bahasa Indonesia
- Structured logging for debugging

### Feature Flags

Role-based UI controlled via:
```dart
// Check role for FAB visibility
if (user.role.isKasie) {
  // Show FAB
}
```

---

## Critical Rules for AI Agents

1. **NEVER flatten the Clean Architecture layers** - always maintain data/domain/presentation
2. **ALWAYS use AppColors constants** - no hardcoded hex values
3. **ALWAYS bundle fonts** - no GoogleFonts network calls
4. **ALWAYS write golden tests** for new widgets
5. **ALWAYS put test fixtures in /test/fixtures**
6. **ALWAYS use injectable annotations** for DI registration
7. **FOLLOW Bulldozer patterns** for shared components
8. **USE Bahasa Indonesia** for user-facing error messages

---

## Version Information

- Flutter: 3.x (latest stable)
- Dart: 3.x (with null safety)
- NestJS: 11.x
- TypeScript: 5.x
- PostgreSQL: 15+

---

*Last Updated: 2026-01-10*

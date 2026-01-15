# Changelog

All notable changes to FSTrack-Tractor will be documented in this file.

## [Unreleased]

### Added
- Story 1.1: Flutter project initialized with Clean Architecture (auth/home/weather features), Hive 2.x encrypted storage, get_it/injectable DI, go_router navigation, and Bulldozer-aligned design system
- Story 1.2: NestJS project initialized with modular architecture, health endpoint (/api/health), Swagger UI (/api/docs), Helmet security headers, and API versioning ready
- Story 1.3: PostgreSQL database configured with TypeORM, users table created via migration with all required columns (id, username, password_hash, role, etc.), and development seed data with dev_kasie user for backend authentication infrastructure
- Minor database configuration fix (changed default database name to 'fstrack_tractor_dev'), imported UsersModule in AppModule, and added unit test for handling non-existent user updates in UsersService
- Story 1.4: GitHub Actions CI/CD pipeline implemented with parallel Flutter (analyze, test) and NestJS (build, lint, test) jobs, triggering on pushes/PRs to main branch for automated code quality checks
- Story 1.5: Design system foundation implemented with Poppins font bundled, complete Bulldozer-aligned color/text tokens, spacing constants, and theme configuration for consistent UI
- Story 2.1: Backend authentication module implemented with JWT strategy, login endpoint with bcrypt validation, 14-day token expiry, account lockout checks, and Bahasa Indonesia error responses
- Story 2.2: Backend security implemented with per-username rate limiting (5 attempts/15min) and account lockout (10 failures/30min lock), preventing brute force attacks with Indonesian error responses
- Story 2.3: Flutter login page implemented with AuthBloc, Clean Architecture layers, shared widgets, Dio client with retry interceptor, and Bahasa Indonesia error handling
- Story 2.4: Secure token storage with Hive, offline login with 24-hour grace period, ConnectivityService with debounce logic, and remember me functionality implemented
- Story 2.5: Logout use case implemented with Clean Architecture pattern, AuthBloc integration for session termination, and comprehensive unit testing (infrastructure only)
- Story 2.6: go_router authentication integration implemented with state-based redirects, first-time user onboarding flow, and placeholder pages for home and onboarding
- Infrastructure: Backend staging environment deployed to Railway with PostgreSQL, CI/CD adjusted for controlled deployments, and Epic 2 DoD verification enabled
- Story 3.1: HomePage dashboard implemented with time-based personalized greeting, WIB timezone clock with auto-update, and placeholder containers for weather and menu widgets
- Story 3.2: Backend weather proxy implemented with Adapter pattern for OpenWeatherMap API, GET /api/v1/weather endpoint with Indonesian responses, and comprehensive error handling
- Story 3.3: WeatherWidget implemented with 30-minute caching, auto-refresh every 30 minutes, skeleton loading, graceful error handling with retry, and integration in HomePage dashboard
- Story 3.4: Role-based menu cards implemented with Kasie getting 2 cards (create/view work plans) plus FAB, non-Kasie roles getting 1 card (view only), Coming Soon bottom sheet, and HomePage integration
- Story 4.1: OfflineBanner widget implemented with animated slide transitions, ConnectivityService integration for real-time status, priority manager for multiple banners, and HomePage integration with tap-to-refresh functionality
- Story 4.2: JWT expiry warning banner implemented with SessionExpiryChecker service, rate-limited warnings (once per 24h), force logout on expired sessions with grace period, and actionable error messages in Bahasa Indonesia
- Story 5.1: Backend first-time status endpoint implemented with PATCH /api/v1/users/me/first-time, JWT authentication, CurrentUser decorator, and database update for user onboarding completion tracking
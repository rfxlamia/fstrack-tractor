# Changelog

All notable changes to FSTrack-Tractor will be documented in this file.

## [Unreleased]

### Added
- Story 1.1: Flutter project initialized with Clean Architecture (auth/home/weather features), Hive 2.x encrypted storage, get_it/injectable DI, go_router navigation, and Bulldozer-aligned design system
- Story 1.2: NestJS project initialized with modular architecture, health endpoint (/api/health), Swagger UI (/api/docs), Helmet security headers, and API versioning ready
- Story 1.3: PostgreSQL database configured with TypeORM, users table created via migration with all required columns (id, username, password_hash, role, etc.), and development seed data with dev_kasie user for backend authentication infrastructure
- Minor database configuration fix (changed default database name to 'fstrack_tractor_dev'), imported UsersModule in AppModule, and added unit test for handling non-existent user updates in UsersService

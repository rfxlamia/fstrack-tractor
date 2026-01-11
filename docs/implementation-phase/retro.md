# Retrospective

*2026-01-11.* 
Epic 1 kelar, 5/5 stories done.

Yang dibangun: Flutter + Clean Architecture, NestJS backend, PostgreSQL dengan TypeORM, CI/CD pipeline, design system. Fondasi FSTrack-Tractor udah jadi.

---

## What Works

Template-driven implementation ternyata ngebantu banget. Setiap story udah ada code template-nya yang match sama architecture decisions, jadi developer ga perlu nebak-nebak. Semua jadi consistent.

Design system di Story 1.5 pake hybrid approach - warna dari Bulldozer tapi rounded corners dari Warm Friendly. Hasilnya clean. Semua tokens (colors, spacing, typography, radius) centralized di app_colors.dart, app_text_styles.dart, app_spacing.dart.

Flutter sama NestJS bisa dikerjain parallel karena ga ada direct dependencies. Story 1.3 baru butuh Story 1.2 selesai. Efficient.

CI/CD setup dengan parallel jobs - Flutter job (analyze, test, build) sama NestJS job (lint, build, test) jalan bareng. Setiap push langsung dapet feedback.

---

## Code Review

Adversarial code review nemuin banyak issues. Average 4-6 issues per story, mostly MEDIUM severity. Yang sering ketemu: test coverage gaps, deprecated APIs, unused variables, documentation yang ga match. AppSpacing.xs harusnya 8 bukan 4, AppSpacing.sm harusnya 12 bukan 8. Kecil tapi kalo ga dibenerin bakal ripple ke semua components. Untung ketemu di review.

---

Worth it. Kalo sampe production baru ketemu, bakal lebih nyusahin.

---

## Masalah yang Muncul

Hive version surprise. Template dibuat buat Hive 4.x, ternyata belum stable. Harus downgrade ke 2.x. Perubahannya lumayan: `Hive.defaultDirectory` jadi `Hive.initFlutter()`, `Hive.box()` jadi `Hive.openBox()`.

Lesson: check pub.dev dulu sebelum pake template. Jangan assume versi di docs udah stable.

Dependency chain antar stories ga explicit. Story 1.3 butuh Story 1.2, tapi ga ada marking di story file. Developer harus figure out sendiri. Risiko mulai story yang dependencies-nya belum ready.

Ada migration file dari Story 1.3 yang belum di-commit, ketemu pas Story 1.4 code review. Seharusnya commit migration segera setelah generate, jangan nunggu.

Documentation kadang ga match. Story 1.4 bilang "12 tests" tapi setelah code review nambah Health module tests jadi 13. Harus update docs setelah review.

---

## Patterns

Template version mismatch happens. Story 1.1 template buat Hive 4.x, dipake Hive 2.x. Story 1.2 template buat NestJS 10.x, dipake 11.x. Templates dibuat waktu planning, package versions udah berubah waktu implementation.

Code review sering update documentation - test counts, file lists, change logs. Mungkin perlu checklist buat ini.

---

## Action Items

Validate package versions sebelum mulai story - check pub.dev/npm. Add explicit dependency chain di story files. Commit migrations. Update test counts setelah code review.

---

## Next Prep

Epic 2: User Authentication & Session. Login page, JWT auth, rate limiting, account lockout, logout, go_router integration. 6 stories.

Dependencies dari Epic 1 udah ready: database schema, CI/CD, design system, UsersService, bcrypt hashing. Columns buat failed_login_attempts sama locked_until juga udah ada.

Yang perlu dicek: dev_kasie seed user bisa authenticate, PostgreSQL connection works di CI.

Knowledge gaps: passport-jwt integration sama NestJS, JWT payload structure (role, estate_id, is_first_time), go_router refreshListenable pattern buat auth redirects.

Rate limiting (5 attempts per 15 menit) sama account lockout (30 menit setelah 10 failed attempts) butuh careful implementation. Harus test thoroughly.

Nothing dari Epic 1 yang fundamentally changes plan buat Epic 2. Architecture sound, database ready, CI green. Proceed.

---

## Takeaways

Template validation penting. Code review depth saves time. Party Mode buat design decisions prevents rework. Hive 2.x stable, 4.x belum. TypeORM migrations > synchronize buat production.

Sebelum Epic 2: verify dev_kasie authentication, test PostgreSQL di CI, document JWT flow.

---

<direction>to be append after each epic done</direction>

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/theme/app_theme.dart';
import 'package:fstrack_tractor/features/auth/domain/entities/user_entity.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_event.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_state.dart';
import 'package:fstrack_tractor/features/home/presentation/widgets/greeting_header.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createGoldenWidget({DateTime? testTime}) {
    const testUser = UserEntity(
      id: '1',
      fullName: 'Pak Suswanto',
      role: UserRole.kasie,
      estateId: 'estate1',
      isFirstTime: false,
    );

    when(() => mockAuthBloc.state)
        .thenReturn(const AuthSuccess(user: testUser));

    return MaterialApp(
      theme: AppTheme.light,
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: Scaffold(
          body: Center(
            child: GreetingHeader(testTime: testTime),
          ),
        ),
      ),
    );
  }

  group('GreetingHeader Golden Tests', () {
    testGoldens('Selamat Pagi (08:00 WIB)', (tester) async {
      // 08:00 WIB = 01:00 UTC
      final testTime = DateTime.utc(2026, 1, 13, 1, 0, 0);

      await tester.pumpWidgetBuilder(
        createGoldenWidget(testTime: testTime),
      );

      await screenMatchesGolden(tester, 'greeting_header_pagi');
    });

    testGoldens('Selamat Siang (13:00 WIB)', (tester) async {
      // 13:00 WIB = 06:00 UTC
      final testTime = DateTime.utc(2026, 1, 13, 6, 0, 0);

      await tester.pumpWidgetBuilder(
        createGoldenWidget(testTime: testTime),
      );

      await screenMatchesGolden(tester, 'greeting_header_siang');
    });

    testGoldens('Selamat Sore (16:00 WIB)', (tester) async {
      // 16:00 WIB = 09:00 UTC
      final testTime = DateTime.utc(2026, 1, 13, 9, 0, 0);

      await tester.pumpWidgetBuilder(
        createGoldenWidget(testTime: testTime),
      );

      await screenMatchesGolden(tester, 'greeting_header_sore');
    });

    testGoldens('Selamat Malam (20:00 WIB)', (tester) async {
      // 20:00 WIB = 13:00 UTC
      final testTime = DateTime.utc(2026, 1, 13, 13, 0, 0);

      await tester.pumpWidgetBuilder(
        createGoldenWidget(testTime: testTime),
      );

      await screenMatchesGolden(tester, 'greeting_header_malam');
    });
  });
}

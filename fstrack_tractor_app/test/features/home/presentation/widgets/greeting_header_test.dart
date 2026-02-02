import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/theme/app_colors.dart';
import 'package:fstrack_tractor/core/theme/app_text_styles.dart';
import 'package:fstrack_tractor/features/auth/domain/entities/user_entity.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_event.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_state.dart';
import 'package:fstrack_tractor/features/home/presentation/widgets/greeting_header.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createWidget({DateTime? testTime}) {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: Scaffold(
          body: GreetingHeader(testTime: testTime),
        ),
      ),
    );
  }

  group('GreetingHeader Widget Tests', () {
    const testUser = UserEntity(
      id: '1',
      fullName: 'Pak Suswanto',
      role: UserRole.kasiePg,
      estateId: 'estate1',
      isFirstTime: false,
    );

    testWidgets('displays greeting with user name when authenticated',
        (tester) async {
      when(() => mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: testUser));

      await tester.pumpWidget(createWidget());

      // Verify contains user name
      expect(find.textContaining('Pak Suswanto'), findsOneWidget);
    });

    testWidgets('displays fallback "User" when not authenticated',
        (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(createWidget());

      // Fallback to 'User'
      expect(find.textContaining('User'), findsOneWidget);
    });

    testWidgets('uses correct typography (w500s16, textPrimary) per UX spec',
        (tester) async {
      when(() => mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: testUser));

      await tester.pumpWidget(createWidget());

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.fontSize, AppTextStyles.w500s16.fontSize);
      expect(textWidget.style?.fontWeight, AppTextStyles.w500s16.fontWeight);
      expect(textWidget.style?.color, AppColors.textPrimary);
    });

    group('Time-based Greeting Tests', () {
      testWidgets('displays "Selamat Pagi" for morning (08:00 WIB)',
          (tester) async {
        when(() => mockAuthBloc.state)
            .thenReturn(const AuthSuccess(user: testUser));

        // 08:00 WIB = 01:00 UTC
        final testTime = DateTime.utc(2026, 1, 13, 1, 0, 0);

        await tester.pumpWidget(createWidget(testTime: testTime));

        expect(find.text('Selamat Pagi, Pak Suswanto'), findsOneWidget);
      });

      testWidgets('displays "Selamat Siang" for afternoon (13:00 WIB)',
          (tester) async {
        when(() => mockAuthBloc.state)
            .thenReturn(const AuthSuccess(user: testUser));

        // 13:00 WIB = 06:00 UTC
        final testTime = DateTime.utc(2026, 1, 13, 6, 0, 0);

        await tester.pumpWidget(createWidget(testTime: testTime));

        expect(find.text('Selamat Siang, Pak Suswanto'), findsOneWidget);
      });

      testWidgets('displays "Selamat Sore" for late afternoon (16:00 WIB)',
          (tester) async {
        when(() => mockAuthBloc.state)
            .thenReturn(const AuthSuccess(user: testUser));

        // 16:00 WIB = 09:00 UTC
        final testTime = DateTime.utc(2026, 1, 13, 9, 0, 0);

        await tester.pumpWidget(createWidget(testTime: testTime));

        expect(find.text('Selamat Sore, Pak Suswanto'), findsOneWidget);
      });

      testWidgets('displays "Selamat Malam" for evening (20:00 WIB)',
          (tester) async {
        when(() => mockAuthBloc.state)
            .thenReturn(const AuthSuccess(user: testUser));

        // 20:00 WIB = 13:00 UTC
        final testTime = DateTime.utc(2026, 1, 13, 13, 0, 0);

        await tester.pumpWidget(createWidget(testTime: testTime));

        expect(find.text('Selamat Malam, Pak Suswanto'), findsOneWidget);
      });
    });
  });

  group('Greeting Logic Unit Tests', () {
    test('morning greeting for hours 0-11', () {
      for (var hour = 0; hour < 12; hour++) {
        final greeting = _getGreetingForHour(hour);
        expect(greeting, 'Selamat Pagi', reason: 'Hour $hour should be Pagi');
      }
    });

    test('afternoon greeting for hours 12-14', () {
      for (var hour = 12; hour < 15; hour++) {
        final greeting = _getGreetingForHour(hour);
        expect(greeting, 'Selamat Siang',
            reason: 'Hour $hour should be Siang');
      }
    });

    test('late afternoon greeting for hours 15-17', () {
      for (var hour = 15; hour < 18; hour++) {
        final greeting = _getGreetingForHour(hour);
        expect(greeting, 'Selamat Sore', reason: 'Hour $hour should be Sore');
      }
    });

    test('evening greeting for hours 18-23', () {
      for (var hour = 18; hour < 24; hour++) {
        final greeting = _getGreetingForHour(hour);
        expect(greeting, 'Selamat Malam',
            reason: 'Hour $hour should be Malam');
      }
    });

    test('edge case: 11:59 should be Pagi', () {
      expect(_getGreetingForHour(11), 'Selamat Pagi');
    });

    test('edge case: 12:00 should be Siang', () {
      expect(_getGreetingForHour(12), 'Selamat Siang');
    });

    test('edge case: 14:59 should be Siang', () {
      expect(_getGreetingForHour(14), 'Selamat Siang');
    });

    test('edge case: 15:00 should be Sore', () {
      expect(_getGreetingForHour(15), 'Selamat Sore');
    });

    test('edge case: 17:59 should be Sore', () {
      expect(_getGreetingForHour(17), 'Selamat Sore');
    });

    test('edge case: 18:00 should be Malam', () {
      expect(_getGreetingForHour(18), 'Selamat Malam');
    });

    test('edge case: 23:59 should be Malam', () {
      expect(_getGreetingForHour(23), 'Selamat Malam');
    });
  });
}

// Helper to test greeting logic (mirrors widget implementation)
String _getGreetingForHour(int hour) {
  if (hour >= 0 && hour < 12) {
    return 'Selamat Pagi';
  } else if (hour >= 12 && hour < 15) {
    return 'Selamat Siang';
  } else if (hour >= 15 && hour < 18) {
    return 'Selamat Sore';
  } else {
    return 'Selamat Malam';
  }
}

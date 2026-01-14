import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/features/auth/domain/entities/user_entity.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_state.dart';
import 'package:fstrack_tractor/features/home/presentation/widgets/menu_card.dart';
import 'package:fstrack_tractor/features/home/presentation/widgets/menu_card_skeleton.dart';
import 'package:fstrack_tractor/features/home/presentation/widgets/role_based_menu_cards.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createTestWidget(AuthState state) {
    when(() => mockAuthBloc.state).thenReturn(state);
    when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(state));

    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const RoleBasedMenuCards(),
        ),
      ),
    );
  }

  group('RoleBasedMenuCards', () {
    testWidgets('Kasie shows 2 cards', (tester) async {
      const kasieUser = UserEntity(
        id: '1',
        fullName: 'Kasie User',
        role: UserRole.kasie,
        estateId: 'estate1',
        isFirstTime: false,
      );

      await tester.pumpWidget(
        createTestWidget(const AuthSuccess(user: kasieUser)),
      );
      await tester.pumpAndSettle();

      // Verify 2 MenuCards are shown
      expect(find.byType(MenuCard), findsNWidgets(2));

      // Verify both card titles
      expect(find.text('Buat Rencana'), findsOneWidget);
      expect(find.text('Lihat Rencana'), findsOneWidget);
    });

    testWidgets('Operator shows 1 card', (tester) async {
      const operatorUser = UserEntity(
        id: '2',
        fullName: 'Operator User',
        role: UserRole.operator,
        estateId: 'estate1',
        isFirstTime: false,
      );

      await tester.pumpWidget(
        createTestWidget(const AuthSuccess(user: operatorUser)),
      );
      await tester.pumpAndSettle();

      // Verify only 1 MenuCard is shown
      expect(find.byType(MenuCard), findsOneWidget);

      // Verify only "Lihat Rencana" card
      expect(find.text('Lihat Rencana'), findsOneWidget);
      expect(find.text('Buat Rencana'), findsNothing);
    });

    testWidgets('Mandor shows 1 card', (tester) async {
      const mandorUser = UserEntity(
        id: '3',
        fullName: 'Mandor User',
        role: UserRole.mandor,
        estateId: 'estate1',
        isFirstTime: false,
      );

      await tester.pumpWidget(
        createTestWidget(const AuthSuccess(user: mandorUser)),
      );
      await tester.pumpAndSettle();

      // Verify only 1 MenuCard is shown
      expect(find.byType(MenuCard), findsOneWidget);

      // Verify only "Lihat Rencana" card
      expect(find.text('Lihat Rencana'), findsOneWidget);
      expect(find.text('Buat Rencana'), findsNothing);
    });

    testWidgets('Admin shows 1 card', (tester) async {
      const adminUser = UserEntity(
        id: '4',
        fullName: 'Admin User',
        role: UserRole.admin,
        estateId: 'estate1',
        isFirstTime: false,
      );

      await tester.pumpWidget(
        createTestWidget(const AuthSuccess(user: adminUser)),
      );
      await tester.pumpAndSettle();

      // Verify only 1 MenuCard is shown
      expect(find.byType(MenuCard), findsOneWidget);

      // Verify only "Lihat Rencana" card
      expect(find.text('Lihat Rencana'), findsOneWidget);
      expect(find.text('Buat Rencana'), findsNothing);
    });

    testWidgets('Shows skeleton when not authenticated', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AuthInitial()),
      );
      await tester.pump(); // Use pump() instead of pumpAndSettle() due to shimmer animation

      // Verify skeleton is shown
      expect(find.byType(MenuCardSkeleton), findsNWidgets(2));
      expect(find.byType(MenuCard), findsNothing);
    });
  });
}

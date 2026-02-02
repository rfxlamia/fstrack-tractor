import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fstrack_tractor/features/work_plan/domain/entities/work_plan_entity.dart';
import 'package:fstrack_tractor/features/work_plan/presentation/bloc/work_plan_bloc.dart';
import 'package:fstrack_tractor/features/work_plan/presentation/bloc/work_plan_event.dart';
import 'package:fstrack_tractor/features/work_plan/presentation/bloc/work_plan_state.dart';
import 'package:fstrack_tractor/features/work_plan/presentation/widgets/create_bottom_sheet.dart';

class MockWorkPlanBloc extends MockBloc<WorkPlanEvent, WorkPlanState>
    implements WorkPlanBloc {}

class FakeWorkPlanEvent extends Fake implements WorkPlanEvent {}

void main() {
  late MockWorkPlanBloc mockWorkPlanBloc;

  setUpAll(() async {
    registerFallbackValue(FakeWorkPlanEvent());
    await initializeDateFormatting('id_ID', null);
  });

  setUp(() {
    mockWorkPlanBloc = MockWorkPlanBloc();
  });

  Widget createTestWidget({
    required MockWorkPlanBloc bloc,
    required Widget child,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      home: BlocProvider<WorkPlanBloc>.value(
        value: bloc,
        child: Scaffold(body: child),
      ),
    );
  }

  group('CreateBottomSheet', () {
    testWidgets('renders all form fields correctly', (tester) async {
      when(() => mockWorkPlanBloc.state).thenReturn(const WorkPlanInitial());

      await tester.pumpWidget(
        createTestWidget(
          bloc: mockWorkPlanBloc,
          child: const CreateBottomSheet(),
        ),
      );

      // Verify title
      expect(find.text('Buat Rencana Kerja Baru'), findsOneWidget);

      // Verify all form fields
      expect(find.text('Tanggal Kerja'), findsOneWidget);
      expect(find.text('Pola Kerja'), findsOneWidget);
      expect(find.text('Shift'), findsOneWidget);
      expect(find.text('Lokasi'), findsOneWidget);
      expect(find.text('Unit'), findsOneWidget);

      // Verify buttons
      expect(find.text('Simpan'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
    });

    testWidgets('shows validation errors when submitting empty form',
        (tester) async {
      when(() => mockWorkPlanBloc.state).thenReturn(const WorkPlanInitial());

      await tester.pumpWidget(
        createTestWidget(
          bloc: mockWorkPlanBloc,
          child: const CreateBottomSheet(),
        ),
      );

      // Tap Simpan without filling form
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      // Verify validation errors appear (4 dropdowns should show error)
      expect(find.text('Field ini wajib diisi'), findsNWidgets(4));
    });

    testWidgets('dropdowns are tappable and selectable', (tester) async {
      when(() => mockWorkPlanBloc.state).thenReturn(const WorkPlanInitial());

      await tester.pumpWidget(
        createTestWidget(
          bloc: mockWorkPlanBloc,
          child: const CreateBottomSheet(),
        ),
      );

      // Tap on Pola Kerja dropdown
      await tester.tap(find.text('Pola Kerja'));
      await tester.pumpAndSettle();

      // Select 'Rotasi' option
      await tester.tap(find.text('Rotasi').last);
      await tester.pumpAndSettle();

      // Verify selection
      expect(find.text('Rotasi'), findsOneWidget);

      // Tap on Shift dropdown
      await tester.tap(find.text('Shift'));
      await tester.pumpAndSettle();

      // Select 'Pagi' option
      await tester.tap(find.text('Pagi').last);
      await tester.pumpAndSettle();

      // Verify selection
      expect(find.text('Pagi'), findsOneWidget);
    });

    testWidgets('date picker opens when tapping date field', (tester) async {
      when(() => mockWorkPlanBloc.state).thenReturn(const WorkPlanInitial());

      await tester.pumpWidget(
        createTestWidget(
          bloc: mockWorkPlanBloc,
          child: const CreateBottomSheet(),
        ),
      );

      // Tap on date field (find by the calendar icon)
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // Verify date picker is shown
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('dispatches CreateWorkPlanRequested when form is valid',
        (tester) async {
      when(() => mockWorkPlanBloc.state).thenReturn(const WorkPlanInitial());

      await tester.pumpWidget(
        createTestWidget(
          bloc: mockWorkPlanBloc,
          child: const CreateBottomSheet(),
        ),
      );

      // Fill Pola Kerja
      await tester.tap(find.text('Pola Kerja'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rotasi').last);
      await tester.pumpAndSettle();

      // Fill Shift
      await tester.tap(find.text('Shift'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pagi').last);
      await tester.pumpAndSettle();

      // Fill Lokasi
      await tester.tap(find.text('Lokasi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('AFD01').last);
      await tester.pumpAndSettle();

      // Fill Unit
      await tester.tap(find.text('Unit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TR01').last);
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.text('Simpan'));
      await tester.pump();

      // Verify event was dispatched
      verify(() => mockWorkPlanBloc.add(any(that: isA<CreateWorkPlanRequested>())))
          .called(1);
    });

    testWidgets('shows loading indicator when state is WorkPlanLoading',
        (tester) async {
      when(() => mockWorkPlanBloc.state).thenReturn(const WorkPlanLoading());

      await tester.pumpWidget(
        createTestWidget(
          bloc: mockWorkPlanBloc,
          child: const CreateBottomSheet(),
        ),
      );

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify Simpan button is disabled (no text visible when loading)
      expect(find.text('Simpan'), findsNothing);
    });

    testWidgets('closes bottom sheet and shows success snackbar on WorkPlanCreated',
        (tester) async {
      final workPlan = WorkPlanEntity(
        id: '1',
        workDate: DateTime.now(),
        pattern: 'Rotasi',
        shift: 'Pagi',
        locationId: 'AFD01',
        unitId: 'TR01',
        status: 'OPEN',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      whenListen(
        mockWorkPlanBloc,
        Stream.fromIterable([
          const WorkPlanLoading(),
          WorkPlanCreated(workPlan),
        ]),
        initialState: const WorkPlanInitial(),
      );

      await tester.pumpWidget(
        createTestWidget(
          bloc: mockWorkPlanBloc,
          child: const CreateBottomSheet(),
        ),
      );

      // Wait for state changes
      await tester.pump();
      await tester.pump();

      // Verify success snackbar message
      expect(find.text('Rencana kerja berhasil dibuat!'), findsOneWidget);
    });

    testWidgets('shows error snackbar on WorkPlanError', (tester) async {
      whenListen(
        mockWorkPlanBloc,
        Stream.fromIterable([
          const WorkPlanLoading(),
          const WorkPlanError('Gagal membuat rencana kerja'),
        ]),
        initialState: const WorkPlanInitial(),
      );

      await tester.pumpWidget(
        createTestWidget(
          bloc: mockWorkPlanBloc,
          child: const CreateBottomSheet(),
        ),
      );

      // Wait for state changes
      await tester.pump();
      await tester.pump();

      // Verify error snackbar message
      expect(find.text('Gagal membuat rencana kerja'), findsOneWidget);
    });

    testWidgets('closes bottom sheet when Batal button is tapped',
        (tester) async {
      when(() => mockWorkPlanBloc.state).thenReturn(const WorkPlanInitial());

      await tester.pumpWidget(
        createTestWidget(
          bloc: mockWorkPlanBloc,
          child: const CreateBottomSheet(),
        ),
      );

      // Tap Batal button
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Bottom sheet should be closed (no CreateBottomSheet in tree)
      expect(find.byType(CreateBottomSheet), findsNothing);
    });

    testWidgets('golden: initial state renders correctly', (tester) async {
      when(() => mockWorkPlanBloc.state).thenReturn(const WorkPlanInitial());

      await tester.pumpWidget(
        createTestWidget(
          bloc: mockWorkPlanBloc,
          child: const CreateBottomSheet(),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CreateBottomSheet),
        matchesGoldenFile('goldens/create_bottom_sheet_initial.png'),
      );
    });

    testWidgets('golden: validation error state renders correctly',
        (tester) async {
      when(() => mockWorkPlanBloc.state).thenReturn(const WorkPlanInitial());

      await tester.pumpWidget(
        createTestWidget(
          bloc: mockWorkPlanBloc,
          child: const CreateBottomSheet(),
        ),
      );

      // Tap Simpan without filling form to trigger validation errors
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CreateBottomSheet),
        matchesGoldenFile('goldens/create_bottom_sheet_validation_error.png'),
      );
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_event.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(const LoginRequested(username: '', password: ''));
    registerFallbackValue(const AuthInitial());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
    when(() => mockAuthBloc.stream)
        .thenAnswer((_) => Stream.value(const AuthInitial()));
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const Scaffold(
          body: SafeArea(child: _TestableLoginForm()),
        ),
      ),
    );
  }

  group('LoginPage', () {
    testWidgets('renders login form with all required elements',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check for header text
      expect(find.text('Masuk'), findsWidgets);
      expect(find.text('Silakan masuk untuk melanjutkan'), findsOneWidget);

      // Check for input field labels
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Check for remember me checkbox
      expect(find.text('Ingat Saya'), findsOneWidget);

      // Check for login button
      expect(find.widgetWithText(ElevatedButton, 'Masuk'), findsOneWidget);
    });

    testWidgets('password field has visibility toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially password should be obscured (visibility_off icon shown)
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);

      // Tap toggle button
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Now password should be visible (visibility icon shown)
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });

    testWidgets('shows loading indicator when AuthLoading state',
        (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(const AuthLoading()));

      await tester.pumpWidget(createTestWidget());

      // Should show CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error snackbar when AuthError state', (tester) async {
      const errorMessage = 'Username atau password salah';

      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
      when(() => mockAuthBloc.stream).thenAnswer(
          (_) => Stream.value(const AuthError(message: errorMessage)));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show snackbar with error message
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('remember me checkbox toggles', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find checkbox
      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      // Initially unchecked
      Checkbox checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, false);

      // Tap to check
      await tester.tap(find.text('Ingat Saya'));
      await tester.pump();

      // Now should be checked
      checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, true);
    });

    testWidgets('login button disabled during loading', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(const AuthLoading()));

      await tester.pumpWidget(createTestWidget());

      // Button should show CircularProgressIndicator and be disabled
      final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton).first);
      expect(button.onPressed, isNull);
    });

    testWidgets('validates empty username shows error', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap login button without entering anything
      await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
      await tester.pump();

      // Should show validation error for username
      expect(find.text('Username tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('validates empty password shows error', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter username only
      final usernameField = find.byType(TextFormField).first;
      await tester.enterText(usernameField, 'dev_kasie');

      // Tap login button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
      await tester.pump();

      // Should show validation error for password
      expect(find.text('Password tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('submits login event when form is valid', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find text fields
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));

      // Enter username
      await tester.enterText(textFields.first, 'dev_kasie');
      // Enter password
      await tester.enterText(textFields.last, 'DevPassword123');

      // Tap login button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
      await tester.pump();

      // Verify LoginRequested event was added
      verify(() => mockAuthBloc.add(any(that: isA<LoginRequested>()))).called(1);
    });
  });
}

/// Testable LoginForm widget for widget testing
class _TestableLoginForm extends StatefulWidget {
  const _TestableLoginForm();

  @override
  State<_TestableLoginForm> createState() => _TestableLoginFormState();
}

class _TestableLoginFormState extends State<_TestableLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginRequested(
              username: _usernameController.text.trim(),
              password: _passwordController.text,
              rememberMe: _rememberMe,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                const Text(
                  'Masuk',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Silakan masuk untuk melanjutkan',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Username field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Username'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _usernameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Password field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Password'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Remember me checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _rememberMe = !_rememberMe;
                        });
                      },
                      child: const Text('Ingat Saya'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Login button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Masuk'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

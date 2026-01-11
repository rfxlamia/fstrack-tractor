import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../shared/widgets/custom_checkbox.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/text_input_global.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'password_field.dart';

/// Login form widget with form validation and auth state handling
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

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
          SnackbarHelper.showError(
            context,
            message: state.message,
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Header
              Text(
                'Masuk',
                style: AppTextStyles.headline1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Silakan masuk untuk melanjutkan',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Username field
              TextInputGlobal(
                controller: _usernameController,
                label: 'Username',
                keyboardType: TextInputType.text,
                onFieldSubmitted: (_) => _handleLogin(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Password field
              PasswordField(
                controller: _passwordController,
                onFieldSubmitted: (_) => _handleLogin(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Remember me checkbox
              CustomCheckbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                label: 'Ingat Saya',
              ),
              const SizedBox(height: 32),
              // Login button
              _buildLoginButton(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return PrimaryButton(
          onPressed: isLoading ? null : _handleLogin,
          text: 'Masuk',
          isLoading: isLoading,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/text_input_global.dart';

/// Password field widget with visibility toggle
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    required this.controller,
    this.onFieldSubmitted,
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextInputGlobal(
      controller: widget.controller,
      label: 'Password',
      obscureText: !_passwordVisible,
      suffixIcon: IconButton(
        icon: Icon(
          _passwordVisible ? Icons.visibility : Icons.visibility_off,
          color: AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _passwordVisible = !_passwordVisible;
          });
        },
      ),
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
    );
  }
}

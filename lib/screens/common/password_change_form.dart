import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../utils/handle_errors.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/password_form_field.dart';

class PasswordChangeForm extends StatefulWidget {
  const PasswordChangeForm({super.key});

  @override
  _PasswordChangeFormState createState() => _PasswordChangeFormState();
}

class _PasswordChangeFormState extends State<PasswordChangeForm> {
  final _passwordFormKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _reenterPasswordController = TextEditingController();

  void _savePassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.changePassword(
          _oldPasswordController.text,
          _newPasswordController.text,
        );
        showCustomSnackBar(context, 'Password changed successfully!');
      } catch (e) {
        handleErrors(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _passwordFormKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPaddings.smallPadding),
        child: Column(
          children: [
            const SizedBox(height: 20),
            PasswordFormTextField(
              controller: _oldPasswordController,
              labelText: 'Old Password',
              prefixIcon: Icons.lock_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your old password';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            PasswordFormTextField(
              controller: _newPasswordController,
              labelText: 'New Password',
              prefixIcon: Icons.lock,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your new password';
                }
                if (!RegularExpressions.passwordRegex.hasMatch(value)) {
                  return 'Password must be at least 6 characters,\ncontain a letter, number, and special character';
                }
                if (value == _oldPasswordController.text) {
                  return 'New password cannot be the same as the old password';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            PasswordFormTextField(
              controller: _reenterPasswordController,
              labelText: 'Re-enter New Password',
              prefixIcon: Icons.lock,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please re-enter your new password';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: CustomElevatedButton(
                onPressed: _savePassword,
                text: 'Change Password',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

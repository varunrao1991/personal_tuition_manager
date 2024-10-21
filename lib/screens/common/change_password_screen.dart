import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/handle_errors.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_form_text_field.dart';
import '../../../widgets/custom_text_button.dart';
import '../../constants/app_constants.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppPaddings.smallPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              const FlutterLogo(size: 80),
              const SizedBox(height: 20),
              Text(
                'Change Password',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Set a new password to secure your account',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomFormTextField(
                      controller: _oldPasswordController,
                      labelText: 'Old Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your old password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomFormTextField(
                      controller: _newPasswordController,
                      labelText: 'New Password',
                      prefixIcon: Icons.lock,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Provide new password';
                        }
                        if (!RegularExpressions.passwordRegex.hasMatch(value)) {
                          return 'Password must be at least 6 characters,\ncontain a letter, number, and special character';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomFormTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm Password',
                      prefixIcon: Icons.lock,
                      obscureText: true,
                      validator: (value) {
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: screenWidth * 0.8,
                            child: CustomElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final oldPassword =
                                      _oldPasswordController.text;
                                  final newPassword =
                                      _newPasswordController.text;
                                  try {
                                    await authProvider.changePassword(
                                        oldPassword, newPassword);
                                    if (!authProvider.isTemporaryPassword) {
                                      Navigator.pop(context);
                                    }
                                  } catch (e) {
                                    handleErrors(context, e);
                                  }
                                }
                              },
                              text: 'Update Password',
                            ),
                          ),
                    const SizedBox(height: 20),
                    CustomTextButton(
                      text: 'Skip',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

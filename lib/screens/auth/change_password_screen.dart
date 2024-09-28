import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/roles.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_form_text_field.dart';
import '../../widgets/custom_text_button.dart';

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

  void _navigateToDashboardOrChangePassword(
      String role, bool isTemporaryPassword) {
    if (isTemporaryPassword) {
      Navigator.pushReplacementNamed(context, '/change-password');
    } else {
      final userRole = getUserRole(role);
      if (userRole == UserRole.teacher) {
        Navigator.pushReplacementNamed(context, '/teacher');
      } else if (userRole == UserRole.student) {
        Navigator.pushReplacementNamed(context, '/student');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              const FlutterLogo(size: 80),
              const SizedBox(height: 20),
              const Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Set a new password to secure your account',
                style: TextStyle(fontSize: 16, color: Colors.grey),
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
                                  await authProvider.changePassword(
                                      oldPassword, newPassword);
                                  if (!authProvider.isTemporaryPassword) {
                                    _navigateToDashboardOrChangePassword(
                                        authProvider.user!.role,
                                        authProvider.isTemporaryPassword);
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
                          Navigator.pushReplacementNamed(context, '/dashboard');
                        }),
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

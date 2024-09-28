import 'package:flutter/material.dart';
import 'package:padmayoga/widgets/custom_text_button.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/roles.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_form_text_field.dart';
import '../../widgets/custom_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isCheckingLoginStatus = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _navigateToDashboardOrChangePassword(
      String role, bool isTemporaryPassword) {
    if (isTemporaryPassword) {
      Navigator.pushReplacementNamed(context, '/change-password');
    } else {
      final userRole = getUserRole(role);
      switch (userRole) {
        case UserRole.teacher:
          Navigator.pushReplacementNamed(context, '/teacher');
          break;
        case UserRole.student:
          Navigator.pushReplacementNamed(context, '/student');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/manager');
          break;
      }
    }
  }

  Future<void> _checkLoginStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.refresh();
      if (authProvider.user != null) {
        _navigateToDashboardOrChangePassword(
            authProvider.user!.role, authProvider.isTemporaryPassword);
      } else {
        setState(() {
          _isCheckingLoginStatus = false;
        });
      }
    } catch (e) {
      setState(() {
        _isCheckingLoginStatus = false;
      });
      showCustomSnackBar(context, 'Session expired. Please log in again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (_isCheckingLoginStatus) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              const FlutterLogo(size: 100),
              const SizedBox(height: 20),
              const Text(
                'Welcome Back!',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
              const SizedBox(height: 10),
              const Text(
                'Login to your account',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomFormTextField(
                      controller: _mobileController,
                      labelText: 'Mobile Number',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length != 10) {
                          return 'Enter a valid 10-digit mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomFormTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      prefixIcon: Icons.lock,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : CustomElevatedButton(
                            text: 'Login',
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final mobile = _mobileController.text;
                                final password = _passwordController.text;
                                try {
                                  await authProvider.login(mobile, password);
                                  if (authProvider.user != null) {
                                    _navigateToDashboardOrChangePassword(
                                        authProvider.user!.role,
                                        authProvider.isTemporaryPassword);
                                  }
                                } catch (e) {
                                  showCustomSnackBar(context, e.toString());
                                }
                              }
                            },
                          ),
                    const SizedBox(height: 20),
                    CustomTextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        text: 'Forgot your password?')
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

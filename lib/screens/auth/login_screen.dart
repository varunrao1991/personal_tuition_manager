import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/custom_text_button.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/handle_errors.dart';
import '../../utils/roles.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_form_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isCheckingLoginStatus = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.loadUser();
      if (authProvider.user != null) {
        _navigateToDashboard(authProvider.user!.role);
      }
    } catch (e) {
      handleErrors(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingLoginStatus = false;
        });
      }
    }
  }

  void _navigateToDashboard(String role) {
    final userRole = getUserRole(role);
    switch (userRole) {
      case UserRole.teacher:
        Navigator.of(context).pushReplacementNamed('/teacher');
        break;
      case UserRole.student:
        Navigator.of(context).pushReplacementNamed('/student');
        break;
      default:
        Navigator.of(context).pushReplacementNamed('/manager');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: _isCheckingLoginStatus
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  SvgPicture.asset('assets/icon/app_icon.svg',
                      width: 100, height: 100),
                  const SizedBox(height: 20),
                  Text('Welcome Back!',
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 10),
                  Text(
                    'Login to your account',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 40),
                  _buildLoginForm(authProvider),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildLoginForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomFormTextField(
            controller: _mobileController,
            labelText: 'Mobile Number',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty || value.length != 10) {
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
                        _navigateToDashboard(authProvider.user!.role);
                      } catch (e) {
                        handleErrors(context, e);
                      }
                    }
                  },
                ),
          const SizedBox(height: 20),
          CustomTextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/forgot-password');
            },
            text: 'Forgot your password?',
          ),
        ],
      ),
    );
  }
}

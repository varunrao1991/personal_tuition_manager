import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_constants.dart';
import '../../exceptions/auth_exception.dart';
import '../../widgets/custom_text_button.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/handle_errors.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_form_text_field.dart';
import '../../widgets/password_form_field.dart';

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
      if (authProvider.user != null && authProvider.user!.role == 'teacher') {
        await Navigator.of(context).pushReplacementNamed('/teacher');
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          _isCheckingLoginStatus
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppPaddings.smallPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      SvgPicture.asset(
                        'assets/icon/app_icon.svg',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Welcome Back!',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 10),
                      Text('Login to teacher account',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 40),
                      _buildLoginForm(authProvider),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
        ],
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
              if (value == null || value.isEmpty) {
                return 'Enter a valid 10-digit mobile number';
              }
              if (!RegularExpressions.mobileRegex.hasMatch(value)) {
                return 'Mobile number must be exactly 10 digits and contain only numbers';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          PasswordFormTextField(
            controller: _passwordController,
            labelText: 'Password',
            prefixIcon: Icons.lock,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (!RegularExpressions.passwordRegex.hasMatch(value)) {
                return 'Password must be at least 6 characters,\ncontain a letter, number, and special character';
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
                        if (authProvider.user != null &&
                            authProvider.user!.role == 'teacher') {
                          await Navigator.of(context)
                              .pushReplacementNamed('/teacher');
                        } else {
                          throw AuthException('Could not login as teacher');
                        }
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
          const SizedBox(height: 20),
          CustomTextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            text: 'Register',
          ),
        ],
      ),
    );
  }
}

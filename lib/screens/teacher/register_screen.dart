import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_text_button.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/handle_errors.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_form_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppPaddings.smallPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                Image.asset(
                  'assets/icon/app_icon.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 20),
                Text(
                  'Create a New Account',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  'Register as a teacher',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 40),
                _buildRegisterForm(authProvider),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomFormTextField(
            controller: _nameController,
            labelText: 'Full Name',
            prefixIcon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              if (!RegularExpressions.nameRegex.hasMatch(value)) {
                return 'Name must be at least 3 characters and can contain spaces only';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomFormTextField(
            controller: _mobileController,
            labelText: 'Mobile Number',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null ||
                  !RegularExpressions.mobileRegex.hasMatch(value)) {
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
              if (!RegularExpressions.passwordRegex.hasMatch(value)) {
                return 'Password must be at least 6 characters,\ncontain a letter, number, and special character';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const CircularProgressIndicator()
              : CustomElevatedButton(
                  text: 'Register',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final name = _nameController.text;
                      final mobile = _mobileController.text;
                      final password = _passwordController.text;

                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        await authProvider.register(
                          name,
                          mobile,
                          password,
                        );
                        Navigator.of(context).pushReplacementNamed('/login');
                      } catch (e) {
                        handleErrors(context, e);
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                ),
          const SizedBox(height: 20),
          CustomTextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            text: 'Already have an account? Login',
          ),
        ],
      ),
    );
  }
}

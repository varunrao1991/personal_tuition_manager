import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yoglogonline/constants/app_constants.dart';
import '../../widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/handle_errors.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_form_text_field.dart';
import '../../widgets/custom_text_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _reEnterPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isOtpSent = false;
  bool _isLoading = false;
  int _countdown = 60;
  Timer? _timer;

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _requestOtp() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      setState(() {
        _isLoading = true;
      });
      try {
        await authProvider.requestPasswordChange(_mobileController.text);
        _isOtpSent = true;
        _startCountdown();
        showCustomSnackBar(context, 'OTP sent to your mobile number.');
      } catch (e) {
        handleErrors(context, e);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
    });
    try {
      await authProvider.changePasswordWithOTP(
        _mobileController.text,
        _otpController.text,
        _newPasswordController.text,
      );
      showCustomSnackBar(context, 'Password changed successfully.');
      Navigator.pop(context);
    } catch (e) {
      handleErrors(context, e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppPaddings.smallPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              SvgPicture.asset('assets/icon/app_icon.svg',
                  width: 100, height: 100),
              const SizedBox(height: 20),
              Text(
                'Reset Your Password',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                'Enter your details below',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.grey),
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
                        if (value == null || value.isEmpty) {
                          return 'Enter a valid mobile number';
                        }
                        if (!RegularExpressions.mobileRegex.hasMatch(value)) {
                          return 'Mobile number must be exactly 10 digits and contain only numbers';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_isOtpSent) ...[
                      CustomFormTextField(
                        controller: _otpController,
                        labelText: 'Enter OTP',
                        prefixIcon: Icons.lock,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter the OTP sent to your mobile';
                          }
                          if (!RegularExpressions.otpRegex.hasMatch(value)) {
                            return 'OTP must be exactly 4 digits and contain numbers only';
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
                            return 'Password must not be empty';
                          }
                          if (!RegularExpressions.passwordRegex
                              .hasMatch(value)) {
                            return 'Password must be at least 6 characters,\ncontain a letter, number, and special character';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomFormTextField(
                        controller: _reEnterPasswordController,
                        labelText: 'Re-enter Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please re-enter your password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : CustomElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _resetPassword();
                                }
                              },
                              text: 'Change Password',
                            ),
                      const SizedBox(height: 20),
                      if (_countdown > 0)
                        Text(
                          'Resend OTP in $_countdown seconds',
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      else
                        CustomTextButton(
                          onPressed: _requestOtp,
                          text: 'Resend OTP',
                        ),
                    ] else ...[
                      _isLoading
                          ? const CircularProgressIndicator()
                          : CustomElevatedButton(
                              onPressed: _requestOtp,
                              text: 'Request OTP',
                            ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomTextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                text: 'Back to Login',
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

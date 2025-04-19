import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../exceptions/custom_exception.dart';
import '../../providers/auth_provider.dart';
import '../../utils/handle_errors.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/custom_form_text_field.dart';

class LockPinScreen extends StatefulWidget {
  const LockPinScreen({super.key});

  @override
  State<LockPinScreen> createState() => _LockPinScreenState();
}

class _LockPinScreenState extends State<LockPinScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  bool _isLoading = false;
  bool _pinExists = false;
  String? _selectedQuestion;
  Map<String, String> _securityQuestions = {};

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _pinExists = await authProvider.doesPinExist();
    _securityQuestions = await authProvider.getSecurityQuestions();
    if (_securityQuestions.isNotEmpty) {
      _selectedQuestion = _securityQuestions.keys.first;
    }
    setState(() {});
  }

  void _clearPins() {
    _pinController.clear();
    _confirmPinController.clear();
  }

  Future<void> _handlePinEntered() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (_pinExists) {
        final isValid = await authProvider.login(_pinController.text);
        if (isValid) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          throw PinIncorrectException('Incorrect PIN');
        }
      } else {
        await _registerNewPin(authProvider);
      }
    } catch (e) {
      handleErrors(context, e);
      _clearPins();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _registerNewPin(AuthProvider authProvider) async {
    if (_selectedQuestion == null || _answerController.text.isEmpty) {
      throw CustomException('Please fill all fields', ErrorCodes.fillAll);
    }

    await authProvider.register(
      _pinController.text,
      _selectedQuestion!,
      _answerController.text,
    );

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
    showCustomSnackBar(context, 'PIN setup successfully');
  }

  String? _validatePin(String? pin) {
    if (pin == null || pin.length != 4) return 'Please enter a 4-digit PIN';
    return null;
  }

  String? _validateConfirmPin(String? pin) {
    final newPin = _pinController.text;
    if (pin == null || pin.length != 4) {
      return 'Please confirm your PIN';
    }
    if (newPin != pin) return 'PINs do not match';
    return null;
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.lock_outlined,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 32),
                Text(
                  _pinExists ? 'Enter Your PIN' : 'Set Up Your PIN',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _pinExists
                      ? 'Enter your 4-digit PIN to continue.'
                      : 'Create a secure 4-digit PIN and security question.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (!_pinExists) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedQuestion,
                    items: _securityQuestions.keys
                        .map((question) => DropdownMenuItem(
                              value: question,
                              child: Text(
                                question,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedQuestion = value),
                    decoration: InputDecoration(
                      labelText: 'Security Question',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomFormTextField(
                    controller: _answerController,
                    labelText: 'Your Answer',
                    prefixIcon: Icons.question_answer_outlined,
                    validator: (value) {
                      if (!_pinExists && (value == null || value.isEmpty)) {
                        return 'Please enter your answer';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                Text(
                  _pinExists ? 'PIN' : 'Create PIN',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 180,
                  child: TextFormField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    obscureText: true,
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 28,
                      letterSpacing: 12,
                    ),
                    validator: _validatePin,
                    onChanged: (value) {
                      if (value.length == 4 && _pinExists) {
                        _handlePinEntered();
                      } else if (value.length == 4 && !_pinExists) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                ),
                if (!_pinExists) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Confirm PIN',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 180,
                    child: TextFormField(
                      controller: _confirmPinController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      obscureText: true,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 28,
                        letterSpacing: 12,
                      ),
                      validator: _validateConfirmPin,
                      onChanged: (value) {
                        if (value.length == 4 && _formKey.currentState!.validate()) {
                          _handlePinEntered();
                        }
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                if (_isLoading)
                  const CircularProgressIndicator()
                else if (!_pinExists)
                  CustomElevatedButton(
                    text: 'Set Up PIN',
                    onPressed: _handlePinEntered,
                  ),
                if (_pinExists)
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/forgot-pin'),
                    child: Text(
                      'Forgot PIN?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../exceptions/custom_exception.dart';
import '../../providers/auth_provider.dart';
import '../../utils/handle_errors.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/custom_form_text_field.dart';

class ForgotPinScreen extends StatefulWidget {
  const ForgotPinScreen({super.key});

  @override
  State<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

class _ForgotPinScreenState extends State<ForgotPinScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedQuestion;
  Map<String, String> _securityQuestions = {}; // To hold fetched questions

  @override
  void initState() {
    super.initState();
    _loadSecurityQuestion();
  }

  Future<void> _loadSecurityQuestion() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final questions = await authProvider.getSecurityQuestions();
    if (mounted) {
      setState(() {
        _securityQuestions = questions;
        if (_securityQuestions.isNotEmpty) {
          _selectedQuestion = _securityQuestions.keys.first;
        }
      });
    }
  }

  Future<void> _resetPin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final isValid = await authProvider.verifySecurityQuestionAnswer(
        _selectedQuestion!, // Use the currently selected question
        _answerController.text,
      );

      if (!isValid) {
        throw PinSecurityAnswerNotCorrectException('Incorrect security question or answer');
      }

      final newPin = _newPinController.text;
      final confirmPin = _confirmPinController.text;
      if (newPin != confirmPin) {
        throw PinMismatchException('New PINs do not match');
      }

      await authProvider.changePin(newPin);

      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
      showCustomSnackBar(context, 'PIN reset successfully');
    } catch (e) {
      handleErrors(context, e);
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validatePin(String? pin, String errorMessage) {
    if (pin == null || pin.length != 4) return errorMessage;
    return null;
  }

  String? _validateConfirmPin(String? pin) {
    final newPin = _newPinController.text;
    if (pin == null || pin.length != 4) {
      return 'Please confirm new PIN';
    }
    if (newPin != pin) return 'PINs do not match';
    return null;
  }

  @override
  void dispose() {
    _newPinController.dispose();
    _confirmPinController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Reset PIN'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
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
                  Icons.lock_reset_outlined,
                  size: 72,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 32),
                Text(
                  'Reset Your PIN',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Please answer the security question and enter your new PIN.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a security question';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                CustomFormTextField(
                  controller: _answerController,
                  labelText: 'Your Answer',
                  prefixIcon: Icons.question_answer_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your answer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'New PIN',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 180,
                  child: TextFormField(
                    controller: _newPinController,
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
                    onChanged: (value) {
                      if (value.length == 4) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    validator: (value) => _validatePin(value, 'Please enter a 4-digit PIN'),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Confirm New PIN',
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
                    validator: (value) => _validateConfirmPin(value),
                    onChanged: (value) {
                      if (value.length == 4 && _formKey.currentState!.validate()) {
                        _resetPin();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 40),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  CustomElevatedButton(
                    text: 'Reset PIN',
                    onPressed: _resetPin,
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text('Cancel'),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
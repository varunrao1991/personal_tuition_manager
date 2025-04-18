import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../exceptions/custom_exception.dart';
import '../../providers/auth_provider.dart';
import '../../utils/handle_errors.dart';
import 'security_questions_screen.dart';

class LockPinScreen extends StatefulWidget {
  const LockPinScreen({super.key});

  @override
  State<LockPinScreen> createState() => _LockPinScreenState();
}

class _LockPinScreenState extends State<LockPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  bool _pinExists = false;
  String? _firstPinEntry;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _pinExists = await authProvider.doesPinExist();
    setState(() {});
  }

  void _clearPin() {
    _pinController.clear();
  }

  Future<void> _handlePinEntered() async {
    final pin = _pinController.text;
    if (pin.length != 4) return;

    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (_pinExists) {
        final isValid = await authProvider.login(pin);
        if (isValid) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          throw PinIncorrectException('Incorrect PIN');
        }
      } else {
        await _handleNewPinFlow(pin, authProvider);
      }
    } catch (e) {
      handleErrors(context, e);
      _clearPin();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleNewPinFlow(String pin, AuthProvider authProvider) async {
    if (_firstPinEntry == null) {
      setState(() => _firstPinEntry = pin);
      _clearPin();
      return;
    }

    if (_firstPinEntry != pin) {
      setState(() => _firstPinEntry = null);
      throw PinMismatchException('PINs do not match');
    }

    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const SecurityQuestionScreen(isInitialSetup: true),
      ),
    );

    if (result != null) {
      final question = result['question']!;
      final answer = result['answer']!;

      await authProvider.register(pin, question, answer);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _firstPinEntry = null);
      _clearPin();
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center( // Wrap the Padding widget with Center
        child: SingleChildScrollView( // Added SingleChildScrollView for potential overflow
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Make children take full width
            children: [
              Icon(
                Icons.lock_outlined,
                size: 72, // Increased icon size for better prominence
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32), // Increased spacing
              Text(
                _pinExists ? 'Enter Your PIN' : 'Set Up Your PIN',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith( // More prominent headline
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16), // Increased spacing
              Text(
                _pinExists
                    ? 'Enter your 4-digit PIN to continue.'
                    : _firstPinEntry != null
                        ? 'Enter your PIN again to confirm.'
                        : 'Create a secure 4-digit PIN.',
                style: Theme.of(context).textTheme.bodyLarge, // Slightly larger body text
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32), // Increased spacing
              SizedBox(
                width: 180, // Slightly wider input field
                child: TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  obscureText: true,
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // Slightly more rounded border
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18), // Increased padding
                  ),
                  style: const TextStyle(
                    fontSize: 28, // Larger font for PIN digits
                    letterSpacing: 12,
                  ),
                  onChanged: (value) {
                    if (value.length == 4) {
                      _handlePinEntered();
                    }
                  },
                ),
              ),
              const SizedBox(height: 40), // Increased spacing
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_pinExists)
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
    );
  }
}
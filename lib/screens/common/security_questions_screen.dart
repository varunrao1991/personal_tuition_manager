import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SecurityQuestionScreen extends StatefulWidget {
  final bool isInitialSetup;
  const SecurityQuestionScreen({super.key, this.isInitialSetup = false});

  @override
  State<SecurityQuestionScreen> createState() => _SecurityQuestionScreenState();
}

class _SecurityQuestionScreenState extends State<SecurityQuestionScreen> {
  String? _selectedQuestion;
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedQuestion = AuthService.securityQuestions.keys.first;
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isInitialSetup ? 'Security Question' : 'Verify Identity'),
        leading: widget.isInitialSetup
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedQuestion,
                  items: AuthService.securityQuestions.keys
                      .map((question) => DropdownMenuItem(
                            value: question,
                            child: Text(question),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedQuestion = value),
                  decoration: const InputDecoration(
                    labelText: 'Security Question',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _answerController,
                  decoration: const InputDecoration(
                    labelText: 'Your Answer',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedQuestion == null || _answerController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }
                    Navigator.pop(context, {
                      'question': _selectedQuestion!,
                      'answer': _answerController.text,
                    });
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

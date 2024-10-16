import 'package:flutter/material.dart';
import '../../../widgets/custom_form_date_field.dart';
import '../../../widgets/custom_form_text_field.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../models/create_payment.dart';
import '../../../models/student_model.dart';
import 'student_selection.dart';

class PaymentProcessWidget extends StatefulWidget {
  const PaymentProcessWidget({super.key});

  @override
  _PaymentProcessWidgetState createState() => _PaymentProcessWidgetState();
}

class _PaymentProcessWidgetState extends State<PaymentProcessWidget> {
  int _currentStep = 0;
  Student? _selectedStudent;
  final TextEditingController _amountController = TextEditingController();
  DateTime _paymentDate = DateTime.now();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _goToNextStep() {
    setState(() {
      _currentStep = 1;
    });
  }

  void _goToPreviousStep() {
    setState(() {
      _currentStep = 0;
    });
  }

  void _submitPayment() {
    if (_formKey.currentState!.validate()) {
      final payment = CreatePayment(
        studentId: _selectedStudent!.id,
        studentName: _selectedStudent!.name,
        amount: int.parse(_amountController.text),
        paymentDate: _paymentDate,
      );
      Navigator.of(context).pop(payment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(16.0),
        child: _currentStep == 0
            ? StudentSelector(
                selectedStudent: _selectedStudent,
                onStudentSelected: (student) {
                  setState(() {
                    _selectedStudent = student;
                  });
                  _goToNextStep();
                },
              )
            : _buildPaymentDetailsStep(),
      ),
    );
  }

  Widget _buildPaymentDetailsStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Payment Details', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            children: [
              CustomFormTextField(
                controller: TextEditingController(text: _selectedStudent?.name),
                labelText: 'Selected Student',
                readOnly: true,
                prefixIcon: Icons.person,
                validator: (value) {
                  if (_selectedStudent == null) {
                    return 'Student is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomFormTextField(
                controller: _amountController,
                labelText: 'Amount',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.money,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Amount is required';
                  }
                  final amount = int.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomDateInputField(
                selectedDate: _paymentDate,
                title: 'Payment Date',
                onDateSelected: (selectedDate) {
                  setState(() {
                    _paymentDate = selectedDate;
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomElevatedButton(
                    onPressed: _goToPreviousStep,
                    text: 'Back',
                  ),
                  CustomElevatedButton(
                    onPressed: _submitPayment,
                    text: 'Submit Payment',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

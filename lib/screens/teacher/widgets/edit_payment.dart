import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/create_payment.dart';
import '../../../providers/payment_provider.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_form_date_field.dart';
import '../../../widgets/custom_form_text_field.dart';
import '../../../widgets/custom_section_title.dart';
import '../../../widgets/custom_snackbar.dart'; // Import custom snackBar utility

class EditPaymentWidget extends StatefulWidget {
  final CreatePayment payment;

  const EditPaymentWidget({super.key, required this.payment});

  @override
  _EditPaymentWidgetState createState() => _EditPaymentWidgetState();
}

class _EditPaymentWidgetState extends State<EditPaymentWidget> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime _paymentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.payment.amount.toString();
    _paymentDate = widget.payment.paymentDate;
  }

  Future<void> _saveForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final editedPayment = CreatePayment(
        id: widget.payment.id,
        studentId: widget.payment.studentId,
        studentName: widget.payment.studentName,
        amount: int.parse(_amountController.text),
        paymentDate: _paymentDate,
      );

      try {
        await Provider.of<PaymentProvider>(context, listen: false)
            .updatePayment(editedPayment);
        showCustomSnackBar(context, 'Payment updated successfully!');
        Navigator.of(context).pop(true); // Close modal after success
      } catch (error) {
        showCustomSnackBar(context, error.toString(),
            backgroundColor: Colors.red); // Custom error message
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const CustomSectionTitle(title: 'Edit Payment'),
                const SizedBox(height: 20),
                CustomFormTextField(
                  controller:
                      TextEditingController(text: widget.payment.studentName),
                  labelText: 'Selected Student',
                  prefixIcon: Icons.person,
                  readOnly:
                      true, // Set field to read-only for existing student name
                ),
                const SizedBox(height: 16),
                CustomFormTextField(
                  controller: _amountController,
                  labelText: 'Amount',
                  prefixIcon: Icons.money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomDateInputField(
                  title: 'Payment Date',
                  selectedDate: _paymentDate,
                  onDateSelected: (date) {
                    setState(() {
                      _paymentDate = date;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CustomElevatedButton(
                  text: 'Update',
                  onPressed: () async {
                    await _saveForm(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

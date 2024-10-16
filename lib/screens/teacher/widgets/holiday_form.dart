import 'package:flutter/material.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_form_text_field.dart';
import '../../../widgets/custom_form_date_field.dart';

class HolidayForm extends StatefulWidget {
  final DateTime selectedDate;
  final String reason;

  const HolidayForm({
    super.key,
    required this.selectedDate,
    this.reason = '',
  });

  @override
  _HolidayFormState createState() => _HolidayFormState();
}

class _HolidayFormState extends State<HolidayForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reasonController.text = widget.reason;
  }

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final String reason = _reasonController.text;
      Navigator.of(context)
          .pop({'date': widget.selectedDate, 'reason': reason});
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
                Text('Add Holiday',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 20),
                CustomDateInputField(
                  title: 'Holiday Date',
                  selectedDate: widget.selectedDate,
                  onDateSelected: (date) {},
                ),
                const SizedBox(height: 16.0),
                CustomFormTextField(
                  controller: _reasonController,
                  labelText: 'Reason for Holiday',
                  prefixIcon: Icons.comment,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a reason';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                CustomElevatedButton(
                  text: 'Submit',
                  onPressed: () async {
                    await _submitForm(context);
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

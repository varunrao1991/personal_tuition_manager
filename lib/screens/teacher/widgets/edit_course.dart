import 'package:flutter/material.dart';
import '../../../models/course.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_form_text_field.dart';
import '../../../widgets/custom_form_date_field.dart';
import '../../../widgets/custom_section_title.dart';
import '../../../widgets/custom_snackbar.dart';

class EditCourseWidget extends StatefulWidget {
  final Course course;

  const EditCourseWidget({super.key, required this.course});

  @override
  _EditCourseWidgetState createState() => _EditCourseWidgetState();
}

class _EditCourseWidgetState extends State<EditCourseWidget> {
  final _formKey = GlobalKey<FormState>();
  final _totalClassesController = TextEditingController();
  DateTime? _startDate;

  @override
  void initState() {
    super.initState();
    _totalClassesController.text = widget.course.totalClasses.toString();
    _startDate = widget.course.startDate;
  }

  Future<void> _saveForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final updatedCourse = Course(
        paymentId: widget.course.paymentId,
        startDate: _startDate,
        endDate: widget.course.endDate,
        totalClasses: int.parse(_totalClassesController.text),
        payment: widget.course.payment, // No changes to the payment field
      );

      try {
        Navigator.of(context).pop(updatedCourse);
      } catch (error) {
        showCustomSnackBar(context, error.toString(),
            backgroundColor: Colors.red);
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
                const CustomSectionTitle(title: 'Edit Course'),
                const SizedBox(height: 20),
                if (_startDate != null)
                  CustomDateInputField(
                    title: 'Start Date',
                    selectedDate: _startDate!,
                    onDateSelected: (date) {
                      setState(() {
                        _startDate = date;
                      });
                    },
                  ),
                const SizedBox(height: 16),
                CustomFormTextField(
                  controller: _totalClassesController,
                  labelText: 'Total Classes',
                  prefixIcon: Icons.class_,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the total number of classes';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
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

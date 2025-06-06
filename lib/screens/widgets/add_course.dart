import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/create_course.dart';
import '../../models/owned_by.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_form_text_field.dart';
import 'payment_selection.dart';

class AddStudentCourseProcessWidget extends StatefulWidget {
  const AddStudentCourseProcessWidget({super.key});
  @override
  _AddStudentCourseProcessWidgetState createState() =>
      _AddStudentCourseProcessWidgetState();
}

class _AddStudentCourseProcessWidgetState
    extends State<AddStudentCourseProcessWidget> {
  int _currentStep = 0;
  OwnedBy? _selectedStudent;
  static const int defaultTotalClasses = 23;
  final TextEditingController _totalClassesController =
      TextEditingController(text: defaultTotalClasses.toString());
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

  void _submitCourse() {
    if (_formKey.currentState!.validate()) {
      final totalClasses = int.parse(_totalClassesController.text);
      Navigator.of(context).pop(CourseCreate(
          paymentId: _selectedStudent!.id, totalClasses: totalClasses));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.smallPadding),
        child: _currentStep == 0
            ? PaymentOwnerSelector(
                selectedPayment: _selectedStudent,
                onPaymentSelected: (student) {
                  setState(() {
                    _selectedStudent = student;
                  });
                  _goToNextStep();
                },
              )
            : _buildCourseDetailsStep(),
      ),
    );
  }

  Widget _buildCourseDetailsStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 16.0),
        Text('Course Details', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16.0),
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
              const SizedBox(height: 16.0),
              CustomFormTextField(
                controller: _totalClassesController,
                labelText: 'Classes',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.class_,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Total classes are required';
                  }
                  final totalClasses = int.tryParse(value);
                  if (totalClasses == null || totalClasses <= 0) {
                    return 'Enter a valid number of classes';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomElevatedButton(
                    onPressed: _goToPreviousStep,
                    text: 'Back',
                  ),
                  CustomElevatedButton(
                    onPressed: _submitCourse,
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

  @override
  void dispose() {
    _totalClassesController.dispose();
    super.dispose();
  }
}

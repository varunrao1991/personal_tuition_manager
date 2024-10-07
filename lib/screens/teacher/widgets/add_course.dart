import 'package:flutter/material.dart';
import 'package:padmayoga/widgets/custom_form_text_field.dart';
import 'package:padmayoga/widgets/custom_elevated_button.dart';
import '../../../models/create_course.dart';
import '../../../models/student_model.dart';
import '../../../widgets/custom_section_title.dart';
import 'student_selection.dart';

class AddStudentCourseProcessWidget extends StatefulWidget {
  const AddStudentCourseProcessWidget({super.key});

  @override
  _AddStudentCourseProcessWidgetState createState() =>
      _AddStudentCourseProcessWidgetState();
}

class _AddStudentCourseProcessWidgetState
    extends State<AddStudentCourseProcessWidget> {
  int _currentStep = 0;
  Student? _selectedStudent;
  final TextEditingController _totalClassesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

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
            : _buildCourseDetailsStep(),
      ),
    );
  }

  Widget _buildCourseDetailsStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const CustomSectionTitle(title: 'Course Details'),
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
                controller: _totalClassesController,
                labelText: 'Total Classes',
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
              const SizedBox(height: 20),
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
    _searchController.dispose();
    super.dispose();
  }
}

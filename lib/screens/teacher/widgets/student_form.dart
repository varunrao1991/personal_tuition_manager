import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/student_provider.dart';
import '../../../models/student_update.dart';
import '../../../utils/handle_errors.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_form_date_field.dart';
import '../../../widgets/custom_form_text_field.dart';
import '../../../widgets/custom_section_title.dart';
import '../../../widgets/custom_snackbar.dart';

class StudentForm extends StatefulWidget {
  final StudentUpdate? student; // Optional parameter for editing

  const StudentForm({super.key, this.student}); // Accept student for edit

  @override
  _AddStudentFormState createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<StudentForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late DateTime _dobDate;
  late DateTime _joiningDate;

  @override
  void initState() {
    super.initState();
    // Initialize fields with student data if editing, otherwise use defaults
    _nameController = TextEditingController(
      text: widget.student?.name ?? '',
    );
    _mobileController = TextEditingController(
      text: widget.student?.mobile ?? '',
    );
    _dobDate = widget.student?.dob ?? DateTime.now();
    _joiningDate = widget.student?.joiningDate ?? DateTime.now();
  }

  // Method to check if any field has changed
  bool _hasChanges() {
    return _nameController.text != widget.student?.name ||
        _mobileController.text != widget.student?.mobile ||
        _dobDate != widget.student?.dob ||
        _joiningDate != widget.student?.joiningDate;
  }

  Future<void> _saveForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (!_hasChanges()) {
        // If no changes, simply close the modal
        Navigator.of(context).pop(false);
        return;
      }

      final student = StudentUpdate(
        id: widget.student?.id,
        name: _nameController.text,
        mobile: _mobileController.text,
        dob: _dobDate,
        joiningDate: _joiningDate,
      );

      try {
        final studentProvider =
            Provider.of<StudentProvider>(context, listen: false);

        // Call update if editing, otherwise create new student
        if (widget.student != null) {
          await studentProvider.updateStudent(student);
          showCustomSnackBar(context, 'Student updated successfully!');
        } else {
          await studentProvider.createStudent(student);
          showCustomSnackBar(context, 'Student added successfully!');
        }

        Navigator.of(context).pop(true); // Close modal after success
      } catch (e) {
        handleErrors(context, e);
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
                CustomSectionTitle(
                  title:
                      widget.student != null ? 'Edit Student' : 'Add Student',
                ),
                const SizedBox(height: 20),
                CustomFormTextField(
                  controller: _nameController,
                  labelText: 'Name',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomFormTextField(
                  controller: _mobileController,
                  labelText: 'Mobile Number',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 10) {
                      return 'Enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomDateInputField(
                  title: 'Date of Birth',
                  selectedDate: _dobDate,
                  onDateSelected: (date) {
                    setState(() {
                      _dobDate = date;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CustomDateInputField(
                  title: 'Joining Date',
                  selectedDate: _joiningDate,
                  onDateSelected: (date) {
                    setState(() {
                      _joiningDate = date;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CustomElevatedButton(
                  text: widget.student != null ? 'Update' : 'Add',
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

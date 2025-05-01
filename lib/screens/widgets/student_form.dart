import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/major/student_provider.dart';
import '../../models/student_update.dart';
import '../../utils/handle_errors.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_form_text_field.dart';
import '../../widgets/custom_snackbar.dart';

class StudentForm extends StatefulWidget {
  final StudentUpdate? student;

  const StudentForm({super.key, this.student});

  @override
  _AddStudentFormState createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<StudentForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mobileController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.student?.name ?? '',
    );
    _mobileController = TextEditingController(
      text: widget.student?.mobile ?? '',
    );
  }

  bool _hasChanges() {
    return _nameController.text != widget.student?.name ||
        _mobileController.text != widget.student?.mobile;
  }

  Future<void> _saveForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (!_hasChanges()) {
        Navigator.of(context).pop(false);
        return;
      }

      final student = StudentUpdate(
        id: widget.student?.id,
        name: _nameController.text,
        mobile: _mobileController.text,
      );

      try {
        final studentProvider =
            Provider.of<StudentProvider>(context, listen: false);

        if (widget.student != null) {
          await studentProvider.updateStudent(student);
          showCustomSnackBar(context, 'Student updated successfully!');
        } else {
          await studentProvider.createStudent(student);
          showCustomSnackBar(context, 'Student added successfully!');
        }

        Navigator.of(context).pop(true);
      } catch (e) {
        handleErrors(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppPaddings.mediumPadding),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 16.0),
              Text(widget.student != null ? 'Edit Student' : 'Add Student',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16.0),
              CustomFormTextField(
                controller: _nameController,
                labelText: 'Name',
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  if (!RegularExpressions.nameRegex.hasMatch(value)) {
                    return 'Name must be at least 3 characters and can contain spaces only';
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
    );
  }
}

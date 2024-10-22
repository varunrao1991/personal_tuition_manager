import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/teacher/student_provider.dart';
import '../../../models/student_update.dart';
import '../../../utils/handle_errors.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_form_date_field.dart';
import '../../../widgets/custom_form_text_field.dart';
import '../../../widgets/custom_snackbar.dart';

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
  late DateTime _dobDate;
  late DateTime _joiningDate;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.student?.name ?? '',
    );
    _mobileController = TextEditingController(
      text: widget.student?.mobile ?? '',
    );
    _dobDate = widget.student?.dob ?? DateTime.now();
    _joiningDate = widget.student?.joiningDate ?? DateTime.now();
  }

  bool _hasChanges() {
    return _nameController.text != widget.student?.name ||
        _mobileController.text != widget.student?.mobile ||
        _dobDate != widget.student?.dob ||
        _joiningDate != widget.student?.joiningDate;
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
        dob: _dobDate,
        joiningDate: _joiningDate,
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
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppPaddings.mediumPadding),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(widget.student != null ? 'Edit Student' : 'Add Student',
                    style: Theme.of(context).textTheme.titleLarge),
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

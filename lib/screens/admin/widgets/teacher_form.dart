import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/admin/teacher_provider.dart';
import '../../../models/admin/teacher_update.dart';
import '../../../utils/handle_errors.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_form_date_field.dart';
import '../../../widgets/custom_form_text_field.dart';
import '../../../widgets/custom_snackbar.dart';

class TeacherForm extends StatefulWidget {
  final TeacherUpdate? teacher;

  const TeacherForm({super.key, this.teacher});

  @override
  _AddTeacherFormState createState() => _AddTeacherFormState();
}

class _AddTeacherFormState extends State<TeacherForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mobileController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.teacher?.name ?? '',
    );
    _mobileController = TextEditingController(
      text: widget.teacher?.mobile ?? '',
    );
  }

  bool _hasChanges() {
    return _nameController.text != widget.teacher?.name ||
        _mobileController.text != widget.teacher?.mobile;
  }

  Future<void> _saveForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (!_hasChanges()) {
        Navigator.of(context).pop(false);
        return;
      }

      final teacher = TeacherUpdate(
        id: widget.teacher?.id,
        name: _nameController.text,
        mobile: _mobileController.text,
      );

      try {
        final teacherProvider =
            Provider.of<TeacherProvider>(context, listen: false);

        if (widget.teacher != null) {
          await teacherProvider.updateTeacher(teacher);
          showCustomSnackBar(context, 'Teacher updated successfully!');
        } else {
          await teacherProvider.createTeacher(teacher);
          showCustomSnackBar(context, 'Teacher added successfully!');
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
                Text(widget.teacher != null ? 'Edit Teacher' : 'Add Teacher',
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
                CustomElevatedButton(
                  text: widget.teacher != null ? 'Update' : 'Add',
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

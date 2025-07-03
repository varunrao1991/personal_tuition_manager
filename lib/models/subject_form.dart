import 'package:flutter/material.dart';
import 'package:personal_tuition_manager/models/subject.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/major/subject_provider.dart';
import '../../utils/handle_errors.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_form_text_field.dart';
import '../../widgets/custom_snackbar.dart';

class SubjectForm extends StatefulWidget {
  final SubjectUpdate? subject;

  const SubjectForm({super.key, this.subject});

  @override
  _SubjectFormState createState() => _SubjectFormState();
}

class _SubjectFormState extends State<SubjectForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject?.name ?? '');
    _descriptionController = TextEditingController(text: widget.subject?.description ?? '');
  }

  bool _hasChanges() {
    return _nameController.text != widget.subject?.name ||
        _descriptionController.text != widget.subject?.description;
  }

  Future<void> _saveForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (!_hasChanges()) {
        Navigator.of(context).pop(false);
        return;
      }

      final subject = SubjectUpdate(
        id: widget.subject?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      try {
        final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);

        if (widget.subject != null) {
          await subjectProvider.updateSubject(subject);
          showCustomSnackBar(context, 'Subject updated successfully!');
        } else {
          await subjectProvider.createSubject(subject);
          showCustomSnackBar(context, 'Subject added successfully!');
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
              Text(widget.subject != null ? 'Edit Subject' : 'Add Subject',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16.0),
              CustomFormTextField(
                controller: _nameController,
                labelText: 'Subject Name',
                prefixIcon: Icons.book,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the subject name';
                  }
                  if (value.trim().length < 3) {
                    return 'Subject name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomFormTextField(
                controller: _descriptionController,
                labelText: 'Description (optional)',
                prefixIcon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CustomElevatedButton(
                text: widget.subject != null ? 'Update' : 'Add',
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

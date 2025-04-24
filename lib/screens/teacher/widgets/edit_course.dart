import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_form_text_field.dart';

class EditCourseWidget extends StatefulWidget {
  final int totalClasses;

  const EditCourseWidget({super.key, required this.totalClasses});

  @override
  _EditCourseWidgetState createState() => _EditCourseWidgetState();
}

class _EditCourseWidgetState extends State<EditCourseWidget> {
  final _formKey = GlobalKey<FormState>();
  final _totalClassesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _totalClassesController.text = widget.totalClasses.toString();
  }

  Future<void> _saveForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final totalClasses = int.parse(_totalClassesController.text);
      Navigator.of(context).pop(totalClasses);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppPaddings.smallPadding),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 16.0),
                Text('Edit Course',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16.0),
                CustomFormTextField(
                  controller: _totalClassesController,
                  labelText: 'Classes',
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
                const SizedBox(height: 16.0),
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

  @override
  void dispose() {
    _totalClassesController.dispose();
    super.dispose();
  }
}

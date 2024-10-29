import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/profile_update.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/handle_errors.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_form_text_field.dart';
import '../../widgets/custom_snackbar.dart';

class PersonalInfoForm extends StatefulWidget {
  const PersonalInfoForm({super.key});

  @override
  _PersonalInfoFormState createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  User? _originalUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _originalUser = user;
      _nameController.text = user.name;
      _mobileController.text = user.mobile;
    }
  }

  void _savePersonalInfo() async {
    if (_formKey.currentState!.validate()) {
      ProfileUpdate profileUpdate = ProfileUpdate(
        name: _nameController.text != _originalUser!.name
            ? _nameController.text
            : null,
        mobile: _mobileController.text != _originalUser!.mobile
            ? _mobileController.text
            : null,
      );

      if (profileUpdate.toJson().isNotEmpty) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        try {
          await authProvider.changeProfileInfo(profileUpdate);
          showCustomSnackBar(context, 'Personal info updated successfully!');
        } catch (e) {
          handleErrors(context, e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPaddings.smallPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            CustomFormTextField(
              controller: _mobileController,
              labelText: 'Mobile',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your mobile number';
                }
                if (!RegularExpressions.mobileRegex.hasMatch(value)) {
                  return 'Mobile number must be exactly 10 digits and contain only numbers';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: CustomElevatedButton(
                onPressed: _savePersonalInfo,
                text: 'Save Personal Info',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

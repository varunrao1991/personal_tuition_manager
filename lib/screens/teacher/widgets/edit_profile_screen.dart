import 'package:flutter/material.dart';
import 'package:padmayoga/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/profile_update.dart';
import '../../../models/user_model.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_form_text_field.dart';
import '../../../widgets/custom_snackbar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dobController = TextEditingController();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _reenterPasswordController = TextEditingController();

  DateTime? _selectedDob;
  User? _originalUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _originalUser = user;
      _nameController.text = user.name;
      _mobileController.text = user.mobile;
      _selectedDob = user.dob;
      _dobController.text = DateFormat('yyyy-MM-dd').format(_selectedDob!);
    }
  }

  Future<void> _selectDob(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(_selectedDob!);
      });
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
        dob: _selectedDob != null &&
                DateFormat('yyyy-MM-dd').format(_selectedDob!) !=
                    DateFormat('yyyy-MM-dd').format(_originalUser!.dob)
            ? DateFormat('yyyy-MM-dd').format(_selectedDob!)
            : null,
      );

      if (profileUpdate.toJson().isNotEmpty) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        try {
          await authProvider.changeProfileInfo(profileUpdate);
          showCustomSnackBar(context, 'Personal info updated successfully!');
        } catch (error) {
          showCustomSnackBar(context, 'Error updating profile: $error');
        }
      } else {
        showCustomSnackBar(context, 'No changes detected.');
      }
    }
  }

  void _savePassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.changePassword(
          _oldPasswordController.text,
          _newPasswordController.text,
        );
        showCustomSnackBar(context, 'Password changed successfully!');
      } catch (error) {
        showCustomSnackBar(context, 'Error changing password: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Personal Info'),
            Tab(text: 'Change Password'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Name field using Custom Form Text Field
                  CustomFormTextField(
                    controller: _nameController,
                    labelText: 'Name',
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Mobile field using Custom Form Text Field
                  CustomFormTextField(
                    controller: _mobileController,
                    labelText: 'Mobile',
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      if (value.length != 10) {
                        return 'Mobile number must be 10 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Date of Birth field using Custom Form Text Field
                  CustomFormTextField(
                    controller: _dobController,
                    labelText: 'Date of Birth',
                    prefixIcon: Icons.calendar_today,
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your date of birth';
                      }
                      return null;
                    },
                    onTap: () => _selectDob(context),
                  ),
                  const SizedBox(height: 30),

                  // Save Changes button for Personal Info
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
          ),

          // Change Password Tab
          Form(
            key: _passwordFormKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Old Password field using Custom Form Text Field
                  CustomFormTextField(
                    controller: _oldPasswordController,
                    labelText: 'Old Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your old password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // New Password field using Custom Form Text Field
                  CustomFormTextField(
                    controller: _newPasswordController,
                    labelText: 'New Password',
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your new password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Re-enter New Password field using Custom Form Text Field
                  CustomFormTextField(
                    controller: _reenterPasswordController,
                    labelText: 'Re-enter New Password',
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please re-enter your new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Save Changes button for Password
                  SizedBox(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      onPressed: _savePassword,
                      text: 'Change Password',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

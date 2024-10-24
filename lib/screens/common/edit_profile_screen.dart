import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../models/profile_update.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/handle_errors.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_form_text_field.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/navigation_bar.dart';
import '../../widgets/password_form_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _reenterPasswordController = TextEditingController();

  User? _originalUser;
  int _selectedIndex = 0;

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

  void _savePassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.changePassword(
          _oldPasswordController.text,
          _newPasswordController.text,
        );
        showCustomSnackBar(context, 'Password changed successfully!');
      } catch (e) {
        handleErrors(context, e);
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildPersonalInfoForm(),
      _buildPasswordForm(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
        navItems: const [
          NavItem(icon: Icons.person, label: 'Personal Info'),
          NavItem(icon: Icons.lock, label: 'Change Password'),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
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

  Widget _buildPasswordForm() {
    return Form(
      key: _passwordFormKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPaddings.smallPadding),
        child: Column(
          children: [
            const SizedBox(height: 20),
            PasswordFormTextField(
              controller: _oldPasswordController,
              labelText: 'Old Password',
              prefixIcon: Icons.lock_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your old password';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            PasswordFormTextField(
              controller: _newPasswordController,
              labelText: 'New Password',
              prefixIcon: Icons.lock,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your new password';
                }
                if (!RegularExpressions.passwordRegex.hasMatch(value)) {
                  return 'Password must be at least 6 characters,\ncontain a letter, number, and special character';
                }
                if (value == _oldPasswordController.text) {
                  return 'New password cannot be the same as the old password';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            PasswordFormTextField(
              controller: _reenterPasswordController,
              labelText: 'Re-enter New Password',
              prefixIcon: Icons.lock,
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
    );
  }
}

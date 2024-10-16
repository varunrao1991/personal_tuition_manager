import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/profile_update.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/handle_errors.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalInfoForm(),
          _buildPasswordForm(),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Personal Info', icon: Icon(Icons.person)),
          Tab(text: 'Change Password', icon: Icon(Icons.lock)),
        ],
        indicatorColor: Theme.of(context).colorScheme.primary,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Colors.grey,
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                if (value.length != 10) {
                  return 'Mobile number must be 10 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
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

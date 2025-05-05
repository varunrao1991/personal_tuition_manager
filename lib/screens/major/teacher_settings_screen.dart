import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/major/teacher_settings_provider.dart';
import '../../utils/handle_errors.dart';
import '../../utils/show_custom_center_modal.dart';
import '../../widgets/confirmation_modal.dart';
import '../../widgets/custom_fab.dart';
import '../../widgets/custom_snackbar.dart';
import '../widgets/image_picker_modal.dart';

class TeacherSettingsScreen extends StatefulWidget {
  const TeacherSettingsScreen({super.key});

  @override
  _TeacherSettingsScreenState createState() => _TeacherSettingsScreenState();
}

class _TeacherSettingsScreenState extends State<TeacherSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _receiptHeaderController;
  late TextEditingController _receiptFooterController;
  late TextEditingController _currencyController;
  late TextEditingController _termsController;

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _receiptHeaderController.dispose();
    _receiptFooterController.dispose();
    _currencyController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    final provider =
        Provider.of<TeacherSettingsProvider>(context, listen: false);
    _nameController = TextEditingController(text: provider.teacherName);
    _phoneController = TextEditingController(text: provider.phone);
    _emailController = TextEditingController(text: provider.email);
    _addressController = TextEditingController(text: provider.address);
    _receiptHeaderController =
        TextEditingController(text: provider.receiptHeader);
    _receiptFooterController =
        TextEditingController(text: provider.receiptFooter);
    _currencyController = TextEditingController(text: provider.currencySymbol);
    _termsController = TextEditingController(text: provider.terms);
  }

  Future<void> _loadSettings() async {
    _setLoading(true);
    try {
      await Provider.of<TeacherSettingsProvider>(context, listen: false)
          .loadSettings();
      _initializeControllers(); // Refresh controllers with loaded data
    } catch (e) {
      handleErrors(context, e);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _initializeControllers(); // Reset to original values when canceling edit
      }
    });
  }

  Future<void> _updateLogo() async {
    final result = await showImagePickerModal(context);
    if (result != null) {
      _setLoading(true);
      try {
        final imageBytes = await _getImageBytes(result);
        if (imageBytes != null) {
          await Provider.of<TeacherSettingsProvider>(context, listen: false)
              .updateLogo(imageBytes);
        }
      } catch (e) {
        handleErrors(context, e);
      } finally {
        _setLoading(false);
      }
    }
  }

  Future<void> _updateSignature() async {
    final result = await showImagePickerModal(context);
    if (result != null) {
      _setLoading(true);
      try {
        final imageBytes = await _getImageBytes(result);
        if (imageBytes != null) {
          await Provider.of<TeacherSettingsProvider>(context, listen: false)
              .updateSignature(imageBytes);
        }
      } catch (e) {
        handleErrors(context, e);
      } finally {
        _setLoading(false);
      }
    }
  }

  Future<Uint8List?> _getImageBytes(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      return await pickedFile.readAsBytes();
    }
    return null;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    _setLoading(true);
    try {
      final provider =
          Provider.of<TeacherSettingsProvider>(context, listen: false);

      // Update basic info
      await provider.updateBasicInfo(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
      );

      // Update receipt settings
      await provider.updateReceiptSettings(
        header: _receiptHeaderController.text,
        footer: _receiptFooterController.text,
        currencySymbol: _currencyController.text,
        terms: _termsController.text,
      );

      _toggleEditing();
      showCustomSnackBar(context, 'Settings updated successfully');
    } catch (e) {
      handleErrors(context, e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showCustomDialog(
      context: context,
      child: const ConfirmationDialog(
        message: 'Reset all settings to default values?',
        confirmButtonText: 'Reset',
        cancelButtonText: 'Cancel',
        confirmButtonColor: Colors.redAccent,
      ),
    );

    if (confirmed == true) {
      _setLoading(true);
      try {
        await Provider.of<TeacherSettingsProvider>(context, listen: false)
            .resetSettings();
        _initializeControllers();
        showCustomSnackBar(context, 'Settings reset to defaults');
      } catch (e) {
        handleErrors(context, e);
      } finally {
        _setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Teacher Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditing,
            )
          else
            TextButton(
              onPressed: _toggleEditing,
              child: const Text('Cancel'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<TeacherSettingsProvider>(
              builder: (context, provider, child) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppPaddings.mediumPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Profile Section
                        _buildSectionHeader('Profile Information'),
                        const SizedBox(height: 16),
                        _buildImagePickerSection(provider),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: _nameController,
                          label: 'Name',
                          icon: Icons.person,
                          enabled: _isEditing,
                        ),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          enabled: _isEditing,
                        ),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          enabled: _isEditing,
                        ),
                        _buildTextField(
                          controller: _addressController,
                          label: 'Address',
                          icon: Icons.location_on,
                          maxLines: 2,
                          enabled: _isEditing,
                        ),

                        // Receipt Settings Section
                        _buildSectionHeader('Receipt Settings'),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _receiptHeaderController,
                          label: 'Receipt Header',
                          icon: Icons.title,
                          enabled: _isEditing,
                        ),
                        _buildTextField(
                          controller: _receiptFooterController,
                          label: 'Receipt Footer',
                          icon: Icons.notes,
                          maxLines: 3,
                          enabled: _isEditing,
                        ),
                        _buildTextField(
                          controller: _currencyController,
                          label: 'Currency Symbol',
                          icon: Icons.currency_rupee,
                          enabled: _isEditing,
                        ),
                        _buildTextField(
                          controller: _termsController,
                          label: 'Terms & Conditions',
                          icon: Icons.description,
                          maxLines: 4,
                          enabled: _isEditing,
                        ),

                        if (_isEditing) ...[
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _saveChanges,
                            child: const Text('Save Changes'),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: _resetToDefaults,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Reset to Defaults'),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: _isEditing
          ? null
          : CustomFAB(
              icon: Icons.edit,
              onPressed: _toggleEditing,
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildImagePickerSection(TeacherSettingsProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: _isEditing ? _updateLogo : null,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: provider.logo != null
                    ? ClipOval(
                        child: Image.memory(
                          provider.logo!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Theme.of(context).hintColor,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Logo',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        Column(
          children: [
            GestureDetector(
              onTap: _isEditing ? _updateSignature : null,
              child: Container(
                width: 100,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: provider.signature != null
                    ? Image.memory(
                        provider.signature!,
                        fit: BoxFit.contain,
                      )
                    : Icon(
                        Icons.draw,
                        size: 40,
                        color: Theme.of(context).hintColor,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Signature',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          enabled: enabled,
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        enabled: enabled,
        validator: (value) {
          if (label == 'Name' && (value == null || value.isEmpty)) {
            return 'Please enter your name';
          }
          return null;
        },
      ),
    );
  }
}

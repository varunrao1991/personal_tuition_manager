import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../utils/handle_errors.dart';
import '../../widgets/custom_snackbar.dart';
import 'image_cropper.dart';
import 'package:path/path.dart' as path;

class ProfilePictureEditor extends StatefulWidget {
  const ProfilePictureEditor({super.key});

  @override
  _ProfilePictureEditorState createState() => _ProfilePictureEditorState();
}

class _ProfilePictureEditorState extends State<ProfilePictureEditor> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLargeImage();
    });
  }

  Future<void> _fetchLargeImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.largeImage == null) {
        await authProvider.loadMyLargeImage();
      }
    } catch (e) {
      handleErrors(context, e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _requestPermissions() async {
    final storagePermission = await Permission.storage.request();

    if (storagePermission.isGranted) {
      return true;
    }

    if (storagePermission.isDenied) {
      showCustomSnackBar(context,
          'This app needs access to your photos and storage to upload a profile picture.');
    } else if (storagePermission.isPermanentlyDenied) {
      showCustomSnackBar(context,
          'You have permanently denied access to photos or storage. Please enable them in the app settings to upload a profile picture.');
    }
    return false;
  }

  Future<void> _pickImage() async {
    final permissionGranted = await _requestPermissions();

    if (!permissionGranted) {
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final croppedImage = await _cropImage(pickedFile.path);
      if (croppedImage != null) {
        String? mimeType;
        final fileExtension = path.extension(croppedImage.path);
        if (fileExtension.toLowerCase() == '.jpg' ||
            fileExtension.toLowerCase() == '.jpeg') {
          mimeType = 'image/jpeg';
        } else if (fileExtension.toLowerCase() == '.png') {
          mimeType = 'image/png';
        }
        try {
          if (mimeType != null) {
            Uint8List imageData = await croppedImage.readAsBytes();
            await Provider.of<AuthProvider>(context, listen: false)
                .uploadProfilePicture(
                    imageData, fileExtension.toLowerCase(), mimeType);
            showCustomSnackBar(
                context, 'Profile picture updated successfully!');
          } else {
            showCustomSnackBar(context, "Image type can only be png or jpg");
          }
        } catch (e) {
          handleErrors(context, e);
        }
      }
    }
  }

  Future<CroppedFile?> _cropImage(String imagePath) async {
    try {
      return await cropImageWithCustomRatio(
          imagePath: imagePath, context: context);
    } catch (e) {
      log("Error cropping image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: Form(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppPaddings.smallPadding),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 100,
                      backgroundImage: authProvider.largeImage != null
                          ? MemoryImage(authProvider.largeImage!)
                          : null,
                      child: authProvider.largeImage == null
                          ? const Icon(Icons.person,
                              size: 50, color: Colors.grey)
                          : null,
                    ),
                    if (_isLoading) // Show loading indicator only on avatar
                      const Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: theme.colorScheme.primary,
                          child:
                              const Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

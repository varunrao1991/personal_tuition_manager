import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (1, 1);

  @override
  String get name => '1:1';
}

Future<CroppedFile?> cropImageWithCustomRatio({
  required String imagePath,
  required BuildContext context,
}) async {
  final theme = Theme.of(context);
  return await ImageCropper().cropImage(
    sourcePath: imagePath,
    maxWidth: 300,
    maxHeight: 300,
    aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    uiSettings: [
      if (theme.platform == TargetPlatform.android)
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: theme.colorScheme.primary,
          toolbarWidgetColor: theme.colorScheme.onPrimary,
        ),
      if (theme.platform == TargetPlatform.iOS)
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        ),
      if (theme.platform == TargetPlatform.fuchsia ||
          theme.platform == TargetPlatform.linux ||
          theme.platform == TargetPlatform.windows ||
          theme.platform == TargetPlatform.macOS)
        WebUiSettings(
          context: context,
        ),
    ],
  );
}

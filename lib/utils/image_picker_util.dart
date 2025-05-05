import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickImage(ImageSource source) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(
    source: source,
    imageQuality: 85,
    maxWidth: 800,
  );

  if (pickedFile != null) {
    return await pickedFile.readAsBytes();
  }
  return null;
}
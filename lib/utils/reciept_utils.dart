import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/fetch_payment.dart';
import '../../providers/major/teacher_settings_provider.dart';

class ReceiptWidget extends StatelessWidget {
  final Payment payment;
  final TeacherSettingsProvider teacher;
  final GlobalKey receiptKey = GlobalKey(); // Add a GlobalKey to the widget

  ReceiptWidget({
    super.key,
    required this.payment,
    required this.teacher,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');

    return LayoutBuilder(
      // Use LayoutBuilder to get the available width
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          // Make the entire receipt scrollable vertically
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  // Constrain the maximum width of the content
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment
                        .stretch, // Use stretch for maximum width
                    children: [
                      // Header Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .stretch, // Make children take full width
                        children: [
                          // Receipt Title at the top, centered
                          Text(
                            teacher.receiptHeader.isNotEmpty
                                ? teacher.receiptHeader.toUpperCase()
                                : 'PAYMENT RECEIPT',
                            style: theme.textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                          const SizedBox(height: 8),

                          // Logo below the title, centered
                          if (teacher.logo != null)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: SizedBox(
                                  height: 60,
                                  child: Image.memory(teacher.logo!,
                                      fit: BoxFit.contain),
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),

                          // Business Info (Name, Address, Phone, Email)
                          if (teacher.teacherName.isNotEmpty)
                            Text(
                              teacher.teacherName,
                              style: theme.textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.secondary,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          if (teacher.address.isNotEmpty)
                            Text(
                              teacher.address,
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          if (teacher.phone.isNotEmpty)
                            Text(
                              'Phone: ${teacher.phone}',
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          if (teacher.email.isNotEmpty)
                            Text(
                              'Email: ${teacher.email}',
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          const SizedBox(height: 16),
                          const Divider(thickness: 1.5),
                          const SizedBox(height: 16),
                        ],
                      ),

                      // Receipt Details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Receipt ID:',
                              style: theme.textTheme.titleMedium),
                          Flexible(
                              child: Text('#${payment.id}',
                                  style: theme.textTheme.titleMedium,
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Date:', style: theme.textTheme.bodyLarge),
                          Flexible(
                              child: Text(
                                  dateFormat
                                      .format(payment.paymentDate.toLocal()),
                                  style: theme.textTheme.bodyLarge,
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Payment Details',
                        style: theme.textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Align top for wrapping
                        children: [
                          Expanded(
                              child: Text('Student:',
                                  style: theme.textTheme.bodyLarge)),
                          Expanded(
                            child: Text(
                              payment.studentFrom.name,
                              style: theme.textTheme.bodyLarge,
                              textAlign: TextAlign.end,
                              overflow: TextOverflow
                                  .ellipsis, // Handle long student names
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Amount:', style: theme.textTheme.bodyLarge),
                          Text(
                            '${teacher.currencySymbol}${payment.amount.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(thickness: 1.5),
                      const SizedBox(height: 12),

                      // Footer Section
                      if (teacher.terms.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Terms & Conditions:',
                                style: theme.textTheme.bodySmall),
                            Text(
                              teacher.terms,
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      if (teacher.signature != null)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            height: 40,
                            child: Image.memory(teacher.signature!,
                                fit: BoxFit.contain),
                          ),
                        ),
                      if (teacher.receiptFooter.isNotEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              teacher.receiptFooter,
                              style: theme.textTheme.bodySmall!.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<Uint8List?> captureReceiptImage(GlobalKey key) async {
  try {
    await Future.delayed(const Duration(milliseconds: 300));
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      debugPrint('Error: Could not find RenderRepaintBoundary');
      return null;
    }
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  } catch (e) {
    debugPrint('Error capturing receipt image: $e');
    return null;
  }
}

Future<File?> saveImageToFile(Uint8List imageBytes) async {
  try {
    final directory = await getTemporaryDirectory();
    final filePath =
        '${directory.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);
    return file;
  } catch (e) {
    debugPrint('Error saving image to file: $e');
    return null;
  }
}

Future<void> shareReceiptImage(Payment payment, TeacherSettingsProvider teacher,
    BuildContext context) async {
  if (teacher.teacherName.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please set teacher details first.')),
    );
    return;
  }

  final key = GlobalKey();
  bool dialogOpen = true;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Dialog(
      child: SingleChildScrollView(
        // Make the dialog content scrollable
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              key: key,
              child: ReceiptWidget(payment: payment, teacher: teacher),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Preparing receipt...'),
          ],
        ),
      ),
    ),
  );

  try {
    final imageBytes = await captureReceiptImage(key);
    if (imageBytes == null) {
      if (dialogOpen) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create receipt image.')),
      );
      return;
    }

    final file = await saveImageToFile(imageBytes);
    if (file == null) {
      if (dialogOpen) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save receipt image.')),
      );
      return;
    }

    if (dialogOpen) {
      Navigator.pop(context);
      dialogOpen = false;
    }

    final xFile = XFile(file.path);
    await SharePlus.instance.share(
      ShareParams(files: [xFile]),
    );
  } catch (e) {
    if (dialogOpen) Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error sharing receipt: $e')),
    );
  }
}

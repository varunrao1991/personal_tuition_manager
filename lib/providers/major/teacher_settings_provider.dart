import 'dart:typed_data';
import 'dart:developer';
import 'package:flutter/material.dart';

import '../../services/teacher_settings_service.dart';

class TeacherSettingsProvider with ChangeNotifier {
  TeacherSettingsProvider(this._teacherService);

  final TeacherSettingsService _teacherService;

  bool _isLoading = false;
  Map<String, dynamic> _settings = {};
  Uint8List? _logo;
  Uint8List? _signature;

  Map<String, dynamic> get settings => _settings;
  Uint8List? get logo => _logo;
  Uint8List? get signature => _signature;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadSettings() async {
    _setLoading(true);
    try {
      _settings = await _teacherService.getSettings();
      _logo = await _teacherService.getLogo();
      _signature = await _teacherService.getSignature();
      log('Teacher settings loaded successfully');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateBasicInfo({
    String? name,
    String? phone,
    String? email,
    String? address,
  }) async {
    _setLoading(true);
    try {
      await _teacherService.updateBasicInfo(
        name: name,
        phone: phone,
        email: email,
        address: address,
      );
      await loadSettings(); // Refresh local state
      log('Teacher basic info updated');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateReceiptSettings({
    String? header,
    String? footer,
    String? currencySymbol,
    String? terms,
  }) async {
    _setLoading(true);
    try {
      await _teacherService.updateReceiptSettings(
        header: header,
        footer: footer,
        currencySymbol: currencySymbol,
        terms: terms,
      );
      await loadSettings(); // Refresh local state
      log('Receipt settings updated');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateLogo(Uint8List logoBytes) async {
    _setLoading(true);
    try {
      await _teacherService.updateLogo(logoBytes);
      _logo = logoBytes; // Update local state immediately
      log('Logo updated successfully');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateSignature(Uint8List signatureBytes) async {
    _setLoading(true);
    try {
      await _teacherService.updateSignature(signatureBytes);
      _signature = signatureBytes; // Update local state immediately
      log('Signature updated successfully');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetSettings() async {
    _setLoading(true);
    try {
      await _teacherService.resetAllSettings();
      await loadSettings(); // Refresh all local state
      log('All settings reset to defaults');
    } finally {
      _setLoading(false);
    }
  }

  // New function to check if there are any details
  bool get hasDetails {
    return teacherName.isNotEmpty ||
        phone.isNotEmpty ||
        email.isNotEmpty ||
        address.isNotEmpty ||
        receiptHeader != 'PAYMENT RECEIPT' ||
        receiptFooter.isNotEmpty ||
        currencySymbol != '₹' ||
        terms.isNotEmpty ||
        logo != null ||
        signature != null;
  }

  // Convenience getters
  String get teacherName => _settings['name'] ?? '';
  String get phone => _settings['phone'] ?? '';
  String get email => _settings['email'] ?? '';
  String get address => _settings['address'] ?? '';
  String get receiptHeader => _settings['receiptHeader'] ?? 'PAYMENT RECEIPT';
  String get receiptFooter => _settings['receiptFooter'] ?? '';
  String get currencySymbol => _settings['currencySymbol'] ?? '₹';
  String get terms => _settings['terms'] ?? '';
}
import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/create_payment.dart';
import '../models/fetch_payment.dart';
import '../services/payment_service.dart';
import '../services/token_service.dart';

class PaymentProvider with ChangeNotifier {
  PaymentProvider(this._paymentService, this._tokenService);

  final PaymentService _paymentService;
  final TokenService _tokenService;

  bool _isLoading = false;
  List<Payment> _payments = [];
  int _currentPage = 1;
  int _totalPages = 1;
  Map<int, double> _cachedDailyTotals = {};

  Map<int, double> get dailyTotals => _cachedDailyTotals;

  String? _cachedSort;
  String? _cachedOrder;
  DateTime? _cachedStartDate;
  DateTime? _cachedEndDate;

  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String? get cachedSort => _cachedSort;
  String? get cachedOrder => _cachedOrder;
  DateTime? get cachedStartDate => _cachedStartDate;
  DateTime? get cachedEndDate => _cachedEndDate;

  void clearData() {
    _setLoading(true);
    _payments = [];
    _currentPage = 1;
    _totalPages = 1;
    _cachedDailyTotals = {};
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchPayments({
    int? page,
    String? sort,
    String? order,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);

    _cachedSort = sort ?? _cachedSort;
    _cachedOrder = order ?? _cachedOrder;
    _cachedStartDate = startDate ?? _cachedStartDate;
    _cachedEndDate = endDate ?? _cachedEndDate;

    try {
      final String accessToken = await _tokenService.getToken();
      final PaymentResponse response = await _paymentService.getPayments(
        accessToken: accessToken,
        page: page ?? _currentPage,
        sort: _cachedSort,
        order: _cachedOrder,
        startDate: _cachedStartDate,
        endDate: _cachedEndDate,
      );

      if (page == 1 || page == null) {
        _payments = response.payments;
      } else {
        _payments.addAll(response.payments);
      }

      _currentPage = response.currentPage;
      _totalPages = response.totalPages;
      log('Payments successfully fetched for $_currentPage: ${response.payments.length}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetAndFetch({
    String? sort,
    String? order,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _currentPage = 1;
    await fetchPayments(
      page: 1,
      sort: sort,
      order: order,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<void> addPayment(CreatePayment createPayment) async {
    _setLoading(true);

    try {
      final String accessToken = await _tokenService.getToken();
      await _paymentService.addPayment(
        accessToken: accessToken,
        createPayment: createPayment,
      );
      log('Payment successfully added.');
      await resetAndFetch();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePayment(CreatePayment payment) async {
    _setLoading(true);

    try {
      final String accessToken = await _tokenService.getToken();
      await _paymentService.updatePayment(
        accessToken: accessToken,
        updatePayment: payment,
      );
      log('Payment successfully updated.');
      await resetAndFetch();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchDailyTotalPayments(DateTime monthToFetch) async {
    _setLoading(true);
    try {
      DateTime startDate = DateTime(monthToFetch.year, monthToFetch.month, 1);
      DateTime endDate = DateTime(monthToFetch.year, monthToFetch.month + 1, 0);

      final String accessToken = await _tokenService.getToken();

      _cachedDailyTotals = await _paymentService.getDailyTotalPayments(
        accessToken: accessToken,
        startDate: startDate,
        endDate: endDate,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePayment(int paymentId) async {
    _setLoading(true);
    try {
      final String accessToken = await _tokenService.getToken();
      await _paymentService.deletePayment(
        accessToken: accessToken,
        paymentId: paymentId,
      );
      log('Payment successfully deleted.');
      await resetAndFetch();
    } finally {
      _setLoading(false);
    }
  }
}

import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/create_payment.dart';
import '../models/daily_total.dart';
import '../models/fetch_payment.dart';
import '../services/payment_service.dart';
import '../services/token_service.dart';
import '../exceptions/payment_exception.dart';

class PaymentProvider with ChangeNotifier {
  List<Payment> _payments = [];
  bool _isLoading = false;
  final PaymentService _paymentService;
  final TokenService _tokenService;
  int _currentPage = 1;
  int _totalPages = 1;

  DateTime? _cachedMonth; // Cached month
  List<DailyTotal> _cachedDailyTotals = []; // Cached daily totals

  List<DailyTotal> get dailyTotals => _cachedDailyTotals;

  // Cached parameters
  String? _cachedSort;
  String? _cachedOrder;
  DateTime? _cachedStartDate;
  DateTime? _cachedEndDate;

  // Getters
  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String? get cachedSort => _cachedSort;
  String? get cachedOrder => _cachedOrder;
  DateTime? get cachedStartDate => _cachedStartDate;
  DateTime? get cachedEndDate => _cachedEndDate;

  PaymentProvider(this._paymentService, this._tokenService);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Fetch Payments with pagination and optional filters
  Future<void> fetchPayments({
    int? page,
    String? sort,
    String? order,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);

    // Update cached parameters if new ones are provided
    _cachedSort = sort ?? _cachedSort;
    _cachedOrder = order ?? _cachedOrder;
    _cachedStartDate = startDate ?? _cachedStartDate;
    _cachedEndDate = endDate ?? _cachedEndDate;

    try {
      final String? accessToken = await _tokenService.getToken();
      if (accessToken != null) {
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
        log('Payments successfully fetched.');
        notifyListeners();
      } else {
        throw PaymentException('No access token found.');
      }
    } catch (e) {
      log('Fetch payments error: $e');
      throw PaymentException('Failed to fetch payments: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Reset the payment list and fetch from page 1 (useful for filtering or refresh)
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

  // Add Payment
  Future<void> addPayment(CreatePayment createPayment) async {
    _setLoading(true);

    try {
      final String? accessToken = await _tokenService.getToken();
      if (accessToken != null) {
        await _paymentService.addPayment(
          accessToken: accessToken,
          createPayment: createPayment,
        );
        log('Payment successfully added.');
        await resetAndFetch();
      } else {
        throw PaymentException('No access token found.');
      }
    } catch (e) {
      log('Add payment error: $e');
      throw PaymentException('Failed to add payment: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update Payment
  Future<void> updatePayment(CreatePayment payment) async {
    _setLoading(true);

    try {
      final String? accessToken = await _tokenService.getToken();
      if (accessToken != null) {
        await _paymentService.updatePayment(
          accessToken: accessToken,
          updatePayment: payment,
        );
        log('Payment successfully updated.');
        await resetAndFetch();
      } else {
        throw PaymentException('No access token found.');
      }
    } catch (e) {
      log('Update payment error: $e');
      throw PaymentException('Failed to update payment: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch Daily Total Payments for Month with caching
  Future<void> fetchDailyTotalPaymentsForMonth(DateTime month) async {
    _setLoading(true);
    try {
      final String? accessToken = await _tokenService.getToken();
      if (accessToken != null) {
        DateTime startDate = DateTime(month.year, month.month, 1);
        DateTime endDate = DateTime(month.year, month.month + 1, 0);

        final dailyTotals = await _paymentService.getDailyTotalPayments(
          accessToken: accessToken,
          startDate: startDate,
          endDate: endDate,
        );

        _cachedMonth = month; // Update cached month
        _cachedDailyTotals = dailyTotals; // Cache the daily totals
        log('Daily payments for $month: ${_cachedDailyTotals.length}');
        notifyListeners();
      } else {
        throw PaymentException('No access token found.');
      }
    } catch (e) {
      log('Fetch daily total payments for month error: $e');
      throw PaymentException(
          'Failed to fetch daily total payments for month: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete Payment
  Future<void> deletePayment(int paymentId) async {
    _setLoading(true);

    try {
      final String? accessToken = await _tokenService.getToken();
      if (accessToken != null) {
        await _paymentService.deletePayment(
          accessToken: accessToken,
          paymentId: paymentId,
        );
        log('Payment successfully deleted.');
        await resetAndFetch();
      } else {
        throw PaymentException('No access token found.');
      }
    } catch (e) {
      log('Delete payment error: $e');
      throw PaymentException('Failed to delete payment: $e');
    } finally {
      _setLoading(false);
    }
  }
}

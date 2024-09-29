import 'dart:developer';
import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../services/token_service.dart';
import '../exceptions/payment_exception.dart';

class MonthlyProvider with ChangeNotifier {
  final PaymentService _paymentService;
  final TokenService _tokenService;

  final Map<DateTime, int> _monthlyPayments = {};
  bool _isLoading = false;
  bool _hasMoreMonths = true; // Track if more months can be loaded
  DateTime? _lastLoadedMonth; // Track the last month that was loaded

  // Getters
  Map<DateTime, int> get monthlyPayments => _monthlyPayments;
  bool get isLoading => _isLoading;
  bool get hasMoreMonths => _hasMoreMonths;

  // Constructor
  MonthlyProvider(this._paymentService, this._tokenService);

  // Set Loading State
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Fetch payments for a range of months (for pagination)
  Future<void> fetchPaymentsForMoreMonths({int numberOfMonths = 3}) async {
    if (_isLoading || !_hasMoreMonths) {
      return; // Prevent loading if already loading or no more months
    }

    _setLoading(true);
    try {
      final String? accessToken = await _tokenService.getToken();
      if (accessToken != null) {
        DateTime now = _lastLoadedMonth ?? DateTime.now();
        List<DateTime> monthsToLoad = List.generate(numberOfMonths, (index) {
          return DateTime(now.year, now.month - index, 1);
        });

        for (DateTime month in monthsToLoad) {
          DateTime startDate = DateTime(month.year, month.month, 1);
          DateTime endDate = DateTime(month.year, month.month + 1, 0);

          int totalPayments = await _paymentService.getTotalAmountPayments(
            accessToken: accessToken,
            startDate: startDate,
            endDate: endDate,
          );

          _monthlyPayments[startDate] = totalPayments;
        }

        log('Loaded more months: $numberOfMonths months');
        notifyListeners();

        // Update the last loaded month to the earliest one loaded
        _lastLoadedMonth = monthsToLoad.last;

        // Check if more months can be loaded
        if (_lastLoadedMonth!.isBefore(DateTime(2000, 1, 1))) {
          _hasMoreMonths =
              false; // Assume no more months are available before year 2000
        }
      } else {
        throw PaymentException('No access token found.');
      }
    } catch (e) {
      log('Fetch more months error: $e');
      throw PaymentException('Failed to fetch more months: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch total payments for a list of changed months
  Future<void> fetchTotalPaymentForMonths(List<DateTime> changedMonths) async {
    if (_isLoading) {
      return;
    }

    // Remove duplicates based on year and month
    final uniqueMonths = <DateTime>{};
    for (DateTime month in changedMonths) {
      // Normalize the DateTime to the first day of the month
      DateTime normalizedMonth = DateTime(month.year, month.month, 1);
      uniqueMonths.add(normalizedMonth);
    }

    _setLoading(true);

    try {
      final String? accessToken = await _tokenService.getToken();

      if (accessToken != null) {
        // Loop through each unique month and fetch payments
        for (DateTime uniqueMonth in uniqueMonths) {
          DateTime startDate = DateTime(uniqueMonth.year, uniqueMonth.month, 1);
          DateTime endDate =
              DateTime(uniqueMonth.year, uniqueMonth.month + 1, 0);

          int totalPayments = await _paymentService.getTotalAmountPayments(
            accessToken: accessToken,
            startDate: startDate,
            endDate: endDate,
          );

          // Store total payments for the specific month
          _monthlyPayments[startDate] = totalPayments;
        }

        // Notify listeners after all months are processed
        notifyListeners();
      } else {
        throw PaymentException('No access token found.');
      }
    } catch (e) {
      log('Fetch total payments for months error: $e');
      throw PaymentException('Failed to fetch total payments for months: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Reload total payments for all loaded months
  Future<void> reloadTotalPaymentsForLoadedMonths() async {
    if (_isLoading) return; // Prevent reloading if already loading

    _setLoading(true);
    try {
      final String? accessToken = await _tokenService.getToken();
      if (accessToken != null) {
        for (DateTime startDate in _monthlyPayments.keys) {
          DateTime endDate = DateTime(startDate.year, startDate.month + 1, 0);

          int totalPayments = await _paymentService.getTotalAmountPayments(
            accessToken: accessToken,
            startDate: startDate,
            endDate: endDate,
          );

          _monthlyPayments[startDate] =
              totalPayments; // Update total payments for the month
          log('Reloaded total payments for $startDate: \$${totalPayments.toString()}');
        }
        notifyListeners();
      } else {
        throw PaymentException('No access token found.');
      }
    } catch (e) {
      log('Reload total payments error: $e');
      throw PaymentException('Failed to reload total payments: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Clear monthly payments if needed
  void clearMonthlyPayments() {
    _monthlyPayments.clear();
    notifyListeners();
  }
}

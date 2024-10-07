import 'dart:developer';
import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../services/token_service.dart';

class MonthlyProvider with ChangeNotifier {
  final PaymentService _paymentService;
  final TokenService _tokenService;

  final Map<DateTime, int> _monthlyPayments = {};
  bool _isLoading = false;
  bool _hasMoreMonths = true;
  DateTime? _lastLoadedMonth;

  Map<DateTime, int> get monthlyPayments => _monthlyPayments;
  bool get isLoading => _isLoading;
  bool get hasMoreMonths => _hasMoreMonths;

  MonthlyProvider(this._paymentService, this._tokenService);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchPaymentsForMoreMonths({int numberOfMonths = 3}) async {
    if (_isLoading || !_hasMoreMonths) {
      return;
    }
    _setLoading(true);
    try {
      final String accessToken = await _tokenService.getToken();
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

      _lastLoadedMonth = monthsToLoad.last;

      if (_lastLoadedMonth!.isBefore(DateTime(2000, 1, 1))) {
        _hasMoreMonths = false;
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTotalPaymentForMonths(List<DateTime> changedMonths) async {
    if (_isLoading) {
      return;
    }

    final uniqueMonths = <DateTime>{};
    for (DateTime month in changedMonths) {
      DateTime normalizedMonth = DateTime(month.year, month.month, 1);
      uniqueMonths.add(normalizedMonth);
    }

    _setLoading(true);

    try {
      final String accessToken = await _tokenService.getToken();

      for (DateTime uniqueMonth in uniqueMonths) {
        DateTime startDate = DateTime(uniqueMonth.year, uniqueMonth.month, 1);
        DateTime endDate = DateTime(uniqueMonth.year, uniqueMonth.month + 1, 0);

        int totalPayments = await _paymentService.getTotalAmountPayments(
          accessToken: accessToken,
          startDate: startDate,
          endDate: endDate,
        );

        _monthlyPayments[startDate] = totalPayments;
      }

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reloadTotalPaymentsForLoadedMonths() async {
    if (_isLoading) return;

    _setLoading(true);
    try {
      final String accessToken = await _tokenService.getToken();
      for (DateTime startDate in _monthlyPayments.keys) {
        DateTime endDate = DateTime(startDate.year, startDate.month + 1, 0);

        int totalPayments = await _paymentService.getTotalAmountPayments(
          accessToken: accessToken,
          startDate: startDate,
          endDate: endDate,
        );

        _monthlyPayments[startDate] = totalPayments;
        log('Reloaded total payments for $startDate: \$${totalPayments.toString()}');
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void clearMonthlyPayments() {
    _monthlyPayments.clear();
    notifyListeners();
  }
}

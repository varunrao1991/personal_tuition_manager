import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/create_payment.dart';
import '../models/fetch_payment.dart';
import '../services/payment_service.dart';
import '../services/token_service.dart';
import '../exceptions/payment_exception.dart';

class PaymentProvider with ChangeNotifier {
  List<Payment> _payments = [];
  final Map<DateTime, int> _monthlyPayments = {}; // List for monthly payments

  bool _isLoading = false;
  final PaymentService _paymentService;
  final TokenService _tokenService;
  int _currentPage = 1;
  int _totalPages = 1;

  // Getters
  List<Payment> get payments => _payments;
  Map<DateTime, int> get monthlyPayments =>
      _monthlyPayments; // Getter for monthly payments
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  // Constructor to inject PaymentService and TokenService
  PaymentProvider(this._paymentService, this._tokenService);

  // Set Loading State
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

    try {
      final String? accessToken = await _tokenService.getToken();
      if (accessToken != null) {
        final PaymentResponse response = await _paymentService.getPayments(
          accessToken: accessToken,
          page: page ?? _currentPage,
          sort: sort,
          order: order,
          startDate: startDate,
          endDate: endDate,
        );

        // Handle pagination: Reset the list for page 1, append for other pages
        if (page == 1 || page == null) {
          _payments = response.payments; // Reset on first page load or refresh
        } else {
          _payments.addAll(response.payments); // Append for paginated results
        }

        // Update pagination details
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
    _currentPage = 1; // Reset to the first page
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

        // Refresh the payment list after adding a new payment
        await resetAndFetch(); // Reset and fetch payments after adding
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

  Future<void> getTotalPayments(DateTime month) async {
    _setLoading(true);
    try {
      final String? accessToken = await _tokenService.getToken();
      DateTime startDate = DateTime(month.year, month.month, 1);
      DateTime endDate = DateTime(month.year, month.month+1, 0);
      if (accessToken != null) {
        _monthlyPayments[startDate] = await _paymentService.getTotalAmountPayments(
          accessToken: accessToken,
          startDate: startDate,
          endDate: endDate,
        );
      } else {
        throw PaymentException('No access token found.');
      }
    } catch (e) {
      log('Get total payment error: $e');
      throw PaymentException('Failed to get total payment: $e');
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

        // Refresh the payment list after updating a payment
        await resetAndFetch(); // Reset and fetch payments after updating
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

        // Refresh the payment list after deleting a payment
        await resetAndFetch(); // Reset and fetch payments after deleting
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

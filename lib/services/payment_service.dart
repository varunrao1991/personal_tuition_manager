import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../exceptions/payment_exception.dart';
import '../models/create_payment.dart';
import '../models/daily_total.dart';
import '../models/fetch_payment.dart';
import '../config/app_config.dart';

class PaymentResponse {
  final List<Payment> payments;
  final int totalPages;
  final int totalRecords;
  final int currentPage;

  PaymentResponse({
    required this.payments,
    required this.totalPages,
    required this.totalRecords,
    required this.currentPage,
  });
}

class PaymentService {
  String apiUrl = Config().apiUrl;

  // Fetch payments with additional filtering options: pagination, sort, order, date range
  Future<PaymentResponse> getPayments({
    required String accessToken,
    required int page,
    String? sort,
    String? order,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
      };

      if (sort != null) queryParams['sort'] = sort;
      if (order != null) queryParams['order'] = order;
      if (startDate != null && endDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
        queryParams['endDate'] = endDate.toIso8601String();
      }

      Uri uri = Uri.parse('$apiUrl/api/payments')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final payments = (data['data'] as List)
            .map((paymentJson) => Payment.fromJson(paymentJson))
            .toList();

        return PaymentResponse(
          payments: payments,
          totalPages: data['totalPages'],
          totalRecords: data['totalRecords'],
          currentPage: data['currentPage'],
        );
      } else {
        throw PaymentException('Failed to fetch payments: ${response.body}');
      }
    } catch (e) {
      log('Error fetching payments: $e');
      throw PaymentException('Error fetching payments: $e');
    }
  }

  // Create a new payment with amount, payment date, and studentId
  Future<void> addPayment({
    required String accessToken,
    required CreatePayment createPayment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/api/payments'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(createPayment.toJson()),
      );

      if (response.statusCode != 201) {
        throw PaymentException('Failed to add payment: ${response.body}');
      } else {
        log('Payment successfully created.');
      }
    } catch (e) {
      log('Error creating payment: $e');
      throw PaymentException('Error creating payment: $e');
    }
  }

  Future<int> getTotalAmountPayments({
    required String accessToken,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Convert DateTime to the appropriate string format (e.g., "yyyy-MM-dd")
      final String formattedStartDate = _formatDate(startDate);
      final String formattedEndDate = _formatDate(endDate);

      final response = await http.get(
        Uri.parse(
            '$apiUrl/api/payments/total?startDate=$formattedStartDate&endDate=$formattedEndDate'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch total amount: ${response.body}');
      }
      return int.parse(response.body);
    } catch (e) {
      throw Exception('Error fetching total amount: $e');
    }
  }

  Future<List<DailyTotal>> getDailyTotalPayments({
    required String accessToken,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final String formattedStartDate = _formatDate(startDate);
      final String formattedEndDate = _formatDate(endDate);

      final response = await http.get(
        Uri.parse(
            '$apiUrl/api/payments/daily?startDate=$formattedStartDate&endDate=$formattedEndDate'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch total amount: ${response.body}');
      }

      final List<dynamic> data = jsonDecode(response.body);

      return data.map<DailyTotal>((entry) {
        return DailyTotal.fromJson(entry);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching total amount: $e');
    }
  }

  // Helper method to format DateTime to the required string format
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Update an existing payment by payment ID
  Future<void> updatePayment({
    required String accessToken,
    required CreatePayment updatePayment,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/api/payments/${updatePayment.id}'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatePayment.toJson()),
      );

      if (response.statusCode != 200) {
        throw PaymentException('Failed to update payment: ${response.body}');
      } else {
        log('Payment successfully updated.');
      }
    } catch (e) {
      log('Error updating payment: $e');
      throw PaymentException('Error updating payment: $e');
    }
  }

  // Delete a payment by payment ID
  Future<void> deletePayment({
    required String accessToken,
    required int paymentId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/api/payments/$paymentId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw PaymentException('Failed to delete payment: ${response.body}');
      } else {
        log('Payment successfully deleted.');
      }
    } catch (e) {
      log('Error deleting payment: $e');
      throw PaymentException('Error deleting payment: $e');
    }
  }
}

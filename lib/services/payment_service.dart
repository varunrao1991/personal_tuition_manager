import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/create_payment.dart';
import '../models/daily_total.dart';
import '../models/fetch_payment.dart';
import '../config/app_config.dart';
import '../utils/response_to_error.dart';

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
  final http.Client _client;

  PaymentService(this._client);

  Future<PaymentResponse> getPayments({
    required String accessToken,
    required int page,
    String? sort,
    String? order,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Map<String, String> queryParams = {
      'page': page.toString(),
    };

    if (sort != null) queryParams['sort'] = sort;
    if (order != null) queryParams['order'] = order;
    if (startDate != null && endDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
      queryParams['endDate'] = endDate.toIso8601String();
    }

    Uri uri =
        Uri.parse('$apiUrl/api/payments').replace(queryParameters: queryParams);

    final response = await _client.get(uri, headers: {
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
      throw responseToError(response.body);
    }
  }

  Future<void> addPayment({
    required String accessToken,
    required CreatePayment createPayment,
  }) async {
    final response = await _client.post(
      Uri.parse('$apiUrl/api/payments'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(createPayment.toJson()),
    );

    if (response.statusCode != 201) {
      throw responseToError(response.body);
    } else {
      log('Payment successfully created.');
    }
  }

  Future<int> getTotalAmountPayments({
    required String accessToken,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final String formattedStartDate = _formatDate(startDate);
    final String formattedEndDate = _formatDate(endDate);

    final response = await _client.get(
      Uri.parse(
          '$apiUrl/api/payments/total?startDate=$formattedStartDate&endDate=$formattedEndDate'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    } else {
      return int.parse(response.body);
    }
  }

  Future<Map<int, double>> getDailyTotalPayments({
    required String accessToken,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final String formattedStartDate = _formatDate(startDate);
    final String formattedEndDate = _formatDate(endDate);

    final response = await _client.get(
      Uri.parse(
          '$apiUrl/api/payments/daily?startDate=$formattedStartDate&endDate=$formattedEndDate'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    } else {
      final List<dynamic> data = jsonDecode(response.body);

      // Map the response data to a list of DailyTotal objects
      final List<DailyTotal> dailyTotals = data.map((entry) {
        return DailyTotal.fromJson(entry);
      }).toList();

      // Create a map of DateTime and totalAmount
      return {
        for (var dailyTotal in dailyTotals)
          dailyTotal.dateTime.day: dailyTotal.totalAmount
      };
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> updatePayment({
    required String accessToken,
    required CreatePayment updatePayment,
  }) async {
    final response = await _client.put(
      Uri.parse('$apiUrl/api/payments/${updatePayment.id}'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatePayment.toJson()),
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    } else {
      log('Payment successfully updated.');
    }
  }

  Future<void> deletePayment({
    required String accessToken,
    required int paymentId,
  }) async {
    final response = await _client.delete(
      Uri.parse('$apiUrl/api/payments/$paymentId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw responseToError(response.body);
    } else {
      log('Payment successfully deleted.');
    }
  }
}

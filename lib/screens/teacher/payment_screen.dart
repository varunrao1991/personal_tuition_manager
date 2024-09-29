import 'package:flutter/material.dart';
import 'package:padmayoga/models/create_payment.dart';
import 'package:padmayoga/models/fetch_payment.dart';
import 'package:padmayoga/providers/month_provider.dart';
import 'package:padmayoga/screens/teacher/widgets/edit_payment.dart';
import 'package:provider/provider.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/confirmation_modal.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/show_custom_bottom_modal.dart';
import '../../widgets/show_custom_center_modal.dart';
import '../../widgets/total_graph.dart';
import 'widgets/monthly_payments.dart';
import 'widgets/payment_card.dart';
import 'widgets/add_payment.dart';

class PaymentViewer extends StatefulWidget {
  const PaymentViewer({super.key});

  @override
  _PaymentViewerState createState() => _PaymentViewerState();
}

class _PaymentViewerState extends State<PaymentViewer> {
  late ScrollController _scrollController;
  DateTime _selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPayments();
    });
  }

  Future<void> _fetchPayments() async {
    final paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);
    final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    await paymentProvider.fetchPayments(
        page: 1, startDate: startDate, endDate: endDate);
    await paymentProvider.fetchDailyTotalPaymentsForMonth(_selectedMonth);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final paymentProvider =
          Provider.of<PaymentProvider>(context, listen: false);
      if (!paymentProvider.isLoading &&
          paymentProvider.currentPage < paymentProvider.totalPages) {
        paymentProvider.fetchPayments(
            page: paymentProvider.currentPage + 1,
            startDate: DateTime(_selectedMonth.year, _selectedMonth.month, 1),
            endDate:
                DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0));
      }
    }
  }

  Future<void> _deletePayment(Payment payment) async {
    final paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);
    final monthProvider = Provider.of<MonthlyProvider>(context, listen: false);
    await paymentProvider.deletePayment(payment.id);
    await monthProvider.fetchTotalPaymentForMonths([payment.paymentDate]);
    _fetchPayments();
  }

  void _onMonthChanged(DateTime newMonth) {
    setState(() {
      _selectedMonth = newMonth;
    });
    _fetchPayments();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MonthlyPaymentsWidget(
              onMonthChanged: _onMonthChanged,
              selectedMonth: _selectedMonth,
            ),
          ),
          // Add the daily total graph below the month cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            height: 200, // Adjust height as necessary
            child: TotalGraph(dailyTotals: paymentProvider.dailyTotals),
          ),
          Expanded(
            child: paymentProvider.isLoading && paymentProvider.payments.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchPayments,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: paymentProvider.payments.length +
                          (paymentProvider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == paymentProvider.payments.length) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        Payment payment = paymentProvider.payments[index];

                        return PaymentCard(
                          payment: payment,
                          onEdit: () async {
                            final paymentNew =
                                await showCustomModalBottomSheet<CreatePayment>(
                              context: context,
                              child: EditPaymentWidget(
                                payment: CreatePayment.fromPayment(payment),
                              ),
                            );
                            if (paymentNew != null) {
                              await Provider.of<PaymentProvider>(context,
                                      listen: false)
                                  .updatePayment(paymentNew);

                              final monthProvider =
                                  Provider.of<MonthlyProvider>(context,
                                      listen: false);
                              await monthProvider.fetchTotalPaymentForMonths([
                                payment.paymentDate,
                                paymentNew.paymentDate
                              ]);
                              await paymentProvider
                                  .fetchDailyTotalPaymentsForMonth(
                                      _selectedMonth);
                              showCustomSnackBar(
                                  context, 'Payment updated successfully!');
                            }
                          },
                          onDelete: () async {
                            final success = await showCustomDialog<bool>(
                              context: context,
                              child: const ConfirmationDialog(
                                message: 'Delete this payment?',
                                confirmButtonText: 'Delete',
                                cancelButtonText: 'Cancel',
                              ),
                            );
                            if (success != null && success) {
                              _deletePayment(payment);
                            }
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          showCustomModalBottomSheet(
            context: context,
            child: const PaymentProcessWidget(),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

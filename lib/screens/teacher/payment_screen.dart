import 'package:flutter/material.dart';
import 'package:padmayoga/models/create_payment.dart';
import 'package:padmayoga/models/fetch_payment.dart';
import 'package:padmayoga/providers/month_provider.dart';
import 'package:padmayoga/screens/teacher/widgets/edit_payment.dart';
import 'package:provider/provider.dart';
import '../../providers/payment_provider.dart';
import '../../utils/handle_errors.dart';
import '../../utils/show_custom_center_modal.dart';
import '../../widgets/confirmation_modal.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/show_custom_bottom_modal.dart';
import '../../widgets/total_graph.dart';
import 'widgets/monthly_payments.dart';
import 'widgets/payment_card.dart';
import 'widgets/add_payment.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late ScrollController _scrollController;
  DateTime _selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool _isLoadingMore = false;

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

    try {
      await paymentProvider.fetchPayments(
          page: 1, startDate: startDate, endDate: endDate);
      await paymentProvider.fetchDailyTotalPayments(_selectedMonth);
      await Provider.of<MonthlyProvider>(context, listen: false)
          .fetchTotalPaymentForMonths([startDate, endDate]);
    } catch (e) {
      handleErrors(context, e);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      final paymentProvider =
          Provider.of<PaymentProvider>(context, listen: false);
      if (!paymentProvider.isLoading &&
          paymentProvider.currentPage < paymentProvider.totalPages) {
        _loadMorePayments();
      }
    }
  }

  Future<void> _loadMorePayments() async {
    final paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);
    if (!paymentProvider.isLoading &&
        paymentProvider.currentPage < paymentProvider.totalPages) {
      setState(() {
        _isLoadingMore = true;
      });
      try {
        await paymentProvider.fetchPayments(
            page: paymentProvider.currentPage + 1,
            startDate: DateTime(_selectedMonth.year, _selectedMonth.month, 1),
            endDate:
                DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0));
      } catch (e) {
        handleErrors(context, e);
      } finally {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _deletePayment(Payment payment) async {
    try {
      await Provider.of<PaymentProvider>(context, listen: false)
          .deletePayment(payment.id);
      await Provider.of<MonthlyProvider>(context, listen: false)
          .fetchTotalPaymentForMonths([payment.paymentDate]);
      await _fetchPayments();
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<void> _onMonthChanged(DateTime newMonth) async {
    setState(() {
      _selectedMonth = newMonth;
    });
    _fetchPayments();
  }

  Future<void> _updatePayment(
      CreatePayment paymentNew, DateTime oldPaymentDate) async {
    try {
      final paymentProvider =
          Provider.of<PaymentProvider>(context, listen: false);
      await paymentProvider.updatePayment(paymentNew);

      await Provider.of<MonthlyProvider>(context, listen: false)
          .fetchTotalPaymentForMonths([paymentNew.paymentDate, oldPaymentDate]);
      await _fetchPayments();

      showCustomSnackBar(context, 'Payment updated successfully!');
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<void> _addPayment(CreatePayment paymentNew) async {
    try {
      final paymentProvider =
          Provider.of<PaymentProvider>(context, listen: false);
      await paymentProvider.addPayment(paymentNew);

      await Provider.of<MonthlyProvider>(context, listen: false)
          .fetchTotalPaymentForMonths([paymentNew.paymentDate]);
      await _fetchPayments();
      showCustomSnackBar(context, 'Payment added successfully!');
    } catch (e) {
      handleErrors(context, e);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildMonthlyPayments(),
          _buildTotalGraph(),
          _buildPaymentList(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

// Widget for the monthly payments section
  Widget _buildMonthlyPayments() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MonthlyPaymentsWidget(
        onMonthChanged: _onMonthChanged,
        selectedMonth: _selectedMonth,
      ),
    );
  }

// Widget for the total graph display
  Widget _buildTotalGraph() {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          height: 200,
          child: TotalGraph(
            arrayToDisplay: paymentProvider.dailyTotals,
          ),
        );
      },
    );
  }

// Widget for the payment list
  Widget _buildPaymentList() {
    return Expanded(
      child: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          return paymentProvider.isLoading && paymentProvider.payments.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchPayments,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: paymentProvider.payments.length +
                          (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == paymentProvider.payments.length) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        return _buildPaymentCard(
                            paymentProvider.payments[index]);
                      },
                    ),
                  ));
        },
      ),
    );
  }

// Widget for individual payment card
  Widget _buildPaymentCard(Payment payment) {
    return PaymentCard(
      payment: payment,
      onEdit: () async {
        final paymentNew = await showCustomModalBottomSheet<CreatePayment>(
          context: context,
          child: EditPaymentWidget(
            payment: CreatePayment.fromPayment(payment),
          ),
        );
        if (paymentNew != null) {
          await _updatePayment(paymentNew, payment.paymentDate);
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
  }

// Widget for the floating action button
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Colors.blue,
      onPressed: () {
        showCustomModalBottomSheet(
          context: context,
          child: const PaymentProcessWidget(),
        ).then((newPayment) {
          if (newPayment != null) {
            _addPayment(newPayment);
          }
        });
      },
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}

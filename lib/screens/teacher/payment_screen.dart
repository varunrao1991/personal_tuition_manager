import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoglogonline/widgets/custom_fab.dart';
import '../../models/create_payment.dart';
import '../../models/fetch_payment.dart';
import '../../providers/month_provider.dart';
import '../../providers/payment_provider.dart';
import '../../utils/handle_errors.dart';
import '../../utils/show_custom_center_modal.dart';
import '../../widgets/confirmation_modal.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/show_custom_bottom_modal.dart';
import '../../widgets/total_graph.dart';
import 'widgets/edit_payment.dart';
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
  bool _isFetchingPayments = false;
  late PaymentProvider paymentProvider;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPayments();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!paymentProvider.isLoading &&
          paymentProvider.currentPage < paymentProvider.totalPages) {
        _loadMorePayments();
      }
    }
  }

  Future<void> _fetchPayments() async {
    if (_isFetchingPayments) return;
    _isFetchingPayments = true;

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
    } finally {
      _isFetchingPayments = false;
    }
  }

  Future<void> _loadMorePayments() async {
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
      await paymentProvider.deletePayment(payment.id);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    paymentProvider = Provider.of<PaymentProvider>(context);
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
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildTotalGraph(),
                  _buildPaymentList(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: CustomFAB(
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
        icon: Icons.add,
      ),
    );
  }

  Widget _buildMonthlyPayments() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MonthlyPaymentsWidget(
        onMonthChanged: _onMonthChanged,
        selectedMonth: _selectedMonth,
      ),
    );
  }

  Widget _buildTotalGraph() {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          height: 200,
          child: TotalGraph(
            arrayToDisplay: paymentProvider.dailyTotals,
          ),
        );
      },
    );
  }

  Widget _buildPaymentList() {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, child) {
        if (paymentProvider.isLoading && paymentProvider.payments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          physics:
              const NeverScrollableScrollPhysics(), // Disable internal scroll
          shrinkWrap: true, // Let it take only needed space
          itemCount: paymentProvider.payments.length + (_isLoadingMore ? 1 : 0),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (index == paymentProvider.payments.length) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildPaymentCard(paymentProvider.payments[index]);
          },
        );
      },
    );
  }

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
        if (success == true) {
          _deletePayment(payment);
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:padmayoga/models/create_payment.dart';
import 'package:padmayoga/models/fetch_payment.dart';
import 'package:padmayoga/screens/teacher/widgets/edit_payment.dart';
import 'package:provider/provider.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/confirmation_modal.dart';
import '../../widgets/show_custom_bottom_modal.dart';
import '../../widgets/show_custom_center_modal.dart';
import '../../widgets/sort_modal.dart';
import 'widgets/payment_card.dart';
import 'widgets/add_payment.dart';

class PaymentViewer extends StatefulWidget {
  const PaymentViewer({super.key});

  @override
  _PaymentViewerState createState() => _PaymentViewerState();
}

class _PaymentViewerState extends State<PaymentViewer> {
  late ScrollController _scrollController;
  static const Map<String, String> _sortFieldLabels = {
    'paymentDate': 'Payment Date',
    'amount': 'Amount'
  };
  String _selectedSortField = 'paymentDate';
  bool _isAscending = true;

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
    await paymentProvider.fetchPayments(
      page: 1,
      sort: _selectedSortField,
      order: _isAscending ? 'ASC' : 'DESC',
    );
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
          sort: _selectedSortField,
          order: _isAscending ? 'ASC' : 'DESC',
        );
      }
    }
  }

  void _editPayment(CreatePayment payment) {
    showCustomModalBottomSheet(
        context: context, child: EditPaymentWidget(payment: payment));
  }

  Future<void> _deletePayment(int paymentId) async {
    final paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);
    await paymentProvider.deletePayment(paymentId);
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_alt),
                  onPressed: () => _openSortModal(context),
                ),
              ],
            ),
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
                          onEdit: () {
                            _editPayment(CreatePayment.fromPayment(payment));
                          },
                          onDelete: () async {
                            showCustomDialog(
                              context: context,
                              child: const ConfirmationDialog(
                                message: 'Delete this payment?',
                                confirmButtonText: 'Delete',
                                cancelButtonText: 'Cancel',
                              ),
                            ).then((success) => {
                                  if (success != null && success)
                                    {_deletePayment(payment.id)}
                                });
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

  void _openSortModal(BuildContext context) {
    showCustomDialog(
      context: context,
      child: SortModal(
        title: 'Sort Payments',
        selectedSortField: _selectedSortField,
        sortOptions: _sortFieldLabels,
        isAscending: _isAscending,
        onSortFieldChange: (newSortField) {
          if (newSortField != null) {
            setState(() {
              _selectedSortField = newSortField;
            });
          }
          Navigator.of(context).pop();
        },
        onSortOrderChange: (isAscending) {
          setState(() {
            _isAscending = isAscending;
          });
          Navigator.of(context).pop();
        },
      ),
    ).then((value) {
      _fetchPayments();
    });
  }
}

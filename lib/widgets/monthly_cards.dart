import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';

class MonthCardList extends StatefulWidget {
  final DateTime selectedMonth;
  final Function(DateTime) onMonthSelected;

  const MonthCardList({
    Key? key,
    required this.selectedMonth,
    required this.onMonthSelected,
  }) : super(key: key);

  @override
  _MonthCardListState createState() => _MonthCardListState();
}

class _MonthCardListState extends State<MonthCardList> {
  List<DateTime> _months = [];
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _initializeMonths(); // Load the initial three months (including the current one)
  }

  void _initializeMonths() {
    DateTime now = DateTime.now();
    List<DateTime> latestMonths = [
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month - 1, 1),
      DateTime(now.year, now.month - 2, 1),
    ];
    setState(() {
      _months = latestMonths;
    });
    _fetchTotalsForMonths(_months);
  }

  void _fetchTotalsForMonths(List<DateTime> months) {
    final paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);
    for (var month in months) {
      paymentProvider.getTotalPayments(month); // Fetch totals for each month
    }
  }

  void _loadMoreMonths() {
    setState(() {
      _isLoadingMore = true;
    });

    // Load 3 more previous months
    DateTime lastMonth = _months.last;
    List<DateTime> newMonths = [
      DateTime(lastMonth.year, lastMonth.month - 1, 1),
      DateTime(lastMonth.year, lastMonth.month - 2, 1),
      DateTime(lastMonth.year, lastMonth.month - 3, 1),
    ];

    setState(() {
      _months.addAll(newMonths);
    });

    _fetchTotalsForMonths(
        newMonths); // Fetch total payments for newly added months

    setState(() {
      _isLoadingMore = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.minScrollExtent) {
      _loadMoreMonths();
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scrollbar(
      controller: _scrollController,
      child: Container(
        height: 100,
        margin: const EdgeInsets.all(8.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _months.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _months.length) {
              return const Center(child: CircularProgressIndicator());
            }

            final month = _months[index];
            final isSelected = widget.selectedMonth.month == month.month &&
                widget.selectedMonth.year == month.year;

            return GestureDetector(
              onTap: () => widget.onMonthSelected(month),
              child: Card(
                color: isSelected ? Colors.redAccent : Colors.grey,
                child: Container(
                  width: screenWidth / 3,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getMonthName(month.month),
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${month.year}",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹ ${paymentProvider.getTotalPayments(month)}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          controller: _scrollController,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

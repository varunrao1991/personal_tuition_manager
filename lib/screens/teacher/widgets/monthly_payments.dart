import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/month_provider.dart';
import '../../../widgets/month_info_card.dart';

class MonthlyPaymentsWidget extends StatefulWidget {
  final Function(DateTime)? onMonthChanged;
  final DateTime selectedMonth;

  const MonthlyPaymentsWidget({
    super.key,
    this.onMonthChanged,
    required this.selectedMonth,
  });

  @override
  _MonthlyPaymentsWidgetState createState() => _MonthlyPaymentsWidgetState();
}

class _MonthlyPaymentsWidgetState extends State<MonthlyPaymentsWidget> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.selectedMonth;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MonthlyProvider>(context, listen: false)
          .fetchPaymentsForMoreMonths();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore) {
      _loadMoreMonths();
    }
  }

  Future<void> _loadMoreMonths() async {
    setState(() {
      _isLoadingMore = true;
    });
    await Provider.of<MonthlyProvider>(context, listen: false)
        .fetchPaymentsForMoreMonths();
    setState(() {
      _isLoadingMore = false;
    });
  }

  void _onMonthTap(DateTime month) {
    setState(() {
      _selectedMonth = month;
    });

    widget.onMonthChanged?.call(month);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MonthlyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.monthlyPayments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SizedBox(
          height: 120,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount:
                provider.monthlyPayments.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.monthlyPayments.length) {
                return const Center(child: CircularProgressIndicator());
              }

              final month = provider.monthlyPayments.keys.elementAt(index);
              final totalPayments = provider.monthlyPayments[month];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: MonthInfoCard(
                  month: month,
                  isSelected: month == _selectedMonth,
                  onTap: () => _onMonthTap(month),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: totalPayments != null && totalPayments != 0
                        ? Text(
                            '₹$totalPayments',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: month == _selectedMonth
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/month_provider.dart';
import '../../../utils/handle_errors.dart';
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
      _loadInitialPayments();
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

  Future<void> _loadInitialPayments() async {
    try {
      await Provider.of<MonthlyProvider>(context, listen: false)
          .fetchPaymentsForMoreMonths();
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<void> _loadMoreMonths() async {
    setState(() {
      _isLoadingMore = true;
    });
    try {
      await Provider.of<MonthlyProvider>(context, listen: false)
          .fetchPaymentsForMoreMonths();
    } catch (e) {
      handleErrors(context, e);
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _onMonthTap(DateTime month) async {
    setState(() {
      _selectedMonth = month;
    });
    try {
      await widget.onMonthChanged?.call(month);
    } catch (e) {
      handleErrors(context, e);
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MonthlyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.monthlyPayments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SizedBox(
          height: 150,
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

              return MonthInfoCard(
                month: month,
                isSelected: month == _selectedMonth,
                onTap: () async => await _onMonthTap(month),
                child: totalPayments != null && totalPayments != 0
                    ? Text(
                        '₹$totalPayments',
                        style: month == _selectedMonth
                            ? Theme.of(context).textTheme.bodyMedium
                            : Theme.of(context).textTheme.bodyMedium,
                      )
                    : const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    );
  }
}

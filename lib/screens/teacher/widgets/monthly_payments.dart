import 'package:flutter/material.dart';
import '../../../utils/handle_errors.dart';
import '../../../widgets/month_info_card.dart';

class MonthlyPaymentsWidget extends StatefulWidget {
  final Function(DateTime)? onMonthChanged;
  final DateTime selectedMonth;
  final Map<DateTime, int> monthlyPayments;
  final bool isLoading;
  final Function() onLoadMore;

  const MonthlyPaymentsWidget({
    super.key,
    this.onMonthChanged,
    required this.selectedMonth,
    required this.monthlyPayments,
    required this.isLoading,
    required this.onLoadMore,
  });

  @override
  _MonthlyPaymentsWidgetState createState() => _MonthlyPaymentsWidgetState();
}

class _MonthlyPaymentsWidgetState extends State<MonthlyPaymentsWidget> {
  late ScrollController _scrollController;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.selectedMonth;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(MonthlyPaymentsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMonth != widget.selectedMonth) {
      _selectedMonth = widget.selectedMonth;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !widget.isLoading) {
      widget.onLoadMore();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.monthlyPayments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount:
            widget.monthlyPayments.length + (widget.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == widget.monthlyPayments.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final month = widget.monthlyPayments.keys.elementAt(index);
          final totalPayments = widget.monthlyPayments[month];

          return MonthInfoCard(
            month: month,
            showYear: month.year != DateTime.now().year,
            isSelected: month == _selectedMonth,
            onTap: () async => await _onMonthTap(month),
            child: totalPayments != null && totalPayments != 0
                ? Text('₹$totalPayments',
                    style: Theme.of(context).textTheme.bodyLarge)
                : const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
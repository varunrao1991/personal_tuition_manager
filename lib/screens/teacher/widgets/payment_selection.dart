import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_constants.dart';
import '../../../models/owned_by.dart';
import '../../../providers/teacher/course_provider.dart';
import '../../../utils/handle_errors.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/custom_elevated_button.dart';

class PaymentOwnerSelector extends StatefulWidget {
  final Function(OwnedBy?) onPaymentSelected;
  final OwnedBy? selectedPayment;

  const PaymentOwnerSelector({
    super.key,
    required this.onPaymentSelected,
    this.selectedPayment,
  });

  @override
  _PaymentOwnerSelectorState createState() => _PaymentOwnerSelectorState();
}

class _PaymentOwnerSelectorState extends State<PaymentOwnerSelector> {
  late ScrollController _scrollController;
  OwnedBy? _selectedPayment;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPayments();
    });

    if (widget.selectedPayment != null) {
      _selectedPayment = widget.selectedPayment;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchPayments({int page = 1}) async {
    try {
      await context.read<CourseProvider>().fetchEligibleStudents(page: page);
    } catch (e) {
      handleErrors(context, e);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !context.read<CourseProvider>().isLoading &&
        context.read<CourseProvider>().currentPage <
            context.read<CourseProvider>().totalPages) {
      _fetchPayments(page: context.read<CourseProvider>().currentPage + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            padding: const EdgeInsets.all(AppPaddings.mediumPadding),
            child: SingleChildScrollView(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Select Paid Student',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: Consumer<CourseProvider>(
                    builder: (context, courseProvider, _) {
                      return courseProvider.isLoading &&
                              courseProvider.eligibleStudents.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : GridView.builder(
                              controller: _scrollController,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 16.0,
                                childAspectRatio: 1.5,
                              ),
                              itemCount:
                                  courseProvider.eligibleStudents.length +
                                      (courseProvider.isLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index ==
                                    courseProvider.eligibleStudents.length) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                final student =
                                    courseProvider.eligibleStudents[index];
                                return _buildStudentCard(student);
                              },
                            );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                if (_selectedPayment != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      'Selected Student: ${_selectedPayment!.name}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                const SizedBox(height: 10),
                CustomElevatedButton(
                  onPressed: () {
                    if (_selectedPayment != null) {
                      widget.onPaymentSelected(_selectedPayment!);
                    }
                  },
                  text: 'Next',
                ),
              ],
            ))));
  }

  Widget _buildStudentCard(OwnedBy student) {
    bool isSelected = _selectedPayment?.id == student.id;

    return CustomCard(
      onTap: () {
        setState(() {
          _selectedPayment = student;
        });
      },
      isSelected: isSelected,
      child: Text(
        student.name,
        textAlign: TextAlign.center,
        style: isSelected
            ? Theme.of(context).textTheme.bodyMedium
            : Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

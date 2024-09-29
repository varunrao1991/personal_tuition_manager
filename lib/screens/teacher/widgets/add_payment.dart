import 'package:flutter/material.dart';
import 'package:padmayoga/widgets/custom_form_date_field.dart';
import 'package:padmayoga/widgets/custom_form_text_field.dart';
import 'package:padmayoga/widgets/custom_elevated_button.dart';
import 'package:provider/provider.dart';
import '../../../models/create_payment.dart';
import '../../../models/student_model.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/custom_section_title.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../widgets/search_bar.dart';
import '../../../widgets/show_custom_center_modal.dart';
import '../../../widgets/sort_modal.dart';

class PaymentProcessWidget extends StatefulWidget {
  const PaymentProcessWidget({super.key});

  @override
  _PaymentProcessWidgetState createState() => _PaymentProcessWidgetState();
}

class _PaymentProcessWidgetState extends State<PaymentProcessWidget> {
  int _currentStep = 0;
  Student? _selectedStudent;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _searchController =
      TextEditingController(text: "Select student");

  DateTime _paymentDate = DateTime.now();
  String? _selectedName; // Use a string to hold the selected name

  static const Map<String, String> _sortFieldLabels = {
    'name': 'Name',
    'mobile': 'Mobile Number',
    'dob': 'Date of Birth',
    'joiningDate': 'Joining Date',
  };

  String _selectedSortField = 'name';
  bool _isAscending = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _selectStudent(Student? student) {
    setState(() {
      _selectedStudent = student;
    });
  }

  void _submitPayment() {
    if (_formKey.currentState!.validate()) {
      final payment = CreatePayment(
        studentId: _selectedStudent!.id,
        studentName: _selectedStudent!.name,
        amount: int.parse(_amountController.text),
        paymentDate: _paymentDate,
      );
      Provider.of<PaymentProvider>(context, listen: false).addPayment(payment);
      Navigator.of(context).pop(true);
    } else {
      showCustomSnackBar(
          context, 'Please fill in all fields and select a student.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Center(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(16.0),
        child: _currentStep == 0
            ? _buildSelectStudentStep(studentProvider)
            : _buildPaymentDetailsStep(),
      ),
    );
  }

  void _openSortModal(BuildContext context) {
    showCustomDialog(
      context: context,
      child: SortModal(
        title: 'Sort Students',
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
      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);
      studentProvider.resetAndFetch(
        name: _selectedName,
        sort: _selectedSortField,
        order: _isAscending ? 'ASC' : 'DESC',
      );
    });
  }

  Widget _buildSelectStudentStep(StudentProvider studentProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const CustomSectionTitle(title: 'Select Student'),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: GenericSearchBar(
                controller: _searchController,
                onChanged: (value) async {
                  setState(() {
                    _selectedName = value;
                  });
                  await studentProvider.resetAndFetch(
                    name: _selectedName,
                    sort: _selectedSortField,
                    order: _isAscending ? 'ASC' : 'DESC',
                  );
                },
                onClear: () async {
                  setState(() {
                    _selectedName = null;
                  });
                  await studentProvider.resetAndFetch(
                    name: _selectedName,
                    sort: _selectedSortField,
                    order: _isAscending ? 'ASC' : 'DESC',
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.filter_alt),
              onPressed: () => _openSortModal(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: studentProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: studentProvider.students.length,
                  itemBuilder: (context, index) {
                    final student = studentProvider.students[index];
                    return _buildStudentCard(student);
                  },
                ),
        ),
        const SizedBox(height: 20),
        if (_selectedStudent != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              'Selected Student: ${_selectedStudent!.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        CustomElevatedButton(
          onPressed: () {
            if (_selectedStudent != null) {
              setState(() {
                _currentStep = 1;
              });
            } else {
              showCustomSnackBar(
                  context, 'Please select a student before proceeding.');
            }
          },
          text: 'Next',
        ),
      ],
    );
  }

  Widget _buildPaymentDetailsStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const CustomSectionTitle(title: 'Payment Details'),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            children: [
              CustomFormTextField(
                controller: TextEditingController(text: _selectedStudent?.name),
                labelText: 'Selected Student',
                readOnly: true,
                prefixIcon: Icons.person,
                validator: (value) {
                  if (_selectedStudent == null) {
                    return 'Student is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomFormTextField(
                controller: _amountController,
                labelText: 'Amount',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.money,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Amount is required';
                  }
                  final amount = int.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomDateInputField(
                selectedDate: _paymentDate,
                title: 'Payment Date',
                onDateSelected: (selectedDate) async {
                  setState(() {
                    _paymentDate = selectedDate;
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 0;
                      });
                    },
                    text: 'Back',
                  ),
                  CustomElevatedButton(
                    onPressed: _submitPayment,
                    text: 'Submit',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(Student student) {
    bool isSelected = _selectedStudent == student;

    return CustomCard(
      onTap: () {
        _selectStudent(student);
      },
      elevation: isSelected ? 8.0 : 4.0,
      borderRadius: 15.0,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent.withOpacity(0.1) : Colors.white,
          border: isSelected ? Border.all(color: Colors.blue) : null,
          borderRadius: BorderRadius.circular(15.0),
        ),
        padding: const EdgeInsets.all(4.0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              student.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.blueAccent : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

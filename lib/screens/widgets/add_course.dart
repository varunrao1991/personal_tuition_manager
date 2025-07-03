import 'package:flutter/material.dart';
import 'package:personal_tuition_manager/models/subject.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/create_course.dart';
import '../../models/owned_by.dart';
import '../../providers/major/subject_provider.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_form_text_field.dart';
import 'payment_selection.dart';

class AddStudentCourseProcessWidget extends StatefulWidget {
  const AddStudentCourseProcessWidget({super.key});
  
  @override
  _AddStudentCourseProcessWidgetState createState() =>
      _AddStudentCourseProcessWidgetState();
}

class _AddStudentCourseProcessWidgetState
    extends State<AddStudentCourseProcessWidget> {
  int _currentStep = 0;
  OwnedBy? _selectedStudent;
  int? _selectedSubjectId; // Only track one selected subject
  static const int defaultTotalClasses = 23;
  final TextEditingController _totalClassesController =
      TextEditingController(text: defaultTotalClasses.toString());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _subjectScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _subjectScrollController.addListener(_onSubjectScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubjectProvider>(context, listen: false).resetAndFetch();
    });
  }

  void _onSubjectScroll() {
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    if (_subjectScrollController.position.pixels >=
        _subjectScrollController.position.maxScrollExtent - 100) {
      if (!subjectProvider.isLoading &&
          subjectProvider.currentPage < subjectProvider.totalPages) {
        subjectProvider.fetchSubjects(
          page: subjectProvider.currentPage + 1,
          sort: 'name',
          order: 'ASC',
          name: null,
        );
      }
    }
  }

  void _goToNextStep() {
    setState(() {
      _currentStep = 1;
    });
  }

  void _goToPreviousStep() {
    setState(() {
      _currentStep = 0;
    });
  }

  void _submitCourse() {
    if (_formKey.currentState!.validate()) {
      final totalClasses = int.parse(_totalClassesController.text);
      Navigator.of(context).pop(CourseCreate(
        paymentId: _selectedStudent!.id,
        totalClasses: totalClasses,
        subjectId: _selectedSubjectId, // Single subject ID
      ));
    }
  }

  void _selectSubject(int subjectId) {
    setState(() {
      _selectedSubjectId = subjectId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.smallPadding),
        child: _currentStep == 0
            ? PaymentOwnerSelector(
                selectedPayment: _selectedStudent,
                onPaymentSelected: (student) {
                  setState(() {
                    _selectedStudent = student;
                  });
                  _goToNextStep();
                },
              )
            : _buildCourseDetailsStep(),
      ),
    );
  }

  Widget _buildCourseDetailsStep() {
    final subjectProvider = Provider.of<SubjectProvider>(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 16.0),
        Text('Course Details', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16.0),
        
        // Only show subjects if they exist
        if (subjectProvider.anySubjectExists) ...[
          _buildSubjectPills(subjectProvider),
          const SizedBox(height: 16.0),
        ],
        
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
              const SizedBox(height: 16.0),
              CustomFormTextField(
                controller: _totalClassesController,
                labelText: 'Classes',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.class_,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Total classes are required';
                  }
                  final totalClasses = int.tryParse(value);
                  if (totalClasses == null || totalClasses <= 0) {
                    return 'Enter a valid number of classes';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomElevatedButton(
                    onPressed: _goToPreviousStep,
                    text: 'Back',
                  ),
                  CustomElevatedButton(
                    onPressed: _submitCourse,
                    text: 'Submit Payment',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectPills(SubjectProvider subjectProvider) {
    return SizedBox(
      height: 50,
      child: subjectProvider.isLoading && subjectProvider.subjects.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Selected subject pill (fixed at the start)
                if (_selectedSubjectId != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildSubjectPill(
                      subjectProvider.subjects.firstWhere(
                        (s) => s.id == _selectedSubjectId,
                      ),
                      true,
                    ),
                  ),
                
                // Scrollable list of other subjects
                Expanded(
                  child: ListView.builder(
                    controller: _subjectScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: subjectProvider.subjects.length +
                              (subjectProvider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Loading indicator at the end
                      if (index == subjectProvider.subjects.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      
                      final subject = subjectProvider.subjects[index];
                      // Skip if this is the selected subject (it's already shown at the start)
                      if (subject.id == _selectedSubjectId) {
                        return const SizedBox.shrink();
                      }
                      
                      return _buildSubjectPill(subject, false);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSubjectPill(Subject subject, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(subject.name),
        selected: isSelected,
        onSelected: (selected) => _selectSubject(subject.id),
        selectedColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected 
              ? Colors.white 
              : Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _totalClassesController.dispose();
    _subjectScrollController.dispose();
    super.dispose();
  }
}
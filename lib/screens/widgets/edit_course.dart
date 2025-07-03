import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/subject.dart';
import '../../providers/major/subject_provider.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_form_text_field.dart';

class EditCourseWidget extends StatefulWidget {
  final int totalClasses;
  final int? currentSubjectId;

  const EditCourseWidget({
    super.key, 
    required this.totalClasses,
    this.currentSubjectId,
  });

  @override
  _EditCourseWidgetState createState() => _EditCourseWidgetState();
}

class _EditCourseWidgetState extends State<EditCourseWidget> {
  final _formKey = GlobalKey<FormState>();
  final _totalClassesController = TextEditingController();
  final _subjectScrollController = ScrollController();
  int? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    _totalClassesController.text = widget.totalClasses.toString();
    _selectedSubjectId = widget.currentSubjectId;
    _subjectScrollController.addListener(_onSubjectScroll);
    
    // Load subjects if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
      if (subjectProvider.subjects.isEmpty) {
        subjectProvider.resetAndFetch();
      }
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

  Future<void> _saveForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final totalClasses = int.parse(_totalClassesController.text);
      Navigator.of(context).pop({
        'totalClasses': totalClasses,
        'subjectId': _selectedSubjectId,
      });
    }
  }

  void _selectSubject(int subjectId) {
    setState(() {
      _selectedSubjectId = subjectId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final subjectProvider = Provider.of<SubjectProvider>(context);
    
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppPaddings.smallPadding),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 16.0),
                Text('Edit Course',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16.0),
                
                // Subject selection (only if subjects exist)
                if (subjectProvider.anySubjectExists) ...[
                  _buildSubjectPills(subjectProvider),
                  const SizedBox(height: 16.0),
                ],
                
                CustomFormTextField(
                  controller: _totalClassesController,
                  labelText: 'Classes',
                  prefixIcon: Icons.class_,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the total number of classes';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                CustomElevatedButton(
                  text: 'Update',
                  onPressed: () async {
                    await _saveForm(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
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
                      // Skip if this is the selected subject
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
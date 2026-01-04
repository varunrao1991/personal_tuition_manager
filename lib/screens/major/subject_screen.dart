import 'package:flutter/material.dart';
import 'package:personal_tuition_manager/models/subject.dart';
import 'package:personal_tuition_manager/models/subject_form.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/major/subject_provider.dart';
import '../../utils/handle_errors.dart';
import '../../widgets/custom_fab.dart';
import '../../widgets/search_bar.dart';
import '../../utils/show_custom_bottom_modal.dart';
import '../../utils/show_custom_center_modal.dart';
import '../../widgets/sort_modal.dart';
import '../widgets/subject_card.dart';
import '../../widgets/confirmation_modal.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  _SubjectScreenState createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();

  static const Map<String, String> _sortFieldLabels = {
    'name': 'Name',
    'createdAt': 'Created Date',
  };

  String _selectedSortField = 'name';
  String? _selectedName;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSubjects();
    });
  }

  Future<void> _fetchSubjects() async {
    final subjectProvider =
        Provider.of<SubjectProvider>(context, listen: false);
    try {
      await subjectProvider.fetchSubjects(
          page: 1,
          sort: _selectedSortField,
          order: _isAscending ? 'ASC' : 'DESC',
          name: _selectedName);
    } catch (e) {
      handleErrors(context, e);
    }
  }

  void _onScroll() {
    final subjectProvider =
        Provider.of<SubjectProvider>(context, listen: false);

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!subjectProvider.isLoading &&
          subjectProvider.currentPage < subjectProvider.totalPages) {
        try {
          subjectProvider.fetchSubjects(
            page: subjectProvider.currentPage + 1,
            sort: _selectedSortField,
            order: _isAscending ? 'ASC' : 'DESC',
            name: _searchController.text.isNotEmpty
                ? _searchController.text
                : null,
          );
        } catch (e) {
          handleErrors(context, e);
        }
      }
    }
  }

  Future<void> _openSubjectForm({SubjectUpdate? subject}) async {
    await showCustomModalBottomSheet(
      context: context,
      child: SubjectForm(
        subject: subject,
      ),
    );
    _fetchSubjects();
  }

  Future<void> _deleteSubject(int subjectId) async {
    final subjectProvider =
        Provider.of<SubjectProvider>(context, listen: false);
    try {
      await subjectProvider.deleteSubject(subjectId);
    } catch (e) {
      handleErrors(context, e);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Subjects',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterRow(context),
          _buildSubjectList(),
        ],
      ),
      floatingActionButton: CustomFAB(
        icon: Icons.add,
        onPressed: _openSubjectForm,
      ),
    );
  }

  Widget _buildSearchAndFilterRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppPaddings.mediumPadding),
      child: GenericSearchBar(
        controller: _searchController,
        onClear: () => _resetSearch(context),
        onChanged: (value) => _performSearch(context, value),
        onFilterPressed: () => _openSortModal(context),
      ),
    );
  }

  Future<void> _resetSearch(BuildContext context) async {
    setState(() {
      _selectedName = null;
    });
    _searchController.clear();
    await _fetchSubjectsWithCurrentFilters(context);
  }

  Future<void> _performSearch(BuildContext context, String value) async {
    setState(() {
      _selectedName = value;
    });
    try {
      await _fetchSubjectsWithCurrentFilters(context);
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<void> _fetchSubjectsWithCurrentFilters(BuildContext context) async {
    try {
      await Provider.of<SubjectProvider>(context, listen: false).resetAndFetch(
        name: _selectedName,
        sort: _selectedSortField,
        order: _isAscending ? 'ASC' : 'DESC',
      );
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Widget _buildSubjectList() {
    return Expanded(
      child: Consumer<SubjectProvider>(
        builder: (context, subjectProvider, child) {
          if (subjectProvider.isLoading && subjectProvider.subjects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
              padding: const EdgeInsets.all(AppPaddings.smallPadding),
              child: RefreshIndicator(
                onRefresh: _fetchSubjects,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: subjectProvider.subjects.length +
                      (subjectProvider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == subjectProvider.subjects.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return _buildSubjectCard(subjectProvider.subjects[index]);
                  },
                ),
              ));
        },
      ),
    );
  }

  Widget _buildSubjectCard(Subject subject) {
    SubjectUpdate subjectUpdate = SubjectUpdate(
      id: subject.id,
      name: subject.name,
      description: subject.description,
    );
    return SubjectCard(
      subject: subject,
      onEdit: () => _openSubjectForm(subject: subjectUpdate),
      onDelete: () async {
        bool? success = await _showDeleteConfirmationDialog(context);
        if (success == true) {
          _deleteSubject(subject.id);
        }
      },
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showCustomDialog(
      context: context,
      child: const ConfirmationDialog(
        message: 'Delete the subject?',
        confirmButtonText: 'Delete',
        cancelButtonText: 'Cancel',
      ),
    );
  }

  void _openSortModal(BuildContext context) async {
    final result = await showCustomDialog(
      context: context,
      child: SortModal(
        title: 'Sort Subjects',
        selectedSortField: _selectedSortField,
        sortOptions: _sortFieldLabels,
        isAscending: _isAscending,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedSortField = result['field'];
        _isAscending = result['order'];
      });

      final subjectProvider =
          Provider.of<SubjectProvider>(context, listen: false);
      try {
        await subjectProvider.resetAndFetch(
          name: _selectedName,
          sort: _selectedSortField,
          order: _isAscending ? 'ASC' : 'DESC',
        );
      } catch (e) {
        handleErrors(context, e);
      }
    }
  }
}

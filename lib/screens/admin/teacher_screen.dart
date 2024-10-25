import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/admin/teacher_model.dart';
import '../../models/admin/teacher_update.dart';
import '../../providers/admin/teacher_provider.dart';
import '../../utils/handle_errors.dart';
import '../../widgets/custom_fab.dart';
import '../../widgets/search_bar.dart';
import '../../utils/show_custom_bottom_modal.dart';
import '../../utils/show_custom_center_modal.dart';
import '../../widgets/sort_modal.dart';
import 'widgets/teacher_form.dart';
import 'widgets/teacher_card.dart';
import '../../widgets/confirmation_modal.dart';

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  _TeacherScreenState createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();

  static const Map<String, String> _sortFieldLabels = {
    'name': 'Name',
    'mobile': 'Mobile Number',
    'createdAt': 'Joining Date',
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
      _fetchTeachers();
    });
  }

  Future<void> _fetchTeachers() async {
    final teacherProvider =
        Provider.of<TeacherProvider>(context, listen: false);
    try {
      await teacherProvider.fetchTeachers(
          page: 1,
          sort: _selectedSortField,
          order: _isAscending ? 'ASC' : 'DESC',
          name: _selectedName);
    } catch (e) {
      handleErrors(context, e);
    }
  }

  void _onScroll() {
    final teacherProvider =
        Provider.of<TeacherProvider>(context, listen: false);

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!teacherProvider.isLoading &&
          teacherProvider.currentPage < teacherProvider.totalPages) {
        try {
          teacherProvider.fetchTeachers(
            page: teacherProvider.currentPage + 1,
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

  Future<void> _openTeacherForm({TeacherUpdate? teacher}) async {
    await showCustomModalBottomSheet(
      context: context,
      child: TeacherForm(
        teacher: teacher,
      ),
    );
    _fetchTeachers();
  }

  Future<void> _deleteTeacher(int teacherId) async {
    final teacherProvider =
        Provider.of<TeacherProvider>(context, listen: false);
    try {
      await teacherProvider.deleteTeacher(teacherId);
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
      body: Column(
        children: [
          _buildSearchAndFilterRow(context),
          _buildTeacherList(),
        ],
      ),
      floatingActionButton: CustomFAB(
        icon: Icons.add,
        onPressed: _openTeacherForm,
      ),
    );
  }

  Widget _buildSearchAndFilterRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppPaddings.mediumPadding),
      child: Row(
        children: [
          Expanded(
            child: GenericSearchBar(
              controller: _searchController,
              onClear: () => _resetSearch(context),
              onChanged: (value) => _performSearch(context, value),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _openSortModal(context),
          ),
        ],
      ),
    );
  }

  Future<void> _resetSearch(BuildContext context) async {
    setState(() {
      _selectedName = null;
    });
    _searchController.clear();
    try {
      await _fetchTeachersWithCurrentFilters(context);
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<void> _performSearch(BuildContext context, String value) async {
    setState(() {
      _selectedName = value;
    });
    try {
      await _fetchTeachersWithCurrentFilters(context);
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Future<void> _fetchTeachersWithCurrentFilters(BuildContext context) async {
    try {
      await Provider.of<TeacherProvider>(context, listen: false).resetAndFetch(
        name: _selectedName,
        sort: _selectedSortField,
        order: _isAscending ? 'ASC' : 'DESC',
      );
    } catch (e) {
      handleErrors(context, e);
    }
  }

  Widget _buildTeacherList() {
    return Expanded(
      child: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          if (teacherProvider.isLoading && teacherProvider.teachers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
              padding: const EdgeInsets.all(AppPaddings.smallPadding),
              child: RefreshIndicator(
                onRefresh: _fetchTeachers,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: teacherProvider.teachers.length +
                      (teacherProvider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == teacherProvider.teachers.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return _buildTeacherCard(teacherProvider.teachers[index]);
                  },
                ),
              ));
        },
      ),
    );
  }

  Widget _buildTeacherCard(Teacher teacher) {
    TeacherUpdate teacherUpdate = TeacherUpdate.fromTeacher(teacher);
    return TeacherCard(
      teacher: teacher,
      onLongPress: () => _onLongPress(context, teacher.id, teacher.enabled),
      onEdit: () => _openTeacherForm(teacher: teacherUpdate),
      onDelete: () async {
        bool? success = await _showDeleteConfirmationDialog(context);
        if (success == true) {
          _deleteTeacher(teacher.id);
        }
      },
    );
  }

  Future<void> _onLongPress(
      BuildContext context, int teacherId, bool enabled) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(enabled ? 'Disable Teacher' : 'Enable Teacher'),
                onTap: () async {
                  final teacherProvider =
                      Provider.of<TeacherProvider>(context, listen: false);
                  try {
                    await teacherProvider.enableTeacher(teacherId, !enabled);
                  } catch (e) {
                    handleErrors(context, e);
                  }
                  _fetchTeachers();
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showCustomDialog(
      context: context,
      child: const ConfirmationDialog(
        message: 'Delete this teacher?',
        confirmButtonText: 'Delete',
        cancelButtonText: 'Cancel',
      ),
    );
  }

  void _openSortModal(BuildContext context) async {
    final result = await showCustomDialog(
      context: context,
      child: SortModal(
        title: 'Sort Teachers',
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

      final teacherProvider =
          Provider.of<TeacherProvider>(context, listen: false);
      try {
        await teacherProvider.resetAndFetch(
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

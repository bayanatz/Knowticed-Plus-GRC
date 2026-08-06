import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grc_module/core/helper/main_helper/employee_helper.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'grc_owner_state.dart';

class OwnerData {
  final String id;
  final String name;
  final String email;
  final String department;
  final String jobTitle;
  final String photo;
  bool isSelected;

  OwnerData({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.jobTitle,
    required this.photo,
    this.isSelected = false,
  });
}

class GrcOwnerCubit extends Cubit<GrcOwnerState> {
  GrcOwnerCubit() : super(GrcOwnerInitial());

  final TextEditingController searchController = TextEditingController();

  List<OwnerData> _allOwners = [];
  List<OwnerData> filteredOwners = [];
  String _searchQuery = '';
  List<String>? _selectedDepartmentNames;
  List<String> _excludedEmails = const [];

  void loadOwners(
    BuildContext context, {
    List<String> initialOwnerEmails = const [],
    String? selectedDepartmentName,
    List<String>? selectedDepartmentNames,
    List<String> excludeEmails = const [],
  }) {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return;
    final ctrl = Get.find<MainCoreEmployeeController>();
    final employees = ctrl.allEmployeesEntities ?? [];
    _allOwners = employees.map((e) {
      return OwnerData(
        id: e.id ?? '',
        name: EmployeeHelper.getEmployeeLocalizedName(employee: e, context: context),
        email: e.email ?? '',
        department: EmployeeHelper.getEmployeeLocalizeDepartment(employee: e, context: context),
        jobTitle: EmployeeHelper.getEmployeeLocalizedTitle(employee: e, context: context)?.toString() ?? '',
        photo: EmployeeHelper.getEmployeeImage(employee: e),
        isSelected: initialOwnerEmails.contains(e.email ?? ''),
      );
    }).toList();
    _selectedDepartmentNames = selectedDepartmentNames ??
        (selectedDepartmentName == null ? null : [selectedDepartmentName]);
    _excludedEmails = excludeEmails;
    _applyFilters();
  }

  void search(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilters();
  }

  /// Restricts the visible owners to those belonging to [departmentName].
  /// Pass null to clear the department filter and show everyone again.
  void filterByDepartment(String? departmentName) {
    filterByDepartments(departmentName == null ? null : [departmentName]);
  }

  /// Restricts the visible owners to those belonging to any department in
  /// [departmentNames]. Pass null (or empty) to clear the filter and show
  /// everyone again. A Control can be scoped to several departments at
  /// once, unlike a Module (single department), hence the list form.
  void filterByDepartments(List<String>? departmentNames) {
    if (_listEquals(_selectedDepartmentNames, departmentNames)) return;
    _selectedDepartmentNames = departmentNames;
    _applyFilters();
  }

  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Hides whoever is in [emails] from the picker entirely — used so a
  /// person already picked as this Control's Champion can't also be picked
  /// as its Owner (and vice versa). Pass an empty list to clear.
  void filterByExcludedEmails(List<String> emails) {
    if (_listEquals(_excludedEmails, emails)) return;
    _excludedEmails = emails;
    _applyFilters();
  }

  void _applyFilters() {
    filteredOwners = _allOwners.where((o) {
      final matchesDepartment = _selectedDepartmentNames == null ||
          _selectedDepartmentNames!.isEmpty ||
          _selectedDepartmentNames!.contains(o.department);
      final matchesSearch = _searchQuery.isEmpty ||
          o.name.toLowerCase().contains(_searchQuery) ||
          o.department.toLowerCase().contains(_searchQuery) ||
          o.jobTitle.toLowerCase().contains(_searchQuery);
      final notExcluded = !_excludedEmails.contains(o.email);
      return matchesDepartment && matchesSearch && notExcluded;
    }).toList();
    emit(GrcOwnerLoaded());
  }

  /// When [singleSelect] is true, selecting one person clears every other
  /// selection first (so exactly one, or zero, [OwnerData] ends up selected)
  /// instead of the default multi-select toggle.
  void toggleOwner(int index, {bool singleSelect = false}) {
    final tapped = filteredOwners[index];
    if (singleSelect) {
      final wasSelected = tapped.isSelected;
      for (final owner in _allOwners) {
        owner.isSelected = false;
      }
      tapped.isSelected = !wasSelected;
    } else {
      tapped.isSelected = !tapped.isSelected;
    }
    emit(GrcOwnerLoaded());
  }

  List<OwnerData> get selectedOwners =>
      _allOwners.where((o) => o.isSelected).toList();

  @override
  Future<void> close() {
    searchController.dispose();
    return super.close();
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
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

  void loadOwners(
    BuildContext context, {
    List<String> initialOwnerEmails = const [],
    String? selectedDepartmentName,
    List<String>? selectedDepartmentNames,
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

  void _applyFilters() {
    filteredOwners = _allOwners.where((o) {
      final matchesDepartment = _selectedDepartmentNames == null ||
          _selectedDepartmentNames!.isEmpty ||
          _selectedDepartmentNames!.contains(o.department);
      final matchesSearch = _searchQuery.isEmpty ||
          o.name.toLowerCase().contains(_searchQuery) ||
          o.department.toLowerCase().contains(_searchQuery) ||
          o.jobTitle.toLowerCase().contains(_searchQuery);
      return matchesDepartment && matchesSearch;
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

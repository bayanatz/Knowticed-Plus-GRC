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
  String? _selectedDepartmentName;

  void loadOwners(
    BuildContext context, {
    List<String> initialOwnerEmails = const [],
    String? selectedDepartmentName,
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
    _selectedDepartmentName = selectedDepartmentName;
    _applyFilters();
  }

  void search(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilters();
  }

  /// Restricts the visible owners to those belonging to [departmentName].
  /// Pass null to clear the department filter and show everyone again.
  void filterByDepartment(String? departmentName) {
    if (_selectedDepartmentName == departmentName) return;
    _selectedDepartmentName = departmentName;
    _applyFilters();
  }

  void _applyFilters() {
    filteredOwners = _allOwners.where((o) {
      final matchesDepartment = _selectedDepartmentName == null ||
          _selectedDepartmentName!.isEmpty ||
          o.department == _selectedDepartmentName;
      final matchesSearch = _searchQuery.isEmpty ||
          o.name.toLowerCase().contains(_searchQuery) ||
          o.department.toLowerCase().contains(_searchQuery) ||
          o.jobTitle.toLowerCase().contains(_searchQuery);
      return matchesDepartment && matchesSearch;
    }).toList();
    emit(GrcOwnerLoaded());
  }

  void toggleOwner(int index) {
    filteredOwners[index].isSelected = !filteredOwners[index].isSelected;
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

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
  final String departmentId;
  final String jobTitle;
  final String photo;
  bool isSelected;

  OwnerData({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.departmentId,
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
  String? _selectedDepartmentId;

  void loadOwners(
    BuildContext context, {
    List<String> initialOwnerEmails = const [],
    String? selectedDepartmentId,
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
        departmentId: e.departmentId ?? '',
        jobTitle: EmployeeHelper.getEmployeeLocalizedTitle(employee: e, context: context)?.toString() ?? '',
        photo: EmployeeHelper.getEmployeeImage(employee: e),
        isSelected: initialOwnerEmails.contains(e.email ?? ''),
      );
    }).toList();
    _selectedDepartmentId = selectedDepartmentId;
    _applyFilters();
  }

  void search(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilters();
  }

  /// Restricts the visible owners to those belonging to [departmentId].
  /// Pass null to clear the department filter and show everyone again.
  void filterByDepartment(String? departmentId) {
    if (_selectedDepartmentId == departmentId) return;
    _selectedDepartmentId = departmentId;
    _applyFilters();
  }

  void _applyFilters() {
    filteredOwners = _allOwners.where((o) {
      final matchesDepartment = _selectedDepartmentId == null ||
          _selectedDepartmentId!.isEmpty ||
          o.departmentId == _selectedDepartmentId;
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

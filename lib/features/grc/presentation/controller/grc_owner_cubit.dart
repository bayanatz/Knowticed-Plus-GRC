import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'grc_owner_state.dart';

class OwnerData {
  final String id;
  final String name;
  final String department;
  final String jobTitle;
  final String photo;
  bool isSelected;

  OwnerData({
    required this.id,
    required this.name,
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

  void loadOwners(BuildContext context) {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return;
    final ctrl = Get.find<MainCoreEmployeeController>();
    final employees = ctrl.allEmployeesEntities ?? [];
    _allOwners = employees.map((e) {
      return OwnerData(
        id: e.id ?? '',
        name: EmployeeHelper.getEmployeeLocalizedName(employee: e, context: context),
        department: EmployeeHelper.getEmployeeLocalizeDepartment(employee: e, context: context),
        jobTitle: EmployeeHelper.getEmployeeLocalizedTitle(employee: e, context: context)?.toString() ?? '',
        photo: EmployeeHelper.getEmployeeImage(employee: e),
      );
    }).toList();
    filteredOwners = List.from(_allOwners);
    emit(GrcOwnerLoaded());
  }

  void search(String query) {
    final q = query.toLowerCase().trim();
    filteredOwners = q.isEmpty
        ? List.from(_allOwners)
        : _allOwners
            .where((o) =>
                o.name.toLowerCase().contains(q) ||
                o.department.toLowerCase().contains(q) ||
                o.jobTitle.toLowerCase().contains(q))
            .toList();
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

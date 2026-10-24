// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';

import 'package:knowticed_plus/features/org_chart/data/models/department_model.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/org_chart/presentation/employees_views/employee_views_mobile/employee_personal_info.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart'
    as new_department_model;
import 'package:knowticed_plus/features/org_chart/data/repository/departments_repository.dart';
import 'package:knowticed_plus/features/org_chart/helpers/constants/employees_constants.dart';

// name:AddDepartmentController
// date:Jan/10/2024
// by:MohamedFouad
// lastUpdate:Jan/10/2024

class AddDepartmentController extends GetxController with StateMixin {
  final DepartmentsRepository departmentsRepository = DepartmentsRepository();
  final LiveRefresh _live = LiveRefresh();
  Map<String, String> _departmentsArabicNameFromDepartmentId = {};
  Map<String, String> _departmentsEnglishNameFromDepartmentId = {};
  Map<String, String> _getDepartmentIdFromDepartmentName = {};
  List<String> _departmentsEnglishName = [];
  List<String> _departmentsArabicName = [];
  List<String> _departmentIds = [];
  List<String> get departmentsEnglishName => _departmentsEnglishName;
  List<String> get departmentsArabicName => _departmentsArabicName;
  List<String> get departmentIds => _departmentIds;
  // FirebaseFirestore instance for interacting with Firestore.
  FirebaseFirestore db = FirebaseFirestore.instance;
  Rx<DepartmentModel> departmentModel = DepartmentModel().obs;
  List<new_department_model.DepartmentModelPro> allDepartments = [];

  Future addDepartment(
      new_department_model.DepartmentModelPro department) async {
    try {
      await FirebaseFirestore.instance
          .collection(ApiConstants.departments)
          .doc(department.departmentID)
          .set(department.toMap());
    } catch (e) {
      debugPrint('Ignored error: $e');
    }
  }

  Future<List<new_department_model.DepartmentModelPro>>
      getAllDepartments() async {
    final String collectionPath =
        getBaseUrl(ApiConstants.departmentDocumentKey);
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionPath).get();

      List<new_department_model.DepartmentModelPro> departments =
          querySnapshot.docs.map((doc) {
        return new_department_model.DepartmentModelPro.fromMap(
            doc.data() as Map<String, dynamic>);
      }).toList();
      allDepartments = departments;
      _getDepartmentMapsFromDepartmentsList(departments);
      _setDepartmentNamesLists(departments);
      _live.watchPaths(<String>[collectionPath], () async {
        await getAllDepartments();
        update();
      });
      return departments;
    } catch (e) {
      return [];
    }
  }

  void _getDepartmentMapsFromDepartmentsList(
      List<new_department_model.DepartmentModelPro> departments) {
    _departmentsArabicNameFromDepartmentId = {};
    _departmentsEnglishNameFromDepartmentId = {};
    _getDepartmentIdFromDepartmentName = {};
    for (new_department_model.DepartmentModelPro department in departments) {
      _departmentsArabicNameFromDepartmentId[department.departmentID!] =
          department.departmentNameInArabic!;
      _departmentsEnglishNameFromDepartmentId[department.departmentID!] =
          containAbbreviation(department.departmentName!);
      _getDepartmentIdFromDepartmentName[
          department.departmentName!.toLowerCase()] = department.departmentID!;
      _getDepartmentIdFromDepartmentName[department.departmentNameInArabic!] =
          department.departmentID!;
    }
  }

  Future<List<new_department_model.DepartmentModelPro>> getDepartments() async {
    // Same path the (working) roles DepartmentRemoteDataSource uses:
    // "${ApiConstants.baseUri}/Departments" e.g. "Demo/75440689/Departments".
    final String collectionPath =
        getBaseUrl(ApiConstants.departmentDocumentKey);
    try {
      if (ApiConstants.baseUri.isEmpty) {}

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionPath).get();

      List<new_department_model.DepartmentModelPro> departments =
          querySnapshot.docs.map((doc) {
        return new_department_model.DepartmentModelPro.fromMap(
            doc.data() as Map<String, dynamic>);
      }).toList();
      allDepartments = departments;
      _getDepartmentMapsFromDepartmentsList(departments);
      _setDepartmentNamesLists(departments);
      _live.watchPaths(<String>[collectionPath], () async {
        await getAllDepartments();
        update();
      });
      return allDepartments;
    } catch (e) {
      // Previously this returned [] silently, which is why the department
      // filter chips rendered as just "All" with no clue why.
      return [];
    }
  }

  void _setDepartmentNamesLists(
      List<new_department_model.DepartmentModelPro> departments) {
    _departmentsArabicName = [];
    _departmentsEnglishName = [];
    _departmentIds = [];
    for (new_department_model.DepartmentModelPro department in departments) {
      _departmentIds.add(department.departmentID!);
      _departmentsArabicName.add(department.departmentNameInArabic!);
      _departmentsEnglishName
          .add(containAbbreviation(department.departmentName!));
    }
  }

  @override
  void onClose() {
    _live.dispose();
    super.onClose();
  }

  String containAbbreviation(String abbreviation) {
    if (EmployeesConstants.abbreviation.contains(abbreviation)) {
      return abbreviation.toUpperCase();
    }
    return capitalize(abbreviation);
  }

  String? getDepartmentIdFromDepartmentName({required String departmentName}) {
    departmentName.toLowerCase();
    return _getDepartmentIdFromDepartmentName[departmentName];
  }

  String? getEnglishDepartmentNameFromDepartmentId(
      {required String departmentId}) {
    return _departmentsEnglishNameFromDepartmentId[departmentId];
  }

  String? getArabicDepartmentNameFromDepartmentId(
      {required String departmentId}) {
    return _departmentsArabicNameFromDepartmentId[departmentId];
  }

  String? getDepartmentEnglishNameFromArabicName({required String arabicName}) {
    String departmentId =
        getDepartmentIdFromDepartmentName(departmentName: arabicName)!;
    return getEnglishDepartmentNameFromDepartmentId(departmentId: departmentId);
  }

  String? getDepartmentArabicNameFromEnglishName(
      {required String englishName}) {
    String departmentId = getDepartmentIdFromDepartmentName(
        departmentName: englishName.toLowerCase())!;
    return getArabicDepartmentNameFromDepartmentId(departmentId: departmentId);
  }
}

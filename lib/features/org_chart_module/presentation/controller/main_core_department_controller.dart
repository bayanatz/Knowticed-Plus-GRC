// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';

import 'package:grc_module/features/org_chart_module/data/models/department_model.dart';
import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/core/network/get_base_url.dart';
import 'package:grc_module/features/org_chart_module/presentation/employees_views/employee_views_mobile/employee_personal_info.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/department_model.dart'
    as newDepartmentModel;
import 'package:grc_module/features/org_chart_module/data/repository/departments_repository.dart';
import 'package:grc_module/features/org_chart_module/utils/employees_constants.dart';

// name:AddDepartmentController
// date:Jan/10/2024
// by:MohamedFouad
// lastUpdate:Jan/10/2024

class AddDepartmentController extends GetxController with StateMixin {
  final DepartmentsRepository departmentsRepository = DepartmentsRepository();
  Map<String, String> _departmentsArabicNameFromDepartmentId = {};
  Map<String, String> _departmentsEnglishNameFromDepartmentId = {};
  Map<String, String> _getDepartmentIdFromDepartmentName = {};
  List<String> _departmentsEnglishName = [];
  List<String> _departmentsArabicName = [];
  List<String> _departmentIds=[];
  List<String> get departmentsEnglishName => _departmentsEnglishName;
  List<String> get departmentsArabicName => _departmentsArabicName;
  List<String> get departmentIds => _departmentIds;
  // FirebaseFirestore instance for interacting with Firestore.
  FirebaseFirestore db = FirebaseFirestore.instance;
  Rx<DepartmentModel> departmentModel = DepartmentModel().obs;
  List<newDepartmentModel.DepartmentModelPro> allDepartments = [];

  Future addDepartment(newDepartmentModel.DepartmentModelPro department) async {
    try {
      await FirebaseFirestore.instance
          .collection(ApiConstants.departments)
          .doc(department.departmentID)
          .set(department.toMap());
    } catch (e) {
      print("Failed to set department: $e");
    }
  }

  Future<List<newDepartmentModel.DepartmentModelPro>> getAllDepartments() async {
    final String collectionPath =
        getBaseUrl(ApiConstants.departmentDocumentKey);
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionPath).get();

      List<newDepartmentModel.DepartmentModelPro> departments =
          querySnapshot.docs.map((doc) {
        return newDepartmentModel.DepartmentModelPro.fromMap(
            doc.data() as Map<String, dynamic>);
      }).toList();
      allDepartments = departments;
      _getDepartmentMapsFromDepartmentsList(departments);
      _setDepartmentNamesLists(departments);
      print('✅ [Department] getAllDepartments loaded ${departments.length}');
      return departments;
    } catch (e, st) {
      print('❌ [Department] getAllDepartments FAILED for "$collectionPath": $e');
      print(st);
      return [];
    }
  }

  _getDepartmentMapsFromDepartmentsList(
      List<newDepartmentModel.DepartmentModelPro> departments)
  {
    _departmentsArabicNameFromDepartmentId = {};
    _departmentsEnglishNameFromDepartmentId = {};
    _getDepartmentIdFromDepartmentName = {};
    for (newDepartmentModel.DepartmentModelPro department in departments) {
      _departmentsArabicNameFromDepartmentId[department.departmentID!] =
          department.departmentNameInArabic!;
      _departmentsEnglishNameFromDepartmentId[department.departmentID!] =
         containAbbreviation(department.departmentName!);
      _getDepartmentIdFromDepartmentName[department.departmentName!.toLowerCase()] =
          department.departmentID!;
      _getDepartmentIdFromDepartmentName[department.departmentNameInArabic!] =
          department.departmentID!;
    }
  }

  Future<List<newDepartmentModel.DepartmentModelPro>> getDepartments() async {
    // Same path the (working) roles DepartmentRemoteDataSource uses:
    // "${ApiConstants.baseUri}/Departments" e.g. "Demo/75440689/Departments".
    final String collectionPath =
        getBaseUrl(ApiConstants.departmentDocumentKey);
    try {
      print('📁 [Department] baseUri="${ApiConstants.baseUri}"');
      print('📁 [Department] querying collection: $collectionPath');

      if (ApiConstants.baseUri.isEmpty) {
        print('⚠️ [Department] baseUri is EMPTY — the path would resolve to a '
            'top-level "Departments" collection, which is almost certainly not '
            'where the tenant data lives. Departments will come back empty.');
      }

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionPath).get();

      List<newDepartmentModel.DepartmentModelPro> departments =
          querySnapshot.docs.map((doc) {
        return newDepartmentModel.DepartmentModelPro.fromMap(
            doc.data() as Map<String, dynamic>);
      }).toList();
      allDepartments = departments;
      _getDepartmentMapsFromDepartmentsList(departments);
      _setDepartmentNamesLists(departments);
      print('✅ [Department] loaded ${departments.length} departments, '
          'ids=${_departmentIds.length}');
      return allDepartments;
    } catch (e, st) {
      // Previously this returned [] silently, which is why the department
      // filter chips rendered as just "All" with no clue why.
      print('❌ [Department] getDepartments FAILED for "$collectionPath": $e');
      print(st);
      return [];
    }
  }

  _setDepartmentNamesLists(
      List<newDepartmentModel.DepartmentModelPro> departments)
  {
    _departmentsArabicName = [];
    _departmentsEnglishName = [];
    _departmentIds=[];
    for (newDepartmentModel.DepartmentModelPro department in departments) {
      _departmentIds.add(department.departmentID!);
      _departmentsArabicName.add(department.departmentNameInArabic!);
      _departmentsEnglishName
          .add(containAbbreviation(department.departmentName!));
    }
  }

  String containAbbreviation(String abbreviation) {
    if (EmployeesConstants.abbreviation.contains(abbreviation)) {
      return abbreviation.toUpperCase();
    }
    return capitalize(abbreviation);
  }

  String? getDepartmentIdFromDepartmentName(
      {required String departmentName}) {
    departmentName.toLowerCase();
    return _getDepartmentIdFromDepartmentName[departmentName];
  }

  String? getEnglishDepartmentNameFromDepartmentId({required String departmentId}) {
    return _departmentsEnglishNameFromDepartmentId[departmentId];
  }

  String? getArabicDepartmentNameFromDepartmentId({required String departmentId}) {
    return _departmentsArabicNameFromDepartmentId[departmentId];
  }

  getDepartmentEnglishNameFromArabicName({required String arabicName}){
    String departmentId = getDepartmentIdFromDepartmentName(departmentName: arabicName)!;
    return getEnglishDepartmentNameFromDepartmentId(departmentId: departmentId);
  }

  getDepartmentArabicNameFromEnglishName({required String englishName}){
    print("departmentName: $englishName");
    String departmentId = getDepartmentIdFromDepartmentName(departmentName: englishName.toLowerCase())!;
    return getArabicDepartmentNameFromDepartmentId(departmentId: departmentId);
  }
}

// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';
import 'package:demo_app/core/enums/enum.dart';

import 'package:demo_app/core/helper/organization_chart_module/data/models/department_model.dart';
import 'package:demo_app/core/network/api_constants.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/department_model/department_model.dart'
    as newDepartmentModel;
import 'package:demo_app/core/helper/organization_chart_module/data/repository/departments_repository.dart';
import 'package:demo_app/core/helper/organization_chart_module/utils/employees_constants.dart';

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
  List<newDepartmentModel.DepartmentModel> allDepartments = [];

  Future addDepartment(newDepartmentModel.DepartmentModel department) async {
    try {
      await FirebaseFirestore.instance
          .collection(ApiConstants.departments)
          .doc(department.departmentID)
          .set(department.toMap());
    } catch (e) {
      print("Failed to set department: $e");
    }
  }

  Future<List<newDepartmentModel.DepartmentModel>> getAllDepartments() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(ApiConstants.departments).get();

      List<newDepartmentModel.DepartmentModel> departments =
          querySnapshot.docs.map((doc) {
        return newDepartmentModel.DepartmentModel.fromMap(
            doc.data() as Map<String, dynamic>);
      }).toList();
      allDepartments = departments;
      _getDepartmentMapsFromDepartmentsList(departments);
      _setDepartmentNamesLists(departments);
      print("Departments: ${departments.length}");
      return departments;
    } catch (e) {
      return [];
    }
  }

  _getDepartmentMapsFromDepartmentsList(
      List<newDepartmentModel.DepartmentModel> departments)
  {
    _departmentsArabicNameFromDepartmentId = {};
    _departmentsEnglishNameFromDepartmentId = {};
    _getDepartmentIdFromDepartmentName = {};
    for (newDepartmentModel.DepartmentModel department in departments) {
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

  Future<List<newDepartmentModel.DepartmentModel>> getDepartments() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(ApiConstants.departments).get();

      List<newDepartmentModel.DepartmentModel> departments =
          querySnapshot.docs.map((doc) {
        return newDepartmentModel.DepartmentModel.fromMap(
            doc.data() as Map<String, dynamic>);
      }).toList();
      allDepartments = departments;
      _getDepartmentMapsFromDepartmentsList(departments);
      _setDepartmentNamesLists(departments);
      print("Departments: ${departments.length}");
      return allDepartments;
    } catch (e) {
      return [];
    }
  }

  _setDepartmentNamesLists(
      List<newDepartmentModel.DepartmentModel> departments)
  {
    _departmentsArabicName = [];
    _departmentsEnglishName = [];
    _departmentIds=[];
    for (newDepartmentModel.DepartmentModel department in departments) {
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

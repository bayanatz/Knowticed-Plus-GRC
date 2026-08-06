/// ***************************** FILE INFO ***************************** ///
/// File Name: main_core_department_cubit.dart
/// Purpose: Manages the department data within the application.
/// Author: Mohamed Fouad
/// Created At: Jan/10/2024
/// Description: Converted from MainCoreDepartmentController (GetxController).
///              The old onInit() auto-load now runs from the constructor, so
///              creating the cubit still kicks off the department fetch.
/// ********************************************************************* ///

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
// Full import: `Get.locale` is an extension member on GetInterface, so a
// `show Get` clause does not bring it into scope.
import 'package:get/get.dart';

import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/repository/department_repository.dart';

part './main_core_department_state.dart';

class MainCoreDepartmentCubit extends Cubit<MainCoreDepartmentState> {
  /// Kicks off [getAllDepartments] immediately, mirroring the GetxController
  /// `onInit` behaviour the rest of the app relies on.
  MainCoreDepartmentCubit({bool autoLoad = true})
      : super(const MainCoreDepartmentInitial()) {
    if (autoLoad) {
      getAllDepartments();
    }
  }

  DepartmentRepository departmentRepository = DepartmentRepository();
  FirebaseFirestore db = FirebaseFirestore.instance;

  List<DepartmentModelPro> departmentModels = [];

  Map<String, String> _departmentsArabicNameFromDepartmentId = {};
  Map<String, String> _departmentsEnglishNameFromDepartmentId = {};
  Map<String, String> _getDepartmentIdFromDepartmentName = {};
  List<String> _departmentsEnglishName = [];
  List<String> _departmentsArabicName = [];
  List<String> _departmentIds = [];

  List<String> get departmentsEnglishName => _departmentsEnglishName;
  List<String> get departmentsArabicName => _departmentsArabicName;
  List<String> get departmentIds => _departmentIds;

  /// Arabic label for the catch-all "Other" department bucket.
  static const String otherAr = 'أخرى';

  /// Dynamic English -> Arabic department-name map, built from the departments
  /// loaded via [getAllDepartments].
  Map<String, String> get enToAr {
    final Map<String, String> map = {};
    final int length =
        _departmentsEnglishName.length < _departmentsArabicName.length
            ? _departmentsEnglishName.length
            : _departmentsArabicName.length;
    for (int i = 0; i < length; i++) {
      map[_departmentsEnglishName[i]] = _departmentsArabicName[i];
    }
    return map;
  }

  /// Method Name: [getAllDepartments]
  ///
  /// Purpose: get all company departments
  Future<List<DepartmentModelPro>> getAllDepartments() async {
    emit(const MainCoreDepartmentLoading());
    try {
      Either<Failure, dynamic> result =
          await departmentRepository.getDepartments();
      if (result.isRight()) departmentModels = result.getOrElse(() => []);
      _getDepartmentMapsFromDepartmentsList(departmentModels);
      _setDepartmentNamesLists(departmentModels);
      _publish();
      return departmentModels;
    } catch (e) {
      emit(MainCoreDepartmentError(e.toString()));
      return departmentModels;
    }
  }

  void _publish() {
    emit(MainCoreDepartmentLoaded(
      departments: List.unmodifiable(departmentModels),
      englishNames: List.unmodifiable(_departmentsEnglishName),
      arabicNames: List.unmodifiable(_departmentsArabicName),
      departmentIds: List.unmodifiable(_departmentIds),
    ));
  }

  /// Fetches the department name based on the department ID.
  ///
  /// A null [isEnglish] falls back to the active locale, as before. `Get.locale`
  /// is the localization accessor and is unrelated to the GetX state layer this
  /// class was converted away from.
  String getDepartmentName(String departmentId, bool? isEnglish) {
    final bool useEnglish =
        isEnglish ?? Get.locale.toString().contains('en');
    return useEnglish
        ? getEnglishDepartmentNameFromDepartmentId(departmentId: departmentId)!
        : getArabicDepartmentNameFromDepartmentId(departmentId: departmentId)!;
  }

  /// Fetches the department ID based on the department name or its Arabic
  /// counterpart. Returns the department ID if found, otherwise "none".
  String getDepartmentId(String departmentName) {
    List<DepartmentModelPro> departmentModel = departmentModels
        .where((element) =>
            element.departmentName == departmentName ||
            element.departmentNameInArabic == departmentName)
        .toList();

    if (departmentModel.isEmpty) {
      return "none";
    } else {
      return departmentModel.first.departmentID!;
    }
  }

  /// Returns the abbreviation capitalised.
  String containAbbreviation(String abbreviation) {
    return FormatHelper.capitalize(abbreviation);
  }

  void _getDepartmentMapsFromDepartmentsList(
      List<DepartmentModelPro> departments) {
    _departmentsArabicNameFromDepartmentId = {};
    _departmentsEnglishNameFromDepartmentId = {};
    _getDepartmentIdFromDepartmentName = {};
    for (DepartmentModelPro department in departments) {
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

  void _setDepartmentNamesLists(List<DepartmentModelPro> departments) {
    _departmentsArabicName = [];
    _departmentsEnglishName = [];
    _departmentIds = [];
    for (DepartmentModelPro department in departments) {
      _departmentIds.add(department.departmentID!);
      _departmentsArabicName.add(department.departmentNameInArabic!);
      _departmentsEnglishName
          .add(containAbbreviation(department.departmentName!));
    }
  }

  String? getDepartmentIdFromDepartmentName({required String departmentName}) {
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

  dynamic getDepartmentEnglishNameFromArabicName(
      {required String arabicName}) {
    String departmentId =
        getDepartmentIdFromDepartmentName(departmentName: arabicName)!;
    return getEnglishDepartmentNameFromDepartmentId(departmentId: departmentId);
  }

  dynamic getDepartmentArabicNameFromEnglishName(
      {required String englishName}) {
    String departmentId = getDepartmentIdFromDepartmentName(
        departmentName: englishName.toLowerCase())!;
    return getArabicDepartmentNameFromDepartmentId(departmentId: departmentId);
  }
}

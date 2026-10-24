/// ***************************** FILE INFO ***************************** ///
/// File Name: main_core_department_controller.dart
/// Purpose: Manages the department data within the application.
/// Author: Mohamed Fouad
/// Created At: Jan/10/2024
/// Last Updated: 17/1/2025
/// Updated By : Mohammed Yasser
/// Description: Controller for adding and managing departments.
/// ********************************************************************* ///
library;

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/repository/department_repository.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/enums/enum.dart';

class MainCoreDepartmentController extends GetxController with StateMixin {
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

  /// Method Name: [getAllDepartments]
  ///
  /// Purpose: get all company departments
  ///
  /// return type: [List<DepartmentModel>]
  Future<List<DepartmentModelPro>> getAllDepartments() async {
    final result = await departmentRepository.getDepartments();
    if (result.isRight()) departmentModels = result.fold((_) => [], (r) => r);
    _getDepartmentMapsFromDepartmentsList(departmentModels);
    _setDepartmentNamesLists(departmentModels);
    update(); // notify GetBuilder/Obx listeners once data arrives
    return departmentModels;
  }

  bool _isLoadingDepartments = false;

  /// Ensures the department list is loaded. Safe to call repeatedly and from
  /// build methods (it only triggers a network load when the cache is empty
  /// or [force] is set, and de-dupes concurrent calls).
  Future<void> ensureDepartmentsLoaded({bool force = false}) async {
    if (_isLoadingDepartments) return;
    if (!force && departmentModels.isNotEmpty) return;
    _isLoadingDepartments = true;
    try {
      await getAllDepartments();
    } finally {
      _isLoadingDepartments = false;
    }
  }

  /// Method Name: [getDepartmentName]
  ///
  /// Purpose: Fetches the department name based on the department ID.
  ///
  /// Parameters:
  ///            [departmentId] String - The ID of the department.
  String getDepartmentName(String departmentId, bool? isEnglish) {
    // Resolve whether to use the English or Arabic name.
    final bool useEnglish = isEnglish ?? Get.locale.toString().contains('en');

    final String rawId = departmentId.trim();

    // 1️⃣ Direct lookup by department id.
    String? name = useEnglish
        ? getEnglishDepartmentNameFromDepartmentId(departmentId: rawId)
        : getArabicDepartmentNameFromDepartmentId(departmentId: rawId);

    // 2️⃣ Fallback: maybe the value passed in is actually a department NAME
    //     (English or Arabic) rather than an id. Resolve the id, then re-lookup.
    if (name == null || name.isEmpty) {
      final String? resolvedId =
          getDepartmentIdFromDepartmentName(departmentName: rawId) ??
              getDepartmentIdFromDepartmentName(
                  departmentName: rawId.toLowerCase());
      if (resolvedId != null) {
        name = useEnglish
            ? getEnglishDepartmentNameFromDepartmentId(departmentId: resolvedId)
            : getArabicDepartmentNameFromDepartmentId(departmentId: resolvedId);
      }
    }

    // 3️⃣ Self-heal: if nothing is loaded, trigger a (de-duped) reload. When it
    //     completes, update() rebuilds GetBuilder/Obx listeners with the name.
    if ((name == null || name.isEmpty) && departmentModels.isEmpty) {
      ensureDepartmentsLoaded();
      debugPrint(
          '⚠️ [Department] Empty cache while resolving "$rawId" — reloading…');
    } else if (name == null || name.isEmpty) {
      debugPrint('⚠️ [Department] No match for "$rawId". '
          'loaded=${departmentModels.length}, '
          'idKeys=${_departmentsEnglishNameFromDepartmentId.keys.take(5).toList()}');
    }

    return (name == null || name.isEmpty) ? '-' : name;
  }

  /// Fetches the department ID based on the department name or its Arabic counterpart.
  /// [departmentName] - Name of the department.
  /// Returns the department ID if found, otherwise "none".
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

  /// Checks if the given abbreviation is contained in the list of known abbreviations.
  /// [abbreviation] - The abbreviation to check.
  /// Returns the abbreviation in uppercase if it is a known abbreviation, otherwise capitalizes it.
  String containAbbreviation(String abbreviation) {
    return capitalize(abbreviation);
  }

  @override
  void onInit() {
    getAllDepartments();
    super.onInit();
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

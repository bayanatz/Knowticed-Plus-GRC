import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/features/settings/main_controller/data/models/employee_directory_model.dart';
import 'package:grc_module/features/settings/main_controller/data/repository/employees_repository.dart';
import 'package:grc_module/features/settings/se5_emergency_contact/presentation/controller/emergency_contact_controller.dart';
import 'package:grc_module/features/settings/se4_health_insurance/presentation/controller/employees_health_insurance_cubit.dart';

/// Date: Jan/8/2024
/// By: MohamedFouad
/// Description: Controller for Employee management - CRUD operations and
///              employee data retrieval.
///
/// PORTING NOTE (services_app):
/// This is a trimmed port of services_app's
/// `features/employees/presentation/controller/employee_controller.dart`.
/// Only the members that services_app actually references are kept. The
/// org-chart / hierarchy, department CRUD, backup and demo-cleanup code was
/// dropped because it pulled in the whole `features/employees` tree, which
/// services_app does not have.
///
/// Everything else is reused from what already exists in services_app:
///   - NewEmployeeModelHistory  -> features/roles/r4_active_directory/...
///   - MainCoreDepartmentCubit -> features/roles/r4_active_directory/...
///   - MainCoreEmployeeController   -> features/roles/r4_active_directory/...
class EmployeeController extends GetxController with StateMixin {
  /// Repository for employee data operations
  final EmployeesRepository employeesRepository = EmployeesRepository();

  FirebaseFirestore db = FirebaseFirestore.instance;

  /// Department name lookup, reused from active_directory.
  ///
  /// Resolved rather than constructed: creating a second instance here used to
  /// duplicate the Firestore department fetch and could diverge from the one
  /// the widget tree reads via BlocProvider.
  MainCoreDepartmentCubit get addDepartmentController =>
      Get.find<MainCoreDepartmentCubit>();

  /// Currently loaded employee (set by [getEmployee]).
  NewEmployeeModelHistory? employee;

  Rx<NewEmployeeModelHistory> employeeModel = NewEmployeeModelHistory().obs;
  Rx<EmployeeDirectoryModel> employeeDirectoryModel =
      EmployeeDirectoryModel().obs;

  List<NewEmployeeModelHistory>? allEmployees;
  List<NewEmployeeModelHistory>? employeesWithoutFilter;
  List<EmployeeDirectoryModel>? allEmployeesDirectory;

  NewEmployeeModelHistory employeePhone = NewEmployeeModelHistory();
  EmployeeDirectoryModel employeeDirectoryPhone = EmployeeDirectoryModel();

  @override
  onInit() {
    super.onInit();
    getAllEmployees();
    // Registered here (as services_app does) so that
    // SettingsHealthInsuranceController's Get.find<...>() calls resolve.
    Get.put(EmployeesHealthInsuranceCubit());
    Get.put(EmergencyContactController());
  }

  /// Method Name: getAllEmployees
  /// Purpose: load every employee and cache into [allEmployees] /
  ///          [employeesWithoutFilter], then sync MainCoreEmployeeController.
  getAllEmployees() async {
    Either<Failure, dynamic> result;
    result = await employeesRepository.getAllEmployees();

    if (result.isRight()) {
      var rawData = result.getOrElse(() => <NewEmployeeModelHistory>[]);
      employeesWithoutFilter = (rawData is List)
          ? rawData.cast<NewEmployeeModelHistory>()
          : <NewEmployeeModelHistory>[];
      allEmployees = employeesWithoutFilter;
    }

    update();

    try {
      await Get.find<MainCoreEmployeeController>().getAllNewEmployees();

      // ONLY access employee if it's initialized
      if (employee != null && employee!.email.isNotEmpty) {
        String userEmail = employee!.email.last;
        await Get.find<MainCoreEmployeeController>().getNewEmployee(userEmail);
      }
    } catch (e) {
      debugPrint("Error in getAllEmployees: $e");
    }

    return allEmployees;
  }

  /// function name: createEmployee
  /// function purpose: create or update employee in Firestore
  /// parameters:
  ///   - employeeModelNew: NewEmployeeModelHistory - employee data to save
  ///   - email: String - employee email
  Future createEmployee(
      NewEmployeeModelHistory employeeModelNew, String email) async {
    update();

    // Build the correct collection path (same logic as getEmployee)
    String collectionPath;
    if (ApiConstants.baseUri.isNotEmpty) {
      // Demo/Production mode: Demo/84763782/Employees_Info
      collectionPath = '${ApiConstants.baseUri}/Employees_Info';
    } else {
      // Fallback to direct path
      collectionPath = ApiConstants.employeeInfo;
    }

    final CollectionReference employeeCollection = db.collection(collectionPath);
    final dataToSave = employeeModelNew.toMap();

    await employeeCollection
        .doc(employeeModelNew.id)
        .set(dataToSave, SetOptions(merge: true));

    update();
    change(employeeModelNew, status: RxStatus.success());
  }

  /// function name: getEmployee
  /// function purpose: get employee from Firestore by email
  /// return: Future<NewEmployeeModelHistory?> - employee data or null
  Future<NewEmployeeModelHistory?> getEmployee(String email) async {
    String collectionPath;
    if (ApiConstants.baseUri.isNotEmpty) {
      collectionPath = '${ApiConstants.baseUri}/Employees_Info';
    } else {
      collectionPath = ApiConstants.employeeInfo;
    }

    final CollectionReference employeeCollection = db.collection(collectionPath);

    try {
      QuerySnapshot employeeSnapshot = await employeeCollection
          .where('Email', arrayContains: email)
          .limit(1)
          .get();

      if (employeeSnapshot.docs.isNotEmpty) {
        employee = NewEmployeeModelHistory.fromMap(
            employeeSnapshot.docs[0].data() as Map);
        update();
        return employee;
      } else {
        debugPrint("No employee found with email: $email in $collectionPath");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching employee: $e");
      return null;
    }
  }

  /// function name: getEmployeeDirectory
  /// function purpose: get employee directory entry by email
  Future<EmployeeDirectoryModel?> getEmployeeDirectory(String email) async {
    final CollectionReference employeeDirectoryCollection =
        db.collection(ApiConstants.employeesDirectory);
    DocumentSnapshot employeeDirectorySnapshot =
        await employeeDirectoryCollection.doc(email).get();

    if (employeeDirectorySnapshot.exists) {
      EmployeeDirectoryModel employee = EmployeeDirectoryModel.fromMap(
          employeeDirectorySnapshot.data() as Map);
      return employee;
    } else {
      return null;
    }
  }

  /// function name: getLocaleEmployee
  /// function purpose: get cached employee object by email
  NewEmployeeModelHistory getLocaleEmployee(String email) {
    NewEmployeeModelHistory employee = employeesWithoutFilter!
        .firstWhere((element) => email == element.email.last);
    return employee;
  }

  /// function name: getEmployeeName
  /// function purpose: get employee full name based on current locale
  String getEmployeeName(String email) {
    NewEmployeeModelHistory employee = employeesWithoutFilter!
        .firstWhere((element) => email == element.email.last);

    return Get.locale.toString().contains('en')
        ? "${employee.firstName.isNotEmpty ? employee.firstName.last : ''} ${employee.lastName.isNotEmpty ? employee.lastName.last : ''}"
        : "${employee.firstNameInArabic.isNotEmpty ? employee.firstNameInArabic.last : ''} ${employee.lastNameInArabic.isNotEmpty ? employee.lastNameInArabic.last : ''}";
  }

  /// function name: getEmployeeNameEnglishArabic
  /// function purpose: get employee name in a specific language
  String getEmployeeNameEnglishArabic(String email, bool isEnglish) {
    NewEmployeeModelHistory employee = employeesWithoutFilter!
        .firstWhere((element) => email == element.email.last);

    return isEnglish
        ? "${employee.firstName.isNotEmpty ? employee.firstName.last : ''} ${employee.lastName.isNotEmpty ? employee.lastName.last : ''}"
        : "${employee.firstNameInArabic.isNotEmpty ? employee.firstNameInArabic.last : ''} ${employee.lastNameInArabic.isNotEmpty ? employee.lastNameInArabic.last : ''}";
  }

  /// function name: getEmployeeEmailFromId
  /// function purpose: get employee email from employee ID
  String getEmployeeEmailFromId(String employeeId) {
    NewEmployeeModelHistory employee = employeesWithoutFilter!
        .firstWhere((element) => employeeId == element.id);
    return employee.email.isNotEmpty ? employee.email.last : '';
  }

  /// function name: getEmployeeJobTitle
  /// function purpose: get employee job title based on current locale
  String getEmployeeJobTitle(String email) {
    NewEmployeeModelHistory employee = employeesWithoutFilter!
        .firstWhere((element) => email == element.email.last);

    return Get.locale.toString().contains('en')
        ? (employee.title.isNotEmpty ? employee.title.last : '')
        : (employee.titleInArabic.isNotEmpty ? employee.titleInArabic.last : '');
  }

  /// function name: getEmployeePhoto
  /// function purpose: get employee photo URL or a default gendered avatar
  String getEmployeePhoto(String email) {
    NewEmployeeModelHistory employee = employeesWithoutFilter!
        .firstWhere((element) => email == element.email.last);

    bool hasPhoto = employee.photo.isNotEmpty && employee.photo.last.isNotEmpty;

    if (!hasPhoto) {
      bool isFemale = employee.gender.isNotEmpty &&
          employee.gender.last.toLowerCase() == 'female';
      return isFemale
          ? "assets/icons_assets/main_icons_assets/female_avatar.png"
          : "assets/icons_assets/main_icons_assets/male_avatar.png";
    }

    return employee.photo.last;
  }

  /// function name: getDepartment
  /// function purpose: get department name based on current locale
  String getDepartment(String department) {
    return Get.locale.toString().contains('en')
        ? (addDepartmentController.getEnglishDepartmentNameFromDepartmentId(
                    departmentId: department) ??
                "")
            .toLowerCase()
        : (addDepartmentController.getArabicDepartmentNameFromDepartmentId(
                departmentId: department) ??
            "");
  }

  // ── Ported from Knowticed org-chart EmployeeController ──────────────
  /// function name: clearCollection
  /// function purpose: delete all documents in a collection
  /// parameters:
  ///   - collection: CollectionReference - collection to clear
  Future<void> clearCollection(CollectionReference collection) async {
    QuerySnapshot snapshot = await collection.get();
    for (DocumentSnapshot doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// function name: backupCollections
  /// function purpose: create backup of employee collections (2-level backup)
  /// UPDATED: Added comprehensive logging to track backup process
  Future<void> backupCollections() async {
    print("\n╔════════════════════════════════════════════════════════════╗");
    print("║  backupCollections() STARTED                              ║");
    print("╚════════════════════════════════════════════════════════════╝\n");

    final FirebaseFirestore db = FirebaseFirestore.instance;

    print("📍 Step 1: Getting collection references...");

    // ✅ Build consistent paths for all collections
    String mainCollectionPath;
    String backupOneCollectionPath;
    String backupTwoCollectionPath;

    if (ApiConstants.baseUri.isNotEmpty) {
      // Demo/Production mode: Use base URI for ALL collections
      mainCollectionPath = '${ApiConstants.baseUri}/Employees_Info';
      backupOneCollectionPath = '${ApiConstants.baseUri}/Employees Backup One';
      backupTwoCollectionPath = '${ApiConstants.baseUri}/Employees Backup Two';
    } else {
      // Fallback to direct paths
      mainCollectionPath = ApiConstants.employeeInfo;
      backupOneCollectionPath = ApiConstants.employeesProfileBackUpOne;
      backupTwoCollectionPath = ApiConstants.employeesProfileBackUpTwo;
    }

    final CollectionReference employeeCollection = db.collection(mainCollectionPath);
    final CollectionReference backupCollectionOne = db.collection(backupOneCollectionPath);
    final CollectionReference backupCollectionTwo = db.collection(backupTwoCollectionPath);

    print("  - Main collection: $mainCollectionPath");
    print("  - Backup 1 collection: $backupOneCollectionPath");
    print("  - Backup 2 collection: $backupTwoCollectionPath");

    try {
      // ✅ Read FRESH data from main collection
      print("\n📖 Step 2: Reading FRESH data from main collection...");
      QuerySnapshot snapshot = await employeeCollection.get();
      print("  ✓ Successfully read ${snapshot.docs.length} documents from MAIN collection");

      if (snapshot.docs.isNotEmpty) {
        print("  📋 Sample employee IDs from main:");
        for (var doc in snapshot.docs.take(3)) {
          var data = doc.data() as Map<String, dynamic>;
          var email = data['Email'] is List ? data['Email'].last : data['Email'];
          print("    - ID: ${doc.id}, Email: $email");
        }
      } else {
        print("  ⚠️ WARNING: Main collection is EMPTY!");
      }

      print("\n📖 Step 3: Reading current backup 1 data...");
      QuerySnapshot snapshotBackupOne = await backupCollectionOne.get();
      print("  ✓ Successfully read ${snapshotBackupOne.docs.length} documents from BACKUP 1");

      // Move backup 1 to backup 2
      print("\n🔄 Step 4: Moving backup 1 → backup 2...");
      print("  - Clearing backup 2 collection...");
      await clearCollection(backupCollectionTwo);
      print("  ✓ Backup 2 cleared successfully");

      print("  - Copying ${snapshotBackupOne.docs.length} documents to backup 2...");
      int copiedToBackup2 = 0;
      for (var doc in snapshotBackupOne.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        await backupCollectionTwo.doc(doc.id).set(data, SetOptions(merge: true));
        copiedToBackup2++;

        // Progress indicator for large datasets
        if (copiedToBackup2 % 10 == 0) {
          print("    Progress: $copiedToBackup2/${snapshotBackupOne.docs.length} docs copied to backup 2");
        }
      }
      print("  ✓ Successfully copied $copiedToBackup2 documents to backup 2");

      // Move main to backup 1
      print("\n🔄 Step 5: Moving main → backup 1...");
      print("  - Clearing backup 1 collection...");
      await clearCollection(backupCollectionOne);
      print("  ✓ Backup 1 cleared successfully");

      print("  - Copying ${snapshot.docs.length} documents from MAIN to backup 1...");
      int copiedToBackup1 = 0;
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        await backupCollectionOne.doc(doc.id).set(data, SetOptions(merge: true));
        copiedToBackup1++;

        // Progress indicator for large datasets
        if (copiedToBackup1 % 10 == 0) {
          print("    Progress: $copiedToBackup1/${snapshot.docs.length} docs copied to backup 1");
        }
      }
      print("  ✓ Successfully copied $copiedToBackup1 documents to backup 1");

      print("\n╔════════════════════════════════════════════════════════════╗");
      print("║  ✓✓✓ backupCollections() COMPLETED SUCCESSFULLY ✓✓✓       ║");
      print("╚════════════════════════════════════════════════════════════╝");
      print("📊 FINAL BACKUP SUMMARY:");
      print("  - Main collection: ${snapshot.docs.length} employees");
      print("  - Backup 1 (latest): $copiedToBackup1 employees");
      print("  - Backup 2 (previous): $copiedToBackup2 employees");
      print("════════════════════════════════════════════════════════════\n");

    } catch (e, stackTrace) {
      print("\n╔════════════════════════════════════════════════════════════╗");
      print("║  ❌❌❌ backupCollections() FAILED ❌❌❌                   ║");
      print("╚════════════════════════════════════════════════════════════╝");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      rethrow;
    }
  }

  /// function name: restoreFromBackup
  /// function purpose: restore the main employee collection from a backup
  /// parameters:
  ///   - backupVersion: 'first' or 'second' backup to restore from
  Future<void> restoreFromBackup(String backupVersion) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    // ✅ Build the same demo/production-aware paths as backupCollections().
    String mainCollectionPath;
    String backupOneCollectionPath;
    String backupTwoCollectionPath;

    if (ApiConstants.baseUri.isNotEmpty) {
      mainCollectionPath = '${ApiConstants.baseUri}/Employees_Info';
      backupOneCollectionPath = '${ApiConstants.baseUri}/Employees Backup One';
      backupTwoCollectionPath = '${ApiConstants.baseUri}/Employees Backup Two';
    } else {
      mainCollectionPath = ApiConstants.employeeInfo;
      backupOneCollectionPath = ApiConstants.employeesProfileBackUpOne;
      backupTwoCollectionPath = ApiConstants.employeesProfileBackUpTwo;
    }

    final CollectionReference mainCollection = db.collection(mainCollectionPath);
    final CollectionReference backupCollection = db.collection(
        backupVersion == 'second'
            ? backupTwoCollectionPath
            : backupOneCollectionPath);

    // Replace the main collection with the selected backup's contents.
    await clearCollection(mainCollection);

    QuerySnapshot snapshot = await backupCollection.get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      await mainCollection.doc(doc.id).set(data, SetOptions(merge: true));
    }
  }

}

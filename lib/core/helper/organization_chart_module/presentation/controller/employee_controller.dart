import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/network/api_constants.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/helper/organization_chart_module/presentation/controller/employees_hierarchy_drawer.dart';
import 'package:demo_app/core/helper/organization_chart_module/presentation/controller/health_insurance_controller.dart';
import 'package:demo_app/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:demo_app/core/network/failure_model.dart';

import 'package:demo_app/features/employee/data/models/emplyees_model/new_employee_model.dart';
import 'package:demo_app/features/roles/role_management/utils/constants.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/department_model/department_model.dart' as newDepartmentModel;
import 'package:demo_app/core/helper/organization_chart_module/data/models/employee_model/employee_directory_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/repository/employees_repository.dart';
import 'package:demo_app/core/helper/organization_chart_module/domain/entities/organization_hierarchy_node.dart';
import 'package:demo_app/core/helper/organization_chart_module/presentation/controller/main_core_department_controller.dart';
import 'package:demo_app/core/helper/organization_chart_module/presentation/controller/emergency_contact_controller.dart';
import 'package:intl/intl.dart';

/// Date: Jan/8/2024
/// By: MohamedFouad
/// Last Update: Migrated to NewEmployeeModelHistory model
/// Description: Controller for Employee management - handles CRUD operations,
///              hierarchy management, and employee data retrieval

class EmployeeController extends GetxController with StateMixin {
  // Repository for employee data operations
  final EmployeesRepository employeesRepository = EmployeesRepository();

  // Organization hierarchy structures
  Map<String, OrganizationHierarchyNode> organizationHierarchyNodes = {};
  Map<String, OrganizationHierarchyNode> organizationHierarchyNodesRoots = {};

  // View state flags
  bool chartSelected = false;
  bool orgSelected = true;

  // ✅ NEW: Selected department for filtering (stores localized name)
  String? selectedDepartment;

  NewEmployeeModelHistory? employee;

  List<NewEmployeeModelHistory>? allnNewEmployees;
  List<newDepartmentModel.DepartmentModel> newDepartmentModels = [];
  int graphDepth = 0;

  @override
  onInit() {
    super.onInit();
    getAllEmployees();
    Get.put(HealthInsuranceController());
    Get.put(EmergencyContactController());
  }

  /// function name: activateAccount
  /// function purpose: activate a user account (first login)
  /// parameters:
  ///   - employee: NewEmployeeModelHistory - employee to activate
  ///   - isDemoActivation: bool - whether this is a demo activation
  /// ✅ UPDATED: Uses NewEmployeeModelHistory with copyWithUpdateSynchronized
  activateAccount(NewEmployeeModelHistory employee, bool isDemoActivation) {
    // Format the activation date and first login date
    String formattedDate = DateFormat(Constants.userAccessDateFormat, 'en')
        .format(DateTime.now());
    String firstLoginDate = DateTime.now().toString();

    // ✅ Update using copyWithUpdateSynchronized
    employee = employee.copyWithUpdateSynchronized(
      activationDate: formattedDate,
      firstLogin: firstLoginDate,
      addTimestamp: DateTime.now().millisecondsSinceEpoch,
    );

    // ✅ Get last email from array
    String userEmail = employee.email.isNotEmpty
        ? employee.email.last
        : '';

    createEmployee(employee, userEmail);
    activateAccountOverview(userEmail, isDemoActivation);
  }

  FirebaseFirestore db = FirebaseFirestore.instance;


  /// function name: fixSupervisorEmailDomains
  /// function purpose: Update all supervisor emails to match current company domain
  /// parameters:
  ///   - fromDomain: String - old domain (e.g., '@bayanatz.com')
  ///   - toDomain: String - new domain (e.g., '@spacex.com')
  Future<void> fixSupervisorEmailDomains({
    required String fromDomain,
    required String toDomain,
  }) async {
    print("\n╔════════════════════════════════════════════════════════════╗");
    print("║  FIXING SUPERVISOR EMAIL DOMAINS                          ║");
    print("╚════════════════════════════════════════════════════════════╝\n");

    if (allEmployees == null || allEmployees!.isEmpty) {
      print("❌ No employees loaded!");
      return;
    }

    print("📊 Total employees to process: ${allEmployees!.length}");
    print("🔄 Replacing '$fromDomain' with '$toDomain'\n");

    // Build the correct collection path
    String collectionPath;
    if (ApiConstants.baseUri.isNotEmpty) {
      collectionPath = '${ApiConstants.baseUri}/Employees_Info';
    } else {
      collectionPath = ApiConstants.employeeInfo;
    }

    final CollectionReference employeeCollection = db.collection(collectionPath);

    int updatedCount = 0;
    int skippedCount = 0;
    int errorCount = 0;

    for (var employee in allEmployees!) {
      String empEmail = employee.email.isNotEmpty ? employee.email.last : '';
      String empName = "${employee.firstName.isNotEmpty ? employee.firstName.last : ''} ${employee.lastName.isNotEmpty ? employee.lastName.last : ''}".trim();

      // Check if supervisor field needs updating
      if (employee.supervisor?.isNotEmpty == true) {
        String currentSupervisorEmail = employee.supervisor!.last?.trim() ?? '';

        if (currentSupervisorEmail.endsWith(fromDomain)) {
          // Replace the domain
          String newSupervisorEmail = currentSupervisorEmail.replaceAll(fromDomain, toDomain);

          print("🔄 Updating: $empName");
          print("   Old supervisor: $currentSupervisorEmail");
          print("   New supervisor: $newSupervisorEmail");

          try {
            // Create updated supervisor array
            List<String?> updatedSupervisorArray = List.from(employee.supervisor!);
            updatedSupervisorArray[updatedSupervisorArray.length - 1] = newSupervisorEmail;

            // Update in Firestore
            await employeeCollection.doc(employee.id).update({
              'Supervisor': updatedSupervisorArray,
            });

            updatedCount++;
            print("   ✓ Updated successfully\n");

          } catch (e) {
            errorCount++;
            print("   ❌ Error: $e\n");
          }

        } else {
          skippedCount++;
          print("⏭️ Skipped: $empName (supervisor doesn't need update)");
        }
      } else {
        skippedCount++;
        print("⏭️ Skipped: $empName (no supervisor)");
      }
    }

    print("\n╔════════════════════════════════════════════════════════════╗");
    print("║  MIGRATION COMPLETED                                       ║");
    print("╚════════════════════════════════════════════════════════════╝");
    print("📊 SUMMARY:");
    print("  ✓ Successfully updated: $updatedCount employees");
    print("  ⏭️ Skipped: $skippedCount employees");
    print("  ❌ Errors: $errorCount employees");
    print("════════════════════════════════════════════════════════════\n");

    // Reload employees after update
    await getAllEmployees();
    print("🔄 Employee data reloaded. Please rebuild hierarchy.");
  }

  // ✅ UPDATED: Use NewEmployeeModelHistory
  Rx<NewEmployeeModelHistory> employeeModel = NewEmployeeModelHistory().obs;
  Rx<EmployeeDirectoryModel> employeeemployeeDirectoryModelModel =
      EmployeeDirectoryModel().obs;

  List<NewEmployeeModelHistory>? allEmployees;
  List<NewEmployeeModelHistory>? employeesWithoutFilter;
  List<EmployeeDirectoryModel>? allEmployeesDirectory;

  NewEmployeeModelHistory employeePhone = NewEmployeeModelHistory();
  List<MultiSelectDropdownItem<dynamic>> selectedDaysOptions = [];

  void selecteItem(List<MultiSelectDropdownItem<dynamic>> item) {
    selectedDaysOptions.clear();
    selectedDaysOptions.addAll(item);
    update();
  }

  AddDepartmentController addDepartmentController =
  Get.put(AddDepartmentController());
  EmployeeDirectoryModel employeeDirectoryPhone = EmployeeDirectoryModel();

  /// function name: createEmployee
  /// function purpose: create or update employee in Firestore
  /// parameters:
  ///   - employeeModelNew: NewEmployeeModelHistory - employee data to save
  ///   - email: String - employee email
  /// ✅ UPDATED: Uses NewEmployeeModelHistory
  Future createEmployee(
      NewEmployeeModelHistory employeeModelNew, String email) async {
    update();

    // ✅ Build the correct collection path (same logic as getEmployee)
    String collectionPath;
    if (ApiConstants.baseUri.isNotEmpty) {
      // Demo/Production mode: Demo/84763782/Employees_Info
      collectionPath = '${ApiConstants.baseUri}/Employees_Info';
    } else {
      // Fallback to direct path
      collectionPath = ApiConstants.employeeInfo;
    }

    print("📍 Saving employee to: $collectionPath");
    print("📍 Employee ID: ${employeeModelNew.id}");
    print("📍 New Password: ${employeeModelNew.password}");

    final CollectionReference employeeCollection = db.collection(collectionPath);

    final dataToSave = employeeModelNew.toMap();
    print("📍 Password in map: ${dataToSave['Password']}");

    await employeeCollection
        .doc(employeeModelNew.id)
        .set(dataToSave, SetOptions(merge: true));

    print("✅ Employee saved successfully to $collectionPath/${employeeModelNew.id}");

    update();
    change(employeeModelNew, status: RxStatus.success());
  }

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
  /// function purpose: restore employee collection from backup
  /// parameters:
  ///   - backupVersion: String - 'first' or 'second' backup to restore from
  Future<void> restoreFromBackup(String backupVersion) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final CollectionReference mainCollection =
    db.collection(ApiConstants.employeeInfo);
    final CollectionReference backupCollectionOne =
    db.collection(ApiConstants.employeesProfileBackUpOne);
    final CollectionReference backupCollectionTwo =
    db.collection(ApiConstants.employeesProfileBackUpTwo);

    // Clear the main collection
    await clearCollection(mainCollection);

    if (backupVersion == 'first') {
      // Read all documents from backup collection 1
      QuerySnapshot snapshot = await backupCollectionOne.get();

      // Write all documents to the main collection
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        await mainCollection.doc(doc.id).set(data, SetOptions(merge: true));
      }
    } else if (backupVersion == 'second') {
      // Read all documents from backup collection 2
      QuerySnapshot snapshot = await backupCollectionTwo.get();

      // Write all documents to the main collection
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        await mainCollection.doc(doc.id).set(data, SetOptions(merge: true));
      }
    }
  }

  /// Method Name: getAllEmployees
  /// Purpose: function to get all employees and filter active employees
  /// ✅ UPDATED: Returns List<NewEmployeeModelHistory>
  getAllEmployees() async {
    Either<Failure, dynamic> result;
    result = await employeesRepository.getAllEmployees();

    if (result.isRight()) {
      // ✅ Cast properly
      var rawData = result.getOrElse(() => <NewEmployeeModelHistory>[]);
      employeesWithoutFilter = (rawData is List)
          ? rawData.cast<NewEmployeeModelHistory>()
          : <NewEmployeeModelHistory>[];
      allEmployees = employeesWithoutFilter;
    }

    update();

    try {
      await Get.find<MainCoreEmployeeController>().getAllNewEmployees();

      // ✅ ONLY access employee if it's initialized
      if (employee != null && employee!.email.isNotEmpty) {
        String userEmail = employee!.email.last;
        await Get.find<MainCoreEmployeeController>().getNewEmployee(userEmail);
      }
    } catch (e) {
      debugPrint("Error in getAllEmployees: $e");
    }

    return allEmployees;
  }

  /// function name: getEmployeeName
  /// function purpose: get employee full name based on current locale
  /// parameters:
  ///   - email: String - employee email
  /// return: String - employee full name
  /// ✅ UPDATED: Uses array-based fields
  String getEmployeeName(String email) {
    NewEmployeeModelHistory employee = employeesWithoutFilter!
        .firstWhere((element) => email == element.email.last);

    return Get.locale.toString().contains('en')
        ? "${employee.firstName.isNotEmpty ? employee.firstName.last : ''} ${employee.lastName.isNotEmpty ? employee.lastName.last : ''}"
        : "${employee.firstNameInArabic.isNotEmpty ? employee.firstNameInArabic.last : ''} ${employee.lastNameInArabic.isNotEmpty ? employee.lastNameInArabic.last : ''}";
  }

  /// function name: getEmployeeEmailFromId
  /// function purpose: get employee email from employee ID
  /// parameters:
  ///   - employeeId: String - employee ID
  /// return: String - employee email
  /// ✅ UPDATED: Uses array-based email field
  String getEmployeeEmailFromId(String employeeId) {
    NewEmployeeModelHistory employee = employeesWithoutFilter!
        .firstWhere((element) => employeeId == element.id);
    return employee.email.isNotEmpty ? employee.email.last : '';
  }

  /// function name: getEmployeeNameEnglishArabic
  /// function purpose: get employee name in specific language
  /// parameters:
  ///   - email: String - employee email
  ///   - isEnglish: bool - true for English, false for Arabic
  /// return: String - employee full name
  /// ✅ UPDATED: Uses array-based fields
  String getEmployeeNameEnglishArabic(String email, bool isEnglish) {
    NewEmployeeModelHistory employee = employeesWithoutFilter!
        .firstWhere((element) => email == element.email.last);

    return isEnglish
        ? "${employee.firstName.isNotEmpty ? employee.firstName.last : ''} ${employee.lastName.isNotEmpty ? employee.lastName.last : ''}"
        : "${employee.firstNameInArabic.isNotEmpty ? employee.firstNameInArabic.last : ''} ${employee.lastNameInArabic.isNotEmpty ? employee.lastNameInArabic.last : ''}";
  }

  /// function name: getEmployeeJobTitle
  /// function purpose: get employee job title based on current locale
  /// parameters:
  ///   - email: String - employee email
  /// return: String - employee job title
  /// ✅ UPDATED: Uses array-based title fields
  String getEmployeeJobTitle(String email) {
    NewEmployeeModelHistory employee = employeesWithoutFilter!
        .firstWhere((element) => email == element.email.last);

    return Get.locale.toString().contains('en')
        ? (employee.title.isNotEmpty ? employee.title.last : '')
        : (employee.titleInArabic.isNotEmpty ? employee.titleInArabic.last : '');
  }

  /// function name: getEmployeePhoto
  /// function purpose: get employee photo URL or default avatar
  /// parameters:
  ///   - email: String - employee email
  /// return: String - photo URL or asset path
  /// ✅ UPDATED: Uses array-based photo and gender fields
  String getEmployeePhoto(String email) {
    NewEmployeeModelHistory employee = employeesWithoutFilter!
        .firstWhere((element) => email == element.email.last);

    bool hasPhoto = employee.photo.isNotEmpty && employee.photo.last.isNotEmpty;

    if (!hasPhoto) {
      bool isFemale = employee.gender.isNotEmpty &&
          employee.gender.last.toLowerCase() == 'female';
      return isFemale
          ? "assets/icons_assets/main_icons_assets/images_female.svg"
          : "assets/icons_assets/main_icons_assets/assets_male.svg";
    }

    return employee.photo.last;
  }

  /// function name: getDepartment
  /// function purpose: get department name based on current locale
  /// parameters:
  ///   - department: String - department ID
  /// return: String - department name
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

  /// function name: getLocaleEmployee
  /// function purpose: get employee object by email
  /// parameters:
  ///   - email: String - employee email
  /// return: NewEmployeeModelHistory - employee data
  /// ✅ UPDATED: Returns NewEmployeeModelHistory
  NewEmployeeModelHistory getLocaleEmployee(String email) {
    NewEmployeeModelHistory employee = employeesWithoutFilter!
        .firstWhere((element) => email == element.email.last);
    return employee;
  }

  /// function name: getEmployee
  /// function purpose: get employee from Firestore by email
  /// parameters:
  ///   - email: String - employee email
  /// return: Future<NewEmployeeModelHistory?> - employee data or null
  /// ✅ UPDATED: Returns NewEmployeeModelHistory and uses arrayContains
  Future<NewEmployeeModelHistory?> getEmployee(String email) async {
    print("📍 Getting employee for email: $email");
    print("📍 Base URI: ${ApiConstants.baseUri}");

    // ✅ Build the correct collection path
    String collectionPath;
    if (ApiConstants.baseUri.isNotEmpty) {
      // Demo/Production mode: Demo/84763782/Employees_Info
      collectionPath = '${ApiConstants.baseUri}/Employees_Info';
    } else {
      // Fallback to direct path
      collectionPath = ApiConstants.employeeInfo;
    }

    print("📍 Fetching from collection: $collectionPath");

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
        print("✓ Employee loaded successfully!");
        print("  - ID: ${employee?.id}");
        print("  - Email: ${employee?.email?.lastOrNull}");
        print("  - Name: ${employee?.firstName?.lastOrNull} ${employee?.lastName?.lastOrNull}");
        return employee;
      } else {
        print("⚠️ No employee found with email: $email in $collectionPath");
        return null;
      }
    } catch (e, stackTrace) {
      print("❌ Error fetching employee: $e");
      print("Stack trace: $stackTrace");
      return null;
    }
  }

  /// function name: getEmployeeDirectory
  /// function purpose: get employee directory entry by email
  /// parameters:
  ///   - email: String - employee email
  /// return: Future<EmployeeDirectoryModel?> - directory data or null
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
  /// function name: removeKnowticedCompanyAccountsDirect
  /// function purpose: Remove all accounts with @knowticedcompany domain from Demo_Users_Accounts
  /// Uses direct path: Demo_Users_Accounts
  Future<void> removeKnowticedCompanyAccountsDirect() async {
    print("\n╔════════════════════════════════════════════════════════════╗");
    print("║  REMOVING @knowticedcompany ACCOUNTS                       ║");
    print("╚════════════════════════════════════════════════════════════╝\n");

    try {
      // ✅ Direct path to Demo_Users_Accounts
      const String collectionPath = 'Demo_Users_Accounts';

      print("📍 Collection path: $collectionPath");

      final CollectionReference accountsCollection = db.collection(collectionPath);

      // Get all documents
      QuerySnapshot snapshot = await accountsCollection.get();

      print("📊 Total documents found: ${snapshot.docs.length}");

      int deletedCount = 0;
      int skippedCount = 0;
      List<String> deletedEmails = [];

      for (var doc in snapshot.docs) {
        try {
          String docId = doc.id;

          // Document ID is the email itself (based on your screenshot)
          if (docId.contains('@knowticedcompany')) {
            print("🗑️  Deleting: $docId");
            await doc.reference.delete();
            deletedCount++;
            deletedEmails.add(docId);
          } else {
            skippedCount++;
            if (skippedCount <= 3) { // Show first 3 skipped
              print("⏭️  Skipped: $docId (different domain)");
            }
          }
        } catch (e) {
          print("❌ Error processing document ${doc.id}: $e");
        }
      }

      print("\n╔════════════════════════════════════════════════════════════╗");
      print("║  ✅ DELETION COMPLETED SUCCESSFULLY                        ║");
      print("╚════════════════════════════════════════════════════════════╝");
      print("📊 SUMMARY:");
      print("  🗑️  Deleted: $deletedCount accounts");
      print("  ⏭️  Skipped: $skippedCount accounts");

      if (deletedEmails.isNotEmpty) {
        print("\n📧 DELETED EMAILS:");
        for (var email in deletedEmails.take(10)) { // Show first 10
          print("  - $email");
        }
        if (deletedEmails.length > 10) {
          print("  ... and ${deletedEmails.length - 10} more");
        }
      }

      print("════════════════════════════════════════════════════════════\n");

    } catch (e, stackTrace) {
      print("\n╔════════════════════════════════════════════════════════════╗");
      print("║  ❌ DELETION FAILED ❌                                     ║");
      print("╚════════════════════════════════════════════════════════════╝");
      print("Error: $e");
      print("StackTrace: $stackTrace\n");
      rethrow;
    }
  }
  /// function name: filterEmployeesByDepartmentId
  /// function purpose: filter employees by department and build org chart
  /// parameters:
  ///   - value: String? - department ID or 'All'
  /// ✅ UPDATED: Tracks selected department for filter chips and handles null values
  filterEmployeesByDepartmentId(String? value) async {
    List<NewEmployeeModelHistory> graphEmployees = [];

    bool isArabic = Get.locale?.languageCode == 'ar';
    String allLabel = isArabic ? 'الكل' : 'All';

    if (value == null || value == 'All') {
      selectedDepartment = allLabel;
      graphEmployees = List.from(allEmployees ?? []);
    } else {
      selectedDepartment = getDepartment(value);
      if (selectedDepartment?.isEmpty ?? true) selectedDepartment = allLabel;

      // Get the filtered department employees
      List<NewEmployeeModelHistory> deptEmployees = allEmployees!
          .where((employee) =>
      employee.departmentId.isNotEmpty &&
          employee.departmentId.last == value)
          .toList();

      // ✅ Walk up the supervisor chain for each employee and include their full chain
      Set<String> emailsToInclude = {};
      Map<String, NewEmployeeModelHistory> emailMap = {
        for (var e in allEmployees!)
          if (e.email.isNotEmpty) e.email.last.trim(): e
      };

      for (var emp in deptEmployees) {
        String? current = emp.email.isNotEmpty ? emp.email.last.trim() : null;
        while (current != null && !emailsToInclude.contains(current)) {
          emailsToInclude.add(current);
          NewEmployeeModelHistory? empObj = emailMap[current];
          current = (empObj?.supervisor?.isNotEmpty == true)
              ? empObj!.supervisor!.last?.trim()
              : null;
        }
      }

      graphEmployees = allEmployees!
          .where((e) =>
      e.email.isNotEmpty && emailsToInclude.contains(e.email.last.trim()))
          .toList();
    }

    debugPrint("📊 Filtering by department: $value");
    debugPrint("📊 Selected department display: $selectedDepartment");
    debugPrint("📊 Total employees: ${allEmployees?.length ?? 0}");
    debugPrint("📊 Filtered employees: ${graphEmployees.length}");

    buildOrganizationHierarchyGraph(graphEmployees);
    update();
  }

  Map<String, int> topCountries = {};

  /// function name: countCountries
  /// function purpose: count employees by nationality and get top 3
  /// return: Map<String, int> - country counts (top 3)
  /// ✅ UPDATED: Uses array-based nationality field
  Map<String, int> countCountries() {
    Map<String, int> countryCount = {};

    for (var employee in allEmployees!) {
      String nationality = employee.nationality.isNotEmpty
          ? employee.nationality.last
          : 'Unknown';

      if (nationality.isNotEmpty && nationality != 'Unknown') {
        countryCount[nationality] = (countryCount[nationality] ?? 0) + 1;
      }
    }

    var sortedEntries = countryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    topCountries = Map<String, int>.fromEntries(sortedEntries.take(3));
    return topCountries;
  }

  /// function name: activateAccountOverview
  /// function purpose: activate account overview in demo system
  /// parameters:
  ///   - email: String - employee email
  ///   - isDemoActivation: bool - whether this is demo activation
  void activateAccountOverview(String email, bool isDemoActivation) {
    employeesRepository.activateAccountOverview(email, isDemoActivation);
  }


  /// function name: diagnoseHierarchyIssues
  /// function purpose: Diagnose why hierarchy is not building correctly
  /// return: Map with diagnostic results
  Map<String, dynamic> diagnoseHierarchyIssues() {
    print("\n╔════════════════════════════════════════════════════════════╗");
    print("║         HIERARCHY DIAGNOSTIC REPORT                        ║");
    print("╚════════════════════════════════════════════════════════════╝\n");

    Map<String, dynamic> diagnostics = {
      'totalEmployees': allEmployees?.length ?? 0,
      'employeesWithSupervisor': 0,
      'employeesWithoutSupervisor': 0,
      'orphanedEmployees': [],
      'invalidSupervisorEmails': [],
      'ceoCount': 0,
      'supervisorEmailNotFound': [],
      'circularReferences': [],
      'employeeDetails': [],
    };

    if (allEmployees == null || allEmployees!.isEmpty) {
      print("❌ ERROR: No employees loaded!");
      return diagnostics;
    }

    // Create email lookup map
    Map<String, bool> validEmails = {};
    for (var emp in allEmployees!) {
      String email = emp.email.isNotEmpty ? emp.email.last : '';
      if (email.isNotEmpty) {
        validEmails[email.trim()] = true;
      }
    }

    print("📊 TOTAL EMPLOYEES: ${allEmployees!.length}");
    print("📧 VALID EMAIL ADDRESSES: ${validEmails.length}\n");

    // Analyze each employee
    for (var employee in allEmployees!) {
      String empEmail = employee.email.isNotEmpty ? employee.email.last : '';
      String empName = employee.firstName.isNotEmpty && employee.lastName.isNotEmpty
          ? "${employee.firstName.last} ${employee.lastName.last}"
          : empEmail;
      String supervisorEmail = employee.supervisor?.isNotEmpty == true
          ? employee.supervisor!.last?.trim() ?? ''
          : '';
      String title = employee.title.isNotEmpty ? employee.title.last : 'No Title';

      Map<String, dynamic> empDetails = {
        'name': empName,
        'email': empEmail,
        'title': title,
        'supervisorEmail': supervisorEmail,
        'hasSupervisor': supervisorEmail.isNotEmpty,
        'supervisorExists': false,
        'issues': [],
      };

      // Check if has supervisor
      if (supervisorEmail.isEmpty) {
        diagnostics['employeesWithoutSupervisor']++;

        // Check if this should be CEO
        bool isCEO = title.toLowerCase().contains('ceo') ||
            title.toLowerCase().contains('chief executive') ||
            title.contains('رئيس تنفيذي');

        if (isCEO) {
          diagnostics['ceoCount']++;
          empDetails['issues'].add('✓ Valid CEO (no supervisor needed)');
        } else {
          empDetails['issues'].add('⚠️ No supervisor assigned (not CEO)');
          diagnostics['orphanedEmployees'].add(empName);
        }
      } else {
        diagnostics['employeesWithSupervisor']++;

        // Check if supervisor email exists in system
        if (!validEmails.containsKey(supervisorEmail)) {
          empDetails['issues'].add('❌ Supervisor email NOT FOUND in system: $supervisorEmail');
          diagnostics['supervisorEmailNotFound'].add({
            'employee': empName,
            'invalidSupervisor': supervisorEmail,
          });
        } else {
          empDetails['supervisorExists'] = true;
          empDetails['issues'].add('✓ Valid supervisor reference');
        }

        // Check for self-reference
        if (supervisorEmail == empEmail) {
          empDetails['issues'].add('❌ CIRCULAR: Employee is their own supervisor!');
          diagnostics['circularReferences'].add(empName);
        }
      }

      diagnostics['employeeDetails'].add(empDetails);
    }

    // Print detailed report
    print("═══════════════════════════════════════════════════════════");
    print("SUMMARY:");
    print("═══════════════════════════════════════════════════════════");
    print("✓ Employees with supervisor: ${diagnostics['employeesWithSupervisor']}");
    print("⚠ Employees without supervisor: ${diagnostics['employeesWithoutSupervisor']}");
    print("👑 CEO count: ${diagnostics['ceoCount']}");
    print("❌ Invalid supervisor references: ${diagnostics['supervisorEmailNotFound'].length}");
    print("🔄 Circular references: ${diagnostics['circularReferences'].length}");
    print("👥 Orphaned employees: ${diagnostics['orphanedEmployees'].length}\n");

    // Show CEOs
    if (diagnostics['ceoCount'] > 0) {
      print("👑 CEO(s) FOUND:");
      for (var emp in diagnostics['employeeDetails']) {
        if (emp['issues'].toString().contains('Valid CEO')) {
          print("  - ${emp['name']} (${emp['email']})");
          print("    Title: ${emp['title']}");
        }
      }
      print("");
    }

    // Show broken supervisor links
    if (diagnostics['supervisorEmailNotFound'].length > 0) {
      print("❌ BROKEN SUPERVISOR LINKS:");
      for (var issue in diagnostics['supervisorEmailNotFound']) {
        print("  - Employee: ${issue['employee']}");
        print("    Invalid Supervisor Email: ${issue['invalidSupervisor']}");
      }
      print("");
    }

    // Show orphaned employees (non-CEO without supervisor)
    if (diagnostics['orphanedEmployees'].length > 0) {
      print("⚠️ ORPHANED EMPLOYEES (No supervisor, not CEO):");
      for (var emp in diagnostics['employeeDetails']) {
        if (emp['issues'].toString().contains('No supervisor assigned')) {
          print("  - ${emp['name']} (${emp['title']})");
        }
      }
      print("");
    }

    // Show circular references
    if (diagnostics['circularReferences'].length > 0) {
      print("🔄 CIRCULAR REFERENCES:");
      for (var name in diagnostics['circularReferences']) {
        print("  - $name");
      }
      print("");
    }

    // Detailed employee list
    print("═══════════════════════════════════════════════════════════");
    print("DETAILED EMPLOYEE ANALYSIS:");
    print("═══════════════════════════════════════════════════════════");
    for (var emp in diagnostics['employeeDetails']) {
      print("\n👤 ${emp['name']}");
      print("   📧 Email: ${emp['email']}");
      print("   💼 Title: ${emp['title']}");
      print("   👔 Supervisor: ${emp['supervisorEmail'].isEmpty ? 'None' : emp['supervisorEmail']}");
      for (var issue in emp['issues']) {
        print("   $issue");
      }
    }

    print("\n╔════════════════════════════════════════════════════════════╗");
    print("║         END OF DIAGNOSTIC REPORT                           ║");
    print("╚════════════════════════════════════════════════════════════╝\n");

    return diagnostics;
  }

}
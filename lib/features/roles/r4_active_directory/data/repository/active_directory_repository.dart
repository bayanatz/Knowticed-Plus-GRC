/// ************************ FILE INFO ****************************
/// File: active_directory_repository.dart
/// purpose: handle the business logic of the active directory file uploading
/// Author: Mohamed Elrashidy
/// created at: 16/12/2024

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/core/helper/main_helper/single_value_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/data_source/remote_data_source/active_directory_remote_data_source.dart';
import 'package:grc_module/features/roles/r4_active_directory/domain/enums/employee_data_functions.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/employee_controller.dart';

import 'package:grc_module/features/onboarding/o3_authentication/data/models/demo_company_model.dart';
import 'package:grc_module/features/onboarding/o3_authentication/data/models/demo_user_account_overview.dart';

import 'package:grc_module/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:grc_module/features/roles/r1_role_management/data/models/role_access_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/edit_by_model.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/mobile_phone_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/domain/constants/active_directory_constants.dart';
import 'package:grc_module/features/roles/r4_active_directory/domain/enums/employee_data.dart';

class ActiveDirectoryRepository {
  final ActiveDirectoryRemoteDataSource remoteDataSource =
  ActiveDirectoryRemoteDataSource();

  // ─────────────────────────────────────────────────────────────────────────
  // UPLOAD CSV FILE DATA
  // ─────────────────────────────────────────────────────────────────────────

  uploadCsvFileData({
    required List<dynamic> validData,
    required List<dynamic> invalidData,
    required List<String> departmentIds,
    required List<String> employeesIds,
    required String companyId,
    required List<String> employeesEmails,
    required String currentUserEmail,
  }) async {

    try {
      remoteDataSource.startTransaction();

      _uploadWrongData(invalidData: invalidData);

      List<NewEmployeeModelHistory> employees = _uploadValidData(
          validData: validData,
          employeesIds: employeesIds,
          companyId: companyId,
          employeesEmails: employeesEmails);

      _addUserAccess(
          employees: employees, currentUserEmail: currentUserEmail);

      _addDepartment(
          validData: validData,
          departmentsIdsList: departmentIds,
          currentUserEmail: currentUserEmail);

      _removeAdminData();

      var result = await remoteDataSource.endTransaction();

      if (result.isRight()) {
      } else {
      }


      return result;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REMOVE VALID EMPLOYEE
  // ─────────────────────────────────────────────────────────────────────────

  /// function name: removeValidEmployee
  /// purpose: delete a valid employee document from Firebase
  Future<Either<Failure, void>> removeValidEmployee({
    required String employeeId,
  }) async {
    try {
      remoteDataSource.startTransaction();
      remoteDataSource.removeEmployeeWithinTransaction(
          employeeId: employeeId);
      final result = await remoteDataSource.endTransaction();
      return result;
    } catch (e, st) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // EDIT VALID USER DATA
  // ─────────────────────────────────────────────────────────────────────────

  /// function name: editValidUserData
  /// purpose: edit the valid employee data in the database
  Future<Either<Failure, void>> editValidUserData({
    required List<dynamic> editedData,
    required List<String> departmentIds,
    required NewEmployeeModelHistory employee,
    required String currentUserEmail,
  }) async {

    try {
      // Step 1 — build the updated model
      NewEmployeeModelHistory employeeModel = _createEditedEmployeeModel(
        validDataRow: editedData,
        employee: employee,
        isWrongEmployee: false,
      );

      // Step 2 — start batch
      remoteDataSource.startTransaction();

      // Step 3 — queue employee write
      remoteDataSource.uploadEmployeeWithinTransaction(
          employee: employeeModel);

      // Step 4 — queue department write
      _addDepartment(
        validData: [editedData],
        departmentsIdsList: departmentIds,
        currentUserEmail: currentUserEmail,
      );

      // Step 6 — COMMIT
      final Either<Failure, void> result =
      await remoteDataSource.endTransaction();


      return result;
    } catch (e, stackTrace) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CREATE EDITED EMPLOYEE MODEL
  // ─────────────────────────────────────────────────────────────────────────

  /// function name: _createEditedEmployeeModel
  /// purpose: append edited values to the existing employee's tracking arrays.
  ///
  /// KEY DESIGN: NewEmployeeModelHistory stores every field as an array
  /// (history tracking). On edit we APPEND the new value + a new timestamp
  /// rather than overwriting index 0. This preserves the full history and
  /// matches exactly what the Firebase document already contains.
  NewEmployeeModelHistory _createEditedEmployeeModel({
    required List<dynamic> validDataRow,
    required NewEmployeeModelHistory employee,
    required bool isWrongEmployee,
  }) {

    final int now = DateTime.now().millisecondsSinceEpoch;

    // ── Helper: copy existing array and append new string value ────────────
    List<String> _append(List<dynamic>? existing, String newValue) {
      return [
        ...(existing ?? []).map((e) => e?.toString() ?? ''),
        newValue,
      ];
    }

    // ── Typed row from UI ───────────────────────────────────────────────────
    // Enum indices (from employee_data.dart):
    // 0:id  1:firstName  2:middleName  3:lastName
    // 4:firstNameArabic  5:middleNameArabic  6:lastNameArabic
    // 7:email  8:mobileCountryCode  9:mobileNumber
    // 10:homeCountryCode  11:homeNumber  12:officeCountryCode  13:officeNumber
    // 14:extension  15:gender  16:country  17:province  18:city
    // 19:postalCode  20:street  21:language
    // 22:departmentId  23:departmentEnglishName  24:departmentArabicName
    // 25:supervisorEmail  26:role  27:englishTitle  28:arabicTitle
    // 29:workLocation  30:none
    final List<String> row =
    validDataRow.map((e) => e?.toString() ?? '').toList();

    final updated = NewEmployeeModelHistory(
      // ── Identity (never changed from UI) ─────────────────────────────────
      id: employee.id,
      timestamps: List<int>.from(employee.timestamps ?? [])..add(now),

      // ── Names ─────────────────────────────────────────────────────────────
      firstName:          _append(employee.firstName,          row[EmployeeDataItems.firstName.index]),
      middleName:         _append(employee.middleName,         row[EmployeeDataItems.middleName.index]),
      lastName:           _append(employee.lastName,           row[EmployeeDataItems.lastName.index]),
      firstNameInArabic:  _append(employee.firstNameInArabic,  row[EmployeeDataItems.firstNameArabic.index]),
      middleNameInArabic: _append(employee.middleNameInArabic, row[EmployeeDataItems.middleNameArabic.index]),
      lastNameInArabic:   _append(employee.lastNameInArabic,   row[EmployeeDataItems.lastNameArabic.index]),

      // ── Contact (email protected — copy as-is) ────────────────────────────
      email:       List<String>.from(employee.email?.map((e) => e?.toString() ?? '') ?? []),
      officePhone: _append(employee.officePhone, row[EmployeeDataItems.officeNumber.index]),
      homePhone:   _append(employee.homePhone,   row[EmployeeDataItems.homeNumber.index]),
      extension:   _append(employee.extension,   row[EmployeeDataItems.extension.index]),

      // Mobile phone is a complex nested object — keep existing
      mobilePhone: employee.mobilePhone,

      // ── Personal ──────────────────────────────────────────────────────────
      gender:        _append(employee.gender,        row[EmployeeDataItems.gender.index]),
      country:       _append(employee.country,       row[EmployeeDataItems.country.index]),
      province:      _append(employee.province,      row[EmployeeDataItems.province.index]),
      city:          _append(employee.city,          row[EmployeeDataItems.city.index]),
      postalCode:    _append(employee.postalCode,    row[EmployeeDataItems.postalCode.index]),
      street:        _append(employee.street,        row[EmployeeDataItems.street.index]),
      language:      _append(employee.language,      row[EmployeeDataItems.language.index]),

      // Not in the edit table — keep as-is
      birthDay:                 employee.birthDay,
      maritalStatus:            employee.maritalStatus,
      nationality:              employee.nationality,
      nationalId:               employee.nationalId,
      nationalIdExpirationDate: employee.nationalIdExpirationDate,
      passport:                 employee.passport,
      passportExpirationDate:   employee.passportExpirationDate,

      // ── Work ──────────────────────────────────────────────────────────────
      departmentId:  _append(employee.departmentId,  row[EmployeeDataItems.departmentId.index]),
      supervisor:    _append(employee.supervisor,    row[EmployeeDataItems.supervisorEmail.index]),
      role:          _append(employee.role,          row[EmployeeDataItems.role.index]),
      title:         _append(employee.title,         row[EmployeeDataItems.englishTitle.index]),
      titleInArabic: _append(employee.titleInArabic, row[EmployeeDataItems.arabicTitle.index]),
      workLocation:  _append(employee.workLocation,  row[EmployeeDataItems.workLocation.index]),

      // ── Complex fields — keep as-is ───────────────────────────────────────
      drivingLicenseId: employee.drivingLicenseId,
      carPlates:        employee.carPlates,
      academicHistory:  employee.academicHistory,
      bio:              employee.bio,
      photo:            employee.photo,
      skills:           employee.skills,
      hobbies:          employee.hobbies,

      // ── Status — never changed from edit table ────────────────────────────
      status: employee.status,

      // ── Insurance — not in edit table ────────────────────────────────────
      insuranceName:         employee.insuranceName,
      insurancePolicyNumber: employee.insurancePolicyNumber,

      // ── Emergency contacts — not in edit table ────────────────────────────
      firstContactFirstName:    employee.firstContactFirstName,
      firstContactLastName:     employee.firstContactLastName,
      firstContactRelationship: employee.firstContactRelationship,
      firstContactEmail:        employee.firstContactEmail,
      firstContactPhone:        employee.firstContactPhone,
      firstContactLanguage:     employee.firstContactLanguage,
      firstContactCountry:      employee.firstContactCountry,
      firstContactProvince:     employee.firstContactProvince,
      firstContactCity:         employee.firstContactCity,
      firstContactStreet:       employee.firstContactStreet,

      secondContactFirstName:    employee.secondContactFirstName,
      secondContactLastName:     employee.secondContactLastName,
      secondContactRelationship: employee.secondContactRelationship,
      secondContactEmail:        employee.secondContactEmail,
      secondContactPhone:        employee.secondContactPhone,
      secondContactLanguage:     employee.secondContactLanguage,
      secondContactCountry:      employee.secondContactCountry,
      secondContactProvince:     employee.secondContactProvince,
      secondContactCity:         employee.secondContactCity,
      secondContactStreet:       employee.secondContactStreet,

      // ── Auth — never changed from edit table ──────────────────────────────
      password:               employee.password,
      defaultPassword:        employee.defaultPassword,
      passwordExpirationTime: employee.passwordExpirationTime,
      passwordExpirationUnit: employee.passwordExpirationUnit,
      firstLogin:             employee.firstLogin,
      lastLogin:              employee.lastLogin,
      activationDate:         employee.activationDate,
      deactivationDate:       employee.deactivationDate,
    );


    return updated;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPLOAD WRONG DATA
  // ─────────────────────────────────────────────────────────────────────────

  _uploadWrongData({required List<dynamic> invalidData}) {

    for (int i = 0; i < invalidData.length; i++) {
      List<dynamic> row = invalidData[i];
      try {
        var employeeModel = _createEmployeeModel(row, true);
        remoteDataSource.uploadWrongEmployeeWithinTransaction(
            employee: employeeModel);
      } catch (e, stackTrace) {
        rethrow;
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CREATE EMPLOYEE MODEL (new upload)
  // ─────────────────────────────────────────────────────────────────────────

  NewEmployeeModelHistory _createEmployeeModel(
      List<dynamic> row, bool isWrongEmployee) {
    NewEmployeeModelHistory employee = initEmployeeModel();

    for (int i = 0; i < EmployeeDataItems.values.length; i++) {
      EmployeeDataItems item = EmployeeDataItems.values[i];
      if (item == EmployeeDataItems.none) continue;
      try {
        item.updateFieldDirectly(
            employee: employee, data: row, isWrongEmployee: isWrongEmployee);
      } catch (e, stackTrace) {
        rethrow;
      }
    }

    return employee;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INIT EMPLOYEE MODEL
  // ─────────────────────────────────────────────────────────────────────────

  NewEmployeeModelHistory initEmployeeModel() {
    int now = DateTime.now().millisecondsSinceEpoch;

    return NewEmployeeModelHistory(
      id: null,
      timestamps: [now],
      firstName: [''],
      middleName: [''],
      lastName: [''],
      firstNameInArabic: [''],
      middleNameInArabic: [''],
      lastNameInArabic: [''],
      nationalId: [''],
      nationalIdExpirationDate: [''],
      nationality: [''],
      passport: [''],
      passportExpirationDate: [''],
      email: [''],
      mobilePhone: [MobilePhone()],
      officePhone: [''],
      homePhone: [''],
      extension: [''],
      birthDay: [''],
      gender: [''],
      country: [''],
      province: [''],
      city: [''],
      postalCode: [''],
      street: [''],
      maritalStatus: [''],
      language: [''],
      departmentId: [''],
      supervisor: [''],
      role: [''],
      title: [''],
      titleInArabic: [''],
      workLocation: [''],
      drivingLicenseId: [''],
      carPlates: [[]],
      academicHistory: [{}],
      bio: [''],
      photo: [''],
      skills: [[]],
      hobbies: [[]],
      status: ["active"],
      insuranceName: [''],
      insurancePolicyNumber: [''],
      firstContactFirstName: [''],
      firstContactLastName: [''],
      firstContactRelationship: [''],
      firstContactEmail: [''],
      firstContactPhone: [''],
      firstContactLanguage: [''],
      firstContactCountry: [''],
      firstContactProvince: [''],
      firstContactCity: [''],
      firstContactStreet: [''],
      secondContactFirstName: [''],
      secondContactLastName: [''],
      secondContactRelationship: [''],
      secondContactEmail: [''],
      secondContactPhone: [''],
      secondContactLanguage: [''],
      secondContactCountry: [''],
      secondContactProvince: [''],
      secondContactCity: [''],
      secondContactStreet: [''],
      password: null,
      defaultPassword: '123456',
      passwordExpirationTime: null,
      passwordExpirationUnit: null,
      firstLogin: DateTime.now().toString(),
      lastLogin: DateTime.now().toString(),
      activationDate: null,
      deactivationDate: null,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPLOAD VALID DATA
  // ─────────────────────────────────────────────────────────────────────────

  List<NewEmployeeModelHistory> _uploadValidData({
    required List<dynamic> validData,
    required List<String> employeesIds,
    required String companyId,
    required List<String> employeesEmails,
  }) {
    List<NewEmployeeModelHistory> employees = [];


    for (int i = 0; i < validData.length; i++) {
      List<dynamic> row = validData[i];
      NewEmployeeModelHistory employee = _createEmployeeModel(row, false);

      String employeeIdFromCsv =
      row[EmployeeDataItems.id.index].toString().trim();
      bool isAdminEmployee = (employeeIdFromCsv == '1');

      if (isAdminEmployee) {
        updateAdminData(employee);
      }

      employees.add(employee);
      remoteDataSource.uploadEmployeeWithinTransaction(employee: employee);

      if (!isAdminEmployee) {
        DemoUserAccountOverview demoUserAccountOverview =
        DemoUserAccountOverview(
          email: employee.email!.last!.trim().toLowerCase(),
          companyId: companyId,
          isActivated: false,
          demoGranted: null,
          demoActivated: null,
        );
        remoteDataSource.uploadDemoUserOverviewWithinTransaction(
            employee: demoUserAccountOverview);
      }

      remoteDataSource.removeWrongEmployeeWithinTransaction(
          employeeId: employee.id!);
    }

    return employees;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // USER ACCESS
  // ─────────────────────────────────────────────────────────────────────────

  void _addUserAccess(
      {required List<NewEmployeeModelHistory> employees,
        required String currentUserEmail}) {
    Timestamp timestamp = Timestamp.now();
    for (NewEmployeeModelHistory employee in employees) {
      UserPermissionModel userPermissionModel = UserPermissionModel(
        employeeId: employee.id!,
        role: SingleValueModel(
            values: [employee.role!.last!.trim().toLowerCase()],
            timestamps: [timestamp]),
        fromDate: SingleValueModel(
            values: [DateFormat('MMM dd, yyyy').format(DateTime.now())],
            timestamps: [timestamp]),
        toDate: SingleValueModel(values: [
          DateFormat('MMM dd, yyyy')
              .format(DateTime.now().add(const Duration(days: 180)))
        ], timestamps: [
          timestamp
        ]),
        editBy: SingleValueModel(
            values: [currentUserEmail.trim().toLowerCase()],
            timestamps: [timestamp]),
      );
      remoteDataSource.uploadUserAccessWithinTransaction(
          usersAccessModel: userPermissionModel, employeeId: employee.id!);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DEPARTMENTS
  // ─────────────────────────────────────────────────────────────────────────

  void _addDepartment(
      {required List<dynamic> validData,
        required List<String> departmentsIdsList,
        required String currentUserEmail}) {
    Set<String> departmentsIds = Set.from(departmentsIdsList);

    for (List<dynamic> row in validData) {
      if (!departmentsIds
          .contains(row[EmployeeDataItems.departmentId.index])) {
        remoteDataSource.uploadDepartmentWithinTransaction(
            department: DepartmentModelPro(
              departmentID: row[EmployeeDataItems.departmentId.index]
                  .toString()
                  .trim()
                  .toLowerCase(),
              departmentName:
              row[EmployeeDataItems.departmentEnglishName.index]
                  .trim()
                  .toLowerCase(),
              departmentNameInArabic:
              row[EmployeeDataItems.departmentArabicName.index]
                  .trim()
                  .toLowerCase(),
              creationDate: Timestamp.now(),
              addedBy: currentUserEmail.trim().toLowerCase(),
            ));
        departmentsIds.add(row[EmployeeDataItems.departmentId.index]
            .toString()
            .trim()
            .toLowerCase());
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ACCESS TYPES
  // ─────────────────────────────────────────────────────────────────────────


  Future<RoleHistoryModel> _createAccessType(
      NewEmployeeModelHistory employee, String currentUserEmail) async {
    List<String> defaultModules = _getDefaultModulesPermissions();
    String nextRoleId = await RoleHistoryModel.generateNextRoleId();

    return RoleHistoryModel.createNew(
      roleId: nextRoleId,
      roleName: employee.role!.last!.trim().toLowerCase(),
      roleNameAr: '',
      roleDescription: 'Auto-generated role from Active Directory',
      roleDescriptionAr: '',
      roleImage: '',
      createdAt: Timestamp.now(),
      createdBy: currentUserEmail.trim().toLowerCase(),
      status: RoleStatus.active,
      selectedModules: [],
      editBy: EditBy(editorEmail: [], timestamps: []),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DEMO NUMBER OF USERS
  // ─────────────────────────────────────────────────────────────────────────

  getDemoNumberOfUsers({required String currentUserEmail}) async {
    Either<Failure, dynamic> result = await remoteDataSource
        .getDemoUserAccountOverview(currentUserEmail: currentUserEmail);
    if (result.isLeft()) return result;
    DemoUserAccountOverview demoUserAccountOverview =
    DemoUserAccountOverview.fromMap(result.getOrElse(() => {}));
    result = await remoteDataSource.getDemoDetails(
        companyName: demoUserAccountOverview.companyId);
    if (result.isLeft()) return result;
    Map<String, dynamic> demos = result.getOrElse(() => null);
    DemoCompanyModel companyModel = DemoCompanyModel.fromMap(demos);
    return result =
        Right(companyModel.demoDetails!.numberOfUsers!.values.last);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MODULES HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  List<String> _getDefaultModulesPermissions() {
    List<String> demoModules = ModulesCubit().getDemoActiveModules();
    List<String> allowedDefault = [];
    List<String> defaultModuleStrings = _convertEnumListToStringList(
        ActiveDirectoryConstants.defaultAccessTypeModules);
    for (String defaultModule in defaultModuleStrings) {
      if (demoModules.contains(defaultModule)) {
        allowedDefault.add(defaultModule);
      }
    }
    return allowedDefault;
  }

  List<String> _convertEnumListToStringList(List<Modules> moduleEnums) {
    return moduleEnums.map((module) => _moduleEnumToString(module)).toList();
  }

  String _moduleEnumToString(Modules module) {
    switch (module) {
      case Modules.employees:    return 'employees';
      case Modules.services:     return 'services';
      case Modules.tasks:        return 'tasks';
      case Modules.todo:         return 'todo';
      case Modules.events:       return 'events';
      case Modules.notes:        return 'notes';
      case Modules.requests:     return 'requests';
      case Modules.knowledgeHub: return 'knowledge_hub';
      case Modules.qiyas:        return 'qiyas';
      case Modules.tracking:     return 'tracking';
      case Modules.inventory:    return 'inventory';
      case Modules.messages:     return 'messages';
      case Modules.database:     return 'database_builder';
      case Modules.formBuilder:  return 'services_app';
      case Modules.roles:        return 'roles';
      case Modules.settings:     return 'settings';
      default:                   return 'employees';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ADMIN HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  void updateAdminData(NewEmployeeModelHistory employee) {
    NewEmployeeModelHistory? admin;
    try {
      admin = Get.find<EmployeeController>()
          .allEmployees
          ?.firstWhere((element) => element.id == '1');
    } catch (e) {
      return;
    }

    if (admin == null || admin.email.isEmpty || employee.email.isEmpty) return;
    if (admin.email.last != employee.email.last) return;

    employee.password = admin.password;
    employee.activationDate = admin.activationDate;
    employee.deactivationDate = admin.deactivationDate;
    employee.firstLogin = admin.firstLogin;
    employee.lastLogin = admin.lastLogin;
    employee.defaultPassword = admin.defaultPassword;
    if (admin.status.isNotEmpty) employee.status = List.from(admin.status);
    if (admin.role.isNotEmpty) employee.role = List.from(admin.role);

  }

  bool isAdmin(NewEmployeeModelHistory employee) {
    if (employee.email.isEmpty) return false;
    NewEmployeeModelHistory? admin;
    try {
      admin = Get.find<EmployeeController>()
          .allEmployees
          ?.firstWhere((element) => element.id == '1');
    } catch (e) {
      return false;
    }
    if (admin == null || admin.email.isEmpty) return false;
    return admin.email.last == employee.email.last;
  }

  void _removeAdminData() {

    NewEmployeeModelHistory? existingAdmin;
    try {
      existingAdmin = Get.find<EmployeeController>()
          .allEmployees
          ?.firstWhere((element) => element.id == '1');
    } catch (e) {
    }

    if (existingAdmin == null ||
        existingAdmin.email == null ||
        existingAdmin.email!.isEmpty ||
        existingAdmin.email!.last == null ||
        existingAdmin.email!.last!.isEmpty) {
      remoteDataSource.removeEmployeeAdminDefaultModel();
      remoteDataSource.removeUserAccessAdminDefaultModel();
    } else {
    }
  }
}
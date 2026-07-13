import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/features/roles/role_management/domain/use_cases/delete_user_permission_use_case.dart';
import 'package:demo_app/features/settings/presentation/controller/add_company_controller.dart';

import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/roles/role_management/data/repository/user_role_repository.dart';
import 'package:demo_app/features/roles/role_management/domain/entity/user_permission_entity.dart';
import 'package:demo_app/features/roles/role_management/domain/use_cases/update_selected_members_use_case.dart';
import 'package:demo_app/features/roles/role_management/utils/constants.dart';
import 'package:demo_app/features/roles/role_management/utils/user_access_status.dart';

part 'user_management_state.dart';

class UserManagementAccessCubit extends Cubit<UserManagementAccessState> {
  UserManagementAccessCubit() : super(UserManagementInitial());

  TextEditingController homePageSearchController = TextEditingController();
  UserManagementAccessRepository repository = UserManagementAccessRepository();
  Map<String, List<UserPermissionEntity>> roleFilteredUsersPermissions = {};
  Map<UserAccessStatus, List<UserPermissionEntity>>
  accessStatusFilteredUsersPermissions = {};
  String selectedRole = 'all';
  UserAccessStatus selectedUserAccessStatus = UserAccessStatus.all;
  List<UserPermissionEntity> filteredUsersPermissions = [];
  DateTime accessGranted = DateTime.now();
  DateTime accessRevoked = DateTime.now().add(Duration(days: 30 * 6));
  String? newAccessSelectedRole = 'super admin';
  List<String> rolesName = [];
  List<String> rolesNameAr = [];
  List<UserPermissionEntity> employeeToGiveAccess = [];
  List<UserPermissionEntity> filteredEmployeeToGiveAccess = [];
  String? addNewAccessDepartmentId;
  TextEditingController addNewSearchController = TextEditingController();
  Set<String> selectedUsersIdToChangeAccess = {};
  DateTime? creationDate;

  getUserAccess() async {
    // print("════════════════════════════════════════════════════════");
    // print("🎮 [CUBIT] getUserAccess - START");
    // print("════════════════════════════════════════════════════════");

    try {
      // print("🎮 [CUBIT] Step 1: Emitting UserPermissionsDataLoading...");
      emit(UserPermissionsDataLoading());
      // print("✅ [CUBIT] UserPermissionsDataLoading emitted");

      // print("🎮 [CUBIT] Step 2: Calling repository.getUsersPermissionsData()...");
      Either<Failure, dynamic> result = await repository.getUsersPermissionsData();

      // print("🎮 [CUBIT] Step 3: Checking result...");
      // print("   - isLeft: ${result.isLeft()}");
      // print("   - isRight: ${result.isRight()}");

      if (result.isLeft()) {
        Failure failure = result.fold((l) => l, (r) => null)!;
        // print("❌ [CUBIT] ERROR from repository: ${failure.errMessage}");
       // emit(UserPermissionsDataError(failure.errMessage));
        // print("════════════════════════════════════════════════════════");
        return;
      }

      List<UserPermissionEntity> userPermissions = result.getOrElse(() => []);
      // print("✅ [CUBIT] Retrieved ${userPermissions.length} user permissions");

      if (userPermissions.isEmpty) {
        // print("⚠️ [CUBIT] WARNING: No user permissions found!");
      } else {
        // print("🎮 [CUBIT] Sample permissions:");
        for (int i = 0; i < (userPermissions.length > 3 ? 3 : userPermissions.length); i++) {
          // print("   [$i] ${userPermissions[i].englishName} - ${userPermissions[i].accessName}");
        }
      }

      // print("🎮 [CUBIT] Step 4: Calling getUsersPermissionFilteredMaps...");
      getUsersPermissionFilteredMaps(userPermissions);

      // print("🎮 [CUBIT] Step 5: Calling filterHomePageUser...");
      filterHomePageUser(homePageSearchController.text);

      // print("════════════════════════════════════════════════════════");
      // print("🎮 [CUBIT] getUserAccess - END SUCCESS");
      // print("════════════════════════════════════════════════════════");
    } catch (e, stackTrace) {
      // print("════════════════════════════════════════════════════════");
      // print("❌❌❌ [CUBIT] CRITICAL EXCEPTION in getUserAccess ❌❌❌");
      // print("Error: $e");
      // print("Stack trace:\n$stackTrace");
      // print("════════════════════════════════════════════════════════");
     // emit(UserPermissionsDataError(e.toString()));
    }
  }

  void getUsersPermissionFilteredMaps(List<UserPermissionEntity> userPermissions) {
    // print("┌─────────────────────────────────────────────────────┐");
    // print("│ 🗂️  [CUBIT] getUsersPermissionFilteredMaps - START │");
    // print("│ Input: ${userPermissions.length.toString().padRight(3)} permissions                             │");
    // print("└─────────────────────────────────────────────────────┘");

    try {
      // print("🗂️  [CUBIT] Initializing filter maps...");
      roleFilteredUsersPermissions = {};
      accessStatusFilteredUsersPermissions = {};

      // print("🗂️  [CUBIT] Creating status buckets...");
      for (UserAccessStatus status in UserAccessStatus.values) {
        accessStatusFilteredUsersPermissions.putIfAbsent(status, () => []);
        // print("   - ${status.toString()}: initialized");
      }

      // print("🗂️  [CUBIT] Processing ${userPermissions.length} permissions...");
      Map<String, int> roleCount = {};
      Map<UserAccessStatus, int> statusCount = {};

      for (int i = 0; i < userPermissions.length; i++) {
        UserPermissionEntity userPermission = userPermissions[i];

        if (i < 5) {
          // print("   [$i] ${userPermission.englishName}");
          // print("       - Role: ${userPermission.accessName}");
          // print("       - Status: ${userPermission.accessStatus}");
        }

        // ✅ Use role ID (accessName) as key - not localized name
        String roleKey = userPermission.accessName ?? 'unknown';
        roleFilteredUsersPermissions.putIfAbsent(roleKey, () => []);
        roleFilteredUsersPermissions[roleKey]!.add(userPermission);
        roleCount[roleKey] = (roleCount[roleKey] ?? 0) + 1;

        // Add to status filters
        accessStatusFilteredUsersPermissions[userPermission.accessStatus]!.add(userPermission);
        accessStatusFilteredUsersPermissions[UserAccessStatus.all]!.add(userPermission);
        statusCount[userPermission.accessStatus] = (statusCount[userPermission.accessStatus] ?? 0) + 1;
      }

      // print("┌═════════════════════════════════════════════════════┐");
      // print("│ 🗂️  [CUBIT] Filter Maps Created - SUMMARY          │");
      // print("├═════════════════════════════════════════════════════┤");
      // print("│ ROLES:");
      roleCount.forEach((role, count) {
        // print("│   - $role: $count users");
      });
      // print("│");
      // print("│ ACCESS STATUS:");
      statusCount.forEach((status, count) {
        // print("│   - $status: $count users");
      });
      // print("│   - all: ${accessStatusFilteredUsersPermissions[UserAccessStatus.all]!.length} users");
      // print("└═════════════════════════════════════════════════════┘");

    } catch (e, stackTrace) {
      // print("════════════════════════════════════════════════════════");
      // print("❌❌❌ [CUBIT] ERROR in getUsersPermissionFilteredMaps ❌❌❌");
      // print("Error: $e");
      // print("Stack trace:\n$stackTrace");
      // print("════════════════════════════════════════════════════════");
    }
  }
  void selectNewRole(String role) {
    // print("🎯 [CUBIT] selectNewRole: $role");
    selectedRole = role;
    filterHomePageUser(homePageSearchController.text);
  }

  void selectNewAccessStatus(UserAccessStatus status) {
    // print("🎯 [CUBIT] selectNewAccessStatus: $status");
    selectedUserAccessStatus = status;
    filterHomePageUser(homePageSearchController.text);
  }

  void filterHomePageUser(String searchText) {
    // print("┌─────────────────────────────────────────────────────┐");
    // print("│ 🔍 [CUBIT] filterHomePageUser - START              │");
    // print("└─────────────────────────────────────────────────────┘");
    // print("   - Search text: '$searchText'");
    // print("   - Selected role: '$selectedRole'");
    // print("   - Selected status: $selectedUserAccessStatus");

    try {
      filteredUsersPermissions = [];
      Map<UserPermissionEntity, int> userPermissionCount = {};

      // Get users based on selected role
      List<UserPermissionEntity> roleUsers = [];
      if (selectedRole == 'all') {
        // print("   🔍 Getting ALL users from all roles_module...");
        int totalFromRoles = 0;
        roleFilteredUsersPermissions.forEach((key, value) {
          // print("      - Role '$key': ${value.length} users");
          roleUsers.addAll(value);
          totalFromRoles += value.length;
        });
        // print("   🔍 Total users from all roles_module: $totalFromRoles");
      } else {
        roleUsers = roleFilteredUsersPermissions[selectedRole] ?? [];
        // print("   🔍 Users with role '$selectedRole': ${roleUsers.length}");
      }

      // Filter by role and search text
      int roleMatchCount = 0;
      for (UserPermissionEntity permission in roleUsers) {
        if (permission.arabicName.toLowerCase().contains(searchText.toLowerCase()) ||
            permission.englishName.toLowerCase().contains(searchText.toLowerCase())) {
          userPermissionCount.putIfAbsent(permission, () => 0);
          userPermissionCount[permission] = userPermissionCount[permission]! + 1;
          roleMatchCount++;
        }
      }
      // print("   🔍 After role + search filter: $roleMatchCount users");

      // Filter by access status and search text
      int statusMatchCount = 0;
      List<UserPermissionEntity> statusUsers =
          accessStatusFilteredUsersPermissions[selectedUserAccessStatus] ?? [];
      // print("   🔍 Users with status '$selectedUserAccessStatus': ${statusUsers.length}");

      for (UserPermissionEntity permission in statusUsers) {
        if (permission.arabicName.toLowerCase().contains(searchText.toLowerCase()) ||
            permission.englishName.toLowerCase().contains(searchText.toLowerCase())) {
          userPermissionCount.putIfAbsent(permission, () => 0);
          userPermissionCount[permission] = userPermissionCount[permission]! + 1;
          statusMatchCount++;
        }
      }
      // print("   🔍 After status + search filter: $statusMatchCount users");

      // Add users that match both role and status filters (count == 2)
      int finalCount = 0;
      userPermissionCount.forEach((key, value) {
        if (value == 2) {
          filteredUsersPermissions.add(key);
          finalCount++;
          if (finalCount <= 5) {
            // print("      ✅ ${key.englishName} (${key.accessName})");
          }
        }
      });

      // // print("┌═════════════════════════════════════════════════════┐");
      // // print("│ 🔍 [CUBIT] filterHomePageUser - SUMMARY            │");
      // // print("├═════════════════════════════════════════════════════┤");
      // // print("│ Final filtered users: ${filteredUsersPermissions.length.toString().padRight(3)}                        │");
      // // print("│ Emitting: UserPermissionsDataLoaded                │");
      // // print("└═════════════════════════════════════════════════════┘");

      emit(UserPermissionsDataLoaded());

    } catch (e, stackTrace) {
      // print("════════════════════════════════════════════════════════");
      // print("❌❌❌ [CUBIT] ERROR in filterHomePageUser ❌❌❌");
      // print("Error: $e");
      // print("Stack trace:\n$stackTrace");
      // print("════════════════════════════════════════════════════════");
    }
  }

  void initializeWithAllFilter() {
    // print("🎮 [CUBIT] initializeWithAllFilter");
    selectedRole = 'all';
    selectedUserAccessStatus = UserAccessStatus.all;
    // print("   - selectedRole set to: 'all'");
    // print("   - selectedUserAccessStatus set to: all");
  }

  initNewAccessController(List<String> roles, List<String> rolesAr, // ✅ Add rolesAr
          {String? selectedRole, DateTime? creationDate}) {
    accessGranted = DateTime.now();
    accessRevoked = DateTime.now().add(Duration(days: 30 * 6));
    newAccessSelectedRole = null;
    rolesName = roles;
    rolesNameAr = rolesAr; // ✅ Add this
    selectedUsersIdToChangeAccess = {};
    addNewAccessDepartmentId = null;
    addNewSearchController.clear();
    this.creationDate = creationDate;
    if (selectedRole == null) {
      getUsersToGiveAccess();
    } else {
      getSelectedRoleUsers(selectedRole);
    }
  }
  void getUsersToGiveAccess() {
    employeeToGiveAccess = [];
    Get.find<MainCoreEmployeeController>()
        .allEmployeesEntities!
        .forEach((element) {
      if (element.email !=
          Get.find<MainCoreEmployeeController>().employeeEntity!.email) {
        employeeToGiveAccess
            .add(UserPermissionEntity.fromEmployeeEntity(element));
      }
    });
    filterEmployeesToGiveAccess("");
  }

  void filterEmployeesToGiveAccess(String searchText) {

    filteredEmployeeToGiveAccess = [];

    // ✅ Check current employee email
    final mainCoreController = Get.find<MainCoreEmployeeController>();
    final currentEmployeeEmail = mainCoreController.employeeEntity?.email;

    // ✅ Check company email step by step
    try {
      final companyController = Get.find<CompanyController>();

      final companyEmail = companyController.company?.email?.emails?.lastOrNull;


      for (int i = 0; i < employeeToGiveAccess.length; i++) {
        var element = employeeToGiveAccess[i];

        if (i < 3) {
        }

        // Search filter
        bool matchesSearch = element.arabicName.toLowerCase().contains(searchText.toLowerCase()) ||
            element.englishName.toLowerCase().contains(searchText.toLowerCase());

        // Department filter
        bool matchesDepartment = (addNewAccessDepartmentId == null) ||
            (element.departmentId == addNewAccessDepartmentId);

        if (i < 3) {
        }

        if (matchesSearch && matchesDepartment) {
          // ✅ Safe comparison
          bool isCurrentEmployee = element.employeeEmail == currentEmployeeEmail;
          bool isCompanyEmail = companyEmail != null && element.employeeEmail == companyEmail;

          if (isCurrentEmployee || isCompanyEmail) {
            continue;
          }

          filteredEmployeeToGiveAccess.add(element);
        }
      }


      emit(EmployeeToGiveAccessDataLoaded());

    } catch (e, stackTrace) {
      rethrow;
    }
  }

  selectUserToChangeAccess(String employeeId) {
    if (selectedUsersIdToChangeAccess.contains(employeeId)) {
      selectedUsersIdToChangeAccess.remove(employeeId);
    } else {
      selectedUsersIdToChangeAccess.add(employeeId);
    }
    emit(EmployeeToGiveAccessDataLoaded());
  }

  void getSelectedRoleUsers(String selectedRole) {
    employeeToGiveAccess = [];

    if (selectedRole == 'all') {
      roleFilteredUsersPermissions.forEach((key, value) {
        employeeToGiveAccess.addAll(value);
      });
    } else {
      for (var element in roleFilteredUsersPermissions[selectedRole] ?? []) {
        employeeToGiveAccess.add(element);
      }
    }

    filterEmployeesToGiveAccess("");
  }

  removeUserAccess(UserPermissionEntity userPermission) async {
    Either<Failure, dynamic> result =
    await DeleteUserPermissionUseCase(repository).execute(
        permission: userPermission,
        employeeEmail: userPermission.employeeEmail,
        currentUserEmail:
        Get.find<MainCoreEmployeeController>().employeeEntity!.email!);
    if (result.isRight()) {
      getUserAccess();
      getSelectedRoleUsers(selectedRole);
    }
  }

  updateSelectedMembersAccess() async {

    Either<Failure, dynamic> result =
    await UpdateSelectedMembersUseCase(repository).execute(
      accessName: newAccessSelectedRole!,
      startDate:
      DateFormat(Constants.userAccessDateFormat).format(accessGranted),
      endDate: DateFormat(Constants.userAccessDateFormat).format(accessRevoked),
      selectedMembers: Get.find<MainCoreEmployeeController>()
          .allEmployeesEntities!
          .where(
            (element) => selectedUsersIdToChangeAccess.contains(element.id),
      )
          .toList(),
      currentUserEmail:
      Get.find<MainCoreEmployeeController>().employeeEntity!.email!,
    );

    if (result.isRight()) {
      getUserAccess();
      emit(EmployeeToGiveAccessDataLoaded()); // Refresh UI
    } else {
      // ✅ HANDLE ERROR - Show error message
      Failure failure = result.fold((l) => l, (r) => null)!;

      // Emit error state to show in UI
      emit(UserManagementAccessError(failure.errMessage));
    }
  }

  Future<List<Map<String, dynamic>>> getUserAccessHistory(
      String userEmail) async {
    return [];
  }

  List<UserPermissionEntity> getUsersWithExpiringSoon({int days = 14}) {
    return filteredUsersPermissions
        .where((user) => user.accessStatus == UserAccessStatus.expiringSoon)
        .toList();
  }

  List<UserPermissionEntity> getUsersByRole(String roleName) {
    return roleFilteredUsersPermissions[roleName] ?? [];
  }

  Map<UserAccessStatus, int> getAccessSummary() {
    Map<UserAccessStatus, int> summary = {};
    for (UserAccessStatus status in UserAccessStatus.values) {
      summary[status] =
          accessStatusFilteredUsersPermissions[status]?.length ?? 0;
    }
    return summary;
  }

  List<Map<String, dynamic>> exportUserAccessData() {
    return filteredUsersPermissions
        .map((user) => {
      'employeeEmail': user.employeeEmail,
      'englishName': user.englishName,
      'arabicName': user.arabicName,
      'accessName': user.accessName,
      'accessStatus': user.accessStatus.toString(),
      'startDate': user.startDate,
      'endDate': user.endDate,
      'grantorEnglishName': user.grantorEnglishName,
      'grantorArabicName': user.grantorArabicName,
      'departmentId': user.departmentId,
      'jobTitle': user.englishJobTitle,
    })
        .toList();
  }

  Future<void> bulkUpdateAccess({
    required List<String> userIds,
    required String newRole,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    for (String userId in userIds) {
      selectedUsersIdToChangeAccess.add(userId);
    }

    newAccessSelectedRole = newRole;
    accessGranted = startDate;
    accessRevoked = endDate;

    await updateSelectedMembersAccess();
  }

  bool validateAccessDates(DateTime startDate, DateTime endDate) {
    return startDate.isBefore(endDate) && endDate.isAfter(DateTime.now());
  }

  List<UserPermissionEntity> getOverlappingAccess(String userId) {
    return [];
  }
}
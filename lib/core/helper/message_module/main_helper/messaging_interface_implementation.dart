/// Module: core / message_module / main_helper
/// ************************* FILE INFO *************************** ///
/// File Name: messaging_interface_implementation.dart
/// Purpose: Bootstraps the messaging module.
///
///   The messaging feature was copied into this project as files only (see
///   MESSAGING_MIGRATION_NOTES.md) — this file, which actually *wires it up*,
///   was never ported. Without it `MessagingInitController` is never
///   constructed, so `Dependency().init()` never runs, no messaging cubit is
///   ever registered with GetX, and the Messages tab renders empty.
///
///   Ported from Knowticed_plus:
///   `lib/features/messaging/interface/messaging_interface_implementation.dart`
///   with the types remapped to this project:
///     DepartmentModel      -> DepartmentModelPro
///     EmployeeController   -> OrgChartEmployeeController
///
/// Usage (both steps are required, in this order):
///   1. `MessagingInterfaceImplementation().initMessagingModule();`
///      once the signed-in employee + permissions are loaded.
///   2. `await MessagingInterfaceImplementation()
///          .useGroupAndSingleMessaging(context, employee);`
///      before navigating to the Messages tab.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/core/enums/message_module/permissions/messages_more_permissions.dart';
import 'package:grc_module/core/enums/message_module/permissions/messages_permissions.dart';
import 'package:grc_module/core/enums/message_module/permissions/messages_permissions_sections.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/org_chart_module/presentation/controller/employee_controller.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';

import '../interface/controller/messaging_init_controller.dart';
import '../interface/entity/group_chat_interface_parameters.dart';
import '../interface/entity/messaging_configurations.dart';
import '../interface/entity/user_category.dart';
import '../interface/entity/user_connection_interface_parameters.dart';
import '../interface/entity/user_preferred_color.dart';

class MessagingInterfaceImplementation {
  /// Default "All" pseudo-category. The id is arbitrary but must be stable —
  /// `useGroupAndSingleMessaging` inserts it at index 0 keyed on this id.
  static final UserCategory allCategory = UserCategory(
    primaryLanguageName: "All",
    secondaryLanguageName: "كل",
    categoryId: "2343",
  );

  /// Registers [MessagingInitController], whose constructor runs
  /// `Dependency().init()` and puts every messaging cubit into GetX.
  ///
  /// Safe to call more than once — re-registering is skipped.
  void initMessagingModule() {
    if (Get.isRegistered<MessagingInitController>()) return;

    final employeeController = Get.find<MainCoreEmployeeController>();

    bool can(dynamic permission, MessagesPermissionsSections section) =>
        employeeController.isHasPermission(
          module: Modules.messages,
          permission: permission,
          section: section,
        );

    // permanent: this runs during login, and GetX disposes non-permanent
    // instances when the login route is popped.
    Get.put(
      permanent: true,
      MessagingInitController(
        configurations: MessagingConfigurations(
          createGroup: can(MessagesPermissions.createGroup,
              MessagesPermissionsSections.messagesPermissions),
          seenAndUnseen: can(MessagesPermissions.seenAndUnseen,
              MessagesPermissionsSections.messagesPermissions),
          editMessage: can(MessagesPermissions.editMessage,
              MessagesPermissionsSections.messagesPermissions),
          deleteMessage: can(MessagesPermissions.deleteMessage,
              MessagesPermissionsSections.messagesPermissions),
          reactions: can(MessagesPermissions.reactions,
              MessagesPermissionsSections.messagesPermissions),
          forwardMessages: can(MessagesPermissions.forwardMessage,
              MessagesPermissionsSections.messagesPermissions),
          contact: can(MessagesMorePermissions.contact,
              MessagesPermissionsSections.morePermissions),
          location: can(MessagesMorePermissions.location,
              MessagesPermissionsSections.morePermissions),
          photo: can(MessagesMorePermissions.photo,
              MessagesPermissionsSections.morePermissions),
          documents: can(MessagesMorePermissions.documents,
              MessagesPermissionsSections.morePermissions),
          poll: can(MessagesMorePermissions.poll,
              MessagesPermissionsSections.morePermissions),
          muteNotifications: can(MessagesMorePermissions.muteNotifications,
              MessagesPermissionsSections.morePermissions),
          disappearingMessages: can(MessagesMorePermissions.disappearingMessages,
              MessagesPermissionsSections.morePermissions),
          scheduleMessages: can(MessagesMorePermissions.scheduleMessages,
              MessagesPermissionsSections.morePermissions),
          scaffoldBackgroundColor: UserPreferredColor(
            light: Colors.white,
            dark: Colors.black,
          ),
          primaryColor:
              UserPreferredColor(light: Colors.blue, dark: Colors.purple),
          secondaryColor: UserPreferredColor(
            light: Colors.lightBlueAccent,
            dark: Colors.deepPurpleAccent,
          ),
          isSecondaryLanguage: () => Get.locale?.languageCode == 'ar',
          // Messaging push notifications are not wired to a sender yet; the
          // module only needs the callback to exist.
          sendNotification: ({
            required List<String> targetAudienceIds,
            required String englishBody,
            required String englishTitle,
            required String arabicBody,
            required String arabicTitle,
            required Map<String, String> payload,
          }) {},
          baseUri: () => ApiConstants.baseUri,
        ),
      ),
    );
  }

  /// Departments -> messaging categories.
  Future<List<UserCategory>> getCategories() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(ApiConstants.departments)
        .get();

    return snapshot.docs
        .map((e) => DepartmentModelPro.fromMap(e.data()))
        .map((d) => UserCategory(
              primaryLanguageName: d.departmentName ?? '',
              secondaryLanguageName: d.departmentNameInArabic,
              categoryId: d.departmentID ?? '',
            ))
        .toList();
  }

  Timestamp convertDate(String date) =>
      Timestamp.fromDate(DateTime.parse(date));

  /// Every employee, shaped as a messaging connection.
  ///
  /// Employees whose record is missing a field the module requires are skipped
  /// rather than aborting the whole list — matches the original behaviour.
  Future<List<UserConnectionInterfaceParameters>> getAllUsersData() async {
    final categories = await getCategories();
    final snapshot = await FirebaseFirestore.instance
        .collection(ApiConstants.employeesProfile)
        .get();

    final users = <UserConnectionInterfaceParameters>[];
    for (final doc in snapshot.docs) {
      final employee = NewEmployeeModelHistory.fromMap(doc.data());
      try {
        users.add(
          UserConnectionInterfaceParameters(
            primaryLanguageName:
                '${employee.firstName!.last!} ${employee.lastName!.last!}',
            secondaryLanguageName:
                '${employee.firstNameInArabic!.last!} ${employee.lastNameInArabic!.last!}',
            primaryLanguageSubInfo: employee.title!.last!,
            secondaryLanguageSubInfo: employee.titleInArabic!.last!,
            imageUri: _photoOf(employee)!,
            userId: employee.email!.last!,
            phone: "",
            userCategory: categories.firstWhere(
              (c) => c.categoryId == employee.departmentId!.last!,
              orElse: () => allCategory,
            ),
            userAccountActivationTime: convertDate(employee.firstLogin!),
          ),
        );
      } catch (_) {
        // Incomplete employee record — skip it.
      }
    }
    return users;
  }

  /// Hands the signed-in user + category list to the messaging module.
  /// Must run before the Messages tab is opened.
  Future<void> useGroupAndSingleMessaging(
    BuildContext context,
    NewEmployeeModelHistory employee,
  ) async {
    initMessagingModule();

    final categories = await getCategories();
    if (!context.mounted) return;

    final groupChatParameters = GroupChatInterfaceParameters(
      primaryLanguageName:
          '${employee.firstName!.last!} ${employee.lastName!.last!}',
      secondaryLanguageName:
          '${employee.firstNameInArabic!.last!} ${employee.lastNameInArabic!.last!}',
      primaryLanguageSubInfo: employee.title!.last!,
      secondaryLanguageSubInfo: employee.titleInArabic!.last!,
      imageUri: _photoOf(employee)!,
      userId: employee.email!.last!,
      phone: "",
      userCategory: categories.firstWhere(
        (c) => c.categoryId == employee.departmentId!.last!,
        orElse: () => allCategory,
      ),
      categories: categories,
    );

    Get.find<MessagingInitController>().useGroupAndSingleMessaging(
      context: context,
      groupChatParameters: groupChatParameters,
      defaultCategory: allCategory,
      getAllUsersDate: getAllUsersData,
    );
  }

  /// Photo straight off the record, falling back to the org-chart lookup.
  String? _photoOf(NewEmployeeModelHistory employee) {
    try {
      return employee.photo!.last!;
    } catch (_) {
      try {
        return Get.find<OrgChartEmployeeController>()
            .getEmployeePhoto(employee.email!.last!);
      } catch (_) {
        return null;
      }
    }
  }
}

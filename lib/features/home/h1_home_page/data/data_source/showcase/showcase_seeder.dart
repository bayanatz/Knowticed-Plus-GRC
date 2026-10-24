/// Module: home/h1_home_page / data / data_source / showcase
///
///*************************** FILE INFO ****************************///
/// File Name: showcase_seeder.dart
/// Purpose: Owner-only "Fill showcase data": writes professional demo
///          records for every module shown to clients, spread over the year,
///          in the app's current language. Each module runs on its own, so
///          one module's failure is reported without stopping the others.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// Reached only from the `kOwnerTools` debug menu. Never deletes anything;
/// every document has a fixed `showcase_` id, so a second run overwrites.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_calendar.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_common.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_database.dart'; // [module:database]
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_form_builder.dart'; // [module:form_builder]
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_grc.dart'; // [module:grc]
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_knowledge_hub.dart'; // [module:knowledge_hub]
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_messages.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_org_chart.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_roles.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_services.dart'; // [module:services]
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_settings.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_time_tracker.dart'; // [module:time_tracker]
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_todo.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

/// Result of one module: documents written, or the error it hit.
class ShowcaseModuleResult {
  const ShowcaseModuleResult(this.module, {this.count = 0, this.error});

  final String module;
  final int count;
  final String? error;
}

typedef _Step = Future<int> Function();

abstract final class ShowcaseSeeder {
  /// Function Name: [run]
  ///
  /// Purpose: Fills every module; [onProgress] gets each module's result as
  /// it finishes.
  static Future<List<ShowcaseModuleResult>> run({
    required bool isArabic,
    void Function(ShowcaseModuleResult result)? onProgress,
  }) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final DateTime now = DateTime.now();
    final ShowcasePerson me = _loadPeople(isArabic);

    final Map<String, _Step> steps = <String, _Step>{
      'Org Chart': () => ShowcaseOrgChart.seed(
          firestore: db, me: me, isArabic: isArabic, now: now),
      'Roles': () => ShowcaseRoles.seed(
          firestore: db, me: me, isArabic: isArabic, now: now),
      'Messages': () => ShowcaseMessages.seed(
          firestore: db, me: me, isArabic: isArabic, now: now),
      // [module:grc]
      'GRC': () =>
          ShowcaseGrc.seed(firestore: db, me: me, isArabic: isArabic, now: now),
      // [/module:grc]
      // [module:database]
      'Database': () => ShowcaseDatabase.seed(
          firestore: db, me: me, isArabic: isArabic, now: now),
      // [/module:database]
      // [module:knowledge_hub]
      'Knowledge Hub': () => ShowcaseKnowledgeHub.seed(
          firestore: db, me: me, isArabic: isArabic, now: now),
      // [/module:knowledge_hub]
      // [module:form_builder]
      'Form Builder': () => ShowcaseFormBuilder.seed(
          firestore: db, me: me, isArabic: isArabic, now: now),
      // [/module:form_builder]
      // [module:time_tracker]
      'Time Tracker': () => ShowcaseTimeTracker.seed(
          firestore: db, me: me, isArabic: isArabic, now: now),
      // [/module:time_tracker]
      'Calendar (all modules, one day)': () => ShowcaseCalendar.seed(
          firestore: db, me: me, isArabic: isArabic, now: now),
      'To-Do': () => ShowcaseTodo.seed(
          firestore: db, ownerEmail: me.email, isArabic: isArabic, now: now),
      'Settings': () => ShowcaseSettings.seed(
          firestore: db, me: me, isArabic: isArabic, now: now),
      // [module:services]
      'Services': () => ShowcaseServices.seed(
          firestore: db, me: me, isArabic: isArabic, now: now),
      // [/module:services]
    };

    final List<ShowcaseModuleResult> results = <ShowcaseModuleResult>[];
    for (final MapEntry<String, _Step> step in steps.entries) {
      ShowcaseModuleResult result;
      try {
        result = ShowcaseModuleResult(step.key, count: await step.value());
      } catch (e) {
        result = ShowcaseModuleResult(step.key, error: '$e');
      }
      results.add(result);
      onProgress?.call(result);
    }
    return results;
  }

  /// Sets [ShowcaseCommon.people] to the company's employees (the signed-in
  /// user first) and returns the signed-in user.
  static ShowcasePerson _loadPeople(bool isArabic) {
    final MainCoreEmployeeController c = Get.find<MainCoreEmployeeController>();
    ShowcasePerson toPerson(EmployeeEntityPro e) => ShowcasePerson(
          '${e.firstName ?? ''} ${e.lastName ?? ''}'.trim(),
          '${e.firstNameInArabic ?? e.firstName ?? ''} '
                  '${e.lastNameInArabic ?? e.lastName ?? ''}'
              .trim(),
          (e.email ?? '').trim().toLowerCase(),
          '',
          '',
          id: e.id ?? '',
        );
    final EmployeeEntityPro? self = c.employeeEntity;
    if (self == null || (self.email ?? '').isEmpty) {
      throw StateError('No signed-in employee — sign in first.');
    }
    final ShowcasePerson me = toPerson(self);
    final List<ShowcasePerson> others = <ShowcasePerson>[
      for (final EmployeeEntityPro e
          in c.allEmployeesEntities ?? <EmployeeEntityPro>[])
        if ((e.email ?? '').isNotEmpty &&
            (e.email ?? '').trim().toLowerCase() != me.email)
          toPerson(e),
    ];
    if (others.length >= 3) {
      ShowcaseCommon.people = <ShowcasePerson>[me, ...others.take(12)];
    }
    return me;
  }
}

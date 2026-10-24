/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_data_service_qiyas_approvals.dart
/// Description: Extension methods of `CalendarDataService` — split out of `calendar_data_service.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../calendar_data_service.dart';

// Split from calendar_data_service_methods_3.dart to keep every file under 700 lines.

extension CalendarDataServiceQiyasApprovals on CalendarDataService {
  Future<void> _addQiyasSupervisorApprovals(
    String companyId,
    String currentUserEmail,
    MainCoreEmployeeController mainCoreController,
    bool isArabic,
    List<CalendarEventModel> events,
  ) async {
    // ========================================
    // PART 3: GET SUPERVISOR PENDING APPROVALS
    // ========================================
    try {
      final allEvidenceSnapshot = await _firestore
          .collection(FirebaseCollections.demo)
          .doc(companyId)
          .collection(FirebaseCollections.qiyasEvidenceSubmissions)
          .get()
          .timeout(
        Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Evidence query timeout');
        },
      );

      for (var evidenceDoc in allEvidenceSnapshot.docs) {
        try {
          final evidenceData = evidenceDoc.data();
          final criteriaId = evidenceData['Criteria_Number']?.toString() ?? '';
          final documentNumber =
              evidenceData['Evidence_Number']?.toString() ?? '';
          final championEmail = evidenceData['Submitted_By']?.toString() ?? '';
          final evidenceStatus =
              evidenceData['Submission_Status']?.toString().toLowerCase() ?? '';

          // ✅ CRITICAL FIX: Skip if current user IS the champion themselves
          if (championEmail.toLowerCase() == currentUserEmail.toLowerCase()) {
            continue;
          }

          if (evidenceStatus != 'pending' &&
              evidenceStatus != 'submitted' &&
              evidenceStatus != 'approved_by_supervisor') {
            continue;
          }

          final championEmployee = mainCoreController.getLocaleEmployee(
            championEmail,
          );

          if (championEmployee == null) {
            continue;
          }

          final championSupervisorEmail =
              championEmployee.supervisor?.trim().toLowerCase();

          if (championSupervisorEmail == null ||
              championSupervisorEmail.isEmpty) {
            continue;
          }

          final currentUserEmailNormalized =
              currentUserEmail.trim().toLowerCase();

          bool isCurrentUserSupervisor =
              championSupervisorEmail == currentUserEmailNormalized;

          bool isSuperAdmin = mainCoreController.isSuperAdmin();
          bool hasQiyasAdminPermission = false;

          try {
            hasQiyasAdminPermission = mainCoreController.hasSpecificPermission(
                  Modules.qiyas,
                  'admin_access',
                ) ||
                mainCoreController.hasSpecificPermission(
                  Modules.qiyas,
                  'approve_evidence',
                );
          } catch (e) {
            debugPrint('Ignored error: $e');
          }

          bool shouldShowCard = isCurrentUserSupervisor ||
              isSuperAdmin ||
              hasQiyasAdminPermission;

          if (!shouldShowCard) {
            continue;
          }

          final submissionDateField = evidenceData['Submission_Date'];
          DateTime? submissionDate;

          if (submissionDateField is Timestamp) {
            submissionDate = submissionDateField.toDate();
          }

          if (submissionDate == null) {
            continue;
          }

          String? evidenceName;

          try {
            final championDoc = await _firestore
                .collection(FirebaseCollections.demo)
                .doc(companyId)
                .collection(FirebaseCollections.qiyasControlChampions)
                .where('Criteria_Id', isEqualTo: criteriaId)
                .where('Document', isEqualTo: documentNumber)
                .where('Champion', isEqualTo: championEmail)
                .limit(1)
                .get();

            if (championDoc.docs.isNotEmpty) {
              final championData = championDoc.docs.first.data();

              final notesArray = championData['Notes'] as List?;
              if (notesArray != null && notesArray.isNotEmpty) {
                final notesValue = notesArray.first?.toString().trim();
                if (notesValue != null && notesValue.isNotEmpty) {
                  evidenceName = notesValue;
                }
              }

              if (evidenceName == null || evidenceName.isEmpty) {
                final evidenceNameField = championData['Evidence_Name'];
                if (evidenceNameField != null) {
                  if (evidenceNameField is List &&
                      evidenceNameField.isNotEmpty) {
                    evidenceName = evidenceNameField.first?.toString().trim();
                  } else if (evidenceNameField is String) {
                    evidenceName = evidenceNameField.trim();
                  }
                }
              }
            }
          } catch (e) {
            debugPrint('Ignored error: $e');
          }

          if (evidenceName == null || evidenceName.isEmpty) {
            evidenceName = 'Qiyas Document $criteriaId-$documentNumber';
          }

          final championName =
              '${championEmployee.firstName} ${championEmployee.lastName}';

          final period = submissionDate.hour >= 12 ? 'PM' : 'AM';
          final displayHour = submissionDate.hour > 12
              ? submissionDate.hour - 12
              : (submissionDate.hour == 0 ? 12 : submissionDate.hour);
          final displayTime =
              '${displayHour.toString().padLeft(2, '0')}:${submissionDate.minute.toString().padLeft(2, '0')} $period';

          if (evidenceStatus == 'pending' || evidenceStatus == 'submitted') {
            final pendingDescription = isArabic
                ? 'لديك طلب من $championName يحتاج إلى اتخاذ إجراء'
                : 'You have a request from $championName that needs action';

            events.add(
              CalendarEventModel(
                date: submissionDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: displayTime,
                description: pendingDescription,
                status: 'Pending Approval',
              ),
            );
          } else if (evidenceStatus == 'approved_by_supervisor') {
            DateTime? approvalDate;
            final supervisorApprovalDateField =
                evidenceData['Supervisor_Approval_Date'];
            if (supervisorApprovalDateField is Timestamp) {
              approvalDate = supervisorApprovalDateField.toDate();
            } else {
              final actionDateField = evidenceData['Action_Date'];
              if (actionDateField is Timestamp) {
                approvalDate = actionDateField.toDate();
              } else {
                approvalDate = submissionDate;
              }
            }

            final approvalPeriod = approvalDate.hour >= 12 ? 'PM' : 'AM';
            final approvalDisplayHour = approvalDate.hour > 12
                ? approvalDate.hour - 12
                : (approvalDate.hour == 0 ? 12 : approvalDate.hour);
            final approvalDisplayTime =
                '${approvalDisplayHour.toString().padLeft(2, '0')}:${approvalDate.minute.toString().padLeft(2, '0')} $approvalPeriod';

            final approvedDescription = isArabic
                ? 'لقد وافقت على دليل $championName، في انتظار موافقة المدير'
                : 'You have approved $championName\'s evidence, waiting for manager approval';

            events.add(
              CalendarEventModel(
                date: approvalDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: approvalDisplayTime,
                description: approvedDescription,
                status: 'Approved by Supervisor',
              ),
            );
          }
        } catch (e) {
          debugPrint('Ignored error: $e');
        }
      }
    } catch (e) {
      debugPrint('Ignored error: $e');
    }
  }

  Future<void> _addQiyasManagerApprovals(
    String companyId,
    String currentUserEmail,
    MainCoreEmployeeController mainCoreController,
    bool isArabic,
    List<CalendarEventModel> events,
  ) async {
    // PART 4 (manager pending approvals) is switched off: the
    // QiyasPermissionsSections enum was removed, so the changeSubmissionStatus
    // permission can no longer be granted to anyone and the manager view stays
    // deny-by-default. The old body (a `const false` branch that never ran) is
    // in git history before the lint pass of 17/10/2026.
  }
}

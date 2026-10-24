/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_data_service_qiyas_assignments.dart
/// Description: Extension methods of `CalendarDataService` — split out of `calendar_data_service.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../calendar_data_service.dart';

// Split from calendar_data_service_methods_3.dart to keep every file under 700 lines.

extension CalendarDataServiceQiyasAssignments on CalendarDataService {
  Future<void> _addQiyasChampionAssignments(
    String companyId,
    String currentUserEmail,
    bool isArabic,
    List<CalendarEventModel> events,
  ) async {
    // ========================================
    // PART 1: GET CHAMPION ASSIGNMENTS (Initial Assignment + Due/Overdue)
    // ========================================
    try {
      final championsSnapshot = await _firestore
          .collection(FirebaseCollections.demo)
          .doc(companyId)
          .collection(FirebaseCollections.qiyasControlChampions)
          .where('Champion', isEqualTo: currentUserEmail)
          .get()
          .timeout(
        Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Champions query timeout');
        },
      );

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (var championDoc in championsSnapshot.docs) {
        try {
          final data = championDoc.data();
          final criteriaId = data['Criteria_Id']?.toString() ?? '';
          final documentNumber = data['Document']?.toString() ?? '';
          final status = data['status']?.toString().toLowerCase() ?? '';

          // Check if status is active
          if (status != 'active') {
            continue;
          }

          // Get date from 'Deadline' field (array)
          DateTime? submissionDate;
          final deadlineArray = data['Deadline'] as List?;

          if (deadlineArray != null && deadlineArray.isNotEmpty) {
            final deadlineItem = deadlineArray.first;
            if (deadlineItem is Timestamp) {
              submissionDate = deadlineItem.toDate();
            }
          }

          if (submissionDate == null) {
            continue;
          }

          // Remove time component for date comparison
          final submissionDateOnly = DateTime(
            submissionDate.year,
            submissionDate.month,
            submissionDate.day,
          );

          final daysUntilSubmission =
              submissionDateOnly.difference(today).inDays;

          // ✅ Get VISION/EVIDENCE NAME
          String? evidenceName;

          final notesArray = data['Notes'] as List?;
          if (notesArray != null && notesArray.isNotEmpty) {
            final notesValue = notesArray.first?.toString().trim();
            if (notesValue != null && notesValue.isNotEmpty) {
              evidenceName = notesValue;
            }
          }

          if (evidenceName == null || evidenceName.isEmpty) {
            final evidenceNameField = data['Evidence_Name'];
            if (evidenceNameField != null) {
              if (evidenceNameField is List && evidenceNameField.isNotEmpty) {
                evidenceName = evidenceNameField.first?.toString().trim();
              } else if (evidenceNameField is String) {
                evidenceName = evidenceNameField.trim();
              }
            }
          }

          if (evidenceName == null || evidenceName.isEmpty) {
            final descriptionField = data['Description'];
            if (descriptionField != null) {
              if (descriptionField is List && descriptionField.isNotEmpty) {
                evidenceName = descriptionField.first?.toString().trim();
              } else if (descriptionField is String) {
                evidenceName = descriptionField.trim();
              }
            }
          }

          if (evidenceName == null || evidenceName.isEmpty) {
            final titleField = data['Title'];
            if (titleField != null) {
              if (titleField is List && titleField.isNotEmpty) {
                evidenceName = titleField.first?.toString().trim();
              } else if (titleField is String) {
                evidenceName = titleField.trim();
              }
            }
          }

          if (evidenceName == null || evidenceName.isEmpty) {
            final nameField = data['Name'];
            if (nameField != null) {
              if (nameField is List && nameField.isNotEmpty) {
                evidenceName = nameField.first?.toString().trim();
              } else if (nameField is String) {
                evidenceName = nameField.trim();
              }
            }
          }

          if (evidenceName == null || evidenceName.isEmpty) {
            evidenceName = 'Qiyas Document $criteriaId-$documentNumber';
          }

          // Check if champion has submitted evidence
          bool hasSubmitted = false;
          bool isApprovedBySupervisor = false;
          bool isApprovedByManager = false;
          bool isRejectedBySupervisor = false;
          bool isRejectedByManager = false;
          DateTime? evidenceSubmissionDate;
          DateTime? supervisorApprovalDate;
          DateTime? managerApprovalDate;
          DateTime? supervisorRejectionDate;
          DateTime? managerRejectionDate;

          try {
            final evidenceSnapshot = await _firestore
                .collection(FirebaseCollections.demo)
                .doc(companyId)
                .collection(FirebaseCollections.qiyasEvidenceSubmissions)
                .where('Criteria_Number', isEqualTo: criteriaId)
                .where('Evidence_Number', isEqualTo: documentNumber)
                .where('Submitted_By', isEqualTo: currentUserEmail)
                .orderBy('Submission_Date', descending: true)
                .limit(1)
                .get();

            if (evidenceSnapshot.docs.isNotEmpty) {
              hasSubmitted = true;
              final evidenceData = evidenceSnapshot.docs.first.data();
              final evidenceStatus =
                  evidenceData['Submission_Status']?.toString().toLowerCase() ??
                      '';

              isApprovedBySupervisor =
                  evidenceStatus == 'approved_by_supervisor';
              isApprovedByManager = evidenceStatus == 'approved';
              isRejectedBySupervisor =
                  evidenceStatus == 'rejected_by_supervisor';
              isRejectedByManager = evidenceStatus == 'rejected_by_manager' ||
                  evidenceStatus == 'rejected';

              // Get evidence submission date
              final submissionDateField = evidenceData['Submission_Date'];
              if (submissionDateField is Timestamp) {
                evidenceSubmissionDate = submissionDateField.toDate();
              }

              // Get supervisor approval date
              final supervisorApprovalDateField =
                  evidenceData['Supervisor_Approval_Date'];
              if (supervisorApprovalDateField is Timestamp) {
                supervisorApprovalDate = supervisorApprovalDateField.toDate();
              } else if (isApprovedBySupervisor) {
                final actionDateField = evidenceData['Action_Date'];
                if (actionDateField is Timestamp) {
                  supervisorApprovalDate = actionDateField.toDate();
                } else {
                  supervisorApprovalDate = evidenceSubmissionDate;
                }
              }

              // Get manager approval date
              final managerApprovalDateField =
                  evidenceData['Manager_Approval_Date'];
              if (managerApprovalDateField is Timestamp) {
                managerApprovalDate = managerApprovalDateField.toDate();
              } else if (isApprovedByManager) {
                final actionDateField = evidenceData['Action_Date'];
                if (actionDateField is Timestamp) {
                  managerApprovalDate = actionDateField.toDate();
                } else {
                  managerApprovalDate =
                      supervisorApprovalDate ?? evidenceSubmissionDate;
                }
              }

              // Get supervisor rejection date
              if (isRejectedBySupervisor) {
                final supervisorRejectionDateField =
                    evidenceData['Supervisor_Rejection_Date'];
                if (supervisorRejectionDateField is Timestamp) {
                  supervisorRejectionDate =
                      supervisorRejectionDateField.toDate();
                } else {
                  final actionDateField = evidenceData['Action_Date'];
                  if (actionDateField is Timestamp) {
                    supervisorRejectionDate = actionDateField.toDate();
                  } else {
                    supervisorRejectionDate =
                        evidenceSubmissionDate ?? DateTime.now();
                  }
                }
              }

              // Get manager rejection date
              if (isRejectedByManager) {
                final managerRejectionDateField =
                    evidenceData['Manager_Rejection_Date'];
                if (managerRejectionDateField is Timestamp) {
                  managerRejectionDate = managerRejectionDateField.toDate();
                } else {
                  final actionDateField = evidenceData['Action_Date'];
                  if (actionDateField is Timestamp) {
                    managerRejectionDate = actionDateField.toDate();
                  } else {
                    managerRejectionDate = supervisorApprovalDate ??
                        evidenceSubmissionDate ??
                        DateTime.now();
                  }
                }
              }
            }
          } catch (e) {
            debugPrint('Ignored error: $e');
          }

          // ✅ CARD 1: INITIAL ASSIGNMENT - Always show (PERMANENT)
          final dueDateStr = DateFormat('MMM dd, yyyy').format(submissionDate);

          final assignmentDescription = isArabic
              ? 'تم تعيين دليل لك والموعد النهائي هو $dueDateStr'
              : 'You have been assigned an evidence and due date is $dueDateStr';

          events.add(
            CalendarEventModel(
              date: submissionDate,
              color: AppColors.calendarEventQiyas,
              moduleName: 'Qiyas',
              taskName: evidenceName,
              time: DateFormat('hh:mm a').format(submissionDate),
              description: assignmentDescription,
              status: 'Due',
            ),
          );

          // ✅ CARD 2: OVERDUE
          if (!hasSubmitted &&
              daysUntilSubmission < 0 &&
              !isApprovedByManager) {
            final overdueDescription = isArabic
                ? 'يجب عليك تحميل الدليل الخاص بك على الفور'
                : 'You must upload your evidence immediately';

            events.add(
              CalendarEventModel(
                date: submissionDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(submissionDate),
                description: overdueDescription,
                status: 'Overdue',
              ),
            );
          }

          // ✅ CARD 3: SUBMITTED
          if (hasSubmitted && evidenceSubmissionDate != null) {
            final submittedDescription = isArabic
                ? 'تم تقديم الدليل الخاص بك وفي انتظار موافقة المشرف'
                : 'Your evidence has been submitted and is awaiting supervisor approval';

            events.add(
              CalendarEventModel(
                date: evidenceSubmissionDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(evidenceSubmissionDate),
                description: submittedDescription,
                status: 'Submitted',
              ),
            );
          }

          // ✅ CARD 4: APPROVED BY SUPERVISOR
          if (isApprovedBySupervisor && supervisorApprovalDate != null) {
            final approvedBySupervisorDescription = isArabic
                ? 'تمت الموافقة على الدليل الخاص بك من قبل المشرف، في انتظار موافقة المدير'
                : 'Your evidence has been approved by supervisor, waiting for manager approval';

            events.add(
              CalendarEventModel(
                date: supervisorApprovalDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(supervisorApprovalDate),
                description: approvedBySupervisorDescription,
                status: 'Approved by Supervisor',
              ),
            );
          }

          // ✅ CARD 5: APPROVED BY MANAGER (FINAL)
          if (isApprovedByManager && managerApprovalDate != null) {
            final approvedByManagerDescription = isArabic
                ? 'تمت الموافقة على الدليل الخاص بك بشكل نهائي من قبل المدير'
                : 'Your evidence has been fully approved by manager';

            events.add(
              CalendarEventModel(
                date: managerApprovalDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(managerApprovalDate),
                description: approvedByManagerDescription,
                status: 'Approved',
              ),
            );
          }

          // ✅ CARD 6: REJECTED BY SUPERVISOR
          if (isRejectedBySupervisor && supervisorRejectionDate != null) {
            final rejectedDescription = isArabic
                ? 'تم رفض الدليل الخاص بك من قبل المشرف. يرجى إعادة التقديم'
                : 'Your evidence has been rejected by supervisor. Please resubmit';

            events.add(
              CalendarEventModel(
                date: supervisorRejectionDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(supervisorRejectionDate),
                description: rejectedDescription,
                status: 'Rejected',
              ),
            );
          }

          // ✅ CARD 7: REJECTED BY MANAGER
          if (isRejectedByManager && managerRejectionDate != null) {
            final rejectedDescription = isArabic
                ? 'تم رفض الدليل الخاص بك من قبل المدير. يرجى إعادة التقديم'
                : 'Your evidence has been rejected by manager. Please resubmit';

            events.add(
              CalendarEventModel(
                date: managerRejectionDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(managerRejectionDate),
                description: rejectedDescription,
                status: 'Rejected',
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

  Future<void> _addQiyasSupervisorView(
    String companyId,
    String currentUserEmail,
    MainCoreEmployeeController mainCoreController,
    bool isArabic,
    List<CalendarEventModel> events,
  ) async {
    // ========================================
    // PART 2: GET SUPERVISOR VIEW
    // ========================================
    try {
      final allChampionsSnapshot = await _firestore
          .collection(FirebaseCollections.demo)
          .doc(companyId)
          .collection(FirebaseCollections.qiyasControlChampions)
          .where('status', isEqualTo: 'active')
          .get()
          .timeout(
        Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('All champions query timeout');
        },
      );

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (var championDoc in allChampionsSnapshot.docs) {
        try {
          final data = championDoc.data();
          final criteriaId = data['Criteria_Id']?.toString() ?? '';
          final documentNumber = data['Document']?.toString() ?? '';
          final championEmail = data['Champion']?.toString() ?? '';

          // ✅ CRITICAL FIX: Skip if current user IS the champion themselves
          if (championEmail.toLowerCase() == currentUserEmail.toLowerCase()) {
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

          if (championSupervisorEmail != currentUserEmail.toLowerCase()) {
            continue;
          }

          DateTime? submissionDate;
          final deadlineArray = data['Deadline'] as List?;

          if (deadlineArray != null && deadlineArray.isNotEmpty) {
            final deadlineItem = deadlineArray.first;
            if (deadlineItem is Timestamp) {
              submissionDate = deadlineItem.toDate();
            }
          }

          if (submissionDate == null) {
            continue;
          }

          final submissionDateOnly = DateTime(
            submissionDate.year,
            submissionDate.month,
            submissionDate.day,
          );

          final daysUntilSubmission =
              submissionDateOnly.difference(today).inDays;

          String? evidenceName;
          final notesArray = data['Notes'] as List?;
          if (notesArray != null && notesArray.isNotEmpty) {
            final notesValue = notesArray.first?.toString().trim();
            if (notesValue != null && notesValue.isNotEmpty) {
              evidenceName = notesValue;
            }
          }

          if (evidenceName == null || evidenceName.isEmpty) {
            final evidenceNameField = data['Evidence_Name'];
            if (evidenceNameField != null) {
              if (evidenceNameField is List && evidenceNameField.isNotEmpty) {
                evidenceName = evidenceNameField.first?.toString().trim();
              } else if (evidenceNameField is String) {
                evidenceName = evidenceNameField.trim();
              }
            }
          }

          if (evidenceName == null || evidenceName.isEmpty) {
            evidenceName = 'Qiyas Document $criteriaId-$documentNumber';
          }

          bool hasSubmitted = false;
          bool isApprovedBySupervisor = false;
          bool isApprovedByManager = false;
          bool isRejectedBySupervisor = false;
          bool isRejectedByManager = false;
          DateTime? supervisorApprovalDate;
          DateTime? managerApprovalDate;
          DateTime? supervisorRejectionDate;
          DateTime? managerRejectionDate;

          try {
            final evidenceSnapshot = await _firestore
                .collection(FirebaseCollections.demo)
                .doc(companyId)
                .collection(FirebaseCollections.qiyasEvidenceSubmissions)
                .where('Criteria_Number', isEqualTo: criteriaId)
                .where('Evidence_Number', isEqualTo: documentNumber)
                .where('Submitted_By', isEqualTo: championEmail)
                .orderBy('Submission_Date', descending: true)
                .limit(1)
                .get();

            if (evidenceSnapshot.docs.isNotEmpty) {
              hasSubmitted = true;
              final evidenceData = evidenceSnapshot.docs.first.data();
              final evidenceStatus =
                  evidenceData['Submission_Status']?.toString().toLowerCase() ??
                      '';

              isApprovedBySupervisor =
                  evidenceStatus == 'approved_by_supervisor';
              isApprovedByManager = evidenceStatus == 'approved';
              isRejectedBySupervisor =
                  evidenceStatus == 'rejected_by_supervisor';
              isRejectedByManager = evidenceStatus == 'rejected_by_manager' ||
                  evidenceStatus == 'rejected';

              final supervisorApprovalDateField =
                  evidenceData['Supervisor_Approval_Date'];
              if (supervisorApprovalDateField is Timestamp) {
                supervisorApprovalDate = supervisorApprovalDateField.toDate();
              } else if (isApprovedBySupervisor) {
                final actionDateField = evidenceData['Action_Date'];
                if (actionDateField is Timestamp) {
                  supervisorApprovalDate = actionDateField.toDate();
                } else {
                  supervisorApprovalDate = DateTime.now();
                }
              }

              final managerApprovalDateField =
                  evidenceData['Manager_Approval_Date'];
              if (managerApprovalDateField is Timestamp) {
                managerApprovalDate = managerApprovalDateField.toDate();
              } else if (isApprovedByManager) {
                final actionDateField = evidenceData['Action_Date'];
                if (actionDateField is Timestamp) {
                  managerApprovalDate = actionDateField.toDate();
                } else {
                  managerApprovalDate = DateTime.now();
                }
              }

              if (isRejectedBySupervisor) {
                final supervisorRejectionDateField =
                    evidenceData['Supervisor_Rejection_Date'];
                if (supervisorRejectionDateField is Timestamp) {
                  supervisorRejectionDate =
                      supervisorRejectionDateField.toDate();
                } else {
                  final actionDateField = evidenceData['Action_Date'];
                  if (actionDateField is Timestamp) {
                    supervisorRejectionDate = actionDateField.toDate();
                  } else {
                    supervisorRejectionDate = DateTime.now();
                  }
                }
              }

              if (isRejectedByManager) {
                final managerRejectionDateField =
                    evidenceData['Manager_Rejection_Date'];
                if (managerRejectionDateField is Timestamp) {
                  managerRejectionDate = managerRejectionDateField.toDate();
                } else {
                  final actionDateField = evidenceData['Action_Date'];
                  if (actionDateField is Timestamp) {
                    managerRejectionDate = actionDateField.toDate();
                  } else {
                    managerRejectionDate = DateTime.now();
                  }
                }
              }
            }
          } catch (e) {
            debugPrint('Ignored error: $e');
          }

          final championName =
              '${championEmployee.firstName} ${championEmployee.lastName}';

          // SUPERVISOR CARD 1: DURATION
          final durationDescription = isArabic
              ? 'موظفك $championName تم تعيين له $evidenceName'
              : 'Your employee $championName has been assigned $evidenceName';

          events.add(
            CalendarEventModel(
              date: submissionDate,
              color: AppColors.calendarEventQiyas,
              moduleName: 'Qiyas',
              taskName: evidenceName,
              time: DateFormat('hh:mm a').format(submissionDate),
              description: durationDescription,
              status: 'Duration',
            ),
          );

          // SUPERVISOR CARD 2: OVERDUE
          if (!hasSubmitted &&
              daysUntilSubmission < 0 &&
              !isApprovedByManager) {
            final overdueDescription = isArabic
                ? 'موظفك $championName لم يقم بتحميل الدليل المطلوب منه'
                : 'Your employee $championName did not upload the evidence which was requested from him';

            events.add(
              CalendarEventModel(
                date: submissionDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(submissionDate),
                description: overdueDescription,
                status: 'Overdue',
              ),
            );
          }

          // SUPERVISOR CARD 3: APPROVED BY SUPERVISOR
          if (isApprovedBySupervisor && supervisorApprovalDate != null) {
            final approvedDescription = isArabic
                ? 'لقد وافقت على دليل $championName، في انتظار موافقة المدير'
                : 'You have approved $championName\'s evidence, waiting for manager approval';

            events.add(
              CalendarEventModel(
                date: supervisorApprovalDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(supervisorApprovalDate),
                description: approvedDescription,
                status: 'Approved by Supervisor',
              ),
            );
          }

          // SUPERVISOR CARD 4: APPROVED BY MANAGER
          if (isApprovedByManager && managerApprovalDate != null) {
            final approvedDescription = isArabic
                ? 'تمت الموافقة على دليل $championName بشكل نهائي من قبل المدير'
                : 'Manager has approved $championName\'s evidence';

            events.add(
              CalendarEventModel(
                date: managerApprovalDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(managerApprovalDate),
                description: approvedDescription,
                status: 'Approved',
              ),
            );
          }

          // SUPERVISOR CARD 5: REJECTED BY SUPERVISOR
          if (isRejectedBySupervisor && supervisorRejectionDate != null) {
            final rejectedDescription = isArabic
                ? 'لقد رفضت دليل $championName'
                : 'You have rejected $championName\'s evidence';

            events.add(
              CalendarEventModel(
                date: supervisorRejectionDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(supervisorRejectionDate),
                description: rejectedDescription,
                status: 'Rejected',
              ),
            );
          }

          // SUPERVISOR CARD 6: REJECTED BY MANAGER
          if (isRejectedByManager && managerRejectionDate != null) {
            final rejectedDescription = isArabic
                ? 'المدير رفض دليل $championName'
                : 'Manager has rejected $championName\'s evidence';

            events.add(
              CalendarEventModel(
                date: managerRejectionDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(managerRejectionDate),
                description: rejectedDescription,
                status: 'Rejected',
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
}

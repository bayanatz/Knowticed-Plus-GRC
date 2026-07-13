import 'package:demo_app/features/calender/data/data_source/services_history_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:demo_app/core/network/api_constants.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/qiyas/qiyas_permissions_sections.dart';
import 'package:demo_app/features/department/presentation/controller/add_department_controller.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/calender/data/data_source/calendar_event_model.dart';
import 'package:demo_app/core/network/get_base_url.dart';

class CalendarDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<List<CalendarEventModel>> getApprovalCalendarEvents({
    required String currentUserEmail,
  }) async
  {
    List<CalendarEventModel> events = [];

    try {
      debugPrint('\n🔍 ===== FETCHING APPROVAL CALENDAR EVENTS (SERVICES) =====');
      debugPrint('📧 Current User: $currentUserEmail');

      String companyIdPath = getBaseUrl('');
      String companyId = '';
      if (companyIdPath.contains('/')) {
        final parts = companyIdPath.split('/');
        if (parts.length >= 2) {
          companyId = parts[1];
        }
      }

      debugPrint('🏢 Using company ID: $companyId');

      // ✅ Get current locale to determine language
      final currentLocale = Get.locale?.languageCode ?? 'en';
      final isArabic = currentLocale == 'ar';

      debugPrint('🌍 Current locale: $currentLocale');
      debugPrint('🌍 Is Arabic mode: $isArabic');

      try {
        final exactPath = _firestore
            .collection('Demo')
            .doc(companyId)
            .collection('RequestServices');

        final requestsSnapshot = await exactPath.get().timeout(
          Duration(seconds: 15),
          onTimeout: () {
            debugPrint('⏰ TIMEOUT: Query took more than 15 seconds');
            throw TimeoutException('Approval query timeout after 15 seconds');
          },
        );

        debugPrint('📄 Found ${requestsSnapshot.docs.length} service requests');

        if (requestsSnapshot.docs.isEmpty) {
          debugPrint('⚠️ No requests found');
          return events;
        }

        int requestIndex = 0;

        for (var requestDoc in requestsSnapshot.docs) {
          requestIndex++;
          try {
            final data = requestDoc.data();
            final requestId = requestDoc.id;

            debugPrint('\n📄 [$requestIndex/${requestsSnapshot.docs.length}] Request: $requestId');

            // ✅ Get service name
            String? serviceNameEnglish = _getArrayValue(data['serviceNameEnglish']);
            String? serviceNameArabic = _getArrayValue(data['serviceNameArabic']);

            // Fallback to alternative fields
            if (serviceNameEnglish == null || serviceNameEnglish.isEmpty || serviceNameEnglish.toLowerCase() == 'approval') {
              serviceNameEnglish = _getArrayValue(data['currentServiceNameEnglish']) ?? 'Service Request';
            }

            if (serviceNameArabic == null || serviceNameArabic.isEmpty || serviceNameArabic == 'موافقة') {
              serviceNameArabic = _getArrayValue(data['currentServiceNameArabic']) ?? 'طلب خدمة';
            }

            final taskName = isArabic ? serviceNameArabic : serviceNameEnglish;

            debugPrint('   Selected Task Name: $taskName (${isArabic ? "AR" : "EN"})');

            // Parse approval cycle
            final approvalCycleRaw = data['approvalCycle'];
            List<Map<String, dynamic>> approvalCycle = [];

            if (approvalCycleRaw is List && approvalCycleRaw.isNotEmpty) {
              for (final item in approvalCycleRaw) {
                if (item is String) {
                  try {
                    final decoded = jsonDecode(item);
                    if (decoded is List) {
                      for (final emp in decoded) {
                        if (emp is Map) {
                          approvalCycle.add({
                            'email': (emp['email'] ?? '').toString().toLowerCase(),
                            'state': (emp['state'] ?? '').toString().toLowerCase(),
                          });
                        }
                      }
                    }
                  } catch (e) {
                    debugPrint('   ❌ Error parsing approval cycle: $e');
                  }
                }
              }
            }

            if (approvalCycle.isEmpty) {
              debugPrint('   ⏭️ SKIP: No approval cycle');
              continue;
            }

            // Check if user is in approval cycle
            final myIndex = approvalCycle.indexWhere(
                  (e) => e['email'] == currentUserEmail.toLowerCase(),
            );

            if (myIndex == -1) {
              debugPrint('   ⏭️ SKIP: Not in approval cycle');
              continue;
            }

            final myState = approvalCycle[myIndex]['state'];
            debugPrint('   My state: $myState');

            // Get timestamps
            final timestampsArray = data['timestamps'] as List?;
            if (timestampsArray == null || timestampsArray.isEmpty) {
              debugPrint('   ⏭️ SKIP: No timestamps');
              continue;
            }

            // ✅ CASE 1: Pending Approval (show if currently pending)
            if (['pending', 'normal', ''].contains(myState)) {
              final isMyTurn = _isMyTurnToApprove(
                approvalCycle: approvalCycle,
                currentUserEmail: currentUserEmail,
                myIndex: myIndex,
              );

              if (isMyTurn) {
                final timestamp = timestampsArray.first;
                final date = DateTime.fromMillisecondsSinceEpoch(
                  timestamp is int ? timestamp : int.parse(timestamp.toString()),
                );

                final displayTime = DateFormat('hh:mm a').format(date);

                final description = isArabic
                    ? 'تم تقديم طلب ويتطلب قرارك للمتابعة'
                    : 'A request has been submitted and requires your decision to proceed';

                final status = isArabic ? 'بانتظار الموافقة' : 'Pending Approval';

                events.add(CalendarEventModel(
                  date: date,
                  color: const Color(0xFF0095FF),
                  moduleName: 'Services',
                  taskName: taskName,
                  time: displayTime,
                  description: description,
                  status: status,
                ));

                debugPrint('   ✅ Added Pending Approval event');
              }
            }

            // ✅ CASE 2: Approved (always show, even after approval)
            if (myState == 'approved') {
              DateTime approvalDate;

              if (timestampsArray.length > myIndex) {
                final approvalTimestamp = timestampsArray[myIndex];
                approvalDate = DateTime.fromMillisecondsSinceEpoch(
                  approvalTimestamp is int ? approvalTimestamp : int.parse(approvalTimestamp.toString()),
                );
              } else {
                final timestamp = timestampsArray.first;
                approvalDate = DateTime.fromMillisecondsSinceEpoch(
                  timestamp is int ? timestamp : int.parse(timestamp.toString()),
                );
              }

              final displayTime = DateFormat('hh:mm a').format(approvalDate);

              final description = isArabic
                  ? 'لقد وافقت على هذا الطلب'
                  : 'You have approved this request';

              final status = isArabic ? 'تمت الموافقة' : 'Approved';

              events.add(CalendarEventModel(
                date: approvalDate,
                color: const Color(0xFF0095FF),
                moduleName: 'Services',
                taskName: taskName,
                time: displayTime,
                description: description,
                status: status,
              ));

              debugPrint('   ✅ Added Approved event');
            }

            // ✅ CASE 3: Rejected (always show)
            if (myState == 'rejected') {
              DateTime rejectionDate;

              if (timestampsArray.length > myIndex) {
                final rejectionTimestamp = timestampsArray[myIndex];
                rejectionDate = DateTime.fromMillisecondsSinceEpoch(
                  rejectionTimestamp is int ? rejectionTimestamp : int.parse(rejectionTimestamp.toString()),
                );
              } else {
                final timestamp = timestampsArray.first;
                rejectionDate = DateTime.fromMillisecondsSinceEpoch(
                  timestamp is int ? timestamp : int.parse(timestamp.toString()),
                );
              }

              final displayTime = DateFormat('hh:mm a').format(rejectionDate);

              final description = isArabic
                  ? 'لقد رفضت هذا الطلب'
                  : 'You have rejected this request';

              final status = isArabic ? 'مرفوض' : 'Rejected';

              events.add(CalendarEventModel(
                date: rejectionDate,
                color: const Color(0xFF0095FF),
                moduleName: 'Services',
                taskName: taskName,
                time: displayTime,
                description: description,
                status: status,
              ));

              debugPrint('   ✅ Added Rejected event');
            }

          } catch (e) {
            debugPrint('   ❌ Error processing request: $e');
          }
        }

      } catch (timeoutError) {
        debugPrint('❌ TIMEOUT ERROR: $timeoutError');
        return events;
      }

      debugPrint('\n✅ COMPLETE! Total SERVICES approval events: ${events.length}');

    } catch (e, stackTrace) {
      debugPrint('❌ FATAL ERROR: $e');
      debugPrint('Stack: $stackTrace');
    }

    return events;
  }
















  /// All Qiyas events use GREY color (0xFF9FADAF)
  Future<List<CalendarEventModel>> getQiyasCalendarEvents({
    required String currentUserEmail,
  }) async
  {
    List<CalendarEventModel> events = [];

    try {
      debugPrint('\n🔍 ===== FETCHING QIYAS CALENDAR EVENTS =====');
      debugPrint('📧 Current User: $currentUserEmail');

      String companyIdPath = getBaseUrl('');
      String companyId = '';
      if (companyIdPath.contains('/')) {
        final parts = companyIdPath.split('/');
        if (parts.length >= 2) {
          companyId = parts[1];
        }
      }

      debugPrint('🏢 Using company ID: $companyId');

      // ✅ Get current locale to determine language
      final currentLocale = Get.locale?.languageCode ?? 'en';
      final isArabic = currentLocale == 'ar';

      debugPrint('🌍 Current locale: $currentLocale');
      debugPrint('🌍 Is Arabic mode: $isArabic');

      // Get main core controller for employee details
      final mainCoreController = Get.find<MainCoreEmployeeController>();

      // ========================================
      // PART 1: GET CHAMPION ASSIGNMENTS (Initial Assignment + Due/Overdue)
      // ========================================
      try {
        debugPrint('\n🔍 GETTING CHAMPION ASSIGNMENTS...');

        final championsSnapshot = await _firestore
            .collection('Demo')
            .doc(companyId)
            .collection('Qiyas Control Champions')
            .where('Champion', isEqualTo: currentUserEmail)
            .get()
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            debugPrint('⏰ TIMEOUT: Champions query took more than 15 seconds');
            throw TimeoutException('Champions query timeout');
          },
        );

        debugPrint('📄 Found ${championsSnapshot.docs.length} champion assignments for user');

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        for (var championDoc in championsSnapshot.docs) {
          try {
            final data = championDoc.data();
            final criteriaId = data['Criteria_Id']?.toString() ?? '';
            final documentNumber = data['Document']?.toString() ?? '';
            final championId = championDoc.id;
            final status = data['status']?.toString()?.toLowerCase() ?? '';

            debugPrint('\n📄 Processing Champion Assignment:');
            debugPrint('   Document ID: $championId');
            debugPrint('   Criteria ID: $criteriaId');
            debugPrint('   Document: $documentNumber');
            debugPrint('   Status: $status');

            // Check if status is active
            if (status != 'active') {
              debugPrint('   ⏭️ SKIP: Status is not active ($status)');
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
              debugPrint('   ⏭️ SKIP: No valid deadline found');
              continue;
            }

            // Remove time component for date comparison
            final submissionDateOnly = DateTime(
                submissionDate.year,
                submissionDate.month,
                submissionDate.day
            );

            final daysUntilSubmission = submissionDateOnly.difference(today).inDays;

            debugPrint('   Submission Date: $submissionDateOnly');
            debugPrint('   Today: $today');
            debugPrint('   Days until submission: $daysUntilSubmission');

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

            debugPrint('   📝 Final Evidence Name: $evidenceName');

            // Check if champion has submitted evidence
            bool hasSubmitted = false;
            bool isApprovedBySupervisor = false;
            bool isApprovedByManager = false;
            bool isRejectedBySupervisor = false;
            bool isRejectedByManager = false;
            bool isSubmitted = false;
            DateTime? evidenceSubmissionDate;
            DateTime? supervisorApprovalDate;
            DateTime? managerApprovalDate;
            DateTime? supervisorRejectionDate;
            DateTime? managerRejectionDate;

            try {
              final evidenceSnapshot = await _firestore
                  .collection('Demo')
                  .doc(companyId)
                  .collection('Qiyas Evidence Submissions')
                  .where('Criteria_Number', isEqualTo: criteriaId)
                  .where('Evidence_Number', isEqualTo: documentNumber)
                  .where('Submitted_By', isEqualTo: currentUserEmail)
                  .orderBy('Submission_Date', descending: true)
                  .limit(1)
                  .get();

              if (evidenceSnapshot.docs.isNotEmpty) {
                hasSubmitted = true;
                final evidenceData = evidenceSnapshot.docs.first.data();
                final evidenceStatus = evidenceData['Submission_Status']?.toString().toLowerCase() ?? '';

                isSubmitted = evidenceStatus == 'submitted' || evidenceStatus == 'pending';
                isApprovedBySupervisor = evidenceStatus == 'approved_by_supervisor';
                isApprovedByManager = evidenceStatus == 'approved';
                isRejectedBySupervisor = evidenceStatus == 'rejected_by_supervisor';
                isRejectedByManager = evidenceStatus == 'rejected_by_manager' || evidenceStatus == 'rejected';

                // Get evidence submission date
                final submissionDateField = evidenceData['Submission_Date'];
                if (submissionDateField is Timestamp) {
                  evidenceSubmissionDate = submissionDateField.toDate();
                }

                // Get supervisor approval date
                final supervisorApprovalDateField = evidenceData['Supervisor_Approval_Date'];
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
                final managerApprovalDateField = evidenceData['Manager_Approval_Date'];
                if (managerApprovalDateField is Timestamp) {
                  managerApprovalDate = managerApprovalDateField.toDate();
                } else if (isApprovedByManager) {
                  final actionDateField = evidenceData['Action_Date'];
                  if (actionDateField is Timestamp) {
                    managerApprovalDate = actionDateField.toDate();
                  } else {
                    managerApprovalDate = supervisorApprovalDate ?? evidenceSubmissionDate;
                  }
                }

                // Get supervisor rejection date
                if (isRejectedBySupervisor) {
                  final supervisorRejectionDateField = evidenceData['Supervisor_Rejection_Date'];
                  if (supervisorRejectionDateField is Timestamp) {
                    supervisorRejectionDate = supervisorRejectionDateField.toDate();
                  } else {
                    final actionDateField = evidenceData['Action_Date'];
                    if (actionDateField is Timestamp) {
                      supervisorRejectionDate = actionDateField.toDate();
                    } else {
                      supervisorRejectionDate = evidenceSubmissionDate ?? DateTime.now();
                    }
                  }
                }

                // Get manager rejection date
                if (isRejectedByManager) {
                  final managerRejectionDateField = evidenceData['Manager_Rejection_Date'];
                  if (managerRejectionDateField is Timestamp) {
                    managerRejectionDate = managerRejectionDateField.toDate();
                  } else {
                    final actionDateField = evidenceData['Action_Date'];
                    if (actionDateField is Timestamp) {
                      managerRejectionDate = actionDateField.toDate();
                    } else {
                      managerRejectionDate = supervisorApprovalDate ?? evidenceSubmissionDate ?? DateTime.now();
                    }
                  }
                }

                debugPrint('   Evidence status: $evidenceStatus');
                debugPrint('   Submission date: $evidenceSubmissionDate');
                debugPrint('   Supervisor approval date: $supervisorApprovalDate');
                debugPrint('   Manager approval date: $managerApprovalDate');
                debugPrint('   Supervisor rejection date: $supervisorRejectionDate');
                debugPrint('   Manager rejection date: $managerRejectionDate');
              }
            } catch (e) {
              debugPrint('   ⚠️ Error checking evidence: $e');
            }

            debugPrint('   Has submitted: $hasSubmitted');
            debugPrint('   Is submitted (pending): $isSubmitted');
            debugPrint('   Is approved by supervisor: $isApprovedBySupervisor');
            debugPrint('   Is approved by manager: $isApprovedByManager');
            debugPrint('   Is rejected by supervisor: $isRejectedBySupervisor');
            debugPrint('   Is rejected by manager: $isRejectedByManager');

            // ✅ CARD 1: INITIAL ASSIGNMENT - Always show (PERMANENT)
            final dueDateStr = DateFormat('MMM dd, yyyy').format(submissionDate);

            final assignmentDescription = isArabic
                ? 'تم تعيين دليل لك والموعد النهائي هو $dueDateStr'
                : 'You have been assigned an evidence and due date is $dueDateStr';

            events.add(CalendarEventModel(
              date: submissionDate,
              color: const Color(0xFF9FADAF),
              moduleName: 'Qiyas',
              taskName: evidenceName,
              time: DateFormat('hh:mm a').format(submissionDate),
              description: assignmentDescription,
              status: 'Due',
            ));

            debugPrint('   ✅ Added PERMANENT Initial Assignment card');

            // ✅ CARD 2: OVERDUE
            if (!hasSubmitted && daysUntilSubmission < 0 && !isApprovedByManager) {
              final overdueDescription = isArabic
                  ? 'يجب عليك تحميل الدليل الخاص بك على الفور'
                  : 'You must upload your evidence immediately';

              events.add(CalendarEventModel(
                date: submissionDate,
                color: const Color(0xFF9FADAF),
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(submissionDate),
                description: overdueDescription,
                status: 'Overdue',
              ));

              debugPrint('   ✅ Added PERMANENT Overdue card');
            }

            // ✅ CARD 3: SUBMITTED
            if (hasSubmitted && evidenceSubmissionDate != null) {
              final submittedDescription = isArabic
                  ? 'تم تقديم الدليل الخاص بك وفي انتظار موافقة المشرف'
                  : 'Your evidence has been submitted and is awaiting supervisor approval';

              events.add(CalendarEventModel(
                date: evidenceSubmissionDate,
                color: const Color(0xFF9FADAF),
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(evidenceSubmissionDate),
                description: submittedDescription,
                status: 'Submitted',
              ));

              debugPrint('   ✅ Added PERMANENT Submitted card');
            }

            // ✅ CARD 4: APPROVED BY SUPERVISOR
            if (isApprovedBySupervisor && supervisorApprovalDate != null) {
              final approvedBySupervisorDescription = isArabic
                  ? 'تمت الموافقة على الدليل الخاص بك من قبل المشرف، في انتظار موافقة المدير'
                  : 'Your evidence has been approved by supervisor, waiting for manager approval';

              events.add(CalendarEventModel(
                date: supervisorApprovalDate,
                color: const Color(0xFF9FADAF),
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(supervisorApprovalDate),
                description: approvedBySupervisorDescription,
                status: 'Approved by Supervisor',
              ));

              debugPrint('   ✅ Added PERMANENT Approved by Supervisor card');
            }

            // ✅ CARD 5: APPROVED BY MANAGER (FINAL)
            if (isApprovedByManager && managerApprovalDate != null) {
              final approvedByManagerDescription = isArabic
                  ? 'تمت الموافقة على الدليل الخاص بك بشكل نهائي من قبل المدير'
                  : 'Your evidence has been fully approved by manager';

              events.add(CalendarEventModel(
                date: managerApprovalDate,
                color: const Color(0xFF9FADAF),
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(managerApprovalDate),
                description: approvedByManagerDescription,
                status: 'Approved',
              ));

              debugPrint('   ✅ Added PERMANENT Approved by Manager card');
            }

            // ✅ CARD 6: REJECTED BY SUPERVISOR
            if (isRejectedBySupervisor && supervisorRejectionDate != null) {
              final rejectedDescription = isArabic
                  ? 'تم رفض الدليل الخاص بك من قبل المشرف. يرجى إعادة التقديم'
                  : 'Your evidence has been rejected by supervisor. Please resubmit';

              events.add(CalendarEventModel(
                date: supervisorRejectionDate,
                color: const Color(0xFF9FADAF),
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(supervisorRejectionDate),
                description: rejectedDescription,
                status: 'Rejected',
              ));

              debugPrint('   ✅ Added PERMANENT Rejected by Supervisor card');
            }

            // ✅ CARD 7: REJECTED BY MANAGER
            if (isRejectedByManager && managerRejectionDate != null) {
              final rejectedDescription = isArabic
                  ? 'تم رفض الدليل الخاص بك من قبل المدير. يرجى إعادة التقديم'
                  : 'Your evidence has been rejected by manager. Please resubmit';

              events.add(CalendarEventModel(
                date: managerRejectionDate,
                color: const Color(0xFF9FADAF),
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(managerRejectionDate),
                description: rejectedDescription,
                status: 'Rejected',
              ));

              debugPrint('   ✅ Added PERMANENT Rejected by Manager card');
            }

          } catch (e) {
            debugPrint('   ❌ Error processing champion document: $e');
          }
        }

      } catch (timeoutError) {
        debugPrint('❌ TIMEOUT ERROR in champions query: $timeoutError');
      } catch (e) {
        debugPrint('❌ ERROR in champions query: $e');
      }

      // ========================================
      // PART 2: GET SUPERVISOR VIEW
      // ========================================
      try {
        debugPrint('\n📄 ===== CHECKING SUPERVISOR VIEW =====');

        final allChampionsSnapshot = await _firestore
            .collection('Demo')
            .doc(companyId)
            .collection('Qiyas Control Champions')
            .where('status', isEqualTo: 'active')
            .get()
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            debugPrint('⏰ TIMEOUT: All champions query timeout');
            throw TimeoutException('All champions query timeout');
          },
        );

        debugPrint('📄 Found ${allChampionsSnapshot.docs.length} total active champion assignments');

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
              debugPrint('\n📄 SKIP: Current user IS the champion ($championEmail) - no supervisor cards needed');
              continue;
            }

            final championEmployee = mainCoreController.getLocaleEmployee(championEmail);

            if (championEmployee == null) {
              continue;
            }

            final championSupervisorEmail = championEmployee.supervisor?.trim().toLowerCase();

            if (championSupervisorEmail != currentUserEmail.toLowerCase()) {
              continue;
            }

            debugPrint('\n📄 Processing Assignment for Supervisor View:');
            debugPrint('   Champion: $championEmail');
            debugPrint('   Champion Name: ${championEmployee.firstName} ${championEmployee.lastName}');

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
                submissionDate.day
            );

            final daysUntilSubmission = submissionDateOnly.difference(today).inDays;

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
                  .collection('Demo')
                  .doc(companyId)
                  .collection('Qiyas Evidence Submissions')
                  .where('Criteria_Number', isEqualTo: criteriaId)
                  .where('Evidence_Number', isEqualTo: documentNumber)
                  .where('Submitted_By', isEqualTo: championEmail)
                  .orderBy('Submission_Date', descending: true)
                  .limit(1)
                  .get();

              if (evidenceSnapshot.docs.isNotEmpty) {
                hasSubmitted = true;
                final evidenceData = evidenceSnapshot.docs.first.data();
                final evidenceStatus = evidenceData['Submission_Status']?.toString().toLowerCase() ?? '';

                isApprovedBySupervisor = evidenceStatus == 'approved_by_supervisor';
                isApprovedByManager = evidenceStatus == 'approved';
                isRejectedBySupervisor = evidenceStatus == 'rejected_by_supervisor';
                isRejectedByManager = evidenceStatus == 'rejected_by_manager' || evidenceStatus == 'rejected';

                final supervisorApprovalDateField = evidenceData['Supervisor_Approval_Date'];
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

                final managerApprovalDateField = evidenceData['Manager_Approval_Date'];
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
                  final supervisorRejectionDateField = evidenceData['Supervisor_Rejection_Date'];
                  if (supervisorRejectionDateField is Timestamp) {
                    supervisorRejectionDate = supervisorRejectionDateField.toDate();
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
                  final managerRejectionDateField = evidenceData['Manager_Rejection_Date'];
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
              debugPrint('   ⚠️ Error checking evidence: $e');
            }

            final championName = '${championEmployee.firstName} ${championEmployee.lastName}';

            // SUPERVISOR CARD 1: DURATION
            final durationDescription = isArabic
                ? 'موظفك $championName تم تعيين له $evidenceName'
                : 'Your employee $championName has been assigned $evidenceName';

            events.add(CalendarEventModel(
              date: submissionDate,
              color: const Color(0xFF9FADAF),
              moduleName: 'Qiyas',
              taskName: evidenceName,
              time: DateFormat('hh:mm a').format(submissionDate),
              description: durationDescription,
              status: 'Duration',
            ));

            debugPrint('   ✅ Added PERMANENT Duration card');

            // SUPERVISOR CARD 2: OVERDUE
            if (!hasSubmitted && daysUntilSubmission < 0 && !isApprovedByManager) {
              final overdueDescription = isArabic
                  ? 'موظفك $championName لم يقم بتحميل الدليل المطلوب منه'
                  : 'Your employee $championName did not upload the evidence which was requested from him';

              events.add(CalendarEventModel(
                date: submissionDate,
                color: const Color(0xFF9FADAF),
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(submissionDate),
                description: overdueDescription,
                status: 'Overdue',
              ));

              debugPrint('   ✅ Added PERMANENT Overdue card');
            }

            // SUPERVISOR CARD 3: APPROVED BY SUPERVISOR
            if (isApprovedBySupervisor && supervisorApprovalDate != null) {
              final approvedDescription = isArabic
                  ? 'لقد وافقت على دليل $championName، في انتظار موافقة المدير'
                  : 'You have approved $championName\'s evidence, waiting for manager approval';

              events.add(CalendarEventModel(
                date: supervisorApprovalDate,
                color: const Color(0xFF9FADAF),
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(supervisorApprovalDate),
                description: approvedDescription,
                status: 'Approved by Supervisor',
              ));

              debugPrint('   ✅ Added PERMANENT Approved by Supervisor card');
            }

            // SUPERVISOR CARD 4: APPROVED BY MANAGER
            if (isApprovedByManager && managerApprovalDate != null) {
              final approvedDescription = isArabic
                  ? 'تمت الموافقة على دليل $championName بشكل نهائي من قبل المدير'
                  : 'Manager has approved $championName\'s evidence';

              events.add(CalendarEventModel(
                date: managerApprovalDate,
                color: const Color(0xFF9FADAF),
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(managerApprovalDate),
                description: approvedDescription,
                status: 'Approved',
              ));

              debugPrint('   ✅ Added PERMANENT Manager Approved card');
            }

            // SUPERVISOR CARD 5: REJECTED BY SUPERVISOR
            if (isRejectedBySupervisor && supervisorRejectionDate != null) {
              final rejectedDescription = isArabic
                  ? 'لقد رفضت دليل $championName'
                  : 'You have rejected $championName\'s evidence';

              events.add(CalendarEventModel(
                date: supervisorRejectionDate,
                color: const Color(0xFF9FADAF),
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(supervisorRejectionDate),
                description: rejectedDescription,
                status: 'Rejected',
              ));

              debugPrint('   ✅ Added PERMANENT Rejected by Supervisor card');
            }

            // SUPERVISOR CARD 6: REJECTED BY MANAGER
            if (isRejectedByManager && managerRejectionDate != null) {
              final rejectedDescription = isArabic
                  ? 'المدير رفض دليل $championName'
                  : 'Manager has rejected $championName\'s evidence';

              events.add(CalendarEventModel(
                date: managerRejectionDate,
                color: const Color(0xFF9FADAF),
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(managerRejectionDate),
                description: rejectedDescription,
                status: 'Rejected',
              ));

              debugPrint('   ✅ Added PERMANENT Manager Rejected card');
            }

          } catch (e) {
            debugPrint('   ❌ Error processing supervisor view: $e');
          }
        }

      } catch (timeoutError) {
        debugPrint('❌ TIMEOUT ERROR in supervisor view query: $timeoutError');
      } catch (e) {
        debugPrint('❌ ERROR in supervisor view query: $e');
      }

      // ========================================
      // PART 3: GET SUPERVISOR PENDING APPROVALS
      // ========================================
      try {
        debugPrint('\n📄 ===== CHECKING SUPERVISOR PENDING APPROVALS =====');

        final allEvidenceSnapshot = await _firestore
            .collection('Demo')
            .doc(companyId)
            .collection('Qiyas Evidence Submissions')
            .get()
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            debugPrint('⏰ TIMEOUT: Evidence query timeout');
            throw TimeoutException('Evidence query timeout');
          },
        );

        debugPrint('📄 Found ${allEvidenceSnapshot.docs.length} total evidence submissions');

        int pendingCount = 0;
        int approvedBySupervisorCount = 0;

        for (var evidenceDoc in allEvidenceSnapshot.docs) {
          try {
            final evidenceData = evidenceDoc.data();
            final criteriaId = evidenceData['Criteria_Number']?.toString() ?? '';
            final documentNumber = evidenceData['Evidence_Number']?.toString() ?? '';
            final championEmail = evidenceData['Submitted_By']?.toString() ?? '';
            final evidenceStatus = evidenceData['Submission_Status']?.toString().toLowerCase() ?? '';

            debugPrint('\n📄 Checking evidence: $criteriaId-$documentNumber');
            debugPrint('   Champion: $championEmail');
            debugPrint('   Status: $evidenceStatus');

            // ✅ CRITICAL FIX: Skip if current user IS the champion themselves
            if (championEmail.toLowerCase() == currentUserEmail.toLowerCase()) {
              debugPrint('   ⏭️ SKIP: Current user IS the champion - no supervisor approval cards needed');
              continue;
            }

            if (evidenceStatus != 'pending' &&
                evidenceStatus != 'submitted' &&
                evidenceStatus != 'approved_by_supervisor') {
              debugPrint('   ⏭️ SKIP: Status is not pending/submitted/approved_by_supervisor');
              continue;
            }

            final championEmployee = mainCoreController.getLocaleEmployee(championEmail);

            if (championEmployee == null) {
              debugPrint('   ⚠️ Champion employee not found: $championEmail');
              continue;
            }

            final championSupervisorEmail = championEmployee.supervisor?.trim().toLowerCase();

            if (championSupervisorEmail == null || championSupervisorEmail.isEmpty) {
              debugPrint('   ⚠️ Champion has no supervisor assigned');
              continue;
            }

            final currentUserEmailNormalized = currentUserEmail.trim().toLowerCase();

            bool isCurrentUserSupervisor = championSupervisorEmail == currentUserEmailNormalized;

            bool isSuperAdmin = mainCoreController.isSuperAdmin();
            bool hasQiyasAdminPermission = false;

            try {
              hasQiyasAdminPermission = mainCoreController.hasSpecificPermission(
                  Modules.qiyas,
                  'admin_access'
              ) || mainCoreController.hasSpecificPermission(
                  Modules.qiyas,
                  'approve_evidence'
              );
            } catch (e) {
              debugPrint('   ⚠️ Error checking Qiyas permissions: $e');
            }

            bool shouldShowCard = isCurrentUserSupervisor || isSuperAdmin || hasQiyasAdminPermission;

            if (!shouldShowCard) {
              debugPrint('   ⏭️ SKIP: Current user is not supervisor/admin for this champion');
              continue;
            }

            final submissionDateField = evidenceData['Submission_Date'];
            DateTime? submissionDate;

            if (submissionDateField is Timestamp) {
              submissionDate = submissionDateField.toDate();
            }

            if (submissionDate == null) {
              debugPrint('   ⏭️ SKIP: No submission date');
              continue;
            }

            String? evidenceName;

            try {
              final championDoc = await _firestore
                  .collection('Demo')
                  .doc(companyId)
                  .collection('Qiyas Control Champions')
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
                    if (evidenceNameField is List && evidenceNameField.isNotEmpty) {
                      evidenceName = evidenceNameField.first?.toString().trim();
                    } else if (evidenceNameField is String) {
                      evidenceName = evidenceNameField.trim();
                    }
                  }
                }
              }
            } catch (e) {
              debugPrint('   ⚠️ Error fetching champion details: $e');
            }

            if (evidenceName == null || evidenceName.isEmpty) {
              evidenceName = 'Qiyas Document $criteriaId-$documentNumber';
            }

            final championName = '${championEmployee.firstName} ${championEmployee.lastName}';

            final period = submissionDate.hour >= 12 ? 'PM' : 'AM';
            final displayHour = submissionDate.hour > 12
                ? submissionDate.hour - 12
                : (submissionDate.hour == 0 ? 12 : submissionDate.hour);
            final displayTime =
                '${displayHour.toString().padLeft(2, '0')}:${submissionDate.minute.toString().padLeft(2, '0')} $period';

            if (evidenceStatus == 'pending' || evidenceStatus == 'submitted') {
              debugPrint('   ✅ Creating Pending Approval card (PERMANENT)');

              final pendingDescription = isArabic
                  ? 'لديك طلب من $championName يحتاج إلى اتخاذ إجراء'
                  : 'You have a request from $championName that needs action';

              events.add(CalendarEventModel(
                date: submissionDate,
                color: const Color(0xFF9FADAF),
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: displayTime,
                description: pendingDescription,
                status: 'Pending Approval',
              ));

              pendingCount++;
              debugPrint('   ✅ Added PERMANENT Pending Approval card');

            } else if (evidenceStatus == 'approved_by_supervisor') {
              debugPrint('   ✅ Creating Approved by Supervisor card (PERMANENT)');

              DateTime? approvalDate;
              final supervisorApprovalDateField = evidenceData['Supervisor_Approval_Date'];
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

              events.add(CalendarEventModel(
                date: approvalDate,
                color: const Color(0xFF9FADAF),
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: approvalDisplayTime,
                description: approvedDescription,
                status: 'Approved by Supervisor',
              ));

              approvedBySupervisorCount++;
              debugPrint('   ✅ Added PERMANENT Approved by Supervisor card');
            }

          } catch (e) {
            debugPrint('   ❌ Error processing evidence: $e');
          }
        }

        debugPrint('\n📊 SUPERVISOR CARDS SUMMARY:');
        debugPrint('   Pending Approval cards: $pendingCount');
        debugPrint('   Approved by Supervisor cards: $approvedBySupervisorCount');

      } catch (timeoutError) {
        debugPrint('❌ TIMEOUT ERROR in supervisor pending approvals: $timeoutError');
      } catch (e) {
        debugPrint('❌ ERROR in supervisor pending approvals: $e');
      }

      // ========================================
      // PART 4: GET MANAGER PENDING APPROVALS & ACTIONS
      // ========================================
      try {
        debugPrint('\n📄 ===== CHECKING MANAGER VIEW (CHANGE SUBMISSION STATUS PERMISSION) =====');

        // ✅ Check if user has manager permission
        bool hasManagerPermission = false;

        try {
          hasManagerPermission = mainCoreController.isHasPermission(
            module: Modules.qiyas,
            section: QiyasPermissionsSections.changeSubmissionStatus,
            permission: null,
          );
        } catch (e) {
          debugPrint('   ⚠️ Error checking manager permission: $e');
        }

        debugPrint('   Has changeSubmissionStatus permission: $hasManagerPermission');

        if (!hasManagerPermission) {
          debugPrint('   ⏭️ SKIP: User does not have manager permission (changeSubmissionStatus)');
        } else {
          debugPrint('   ✅ User IS a manager with changeSubmissionStatus permission!');

          // Get all evidence submissions
          final allEvidenceSnapshot = await _firestore
              .collection('Demo')
              .doc(companyId)
              .collection('Qiyas Evidence Submissions')
              .get()
              .timeout(
            Duration(seconds: 15),
            onTimeout: () {
              debugPrint('⏰ TIMEOUT: Manager evidence query timeout');
              throw TimeoutException('Manager evidence query timeout');
            },
          );

          debugPrint('📄 Found ${allEvidenceSnapshot.docs.length} total evidence submissions');

          int managerPendingCount = 0;
          int managerApprovedCount = 0;
          int managerRejectedCount = 0;

          for (var evidenceDoc in allEvidenceSnapshot.docs) {
            try {
              final evidenceData = evidenceDoc.data();
              final criteriaId = evidenceData['Criteria_Number']?.toString() ?? '';
              final documentNumber = evidenceData['Evidence_Number']?.toString() ?? '';
              final championEmail = evidenceData['Submitted_By']?.toString() ?? '';
              final evidenceStatus = evidenceData['Submission_Status']?.toString().toLowerCase() ?? '';

              debugPrint('\n📄 Manager checking evidence: $criteriaId-$documentNumber');
              debugPrint('   Champion: $championEmail');
              debugPrint('   Status: $evidenceStatus');

              // ✅ CRITICAL FIX: Skip if current user IS the champion themselves
              if (championEmail.toLowerCase() == currentUserEmail.toLowerCase()) {
                debugPrint('   ⏭️ SKIP: Current user IS the champion - no manager cards about own evidence');
                continue;
              }

              // ✅ Skip if not relevant to manager
              if (evidenceStatus != 'approved_by_supervisor' &&
                  evidenceStatus != 'approved' &&
                  evidenceStatus != 'rejected_by_manager' &&
                  evidenceStatus != 'rejected') {
                debugPrint('   ⏭️ SKIP: Status not relevant for manager ($evidenceStatus)');
                continue;
              }

              debugPrint('   ✅✅✅ Status IS relevant for manager!');

              // Get champion employee
              final championEmployee = mainCoreController.getLocaleEmployee(championEmail);
              if (championEmployee == null) {
                debugPrint('   ⚠️ Champion employee not found');
                continue;
              }

              final championName = '${championEmployee.firstName} ${championEmployee.lastName}';

              // Get supervisor name
              String supervisorName = 'Supervisor';
              final championSupervisorEmail = championEmployee.supervisor?.trim();
              if (championSupervisorEmail != null && championSupervisorEmail.isNotEmpty) {
                final supervisorEmployee = mainCoreController.getLocaleEmployee(championSupervisorEmail);
                if (supervisorEmployee != null) {
                  supervisorName = '${supervisorEmployee.firstName} ${supervisorEmployee.lastName}';
                }
              }

              debugPrint('   Champion Name: $championName');
              debugPrint('   Supervisor Name: $supervisorName');

              // Get evidence name
              String? evidenceName;
              try {
                final championDoc = await _firestore
                    .collection('Demo')
                    .doc(companyId)
                    .collection('Qiyas Control Champions')
                    .where('Criteria_Id', isEqualTo: criteriaId)
                    .where('Document', isEqualTo: documentNumber)
                    .where('Champion', isEqualTo: championEmail)
                    .limit(1)
                    .get();

                if (championDoc.docs.isNotEmpty) {
                  final championData = championDoc.docs.first.data();
                  final notesArray = championData['Notes'] as List?;
                  if (notesArray != null && notesArray.isNotEmpty) {
                    evidenceName = notesArray.first?.toString().trim();
                  }

                  if (evidenceName == null || evidenceName.isEmpty) {
                    final evidenceNameField = championData['Evidence_Name'];
                    if (evidenceNameField is List && evidenceNameField.isNotEmpty) {
                      evidenceName = evidenceNameField.first?.toString().trim();
                    } else if (evidenceNameField is String) {
                      evidenceName = evidenceNameField.trim();
                    }
                  }
                }
              } catch (e) {
                debugPrint('   ⚠️ Error fetching evidence name: $e');
              }

              if (evidenceName == null || evidenceName.isEmpty) {
                evidenceName = 'Qiyas Document $criteriaId-$documentNumber';
              }

              debugPrint('   Evidence Name: $evidenceName');

              // ✅ MANAGER CARD 1: PENDING APPROVAL (approved_by_supervisor)
              if (evidenceStatus == 'approved_by_supervisor') {
                debugPrint('   ✅ Creating Manager Pending Approval card');

                DateTime? approvalDate;

                // Try to get supervisor approval date
                final supervisorApprovalDateField = evidenceData['Supervisor_Approval_Date'];
                if (supervisorApprovalDateField is Timestamp) {
                  approvalDate = supervisorApprovalDateField.toDate();
                  debugPrint('   📅 Using Supervisor_Approval_Date: $approvalDate');
                } else {
                  final actionDateField = evidenceData['Action_Date'];
                  if (actionDateField is Timestamp) {
                    approvalDate = actionDateField.toDate();
                    debugPrint('   📅 Using Action_Date: $approvalDate');
                  } else {
                    final submissionDateField = evidenceData['Submission_Date'];
                    if (submissionDateField is Timestamp) {
                      approvalDate = submissionDateField.toDate();
                      debugPrint('   📅 Using Submission_Date: $approvalDate');
                    } else {
                      approvalDate = DateTime.now();
                      debugPrint('   📅 Using current time: $approvalDate');
                    }
                  }
                }

                final period = approvalDate.hour >= 12 ? 'PM' : 'AM';
                final displayHour = approvalDate.hour > 12
                    ? approvalDate.hour - 12
                    : (approvalDate.hour == 0 ? 12 : approvalDate.hour);
                final displayTime =
                    '${displayHour.toString().padLeft(2, '0')}:${approvalDate.minute.toString().padLeft(2, '0')} $period';

                final managerPendingDescription = isArabic
                    ? 'لديك طلب من $championName تمت الموافقة عليه من قبل $supervisorName ويحتاج إلى موافقتك'
                    : 'You have a request from $championName approved by $supervisorName that needs your approval';

                events.add(CalendarEventModel(
                  date: approvalDate,
                  color: const Color(0xFF9FADAF),
                  moduleName: 'Qiyas',
                  taskName: evidenceName,
                  time: displayTime,
                  description: managerPendingDescription,
                  status: 'Pending Approval',
                ));

                managerPendingCount++;
                debugPrint('   ✅✅✅ Added PERMANENT Manager Pending Approval card');
              }

              // ✅ MANAGER CARD 2: APPROVED BY MANAGER
              if (evidenceStatus == 'approved') {
                debugPrint('   ✅ Creating Manager Approved card');

                DateTime? managerApprovalDate;
                final managerApprovalDateField = evidenceData['Manager_Approval_Date'];
                if (managerApprovalDateField is Timestamp) {
                  managerApprovalDate = managerApprovalDateField.toDate();
                } else {
                  final actionDateField = evidenceData['Action_Date'];
                  if (actionDateField is Timestamp) {
                    managerApprovalDate = actionDateField.toDate();
                  } else {
                    managerApprovalDate = DateTime.now();
                  }
                }

                final period = managerApprovalDate.hour >= 12 ? 'PM' : 'AM';
                final displayHour = managerApprovalDate.hour > 12
                    ? managerApprovalDate.hour - 12
                    : (managerApprovalDate.hour == 0 ? 12 : managerApprovalDate.hour);
                final displayTime =
                    '${displayHour.toString().padLeft(2, '0')}:${managerApprovalDate.minute.toString().padLeft(2, '0')} $period';

                final managerApprovedDescription = isArabic
                    ? 'لقد وافقت على دليل $championName'
                    : 'You have approved $championName\'s evidence';

                events.add(CalendarEventModel(
                  date: managerApprovalDate,
                  color: const Color(0xFF9FADAF),
                  moduleName: 'Qiyas',
                  taskName: evidenceName,
                  time: displayTime,
                  description: managerApprovedDescription,
                  status: 'Approved',
                ));

                managerApprovedCount++;
                debugPrint('   ✅ Added PERMANENT Manager Approved card');
              }

              // ✅ MANAGER CARD 3: REJECTED BY MANAGER
              if (evidenceStatus == 'rejected_by_manager' || evidenceStatus == 'rejected') {
                debugPrint('   ✅ Creating Manager Rejected card');

                DateTime? managerRejectionDate;
                final managerRejectionDateField = evidenceData['Manager_Rejection_Date'];
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

                final period = managerRejectionDate.hour >= 12 ? 'PM' : 'AM';
                final displayHour = managerRejectionDate.hour > 12
                    ? managerRejectionDate.hour - 12
                    : (managerRejectionDate.hour == 0 ? 12 : managerRejectionDate.hour);
                final displayTime =
                    '${displayHour.toString().padLeft(2, '0')}:${managerRejectionDate.minute.toString().padLeft(2, '0')} $period';

                final managerRejectedDescription = isArabic
                    ? 'لقد رفضت دليل $championName'
                    : 'You have rejected $championName\'s evidence';

                events.add(CalendarEventModel(
                  date: managerRejectionDate,
                  color: const Color(0xFF9FADAF),
                  moduleName: 'Qiyas',
                  taskName: evidenceName,
                  time: displayTime,
                  description: managerRejectedDescription,
                  status: 'Rejected',
                ));

                managerRejectedCount++;
                debugPrint('   ✅ Added PERMANENT Manager Rejected card');
              }

            } catch (e) {
              debugPrint('   ❌ Error processing manager evidence: $e');
            }
          }

          debugPrint('\n📊 MANAGER CARDS SUMMARY:');
          debugPrint('   Manager Pending Approval cards: $managerPendingCount');
          debugPrint('   Manager Approved cards: $managerApprovedCount');
          debugPrint('   Manager Rejected cards: $managerRejectedCount');
        }

      } catch (timeoutError) {
        debugPrint('❌ TIMEOUT ERROR in manager view: $timeoutError');
      } catch (e) {
        debugPrint('❌ ERROR in manager view: $e');
      }

      debugPrint('\n✅ COMPLETE! Total Qiyas events: ${events.length}');
      debugPrint('🎨 All Qiyas events use GREY color (0xFF9FADAF)');
      debugPrint('📌 ✅✅✅ ALL CARDS ARE PERMANENT - THEY NEVER GET DELETED ✅✅✅');

      if (events.isNotEmpty) {
        debugPrint('\n📋 Qiyas Events List:');
        for (var i = 0; i < events.length; i++) {
          final event = events[i];
          debugPrint('   ${i + 1}. [${event.status}] ${event.taskName} - ${event.description} on ${event.date}');
        }
      }

    } catch (e, stackTrace) {
      debugPrint('❌ FATAL ERROR in getQiyasCalendarEvents: $e');
      debugPrint('Stack: $stackTrace');
    }

    return events;
  }




  Future<List<CalendarEventModel>> getTodoCalendarEvents({
    required String currentUserEmail,
  }) async {
    List<CalendarEventModel> events = [];

    try {
      debugPrint('\n🔍 ===== FETCHING TODO CALENDAR EVENTS =====');
      debugPrint('📧 Current User: $currentUserEmail');

      String companyIdPath = getBaseUrl('');
      String companyId = '';
      if (companyIdPath.contains('/')) {
        final parts = companyIdPath.split('/');
        if (parts.length >= 2) {
          companyId = parts[1];
        }
      }

      debugPrint('🏢 Using company ID: $companyId');

      // ✅ Get current locale to determine language
      final currentLocale = Get.locale?.languageCode ?? 'en';
      final isArabic = currentLocale == 'ar';

      debugPrint('🌍 Current locale: $currentLocale');
      debugPrint('🌍 Is Arabic mode: $isArabic');

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      try {
        final todosSnapshot = await _firestore
            .collection('Demo')
            .doc(companyId)
            .collection('Creating_Task')
            .get()
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            debugPrint('⏰ TIMEOUT: Todos query took more than 15 seconds');
            throw TimeoutException('Todos query timeout');
          },
        );

        debugPrint('📄 Found ${todosSnapshot.docs.length} total todos');

        for (var todoDoc in todosSnapshot.docs) {
          try {
            final data = todoDoc.data();
            final taskId = todoDoc.id;

            debugPrint('\n📄 Processing Todo: $taskId');

            // ✅ Get task status from map structure
            final taskStatusMap = data['taskStatus'] as Map<String, dynamic>?;
            if (taskStatusMap == null) {
              debugPrint('   ⏭️ SKIP: No task status');
              continue;
            }

            final taskStatusValues = taskStatusMap['values'] as List?;
            if (taskStatusValues == null || taskStatusValues.isEmpty) {
              debugPrint('   ⏭️ SKIP: No task status values');
              continue;
            }

            final currentStatus = taskStatusValues.last.toString().toLowerCase();
            debugPrint('   Current Status: $currentStatus');

            // Skip deleted tasks
            if (currentStatus == 'deleted') {
              debugPrint('   ⏭️ SKIP: Task is deleted');
              continue;
            }

            // ✅ Get task name from map structure
            final nameMap = data['name'] as Map<String, dynamic>?;
            String taskName = 'Todo Task';
            if (nameMap != null) {
              final nameValues = nameMap['values'] as List?;
              if (nameValues != null && nameValues.isNotEmpty) {
                taskName = nameValues.last.toString();
              }
            }

            debugPrint('   Task Name: $taskName');

            // ✅ Get creator email from map structure
            final creatorEmailMap = data['creatorEmail'] as Map<String, dynamic>?;
            String creatorEmail = '';
            if (creatorEmailMap != null) {
              final creatorEmailValues = creatorEmailMap['values'] as List?;
              if (creatorEmailValues != null && creatorEmailValues.isNotEmpty) {
                creatorEmail = creatorEmailValues.last.toString().toLowerCase().trim();
              }
            }

            if (creatorEmail != currentUserEmail.toLowerCase().trim()) {
              debugPrint('   ⏭️ SKIP: Not created by current user');
              continue;
            }

            debugPrint('   ✅ Todo belongs to current user');

            // ✅ Get scheduled data from map structure
            final scheduledMap = data['scheduled'] as Map<String, dynamic>?;
            if (scheduledMap == null) {
              debugPrint('   ⏭️ SKIP: No scheduled map');
              continue;
            }

            final scheduledValues = scheduledMap['values'] as List?;
            if (scheduledValues == null || scheduledValues.isEmpty) {
              debugPrint('   ⏭️ SKIP: No scheduled values');
              continue;
            }

            final scheduledJsonString = scheduledValues.last.toString();

            // Check if the scheduled data is empty
            if (scheduledJsonString == '{}' || scheduledJsonString.isEmpty) {
              debugPrint('   ⏭️ SKIP: Scheduled data is empty');
              continue;
            }

            Map<String, dynamic>? scheduledData;

            try {
              scheduledData = jsonDecode(scheduledJsonString);
            } catch (e) {
              debugPrint('   ⚠️ Error parsing scheduled data: $e');
              continue;
            }

            // ✅ FIXED: Parse dates - support both ISO string and milliseconds
            DateTime? startDate;
            DateTime? endDate;
            String? endTime;

            if (scheduledData!['taskStartDate'] != null) {
              try {
                final startDateValue = scheduledData['taskStartDate'];

                if (startDateValue is int) {
                  startDate = DateTime.fromMillisecondsSinceEpoch(startDateValue);
                } else if (startDateValue is String) {
                  startDate = DateTime.parse(startDateValue);
                } else {
                  startDate = DateTime.fromMillisecondsSinceEpoch(
                      int.parse(startDateValue.toString())
                  );
                }

                debugPrint('   ✅ Parsed Start Date: $startDate');
              } catch (e) {
                debugPrint('   ⚠️ Error parsing start date: $e');
              }
            }

            if (scheduledData['taskEndDate'] != null) {
              try {
                final endDateValue = scheduledData['taskEndDate'];

                if (endDateValue is int) {
                  endDate = DateTime.fromMillisecondsSinceEpoch(endDateValue);
                } else if (endDateValue is String) {
                  endDate = DateTime.parse(endDateValue);
                } else {
                  endDate = DateTime.fromMillisecondsSinceEpoch(
                      int.parse(endDateValue.toString())
                  );
                }

                debugPrint('   ✅ Parsed End Date: $endDate');
              } catch (e) {
                debugPrint('   ⚠️ Error parsing end date: $e');
              }
            }

            if (scheduledData['taskEndTime'] != null) {
              endTime = scheduledData['taskEndTime'].toString();
            }

            debugPrint('   Start Date: $startDate');
            debugPrint('   End Date: $endDate');
            debugPrint('   End Time: $endTime');

            // ✅ Get frequency data from map structure
            final frequencyMap = data['frequency'] as Map<String, dynamic>?;
            String? frequencyUnit;
            int? frequencyInterval;

            if (frequencyMap != null) {
              final frequencyValues = frequencyMap['values'] as List?;
              if (frequencyValues != null && frequencyValues.isNotEmpty) {
                final frequencyJsonString = frequencyValues.last.toString();

                if (frequencyJsonString != '{}' && frequencyJsonString.isNotEmpty) {
                  try {
                    final frequencyData = jsonDecode(frequencyJsonString);
                    frequencyUnit = frequencyData['frequencyUnit']?.toString().toLowerCase();
                    frequencyInterval = frequencyData['frequencyInterval'] is int
                        ? frequencyData['frequencyInterval']
                        : int.tryParse(frequencyData['frequencyInterval']?.toString() ?? '1');

                    debugPrint('   Frequency Unit: $frequencyUnit');
                    debugPrint('   Frequency Interval: $frequencyInterval');
                  } catch (e) {
                    debugPrint('   ⚠️ Error parsing frequency data: $e');
                  }
                }
              }
            }

            // ========================================
            // CARD 1: SCHEDULED (Show on START DATE only if task hasn't started yet)
            // ========================================
            if (startDate != null) {
              final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);

              // ✅ Only show Scheduled card if start date is in the FUTURE
              if (startDateOnly.isAfter(today)) {
                debugPrint('   ✅ Creating Scheduled card (future start date)');

                final displayDate = DateFormat('MMM dd, yyyy').format(startDate);
                final endDateStr = endDate != null ? DateFormat('MMM dd, yyyy').format(endDate) : '';

                String description;
                if (endDate != null) {
                  description = isArabic
                      ? 'مهمة مجدولة للبدء في $displayDate والانتهاء في $endDateStr'
                      : 'Task scheduled to start on $displayDate and end on $endDateStr';
                } else {
                  description = isArabic
                      ? 'مهمة مجدولة للبدء في $displayDate'
                      : 'Task scheduled to start on $displayDate';
                }

                events.add(CalendarEventModel(
                  date: startDate,
                  color: const Color(0xFF9C27B0), // PURPLE - Todo
                  moduleName: 'Todo',
                  taskName: taskName,
                  time: DateFormat('hh:mm a').format(startDate),
                  description: description,
                  status: 'Scheduled',
                ));

                debugPrint('   ✅ Added Scheduled card on $displayDate');
              } else {
                debugPrint('   ⏭️ SKIP: Start date is not in future ($startDateOnly vs $today)');
              }
            }

            // ========================================
            // CARD 2: DURATION (Show on EVERY DAY between start and end, only if task is currently active)
            // ========================================
            if (startDate != null && endDate != null) {
              final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
              final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

              // ✅ Only show Duration if task is CURRENTLY ACTIVE (today is between start and end)
              if (today.isAfter(startDateOnly.subtract(Duration(days: 1))) &&
                  today.isBefore(endDateOnly.add(Duration(days: 1)))) {

                debugPrint('   ✅ Creating Duration card (task is active)');

                final displayStartDate = DateFormat('MMM dd, yyyy').format(startDate);
                final displayEndDate = DateFormat('MMM dd, yyyy').format(endDate);

                final description = isArabic
                    ? 'مهمة نشطة من $displayStartDate إلى $displayEndDate'
                    : 'Active task from $displayStartDate to $displayEndDate';

                // ✅ Show Duration card on EVERY DAY between start and end
                DateTime currentDate = startDateOnly;

                while (currentDate.isBefore(endDateOnly.add(Duration(days: 1)))) {
                  events.add(CalendarEventModel(
                    date: currentDate,
                    color: const Color(0xFF9C27B0), // PURPLE - Todo
                    moduleName: 'Todo',
                    taskName: taskName,
                    time: DateFormat('hh:mm a').format(startDate),
                    description: description,
                    status: 'Duration',
                  ));

                  debugPrint('   ✅ Added Duration card on ${DateFormat('MMM dd, yyyy').format(currentDate)}');
                  currentDate = currentDate.add(Duration(days: 1));
                }
              } else {
                debugPrint('   ⏭️ SKIP: Task is not currently active');
                debugPrint('         Today: $today');
                debugPrint('         Start: $startDateOnly');
                debugPrint('         End: $endDateOnly');
              }
            }

            // ========================================
            // CARD 3: DUE (Show on END DATE - Always show, even after task ends)
            // ========================================
            if (endDate != null) {
              debugPrint('   ✅ Creating Due card on end date');

              final displayDate = DateFormat('MMM dd, yyyy').format(endDate);

              String description;
              if (currentStatus == 'done') {
                description = isArabic
                    ? 'المهمة اكتملت في $displayDate'
                    : 'Task was completed on $displayDate';
              } else {
                description = isArabic
                    ? 'الموعد النهائي للمهمة هو $displayDate'
                    : 'Task deadline is $displayDate';
              }

              events.add(CalendarEventModel(
                date: endDate,
                color: const Color(0xFF9C27B0), // PURPLE - Todo
                moduleName: 'Todo',
                taskName: taskName,
                time: endTime != null && endTime.isNotEmpty
                    ? endTime
                    : DateFormat('hh:mm a').format(endDate),
                description: description,
                status: 'Due',
              ));

              debugPrint('   ✅ Added Due card on $displayDate');
            }

            // ========================================
            // CARD 4: OVERDUE (Show on END DATE if task passed deadline and not done)
            // ========================================
            if (endDate != null && currentStatus != 'done') {
              debugPrint('   🔍 Checking for overdue...');

              final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
              DateTime deadlineDateTime = endDateOnly;

              // If end time exists, create full datetime
              if (endTime != null && endTime.isNotEmpty) {
                try {
                  // Parse time like "8:26 PM"
                  final timeUpper = endTime.toUpperCase();
                  final isPM = timeUpper.contains('PM');
                  final timeWithoutPeriod = timeUpper.replaceAll(RegExp(r'[AP]M'), '').trim();
                  final timeParts = timeWithoutPeriod.split(':');

                  int hour = int.parse(timeParts[0]);
                  final minute = int.parse(timeParts[1]);

                  // Convert to 24-hour format
                  if (isPM && hour != 12) {
                    hour += 12;
                  } else if (!isPM && hour == 12) {
                    hour = 0;
                  }

                  deadlineDateTime = DateTime(
                    endDate.year,
                    endDate.month,
                    endDate.day,
                    hour,
                    minute,
                  );
                } catch (e) {
                  debugPrint('   ⚠️ Error parsing end time: $e');
                }
              }

              debugPrint('   Deadline DateTime: $deadlineDateTime');
              debugPrint('   Current Time: $now');
              debugPrint('   Is Overdue: ${now.isAfter(deadlineDateTime)}');

              if (now.isAfter(deadlineDateTime)) {
                debugPrint('   🚨 Task is OVERDUE!');

                final overdueDescription = isArabic
                    ? 'المهمة متأخرة! يجب إكمالها على الفور'
                    : 'Task is overdue! Must be completed immediately';

                events.add(CalendarEventModel(
                  date: endDate,
                  color: const Color(0xFF9C27B0), // PURPLE - Todo
                  moduleName: 'Todo',
                  taskName: taskName,
                  time: endTime != null && endTime.isNotEmpty
                      ? endTime
                      : DateFormat('hh:mm a').format(endDate),
                  description: overdueDescription,
                  status: 'Overdue',
                ));

                debugPrint('   ✅ Added Overdue card');
              }
            }

            // ========================================
            // CARD 5: FREQUENCY (Weekly, Monthly, Daily - future occurrences)
            // ========================================
            if (frequencyUnit != null &&
                frequencyUnit.isNotEmpty &&
                frequencyUnit != 'none' &&
                endDate != null) {
              debugPrint('   ✅ Processing Frequency: $frequencyUnit');

              final interval = frequencyInterval ?? 1;
              DateTime nextOccurrence = endDate;
              final maxOccurrences = 10;
              int occurrenceCount = 0;

              while (occurrenceCount < maxOccurrences) {
                DateTime? calculatedNext;

                switch (frequencyUnit) {
                  case 'daily':
                    calculatedNext = nextOccurrence.add(Duration(days: interval));
                    break;

                  case 'weekly':
                    calculatedNext = nextOccurrence.add(Duration(days: 7 * interval));
                    break;

                  case 'monthly':
                    calculatedNext = DateTime(
                      nextOccurrence.year,
                      nextOccurrence.month + interval,
                      nextOccurrence.day,
                      nextOccurrence.hour,
                      nextOccurrence.minute,
                    );
                    break;

                  default:
                    debugPrint('   ⚠️ Unknown frequency unit: $frequencyUnit');
                    break;
                }

                if (calculatedNext == null) {
                  debugPrint('   ⏭️ SKIP: Could not calculate next occurrence');
                  break;
                }

                // ✅ Only add future occurrences
                if (calculatedNext.isAfter(now)) {
                  String frequencyDescription;
                  final occurrenceDateStr = DateFormat('MMM dd, yyyy').format(calculatedNext);

                  if (frequencyUnit == 'daily') {
                    frequencyDescription = isArabic
                        ? 'مهمة متكررة يوميًا - التكرار التالي في $occurrenceDateStr'
                        : 'Daily recurring task - Next occurrence on $occurrenceDateStr';
                  } else if (frequencyUnit == 'weekly') {
                    frequencyDescription = isArabic
                        ? 'مهمة متكررة أسبوعيًا - التكرار التالي في $occurrenceDateStr'
                        : 'Weekly recurring task - Next occurrence on $occurrenceDateStr';
                  } else if (frequencyUnit == 'monthly') {
                    frequencyDescription = isArabic
                        ? 'مهمة متكررة شهريًا - التكرار التالي في $occurrenceDateStr'
                        : 'Monthly recurring task - Next occurrence on $occurrenceDateStr';
                  } else {
                    frequencyDescription = isArabic
                        ? 'مهمة متكررة - التكرار التالي في $occurrenceDateStr'
                        : 'Recurring task - Next occurrence on $occurrenceDateStr';
                  }

                  events.add(CalendarEventModel(
                    date: calculatedNext,
                    color: const Color(0xFF9C27B0), // PURPLE - Todo
                    moduleName: 'Todo',
                    taskName: taskName,
                    time: DateFormat('hh:mm a').format(calculatedNext),
                    description: frequencyDescription,
                    status: 'Frequency',
                  ));

                  debugPrint('   ✅ Added Frequency card for $occurrenceDateStr');
                  occurrenceCount++;
                }

                nextOccurrence = calculatedNext;

                // Stop if we've gone too far into the future (1 year)
                if (calculatedNext.isAfter(now.add(Duration(days: 365)))) {
                  break;
                }
              }

              debugPrint('   ✅ Generated $occurrenceCount frequency cards');
            }

          } catch (e, stackTrace) {
            debugPrint('   ❌ Error processing todo: $e');
            debugPrint('   Stack trace: $stackTrace');
          }
        }

      } catch (timeoutError) {
        debugPrint('❌ TIMEOUT ERROR in todos query: $timeoutError');
      } catch (e) {
        debugPrint('❌ ERROR in todos query: $e');
      }

      debugPrint('\n✅ COMPLETE! Total Todo events: ${events.length}');
      debugPrint('🎨 All Todo events use PURPLE color (0xFF9C27B0)');

      if (events.isNotEmpty) {
        debugPrint('\n📋 Todo Events List:');
        for (var i = 0; i < events.length; i++) {
          final event = events[i];
          debugPrint('   ${i + 1}. [${event.status}] ${event.taskName} - ${event.description} on ${event.date}');
        }
      }

    } catch (e, stackTrace) {
      debugPrint('❌ FATAL ERROR in getTodoCalendarEvents: $e');
      debugPrint('Stack: $stackTrace');
    }

    return events;
  }


  /// Helper method to check if it's user's turn to approve
  bool _isMyTurnToApprove({
    required List<Map<String, dynamic>> approvalCycle,
    required String currentUserEmail,
    required int myIndex,
  }) {
    debugPrint('      🔍 Checking if it\'s my turn...');

    // Check all previous approvers
    for (int i = 0; i < myIndex; i++) {
      final prevState = approvalCycle[i]['state'];
      debugPrint('      Previous approver [$i] state: $prevState');

      // If previous approver rejected or canceled, not my turn
      if (['rejected', 'cancel'].contains(prevState)) {
        debugPrint('      ❌ Previous approver rejected/canceled');
        return false;
      }

      // If previous approver is still pending, not my turn
      if (['pending', 'normal', ''].contains(prevState)) {
        debugPrint('      ❌ Previous approver still pending');
        return false;
      }

      // Previous approver must be approved
      if (prevState != 'approved') {
        debugPrint('      ❌ Previous approver has unexpected state: $prevState');
        return false;
      }
    }

    // Check my state
    final myState = approvalCycle[myIndex]['state'];
    debugPrint('      My state: $myState');

    final isMyTurn = ['pending', 'normal', ''].contains(myState);
    debugPrint('      ✅ Is my turn: $isMyTurn');

    return isMyTurn;
  }



  /// Get all calendar events from Knowledge Hub module
  /// All Knowledge Hub events use BRONZE color (0xFFCD7F32)
  Future<List<CalendarEventModel>> getKnowledgeHubCalendarEvents({
    required String currentUserEmail,
  }) async {
    List<CalendarEventModel> events = [];

    try {
      debugPrint('\n🔍 ===== FETCHING KNOWLEDGE HUB CALENDAR EVENTS =====');
      debugPrint('📧 Current User: $currentUserEmail');

      String companyIdPath = getBaseUrl('');
      String companyId = '';
      if (companyIdPath.contains('/')) {
        final parts = companyIdPath.split('/');
        if (parts.length >= 2) {
          companyId = parts[1];
        }
      }

      debugPrint('🏢 Using company ID: $companyId');

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // ========================================
      // PART 1: GET SCHEDULED DOCUMENTS (startDateTime in future)
      // ========================================
      try {
        debugPrint('\n🔍 PART 1: GETTING SCHEDULED DOCUMENTS...');

        final scheduledSnapshot = await _firestore
            .collection('Demo')
            .doc(companyId)
            .collection('Create_Knowledge')
            .get()
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            debugPrint('⏰ TIMEOUT: Scheduled query took more than 15 seconds');
            throw TimeoutException('Scheduled query timeout');
          },
        );

        debugPrint('📄 Found ${scheduledSnapshot.docs.length} total knowledge documents');

        for (var doc in scheduledSnapshot.docs) {
          try {
            final data = doc.data();
            final knowledgeId = doc.id;

            // Get startDateTime
            final startDateTimeArray = data['startDateTime'] as List?;
            if (startDateTimeArray == null || startDateTimeArray.isEmpty) {
              continue;
            }

            final startTimestamp = startDateTimeArray.first;
            final startDateTime = DateTime.fromMillisecondsSinceEpoch(
              startTimestamp is int ? startTimestamp : int.parse(startTimestamp.toString()),
            );

            final startDateOnly = DateTime(
              startDateTime.year,
              startDateTime.month,
              startDateTime.day,
            );

            debugPrint('\n📄 Processing document: $knowledgeId');
            debugPrint('   Start DateTime: $startDateOnly');
            debugPrint('   Today: $today');

            // ✅ Check if startDateTime is in the FUTURE
            if (startDateOnly.isAfter(today)) {
              debugPrint('   ✅ Document is SCHEDULED (start date in future)');

              // ✅ Get document names in both languages
              final nameEnglishArray = data['nameEnglish'] as List?;
              final nameArabicArray = data['nameArabic'] as List?;

              final nameEnglish = (nameEnglishArray != null && nameEnglishArray.isNotEmpty)
                  ? nameEnglishArray.first.toString()
                  : 'Knowledge Document';

              final nameArabic = (nameArabicArray != null && nameArabicArray.isNotEmpty)
                  ? nameArabicArray.first.toString()
                  : 'وثيقة معرفية';

              // ✅ Create bilingual task name
              final taskName = '$nameEnglish / $nameArabic';

              // Format time
              final period = startDateTime.hour >= 12 ? 'PM' : 'AM';
              final displayHour = startDateTime.hour > 12
                  ? startDateTime.hour - 12
                  : (startDateTime.hour == 0 ? 12 : startDateTime.hour);
              final displayTime =
                  '${displayHour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')} $period';

              events.add(CalendarEventModel(
                date: startDateTime,
                color: const Color(0xFFCD7F32), // BRONZE - Knowledge Hub
                moduleName: 'Knowledge Hub',
                taskName: taskName,
                time: displayTime,
                description: 'Scheduled for publication / مجدول للنشر',
                status: 'Scheduled',
              ));

              debugPrint('   ✅ Scheduled event created: $taskName on $startDateOnly');
            } else {
              debugPrint('   ⏭️ SKIP: Start date is not in future');
            }

          } catch (e) {
            debugPrint('   ❌ Error processing scheduled document: $e');
          }
        }

      } catch (e) {
        debugPrint('❌ ERROR in scheduled documents query: $e');
      }

      // ========================================
      // PART 2: GET EXPIRING SOON & REMINDERS (endDateTime)
      // ========================================
      try {
        debugPrint('\n📄 ===== PART 2: CHECKING EXPIRING & REMINDERS =====');

        final expiringSnapshot = await _firestore
            .collection('Demo')
            .doc(companyId)
            .collection('Create_Knowledge')
            .get()
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            debugPrint('⏰ TIMEOUT: Expiring query timeout');
            throw TimeoutException('Expiring query timeout');
          },
        );

        debugPrint('📄 Checking ${expiringSnapshot.docs.length} documents for expiry');

        for (var doc in expiringSnapshot.docs) {
          try {
            final data = doc.data();
            final knowledgeId = doc.id;

            // Get endDateTime
            final endDateTimeArray = data['endDateTime'] as List?;
            if (endDateTimeArray == null || endDateTimeArray.isEmpty) {
              continue;
            }

            final endTimestamp = endDateTimeArray.first;
            final endDateTime = DateTime.fromMillisecondsSinceEpoch(
              endTimestamp is int ? endTimestamp : int.parse(endTimestamp.toString()),
            );

            final endDateOnly = DateTime(
              endDateTime.year,
              endDateTime.month,
              endDateTime.day,
            );

            final daysUntilEnd = endDateOnly.difference(today).inDays;

            debugPrint('\n📄 Processing document: $knowledgeId');
            debugPrint('   End DateTime: $endDateOnly');
            debugPrint('   Today: $today');
            debugPrint('   Days until end: $daysUntilEnd');

            // Skip if already expired (past dates)
            if (daysUntilEnd < 0) {
              debugPrint('   ⏭️ SKIP: Already expired');
              continue;
            }

            // ✅ Get document names in both languages FIRST
            final nameEnglishArray = data['nameEnglish'] as List?;
            final nameArabicArray = data['nameArabic'] as List?;

            final nameEnglish = (nameEnglishArray != null && nameEnglishArray.isNotEmpty)
                ? nameEnglishArray.first.toString()
                : 'Knowledge Document';

            final nameArabic = (nameArabicArray != null && nameArabicArray.isNotEmpty)
                ? nameArabicArray.first.toString()
                : 'وثيقة معرفية';

            // ✅ Create bilingual task name
            final taskName = '$nameEnglish / $nameArabic';

            String statusText;
            String description;

            // ✅ Determine status based on days until end
            if (daysUntilEnd > 14) {
              // More than 14 days → Expiring Soon
              statusText = 'Expiring Soon';
              description = taskName; // ✅ Use document name
              debugPrint('   ✅ Status: EXPIRING SOON (${daysUntilEnd} days)');
            } else {
              // 0-14 days (including tomorrow) → Reminder
              statusText = 'Reminders';
              description = taskName; // ✅ Use document name
              debugPrint('   ✅ Status: REMINDER (${daysUntilEnd} days)');
            }

            // Format time
            final period = endDateTime.hour >= 12 ? 'PM' : 'AM';
            final displayHour = endDateTime.hour > 12
                ? endDateTime.hour - 12
                : (endDateTime.hour == 0 ? 12 : endDateTime.hour);
            final displayTime =
                '${displayHour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')} $period';

            events.add(CalendarEventModel(
              date: endDateTime,
              color: const Color(0xFFCD7F32), // BRONZE - Knowledge Hub
              moduleName: 'Knowledge Hub',
              taskName: taskName,
              time: displayTime,
              description: description,
              status: statusText,
            ));

            debugPrint('   ✅ Event created: $taskName ($statusText) on $endDateOnly');

          } catch (e) {
            debugPrint('   ❌ Error processing expiring document: $e');
          }
        }

      } catch (e) {
        debugPrint('❌ ERROR in expiring documents query: $e');
      }

      // ========================================
      // PART 3: GET PENDING APPROVALS (Supervisor check)
      // ========================================
      try {
        debugPrint('\n📄 ===== PART 3: CHECKING PENDING APPROVALS =====');

        // Get all pending approval documents
        final pendingSnapshot = await _firestore
            .collection('Demo')
            .doc(companyId)
            .collection('Create_Knowledge')
            .get()
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            debugPrint('⏰ TIMEOUT: Pending approvals query timeout');
            throw TimeoutException('Pending approvals query timeout');
          },
        );

        debugPrint('📄 Found ${pendingSnapshot.docs.length} knowledge documents to check');

        int pendingCount = 0;

        for (var doc in pendingSnapshot.docs) {
          try {
            final data = doc.data();
            final knowledgeId = doc.id;

            // Get status array and check LATEST status
            final statusArray = data['status'] as List?;
            if (statusArray == null || statusArray.isEmpty) {
              continue;
            }

            // ✅ Get LATEST status (last element)
            final latestStatus = statusArray.last.toString().toLowerCase();

            debugPrint('\n📄 Checking document: $knowledgeId');
            debugPrint('   Latest Status: $latestStatus');

            // Only process if status is pending_approval
            if (latestStatus != 'pending_approval') {
              debugPrint('   ⏭️ SKIP: Status is not pending_approval');
              continue;
            }

            // Get creator email
            final createdByEmailArray = data['createdByEmail'] as List?;
            if (createdByEmailArray == null || createdByEmailArray.isEmpty) {
              debugPrint('   ⚠️ No creator email found');
              continue;
            }

            final creatorEmail = createdByEmailArray.first.toString();
            debugPrint('   Created by: $creatorEmail');

            // Get creator's employee data to find their supervisor
            final mainCoreController = Get.find<MainCoreEmployeeController>();
            final creatorEmployee = mainCoreController.getLocaleEmployee(creatorEmail);

            if (creatorEmployee == null) {
              debugPrint('   ⚠️ Creator employee not found: $creatorEmail');
              continue;
            }

            debugPrint('   Creator Name: ${creatorEmployee.firstName} ${creatorEmployee.lastName}');
            debugPrint('   Creator Department: ${creatorEmployee.departmentId}');

            // Get creator's supervisor email
            final creatorSupervisorEmail = creatorEmployee.supervisor?.trim().toLowerCase();

            if (creatorSupervisorEmail == null || creatorSupervisorEmail.isEmpty) {
              debugPrint('   ⚠️ Creator has no supervisor assigned');
              continue;
            }

            final currentUserEmailNormalized = currentUserEmail.trim().toLowerCase();

            debugPrint('   Creator Supervisor: $creatorSupervisorEmail');
            debugPrint('   Current User: $currentUserEmailNormalized');

            // Check if current user is the supervisor
            bool isCurrentUserSupervisor = creatorSupervisorEmail == currentUserEmailNormalized;

            // Also check if user is super admin or has Knowledge Hub admin permission
            bool isSuperAdmin = mainCoreController.isSuperAdmin();
            bool hasKnowledgeHubAdminPermission = false;

            try {
              hasKnowledgeHubAdminPermission = mainCoreController.hasSpecificPermission(
                  Modules.knowledgeHub,
                  'admin_access'
              ) || mainCoreController.hasSpecificPermission(
                  Modules.knowledgeHub,
                  'approve_document'
              );
            } catch (e) {
              debugPrint('   ⚠️ Error checking Knowledge Hub permissions: $e');
            }

            bool shouldShowApproval = isCurrentUserSupervisor || isSuperAdmin || hasKnowledgeHubAdminPermission;

            if (!shouldShowApproval) {
              debugPrint('   ⏭️ SKIP: Current user is not supervisor/admin for this creator');
              debugPrint('         Is Supervisor: $isCurrentUserSupervisor');
              debugPrint('         Is Super Admin: $isSuperAdmin');
              debugPrint('         Has Knowledge Hub Admin: $hasKnowledgeHubAdminPermission');
              continue;
            }

            // Get submission date (use latest timestamp)
            final timestampsArray = data['timestamps'] as List?;
            DateTime? submissionDate;

            if (timestampsArray != null && timestampsArray.isNotEmpty) {
              final latestTimestamp = timestampsArray.last;
              submissionDate = DateTime.fromMillisecondsSinceEpoch(
                latestTimestamp is int ? latestTimestamp : int.parse(latestTimestamp.toString()),
              );
            }

            if (submissionDate == null) {
              debugPrint('   ⏭️ SKIP: No submission date');
              continue;
            }

            String approvalType = 'Supervisor';
            if (isSuperAdmin) approvalType = 'Super Admin';
            if (hasKnowledgeHubAdminPermission) approvalType = 'Knowledge Hub Admin';

            debugPrint('   ✅ Found pending approval for current user!');
            debugPrint('   Approval Type: $approvalType');
            debugPrint('   Submission Date: $submissionDate');

            // ✅ Get document names in both languages
            final nameEnglishArray = data['nameEnglish'] as List?;
            final nameArabicArray = data['nameArabic'] as List?;

            final nameEnglish = (nameEnglishArray != null && nameEnglishArray.isNotEmpty)
                ? nameEnglishArray.first.toString()
                : 'Knowledge Document';

            final nameArabic = (nameArabicArray != null && nameArabicArray.isNotEmpty)
                ? nameArabicArray.first.toString()
                : 'وثيقة معرفية';

            // ✅ Create bilingual task name
            final taskName = '$nameEnglish / $nameArabic';

            // Format time
            final period = submissionDate.hour >= 12 ? 'PM' : 'AM';
            final displayHour = submissionDate.hour > 12
                ? submissionDate.hour - 12
                : (submissionDate.hour == 0 ? 12 : submissionDate.hour);
            final displayTime =
                '${displayHour.toString().padLeft(2, '0')}:${submissionDate.minute.toString().padLeft(2, '0')} $period';

            events.add(CalendarEventModel(
              date: submissionDate,
              color: const Color(0xFFCD7F32), // BRONZE - Knowledge Hub
              moduleName: 'Knowledge Hub',
              taskName: taskName,
              time: displayTime,
              description: 'Pending your approval ($approvalType) / بانتظار موافقتك',
              status: 'Pending Approval',
            ));

            pendingCount++;
            debugPrint('   ✅ Pending Approval event created: $taskName');

          } catch (e) {
            debugPrint('   ❌ Error processing pending approval: $e');
          }
        }

        debugPrint('\n📊 Total Knowledge Hub pending approvals found: $pendingCount');

      } catch (e) {
        debugPrint('❌ ERROR in pending approvals query: $e');
      }

      debugPrint('\n✅ COMPLETE! Total Knowledge Hub events: ${events.length}');
      debugPrint('🎨 All Knowledge Hub events use BRONZE color (0xFFCD7F32)');

      if (events.isNotEmpty) {
        debugPrint('\n📋 Knowledge Hub Events List:');
        for (var i = 0; i < events.length; i++) {
          final event = events[i];
          debugPrint('   ${i + 1}. [${event.status}] ${event.taskName} - ${event.description} on ${event.date}');
        }
      }

    } catch (e, stackTrace) {
      debugPrint('❌ FATAL ERROR in getKnowledgeHubCalendarEvents: $e');
      debugPrint('Stack: $stackTrace');
    }

    return events;
  }

  /// Get all calendar events from Services module
  /// All Services events use BLUE color (0xFF0095FF)
  /// Get all calendar events from Services module
  /// All Services events use BLUE color (0xFF0095FF)
  /// Get all calendar events from Services module
  /// All Services events use BLUE color (0xFF0095FF)
  /// Get all calendar events from Services module
  /// All Services events use BLUE color (0xFF0095FF)
  /// Get all calendar events from Services module
  /// All Services events use BLUE color (0xFF0095FF)
  Future<List<CalendarEventModel>> getServicesCalendarEvents({
    required String currentUserEmail,
  }) async
  {
    print('\n🔍 ========== FETCHING SERVICES CALENDAR EVENTS ==========');
    print('📧 Current user email: $currentUserEmail');

    if (currentUserEmail.isEmpty) {
      print('❌ ERROR: User email is empty');
      return [];
    }

    List<CalendarEventModel> events = [];

    try {
      final companyId = ApiConstants.baseUri.split("/").last;
      print('🏢 Company ID: $companyId');

      final snapshot = await FirebaseFirestore.instance
          .collection('Demo')
          .doc(companyId)
          .collection('RequestServices')
          .get();

      print('📊 Total documents in RequestServices: ${snapshot.docs.length}');

      final now = DateTime.now();

      // ✅ Get current locale to determine language
      final currentLocale = Get.locale?.languageCode ?? 'en';
      final isArabic = currentLocale == 'ar';

      print('🌍 Current locale: $currentLocale');
      print('🌍 Is Arabic mode: $isArabic');

      // ✅ Get main core controllers
      final mainCoreController = Get.find<MainCoreEmployeeController>();
      final departmentController = Get.find<MainCoreDepartmentController>();

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final model = ServicesHistoryModel.fromJson(data, doc.id);

          print('\n📄 Processing service: ${model.currentServiceNameEnglish}');
          print('   Request ID: ${doc.id}');

          // ✅ Get service names in both languages
          final serviceNameEnglish = model.currentServiceNameEnglish.isNotEmpty
              ? model.currentServiceNameEnglish
              : 'Service';

          final serviceNameArabic = model.currentServiceNameArabic.isNotEmpty
              ? model.currentServiceNameArabic
              : 'خدمة';

          // ✅ Create bilingual task name
          final taskName = '$serviceNameEnglish / $serviceNameArabic';

          print('   Service Name (EN): $serviceNameEnglish');
          print('   Service Name (AR): $serviceNameArabic');
          print('   Bilingual Task Name: $taskName');

          // Get final state
          final state = _getFinalStateFromModel(model);
          print('   Final State: $state');

          // Get user involvement
          final assignedEmail = model.currentAssignedProviderEmail.toLowerCase().trim();
          final requesterEmails = model.currentEmailRequester;
          final isAssignedToUser = assignedEmail == currentUserEmail.toLowerCase().trim();
          final isRequestedByUser = requesterEmails.contains(currentUserEmail.toLowerCase().trim());

          print('   Assigned to: $assignedEmail');
          print('   Requester emails: $requesterEmails');
          print('   Is Assigned to User: $isAssignedToUser');
          print('   Is Requested by User: $isRequestedByUser');

          // ✅ Get provider and requester details for manager check
          final providerEmployee = mainCoreController.getLocaleEmployee(assignedEmail);
          final requesterEmail = requesterEmails.isNotEmpty ? requesterEmails.toLowerCase().trim() : '';
          final requesterEmployee = requesterEmail.isNotEmpty
              ? mainCoreController.getLocaleEmployee(requesterEmail)
              : null;

          // ✅ Check if current user is Middle Management in relevant departments
          bool isMiddleManagementForService = false;
          String managerDepartment = '';

          final currentEmployee = mainCoreController.getLocaleEmployee(currentUserEmail);
          if (currentEmployee != null && currentEmployee.role?.toLowerCase() == 'middle management') {
            if (providerEmployee != null &&
                currentEmployee.departmentId == providerEmployee.departmentId) {
              isMiddleManagementForService = true;
              managerDepartment = currentEmployee.departmentId ?? '';
              print('   ✅ Current user is Middle Management for provider department');
            } else if (requesterEmployee != null &&
                currentEmployee.departmentId == requesterEmployee.departmentId) {
              isMiddleManagementForService = true;
              managerDepartment = currentEmployee.departmentId ?? '';
              print('   ✅ Current user is Middle Management for requester department');
            }
          }

          // Skip if not relevant to current user
          if (!isAssignedToUser && !isRequestedByUser && !isMiddleManagementForService) {
            print('   ⏭️ SKIP: Not relevant to current user');
            continue;
          }

          // ✅ Get timestamps array
          final timestampsArray = data['timestamps'] as List?;
          if (timestampsArray == null || timestampsArray.isEmpty) {
            print('   ⚠️ No timestamps found');
            continue;
          }

          // ✅ Get status history array to find when it moved to InProgress
          final statusHistoryArray = data['status'] as List?;

          print('   📊 Status History: $statusHistoryArray');
          print('   📊 Timestamps Array: $timestampsArray');

          // ✅ STAGE 1: APPROVED - Add "Assigned" card (for provider only)
          if (['approved', 'inprogress', 'done'].contains(state.toLowerCase())) {
            if (isAssignedToUser) {
              print('   ✅ Creating Assigned event (service was approved)');

              final approvedTimestamp = timestampsArray.first;
              final eventDate = DateTime.fromMillisecondsSinceEpoch(
                approvedTimestamp is int ? approvedTimestamp : int.parse(approvedTimestamp.toString()),
              );

              events.add(CalendarEventModel(
                date: eventDate,
                time: DateFormat('hh:mm a').format(eventDate),
                taskName: taskName,
                description: 'A service is assigned to you. Review and change status / خدمة معينة لك. راجع وغير الحالة',
                status: 'Assigned',
                moduleName: 'Services',
                color: const Color(0xFF0095FF),
              ));

              print('   ✅ Added Assigned event on $eventDate');
            }
          }

          // ✅ STAGE 2: INPROGRESS - Add "Due" card (for provider) and "In Progress" card (for requester)
          if (['inprogress', 'done'].contains(state.toLowerCase())) {
            print('   ✅ Processing InProgress stage (current or past)');

            DateTime? inProgressStartTime;
            DateTime? dueDate;

            // ✅ Find the ACTUAL timestamp when status changed to "InProgress"
            int? inProgressTimestampIndex;

            if (statusHistoryArray != null && statusHistoryArray.isNotEmpty) {
              // Find the index where status became "InProgress"
              for (int i = 0; i < statusHistoryArray.length; i++) {
                final status = statusHistoryArray[i].toString().toLowerCase();
                if (status == 'inprogress') {
                  inProgressTimestampIndex = i;
                  print('   ✅ Found InProgress status at index: $i');
                  break;
                }
              }
            }

            // If we found the InProgress status index, use that timestamp
            if (inProgressTimestampIndex != null &&
                timestampsArray.length > inProgressTimestampIndex) {
              final inProgressTimestamp = timestampsArray[inProgressTimestampIndex];
              inProgressStartTime = DateTime.fromMillisecondsSinceEpoch(
                inProgressTimestamp is int ? inProgressTimestamp : int.parse(inProgressTimestamp.toString()),
              );
              print('   ✅ InProgress Start Time (from status history): $inProgressStartTime');
            } else {
              // Fallback: use second timestamp if available
              if (timestampsArray.length >= 2) {
                final inProgressTimestamp = timestampsArray[1];
                inProgressStartTime = DateTime.fromMillisecondsSinceEpoch(
                  inProgressTimestamp is int ? inProgressTimestamp : int.parse(inProgressTimestamp.toString()),
                );
                print('   ⚠️ Using fallback timestamp (index 1): $inProgressStartTime');
              } else {
                print('   ❌ Cannot determine InProgress start time');
              }
            }

            if (inProgressStartTime != null) {
              // Calculate due date from InProgress start
              final durationArray = data['durationOfServices'] as List?;
              final durationUnitArray = data['selectedDurationUnit'] as List?;

              if (durationArray != null && durationArray.isNotEmpty &&
                  durationUnitArray != null && durationUnitArray.isNotEmpty) {
                final durationValue = int.tryParse(durationArray.first.toString()) ?? 0;
                final durationUnit = durationUnitArray.first.toString().toLowerCase();

                print('   📊 Service Duration: $durationValue $durationUnit');

                if (durationValue > 0) {
                  switch (durationUnit) {
                    case 'minutes':
                      dueDate = inProgressStartTime.add(Duration(minutes: durationValue));
                      break;
                    case 'hours':
                      dueDate = inProgressStartTime.add(Duration(hours: durationValue));
                      break;
                    case 'days':
                      dueDate = inProgressStartTime.add(Duration(days: durationValue));
                      break;
                    case 'weeks':
                      dueDate = inProgressStartTime.add(Duration(days: durationValue * 7));
                      break;
                    case 'months':
                      dueDate = DateTime(
                        inProgressStartTime.year,
                        inProgressStartTime.month + durationValue,
                        inProgressStartTime.day,
                        inProgressStartTime.hour,
                        inProgressStartTime.minute,
                      );
                      break;
                    default:
                      dueDate = inProgressStartTime.add(Duration(hours: durationValue));
                  }

                  print('   ✅ Calculated Due Date: $dueDate');
                  print('   📊 InProgress Start: $inProgressStartTime');
                  print('   📊 Duration added: $durationValue $durationUnit');
                }
              }

              // ✅ Add Due event for provider
              if (isAssignedToUser && dueDate != null) {
                print('   ✅ Creating Due event for provider');

                final dueDateStr = DateFormat('MMM dd, yyyy hh:mm a').format(dueDate);

                events.add(CalendarEventModel(
                  date: dueDate,
                  time: DateFormat('hh:mm a').format(dueDate),
                  taskName: taskName,
                  description: 'The deadline for the assigned service is $dueDateStr. Kindly prioritize accordingly / الموعد النهائي للخدمة المخصصة هو $dueDateStr. يرجى تحديد الأولويات وفقًا لذلك',
                  status: 'Due',
                  moduleName: 'Services',
                  color: const Color(0xFF0095FF),
                ));

                print('   ✅ Added Due event on due date: $dueDate');
              }

              // ✅ Add "In Progress" event for REQUESTER
              if (isRequestedByUser && dueDate != null) {
                print('   ✅ Creating In Progress event for requester');

                final completionDateStr = DateFormat('MMM dd, yyyy hh:mm a').format(dueDate);

                events.add(CalendarEventModel(
                  date: inProgressStartTime,
                  time: DateFormat('hh:mm a').format(inProgressStartTime),
                  taskName: taskName,
                  description: 'Your service is in progress and is expected to be completed by $completionDateStr / خدمتك قيد التنفيذ ومن المتوقع إكمالها بحلول $completionDateStr',
                  status: 'In Progress',
                  moduleName: 'Services',
                  color: const Color(0xFF0095FF),
                ));

                print('   ✅ Added In Progress event for requester on $inProgressStartTime');
              }

              // ✅ Check for SLA breach (only if InProgress)
              if (state.toLowerCase() == 'inprogress' && dueDate != null) {
                print('\n   🔍 Checking SLA breach...');
                print('   SLA Deadline: $dueDate');
                print('   Current Time: $now');
                print('   Is Past Deadline: ${now.isAfter(dueDate)}');

                if (now.isAfter(dueDate)) {
                  print('   🚨 SLA BREACH DETECTED! Adding SLA cards');

                  final period = dueDate.hour >= 12 ? 'PM' : 'AM';
                  final displayHour = dueDate.hour > 12
                      ? dueDate.hour - 12
                      : (dueDate.hour == 0 ? 12 : dueDate.hour);
                  final displayTime =
                      '${displayHour.toString().padLeft(2, '0')}:${dueDate.minute.toString().padLeft(2, '0')} $period';

                  // Add SLA card for provider
                  if (isAssignedToUser) {
                    print('   ✅ Adding SLA card for PROVIDER');
                    events.add(CalendarEventModel(
                      date: dueDate,
                      time: displayTime,
                      taskName: taskName,
                      description: 'Service has reached SLA threshold. Immediate action required / الخدمة وصلت حد SLA. مطلوب إجراء فوري',
                      status: 'SLA',
                      moduleName: 'Services',
                      color: const Color(0xFF0095FF),
                    ));
                  }

                  // Add SLA card for requester
                  if (isRequestedByUser) {
                    print('   ✅ Adding SLA card for REQUESTER');
                    events.add(CalendarEventModel(
                      date: dueDate,
                      time: displayTime,
                      taskName: taskName,
                      description: 'Your service request exceeded SLA timeframe and is overdue / طلب الخدمة تجاوز الإطار الزمني لـ SLA ومتأخر',
                      status: 'SLA',
                      moduleName: 'Services',
                      color: const Color(0xFF0095FF),
                    ));
                  }

                  // Add SLA card for middle management
                  if (isMiddleManagementForService && !isAssignedToUser && !isRequestedByUser) {
                    print('   ✅ Adding SLA card for MIDDLE MANAGEMENT');

                    String departmentName = departmentController.getDepartmentName(managerDepartment, true);
                    String departmentNameAr = departmentController.getDepartmentName(managerDepartment, false);

                    events.add(CalendarEventModel(
                      date: dueDate,
                      time: displayTime,
                      taskName: taskName,
                      description: 'Service under your supervision ($departmentName) breached SLA. Immediate attention required / خدمة تحت إشرافك ($departmentNameAr) تجاوزت SLA. مطلوب اهتمام فوري',
                      status: 'SLA',
                      moduleName: 'Services',
                      color: const Color(0xFF0095FF),
                    ));
                  }

                  print('   ✅ Added SLA breach cards');
                } else {
                  print('   ✅ Service is within SLA time - no breach');
                }
              }
            }
          }

          // ✅ STAGE 3: DONE - Add "Done" card (for requester only)
          if (state.toLowerCase() == 'done') {
            if (isRequestedByUser) {
              print('   ✅ Creating Done event');

              final doneTimestamp = timestampsArray.last;
              final eventDate = DateTime.fromMillisecondsSinceEpoch(
                doneTimestamp is int ? doneTimestamp : int.parse(doneTimestamp.toString()),
              );

              // ✅ Check if service exceeded SLA before being marked as Done
              bool exceededSLA = false;

              // Calculate if done timestamp is after the due date
              if (statusHistoryArray != null && statusHistoryArray.isNotEmpty) {
                // Find InProgress timestamp index
                int? inProgressTimestampIndex;
                for (int i = 0; i < statusHistoryArray.length; i++) {
                  final status = statusHistoryArray[i].toString().toLowerCase();
                  if (status == 'inprogress') {
                    inProgressTimestampIndex = i;
                    break;
                  }
                }

                if (inProgressTimestampIndex != null &&
                    timestampsArray.length > inProgressTimestampIndex) {
                  final inProgressTimestamp = timestampsArray[inProgressTimestampIndex];
                  final inProgressStartTime = DateTime.fromMillisecondsSinceEpoch(
                    inProgressTimestamp is int ? inProgressTimestamp : int.parse(inProgressTimestamp.toString()),
                  );

                  // Calculate due date
                  final durationArray = data['durationOfServices'] as List?;
                  final durationUnitArray = data['selectedDurationUnit'] as List?;

                  if (durationArray != null && durationArray.isNotEmpty &&
                      durationUnitArray != null && durationUnitArray.isNotEmpty) {
                    final durationValue = int.tryParse(durationArray.first.toString()) ?? 0;
                    final durationUnit = durationUnitArray.first.toString().toLowerCase();

                    if (durationValue > 0) {
                      DateTime? calculatedDueDate;

                      switch (durationUnit) {
                        case 'minutes':
                          calculatedDueDate = inProgressStartTime.add(Duration(minutes: durationValue));
                          break;
                        case 'hours':
                          calculatedDueDate = inProgressStartTime.add(Duration(hours: durationValue));
                          break;
                        case 'days':
                          calculatedDueDate = inProgressStartTime.add(Duration(days: durationValue));
                          break;
                        case 'weeks':
                          calculatedDueDate = inProgressStartTime.add(Duration(days: durationValue * 7));
                          break;
                        case 'months':
                          calculatedDueDate = DateTime(
                            inProgressStartTime.year,
                            inProgressStartTime.month + durationValue,
                            inProgressStartTime.day,
                            inProgressStartTime.hour,
                            inProgressStartTime.minute,
                          );
                          break;
                        default:
                          calculatedDueDate = inProgressStartTime.add(Duration(hours: durationValue));
                      }

                      // Check if done timestamp is after due date
                      if (calculatedDueDate != null && eventDate.isAfter(calculatedDueDate)) {
                        exceededSLA = true;
                        print('   🚨 Service was completed AFTER SLA deadline');
                        print('   📊 Due Date: $calculatedDueDate');
                        print('   📊 Done Date: $eventDate');
                      }
                    }
                  }
                }
              }

              // ✅ Create description based on whether SLA was exceeded
              String description;
              if (exceededSLA) {
                description = isArabic
                    ? 'تجاوزت الخدمة مدة اتفاقية مستوى الخدمة المعتمدة وتم إغلاقها الآن كمنتهية'
                    : 'The service exceeded the approved SLA duration and is now closed as Done';
                print('   ✅ Using SLA-exceeded message');
              } else {
                description = isArabic
                    ? 'طلبك - منتهي'
                    : 'Your request - Done';
                print('   ✅ Using normal Done message');
              }

              events.add(CalendarEventModel(
                date: eventDate,
                time: DateFormat('hh:mm a').format(eventDate),
                taskName: taskName,
                description: description,
                status: 'Done',
                moduleName: 'Services',
                color: const Color(0xFF0095FF),
              ));

              print('   ✅ Added Done event on $eventDate');
            }
          }

        } catch (e) {
          print('   ❌ Error processing document ${doc.id}: $e');
          continue;
        }
      }

      print('\n✅ Total Services events found: ${events.length}');
      print('🎨 All Services events use BLUE color (0xFF0095FF)');

      if (events.isNotEmpty) {
        print('\n📋 Services Events List:');
        for (var i = 0; i < events.length; i++) {
          final event = events[i];
          print('   ${i + 1}. [${event.status}] ${event.taskName} on ${event.date}');
        }
      }

    } catch (e, stackTrace) {
      print('❌ ERROR fetching services calendar events: $e');
      print('Stack trace: $stackTrace');
    }

    print('========== SERVICES CALENDAR EVENTS FETCH COMPLETE ==========\n');
    return events;
  }

  // Helper methods
  String _getFinalStateFromModel(ServicesHistoryModel service) {
    final stateField = service.currentState.toLowerCase();

    if (['cancel', 'inprogress', 'done', 'branchsla', 'breached sla'].contains(stateField)) {
      return stateField;
    }

    final approvalCycle = service.currentApprovalCycle;
    final hasApprovalCycle = approvalCycle.isNotEmpty;

    if (!hasApprovalCycle) {
      if (stateField.isEmpty || stateField == 'pending') {
        return 'approved';
      }
      return stateField.isEmpty ? 'approved' : stateField;
    }

    final states = approvalCycle
        .where((e) => e.state != null && e.state!.isNotEmpty)
        .map((e) => e.state!.toLowerCase())
        .toList();

    if (states.contains('cancel')) return 'cancel';
    if (states.contains('rejected')) return 'rejected';
    if (states.every((s) => s == 'approved') && states.isNotEmpty) return 'approved';
    if (states.contains('pending')) return 'pending';

    if (stateField.isNotEmpty) {
      return stateField;
    }

    return 'approved';
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String? _getArrayValue(dynamic field) {
    if (field == null) return null;
    if (field is List && field.isNotEmpty) {
      return field.first?.toString();
    }
    if (field is String) return field;
    return field.toString();
  }
}
/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_data_service_methods_5.dart
/// Description: Methods of `CalendarDataService` — split out of `calendar_data_service.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../calendar_data_service.dart';

// Split from calendar_data_service.dart to keep every file under 700 lines.

extension CalendarDataServiceMethods5 on CalendarDataService {
  /// Get all calendar events from Knowledge Hub module
  /// All Knowledge Hub events use BRONZE color (0xFFCD7F32)
  Future<List<CalendarEventModel>> getKnowledgeHubCalendarEvents({
    required String currentUserEmail,
  }) async {
    List<CalendarEventModel> events = [];

    try {
      String companyIdPath = getBaseUrl('');
      String companyId = '';
      if (companyIdPath.contains('/')) {
        final parts = companyIdPath.split('/');
        if (parts.length >= 2) {
          companyId = parts[1];
        }
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Card text now comes from KnowledgeHubCalendarEvent, which is
      // bilingual, so the builder needs to know which language to render.
      // Previously every card glued the two languages together with ' / '
      // and showed both to everyone.
      final isArabic = languageCode() == 'ar';

      // ========================================
      // PART 1: GET SCHEDULED DOCUMENTS (startDateTime in future)
      // ========================================
      try {
        final scheduledSnapshot = await _firestore
            .collection(FirebaseCollections.demo)
            .doc(companyId)
            .collection(FirebaseCollections.createKnowledge)
            .get()
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Scheduled query timeout');
          },
        );

        for (var doc in scheduledSnapshot.docs) {
          try {
            final data = doc.data();

            // Get startDateTime
            final startDateTimeArray = data['startDateTime'] as List?;
            if (startDateTimeArray == null || startDateTimeArray.isEmpty) {
              continue;
            }

            final startTimestamp = startDateTimeArray.first;
            final startDateTime = DateTime.fromMillisecondsSinceEpoch(
              startTimestamp is int
                  ? startTimestamp
                  : int.parse(startTimestamp.toString()),
            );

            final startDateOnly = DateTime(
              startDateTime.year,
              startDateTime.month,
              startDateTime.day,
            );

            // ✅ Check if startDateTime is in the FUTURE
            if (startDateOnly.isAfter(today)) {
              // ✅ Get document names in both languages
              final nameEnglishArray = data['nameEnglish'] as List?;
              final nameArabicArray = data['nameArabic'] as List?;

              final nameEnglish =
                  (nameEnglishArray != null && nameEnglishArray.isNotEmpty)
                      ? nameEnglishArray.first.toString()
                      : 'Knowledge Document';

              final nameArabic =
                  (nameArabicArray != null && nameArabicArray.isNotEmpty)
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

              events.add(
                CalendarEventModel.fromType(
                  KnowledgeHubCalendarEvent.documentScheduled,
                  sourceDate: startDateTime,
                  isArabic: isArabic,
                  taskName: taskName,
                  time: displayTime,
                ),
              );
            } else {}
          } catch (e) {
            debugPrint('Ignored error: $e');
          }
        }
      } catch (e) {
        debugPrint('Ignored error: $e');
      }

      // ========================================
      // PART 2: GET EXPIRING SOON & REMINDERS (endDateTime)
      // ========================================
      try {
        final expiringSnapshot = await _firestore
            .collection(FirebaseCollections.demo)
            .doc(companyId)
            .collection(FirebaseCollections.createKnowledge)
            .get()
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Expiring query timeout');
          },
        );

        for (var doc in expiringSnapshot.docs) {
          try {
            final data = doc.data();

            // Get endDateTime
            final endDateTimeArray = data['endDateTime'] as List?;
            if (endDateTimeArray == null || endDateTimeArray.isEmpty) {
              continue;
            }

            final endTimestamp = endDateTimeArray.first;
            final endDateTime = DateTime.fromMillisecondsSinceEpoch(
              endTimestamp is int
                  ? endTimestamp
                  : int.parse(endTimestamp.toString()),
            );

            final endDateOnly = DateTime(
              endDateTime.year,
              endDateTime.month,
              endDateTime.day,
            );

            final daysUntilEnd = endDateOnly.difference(today).inDays;

            // Skip if already expired (past dates)
            if (daysUntilEnd < 0) {
              continue;
            }

            // ✅ Get document names in both languages FIRST
            final nameEnglishArray = data['nameEnglish'] as List?;
            final nameArabicArray = data['nameArabic'] as List?;

            final nameEnglish =
                (nameEnglishArray != null && nameEnglishArray.isNotEmpty)
                    ? nameEnglishArray.first.toString()
                    : 'Knowledge Document';

            final nameArabic =
                (nameArabicArray != null && nameArabicArray.isNotEmpty)
                    ? nameArabicArray.first.toString()
                    : 'وثيقة معرفية';

            // ✅ Create bilingual task name
            final taskName = '$nameEnglish / $nameArabic';

            // ✅ Determine which catalog entry applies, based on how far
            // away the end date is. Both sit ON the end date — the window
            // only decides which bucket (and therefore which filter chip)
            // the card belongs to. See the header of
            // knowledge_hub_calendar_events.dart for why the 14-day
            // reminder is not shifted two weeks earlier.
            final expiryEntry = daysUntilEnd > 14
                ? KnowledgeHubCalendarEvent.documentExpiringSoon
                : KnowledgeHubCalendarEvent.documentValidityExpiring;

            // Format time
            final period = endDateTime.hour >= 12 ? 'PM' : 'AM';
            final displayHour = endDateTime.hour > 12
                ? endDateTime.hour - 12
                : (endDateTime.hour == 0 ? 12 : endDateTime.hour);
            final displayTime =
                '${displayHour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')} $period';

            events.add(
              CalendarEventModel.fromType(
                expiryEntry,
                sourceDate: endDateTime,
                isArabic: isArabic,
                taskName: taskName,
                time: displayTime,
              ),
            );
          } catch (e) {
            debugPrint('Ignored error: $e');
          }
        }
      } catch (e) {
        debugPrint('Ignored error: $e');
      }

      // ========================================
      // PART 3: GET PENDING APPROVALS (Supervisor check)
      // ========================================
      try {
        // Get all pending approval documents
        final pendingSnapshot = await _firestore
            .collection(FirebaseCollections.demo)
            .doc(companyId)
            .collection(FirebaseCollections.createKnowledge)
            .get()
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Pending approvals query timeout');
          },
        );


        for (var doc in pendingSnapshot.docs) {
          try {
            final data = doc.data();

            // Get status array and check LATEST status
            final statusArray = data['status'] as List?;
            if (statusArray == null || statusArray.isEmpty) {
              continue;
            }

            // ✅ Get LATEST status (last element)
            final latestStatus = statusArray.last.toString().toLowerCase();

            // Only process if status is pending_approval
            if (latestStatus != 'pending_approval') {
              continue;
            }

            // Get creator email
            final createdByEmailArray = data['createdByEmail'] as List?;
            if (createdByEmailArray == null || createdByEmailArray.isEmpty) {
              continue;
            }

            final creatorEmail = createdByEmailArray.first.toString();

            // Get creator's employee data to find their supervisor
            final mainCoreController = currentEmployee();
            final creatorEmployee = mainCoreController.getLocaleEmployee(
              creatorEmail,
            );

            if (creatorEmployee == null) {
              continue;
            }

            // Get creator's supervisor email
            final creatorSupervisorEmail =
                creatorEmployee.supervisor?.trim().toLowerCase();

            if (creatorSupervisorEmail == null ||
                creatorSupervisorEmail.isEmpty) {
              continue;
            }

            final currentUserEmailNormalized =
                currentUserEmail.trim().toLowerCase();

            // Check if current user is the supervisor
            bool isCurrentUserSupervisor =
                creatorSupervisorEmail == currentUserEmailNormalized;

            // Also check if user is super admin or has Knowledge Hub admin permission
            bool isSuperAdmin = mainCoreController.isSuperAdmin();
            bool hasKnowledgeHubAdminPermission = false;

            try {
              hasKnowledgeHubAdminPermission =
                  mainCoreController.hasSpecificPermission(
                        Modules.knowledgeHub,
                        'admin_access',
                      ) ||
                      mainCoreController.hasSpecificPermission(
                        Modules.knowledgeHub,
                        'approve_document',
                      );
            } catch (e) {
              debugPrint('Ignored error: $e');
            }

            bool shouldShowApproval = isCurrentUserSupervisor ||
                isSuperAdmin ||
                hasKnowledgeHubAdminPermission;

            if (!shouldShowApproval) {
              continue;
            }

            // Get submission date (use latest timestamp)
            final timestampsArray = data['timestamps'] as List?;
            DateTime? submissionDate;

            if (timestampsArray != null && timestampsArray.isNotEmpty) {
              final latestTimestamp = timestampsArray.last;
              submissionDate = DateTime.fromMillisecondsSinceEpoch(
                latestTimestamp is int
                    ? latestTimestamp
                    : int.parse(latestTimestamp.toString()),
              );
            }

            if (submissionDate == null) {
              continue;
            }

            String approvalType = 'Supervisor';
            if (isSuperAdmin) approvalType = 'Super Admin';
            if (hasKnowledgeHubAdminPermission) {
              approvalType = 'Knowledge Hub Admin';
            }

            // ✅ Get document names in both languages
            final nameEnglishArray = data['nameEnglish'] as List?;
            final nameArabicArray = data['nameArabic'] as List?;

            final nameEnglish =
                (nameEnglishArray != null && nameEnglishArray.isNotEmpty)
                    ? nameEnglishArray.first.toString()
                    : 'Knowledge Document';

            final nameArabic =
                (nameArabicArray != null && nameArabicArray.isNotEmpty)
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

            events.add(
              CalendarEventModel.fromType(
                KnowledgeHubCalendarEvent.approvalPending,
                sourceDate: submissionDate,
                isArabic: isArabic,
                taskName: taskName,
                time: displayTime,
                // Which hat the signed-in user is wearing for this approval —
                // Supervisor / Super Admin / Knowledge Hub Admin. Carried as
                // roleName because that is exactly what it is.
                variables: {TemplateVariable.roleName: approvalType},
              ),
            );

          } catch (e) {
            debugPrint('Ignored error: $e');
          }
        }
      } catch (e) {
        debugPrint('Ignored error: $e');
      }

      // ========================================
      // PART 4: GET PUBLISHED DOCUMENTS (immediate)
      // ========================================
      //
      // ADDED 1/9/2026 — the first row of the Knowledge Hub block in §2 of
      // "Knowticed Plus — Notification & Validation":
      //
      //   Document Published (immediate) → "Document Published and Effective"
      //   "Appears on calendar immediately upon publication. Expiry date is
      //    visible if an End Date is set."
      //
      // `KnowledgeHubCalendarEvent.documentPublished` has existed since the
      // module was migrated onto the calendar enums, and nothing built an
      // occurrence from it: PART 1 covers documents still WAITING to be
      // published, PART 2 their expiry and PART 3 the approval queue, so the
      // one moment the spec puts first — the document going live — was the
      // one moment missing from the calendar. A published policy simply never
      // appeared on the day it took effect.
      //
      // The card is placed on the publication date, which is the FIRST
      // `published` entry in the status history (`publishedAt` on the model
      // uses the same rule) rather than the document's `startDateTime`: an
      // unscheduled document has a start date of "whenever it was created",
      // and a document approved late went live after its planned start.
      try {
        final publishedSnapshot = await _firestore
            .collection(FirebaseCollections.demo)
            .doc(companyId)
            .collection(FirebaseCollections.createKnowledge)
            .get()
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Published query timeout');
          },
        );

        for (var doc in publishedSnapshot.docs) {
          try {
            final data = doc.data();

            // Only documents that are live RIGHT NOW. A document that was
            // published and later removed or archived should not keep
            // advertising itself as effective.
            final statusArray = List<dynamic>.from(data['status'] ?? []);
            if (statusArray.isEmpty) continue;
            final currentStatus =
                statusArray.last.toString().toLowerCase().trim();
            if (currentStatus != 'published') continue;

            // The date it BECAME published — the first 'published' in the
            // history, paired with the timestamp recorded alongside it.
            final publishedIndex = statusArray.indexWhere(
              (s) => s.toString().toLowerCase().trim() == 'published',
            );
            if (publishedIndex == -1) continue;

            final timestampsArray = List<dynamic>.from(
              data['timestamps'] ?? [],
            );
            if (publishedIndex >= timestampsArray.length) continue;

            final rawTimestamp = timestampsArray[publishedIndex];
            final publishedAt = DateTime.fromMillisecondsSinceEpoch(
              rawTimestamp is int
                  ? rawTimestamp
                  : int.parse(rawTimestamp.toString()),
            );

            final nameEnglishArray = data['nameEnglish'] as List?;
            final nameArabicArray = data['nameArabic'] as List?;

            final nameEnglish =
                (nameEnglishArray != null && nameEnglishArray.isNotEmpty)
                    ? nameEnglishArray.first.toString()
                    : 'Knowledge Document';

            final nameArabic =
                (nameArabicArray != null && nameArabicArray.isNotEmpty)
                    ? nameArabicArray.first.toString()
                    : 'وثيقة معرفية';

            final taskName = '$nameEnglish / $nameArabic';

            final period = publishedAt.hour >= 12 ? 'PM' : 'AM';
            final displayHour = publishedAt.hour > 12
                ? publishedAt.hour - 12
                : (publishedAt.hour == 0 ? 12 : publishedAt.hour);
            final displayTime =
                '${displayHour.toString().padLeft(2, '0')}:${publishedAt.minute.toString().padLeft(2, '0')} $period';

            events.add(
              CalendarEventModel.fromType(
                KnowledgeHubCalendarEvent.documentPublished,
                sourceDate: publishedAt,
                isArabic: isArabic,
                taskName: taskName,
                time: displayTime,
              ),
            );
          } catch (e) {
            debugPrint('Ignored error: $e');
          }
        }
      } catch (e) {
        debugPrint('Ignored error: $e');
      }
    } catch (e) {
      debugPrint('Ignored error: $e');
    }

    return events;
  }
}

/// *********************** FILE INFO ***********************
/// File Name: get_tasks_status_use_case.dart
/// Author: Mohamed Elrashidy
/// Created At: 8/5/2025
/// Updated: Fixed late status calculation - late period starts BEFORE deadline
library;

import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/qiyas_champion_entity.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/entities/task_overview.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champion_tasks/data/repository/champigan_tasks_repository.dart';

class GetTasksStatusUseCase {
  ChampiganTasksRepository ownerTasksRepository;

  GetTasksStatusUseCase({required this.ownerTasksRepository});

  /// Function Name: [execute]
  ///
  /// Purpose: Fetches and processes task statuses with proper late status calculation
  ///
  /// Late Status Logic (FIXED):
  /// - Late period STARTS: submission_deadline - late_unit_multiplier
  /// - Example: Deadline Jan 20, Late period 14 days → Late starts Jan 6
  /// - Timeline:
  ///   * Before Jan 6: "Uncompleted" (normal)
  ///   * Jan 6 - Jan 20: "Late" (warning: less than 14 days left!)
  ///   * After Jan 20: Still "Late" if not submitted
  ///
  /// Parameters:
  /// - [criteriaNumbers]: List of champion tasks
  /// - [champiganId]: Champion's email ID
  ///
  /// Returns: Map of EvidenceSubmissionStatus to List of TaskOverview
  Future<Either<Failure, dynamic>> execute({
    required List<QiyasChampionEntity> criteriaNumbers,
    required String champiganId,
  }) async {
    debugPrint('\n🔍 === GET TASKS STATUS USE CASE (Champion) ===');
    debugPrint('Champion ID: $champiganId');
    debugPrint('Processing ${criteriaNumbers.length} tasks...\n');

    // Fetch submission statuses from repository
    var response = await ownerTasksRepository.getTasksStatus(
      criteriaNumbers: criteriaNumbers.map((e) => e.criteriaId.trim()).toList(),
      evidenceNumber:
          criteriaNumbers.map((e) => e.documentNumber.trim()).toList(),
      champiganId: champiganId,
    );

    if (response.isLeft()) {
      debugPrint('❌ Failed to fetch tasks status');
      return response;
    }

    List<EvidenceSubmissionModel?> evidenceSubmissions =
        response.fold((_) => List<EvidenceSubmissionModel?>.from([]), (r) => r);

    debugPrint(
        '📥 Received ${evidenceSubmissions.length} evidence submissions\n');

    List<TaskOverview> taskOverviews = [];
    DateTime now = DateTime.now();
    debugPrint('⏰ Current DateTime: $now');
    debugPrint('⏰ Current DateTime (full): ${now.toString()}\n');

    // Process each task and determine its status
    for (int i = 0; i < criteriaNumbers.length; i++) {
      QiyasChampionEntity task = criteriaNumbers[i];
      EvidenceSubmissionModel? submission = evidenceSubmissions[i];

      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📋 Processing Task #${i + 1}:');
      debugPrint('   Criteria: ${task.criteriaId}');
      debugPrint('   Evidence: ${task.documentNumber}');
      debugPrint('   Submission Deadline: ${task.documentSubmissionDate}');
      debugPrint(
          '   Submission Deadline (full): ${task.documentSubmissionDate.toString()}');
      debugPrint('   Has Submission: ${submission != null}');

      // Determine initial status
      EvidenceSubmissionStatus status =
          submission?.submissionStatus ?? EvidenceSubmissionStatus.unCompleted;

      debugPrint('   📊 Initial Status: ${status.value}');
      debugPrint('');

      // ✅ CALCULATE LATE STATUS
      debugPrint('   🕐 LATE PERIOD CALCULATION:');
      debugPrint('   ────────────────────────────────────────────────────');

      // Calculate late start date
      DateTime lateStartDate = task.documentSubmissionDate.subtract(
        task.lateUnit.subtractValue(task.lateUnitMultiplier),
      );

      debugPrint('   Late Unit: ${task.lateUnit.name}');
      debugPrint('   Late Multiplier: ${task.lateUnitMultiplier}');
      debugPrint('   Late Start Date (calculated): $lateStartDate');
      debugPrint('   Late Start Date (full): ${lateStartDate.toString()}');
      debugPrint('');

      // NORMALIZE DATES (remove time component)
      DateTime nowDate = DateTime(now.year, now.month, now.day);
      DateTime lateStartDateOnly =
          DateTime(lateStartDate.year, lateStartDate.month, lateStartDate.day);
      DateTime deadlineDateOnly = DateTime(task.documentSubmissionDate.year,
          task.documentSubmissionDate.month, task.documentSubmissionDate.day);

      debugPrint('   📅 NORMALIZED DATES (date only, no time):');
      debugPrint('   ────────────────────────────────────────────────────');
      debugPrint('   Current Date (normalized): $nowDate');
      debugPrint('   Late Start (normalized): $lateStartDateOnly');
      debugPrint('   Deadline (normalized): $deadlineDateOnly');
      debugPrint('');

      // COMPARISONS
      debugPrint('   🔍 DATE COMPARISONS:');
      debugPrint('   ────────────────────────────────────────────────────');

      bool isAfterLateStart = nowDate.isAfter(lateStartDateOnly);
      bool isSameAsLateStart = nowDate.isAtSameMomentAs(lateStartDateOnly);
      bool isInLatePeriod = isAfterLateStart || isSameAsLateStart;

      debugPrint('   nowDate.isAfter(lateStartDateOnly): $isAfterLateStart');
      debugPrint(
          '   nowDate.isAtSameMomentAs(lateStartDateOnly): $isSameAsLateStart');
      debugPrint('   ➜ Is in late period? $isInLatePeriod');
      debugPrint('');

      bool isAfterDeadline = nowDate.isAfter(deadlineDateOnly);
      bool isSameAsDeadline = nowDate.isAtSameMomentAs(deadlineDateOnly);
      bool isPastDeadline = isAfterDeadline || isSameAsDeadline;

      debugPrint('   nowDate.isAfter(deadlineDateOnly): $isAfterDeadline');
      debugPrint(
          '   nowDate.isAtSameMomentAs(deadlineDateOnly): $isSameAsDeadline');
      debugPrint('   ➜ Is past deadline? $isPastDeadline');
      debugPrint('');

      // DECISION LOGIC
      debugPrint('   ⚙️  DECISION LOGIC:');
      debugPrint('   ────────────────────────────────────────────────────');
      debugPrint('   Current status: ${status.value}');
      debugPrint(
          '   Is uncompleted? ${status == EvidenceSubmissionStatus.unCompleted}');
      debugPrint(
          '   Is rejected? ${status == EvidenceSubmissionStatus.rejected}');
      debugPrint(
          '   Should check for late? ${status == EvidenceSubmissionStatus.unCompleted || status == EvidenceSubmissionStatus.rejected}');
      debugPrint(
          '   Is in late period OR past deadline? ${isInLatePeriod || isPastDeadline}');
      debugPrint('');

      // Mark as late if:
      // 1. (Current date >= late start date OR past deadline) AND
      // 2. Status is uncompleted or rejected
      if (isInLatePeriod || isPastDeadline) {
        if (status == EvidenceSubmissionStatus.unCompleted ||
            status == EvidenceSubmissionStatus.rejected) {
          debugPrint('   🔴 CHANGING STATUS TO LATE!');
          debugPrint(
              '   Reason: ${isInLatePeriod ? "In late period" : ""}${(isInLatePeriod && isPastDeadline) ? " AND " : ""}${isPastDeadline ? "Past deadline" : ""}');
          status = EvidenceSubmissionStatus.late;
        } else {
          debugPrint(
              '   ℹ️  NOT changing to late (status is ${status.value}, not uncompleted/rejected)');
        }
      } else {
        debugPrint('   ℹ️  NOT in late period yet');
      }
      debugPrint('');

      debugPrint('   ✅ FINAL STATUS: ${status.value}');
      debugPrint('═══════════════════════════════════════════════════════\n');

      // Create TaskOverview with the calculated status
      TaskOverview taskOverview = TaskOverview(
        deadLineDate: task.documentSubmissionDate,
        submissionDate: submission?.submissionDate?.toDate(),
        criteriaNumber: task.criteriaId.trim(),
        evidenceNumber: task.documentNumber.trim(),
        status: status,
      );

      taskOverviews.add(taskOverview);
    }

    // Group tasks by status
    Map<EvidenceSubmissionStatus, List<TaskOverview>> taskStatusMap = {};

    // Initialize all status categories
    for (EvidenceSubmissionStatus status in EvidenceSubmissionStatus.values) {
      taskStatusMap[status] = [];
    }

    // Add tasks to appropriate status lists
    for (var task in taskOverviews) {
      taskStatusMap[task.status]!.add(task);
      taskStatusMap[EvidenceSubmissionStatus.all]!.add(task);
    }

    // Print summary
    debugPrint('╔═══════════════════════════════════════════════════════╗');
    debugPrint('║           📊 TASK STATUS SUMMARY                      ║');
    debugPrint('╠═══════════════════════════════════════════════════════╣');
    taskStatusMap.forEach((status, tasks) {
      if (status != EvidenceSubmissionStatus.all && tasks.isNotEmpty) {
        String count = tasks.length.toString().padLeft(3);
        debugPrint('║   ${status.value.padRight(25)} │ $count tasks      ║');
      }
    });
    debugPrint('╠═══════════════════════════════════════════════════════╣');
    debugPrint(
        '║   ${'الكل (All)'.padRight(25)} │ ${taskStatusMap[EvidenceSubmissionStatus.all]!.length.toString().padLeft(3)} tasks      ║');
    debugPrint('╚═══════════════════════════════════════════════════════╝\n');

    return response = Right(taskStatusMap);
  }
}

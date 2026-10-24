/// Module: knowledge_hub/kh4_submissions/presentation/controller/submissions_cubit.part.2
///
///*************************** FILE INFO ****************************///
/// File Name: submissions_cubit_part2_methods.dart
/// Description: Methods of `SubmissionsCubit` — split out of `submissions_cubit.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../submissions_cubit.dart';

// Split from submissions_cubit.part.2.dart to keep every file under 700 lines.

mixin SubmissionsCubitPart2Methods2 on SubmissionsCubitBase {
  /// Filters by EXACT publish date and/or EXACT archive date (not ranges)
  @override
  void _applyDateFilters() {
    if (selectedStartDate == null && selectedEndDate == null) {
      return;
    }

    khLog('═══════════════════════════════════════', name: 'DateFilter');
    khLog('📅 [DATE FILTER] Starting EXACT date filter', name: 'DateFilter');
    khLog('   Filter Publish Date: $selectedStartDate', name: 'DateFilter');
    khLog('   Filter Archive Date: $selectedEndDate', name: 'DateFilter');
    khLog('═══════════════════════════════════════', name: 'DateFilter');

    int beforeCount = filteredKnowledge.length;
    int matchedCount = 0;
    int noPublishDateCount = 0;
    int noArchiveDateCount = 0;
    int notMatchingCount = 0;

    filteredKnowledge = filteredKnowledge.where((knowledge) {
      khLog(
        '\n🔍 Checking: ${knowledge.currentNameEnglish}',
        name: 'DateFilter',
      );

      // PUBLISH DATE = When document was published (from timestamps)
      DateTime? publishDate;

      if (knowledge.timestamps.isNotEmpty) {
        int publishTimestamp = knowledge.timestamps.first;
        publishDate = DateTime.fromMillisecondsSinceEpoch(publishTimestamp);
        khLog('   📅 Publish Date: $publishDate', name: 'DateFilter');
      } else {
        noPublishDateCount++;
        khLog('   ⚠️  No publish date (no timestamps)', name: 'DateFilter');
      }

      // ARCHIVE/END DATE = currentEndDateTime (expiry date)
      DateTime? archiveDate;

      try {
        if (knowledge.currentEndDateTime != null) {
          archiveDate = knowledge.currentEndDateTime!.toDate();
          khLog('   📅 Archive Date: $archiveDate', name: 'DateFilter');
        } else {
          noArchiveDateCount++;
          khLog('   ⚠️  No archive date set', name: 'DateFilter');
        }
      } catch (e) {
        khLog('   ❌ Error parsing archive date: $e', name: 'DateFilter');
      }

      // Normalize dates to start of day (remove time component)
      DateTime? normalizedPublishDate;
      DateTime? normalizedArchiveDate;
      DateTime? normalizedFilterPublish;
      DateTime? normalizedFilterArchive;

      if (publishDate != null) {
        normalizedPublishDate = DateTime(
          publishDate.year,
          publishDate.month,
          publishDate.day,
        );
      }

      if (archiveDate != null) {
        normalizedArchiveDate = DateTime(
          archiveDate.year,
          archiveDate.month,
          archiveDate.day,
        );
      }

      if (selectedStartDate != null) {
        normalizedFilterPublish = DateTime(
          selectedStartDate!.year,
          selectedStartDate!.month,
          selectedStartDate!.day,
        );
      }

      if (selectedEndDate != null) {
        normalizedFilterArchive = DateTime(
          selectedEndDate!.year,
          selectedEndDate!.month,
          selectedEndDate!.day,
        );
      }

      bool matchesFilter = true;

      // CASE 1: Filter by PUBLISH DATE only (EXACT match)
      if (selectedStartDate != null && selectedEndDate == null) {
        khLog('   🔍 Filtering by EXACT PUBLISH date', name: 'DateFilter');

        if (normalizedPublishDate != null) {
          // Must match EXACTLY
          bool exactMatch = normalizedPublishDate.isAtSameMomentAs(
            normalizedFilterPublish!,
          );

          if (!exactMatch) {
            matchesFilter = false;
            notMatchingCount++;
            khLog(
              '   ❌ REJECTED: Publish date doesn\'t match exactly',
              name: 'DateFilter',
            );
            khLog('      Document: $normalizedPublishDate', name: 'DateFilter');
            khLog('      Filter: $normalizedFilterPublish', name: 'DateFilter');
          } else {
            khLog(
              '   ✅ MATCH: Publish date matches exactly!',
              name: 'DateFilter',
            );
          }
        } else {
          matchesFilter = false;
          khLog('   ❌ REJECTED: No publish date', name: 'DateFilter');
        }
      }
      // CASE 2: Filter by ARCHIVE DATE only (EXACT match)
      else if (selectedStartDate == null && selectedEndDate != null) {
        khLog('   🔍 Filtering by EXACT ARCHIVE date', name: 'DateFilter');

        if (normalizedArchiveDate != null) {
          // Must match EXACTLY
          bool exactMatch = normalizedArchiveDate.isAtSameMomentAs(
            normalizedFilterArchive!,
          );

          if (!exactMatch) {
            matchesFilter = false;
            notMatchingCount++;
            khLog(
              '   ❌ REJECTED: Archive date doesn\'t match exactly',
              name: 'DateFilter',
            );
            khLog('      Document: $normalizedArchiveDate', name: 'DateFilter');
            khLog('      Filter: $normalizedFilterArchive', name: 'DateFilter');
          } else {
            khLog(
              '   ✅ MATCH: Archive date matches exactly!',
              name: 'DateFilter',
            );
          }
        } else {
          matchesFilter = false;
          khLog('   ❌ REJECTED: No archive date', name: 'DateFilter');
        }
      }
      // CASE 3: Filter by BOTH dates (BOTH must match EXACTLY)
      else if (selectedStartDate != null && selectedEndDate != null) {
        khLog(
          '   🔍 Filtering by BOTH PUBLISH and ARCHIVE dates (exact match)',
          name: 'DateFilter',
        );

        bool hasPublishDate = normalizedPublishDate != null;
        bool hasArchiveDate = normalizedArchiveDate != null;

        if (!hasPublishDate) {
          matchesFilter = false;
          khLog('   ❌ REJECTED: No publish date', name: 'DateFilter');
        } else if (!hasArchiveDate) {
          matchesFilter = false;
          khLog('   ❌ REJECTED: No archive date', name: 'DateFilter');
        } else {
          // Both dates must match EXACTLY
          bool publishMatches = normalizedPublishDate.isAtSameMomentAs(
            normalizedFilterPublish!,
          );
          bool archiveMatches = normalizedArchiveDate.isAtSameMomentAs(
            normalizedFilterArchive!,
          );

          if (!publishMatches) {
            matchesFilter = false;
            notMatchingCount++;
            khLog(
              '   ❌ REJECTED: Publish date doesn\'t match',
              name: 'DateFilter',
            );
            khLog('      Document: $normalizedPublishDate', name: 'DateFilter');
            khLog('      Filter: $normalizedFilterPublish', name: 'DateFilter');
          } else if (!archiveMatches) {
            matchesFilter = false;
            notMatchingCount++;
            khLog(
              '   ❌ REJECTED: Archive date doesn\'t match',
              name: 'DateFilter',
            );
            khLog('      Document: $normalizedArchiveDate', name: 'DateFilter');
            khLog('      Filter: $normalizedFilterArchive', name: 'DateFilter');
          } else {
            khLog('   ✅ MATCH: Both dates match exactly!', name: 'DateFilter');
            khLog(
              '      Publish: $normalizedPublishDate = $normalizedFilterPublish',
              name: 'DateFilter',
            );
            khLog(
              '      Archive: $normalizedArchiveDate = $normalizedFilterArchive',
              name: 'DateFilter',
            );
          }
        }
      }

      if (matchesFilter) {
        matchedCount++;
      }

      return matchesFilter;
    }).toList();

    khLog('\n═══════════════════════════════════════', name: 'DateFilter');
    khLog('📊 [DATE FILTER] SUMMARY:', name: 'DateFilter');
    khLog('   • Documents before filter: $beforeCount', name: 'DateFilter');
    khLog('   • Documents matched: $matchedCount', name: 'DateFilter');
    khLog(
      '   • Documents without publish date: $noPublishDateCount',
      name: 'DateFilter',
    );
    khLog(
      '   • Documents without archive date: $noArchiveDateCount',
      name: 'DateFilter',
    );
    khLog('   • Documents not matching: $notMatchingCount', name: 'DateFilter');
    khLog(
      '   • Documents after filter: ${filteredKnowledge.length}',
      name: 'DateFilter',
    );
    khLog('═══════════════════════════════════════\n', name: 'DateFilter');
  }
}

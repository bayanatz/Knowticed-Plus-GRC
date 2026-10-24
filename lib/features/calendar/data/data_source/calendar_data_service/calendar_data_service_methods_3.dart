/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_data_service_methods_3.dart
/// Description: Methods of `CalendarDataService` — split out of `calendar_data_service.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../calendar_data_service.dart';

// Split from calendar_data_service.dart to keep every file under 700 lines.

extension CalendarDataServiceMethods3 on CalendarDataService {
  /// All Qiyas events use GREY color (0xFF9FADAF)
  Future<List<CalendarEventModel>> getQiyasCalendarEvents({
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

      // ✅ Get current locale to determine language
      final currentLocale = languageCode();
      final isArabic = currentLocale == 'ar';

      // Get main core controller for employee details
      final mainCoreController = currentEmployee();

      await _addQiyasChampionAssignments(
        companyId,
        currentUserEmail,
        isArabic,
        events,
      );

      await _addQiyasSupervisorView(
        companyId,
        currentUserEmail,
        mainCoreController,
        isArabic,
        events,
      );

      await _addQiyasSupervisorApprovals(
        companyId,
        currentUserEmail,
        mainCoreController,
        isArabic,
        events,
      );

      await _addQiyasManagerApprovals(
        companyId,
        currentUserEmail,
        mainCoreController,
        isArabic,
        events,
      );
    } catch (e) {
      debugPrint('Ignored error: $e');
    }

    return events;
  }
}

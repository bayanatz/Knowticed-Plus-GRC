/// Module: Core · Helper · Main Helper · Flexible Date Parser
/// Description: Best-effort date parser accepting ISO-8601, dd/MM/yyyy,
///              yyyy-MM-dd, or epoch-millisecond strings. Extracted out of
///              settings pages so the try/catch chain no longer lives in UI
///              code (§11.2).
/// Author: Knowticed Team
/// Date: 01/07/2026
/// Dependencies: none
/// Revision History:
///   - 01/07/2026: Extracted from EditPageRequest._parseDate.
library;

///*************************** FILE INFO ****************************///
/// File Name: flexible_date_parser.dart
/// Purpose: Parse a date string that may arrive in several known formats.

/// Attempts to parse [dateString] as ISO-8601, dd/MM/yyyy, yyyy-MM-dd, or an
/// epoch-millisecond string, in that order. Returns `null` if none match.
DateTime? parseFlexibleDate(String? dateString) {
  if (dateString == null || dateString.trim().isEmpty) return null;

  final cleanedDate = dateString.trim();

  // Try ISO 8601 format first.
  final isoParsed = DateTime.tryParse(cleanedDate);
  if (isoParsed != null) return isoParsed;

  // Manual parsing for dd/MM/yyyy or d/M/yyyy format.
  if (cleanedDate.contains('/')) {
    final parts = cleanedDate.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null &&
          month != null &&
          year != null &&
          day >= 1 &&
          day <= 31 &&
          month >= 1 &&
          month <= 12 &&
          year >= 1900) {
        return DateTime(year, month, day);
      }
    }
  }

  // Manual parsing for yyyy-MM-dd format.
  if (cleanedDate.contains('-')) {
    final parts = cleanedDate.split('-');
    if (parts.length == 3) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (day != null &&
          month != null &&
          year != null &&
          day >= 1 &&
          day <= 31 &&
          month >= 1 &&
          month <= 12 &&
          year >= 1900) {
        return DateTime(year, month, day);
      }
    }
  }

  // Epoch-millisecond string.
  final timestamp = int.tryParse(cleanedDate);
  if (timestamp != null) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  return null;
}

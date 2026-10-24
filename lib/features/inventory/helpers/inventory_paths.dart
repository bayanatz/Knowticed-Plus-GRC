/// Module: inventory
///
///*************************** FILE INFO ****************************///
/// File Name: inventory_paths.dart
/// Purpose: Single source of the signed-in company id and user email used by
///          every Inventory Firestore path (Demo/`<companyId>`/...).
/// Author: Knowticed Plus team
/// Updated: 18/10/2026 - Created; replaces the hard-coded company 84763782 and
///          the personal email that were repeated across the module.
library;

import 'package:knowticed_plus/core/helper/current_user_context.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';

/// Resolves the company and user the Inventory module reads and writes under.
class InventoryPaths {
  InventoryPaths._();

  /// Fallback used only when nobody is signed in (e.g. unit tests).
  static const String _fallbackEmail = 'bayanatz@knowticed.com';

  /// Company id = last segment of [ApiConstants.baseUri] ("Demo/DM-003" -> DM-003).
  static String get companyId {
    final List<String> parts = ApiConstants.baseUri
        .split('/')
        .where((String part) => part.isNotEmpty)
        .toList();
    return parts.isEmpty ? '' : parts.last;
  }

  /// Email of the signed-in user, lower-case (falls back to the showcase user).
  static String get userEmail {
    final String? email = CurrentUserContext.email?.trim();
    // Lower-cased so the document id is the same however the sign-in typed it.
    return (email == null || email.isEmpty)
        ? _fallbackEmail
        : email.toLowerCase();
  }
}

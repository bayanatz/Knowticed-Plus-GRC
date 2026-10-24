/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: feedback_collection_paths.dart
/// Purpose: Resolve the tenant-aware path the feedback flow writes to.
/// Author: Knowticed Plus team
/// Created at: 13/8/2026
///
/// Added while fixing the dead submit button on the comments-and-feedback
/// screen. Follows the shape of `RequestCollectionPaths`: the module document
/// is resolved through `getBaseUrl` so the company id is never hardcoded, and
/// the submissions hang off it as a sub-collection.
library;

import 'package:knowticed_plus/core/constants/firebase_collections.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

abstract final class FeedbackCollectionPaths {
  const FeedbackCollectionPaths._();

  static const String _settingsDocName = 'settings';

  /// `{baseUri}/Modules/settings` — the settings module document.
  ///
  /// Resolves to `Demo/{companyId}/Modules/settings`.
  static String get settingsDoc =>
      '${getBaseUrl(FirebaseCollections.modulesKey)}/$_settingsDocName';

  /// The sub-collection of [settingsDoc] holding one document per submission.
  static String get feedbackCollection => FirebaseCollections.appFeedback;

  /// The sub-collection of [settingsDoc] holding the inquiry and comment
  /// thread of the feedback requests — one document per comment, tagged with
  /// the [commentFeedbackIdField] of the feedback it belongs to (Moataz
  /// 23/10/2026: the same thread the Requests page has, between the employee
  /// and the admin). New collection: it needs a Firestore security rule.
  static String get feedbackCommentsCollection =>
      '$settingsDoc/App_Feedback_Comments';

  /// The field on a comment document naming the feedback it belongs to.
  static const String commentFeedbackIdField = 'Request_Id';
}

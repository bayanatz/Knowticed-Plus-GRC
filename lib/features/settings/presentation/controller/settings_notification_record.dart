/// Module: settings/main_controller
///
///************************ FILE INFO ****************************///
/// File Name: settings_notification_record.dart
/// Purpose: Which screen a change-request notification's View opens (owner,
///          22/10/2026: View opens the request itself, not the Settings menu).
/// Created at: 22/10/2026
///
/// The notification stores the change request's id as `Request_Id` and the
/// screen as `name_of_page`. A reviewer's notification names one of the two
/// preview pages; those cannot be rebuilt from a notification (they take the
/// submitter's ~15 form controllers), so the reviewer gets the screen they
/// decide from — `UserManagementDetailsRequestSettings`, Approve / Reject.
/// Everyone else gets their own request, `DetailsRequestSettings`. Both load
/// the request themselves from its id.
library;

import 'package:flutter/widgets.dart';
import 'package:knowticed_plus/features/notification/domain/enums/settings/settings_notification_pages.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/user_management_details_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/pages/details_request.dart';

class SettingsNotificationRecord {
  SettingsNotificationRecord._();

  /// Function Name: [isReviewPage]
  ///
  /// Purpose: True when [pageKey] is a reviewer's page (a change request
  /// waiting for their decision).
  static bool isReviewPage(String pageKey) {
    final SettingsNotificationPage? page =
        SettingsNotificationPage.fromKey(pageKey);
    return page == SettingsNotificationPage.previewChangesPage ||
        page == SettingsNotificationPage.previewHealthInsuranceChangesPage;
  }

  /// Function Name: [pageFor]
  ///
  /// Purpose: The screen that opens change request [requestId] for a
  /// notification whose `name_of_page` is [pageKey].
  static Widget pageFor({required String requestId, required String pageKey}) {
    // `requestData` is no longer read by either screen; both load by id.
    return isReviewPage(pageKey)
        ? UserManagementDetailsRequestSettings(
            requestId: requestId,
            requestData: const <String, dynamic>{},
          )
        : DetailsRequestSettings(
            requestId: requestId,
            requestData: const <String, dynamic>{},
          );
  }
}

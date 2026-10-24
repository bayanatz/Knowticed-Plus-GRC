// ******************* FILE INFO *******************
// File Name: services_notification_record
// Description: Opens the service request a notification is about (owner,
//              22/10/2026: View opens the record, not the module's page).
//              `ServicesResponsivePage` takes the module's
//              `PendingNotificationRecord`, [load]s the request by its
//              `RequestServices` doc id and pushes the details page [viewFor]
//              picks from the notification's `name_of_page`.
// Module: services_management_module / presentation / controller
// *************************************************

import 'package:knowticed_plus/features/services/domain/entities/parent_service_details.dart';
import 'package:knowticed_plus/features/notification/domain/enums/services/services_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/routing/notification_deep_link.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';

/// Whose view of the request a notification opens.
enum ServicesRecordView {
  /// `ApprovalRequestCard` — the approver's details, with Approve / Reject.
  approver,

  /// `ServiceProviderDashboard` — the provider's details (status actions).
  provider,

  /// `RequestServicesToggle` and anything else — the requester's request.
  requester;

  /// The list this view sits on, so Back from the details lands there.
  NotificationServicesSection get section => switch (this) {
        ServicesRecordView.approver => NotificationServicesSection.approvals,
        ServicesRecordView.provider =>
          NotificationServicesSection.providerDashboard,
        ServicesRecordView.requester => NotificationServicesSection.requests,
      };
}

/// Fetches a parent service's names (same map as
/// `ParentServiceDetailsFetcher.fetch`).
typedef ServiceNamesFetch = Future<ParentServiceDetails> Function(
  String parentServiceId,
);

class ServicesNotificationRecord {
  ServicesNotificationRecord._();

  /// Function Name: [viewFor]
  ///
  /// Purpose: Which details page a notification's `name_of_page` opens.
  static ServicesRecordView viewFor(String pageKey) {
    if (pageKey == ServicesNotificationPage.approvalRequestCard.key) {
      return ServicesRecordView.approver;
    }
    if (pageKey == ServicesNotificationPage.serviceProviderDashboard.key) {
      return ServicesRecordView.provider;
    }
    return ServicesRecordView.requester;
  }

  /// Function Name: [load]
  ///
  /// Purpose: The request [recordId] (a `RequestServices` doc id), or null
  /// when it no longer exists or cannot be read — the caller then leaves the
  /// reader on the list.
  ///
  /// A request doc is written by `createMinimalRequest`, which stores no
  /// service name, so the names are filled from the parent service exactly as
  /// `getMyRequestServices` does (display repair: `bumpTimestamp: false`).
  static Future<ServicesHistoryModel?> load({
    required CreateServicesRepository repository,
    required String recordId,
    required ServiceNamesFetch fetchNames,
  }) async {
    try {
      final Map<String, dynamic>? data =
          await repository.getRequestServiceDocById(recordId);
      if (data == null) return null;
      final ServicesHistoryModel model =
          ServicesHistoryModel.fromJson(data, recordId);

      if ((model.currentServiceNameEnglish.isNotEmpty &&
              model.currentServiceNameArabic.isNotEmpty) ||
          model.currentParentServiceId.isEmpty) {
        return model;
      }
      try {
        final ParentServiceDetails details = await fetchNames(
          model.currentParentServiceId,
        );
        return model.copyWith(
          serviceNameEnglish: details.nameEnglish,
          serviceNameArabic: details.nameArabic,
          serviceDescriptionEnglish: details.descriptionEnglish,
          serviceDescriptionArabic: details.descriptionArabic,
          durationOfServices: details.duration,
          selectedDurationUnit: details.unit,
          bumpTimestamp: false,
        );
      } catch (_) {
        return model; // Names are cosmetic; still open the request.
      }
    } catch (_) {
      return null;
    }
  }
}

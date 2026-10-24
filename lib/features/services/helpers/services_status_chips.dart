/// Module: services / helpers
///
///*************************** FILE INFO ****************************///
/// File Name: services_status_chips.dart
/// Purpose: Builds the status chip row (All, Done, Approved, In progress,
///          Pending, Rejected, Canceled, Breached SLA) used above every
///          request list. Chips are keyed by the stable status value from
///          RequestStatus, never by their translated label.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:flutter/widgets.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_filter_app.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/data/utils/request_status.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Key of the "All" chip.
const String kServicesAllStatus = 'all';

/// Function Name: [servicesStatusColor]
///
/// Purpose: The colour that marks a request status in chips and cards.
///
/// Parameters:
/// - [status]: a canonical [RequestStatus] value.
///
/// Returns: the theme colour for that status.
Color servicesStatusColor(String status) {
  switch (RequestStatus.normalize(status)) {
    case RequestStatus.done:
      return AppColors.green;
    case RequestStatus.approved:
      return AppColors.lightGreen;
    case RequestStatus.inProgress:
      return AppColors.secondaryPrimary;
    case RequestStatus.pending:
      return AppColors.orange;
    case RequestStatus.rejected:
      return AppColors.darkRed;
    case RequestStatus.cancel:
    case RequestStatus.breachedSla:
      return AppColors.red;
    default:
      return AppColors.secondaryText;
  }
}

/// Function Name: [servicesStatusChips]
///
/// Purpose: The chips for a status filter, in a fixed lifecycle order so the
/// row never reshuffles as counts change.
///
/// Parameters:
/// - [context]: for the translated labels.
/// - [total]: count shown on the "All" chip.
/// - [counts]: count per canonical status; statuses missing from the map
///   are not shown.
///
/// Returns: the chip items, "All" first.
List<StatusChipItem> servicesStatusChips(
  BuildContext context, {
  required int total,
  required Map<String, int> counts,
}) {
  const order = [
    RequestStatus.done,
    RequestStatus.approved,
    RequestStatus.inProgress,
    RequestStatus.pending,
    RequestStatus.rejected,
    RequestStatus.cancel,
    RequestStatus.breachedSla,
  ];
  return [
    StatusChipItem(
      key: kServicesAllStatus,
      label: FormatHelper.capitalize(S.of(context).all),
      count: total,
    ),
    for (final status in order)
      if (counts.containsKey(status))
        StatusChipItem(
          key: status,
          label: FormatHelper.capitalize(context.svcStatus(status)),
          count: counts[status] ?? 0,
          labelColor: servicesStatusColor(status),
        ),
  ];
}

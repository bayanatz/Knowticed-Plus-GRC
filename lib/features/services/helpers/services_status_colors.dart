/// Module: services / helpers
///
///*************************** FILE INFO ****************************///
/// File Name: services_status_colors.dart
/// Purpose: The one colour per request status, chosen by the stored status
///          (any spelling), never by its translated label. Labels come from
///          `context.svcStatus` (services_text.dart).
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:flutter/painting.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/data/utils/request_status.dart';

/// Class Name: [ServicesStatusColors]
///
/// Purpose: Status → theme colour.
abstract final class ServicesStatusColors {
  /// Function Name: [of]
  ///
  /// Purpose: The colour of [rawStatus] (normalised first, so 'canceled',
  /// 'breached sla' and 'In Progress' work too).
  static Color of(String? rawStatus) {
    switch (RequestStatus.normalize(rawStatus)) {
      case RequestStatus.approved:
        return AppColors.lightGreen;
      case RequestStatus.done:
        return AppColors.green;
      case RequestStatus.rejected:
        return AppColors.red;
      case RequestStatus.cancel:
        return AppColors.darkRed;
      case RequestStatus.inProgress:
        return AppColors.secondaryPrimary;
      case RequestStatus.pending:
        return AppColors.orange;
      case RequestStatus.breachedSla:
        return AppColors.block;
      default:
        return AppColors.grey;
    }
  }
}

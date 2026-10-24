/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_status_style.dart
/// Purpose: Border colour and icon that mark a request status on the request
///          details page. Keyed by the canonical RequestStatus values.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/data/utils/request_status.dart';

/// Function Name: [requestStatusBorderColor]
///
/// Purpose: The border colour of a request in [status].
///
/// Parameters:
/// - [status]: any stored spelling; normalised first.
///
/// Returns: the theme colour.
Color requestStatusBorderColor(String status) {
  switch (RequestStatus.normalize(status)) {
    case RequestStatus.pending:
      return AppColors.orange;
    case RequestStatus.done:
    case RequestStatus.approved:
      return AppColors.lightGreen;
    case RequestStatus.rejected:
    case RequestStatus.cancel:
    case RequestStatus.breachedSla:
      return AppColors.block;
    case RequestStatus.inProgress:
      return AppColors.secondaryPrimary;
    default:
      return AppColors.lightGrey;
  }
}

/// Function Name: [requestStatusIcon]
///
/// Purpose: The status icon of a request in [status].
///
/// Parameters:
/// - [status]: any stored spelling; normalised first.
///
/// Returns: the asset path.
String requestStatusIcon(String status) {
  switch (RequestStatus.normalize(status)) {
    case RequestStatus.approved:
    case RequestStatus.done:
      return 'assets/icons_assets/main_icons_assets/ic_status_approved_circle.svg';
    case RequestStatus.rejected:
      return 'assets/icons_assets/main_icons_assets/ic_status_rejected.svg';
    case RequestStatus.cancel:
      return 'assets/icons_assets/main_icons_assets/ic_action_close_circle_bold.svg';
    case RequestStatus.inProgress:
      return 'assets/icons_assets/main_icons_assets/ic_status_in_progress.svg';
    case RequestStatus.breachedSla:
      return 'assets/icons_assets/services_assets/ic_time_sla_breached_white.svg';
    default:
      return 'assets/icons_assets/main_icons_assets/ic_status_pending_mixed.svg';
  }
}

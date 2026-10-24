/// Module: services / sv7_approvals / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: approval_request.dart
/// Purpose: The approvals list: status chips with the approver's own counts,
///          search, department filter, sort and the grid of
///          ApprovalRequestCard tiles.
/// Author: Amr Mesbah
/// Created at: 02/07/2026
library;

import 'package:knowticed_plus/features/services/sv7_approvals/presentation/ui/widgets/approval_request_card_header.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/layout/custom_grid_view.dart';
import 'package:knowticed_plus/core/helper/current_user_context.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/features/services/data/utils/request_status.dart';
import 'package:knowticed_plus/features/services/domain/enums/request_sort.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/approval_decision_service.dart';
import 'package:knowticed_plus/features/services/presentation/controller/request_details_lookup.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/controller/approval_request_cubit.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/ui/widgets/approval_request_card.dart';
import 'package:knowticed_plus/core/custom/layout/custom_gridview_with_animation.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_filter_app.dart';

import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/sort.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/ui/widgets/approvals_department_filter.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';

import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/custom_multi.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/services_load_error.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

part 'approval_request_part2.dart';

class ApprovalServices extends StatefulWidget {
  const ApprovalServices({super.key});
  @override
  State<ApprovalServices> createState() => _ApprovalServicesState();
}

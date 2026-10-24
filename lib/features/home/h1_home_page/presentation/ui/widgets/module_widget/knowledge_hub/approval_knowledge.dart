// [module-file:knowledge_hub] — deleted when the knowledge_hub module is split out
/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: approval_knowledge.dart
/// Description: Declares `ApprovalDashBoardWidget`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

// 15/10/2026 — KH report p.29/p.25 "enhance their width": every KH card is
// the dashboard tile width (kHomeWidgetWidth), not its own 400/140.
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/standard_container.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/home/helpers/knowledge_hub_module/knowledge_dashboard_stub.dart';
// The `currentStatus` / `currentCreatedByEmail` getters (an extension).
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/knowledge_hub_module/knowledge_hub/presentation/cubit/dashboard_cubit/dashboard_states.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';

class ApprovalDashBoardWidget extends StatelessWidget {
  final HomeComponentModel model;

  const ApprovalDashBoardWidget({required this.model, super.key});

  /// ✅ Check if document was ever published (for removed count)
  bool _wasEverPublished(dynamic doc) {
    if (doc.status.isEmpty) return false;

    for (var status in doc.status) {
      if (status.toLowerCase() == 'published') {
        return true;
      }
    }
    return false;
  }

  /// ✅ Filter status counts by current user's email
  Map<String, int> _filterStatusCountsByUser(
    Map<String, int> allStatusCounts,
    DashboardCubit cubit,
    String userEmail,
  ) {
    Map<String, int> userCounts = {
      'approved': 0,
      'pending_approval': 0,
      'rejected': 0,
      'removed': 0,
    };

    // Get all documents
    final allDocuments = cubit.getAllDocuments();

    for (var doc in allDocuments) {
      // ✅ Only count documents created by this user
      if (doc.currentCreatedByEmail.toLowerCase().trim() !=
          userEmail.toLowerCase().trim()) {
        continue;
      }

      // Skip if no status history
      if (doc.status.isEmpty) continue;

      // Get the LAST status (current status)
      String currentStatus = doc.status.last.toLowerCase();

      // Count based on the exact last status
      if (currentStatus == 'approved') {
        userCounts['approved'] = (userCounts['approved'] ?? 0) + 1;
      } else if (currentStatus == 'pending_approval') {
        userCounts['pending_approval'] =
            (userCounts['pending_approval'] ?? 0) + 1;
      } else if (currentStatus == 'rejected') {
        userCounts['rejected'] = (userCounts['rejected'] ?? 0) + 1;
      } else if (currentStatus == 'removed') {
        // ✅ Only count if document was published first
        if (_wasEverPublished(doc)) {
          userCounts['removed'] = (userCounts['removed'] ?? 0) + 1;
        }
      }
    }

    return userCounts;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Get current logged-in user's email
    final employeeController = Get.find<MainCoreEmployeeController>();
    final String? currentUserEmail = employeeController.employeeEntity?.email;

    if (currentUserEmail == null) {
      return SizedBox(
        // width = content (18/10/2026)
        child: StandardContainer(
          child: Center(
            child: Text(
              'User not logged in',
              style: StyleText.fontSize14Weight400,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      // width = content (18/10/2026)
      child: StandardContainer(
        // Owns its DashboardCubit, exactly like KnowledgeHubOverview next door.
        // There is no root Provider<DashboardCubit> (main.dart still has the
        // comment for one, but the BlocProvider itself is gone), so relying on
        // an ancestor threw ProviderNotFoundException wherever this widget was
        // rendered outside the Knowledge Hub — e.g. the Adding Widget preview.
        child: BlocProvider(
          create: (_) => DashboardCubit()..loadDashboard(),
          child: BlocBuilder<DashboardCubit, DashboardStates>(
            builder: (context, state) {
              // Default values
              int totalApproved = 0;
              int totalPending = 0;
              int totalRejected = 0;
              int totalRemoved = 0;

              // ✅ Extract and filter data from loaded state
              if (state is DashboardLoaded) {
                // Get the cubit instance to access document list
                final cubit = context.read<DashboardCubit>();

                // Filter counts by current user
                final userCounts = _filterStatusCountsByUser(
                  state.statusCounts,
                  cubit,
                  currentUserEmail,
                );

                totalApproved = userCounts['approved'] ?? 0;
                totalPending = userCounts['pending_approval'] ?? 0;
                totalRejected = userCounts['rejected'] ?? 0;
                totalRemoved = userCounts['removed'] ?? 0;
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment
                    .start, // owner item 200 (21/10/2026): content under the title
                spacing: 8.sp,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 8.w,
                    children: [
                      Text(
                        S.of(context).approvals, // ✅ "My Submissions"
                        style: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.text),
                      ),
                      CustomSvgImage.natural(
                        assetPath:
                            'assets/icons_assets/main_icons_assets/ic_module_knowledge_hub.svg',
                        // 22/10/2026 — Owner: home card title glyph 20 (was 16).
                        width: HomeWidgetCard.iconSize,
                        height: HomeWidgetCard.iconSize,
                        color: AppColors.primary,
                      ),
                    ],
                  ),

                  // Show loading indicator
                  if (state is DashboardLoading)
                    Padding(
                      // 8, not 20: 20 above and below the spinner overflowed
                      // the card by 11 px while loading (21/10/2026).
                      padding: EdgeInsets.symmetric(vertical: 8.sp),
                      child: const Center(
                        child: CircleProgressMaster(),
                      ),
                    )
                  // Show error message
                  else if (state is DashboardError)
                    Padding(
                      // 8, not 20: 20 above and below the spinner overflowed
                      // the card by 11 px while loading (21/10/2026).
                      padding: EdgeInsets.symmetric(vertical: 8.sp),
                      child: Center(
                        child: Text(
                          S.of(context).errorLoadingData,
                          style: StyleText.fontSize14Weight400
                              .copyWith(color: Colors.red),
                        ),
                      ),
                    )
                  // Show empty state
                  else if (state is DashboardEmpty)
                    Padding(
                      // 8, not 20: 20 above and below the spinner overflowed
                      // the card by 11 px while loading (21/10/2026).
                      padding: EdgeInsets.symmetric(vertical: 8.sp),
                      child: Center(
                        child: Text(
                          S.of(context).noDataAvailable,
                          style: StyleText.fontSize14Weight400,
                        ),
                      ),
                    )
                  // Show data
                  else
                    HomeStatTileRow(
                      tiles: <HomeStatTile>[
                        _staticItem(
                          title: S.of(context).approved,
                          number: totalApproved,
                          icon:
                              'assets/icons_assets/home_assets/ic_status_approved_stamp.svg',
                        ),
                        _staticItem(
                          title: S.of(context).pending,
                          number: totalPending,
                          icon:
                              'assets/icons_assets/home_assets/ic_status_pending_hourglass.svg',
                        ),
                        _staticItem(
                          title: S.of(context).rejected,
                          number: totalRejected,
                          icon:
                              'assets/icons_assets/home_assets/ic_status_rejected_stamp.svg',
                        ),
                        _staticItem(
                          title: S.of(context).removed,
                          number: totalRemoved,
                          icon:
                              // Owner 21/10/2026 13:31: his exported Figma icon for
                              // Removed (document with a minus circle).
                              'assets/icons_assets/home_assets/ic_status_removed_document.svg',
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // 18/10/2026: the shared stat tile (same icon / label / value scale and
  // the same gap as every other home card) instead of a boxed Expanded tile.
  HomeStatTile _staticItem({
    required String title,
    required int number,
    required String icon,
  }) {
    return HomeStatTile(icon: icon, label: title, value: number.toString());
  }
}

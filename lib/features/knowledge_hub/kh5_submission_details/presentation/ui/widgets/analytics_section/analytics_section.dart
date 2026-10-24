/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section
/// ************************* FILE INFO *************************** ///
/// File Name: analytics_section.dart
/// Description: Build analytics section — Submission Details (S5) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/kh_comment_source.dart';
import 'package:knowticed_plus/features/knowledge_hub/knowledge_hub_get_it.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_system_log.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/knowledge_hub_permissions.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/controller/submissions_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_comment_widget.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/statistics_tab/statistics_tab.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge_hub/knowledge_hub_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge_hub/knowledge_hubssections_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/analytics_tab/analytics_tab.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// Analytics Section for Published Documents
class AnalyticsSection extends StatefulWidget {
  final bool lightMode;
  final String knowledgeId;
  final TextEditingController searchStatisticsController;

  const AnalyticsSection({
    super.key,
    required this.lightMode,
    required this.knowledgeId,
    required this.searchStatisticsController,
  });

  @override
  State<AnalyticsSection> createState() => _AnalyticsSectionState();
}

class _AnalyticsSectionState extends State<AnalyticsSection> {
  int selectedIndex = 0;
  bool isCommentSectionExpanded =
      false; // Track comment section expansion state

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        khLog('🏗️ [buildAnalyticsSection] Creating AnalyticsCubit');
        final cubit = KnowledgeHubDI.analyticsCubit();
        khLog('📡 [buildAnalyticsSection] Triggering fetchAnalytics');
        cubit.fetchAnalytics(widget.knowledgeId);
        return cubit;
      },
      // "RenderFlex children have non-zero flex but incoming
      // height constraints are unbounded", thrown on Submission Details on a
      // phone.
      //
      // The tab content below is an `Expanded`, which needs a FINITE height to
      // divide up. It gets one on tablet/desktop, where the caller wraps this
      // section in `Container(height: 960.h)`. On a phone the caller has no
      // such box and the whole page sits in a scroll view, so the incoming
      // height is infinite — `Expanded` is a contradiction there ("fill the
      // remaining space" inside something that is shrink-wrapping) and layout
      // aborts, which is why the screen came up blank with a wall of
      // 'RenderBox was not laid out' errors after it.
      //
      // So: flex only when there is a height to flex into, and otherwise let
      // the section be as tall as the selected tab and let the page's own
      // scroll view do the scrolling.
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // (Knowledge Hub bug report p.22 — "remove this
          // extra space" under the comment box): the Comments tab never fills
          // the section. It is only as tall as the comments themselves, and the
          // caller's box (a max height since this change, see
          // published_content.dart) shrinks to it instead of leaving
          // the rest of a 960.h block empty.
          final bool bounded =
              constraints.hasBoundedHeight && selectedIndex != 2;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
            children: [
              // Custom Tab Bar
              _buildTabBar(context),

              SizedBox(height: 20.h), // = the 20.h above the tabs (KH p.17)
              // Tab Content — see the note above: `Expanded` only where the
              // height is finite.
              _tabContent(
                bounded: bounded,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8.r),
                      bottomRight: Radius.circular(8.r),
                    ),
                  ),
                  child: _tabStack(
                    fill: bounded,
                    children: [
                      // Analytics Tab
                      buildAnalyticsTab(
                        context,
                        widget.lightMode,
                        widget.knowledgeId,
                      ),

                      // Statistics Tab
                      buildStatisticsTab(
                        context,
                        lightMode: widget.lightMode,
                        searchStatisticsController:
                            widget.searchStatisticsController,
                      ),

                      // Comments Tab - Using UniversalCommentSection
                      _buildCommentsTab(context),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// The Analytics / Statistics / Comments tabs the user may see.
  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.r),
          topRight: Radius.circular(8.r),
        ),
      ),
      // Alongside the 24pt tab labels — a plain Row
      // would overflow. Three labels at 24pt plus two 40.w gaps is wider
      // than a phone in English and wider again in Arabic, and the Row
      // has no flexible child to absorb it, so it would throw the yellow
      // overflow stripes rather than clip. Scrolling keeps every tab
      // reachable at any width instead of hiding the last one.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (KnowledgeHubAccess.has(
              section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
              permission: KnowledgeHubPermissions.analytics,
            ))
              _buildTabItem(context, title: S.of(context).analytics, index: 0),
            if (KnowledgeHubAccess.has(
              section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
              permission: KnowledgeHubPermissions.statistics,
            ))
              SizedBox(width: 40.w),
            if (KnowledgeHubAccess.has(
              section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
              permission: KnowledgeHubPermissions.statistics,
            ))
              _buildTabItem(context, title: S.of(context).statistics, index: 1),
            if (KnowledgeHubAccess.has(
              section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
              permission: KnowledgeHubPermissions.inquiriesAndComments,
            ))
              SizedBox(width: 40.w),
            if (KnowledgeHubAccess.has(
              section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
              permission: KnowledgeHubPermissions.inquiriesAndComments,
            ))
              _buildTabItem(context, title: S.of(context).comments, index: 2),
          ],
        ),
      ),
    );
  }

  /// The Comments tab (the shared comment section).
  Widget _buildCommentsTab(BuildContext context) {
    return UniversalCommentSection(
      isExpandable: true,
      // 22/10/2026: old- and new-format comments (KhCommentSource).
      source: KhCommentSource(knowledgeId: widget.knowledgeId),
      currentUserId:
          context.read<SubmissionsCubit>().people.signedInEmployee!.email!,
      fixedHeight: isCommentSectionExpanded ? null : 400.h,
      collapsedHeight: 400.h,
      onCommentAdded: (_) =>
          khSystemLog(KhLogAction.submitInquiryComment), // System Logs §3
      onExpandChanged: (bool expanded) {
        // Update state when expansion changes
        setState(() {
          isCommentSectionExpanded = expanded;
        });
      },
      style: CommentSectionStyle(
        hintStyle: StyleText.fontSize16Weight400.copyWith(
          color: AppColors.secondaryText.withValues(alpha: .5),
        ),
        commentTextStyle: StyleText.fontSize18Weight500.copyWith(
          color: AppColors.text,
        ),
        fileChipDecoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        fileIconColor: AppColors.text,
        fileNameStyle: StyleText.fontSize12Weight400.copyWith(
          color: AppColors.text,
        ),
        avatarColor: AppColors.background,
        inputFillColor: AppColors.card,
        containerDecoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        commentItemDecoration: BoxDecoration(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        userNameStyle: StyleText.fontSize16Weight400.copyWith(
          color: AppColors.text,
        ),
        sendButtonDecoration: BoxDecoration(
          color: AppColors.secondaryPrimary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        sendIconColor: AppColors.secondaryPrimaryText,
      ),
    );
  }

  /// The tab-content slot: a flex child where the incoming height is finite,
  /// and a plain child where it is not. See the note in [build].
  Widget _tabContent({required bool bounded, required Widget child}) =>
      bounded ? Expanded(child: child) : child;

  /// The three tabs.
  ///
  /// When the section fills a fixed height, an [IndexedStack] as before. When
  /// it sizes to its content, ONLY the selected tab is built: an IndexedStack
  /// is as tall as its TALLEST child, so the short Comments tab used to sit on
  /// top of the Analytics tab's full height — the empty band reported on p.22.
  Widget _tabStack({required bool fill, required List<Widget> children}) => fill
      ? IndexedStack(index: selectedIndex, children: children)
      : children[selectedIndex.clamp(0, children.length - 1)];

  Widget _buildTabItem(
    BuildContext context, {
    required String title,
    required int index,
  }) {
    final isSelected = selectedIndex == index;
    final textColor = isSelected ? AppColors.primary : AppColors.secondaryText;

    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            // 16 -> 24, in two steps (16 -> 20 -> 24;
            // 20 was still reported as too small). These three tabs are the
            // only navigation on Submission Details and sat smaller than the
            // "Department" / "Document Utilization" card headings beneath
            // them, so they read as secondary text rather than as the control
            // they are. 24 puts them clearly above those headings.
            // 15/10/2026 — KH vertical report p.18 "Not bold": regular
            // weight; the colour and underline mark the selected tab.
            style: StyleText.fontSize24Weight400.copyWith(
              color: textColor,
              shadows: [],
            ),
          ),
          SizedBox(height: 0.6.h),
          if (isSelected)
            Container(
              height: 0.6.h,
              // The underline is measured from the same style as the label, so
              // it has to move with it.
              width: _getTextWidth(title, StyleText.fontSize24Weight400),
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }

  double _getTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: ui.TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }
}

/// Wrapper function to maintain compatibility with existing code
Widget buildAnalyticsSection(
  BuildContext context, {
  required bool lightMode,
  required String knowledgeId,
  String selectedTab = 'Analytics',
  required TextEditingController searchStatisticsController,
}) {
  return AnalyticsSection(
    lightMode: lightMode,
    knowledgeId: knowledgeId,
    searchStatisticsController: searchStatisticsController,
  );
}

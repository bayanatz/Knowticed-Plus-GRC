/// Module: knowledge_hub/kh3_view_knowledge_details/presentation/ui/pages
///
///*************************** FILE INFO ****************************///
/// File Name: view_knowledge_details.sections.dart
/// Description: `_ViewKnowledgeDetailsSections` — split out of `view_knowledge_details.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'view_knowledge_details.dart';

/// Module: knowledge_hub / presentation / s3_view_knowledge_details/master_page/view_knowledge_details.sections.dart

/// Builder methods + view state for [ViewKnowledgeDetails], split out of
/// the master page to keep each file under the 800-LOC limit (§7).
mixin _ViewKnowledgeDetailsSections on State<ViewKnowledgeDetails> {
  late bool isOwner;
  TabController? _tabController;
  final TextEditingController _searchStatisticsController =
      TextEditingController();
  int _selectedSectionIndex = 0; // 0: Analytics, 1: Statistics, 2: Comments

  /// KH-CREATE-26: created once with the page State and disposed in
  /// dispose(), so an Expand / Collapse tap or a failed send (both rebuild
  /// the comments area) no longer wipes the comment being typed.
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _commentsScrollController = ScrollController();

  /// Name of the file attached to the comment being typed (KH-CREATE-25).
  String? _attachmentName;

  /// Disposes the controllers owned by this mixin. Called from dispose().
  void _disposeCommentControllers() {
    _commentController.dispose();
    _commentsScrollController.dispose();
  }

  /// ✅ Check if current user is the document owner
  bool _checkIfOwner() {
    // Runs from initState, above this page's own providers, so it asks the
    // module's DI for the signed-in employee.
    final String email = KnowledgeHubDI.people.signedInEmail;
    return email.isNotEmpty &&
        email.toLowerCase().trim() == widget.emailUser.toLowerCase().trim();
  }

  double _getTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  bool _canSee(KnowledgeHubPermissions permission) => KnowledgeHubAccess.has(
        section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
        permission: permission,
      );

  /// ✅ Build section selector and content for OWNER (Analytics, Statistics, Comments)
  Widget _buildOwnerTabsView(BuildContext context, bool lightMode) {
    final S s = S.of(context);
    return Column(
      children: [
        Row(
          children: [
            if (_canSee(KnowledgeHubPermissions.analytics)) ...[
              _buildSectionTab(label: s.analytics, index: 0),
              SizedBox(width: 39.w),
            ],
            if (_canSee(KnowledgeHubPermissions.statistics)) ...[
              _buildSectionTab(label: s.statistics, index: 1),
              SizedBox(width: 39.w),
            ],
            if (_canSee(KnowledgeHubPermissions.inquiriesAndComments))
              _buildSectionTab(label: s.comments, index: 2),
          ],
        ),
        SizedBox(height: 15.h),
        _buildSelectedSectionContent(context, lightMode),
      ],
    );
  }

  /// One tab of the owner's section selector, underlined when selected.
  Widget _buildSectionTab({required String label, required int index}) {
    final bool selected = _selectedSectionIndex == index;
    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () => setState(() => _selectedSectionIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: StyleText.fontSize20Weight500.copyWith(
              color: selected ? AppColors.primary : AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 2),
          if (selected)
            Container(
              height: 2,
              width: _getTextWidth(label, StyleText.fontSize20Weight500),
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }

  /// ✅ Build content based on selected section
  Widget _buildSelectedSectionContent(BuildContext context, bool lightMode) {
    switch (_selectedSectionIndex) {
      case 0:
        return buildAnalyticsTab(context, lightMode, widget.knowledgeId);
      case 1:
        return buildStatisticsTab(
          context,
          lightMode: lightMode,
          searchStatisticsController: _searchStatisticsController,
        );
      case 2:
        return _buildCommentsSection(context);
      default:
        return SizedBox.shrink();
    }
  }

  /// ✅ Build simple comments view for CONTRIBUTOR (No tabs)
  Widget _buildContributorCommentsView(BuildContext context, bool lightMode) {
    // 22/10/2026 (Moataz, Mac: the heading showed twice): the shared box
    // draws "Inquiries And Comments" and its own Expand, so this view no
    // longer adds a second heading and toggle above it.
    return _buildCommentsSection(context);
  }

  /// ✅ Comments Section Widget
  ///
  /// 22/10/2026 (Moataz: "Settings → Requests, Inquiries And Comments is the
  /// perfect model — apply it everywhere"): the shared box, over the same
  /// `knowledgeComments` thread the Approvals page shows (`Request_Id`).
  Widget _buildCommentsSection(BuildContext context) {
    return UniversalCommentSection(
      // 22/10/2026: old- and new-format comments (KhCommentSource).
      source: KhCommentSource(knowledgeId: widget.knowledgeId),
      currentUserId:
          Get.find<MainCoreEmployeeController>().employeeEntity?.email ?? '',
      collapsedHeight: kpIsPhoneLayout(context) ? 320.h : 400.h,
      fitBelowPageTopWhenExpanded: true,
    );
  }

  /// ✅ Show error dialog
  void _showErrorDialog(BuildContext context, String error) {
    BuildContext? dialogCtx;

    showAppDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (ctx) {
        dialogCtx = ctx;
        return _buildErrorDialog(ctx);
      },
    ).timeout(const Duration(milliseconds: 1), onTimeout: () {});

    // Auto-close after 3 seconds
    Future.delayed(const Duration(seconds: 3)).then((_) {
      final BuildContext? openDialogCtx = dialogCtx;
      if (openDialogCtx != null && openDialogCtx.mounted) {
        final nav = Navigator.of(openDialogCtx, rootNavigator: true);
        if (nav.canPop()) {
          nav.pop();
        }
      }
    });
  }

  Widget _buildErrorDialog(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: SizedBox(
          width: 411.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie_assets/main_lottie_assets/lot_status_rejected.json',
                width: 70.sp,
                height: 70.sp,
                fit: BoxFit.scaleDown,
                repeat: false,
              ),
              SizedBox(height: 15.sp),
              Text(
                S.of(context).failedToAddComment,
                textAlign: TextAlign.center,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

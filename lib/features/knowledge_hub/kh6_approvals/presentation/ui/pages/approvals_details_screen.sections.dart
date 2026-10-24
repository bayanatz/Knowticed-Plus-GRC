/// Module: knowledge_hub/kh6_approvals/presentation/ui/pages
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_details_screen.sections.dart
/// Description: `_ApprovalsDetailsSections` — split out of `approvals_details_screen.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'approvals_details_screen.dart';

/// Fields + helper/builder methods for the screen, split out to keep
/// each file under 800 LOC (§7).
mixin _ApprovalsDetailsSections on State<ApprovalsDetailsScreen> {
  /// Removal reason, read through the cubit (KH-APPROVE-05).
  Future<String?> _getRemovalReason(String knowledgeId) =>
      context.read<ApprovalsCubit>().getRemovalReason(knowledgeId);

  EmployeeData? creatorData;

  String? departmentName;

  bool isLoading = true;

  String currentStatus = '';

  /// ✅ Get file icon based on extension
  String getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'assets/icons_assets/main_icons_assets/ic_file_pdf.svg';
      case 'ppt':
      case 'pptx':
        return 'assets/icons_assets/main_icons_assets/ic_file_powerpoint.svg';
      case 'doc':
      case 'docx':
        return 'assets/icons_assets/main_icons_assets/ic_file_doc.svg';
      case 'png':
      case 'jpg':
      case 'jpeg':
        return 'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
      case 'mkv':
      case 'webm':
        return 'assets/icons_assets/main_icons_assets/ic_file_video.svg';
      case 'xlsx':
      case 'xls':
      case 'xlsm':
      case 'csv':
        return 'assets/icons_assets/main_icons_assets/ic_file_excel_grid.svg';
      default:
        return 'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg';
    }
  }

  /// ✅ Fetch creator and department data
  Future<void> _fetchData() async {
    final data = await context.read<ApprovalsCubit>().loadCreatorAndDepartment(
      creatorEmail: widget.createdByEmail,
      department: widget.department,
    );
    if (!mounted) return;
    setState(() {
      creatorData = data.creator;
      departmentName = data.departmentName;
      isLoading = false;
    });
  }

  /// ✅ Format timestamp to readable date
  String _formatDate(int? timestamp) {
    if (timestamp == null) return '-';
    return DateFormat('dd MMM yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }

  /// Delegated to the shared formatter so the Firestore `Timestamp` handling
  /// stays out of the UI (CR-KH-S7 §3).
  String? _formatDateTime(dynamic timestamp) =>
      SubmissionDateFormatter.formatDateTime(timestamp);

  /// Time from String / Map / List, in the UI language (shared formatter).
  String? _formatTime(dynamic timeData) =>
      SubmissionDateFormatter.formatTime(timeData);

  /// ✅ Get localized employee name (Arabic/English)
  String _getLocalizedEmployeeName(EmployeeData? employee) {
    if (employee == null) return '-';

    final employeeController = context.read<ApprovalsCubit>().people.employees;
    final isEnglish = KhLocale.isEnglish(context);

    String name = employeeController.getEmployeeNameEnglishArabic(
      employee.currentemployeeEmail,
      isEnglish,
    );

    return name.isNotEmpty
        ? FormatHelper.capitalize(name)
        : FormatHelper.capitalize(employee.currentemployeeName);
  }

  String _getLocalizedDepartmentName(String departmentName) =>
      KhLocale.department(context, departmentName);

  /// ✅ Get localized job title (Arabic/English)
  String _getLocalizedJobTitle(EmployeeData? employee) {
    if (employee == null) return '-';

    final employeeController = context.read<ApprovalsCubit>().people.employees;
    String jobTitle = employeeController.getEmployeeJobTitle(
      employee.currentemployeeEmail,
    );

    return jobTitle == "no job" ? employee.currentemployeeRole : jobTitle;
  }

  /// ✅ Get localized document name (Arabic/English)
  String _getLocalizedDocumentName() {
    return FormatHelper.capitalize(widget.documentName);
  }

  /// ✅ Get localized description (Arabic/English)
  String _getLocalizedDescription() {
    return FormatHelper.capitalize(widget.documentDesc);
  }

  /// ✅ Format phone number with country code (+966 for Saudi Arabia)
  String _formatPhoneNumber(dynamic phone) {
    if (phone == null) return '-';

    String phoneStr = '';

    if (phone is List) {
      if (phone.isEmpty) return '-';
      phoneStr = phone.first.toString();
    } else if (phone is String) {
      if (phone.isEmpty) return '-';
      phoneStr = phone;
    } else {
      phoneStr = phone.toString();
    }

    phoneStr = phoneStr.replaceAll('[', '').replaceAll(']', '').trim();

    if (phoneStr.isEmpty) return '-';

    if (phoneStr.startsWith('+')) {
      return phoneStr;
    }

    if (phoneStr.startsWith('05') || phoneStr.startsWith('5')) {
      String cleanNumber = phoneStr.startsWith('0')
          ? phoneStr.substring(1)
          : phoneStr;
      return '+966 $cleanNumber';
    }

    return phoneStr;
  }

  /// ✅ Get status info with proper SVG icons and colors
  Map<String, dynamic> _getStatusInfo(String status) {
    String statusLower = status.toLowerCase().trim();

    switch (statusLower) {
      case 'rejected':
        return {
          'text': S.of(context).rejected,
          'color': AppColors.red,
          'widget': CustomSvgImage(
            assetPath: 'assets/icons_assets/main_icons_assets/ic_status_rejected_circle.svg',
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.cover,
          ),
        };

      case 'pending_approval':
      case 'pending':
        return {
          'text': S.of(context).pending,
          'color': AppColors.orange,
          'widget': CustomSvgImage(
            assetPath:
                'assets/icons_assets/main_icons_assets/ic_status_pending.svg',
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.cover,
          ),
        };

      case 'scheduled':
        return {
          'text': S.of(context).pending,
          'color': AppColors.orange,
          'widget': CustomSvgImage(
            assetPath: 'assets/icons_assets/main_icons_assets/ic_pending.svg',
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.cover,
          ),
        };

      case 'published':
      case 'approved':
        return {
          'text': S.of(context).approved,
          'color': AppColors.lightGreen,
          'widget': CustomSvgImage(
            assetPath: 'assets/icons_assets/knowledge_hub_assets/ic_images_approve.svg',
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.cover,
          ),
        };

      case 'removed':
        return {
          'text': S.of(context).removed,
          'color': AppColors.redCrimson,
          'widget': CustomSvgImage(
            assetPath: 'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg',
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.cover,
          ),
        };

      default:
        return {
          'text': status,
          'color': AppColors.primary,
          'widget': Icon(Icons.info, color: AppColors.primary, size: 24.sp),
        };
    }
  }

  /// ✅ Get localized document type (Arabic/English)
  String _getLocalizedDocumentType(String fileType) {
    String typeLower = fileType.toLowerCase().trim();

    switch (typeLower) {
      case 'presentation':
        return S.of(context).presentation;
      case 'form':
        return S.of(context).form;
      case 'report':
        return S.of(context).report;
      case 'booklet':
        return S.of(context).booklet;
      case 'video recording':
        return S.of(context).video_recording;
      case 'letter':
        return S.of(context).letter;
      case 'mandate':
        return S.of(context).mandate;
      case 'policy':
        return S.of(context).policy;
      case 'frame work':
        return S.of(context).frame_work;
      case 'workshop':
        return S.of(context).workshop;
      case 'guidelines':
        return S.of(context).guidelines;
      case 'other':
        return S.of(context).other;
      default:
        return FormatHelper.capitalize(fileType);
    }
  }

  /// ✅ Build approval/reject action buttons
  ///
  Widget _buildApprovalButtons(bool isMobile, bool lightMode) {
    final ApprovalAccess access = KnowledgeHubAccess.approvalAccess;

    // Nothing to act with — draw no row rather than an empty one, so the
    // spacing above and below collapses too.
    if (!access.canApprove) return const SizedBox.shrink();

    // 17/10/2026: the shared Approve / Reject pair (one version for every
    // module). Approve-only tier = Approve alone, full width on a phone.
    return CustomActionRow(
      children: [
        if (access.canReject)
          CustomOutlinedActionButton(
            label: S.of(context).reject,
            svgPath: ApprovalIcons.reject,
            color: AppColors.red,
            high: true,
            onTap: () => _showRejectDialog(isMobile, lightMode),
          ),
        CustomOutlinedActionButton(
          label: S.of(context).approve,
          svgPath: ApprovalIcons.approve,
          color: AppColors.lightGreen,
          onTap: () => _showApproveDialog(isMobile, lightMode),
        ),
      ],
    );
  }

  /// ✅ Build status badge
  Widget _buildStatusBadge(
    bool isMobile,
    bool lightMode,
    Map<String, dynamic> statusInfo,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 36,
          width: isMobile ? ScreenUtil().screenWidth - 80.w : 200.w,
          decoration: BoxDecoration(
            color: AppColors.card,
            border: Border.all(color: statusInfo['color'], width: 2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 12.w),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              statusInfo['widget'],
              SizedBox(width: 8.w),
              Text(
                statusInfo['text'],
                style: StyleText.fontSize16Weight500.copyWith(
                  color: statusInfo['color'],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ✅ Show approve dialog
  void _showApproveDialog(bool isMobile, bool lightMode) {
    showAppDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Material(
          color: AppColors.transparent,
          child: Container(
            width: isMobile ? double.infinity : 411.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.card,
            ),
            padding: EdgeInsets.all(20.r),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
                  height: 70.h,
                  width: 70.w,
                ),
                SizedBox(height: 20.h),
                Text(
                  S.of(context).approveRequest,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  S.of(context).areYouSureYouWantToApproveRequest,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    customButton(
                      title: S.of(context).no,
                      height: 38.h,
                      width: 135.w,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.onSecondaryAction,
                      ),
                      color: AppColors.secondaryAction,
                      function: () => Navigator.of(ctx).pop(),
                    ),
                    SizedBox(width: 23.w),
                    customButton(
                      height: 38.h,
                      width: 135.w,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      title: S.of(context).yes,
                      function: () {
                        Navigator.pop(ctx);
                        showAppDialog(
                          barrierDismissible: true,
                          builder: (dialogContext) => BlocProvider.value(
                            value: context.read<ApprovalsCubit>(),
                            child: ReasonForJustificationsDialog(
                              knowledgeId: widget.knowledgeId,
                            ),
                          ),
                          context: ctx,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ Show reject dialog
  void _showRejectDialog(bool isMobile, bool lightMode) {
    showAppDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Material(
          color: AppColors.transparent,
          child: Container(
            width: isMobile ? double.infinity : 411.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.chatBackground,
            ),
            padding: EdgeInsets.all(20.r),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lot_status_rejected.json',
                  height: 70.h,
                  width: 70.w,
                ),
                SizedBox(height: 20.h),
                Text(
                  S.of(context).rejectRequest,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  S.of(context).areYouSureYouWantToRejectRequest,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    customButton(
                      title: S.of(context).no,
                      height: 38.h,
                      width: 135.w,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.onSecondaryAction,
                      ),
                      color: AppColors.secondaryAction,
                      function: () => Navigator.of(ctx).pop(),
                    ),
                    SizedBox(width: 23.w),
                    customButton(
                      height: 38.h,
                      width: 135.w,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      title: S.of(context).yes,
                      function: () {
                        Navigator.pop(ctx);
                        showAppDialog(
                          barrierDismissible: true,
                          builder: (dialogContext) => BlocProvider.value(
                            value: context.read<ApprovalsCubit>(),
                            child: ResonForApprovalRemovingDialog(
                              knowledgeId: widget.knowledgeId,
                            ),
                          ),
                          context: ctx,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

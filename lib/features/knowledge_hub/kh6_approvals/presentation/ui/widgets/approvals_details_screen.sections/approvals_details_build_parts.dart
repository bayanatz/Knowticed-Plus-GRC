/// Module: knowledge_hub/kh6_approvals/presentation/ui/widgets
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_details_build_parts.dart
/// Description: Sections of the approvals details screen's build method,
///              split out so no build method is over 100 lines.
/// Author: Amr Mesbah
/// Created at: 20/10/2026

part of '../../pages/approvals_details_screen.dart';

/// The pieces the details screen's build() is made of.
mixin _ApprovalsDetailsBuildParts
    on
        State<ApprovalsDetailsScreen>,
        _ApprovalsDetailsSections,
        _ApprovalsDetailsSectionsBuilders {
  /// Reacts to approve / reject results by updating the shown status.
  void _onApprovalsState(BuildContext context, ApprovalsStates state) {
    if (!mounted) return;
    if (state is ApprovingKnowledgeSuccessState) {
      setState(() => currentStatus = 'published');
    }
    if (state is RejectingKnowledgeSuccessState) {
      setState(() => currentStatus = 'rejected');
    }
  }

  /// Title (wide screens) and the view / download / export buttons.
  Widget _buildDetailsHeader(bool isMobile) {
    return Row(
      mainAxisAlignment:
          isMobile ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
      children: [
        if (!isMobile)
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: 16.w),
              child: Text(
                '${_getLocalizedDocumentName()} ${S.of(context).details}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize20Weight600.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
            ),
          ),
        buildApprovalsActionButtons(
          knowledgeId: widget.knowledgeId,
          fileName: widget.fileName,
          fileType: widget.fileType,
          fileUrl: widget.fileUrl,
          department: departmentName ?? widget.department,
          fileExtension: widget.fileExtension,
        ),
      ],
    );
  }

  /// File icon, document name and (wide screens) the description.
  Widget _buildDocumentTitleRow(bool isMobile, bool lightMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomSvgImage(
          assetPath: getFileIcon(widget.fileExtension),
          height: 70.h,
          width: 70.w,
          fit: BoxFit.fill,
        ),
        SizedBox(width: 10.sp),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile) _buildMobileRequestedDate(lightMode),
              _buildTitleLabel(isMobile, lightMode),
              SizedBox(height: 5.h),
              if (!isMobile)
                Text(
                  _getLocalizedDescription(),
                  style: StyleText.fontSize13Weight500
                      .copyWith(color: AppColors.secondaryBlack)
                      .copyWith(color: AppColors.text),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// The description block shown under the title on phones.
  List<Widget> _buildMobileDescription() {
    return [
      Row(
        children: [
          CustomSvgImage(
            assetPath:
                'assets/icons_assets/knowledge_hub_assets/ic_org_department_limited.svg',
          ),
          SizedBox(width: 3.w),
          Text(
            S.of(context).description,
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
      Align(
        alignment: AlignmentDirectional.topStart,
        child: Text(
          _getLocalizedDescription(),
          style: StyleText.fontSize13Weight500
              .copyWith(color: AppColors.secondaryBlack)
              .copyWith(color: AppColors.blackButton),
        ),
      ),
    ];
  }

  /// Department, creator, contact and schedule rows.
  List<Widget> _buildCreatorInfoRows(bool isMobile, bool lightMode) {
    return [
      // ✅ Department and Document Type
      buildUserDataInfo(
        firstKey: "${S.of(context).owning_department}: ",
        firstValue: (departmentName ?? '').isEmpty
            ? S.of(context).khUnknownDepartment
            : _getLocalizedDepartmentName(departmentName!),
        secondKey: '${S.of(context).document_type}: ',
        secondValue: _getLocalizedDocumentType(widget.fileType),
        firstIcon: CustomSvgImage(
          assetPath:
              'assets/icons_assets/main_icons_assets/ic_org_briefcase.svg',
          height: 24.h,
          width: 24.w,
          fit: BoxFit.fill,
          color: AppColors.secondaryText.withValues(alpha: .7),
        ),
        secondIcon: CustomSvgImage(
          assetPath: 'assets/icons_assets/knowledge_hub_assets/ic_doctype.svg',
          height: 24.h,
          width: 24.w,
          fit: BoxFit.fill,
          color: AppColors.secondaryText.withValues(alpha: .7),
        ),
        isMobile: isMobile,
        lightMode: lightMode,
      ),
      SizedBox(height: isMobile ? 12.h : 15.h),

      // ✅ Requested By and Job Title
      buildUserDataInfo(
        firstKey: '${S.of(context).requestedBy}: ',
        firstValue: _getLocalizedEmployeeName(creatorData),
        secondKey: '${S.of(context).jobTitle}: ',
        secondValue: _getLocalizedJobTitle(creatorData),
        firstIcon: CustomSvgImage(
          assetPath:
              'assets/icons_assets/main_icons_assets/ic_user_profile.svg',
          height: 24.h,
          width: 24.w,
          fit: BoxFit.cover,
          color: AppColors.secondaryText.withValues(alpha: .7),
        ),
        secondIcon: CustomSvgImage(
          assetPath:
              'assets/icons_assets/main_icons_assets/ic_org_briefcase.svg',
          height: 24.h,
          width: 24.w,
          fit: BoxFit.fill,
          color: AppColors.secondaryText.withValues(alpha: .7),
        ),
        isMobile: isMobile,
        lightMode: lightMode,
        userPhoto: _buildCreatorAvatar(),
      ),
      SizedBox(height: isMobile ? 12.h : 15.h),
    ];
  }

  /// Contact and schedule rows.
  List<Widget> _buildContactAndScheduleRows(bool isMobile, bool lightMode) {
    final formattedStartDate = _formatDateTime(widget.startDate);
    final formattedEndDate = _formatDateTime(widget.endDate);
    final formattedStartTime = _formatTime(widget.startTime);
    final formattedEndTime = _formatTime(widget.endTime);

    return [
      // ✅ Email and Phone Number
      buildUserDataInfo(
        firstKey: '${S.of(context).email}: ',
        firstValue: creatorData?.currentemployeeEmail ?? widget.createdByEmail,
        secondKey: '${S.of(context).phoneNumber}: ',
        secondValue: _formatPhoneNumber(creatorData?.currentemployeePhone),
        firstIcon: CustomSvgImage(
          assetPath: 'assets/icons_assets/main_icons_assets/ic_comms_sms.svg',
          height: 24.h,
          width: 24.w,
          fit: BoxFit.fill,
          color: AppColors.secondaryText.withValues(alpha: .7),
        ),
        secondIcon: CustomSvgImage(
          assetPath:
              'assets/icons_assets/main_icons_assets/ic_comms_phone_rounded.svg',
          height: 24.h,
          width: 24.w,
          fit: BoxFit.fill,
          color: AppColors.secondaryText.withValues(alpha: .7),
        ),
        isMobile: isMobile,
        lightMode: lightMode,
      ),

      // ✅ START DATE + TIME and END DATE + TIME
      if (formattedStartDate != null || formattedEndDate != null) ...[
        SizedBox(height: isMobile ? 12.h : 15.h),
        buildUserDataInfo(
          firstKey: '${S.of(context).start_date}: ',
          firstValue:
              formattedStartTime != null && formattedStartTime.isNotEmpty
                  ? '$formattedStartDate At $formattedStartTime'
                  : formattedStartDate ?? '-',
          secondKey: '${S.of(context).end_date}: ',
          secondValue: formattedEndTime != null && formattedEndTime.isNotEmpty
              ? '$formattedEndDate At $formattedEndTime'
              : formattedEndDate ?? '-',
          firstIcon: CustomSvgImage(
            assetPath:
                'assets/icons_assets/main_icons_assets/ic_time_calendar.svg',
            height: 24.h,
            width: 24.w,
            fit: BoxFit.fill,
            color: AppColors.secondaryText,
          ),
          secondIcon: CustomSvgImage(
            assetPath:
                'assets/icons_assets/main_icons_assets/ic_time_calendar.svg',
            height: 24.h,
            width: 24.w,
            fit: BoxFit.fill,
            color: AppColors.secondaryText,
          ),
          isMobile: isMobile,
          lightMode: lightMode,
        ),
      ],

      SizedBox(height: isMobile ? 12.h : 15.h),
    ];
  }

  /// The reason a removed document was removed.
  Widget _buildRemovalReason(bool isMobile) {
    return FutureBuilder<String?>(
      future: _getRemovalReason(widget.knowledgeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 20.h,
            child: Center(
              child: SizedBox(
                width: 16.w,
                height: 16.h,
                child: CircleProgressMaster.inline(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }

        final reason = snapshot.data;

        if (reason == null || reason.isEmpty) {
          return SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMobile) ...[
              // Mobile Layout
              _buildRemovalReasonMobile(reason),
            ] else ...[
              // Desktop Layout
              _buildRemovalReasonWide(reason),
            ],
            SizedBox(height: isMobile ? 12.h : 15.h),
          ],
        );
      },
    );
  }

  /// "Requested date" in the card's top corner (wide screens).
  Widget _buildRequestedDateCorner() {
    return PositionedDirectional(
      top: 8.h,
      end: 8.h,
      child: Row(
        children: [
          Text(
            '${S.of(context).requestedDate}: ',
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          Text(
            _formatDate(widget.createdTimestamp),
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.blackButton,
            ),
          ),
        ],
      ),
    );
  }

  /// Title and list of inquiries and comments.
  List<Widget> _buildCommentsSection() {
    return [
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          S.of(context).inquiriesAndComments,
          style: StyleText.fontSize20Weight600.copyWith(color: AppColors.text),
        ),
      ),
      SizedBox(height: 12.h),
      UniversalCommentSection(
        // Fixed height: the page around it already scrolls.
        isExpandable: false,
        fixedHeight: 400.h,
        // 22/10/2026: old- and new-format comments (KhCommentSource).
        source: KhCommentSource(knowledgeId: widget.knowledgeId),
        onCommentAdded: (_) =>
            khSystemLog(KhLogAction.submitInquiryComment), // System Logs §3
        currentUserId: context.read<ApprovalsCubit>().people.signedInEmail,
      ),
    ];
  }

  /// "Requested date" line above the title (phones).
  Widget _buildMobileRequestedDate(bool lightMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${S.of(context).requestedDate}: ',
          style: StyleText.fontSize10Weight400.copyWith(
            color: lightMode ? AppColors.secondaryText : AppColors.grey,
          ),
        ),
        Text(
          _formatDate(widget.createdTimestamp),
          style: StyleText.fontSize10Weight400.copyWith(
            color: AppColors.blackButton,
          ),
        ),
      ],
    );
  }

  /// Document name (phones) or the "Description" label (wide screens).
  Widget _buildTitleLabel(bool isMobile, bool lightMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (!isMobile)
              Row(
                children: [
                  CustomSvgImage(
                    assetPath:
                        'assets/icons_assets/knowledge_hub_assets/ic_org_department_limited.svg',
                    fit: BoxFit.fill,
                    width: 16.w,
                    height: 16.h,
                  ),
                  SizedBox(width: 6.w),
                ],
              ),
            Text(
              isMobile
                  ? _getLocalizedDocumentName()
                  : S.of(context).description,
              style: StyleText.fontSize14Weight400.copyWith(
                color: lightMode
                    ? isMobile
                        ? AppColors.blackButton
                        : AppColors.secondaryText
                    : isMobile
                        ? AppColors.white
                        : AppColors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Removal reason, stacked layout (phones).
  Widget _buildRemovalReasonMobile(String reason) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomSvgImage(
          assetPath: 'assets/icons_assets/main_icons_assets/ic_status.svg',
          fit: BoxFit.fill,
          width: 16.w,
          height: 16.h,
          color: AppColors.darkRed,
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${S.of(context).reasonOfRemoving}: ',
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.darkRed,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                reason,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Removal reason, single-row layout (wide screens).
  Widget _buildRemovalReasonWide(String reason) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 16.h,
          width: 16.w,
          child: CustomSvgImage(
            assetPath: 'assets/icons_assets/main_icons_assets/ic_status.svg',
            fit: BoxFit.fill,
            color: AppColors.darkRed,
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          '${S.of(context).reasonOfRemoving}: ',
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.darkRed,
          ),
        ),
        Expanded(
          child: Text(
            reason,
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// The creator's photo, or the default avatar.
  Widget _buildCreatorAvatar() {
    return creatorData?.currentemployeePhoto != null &&
            creatorData!.currentemployeePhoto.isNotEmpty
        ? CircleAvatar(
            radius: 16.r,
            backgroundImage: NetworkImage(creatorData!.currentemployeePhoto),
            onBackgroundImageError: (_, __) {},
            child: SizedBox(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomSvgImage(
                  assetPath:
                      'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png',
                  height: 32.r,
                  width: 32.r,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          )
        : CircleAvatar(
            radius: 16.r,
            backgroundColor: AppColors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: CustomSvgImage(
                assetPath:
                    'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png',
                height: 32.r,
                width: 32.r,
              ),
            ),
          );
  }
}

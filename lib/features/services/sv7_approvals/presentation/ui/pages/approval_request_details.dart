/// Module: services / sv7_approvals / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: approval_request_details.dart
/// Purpose: The approval details page: service, provider, requester,
///          approval cycle, comments and the Approve / Reject actions. All
///          reads and the decision are done by ApprovalRequestDetailsCubit;
///          the sections are separate widgets (approval_*_section.dart,
///          approval_details_actions.dart and the shared request widgets).
/// Author: Amr Mesbah
/// Created at: 02/02/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_comment_widget.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/current_user_context.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/approval_decision_service.dart';
import 'package:knowticed_plus/features/services/data/utils/approval_cycle.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/presentation/controller/request_details_lookup.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/approvals.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/my_request_service_info_card.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/request_reason_comments.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/controller/approval_request_details_cubit.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/controller/approval_request_details_state.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/ui/pages/approval_request_toggle.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/ui/widgets/approval_details_actions.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/ui/widgets/approval_provider_section.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/ui/widgets/approval_requester_section.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services/data/models/request_comment_fields.dart';

class ApprovalDetailsScreen extends StatelessWidget {
  const ApprovalDetailsScreen({
    super.key,
    required this.index,
    required this.approvalModel,
    this.fromTable = false,
    this.createServicesModel,
  });

  final ServicesHistoryModel approvalModel;
  final int index;

  /// Opened from a dashboard table: read-only, the provider can be changed.
  final bool fromTable;
  final ServicesHistoryModel? createServicesModel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApprovalRequestDetailsCubit(
        repository: context.read<CreateServicesRepository>(),
        approvalModel: approvalModel,
        lookup: context.read<RequestDetailsLookup>(),
        decisions: context.read<ApprovalDecisionService>(),
      )..initialize(),
      child: _ApprovalDetailsView(
        approvalModel: approvalModel,
        fromTable: fromTable,
      ),
    );
  }
}

class _ApprovalDetailsView extends StatefulWidget {
  const _ApprovalDetailsView({
    required this.approvalModel,
    required this.fromTable,
  });

  final ServicesHistoryModel approvalModel;
  final bool fromTable;

  @override
  State<_ApprovalDetailsView> createState() => _ApprovalDetailsViewState();
}

class _ApprovalDetailsViewState extends State<_ApprovalDetailsView> {
  bool _isCommentSectionExpanded = false;

  /// The request as last read (re-read after a provider change).
  late ServicesHistoryModel _model = widget.approvalModel;

  @override
  void initState() {
    super.initState();
    _refreshModel();
  }

  Future<void> _refreshModel() async {
    final refreshed = await context
        .read<ApprovalRequestDetailsCubit>()
        .refreshModelFromFirestore();
    if (refreshed != null && mounted) setState(() => _model = refreshed);
  }

  bool _isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 600 &&
        MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// This approver's own step. 'waiting' when an earlier approver has not
  /// approved yet: the buttons only show on the approver's turn (the
  /// repository re-checks the turn when the decision is saved).
  String? _myState() {
    final me = (CurrentUserContext.email ?? '').toLowerCase();
    final cycle = widget.approvalModel.currentApprovalCycle;
    final myIndex = cycle.indexWhere((e) => e.email?.toLowerCase() == me);
    if (myIndex == -1) return null;
    final earlierApproved = cycle
        .take(myIndex)
        .every((e) => (e.state ?? '').toLowerCase() == 'approved');
    final own = cycle[myIndex].state?.toLowerCase();
    return (own == 'pending' && !earlierApproved) ? 'waiting' : own;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApprovalRequestDetailsCubit,
        ApprovalRequestDetailsState>(
      builder: (context, state) {
        if (state is ApprovalRequestDetailsLoading) {
          return Container(
            color: AppColors.background,
            child: const Center(child: CircleProgressMaster()),
          );
        }
        final data = state.data;
        final serviceName = context.svcPick(
          data.serviceNameEnglish ??
              widget.approvalModel.currentServiceNameEnglish,
          data.serviceNameArabic ??
              widget.approvalModel.currentServiceNameArabic,
        );

        return SlideInContent(
          from: SlideFrom.bottom,
          child: Scaffold(
            body: SafeArea(
              child: SideFrameMasterServices(
                titleText: S.of(context).services,
                onFirstTap: () => Navigator.pop(context),
                secondTitle: widget.fromTable
                    ? FormatHelper.capitalize(serviceName)
                    : S.of(context).approvals,
                onSecondTap: () => navigateTo(context, ApprovalToggle()),
                thirdTitle: widget.fromTable
                    ? S.of(context).RequestedServicesDetails
                    : FormatHelper.capitalize(serviceName),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      if (!_isCommentSectionExpanded) ...[
                        Row(
                          children: [
                            SizedBox(width: 3.sp),
                            Text(
                              S.of(context).approval_request_details,
                              style: StyleText.fontSize16Weight600.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.sp),
                        _buildDetailsCard(context, data, serviceName),
                        SizedBox(height: 20.sp),
                      ],
                      _buildComments(context),
                      SizedBox(height: 20.sp),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailsCard(
    BuildContext context,
    ApprovalRequestDetailsData data,
    String serviceName,
  ) {
    final isMobile = ContextExtension(context).isPhone;
    final description = context.svcPick(
      data.serviceDescriptionEnglish ??
          widget.approvalModel.currentServiceDescriptionEnglish,
      data.serviceDescriptionArabic ??
          widget.approvalModel.currentServiceDescriptionArabic,
    );
    final requester = context.read<RequestDetailsLookup>().requesterInfo(
          widget.approvalModel.currentEmailRequester,
        );
    String orDash(String value) => value.isEmpty ? '-' : value;
    final displayCycle = ApprovalCycle.forDisplay(
      widget.approvalModel.currentApprovalCycle,
    );

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.card,
          ),
          child: Column(
            children: [
              MyRequestServiceInfoCard(
                imageUrl: widget.approvalModel.currentImageUrl,
                isMobile: isMobile,
                isTablet: ContextExtension(context).isTablet,
                isTabletLandscape: _isTabletLandscape(context),
                serviceNameToDisplay: serviceName,
                serviceDescriptionToDisplay: description,
                isLoadingServiceDetails: false,
              ),
              SizedBox(height: 20.h),
              if (isMobile) ...[
                MyRequestDescriptionWidget(
                  serviceDescriptionToDisplay: description,
                  isLoadingServiceDetails: false,
                ),
                SizedBox(height: 20.sp),
              ],
              ApprovalProviderSection(
                model: _model,
                fromTable: widget.fromTable,
                duration: data.serviceDuration ??
                    widget.approvalModel.currentDurationOfServices,
                durationUnit: data.serviceDurationUnit ??
                    widget.approvalModel.currentSelectedDurationUnit,
                state: data.currentState ?? 'pending',
                onProviderChanged: _refreshModel,
              ),
              SizedBox(height: 29.sp),
              _sectionTitle(
                context,
                S.of(context).RequesterDetails,
                StyleText.fontSize16Weight500,
              ),
              SizedBox(height: 10.sp),
              ApprovalRequesterSection(
                name: orDash(
                  context.svcPick(requester.nameEnglish, requester.nameArabic),
                ),
                department: orDash(
                  context.svcPick(
                    requester.departmentEnglish,
                    requester.departmentArabic,
                  ),
                ),
                jobTitle: orDash(
                  context.svcPick(
                    requester.jobTitleEnglish,
                    requester.jobTitleArabic,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              _sectionTitle(
                context,
                '${S.of(context).approvalCycle}: ',
                StyleText.fontSize14Weight400,
                color: AppColors.secondaryText,
              ),
              if (!isMobile) SizedBox(height: 15.h),
              if (displayCycle.isNotEmpty)
                isMobile
                    ? buildApprovalCycleMyRequest(
                        context,
                        false,
                        [],
                        displayCycle,
                      )
                    : Row(
                        children: [
                          approvalCycleViewLogic(context, displayCycle),
                        ],
                      ),
              RequestReasonComments(
                cancelReason: data.cancelReason,
                rejectCommentText: data.rejectCommentText,
                approveCommentText: data.approveCommentText,
                isMobile: isMobile,
              ),
              SizedBox(height: 20.h),
              if (!widget.fromTable)
                ApprovalDetailsActions(
                  myState: _myState(),
                  documentState: data.currentState,
                  serviceNameEnglish: data.serviceNameEnglish ??
                      widget.approvalModel.currentServiceNameEnglish,
                  serviceNameArabic: data.serviceNameArabic ??
                      widget.approvalModel.currentServiceNameArabic,
                ),
            ],
          ),
        ),
        _buildRequestDate(context, isMobile),
      ],
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String text,
    TextStyle style, {
    Color? color,
  }) {
    return Row(
      children: [
        Text(text, style: style.copyWith(color: color ?? AppColors.text)),
      ],
    );
  }

  Widget _buildRequestDate(BuildContext context, bool isMobile) {
    final timestamps = widget.approvalModel.timestamps;
    final requested = timestamps.isEmpty
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(timestamps.first);
    final base = isMobile
        ? StyleText.fontSize10Weight400
        : StyleText.fontSize12Weight400;
    return Padding(
      padding: EdgeInsets.all(10.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '${S.of(context).requestDate}: ',
            style: base.copyWith(color: AppColors.secondaryText),
          ),
          Text(
            DateFormat(
              'dd MMM yyyy',
              Localizations.localeOf(context).toString(),
            ).format(requested),
            style: base.copyWith(color: AppColors.text),
          ),
        ],
      ),
    );
  }

  Widget _buildComments(BuildContext context) {
    return UniversalCommentSection(
      isExpandable: true,
      collectionPath: getBaseUrl(FirestoreCollections.commentsRoot),
      filterFields: {
        RequestCommentFields.requestId: widget.approvalModel.currentId,
      },
      currentUserId: CurrentUserContext.email ?? '',
      fixedHeight: _isCommentSectionExpanded ? null : 400.h,
      onExpandChanged: (bool expanded) {
        setState(() => _isCommentSectionExpanded = expanded);
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
}

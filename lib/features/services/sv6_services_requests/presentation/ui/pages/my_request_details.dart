/// Module: services / sv6_services_requests / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: my_request_details.dart
/// Purpose: The "My request" details page: the request's status, service,
///          provider, approval cycle, comments and the Cancel action. All
///          reads and writes are done by MyRequestDetailsCubit.
/// Author: Amr Mesbah
/// Created at: 02/07/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/data_source/remote_data_source/services_notification_service.dart';
import 'package:knowticed_plus/features/services/data/utils/approval_cycle.dart';
import 'package:knowticed_plus/features/services/data/utils/request_status.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/my_request_details_cubit.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/my_request_details_state.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/pages/request_services_toggle.dart';
import 'package:knowticed_plus/features/services/presentation/widgets/approvals.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/my_request_cancel_button.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/my_request_service_info_card.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/my_request_status_footer.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/request_provider_section.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/request_reason_comments.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/ui/widgets/request_status_style.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services/data/models/request_comment_fields.dart';

class MyRequestDetails extends StatelessWidget {
  const MyRequestDetails({required this.myRequestDetailsModel, super.key});

  final ServicesHistoryModel myRequestDetailsModel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyRequestDetailsCubit(
        repository: context.read<CreateServicesRepository>(),
        notifications: context.read<ServicesNotificationService>(),
        model: myRequestDetailsModel,
        requesterEmail: CurrentUserContext.email ?? '',
      )..initialize(),
      child: _MyRequestDetailsView(
        myRequestDetailsModel: myRequestDetailsModel,
      ),
    );
  }
}

/// Status, border colour and icon of the request as shown on the page.
class _StatusView {
  const _StatusView(this.status, this.borderColor, this.iconAsset);

  final String status;
  final Color borderColor;
  final String iconAsset;
}

class _MyRequestDetailsView extends StatefulWidget {
  const _MyRequestDetailsView({required this.myRequestDetailsModel});

  final ServicesHistoryModel myRequestDetailsModel;

  @override
  State<_MyRequestDetailsView> createState() => _MyRequestDetailsViewState();
}

class _MyRequestDetailsViewState extends State<_MyRequestDetailsView> {
  bool _isCommentExpanded = false;
  final TextEditingController _cancelController = TextEditingController();

  ServicesHistoryModel get _model => widget.myRequestDetailsModel;

  @override
  void dispose() {
    _cancelController.dispose();
    super.dispose();
  }

  bool _isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 600 &&
        MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Overall status: a final saved state wins, then the approval cycle; a
  /// request without approvers is approved.
  String _overallStatus(MyRequestDetailsData data) {
    final cycle = _model.currentApprovalCycle;
    final saved = RequestStatus.normalize(data.currentState);
    const finalStates = {
      RequestStatus.cancel,
      RequestStatus.inProgress,
      RequestStatus.breachedSla,
      RequestStatus.done,
    };
    if (cycle.isEmpty) {
      if (finalStates.contains(saved) || saved == RequestStatus.rejected) {
        return saved;
      }
      return RequestStatus.approved;
    }
    if (finalStates.contains(saved)) return saved;
    final rejection = ApprovalCycle.firstRejection(cycle);
    if (rejection != null) return RequestStatus.normalize(rejection.state);
    if (ApprovalCycle.hasState(cycle, RequestStatus.pending)) {
      return RequestStatus.pending;
    }
    if (ApprovalCycle.allApproved(cycle)) return RequestStatus.approved;
    return RequestStatus.pending;
  }

  _StatusView _statusView(
    String status,
    List<ServiceEmployeeModel> displayCycle,
  ) {
    var mark = status;
    final rejection = ApprovalCycle.firstRejection(displayCycle);
    if (status == RequestStatus.cancel) {
      mark = RequestStatus.cancel;
    } else if (rejection != null) {
      mark = RequestStatus.normalize(rejection.state);
    } else if (status != RequestStatus.inProgress &&
        status != RequestStatus.done &&
        status != RequestStatus.breachedSla &&
        ApprovalCycle.allApproved(displayCycle)) {
      mark = RequestStatus.approved;
    } else if (ApprovalCycle.hasState(displayCycle, RequestStatus.pending)) {
      mark = RequestStatus.pending;
    }
    return _StatusView(
      status,
      requestStatusBorderColor(mark),
      requestStatusIcon(mark),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyRequestDetailsCubit, MyRequestDetailsState>(
      listener: (context, state) {
        if (state is MyRequestDetailsCancelError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).svcCancelRequestFailed),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is MyRequestDetailsLoading) {
          return const Center(child: CircleProgressMaster());
        }
        final data = state.data;
        final serviceName = context.svcPick(
          data.serviceNameEnglish,
          data.serviceNameArabic,
        );

        return SlideInContent(
          from: SlideFrom.bottom,
          child: Scaffold(
            body: SafeArea(
              child: SideFrameMasterServices(
                titleText: FormatHelper.capitalize(S.of(context).services),
                onFirstTap: () => navigateTo(context, LayoutScreenServices()),
                secondTitle: FormatHelper.capitalize(
                  S.of(context).serviceRequests,
                ),
                onSecondTap: () => navigateTo(context, RequestServicesToggle()),
                thirdTitle: FormatHelper.capitalize(S.of(context).myRequests),
                onThirdTap: () => Navigator.pop(context),
                fourthTitle: data.isLoadingServiceDetails
                    ? '...'
                    : FormatHelper.capitalize(serviceName),
                // The frame already scrolls this child on a phone; see
                // `SideFrameScrollableBody`.
                child: SideFrameScrollableBody(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      if (!_isCommentExpanded) ...[
                        _buildHeader(context, data, serviceName),
                        SizedBox(height: 8.sp),
                        _buildDetailsCard(context, data),
                        SizedBox(height: 19.sp),
                      ],
                      _buildComments(context),
                      if (!_isCommentExpanded) SizedBox(height: 19.sp),
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

  Widget _buildHeader(
    BuildContext context,
    MyRequestDetailsData data,
    String serviceName,
  ) {
    final cycle = ApprovalCycle.forDisplay(_model.currentApprovalCycle);
    final saved = RequestStatus.normalize(data.currentState);
    final canCancel = (data.cancelReason?.isEmpty ?? true) &&
        !ApprovalCycle.hasRejection(cycle) &&
        saved != RequestStatus.cancel &&
        saved != RequestStatus.done;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          S.of(context).requestDetails,
          style: StyleText.fontSize16Weight600.copyWith(
            color: AppColors.blackButton,
          ),
        ),
        const Spacer(),
        if (canCancel)
          MyRequestCancelButton(
            isMobile: ContextExtension(context).isPhone,
            cancelController: _cancelController,
            serviceName: serviceName,
            onCancelled: () => _refreshLists(context),
          ),
      ],
    );
  }

  Future<void> _refreshLists(BuildContext context) async {
    final manager = ServicesManagerCubit.get(context);
    await manager.getMyRequestServices();
    final email = CurrentUserContext.email;
    if (email != null && email.isNotEmpty) {
      await manager.getRequestedServices(email);
    }
  }

  Widget _buildDetailsCard(BuildContext context, MyRequestDetailsData data) {
    final isMobile = ContextExtension(context).isPhone;
    final approvalCycle = _model.currentApprovalCycle;
    final displayCycle = ApprovalCycle.forDisplay(approvalCycle);
    final status = _overallStatus(data);
    final view = _statusView(status, displayCycle);
    final hasRejection = ApprovalCycle.hasRejection(displayCycle);
    final isCanceled =
        RequestStatus.normalize(data.currentState) == RequestStatus.cancel;
    final hasBreachedSlaAt3 = approvalCycle.length > 3 &&
        RequestStatus.normalize(approvalCycle[3].state) ==
            RequestStatus.breachedSla;
    final description = context.svcPick(
      data.descriptionEnglish,
      data.descriptionArabic,
    );

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(15.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.card,
            border: Border.all(
              color: hasBreachedSlaAt3 ? AppColors.red : AppColors.transparent,
            ),
          ),
          child: Column(
            children: [
              MyRequestServiceInfoCard(
                imageUrl: _model.currentImageUrl,
                isMobile: isMobile,
                isTablet: ContextExtension(context).isTablet,
                isTabletLandscape: _isTabletLandscape(context),
                serviceNameToDisplay: context.svcPick(
                  data.serviceNameEnglish,
                  data.serviceNameArabic,
                ),
                serviceDescriptionToDisplay: description,
                isLoadingServiceDetails: data.isLoadingServiceDetails,
              ),
              SizedBox(height: 20.h),
              if (isMobile) ...[
                MyRequestDescriptionWidget(
                  serviceDescriptionToDisplay: description,
                  isLoadingServiceDetails: data.isLoadingServiceDetails,
                ),
                SizedBox(height: 20.sp),
              ],
              RequestProviderSection(
                model: _model,
                provider: data.provider,
                isLoading: data.isLoadingProvider,
                isMobile: isMobile,
                duration: data.duration,
                durationUnit: data.durationUnit,
              ),
              SizedBox(height: 20.h),
              if (approvalCycle.isNotEmpty)
                _buildApprovalCycle(context, isMobile, displayCycle),
              RequestReasonComments(
                cancelReason: data.cancelReason,
                rejectCommentText: data.rejectCommentText,
                approveCommentText: data.approveCommentText,
                isMobile: isMobile,
              ),
              SizedBox(height: 20.h),
              MyRequestStatusFooter(
                requestId: _model.currentId,
                isMobile: isMobile,
                shouldShowReminder: ApprovalCycle.hasState(
                      approvalCycle,
                      RequestStatus.pending,
                    ) &&
                    !hasRejection &&
                    !isCanceled,
                reminderServiceName: context.svcPick(
                  _model.currentServiceNameEnglish,
                  _model.currentServiceNameArabic,
                ),
                currentApproverEmail: ApprovalCycle.currentApproverEmail(
                  displayCycle,
                ),
                hasApprovalCycle: approvalCycle.isNotEmpty,
                hasRejectionOrCancel:
                    RequestStatus.normalize(_model.currentState) ==
                            RequestStatus.cancel ||
                        (approvalCycle.isNotEmpty && hasRejection),
                borderColor: view.borderColor,
                iconAsset: view.iconAsset,
                stateLabel: FormatHelper.capitalize(context.svcStatus(status)),
              ),
            ],
          ),
        ),
        MyRequestDateRibbon(
          isMobile: isMobile,
          requestedTimestamp: _model.currentTimestamp,
          showBreachedSlaRibbon: hasBreachedSlaAt3,
        ),
      ],
    );
  }

  Widget _buildApprovalCycle(
    BuildContext context,
    bool isMobile,
    List<ServiceEmployeeModel> displayCycle,
  ) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).approvalCycle,
          style: StyleText.fontSize14Weight400.copyWith(
            color: lightMode ? AppColors.secondaryText : AppColors.white,
          ),
        ),
        if (!isMobile) SizedBox(height: 15.h),
        isMobile
            ? buildApprovalCycleMyRequest(context, false, [], displayCycle)
            : approvalCycleViewLogic(context, displayCycle),
      ],
    );
  }

  Widget _buildComments(BuildContext context) {
    return UniversalCommentSection(
      collectionPath: getBaseUrl(FirestoreCollections.commentsRoot),
      filterFields: {RequestCommentFields.requestId: _model.currentId},
      currentUserId: context.read<MyRequestDetailsCubit>().requesterEmail,
      isExpandable: true,
      fixedHeight: MediaQuery.of(context).size.height,
      onExpandChanged: (expanded) {
        setState(() => _isCommentExpanded = expanded);
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
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        sendIconColor: AppColors.textButton,
      ),
    );
  }
}

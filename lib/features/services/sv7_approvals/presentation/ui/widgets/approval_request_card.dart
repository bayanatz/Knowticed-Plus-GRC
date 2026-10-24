/// Module: services / sv7_approvals / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: approval_request_card.dart
/// Purpose: One card of the approvals list: service, requester, duration and
///          date, plus Approve / Reject when it is this approver's turn (or
///          the approver's own decision otherwise). The parent service is
///          read once per service through ApprovalRequestCubit (started in
///          initState, never in build) and the decision is made by the cubit.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/helper/current_user_context.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/domain/entities/parent_service_details.dart';
import 'package:knowticed_plus/features/services/helpers/services_feedback.dart';
import 'package:knowticed_plus/features/services/helpers/services_module_access.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/controller/approval_request_cubit.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/ui/pages/approval_request_details_toggle.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/ui/widgets/approval_request_card_action_buttons.dart';
import 'package:knowticed_plus/features/services/sv7_approvals/presentation/ui/widgets/approval_request_card_header.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class ApprovalRequestCard extends StatefulWidget {
  final ServicesHistoryModel service;
  final VoidCallback onRefresh;
  final bool isTablet;
  final bool isMobile;
  final bool isLandscape;
  final ApprovalRequestCubit cubit;

  const ApprovalRequestCard({
    super.key,
    required this.service,
    required this.onRefresh,
    required this.isTablet,
    required this.isMobile,
    required this.isLandscape,
    required this.cubit,
  });

  @override
  State<ApprovalRequestCard> createState() => _ApprovalRequestCardState();
}

class _ApprovalRequestCardState extends State<ApprovalRequestCard> {
  final TextEditingController _rejectController = TextEditingController();
  final TextEditingController _approveController = TextEditingController();
  late Future<ParentServiceDetails> _details;

  String get _myEmail => (CurrentUserContext.email ?? '').toLowerCase();

  @override
  void initState() {
    super.initState();
    _details = widget.cubit.serviceDetails(
      widget.service.currentParentServiceId,
    );
  }

  @override
  void didUpdateWidget(covariant ApprovalRequestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service.currentId != widget.service.currentId) {
      _approveController.clear();
      _rejectController.clear();
      _details = widget.cubit.serviceDetails(
        widget.service.currentParentServiceId,
      );
    }
  }

  @override
  void dispose() {
    _rejectController.dispose();
    _approveController.dispose();
    super.dispose();
  }

  static String _norm(String? s) {
    final v = (s ?? '').toLowerCase().trim();
    return v == 'cancelled' || v == 'canceled' ? 'cancel' : v;
  }

  /// Whether the signed-in approver may act now: the request is open, the
  /// approver has not decided yet and every earlier approver approved.
  bool _isMyTurn() {
    final serviceState = _norm(widget.service.currentState);
    if (serviceState == 'cancel' ||
        serviceState == 'done' ||
        serviceState == 'completed') {
      return false;
    }
    final list = widget.service.currentApprovalCycle;
    if (list.any((a) => _norm(a.state) == 'cancel')) return false;
    final myIndex = list.indexWhere(
      (e) => (e.email ?? '').toLowerCase() == _myEmail,
    );
    if (myIndex == -1) return false;
    final myState = _norm(list[myIndex].state);
    if (!(myState.isEmpty || myState == 'normal' || myState == 'pending')) {
      return false;
    }
    for (var i = 0; i < myIndex; i++) {
      if (_norm(list[i].state) != 'approved') return false;
    }
    return true;
  }

  /// The approver's own decision: pending, approved, rejected or cancel.
  String _myAction() {
    if (_norm(widget.service.currentState) == 'cancel') return 'cancel';
    final list = widget.service.currentApprovalCycle;
    if (list.any((a) => _norm(a.state) == 'cancel')) return 'cancel';
    final i = list.indexWhere((e) => (e.email ?? '').toLowerCase() == _myEmail);
    if (i == -1) return 'pending';
    final s = _norm(list[i].state);
    return const {'approved', 'rejected', 'cancel'}.contains(s) ? s : 'pending';
  }

  String _actionLabel(String action) {
    final t = S.of(context);
    switch (action) {
      case 'approved':
        return t.Approved;
      case 'rejected':
        return t.Rejected;
      case 'cancel':
        return t.canceled;
      default:
        return t.Pending;
    }
  }

  Color _actionColor(String action) {
    switch (action) {
      case 'approved':
        return AppColors.lightGreen;
      case 'rejected':
        return AppColors.red;
      case 'cancel':
        return AppColors.darkRed;
      default:
        return AppColors.orange;
    }
  }

  String _actionAsset(String action) {
    switch (action) {
      case 'approved':
        return 'assets/icons_assets/main_icons_assets/ic_status_approved_circle.svg';
      case 'rejected':
        return 'assets/icons_assets/main_icons_assets/ic_status_rejected.svg';
      case 'cancel':
        return 'assets/icons_assets/main_icons_assets/ic_action_close_circle_bold.svg';
      default:
        return 'assets/icons_assets/main_icons_assets/ic_status_pending_mixed.svg';
    }
  }

  void _refreshLists() {
    final manager = ServicesManagerCubit.get(context);
    manager.getAllServices();
    manager.getMyRequestServices();
    manager.loadProviderPerDocument();
    manager.getMyApprovalServices(_myEmail);
    widget.onRefresh();
  }

  Future<bool> _submit({
    required bool approve,
    required ParentServiceDetails details,
  }) async {
    if (_myEmail.isEmpty) return false;
    final manager = ServicesManagerCubit.get(context);
    final serviceId = widget.service.currentId;
    final docId = manager.serviceIdToFirestoreDocId[serviceId] ?? serviceId;
    final requester = widget.cubit.requester(
      widget.service.currentEmailRequester,
    );
    final messenger = ScaffoldMessenger.of(context);
    final s = S.of(context);
    final serviceEnglish = details.nameEnglish.isNotEmpty
        ? details.nameEnglish
        : widget.service.currentServiceNameEnglish;
    final serviceArabic = details.nameArabic.isNotEmpty
        ? details.nameArabic
        : widget.service.currentServiceNameArabic;
    final ok = approve
        ? await widget.cubit.approve(
            firestoreDocId: docId,
            approverEmail: _myEmail,
            comment: _approveController.text,
            displayServiceName: serviceEnglish,
            displayServiceNameArabic: serviceArabic,
            displayRequesterName: requester.nameEnglish,
            displayRequesterNameArabic: requester.nameArabic,
            requesterEmail: widget.service.currentEmailRequester,
          )
        : await widget.cubit.reject(
            firestoreDocId: docId,
            approverEmail: _myEmail,
            comment: _rejectController.text,
            displayServiceName: serviceEnglish,
            displayServiceNameArabic: serviceArabic,
            displayRequesterName: requester.nameEnglish,
            displayRequesterNameArabic: requester.nameArabic,
            requesterEmail: widget.service.currentEmailRequester,
          );
    if (!ok) {
      // SVC-REQ-10: say why the decision was refused.
      ServicesFeedback.showWarning(
        messenger,
        ServicesFeedback.refusalText(s, widget.cubit.lastRefusal),
      );
      return false;
    }
    // SVC-REQ-08: saved, but the next person was not notified.
    if (widget.cubit.lastNotificationFailed) {
      ServicesFeedback.showWarning(messenger, s.svcDecisionSavedNotifyFailed);
    }
    if (mounted) _refreshLists();
    return true;
  }

  void _openDialog({
    required bool approve,
    required ParentServiceDetails details,
  }) {
    final s = S.of(context);
    CustomDialogManager.showDialogFlow(
      confirmWidth: 411,
      context: context,
      customReasonTitle: approve ? s.reasonOfApproval : s.reasonOfRejection,
      confirmLottie:
          approve ? ServicesLottie.approved : ServicesLottie.rejected,
      confirmTitle: approve ? s.ApproveRequest : s.RejectRequest,
      confirmSubtitle: approve
          ? s.AreYouSureYouWantToApproveThisRequest
          : s.AreYouSureYouWantToRejectThisRequest,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: () async => true,
      comment: true,
      // A reason is required for both decisions.
      commentRequired: true,
      commentController: approve ? _approveController : _rejectController,
      commentSubmitText: s.submit,
      commentDiscardText: s.discard,
      onCommentSubmit: () => _submit(approve: approve, details: details),
      onSuccessDismissed: () {
        if (mounted) _refreshLists();
      },
      successLottie:
          approve ? ServicesLottie.approved : ServicesLottie.rejected,
      successTitle: approve ? s.Successful : s.RejectRequest,
      successSubtitle: approve
          ? s.YouSuccessfullyApprovedThisRequest
          : s.YouSuccessfullyRejectedThisRequest,
    );
  }

  Widget _actionBadge(String action) {
    final color = _actionColor(action);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomSvgImage.natural(
            assetPath: _actionAsset(action),
            width: 24.sp,
            height: 24.sp,
            fit: BoxFit.scaleDown,
          ),
          SizedBox(width: 8.w),
          Text(
            _actionLabel(action),
            style: StyleText.fontSize16Weight500.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticController.low();
        navigateTo(
          context,
          ServicesApprovalDetailsToggle(
            index: 0,
            approvalModel: widget.service,
          ),
        );
      },
      child: FutureBuilder<ParentServiceDetails>(
        future: _details,
        builder: (context, snapshot) =>
            _buildCard(context, snapshot.data ?? ParentServiceDetails.empty),
      ),
    );
  }

  Widget _buildCard(BuildContext context, ParentServiceDetails details) {
    final service = widget.service;
    final requester = widget.cubit.requester(service.currentEmailRequester);
    String orDash(String v) => v.isEmpty ? '-' : v;
    final duration = details.duration.isNotEmpty && details.unit.isNotEmpty
        ? context.svcDuration(details.duration, details.unit)
        : context.svcDuration(
            service.currentDurationOfServices,
            service.currentSelectedDurationUnit,
          );
    final action = _myAction();
    // "Approve And Reject" joins the turn and state checks: without it the
    // card and its status still show, just no buttons.
    final canAct = action == 'pending' &&
        _isMyTurn() &&
        ServicesModuleAccess.canApproveAndReject;

    return Container(
      padding: EdgeInsets.only(right: 15.w, left: 15.w, top: 15.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ApprovalRequestCardHeader(
            imageUrl: service.currentImageUrl.isNotEmpty
                ? service.currentImageUrl
                : details.imageUrl,
            displayServiceName: context.svcPick(
              details.nameEnglish.isNotEmpty
                  ? details.nameEnglish
                  : service.currentServiceNameEnglish,
              details.nameArabic.isNotEmpty
                  ? details.nameArabic
                  : service.currentServiceNameArabic,
            ),
            displayRequesterName: orDash(
              context.svcPick(requester.nameEnglish, requester.nameArabic),
            ),
            displayDepartment: orDash(
              context.svcPick(
                requester.departmentEnglish,
                requester.departmentArabic,
              ),
            ),
            displayJobTitle: orDash(
              context.svcPick(
                requester.jobTitleEnglish,
                requester.jobTitleArabic,
              ),
            ),
            displayDuration: duration,
            dateRequested: service.timestamps.isNotEmpty
                ? DateTime.fromMillisecondsSinceEpoch(service.timestamps.first)
                : DateTime.now(),
          ),
          if (canAct)
            ApprovalRequestCardActionButtons(
              isLightMode: Theme.of(context).brightness == Brightness.light,
              onRejectTap: () => _openDialog(approve: false, details: details),
              onApproveTap: () => _openDialog(approve: true, details: details),
            )
          else
            Center(child: _actionBadge(action)),
        ],
      ),
    );
  }
}

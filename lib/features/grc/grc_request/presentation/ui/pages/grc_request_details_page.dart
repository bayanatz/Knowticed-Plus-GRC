/// Module: GRC Request Management
/// Description: Details view for a single GRC Request. For
///              GrcRequestType.reassignChampion / reassignOwner, shows
///              Current vs New Champion/Owner, dates, note, and assigned
///              controls, with Approve/Reject actions while pending. Any
///              other request type renders a "not supported" placeholder.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: flutter_bloc, GrcRequestCubit, custom_confirm_dialog
library;

import 'package:grc_module/core/custom/3-custom_dropdwon_calander.dart';
import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
import 'package:grc_module/core/custom/11_custom_confirm_diaolog.dart';
import 'package:grc_module/core/custom/16-custom_card_styles.dart';
import 'package:grc_module/core/custom/21-custom_contact_card.dart';
import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/approval_status.dart';
import 'package:grc_module/core/custom/messaging_custom_button.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/core/helper/main_helper/employee_helper.dart';
import 'package:grc_module/core/constants/app_assets.dart';
import 'package:grc_module/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:grc_module/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/features/grc/control/domain/entities/control_entity.dart';
import 'package:grc_module/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:grc_module/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:grc_module/features/grc/grc_request/presentation/controller/grc_request_cubit.dart';
import 'package:grc_module/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:grc_module/core/helper/main_helper/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/grc/shared/helpers/grc_l10n.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';


class GrcRequestDetailsPage extends StatelessWidget {
  final GRCModuleEntity module;
  final GrcRequestEntity request;
  final bool isMyRequest;

  const GrcRequestDetailsPage({
    super.key,
    required this.module,
    required this.request,
    required this.isMyRequest,
  });

  @override
  Widget build(BuildContext context) {
    // GrcRequestCubit is provided by the caller (grc_requests_list_page.dart
    // wraps this page's route in BlocProvider.value using its own instance)
    // so the details page and list page share one Cubit and stay in sync
    // without a manual re-fetch. Only read/watch it here, don't resolve a
    // fresh one from GetIt.
    return _GrcRequestDetailsBody(
      module: module,
      request: request,
      isMyRequest: isMyRequest,
    );
  }
}

class _GrcRequestDetailsBody extends StatefulWidget {
  final GRCModuleEntity module;
  final GrcRequestEntity request;
  final bool isMyRequest;

  const _GrcRequestDetailsBody({
    required this.module,
    required this.request,
    required this.isMyRequest,
  });

  @override
  State<_GrcRequestDetailsBody> createState() => _GrcRequestDetailsBodyState();
}

class _GrcRequestDetailsBodyState extends State<_GrcRequestDetailsBody> {
  late GrcRequestEntity _request;
  final Map<String, List<ControlEntity>> _policyControls = {};
  bool _isLoadingControls = true;

  @override
  void initState() {
    super.initState();
    _request = widget.request;
    _loadPolicyData();
  }

  Future<void> _loadPolicyData() async {
    final grcRequestCubit = context.read<GrcRequestCubit>();
    final polResult =
        await grcRequestCubit.getAllPolicies(moduleId: widget.module.moduleId);
    await polResult.fold(
      (failure) async {},
      (policies) async {
        for (final policy in policies) {
          final ctrlResult = await grcRequestCubit.getAllControlsForPolicy(
              moduleId: widget.module.moduleId, policyId: policy.id);
          ctrlResult.fold(
            (failure) {},
            (controls) {
              _policyControls[policy.id] = controls;
            },
          );
        }
      },
    );
    if (mounted) setState(() => _isLoadingControls = false);
  }

  ControlEntity? _getControlEntity(String policyId, String controlId) {
    final list = _policyControls[policyId];
    if (list != null) {
      for (final c in list) {
        if (c.id == controlId) return c;
      }
    }
    return null;
  }

  EmployeeEntityPro? _findEmployee(String email) {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return null;
    final employees =
        Get.find<MainCoreEmployeeController>().allEmployeesEntities ?? [];
    for (final e in employees) {
      if (e.email == email) return e;
    }
    return null;
  }

  String _employeeDisplayName(BuildContext context, String email) {
    final employee = _findEmployee(email);
    if (employee == null) return email;
    return EmployeeHelper.getEmployeeLocalizedName(
        employee: employee, context: context);
  }

  bool get _isOwnerRequest => _request.type == GrcRequestType.reassignOwner;

  String get _currentAssigneeEmail => _isOwnerRequest
      ? (_request.currentOwnerEmail ?? '')
      : (_request.currentChampionEmail ?? '');

  String get _newAssigneeEmail => _isOwnerRequest
      ? (_request.newOwnerEmail ?? '')
      : (_request.newChampionEmail ?? '');

  String get _currentAssigneeLabel => _isOwnerRequest
      ? S.of(context).currentControlOwner
      : S.of(context).currentControlChampion;

  String get _newAssigneeLabel =>
      _isOwnerRequest ? S.of(context).newControlOwner : S.of(context).newControlChampion;

  Widget _assigneeCard(BuildContext context, String email) {
    final employee = _findEmployee(email);
    final photo = employee != null
        ? EmployeeHelper.getEmployeeImage(employee: employee)
        : AppAssets.defaultEmployeeAvatar;
    final name = _employeeDisplayName(context, email);
    final dept = employee != null
        ? EmployeeHelper.getEmployeeLocalizeDepartment(
            employee: employee, context: context)
        : '';
    final jobTitle = employee != null
        ? (EmployeeHelper.getEmployeeLocalizedTitle(
                    employee: employee, context: context)
                ?.toString() ??
            '')
        : '';
    final phone = employee?.mobilePhone?.phone ?? grcMockPhoneFallback;
    return ContactCard(
      name: name,
      jobTitle: jobTitle.isNotEmpty ? jobTitle :grcTr(context, grcMockJobTitleFallback),
      department: dept.isNotEmpty ? dept :grcTr(context, grcMockDepartmentFallback),
      email: email,
      phone: phone,
      avatar: photo.startsWith('http') ? NetworkImage(photo) : null,
      onMessage: () {},
    );
  }

  Widget _assignedControlsChips(BuildContext context) {
    if (_isLoadingControls) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    final controls = _request.controls ?? [];
    if (controls.isEmpty) {
      return Text(
        S.of(context).noControlsAssigned,
        style: StyleText.fontSize12Weight400
            .copyWith(color: AppColors.secondaryText),
      );
    }
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: controls.map((c) {
        final ctrl = _getControlEntity(c.policyId, c.controlId);
        final cName = ctrl != null
            ? (context.isArabic ? ctrl.controlsNameAr : ctrl.controlsNameEn)
            : c.controlId;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(cName,
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.text)),
        );
      }).toList(),
    );
  }

  /// Mirrors GrcRequestsListPage's own `_canCancel` rule exactly: only the
  /// requester, only while pending, and only before the request's start
  /// date has arrived.
  bool get _canCancel =>
      widget.isMyRequest &&
      _request.status == ApprovalStatus.pending &&
      _request.startDate != null &&
      _request.startDate!.isAfter(DateTime.now());

  void _onCancel(BuildContext context) {
    showConfirmDialog(
      context: context,
      title: S.of(context).CancelRequest,
      subtitle: S.of(context).AreYousureYouWanttoCancelThisRequest,
      cancelLabel: S.of(context).no,
      confirmLabel: S.of(context).yes,
      onConfirm: () {
        context.read<GrcRequestCubit>().cancelRequest(
              moduleId: widget.module.moduleId,
              requestId: _request.id,
            );
      },
    );
  }

  Widget _cancelButton(BuildContext context) {
    return CustomButton(
      width: 100.w,
      horizontalPadding: 10,
      verticalPadding: 6,
      onTap: () => _onCancel(context),
      buttonText: S.of(context).Cancel,
    );
  }

  void _onApprove() {
    showConfirmDialog(
      context: context,
      title: S.of(context).ApproveRequest,
      subtitle: S.of(context).AreYouSureYouWantToApproveThisRequest,
      onConfirm: () {
        context.read<GrcRequestCubit>().approveRequest(
              moduleId: widget.module.moduleId,
              requestId: _request.id,
            );
      },
    );
  }

  void _onReject() {
    showCommentDialog(
      context: context,
      title: S.of(context).ReasonOfRejection,
      fieldLabel: S.of(context).Justifications,
      onSubmit: (reason) {
        context.read<GrcRequestCubit>().rejectRequest(
              moduleId: widget.module.moduleId,
              requestId: _request.id,
              reason: reason,
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GrcRequestCubit, GrcRequestState>(
      listener: (context, state) {
        if (state is GrcRequestActionSuccess &&
            state.request.id == _request.id) {
          setState(() => _request = state.request);
        } else if (state is GrcRequestFailure) {
          CustomDialogManager.showMessage(
            context: context,
            lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
            title: S.of(context).unsuccessful,
            subtitle: '${S.of(context).actionFailed} ${state.message}',
          );
        }
      },
      builder: (context, state) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final isSupportedRequestType = _request.type.isReassignment;
    if (!isSupportedRequestType) {
      return _buildUnsupportedRequestTypeScaffold(context);
    }
    return _buildReassignmentScaffold(context);
  }

  /// Placeholder shown for any [GrcRequestType] other than the two
  /// reassignment types this page renders full details for.
  Widget _buildUnsupportedRequestTypeScaffold(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaginationAppBar(
                screensTitles: [
                  widget.module.moduleNameEn,
                  S.of(context).requests,
                  S.of(context).requestDetails
                ],
              ),
              SizedBox(height: 40.h),
              Center(child: Text(S.of(context).thisRequestTypeIsNotSupportedYet)),
            ],
          ),
        ),
      ),
    );
  }

  /// Main scaffold for reassignChampion / reassignOwner requests: app bar,
  /// current/new assignee sections, and the approve/reject or decided-status
  /// footer.
  Widget _buildReassignmentScaffold(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: PaginationAppBar(
                      screensTitles: [
                        S.of(context).grc,
                        context.isArabic
                            ? widget.module.moduleNameAr
                            : widget.module.moduleNameEn,
                        S.of(context).requestsDetails,
                      ],
                    ),
                  ),
                  if (_canCancel) _cancelButton(context),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      _buildCurrentAssigneeSection(context),
                      SizedBox(height: 16.h),
                      _buildNewAssigneeSection(context, dateFormat),
                      SizedBox(height: 24.h),
                      _buildActionOrStatusSection(context),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "Current Control Champion/Owner" card: assignee contact info plus the
  /// controls presently assigned to them.
  Widget _buildCurrentAssigneeSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_currentAssigneeLabel,
              style: StyleText.fontSize16Weight600
                  .copyWith(color: AppColors.text)),
          SizedBox(height: 8.h),
          _assigneeCard(context, _currentAssigneeEmail),
          SizedBox(height: 20.h),
          Text(S.of(context).assignedControls,
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.text)),
          SizedBox(height: 8.h),
          _assignedControlsChips(context),
        ],
      ),
    );
  }

  /// "New Control Champion/Owner" card: assignee contact info, the requested
  /// start/end dates, the request note, and the (same) assigned controls.
  Widget _buildNewAssigneeSection(BuildContext context, DateFormat dateFormat) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_newAssigneeLabel,
              style: StyleText.fontSize16Weight600
                  .copyWith(color: AppColors.text)),
          SizedBox(height: 8.h),
          _assigneeCard(context, _newAssigneeEmail),
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: IgnorePointer(
                  child: CustomDropdownCalendar(
                    label: S.of(context).startDate,
                    hint: S.of(context).chooseTheDate,
                    value: _request.startDate,
                    fillColor: AppColors.background,
                    dateFormatter: dateFormat.format,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: IgnorePointer(
                  child: CustomDropdownCalendar(
                    label: S.of(context).endDate,
                    hint: S.of(context).chooseTheDate,
                    value: _request.endDate,
                    fillColor: AppColors.background,
                    dateFormatter: dateFormat.format,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(S.of(context).request_note,
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.text)),
          SizedBox(height: 6.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _request.note.isNotEmpty ? _request.note : S.of(context).Texthere,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: _request.note.isNotEmpty
                        ? AppColors.text
                        : AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${_request.note.length}/500',
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryText),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Text(S.of(context).assignedControls,
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.text)),
          SizedBox(height: 8.h),
          _assignedControlsChips(context),
        ],
      ),
    );
  }

  /// Approve/Reject buttons for an approver viewing a pending request;
  /// otherwise a read-only status banner (pending-for-requester, approved,
  /// rejected-with-reason, or canceled).
  Widget _buildActionOrStatusSection(BuildContext context) {
    if (_request.status == ApprovalStatus.pending && !widget.isMyRequest) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          customButtonWithSvg(
            colorBorder: AppColors.red,
            space: 8.w,
            widthImage: 18.w,
            heightImage: 18.h,
            image: "assets/icons_assets/data_grc_assets/icons_icon _trash.svg",
            title: S.of(context).Reject,
            function: _onReject,
            color: AppColors.red,
            textStyle:
                StyleText.fontSize16Weight500.copyWith(color: Colors.white),
            svgColor: Colors.white,
          ),
          SizedBox(width: 16.w),
          customButtonWithSvg(
            colorBorder: AppColors.green,
            space: 8.w,
            widthImage: 18.w,
            heightImage: 18.h,
            image: 'assets/icons_assets/data_grc_assets/images_success.svg',
            title: S.of(context).Approve,
            function: _onApprove,
            color: AppColors.green,
            textStyle:
                StyleText.fontSize16Weight500.copyWith(color: Colors.white),
            svgColor: Colors.white,
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [_statusBanner(_request.status)],
    );
  }

  /// Read-only colored banner for any [ApprovalStatus], using
  /// [ApprovalStatus.color]/[GetApprovalStatusName.getName] as the single
  /// source of truth for status styling. `rejected` additionally shows the
  /// stored rejection reason.
  Widget _statusBanner(ApprovalStatus status) {
    final color = status.color;
    final text = status == ApprovalStatus.rejected
        ? '${S.of(context).status_rejected}: ${_request.rejectionReason ?? ''}'
        :grcTr(context, status.getName);
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: StyleText.fontSize14Weight500.copyWith(color: color),
      ),
    );
  }
}

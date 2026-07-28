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

import 'package:demo_app/core/custom/3-custom_dropdwon_calander.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/custom/21-custom_contact_card.dart';
import 'package:demo_app/core/enums/approval_status.dart';
import 'package:demo_app/core/local_widgets/main_widget/custom_button.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/core/constants/app_assets.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:demo_app/features/grc/grc_request/presentation/controller/grc_request_cubit.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
      ? 'Current Control Owner'.tr
      : 'Current Control Champion'.tr;

  String get _newAssigneeLabel =>
      _isOwnerRequest ? 'New Control Owner'.tr : 'New Control Champion'.tr;

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
      jobTitle: jobTitle.isNotEmpty ? jobTitle : grcMockJobTitleFallback.tr,
      department: dept.isNotEmpty ? dept : grcMockDepartmentFallback.tr,
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
        'No Controls assigned.'.tr,
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
      title: 'Cancel Request'.tr,
      subtitle: 'Are you sure you want to cancel this request?'.tr,
      cancelLabel: 'No'.tr,
      confirmLabel: 'Yes'.tr,
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      onTap: () => _onCancel(context),
      buttonText: 'Cancel'.tr,
    );
  }

  void _onApprove() {
    showConfirmDialog(
      context: context,
      title: 'Approve Request'.tr,
      subtitle: 'Are you sure you want to approve this request?'.tr,
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
      title: 'Reason Of Rejection'.tr,
      fieldLabel: 'Justifications'.tr,
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
          showErrorDialog(
            context: context,
            subtitle: '${'Action failed: '.tr} ${state.message}',
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
                  'Requests'.tr,
                  'Request Details'.tr
                ],
              ),
              SizedBox(height: 40.h),
              Center(child: Text('This request type is not supported yet.'.tr)),
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
                        'GRC'.tr,
                        context.isArabic
                            ? widget.module.moduleNameAr
                            : widget.module.moduleNameEn,
                        'Requests Details'.tr,
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
          Text('Assigned Controls'.tr,
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
                    label: 'Start Date'.tr,
                    hint: 'Choose The Date'.tr,
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
                    label: 'End Date'.tr,
                    hint: 'Choose The Date'.tr,
                    value: _request.endDate,
                    fillColor: AppColors.background,
                    dateFormatter: dateFormat.format,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text('Request Note'.tr,
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
                  _request.note.isNotEmpty ? _request.note : 'Text here'.tr,
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
          Text('Assigned Controls'.tr,
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
            title: 'Reject'.tr,
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
            title: 'Approve'.tr,
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
        ? '${'Rejected'.tr}: ${_request.rejectionReason ?? ''}'
        : status.getName.tr;
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

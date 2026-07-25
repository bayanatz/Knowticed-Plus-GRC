/// Module: GRC Request Management
/// Description: Details view for a single GRC Request. For
///              GrcRequestType.reassignChampion, shows Current vs New
///              Control Champion, dates, note, and assigned controls, with
///              Approve/Reject actions while pending. Any other request
///              type renders a "not supported" placeholder.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: flutter_bloc, get_it, GrcRequestCubit, custom_confirm_dialog

import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/enums/approval_status.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:demo_app/features/grc/grc_request/presentation/controller/grc_request_cubit.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class GrcRequestDetailsPage extends StatelessWidget {
  final GRCModuleEntity module;
  final GrcRequestEntity request;

  const GrcRequestDetailsPage({
    super.key,
    required this.module,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GrcRequestCubit>(
      create: (_) => GetIt.instance<GrcRequestCubit>(),
      child: _GrcRequestDetailsBody(module: module, request: request),
    );
  }
}

class _GrcRequestDetailsBody extends StatefulWidget {
  final GRCModuleEntity module;
  final GrcRequestEntity request;

  const _GrcRequestDetailsBody({required this.module, required this.request});

  @override
  State<_GrcRequestDetailsBody> createState() => _GrcRequestDetailsBodyState();
}

class _GrcRequestDetailsBodyState extends State<_GrcRequestDetailsBody> {
  late GrcRequestEntity _request;

  @override
  void initState() {
    super.initState();
    _request = widget.request;
  }

  EmployeeEntityPro? _findEmployee(String email) {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return null;
    final employees = Get.find<MainCoreEmployeeController>().allEmployeesEntities ?? [];
    for (final e in employees) {
      if (e.email == email) return e;
    }
    return null;
  }

  String _employeeDisplayName(BuildContext context, String email) {
    final employee = _findEmployee(email);
    if (employee == null) return email;
    return EmployeeHelper.getEmployeeLocalizedName(employee: employee, context: context);
  }

  Widget _championCard(BuildContext context, String title, String email) {
    final employee = _findEmployee(email);
    final photo = employee != null
        ? EmployeeHelper.getEmployeeImage(employee: employee)
        : 'assets/icons_assets/main_icons_assets/assets_male.svg';
    final name = _employeeDisplayName(context, email);
    final dept = employee != null
        ? EmployeeHelper.getEmployeeLocalizeDepartment(employee: employee, context: context)
        : '';
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [BoxShadow(color: AppColors.dropShadow, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text)),
          SizedBox(height: 8.h),
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: photo.startsWith('http') ? NetworkImage(photo) : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                    if (dept.isNotEmpty)
                      Text(dept, style: StyleText.fontSize12Weight500.copyWith(color: AppColors.secondaryText)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
        if (state is GrcRequestActionSuccess && state.request.id == _request.id) {
          setState(() => _request = state.request);
        } else if (state is GrcRequestFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Action failed: ${state.message}')),
          );
        }
      },
      builder: (context, state) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_request.type != GrcRequestType.reassignChampion) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaginationAppBar(
                  screensTitles: [widget.module.moduleNameEn, 'Requests'.tr, 'Request Details'.tr],
                ),
                SizedBox(height: 40.h),
                Center(child: Text('This request type is not supported yet.'.tr)),
              ],
            ),
          ),
        ),
      );
    }

    final dateFormat = DateFormat('d MMM yyyy');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaginationAppBar(
                screensTitles: [widget.module.moduleNameEn, 'Requests'.tr, 'Request Details'.tr],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      _championCard(context, 'Current Control Champion'.tr,
                          _request.currentChampionEmail ?? ''),
                      SizedBox(height: 16.h),
                      _championCard(context, 'New Control Champion'.tr,
                          _request.newChampionEmail ?? ''),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${'Start Date'.tr}: ${_request.startDate != null ? dateFormat.format(_request.startDate!) : '-'}',
                              style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${'End Date'.tr}: ${_request.endDate != null ? dateFormat.format(_request.endDate!) : '-'}',
                              style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Text('Request Note'.tr, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                      SizedBox(height: 6.h),
                      Text(_request.note, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText)),
                      SizedBox(height: 20.h),
                      Text('Assigned Controls'.tr, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: (_request.controls ?? []).map((c) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(c.controlId, style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 40.h),
                      if (_request.status == ApprovalStatus.pending)
                        Row(
                          children: [
                            Expanded(
                              child: customButton(
                                title: 'Reject'.tr,
                                function: _onReject,
                                color: Colors.red,
                                textStyle: StyleText.fontSize16Weight500.copyWith(color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: customButton(
                                title: 'Approve'.tr,
                                function: _onApprove,
                                color: Colors.green,
                                textStyle: StyleText.fontSize16Weight500.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: _request.status == ApprovalStatus.approved
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            _request.status == ApprovalStatus.approved
                                ? 'Approved'.tr
                                : '${'Rejected'.tr}: ${_request.rejectionReason ?? ''}',
                            style: StyleText.fontSize14Weight500.copyWith(
                              color: _request.status == ApprovalStatus.approved ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
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
}

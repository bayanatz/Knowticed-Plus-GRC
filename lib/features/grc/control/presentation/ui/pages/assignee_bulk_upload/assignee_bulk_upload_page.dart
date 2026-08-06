/// Module: GRC Assignee Bulk Upload (shared by Control Owner + Control Champion)
/// Description: The "Bulk Upload" drag & drop / browse screen. Loads the
///              module's Policies/Controls/system-users first (validation
///              needs them), then parses the selected workbook via
///              parseAssigneeExcel() and, on success, opens the editable
///              preview table under a fresh AssigneeBulkUploadCubit; on a
///              header mismatch or empty file it shows an inline error
///              instead of navigating. Mirrors policy_bulk_upload_page.dart.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-26
/// Dependencies: desktop_drop, file_picker, AssigneeBulkUploadCubit, assignee_excel_parser.dart

import 'dart:io';

import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/features/grc/control/domain/entities/control_entity.dart';
import 'package:grc_module/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:grc_module/features/grc/control/presentation/ui/pages/assignee_bulk_upload/assignee_bulk_upload_cubit.dart';
import 'package:grc_module/features/grc/control/presentation/ui/pages/assignee_bulk_upload/assignee_bulk_upload_preview_page.dart';
import 'package:grc_module/features/grc/control/presentation/ui/pages/assignee_bulk_upload/assignee_excel_parser.dart';
import 'package:grc_module/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:grc_module/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:grc_module/core/helper/main_helper/pagination_app_bar.dart';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Border, BorderStyle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_it/get_it.dart';
import 'package:grc_module/generated/l10n.dart';

/// class name: [AssigneeBulkUploadPage]
///
/// purpose: let the user pick or drop an Excel workbook of Owner/Champion
///          assignments, parse it, and open the editable preview table on
///          success. Entity-agnostic: [assigneeLabel] drives every visible
///          string and [createAssignee] drives what actually gets created.
class AssigneeBulkUploadPage extends StatefulWidget {
  final String moduleId;

  /// e.g. 'Control Owner' or 'Control Champion' — used in titles/messages.
  final String assigneeLabel;

  final AssigneeBulkCreateCallback createAssignee;

  const AssigneeBulkUploadPage({
    super.key,
    required this.moduleId,
    required this.assigneeLabel,
    required this.createAssignee,
  });

  @override
  State<AssigneeBulkUploadPage> createState() => _AssigneeBulkUploadPageState();
}

class _AssigneeBulkUploadPageState extends State<AssigneeBulkUploadPage> {
  bool _isDragging = false;
  bool _isProcessing = false;
  String? _errorMessage;

  bool _isLoadingPrereqs = true;
  List<PolicyEntity> _allPolicies = [];
  final Map<String, List<ControlEntity>> _policyControls = {};

  @override
  void initState() {
    super.initState();
    _loadPrereqs();
  }

  Future<void> _loadPrereqs() async {
    final polResult = await GetIt.instance<GetAllPoliciesUseCase>()
        .call(moduleId: widget.moduleId);
    await polResult.fold(
      (failure) async {},
      (policies) async {
        _allPolicies = policies;
        for (final policy in policies) {
          final ctrlResult = await GetIt.instance<GetAllControlsUseCase>()
              .call(moduleId: widget.moduleId, policyId: policy.id);
          ctrlResult.fold(
            (failure) {},
            (controls) {
              _policyControls[policy.id] = controls;
            },
          );
        }
      },
    );
    if (mounted) setState(() => _isLoadingPrereqs = false);
  }

  List<EmployeeEntityPro> get _employees {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return [];
    return Get.find<MainCoreEmployeeController>().allEmployeesEntities ?? [];
  }

  Future<void> _pickAndParseExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    var bytes = file.bytes;
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }
    if (bytes == null) {
      setState(() => _errorMessage = S.of(context).unableToReadTheSelectedFile);
      return;
    }
    await _processBytes(bytes);
  }

  Future<void> _onDragDone(DropDoneDetails details) async {
    setState(() => _isDragging = false);
    if (details.files.isEmpty) return;

    final file = details.files.first;
    final lowerName = file.name.toLowerCase();
    if (!lowerName.endsWith('.xlsx') && !lowerName.endsWith('.xls')) {
      setState(
          () => _errorMessage = S.of(context).pleaseDropAnExcelFileXlsxOrXls);
      return;
    }
    await _processBytes(await file.readAsBytes());
  }

  Future<void> _processBytes(List<int> bytes) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final result = parseAssigneeExcel(bytes);

    if (!mounted) return;
    setState(() => _isProcessing = false);

    switch (result) {
      case AssigneeExcelParseSuccess(:final rows):
        final activated = await Navigator.push<bool>(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => BlocProvider<AssigneeBulkUploadCubit>(
              create: (_) => AssigneeBulkUploadCubit(
                createAssignee: widget.createAssignee,
                parsedRows: rows,
                employees: _employees,
                allPolicies: _allPolicies,
                policyControls: _policyControls,
              ),
              child: AssigneeBulkUploadPreviewPage(
                moduleId: widget.moduleId,
                assigneeLabel: widget.assigneeLabel,
              ),
            ),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
        if (activated == true && mounted) {
          Navigator.pop(context, true);
        }
      case AssigneeExcelParseHeaderMismatch(:final message):
        setState(() => _errorMessage = message);
      case AssigneeExcelParseEmpty():
        setState(() => _errorMessage = S.of(context).noDataRowsFoundInTheExcelFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPrereqs) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PaginationAppBar(
                screensTitles: [S.of(context).grc, '${widget.assigneeLabel} ${S.of(context).bulkUpload}'],
              ),
              SizedBox(height: 15.h),
              Expanded(
                child: DropTarget(
                  onDragEntered: (_) => setState(() => _isDragging = true),
                  onDragExited: (_) => setState(() => _isDragging = false),
                  onDragDone: _onDragDone,
                  child: GestureDetector(
                    onTap: _pickAndParseExcel,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _isDragging
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: _isProcessing
                            ? CircularProgressIndicator(color: AppColors.primary)
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons_assets/main_icons_assets/uploadfile.svg',
                                    width: 100.sp,
                                    height: 100.sp,
                                  ),
                                  SizedBox(height: 27.sp),
                                  Text(
                                    S.of(context).dragDropHere,
                                    style: StyleText.fontSize20Weight500
                                        .copyWith(color: AppColors.text),
                                  ),
                                  SizedBox(height: 8.sp),
                                  Text(
                                    S.of(context).or,
                                    style: StyleText.fontSize16Weight500
                                        .copyWith(color: AppColors.secondaryText),
                                  ),
                                  if (_errorMessage != null) ...[
                                    SizedBox(height: 16.sp),
                                    Text(
                                      _errorMessage!,
                                      style: StyleText.fontSize14Weight500
                                          .copyWith(color: AppColors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 26.h),
              Row(
                children: [
                  customButton(
                    title: S.of(context).discard,
                    function: () => Navigator.pop(context),
                    width: 150.w,
                    height: 38.h,
                    color: AppColors.secondaryText,
                    textStyle: StyleText.fontSize16Weight600
                        .copyWith(color: AppColors.text),
                  ),
                  const Spacer(),
                  customButton(
                    title: S.of(context).browseFiles,
                    function: _pickAndParseExcel,
                    width: 150.w,
                    height: 38.h,
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize16Weight600
                        .copyWith(color: AppColors.textButton),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

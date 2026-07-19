// lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_page.dart
/// Module: GRC Control Bulk Upload
/// Description: The "Control Bulk Upload" drag & drop / browse screen,
///              scoped to a single Policy. Parses the selected workbook
///              via parseControlExcel() and, on success, provides
///              ChampionCubit/OwnerCubit (loading their module-scoped
///              lists) plus a fresh ControlBulkUploadCubit, then opens the
///              editable preview table. Mirrors
///              policy_bulk_upload_page.dart.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: desktop_drop, file_picker, ControlBulkUploadCubit,
///               ChampionCubit, OwnerCubit, control_excel_parser.dart

import 'dart:io';

import 'package:demo_app/core/custom/37-custom_navigate.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/create_control_usecase.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_cubit.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_preview_page.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser.dart';
import 'package:demo_app/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:demo_app/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Border, BorderStyle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';

class ControlBulkUploadPage extends StatefulWidget {
  final String moduleId;
  final String policyId;

  const ControlBulkUploadPage({
    super.key,
    required this.moduleId,
    required this.policyId,
  });

  @override
  State<ControlBulkUploadPage> createState() => _ControlBulkUploadPageState();
}

class _ControlBulkUploadPageState extends State<ControlBulkUploadPage> {
  bool _isDragging = false;
  bool _isProcessing = false;
  String? _errorMessage;

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
      setState(() => _errorMessage = 'Unable to read the selected file'.tr);
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
      setState(() => _errorMessage = 'Please drop an Excel file (.xlsx or .xls)'.tr);
      return;
    }
    await _processBytes(await file.readAsBytes());
  }

  Future<void> _processBytes(List<int> bytes) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final result = parseControlExcel(bytes);

    if (!mounted) return;
    setState(() => _isProcessing = false);

    switch (result) {
      case ControlExcelParseSuccess(:final rows):
        navigateTo(
          context,
          MultiBlocProvider(
            providers: [
              BlocProvider<ChampionCubit>(
                create: (_) => GetIt.instance<ChampionCubit>()
                  ..getAllChampions(moduleId: widget.moduleId),
              ),
              BlocProvider<OwnerCubit>(
                create: (_) => GetIt.instance<OwnerCubit>()
                  ..getAllOwners(moduleId: widget.moduleId),
              ),
            ],
            child: Builder(
              builder: (innerContext) => BlocProvider<ControlBulkUploadCubit>(
                create: (_) => ControlBulkUploadCubit(
                  createControlUseCase: GetIt.instance<CreateControlUseCase>(),
                  championCubit: innerContext.read<ChampionCubit>(),
                  ownerCubit: innerContext.read<OwnerCubit>(),
                  parsedRows: rows,
                ),
                child: ControlBulkUploadPreviewPage(
                  moduleId: widget.moduleId,
                  policyId: widget.policyId,
                ),
              ),
            ),
          ),
        );
      case ControlExcelParseHeaderMismatch(:final message):
        setState(() => _errorMessage = message);
      case ControlExcelParseEmpty():
        setState(() => _errorMessage = 'No data rows found in the Excel file'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PaginationAppBar(
                screensTitles: ['GRC'.tr, 'Control Bulk Upload'.tr],
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
                                    'Drag & Drop files here'.tr,
                                    style: StyleText.fontSize20Weight500
                                        .copyWith(color: AppColors.text),
                                  ),
                                  SizedBox(height: 8.sp),
                                  Text(
                                    'Or'.tr,
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
                    title: 'Discard'.tr,
                    function: () => Navigator.pop(context),
                    width: 150.w,
                    height: 38.h,
                    color: AppColors.secondaryText,
                    textStyle: StyleText.fontSize16Weight600
                        .copyWith(color: AppColors.text),
                  ),
                  const Spacer(),
                  customButton(
                    title: 'Browse Files'.tr,
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

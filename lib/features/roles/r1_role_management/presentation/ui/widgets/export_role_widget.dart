import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';

import 'package:grc_module/features/roles/r1_role_management/presentation/ui/widgets/success_dialog.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:grc_module/generated/l10n.dart';


import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';

class RoleExportDialog extends StatefulWidget {
  final List<RoleHistoryModel> roles;

  const RoleExportDialog({
    Key? key,
    required this.roles,
  }) : super(key: key);

  @override
  State<RoleExportDialog> createState() => _RoleExportDialogState();
}

class _RoleExportDialogState extends State<RoleExportDialog> {
  final TextEditingController controller = TextEditingController();
  OverlayEntry? _overlayEntry;
  bool _isExporting = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (controller.text.isEmpty) {
      controller.text = _getDefaultFileName(context);
    }
  }

  String _getDefaultFileName(BuildContext context) {
    final now = DateTime.now();
    final dateStr =
        "${now.day} ${_getMonthName(context, now.month)} ${now.year}";
    return "${S.of(context).rolesExport}_$dateStr";
  }

  String _getMonthName(BuildContext context, int month) {
    final s = S.of(context);
    return [
      s.jan,
      s.feb,
      s.mar,
      s.apr,
      s.may,
      s.jun,
      s.jul,
      s.aug,
      s.sep,
      s.oct,
      s.nov,
      s.dec,
    ][month - 1];
  }

  Future<void> _showLoadingIndicator(BuildContext context) async {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withOpacity(0.3),
          ),
          Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    final overlay = Overlay.of(context);
    overlay.insert(_overlayEntry!);
  }

  void _hideLoadingIndicator() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _exportData(BuildContext context) async {
    if (_isExporting) return;

    setState(() {
      _submitted = true;
    });

    final fileName = controller.text.trim();
    if (fileName.isEmpty) {
      Get.snackbar(
        S.of(context).error,
        S.of(context).pleaseEnterAFileName,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      await _showLoadingIndicator(context);

      if (widget.roles.isEmpty) {
        _hideLoadingIndicator();
        setState(() {
          _isExporting = false;
        });
        Get.snackbar(
          S.of(context).noData,
          S.of(context).noRolesToExport,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      String finalFileName = fileName.toLowerCase().endsWith('.csv')
          ? fileName
          : '$fileName.csv';

      final filePath = '${directory.path}/$finalFileName';
      final file = File(filePath);

      String csvContent = _generateCSVContent(context);
      await file.writeAsString(csvContent);

      _hideLoadingIndicator();
      setState(() {
        _isExporting = false;
      });

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      SuccessDialog.show(context);
    } catch (e) {
      _hideLoadingIndicator();
      setState(() {
        _isExporting = false;
      });

      Get.snackbar(
        S.of(context).exportFailed,
        '${S.of(context).error}: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  String _generateCSVContent(BuildContext context) {
    final s = S.of(context);
    List<List<dynamic>> rows = [
      [
        'No',
        s.roleName,
        s.roleNameArabic,
        s.roleDescription,
        s.roleDescriptionArabic,
        s.status,
        s.createdBy,
        s.createdAt,
        s.moduleName,
      ],
    ];

    int rowNumber = 1;
    for (var role in widget.roles) {
      List<String> selectedModules = role.currentSelectedModules;
      String createdByName = _extractNameFromEmail(role.currentCreatedBy);

      if (selectedModules.isEmpty) {
        rows.add([
          rowNumber,
          _safeString(role.currentRoleName),
          _safeString(role.currentRoleNameAr),
          _safeString(role.currentRoleDescription),
          _safeString(role.currentRoleDescriptionAr),
          _safeString(role.currentStatus.name),
          _safeString(createdByName),
          _formatDate(context, role.currentCreatedAt.toDate()),
          '-',
        ]);
        rowNumber++;
      } else {
        for (var moduleName in selectedModules) {
          rows.add([
            rowNumber,
            _safeString(role.currentRoleName),
            _safeString(role.currentRoleNameAr),
            _safeString(role.currentRoleDescription),
            _safeString(role.currentRoleDescriptionAr),
            _safeString(role.currentStatus.name),
            _safeString(createdByName),
            _formatDate(context, role.currentCreatedAt.toDate()),
            _safeString(_formatModuleName(moduleName)),
          ]);
          rowNumber++;
        }
      }
    }

    return _convertToCSV(rows);
  }

  String _extractNameFromEmail(String? email) {
    if (email == null || email.isEmpty) return '';
    String username = email.split('@').first;
    username = username
        .replaceAll('.', ' ')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');
    username = username.replaceAll(RegExp(r'\d'), '');
    List<String> words =
    username.split(' ').where((word) => word.isNotEmpty).toList();
    return words
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ');
  }

  String _formatModuleName(String moduleName) {
    return moduleName
        .split('_')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1)}'
        : '')
        .join(' ');
  }

  String _formatDate(BuildContext context, DateTime date) {
    return "${date.day} ${_getMonthName(context, date.month)} ${date.year} "
        "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  String _safeString(dynamic value) {
    if (value == null) return '';
    String str = value.toString();
    if (str.contains(',') || str.contains('"') || str.contains('\n')) {
      str = '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  String _convertToCSV(List<List<dynamic>> rows) {
    StringBuffer csvBuffer = StringBuffer();
    for (List<dynamic> row in rows) {
      csvBuffer.writeln(row.join(','));
    }
    return csvBuffer.toString();
  }

  @override
  void dispose() {
    _hideLoadingIndicator();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        width: 411.sp,
        padding: EdgeInsets.all(20.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30.sp,
                  height: 30.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: Center(
                    child: CustomSvgImage(assetPath: 
                      "assets/icons_assets/main_icons_assets/export_arrow.svg",
                      width: 16.sp,
                      height: 16.sp,
                      color: AppColors.textButton,
                    ),
                  ),
                ),
                SizedBox(width: 8.sp),
                Text(
                  S.of(context).exportRoles,
                  style: AppTextStyles.font16BlackSemiBoldCairo,
                ),
              ],
            ),
            SizedBox(height: 15.sp),
            CustomTextField(
              label: S.of(context).fileName,
              hint: S.of(context).enterFileName,
              controller: controller,
              onChanged: (_) => setState(() {}),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 5.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: customButton(
                    title: S.of(context).discard,
                    function:
                    _isExporting ? () {} : () => Navigator.pop(context),
                    height: 38.h,
                    color: lightMode ? Colors.grey[400] : Colors.grey[700],
                    textStyle: StyleText.fontSize14Weight400.copyWith(
                      color: lightMode ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  child: customButton(
                    title: _isExporting
                        ? S.of(context).exporting
                        : S.of(context).exportCsv,
                    function:
                    _isExporting ? () {} : () => _exportData(context),
                    height: 38.h,
                    color: AppColors.primary,
                    textStyle: AppTextStyles.font14BlackCairoMedium.copyWith(
                      color: AppColors.textButton,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
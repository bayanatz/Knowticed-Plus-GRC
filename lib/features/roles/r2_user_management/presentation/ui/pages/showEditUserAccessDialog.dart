import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/grc/core/widgets/custom_botton.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:grc_module/generated/l10n.dart';

import 'package:grc_module/features/roles/r2_user_management/domain/entity/user_permission_entity.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import './edit_select.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'package:grc_module/core/custom/5-custom_button.dart';
/// Shows the Edit User Access Dialog
/// Returns Map<String, dynamic> with 'role', 'accessGranted', 'accessRevoked' on success
/// Returns null on discard
Future<dynamic> showEditUserAccessDialog({
  required BuildContext context,
  required UserPermissionEntity userPermission,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<UserManagementAccessCubit>()),
        BlocProvider.value(value: context.read<RoleCubit>()),
      ],
      child: _EditUserAccessDialogContent(
        userPermission: userPermission,
      ),
    ),
  );
}

class _EditUserAccessDialogContent extends StatefulWidget {
  final UserPermissionEntity userPermission;

  const _EditUserAccessDialogContent({required this.userPermission});

  @override
  State<_EditUserAccessDialogContent> createState() =>
      _EditUserAccessDialogContentState();
}

class _EditUserAccessDialogContentState
    extends State<_EditUserAccessDialogContent> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final controller = context.read<UserManagementAccessCubit>();
      final roleCubit = context.read<RoleCubit>();

      final activeRoles = roleCubit.roles
          .where((r) => r.currentStatus == RoleStatus.active)
          .toList();

      controller.rolesName =
          activeRoles.map((r) => r.currentRoleName).toList();
      controller.rolesNameAr =
          activeRoles.map((r) => r.currentRoleNameAr).toList();

      if (widget.userPermission.accessName != null) {
        controller.newAccessSelectedRole = widget.userPermission.accessName;
      }

      if (widget.userPermission.startDate != null &&
          widget.userPermission.startDate!.isNotEmpty &&
          widget.userPermission.startDate != '-') {
        final parsed = _parseDate(widget.userPermission.startDate!);
        if (parsed != null) controller.accessGranted = parsed;
      }

      if (widget.userPermission.endDate != null &&
          widget.userPermission.endDate!.isNotEmpty &&
          widget.userPermission.endDate != '-') {
        final parsed = _parseDate(widget.userPermission.endDate!);
        if (parsed != null) controller.accessRevoked = parsed;
      }

      controller.emit(UserPermissionsDataLoaded());
    });
  }

  DateTime? _parseDate(String dateString) {
    if (dateString.isEmpty || dateString == '-') return null;

    String normalized = dateString;
    const arabicNums = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const westernNums = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < arabicNums.length; i++) {
      normalized = normalized.replaceAll(arabicNums[i], westernNums[i]);
    }

    try {
      if (normalized.contains('T') ||
          (normalized.contains('-') && !normalized.contains(' '))) {
        return DateTime.parse(normalized);
      }

      if (normalized.contains('/')) {
        final parts = normalized.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }

      if (normalized.contains(' ')) {
        final formats = [
          'dd MMM yyyy',
          'MMM dd, yyyy',
          'dd MMMM yyyy',
          'MMMM dd, yyyy',
          'MMM dd yyyy',
        ];
        for (final fmt in formats) {
          try {
            return DateFormat(fmt, 'en').parse(normalized);
          } catch (_) {}
        }

        final arabicMonths = {
          'يناير': 1, 'فبراير': 2, 'مارس': 3, 'أبريل': 4,
          'مايو': 5, 'يونيو': 6, 'يوليو': 7, 'أغسطس': 8,
          'سبتمبر': 9, 'أكتوبر': 10, 'نوفمبر': 11, 'ديسمبر': 12,
        };
        for (final entry in arabicMonths.entries) {
          if (normalized.contains(entry.key)) {
            final cleaned = normalized
                .replaceAll(entry.key, '')
                .replaceAll(',', '')
                .trim();
            final parts = cleaned.split(RegExp(r'\s+'));
            if (parts.length == 2) {
              final nums = parts.map((p) => int.tryParse(p)).toList();
              if (nums[0] != null && nums[1] != null) {
                final day = nums[0]! < 100 ? nums[0]! : nums[1]!;
                final year = nums[0]! > 100 ? nums[0]! : nums[1]!;
                return DateTime(year, entry.value, day);
              }
            }
          }
        }
      }
    } catch (e) {
    }

    return null;
  }

  void _onSaveTapped() {
    final controller = context.read<UserManagementAccessCubit>();
    final s = S.of(context);

    if (controller.newAccessSelectedRole == null ||
        controller.newAccessSelectedRole!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.pleaseSelectARoleType),   // ← use S.of(context) key
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (controller.accessGranted == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.pleaseSelectAccessGrantedDate),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (controller.accessRevoked == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.pleaseSelectAccessRevokedDate),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() => _isSaving = true);

    Future.microtask(() {
      if (!mounted) return;
      Navigator.of(context).pop({
        'role': controller.newAccessSelectedRole,
        'accessGranted': controller.accessGranted,
        'accessRevoked': controller.accessRevoked,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    // ── Detect locale direction ────────────────────────────────────────────
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final textDir = isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr;

    return Directionality(
      textDirection: textDir,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 330.w,
          height: 290.h,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          // ── Pass hint color down via Theme so EditAccessDetails picks it up ──
          child: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme:
              Theme.of(context).inputDecorationTheme.copyWith(
                hintStyle: TextStyle(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Form ──────────────────────────────────────────────────
                Expanded(
                  child: EditAccessDetails(),
                ),

                // ── Buttons ───────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.all(15.sp),
                  child: Row(
                    children: [
                      if (!_isSaving)
                        customButton(
                          title: S.of(context).discard,
                          textStyle: StyleText.fontSize16Weight400.copyWith(
                            color: lightMode ? Colors.black : Colors.white,
                          ),
                          function: () => Navigator.pop(context),
                          color:
                          lightMode ? Colors.grey[400] : Colors.grey[700],
                          width: 135.w,
                          height: 38.h,
                        ),

                      const Spacer(),

                      if (_isSaving)
                        SizedBox(
                          width: 38.h,
                          height: 38.h,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.5,
                          ),
                        )
                      else
                        customButton(
                          title: S.of(context).save,
                          function: _onSaveTapped,
                          color: AppColors.primary,
                          width: 135.w,
                          height: 38.h,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
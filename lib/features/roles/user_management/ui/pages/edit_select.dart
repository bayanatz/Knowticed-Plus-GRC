import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/custom_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/DatePicker.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/roles/role_management/controller/role_cubit.dart';
import 'package:demo_app/features/roles/user_management/controller/user_management_cubit.dart';

class EditAccessDetails extends StatefulWidget {
  const EditAccessDetails({super.key});

  @override
  State<EditAccessDetails> createState() => _EditAccessDetailsState();
}

class _EditAccessDetailsState extends State<EditAccessDetails> {
  late TextEditingController _grantedDateController;
  late TextEditingController _revokedDateController;
  String? _selectedRole;

  final DatePicker _datePicker = DatePicker();

  @override
  void initState() {
    super.initState();
    _grantedDateController = TextEditingController();
    _revokedDateController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    try {
      final userAccessCubit = context.read<UserManagementAccessCubit>();

      if (userAccessCubit.newAccessSelectedRole != null &&
          userAccessCubit.newAccessSelectedRole!.isNotEmpty) {
        setState(() {
          _selectedRole = userAccessCubit.newAccessSelectedRole!;
        });
      }

      if (userAccessCubit.accessGranted != null) {
        setState(() {
          _grantedDateController.text =
              _formatDateForDisplay(userAccessCubit.accessGranted!);
        });
      }

      if (userAccessCubit.accessRevoked != null) {
        setState(() {
          _revokedDateController.text =
              _formatDateForDisplay(userAccessCubit.accessRevoked!);
        });
      }
    } catch (e) {
    }
  }

  @override
  void dispose() {
    _grantedDateController.dispose();
    _revokedDateController.dispose();
    super.dispose();
  }

  // ── Returns EN role names sorted alphabetically ──────────────────────────
  List<String> _getSortedRolesEn() {
    try {
      final roles = context.read<RoleCubit>().roles;
      if (roles.isEmpty) return [];
      return roles
          .map((r) => r.currentRoleName)
          .where((name) => name.isNotEmpty)
          .toList()
        ..sort((a, b) => a.compareTo(b));
    } catch (e) {
      return [];
    }
  }

  // ── Returns AR role names in the SAME order as _getSortedRolesEn ─────────
  List<String> _getSortedRolesAr() {
    try {
      final roles = context.read<RoleCubit>().roles;
      if (roles.isEmpty) return [];
      final sorted = roles
          .where((r) => r.currentRoleName.isNotEmpty)
          .toList()
        ..sort((a, b) => a.currentRoleName.compareTo(b.currentRoleName));
      return sorted.map((r) => r.currentRoleNameAr).toList();
    } catch (e) {
      return [];
    }
  }

  String _formatDateForDisplay(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<DateTime?> _openDatePicker({DateTime? currentDate}) async {
    final result = await _datePicker.showDatePicker(
      context,
      [currentDate],
      currentDate ?? DateTime.now(),
      CalendarDatePicker2Type.single,
    );
    if (result != null && result.isNotEmpty && result.first != null) {
      return result.first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserManagementAccessCubit, UserManagementAccessState>(
      builder: (context, state) {
        final userAccessCubit = context.read<UserManagementAccessCubit>();
        final isArabic = Localizations.localeOf(context).languageCode == 'ar';

        // ── Role lists ────────────────────────────────────────────────────
        final rolesEn = _getSortedRolesEn();
        final rolesAr = _getSortedRolesAr();

        return Padding(
          padding: EdgeInsets.all(15.sp),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Role Dropdown ─────────────────────────────────────────
                CustomDropdown<String>(
                  label: isArabic ? 'نوع الدور' : 'Role Type',
                  hint: isArabic ? 'اختر دورًا' : 'Select role',
                  labelStyle: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  hintStyle: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  // Items are always EN keys (used for storage & matching)
                  items: rolesEn.map((role) {
                    final index = rolesEn.indexOf(role);
                    final label =
                        (isArabic && index >= 0 && index < rolesAr.length)
                            ? rolesAr[index]
                            : role;
                    return DropdownItem<String>(value: role, label: label);
                  }).toList(),
                  // Value is always the EN key
                  value: _selectedRole,
                  required: false,
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                      userAccessCubit.newAccessSelectedRole = value;
                    });
                    userAccessCubit.emit(UserPermissionsDataLoaded());
                  },
                  itemStyle: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.text,
                  ),
                  borderRadius: BorderRadius.circular(4.r),
                  fillColor: AppColors.background,
                  triggerPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                ),

                SizedBox(height: 15.h),

                // ── Access Granted Date ───────────────────────────────────
                Text(
                  isArabic ? 'تاريخ منح الوصول' : 'Access Granted Date',
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 8.h),

                GestureDetector(
                  onTap: () async {
                    final pickedDate = await _openDatePicker(
                      currentDate: userAccessCubit.accessGranted,
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _grantedDateController.text =
                            _formatDateForDisplay(pickedDate);
                        userAccessCubit.accessGranted = pickedDate;
                      });
                      userAccessCubit.emit(UserPermissionsDataLoaded());
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: AppColors.background,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _grantedDateController.text.isNotEmpty
                                ? _grantedDateController.text
                                : (isArabic ? 'اختر تاريخًا' : 'Select a date'),
                            style: StyleText.fontSize12Weight500.copyWith(
                              color: _grantedDateController.text.isNotEmpty
                                  ? AppColors.text
                                  : AppColors.secondaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        CustomSvg(
                          assetPath: 'assets/calender.svg',
                          width: 15.w,
                          height: 15.h,
                          fit: BoxFit.fill,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 15.h),

                // ── Access Revoked Date ───────────────────────────────────
                Text(
                  isArabic ? 'تاريخ إلغاء الوصول' : 'Access Revoked Date',
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 8.h),

                GestureDetector(
                  onTap: () async {
                    final pickedDate = await _openDatePicker(
                      currentDate: userAccessCubit.accessRevoked,
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _revokedDateController.text =
                            _formatDateForDisplay(pickedDate);
                        userAccessCubit.accessRevoked = pickedDate;
                      });
                      userAccessCubit.emit(UserPermissionsDataLoaded());
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: AppColors.background,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _revokedDateController.text.isNotEmpty
                                ? _revokedDateController.text
                                : (isArabic ? 'اختر تاريخًا' : 'Select a date'),
                            style: StyleText.fontSize12Weight500.copyWith(
                              color: _revokedDateController.text.isNotEmpty
                                  ? AppColors.text
                                  : AppColors.secondaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        CustomSvg(
                          assetPath: 'assets/calender.svg',
                          width: 15.w,
                          height: 15.h,
                          fit: BoxFit.fill,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
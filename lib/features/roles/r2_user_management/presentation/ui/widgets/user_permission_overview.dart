import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';

import 'package:grc_module/core/helper/main_helper/employee_helper.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/custom/custom_title_value_widget.dart';
import 'package:grc_module/features/roles/r2_user_management/domain/entity/user_permission_entity.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/ui/pages/adding_new_role.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/pages/employee_details.dart';

import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
class UserPermissionOverview extends StatelessWidget {
  UserPermissionOverview({super.key, required this.userPermissionEntity});

  final UserPermissionEntity userPermissionEntity;

  /// ✅ Get localized role name
  String _getLocalizedRoleName(BuildContext context) {
    if (userPermissionEntity.accessName == null ||
        userPermissionEntity.accessName!.isEmpty) {
      return '-';
    }

    try {
      final roleCubit = context.read<RoleCubit>();
      final role = roleCubit.roles.firstWhereOrNull(
              (r) => r.roleId == userPermissionEntity.accessName ||
              r.currentRoleName == userPermissionEntity.accessName
      );

      if (role != null) {
        // Return localized name based on current locale
        return Get.locale.toString().contains('en')
            ? role.currentRoleName
            : role.currentRoleNameAr;
      }

      // Fallback to accessName if role not found
      return userPermissionEntity.accessName!;
    } catch (e) {
      return userPermissionEntity.accessName!;
    }
  }

  /// ✅ Get status color based on status name
  Color _getStatusColor(String statusName) {
    final normalizedStatus = statusName.toLowerCase().replaceAll(' ', '');

    Color resultColor;
    switch (normalizedStatus) {
      case 'active':
        resultColor = AppColors.lightGreen; // Green
        break;
      case 'inactive':
        resultColor = AppColors.red; // Red
        break;
      case 'scheduled':
        resultColor = AppColors.orange; // Orange
        break;
      case 'expiringsoon':
        resultColor = AppColors.expiringSoon; // Dark Red
        break;
      default:
        resultColor = AppColors.card;
        break;
    }

    return resultColor;
  }

  /// ✅ Format date with Arabic numerals if locale is Arabic
  String _getLocalizedDate(String? dateString) {
    if (dateString == null || dateString.isEmpty || dateString == '-') {
      return '-';
    }

    try {
      DateTime? date;

      // 1. ISO / yyyy-MM-dd  (also handles yyyy-MM-ddTHH:mm:ss)
      if (date == null && dateString.contains('-')) {
        try {
          date = DateTime.parse(dateString);
        } catch (_) {}
      }

      // 2. dd/MM/yyyy
      if (date == null && dateString.contains('/')) {
        try {
          final parts = dateString.split('/');
          if (parts.length == 3) {
            date = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        } catch (_) {}
      }

      // 3. Named-month formats with comma  → "Nov 05, 2025"  /  "May 22, 2026"
      if (date == null && dateString.contains(',')) {
        for (final fmt in ['MMM dd, yyyy', 'dd MMM, yyyy', 'MMMM dd, yyyy', 'dd MMMM, yyyy']) {
          try {
            date = DateFormat(fmt, 'en').parse(dateString);
            break;
          } catch (_) {}
        }
      }

      // 4. Named-month formats without comma  → "23 Feb 2022"  /  "Feb 23 2022"
      if (date == null) {
        for (final fmt in ['dd MMM yyyy', 'MMM dd yyyy', 'dd MMMM yyyy', 'MMMM dd yyyy']) {
          try {
            date = DateFormat(fmt, 'en').parse(dateString);
            break;
          } catch (_) {}
        }
      }

      if (date == null) {
        return dateString;
      }

      // ── Format output based on locale ───────────────────────────────────
      final isArabic = Get.locale?.languageCode == 'ar' ||
          Get.locale.toString().toLowerCase().contains('ar');

      if (isArabic) {
        final day   = _convertToArabicNumerals(date.day.toString());
        final month = _getArabicMonthNameShort(date.month);
        final year  = _convertToArabicNumerals(date.year.toString());
        return '$day $month $year'; // ٢٣ فبراير ٢٠٢٢
      } else {
        return DateFormat('dd MMM yyyy').format(date); // 23 Feb 2022
      }
    } catch (e) {
      return dateString;
    }
  }

  /// ✅ Get abbreviated Arabic month name
  String _getArabicMonthNameShort(int month) {
    const arabicMonthsShort = [
      'يناير',    // January - 1
      'فبراير',   // February - 2
      'مارس',     // March - 3
      'أبريل',    // April - 4
      'مايو',     // May - 5
      'يونيو',    // June - 6
      'يوليو',    // July - 7
      'أغسطس',    // August - 8
      'سبتمبر',   // September - 9
      'أكتوبر',   // October - 10
      'نوفمبر',   // November - 11
      'ديسمبر'    // December - 12
    ];

    if (month >= 1 && month <= 12) {
      return arabicMonthsShort[month - 1];
    }
    return month.toString();
  }

  /// ✅ Get Arabic month name
  String _getArabicMonthName(int month) {
    const arabicMonths = [
      'يناير',    // January - 1
      'فبراير',   // February - 2
      'مارس',     // March - 3
      'أبريل',    // April - 4
      'مايو',     // May - 5
      'يونيو',    // June - 6
      'يوليو',    // July - 7
      'أغسطس',    // August - 8
      'سبتمبر',   // September - 9
      'أكتوبر',   // October - 10
      'نوفمبر',   // November - 11
      'ديسمبر'    // December - 12
    ];

    if (month >= 1 && month <= 12) {
      return arabicMonths[month - 1];
    }
    return month.toString();
  }

  /// ✅ Convert Western numerals to Arabic-Indic numerals
  String _convertToArabicNumerals(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }



  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    var isMobile = ContextExtension(context).isPhone;

    return GestureDetector(
      onTap: () {
        // Check if this is a draft role
        final roleCubit = context.read<RoleCubit>();
        final draftRole = roleCubit.roles.firstWhereOrNull(
                (role) => (role.roleId == userPermissionEntity.accessName ||
                role.currentRoleName == userPermissionEntity.accessName) &&
                role.currentStatus == RoleStatus.draft
        );

        if (draftRole != null) {
          // Load the draft and navigate to editing
          roleCubit.selectRole(draftRole);
          roleCubit.isEditing = false; // Set to false to allow "Save for Later"

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider<RoleCubit>.value(
                value: roleCubit,
                child: AddingNewRole(),
              ),
            ),
          );
        } else {
          // If not a draft role, navigate to employee details page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RoleEmployeeDetailsPage(
                userPermission: userPermissionEntity,
              ),
            ),
          );
        }
      },
      child: Container(
          padding: EdgeInsets.all(10.sp),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.card
          ),
          child: Column(
              spacing: 10.sp,
              mainAxisSize: MainAxisSize.min,
              children: [
            // No fixed height here: the name/role/status stack is taller than
            // the 52.sp this used to hard-code, which clipped it. The grid's
            // mainAxisExtent sizes the card instead.
            Container(
              child: Row(
                spacing: 5.sp,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  userImage(),
                  SizedBox(width: 3.sp),
                  // Expanded so long employee names ellipsize instead of
                  // overflowing the card horizontally.
                  Expanded(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Text(  FormatHelper.capitalize(EmployeeHelper.getEmployeeLocalizedNameWithId(
                          employeeId: userPermissionEntity.employeeId,
                          context: context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.text
                        ),

                      ),


                      isMobile ? SizedBox() : SizedBox(height: 3.h),

                      // ✅ UPDATED: Use localized role name
                      CustomTitleValueWidget(
                          title: "${S.of(context).roleType}: ",
                          value: FormatHelper.capitalize(_getLocalizedRoleName(context))
                      ),

                      isMobile ? SizedBox() :   SizedBox(height: 2.h),

                      Builder(
                          builder: (context) {
                            final statusName = userPermissionEntity.accessStatus.name;
                            final statusColor = _getStatusColor(statusName);



                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("${S.of(context).status}: ",style: StyleText.fontSize14Weight500.copyWith(
                                  color: AppColors.secondaryText
                                ),),

                                Flexible(
                                  child: Text(FormatHelper.capitalize(statusName),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: StyleText.fontSize14Weight500.copyWith(
                                    color: statusColor
                                ),),
                                ),
                              ],
                            );
                          }
                      )
                    ],
                  ),
                  ),
                ],
              ),
            ),
            // Flexible (not Spacer) so the two date pairs share the row and
            // ellipsize when the card is narrow, instead of overflowing right.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: CustomTitleValueWidget(
                      title: "${S.of(context).access_granted}: ",
                      titleStyle: StyleText.fontSize10Weight400.copyWith(
                        color: AppColors.secondaryText
                      ),
                      valueStyle: StyleText.fontSize10Weight400.copyWith(
                          color: AppColors.text
                      ),
                      value: _getLocalizedDate(userPermissionEntity.startDate)),
                ),
                SizedBox(width: 6.sp),
                Flexible(
                  child: CustomTitleValueWidget(
                      title: "${S.of(context).access_revoked}: ",
                      titleStyle: StyleText.fontSize10Weight400.copyWith(
                          color: AppColors.secondaryText
                      ),
                      valueStyle:  StyleText.fontSize10Weight400.copyWith(
                          color: AppColors.text
                      ),
                      value: _getLocalizedDate(userPermissionEntity.endDate)),
                ),
              ],
            )
          ])),
    );
  }

  Widget userImage() {
    String imageUrl = EmployeeHelper.getEmployeeImageWithId(
        employeeId: userPermissionEntity.employeeId);

    // ✅ Handle empty, null, or invalid image paths
    bool isValidUrl = imageUrl.isNotEmpty &&
        imageUrl != "[]" &&
        imageUrl.contains('http');

    bool isValidAsset = imageUrl.isNotEmpty &&
        imageUrl != "[]" &&
        !imageUrl.contains('http');

    return ClipRRect(
      borderRadius: BorderRadius.circular(50.r),
      child: isValidUrl
          ? Image.network(
        imageUrl,
        width: 50.sp,
        height: 50.sp,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImage();
        },
      )
          : isValidAsset
          ? Image.asset(
        imageUrl,
        width: 50.sp,
        height: 50.sp,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImage();
        },
      )
          : _buildFallbackImage(),
    );
  }

  // ✅ Add fallback image widget
  Widget _buildFallbackImage() {
    return Container(
        width: 50.sp,
        height: 50.sp,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: CustomSvgImage(assetPath: "assets/icons_assets/main_icons_assets/male_avatar.svg")
    );
  }
}
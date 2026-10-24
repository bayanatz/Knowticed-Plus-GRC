// ****************** FILE INFO ******************
// File Name: crm_card_helper.dart
// Purpose: Shared helper for CRM cards (creator name resolution, metadata row, status chip)
// Author: Mohand Adel
// Created At: 16/08/2026

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

abstract class CrmCardHelper {
  /// Resolves the human-readable employee name from email or raw identifier.
  static String resolveCreatorName(
    String updatedBy, {
    required bool isArabic,
  }) {
    final String trimmed = updatedBy.trim();
    if (trimmed.isEmpty) return '-';

    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final MainCoreEmployeeController controller =
          Get.find<MainCoreEmployeeController>();

      // 1. Check current logged-in employee first
      final EmployeeEntityPro? current = controller.employeeEntity;
      if (current != null &&
          (current.email?.trim().toLowerCase() == trimmed.toLowerCase() ||
              current.id?.trim() == trimmed)) {
        final String name = _extractNameFromEntity(current, isArabic: isArabic);
        if (name.isNotEmpty) return name;
      }

      // 2. Check all employees list (case-insensitive email or ID match)
      final List<EmployeeEntityPro>? all = controller.allEmployeesEntities;
      if (all != null && all.isNotEmpty) {
        for (final EmployeeEntityPro emp in all) {
          if (emp.email?.trim().toLowerCase() == trimmed.toLowerCase() ||
              emp.id?.trim() == trimmed) {
            final String name = _extractNameFromEntity(emp, isArabic: isArabic);
            if (name.isNotEmpty) return name;
            break;
          }
        }
      }

      // 3. Fallback to controller methods
      final String employeeName = isArabic
          ? controller.getEmployeeNameEnglishArabic(
              trimmed.toLowerCase(),
              false,
            )
          : controller.getEmployeeName(trimmed.toLowerCase());
      final String normalizedName = employeeName.trim();
      if (normalizedName.isNotEmpty &&
          normalizedName.toLowerCase() != 'no name' &&
          !normalizedName.contains('@')) {
        return capitalizeWords(normalizedName);
      }
    }

    return extractFirstAndLastName(trimmed);
  }

  /// Extracts display name from an [EmployeeEntityPro], respecting locale.
  static String _extractNameFromEntity(
    EmployeeEntityPro emp, {
    required bool isArabic,
  }) {
    if (isArabic) {
      final String arFirst = emp.firstNameInArabic?.trim() ?? '';
      final String arLast = emp.lastNameInArabic?.trim() ?? '';
      final String arFull = '$arFirst $arLast'.trim();
      if (arFull.isNotEmpty &&
          arFull.toLowerCase() != 'no name' &&
          !arFull.contains('@')) {
        return arFull;
      }
    }
    final String enFirst = emp.firstName?.trim() ?? '';
    final String enLast = emp.lastName?.trim() ?? '';
    final String enFull = '$enFirst $enLast'.trim();
    if (enFull.isNotEmpty &&
        enFull.toLowerCase() != 'no name' &&
        !enFull.contains('@')) {
      return capitalizeWords(enFull);
    }
    return '';
  }

  /// Capitalizes each word, handling hyphenated names (e.g. Al-Mansoor).
  static String capitalizeWords(String input) {
    final String trimmed = input.trim();
    if (trimmed.isEmpty) return '';

    return trimmed.split(' ').map((String word) {
      if (word.isEmpty) return '';
      if (word.contains('-')) {
        return word.split('-').map(_capitalizeSingleWord).join('-');
      }
      return _capitalizeSingleWord(word);
    }).join(' ');
  }

  static String _capitalizeSingleWord(String word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  /// Extracts capitalized First and Last Name from email or identifier string.
  static String extractFirstAndLastName(String rawValue) {
    String normalized = rawValue.trim();
    if (normalized.contains('@')) {
      normalized = normalized.split('@').first.trim();
    }
    // Replace dots, underscores, slashes with spaces, but keep hyphens for compound names
    normalized = normalized.replaceAll(RegExp(r'[._/]+'), ' ');

    final List<String> rawTokens = normalized
        .split(' ')
        .map((String w) => w.trim())
        .where((String w) => w.isNotEmpty && !RegExp(r'^\d+$').hasMatch(w))
        .toList();

    if (rawTokens.isEmpty) return capitalizeWords(rawValue.split('@').first);

    // Capitalize each token
    final List<String> words = rawTokens.map(capitalizeWords).toList();

    if (words.length == 1) return words.first;

    // Handle compound Arabic prefixes: e.g. ["Ahmed", "Al", "Mansoor"] -> "Ahmed Al-Mansoor"
    if (words.length >= 3 &&
        (words[1].toLowerCase() == 'al' || words[1].toLowerCase() == 'el')) {
      return '${words[0]} ${words[1]}-${words[2]}';
    }

    // Two tokens: e.g. ["Ahmed", "Mansoor"] -> "Ahmed Mansoor"
    if (words.length == 2) {
      if (words[0].toLowerCase() == 'al' || words[0].toLowerCase() == 'el') {
        return '${words[0]}-${words[1]}';
      }
      return '${words[0]} ${words[1]}';
    }

    return words.take(3).join(' ');
  }

  /// Builds the 3-column metadata row (Count, By, Last Update) for CRM cards.
  static Widget buildCardMetaRow({
    required BuildContext context,
    required String countLabel,
    required String countValue,
    required String countIcon,
    required String creator,
    required String lastUpdate,
    required bool isArabic,
  }) {
    final bool isMobile = kpIsPhoneLayout(context);
    final double fontSize = isMobile ? 10.sp : 13.sp;
    final double iconSize = isMobile ? 11.sp : 14.sp;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: CardInfoRow(
            fontSize: fontSize,
            iconSize: iconSize,
            info: CardInfo(
              label: countLabel,
              value: countValue,
              icon: CustomSvgImage(
                assetPath: countIcon,
                width: iconSize,
                height: iconSize,
                color: AppColors.black,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: CardInfoRow(
            fontSize: fontSize,
            iconSize: iconSize,
            info: CardInfo(
              label: isArabic ? 'بواسطة:' : 'By:',
              value: creator,
              icon: CustomSvgImage(
                assetPath: AppAssets.crmGroup,
                width: iconSize,
                height: iconSize,
                color: AppColors.black,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: CardInfoRow(
            fontSize: fontSize,
            iconSize: iconSize,
            info: CardInfo(
              label: isArabic ? 'آخر تحديث:' : 'Last Update:',
              value: lastUpdate,
              icon: CustomSvgImage(
                assetPath: AppAssets.timeSelectorIcon,
                width: iconSize,
                height: iconSize,
                color: AppColors.black,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the positioned active/inactive status chip.
  static Widget buildPositionedStatusChip({
    required bool isActive,
    required bool isArabic,
  }) {
    return Positioned(
      top: 14.sp,
      left: isArabic ? 14.sp : null,
      right: isArabic ? null : 14.sp,
      child: buildInlineStatusChip(
        isActive: isActive,
        isArabic: isArabic,
      ),
    );
  }

  /// Builds an inline active/inactive status chip.
  static Widget buildInlineStatusChip({
    required bool isActive,
    required bool isArabic,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
      decoration: BoxDecoration(
        color: isActive ? AppColors.green : AppColors.orange,
        borderRadius: BorderRadius.circular(4.sp),
      ),
      child: Text(
        isActive
            ? (isArabic ? 'نشط' : 'Active')
            : (isArabic ? 'غير نشط' : 'Inactive'),
        style: StyleText.fontSize10Weight600.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Returns responsive cross-axis count for CRM grid cards:
  /// - Mobile (< 600px): 1 in a row
  /// - Medium / Tablet (600px – 1199px): 2 in a row
  /// - Large / Desktop (≥ 1200px): 3 in a row
  static int getCrossAxisCountForCards(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 1;
    } else if (screenWidth < 1200) {
      return 2;
    } else {
      return 3;
    }
  }
}

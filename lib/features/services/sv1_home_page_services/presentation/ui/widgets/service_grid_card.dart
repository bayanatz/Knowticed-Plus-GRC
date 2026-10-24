/// Module: services / sv1_home_page_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: service_grid_card.dart
/// Purpose: Single service card shown in the management grid view, including
///          tap handling (draft resume / details navigation) and the duration
///          pluralization helpers. Extracted from ManagementWidget.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';

import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services/data/repository/firebase_draft_repository.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/ui/pages/create_new_services_toggle.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/ui/pages/details_services_toggle.dart';

import 'package:knowticed_plus/features/services/helpers/services_text.dart';

class ServiceGridCard extends StatelessWidget {
  final ServicesHistoryModel service;
  final String duration;
  final String unit;
  final String Function(dynamic) formatStartDate;

  /// Resolved "done services" counts (local Firestore counts take precedence
  /// over the parent-provided map; merge them before passing in).
  final Map<String, int> doneServicesCount;

  const ServiceGridCard({
    super.key,
    required this.service,
    required this.duration,
    required this.unit,
    required this.formatStartDate,
    required this.doneServicesCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticController.low(); // card tap
        final isDraft = service.currentState.toLowerCase().trim() == 'draft';
        final cubit = ServicesManagerCubit.get(context);

        if (isDraft) {
          // 🔥 CHECK IF IT'S A FIREBASE DRAFT WITH PAGE TRACKING
          final draftWithPage = await cubit.getDraftWithPage(service.currentId);

          if (!context.mounted) return;
          if (draftWithPage != null) {
            // Navigate to specific page based on saved progress
            _navigateToDraftPage(context, draftWithPage);
          } else {
            // Fallback: old SharedPrefs draft or new draft without page info
            navigateTo(context, CreateNewServicesLayout(editingModel: service));
          }
        } else {
          // Existing active/inactive service flow
          // SVC-HOME-24: the details page loads its own data, so nothing is
          // fetched (and awaited) here before navigating.
          final serviceId = service.currentId;
          if (serviceId.isNotEmpty) {
            navigateTo(
              context,
              ToggleDetailsServicesLayout(createServicesModel: service),
            );
          }
        }
      },
      child: _buildServiceCardContent(context),
    );
  }

  /// Open a draft at the start of the wizard.
  ///
  /// ✅ FIX (bug report p2): this used to deep-link straight to
  /// `draftWithPage.currentPage`, so a draft saved on the provider step
  /// reopened on the provider step. Resuming a draft always starts at step 1
  /// (basic info) instead: the saved model is passed through so every step
  /// stays prefilled and the user walks forward through the wizard.
  ///
  /// `draftWithPage.currentPage` is still written by the save path and is left
  /// intact for progress reporting.
  void _navigateToDraftPage(BuildContext context, DraftWithPage draftWithPage) {
    navigateTo(
      context,
      CreateNewServicesLayout(
        editingModel: draftWithPage.model,
        docId: draftWithPage.draftId,
      ),
    );
  }

  Widget _buildServiceCardContent(BuildContext context) {
    // Rule "All text in the translation files": layout follows the text
    // direction, not a language flag passed down the tree.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.only(right: 10.sp, left: isRtl ? 10.sp : 0.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildServiceImage(context),
                SizedBox(width: isRtl ? 0.sp : 5.sp),
                Expanded(child: _buildServiceInfo(context)),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
          child: _buildStartDate(context),
        ),
      ],
    );
  }

  Widget _buildServiceImage(BuildContext context) {
    return Container(
      width: 60.w,
      height: 60.h,
      margin: EdgeInsets.only(top: 10.sp, bottom: 10.sp, left: 10.sp),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: (service.currentImageUrl.isNotEmpty)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: CachedNetworkImage(
                imageUrl: service.currentImageUrl,
                width: 80.sp,
                height: 80.sp,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: AppColors.secondaryText.withValues(alpha: .3),
                  highlightColor: AppColors.background.withValues(alpha: .5),
                  child: Container(
                    width: 80.sp,
                    height: 80.sp,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryText.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) {
                  return CustomSvgImage.natural(
                    assetPath:
                        'assets/icons_assets/services_assets/ic_time_clock_dashed.svg',
                    width: 40.sp,
                    height: 40.sp,
                    color: AppColors.secondaryText,
                    fit: BoxFit.scaleDown,
                  );
                },
              ),
            )
          : CustomSvgImage.natural(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_module_support_headset.svg',
              width: 30.w,
              height: 30.h,
              color: AppColors.secondaryText,
              fit: BoxFit.fill,
            ),
    );
  }

  Widget _buildServiceInfo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 11.sp, bottom: 10.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 3.h),
              child: _buildServiceName(context),
            ),
          ),
          Expanded(child: _buildDoneServicesCount(context)),
          Expanded(child: _buildDuration(context)),
        ],
      ),
    );
  }

  Widget _buildServiceName(BuildContext context) {
    final serviceName = Localizations.localeOf(context).languageCode == 'ar'
        ? service.currentServiceNameArabic
        : service.currentServiceNameEnglish;

    return Text(
      FormatHelper.capitalize(serviceName),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
    );
  }

  Widget _buildDoneServicesCount(BuildContext context) {
    // 🔥 Priority handled by caller: local Firestore count > parent count > "-"
    final count = doneServicesCount[service.currentId];

    return Row(
      children: [
        Text(
          "${S.of(context).doneServices}: ",
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        Text(
          "${count ?? '-'}",
          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
        ),
      ],
    );
  }

  Widget _buildDuration(BuildContext context) {
    // H13: one unit parser (ServiceDurationUnit) and translated unit names.
    final durationValue = int.tryParse(duration);
    final displayUnit = durationValue == null
        ? unit
        : context.svcDurationUnit(unit, durationValue);

    return Row(
      children: [
        Text(
          "${S.of(context).duration}: ",
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        Text(
          FormatHelper.capitalize("$duration $displayUnit"),
          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
        ),
      ],
    );
  }

  Widget _buildStartDate(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 0.sp, left: 0.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Text(
                "${S.of(context).startDate}: ",
                style: StyleText.fontSize10Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              _buildStartDateValue(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartDateValue(BuildContext context) {
    final isDraft = service.currentState.toLowerCase().trim() == 'draft';

    if (isDraft) {
      return Text(
        '-',
        style: StyleText.fontSize10Weight400.copyWith(color: AppColors.text),
      );
    }

    // W04: guarded access instead of try/catch.
    if (service.timestamps.isNotEmpty) {
      final timestamp = Timestamp.fromMillisecondsSinceEpoch(
        service.timestamps[0],
      );
      return Text(
        formatStartDate(timestamp),
        style: StyleText.fontSize10Weight400.copyWith(color: AppColors.text),
      );
    }

    return Text(
      '-',
      style: StyleText.fontSize10Weight400.copyWith(color: AppColors.text),
    );
  }
}

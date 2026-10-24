// ****************** FILE INFO ******************
// File Name: crm_client_card.dart
// Purpose: Extracted client record card widget for the CRM clients grid
// Author: Mohand Adel
// Created At: 08/08/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_custom_grid_card_mapper.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// Grid card for a dynamic [CrmClientRecordModel]. Shows the primary display
/// value (name), secondary value (email/phone), creation date, and status.
class CrmClientCard extends StatelessWidget {
  final CrmClientRecordModel record;
  final CrmClientTypeModel? clientType;
  final List<CrmClientCustomGridCardItem> customGridItems;
  final VoidCallback? onTap;

  const CrmClientCard({
    super.key,
    required this.record,
    this.clientType,
    this.customGridItems = const <CrmClientCustomGridCardItem>[],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String? name = record.primaryDisplayValue;

    return InkWell(
      onTap: withHaptic(onTap, HapticLevel.low),
      borderRadius: BorderRadius.circular(10.sp),
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48.sp,
              height: 48.sp,
              decoration: BoxDecoration(
                color: AppColors.disabledGrey,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: CustomSvgImage(
                assetPath: clientType?.svgAsset ?? AppAssets.crmPerson,
                width: 26.sp,
                height: 26.sp,
                color: AppColors.black,
              ),
            ),
            SizedBox(width: 12.sp),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name ?? S.current.crmAddNewClient,
                          style: StyleText.fontSize14Weight600.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      _StatusBadge(status: record.status),
                    ],
                  ),
                  if (customGridItems.isNotEmpty) ...[
                    SizedBox(height: 6.sp),
                    _buildCustomGridInfo(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomGridInfo() {
    final int splitIndex = (customGridItems.length / 2).ceil();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoColumn(customGridItems.take(splitIndex).toList()),
        if (customGridItems.length > splitIndex) ...[
          SizedBox(width: 8.sp),
          _buildInfoColumn(customGridItems.skip(splitIndex).toList()),
        ],
      ],
    );
  }

  Widget _buildInfoColumn(List<CrmClientCustomGridCardItem> items) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int index = 0; index < items.length; index++) ...[
            CardInfoRow(
              info: CardInfo(
                label: '${items[index].label}:',
                value: items[index].value,
                icon: CustomSvgImage(
                  assetPath: items[index].iconAsset,
                  width: 12.sp,
                  height: 12.sp,
                  color: AppColors.black,
                ),
              ),
              fontSize: 12.sp,
              iconSize: 12.sp,
            ),
            if (index < items.length - 1) SizedBox(height: 4.sp),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final String normalized = status.toLowerCase().trim();
    final Color color;
    final String label;

    switch (normalized) {
      case 'active':
        color = AppColors.green;
        label = S.current.crmActive;
        break;
      case 'inactive':
        color = AppColors.orange;
        label = S.current.crmInactive;
        break;
      case 'archived':
        color = AppColors.grey;
        label = S.current.crmArchived;
        break;
      case 'prospect':
        color = AppColors.blue;
        label = S.current.crmProspect;
        break;
      default:
        color = AppColors.green;
        label = status.isNotEmpty ? status : S.current.crmActive;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 2.sp),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.sp),
      ),
      child: Text(
        label,
        style: StyleText.fontSize10Weight400.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

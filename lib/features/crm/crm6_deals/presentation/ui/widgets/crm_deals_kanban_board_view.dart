// ****************** FILE INFO ******************
// File Name: crm_deals_kanban_board_view.dart
// Purpose: Horizontally scrollable Pipeline Kanban Board with dynamic stage columns from Controls
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_kanban_card.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class StageColumnData {
  final String key;
  final String titleEn;
  final String titleAr;
  final Color bgColor;
  final Color badgeColor;
  final String prob;

  const StageColumnData({
    required this.key,
    required this.titleEn,
    required this.titleAr,
    required this.bgColor,
    required this.badgeColor,
    required this.prob,
  });
}

class CrmDealsKanbanBoardView extends StatelessWidget {
  final List<CrmClientDealModel> deals;
  final List<CrmDealStageModel>? stages;
  final ValueChanged<String>? onAddDealToStage;
  final ValueChanged<CrmClientDealModel>? onDealTap;

  static const List<Map<String, Color>> _palette = <Map<String, Color>>[
    <String, Color>{
      'bg': Color(0xFFF0F5FF),
      'badge': Color(0xFF3B82F6)
    }, // blue
    <String, Color>{
      'bg': Color(0xFFFFFBEA),
      'badge': Color(0xFFEAB308)
    }, // amber
    <String, Color>{
      'bg': Color(0xFFFFF4EC),
      'badge': Color(0xFFF97316)
    }, // orange
    <String, Color>{
      'bg': Color(0xFFF7F0FF),
      'badge': Color(0xFF8B5CF6)
    }, // purple
    <String, Color>{
      'bg': Color(0xFFFFF0F5),
      'badge': Color(0xFFEC4899)
    }, // pink
    <String, Color>{
      'bg': Color(0xFFF0FFF4),
      'badge': Color(0xFF22C55E)
    }, // green
    <String, Color>{
      'bg': Color(0xFFF0FDF4),
      'badge': Color(0xFF10B981)
    }, // emerald
    <String, Color>{'bg': Color(0xFFFFF0F0), 'badge': Color(0xFFEF4444)}, // red
  ];

  const CrmDealsKanbanBoardView({
    super.key,
    required this.deals,
    this.stages,
    this.onAddDealToStage,
    this.onDealTap,
  });

  List<StageColumnData> _buildColumns() {
    if (stages != null && stages!.isNotEmpty) {
      final List<CrmDealStageModel> active = stages!
          .where((CrmDealStageModel s) => s.isActive && !s.isDeleted)
          .toList()
        ..sort((CrmDealStageModel a, CrmDealStageModel b) =>
            a.order.compareTo(b.order));

      if (active.isNotEmpty) {
        return active
            .asMap()
            .entries
            .map((MapEntry<int, CrmDealStageModel> entry) {
          final int idx = entry.key;
          final CrmDealStageModel s = entry.value;
          final Map<String, Color> theme = _palette[idx % _palette.length];
          return StageColumnData(
            key: s.id,
            titleEn: s.nameEn,
            titleAr: s.nameAr,
            bgColor: theme['bg']!,
            badgeColor: theme['badge']!,
            prob: '${s.probability}%',
          );
        }).toList();
      }
    }

    return <StageColumnData>[
      StageColumnData(
        key: 'new',
        titleEn: 'New',
        titleAr: 'جديد',
        bgColor: const Color(0xFFF0F5FF),
        badgeColor: AppColors.blue,
        prob: '25%',
      ),
      StageColumnData(
        key: 'discovery',
        titleEn: 'Discovery',
        titleAr: 'اكتشاف',
        bgColor: Color(0xFFFFFBEA),
        badgeColor: Color(0xFFEAB308),
        prob: '25%',
      ),
      StageColumnData(
        key: 'qualified',
        titleEn: 'Qualified',
        titleAr: 'مؤهل',
        bgColor: Color(0xFFFFF4EC),
        badgeColor: Color(0xFFF97316),
        prob: '25%',
      ),
      StageColumnData(
        key: 'proposal',
        titleEn: 'Proposal',
        titleAr: 'تقديم العرض',
        bgColor: Color(0xFFF7F0FF),
        badgeColor: Color(0xFF8B5CF6),
        prob: '25%',
      ),
      StageColumnData(
        key: 'negotiation',
        titleEn: 'Negotiation',
        titleAr: 'تفاوض',
        bgColor: Color(0xFFFFF0F5),
        badgeColor: Color(0xFFEC4899),
        prob: '25%',
      ),
      StageColumnData(
        key: 'closedLost',
        titleEn: 'Closed Lost',
        titleAr: 'مغلق خاسر',
        bgColor: Color(0xFFFFF0F0),
        badgeColor: AppColors.red,
        prob: '0%',
      ),
      StageColumnData(
        key: 'closedWon',
        titleEn: 'Closed Won',
        titleAr: 'مغلق فائز',
        bgColor: Color(0xFFF0FFF4),
        badgeColor: AppColors.green,
        prob: '100%',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<StageColumnData> columns = _buildColumns();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns
            .map((StageColumnData c) => _buildStageColumn(context, c))
            .toList(),
      ),
    );
  }

  Widget _buildStageColumn(BuildContext context, StageColumnData col) {
    final String title = FormatHelper.localizedString(
      englishName: col.titleEn,
      arabicName: col.titleAr,
    );

    final List<CrmClientDealModel> stageDeals =
        deals.where((CrmClientDealModel d) {
      final String dStage = d.stage.trim().toLowerCase();
      final String dLabelEn = d.stageLabelEn.trim().toLowerCase();
      final String dLabelAr = d.stageLabelAr.trim().toLowerCase();
      final String k = col.key.trim().toLowerCase();
      final String tEn = col.titleEn.trim().toLowerCase();
      final String tAr = col.titleAr.trim().toLowerCase();
      return dStage == k || dStage == tEn || dLabelEn == tEn || dLabelAr == tAr;
    }).toList();

    final double totalAmount = stageDeals.fold<double>(
      0.0,
      (double sum, CrmClientDealModel item) =>
          sum + (item.amount > 0 ? item.amount : item.expectedValue),
    );
    final String amountFormatted =
        totalAmount > 0 ? '\$${totalAmount.toStringAsFixed(0)}' : '\$0';

    return Container(
      width: 320.sp,
      margin: EdgeInsets.only(right: 14.sp),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: col.bgColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header Row 1: Stage Title + Badge count
          Row(
            children: <Widget>[
              Text(
                title,
                style: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8.sp),
              Container(
                width: 22.sp,
                height: 22.sp,
                decoration: BoxDecoration(
                  color: col.badgeColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${stageDeals.length}',
                  style: StyleText.fontSize10Weight400
                      .copyWith(color: AppColors.fullBlack)
                      .copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.sp),

          // Header Row 2: Amount + Probability
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                amountFormatted,
                style: StyleText.fontSize10Weight400
                    .copyWith(color: AppColors.fullBlack)
                    .copyWith(
                      color: AppColors.darkGrey,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                col.prob,
                style: StyleText.fontSize10Weight400
                    .copyWith(color: AppColors.fullBlack)
                    .copyWith(
                      color: AppColors.darkGrey,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          SizedBox(height: 12.sp),

          // Cards List
          if (stageDeals.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.sp),
              child: Center(
                child: Text(
                  FormatHelper.localizedString(
                    englishName: 'No Deals In This Stage',
                    arabicName: 'لا توجد صفقات في هذه المرحلة',
                  ),
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
            )
          else
            ...stageDeals.map((CrmClientDealModel d) => CrmDealKanbanCard(
                  deal: d,
                  onTap: () => onDealTap?.call(d),
                )),

          SizedBox(height: 8.sp),

          // + Add Deal Button Container
          InkWell(
            onTapDown: (_) => HapticController.medium(),
            onTap: () => onAddDealToStage?.call(col.key),
            borderRadius: BorderRadius.circular(6.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.sp),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(6.r),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    size: 16.sp,
                    color: AppColors.text,
                  ),
                  SizedBox(width: 4.sp),
                  Text(
                    FormatHelper.localizedString(
                      englishName: 'Add Deal',
                      arabicName: 'إضافة صفقة',
                    ),
                    style: StyleText.fontSize12Weight400.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

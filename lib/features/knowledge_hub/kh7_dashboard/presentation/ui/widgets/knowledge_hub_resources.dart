/// Module: knowledge_hub/kh7_dashboard/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: knowledge_hub_resources.dart
/// Description: Published documents per file type — Dashboard screen.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/charts/custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

const String _resourcesIcon =
    'assets/icons_assets/knowledge_hub_assets/ic_knowledge_hub_resources.svg';

class KnowledgeHubResources extends StatelessWidget {
  const KnowledgeHubResources({super.key, required this.extensionData});

  final Map<String, int> extensionData;

  @override
  Widget build(BuildContext context) {
    if (extensionData.isEmpty) return _empty(context);
    return BarChartCard(
      title: S.of(context).knowledgeHubResources,
      dotIcon: _resourcesIcon,
      dotColor: AppColors.primary,
      bars: extensionData.entries
          .map(
            (e) => ChartData(
              label: e.key.toUpperCase(),
              value: e.value.toDouble(),
            ),
          )
          .toList(),
      chartHeight: 300,
      barWidth: 20.sp,
      barColor: AppColors.primary,
    );
  }

  Widget _empty(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26.sp,
                height: 26.sp,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomSvgImage(
                    assetPath: _resourcesIcon,
                    height: 16.sp,
                    width: 16.sp,
                    color: AppColors.textButton,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  S.of(context).knowledgeHubResources,
                  style: StyleText.fontSize14Weight600.copyWith(
                    color: AppColors.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: Text(
                S.of(context).noResourcesDataAvailable,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

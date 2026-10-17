/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_extra_widgets.dart
/// Description: The four Adding Widget cards Figma shows that had no
///          `HomeComponents` value at all — `EmployeeMessagesWidget`,
///          `GroupMessagesWidget`, `FormsSubmission` and `LowStocks`.
/// Author: Amr Mesbah
/// Created at: 23/8/2026
///
/// Source: Figma file BuJXLizpGcK5eHVBqQomXc, Settings > Home Layout >
/// Adding Widget, iPad Horizontal View (node 4717:68984). Figures are the
/// placeholder values from the Figma frames, like the rest of the picker.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/cards/custom_card_styles.dart';
import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:grc_module/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:grc_module/generated/l10n.dart';

/// Placeholder employee name shown in the preview rows.
const String _kSampleEmployee = 'Moataz Handousa';

/// One avatar + name + Messages button, repeated across the contacts card.
class _MessageContact extends StatelessWidget {
  final String name;

  /// Null renders the plain grey placeholder circle Figma uses for a group.
  final String? avatar;

  const _MessageContact({required this.name, this.avatar});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: avatar == null
              ? null
              : CustomSvgImage(
                  assetPath: avatar!,
                  width: 32.r,
                  height: 32.r,
                  fit: BoxFit.cover,
                ),
        ),
        SizedBox(height: 4.h),
        Text(
          name,
          style: CardStyles.label(8),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        HomeCardButton(label: l.messages),
      ],
    );
  }
}

/// Figma: the four-employee contacts card, three grid columns wide.
class EmployeeMessagesWidget extends StatelessWidget {
  /// Carried for parity with every other component widget.
  final HomeComponentModel model;

  const EmployeeMessagesWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return HomeWidgetCard(
      title: l.employeeMessages,
      icon: HomeWidgetSvg.messages,
      width: kHomeWidgetWideWidth,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < 4; i++) ...<Widget>[
            if (i > 0) SizedBox(width: 8.w),
            const Expanded(
              child: _MessageContact(
                name: _kSampleEmployee,
                avatar: HomeWidgetSvg.avatar,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Figma: the single-group messages card, one grid column wide.
class GroupMessagesWidget extends StatelessWidget {
  final HomeComponentModel model;

  const GroupMessagesWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return HomeWidgetCard(
      title: l.groupMessages,
      icon: HomeWidgetSvg.messages,
      width: kHomeWidgetNarrowWidth,
      child: _MessageContact(name: l.groupName),
    );
  }
}

/// Figma: "Low Stocks" — reorder thresholds, a remaining-stock bar, and the
/// products currently under their reorder level.
class LowStocks extends StatelessWidget {
  final HomeComponentModel model;

  const LowStocks({super.key, required this.model});

  /// Units left against the reorder quantity, as Figma labels them.
  static const int _left = 30;
  static const int _reorderLevel = 40;
  static const int _reorderQuantity = 100;

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return HomeWidgetCard(
      title: l.lowStocks,
      icon: HomeWidgetSvg.lowStock,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${l.reorderLevel} $_reorderLevel',
                  style: CardStyles.label(8),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  '${l.reorderQuantity} $_reorderQuantity',
                  style: CardStyles.label(8),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: <Widget>[
              Text(
                '$_left ${l.left}',
                style: CardStyles.value(9).copyWith(color: AppColors.red),
              ),
              const Spacer(),
              Text('$_reorderQuantity', style: CardStyles.label(9)),
            ],
          ),
          SizedBox(height: 2.h),
          Stack(
            children: <Widget>[
              Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _left / _reorderQuantity,
                child: Container(
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Products under the threshold. The first reads as selected, the
          // rest as plain chips, exactly as Figma draws the row.
          Row(
            children: <Widget>[
              for (int i = 0; i < 4; i++) ...<Widget>[
                if (i > 0) SizedBox(width: 4.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: i == 0 ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      l.productName,
                      style: CardStyles.label(8).copyWith(
                        color: i == 0 ? AppColors.textButton : AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

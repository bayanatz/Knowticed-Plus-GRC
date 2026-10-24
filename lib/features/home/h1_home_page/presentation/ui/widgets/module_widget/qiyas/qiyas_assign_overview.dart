/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: qiyas_assign_overview.dart
/// Purpose: Declares `QiyasAssignOverview`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 7/10/2026 - Declares its own width (`kHomeWidgetCompactWidth`,
///          260) instead of `IntrinsicWidth`: home cards now keep their own
///          width, and the intrinsic width here grew with the topic count
///          (15 circles ≈ 540) — the status rows scroll horizontally anyway.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/features/home/helpers/qiyas/qiyas_interface_consumer.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/home/helpers/qiyas/domain/entities/qiyas_tracker_entity.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class QiyasAssignOverview extends StatefulWidget {
  const QiyasAssignOverview({required this.model, super.key});
  final HomeComponentModel model;

  @override
  State<QiyasAssignOverview> createState() => _QiyasAssignOverviewState();
}

class _QiyasAssignOverviewState extends State<QiyasAssignOverview> {
  QiyasTrackerEntity? trackerEntity;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    // Owner item 199 (21/10/2026): each status is its NAME and its NUMBER
    // on one line (label 12, number 14/500) in the house card — the
    // horizontal strip of topic-id circles showed raw ids (D-226) and was
    // scrolled off the card, so the card read as four names with nothing.
    final S s = S.of(context);
    return HomeWidgetCard(
      title: s.qiyas,
      icon: 'assets/icons_assets/main_icons_assets/ic_module_qiyas.svg',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          statusRow(
              s.approved, AppColors.green, trackerEntity?.approvedTopics ?? []),
          statusRow(s.partialAssignation, const Color(0xFFFF814A),
              trackerEntity?.partialAssigned ?? []),
          statusRow(s.assigned, AppColors.secondaryPrimary,
              trackerEntity?.assigned ?? []),
          statusRow(
              s.notAssigned, AppColors.grey, trackerEntity?.notAssigned ?? []),
        ],
      ),
    );
  }

  Widget statusRow(String statusTitle, Color color, List<String> ids) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 8.w),
          Text(statusTitle,
              style: StyleText.fontSize12Weight400
                  .copyWith(color: AppColors.text)),
          SizedBox(width: 16.w),
          Text(trackerEntity == null ? '—' : '${ids.length}',
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.text)),
        ],
      ),
    );
  }

  Future<void> fetchData() async {
    trackerEntity = await QiyasInterfaceConsumer().getTopicsAssignStatus();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  String? getIndexId(int index, List<String> ids) {
    for (int i = 0; i < ids.length; i++) {
      if (int.tryParse(ids[i].split('.')[1]) == index + 1) {
        return ids[i];
      }
    }
    return null;
  }
}

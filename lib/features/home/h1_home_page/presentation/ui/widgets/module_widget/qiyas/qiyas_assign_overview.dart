import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/standard_container.dart';
import 'package:grc_module/features/home/main_controller/helper/qiyas/qiyas_interface_consumer.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/features/home/main_controller/helper/qiyas/domain/entity/qiyas_tracker_entity.dart';
import 'package:grc_module/features/home/h1_home_page/data_source/models/home_component_model.dart';
import 'package:grc_module/generated/l10n.dart';

class QiyasAssignOverview extends StatefulWidget {
  QiyasAssignOverview({required this.model, super.key});
  HomeComponentModel model;

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
    return IntrinsicWidth(
      child: StandardContainer(
          child: Column(
        spacing: 5.sp,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).qiyas,
                style: AppTextStyles.font14BlackCairoMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SvgPicture.asset(
                'assets/icons_assets/roles_assets/analytics_chart_cycle.svg',
                width: 20,
                height: 20,
                color: AppColors.primary,
              )
            ],
          ),
          Container(),
          statusRow(
              'Approved', AppColors.green, trackerEntity?.approvedTopics ?? []),
          statusRow('Partial Assignation', Color(0xFFFF814A),
              trackerEntity?.partialAssigned ?? []),
          statusRow('Assigned', AppColors.secondaryPrimary,
              trackerEntity?.assigned ?? []),
          statusRow(
              'Not Assigned', AppColors.grey, trackerEntity?.notAssigned ?? []),
        ],
      )),
    );
  }

  Widget statusRow(String statusTitle, Color color, List<String> ids) {
    return Column(
      spacing: 5.sp,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          statusTitle,
          style: AppTextStyles.font12BlackCairoRegular,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 5.sp,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0;
                  i <
                      (trackerEntity == null
                          ? 15
                          : trackerEntity!.numberOfTopics);
                  i++)
                CircleAvatar(
                  backgroundColor: getIndexId(i, ids) != null
                      ? color
                      : AppColors.secondaryButton,
                  radius: 15.sp,
                  child: Text(
                    getIndexId(i, ids) ?? '',
                    style: AppTextStyles.font10BlackCairoRegular,
                  ),
                )
            ],
          ),
        )
      ],
    );
  }

  fetchData() async {
    trackerEntity = await QiyasInterfaceConsumer().getTopicsAssignStatus();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print("trackerEntity ${trackerEntity?.numberOfTopics}");
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

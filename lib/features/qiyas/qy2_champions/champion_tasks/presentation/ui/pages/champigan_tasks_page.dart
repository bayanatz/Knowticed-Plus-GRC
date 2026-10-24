import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/qyias_module/routes.dart';
import 'package:knowticed_plus/core/helper/pagination_app_bar.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champion_tasks/presentation/controller/qiyas_champigan_tasks_cubit.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/presentation/ui/widgets/task_overview_widget.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champion_tasks/presentation/ui/pages/champigan_task_details_page.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/qiyas_log_service.dart';
import 'package:knowticed_plus/core/custom/navigation/filter_bar_item.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class ChampiganTasksPage extends StatelessWidget {
  ChampiganTasksPage({super.key});
  final QiyasChampiganTasksCubit controller =
      sl.registerSingletonIfAbsent(() => QiyasChampiganTasksCubit());
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initCubit();
      QiyasLogService.log('qiyas champion tasks');
    });
    bool isTablet = !kpIsPhoneLayout(context); // Check if pages
    return BlocProvider<QiyasChampiganTasksCubit>.value(
      value: controller,
      child: Scaffold(
        body: SafeArea(
            child: Container(
          padding: EdgeInsetsDirectional.only(
              start: isTablet ? 30.sp : 15.sp, end: 15.sp),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PaginationAppBar(
                    screensTitles: ['قياس التحول الرقمي', 'المعايير المكلفه']),
                BlocBuilder<QiyasChampiganTasksCubit, QiyasTasksState>(
                  buildWhen: (_, currentState) {
                    debugPrint("curentState: $currentState");
                    return currentState is QiyasTasksStatusUpdated;
                  },
                  builder: (context, state) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 30.sp,
                        children: [
                          for (EvidenceSubmissionStatus status
                              in EvidenceSubmissionStatus.values)
                            FilterBarItem(
                              isSelected: status == controller.selectedStatus,
                              title: status.value,
                              numberOfItems:
                                  controller.taskStatusMap[status]?.length ?? 0,
                              // Replace with actual count
                              onTap: () {
                                controller.updateSelectedStatus(status);
                              },

                              color: status.color,
                            ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 15.sp),
                BlocBuilder<QiyasChampiganTasksCubit, QiyasTasksState>(
                  buildWhen: (_, currentState) {
                    debugPrint("curentState: $currentState");
                    return currentState is QiyasTasksStatusUpdated;
                  },
                  builder: (context, state) {
                    return Expanded(
                        child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: CrossAxisCountHelper
                            .getCrossAxisCountForDefaultTablet2(context),
                        mainAxisExtent: 170.sp,
                        mainAxisSpacing: 10.sp,
                        crossAxisSpacing: 10.sp,
                      ),
                      itemCount: controller
                              .taskStatusMap[controller.selectedStatus]
                              ?.length ??
                          0,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onTap: () {
                            HapticController
                                .low(); // list row: on the tap (X-117)
                            controller.selectTask(controller.taskStatusMap[
                                controller.selectedStatus]![index]);
                            if (isTablet) {
                              Navigator.pushNamed(
                                  context, Routes.champiganTaskDetailsPage);
                            } else {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) {
                                return ChampiganTaskDetailsPage();
                              }));
                            }
                          },
                          child: TaskOverviewWidget(
                            taskOverview: controller.taskStatusMap[
                                controller.selectedStatus]![index],
                          ),
                        );
                      },
                    ));
                  },
                )
              ],
            ),
          ),
        )),
      ),
    );
  }
}

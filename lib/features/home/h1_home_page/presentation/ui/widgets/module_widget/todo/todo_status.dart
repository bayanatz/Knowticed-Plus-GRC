import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/standard_container.dart';

import 'package:grc_module/core/custom/37-custom_navigate.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
// REMOVED_MODULE: import 'package:grc_module/features/todo_new_module/external/tasks_module/category/data/models/task_model_updates_with_field_history.dart';
// REMOVED_MODULE: import 'package:grc_module/features/todo_new_module/external/tasks_module/category/domain/services/task_services.dart';
// REMOVED_MODULE: import 'package:grc_module/features/todo_new_module/external/tasks_module/category/presentation/screens/to_do_list/home_screen.dart';
// REMOVED_MODULE: import 'package:grc_module/features/todo_new_module/external/tasks_module/core/enums/task_priority_enum.dart';
// REMOVED_MODULE: import 'package:grc_module/features/todo_new_module/external/tasks_module/core/enums/task_status_enum.dart';
import 'package:grc_module/features/home/h1_home_page/data_source/models/home_component_model.dart';
import 'package:grc_module/features/home/main_controller/helper/todo_new_module/tasks_stub.dart';


class MyTodoStatus extends StatelessWidget {
  MyTodoStatus({required this.model, super.key});
  final HomeComponentModel model;
  final TaskFirebaseService _taskService = TaskFirebaseService();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130.sp,
      child: StandardContainer(
        child: StreamBuilder<List<TaskModel>>(
          stream: _taskService.getAllTasks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            if (snapshot.hasError) {
              return _buildErrorState();
            }

            final allTasks = snapshot.data ?? [];

            // Calculate priority statistics
            final stats = _calculatePriorityStats(allTasks);

            return Column(
              spacing: 8.sp,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).homeScreenToDoListTitle,
                      style: AppTextStyles.font14BlackCairoMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SvgPicture.asset(
                      'assets/icons_assets/home_assets/todo_checklist_clipboard.svg',
                      width: 20,
                      height: 20,
                      color: AppColors.primary,
                    )
                  ],
                ),
                const SizedBox.shrink(),
                Column(
                  spacing: 10.sp,
                  children: [
                    item(
                      color: AppColors.red,
                      number: '${stats['high']}',
                      icon: 'assets/icons_assets/home_assets/priority_high_red.svg',
                    ),
                    item(
                      color: AppColors.yellow,
                      number: '${stats['medium']}',
                      icon: 'assets/icons_assets/home_assets/priority_medium_important.svg',
                    ),
                    item(
                      color: AppColors.green,
                      number: '${stats['low']}',
                      icon: 'assets/icons_assets/home_assets/priority_low_blue.svg',
                    ),
                  ],
                ),
                const SizedBox.shrink(),

                GestureDetector(
                  onTap: (){
                    navigateTo(context, ToDoListScreen());
                  },
                  child: Container(
                    height: 30.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: AppColors.primary
                    ),
                    child: Center(
                      child: Text(S.of(context).view,style: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.textButton
                      ),),
                    ),
                  ),
                ),
                // customButton(
                //   context: context,
                //    radius: 8.r,
                //     height: 15.h,
                //     color: AppColors.primary,
                //     textStyle: StyleText.fontSize10Weight500.copyWith(
                //       color: AppColors.textButton
                //     ),
                //     title: S.of(context).view, function: (){
                //   navigateTo(context, ToDoListScreen());
                // })
              ],
            );
          },
        ),
      ),
    );
  }

  Map<String, int> _calculatePriorityStats(List<TaskModel> tasks) {
    // Filter out deleted tasks only
    final activeTasks = tasks.where(
          (task) => task.taskStatus.current != TaskStatus.deleted,
    ).toList();

    int highCount = 0;
    int mediumCount = 0;
    int lowCount = 0;

    for (var task in activeTasks) {
      final priority = task.priority.current;

      if (priority == TaskPriority.high) {
        highCount++;
      } else if (priority == TaskPriority.medium) {
        mediumCount++;
      } else if (priority == TaskPriority.low) {
        lowCount++;
      }
    }

    return {
      'high': highCount,
      'medium': mediumCount,
      'low': lowCount,
      'total': activeTasks.length,
    };
  }

  Widget _buildLoadingState() {
    return Column(
      spacing: 8.sp,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.current.homeScreenToDoListTitle,
              style: AppTextStyles.font14BlackCairoMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SvgPicture.asset(
              'assets/icons_assets/home_assets/todo_checklist_clipboard.svg',
              width: 20,
              height: 20,
              color: AppColors.primary,
            )
          ],
        ),
        const SizedBox.shrink(),
        const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      spacing: 8.sp,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.current.homeScreenToDoListTitle,
              style: AppTextStyles.font14BlackCairoMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SvgPicture.asset(
              'assets/icons_assets/home_assets/todo_checklist_clipboard.svg',
              width: 20,
              height: 20,
              color: AppColors.primary,
            )
          ],
        ),
        const SizedBox.shrink(),
        Text(
          S.current.errorLoadingTasks,
          style: AppTextStyles.font12BlackCairoRegular
              .copyWith(color: AppColors.red, fontSize: 10.sp),
        ),
      ],
    );
  }

  Widget item({
    required Color color,
    required String number,
    required String icon,
  }) {
    return Row(
      spacing: 4.sp,
      children: [
        SvgPicture.asset(
          icon,
          width: 15,
          height: 15,
          color: color,
        ),
        Text(
          number,
          style: AppTextStyles.font12BlackCairoRegular
              .copyWith(fontWeight: FontWeight.bold, color: color),
        )
      ],
    );
  }
}
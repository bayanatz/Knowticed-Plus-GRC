import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/standard_container.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
// REMOVED_MODULE: import 'package:demo_app/features/todo_new_module/external/tasks_module/category/data/models/task_model_updates_with_field_history.dart';
// REMOVED_MODULE: import 'package:demo_app/features/todo_new_module/external/tasks_module/category/domain/services/task_services.dart';
import 'package:demo_app/features/home/home_page/data_source/models/home_component_model.dart';
import 'package:demo_app/features/home/helper/todo_new_module/tasks_stub.dart';


class MyTodo extends StatelessWidget {
  MyTodo({required this.model, super.key});
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

            // Calculate statistics
            final stats = _calculateTaskStats(allTasks);

            return Column(
              spacing: 8.sp,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'To-Do List'.tr,
                      style: AppTextStyles.font14BlackCairoMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SvgPicture.asset(
                      'assets/skeleton/home/icons/todo.svg',
                      width: 20,
                      height: 20,
                      color: AppColors.primary,
                    )
                  ],
                ),
                const SizedBox.shrink(),
                Text(
                  '${'Total'.tr}: ${stats['total']}',
                  style: AppTextStyles.font14BlackSemiBoldCairo
                      .copyWith(color: AppColors.secondaryText),
                ),
                Column(
                  spacing: 10.sp,
                  children: [
                    item(
                      color: AppColors.green,
                      number: '${stats['done']}',
                      icon: 'assets/icons_assets/home_assets/todo_done.svg',
                    ),
                    item(
                      color: AppColors.yellow,
                      number: '${stats['scheduled']}',
                      icon: 'assets/icons_assets/home_assets/todo_future.svg',
                    ),
                    item(
                      color: AppColors.red,
                      number: '${stats['overdue']}',
                      icon: 'assets/icons_assets/home_assets/todo_overdue.svg',
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Map<String, int> _calculateTaskStats(List<TaskModel> tasks) {
    final now = DateTime.now();

    // Filter out deleted tasks
    final activeTasks = tasks.where(
          (task) => task.taskStatus.current != 'deleted',
    ).toList();

    int doneCount = 0;
    int scheduledCount = 0;
    int overdueCount = 0;

    for (var task in activeTasks) {
      final status = task.taskStatus.current;

      // Count done tasks
      if (status == 'done') {
        doneCount++;
        continue;
      }

      // Count scheduled tasks (future tasks)
      if (status == 'scheduled') {
        final scheduled = task.currentScheduled;
        if (scheduled != null) {
          final taskStartDate = scheduled.taskStartDate;
          if (taskStartDate.isAfter(now)) {
            scheduledCount++;
            continue;
          }
        }
      }

      // Count overdue tasks
      if (_taskService.isTaskOverdue(task, now)) {
        overdueCount++;
      }
    }

    return {
      'total': activeTasks.length,
      'done': doneCount,
      'scheduled': scheduledCount,
      'overdue': overdueCount,
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
              'To-Do List'.tr,
              style: AppTextStyles.font14BlackCairoMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SvgPicture.asset(
              'assets/skeleton/home/icons/todo.svg',
              width: 20,
              height: 20,
              color: AppColors.primary,
            )
          ],
        ),
        const SizedBox.shrink(),
        const Center(
          child: CircularProgressIndicator(),
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
              'To-Do List'.tr,
              style: AppTextStyles.font14BlackCairoMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SvgPicture.asset(
              'assets/skeleton/home/icons/todo.svg',
              width: 20,
              height: 20,
              color: AppColors.primary,
            )
          ],
        ),
        const SizedBox.shrink(),
        Text(
          'Error loading tasks'.tr,
          style: AppTextStyles.font12BlackCairoRegular
              .copyWith(color: AppColors.red),
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
import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/core/custom/23-custom_check_box.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/standard_container.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
// REMOVED_MODULE: import 'package:grc_module/features/todo_new_module/external/tasks_module/category/data/models/task_model_updates_with_field_history.dart';
// REMOVED_MODULE: import 'package:grc_module/features/todo_new_module/external/tasks_module/category/domain/services/task_services.dart';
// REMOVED_MODULE: import 'package:grc_module/features/todo_new_module/external/tasks_module/core/enums/task_status_enum.dart';
import 'package:grc_module/features/home/h1_home_page/data_source/models/home_component_model.dart';
import 'package:grc_module/features/home/main_controller/helper/todo_new_module/tasks_stub.dart';
import 'package:grc_module/generated/l10n.dart';

class MyTodoCheckBox extends StatelessWidget {
  MyTodoCheckBox({required this.model, super.key});
  final HomeComponentModel model;
  final TaskFirebaseService _taskService = TaskFirebaseService();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 265.sp,
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

            // Get active (non-deleted, non-done) tasks, limit to 3
            final activeTasks = allTasks
                .where((task) =>
            task.taskStatus.current != TaskStatus.deleted &&
                task.taskStatus.current != TaskStatus.done)
                .take(3)
                .toList();

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
                if (activeTasks.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Text(
                        S.of(context).noActiveTasks,
                        style: StyleText.fontSize12Weight500.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  )
                else
                  ...activeTasks.map((task) => _buildTaskItem(task)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task) {
    // Calculate completed items
    final items = task.currentItems ?? [];
    final completedCount = items.where((item) => item.itemStatus == TaskStatus.done).length;
    final totalCount = items.length;
    final isAllCompleted = totalCount > 0 && completedCount == totalCount;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _taskService.updateTaskStatusUi(task);
            },
            child: CustomCheckBox(
              isSelected: task.taskStatus.current == TaskStatus.done,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              FormatHelper.capitalize(task.name.current ?? S.current.untitledTask),
              style: StyleText.fontSize12Weight500.copyWith(
                color: AppColors.text,
                decoration: task.taskStatus.current == TaskStatus.done
                    ? TextDecoration.lineThrough
                    : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          if (totalCount > 0)
            Container(
              width: 40.w,
              height: 20.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: isAllCompleted ? AppColors.green : AppColors.primary,
              ),
              child: Center(
                child: Text(
                  "$completedCount/$totalCount",
                  style: StyleText.fontSize10Weight500.copyWith(
                    color: AppColors.textButton,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
}
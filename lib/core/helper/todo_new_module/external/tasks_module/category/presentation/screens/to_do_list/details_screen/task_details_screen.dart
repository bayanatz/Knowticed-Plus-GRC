import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/core/helper/todo_new_module/core_widgets/main_widget/side_frame_master.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' as util;
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_colors.dart';

import 'package:demo_app/core/custom/circle_progress.dart';
import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/core/network/get_base_url.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import '../../../../../core/custom_widgets/custom_button_widget.dart';
import '../../../../../core/custom_widgets/custom_pop_up_dialog_widget.dart';
import '../../../../../core/custom_widgets/custom_side_bar_widget.dart';
import '../../../../../core/custom_widgets/svg_custom.dart';
import '../../../../../core/enums/task_status_enum.dart';
import '../../../../../core/utilties/images.dart';
import '../../../../data/models/task_model_updates_with_field_history.dart';
import '../../../../domain/services/task_services.dart';
import '../../../widgets/custom_task_details_card.dart';
import '../create_to_do_list/create_screen.dart';
import '../home_screen.dart';

class ToDoDetailsScreen extends StatefulWidget {
  final TaskModel task;

  const ToDoDetailsScreen({Key? key, required this.task}) : super(key: key);
  static String routeName = '/ToDoDetails';

  @override
  State<ToDoDetailsScreen> createState() => _ToDoDetailsScreenState();
}

class _ToDoDetailsScreenState extends State<ToDoDetailsScreen> {
  final TaskFirebaseService _firebaseService = TaskFirebaseService();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var isMobile = context.isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isSameDay = (widget.task.currentScheduled?.taskStartDate != null)
        ? _firebaseService.isSameDay(
            widget.task.currentScheduled!.taskStartDate,
          )
        : false;
    return Scaffold(
      body: SideFrameMasterServices(
        titleText: S.of(context).toDoListTitle,
        onFirstTap: () {
          Navigator.pop(context);
        },
        secondTitle: S.of(context).detailsPageTitle,
        child: isMobile ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 400.h,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance

                    .collection(getBaseUrl('Creating_Task'))
                    .doc(widget.task.taskId.current)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircleProgressMaster(),
                    );
                  }

                  final task = TaskModel.fromFirestore(
                    snapshot.data!,
                  );
                  return Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,
                    children: [
                      if (task.taskStatus.current !=
                          TaskStatus.deleted)
                        _btns(),
                      SizedBox(height: 15.h),
                      CustomTaskDetailsCard(
                        task: task,
                        isSameDay: isSameDay,
                      ),
                      SizedBox(height: 20.h),
                      if (task.taskStatus.current ==
                          TaskStatus.deleted)
                        _restoreButton(),
                      SizedBox(height: 20.h),
                    ],
                  );
                },
              ),
            ),
          ],
        ) :
        Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Container(
                              child: StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance

                                    .collection(getBaseUrl('Creating_Task'))
                                    .doc(widget.task.taskId.current)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  final task = TaskModel.fromFirestore(
                                    snapshot.data!,
                                  );
                                  return Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                    children: [
                                      if (task.taskStatus.current !=
                                          TaskStatus.deleted)
                                        _btns(),
                                      SizedBox(height: 15.h),
                                      CustomTaskDetailsCard(
                                        task: task,
                                        isSameDay: isSameDay,
                                      ),
                                      SizedBox(height: 20.h),
                                      if (task.taskStatus.current ==
                                          TaskStatus.deleted)
                                        _restoreButton(),
                                      SizedBox(height: 20.h),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _restoreButton() {
    return customButton(
      title: S.of(context).restore,
      function: () => _showCreateRestoreDialog(context),
      textStyle: AppTextStyles.font16BlackMediumCairo.copyWith(
        color: AppColors.textButton,
      ),
      width: 135.w,
      height: 38.h,
      radius: 8.r,
      color: AppColors.primary,
    );
  }

  Widget _btns() {
    var isMobile = context.isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        customButtonWithImage(
          title:isMobile ? "": S.of(context).edit,
          function: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CreateToDoScreen(existingTask: widget.task),
              ),
            );
          },
          textStyle: AppTextStyles.font16BlackMediumCairo.copyWith(
            color: AppColors.textButton,
          ),
          width: isMobile ? 38.w : 135.w,
          height: 38.h,
          space: isMobile ? 0.w :4.w,
          radius: 8.r,
          color: AppColors.primary,
          image: 'assets/knowlege_module/editTODO.svg',
          svgColor: AppColors.textButton,
          widthImage:30.sp,
          heightImage: 30.sp,
          colorBorder: Colors.transparent,
        ),
        SizedBox(width: 15.w),
        customButtonWithImage(
          title: isMobile ? "" : S.of(context).delete,
          function: () => _showCreateTodoDialog(context),
          textStyle: AppTextStyles.font16BlackMediumCairo.copyWith(
              color: Colors.white
          ),
          width: isMobile ? 38.w : 135.w,
          height: 38.h,
          space: isMobile ? 0.w : 4.w,
          radius: 8.r,
          svgColor: Colors.white,
          color: AppColors.red,
          image: Images.deleteIcon,
          widthImage: 20.sp,
          heightImage: 20.sp,
          colorBorder: Colors.transparent,
        ),
      ],
    );
  }



  void _showCreateTodoDialog(BuildContext context) {
    var isMobile = context.isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => CustomPopupDialogWithLottie(
        lottiePath: "assets/lottie/delete.json",
        title: S.current.deletingToDoList,
        message: S.current.areYouSureYouWantToDeleteThisListToDo,
        actions: [
          customButton(
            title: S.of(context).no,
            width: 135.w,
            color: lightMode?Colors.grey[400]:Colors.grey[700],
            height: 38.sp,
            textStyle: AppTextStyles.font16BlackMediumCairo.copyWith(
              color: lightMode?Colors.black:Colors.white,
            ),
            radius: 8.r,
            function: () => Navigator.of(dialogContext).pop(),
          ),
          SizedBox(width: isMobile?  10.w : 28.w),
          customButton(
            title: S.of(context).yes,
            width: 135.w,
            color: AppColors.primary,
            height: 38.sp,
            textStyle: AppTextStyles.font16BlackMediumCairo.copyWith(
              color: AppColors.textButton,
            ),
            radius: 8.r,
            function: () => _deleteTask(dialogContext),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });

        return CustomPopupDialogWithLottie(
          lottiePath: Images.approvedLottie,
          title:S.of(context).deletingToDoList ,
          message: S.of(context).youSuccessfullyDeletedThisToDo,
        );
      },
    );
  }

  void _showCreateRestoreDialog(BuildContext context) {
    var isMobile = context.isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => CustomPopupDialogWithLottie(
        lottiePath: Images.retriveLottie,
        title: S.of(context).restoringToDo,
        message: S.of(context).areYouSureYouWantToRestoreThisListToDo,
        actions: [
          customButton(
            title: S.of(context).no,
            width: 135.w,
            color: lightMode?Colors.grey[400]:Colors.grey[700],
            height: 38.sp,
            textStyle: AppTextStyles.font16BlackMediumCairo.copyWith(
              color: lightMode?Colors.black:Colors.white,
            ),
            radius: 8.r,
            function: () => Navigator.of(dialogContext).pop(),
          ),
          SizedBox(width: isMobile ? 10.w : 28.w),
          customButton(
            title: S.of(context).yes,
            width: 135.w,
            color: AppColors.primary,
            height: 38.sp,
            textStyle: AppTextStyles.font16BlackMediumCairo.copyWith(
              color: AppColors.textButton,
            ),
            radius: 8.r,
            function: () => _restoreTask(dialogContext),
          ),
        ],
      ),
    );
  }

  // Restore task
  void _restoreTask(BuildContext dialogContext) async {
    Navigator.of(dialogContext).pop();

    setState(() => _isLoading = true);

    try {
      await _firebaseService.restoreTask(widget.task.taskId.current ?? '');

      // ✅ Show success dialog after restore
      if (mounted) {
        _showSuccessRestoreDialog(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });

        return  CustomPopupDialogWithLottie(
          lottiePath: Images.approvedLottie,
          title: S.of(context).restoringToDo,
          message: S.of(context).youSuccessfullyRestoredThisToDo,
        );
      },
    );
  }

  void _deleteTask(BuildContext dialogContext) async {
    // Close the confirmation dialog first
    Navigator.of(dialogContext).pop();

    setState(() => _isLoading = true);

    try {
      await _firebaseService.updateTaskStatus(
        widget.task.taskId.current ?? '',
        TaskStatus.deleted,
      );

      // Then show success dialog
      if (mounted) {
        _showSuccessDialog(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
        print('Error saving task: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

}

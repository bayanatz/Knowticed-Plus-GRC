import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_checklists.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/add_edit_card_deadline_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/copy_card_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/success_dialog.dart';

class CustomRowWithIcons extends StatefulWidget {
  final String iconPath;
  final String title;
  final VoidCallback? onArrowPressed;
  final bool? isComments;
  final bool? hideDelete;
  final bool? isExpand;
  final bool? isCheckList;
  final bool? isDate;
  final VoidCallback? onTrashPressed;
  final String? board;
  final CardModel? cardModel;
  final CardCheckLists? currentCheckList;

  const CustomRowWithIcons({
    super.key,
    required this.iconPath,
    required this.title,
    this.onArrowPressed,
    this.onTrashPressed,
    this.isComments = false,
    this.hideDelete = false,
    this.isCheckList = false,
    this.isExpand = true,
    this.board,
    this.cardModel,
    this.isDate = false,
    this.currentCheckList,
  });

  @override
  State<CustomRowWithIcons> createState() => _CustomRowWithIconsState();
}

class _CustomRowWithIconsState extends State<CustomRowWithIcons> {
  TaskDetailsController taskController = Get.find();

  final TextEditingController _editingController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _editingController.text = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final TextStyle titleStyle = AppFontStyle.cairoRegularStyle.copyWith(
        fontSize: isTablet
            ? orientation
                ? FontConstants.fontSize019.h
                : FontConstants.fontSize022.h
            : FontConstants.fontSize020.h,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.inverseSurface,
        height: 1.6);
    return GetBuilder<TaskDetailsController>(builder: (controller) {
      return Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.signOut,
              borderRadius: BorderRadius.circular(isTablet ? 28 : 18),
            ),
            padding: EdgeInsets.all(
                isTablet ? (orientation ? 0.009.h : 0.01.h) : 0.009.h),
            child: SvgPicture.asset(
              widget.iconPath,
              height: isTablet ? (orientation ? 0.02.h : 0.02.h) : null,
              color: AppColors.textButton,
            ),
          ),
          SizedBox(
            width: isTablet ? (orientation ? 0.02.w : 0.02.h) : 0.02.w,
          ),
          if (widget.isCheckList == false)
            Text(
              widget.title,
              style: titleStyle,
            ),
          if (widget.isCheckList == true)
            Container(
              child: Text(
                _editingController.text.capitalize!,
                style: titleStyle,
              ),
            ),
          if (widget.isCheckList == true || widget.isDate == true)
            Row(
              children: [
                SizedBox(
                  width: 0.02.w,
                ),
                InkWell(
                  onTap: () {
                    if (widget.isCheckList == true) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CopyCardDialouge(
                            textController: _editingController,
                            isEditCheckList: true,
                            board: widget.board,
                            cardModel: widget.cardModel,
                            currentCheckList: widget.currentCheckList,
                            title: "Edit Check list Name",
                            onPressed: () {},
                            iconUrl: 'assets/icons_assets/task_assets/CheckSquareIcon.svg',
                          );
                        },
                      );
                    }
                    if (widget.isDate == true) {
                      if (widget.cardModel!.cardCreator!.cardCreator!.last ==
                          Get.find<MainCoreEmployeeController>()
                              .employeeEntity!
                              .email!) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AddEditCardDeadlineDialouge(
                              title: "Task Deadline",
                              cardModel: widget.cardModel,
                              board: widget.board,
                              onPressed: () {},
                              isEditDates: true,
                              iconUrl: 'assets/icons_assets/task_assets/taskDeadline.svg',
                            );
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const SuccessDialog(
                              title: "Warning",
                              subtitle: "Only Task Owner Can Edit Deadline",
                              lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
                            );
                          },
                        );
                      }
                    }
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                  child: SvgPicture.asset(
                    'assets/icons_assets/main_icons_assets/isEditIcon.svg',
                    color: AppColors.lightPrimary,
                    height: isTablet ? (orientation ? 0.02.h : 0.03.h) : null,
                  ),
                ),
              ],
            ),
          if (widget.onTrashPressed != null) const Spacer(),
          if (widget.onTrashPressed != null && widget.isExpand == false)
            GestureDetector(
              onTap: widget.onTrashPressed,
              child: SvgPicture.asset(
                'assets/icons_assets/task_assets/deleteIcon.svg',
                height: isTablet ? (orientation ? 0.025.h : null) : null,
              ), //"assets/icons_assets/task_assets/deleteIcon.svg"
            ),
          if (widget.onTrashPressed != null && widget.isExpand == false)
            SizedBox(
              width: isTablet ? 0.06.h : 0.09.w,
            ),
          if (widget.isComments == false && widget.onTrashPressed == null)
            const Spacer(),
          if (widget.isComments == false)
            GestureDetector(
              onTap: widget.onArrowPressed,
              child: widget.hideDelete == true
                  ? SvgPicture.asset(
                      "assets/icons_assets/task_assets/xClose.svg",
                      height: isTablet ? (orientation ? 0.012.h : null) : null,
                    )
                  : SvgPicture.asset(
                      widget.isExpand == true
                          ? 'assets/icons_assets/task_assets/taskOpened.svg'
                          : 'assets/icons_assets/task_assets/taskClosed.svg',
                      color: Theme.of(context).colorScheme.inverseSurface,
                      height: 0.012.h,
                    ), //"assets/icons_assets/task_assets/deleteIcon.svg"
            ),
          if (widget.isComments == true) const Spacer(),
          widget.isComments == true
              ? widget.cardModel!.comments!.isEmpty
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: widget.onArrowPressed,
                      child: Text(
                        "See All".tr,
                        style: titleStyle.copyWith(
                            decoration: TextDecoration.underline,
                            color: AppColors.blue),
                      ),
                    )
              : const SizedBox.shrink(),
        ],
      );
    });
  }
}

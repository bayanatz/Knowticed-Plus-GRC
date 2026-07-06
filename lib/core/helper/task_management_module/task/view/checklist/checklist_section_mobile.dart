import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/screen_size.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_checklists.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';

import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_checklist_section.dart';

/// App Version : Version 2
/// Date of Last Edit :23/April/2024 By Abdullah Ibrahim
/// Objectives: represents the checklist section in the task details screen
class ChecklistWidget extends StatefulWidget {
  final CardCheckLists checklist;
  final String? board;
  final CardModel? cardModel;
  final BoardModel? boardModel;
  void Function()? onDeletePressed;
  ChecklistWidget(
      {super.key,
      required this.checklist,
      this.onDeletePressed,
      this.board,
      this.cardModel,
      required this.boardModel});

  @override
  State<ChecklistWidget> createState() => _ChecklistWidgetState();
}

class _ChecklistWidgetState extends State<ChecklistWidget> {
  TaskDetailsController taskController = Get.find();

  @override
  bool _checkListExpanded = true;

  void _updateCheckListExpanded(bool value) {
    setState(() {
      _checkListExpanded = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return GetBuilder<TaskDetailsController>(
      builder: (controller) {
        print("${widget.checklist.checkListTitle!.last}sssssssssssssssss");

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inversePrimary,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 0.025.h : 0.04.w, vertical: 0.015.h),
          child: ChecklistSection(
            cardCheckLists: widget.checklist,
            onExpandCheckListChanged: _updateCheckListExpanded,
            checkListName: widget.checklist.checkListTitle!.last,
            board: widget.board,
            cardModel: widget.cardModel,
            boardModel: widget.boardModel,
            onDeletePressed: widget.onDeletePressed,
          ),
        );
      },
    );
  }
}

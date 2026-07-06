/// Date Created: 17/2/2025
/// by: Islam Diab
/// objective: Create a widget that displays the header of the project screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/success_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_share_members_dialog_Tablet.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/screen_size.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';

class ProjectHeaderSection extends StatelessWidget {
  final TaskDetailsController controller;
  final BoardModel boardModel;
  final String projectName;
  const ProjectHeaderSection(
      {super.key,
      required this.controller,
      required this.boardModel,
      required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: Get.locale.toString().contains('en') ? 0.02.h : 0,
        right: Get.locale.toString().contains('ar') ? 0.02.h : 0, //0.03.w
      ),

      /// This is the header of the page, it consist of the bread crumbs and if you click on the borad name it will navigate you back ,
      /// it has also the title of the project and the 6 images of the members with the total number of members enrolled in this project, and an invittion
      /// button for inviting new members to this project
      child: ProjectHeader(
        projectName: projectName.tr,
        boardModel: boardModel,
        membersImages: controller.images,
        allMembersNum: controller.allMembersNum,
        onPressed: () {
          hapticController.triggerHapticFeedback(
              vibration: VibrateType.mediumImpact,
              hapticFeedback: HapticFeedback.mediumImpact);

          /// if the board owner can edit members
          if (boardModel.boardCreator ==
              Get.find<MainCoreEmployeeController>().employeeEntity!.email!) {
            List<String> boardMembers = controller.currentCardMembers;

            /// remove the owner from the board members
            if (controller.currentCardMembers.isNotEmpty) {
              if (boardMembers[0] ==
                  Get.find<MainCoreEmployeeController>().employeeEntity!.email!) {
                boardMembers.removeAt(0);
              }
            }

            /// show the share members dialog for the board
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomShareMemberDialogTablet(
                  board: boardModel,
                  edit: controller.currentCardMembers.isNotEmpty ? true : false,
                  onApplyPressed: () {
                    // setState(() {});
                  },
                  selectedMembers: controller.currentCardMembers.isNotEmpty
                      ? boardMembers
                      : [],
                );
              },
            );
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return const SuccessDialog(
                  title: 'Warning',
                  subtitle: 'Only the board owner can edit members',
                  lottieAsset: 'assets/lottie_assets/main_lottie_assets/error.json',
                );
              },
            );
          }
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/search_filter_row_invited_members.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/screen_size.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_members.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_members.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/checklist_item.dart';
import 'package:demo_app/core/theme/app_colors.dart';

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_black_button.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/success_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_container_header_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_members_dialog_Tablet.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_members_dialog_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_members_list_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/circle_progress.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';

/// App Version : Version 2
/// Date of Last Edit :23/April/2024 By Abdullah Ibrahim
/// Objectives: represents the member section in the task details screen
class MemberContainer extends StatefulWidget {
  bool showMembers;
  final VoidCallback toggleShowMembers;
  final String department;
  final String board;
  final CardModel cardModel;
  final BoardModel boardModel;
  MemberContainer({
    super.key,
    required this.showMembers,
    required this.toggleShowMembers,
    required this.department,
    required this.cardModel,
    required this.board,
    required this.boardModel,
  });

  @override
  State<MemberContainer> createState() => _MemberContainerState();
}

class _MemberContainerState extends State<MemberContainer> {
  int memberCounter = 4;
  //List<EmployeeModel> employees = [];
  TaskDetailsController tController = TaskDetailsController();
  List<String> currentCardMembers = [];

  /// Sets the currentCardMembers list based on the cardModel's cardMembers.
  void setMembers() {
    currentCardMembers = [];
    for (int i = 0;
        i < widget.cardModel.cardMembers!.cardMembers!.length;
        i++) {
      if (widget.cardModel.cardMembers!.cardMembersStatus![i] == "invited") {
        currentCardMembers
            .add(widget.cardModel.cardMembers!.cardMembers![i].toString());
      }
    }
    if (currentCardMembers.isNotEmpty) {
      currentCardMembers = currentCardMembers.reversed.toList();
      currentCardMembers
          .add(Get.find<MainCoreEmployeeController>().employeeEntity!.email!);
      currentCardMembers = currentCardMembers.reversed.toList();
    }
  }


  @override
  void initState() {
    super.initState();
    tController.getAllMembersNum(widget.boardModel);
    BoardController().getEmployee();
    BoardController().getAllEmployees();


    setMembers();
  }


  @override
  Widget build(BuildContext context) {
    setMembers();
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return GetBuilder<MainCoreEmployeeController>(
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inversePrimary,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 0.025.h : 0.04.w, vertical: 0.015.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CustomRowWithIcons(
              //   iconPath: "assets/icons_assets/task_assets/memebrsIcon.svg",
              //   title: "Members".tr,
              //   isExpand: widget.showMembers,
              //   onArrowPressed: () {
              //     // Toggle the value of showMembers when delete button is pressed
              //     // This will control the visibility of the member list
              //     setState(() {
              //       widget.showMembers = !widget.showMembers;
              //     });
              //   },
              // ),
              SearchFilterRowInvitedMembers(
                filterColor: true,
                onEditPressed: () {
                  hapticController.triggerHapticFeedback(
                      vibration: VibrateType.lightImpact,
                      hapticFeedback: HapticFeedback.lightImpact);
                  if (widget.cardModel.cardCreator!.cardCreator!.last ==
                      Get.find<MainCoreEmployeeController>()
                          .employeeEntity!
                          .email!) {
                    if (!isTablet) {
                      List<String> cardMembers = currentCardMembers;
                      if (cardMembers[0] ==
                          Get.find<MainCoreEmployeeController>()
                              .employeeEntity!
                              .email!) {
                        cardMembers.removeAt(0);
                      }

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomMemberDialogMobile(
                            boardModel: widget.boardModel,
                            assignCardMember: true,
                            currentListItem: CheckListItems(),
                            board: widget.board,
                            cardModel: widget.cardModel,
                            edit: true,
                            onApplyPressed: () {
                              setState(() {
                                // showMembers = true;
                              });
                            },
                            selectedMembers: cardMembers,
                          );
                        },
                      );
                    } else {
                      //////////////////// ????
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomMemberDialogTablet(
                            boardModel: widget.boardModel,
                            board: widget.board,
                            cardModel: widget.cardModel,
                            edit: true,
                            selectedMembers: currentCardMembers,
                            assignCardMember: true,
                            onApplyPressed: () {},
                          );
                        },
                      );
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const SuccessDialog(
                          title: "Warning",
                          subtitle: "Only Task Owner Can Edit Members",
                          lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
                        );
                      },
                    );
                  }
                },
                onSearchChanged: (p0) {

              }, onFilterPressed: () {

              },),
              if (widget.showMembers == true)
                SizedBox(
                  height: isTablet ? 0.02.h : 0.015.h,
                ),
              if (widget.showMembers == true)
                currentCardMembers.isNotEmpty
                    ? ListView.builder(
                          shrinkWrap: true,
                        itemCount: currentCardMembers.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == memberCounter ? 0 : 0.015.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PersonListTile(
                                  isTaskOwner: index == 0 ? true : false,
                                  imageUrl: controller.getEmployeePhoto(
                                    currentCardMembers[index],
                                  ),
                                  fullName: controller.getEmployeeName(
                                    currentCardMembers[index],
                                  ),
                                  department: widget.department,
                                departmentMember: controller.getEmployeeDepartmentName(
                                  currentCardMembers[index],
                                ),
                                  date: (widget.cardModel.cardMembers?.timestamp?.isNotEmpty ?? false)
                                      ? widget.cardModel.cardMembers!.timestamp!.first.toString()
                                      : "No Date",

                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : const CircleProgress(),
              // if (widget.showMembers == true) SizedBox(height: 0.01.h),
              // if (widget.showMembers == true)
              //   Row(
              //     children: [
              //       CustomBlackButton(
              //         buttonText: 'Edit Member'.tr,
              //         onPressed: () {
              //           hapticController.triggerHapticFeedback(
              //               vibration: VibrateType.lightImpact,
              //               hapticFeedback: HapticFeedback.lightImpact);
              //           if (widget.cardModel.cardCreator!.cardCreator!.last ==
              //               Get.find<AddEmployeeController>()
              //                   .employeeEntity!
              //                   .email!) {
              //             if (!isTablet) {
              //               List<String> cardMembers = currentCardMembers;
              //               if (cardMembers[0] ==
              //                   Get.find<AddEmployeeController>()
              //                       .employeeEntity!
              //                       .email!) {
              //                 cardMembers.removeAt(0);
              //               }
              //
              //               showDialog(
              //                 context: context,
              //                 builder: (BuildContext context) {
              //                   return CustomMemberDialogMobile(
              //                     boardModel: widget.boardModel,
              //                     assignCardMember: true,
              //                     currentListItem: CheckListItems(),
              //                     board: widget.board,
              //                     cardModel: widget.cardModel,
              //                     edit: true,
              //                     onApplyPressed: () {
              //                       setState(() {
              //                         // showMembers = true;
              //                       });
              //                     },
              //                     selectedMembers: cardMembers,
              //                   );
              //                 },
              //               );
              //             } else {
              //               //////////////////// ????
              //               showDialog(
              //                 context: context,
              //                 builder: (BuildContext context) {
              //                   return CustomMemberDialogTablet(
              //                     boardModel: widget.boardModel,
              //                     board: widget.board,
              //                     cardModel: widget.cardModel,
              //                     edit: true,
              //                     selectedMembers: currentCardMembers,
              //                     assignCardMember: true,
              //                     onApplyPressed: () {},
              //                   );
              //                 },
              //               );
              //             }
              //           } else {
              //             showDialog(
              //               context: context,
              //               builder: (context) {
              //                 return const SuccessDialog(
              //                   title: "Warning",
              //                   subtitle: "Only Task Owner Can Edit Members",
              //                   lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
              //                 );
              //               },
              //             );
              //           }
              //         },
              //       ),
              //     ],
              //   ),
            ],
          ),
        );
      },
    );
  }
}

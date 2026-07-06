import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_black_button.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/copy_card_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/delete_archive_card_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_attachments_container.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_container_header_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_project_screen_header.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';

class AttachmentSectionTablet extends StatefulWidget {
  final bool showAttach;
  final VoidCallback toggleShowAttach;
  final CardModel cardModel;
  final String board;

  const AttachmentSectionTablet({
    super.key,
    required this.showAttach,
    required this.toggleShowAttach,
    required this.cardModel,
    required this.board,
  });

  @override
  State<AttachmentSectionTablet> createState() => _AttachmentSectionState();
}

bool expandAttach = true;

class _AttachmentSectionState extends State<AttachmentSectionTablet> {
  TaskDetailsController taskController = Get.find();

  //List<String> allAttachments = [];

  @override
  void initState() {
    if (widget.cardModel.cardAttachments!.cardAttachments!.isNotEmpty) {
      taskController.allAttachments = [];
      for (int i = 0;
          i < widget.cardModel.cardAttachments!.cardAttachments!.length;
          i++) {
        if (widget.cardModel.cardAttachments!.cardAttachmentsStatus![i] ==
            "uploaded") {
          taskController.allAttachments
              .add(widget.cardModel.cardAttachments!.cardAttachments![i]);
        }
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return GetBuilder<TaskDetailsController>(
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
              CustomRowWithIcons(
                iconPath: "assets/icons_assets/task_assets/attachsquareIcon.svg",
                title: "Attachments".tr,
                isExpand: expandAttach,
                onTrashPressed: widget.toggleShowAttach,
                onArrowPressed: () {
                  setState(() {
                    expandAttach = !expandAttach;
                  });
                },
              ),
              if (expandAttach == true) ...[
                SizedBox(height: 0.015.h),
                _buildAttachmentList(),
                SizedBox(height: 0.015.h),
                _buildButtonRow(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentList(/*CardModel cardModel*/) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return GetBuilder<TaskDetailsController>(
      builder: (controller) {
        return Container(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 0.0.h),
            child: SizedBox(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    (controller.allAttachments.length / 2).ceil(),
                    (int index) {
                      int firstIndex = index * 2;
                      int secondIndex = firstIndex + 1;

                      return Padding(
                        padding: EdgeInsets.only(
                            right: isTablet
                                ? (isPortrait ? 0.02.w : 0.01.w)
                                : 0.01.w),
                        child: Column(
                          children: [
                            firstIndex < controller.allAttachments.length
                                ? AttachmentContainer(
                                    context: context,
                                    fileName: controller.getFileNameFromUrl(
                                      controller.allAttachments[firstIndex]
                                          .toString(),
                                    ),
                                    fileSize: controller
                                        .allAttachments[firstIndex]
                                        .toString(),
                                    onTapDelete: () {
                                      controller.allAttachments.remove(
                                          controller
                                              .allAttachments[firstIndex]);
                                      taskController.updateCard(
                                        board: widget.board,
                                        cardModel: widget.cardModel,
                                        cardAttachments:
                                            controller.allAttachments,
                                      );
                                    },
                                    onTapDownload: () async {
                                      var link = Uri.parse(controller
                                          .allAttachments[firstIndex]
                                          .toString());
                                      await launchUrl(
                                        link,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                  )
                                : const SizedBox(),
                            SizedBox(height: 0.015.h),
                            secondIndex < controller.allAttachments.length
                                ? AttachmentContainer(
                                    context: context,
                                    fileName: controller.getFileNameFromUrl(
                                      controller.allAttachments[secondIndex]
                                          .toString(),
                                    ),
                                    fileSize: controller
                                        .allAttachments[secondIndex]
                                        .toString(),
                                    onTapDelete: () {
                                      controller.allAttachments.remove(
                                          controller
                                              .allAttachments[secondIndex]);
                                      taskController.updateCard(
                                        board: widget.board,
                                        cardModel: widget.cardModel,
                                        cardAttachments:
                                            controller.allAttachments,
                                      );
                                    },
                                    onTapDownload: () async {
                                      var link = Uri.parse(controller
                                          .allAttachments[secondIndex]
                                          .toString());
                                      await launchUrl(
                                        link,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonRow() {
    return Row(
      children: [
        CustomBlackButton(
          buttonText: 'Add Item'.tr,
          onPressed: () {
            hapticController.triggerHapticFeedback(
                vibration: VibrateType.lightImpact,
                hapticFeedback: HapticFeedback.lightImpact);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CopyCardDialouge(
                  title: "Add Attachment",
                  onPressed: () {},
                  isAttachment: true,
                  cardModel: widget.cardModel,
                  board: widget.board,
                  iconUrl: 'assets/icons_assets/task_assets/attachsquareIcon.svg',
                );
              },
            );

            /* showDialog(
              context: context,
              builder: (BuildContext context) {
                return CopyCardDialouge(
                  title: "Add Attachment",
                  onPressed: () {},
                  isAttachment: true,
                  iconUrl: 'assets/icons_assets/task_assets/attachsquareIcon.svg',
                );
              },
            );*/
          },
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return DeletOrArchiveDialog(
                  yesOnPressed: () {
                    setState(() {
                      taskController
                          .updateCard(
                        cardModel: widget.cardModel,
                        board: widget.board,
                        deleteAllAttachments: true,
                      )
                          .then((value) {
                        taskController.allAttachments.clear();
                        //expandAttach=false;
                      });
                      //Navigator.of(context).pop();
                    });
                  },
                  isAttachment: true,
                  isDelete: false,
                );
              },
            );
          },
          child: SvgPicture.asset(
            'assets/icons_assets/task_assets/deleteIcon.svg',
            height: 0.025.h,
            color: AppColors.red,
          ),
        ),
      ],
    );
  }
}

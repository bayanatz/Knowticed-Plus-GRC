import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_attachments_container.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/screen_size.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:url_launcher/url_launcher.dart';

// Name: Nour Nabil
// Date: 20/2/2025
// Goal: Refactor screen to display one attachment per row
class AttachmentList extends StatelessWidget {
  final TaskDetailsController controller;
  final CardModel cardModel;
  final String board;

  const AttachmentList({
    super.key,
    required this.controller,
    required this.cardModel,
    required this.board,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(), // Prevent internal scroll
      shrinkWrap: true, // Take only needed height
      itemCount: controller.allAttachments.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h), // Optional spacing
          child: _buildAttachmentContainer(index,context),
        );
      },
    );
  }

  Widget _buildAttachmentContainer(int index, context) {
    return GetBuilder<TaskDetailsController>(
      builder: (controller) {
        // Ensure index is valid before accessing the list
        if (index >= controller.allAttachments.length) {
          return SizedBox(); // Return an empty widget if index is out of range
        }

        return AttachmentContainer(
          context: context,
          fileName: controller.getFileNameFromUrl(controller.allAttachments[index].toString()),
          fileSize: controller.allAttachments[index],
          onTapDelete: () async {
            if (index < controller.allAttachments.length) {
              String removedAttachment = controller.allAttachments[index];
              controller.allAttachments.removeAt(index);
              await controller.updateCard(
                board: board,
                cardModel: cardModel,
                cardAttachments: controller.allAttachments,
              );
              controller.update(); // ✅ Update the ui immediately
              print("Deleted attachment: $removedAttachment");
              print("Updated list: ${controller.allAttachments}");
            }
          },


          onTapDownload: () async {
            if (index < controller.allAttachments.length) {
              var link = Uri.parse(controller.allAttachments[index].toString());
              await launchUrl(link, mode: LaunchMode.externalApplication);
            }
          },
        );
      },
    );
  }

}
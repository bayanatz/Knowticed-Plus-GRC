import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/custom_button.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/features/messaging/features/groups/domain/entity/group_entity.dart';
import 'package:demo_app/features/messaging/interface/controller/messaging_init_controller.dart' hide GroupEntity;

import 'package:demo_app/core/helper/main_helper/cross_axis_count_helper.dart';
import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/core/custom/23-custom_check_box.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
// GroupEntity is defined in messaging_init_controller.dart stub
import 'package:demo_app/features/home/home_page/data_source/models/group_message_model.dart';

class GroupsDialog extends StatefulWidget {
  GroupsDialog({required this.model, required this.onSave, super.key});
  GroupMessageModel model;
  Function() onSave;
  @override
  State<GroupsDialog> createState() => _GroupsDialogState();
}

class _GroupsDialogState extends State<GroupsDialog> {
  List<GroupEntity> allGroups =
      Get.find<MessagingInitController>().getUserGroups();
  List<String> selectedGroups = [];
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    List<GroupEntity> groups = filterGroups();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 15.sp,
      children: [
        Row(
          spacing: 8.sp,
          children: [
            CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 20,
                child: SvgPicture.asset(
                    'assets/icons_assets/home_assets/contact.svg',
                    color: AppColors.textButton)),
            Text('Contact'.tr, style: AppTextStyles.font16BlackMediumCairo)
          ],
        ),
        Row(
          spacing: 10.sp,
          children: [
            AppSearchTextField(
              controller: controller,
              onChanged: (value) {
                setState(() {});
              },
              fillColor: AppColors.background,
            ),
          ],
        ),
        Expanded(
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
                          context),
                  mainAxisExtent: 75.sp,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: MediaQuery.of(context).size.shortestSide < 600 ? 1.5 : 1.2,
                ),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  return groupView(groups[index]);
                })),
        SizedBox(height: 20.sp),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomButton(
              buttonText: 'Cancel'.tr,
              onTap: () {
                Navigator.of(context).pop();
              },
              buttonColor: AppColors.secondaryButton,
              textStyle: AppTextStyles.font16BlackRegularCairo,
              width: 135,
            ),
            CustomButton(
              buttonText: 'Add'.tr,
              onTap: () {
                widget.model.groupIds = selectedGroups.toSet().toList();
                Navigator.of(context).pop();
                widget.onSave?.call();
              },
              width: 135,
            )
          ],
        ),
        SizedBox(height: 20.sp)
      ],
    );
  }

  List<GroupEntity> filterGroups() {
    List<GroupEntity> filteredGroups = [];
    for (GroupEntity group in allGroups) {
      if (controller.text.isEmpty) {
        filteredGroups.add(group);
      } else {
        if ((context.isArabic!
                ? group.secondaryLanguageName
                : group.primaryLanguageName)!
            .toLowerCase()
            .contains(controller.text.toLowerCase())) {
          filteredGroups.add(group);
        }
      }
    }

    return filteredGroups;
  }

  Widget groupView(GroupEntity group) {
    bool isSelected = selectedGroups.contains(group.groupId!);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedGroups.contains(group.groupId!)) {
            selectedGroups.remove(group.groupId!);
          } else {
            selectedGroups.add(group.groupId!);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsetsDirectional.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20.sp,
              backgroundColor: AppColors.primary,
              backgroundImage: group.imageUri.contains('http')
                  ? NetworkImage(group.imageUri)
                  : AssetImage(group.imageUri),
            ),
            SizedBox(width: 10.sp),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FormatHelper.capitalize(context.isArabic
                        ? group.secondaryLanguageName!
                        : group.primaryLanguageName!),
                    style: AppTextStyles.font14BlackCairoMedium
                        .copyWith(height: 1),
                  ),
                ],
              ),
            ),
            Align(
                alignment: AlignmentDirectional.topEnd,
                child: CustomCheckBox(isSelected: isSelected)),
          ],
        ),
      ),
    );
  }
}

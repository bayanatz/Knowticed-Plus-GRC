import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_checklist_invited_members.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/date_time_in_arabic.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/row_icon_text.dart';
import 'package:demo_app/core/utils/app_image_provider.dart';

class CustomInvitedMembersContainerMobile extends StatelessWidget {
  const CustomInvitedMembersContainerMobile({
    super.key,
    required this.invitedMember,
  });

  final CardChecklistInvitedMembers invitedMember;

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    String statusLower = invitedMember.status.toLowerCase();
    Color statusColor;

    switch (statusLower) {
      case 'done':
        statusColor = AppColors.unBlock;
        break;
      case 'exceeded deadline':
        statusColor = AppColors.delete;
        break;
      case 'not started':
        statusColor = AppColors.secondaryColor;
        break;
      case 'in progress':
        statusColor = AppColors.warning;
        break;
      default:
        statusColor = Theme.of(context).colorScheme.inverseSurface;
    }
    double heightSpacer = 0.015.h;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.inversePrimary,
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.04.w, vertical: 0.02.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (invitedMember.memberImage != null)
                        invitedMember.memberImage!.contains('assets')
                            ? CircleAvatar(
                                radius: 0.04.w,
                                backgroundColor: Colors.transparent,
                                backgroundImage:
                                    appImageProvider(invitedMember.memberImage!),
                              )
                            : CircleAvatar(
                                radius: 0.04.w,
                                backgroundColor: Colors.transparent,
                                backgroundImage:
                                    NetworkImage(invitedMember.memberImage!),
                              ),
                      if (invitedMember.memberImage != null)
                        SizedBox(width: 0.015.w),
                      Expanded(
                        child: Text(
                          invitedMember.memberName.capitalize!,
                          style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: FontConstants.fontSize018.h,
                            color: themeController.currentTheme ==
                                    AppColors.lightTheme
                                ? AppColors.colorBlack
                                : AppColors.colorWhiteDark,
                            fontWeight: FontWeight.w500,
                            height: 1.6,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 0.015.w),
                Text(
                  invitedMember.status.capitalize!.tr,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: FontConstants.fontSize018.h,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: heightSpacer),
            RowIconTextAnnouncement(
              iconUrl: "assets/icons_assets/main_icons_assets/details_User Plus.svg",
              text: "Card",
              hideImage: true,
              value: invitedMember.card,
            ),
            SizedBox(height: heightSpacer),
            RowIconTextAnnouncement(
              iconUrl: "assets/icons_assets/main_icons_assets/details_User Plus.svg",
              text: "Task",
              hideImage: true,
              value: invitedMember.task,
            ),
            if (invitedMember.startDate != null ||
                invitedMember.endDate != null)
              SizedBox(height: heightSpacer),
            Row(
              children: [
                if (invitedMember.startDate != null)
                  Expanded(
                    child: RowIconTextAnnouncement(
                      iconUrl: "assets/icons_assets/main_icons_assets/details_User Plus.svg",
                      hideImage: true,
                      text: "Start Date",
                      value: Get.locale.toString().contains('en')
                          ? invitedMember.startDate!
                          : translateDate(invitedMember.startDate!),
                    ),
                  ),
                if (invitedMember.startDate != null &&
                    invitedMember.endDate != null)
                  SizedBox(width: 0.01.w),
                if (invitedMember.endDate != null)
                  Expanded(
                    child: RowIconTextAnnouncement(
                      iconUrl: "assets/icons_assets/main_icons_assets/details_User Plus.svg",
                      text: "End Date",
                      hideImage: true,
                      value: Get.locale.toString().contains('en')
                          ? invitedMember.endDate!
                          : translateDate(invitedMember.endDate!),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

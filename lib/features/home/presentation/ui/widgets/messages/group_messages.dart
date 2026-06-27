import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/features/home/widgets/standard_container.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/features/messaging/features/groups/domain/entity/group_entity.dart';
import 'package:demo_app/features/messaging/interface/controller/messaging_init_controller.dart';
import 'package:demo_app/features/home/data/models/group_message_model.dart';

import 'package:demo_app/features/home/core_widgets/main_widget/custom_button.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../messaging/interface/message_interface_consumer.dart';

class GroupMessages extends StatelessWidget {
  GroupMessages({required this.model, super.key});
  GroupMessageModel model;

  /// Safely fetches groups — returns empty list if MessagingInitController
  /// has not yet been initialized via useGroupAndSingleMessaging().
  List<GroupEntity> _getGroups() {
    try {
      return Get.find<MessagingInitController>()
          .getUserGroups()
          .where((group) => model.groupIds.contains(group.groupId))
          .toList();
    } catch (e) {
      print('⚠️ GroupMessages: MessagingInitController not ready yet — $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<GroupEntity> groups = _getGroups();

    return StandardContainer(
      height: 175.h,
      child: Column(
        children: [
          Container(width: 140.sp),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 10.sp,
            children: [
              for (GroupEntity group in groups)
                Column(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.grey,
                      backgroundImage: (group.groupImage == null)
                          ? null
                          : (group.groupImage!.contains('http'))
                          ? NetworkImage(group.groupImage!) as ImageProvider
                          : AssetImage(group.groupImage!),
                      child: (group.groupImage == null)
                          ? SvgPicture.asset(
                          'assets/skeleton/home/icons/contact.svg')
                          : null,
                    ),
                    SizedBox(height: 5.sp),
                    Text(
                      FormatHelper.capitalize(context.isArabic!
                          ? group.secondaryLanguageName!
                          : group.primaryLanguageName!),
                      style: AppTextStyles.font10BlackCairoRegular
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 23.sp),
                    CustomButton(
                      buttonText: 'Messages'.tr,
                      width: 140,
                      onTap: () {
                        MessageInterfaceConsumer.openGroupChat(
                            group.groupId, context);
                      },
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
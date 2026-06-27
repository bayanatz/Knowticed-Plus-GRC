/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import '../../../../../../core/theme/font_manager.dart';
import 'package:demo_app/core/custom/circle_progress.dart';
import 'package:demo_app/features/notification/core_widgets/main_widget/custom_appbar.dart';
import '../../../controller/notification_controller.dart';
import '../../widgets/custom_notification_chat.dart';

// Date Created :4/December/2023
// Developer Name : Bassem Mohamed
//App Version : Version 2
// Date of Last Edit :10/December/2023
// Objectives: this is screen shows the notification available for each user

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  bool checkedIn = false;
  bool isNotifications = true;

  MainCoreNotificationController appNotificationController = Get.find();

  @override
  void initState() {
    appNotificationController.fetchNotifications();
    appNotificationController.updateSeenNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      body: SafeArea(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppBar(
                    isNotifications: isNotifications,
                    isNotState: (value) {
                      setState(() {
                        isNotifications = value;
                      });
                    },
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 0.02.h,
                        horizontal: 0.02.h, //0.03.w,
                      ),
                      child: GetBuilder<MainCoreNotificationController>(
                          builder: (controller) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Notifications".tr,
                              style: AppFontStyle.cairoRegularStyle.copyWith(
                                  fontSize: isPortrait
                                      ? FontConstants.fontSize028.h
                                      : FontConstants.fontSize038.h,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.1,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: isPortrait ? 0.015.h : 0.02.h),
                              child: Container(
                                height: isPortrait ? 0.81.h : 0.75.h,
                                child: controller.isLoading
                                    ? const CircleProgress()
                                    : controller.allNotifications.isEmpty
                                        ? const Center(
                                            child: Text('No Notifications'))
                                        : ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: controller
                                                .allNotifications.length,
                                            itemBuilder: (context, index) {
                                              return CustomNotificationChatMobile(
                                                  notification: controller
                                                      .allNotifications[index],
                                                  isChat: false,
                                                  time: "Today at 10 : 00 AM");
                                            },
                                          ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}
*/

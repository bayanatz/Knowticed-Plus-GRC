/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/notification/core_widgets/main_widget/custom_appbar_mobile.dart';
import '../../../../../../core/theme/font_manager.dart';
import 'package:demo_app/core/custom/circle_progress.dart';
import '../../../controller/notification_controller.dart';
import '../../widgets/custom_notification_chat.dart';
import 'package:lottie/lottie.dart';


class NotificationScreenMobile extends StatefulWidget {
  const NotificationScreenMobile({super.key});

  @override
  State<NotificationScreenMobile> createState() =>
      _NotificationScreenMobileState();
}

class _NotificationScreenMobileState extends State<NotificationScreenMobile> {
  bool isEmpty = false;

  MainCoreNotificationController appNotificationController = Get.find();

  @override
  void initState() {
    appNotificationController.fetchNotifications();
    appNotificationController.updateSeenNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GetBuilder<MainCoreNotificationController>(builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomAppBarMobile(
                showIcon: true,
                title: "Notifications",
                isHome: false,
              ),
              isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.2.h),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Transform.scale(
                                scale: 1.5,
                                child: Lottie.asset(
                                    'assets/images/empty_notify2.json')),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 0.08.h),
                              child: Text(
                                "No Notifications".tr,
                                style: AppFontStyle.cairoRegularStyle.copyWith(
                                    fontSize: FontConstants.fontSize022.h,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inverseSurface),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: controller.isLoading
                          ? const CircleProgress()
                          : controller.allNotifications.isEmpty
                              ? const Center(child: Text('No Notifications'))
                              : Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 0.04.w),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount:
                                        controller.allNotifications.length,
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
              SizedBox(
                height: 0.015.h,
              )
            ],
          );
        }),
      ),
    );
  }
}
*/

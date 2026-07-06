import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/theme_controller.dart';import 'package:demo_app/core/helper/task_management_module/borad/view/board_home/board_screen_mobile.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_drawer.dart';

final ThemeController themeController = Get.put(ThemeController());

class SelectionUser extends StatefulWidget {
  const SelectionUser({super.key});

  @override
  State<SelectionUser> createState() => _SelectionUserState();
}

class _SelectionUserState extends State<SelectionUser> {
  GetStorage box = GetStorage();

  @override
  void initState() {
    super.initState();

    MediaQuery.of(Get.context!).size.shortestSide > 600
        ? themeController.updateSystemUIOverlayStyleTablet()
        : themeController.updateSystemUIOverlayStyleMobile();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    // box.write('SelectedTheme', savedTheme.toString());
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 0.5.w,
              height: 0.07.h,
              child: ElevatedButton(
                onPressed: () {
                  isTablet
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CustomDrawer(
                                    initialIndex: 1,
                                  )))
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BoardScreenMobile()));
                },
                child: Text(
                  'Tasks',
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: isTablet
                          ? FontConstants.fontSize032.h
                          : FontConstants.fontSize018.h,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

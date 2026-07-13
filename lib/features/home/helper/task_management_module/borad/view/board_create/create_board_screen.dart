import 'package:demo_app/core/helper/task_management_module/core/components/custom_create_board.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/theme/app_colors.dart';


import 'package:demo_app/core/helper/data_grc_module/constant/theme_controller.dart';
import '../../../../../../../core/local_widgets/custom_appbar_mobile.dart';

/// Date Created :12/November/2023
/// Developer Name : Nour Nabil
/// App Version : Version 2.1.0
/// Date of Last Edit :15/mar/2024
/// Objectives: this screen is the home page, this page consist of multiple widgets:
///
class CreateBoardScreenMobile extends StatelessWidget {
  final BoardModel? board;
  const CreateBoardScreenMobile({
    super.key,
    this.board,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          height: 0.87.h,
          color: themeController.currentTheme == AppColors.lightTheme
              ? AppColors.colorLightGrey
              : AppColors.colorBlack,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBarMobile(
                  showIcon: true,
                  title: board == null
                      ? "Creating New Board"
                      : 'Editing ${board?.boardName?.boardgName?.last}',
                  onIconPressed: () {},
                ),
                SizedBox(
                  height: .014.h,
                ),
                Container(
                  color: themeController.currentTheme == AppColors.lightTheme
                      ? AppColors.moreLightGrey
                      : AppColors.black,
                  padding: EdgeInsets.symmetric(horizontal: 0.04.w),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 0.0.h),
                          child: Column(
                            children: [
                              CustomCreateBoardContainer(
                                boardModel: board,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String getCurrentDate() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd MMMM yyyy').format(now);
  return formattedDate;
}

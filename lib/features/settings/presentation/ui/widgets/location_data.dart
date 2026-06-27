///*********************** FILE INFO ********************///
/// Purpose: This file contains the LocationData widget in settings personal information
/// Author: Mohamed Elrashidy
/// Created At: 10/11/2024


import 'package:flutter/material.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/settings/core_widgets/form_fields/profile_textfield.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';

import '../../../../../generated/l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../pages/settings_screen.dart';
import 'settings_header.dart';

class LocationData extends StatefulWidget {
  const LocationData({super.key});

  @override
  State<LocationData> createState() => _LocationDataState();
}

class _LocationDataState extends State<LocationData> {
  late TextEditingController _countryController;
  late TextEditingController _provinceController;
  late TextEditingController _cityController;
  late TextEditingController _streetController;

  @override
  void initState() {
    super.initState();
    _countryController = TextEditingController(
      text: capitalize('${employee!.country?.lastOrNull ?? ""}'),
    );
    _provinceController = TextEditingController(
      text: capitalize('${employee!.province?.lastOrNull ?? ""}'),
    );
    _cityController = TextEditingController(
      text: capitalize('${employee!.city?.lastOrNull ?? ""}'),
    );
    _streetController = TextEditingController(
      text: employee!.street?.lastOrNull != null
          ? capitalize('${employee!.street!.lastOrNull}')
          : "",
    );
  }

  @override
  void dispose() {
    _countryController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isPhone = context.isPhone;

    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      decoration: isPhone
          ? BoxDecoration(
          borderRadius: BorderRadius.circular(0),
        color:  AppColors.card,
      )
          : BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        color:  AppColors.card,
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 15.sp,right: 15.sp,left: 15.sp),
        child: Column(
          children: [

            SettingsHeader(
                imagePath: 'assets/new_location.svg',
                text: S.of(context).location),

            SizedBox(height: 10.sp),

            // Country, Province, City in one row
            isPortrait
                ? Column(
              children: [
                // Country Field
                Stack(
                  children: [
                    CustomTextField(
                      label: S.of(context).country,
                      hint: 'Enter Your Country'.tr,
                      controller: _countryController,
                      enabled: false,
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        color: Colors.transparent,
                      ),
                    ),
                  ],
                ),
                isPhone ? SizedBox() : SizedBox(height: 16.h),

                // Province Field
                Stack(
                  children: [
                    CustomTextField(
                      label: S.of(context).stateOrProvince,
                      hint: 'Enter Your State Or Province'.tr,
                      controller: _provinceController,
                      enabled: false,
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        color: Colors.transparent,
                      ),
                    ),
                  ],
                ),
                isPhone ? SizedBox() : SizedBox(height: 16.h),

                // City Field
                Stack(
                  children: [
                    CustomTextField(
                      label: S.of(context).city,
                      hint: 'Enter Your City'.tr,
                      controller: _cityController,
                      enabled: false,
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        color: Colors.transparent,
                      ),
                    ),
                  ],
                ),
                isPhone ? SizedBox() : SizedBox(height: 16.h),
              ],
            )
                : Row(
              children: [
                // Country Field
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: Get.locale.toString().contains('en') ? 0.01.w : 0,
                      left: Get.locale.toString().contains('ar') ? 0.01.w : 0,
                    ),
                    child: Stack(
                      children: [
                        CustomTextField(
                          label: S.of(context).country,
                          hint: 'Enter Your Country'.tr,
                          controller: _countryController,
                          enabled: false,
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            color: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Province Field
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 0.005.w,
                    ),
                    child: Stack(
                      children: [
                        CustomTextField(
                          label: S.of(context).stateOrProvince,
                          hint: '_',
                          controller: _provinceController,
                          enabled: false,
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            color: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // City Field
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: Get.locale.toString().contains('en') ? 0.01.w : 0,
                      right: Get.locale.toString().contains('ar') ? 0.01.w : 0,
                    ),
                    child: Stack(
                      children: [
                        CustomTextField(
                          label: S.of(context).city,
                          hint: 'Enter Your City'.tr,
                          controller: _cityController,
                          enabled: false,
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            color: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

         //   SizedBox(height: 0.01.h),

            // Street Field (Full Width)
            CustomTextField(
              label: S.of(context).streetName,
              hint: '-',
              controller: _streetController,
              enabled: false,
            ),

           // isPhone ? SizedBox() : SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
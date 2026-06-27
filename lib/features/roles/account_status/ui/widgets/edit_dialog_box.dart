import 'package:demo_app/features/roles/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/helper/knowledge_hub_module/core/custom_drop_down.dart';
import 'package:demo_app/core/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'package:demo_app/features/roles/account_status/domain/entity/account_status_access_entity.dart';
import 'package:demo_app/generated/l10n.dart'; // ✅ Add this import

import 'package:demo_app/features/roles/core_widgets/main_widget/custom_button.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/custom_drop_down.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/roles/account_status/controller/account_status_cubit.dart';

class EditAccessDetailsDialog extends StatefulWidget {
  EditAccessDetailsDialog({
    required this.accountStatusEntity,
    super.key,
  });
  AccountStatusAccessEntity accountStatusEntity;

  @override
  State<EditAccessDetailsDialog> createState() => _EditAccessDetailsDialogState();
}

class _EditAccessDetailsDialogState extends State<EditAccessDetailsDialog> {
  late AccountStatusCubit controller;
  late TextEditingController expirationTimeController;
  late TextEditingController defaultPasswordController;
  String? selectedTimeUnit;

  late List<Map<String, String>> timeUnits;

  @override
  void initState() {
    super.initState();
    expirationTimeController = TextEditingController(
        text: widget.accountStatusEntity.expirationTimeOfPassword);
    defaultPasswordController = TextEditingController(
        text: widget.accountStatusEntity.tempPassword);

    // ✅ FIX: Initialize with current value from entity and capitalize it
    String unitFromFirebase = widget.accountStatusEntity.expirationTimeUnit;
    // Capitalize first letter to match dropdown items (Day, Week, Month, Year)
    selectedTimeUnit = unitFromFirebase.isNotEmpty
        ? unitFromFirebase[0].toUpperCase() + unitFromFirebase.substring(1).toLowerCase()
        : 'Week';

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Initialize time units with localized values
    timeUnits = [
      {"key": "Day", "value": S.of(context).day},
      {"key": "Week", "value": S.of(context).week},
      {"key": "Month", "value": S.of(context).month},
      {"key": "Year", "value": S.of(context).year},
    ];
  }

  @override
  void dispose() {
    expirationTimeController.dispose();
    defaultPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    controller = context.read<AccountStatusCubit>();
    bool isTablet = MediaQuery.of(context).size.width > 600;
    final isArabic = context.isArabic;

    return Container(
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      width: isTablet ? 500.sp : 350.sp,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            spacing: 10.sp,
            children: [
              CircleAvatar(
                radius: 15.sp,
                backgroundColor: AppColors.primary,
                child: SvgPicture.asset(
                  'assets/skeleton/roles/icons/edit_schedule_icon.svg',
                  width: 12.sp,
                  height: 16.sp,
                  color: AppColors.textButton,
                ),
              ),
              Text(
                S.of(context).editingAccessDetails,
                style: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.text
                ),
              ),
            ],
          ),

          SizedBox(height: 15.h),

          Text(
            S.of(context).expirationTime,
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text
            ),
          ),
          // Expiration Time Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 0.sp,
            children: [
              Row(
                spacing: 10.h,
                children: [
                  // Plus/Minus Container with Number
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Container(
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        children: [
                          // Minus Button
                          InkWell(
                            onTap: () {
                              int currentValue = int.tryParse(expirationTimeController.text) ?? 1;
                              if (currentValue > 1) {
                                expirationTimeController.text = (currentValue - 1).toString();
                                setState(() {});
                              }
                            },
                            child: Container(
                              width: 40.sp,
                              height: 36.sp,
                              child: Icon(
                                Icons.remove,
                                color: AppColors.secondaryText,
                                size: 20.sp,
                              ),
                            ),
                          ),

                          // Number Display
                          Container(
                            width: 50.sp,
                            child: Center(
                              child: Text(
                                expirationTimeController.text,
                                style: StyleText.fontSize14Weight400.copyWith(
                                    color: AppColors.text
                                ),
                              ),
                            ),
                          ),

                          // Plus Button
                          InkWell(
                            onTap: () {
                              int currentValue = int.tryParse(expirationTimeController.text) ?? 1;
                              expirationTimeController.text = (currentValue + 1).toString();
                              setState(() {});
                            },
                            child: Container(
                              width: 40.sp,
                              height: 36.sp,
                              child: Icon(
                                Icons.add,
                                color: AppColors.secondaryText,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Time Unit Dropdown
                  Expanded(
                    child: CustomDropdownFormFieldInvMaster(
                      selectedValue: selectedTimeUnit,
                      borderRadius: 4.r,
                      items: timeUnits,
                      height: 36,
                      widthIcon: 14,
                      heightIcon: 7,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedTimeUnit = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Default Password Section
          CustomTextField(
            label: S.of(context).defaultPassword,
            hint: S.of(context).enterDefaultPassword,
            controller: defaultPasswordController,
            textDirection: TextDirection.ltr,
          ),

          SizedBox(height: 15.h),

          // Action Buttons
          Row(
            children: [
              customButton(
                width: ContextExtension(context).isPhone ? 120.w : 135.w,
                height: 38.h,
                color: Color(0xffCCCCCCCC),
                textStyle: StyleText.fontSize16Weight500.copyWith(
                  color: Colors.black,
                ),
                title: S.of(context).discard,
                function: () {
                  Navigator.of(context).pop();
                },
              ),
              Spacer(),
              customButton(
                width: ContextExtension(context).isPhone ? 120.w : 135.w,
                height: 38.h,
                textStyle: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.textButton
                ),
                color: AppColors.primary,
                title: S.of(context).save,
                function: () {

                  // Validate input
                  if (expirationTimeController.text.isEmpty) {
                    Get.snackbar(
                      S.of(context).error,
                      S.of(context).pleaseEnterExpirationTime,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: EdgeInsets.all(10.sp),
                    );
                    return;
                  }

                  if (defaultPasswordController.text.isEmpty) {
                    Get.snackbar(
                      S.of(context).error,
                      S.of(context).pleaseEnterDefaultPassword,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: EdgeInsets.all(10.sp),
                    );
                    return;
                  }


                  // ✅ FIX: Update ALL THREE fields in the entity
                  widget.accountStatusEntity.expirationTimeOfPassword = expirationTimeController.text;
                  widget.accountStatusEntity.expirationTimeUnit = selectedTimeUnit ?? 'Week';
                  widget.accountStatusEntity.tempPassword = defaultPasswordController.text;


                  // Call the update method
                  controller.updateAccessDetails(widget.accountStatusEntity);

                  Navigator.of(context).pop();

                  // ✅ Show success dialog with Lottie animation
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext dialogContext) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.sp),
                        ),
                        child: Container(
                          width: 411.w,
                          padding: EdgeInsets.all(15.sp),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12.sp),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 20.sp,
                            children: [
                              // Lottie Animation
                              SizedBox(
                                width: 100.w,
                                height: 100.h,
                                child: Lottie.asset(
                                  'assets/lottie/approved.json',
                                  repeat: false,
                                ),
                              ),

                              // Success Title
                              Text(
                                S.of(context).success,
                                style: AppTextStyles.font18BlackCairoMedium.copyWith(
                                  color: AppColors.text
                                ),
                              ),

                              // Success Message
                              Text(
                                S.of(context).passwordAndExpirationTimeUpdatedSuccessfully,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.font14BlackCairoRegular.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
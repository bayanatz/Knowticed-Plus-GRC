/// ***************************** FILE INFO ***************************** ///
/// File Name: champion_documentation_date_text_field.dart
/// Purpose: Defines a custom widget for displaying a date picker for selecting the "documentation users_tasks date" in the Qiyas control champion form.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This file contains the `ChampionDocumentationDateTextField` widget, which is used for rendering a
///              date picker to select the "documentation users_tasks date" in the "Qiyas Create Control Champion" form.
///              The widget uses InkWell to open a calendar when tapped and integrates with the `QiyasCreateControlChampionController`
///              to handle the state and selection of the chosen date.
/// ********************************************************************* ///
library;

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_pic.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class ChampionDocumentationDateTextField extends StatelessWidget {
  ChampionDocumentationDateTextField({super.key, required this.index});

  final QiyasCreateChampionControllerCubit controller = sl();
  final int index;

  /// Converts English numerals to Arabic numerals
  String _convertToArabicNumerals(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = [
      // D-145: Western digits in Arabic too.
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    ];

    String result = text;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.sp,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'تاريخ تقديم المستند',
            style: StyleText.fontSize14Weight400.copyWith(
              height: 1.2,
              color: AppColors.text,
            ),
          ),
          FormField<String>(
            validator: (value) {
              if (controller.dateControllersList[index].text.isEmpty) {
                return 'الرجاء اختيار تاريخ تقديم المستند';
              }
              return null;
            },
            builder: (formFieldState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTapDown: (_) => HapticController.low(),
                    onTap: () async {
                      List<DateTime?>? dates =
                          await DatePicker().showDatePicker(
                        context,
                        [controller.selectedDate],
                        DateTime.now(),
                        CalendarDatePicker2Type.single,
                        firstDate: DateTime.now(),
                      );

                      if (dates != null && dates.first != null) {
                        controller.selectedDate = dates.first!;

                        // Format date in Arabic with pattern: d MMMM yyyy
                        String formattedDate = DateFormat('d MMMM yyyy', 'ar')
                            .format(dates.first!);

                        // Convert numerals to Arabic
                        controller.dateControllersList[index].text =
                            _convertToArabicNumerals(formattedDate);

                        // Notify FormField that value changed
                        formFieldState.didChange(
                            controller.dateControllersList[index].text);

                        controller.emitState(VisionsDataChanged());
                      }
                    },
                    splashColor:
                        Colors.transparent, // removes the splash ripple
                    highlightColor: Colors
                        .transparent, // removes the long-press shadow/highlight
                    hoverColor: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.sp, vertical: 8.h),
                      height: 38.sp,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4.sp),
                        border: Border.all(
                          color: formFieldState.hasError
                              ? AppColors.red
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              controller.dateControllersList[index].text.isEmpty
                                  ? 'اختر تاريخ'
                                  : controller.dateControllersList[index].text,
                              style: controller
                                      .dateControllersList[index].text.isEmpty
                                  ? StyleText.fontSize12Weight500.copyWith(
                                      height: 1.2,
                                      color: AppColors.secondaryText
                                          .withValues(alpha: .6),
                                    )
                                  : StyleText.fontSize12Weight400.copyWith(
                                      height: 1.2,
                                      color: AppColors.text,
                                    ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          SvgPicture.asset(
                            'assets/icons_assets/main_icons_assets/ic_time_calendar.svg',
                            width: 20.sp,
                            height: 20.sp,
                            fit: BoxFit.fill,
                            colorFilter: ColorFilter.mode(
                              AppColors.secondaryText,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (formFieldState.hasError)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h, right: 16.w),
                      child: Text(
                        formFieldState.errorText ?? '',
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.red,
                          height: 1.2,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

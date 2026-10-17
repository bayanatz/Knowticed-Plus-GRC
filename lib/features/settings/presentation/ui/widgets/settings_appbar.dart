/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: settings_appbar.dart
/// Purpose: The profile header at the top of the settings menu — avatar, name,
///          role, supervisor and start date.
/// Author: Amr Mesbah
/// Created at: 10/11/2024
/// Updated: 11/8/2026 - Moved out of widgets/shared/ (CR-SKEL-SEMAIN-N03);
///          raw Colors.* routed through AppColors (N23); header added.
library;

import 'package:grc_module/core/extensions/context_extensions.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:grc_module/core/extensions/screen_fraction_extension.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/settings/presentation/ui/pages/settings_screen.dart';
import 'package:grc_module/core/helper/format_title.dart';

class SettingsAppBar extends StatefulWidget {
  final String? name;
  final String? image;
  final String? role;
  final String? startDate;
  final String? superVisor;
  const SettingsAppBar(
      {super.key,
      this.name,
      this.role,
      this.image,
      this.startDate,
      this.superVisor});
  @override
  State<SettingsAppBar> createState() => _SettingsAppBarState();
}

class _SettingsAppBarState extends State<SettingsAppBar> {
  String _formatDate(String dateString) {
    try {
      // Parse the date string
      DateTime date = DateTime.parse(dateString);

      // Check if the current locale is Arabic
      if (context.isArabic) {
        // Arabic month names
        List<String> arabicMonths = [
          'يناير',
          'فبراير',
          'مارس',
          'أبريل',
          'مايو',
          'يونيو',
          'يوليو',
          'أغسطس',
          'سبتمبر',
          'أكتوبر',
          'نوفمبر',
          'ديسمبر'
        ];

        // Convert numbers to Arabic numerals
        String day = _convertToArabicNumbers(date.day.toString());
        String year = _convertToArabicNumbers(date.year.toString());
        String month = arabicMonths[date.month - 1];

        return '$day $month $year';
      } else {
        // English format
        List<String> months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];

        return '${date.day} ${months[date.month - 1]} ${date.year}';
      }
    } catch (e) {
      // If parsing fails, return original string
      return dateString;
    }
  }

// Helper method to convert English numbers to Arabic numerals
  String _convertToArabicNumbers(String number) {
    // D-145: Western digits in Arabic too.
    const englishToArabic = {
      '0': '0',
      '1': '1',
      '2': '2',
      '3': '3',
      '4': '4',
      '5': '5',
      '6': '6',
      '7': '7',
      '8': '8',
      '9': '9',
    };

    return number
        .split('')
        .map((char) => englishToArabic[char] ?? char)
        .join('');
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    ContextExtension(context).isLandscape;
    return isMobile
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.sp),
            child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 50.sp),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Circular image
                            widget.image == null ||
                                    widget.image!.isEmpty ||
                                    widget.image == '[]'
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        top: isMobile ? 17.sp : 0.sp),
                                    child: CircleAvatar(
                                      backgroundColor: AppColors.transparent,
                                      radius: 36
                                          .sp, // was 3-3.5% of the window: ~120 px wide on a Mac (17/10/2026)
                                      backgroundImage: AssetImage(employee!
                                                  .gender.last ==
                                              'female'
                                          ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png'
                                          : 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'),
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: AppColors.transparent,
                                    radius: 36
                                        .sp, // was 3-3.5% of the window: ~120 px wide on a Mac (17/10/2026)
                                    backgroundImage:
                                        NetworkImage(widget.image!),
                                  ),
                            SizedBox(
                              width: 0.02.h,
                            ),
                            // Texts
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 17.h),
                                    Text(
                                        FormatHelper.capitalize(
                                            widget.name ?? ''),
                                        style: StyleText.fontSize18Weight500
                                            .copyWith(color: AppColors.text)),
                                    SizedBox(height: 2.h),
                                    Text(
                                        FormatHelper.capitalize(
                                          context.isArabic
                                              ? employee!.titleInArabic
                                                      .lastOrNull ??
                                                  ''
                                              : employee!.title.lastOrNull ??
                                                  '',
                                        ),
                                        style: StyleText.fontSize16Weight400
                                            .copyWith(
                                                color:
                                                    AppColors.secondaryText)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        isMobile ? Spacer() : Spacer(),
                        isMobile
                            ? SizedBox()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 22.h),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${S.of(context).start_date}: ",
                                        style: StyleText.fontSize12Weight400
                                            .copyWith(
                                                color: AppColors.secondaryText),
                                      ),
                                      Text(
                                        _formatDate(widget.startDate!),
                                        style: StyleText.fontSize12Weight400
                                            .copyWith(color: AppColors.text),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                      ],
                    ),
                    SizedBox(height: 15.sp),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     SizedBox(height: 22.h),
                    //     Row(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text(
                    //           "${S.of(context).start_date}: ",
                    //           style: StyleText.fontSize12Weight400.copyWith(
                    //               color: AppColors.secondaryText
                    //           ),
                    //         ),
                    //         Text(
                    //           _formatDate(widget.startDate!),
                    //           style: StyleText.fontSize12Weight400.copyWith(
                    //               color: AppColors.text
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //
                    //   ],
                    // )
                  ],
                ),
              ],
            ),
          )
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.02.h),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50.sp),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Circular image
                        widget.image == null ||
                                widget.image!.isEmpty ||
                                widget.image == '[]'
                            ? Padding(
                                padding: EdgeInsets.only(
                                    top: isMobile ? 12.sp : 0.sp),
                                child: CircleAvatar(
                                  backgroundColor: AppColors.transparent,
                                  radius: 36
                                      .sp, // was 3-3.5% of the window: ~120 px wide on a Mac (17/10/2026)
                                  backgroundImage: AssetImage(employee!
                                              .gender.last ==
                                          'female'
                                      ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png'
                                      : 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'),
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: AppColors.transparent,
                                radius: 36
                                    .sp, // was 3-3.5% of the window: ~120 px wide on a Mac (17/10/2026)
                                backgroundImage: NetworkImage(widget.image!),
                              ),
                        SizedBox(
                          width: 0.02.h,
                        ),
                        // Texts
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 17.h),
                                Text(FormatHelper.capitalize(widget.name ?? ''),
                                    style: StyleText.fontSize18Weight500
                                        .copyWith(
                                            color: AppColors.blackButton)),
                                SizedBox(height: 10.h),
                                Text(
                                    FormatHelper.capitalize(
                                      context.isArabic
                                          ? employee!
                                                  .titleInArabic.lastOrNull ??
                                              ''
                                          : employee!.title.lastOrNull ?? '',
                                    ),
                                    style: StyleText.fontSize16Weight400
                                        .copyWith(
                                            color: AppColors.secondaryText)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    isMobile ? SizedBox() : Spacer(),
                    isMobile
                        ? SizedBox()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 22.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${S.of(context).start_date}: ",
                                    style: StyleText.fontSize14Weight400
                                        .copyWith(
                                            color: AppColors.secondaryText),
                                  ),
                                  Text(
                                    _formatDate(widget.startDate!),
                                    style: StyleText.fontSize14Weight400
                                        .copyWith(color: AppColors.blackButton),
                                  ),
                                ],
                              ),
                            ],
                          )
                  ],
                ),
                isMobile
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 22.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${S.of(context).start_date}: ",
                                    style: StyleText.fontSize14Weight400
                                        .copyWith(
                                            color: AppColors.secondaryText),
                                  ),
                                  Text(
                                    _formatDate(widget.startDate!),
                                    style: StyleText.fontSize14Weight400
                                        .copyWith(color: AppColors.blackButton),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      )
                    : SizedBox()
              ],
            ),
          );
  }
}

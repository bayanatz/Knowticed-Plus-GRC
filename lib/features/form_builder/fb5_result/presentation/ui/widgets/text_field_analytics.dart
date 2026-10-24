/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: text_field_analytics.dart
/// Description: `TextFieldAnalytics` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/utils/analytics_helper.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/analytics_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/analytics_text_field_entity.dart';

/// The list of each person's answer to one text-like field.
class TextFieldAnalytics extends StatelessWidget {
  const TextFieldAnalytics({required this.entity, super.key});
  final AnalyticsEntity entity;
  @override
  @override
  Widget build(BuildContext context) {
    // Add null check
    if (entity.data == null || entity.data!.isEmpty) {
      return Center(
        child: Text(
          S.current.noDataAvailable,
          style: StyleText.fontSize12Weight500,
        ),
      );
    }

    // The card width is measured from the space this
    // widget really has (LayoutBuilder) rather than "screen width − 200",
    // which guessed the side rail and card padding and so could fit one card
    // fewer — or one more — than [_getRowItems] asked for.
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = _getRowItems(context);
        const double spacing = 10; // same as the Wrap spacing below
        final double available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final double itemWidth =
            ((available - (columns - 1) * spacing) / columns).floorToDouble();
        return Wrap(
          alignment: WrapAlignment.start,
          spacing: spacing,
          runSpacing: 10,
          children: entity.data!.map((item) {
            return SizedBox(
              width: itemWidth,
              child: mainTextFieldWidget(context, item, entity.type),
            );
          }).toList(),
        );
      },
    );
  }

  /// Method Name: [mainTextFieldWidget]
  ///
  /// Purpose: one person's card: avatar, name, job title, date and answer.
  ///
  /// Returns: the card.
  Widget mainTextFieldWidget(BuildContext context,
      AnalyticsTextFieldEntity entity, FormFieldType type) {
    return IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.all(8.sp),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${S.current.submissionDate}: ',
                        style: StyleText.fontSize10Weight400
                            .copyWith(color: AppColors.spanText)
                            .copyWith(fontSize: 8.sp),
                      ),
                      TextSpan(
                          //number
                          text:
                              ' ${FormDateTimeHelper.formatDate(entity.submissionDate)}',
                          style: StyleText.fontSize10Weight400
                              .copyWith(color: AppColors.fullBlack)
                              .copyWith(fontSize: 8.sp))
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16.r,
                    backgroundColor: AppColors.primary,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: SizedBox(
                        child: CustomSvgImage(
                          assetPath:
                              "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
                          width: 35.w,
                          height: 35.h,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  horizontalSpace(10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FormatHelper.capitalize(entity.person.name),
                          style: StyleText.fontSize12Weight500,
                          overflow: TextOverflow.ellipsis,
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${S.current.jobTitle}: ',
                                style: StyleText.fontSize12Weight400
                                    .copyWith(color: AppColors.spanText),
                              ),
                              TextSpan(
                                  //number
                                  text: entity.person.title,
                                  style: StyleText.fontSize12Weight400
                                      .copyWith(color: AppColors.fullBlack))
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            verticalSpace(10),
            if (type == FormFieldType.description)
              descriptionTextField(entity.answers.first)
            else if (type == FormFieldType.phone)
              phoneTextField(context, entity.answers.first)
            else if (type == FormFieldType.location)
              locationTextField(entity.answers.first)
            else if (type == FormFieldType.address)
              addressTextField(entity.answers.first)
            else if (type == FormFieldType.timeSelector)
              timeSelectorTextField(entity.answers.first)
            else
              customTextField(
                width: type == FormFieldType.dateSelector ? 150.w : null,
                entity.answers.first,
                alignment: type == FormFieldType.dateSelector
                    ? Alignment.center
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  /// Method Name: [descriptionTextField]
  ///
  /// Parameters:
  /// - [answer]: the description answer.
  ///
  /// Returns: a read-only multi-line field.
  Widget descriptionTextField(String description) {
    return Text(
      description,
      style: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryBlack),
      maxLines: 1000,
      textAlign: TextAlign.start,
    );
  }

  /// Method Name: [phoneTextField]
  ///
  /// Parameters:
  /// - [context]: for the item width.
  /// - [answer]: the stored "code-number" answer.
  ///
  /// Returns: the country code and the number side by side.
  Widget phoneTextField(BuildContext context, String answer) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SizedBox(
        width: _getItemWidth(context) / 4,
        // Bug report p.39: "+20", not the raw stored value ("null"/"EG").
        child: customTextField(
            AnalyticsHelper.phoneCodeLabel(answer.split('-').first)),
      ),
      SizedBox(
          width: (2.66 * (_getItemWidth(context) / 4)) - 10.w,
          child: customTextField(answer.split('-').last)),
    ]);
  }

  /// Method Name: [locationTextField]
  ///
  /// Parameters:
  /// - [answer]: the location answer.
  ///
  /// Returns: a read-only field.
  Widget locationTextField(String location) {
    if (location.contains(',')) {
      return customTextField(location);
    } else {
      return Column(children: [
        customTextField(location.split(',').first),
        verticalSpace(10),
        customTextField(
          location.split(',').last,
        ),
      ]);
    }
  }

  /// Method Name: [customTextField]
  ///
  /// Parameters:
  /// - [text]: the value shown.
  ///
  /// Returns: a read-only one-line field.
  Widget customTextField(String text, {Alignment? alignment, double? width}) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Expanded(
              child: Container(
            alignment: alignment,
            padding: EdgeInsets.all(8.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              text,
              style: StyleText.fontSize12Weight500,
              overflow: TextOverflow.ellipsis,
            ),
          )),
        ],
      ),
    );
  }

  int _getRowItems(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (entity.type == FormFieldType.description) {
      if (screenWidth > 3600) {
        return 4;
      } else if (screenWidth > 2400) {
        return 3;
      } else if (screenWidth <= 2400 && screenWidth > 1200) {
        return 2;
      } else if (screenWidth > 600 && screenWidth < 1200) {
        return 1;
      }
      return 1;
    } else {
      if (screenWidth > 3600) {
        return 6;
      } else if (screenWidth > 2400) {
        return 5;
      } else if (screenWidth <= 2400 && screenWidth > 1200) {
        return 4;
      } else if (screenWidth > 600 && screenWidth < 1200) {
        // (vertical bug report p.28 — "2 cards in the row
        // not 3"): three answer cards did not fit a portrait tablet; the
        // third wrapped or the e-mails were cut to "…democompany@knowti".
        return 2;
      }
      return 1; // Default for phone
    }
  }

  double _getItemWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = !kpIsPhoneLayout(context);
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    if (isTablet) {
      screenWidth -= isPortrait ? 200.w : 200.w; // Adjust for tablet
    }
    int columns = _getRowItems(context);
    double spacing = 10; // same as Wrap spacing
    return (screenWidth - (columns - 1) * spacing) / columns;
  }

  Column addressTextField(String answer) {
    List<String> address = answer.split(',   ');
    return Column(
      spacing: 10.h,
      children: [for (String item in address) customTextField(item)],
    );
  }

  Row timeSelectorTextField(String answer) {
    return Row(children: [
      SizedBox(
        width: 50.w,
        child: customTextField(answer.split(' ').first,
            alignment: Alignment.center),
      ),
      horizontalSpace(10),
      SizedBox(
        width: 50.w,
        child: customTextField(answer.split(' ').last,
            alignment: Alignment.center),
      ),
    ]);
  }
}

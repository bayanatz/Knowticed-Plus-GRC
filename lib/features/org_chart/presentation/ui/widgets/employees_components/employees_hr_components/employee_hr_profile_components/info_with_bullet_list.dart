import 'package:grc_module/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/helper/arabic_number_format.dart';
import 'package:grc_module/core/extensions/screen_fraction_extension.dart';
import 'package:grc_module/core/theme/app_colors.dart';

class InfoWithBulletList extends StatefulWidget {
  final List<String>? skillsTexts;

  const InfoWithBulletList({super.key, this.skillsTexts});

  @override
  State<InfoWithBulletList> createState() => _InfoWithBulletListState();
}

class _InfoWithBulletListState extends State<InfoWithBulletList> {
  @override
  Widget build(BuildContext context) {
    final bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return isVertical ? _buildVerticalList() : _buildHorizontalList();
  }

  Widget _buildVerticalList() {
    !kpIsPhoneLayout(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        ((widget.skillsTexts!.length + 1) / 2).ceil(),
        (rowIndex) {
          final start = rowIndex * 2;
          final end = (rowIndex + 1) * 2;
          return Padding(
            padding: EdgeInsets.only(bottom: 0.01.h),
            child: Row(
              children: widget.skillsTexts!
                  .sublist(start, end.clamp(0, widget.skillsTexts!.length))
                  .map((text) {
                return Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\u25CF',
                        style: StyleText.fontSize16Weight400.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w400,
                            height: 1.6),
                      ),
                      SizedBox(width: 0.01.w),
                      Flexible(
                        child: Text(
                          Get.locale.toString().contains('en')
                              ? text.capitalize ?? ''
                              : (text.capitalize ?? '').toArabicNumbers(),
                          maxLines: 14,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: !AppTheme.isDark
                                ? AppColors.colorBlack
                                : AppColors.colorWhiteDark,
                            fontWeight: FontWeight.w400,
                            height: 1.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: ((widget.skillsTexts!.length + 2) / 3).floor(),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final start = index * 3;
        final end = (index + 1) * 3;
        return Padding(
          padding: EdgeInsets.only(bottom: 0.01.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: widget.skillsTexts!
                .sublist(start, end.clamp(0, widget.skillsTexts!.length))
                .map((text) {
              return Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '\u25CF',
                      style: StyleText.fontSize16Weight400.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 0.01.w),
                    Flexible(
                      child: Text(
                        Get.locale.toString().contains('en')
                            ? text.capitalize ?? ''
                            : (text.capitalize ?? '').toArabicNumbers(),
                        maxLines: 14,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: !AppTheme.isDark
                              ? AppColors.colorBlack
                              : AppColors.colorWhiteDark,
                          fontWeight: FontWeight.w400,
                          height: 1.8,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

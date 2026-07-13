import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:demo_app/core/helper/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

import 'package:demo_app/features/roles/core_widgets/main_widget/custom_app_bar.dart';

class PaginationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PaginationAppBar({super.key, required this.screensTitles});
  final List<String> screensTitles;

  @override
  Widget build(BuildContext context) {
    return ContextExtension(context).isTablet
        ? _buildTabletAppBar(context)
        : _buildMobileAppBar();
  }

  @override
  Size get preferredSize => Size.fromHeight(60.h);

  _buildMobileAppBar() {
    return CustomAppBar(
      title: screensTitles.last,
      paddedLeading: false,
      hideLeading: screensTitles.length == 1,
      centerTitle: false,
    );
  }

  _buildTabletAppBar(BuildContext context) {
    final List<String> visibleTitles = screensTitles.length > 3
        ? screensTitles.sublist(screensTitles.length - 3)
        : screensTitles;
    final int startIndex = screensTitles.length - visibleTitles.length;

    return Padding(
        padding: EdgeInsetsDirectional.only(
          top: ContextExtension(context).isPhone ? 15.sp : 30.sp,
          bottom: ContextExtension(context).isPhone ? 15.sp : 30.sp,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: context.isArabic, // ✅ this makes it start from right in RTL
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                spacing: 15.sp,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(
                  visibleTitles.length,
                      (index) => _buildAppBarItem(context,
                      title: visibleTitles[index],
                      originalIndex: startIndex + index,
                      isLast: ((index + 1) == visibleTitles.length)),
                ),
              ),
              Container()
            ],
          ),
        ));
  }

  _buildAppBarItem(BuildContext context,
      {required String title, required int originalIndex, required bool isLast}) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 15.sp,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: isLast
                ? null
                : () {
              int manyPop = screensTitles.length - (originalIndex + 1);
              for (int i = 0; i < manyPop; i++) {
                Navigator.of(context).pop();
              }
            },
            child: Text(screensTitles[originalIndex],
                style: StyleText.fontSize28Weight600.copyWith(
                    color: AppColors.text)),
          ),
          if (!isLast)
            Transform.rotate(
              angle: context.isArabic ? -3.14 : 0,
              child: Container(
                margin: EdgeInsets.only(top: 3.sp),
                child: SvgPicture.asset(
                  height: 25.sp,
                  width: 25.sp,
                  "assets/icons_assets/main_icons_assets/arrow_right_mobile.svg",
                  fit: BoxFit.fill,
                  colorFilter:
                  ColorFilter.mode(AppColors.text, BlendMode.srcIn),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
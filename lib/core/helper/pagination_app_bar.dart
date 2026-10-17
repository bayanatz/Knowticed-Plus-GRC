/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: pagination_app_bar.dart
/// Description: Declares `PaginationAppBar`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:grc_module/core/extensions/context_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:grc_module/core/theme/app_colors.dart';

import 'package:grc_module/features/messaging/helpers/messaging_app_bar.dart';

class PaginationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PaginationAppBar({
    super.key,
    required this.screensTitles,
    this.padding,
  });
  final List<String> screensTitles;

  /// Padding around the breadcrumb row on tablet/desktop.
  ///
  /// ADDED 18/8/2026. Null keeps the historical behaviour — 15.sp (phone) or
  /// 30.sp top and bottom, and **zero horizontal**, which is why the title
  /// rendered flush against the page edge. This widget is shared with other
  /// modules, so that default is left as it was; `form_builder_module` passes
  /// `formBuilderTitlePadding` (20.sp all round) at every call site.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ContextExtension(context).isTablet
        ? _buildTabletAppBar(context)
        : _buildMobileAppBar();
  }

  @override
  Size get preferredSize => Size.fromHeight(60.h);

  CustomAppBar _buildMobileAppBar() {
    return CustomAppBar(
      title: screensTitles.last,
      paddedLeading: false,
      hideLeading: screensTitles.length == 1,
      centerTitle: false,
    );
  }

  // CHANGED 14/10/2026 (iPad Arabic bug report):
  //  1. Direction — the old version put the crumbs in a horizontal
  //     SingleChildScrollView with `reverse: context.isArabic`. A horizontal
  //     scroll view ALREADY starts on the right in RTL, so `reverse` flipped it
  //     back and the Arabic breadcrumb hugged the LEFT edge. The crumbs now sit
  //     in a full-width Row with an explicit text direction, so Arabic starts
  //     at the right edge and reads right-to-left.
  //  2. Overflow — every crumb is one line ending in "…" when it doesn't fit.
  //     Earlier crumbs share at most 40% of the row; the current page (last
  //     crumb) gets the rest.
  Widget _buildTabletAppBar(BuildContext context) {
    final List<String> visibleTitles = screensTitles.length > 3
        ? screensTitles.sublist(screensTitles.length - 3)
        : screensTitles;
    final int startIndex = screensTitles.length - visibleTitles.length;
    final bool isArabic = context.isArabic;
    final TextDirection direction =
        isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Padding(
      padding: padding ??
          EdgeInsetsDirectional.only(
            top: ContextExtension(context).isPhone ? 15.sp : 30.sp,
            bottom: ContextExtension(context).isPhone ? 15.sp : 30.sp,
          ),
      child: Directionality(
        textDirection: direction,
        child: SizedBox(
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // CHANGED 14/10/2026: each crumb's share of the row is
              // proportional to its full text width, so nothing is cut while
              // the crumbs fit; only real overflow ends in "…".
              final TextStyle crumbStyle =
                  StyleText.fontSize28Weight600.copyWith(color: AppColors.text);
              final TextScaler scaler = MediaQuery.textScalerOf(context);
              int crumbFlex(String text) {
                final TextPainter painter = TextPainter(
                  // FIXED 14/10/2026: measure with the SAME style the Text
                  // widget paints with — the inherited DefaultTextStyle (the
                  // app font from the theme) merged with crumbStyle. Measuring
                  // crumbStyle alone used the fallback font, came out too
                  // narrow, and the crumb still got "…" with room to spare.
                  text: TextSpan(
                      text: text,
                      style:
                          DefaultTextStyle.of(context).style.merge(crumbStyle)),
                  locale: Localizations.maybeLocaleOf(context),
                  maxLines: 1,
                  textDirection: direction,
                  textScaler: scaler,
                )..layout();
                return painter.width.ceil() + 6;
              }

              final List<Widget> children = [];
              for (int index = 0; index < visibleTitles.length; index++) {
                final bool isLast = index == visibleTitles.length - 1;
                final int originalIndex = startIndex + index;

                if (index != 0) {
                  children.add(SizedBox(width: 15.sp));
                  children.add(_buildChevron(context));
                  children.add(SizedBox(width: 15.sp));
                }

                final Widget crumb = _buildAppBarItem(
                  context,
                  title: visibleTitles[index],
                  originalIndex: originalIndex,
                  isLast: isLast,
                  direction: direction,
                );

                children.add(Flexible(
                  flex: crumbFlex(screensTitles[originalIndex]),
                  child: crumb,
                ));
              }

              return Row(
                textDirection: direction,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChevron(BuildContext context) {
    return Transform.rotate(
      angle: context.isArabic ? -3.14 : 0,
      child: Container(
        margin: EdgeInsets.only(top: 3.sp),
        child: CustomSvgImage.natural(
          assetPath:
              "assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg",
          height: 25.sp,
          width: 25.sp,
          fit: BoxFit.fill,
          colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildAppBarItem(BuildContext context,
      {required String title,
      required int originalIndex,
      required bool isLast,
      required TextDirection direction}) {
    return GestureDetector(
      onTap: isLast
          ? null
          : () {
              int manyPop = screensTitles.length - (originalIndex + 1);
              for (int i = 0; i < manyPop; i++) {
                Navigator.of(context).pop();
              }
            },
      child: Text(
        screensTitles[originalIndex],
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        textDirection: direction,
        style: StyleText.fontSize28Weight600.copyWith(color: AppColors.text),
      ),
    );
  }
}

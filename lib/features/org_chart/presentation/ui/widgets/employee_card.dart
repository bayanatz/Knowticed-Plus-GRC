// Date Created :15/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :22/October/2026 (compact row card on the iPad)
// Objectives: this is a widget to customize the card of the employee in the org chart
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/layout/marquee_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';
import 'package:knowticed_plus/features/org_chart/presentation/employees_views/employee_detailed_info/employee_detailed_info_screen.dart';
import 'package:knowticed_plus/features/org_chart/presentation/employees_views/employees_hr_view/employees_profile/employee_profile_mobile/employee_profile_screen_employee_view_mobile.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:page_transition/page_transition.dart';

import 'package:knowticed_plus/features/org_chart/presentation/controller/employee_helper.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class EmployeeCard extends StatelessWidget {
  const EmployeeCard({
    super.key,
    required this.employee,
    required this.cardColor,
    required this.isLeader,
    required this.textColor,
    this.boxWidth,
  });
  final NewEmployeeModelHistory employee;
  final Color textColor;
  final Color cardColor;
  final bool isLeader;

  /// Phone: when set, the employee is drawn as a square-ish BOX of this width
  /// (avatar on top, then the name, then the job title) instead of a row —
  /// Moataz 23/10/2026: "as a structure", boxes in a grid.
  final double? boxWidth;

  /// Smallest card width, so a short name does not give a tiny card.
  static double minWidth(BuildContext context) =>
      kpIsPhoneLayout(context) ? 140.w : 180.w;

  /// ONE width for every Org Chart card (18/10/2026, Moataz: equal widths,
  /// "the perfect width", not too big). It fits a normal name + job title;
  /// a longer line scrolls inside the card (MarqueeText) instead of widening
  /// the card.
  ///
  /// 22/10/2026 (Moataz, phone: "not the perfect way to see it"): on the
  /// phone the compact row card spans the page (inside the page's 4% side
  /// padding), one clear list per department.
  static double cardWidth(BuildContext context) => kpIsPhoneLayout(context)
      ? MediaQuery.sizeOf(context).width * 0.92
      : 250.sp;

  // CHANGED 18/10/2026 (owner, final: "ayanatz Transformatio", "irs",
  // "ces officer" were cut; the marquee does not work for him): the card is
  // sized to its content. No fixed width, no marquee — name and job title
  // are each one full line. A column of cards gets one width by wrapping the
  // cards in IntrinsicWidth + Column(crossAxisAlignment: stretch).
  // Corners: D-146 diagonal cut — content sits CardStyles.cornerInset (10)
  // from the top and the side.
  @override
  Widget build(BuildContext context) {
    final bool isTablet = !kpIsPhoneLayout(context);
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    // 22/10/2026 (Moataz, iPad portrait: "the card is too big … reduce it to
    // see more boxes", then the phone too): one compact row on every device —
    // small avatar beside the name and job title — about 1/3 of the old
    // stacked height (80 avatar over two 16 lines).
    final TextStyle nameStyle =
        StyleText.fontSize14Weight600.copyWith(color: textColor);
    // The job title one step quieter than the name.
    final TextStyle titleStyle = StyleText.fontSize12Weight400
        .copyWith(color: textColor.withValues(alpha: 0.8));

    // A line that fits stays still; a longer one scrolls inside the card.
    Widget line(String text, TextStyle style) =>
        MarqueeText(text: text, style: style, center: false);

    final Widget texts = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Each word capitalised (18/10/2026: "Khaled abdelrahman" showed the
        // surname in lower case, unlike the Employee Info page).
        line(
            FormatHelper.capitalize(EmployeeHelper.getEmployeeFirstAndLastNames(
                employee: employee)),
            nameStyle),
        SizedBox(height: 2.sp),
        line(
            FormatHelper.capitalize(
                EmployeeHelper.getEmployeeJobTitle(employee: employee)),
            titleStyle),
      ],
    );

    if (boxWidth != null) return _box(context);

    final Widget content = Row(
      children: [
        userImage(isTablet, isPortrait),
        SizedBox(width: 10.sp),
        Expanded(child: texts),
      ],
    );

    return GestureDetector(
      onTap: () {
        HapticController.low(); // list row: on the tap (X-117)
        if (isTablet) {
          Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.fade,
                child: EmployeeDetailedInfo(employee: employee)),
          );
        } else {
          PersistentNavBarNavigator.pushNewScreen(context,
              withNavBar: false,
              screen: EmployeeProfileScreenMobileEmployeeViewScreen(
                  employee: employee));
        }
      },
      child: Container(
        width: cardWidth(context),
        padding: EdgeInsets.all(CardStyles.cornerInset),
        decoration: BoxDecoration(
          borderRadius: CardStyles.radius(),
          color: cardColor,
        ),
        child: content,
      ),
    );
  }

  /// The phone box: avatar, name, job title, centred.
  Widget _box(BuildContext context) {
    final String name = FormatHelper.capitalize(
        EmployeeHelper.getEmployeeFirstAndLastNames(employee: employee));
    final String title = FormatHelper.capitalize(
        EmployeeHelper.getEmployeeJobTitle(employee: employee));
    // Each box repaints on its own: the scrolling names no longer force the
    // whole chart to repaint every frame.
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          HapticController.low();
          PersistentNavBarNavigator.pushNewScreen(context,
              withNavBar: false,
              screen: EmployeeProfileScreenMobileEmployeeViewScreen(
                  employee: employee));
        },
        child: Container(
          width: boxWidth,
          // 24/10/2026 (Moataz: "the diagonal cut — remove the extra padding
          // from the bottom"): no fixed height. The box is as tall as its
          // content, so the space under the job title equals the space above
          // the avatar. Every box has the same three lines, so they match.
          padding: EdgeInsets.symmetric(
              horizontal: 6.sp, vertical: CardStyles.cornerInset),
          decoration: BoxDecoration(
            borderRadius: CardStyles.radius(),
            color: cardColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              userImage(false, true, size: 32.sp),
              SizedBox(height: 6.sp),
              // One line each; a longer one scrolls sideways inside the box, as
              // on the iPad (Moataz 23/10/2026).
              MarqueeText(
                text: name,
                center: true,
                style: StyleText.fontSize14Weight600
                    .copyWith(color: textColor, fontSize: 12.sp, height: 1.2),
              ),
              SizedBox(height: 2.sp),
              MarqueeText(
                text: title,
                center: true,
                style: StyleText.fontSize12Weight400.copyWith(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: 10.sp,
                    height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget userImage(bool isTablet, bool isPortrait, {double? size}) {
    // 22/10/2026: 40 on the iPad in both orientations (was 80 upright).
    final double avatar = size ?? 40.sp;
    return ClipOval(
      child: Container(
        width: avatar,
        height: avatar,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.barrierColor,
        ),
        child: CustomSvgImage(
          assetPath: CardSvg.male,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

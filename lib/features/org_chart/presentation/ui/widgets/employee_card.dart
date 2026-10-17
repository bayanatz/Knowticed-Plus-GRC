// Date Created :15/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :18/October/2026 (sized to its content, no marquee)
// Objectives: this is a widget to customize the card of the employee in the org chart
import 'package:grc_module/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/features/home/h2_nav_bar/persistent_nav_bar.dart';
import 'package:grc_module/features/org_chart/presentation/employees_views/employee_detailed_info/employee_detailed_info_screen.dart';
import 'package:grc_module/features/org_chart/presentation/employees_views/employees_hr_view/employees_profile/employee_profile_mobile/employee_profile_screen_employee_view_mobile.dart';
import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:grc_module/core/custom/cards/custom_card_styles.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:page_transition/page_transition.dart';

import 'package:grc_module/features/org_chart/presentation/controller/employee_helper.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

class EmployeeCard extends StatelessWidget {
  const EmployeeCard({
    super.key,
    required this.employee,
    required this.cardColor,
    required this.isLeader,
    required this.textColor,
  });
  final NewEmployeeModelHistory employee;
  final Color textColor;
  final Color cardColor;
  final bool isLeader;

  /// Smallest card width, so a short name does not give a tiny card.
  static double minWidth(BuildContext context) =>
      kpIsPhoneLayout(context) ? 140.w : 180.w;

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
    final bool stacked = !isTablet || isPortrait;
    final TextStyle style = (isTablet
            ? StyleText.fontSize16Weight600
            : StyleText.fontSize12Weight600)
        .copyWith(color: textColor);

    Widget line(String text) => Padding(
          // Room for descenders (the "g" in "Manager").
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            text,
            style: style,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            textAlign: stacked ? TextAlign.center : TextAlign.start,
          ),
        );

    final Widget texts = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          stacked ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        line(EmployeeHelper.getEmployeeFirstAndLastNames(employee: employee)),
        line(EmployeeHelper.getEmployeeJobTitle(employee: employee)),
      ],
    );

    final Widget content = stacked
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              userImage(isTablet, isPortrait),
              SizedBox(height: 8.h),
              texts,
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              userImage(isTablet, isPortrait),
              SizedBox(width: 10.w),
              texts,
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
        constraints: BoxConstraints(minWidth: minWidth(context)),
        padding: EdgeInsets.all(CardStyles.cornerInset),
        decoration: BoxDecoration(
          borderRadius: CardStyles.radius(),
          color: cardColor,
        ),
        child: stacked ? Center(widthFactor: 1, child: content) : content,
      ),
    );
  }

  Widget userImage(bool isTablet, bool isPortrait) {
    final double size = isTablet && isPortrait ? 80.w : 40.w;
    return ClipOval(
      child: Container(
        width: size,
        height: size,
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

/// Date Created :12/November/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Objectives: the home page.
///
/// Merged from the former mobile/home_screen_mobile.dart and
/// tablet/tablet_home_screen.dart into a single widget that branches on form
/// factor internally. The component grid was identical in both, so it now
/// lives in one place ([_buildComponentsGrid]); everything else that genuinely
/// differed (mobile greeting header vs tablet calendar column) is kept as-is.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:grc_module/core/helper/main_helper/role_access.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/features/calender/c1_calendar/presentation/ui/pages/home_calendar_page.dart';
import 'package:grc_module/features/home/h1_home_page/data_source/models/home_component_model.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/controller/home_state.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/controller/skeleton_home_controller.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/gradiant_container.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/module_widget/tablet/home_appbar_section.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/upcoming_schedule_listview.dart';
import 'package:grc_module/features/home/h1_home_page/data_source/home_constants.dart';
import 'package:grc_module/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:grc_module/features/home/h2_nav_bar/utils/functions.dart';
import 'package:grc_module/features/home/h2_nav_bar/utils/model.dart';
import 'package:grc_module/features/home/main_controller/core_widgets/main_widget/custom_appbar_mobile.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
// Provides the app-wide `employee` global used by the greeting below.
import 'package:grc_module/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';
import 'package:grc_module/generated/l10n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Tablet-only: the day picked in the side calendar.
  DateTime? selectedDate;

  /// Declared here rather than relying on the global that leaks out of
  /// timeline_widget.dart, which is how the former mobile page resolved it.
  final HapticController hapticController = Get.put(HapticController());

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 768.0;

    return BlocBuilder<AppHomeCubit, HomeState>(
      buildWhen: (_, __) => true,
      builder: (context, state) {
        final homeCubit = context.read<AppHomeCubit>();
        return isTablet ? _tabletLayout(homeCubit) : _mobileLayout(homeCubit);
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Shared
  // ───────────────────────────────────────────────────────────────────────

  /// The dashboard component grid — identical on both form factors.
  Widget _buildComponentsGrid(AppHomeCubit homeCubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10.sp,
      children: [
        for (int rowIndex = 0;
            rowIndex < HomeConstants.NUMBER_OF_ROWS;
            rowIndex++)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 10.sp,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (HomeComponentModel component
                    in homeCubit.getActiveRowComponents(rowIndex))
                  component.component.widget(component) ?? Container()
              ],
            ),
          ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Mobile
  // ───────────────────────────────────────────────────────────────────────

  Widget _mobileLayout(AppHomeCubit homeCubit) {
    final SkeletonHomeController controller = Get.find();

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomAppBarMobile(
                showIcon: false,
                isHome: true,
                showMoreIcon: true,
                showNotification: true,
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: Container(
                  color: AppColors.background,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _mobileDateRow(controller),
                        SizedBox(height: 10.h),
                        Text(
                          "${DateTime.now().hour < 12 ? S.of(context).goodMorning : DateTime.now().hour < 14 ? S.of(context).goodAfternoon : S.of(context).goodEvening} ${Get.locale.toString().contains('en') ? employee!.firstName!.last!.capitalize : employee!.firstNameInArabic!.last!.capitalize}",
                          style: AppTextStyles.font25BlackSemiBoldCairo
                              .copyWith(height: 1.4),
                        ),
                        SizedBox(height: 15.h),
                        GradientContainer(),
                        SizedBox(height: 15.h),
                        _buildComponentsGrid(homeCubit),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileDateRow(SkeletonHomeController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              "assets/icons_assets/home_assets/calendar_event_star_white.svg",
              color: AppColors.icon,
            ),
            SizedBox(width: 8.w),
            Text(
              controller.getCurrentDate(),
              style: AppTextStyles.font20SecondaryBlackMediumCairo
                  .copyWith(height: 1.8, color: AppColors.icon),
            ),
          ],
        ),
        controller.modules.contains(Modules.employees)
            ? GestureDetector(
                onTap: () {
                  hapticController.triggerHapticFeedback(
                      vibration: VibrateType.lightImpact,
                      hapticFeedback: HapticFeedback.lightImpact);
                  if (Get.find<NavBarCubit>()
                      .navBarModules
                      .contains(Modules.employees)) {
                    RoleAccess.controller.jumpToTab(Get.find<NavBarCubit>()
                        .navBarModules
                        .indexOf(Modules.employees));
                  } else {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        pageTransitionAnimation: PageTransitionAnimation.fade,
                        withNavBar: true,
                        screen: Modules.employees.widget);
                  }
                },
                child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.signOut,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(8.h),
                    child: SvgPicture.asset(
                      "assets/icons_assets/roles_assets/organization_chart_tree.svg",
                      color: AppColors.black,
                    )),
              )
            : const SizedBox()
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Tablet
  // ───────────────────────────────────────────────────────────────────────

  Widget _tabletLayout(AppHomeCubit homeCubit) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          color: AppColors.background,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Section - Main Content
              Expanded(
                flex: 5,
                child: Container(
                  height: isPortrait ? 930.h : 699.h,
                  color: AppColors.background,
                  padding: EdgeInsetsDirectional.only(
                    start: 20.w,
                    end: isPortrait ? 20.w : 10.w,
                  ),
                  child: ScrollConfiguration(
                    behavior:
                        const ScrollBehavior().copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(flex: 1, child: HomeAppbarSection()),
                              SizedBox(width: 0.sp),
                            ],
                          ),
                          SizedBox(height: 20.sp),
                          _buildComponentsGrid(homeCubit),

                          // Portrait mode schedule section
                          if (isPortrait) SizedBox(height: 30.h),
                          if (isPortrait)
                            Text(S.of(context).upcomingSchedule,
                                style: StyleText.fontSize20Weight500.copyWith(
                                    color: lightMode
                                        ? AppColors.red
                                        : AppColors.white)),
                          if (isPortrait)
                            UpcomingScheduleListview(
                                selectedDate: selectedDate != null
                                    ? [selectedDate!]
                                    : [DateTime.now()]),
                          if (!isPortrait) SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Right Section - Calendar (only in landscape)
              if (!isPortrait)
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(top: 15.sp, bottom: 15.sp),
                    child: HomeCalendarWidget(
                      onDateSelected: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

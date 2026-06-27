import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'package:demo_app/features/home/data/models/home_component_model.dart';
import 'package:demo_app/features/home/presentation/controller/home_cubit.dart';

import '../../../../../generated/l10n.dart';
import '../widgets/add_component_wrapper.dart';
import 'chart_widget_layout.dart';

class AddingWidgetPage extends StatefulWidget {
  AddingWidgetPage({super.key});

  @override
  State<AddingWidgetPage> createState() => _AddingWidgetPageState();
}

class _AddingWidgetPageState extends State<AddingWidgetPage> {
  late bool isTablet;
  int selectedTab = 0; // 0 for Widgets, 1 for Chart & Graph

  @override
  Widget build(BuildContext context) {
    isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
                start: isTablet ? 30.sp : 15.sp, end: 15.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                PaginationAppBar(screensTitles: [
                  'Settings'.tr,
                  S.of(context).home,
                  S.of(context).addingWidget
                ]),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Animated Tab Switcher
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 300.w,
                              height: 41.h,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Stack(
                                children: [
                                  // Animated Background Indicator
                                  // Replace AnimatedPositioned with this:
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    // For RTL support:
                                    right: Directionality.of(context) == TextDirection.rtl
                                        ? (selectedTab == 0 ? 0 : 150.w)
                                        : null,
                                    left: Directionality.of(context) == TextDirection.ltr
                                        ? (selectedTab == 0 ? 0 : 150.w)
                                        : null,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 150.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                    ),
                                  ),
                                  // Tab Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => setState(() => selectedTab = 0),
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.circular(4.r),
                                            ),
                                            child: AnimatedDefaultTextStyle(
                                              duration: const Duration(milliseconds: 250),
                                              curve: Curves.easeInOut,
                                              style: StyleText.fontSize16Weight500.copyWith(
                                                color: selectedTab == 0
                                                    ? AppColors.textButton
                                                    : AppColors.text,
                                              ),
                                              child: Text(S.of(context).widget),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => setState(() => selectedTab = 1),
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.circular(4.r),
                                            ),
                                            child: AnimatedDefaultTextStyle(
                                              duration: const Duration(milliseconds: 250),
                                              curve: Curves.easeInOut,
                                              style: StyleText.fontSize16Weight500.copyWith(
                                                color: selectedTab == 1
                                                    ? AppColors.textButton
                                                    : AppColors.text,
                                              ),
                                              child: Text(S.of(context).chartGraph),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.sp),
                        // Animated Content Switcher
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: selectedTab == 0
                              ? Wrap(
                            key: const ValueKey('widgets'),
                            runSpacing: 10.sp,
                            spacing: 10.sp,
                            children: [
                              for (HomeComponentModel componentModel
                              in context.read<AppHomeCubit>().readyToAddComponent)
                                AddComponentWrapper(
                                    model: componentModel,
                                    component: componentModel.component
                                        .widget(componentModel) ??
                                        Container())
                            ],
                          )
                              : HomeLayoutChartWidget(
                            key: const ValueKey('charts'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.sp,
                )
              ],
            ),
          ),
        ));
  }
}
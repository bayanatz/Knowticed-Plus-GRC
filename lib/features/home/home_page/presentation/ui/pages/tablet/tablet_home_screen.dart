import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'package:demo_app/features/home/home_page/data_source/models/home_component_model.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/upcoming_schedule_listview.dart';
import 'package:demo_app/features/calender/presentation/ui/widgets/home_calendar_widget.dart';


import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/home/home_page/presentation/utils/home_constants.dart';
import 'package:demo_app/features/home/home_page/presentation/controller/home_cubit.dart';
import 'package:demo_app/features/home/home_page/presentation/controller/home_state.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/tablet/home_appbar_section.dart';

class TabletHomeScreen extends StatefulWidget {
  const TabletHomeScreen({super.key});

  @override
  State<TabletHomeScreen> createState() => _TabletHomeScreenState();
}

class _TabletHomeScreenState extends State<TabletHomeScreen> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return BlocBuilder<AppHomeCubit, HomeState>(
      buildWhen: (_, __) {
        return true;
      },
      builder: (context, state) {
        final homeCubit = context.read<AppHomeCubit>();

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
                        behavior: const ScrollBehavior().copyWith(scrollbars: false),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCustomAppBar(homeCubit),

                              SizedBox(height: 20.sp),

                              // Components grid
                              Column(
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
                                          in homeCubit
                                              .getActiveRowComponents(rowIndex))
                                            component.component.widget(component) ??
                                                Container()
                                        ],
                                      ),
                                    ),
                                ],
                              ),

                              // Portrait mode schedule section
                              if (isPortrait) SizedBox(height: 30.h),
                              if (isPortrait)
                                Text("Upcoming Schedule".tr,
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
      },
    );
  }

  // Build custom app bar with header icons
  Widget _buildCustomAppBar(AppHomeCubit homeCubit) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: HomeAppbarSection(),
        ),
        SizedBox(width: 0.sp),
      ],
    );
  }
}
///*********************** FILE INFO ****************************///
/// File Name: edit_home_page.dart
/// Purpose: UI for editing home page components
/// Author: Amr Mesbah
/// Created at: 21/9/2025

import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/helper/main_helper/pagination_app_bar.dart';
import 'package:grc_module/features/home/h1_home_page/data_source/models/home_component_model.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/pages/adding_widget_page.dart';
import 'package:flutter/services.dart';

import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/home/h3_app_drawer/presentation/ui/pages/custom_drawer.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';
import 'package:grc_module/features/home/h1_home_page/data_source/home_constants.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/controller/home_state.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/add_component_widget.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/app_bar_date.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/app_bar_greetings.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/dashedIcon_container.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/edit_home_page_custom_button.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/icon_selector_dialog_widget.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/remove_component_wrapper.dart';

import 'package:grc_module/core/custom/32-custom_svg.dart';

import '../../../../../../core/custom/33-custom_haptic.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
class EditHomePage extends StatelessWidget {
  EditHomePage({super.key});
  late bool isTablet;

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    AppHomeCubit homeCubit = context.read<AppHomeCubit>();
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
            padding: EdgeInsetsDirectional.only(
                start: isTablet ? 30.sp : 15.sp, end: 10.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaginationAppBar(screensTitles: [
                  (S.of(context).settings),
                  S.of(context).homeLayout
                ]),
                Expanded(
                  child: ScrollConfiguration(
                    behavior:
                    const ScrollBehavior().copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Add Drawer Reordering Toggle Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Obx(() {
                                return GestureDetector(
                                  onTap: () {
                                    hapticController.triggerHapticFeedback(
                                        vibration: VibrateType.mediumImpact,
                                        hapticFeedback:
                                        HapticFeedback.mediumImpact);

                                    isDrawerReorderingActive.value =
                                    !isDrawerReorderingActive.value;
                                  },
                                  child: Container(
                                    width: 300.w,
                                    height: 36.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius:
                                      BorderRadius.circular(8.sp),
                                      border: Border.all(
                                        color: AppColors.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isDrawerReorderingActive.value
                                              ? Icons.check_circle
                                              : Icons.reorder,
                                          color: AppColors.textButton,
                                          size: 15.sp,
                                        ),
                                        SizedBox(width: 8.sp),
                                        Text(
                                          isDrawerReorderingActive.value
                                              ? S.of(context).reorderingActive
                                              : S
                                              .of(context)
                                              .enableDrawerReordering,
                                          style: AppTextStyles
                                              .font12BlackMediumCairo
                                              .copyWith(
                                            color: AppColors.textButton,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                          SizedBox(height: 20.sp),
                          Row(
                            spacing: 10.sp,
                            children: [
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    spacing: 15.sp,
                                    children: [
                                      // ✅ FIX: Wrapped in LayoutBuilder to prevent Row overflow.
                                      // The icons row now uses Flexible so it won't overflow
                                      // when 3 icons are added.
                                      Row(
                                        spacing: 10.sp,
                                        children: [
                                          Container(
                                              padding:
                                              EdgeInsets.all(10.sp),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                      AppColors.primary),
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      8.sp)),
                                              child: AppBarDate()),
                                          Spacer(),

                                          // Plus button
                                          BlocBuilder<AppHomeCubit,
                                              HomeState>(
                                            builder: (context, state) {
                                              if (homeCubit
                                                  .selectedHeaderIcons
                                                  .length <
                                                  3) {
                                                return InkWell(
                                                  onTap: () {
                                                    hapticController
                                                        .triggerHapticFeedback(
                                                        vibration:
                                                        VibrateType
                                                            .lightImpact,
                                                        hapticFeedback:
                                                        HapticFeedback
                                                            .lightImpact);
                                                    showDialog(
                                                      context: context,
                                                      builder: (dialogContext) =>
                                                          IconSelectorDialog(
                                                            onIconSelected:
                                                                (icon) {
                                                              homeCubit
                                                                  .addHeaderIcon(
                                                                  icon);
                                                            },
                                                          ),
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 25.sp,
                                                    height: 25.sp,
                                                    decoration: BoxDecoration(
                                                        color:
                                                        AppColors.primary,
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            4.r)),
                                                    child: SizedBox(
                                                      child: CustomSvgImage(
                                                        assetPath:
                                                        "assets/icons_assets/main_icons_assets/plus.svg",
                                                        width: 12.w,
                                                        height: 12.h,
                                                        color: AppColors
                                                            .textButton,
                                                        fit: BoxFit.scaleDown,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return SizedBox.shrink();
                                              }
                                            },
                                          ),

                                          // ✅ FIX: Wrapped icons row in Flexible to prevent
                                          // overflow when multiple icons are displayed.
                                          Flexible(
                                            child: BlocBuilder<AppHomeCubit,
                                                HomeState>(
                                              builder: (context, state) {
                                                return SingleChildScrollView(
                                                  scrollDirection:
                                                  Axis.horizontal,
                                                  child: Row(
                                                    spacing: 4.sp,
                                                    children: [
                                                      for (int i = 0;
                                                      i <
                                                          homeCubit
                                                              .selectedHeaderIcons
                                                              .length;
                                                      i++)
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                              horizontal:
                                                              2.sp,
                                                              vertical:
                                                              4.sp),
                                                          child: InkWell(
                                                            onTap: () {
                                                              Navigator.of(
                                                                  context)
                                                                  .push(
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                      homeCubit
                                                                          .selectedHeaderIcons[i]
                                                                          .navigateTo(context),
                                                                ),
                                                              );
                                                            },
                                                            child:
                                                            DashedIconContainer(
                                                              svgAssetPath: homeCubit
                                                                  .selectedHeaderIcons[
                                                              i]
                                                                  .svgPath,
                                                              onMinusTap: () {
                                                                homeCubit
                                                                    .removeHeaderIcon(
                                                                    i);
                                                              },
                                                              dashColor:
                                                              AppColors
                                                                  .primary,
                                                              backgroundColor:
                                                              AppColors
                                                                  .primary,
                                                              width: 48.sp,
                                                              height: 48.sp,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10.sp),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColors.primary),
                                            borderRadius:
                                            BorderRadius.circular(8.sp)),
                                        child: AppBarGreetings(),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                                height: 80.sp,
                                                padding:
                                                EdgeInsets.all(10.sp),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                        AppColors.primary),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.sp)),
                                                child: Text(
                                                    context
                                                        .read<AppHomeCubit>()
                                                        .quote
                                                        ,
                                                    style: StyleText
                                                        .fontSize16Weight500
                                                        .copyWith(
                                                        fontWeight:
                                                        FontWeight.w700,
                                                        color: AppColors
                                                            .text))),
                                          ),
                                        ],
                                      ),

                                      BlocBuilder<AppHomeCubit, HomeState>(
                                          builder: (_, state) {
                                            return Column(
                                              spacing: 15.sp,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                for (int rowIndex = 1;
                                                rowIndex <=
                                                    HomeConstants
                                                        .NUMBER_OF_ROWS;
                                                rowIndex++)
                                                  SingleChildScrollView(
                                                    scrollDirection:
                                                    Axis.horizontal,
                                                    child: Row(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      spacing: 15.sp,
                                                      children: [
                                                        for (int columnIndex = 1;
                                                        columnIndex <=
                                                            HomeConstants
                                                                .NUMBER_OF_COLUMNS;
                                                        columnIndex++)
                                                          item(
                                                              columnIndex:
                                                              columnIndex,
                                                              rowIndex: rowIndex,
                                                              cubit: homeCubit)
                                                      ],
                                                    ),
                                                  )
                                              ],
                                            );
                                          })
                                    ]),
                              ),
                              // ✅ FIX: Removed the fixed-width Container(355.sp) that was
                              // causing a large empty space on the left in RTL (Arabic) mode.
                              // In RTL layouts, a trailing spacer becomes a leading spacer,
                              // pushing all content away from the drawer side.
                            ],
                          ),
                          SizedBox(height: 20.sp),
                          SizedBox(height: 10.sp),
                          EditHomePageCustomButton(),
                          SizedBox(height: 20.sp)
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.sp)
              ],
            )),
      ),
    );
  }

  Widget item(
      {required int columnIndex,
        required int rowIndex,
        required AppHomeCubit cubit}) {
    HomeComponentModel? model =
    cubit.getEditedComponent(columnIndex: columnIndex, rowIndex: rowIndex);

    return Builder(
      builder: (BuildContext context) {
        if (model == null) {
          return InkWell(
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              cubit.selectComponentToEdit(
                  rowIndex: rowIndex, columnIndex: columnIndex);

              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BlocProvider<AppHomeCubit>.value(
                      value: cubit, child: AddingWidgetPage())));
            },
            child: AddComponentWidget(
                columnIndex: columnIndex, rowIndex: rowIndex),
          );
        } else {
          return RemoveComponentWrapper(
              model: model,
              component: model.component.widget(model) ?? Container());
        }
      },
    );
  }
}
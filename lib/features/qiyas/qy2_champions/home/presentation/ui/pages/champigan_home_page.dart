import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/qyias_module/routes.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/helper/pagination_app_bar.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/presentation/controller/qiyas_dashboard_controller_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/controller/qiyas_home_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/qiyas_table_headers.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/home/presentation/ui/widgets/tablet/qiyas_custom_home_table.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/ui/widgets/qiyas_custom_vision_list.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/ui/widgets/qiyas_custom_vision_list_mobile.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champigan_core/presentation/controller/champigan_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champion_tasks/presentation/ui/pages/champigan_tasks_page.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/qiyas_log_service.dart';

class ChampiganHomePage extends StatelessWidget {
  ChampiganHomePage({super.key});
  final QiyasHomeCubit controller =
      sl.registerSingletonIfAbsent(() => QiyasHomeCubit());
  final ChampiganCoreCubit champiganCoreCubit =
      sl.registerSingletonIfAbsent(() => ChampiganCoreCubit());

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      QiyasLogService.log('qiyas champion home');
    });
    sl<ChampiganCoreCubit>().initCubit();
    bool isTablet = !kpIsPhoneLayout(context);
    return BlocProvider<QiyasHomeCubit>.value(
      value: controller,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
                start: isTablet ? 30.sp : 15.sp, end: 15.sp),
            child: Directionality(
                textDirection: TextDirection.rtl,
                child: BlocBuilder<QiyasHomeCubit, QiyasHomeState>(
                  buildWhen: (_, __) {
                    return true;
                  },
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PaginationAppBar(
                          screensTitles: ['قياس التحول الرقمي'],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isTablet) SizedBox(height: 30.sp),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    customButton(
                                        width: 140.sp,
                                        title: 'المعايير المكلفه',
                                        function: () {
                                          if (isTablet) {
                                            Navigator.of(context).pushNamed(
                                                Routes.champiganTasksPage);
                                          } else {
                                            Navigator.push(context,
                                                MaterialPageRoute(builder: (_) {
                                              return ChampiganTasksPage();
                                            }));
                                          }
                                        })
                                  ],
                                ),
                                SizedBox(height: 25.sp),
                                if (isTablet) // Todo: ensure there is a data
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: AppColors.card),
                                        padding: EdgeInsets.all(8.sp),
                                        child: Row(
                                          children: [
                                            customButton(
                                              function: () {
                                                controller
                                                    .isTabsSelectedState(true);
                                              },
                                              textStyle: StyleText
                                                  .fontSize14Weight500
                                                  .copyWith(
                                                      color: controller
                                                              .isTabsSelected
                                                          ? AppColors.textButton
                                                          : AppColors.text),
                                              color: controller.isTabsSelected
                                                  ? AppColors.primary
                                                  : AppColors.card,
                                              title: "المخطط",
                                            ),
                                            SizedBox(width: 10.sp),
                                            customButton(
                                              function: () {
                                                controller
                                                    .isTabsSelectedState(false);
                                              },
                                              textStyle: StyleText
                                                  .fontSize14Weight500
                                                  .copyWith(
                                                      color: !controller
                                                              .isTabsSelected
                                                          ? AppColors.textButton
                                                          : AppColors.text),
                                              color: !controller.isTabsSelected
                                                  ? AppColors.primary
                                                  : AppColors.card,
                                              title: "الجدول",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                SizedBox(height: (isTablet) ? 25.sp : 10.sp),
                                (controller.isTabsSelected)
                                    ? isTablet
                                        ? BlocProvider(
                                            create: (context) =>
                                                QiyasDashboardControllerCubit(),
                                            child: QiyasCustomVisionList(
                                                isClickable: false),
                                          )
                                        : BlocProvider(
                                            create: (context) =>
                                                QiyasDashboardControllerCubit(),
                                            child: QiyasCustomVisionListMobile(
                                                isClickable: false),
                                          )
                                    : Column(
                                        children: [
                                          Row(
                                            spacing: ButtonSizing.toolbarGap(
                                                context),
                                            children: [
                                              AppSearchTextField(
                                                controller:
                                                    controller.visionName,
                                                onChanged: (_) {
                                                  controller.filterVisions();
                                                },
                                              ),
                                              /*  SizedBox(
                                                height: ButtonSizing.height,
                                                width: isPortrait ? 38.h : 100.w,
                                                child: isPortrait
                                                    ? ReusableIconContainer(
                                                        filterColor: true,
                                                        imagePath:
                                                            "assets/icons_assets/main_icons_assets/ic_action_export.svg",
                                                        onPressed: () {
                                                          showAppDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext context) {
                                                              return const ExportTableDialog();
                                                            },
                                                          );
                                                        })
                                                    : CustomIconButton(
                                                        buttonText: "تصدير",
                                                        iconPath:
                                                            "assets/icons_assets/main_icons_assets/ic_action_export.svg",
                                                        onTap: () {
                                                          showAppDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext context) {
                                                              return const ExportTableDialog();
                                                            },
                                                          );
                                                        }),
                                              ),*/
                                            ],
                                          ),
                                          SizedBox(height: 10.sp),
                                          /*  Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              CustomIconButton(
                                                  buttonText: "تعديل",
                                                  iconPath: "assets/icons_assets/main_icons_assets/ic_action_edit.svg",
                                                  onTap: () {})
                                            ],
                                          ),*/
                                          SizedBox(height: 10.sp),
                                          QiyasCustomHomeTable(
                                              columnNames: qiyasTableHeaders)
                                        ],
                                      )
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                )),
          ),
        ),
      ),
    );
  }
}

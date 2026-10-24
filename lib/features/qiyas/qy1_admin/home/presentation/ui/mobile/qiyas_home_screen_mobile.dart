/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_home_screen_mobile.dart
/// Purpose: Displays the "Qiyas Home" screen with options for different sections such as approvals,
///          dashboard, and transformation roles_module. It features dynamic navigation, filters, and interactive elements.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This widget renders the mobile layout for the "Qiyas Home" screen. It provides navigation
///              to various sections like "approvals", "Dashboard", "Visionaries", and "Owners". It also includes
///              search bars, filter buttons, and dynamic content based on the selected section (visionaries or owners).
/// ********************************************************************* ///
library;

import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/home/presentation/controller/manager_home_controller.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/page_screen_toplevel.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/export_dialog.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/presentation/controller/qiyas_bulk_visions_controller.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/home/presentation/ui/widgets/navigation_buttons.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions_sections.dart';
import 'package:page_transition/page_transition.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_tabs.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champigan_core/presentation/controller/champigan_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/controller/qiyas_home_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/ui/widgets/qiyas_custom_vision_list_mobile.dart';
import 'package:knowticed_plus/features/qiyas/qy4_owner/owner_core/presentation/controller/owner_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/ui/pages/tablet/qiyas_create_control_champion.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/ui/widgets/filter_by_department.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/presentation/controller/qiyas_dashboard_controller_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/home/presentation/ui/widgets/bulk_upload_section.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/home/presentation/ui/widgets/tablet/qiyas_control_champion_card.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/qiyas_log_service.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_toolbar_action_button.dart';

class QiyasHomeScreenMobile extends StatelessWidget {
  const QiyasHomeScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      QiyasLogService.log('qiyas home');
    });
    MainCoreEmployeeController mainCoreEmployeeController = Get.find();

    Get.put(QiyasBulkVisionsController());
    Get.put(ManagerHomeController());
    sl.registerSingletonIfAbsent(() => QiyasCreateChampionControllerCubit());
    sl.registerSingletonIfAbsent(() => QiyasHomeCubit());
    sl.registerSingletonIfAbsent(() => OwnerCoreCubit());
    sl.registerSingletonIfAbsent(() => ChampiganCoreCubit());
    return BlocProvider(
      create: (context) => sl<QiyasHomeCubit>(),
      child: BlocBuilder<QiyasHomeCubit, QiyasHomeState>(buildWhen: (_, state) {
        return true;
      }, builder: (context, state) {
        QiyasHomeCubit controller = context.read<QiyasHomeCubit>();
        return Directionality(
          textDirection: TextDirection.rtl,
          child: PageScreenTopLevel(
              hasScroll: true,
              title: "قياس التحول الرقمي",
              children: [
                NavigationButtons(),
                SizedBox(height: 25.sp),
                CustomTabs(
                    selectedValue: controller.selectedQiyasScreenIndex,
                    onChanged: controller.updateSelectedQiyasScreenIndex,
                    tabs: const [
                      'المناظير',
                      'سفراء التحول الرقمي',
                    ]),
                SizedBox(height: 10.sp),
                if (controller.selectedQiyasScreenIndex == 0 &&
                    mainCoreEmployeeController.isHasPermission(
                        module: Modules.qiyas,
                        permission: QiyasPermissions.exportTable,
                        section: QiyasPermissionsSections.qiyasPermissions))
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                              height: 38.h,
                              width: 38.h,
                              child: customButtonWithSvg(
                                image:
                                    "assets/icons_assets/main_icons_assets/ic_action_export.svg",
                                function: () {
                                  showAppDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: ExportDialog(
                                          onDownloadFile: (String fileName) {
                                            controller.exportFile(fileName);
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                                title: '',
                                color: AppColors.primary,
                                svgColor: AppColors.textButton,
                                colorBorder: AppColors.transparent,
                                widthImage: 20.sp,
                                heightImage: 20.sp,
                                textStyle: StyleText.fontSize16Weight400,
                              )),
                        ],
                      ),
                      SizedBox(height: 10.sp)
                    ],
                  ),
                controller.selectedQiyasScreenIndex == 0
                    ? controller.isEmptyVisions
                        ? BulkUploadSection()
                        : BlocProvider(
                            create: (context) =>
                                QiyasDashboardControllerCubit(),
                            child: QiyasCustomVisionListMobile(),
                          )
                    : controller.selectedQiyasScreenIndex == 1
                        ? BlocProvider<ControlCoreCubit>.value(
                            value: sl<QiyasCreateChampionControllerCubit>(),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    AppSearchTextField(
                                      controller:
                                          sl<QiyasCreateChampionControllerCubit>()
                                              .searchController,
                                      onChanged: (value) {
                                        sl<QiyasCreateChampionControllerCubit>()
                                            .filterEmployees();
                                      },
                                    ),
                                    SizedBox(
                                        width:
                                            ButtonSizing.toolbarGap(context)),
                                    SizedBox(
                                      height: 38,
                                      width: 38,
                                      child: customButtonWithSvg(
                                        function: () {
                                          FilterByDepartmentDialog.show(
                                              sl<QiyasCreateChampionControllerCubit>(),
                                              context);
                                        },
                                        image:
                                            "assets/icons_assets/main_icons_assets/ic_action_filter.svg",
                                        title: '',
                                        // 22/10/2026 — Owner: filter and sort icons are one size and colour in every module (ToolbarStyle).
                                        color: AppColors.card,
                                        svgColor: ToolbarStyle.contentColor,
                                        colorBorder: AppColors.transparent,
                                        widthImage: 20.sp,
                                        heightImage: 20.sp,
                                        textStyle:
                                            StyleText.fontSize16Weight400,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                if (mainCoreEmployeeController.isHasPermission(
                                    module: Modules.qiyas,
                                    permission: QiyasPermissions.assignChampion,
                                    section: QiyasPermissionsSections
                                        .qiyasPermissions))
                                  SizedBox(
                                      height: 38,
                                      child: customButtonWithSvg(
                                        title: "سفير",
                                        image:
                                            "assets/icons_assets/main_icons_assets/ic_action_plus.svg",
                                        function: () {
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              type: PageTransitionType.fade,
                                              child: BlocProvider<
                                                  ControlCoreCubit>.value(
                                                value: sl<
                                                    QiyasCreateChampionControllerCubit>(),
                                                child:
                                                    QiyasCreateControlChampion(),
                                              ),
                                            ),
                                          );
                                        },
                                        color: AppColors.primary,
                                        colorBorder: AppColors.transparent,
                                        widthImage: 20.sp,
                                        heightImage: 20.sp,
                                        svgColor: AppColors.textButton,
                                        // 22/10/2026 — Owner: toolbar text is 14 medium (500) in every module.
                                        textStyle: StyleText.fontSize14Weight500
                                            .copyWith(
                                                color: AppColors.textButton),
                                      )),
                                const QiyasControlChampionCard(),
                              ],
                            ),
                          )
                        : Container(),
              ]),
        );
      }),
    );
  }
}

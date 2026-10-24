/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_home_screen_tablet.dart
/// Purpose: Displays the "Qiyas Home" screen for pages layout with options for different sections such as approvals,
///          dashboard, transformation roles_module, and vision management. It supports dynamic navigation, filters, and interactive components.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This widget renders the pages layout for the "Qiyas Home" screen. It includes navigation to sections
///              like "approvals", "Dashboard", and transformation roles_module (visionaries and owners). The layout adapts to
///              portrait/landscape orientations and integrates various filters, search bars, and dynamic content such as tables and vision lists.
/// ********************************************************************* ///
library;

import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/home/presentation/controller/manager_home_controller.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/qyias_module/routes.dart';
import 'package:knowticed_plus/core/helper/pagination_app_bar.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/presentation/controller/qiyas_dashboard_controller_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/controller/qiyas_home_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy4_owner/owner_tasks/presentation/controller/qiyas_owner_core_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions_sections.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_tabs.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/data_grc_2/features/dashboard_screens_departments/presentation/UI/widgets/container_filter.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/CUD_module/domain/usecases/read_all_module_usecase.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/domain/use_cases/read_all_vision_usecase.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';

import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/qiyas_table_headers.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/export_dialog.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champigan_core/presentation/controller/champigan_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/ui/widgets/qiyas_custom_vision_list.dart';
import 'package:knowticed_plus/features/qiyas/qy4_owner/owner_core/presentation/controller/owner_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/presentation/controller/qiyas_bulk_visions_controller.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/ui/widgets/filter_by_department.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/home/presentation/ui/widgets/bulk_upload_section.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/home/presentation/ui/widgets/navigation_buttons.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/home/presentation/ui/widgets/tablet/qiyas_control_champion_card.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/home/presentation/ui/widgets/tablet/qiyas_custom_home_table.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/qiyas_log_service.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_toolbar_action_button.dart';

class QiyasHomeScreenTablet extends StatefulWidget {
  const QiyasHomeScreenTablet({super.key});

  @override
  State<QiyasHomeScreenTablet> createState() => _QiyasHomeScreenTabletState();
}

class _QiyasHomeScreenTabletState extends State<QiyasHomeScreenTablet> {
  MainCoreEmployeeController mainCoreEmployeeController = Get.find();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initControllers(); // registers cubits/controllers before first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load vision data AFTER the first build so BlocBuilder is subscribed
      // before getVisions() emits and triggers a rebuild.
      final bulkController = Get.isRegistered<QiyasBulkVisionsController>()
          ? Get.find<QiyasBulkVisionsController>()
          : Get.put(QiyasBulkVisionsController());
      bulkController.readDataFromFirestore();
      QiyasLogService.log('qiyas home');
    });
  }

  void _initControllers() {
    if (_initialized) return;
    _initialized = true;

    // Initialize the Qiyas service locator FIRST so that use-cases
    // (ReadAllVisionUsecase, QiyasChampionRepo, etc.) are registered
    // before any controller's onInit() tries to call sl<...>().
    if (!sl.isRegistered<ReadAllVisionUsecase>()) {
      setUpQiyas();
    }

    // Register all cubits/controllers — do NOT load data yet.
    // Data loading is deferred to addPostFrameCallback above.
    sl.registerSingletonIfAbsent(() => QiyasHomeCubit());
    sl.registerSingletonIfAbsent(() => QiyasCreateChampionControllerCubit());
    sl.registerSingletonIfAbsent(() => QiyasDashboardControllerCubit());
    final OwnerCoreCubit ownerCoreCubit =
        sl.registerSingletonIfAbsent(() => OwnerCoreCubit());
    final ChampiganCoreCubit champiganCoreCubit =
        sl.registerSingletonIfAbsent(() => ChampiganCoreCubit());
    sl.registerSingletonIfAbsent(() => QiyasOwnerTasksCubit());
    ownerCoreCubit.initCubit();
    champiganCoreCubit.initCubit();

    // Create the bulk controller without triggering a data load
    // (onInit fires here, but readDataFromFirestore is also called above
    // via postFrameCallback which is the authoritative load).
    if (!Get.isRegistered<QiyasBulkVisionsController>()) {
      Get.put(QiyasBulkVisionsController());
    }

    // Initialize the GRC service locator so that ManagerHomeController.onInit()
    // can resolve ReadAllModuleUsecase, ReadAllPolicyUsecase, ReadAllControlUsecase,
    // ReadAllControlChampionUsecase, and ReadAllControlOwnerUsecase.
    if (!sl.isRegistered<ReadAllModuleUsecase>()) {
      setUp();
    }

    if (!Get.isRegistered<ManagerHomeController>()) {
      Get.put(ManagerHomeController());
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context); // Check if tablet
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocProvider.value(
      value: sl<QiyasHomeCubit>(),
      child: BlocBuilder<QiyasHomeCubit, QiyasHomeState>(buildWhen: (_, state) {
        return true;
      }, builder: (context, state) {
        debugPrint("build home screen pages");
        QiyasHomeCubit controller = context.read<QiyasHomeCubit>();
        return BlocProvider.value(
          value: sl<QiyasCreateChampionControllerCubit>() as ControlCoreCubit,
          child: Scaffold(
            body: Padding(
              padding: EdgeInsetsDirectional.only(
                  start: isTablet ? 15.sp : 15.sp, end: 15.sp),
              child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PaginationAppBar(screensTitles: ["قياس التحول الرقمي"]),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              NavigationButtons(),
                              SizedBox(height: 25.sp),
                              Row(children: [
                                Expanded(
                                  child: CustomTabs(
                                      selectedValue:
                                          controller.selectedQiyasScreenIndex,
                                      onChanged: controller
                                          .updateSelectedQiyasScreenIndex,
                                      tabs: const [
                                        'المناظير',
                                        'سفراء التحول الرقمي',
                                      ]),
                                ),
                                if (!controller.isEmptyVisions &&
                                    controller.selectedQiyasScreenIndex == 0)
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: AppColors.card),
                                    padding: EdgeInsets.all(8.sp),
                                    child: Row(
                                      children: [
                                        ContainerFiltered(
                                          horizontalPadding: 8,
                                          onTap: () {
                                            controller
                                                .isTabsSelectedState(true);
                                          },
                                          isSelcted: controller.isTabsSelected,
                                          title: "المخطط",
                                        ),
                                        SizedBox(width: 10.sp),
                                        ContainerFiltered(
                                          horizontalPadding: 8,
                                          onTap: () {
                                            controller
                                                .isTabsSelectedState(false);
                                          },
                                          isSelcted: !controller.isTabsSelected,
                                          title: "الجدول",
                                        ),
                                      ],
                                    ),
                                  ),
                              ]),
                              SizedBox(height: 16.sp),
                              controller.selectedQiyasScreenIndex == 0
                                  ? controller.isEmptyVisions
                                      ? BulkUploadSection()
                                      : controller.isTabsSelected
                                          ? BlocProvider(
                                              create: (context) =>
                                                  QiyasDashboardControllerCubit(),
                                              child: QiyasCustomVisionList(
                                                  isAdminHome: true),
                                            )
                                          : tableSection(
                                              controller, isPortrait, context)
                                  : controller.selectedQiyasScreenIndex == 1
                                      ? championSection(isPortrait, context)
                                      : Container(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        );
      }),
    );
  }

  Column championSection(bool isPortrait, BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: ButtonSizing.toolbarGap(context),
          children: [
            AppSearchTextField(
              hintText: "بحث",
              controller:
                  sl<QiyasCreateChampionControllerCubit>().searchController,
              onChanged: (value) {
                sl<QiyasCreateChampionControllerCubit>().filterEmployees();
              },
            ),
            isPortrait
                ? SizedBox(
                    height: 38.sp,
                    width: 38.sp,
                    child: customButtonWithSvg(
                      function: () {
                        FilterByDepartmentDialog.show(
                            sl<QiyasCreateChampionControllerCubit>(), context);
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
                      textStyle: StyleText.fontSize16Weight400,
                    ),
                  )
                : SizedBox(
                    height: 38.sp,
                    width: 100.sp,
                    child: customButtonWithSvg(
                      // 22/10/2026 — Owner: toolbar text is 14 in every module (was 16).
                      textStyle: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.blackButton)
                          .copyWith(color: AppColors.secondaryText),
                      svgColor: AppColors.secondaryText,
                      title: "الفرز",
                      function: () {
                        FilterByDepartmentDialog.show(
                            sl<QiyasCreateChampionControllerCubit>(), context);
                      },
                      color: AppColors.card,
                      image:
                          "assets/icons_assets/main_icons_assets/ic_action_filter.svg",
                      colorBorder: AppColors.transparent,
                      widthImage: 20.sp,
                      heightImage: 20.sp,
                    ),
                  ),
            if (mainCoreEmployeeController.isHasPermission(
                module: Modules.qiyas,
                permission: null,
                section: QiyasPermissionsSections.qiyasPermissions))
              if (mainCoreEmployeeController.isHasPermission(
                  module: Modules.qiyas,
                  permission: QiyasPermissions.assignChampion,
                  section: QiyasPermissionsSections.qiyasPermissions))
                customButtonWithSvg(
                  width: 100,
                  title: "سفير",
                  image:
                      "assets/icons_assets/main_icons_assets/ic_action_plus.svg",
                  function: () {
                    Navigator.pushNamed(context, Routes.createControlChampion);
                  },
                  color: AppColors.primary,
                  colorBorder: AppColors.transparent,
                  widthImage: 20.sp,
                  heightImage: 20.sp,
                  svgColor: AppColors.textButton,
                  // 22/10/2026 — Owner: toolbar text is 14 medium (500) in every module.
                  textStyle: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.textButton),
                )
          ],
        ),
        const QiyasControlChampionCard(),
      ],
    );
  }

  Column tableSection(
      QiyasHomeCubit controller, bool isPortrait, BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: ButtonSizing.toolbarGap(context),
          children: [
            AppSearchTextField(
              controller: controller.visionName,
              onChanged: (_) {
                controller.filterVisions();
              },
            ),
            if (mainCoreEmployeeController.isHasPermission(
                module: Modules.qiyas,
                permission: QiyasPermissions.exportTable,
                section: QiyasPermissionsSections.qiyasPermissions))
              SizedBox(
                height: ButtonSizing.height,
                width: isPortrait ? 38.h : 100.w,
                child: isPortrait
                    ? customButtonWithSvg(
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
                      )
                    : customButtonWithSvg(
                        title: "تصدير",
                        image:
                            "assets/icons_assets/main_icons_assets/ic_action_export.svg",
                        function: () {
                          showAppDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                backgroundColor: AppColors.background,
                                child: ExportDialog(
                                  onDownloadFile: (String fileName) {
                                    controller.exportFile(fileName);
                                  },
                                ),
                              );
                            },
                          );
                        },
                        color: AppColors.primary,
                        colorBorder: AppColors.transparent,
                        widthImage: 20.sp,
                        heightImage: 20.sp,
                        svgColor: AppColors.textButton,
                        // 22/10/2026 — Owner: toolbar text is 14 medium (500) in every module.
                        textStyle: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.textButton),
                      ),
              ),
          ],
        ),
        SizedBox(height: 10.sp),
        SizedBox(height: 10.sp),
        QiyasCustomHomeTable(columnNames: qiyasTableHeaders)
      ],
    );
  }
}

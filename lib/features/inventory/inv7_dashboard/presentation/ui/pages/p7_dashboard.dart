import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_tabs.dart';

class DashboardDesktopScreen extends StatefulWidget {
  const DashboardDesktopScreen({super.key});

  @override
  State<DashboardDesktopScreen> createState() => _DashboardDesktopScreenState();
}

class _DashboardDesktopScreenState extends State<DashboardDesktopScreen> {
  /////////////////////////////////////// storage location //////////////////////
  // Default storage location (shown alone first)
  String? selectSupplier;
  final List<Map<String, String>> selectSupplierList = [
    {"key": "roomA", "value": "Room A"},
    {"key": "roomB", "value": "Room B"},
    {"key": "roomC", "value": "Room C"},
  ];
  /////////////////////////////////////// storage location //////////////////////

  /////////////////////////////////////// storage location //////////////////////
  // Default storage location (shown alone first)
  String? selectStatus;
  final List<Map<String, String>> selectStatusList = [
    {"key": "roomA", "value": "Room A"},
    {"key": "roomB", "value": "Room B"},
    {"key": "roomC", "value": "Room C"},
  ];
  /////////////////////////////////////// storage location //////////////////////

  /////////////////////////////////////// storage location //////////////////////
  // Default storage location (shown alone first)
  String? selectProductType;
  final List<Map<String, String>> selectProductTypeList = [
    {"key": "roomA", "value": "Room A"},
    {"key": "roomB", "value": "Room B"},
    {"key": "roomC", "value": "Room C"},
  ];
  /////////////////////////////////////// storage location //////////////////////

  /////////////////////////////////////// storage location //////////////////////
  // Default storage location (shown alone first)
  String? selectDepartment;
  final List<Map<String, String>> selectDepartmentList = [
    {"key": "roomA", "value": "Room A"},
    {"key": "roomB", "value": "Room B"},
    {"key": "roomC", "value": "Room C"},
  ];
  /////////////////////////////////////// storage location //////////////////////

  /////////////////////////////////////// storage location //////////////////////
  // Default storage location (shown alone first)
  String? selectTime;
  final List<Map<String, String>> selectTimeList = [
    {"key": "roomA", "value": "Room A"},
    {"key": "roomB", "value": "Room B"},
    {"key": "roomC", "value": "Room C"},
  ];
  /////////////////////////////////////// storage location //////////////////////

  //////////////////////////////////////  Stocks Overview //////////////////////////
  final Map<int, int> monthCountss = {
    0: 220,
    1: 300,
    2: 366,
    3: 282,
    4: 49,
    5: 79,
  };
  final List<String> serviceNames = List.generate(
    6,
    (_) => "Product Categories",
  );
  final List<String> serviceNamesArabic = List.generate(
    6,
    (_) => "فئات المنتجات",
  );
  bool isLoadingServicesName = false;
  //////////////////////////////////////  Stocks Overview //////////////////////////

  ///////////////////////////////////// Demands ///////////////////////////////////
  bool isLoadingDemands = false;

  ///////////////////////////////////// Demands ///////////////////////////////////

  /////////////////////////////////// var ////////////////////////////////////////////
  String selectedType = 'Products';
  String selectedTypeHorizental = 'Asset';
  /////////////////////////////////// var ////////////////////////////////////////////

  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    Localizations.localeOf(context).languageCode == 'en';
    final isMobile = context.isPhone;
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventoryManagement,
          onFirstTap: () {
            {
              navigateTo(context, InventoryManagement());
            }
          },
          secondTitle: S.of(context).dashboard,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DropDown
                Row(
                  children: [
                    SizedBox(
                      width: 185.sp,
                      child: CustomDropdown<String>(
                        items: (selectSupplierList)
                            .map((e) => DropdownItem<String>(
                                value: e['key'] ?? '', label: e['value'] ?? ''))
                            .toList(),
                        value: selectSupplier,
                        onChanged: (val) {
                          setState(() {
                            selectSupplier = val;
                          });
                        },
                        hint: S.of(context).selectStorageLocation,
                        height: 38.sp,
                        fillColor: AppColors.card,
                      ),
                    ),
                    Spacer(),
                    SizedBox(
                      width: 185.sp,
                      child: CustomDropdown<String>(
                        items: (selectDepartmentList)
                            .map((e) => DropdownItem<String>(
                                value: e['key'] ?? '', label: e['value'] ?? ''))
                            .toList(),
                        value: selectDepartment,
                        onChanged: (val) {
                          setState(() {
                            selectDepartment = val;
                          });
                        },
                        hint: S.of(context).selectStorageLocation,
                        height: 38.sp,
                        fillColor: AppColors.card,
                      ),
                    ),
                    SizedBox(width: 16.sp),
                    SizedBox(
                      width: 185.sp,
                      child: CustomDropdown<String>(
                        items: (selectTimeList)
                            .map((e) => DropdownItem<String>(
                                value: e['key'] ?? '', label: e['value'] ?? ''))
                            .toList(),
                        value: selectTime,
                        onChanged: (val) {
                          setState(() {
                            selectTime = val;
                          });
                        },
                        hint: S.of(context).selectStorageLocation,
                        height: 38.sp,
                        fillColor: AppColors.card,
                      ),
                    ),
                  ],
                ),
                // space
                SizedBox(height: 15.sp),
                // Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Overall
                              Text(
                                S.of(context).overall,
                                style: StyleText.fontSize20Weight500.copyWith(
                                  color: AppColors.blackButton,
                                ),
                              ),
                              // Space
                              SizedBox(height: 16.sp),

                              Row(
                                children: [
                                  // products
                                  DashboardInfoItem(
                                    assetPath:
                                        "assets/icons_assets/main_icons_assets/ic_data_inventory_products.svg",
                                    label: S.of(context).product,
                                    value: "12",
                                    iconColor: const Color(0xffD8A353),
                                    labelColor: AppColors.secondaryPrimary,
                                    valueColor: AppColors.blackButton,
                                  ),
                                  // Space
                                  SizedBox(width: 32.sp),
                                  // orders
                                  DashboardInfoItem(
                                    assetPath:
                                        "assets/icons_assets/main_icons_assets/ic_data_service_requests.svg",
                                    label: S.of(context).orders,
                                    value: "12",
                                    iconColor: const Color(0xffD8A353),
                                    labelColor: AppColors.secondaryPrimary,
                                    valueColor: AppColors.blackButton,
                                  ),
                                  // Space
                                  SizedBox(width: 32.sp),
                                  // Warehouses
                                  DashboardInfoItem(
                                    assetPath:
                                        "assets/icons_assets/main_icons_assets/ic_module_inventory.svg",
                                    label: S.of(context).warehouses,
                                    value: "12",
                                    iconColor: const Color(0xffD8A353),
                                    labelColor: AppColors.secondaryPrimary,
                                    valueColor: AppColors.blackButton,
                                  ),
                                  // Space
                                  SizedBox(width: 32.sp),
                                  // Low Stock
                                  DashboardInfoItem(
                                    assetPath:
                                        "assets/icons_assets/main_icons_assets/ic_data_inventory_damaged.svg",
                                    label: S.of(context).lowStock,
                                    value: "12",
                                    iconColor: const Color(0xffD8A353),
                                    labelColor: AppColors.secondaryPrimary,
                                    valueColor: AppColors.blackButton,
                                  ),
                                  // Space
                                  SizedBox(width: 32.sp),
                                  // Supplier
                                  DashboardInfoItem(
                                    assetPath:
                                        "assets/icons_assets/main_icons_assets/ic_org_company_building.svg",
                                    label: S.of(context).suppliers,
                                    value: "12",
                                    iconColor: const Color(0xffD8A353),
                                    labelColor: AppColors.secondaryPrimary,
                                    valueColor: AppColors.blackButton,
                                  ),
                                  // Space
                                  SizedBox(width: 32.sp),
                                  // Supplier
                                  DashboardInfoItem(
                                    assetPath:
                                        "assets/icons_assets/main_icons_assets/ic_requests.svg",
                                    label: S.of(context).requests,
                                    value: "12",
                                    iconColor: const Color(0xffD8A353),
                                    labelColor: AppColors.secondaryPrimary,
                                    valueColor: AppColors.blackButton,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // space
                SizedBox(height: 15.sp),

                // Services Offered
                Container(
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 26.sp,
                            height: 26.sp,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                            child: Center(
                              child: CustomSvgImage.natural(
                                assetPath: "",
                                fit: BoxFit.scaleDown,
                                width: 16.sp,
                                height: 16.sp,
                                color: AppColors.textButton,
                                semanticsLabel: 'Dart Logo',
                              ),
                            ),
                          ),
                          SizedBox(width: 4.sp),
                          Text(
                            S.of(context).stocksOverview,
                            style: StyleText.fontSize14Weight400.copyWith(
                              color: AppColors.blackButton,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.sp),
                      SizedBox(
                        height: 200.h,
                        child: isLoadingServicesName
                            ? Center(child: CircleProgressMaster())
                            : BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: 400,
                                  titlesData: FlTitlesData(
                                    // number bar ( 0  - 100  -   200  -   300  -    400 )
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles:
                                            !isArabic, // ✅ show on left only if not Arabic
                                        reservedSize: 28.sp,
                                        interval: 100,
                                        getTitlesWidget: (value, _) {
                                          return Center(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                right: value == 0 ? 6 : 0,
                                              ),
                                              child: Text(
                                                value.toInt().toString(),
                                                style: StyleText
                                                    .fontSize14Weight500
                                                    .copyWith(
                                                  color:
                                                      AppColors.secondaryText,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    // label services
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, _) {
                                          final index = value.toInt();
                                          Localizations.localeOf(
                                            context,
                                          ).languageCode;

                                          if (index >= 0 &&
                                              index < serviceNames.length) {
                                            final isArabic =
                                                Localizations.localeOf(
                                                      context,
                                                    ).languageCode ==
                                                    'ar';
                                            final arabicName = index <
                                                    serviceNamesArabic.length
                                                ? serviceNamesArabic[index]
                                                : '';
                                            final englishName =
                                                index < serviceNames.length
                                                    ? serviceNames[index]
                                                    : '';
                                            final serviceName = isArabic
                                                ? (arabicName.isNotEmpty
                                                    ? arabicName
                                                    : englishName)
                                                : englishName;

                                            return Transform.translate(
                                              offset: const Offset(0, 0),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 10.sp,
                                                  vertical: 5.sp,
                                                ),
                                                child: Text(
                                                  serviceName,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: StyleText
                                                      .fontSize12Weight400
                                                      .copyWith(
                                                    color: Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.light
                                                        ? AppColors.blackButton
                                                        : AppColors.white,
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return const SizedBox.shrink();
                                          }
                                        },
                                      ),
                                    ),

                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: false,
                                      ),
                                    ),

                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles:
                                            isArabic, // ✅ show on right only if Arabic
                                        reservedSize: 28.sp,
                                        interval: 100,
                                        getTitlesWidget: (value, _) {
                                          return Center(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                left: value == 0 ? 6 : 0,
                                              ),
                                              child: Text(
                                                value.toInt().toString(),
                                                style: StyleText
                                                    .fontSize14Weight500
                                                    .copyWith(
                                                  color:
                                                      AppColors.secondaryText,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barTouchData: BarTouchData(
                                    touchTooltipData: BarTouchTooltipData(
                                      tooltipPadding: EdgeInsets.zero,
                                      tooltipMargin: 10,
                                      getTooltipColor: (group) =>
                                          Colors.transparent,
                                      getTooltipItem: (
                                        group,
                                        groupIndex,
                                        rod,
                                        rodIndex,
                                      ) {
                                        if (rod.toY.toInt() == 0) return null;
                                        return BarTooltipItem(
                                          rod.toY.toInt().toString(),
                                          StyleText.fontSize12Weight500
                                              .copyWith(
                                            color: AppColors.blackButton,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  barGroups: monthCountss.entries
                                      .map(
                                        (entry) => _buildBarGroup(
                                          entry.key,
                                          entry.value,
                                        ),
                                      )
                                      .toList(),
                                  gridData: FlGridData(show: false),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                // space
                SizedBox(height: 15.sp),

                // PieChartWithLabels
                isMobile
                    ? Column(
                        children: [
                          // Demands Pie Chart (Assets + Consumables)
                          _PieChartWithLabels(
                            icon:
                                "assets/icons_assets/main_icons_assets/ic_org_briefcase.svg",
                            title: S.of(context).demands,
                            total:
                                '9K', // ⬅️ You can localize it later as needed
                            numberList: ['513', '513'],
                            data: [
                              ('Assets', Color(0xFFFFD452), 40.0),
                              (
                                'Consumables Consumables ',
                                Color(0xFFACACAC),
                                25.0,
                              ),
                            ],
                          ),

                          isMobile
                              ? SizedBox(height: 15.sp)
                              : SizedBox(
                                  width: !isTabletLandscape(context)
                                      ? 15.sp
                                      : 18.sp,
                                ),

                          // Order Fulfillment Status Pie Chart
                          _PieChartWithLabels(
                            icon:
                                "assets/icons_assets/main_icons_assets/ic_status.svg",
                            title: S.of(context).orderFulfillmentStatus,
                            total: '9K',
                            numberList: ['513', '513', '513', '513'],
                            data: [
                              ('Received', Colors.green, 10.0),
                              ('Received Partially', Color(0xFFFF914D), 40.0),
                              ('Cancelled', Colors.red, 25.0),
                              ('Draft', Color(0xFFACACAC), 25.0),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          // Demands Pie Chart (Assets + Consumables)
                          Expanded(
                            child: _PieChartWithLabels(
                              icon:
                                  "assets/icons_assets/main_icons_assets/ic_org_briefcase.svg",
                              title: S.of(context).demands,
                              total:
                                  '9K', // ⬅️ You can localize it later as needed
                              numberList: ['513', '513'],
                              data: [
                                ('Assets', Color(0xFFFFD452), 40.0),
                                (
                                  'Consumables Consumables ',
                                  Color(0xFFACACAC),
                                  25.0,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            width: !isTabletLandscape(context) ? 15.sp : 18.sp,
                          ),

                          // Order Fulfillment Status Pie Chart
                          Expanded(
                            child: _PieChartWithLabels(
                              icon:
                                  "assets/icons_assets/main_icons_assets/ic_status.svg",
                              title: S.of(context).orderFulfillmentStatus,
                              total: '9K',
                              numberList: [
                                '513',
                                '513',
                                '513',
                                '513',
                                '513',
                                '513',
                                '513',
                              ],
                              data: [
                                ('Received', Colors.green, 10.0),
                                ('Received Partially', Color(0xFFFF914D), 40.0),
                                ('Cancelled', Colors.red, 25.0),
                                ('Draft', Color(0xFFACACAC), 25.0),
                                ('Draft', Color(0xFFACACAC), 25.0),
                                ('Draft', Color(0xFFACACAC), 25.0),
                                ('Draft', Color(0xFFACACAC), 25.0),
                              ],
                            ),
                          ),
                        ],
                      ),

                // space
                SizedBox(height: 15.sp),

                buildHorizontalInventoryChart(
                  context: context,
                  lightMode: lightMode,
                  title: "Inventory Valuation",
                  labels: ["Q1", "Q2", "Q3", "Q4"],
                  values: [355, 110, 53, 11],
                  maxValue: 400,
                  barColor: AppColors.primary,
                  backgroundColor: AppColors.card,
                  axisLabels: ["0", "100", "200", "300", "400"],
                ),

                buildVerticalCustomBarChart(
                  context: context,
                  lightMode: Theme.of(context).brightness == Brightness.light,
                  title: S.of(context).productConsumption,
                  labels: ['Water Amr MEsbah hosny main X axis ', 'Juice'],
                  values: [220, 300],
                ),
                // space
                SizedBox(height: 15.sp),

                buildVerticalCustomBarChart(
                  context: context,
                  lightMode: Theme.of(context).brightness == Brightness.light,
                  title: S.of(context).productConsumption,
                  labels: ['Water', 'Juice'],
                  values: [220, 300],
                  needWidget: CustomTabs(
                    tabs: ["Products", "Categories"],
                    selectedValue:
                        (["Products", "Categories"]).indexOf(selectedType),
                    onChanged: (index) => ((val) {
                      setState(() {
                        selectedType = val;
                      });
                    })((["Products", "Categories"])[index]),
                  ),
                ),

                SizedBox(height: 15.sp),

                buildHorizontalInventoryChart(
                  context: context,
                  lightMode: lightMode,
                  title: S.of(context).productsDiscrepancy,
                  labels: ["Missing", "Damaged", "Expired"],
                  values: [355, 110, 53],
                  maxValue: 400,
                  barColor: AppColors.primary,
                  barColors: [
                    Color(0xff797979),
                    Color(0xffDF1C1C),
                    Color(0xffFFDE59),
                  ],
                  backgroundColor: AppColors.card,
                  axisLabels: ["0", "100", "200", "300", "400"],
                  needWidget: CustomTabs(
                    tabs: const ['Asset', 'Consumable'],
                    selectedValue: (const ['Asset', 'Consumable'])
                        .indexOf(selectedTypeHorizental),
                    onChanged: (index) => ((val) {
                      setState(() {
                        selectedTypeHorizental = val;
                      });
                    })((const ['Asset', 'Consumable'])[index]),
                  ),
                ),

                SizedBox(height: 15.sp),

                buildVerticalCustomBarChart(
                  context: context,
                  lightMode: Theme.of(context).brightness == Brightness.light,
                  title: S.of(context).productConsumption,
                  labels: ['Jan', 'Feb', 'Mar', 'April', 'May'],
                  values: [220, 300, 205, 320, 190],
                  barAlignment: BarChartAlignment.start,
                  groupsSpace: 30.sp,
                  needWidget: Row(
                    children: [
                      SizedBox(
                        width: 110.sp,
                        child: CustomDropdown<String>(
                          items: (selectStatusList)
                              .map((e) => DropdownItem<String>(
                                  value: e['key'] ?? '',
                                  label: e['value'] ?? ''))
                              .toList(),
                          value: selectStatus,
                          onChanged: (val) {
                            setState(() {
                              selectStatus = val;
                            });
                          },
                          hint: S.of(context).status,
                          height: 30.sp,
                        ),
                      ),
                      SizedBox(width: 10.sp),
                      SizedBox(
                        width: 110.sp,
                        child: CustomDropdown<String>(
                          items: (selectProductTypeList)
                              .map((e) => DropdownItem<String>(
                                  value: e['key'] ?? '',
                                  label: e['value'] ?? ''))
                              .toList(),
                          value: selectProductType,
                          onChanged: (val) {
                            setState(() {
                              selectProductType = val;
                            });
                          },
                          hint: S.of(context).productType,
                          height: 30.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 15.sp),

                buildVerticalCustomBarChart(
                  context: context,
                  lightMode: Theme.of(context).brightness == Brightness.light,
                  title: S.of(context).maintenanceRequests,
                  labels: ['Dell', 'Router', 'HP 152'],
                  values: [220, 300, 350],
                  needWidget: CustomTabs(
                    tabs: ["Products", "Categories"],
                    selectedValue:
                        (["Products", "Categories"]).indexOf(selectedType),
                    onChanged: (index) => ((val) {
                      setState(() {
                        selectedType = val;
                      });
                    })((["Products", "Categories"])[index]),
                  ),
                ),
                SizedBox(height: 15.sp),
                buildVerticalCustomBarChart(
                  context: context,
                  lightMode: Theme.of(context).brightness == Brightness.light,
                  title: S.of(context).requests,
                  labels: ['Jan', 'Feb', 'Mar', 'April', 'May'],
                  values: [220, 300, 205, 320, 190],
                  barAlignment: BarChartAlignment.start,
                  groupsSpace: 30.sp,
                  needWidget: Row(
                    children: [
                      SizedBox(
                        width: 110.sp,
                        child: CustomDropdown<String>(
                          items: (selectStatusList)
                              .map((e) => DropdownItem<String>(
                                  value: e['key'] ?? '',
                                  label: e['value'] ?? ''))
                              .toList(),
                          value: selectStatus,
                          onChanged: (val) {
                            setState(() {
                              selectStatus = val;
                            });
                          },
                          hint: S.of(context).status,
                          height: 30.sp,
                        ),
                      ),
                      SizedBox(width: 10.sp),
                      SizedBox(
                        width: 110.sp,
                        child: CustomDropdown<String>(
                          items: (selectProductTypeList)
                              .map((e) => DropdownItem<String>(
                                  value: e['key'] ?? '',
                                  label: e['value'] ?? ''))
                              .toList(),
                          value: selectProductType,
                          onChanged: (val) {
                            setState(() {
                              selectProductType = val;
                            });
                          },
                          hint: S.of(context).productType,
                          height: 30.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 15.sp),

                buildVerticalCustomBarChart(
                  context: context,
                  lightMode: Theme.of(context).brightness == Brightness.light,
                  title: S.of(context).suppliers,
                  labels: [
                    'Supplier Name',
                    'Supplier Name',
                    'Supplier Name',
                    'Supplier Name',
                    'Supplier Name',
                  ],
                  values: [220, 300, 205, 320, 190],
                  barAlignment: BarChartAlignment.start,
                  groupsSpace: 100.sp,
                  needWidget: Row(
                    children: [
                      SizedBox(
                        width: 110.sp,
                        child: CustomDropdown<String>(
                          items: (selectStatusList)
                              .map((e) => DropdownItem<String>(
                                  value: e['key'] ?? '',
                                  label: e['value'] ?? ''))
                              .toList(),
                          value: selectStatus,
                          onChanged: (val) {
                            setState(() {
                              selectStatus = val;
                            });
                          },
                          hint: S.of(context).status,
                          height: 30.sp,
                        ),
                      ),
                      SizedBox(width: 10.sp),
                      SizedBox(
                        width: 110.sp,
                        child: CustomDropdown<String>(
                          items: (selectProductTypeList)
                              .map((e) => DropdownItem<String>(
                                  value: e['key'] ?? '',
                                  label: e['value'] ?? ''))
                              .toList(),
                          value: selectProductType,
                          onChanged: (val) {
                            setState(() {
                              selectProductType = val;
                            });
                          },
                          hint: S.of(context).productType,
                          height: 30.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildVerticalCustomBarChart({
    required BuildContext context,
    required bool lightMode,
    required String title,
    required List<String> labels,
    required List<double> values,
    Widget? needWidget,
    double maxY = 400,
    double height = 250,
    Color? barColor,
    BarChartAlignment barAlignment = BarChartAlignment.spaceAround, // ✅ New
    double groupsSpace = 30, // ✅ NEW PARAM
  }) {
    return Container(
      margin: EdgeInsets.only(top: 20.sp),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 26.sp,
                    height: 26.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 8.sp),
                  Text(
                    title,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: lightMode ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [if (needWidget != null) needWidget],
          ),

          SizedBox(height: 40.sp),

          // Chart
          SizedBox(
            height: height.sp,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: barAlignment,
                groupsSpace: groupsSpace.sp,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 100,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: lightMode
                          ? const Color(0xffEFF3F9)
                          : Colors.grey.shade800,
                      strokeWidth: 1,
                    );
                  },
                ),
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 0.sp,
                    getTooltipColor: (_) => Colors.transparent,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.toInt().toString(),
                        StyleText.fontSize12Weight500.copyWith(
                          color: AppColors.blackButton,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 100,
                      reservedSize: 35.sp,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameSize: 24.sp,
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < labels.length) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 0.sp),
                            child: SizedBox(
                              width: 150.sp,
                              child: Text(
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                labels[index],
                                style: StyleText.fontSize12Weight400.copyWith(
                                  color: AppColors.blackButton,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(values.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barsSpace: 200.sp,
                    barRods: [
                      BarChartRodData(
                        toY: values[index],
                        width: 30.sp,
                        borderRadius: BorderRadius.circular(6.r),
                        color: barColor ?? AppColors.primary,
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHorizontalInventoryChart({
    required BuildContext context,
    required bool lightMode,
    required String title,
    required List<String> labels,
    required List<double> values,
    required double maxValue,
    Widget? needWidget,
    Color? barColor,
    Color? backgroundColor,
    List<String>? axisLabels,
    List<Color>? barColors,
  }) {
    final Color defaultBackgroundColor = AppColors.card;
    final Color defaultBarColor = barColor ?? AppColors.primary;

    return Container(
      margin: EdgeInsets.only(top: 20.sp),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBackgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Title Row
          Row(
            children: [
              Container(
                width: 26.sp,
                height: 26.sp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 8.sp),
              Text(
                title,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: lightMode ? Colors.black : Colors.white,
                ),
              ),
              Spacer(),
              if (needWidget != null) needWidget,
            ],
          ),

          SizedBox(height: 20.sp),

          /// 🔹 Horizontal Bars
          Column(
            children: List.generate(labels.length, (index) {
              final label = labels[index];
              final value = values[index];
              final percent = (value / maxValue).clamp(0, 1.0);
              final Color currentBarColor =
                  (barColors != null && index < barColors.length)
                      ? barColors[index]
                      : defaultBarColor;

              return Padding(
                padding: EdgeInsets.only(bottom: 20.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔸 Label & Value
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: StyleText.fontSize12Weight400.copyWith(
                            color: AppColors.blackButton,
                          ),
                        ),
                        Text(
                          value.toInt().toString(),
                          style: StyleText.fontSize12Weight400.copyWith(
                            color: AppColors.blackButton,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.sp),

                    /// 🔸 Bar
                    Stack(
                      children: [
                        Container(
                          height: 20.sp,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5FF),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: percent.toDouble(),
                          child: Container(
                            height: 20.sp,
                            decoration: BoxDecoration(
                              color: currentBarColor,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),

          /// 🔹 Bottom Axis
          Padding(
            padding: EdgeInsets.only(top: 10.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  (axisLabels ?? const ["0", "50K", "100K", "200K", "300K"])
                      .map((label) {
                return Text(
                  label,
                  style: StyleText.fontSize10Weight400.copyWith(
                    color: AppColors.blackButton,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHorizontalInventoryChartFinal(
    BuildContext context,
    bool lightMode,
  ) {
    const List<String> quarters = [
      'Quarter 1',
      'Quarter 2',
      'Quarter 3',
      'Quarter 4',
    ];
    const List<double> values = [355, 110, 53, 11];
    const double maxValue = 400;

    return Container(
      margin: EdgeInsets.only(top: 20.sp),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: lightMode ? Colors.white : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Title
          Row(
            children: [
              Container(
                width: 26.sp,
                height: 26.sp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 8.sp),
              Text(
                'Inventory Valuation',
                style: StyleText.fontSize14Weight500.copyWith(
                  color: lightMode ? Colors.black : Colors.white,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.sp),

          /// 🔹 Bar Rows
          Column(
            children: List.generate(quarters.length, (index) {
              final label = quarters[index];
              final value = values[index];
              final percent = (value / maxValue).clamp(0, 1.0);

              return Padding(
                padding: EdgeInsets.only(bottom: 20.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🟡 Title & Value (Above bar)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: StyleText.fontSize12Weight400.copyWith(
                            color: lightMode ? Colors.black : Colors.white,
                          ),
                        ),
                        Text(
                          value.toInt().toString(),
                          style: StyleText.fontSize12Weight400.copyWith(
                            color: lightMode ? Colors.black : Colors.white,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.sp),

                    /// 📊 Bar (Below title/value)
                    Stack(
                      children: [
                        Container(
                          height: 20.sp,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5FF),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: percent.toDouble(),
                          child: Container(
                            height: 20.sp,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),

          /// 🔹 Bottom Axis
          Padding(
            padding: EdgeInsets.only(top: 10.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("0"),
                Text("50K"),
                Text("100K"),
                Text("200K"),
                Text("300K"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int index, int value) {
    Color color;
    if (index == 0 || index == 3) {
      color = Color(0xFFFF914D); // Orange
    } else if (index == 1 || index == 2) {
      color = Color(0xFF45C43C); // Green
    } else {
      color = Color(0xFFD61F1F); // Red
    }

    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: value.toDouble(),
          color: color,
          // Bar Width
          width: 40.sp,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }
}

class DashboardInfoItem extends StatelessWidget {
  final String assetPath;
  final String label;
  final String value;
  final Color iconColor;
  final Color labelColor;
  final Color valueColor;

  const DashboardInfoItem({
    super.key,
    required this.assetPath,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomSvgImage(
          color: iconColor,
          assetPath: assetPath,
          width: 45.sp,
          height: 45.sp,
          fit: BoxFit.scaleDown,
        ),
        SizedBox(width: 10.sp),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: StyleText.fontSize15Weight600.copyWith(color: labelColor),
            ),
            Text(
              value,
              style: StyleText.fontSize20Weight600.copyWith(color: valueColor),
            ),
          ],
        ),
      ],
    );
  }
}

class _PieChartWithLabels extends StatelessWidget {
  final String title;
  final String total;
  final String icon;
  final List<(String, Color, double)> data;
  final List<String> numberList;

  const _PieChartWithLabels({
    required this.title,
    required this.total,
    required this.icon,
    required this.data,
    required this.numberList,
  });

  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isPhone;

    final int itemCount = data.length;
    final double labelRowHeight = 26.sp;
    final double itemRowHeight = 19.sp;
    final double itemSpacing = 5.sp;
    final double topPadding = 10.sp;
    final double pieChartHeight = 120.sp;
    final double bottomPadding = 10.sp;

    final double minHeight =
        labelRowHeight + topPadding + 30.sp + bottomPadding + pieChartHeight;

    final double calculatedHeight = labelRowHeight +
        topPadding +
        bottomPadding +
        (itemCount * (itemRowHeight + itemSpacing));

    return Container(
      height: isMobile ? min(max(calculatedHeight, minHeight), 220.sp) : 260.sp,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7.r),
        color: AppColors.card,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 10.sp,
          right: 10.sp,
          top: topPadding,
          bottom: bottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔷 Icon + Title
            Row(
              children: [
                Container(
                  width: labelRowHeight,
                  height: labelRowHeight,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: Center(
                    child: CustomSvgImage.natural(
                      assetPath: icon,
                      width: 16.sp,
                      height: 16.sp,
                      fit: BoxFit.scaleDown,
                      color: AppColors.textButton,
                    ),
                  ),
                ),
                SizedBox(width: 7.w),
                Text(
                  title,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.sp),

            // 🔷 Main Content Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 Labels
                Expanded(
                  flex: 3,
                  child: Column(
                    spacing: 5.sp,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data
                        .map(
                          (e) => FittedBox(
                            child: Row(
                              children: [
                                Container(
                                  width: 14.sp,
                                  height: 14.sp,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: e.$2,
                                  ),
                                ),
                                SizedBox(width: 6.sp),
                                Container(
                                  color: Colors.red,
                                  child: Text(
                                    e.$1,
                                    style:
                                        StyleText.fontSize12Weight400.copyWith(
                                      color: Theme.of(
                                                context,
                                              ).brightness ==
                                              Brightness.light
                                          ? AppColors.blackButton
                                          : AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

                SizedBox(width: 30.sp),

                // 🔹 Numbers
                Expanded(
                  child: Column(
                    spacing: 5.sp,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: numberList
                        .map(
                          (number) => Container(
                            color: Colors.yellow,
                            child: Text(
                              number,
                              style: StyleText.fontSize12Weight500.copyWith(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? AppColors.header
                                    : AppColors.white,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

                // 🔹 Pie Chart
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: pieChartHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius:
                                !isTabletLandscape(context) ? 35.r : 50.r,
                            sections: data
                                .map(
                                  (e) => PieChartSectionData(
                                    value: e.$3,
                                    color: e.$2,
                                    radius: 24.r,
                                    title: "",
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              total,
                              style: StyleText.fontSize16Weight700.copyWith(
                                color: AppColors.blackButton,
                              ),
                            ),
                            Text(
                              S.of(context).total,
                              style: StyleText.fontSize12Weight400.copyWith(
                                color: AppColors.blackButton,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

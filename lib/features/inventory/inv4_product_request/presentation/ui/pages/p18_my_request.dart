import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv4_product_request/presentation/ui/pages/p15_product_request_toogel.dart';
import 'package:knowticed_plus/features/inventory/inv4_product_request/presentation/ui/pages/p18_1_my_request_details_toogel.dart';
import 'package:knowticed_plus/features/inventory/inv4_product_request/presentation/ui/pages/p19_create_new_request_toogel.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_tabs.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class MyRequestDesktopScreen extends StatefulWidget {
  const MyRequestDesktopScreen({super.key});

  @override
  State<MyRequestDesktopScreen> createState() => _MyRequestDesktopScreenState();
}

class _MyRequestDesktopScreenState extends State<MyRequestDesktopScreen> {
  /////////////////////////////////// var ////////////////////////////////////////////
  String selectedType = 'Asset';

  /////////////////////////////////// var ////////////////////////////////////////////

  final TextEditingController _searchController = TextEditingController();
  bool isGridViewChoose = true;
  String? selectedReceivingMethod;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> selectedReceivingMethodList = [
      {"key": "Urgent", "value": S.of(context).priorityUrgent},
      {"key": "High", "value": S.of(context).priorityHigh},
      {"key": "Medium", "value": S.of(context).priorityMedium},
      {"key": "Low", "value": S.of(context).priorityLow},
    ];
    var lightMode = Theme.of(context).brightness == Brightness.light;
    Localizations.localeOf(context).languageCode == 'ar';
    Localizations.localeOf(context).languageCode == 'en';
    final isMobile = context.isPhone;
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventoryManagement,
          onFirstTap: () {
            Navigator.pop(context);
          },
          secondTitle: S.of(context).productRequests,
          onSecondTap: () {
            navigateTo(context, ProductRequest());
          },
          thirdTitle: S.of(context).myRequest,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                // Assets & Consumable
                Row(
                  children: [
                    CustomTabs(
                      tabs: const ['Asset', 'Consumable'],
                      selectedValue:
                          (const ['Asset', 'Consumable']).indexOf(selectedType),
                      onChanged: (index) => ((val) {
                        setState(() {
                          selectedType = val;
                        });
                      })((const ['Asset', 'Consumable'])[index]),
                    ),
                  ],
                ),

                // space
                SizedBox(height: 15.sp),

                // Filter Section
                SizedBox(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      textDirection: ui.TextDirection.ltr,
                      children: [filterSection(context)],
                    ),
                  ),
                ),

                // space
                SizedBox(height: 20.sp),

                // Search & Request
                Row(
                  children: [
                    // Search
                    Expanded(
                      flex: 7,
                      child: SizedBox(
                        height: 38.sp,
                        child: AppSearchTextField(
                          controller: _searchController,
                          expanded: false,
                        ),
                      ),
                    ),

                    // space
                    SizedBox(width: ButtonSizing.toolbarGap(context)),

                    // Add Request Button
                    customButtonWithSvg(
                      title: isMobile ? "" : S.of(context).request,
                      function: () {
                        navigateTo(context, CreateNewRequest());
                      },
                      // 22/10/2026 — Owner: toolbar text is 14 in every module (was 16).
                      textStyle: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      width: isMobile ? 38.sp : 110.sp,
                      height: 38.sp,
                      space: 8.sp,
                      radius: 4.r,
                      color: AppColors.primary,
                      svgColor: AppColors.textButton,
                      image: isMobile
                          ? "assets/icons_assets/main_icons_assets/ic_data_inventory_assets.svg"
                          : "assets/icons_assets/main_icons_assets/ic_action_plus.svg",
                      widthImage: 16.sp,
                      heightImage: 16.sp,
                      colorBorder: Colors.transparent,
                    ),
                  ],
                ),

                //space
                SizedBox(height: 15.sp),

                //  Filter page and three icon (grid & table)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // All
                    isMobile
                        ? requestTypeDropdown(selectedReceivingMethodList)
                        : Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  HapticController
                                      .low(); // list row: on the tap (X-117)
                                  setState(() {
                                    selectFilterProduct = "all";
                                  });
                                },
                                child: filterProduct(
                                  context: context,
                                  label: S.of(context).all,
                                  isSelected: selectFilterProduct == "all",
                                  colorLabel: AppColors.blackButton,
                                ),
                              ),
                              // space
                              SizedBox(width: 10.sp),
                              // New
                              GestureDetector(
                                onTap: () {
                                  HapticController
                                      .low(); // list row: on the tap (X-117)
                                  setState(() {
                                    selectFilterProduct = "New";
                                  });
                                },
                                child: filterProduct(
                                  context: context,
                                  label: S.of(context).inStock,
                                  isSelected: selectFilterProduct == "New",
                                  colorLabel: Color(0xff4BB609),
                                ),
                              ),

                              // space
                              SizedBox(width: 10.sp),
                              // Returned
                              GestureDetector(
                                onTap: () {
                                  HapticController
                                      .low(); // list row: on the tap (X-117)
                                  setState(() {
                                    selectFilterProduct = "Returned";
                                  });
                                },
                                child: filterProduct(
                                  context: context,
                                  label: S.of(context).returned,
                                  isSelected: selectFilterProduct == "Returned",
                                  colorLabel: Color(0xffDF1C1C),
                                ),
                              ),
                              // space
                              SizedBox(width: 10.sp),
                              //Missing
                              GestureDetector(
                                onTap: () {
                                  HapticController
                                      .low(); // list row: on the tap (X-117)
                                  setState(() {
                                    selectFilterProduct = "Missing";
                                  });
                                },
                                child: filterProduct(
                                  context: context,
                                  label: S.of(context).missing,
                                  isSelected: selectFilterProduct == "Missing",
                                  colorLabel: Color(0xff797979),
                                ),
                              ),
                              // space
                              SizedBox(width: 10.sp),
                              //Stolen
                              GestureDetector(
                                onTap: () {
                                  HapticController
                                      .low(); // list row: on the tap (X-117)
                                  setState(() {
                                    selectFilterProduct = "Stolen";
                                  });
                                },
                                child: filterProduct(
                                  context: context,
                                  label: S.of(context).stolen,
                                  isSelected: selectFilterProduct == "Stolen",
                                  colorLabel: Color(0xff797979),
                                ),
                              ),
                            ],
                          ),

                    Spacer(),

                    isMobile
                        ? Container(
                            width: 38.sp,
                            height: 38.sp,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: CustomSvgImage.natural(
                                assetPath:
                                    "assets/icons_assets/main_icons_assets/ic_upload.svg",
                                width: 24.sp,
                                height: 24.sp,
                                fit: BoxFit.fill,
                                semanticsLabel: 'Table View',
                                color: AppColors.textButton,
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              // Table View
                              GestureDetector(
                                onTap: () => setState(() =>
                                    isGridViewChoose = withLowHaptic(false)),
                                child: Container(
                                  width: 38.sp,
                                  height: 38.sp,
                                  decoration: BoxDecoration(
                                    color: !isGridViewChoose
                                        ? AppColors
                                            .primary // selected background
                                        : AppColors.card,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Center(
                                    child: CustomSvgImage.natural(
                                      assetPath:
                                          "assets/icons_assets/main_icons_assets/ic_list_lines.svg",
                                      width: 20.sp,
                                      height: 20.sp,
                                      fit: BoxFit.scaleDown,
                                      semanticsLabel: 'Table View',
                                      color: !isGridViewChoose
                                          ? AppColors
                                              .textButton // selected icon
                                          : Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors
                                                  .black // unselected, light mode
                                              : Colors
                                                  .white, // unselected, dark mode
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15.sp),
                              // Grid View
                              GestureDetector(
                                onTap: () => setState(() =>
                                    isGridViewChoose = withLowHaptic(true)),
                                child: Container(
                                  width: 38.sp,
                                  height: 38.sp,
                                  decoration: BoxDecoration(
                                    color: isGridViewChoose
                                        ? AppColors.primary
                                        : AppColors.card,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Center(
                                    child: CustomSvgImage.natural(
                                      assetPath:
                                          "assets/icons_assets/main_icons_assets/ic_nav_grid.svg",
                                      width: 20.sp,
                                      height: 20.sp,
                                      fit: BoxFit.scaleDown,
                                      semanticsLabel: 'Grid View',
                                      color: isGridViewChoose
                                          ? AppColors
                                              .textButton // selected icon
                                          : Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors
                                                  .black // unselected, light mode
                                              : Colors
                                                  .white, // unselected, dark mode
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),

                // Space
                SizedBox(height: 15.sp),

                BounceSwitcher(
                  // Bounce when switching list <-> grid view.
                  triggerValue: isGridViewChoose,
                  child: // GridView of product
                      SizedBox(
                    //height: MediaQuery.sizeOf(context).height*.5, // adjust based on your UI
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: CrossAxisCountHelper
                            .getCrossAxisCountForDefaultTablet2(
                          context,
                        ),
                        crossAxisSpacing: 15.sp,
                        mainAxisSpacing: 15.sp,
                        mainAxisExtent: 238.sp,
                      ),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            navigateTo(context, MyRequestDetails());
                          },
                          child: Container(
                            width: 289.sp,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 10.sp,
                                right: 10.sp,
                                left: 10.sp,
                                bottom: 10.sp,
                              ),
                              child: Column(
                                children: [
                                  // Date Requested:
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      itemTextProduct(
                                        label:
                                            "${S.of(context).dateRequested}: ",
                                        imagePath: "",
                                        labelStyle: StyleText
                                            .fontSize10Weight400
                                            .copyWith(
                                          color: AppColors.secondaryText,
                                        ),
                                        value: "15 Oct 2024",
                                        valueStyle: StyleText
                                            .fontSize10Weight400
                                            .copyWith(
                                          color: AppColors.blackButton,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // image & Name of Assets
                                  Row(
                                    children: [
                                      // image
                                      Container(
                                        width: 50.sp,
                                        height: 50.sp,
                                        decoration: BoxDecoration(
                                          color: lightMode
                                              ? AppColors.grey
                                              : AppColors.background,
                                          borderRadius: BorderRadius.circular(
                                            4.r,
                                          ),
                                        ),
                                        child: CustomSvgImage(
                                          assetPath:
                                              "assets/icons_assets/main_icons_assets/ic_data_inventory_assets.svg",
                                          fit: BoxFit.scaleDown,
                                          width: 38.sp,
                                          height: 31.sp,
                                        ),
                                      ),
                                      // space
                                      SizedBox(width: 5.sp),
                                      // Name of Assets
                                      Text(
                                        "Name Of Asset",
                                        style: StyleText.fontSize16Weight500
                                            .copyWith(
                                          color: AppColors.blackButton,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // space
                                  SizedBox(height: 9.sp),
                                  itemTextProduct(
                                    label: "${S.of(context).requestType}: ",
                                    value: "New Asset",
                                    imagePath:
                                        "assets/icons_assets/main_icons_assets/ic_category.svg",
                                  ),
                                  //space
                                  SizedBox(height: 8.sp),
                                  itemTextProduct(
                                    label: "${S.of(context).priority}: ",
                                    value: "High",
                                    imagePath:
                                        "assets/icons_assets/main_icons_assets/ic_status_priority_medium.svg",
                                  ),
                                  //space
                                  SizedBox(height: 8.sp),
                                  itemTextProduct(
                                    label: "${S.of(context).quantity}: ",
                                    value: "10",
                                    imagePath:
                                        "assets/icons_assets/main_icons_assets/ic_hash.svg",
                                  ),
                                  //space
                                  SizedBox(height: 8.sp),
                                  itemTextProduct(
                                    label:
                                        "${S.of(context).expectedDelivery}: ",
                                    value: "15 Oct 2024",
                                    imagePath:
                                        "assets/icons_assets/main_icons_assets/ic_status_todo_scheduled.svg",
                                  ),
                                  //space
                                  SizedBox(height: 8.sp),
                                  itemTextProduct(
                                    label: "${S.of(context).expectedReturn}: ",
                                    value: "15 Oct 2024",
                                    imagePath:
                                        "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
                                  ),
                                  //space
                                  SizedBox(height: 8.sp),
                                  itemTextProduct(
                                    label: "${S.of(context).status}: ",
                                    value: "Approved",
                                    imagePath:
                                        "assets/icons_assets/main_icons_assets/ic_status.svg",
                                    valueStyle: StyleText.fontSize12Weight400
                                        .copyWith(color: Color(0xff4BB609)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /////////////////////////// ListView Item Text /////////////////////////////////////////////////////////

  Widget itemTextProduct({
    required String label,
    required String value,
    TextStyle? labelStyle,
    required String imagePath,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomSvgImage(
          assetPath: imagePath,
          fit: BoxFit.scaleDown,
          width: 13.sp,
          height: 13.sp,
        ),

        // space
        SizedBox(width: 5.sp),

        Text(
          FormatHelper.capitalize(label),
          style: labelStyle ??
              StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
        ),
        Text(
          FormatHelper.capitalize(value),
          style: valueStyle ??
              StyleText.fontSize12Weight400.copyWith(
                color: AppColors.blackButton,
              ),
        ),
      ],
    );
  }

  Widget requestTypeDropdown(List<Map<String, String>> selectedPriorityList) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return SizedBox(
      width: 111.sp,
      child: CustomDropdown<String>(
        items: (selectedPriorityList)
            .map((e) => DropdownItem<String>(
                value: e['key'] ?? '', label: e['value'] ?? ''))
            .toList(),
        value: selectedReceivingMethod,
        onChanged: (value) {
          setState(() {
            selectedReceivingMethod = value;
          });
        },
        hint: S.of(context).requestType,
        height: 36.sp,
        fillColor: lightMode ? AppColors.white : AppColors.background,
      ),
    );
  }

  /////////////////////////// ListView Item Text /////////////////////////////////////////////////////////

  //////////////////////////// Filter Product ////////////////////////////////////////////////////////////

  String selectFilterProduct = "all"; // Default selected chip
  Widget filterProduct({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required Color colorLabel,
  }) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      height: 28.sp,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary
            : isLight
                ? AppColors.white
                : AppColors.chatBackground,
        borderRadius: BorderRadius.circular(4.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
      child: Center(
        child: Text(
          label,
          style: StyleText.fontSize14Weight400.copyWith(color: colorLabel),
        ),
      ),
    );
  }

  //////////////////////////// Filter Product ////////////////////////////////////////////////////////////

  /////////////////////////// Filter //////////////////////////////////

  String selectedLabel = "All"; // Default selected chip

  Widget filterSection(BuildContext context) {
    final Map<String, String> filterItems = {
      "All": S.of(context).all,
      "Approved": S.of(context).approved,
      "Pending": S.of(context).pending,
      "Rejected": S.of(context).rejected,
      "Canceled": S.of(context).canceled,
    };

    final Map<String, String> filterCounts = {
      "All": "14",
      "Approved": "5",
      "Pending": "5",
      "Rejected": "5",
      "Canceled": "5",
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filterItems.entries.map((entry) {
          final key = entry.key;
          final label = entry.value;
          final count = filterCounts[key] ?? "0";
          return _statusChip(
            count,
            key,
            label,
            context,
          ); // ✅ Now passes all required arguments
        }).toList(),
      ),
    );
  }

  Widget _statusChip(
    String count,
    String key,
    String label,
    BuildContext context,
  ) {
    bool isSelected = key == selectedLabel;
    bool isLight = Theme.of(context).brightness == Brightness.light;
    final isMobile = context.isPhone;
    // Custom colors for each status
    final statusColors = {
      "Approved": const Color(0xFF4BB609),
      "Pending": const Color(0xFFFF814A),
      "Rejected": const Color(0xFFDF1C1C),
      "Canceled": const Color(0xFFBA1B1B),
      "All": isLight ? AppColors.blackButton : AppColors.white,
    };

    final Color textColor = statusColors[key] ??
        (isLight ? AppColors.secondaryText : AppColors.grey);

    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () {
        setState(() {
          selectedLabel = key;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Count circle
          Container(
            width: isMobile ? 35.sp : 45.sp,
            height: isMobile ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isLight ? AppColors.white : AppColors.chatBackground),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                count,
                style: isMobile
                    // 22/10/2026 — Owner (phone): count chips match Notifications — box 35, number 14/400, label 14/600.
                    ? StyleText.fontSize14Weight400.copyWith(
                        color: isSelected
                            ? AppColors.textButton
                            : isLight
                                ? AppColors.secondaryText
                                : AppColors.grey,
                      )
                    : StyleText.fontSize20Weight500.copyWith(
                        color: isSelected
                            ? AppColors.textButton
                            : isLight
                                ? AppColors.secondaryText
                                : AppColors.grey,
                      ),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          // Status label
          Text(
            FormatHelper.capitalize(label),
            style: (isMobile
                    ? StyleText.fontSize14Weight600
                    : StyleText.fontSize16Weight600)
                .copyWith(
              color: textColor, // ✅ Always use status-based color
            ),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }

  /////////////////////////// Filter //////////////////////////////////
}

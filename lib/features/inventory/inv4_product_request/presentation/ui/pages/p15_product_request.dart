import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/inventory/inv4_product_request/presentation/ui/widgets/p15_product_request/table.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv2_view_product/presentation/ui/pages/product_details_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv4_product_request/presentation/ui/pages/p16_add_new_asset_or_consumable_toogel.dart';
import 'package:knowticed_plus/features/inventory/inv4_product_request/presentation/ui/pages/p18_my_request.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class ProductRequestDesktopScreen extends StatefulWidget {
  const ProductRequestDesktopScreen({super.key});

  @override
  State<ProductRequestDesktopScreen> createState() =>
      _ProductRequestDesktopScreenState();
}

class _ProductRequestDesktopScreenState
    extends State<ProductRequestDesktopScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isGridViewChoose = true;

  final List<Map<String, dynamic>> tableData = [
    {
      'assetId': 'A001',
      'assetName': {'en': 'Laptop Dell', 'ar': 'لاب توب ديل'},
      'category': {'en': 'Electronics', 'ar': 'إلكترونيات'},
      'subcategory': {'en': 'Computers', 'ar': 'أجهزة كمبيوتر'},
      'model': 'Latitude 5420',
      'brand': 'Dell',
      'receivedDate': '2023-01-15',
      'returnDate': '2023-12-20',
      'quantity': 5,
      'maintenanceFrequency': 'Quarterly',
      'nextScheduledDate': '2024-04-15',
      'expectedLifetime': '3 Years',
      'status': {'en': 'Returned', 'ar': 'تم الإرجاع'},
    },
    {
      'assetId': 'A002',
      'assetName': {'en': 'Printer HP', 'ar': 'طابعة HP'},
      'category': {'en': 'Accessories', 'ar': 'ملحقات'},
      'subcategory': {'en': 'Printers', 'ar': 'الطابعات'},
      'model': 'LaserJet Pro',
      'brand': 'HP',
      'receivedDate': '2022-10-10',
      'returnDate': '2023-09-15',
      'quantity': 2,
      'maintenanceFrequency': 'Yearly',
      'nextScheduledDate': '2025-10-10',
      'expectedLifetime': '5 Years',
      'status': {'en': 'In Use', 'ar': 'قيد الاستخدام'},
    },
    {
      'assetId': 'A003',
      'assetName': {'en': 'Cisco Router', 'ar': 'راوتر سيسكو'},
      'category': {'en': 'Networking', 'ar': 'شبكات'},
      'subcategory': {'en': 'Routers', 'ar': 'راوترات'},
      'model': 'RV340',
      'brand': 'Cisco',
      'receivedDate': '2021-06-01',
      'returnDate': '2024-06-01',
      'quantity': 1,
      'maintenanceFrequency': 'Semi-Annual',
      'nextScheduledDate': '2024-12-01',
      'expectedLifetime': '6 Years',
      'status': {'en': 'Available', 'ar': 'متاح'},
    },
    {
      'assetId': 'A004',
      'assetName': {'en': 'Projector Epson', 'ar': 'بروجيكتور إبسون'},
      'category': {'en': 'AV Equipment', 'ar': 'معدات صوتية بصرية'},
      'subcategory': {'en': 'Projectors', 'ar': 'بروجيكتورات'},
      'model': 'EB-E10',
      'brand': 'Epson',
      'receivedDate': '2023-03-01',
      'returnDate': '2024-03-01',
      'quantity': 3,
      'maintenanceFrequency': 'Monthly',
      'nextScheduledDate': '2024-07-01',
      'expectedLifetime': '4 Years',
      'status': {'en': 'In Maintenance', 'ar': 'قيد الصيانة'},
    },
    {
      'assetId': 'A005',
      'assetName': {'en': 'iMac', 'ar': 'آي ماك'},
      'category': {'en': 'Computers', 'ar': 'أجهزة كمبيوتر'},
      'subcategory': {'en': 'Desktops', 'ar': 'أجهزة مكتبية'},
      'model': 'iMac M1',
      'brand': 'Apple',
      'receivedDate': '2023-07-10',
      'returnDate': '2026-07-10',
      'quantity': 1,
      'maintenanceFrequency': 'Annually',
      'nextScheduledDate': '2025-07-10',
      'expectedLifetime': '7 Years',
      'status': {'en': 'Damaged', 'ar': 'تالف'},
    },
  ];

  @override
  Widget build(BuildContext context) {
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
          secondTitle: S.of(context).productDetails,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                isMobile
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [myRequestButton()],
                      )
                    : SizedBox(),

                SizedBox(height: 15.sp),

                // Filter Widget & My Request
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    filterSection(context),
                    Spacer(),
                    isMobile ? SizedBox() : myRequestButton(),
                  ],
                ),

                // space
                SizedBox(height: 15.sp),

                // Search and filter and Add Product
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

                    // Filter
                    customButtonWithSvg(
                      width: isMobile ? 38.sp : 100.sp,
                      title: isMobile ? "" : S.of(context).filter,
                      function: () {},
                      // 22/10/2026 — Owner: toolbar text is 14 in every module (was 16).
                      textStyle: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      height: 38.sp,
                      space: 8.sp,
                      radius: 8.r,
                      svgColor: AppColors.secondaryText,
                      color: AppColors.card,
                      image:
                          "assets/icons_assets/main_icons_assets/ic_action_filter.svg",
                      widthImage: 20.sp,
                      heightImage: 20.sp,
                      colorBorder: Colors.transparent,
                    ),
                    // space
                    SizedBox(width: ButtonSizing.toolbarGap(context)),

                    // Add Product
                    customButtonWithSvg(
                      title: isMobile
                          ? ""
                          : selectedLabel == 'Assets'
                              ? S.of(context).assets
                              : S.of(context).consumables,
                      function: () {
                        selectedLabel == 'Assets'
                            ? navigateTo(
                                context,
                                AddNewAssetsOrConsumable(type: "Assets"),
                              )
                            : navigateTo(context, widget);
                      },
                      // 22/10/2026 — Owner: toolbar text is 14 in every module (was 16).
                      textStyle: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      height: 38.sp,
                      width: isMobile
                          ? 38.sp
                          : selectedLabel == "Assets"
                              ? 100.sp
                              : 135.sp,
                      space: 8.sp,
                      radius: 8.r,
                      color: AppColors.primary,
                      svgColor: AppColors.textButton,
                      image:
                          "assets/icons_assets/main_icons_assets/ic_data_inventory_assets.svg",
                      widthImage: 20.sp,
                      heightImage: 20.sp,
                      colorBorder: Colors.transparent,
                    ),
                  ],
                ),

                // space
                SizedBox(height: 10.sp),
                //  Filter page and three icon (grid & table & bulk Upload)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticController.low(); // list row: on the tap (X-117)
                        setState(() {
                          selectFilterProduct = "all";
                        });
                      },
                      child: filterProduct(
                        context: context,
                        label: S.of(context).all,
                        isSelected: selectFilterProduct == "all",
                        colorLabel: AppColors.textButton,
                      ),
                    ),
                    SizedBox(width: 10.sp),
                    GestureDetector(
                      onTap: () {
                        HapticController.low(); // list row: on the tap (X-117)
                        setState(() {
                          selectFilterProduct = "In Use";
                        });
                      },
                      child: filterProduct(
                        context: context,
                        label: S.of(context).inUse,
                        isSelected: selectFilterProduct == "In Use",
                        colorLabel: AppColors.lightGreen,
                      ),
                    ),
                    SizedBox(width: 10.sp),
                    GestureDetector(
                      onTap: () {
                        HapticController.low(); // list row: on the tap (X-117)
                        setState(() {
                          selectFilterProduct = "Maintenance";
                        });
                      },
                      child: filterProduct(
                        context: context,
                        label: S.of(context).maintenance,
                        isSelected: selectFilterProduct == "Maintenance",
                        colorLabel: AppColors.red,
                      ),
                    ),
                    SizedBox(width: 10.sp),
                    GestureDetector(
                      onTap: () {
                        HapticController.low(); // list row: on the tap (X-117)
                        setState(() {
                          selectFilterProduct = "Returned";
                        });
                      },
                      child: filterProduct(
                        context: context,
                        label: S.of(context).returned,
                        isSelected: selectFilterProduct == "Returned",
                        colorLabel: AppColors.secondaryPrimary,
                      ),
                    ),

                    Spacer(),

                    // Export
                    exportButton(),

                    isMobile ? SizedBox() : SizedBox(width: 18.sp),

                    // Table View
                    isMobile
                        ? SizedBox()
                        : GestureDetector(
                            onTap: () => setState(
                                () => isGridViewChoose = withLowHaptic(false)),
                            child: Container(
                              width: 38.sp,
                              height: 38.sp,
                              decoration: BoxDecoration(
                                color: !isGridViewChoose
                                    ? AppColors.primary // selected background
                                    : AppColors.card,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: CustomSvgImage.natural(
                                assetPath:
                                    "assets/icons_assets/main_icons_assets/ic_list_lines.svg",
                                width: 20.sp,
                                height: 20.sp,
                                fit: BoxFit.scaleDown,
                                semanticsLabel: 'Table View',
                                color: !isGridViewChoose
                                    ? AppColors.textButton // selected icon
                                    : Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.black // unselected, light mode
                                        : Colors.white, // unselected, dark mode
                              ),
                            ),
                          ),
                    isMobile ? SizedBox() : SizedBox(width: 15.sp),

                    // Grid View
                    isMobile
                        ? SizedBox()
                        : GestureDetector(
                            onTap: () => setState(
                                () => isGridViewChoose = withLowHaptic(true)),
                            child: Container(
                              width: 38.sp,
                              height: 38.sp,
                              decoration: BoxDecoration(
                                color: isGridViewChoose
                                    ? AppColors.primary
                                    : AppColors.card,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: CustomSvgImage.natural(
                                assetPath:
                                    "assets/icons_assets/main_icons_assets/ic_nav_grid.svg",
                                width: 20.sp,
                                height: 20.sp,
                                fit: BoxFit.scaleDown,
                                semanticsLabel: 'Grid View',
                                color: isGridViewChoose
                                    ? AppColors.textButton // selected icon
                                    : Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.black // unselected, light mode
                                        : Colors.white, // unselected, dark mode
                              ),
                            ),
                          ),
                  ],
                ),

                // space
                SizedBox(height: 20.sp),

                // GridView of product
                BounceSwitcher(
                  // Bounce when switching list <-> grid view.
                  triggerValue: isGridViewChoose,
                  child: isGridViewChoose
                      ? SizedBox(
                          //  height: MediaQuery.sizeOf(context).height*.5, // adjust based on your UI
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: CrossAxisCountHelper
                                  .getCrossAxisCountForDefaultTablet2(
                                context,
                              ),
                              crossAxisSpacing: 15.sp,
                              mainAxisSpacing: 15.sp,
                              mainAxisExtent: 107.sp,
                            ),
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  navigateTo(context, ViewProductDetails());
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
                                        // Image and Info
                                        Stack(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                //  image
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // image
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          4.r,
                                                        ),
                                                        color: lightMode
                                                            ? AppColors.grey
                                                            : AppColors
                                                                .background,
                                                      ),
                                                      width: 50.sp,
                                                      height: 50.sp,
                                                      child: CustomSvgImage(
                                                        assetPath:
                                                            "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
                                                        color: lightMode
                                                            ? AppColors
                                                                .blackButton
                                                            : AppColors.white,
                                                        fit: BoxFit.scaleDown,
                                                        height: 30.sp,
                                                        width: 34.sp,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                //space
                                                SizedBox(width: 5.sp),
                                                // info product
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    itemTextProduct(
                                                      value: "011",
                                                      label:
                                                          "${S.of(context).assetId}: ",
                                                    ),
                                                    SizedBox(height: 3.sp),
                                                    itemTextProduct(
                                                      value: "1",
                                                      label:
                                                          "${S.of(context).quantity}: ",
                                                    ),
                                                    SizedBox(height: 3.sp),
                                                    itemTextProduct(
                                                      value: "Quarter",
                                                      label:
                                                          "${S.of(context).maintenanceFrequency}: ",
                                                    ),
                                                  ],
                                                ),

                                                Spacer(),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${S.of(context).status}: ",
                                                      style: StyleText
                                                          .fontSize8Weight400
                                                          .copyWith(
                                                        color: lightMode
                                                            ? AppColors
                                                                .secondaryText
                                                            : AppColors.grey,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Returned",
                                                      style: StyleText
                                                          .fontSize8Weight400
                                                          .copyWith(
                                                        color: AppColors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 3.sp),
                                        // name product
                                        Row(
                                          children: [
                                            //space
                                            SizedBox(height: 4.sp),
                                            // name product
                                            Text(
                                              FormatHelper.capitalize(
                                                  "Dell GS 15"),
                                              style: StyleText
                                                  .fontSize14Weight400
                                                  .copyWith(
                                                color: AppColors.blackButton,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 2.sp),
                                        // Received Date &
                                        Row(
                                          children: [
                                            // Received Date & Return Date
                                            Text(
                                              "${S.of(context).receivedDate}: ",
                                              style: StyleText
                                                  .fontSize8Weight400
                                                  .copyWith(
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                            // value Received Date
                                            Text(
                                              "28 May 2020",
                                              style: StyleText
                                                  .fontSize8Weight400
                                                  .copyWith(
                                                color: AppColors.blackButton,
                                              ),
                                            ),

                                            Spacer(),

                                            // Return Date
                                            Text(
                                              "${S.of(context).returnDate}: ",
                                              style: StyleText
                                                  .fontSize8Weight400
                                                  .copyWith(
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                            // value Return Date
                                            Text(
                                              "28 May 2020",
                                              style: StyleText
                                                  .fontSize8Weight400
                                                  .copyWith(
                                                color: AppColors.blackButton,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : ProductRequestTableWidget(
                          data: tableData,
                          locale: Localizations.localeOf(context).languageCode,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /////////////////////////////Export //////////////////////////////

  Widget exportButton() {
    final isMobile = context.isPhone;

    return customButtonWithSvg(
      title: isMobile ? "" : S.of(context).export,
      function: () {},
      // 22/10/2026 — Owner: toolbar text is 14 in every module (was 16).
      textStyle: StyleText.fontSize14Weight500.copyWith(
        color: AppColors.textButton,
      ),
      width: isMobile ? 38.sp : 100.sp,
      height: 38.sp,
      space: 8.sp,
      radius: 8.r,
      svgColor: AppColors.textButton,
      color: AppColors.primary,
      image: "assets/icons_assets/main_icons_assets/ic_action_export.svg",
      widthImage: 24.sp,
      heightImage: 24.sp,
      colorBorder: Colors.transparent,
    );
  }

  /////////////////////////////Export //////////////////////////////

  ////////////////////////// my Request //////////////////////////

  Widget myRequestButton() {
    return customButton(
      title: S.of(context).myRequest,
      function: () {
        navigateTo(context, MyRequestDesktopScreen());
      },
      color: AppColors.primary,
      // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
      textStyle: StyleText.fontSize14Weight500,
      width: 135.sp,
      height: 38.sp,
      radius: 8.r,
      textColor: AppColors.textButton,
    );
  }
  ////////////////////////// my Request //////////////////////////

  /////////////////////////// Filter in Assigned & Stock //////////////////////////////////

  String selectedLabel = "Assets"; // Default selected chip

  Widget filterSection(BuildContext context) {
    final Map<String, String> filterItems = {
      "Assets": S.of(context).assets,
      "Consumable": S.of(context).consumables,
    };

    final Map<String, String> filterCounts = {
      "Assets": "14",
      "Consumable": "5",
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
    final isMobile = context.isPhone;

    bool isSelected = key == selectedLabel;
    bool isLight = Theme.of(context).brightness == Brightness.light;
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
          Text(
            FormatHelper.capitalize(label),
            style: (isMobile
                    ? StyleText.fontSize14Weight600
                    : StyleText.fontSize16Weight600)
                .copyWith(
              color: isSelected
                  ? isLight
                      ? AppColors.blackButton
                      : AppColors.white
                  : (isLight ? AppColors.secondaryText : AppColors.grey),
            ),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }

  /////////////////////////// Filter in Assigned & Stock //////////////////////////////////

  //////////////////////////// Filter Product ////////////////////////////////////////////////////////////

  String selectFilterProduct = "all"; // Default selected chip
  Widget filterProduct({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required Color colorLabel,
  }) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final isMobile = context.isPhone;

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
          style: isMobile
              ? StyleText.fontSize12Weight400.copyWith(color: colorLabel)
              : StyleText.fontSize14Weight400.copyWith(color: colorLabel),
        ),
      ),
    );
  }

  //////////////////////////// Filter Product ////////////////////////////////////////////////////////////

  /////////////////////////// ListView Item Text /////////////////////////////////////////////////////////

  Widget itemTextProduct({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          FormatHelper.capitalize(label),
          style: StyleText.fontSize10Weight500.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        Text(
          FormatHelper.capitalize(value),
          style: StyleText.fontSize10Weight500.copyWith(
            color: AppColors.blackButton,
          ),
        ),
      ],
    );
  }

  /////////////////////////// ListView Item Text /////////////////////////////////////////////////////////
}

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv2_view_product/presentation/ui/pages/product_details_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_validated_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_toolbar_action_button.dart';

class StorageLocationDetailsDesktopScreen extends StatefulWidget {
  const StorageLocationDetailsDesktopScreen({super.key});

  @override
  State<StorageLocationDetailsDesktopScreen> createState() =>
      _StorageLocationDetailsDesktopScreenState();
}

class _StorageLocationDetailsDesktopScreenState
    extends State<StorageLocationDetailsDesktopScreen> {
  //////////////////////////////// Hide & Expand //////////////////////////////

  bool _isStorageLocationDetailsExpanded = true;
  bool _isStorageLocationDetailsTwoExpanded = true;
  bool _isEmployeeAssignedInformationExpanded = true;

  //////////////////////////////// Hide & Expand //////////////////////////////

  ///////////////////////////// Dropdown ///////////////////////////////////

  String? selectedAccessLevel;
  String? selectedConditionStorage;

  String? selectedUnit;

  String? selectedEquipmentAvailable;
  String? selectedStorageCapacity;
  String? selectedProductType;

  List<Map<String, String>> accessLevelList = [
    {"key": "Public Access", "value": "Public Access"},
    {"key": "Internal Access Only", "value": "Internal Access Only"},
    {"key": "Authorized Personnel Only", "value": "Authorized Personnel Only"},
    {"key": "Department-Restricted", "value": "Department-Restricted"},
    {"key": "Managerial Access", "value": "Managerial Access"},
    {"key": "Admin-Only Access", "value": "Admin-Only Access"},
    {
      "key": "Confidential / Secure Access",
      "value": "Confidential / Secure Access",
    },
  ];

  List<Map<String, String>> selectedUnitList = [
    {"key": "Units", "value": "Units"},
    {"key": "Volume", "value": "Volume"},
    {"key": "Pallet Space", "value": "Pallet Space"},
    {"key": "Weight", "value": "Weight"},
  ];
  List<Map<String, String>> selectedConditionOfStorageList = [
    {"key": "Standard", "value": "Standard "},
    {"key": "Temperature-Controlled", "value": "Temperature-Controlled"},
    {"key": "Humidity-Controlled Space", "value": "Humidity-Controlled"},
    {"key": "Dry Storage", "value": "Dry Storage"},
    {"key": "Cold Storage", "value": "Cold Storage"},
    {"key": "Frozen Storage", "value": "Frozen Storage"},
    {"key": "Ambient Storage", "value": "Ambient Storage"},
    {"key": "Secure Storage", "value": "Secure Storage"},
  ];

  List<Map<String, String>> selectedStorageCapacityList = [
    {"key": "Forklift", "value": "Forklift "},
    {
      "key": "Hand Pallet Truck (Manual Jack)",
      "value": "Hand Pallet Truck (Manual Jack) ",
    },
    {"key": "Conveyor System", "value": "Conveyor System "},
    {"key": "Lifting Crane / Hoist", "value": "Lifting Crane / Hoist "},
    {"key": "Shelving / Racking System", "value": "Shelving / Racking System "},
    {
      "key": "Temperature Monitoring Devices",
      "value": "Temperature Monitoring Devices ",
    },
    {"key": "Fire Safety Equipment", "value": "Fire Safety Equipment "},
    {"key": "Security Cameras (CCTV)", "value": "Security Cameras (CCTV) "},
    {
      "key": "Labeling / Scanning Devices",
      "value": "Labeling / Scanning Devices ",
    },
    {"key": "Trolleys / Carts", "value": "Trolleys / Carts "},
    {
      "key": "Packing / Unpacking Station",
      "value": "Packing / Unpacking Station ",
    },
    {"key": "Ventilation System", "value": "Ventilation System "},
    {
      "key": "Hazardous Material Handling Kit",
      "value": "Hazardous Material Handling Kit ",
    },
    {
      "key": "Computer Terminal / Inventory Access Point",
      "value": "Computer Terminal / Inventory Access Point ",
    },
    {"key": "None", "value": "None "},
  ];

  List<Map<String, String>> productTypeList = [
    {"key": "Open", "value": "Open"},
    {"key": "Partially Received", "value": "Partially Received"},
    {"key": "Received", "value": "Received"},
    {"key": "Cancelled", "value": "Cancelled"},
  ];

  ///////////////////////////// Dropdown ///////////////////////////////////
  ///////////////////////////// Controller //////////////////////////////////

  TextEditingController storageLocationIdController = TextEditingController();
  TextEditingController storageLocationNameController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController branchNameController = TextEditingController();
  TextEditingController stateOrProvideController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController createdByController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController dateAddedController = TextEditingController();
  TextEditingController assignController = TextEditingController();
  TextEditingController storageCapacityController = TextEditingController();
  TextEditingController additionalNoteController = TextEditingController();
  TextEditingController stateOrProvinceController = TextEditingController();
  TextEditingController assignDepartmentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _searchHistoryProductController =
      TextEditingController();

  ///////////////////////////// Controller //////////////////////////////////

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    Localizations.localeOf(context).languageCode == 'ar';
    final isMobile = context.isPhone;
    Localizations.localeOf(context).languageCode == 'en';
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventoryManagement,
          onFirstTap: () {
            Navigator.pop(context);
          },
          secondTitle: S.of(context).productName,
          onSecondTap: () {
            navigateTo(context, ViewProductDetails());
          },
          thirdTitle: S.of(context).assigningProduct,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                // Storage Location Details Tab and History Product Storage and Stored Products
                Row(
                  children: [
                    buildTab(S.of(context).storageLocationDetails, 0),
                    SizedBox(width: 24.sp),
                    buildTab(S.of(context).historyProductStorage, 1),
                    isMobile ? SizedBox() : SizedBox(width: 24.sp),
                    isMobile
                        ? SizedBox()
                        : buildTab(S.of(context).storedProducts, 2),
                    Spacer(),
                    isMobile
                        ? SizedBox()
                        : customButtonWithSvg(
                            title: S.of(context).edit,
                            function: () {},
                            width: 135.sp,
                            height: 38.sp,
                            color: AppColors.primary,
                            textStyle: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.textButton,
                            ),
                            radius: 8.r,
                            heightImage: 16.sp,
                            widthImage: 16.sp,
                            svgColor: AppColors.textButton,
                            image:
                                "assets/icons_assets/main_icons_assets/ic_action_edit.svg",
                            space: 8.sp,
                            colorBorder: Colors.transparent,
                          ),
                  ],
                ),

                // space
                SizedBox(height: 42.sp),

                // Storage Location Details
                if (selectedSection == 0) ...[
                  // storageLocationDetails & Hide & Expand
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).storageLocationDetails,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                      const Spacer(),
                      isMobile
                          ? customButtonWithSvg(
                              title: "",
                              function: () {},
                              width: isMobile ? 38.sp : 135.sp,
                              height: 38.sp,
                              color: AppColors.primary,
                              textStyle: StyleText.fontSize16Weight500.copyWith(
                                color: AppColors.textButton,
                              ),
                              radius: 8.r,
                              heightImage: 16.sp,
                              widthImage: 16.sp,
                              svgColor: AppColors.textButton,
                              image:
                                  "assets/icons_assets/main_icons_assets/ic_action_edit.svg",
                              space: 8.sp,
                              colorBorder: Colors.transparent,
                            )
                          : GestureDetector(
                              onTap: () {
                                HapticController
                                    .low(); // list row: on the tap (X-117)
                                setState(() {
                                  _isStorageLocationDetailsExpanded =
                                      !_isStorageLocationDetailsExpanded;
                                });
                              },
                              child: Text.rich(
                                TextSpan(
                                  text: _isStorageLocationDetailsExpanded
                                      ? S.of(context).hide
                                      : S.of(context).expand,
                                  style: StyleText.fontSize14Weight500
                                      .copyWith(color: const Color(0xff1877F2))
                                      .merge(
                                        const TextStyle(
                                          decoration: TextDecoration.underline,
                                          decorationColor: Color(0xff1877F2),
                                        ),
                                      ),
                                ),
                              ),
                            ),
                    ],
                  ),

                  SizedBox(height: 8.sp),
                  // Supplier Details
                  if (_isStorageLocationDetailsExpanded)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15.sp),
                        child: Column(
                          children: [
                            // image
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60.sp,
                                  height: 60.sp,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.r),
                                    color: lightMode
                                        ? AppColors.grey
                                        : AppColors.background,
                                  ),
                                  child: CustomSvgImage(
                                    assetPath:
                                        "assets/icons_assets/main_icons_assets/ic_module_inventory.svg",
                                    width: 35.sp,
                                    height: 35.sp,
                                    color: AppColors.blackButton,
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15.sp),
                            // Storage Location ID & Storage Location ID Name
                            buildResponsiveFields(
                              left: storageLocationIdField(),
                              right: storageLocationNameField(),
                              context: context,
                            ),
                            // space
                            SizedBox(height: 15.sp),
                            // country & stateOrProvince
                            buildResponsiveFields(
                              left: storageCountryField(),
                              right: stateOrProvinceField(),
                              context: context,
                            ),
                            // space
                            SizedBox(height: 15.sp),
                            // postalCode & Number & city
                            buildResponsiveFields(
                              left: storagePostalCodeField(),
                              right: storageCityField(),
                              context: context,
                            ),
                            // space
                            SizedBox(height: 15.sp),
                            // Branch Name &  Area
                            buildResponsiveFields(
                              left: branchNameField(),
                              right: areaField(),
                              context: context,
                            ),
                            //space
                            SizedBox(height: 15.sp),
                            // Created By &  Date Added
                            buildResponsiveFields(
                              left: createdByField(),
                              right: dateAddedField(),
                              context: context,
                            ),
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: 20.sp),

                  // storageLocationDetails & Hide & Expand
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).storageLocationDetails,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          HapticController
                              .low(); // list row: on the tap (X-117)
                          setState(() {
                            _isStorageLocationDetailsTwoExpanded =
                                !_isStorageLocationDetailsTwoExpanded;
                          });
                        },
                        child: Text.rich(
                          TextSpan(
                            text: _isStorageLocationDetailsTwoExpanded
                                ? S.of(context).hide
                                : S.of(context).expand,
                            style: StyleText.fontSize14Weight500
                                .copyWith(color: const Color(0xff1877F2))
                                .merge(
                                  const TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(
                                      0xff1877F2,
                                    ), // ✅ underline color
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.sp),
                  // Supplier Details
                  if (_isStorageLocationDetailsTwoExpanded)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15.sp),
                        child: Column(
                          children: [
                            // Assigned Department & Access Level
                            buildResponsiveFields(
                              left: assignedDepartmentField(),
                              right: accessLevelDropdown(),
                              context: context,
                            ),
                            // space
                            SizedBox(height: 15.sp),

                            // Storage Capacity & Unit
                            Row(
                              children: [
                                Expanded(child: storageCapacityField()),
                                SizedBox(width: 10.sp),
                                unitDropdown(),
                              ],
                            ),

                            SizedBox(height: 15.sp),

                            // Additional Note
                            Row(
                              children: [
                                Expanded(
                                  child: CustomValidatedTextFieldMaster(
                                    enabled: false,
                                    showCharCount: true,
                                    height: 72.sp,
                                    maxLines: 3,
                                    label: S.of(context).storageCapacity,
                                    hint: S.of(context).storageCapacity,
                                    controller: storageCapacityController,
                                    textDirection: ui.TextDirection.ltr,
                                    onlyDigits: false,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: 20.sp),

                  // employeeAssignedInformation & Hide & Expand
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).employeeAssignedInformation,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTapDown: (_) => HapticController.medium(),
                        onTap: () {
                          setState(() {
                            _isEmployeeAssignedInformationExpanded =
                                !_isEmployeeAssignedInformationExpanded;
                          });
                        },
                        child: Text.rich(
                          TextSpan(
                            text: _isEmployeeAssignedInformationExpanded
                                ? S.of(context).hide
                                : S.of(context).expand,
                            style: StyleText.fontSize14Weight500
                                .copyWith(color: const Color(0xff1877F2))
                                .merge(
                                  const TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xff1877F2),
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // space
                  SizedBox(height: 8.sp),

                  // Employee Assigned Information
                  if (_isEmployeeAssignedInformationExpanded)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15.sp),
                        child: Column(
                          children: [
                            // Search and DropDown
                            Row(
                              children: [
                                // Search
                                Expanded(
                                  child: SizedBox(
                                    height: 38.sp,
                                    child: AppSearchTextField(
                                      controller: _searchController,
                                      expanded: false,
                                    ),
                                  ),
                                ),

                                // space
                                SizedBox(
                                    width: ButtonSizing.toolbarGap(context)),

                                // Selected Product
                                isMobile
                                    ? customButtonWithSvg(
                                        title: "",
                                        function: () {},
                                        textStyle: StyleText.fontSize8Weight400,
                                        height: 38.sp,
                                        width: 38.sp,
                                        space: 8.sp,
                                        radius: 8.r,
                                        color: AppColors.card,
                                        image:
                                            "assets/icons_assets/main_icons_assets/ic_action_filter.svg",
                                        // 22/10/2026 — Owner: filter and sort icons are one size and colour in every module (ToolbarStyle).
                                        widthImage: ToolbarStyle.iconSize,
                                        heightImage: ToolbarStyle.iconSize,
                                        svgColor: ToolbarStyle.contentColor,
                                        colorBorder: Colors.transparent,
                                      )
                                    : SizedBox(
                                        width: 135.sp,
                                        child: CustomDropdown<String>(
                                          items: (productTypeList)
                                              .map((e) => DropdownItem<String>(
                                                  value: e['key'] ?? '',
                                                  label: e['value'] ?? ''))
                                              .toList(),
                                          value: selectedProductType,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedProductType = value;
                                            });
                                          },
                                          hint: S.of(context).productType,
                                          height: 36.sp,
                                          fillColor: AppColors.background,
                                        ),
                                      ),
                              ],
                            ),

                            SizedBox(height: 15.sp),

                            GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              // avoid nested scroll conflict
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: 3,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: CrossAxisCountHelper
                                    .getCrossAxisCountForDefaultTablet2(
                                  context,
                                ),
                                crossAxisSpacing: 12.sp,
                                mainAxisSpacing: 12.sp,
                                mainAxisExtent: 85.sp,
                              ),
                              itemBuilder: (context, index) {
                                return employeeCard();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ]
                // History Product Storage
                else if (selectedSection == 1) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).historyProductStorage,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                      SizedBox(height: 12.sp),

                      // search bar
                      SizedBox(
                        height: 38.sp,
                        child: AppSearchTextField(
                          controller: _searchHistoryProductController,
                          expanded: false,
                        ),
                      ),
                      // space
                      SizedBox(height: 15.sp),

                      // GridView of product
                      SizedBox(
                        // height: MediaQuery.sizeOf(context).height*.5, // adjust based on your UI
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
                            mainAxisExtent: 123.sp,
                          ),
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                navigateTo(context, widget);
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
                                    bottom: 9.sp,
                                  ),
                                  child: Column(
                                    children: [
                                      // Image & Asset ID & Quantity & Maintenance Frequency
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          // left side product image
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // image
                                              Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        4.r,
                                                      ),
                                                      color: lightMode
                                                          ? AppColors.grey
                                                          : AppColors
                                                              .background,
                                                    ),
                                                    width: 60.sp,
                                                    height: 65.sp,
                                                    child: CustomSvgImage(
                                                      assetPath:
                                                          "assets/icons_assets/main_icons_assets/ic_module_inventory.svg",
                                                      color: lightMode
                                                          ? AppColors
                                                              .blackButton
                                                          : AppColors.white,
                                                      fit: BoxFit.scaleDown,
                                                      height: 65.sp,
                                                      width: 50.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              //space
                                              SizedBox(width: 5.sp),
                                              Column(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          itemTextProductGridView(
                                                            value: "001",
                                                            label:
                                                                "${S.of(context).storageId}: ",
                                                          ),

                                                          //    itemTextProductGridView(value: S.of(context).inUse,label: "${S.of(context).status}: "),
                                                        ],
                                                      ),
                                                      SizedBox(height: 3.sp),
                                                      itemTextProductGridView(
                                                        value: "IT",
                                                        label:
                                                            "${S.of(context).department}: ",
                                                      ),
                                                      SizedBox(height: 3.sp),
                                                      itemTextProductGridView(
                                                        value: "Cartridge",
                                                        label:
                                                            "${S.of(context).branchName}: ",
                                                      ),
                                                      SizedBox(height: 3.sp),
                                                      itemTextProductGridView(
                                                        value: "Floor 15",
                                                        label:
                                                            "${S.of(context).area}: ",
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      // space
                                      SizedBox(height: 2.sp),
                                      // Dell GS 15 title
                                      Row(
                                        children: [
                                          // name product
                                          Text(
                                            FormatHelper.capitalize(
                                              "Storage Name",
                                            ),
                                            style: StyleText.fontSize12Weight400
                                                .copyWith(
                                              color: AppColors.blackButton,
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 2.sp),
                                      // Received Date & Returing Date
                                      Row(
                                        children: [
                                          itemTextProductGridView(
                                            value: "28 May 2020",
                                            label:
                                                "${S.of(context).storedOn}: ",
                                          ),
                                          Spacer(),
                                          itemTextProductGridView(
                                            value: "28 May 2020",
                                            label:
                                                "${S.of(context).returnDate}: ",
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
                      ),
                    ],
                  ),
                ]
                // Stored Products
                else if (selectedSection == 2) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).storedProducts,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                      SizedBox(height: 12.sp),

                      // search bar
                      SizedBox(
                        height: 38.sp,
                        child: AppSearchTextField(
                          controller: _searchHistoryProductController,
                          expanded: false,
                        ),
                      ),
                      // space
                      SizedBox(height: 15.sp),

                      // GridView of product
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height *
                            .5, // adjust based on your UI
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 15.sp,
                            mainAxisSpacing: 15.sp,
                            childAspectRatio: 2.35,
                          ),
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                navigateTo(context, widget);
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
                                  ),
                                  child: Column(
                                    children: [
                                      // Image & Asset ID & Quantity & Maintenance Frequency
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          // left side product image
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // image
                                              Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        4.r,
                                                      ),
                                                      color: lightMode
                                                          ? AppColors.grey
                                                          : AppColors
                                                              .background,
                                                    ),
                                                    width: 60.sp,
                                                    height: 65.sp,
                                                    child: CustomSvgImage(
                                                      assetPath:
                                                          "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
                                                      color: lightMode
                                                          ? AppColors
                                                              .blackButton
                                                          : AppColors.white,
                                                      fit: BoxFit.scaleDown,
                                                      height: 65.sp,
                                                      width: 50.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              //space
                                              SizedBox(width: 5.sp),
                                              Column(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      itemTextProductGridView(
                                                        value: "001",
                                                        label:
                                                            "${S.of(context).category}: ",
                                                      ),
                                                      SizedBox(height: 3.sp),
                                                      itemTextProductGridView(
                                                        value: "IT",
                                                        label:
                                                            "${S.of(context).subcategory}: ",
                                                      ),
                                                      SizedBox(height: 3.sp),
                                                      itemTextProductGridView(
                                                        value: "Cartridge",
                                                        label:
                                                            "${S.of(context).unitOfMeasurement}: ",
                                                      ),
                                                      SizedBox(height: 3.sp),
                                                      itemTextProductGridView(
                                                        value: "Floor 15",
                                                        label:
                                                            "${S.of(context).quantity}: ",
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      // space
                                      SizedBox(height: 2.sp),
                                      // Dell GS 15 title
                                      Row(
                                        children: [
                                          // name product
                                          Text(
                                            FormatHelper.capitalize(
                                              "Printer Ink",
                                            ),
                                            style: StyleText.fontSize12Weight400
                                                .copyWith(
                                              color: AppColors.blackButton,
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 2.sp),
                                      // Received Date & Returing Date
                                      Row(
                                        children: [
                                          itemTextProductGridView(
                                            value: "28 May 2020",
                                            label:
                                                "${S.of(context).expirationDate}: ",
                                          ),
                                          Spacer(),
                                          itemTextProductGridView(
                                            value: "28 May 2020",
                                            label:
                                                "${S.of(context).returnDate}: ",
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
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget employeeCard() {
    return Container(
      width: 310.sp,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
      child: Row(
        children: [
          // image
          CircleAvatar(
            radius: 20.r,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: CustomSvgImage.natural(
                assetPath: "male" == "male"
                    ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'
                    : 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png',
                semanticsLabel: 'Gender Icon',
                fit: BoxFit.cover,
                width: 40.w,
                height: 40.h,
              ),
            ),
          ),
          SizedBox(width: 10.sp),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                FormatHelper.capitalize("Amr Mesbah"),
                style: StyleText.fontSize15Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                FormatHelper.capitalize("Marketing "),
                style: StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Text(
                    FormatHelper.capitalize("Marketing Manger"),
                    style: StyleText.fontSize12Weight500.copyWith(
                      color: AppColors.secondaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),

                  /*
                  SizedBox(width: 90.sp),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color:
                          AppColors.card,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(5.sp),
                      child: Center(
                        child: Text(
                          "Supervisor",
                          style: StyleText.fontSize10Weight400.copyWith(
                            color:
                                AppColors.blackButton,
                          ),
                        ),
                      ),
                    ),
                  ),
                  */
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildResponsiveFields({
    required BuildContext context,
    required Widget left,
    required Widget right,
  }) {
    final isMobile = kpIsPhoneLayout(context);

    if (isMobile) {
      return Column(children: [left, SizedBox(height: 10.sp), right]);
    } else {
      return Row(
        children: [
          Expanded(child: left),
          SizedBox(width: 15.sp),
          Expanded(child: right),
        ],
      );
    }
  }

  //////////////////////// storage Location Details /////////////////////////////

  Widget assignedDepartmentField() => CustomValidatedTextFieldMaster(
        label: S.of(context).assignedDepartment,
        hint: S.of(context).assignedDepartment,
        enabled: false,
        controller: assignDepartmentController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget accessLevelDropdown() => CustomDropdown<String>(
        items: (accessLevelList)
            .map((e) => DropdownItem<String>(
                value: e['key'] ?? '', label: e['value'] ?? ''))
            .toList(),
        value: selectedAccessLevel,
        onChanged: (value) {
          setState(() {
            selectedAccessLevel = value;
          });
        },
        label: S.of(context).accessLevel,
        hint: S.of(context).accessLevel,
        height: 36.sp,
      );

  Widget storageCapacityField() => CustomValidatedTextFieldMaster(
        label: S.of(context).storageCapacity,
        hint: S.of(context).storageCapacity,
        enabled: false,
        width: 308.sp,
        controller: storageCapacityController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget unitDropdown() {
    return SizedBox(
      width: 100.sp,
      child: CustomDropdown<String>(
        items: (selectedUnitList)
            .map((e) => DropdownItem<String>(
                value: e['key'] ?? '', label: e['value'] ?? ''))
            .toList(),
        value: selectedUnit,
        onChanged: (value) {
          setState(() {
            selectedUnit = value;
          });
        },
        label: "",
        hint: S.of(context).unit,
        height: 36.sp,
      ),
    );
  }

  Widget conditionOfStorageDropdown() => CustomDropdown<String>(
        items: (selectedConditionOfStorageList)
            .map((e) => DropdownItem<String>(
                value: e['key'] ?? '', label: e['value'] ?? ''))
            .toList(),
        value: selectedConditionStorage,
        onChanged: (value) {
          setState(() {
            selectedConditionStorage = value;
          });
        },
        label: S.of(context).conditionOfStorage,
        hint: S.of(context).unit,
        height: 36.sp,
      );

  //////////////////////// storage Location Details /////////////////////////////

  ////////////////////////// Storage Location Details /////////////////////////////

  Widget storageLocationIdField() => CustomValidatedTextFieldMaster(
        label: S.of(context).storageLocationID,
        hint: S.of(context).storageLocationID,
        enabled: false,
        controller: storageLocationIdController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget storageLocationNameField() => CustomValidatedTextFieldMaster(
        label: S.of(context).storageLocationIDName,
        hint: S.of(context).storageLocationIDName,
        enabled: false,
        controller: storageLocationNameController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget countryField() => CustomValidatedTextFieldMaster(
        label: S.of(context).country,
        hint: S.of(context).country,
        enabled: false,
        controller: countryController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget stateOrProvinceField() => CustomValidatedTextFieldMaster(
        label: S.of(context).stateOrProvince,
        hint: S.of(context).stateOrProvince,
        enabled: false,
        controller: stateOrProvinceController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget storageCountryField() => CustomValidatedTextFieldMaster(
        label: S.of(context).country,
        hint: S.of(context).country,
        enabled: false,
        controller: countryController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget storageStateOrProvinceField() => CustomValidatedTextFieldMaster(
        label: S.of(context).stateOrProvince,
        hint: S.of(context).stateOrProvince,
        enabled: false,
        controller: stateOrProvinceController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget storageCityField() => CustomValidatedTextFieldMaster(
        label: S.of(context).city,
        hint: S.of(context).city,
        enabled: false,
        controller: cityController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget storagePostalCodeField() => CustomValidatedTextFieldMaster(
        label: S.of(context).postalCode,
        hint: S.of(context).postalCode,
        enabled: false,
        controller: postalCodeController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget branchNameField() => CustomValidatedTextFieldMaster(
        label: S.of(context).branchName,
        hint: S.of(context).branchName,
        enabled: false,
        controller: branchNameController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget areaField() => CustomValidatedTextFieldMaster(
        label: S.of(context).area,
        hint: S.of(context).area,
        enabled: false,
        controller: areaController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget createdByField() => CustomValidatedTextFieldMaster(
        label: S.of(context).createdBy,
        hint: S.of(context).createdBy,
        enabled: false,
        controller: createdByController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget dateAddedField() => CustomValidatedTextFieldMaster(
        label: S.of(context).dateAdded,
        hint: S.of(context).dateAdded,
        enabled: false,
        controller: dateAddedController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  ////////////////////////// Storage Location Details /////////////////////////////

  /////////////////////////// ListView Item Text /////////////////////////////////////////////////////////

  Widget itemTextProductGridView({
    required String label,
    required String value,
  }) {
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

  //////////////////////////////// Navigate Page //////////////////////////

  int selectedSection = 0;

  Widget buildTab(String label, int index) {
    final isSelected = selectedSection == index;
    final isMobile = context.isPhone;

    // Measure text width dynamically
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: label, style: StyleText.fontSize20Weight600),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final double underlineWidth = textPainter.size.width;

    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () {
        setState(() {
          selectedSection = index;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: isMobile
                ? StyleText.fontSize15Weight600.copyWith(
                    color: isSelected
                        ? AppColors.secondaryPrimary
                        : AppColors.secondaryText,
                  )
                : StyleText.fontSize20Weight600.copyWith(
                    color: isSelected
                        ? AppColors.secondaryPrimary
                        : AppColors.secondaryText,
                  ),
          ),
          SizedBox(height: 4.sp),
          if (isSelected)
            Container(
              height: 2.sp,
              width: isMobile ? underlineWidth - 55 : underlineWidth,
              color: AppColors.secondaryPrimary,
            ),
        ],
      ),
    );
  }

  //////////////////////////////// Navigate Page //////////////////////////

  ////////////////////////////// History Order ////////////////////////////

  Widget historyOrderDetailsTable() {
    return Column(
      children: [
        Center(child: Text("HistoryOrderDetailsTable")),
      ],
    );
  }

  ////////////////////////////// History Order ////////////////////////////
}

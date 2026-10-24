import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv2_view_product/presentation/ui/pages/mobile/existing_batch.dart';
import 'package:knowticed_plus/features/inventory/inv2_view_product/presentation/ui/pages/mobile/new_batch.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/order_info.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/select_approval.dart';
import 'package:knowticed_plus/features/inventory/inv3_assign_and_suppliers/presentation/ui/pages/p12_assigning_product_toogel.dart';
import 'package:knowticed_plus/features/inventory/inv3_assign_and_suppliers/presentation/ui/pages/p14_storage_location_details_toogel.dart';
import 'package:knowticed_plus/features/inventory/inv3_assign_and_suppliers/presentation/ui/pages/p8_supplier_details_toggel.dart';
import 'package:knowticed_plus/features/inventory/inv2_view_product/presentation/ui/pages/allocated_details_employee_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/cards/custom_approval_shape.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_pop_up.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_validated_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/features/inventory/helpers/constants/constant_data.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class ViewProductDetailsScreen extends StatefulWidget {
  final ProductModel? productModel; // Add optional product model parameter

  const ViewProductDetailsScreen({super.key, this.productModel});

  @override
  State<ViewProductDetailsScreen> createState() =>
      _ViewProductDetailsScreenState();
}

class _ViewProductDetailsScreenState extends State<ViewProductDetailsScreen> {
  ///////////////////////////////// Variable //////////////////////////////////////////////

  final List<Map<String, String>> departments = [
    {"key": "dep1", "value": "Dep1"},
    {"key": "dep2", "value": "Dep2"},
    {"key": "dep3", "value": "Dep3"},
    {"key": "dep4", "value": "Dep4"},
  ];
  String? selectedDepartment;

  ///////////////////////////////// Variable //////////////////////////////////////////////
  bool showProductDetails = true;
  ///////////////////////////////// Controller ////////////////////////////////////////////
  final TextEditingController _searchController = TextEditingController();

  ///////////////////////////////// Controller ////////////////////////////////////////////

  ///////////////////////////////// Batch section //////////////////////////////////////////

  int selectedBatchIndex = 0;

  ///////////////////////////////// Batch section //////////////////////////////////////////

  //////////////////////////////// Storage Location ///////////////////////////////////////
  final List<Map<String, dynamic>> storageData = [
    {'location': 'Room A13', 'quantity': 10},
    {'location': 'Room B21', 'quantity': 5},
    {'location': 'Room C05', 'quantity': 3},
    {'location': 'Room A13', 'quantity': 10},
    {'location': 'Room B21', 'quantity': 5},
  ];
  //////////////////////////////// Storage Location ///////////////////////////////////////

  /////////////////////////////// Approval Cycle //////////////////////////////////////////
  late ApprovalSection section;

  @override
  void initState() {
    super.initState();

    debugPrint("********************************************");
    debugPrint(
        "approvalCycle length: ${widget.productModel!.approvalCycle.length}");
    debugPrint("********************************************");
    // Replace with empty initialization since we'll use Firebase data
    section = ApprovalSection(selectedApprovers: []);
  }
  /////////////////////////////// Approval Cycle //////////////////////////////////////////

  /////////////////////////// Filter in Assigned & Stock //////////////////////////////////

  String selectedLabel = "allocated"; // Default selected chip

  Widget filterSection(BuildContext context) {
    final Map<String, String> filterItems = {
      "allocated": S.of(context).allocated,
      "Stock": S.of(context).stock,
      "Damaged": S.of(context).damaged,
      "Missing": S.of(context).missing,
      "Stolen": S.of(context).stolen,
    };

    final Map<String, String> filterCounts = {
      "allocated": "14",
      "Stock": "5",
      "Damaged": "5",
      "Missing": "5",
      "Stolen": "5",
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
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
            style: isMobile
                ? StyleText.fontSize14Weight600.copyWith(
                    color: isSelected
                        ? isLight
                            ? AppColors.blackButton
                            : AppColors.white
                        : (isLight ? AppColors.secondaryText : AppColors.grey),
                  )
                : StyleText.fontSize16Weight600.copyWith(
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

  //////////////////////////////////////// Filter person ////////////////////////////////////

  //////////////////////////////////////// Filter person ////////////////////////////////////

  String selectedRoom = 'All';

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    Localizations.localeOf(context).languageCode == 'en';
    final isTablet = context.isTablet;
    final isMobile = context.isPhone;
    final isLandscape = context.isLandscape;
    //
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventoryManagement,
          onFirstTap: () {
            Navigator.pop(context);
          },
          secondTitle: widget.productModel!.productName.value,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warranty & Restock & Specification & Edit
                isMobile
                    ? Row(
                        children: [
                          // Warranty & Restock
                          Column(
                            children: [
                              // Warranty
                              warrantyCustom(() {
                                /* Warranty Logic */
                              }),
                              // space
                              SizedBox(height: 10.sp),
                              // Restock
                              restockCustom(context),
                            ],
                          ),
                          Spacer(),
                          // Specification & Edit
                          Column(
                            children: [
                              // Specification
                              specificationCustom(() {
                                /* Spec Logic */
                              }),
                              // space
                              SizedBox(height: 10.sp),
                              // Edit
                              editCustom(() {
                                /* Edit Logic */
                              }),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          warrantyCustom(() {
                            /* Warranty Logic */
                          }),
                          SizedBox(width: 15.sp),
                          specificationCustom(() {
                            /* Spec Logic */
                          }),
                          SizedBox(width: 15.sp),
                          restockCustom(context),
                          Spacer(),
                          editCustom(() {
                            /* Edit Logic */
                          }),
                        ],
                      ),

                // space
                SizedBox(height: 25.sp),

                // Batch Section
                SizedBox(
                  height: 28.sp,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final batchNumber = (index + 1).toString().padLeft(
                            3,
                            '0',
                          );
                      final isSelected = index == selectedBatchIndex;

                      return GestureDetector(
                        onTap: () {
                          navigateTo(context, StorageLocationDetails());
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 10.sp),
                          child: customButton(
                            title: "${S.of(context).batch} $batchNumber",
                            function: () {
                              setState(() {
                                selectedBatchIndex = index;
                              });
                            },
                            width: isMobile ? 81.sp : 100.sp,
                            height: 28.sp,
                            color:
                                isSelected ? AppColors.primary : AppColors.card,
                            textStyle: StyleText.fontSize14Weight400.copyWith(
                              color: isSelected
                                  ? AppColors.textButton
                                  : AppColors.blackButton,
                            ),
                            radius: 4.r,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // space
                SizedBox(height: 21.sp),

                // Order ID:001 & Hide & Expand
                Row(
                  children: [
                    // orderID
                    Text(
                      "${S.of(context).orderID}: ${widget.productModel!.productId.value}",
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                    // space
                    Spacer(),
                    // Hide and Expand
                    GestureDetector(
                      onTap: () {
                        HapticController.low(); // list row: on the tap (X-117)
                        setState(() {
                          showProductDetails = !showProductDetails;
                        });
                      },
                      child: Builder(
                        builder: (context) {
                          final text = showProductDetails
                              ? S.of(context).hide
                              : S.of(context).expand;
                          final style = StyleText.fontSize12Weight500.copyWith(
                            color: const Color(0xff1877F2),
                          );

                          // Use TextPainter to measure the actual width of the text
                          final TextPainter textPainter = TextPainter(
                            text: TextSpan(text: text, style: style),
                            textDirection: Directionality.of(context),
                            textScaler: MediaQuery.textScalerOf(context),
                          )..layout();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(text, style: style),
                              SizedBox(
                                height: 1.sp,
                              ), // spacing between text and underline
                              Container(
                                height: 1.sp,
                                width: textPainter.width,
                                color: style.color,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // space
                SizedBox(height: 8.sp),

                // All Content of page of Order
                if (showProductDetails)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 15.sp,
                        right: 15.sp,
                        left: 15.sp,
                      ),
                      // All context in page section 1
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First Section
                          isMobile
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // image
                                    Container(
                                      width: 70.sp,
                                      height: 70.sp,
                                      decoration: BoxDecoration(
                                        color: lightMode
                                            ? AppColors.grey
                                            : AppColors.background,
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                      ),
                                      child: CustomSvgImage(
                                        assetPath:
                                            "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
                                        width: 35.sp,
                                        height: 35.sp,
                                        fit: BoxFit.scaleDown,
                                        color: AppColors.blackButton,
                                      ),
                                    ),
                                    // space
                                    SizedBox(width: 10.sp),
                                    // content Of Page
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // productID &  productType & supplierName  & category & subcategory
                                        sectionOne(),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // brand & model  & Maintenance Frequency  &  Quantity  &  Expected Lifetime
                                        sectionTwo(),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // In-Service Date &  Reorder Level / Quantity & Unit Cost  & Currency  & Storage Requirement  & Status
                                        sectionThree(),
                                      ],
                                    ),
                                  ],
                                )
                              : isTablet && !isLandscape
                                  ?
                                  // Vertical
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // image
                                        Container(
                                          width: 80.sp,
                                          height: 80.sp,
                                          decoration: BoxDecoration(
                                            color: lightMode
                                                ? AppColors.grey
                                                : AppColors.background,
                                            borderRadius:
                                                BorderRadius.circular(4.r),
                                          ),
                                          child: CustomSvgImage(
                                            assetPath:
                                                "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
                                            width: 40.sp,
                                            height: 40.sp,
                                            fit: BoxFit.scaleDown,
                                            color: AppColors.blackButton,
                                          ),
                                        ),

                                        // space
                                        SizedBox(width: 5.sp),

                                        // productID &  productType & supplierName  & category & subcategory
                                        sectionOne(),
                                        // space
                                        SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  .025,
                                        ),
                                        // brand & model  & Maintenance Frequency  &  Quantity  &  Expected Lifetime
                                        sectionTwo(),
                                        // space
                                        SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  .025,
                                        ),
                                        // In-Service Date &  Reorder Level / Quantity & Unit Cost  & Currency  & Storage Requirement  & Status
                                        sectionThree(),
                                      ],
                                    )
                                  :
                                  // Horizontal
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        // image
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 80.sp,
                                              height: 80.sp,
                                              decoration: BoxDecoration(
                                                color: lightMode
                                                    ? AppColors.grey
                                                    : AppColors.background,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  4.r,
                                                ),
                                              ),
                                              child: CustomSvgImage(
                                                assetPath:
                                                    "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
                                                width: 40.sp,
                                                height: 40.sp,
                                                fit: BoxFit.scaleDown,
                                                color: AppColors.blackButton,
                                              ),
                                            ),
                                            isTablet && isLandscape
                                                ? SizedBox(height: 5.sp)
                                                : SizedBox(),
                                            isTablet && isLandscape
                                                ? Text(
                                                    widget.productModel!
                                                        .productName.value,
                                                    style: StyleText
                                                        .fontSize14Weight400
                                                        .copyWith(
                                                      color: lightMode
                                                          ? AppColors
                                                              .blackButton
                                                          : AppColors.white,
                                                    ),
                                                  )
                                                : SizedBox(),
                                          ],
                                        ),

                                        // space
                                        SizedBox(width: 10.sp),

                                        // productID &  productType & supplierName  & category
                                        sectionOne(),

                                        SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  .1,
                                        ),

                                        // subcategory &  brand & model  & Maintenance Frequency: &  Quantity &  Expected Lifetime
                                        sectionTwo(),
                                        // space
                                        SizedBox(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  .1,
                                        ),
                                        // subcategory &  brand & model  & expectedLifetime
                                        sectionThree(),
                                      ],
                                    ),

                          SizedBox(height: 2.sp),

                          // name of product & Status
                          isTablet && !isLandscape
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Dell GS 15",
                                      style: StyleText.fontSize14Weight400
                                          .copyWith(
                                        color: AppColors.blackButton,
                                      ),
                                    ),
                                    isTablet && !isLandscape
                                        ? SizedBox(
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                .466,
                                          )
                                        : SizedBox(),
                                    isTablet && !isLandscape
                                        ? itemTextProduct(
                                            value: S.of(context).inStock,
                                            label: "${S.of(context).status}: ",
                                            valueStyle: StyleText
                                                .fontSize10Weight400
                                                .copyWith(
                                                    color: Color(0xff4BB609)),
                                          )
                                        : SizedBox(),
                                  ],
                                )
                              : SizedBox(),

                          // space
                          SizedBox(height: 15.sp),

                          // Additional Note
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 0.sp,
                              ), // or your global page padding
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            "${S.of(context).additionalNote}: ",
                                        style: isMobile
                                            ? StyleText.fontSize10Weight500
                                                .copyWith(
                                                color: AppColors.secondaryText,
                                              )
                                            : StyleText.fontSize12Weight500
                                                .copyWith(
                                                color: AppColors.secondaryText,
                                              ),
                                      ),
                                      TextSpan(
                                        text: widget
                                            .productModel!.additionalNote.value,
                                        style: isMobile
                                            ? StyleText.fontSize8Weight400
                                                .copyWith(
                                                color: AppColors.blackButton,
                                              )
                                            : StyleText.fontSize12Weight500
                                                .copyWith(
                                                color: AppColors.blackButton,
                                              ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.start,
                                  softWrap: true,
                                ),
                              ),
                            ),
                          ),

                          // space
                          SizedBox(height: 15.sp),

                          // Storage Location And Quantity
                          _buildStorageLocationSection(),

                          // space
                          SizedBox(height: 15.sp),
                          // Approval Cycle
                          Row(
                            children: [
                              Text(
                                "${S.of(context).approvalCycle}: ",
                                style: StyleText.fontSize12Weight400.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),

                          // space
                          SizedBox(height: 10.sp),

                          // Approval Cycle item
                          widget.productModel!.approvalCycle.isNotEmpty
                              ? (isMobile
                                  ? _buildApprovalCycleFromFirebase()
                                  : buildApprovalCycleRowFromFirebase())
                              : Container(
                                  padding: EdgeInsets.symmetric(vertical: 8.sp),
                                  child: SizedBox(),
                                ),
                        ],
                      ),
                    ),
                  ),

                // space
                SizedBox(height: 20.sp),

                // Filter Widget
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [filterSection(context)],
                      ),
                    ),
                  ],
                ),

                // space
                SizedBox(height: 15.sp),

                // Search and DropDown Department
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
                    SizedBox(width: ButtonSizing.toolbarGap(context)),
                    // Department
                    isMobile
                        ? customButtonWithSvg(
                            title: "",
                            function: () {},
                            textStyle: StyleText.fontSize8Weight400,
                            height: 38.sp,
                            space: 8.sp,
                            radius: 8.r,
                            color: lightMode
                                ? AppColors.secondaryPrimary
                                : AppColors.chatBackground,
                            image: "",
                            widthImage: 23.sp,
                            heightImage: 23.sp,
                            svgColor: lightMode
                                ? AppColors.blackButton
                                : AppColors.grey,
                            colorBorder: Colors.transparent,
                          )
                        : SizedBox(
                            width: 135.sp,
                            child: CustomDropdown<String>(
                              items: (departments)
                                  .map((e) => DropdownItem<String>(
                                      value: e['key'] ?? '',
                                      label: e['value'] ?? ''))
                                  .toList(),
                              value: selectedDepartment,
                              onChanged: (value) {
                                setState(() {
                                  selectedDepartment = value;
                                });
                              },
                              hint: selectedLabel == "allocated"
                                  ? S.of(context).department
                                  : S.of(context).branch,
                              height: 38.sp,
                              fillColor: AppColors.card,
                            ),
                          ),
                  ],
                ),
                // space
                SizedBox(height: 10.sp),

                if (selectedLabel == "Stock")
                  buildStockCenteredWidget()
                else if (selectedLabel == "Damaged")
                  buildDamageWidget()
                else if (selectedLabel == "Missing")
                  buildDamageWidget()
                else if (selectedLabel == "Stolen")
                  buildDamageWidget()
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: CrossAxisCountHelper
                          .getCrossAxisCountForDefaultTablet2(
                        context,
                      ),
                      crossAxisSpacing: 15.sp,
                      mainAxisSpacing: 15.sp,
                      mainAxisExtent: 116.sp,
                    ),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final item = ConstantData.supplierDummyData[index];
                      return GestureDetector(
                        onTap: () {
                          navigateTo(context, AllocatedDetailsEmployeeToggle());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10.sp),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // image
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image(
                                          image: AssetImage(
                                            "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
                                          ),
                                          width: 40.sp,
                                          height: 40.sp,
                                          fit: BoxFit.scaleDown,
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 5.sp),
                                    // info
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'],
                                          style: StyleText.fontSize14Weight500
                                              .copyWith(
                                            color: AppColors.blackButton,
                                          ),
                                        ),
                                        SizedBox(height: 0.sp),
                                        Text(
                                          item['department'].toString(),
                                          style: StyleText.fontSize10Weight500
                                              .copyWith(
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                        SizedBox(height: 0.sp),
                                        Text(
                                          item['title'].toString(),
                                          style: StyleText.fontSize10Weight500
                                              .copyWith(
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),

                                    Spacer(),

                                    // lastUpdate
                                    itemTextProduct(
                                      labelStyle:
                                          StyleText.fontSize8Weight400.copyWith(
                                        color: AppColors.secondaryText,
                                      ),
                                      valueStyle:
                                          StyleText.fontSize8Weight400.copyWith(
                                        color: AppColors.blackButton,
                                      ),
                                      value: item["lastUpdate"],
                                      label: "${S.of(context).lastUpdate}: ",
                                    ),
                                  ],
                                ),

                                SizedBox(height: 13.sp),

                                // Assigned Date & Return Date & quantityAssigned & location
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        itemTextProduct(
                                          label:
                                              "${S.of(context).assignedDate}: ",
                                          value: item["assignedDate"],
                                        ),
                                        SizedBox(height: 5.sp),
                                        itemTextProduct(
                                          label:
                                              "${S.of(context).quantityAssigned}: ",
                                          value: item["quantity"],
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        itemTextProduct(
                                          label:
                                              "${S.of(context).returnDate}: ",
                                          value: item["returnDate"],
                                        ),
                                        SizedBox(height: 5.sp),
                                        itemTextProduct(
                                          label: "${S.of(context).location}: ",
                                          value: item["location"],
                                        ),
                                      ],
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

                SizedBox(height: 15.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //////////////////////////// storage location and requirement //////////////////////////

  Widget _buildStorageLocationSection() {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isMobile = context.isPhone;

    List<Map<String, dynamic>> storageData = [];
    final location = widget.productModel!.storageLocation.value;

    if (location.isNotEmpty) {
      if (location.contains(' | ')) {
        List<String> parts = location.split(' | ');
        if (parts.length == 2) {
          String locationsString = parts[0];
          String quantity = parts[1];

          // Split by "Room" to separate different rooms
          List<String> roomSections = locationsString.split(
            RegExp(r'(?=Room)'),
          );
          roomSections.removeWhere((section) => section.trim().isEmpty);

          if (roomSections.length > 1) {
            for (String roomSection in roomSections) {
              String cleanRoom =
                  roomSection.replaceAll('/', '').replaceAll(';', '').trim();
              if (cleanRoom.isNotEmpty) {
                storageData.add({'location': cleanRoom, 'quantity': quantity});
              }
            }
          } else {
            // Fallback to split by '/' if no multiple "Room" found
            if (locationsString.contains('/')) {
              List<String> locations = locationsString.split('/');
              for (String loc in locations) {
                String cleanLoc = loc.replaceAll(';', '').trim();
                if (cleanLoc.isNotEmpty) {
                  storageData.add({'location': cleanLoc, 'quantity': quantity});
                }
              }
            } else {
              storageData.add({
                'location': locationsString.replaceAll(';', '').trim(),
                'quantity': quantity,
              });
            }
          }
        }
      } else {
        // Handle case where there's no quantity separator but might have multiple rooms
        List<String> roomSections = location.split(RegExp(r'(?=Room)'));
        roomSections.removeWhere((section) => section.trim().isEmpty);

        if (roomSections.length > 1) {
          for (String roomSection in roomSections) {
            String cleanRoom =
                roomSection.replaceAll('/', '').replaceAll(';', '').trim();
            if (cleanRoom.isNotEmpty) {
              storageData.add({
                'location': cleanRoom,
                'quantity': widget.productModel!.quantity.value,
              });
            }
          }
        } else {
          storageData.add({
            'location': location.replaceAll(';', ''),
            'quantity': widget.productModel!.quantity.value,
          });
        }
      }
    }

    if (storageData.isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "${S.of(context).storageLocationAndQuantity}: ",
                style: isMobile
                    ? StyleText.fontSize10Weight500.copyWith(
                        color: AppColors.secondaryText,
                      )
                    : StyleText.fontSize12Weight400.copyWith(
                        color: AppColors.secondaryText,
                      ),
              ),
              TextSpan(
                text: "No storage location defined",
                style: isMobile
                    ? StyleText.fontSize8Weight400.copyWith(
                        color: AppColors.secondaryText,
                      )
                    : StyleText.fontSize12Weight400.copyWith(
                        color: AppColors.secondaryText,
                      ),
              ),
            ],
          ),
          textAlign: TextAlign.start,
          softWrap: true,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title
        Text(
          "${S.of(context).storageLocationAndQuantity}: ",
          style: isMobile
              ? StyleText.fontSize10Weight500.copyWith(
                  color: AppColors.secondaryText,
                )
              : StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
        ),

        // Storage locations containers on the same line
        Expanded(
          child: Wrap(
            spacing: 10.sp,
            runSpacing: 8.sp,
            children: storageData.map((item) {
              return GestureDetector(
                onTap: () {
                  navigateTo(context, StorageLocationDetails());
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.sp,
                    vertical: 4.sp,
                  ),
                  decoration: BoxDecoration(
                    color: lightMode
                        ? const Color(0xffF5F5F5)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    '${item['location']} | ${item['quantity']}',
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.blackButton,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  //////////////////////////// storage location and requirement //////////////////////////

  //////////////////////////// Approval ///////////////////////////////

  Widget _buildApprovalCycleFromFirebase() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final approvalCycle = widget.productModel!.approvalCycle;

    if (approvalCycle.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8.sp),
        child: Text(
          "No approval cycle defined",
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(approvalCycle.length, (index) {
        final approver = approvalCycle[index];

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index > 0)
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20.sp,
                      right: 15.sp,
                      bottom: 0.sp,
                    ),
                    child: CustomPaint(
                      size: Size(0, 80),
                      painter: CurvedArrowPainter(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.blackButton
                            : AppColors.whiteShadow,
                        isArabic: isArabic,
                      ),
                    ),
                  )
                else
                  SizedBox(width: 2.sp),
                Padding(
                  padding: EdgeInsets.only(top: 14.sp),
                  child: Container(
                    width: 32.sp,
                    height: 32.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.transparent, width: 2.w),
                    ),
                    child: ClipOval(
                      child: CustomSvgImage.natural(
                        assetPath: (approver.gender?.toLowerCase() == "male")
                            ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'
                            : 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png',
                        fit: BoxFit.scaleDown,
                        width: 28.sp,
                        height: 28.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.sp),
                Padding(
                  padding: EdgeInsets.only(top: 12.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FormatHelper.capitalize(
                          isArabic
                              ? "${approver.firstNameInArabic ?? approver.firstName ?? ''} ${approver.lastNameInArabic ?? approver.lastName ?? ''}"
                              : "${approver.firstName ?? ''} ${approver.lastName ?? ''}",
                        ),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blackButton,
                        ),
                      ),
                      Text(
                        FormatHelper.capitalize(
                          isArabic
                              ? approver.titleInArabic ?? approver.title ?? ''
                              : approver.title ?? '',
                        ),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
          ],
        );
      }),
    );
  }

  //////////////////////////////// Approval Cycle from Firebase - Tablet/Desktop //////////////////////////////
  Widget buildApprovalCycleRowFromFirebase() {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final theme = Theme.of(context).brightness == Brightness.light;
    final approvalCycle = widget.productModel!.approvalCycle;

    if (approvalCycle.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8.sp),
        child: Text(
          "No approval cycle defined",
          style: StyleText.fontSize12Weight400.copyWith(
            color: theme ? AppColors.secondaryText : AppColors.grey,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.sp),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 5.sp,
        runSpacing: 0.sp,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: List.generate(approvalCycle.length * 2 - 1, (i) {
          if (i.isEven) {
            final index = i ~/ 2;
            final approver = approvalCycle[index];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: CustomSvgImage.natural(
                      assetPath: (approver.gender?.toLowerCase() == "male")
                          ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'
                          : 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png',
                      semanticsLabel: 'Gender Icon',
                      fit: BoxFit.cover,
                      width: 40.sp,
                      height: 40.sp,
                    ),
                  ),
                ),
                SizedBox(width: 6.sp),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FormatHelper.capitalize(
                        isEnglish
                            ? "${approver.firstName ?? ''} ${approver.lastName ?? ''}"
                            : "${approver.firstNameInArabic ?? approver.firstName ?? ''} ${approver.lastNameInArabic ?? approver.lastName ?? ''}",
                      ),
                      style: StyleText.fontSize10Weight500.copyWith(
                        color: theme ? AppColors.blackButton : AppColors.white,
                      ),
                    ),
                    Text(
                      FormatHelper.capitalize(
                        isEnglish
                            ? approver.title ?? ''
                            : approver.titleInArabic ?? approver.title ?? '',
                      ),
                      style: StyleText.fontSize10Weight500.copyWith(
                        color: theme ? AppColors.secondaryText : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            return Transform.rotate(
              angle: isEnglish ? 0 : 3.1416,
              child: CustomSvgImage.natural(
                assetPath:
                    "assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg",
                width: 25.sp,
                color: theme ? AppColors.text : AppColors.whiteShadow,
              ),
            );
          }
        }),
      ),
    );
  }

  //////////////////////////// Approval ///////////////////////////////

  //////////////////////////// Section One ///////////////////////////////////

  Widget sectionOne() {
    var model = widget.productModel;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemTextProduct(
          value: model!.productId.value,
          label: "${S.of(context).productID}: ",
        ),
        SizedBox(height: 7.sp),
        itemTextProduct(
          value: model.category.value,
          label: "${S.of(context).productType}: ",
        ),
        SizedBox(height: 7.sp),
        GestureDetector(
          onTap: () {
            navigateTo(context, SupplierDetails());
          },
          child: itemTextProduct(
            value: model.supplierName.value,
            label: "${S.of(context).supplierName}: ",
            valueStyle: StyleText.fontSize11Weight400.copyWith(
              color: Color(0xff347AE2),
            ),
          ),
        ),
        SizedBox(height: 7.sp),
        itemTextProduct(
          value: model.category.value,
          label: "${S.of(context).category}: ",
        ),
      ],
    );
  }

  //////////////////////////// Section One ///////////////////////////////////

  //////////////////////////// Section Two ///////////////////////////////////

  Widget sectionTwo() {
    var model = widget.productModel;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemTextProduct(
          value: model!.subCategory.value,
          label: "${S.of(context).subcategory}: ",
        ),
        SizedBox(height: 7.sp),
        itemTextProduct(
          value: model.brand.value,
          label: "${S.of(context).brand}: ",
        ),
        SizedBox(height: 7.sp),
        itemTextProduct(
          value: model.model.value,
          label: "${S.of(context).model}: ",
        ),
        SizedBox(height: 7.sp),
        itemTextProduct(
          value: model.maintenanceFrequency.value,
          label: "${S.of(context).maintenanceFrequency}: ",
        ),
        SizedBox(height: 7.sp),
        itemTextProduct(
          value: model.quantity.value,
          label: "${S.of(context).quantity}: ",
        ),
        SizedBox(height: 7.sp),
        itemTextProduct(
          value: model.expectedLifetime.value,
          label: "${S.of(context).expectedLifetime}: ",
        ),
      ],
    );
  }

  //////////////////////////// Section Two ///////////////////////////////////

  //////////////////////////// Section Three ///////////////////////////////////

  Widget sectionThree() {
    var model = widget.productModel;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemTextProduct(
          value: DateFormat('yyyy-MM-dd').format(model!.reorderLevel.timestamp),
          label: "${S.of(context).inServiceDate}: ",
        ),
        SizedBox(height: 7.sp),
        itemTextProduct(
          value: model.reorderLevel.value,
          label: "${S.of(context).reorderLevel}: ",
        ),
        SizedBox(height: 7.sp),
        itemTextProduct(
          value: model.unitCost.value,
          label: "${S.of(context).unitCost}: ",
        ),
        SizedBox(height: 7.sp),
        itemTextProduct(
          value: model.currency.value,
          label: "${S.of(context).currency}: ",
        ),
        SizedBox(height: 7.sp),
        itemTextProduct(
          value: model.storageRequirement.value,
          label: "${S.of(context).storageRequirement}: ",
        ),
        SizedBox(height: 7.sp),
        itemTextProduct(
          value: "In Stock",
          label: "${S.of(context).status}: ",
          valueStyle: StyleText.fontSize12Weight400.copyWith(
            color: Color(0xff4BB609),
          ),
        ),
      ],
    );
  }

  //////////////////////////// Section Three ///////////////////////////////////

  //////////////////////////////// Warranty Button //////////////////////////////

  Widget warrantyCustom(VoidCallback onTap) {
    final isMobile = context.isPhone;
    return customButtonWithSvg(
      title: S.current.warranty,
      function: () => _showImagePreviewDialog(
        context,
        widget.productModel!.productWarrantyImage.value,
        S.current.warranty,
      ), // Updated this line
      width: isMobile ? 120.sp : 135.sp,
      height: 38.sp,
      color: AppColors.primary,
      textStyle: isMobile
          ? StyleText.fontSize14Weight500.copyWith(
              color: AppColors.textButton,
            )
          : StyleText.fontSize16Weight500.copyWith(
              color: AppColors.textButton,
            ),
      radius: 8.r,
      heightImage: 16.sp,
      widthImage: 16.sp,
      svgColor: AppColors.textButton,
      image:
          "assets/icons_assets/main_icons_assets/ic_hr_insurance_document.svg",
      space: 8.sp,
      colorBorder: Colors.transparent,
    );
  }

  //////////////////////////////// Warranty Button //////////////////////////////

  /////////////////////////////// Specification Button //////////////////////////

  Widget specificationCustom(VoidCallback onTap) {
    final isMobile = context.isPhone;
    return customButtonWithSvg(
      title: S.current.specification,
      function: () => _showImagePreviewDialog(
        context,
        widget.productModel!.productSpecificationImage.value,
        S.current.specification,
      ), // Updated this line
      width: isMobile ? 120.sp : 135.sp,
      height: 38.sp,
      color: AppColors.primary,
      textStyle: isMobile
          ? StyleText.fontSize14Weight500.copyWith(
              color: AppColors.textButton,
            )
          : StyleText.fontSize16Weight500.copyWith(
              color: AppColors.textButton,
            ),
      radius: 8.r,
      heightImage: 16.sp,
      widthImage: 16.sp,
      svgColor: AppColors.textButton,
      image:
          "assets/icons_assets/main_icons_assets/ic_file_document_description.svg",
      space: 8.sp,
      colorBorder: Colors.transparent,
    );
  }

  /////////////////////////////// Specification Button //////////////////////////

  /////////////////////////////// helper view image ////////////////////////////

  void _showImagePreviewDialog(
    BuildContext context,
    String imageUrl,
    String title,
  ) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    // Check if image URL is empty or null
    if (imageUrl.isEmpty) {
      _showNoImageDialog(context, title);
      return;
    }

    showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20.sp),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with title and close button
                Container(
                  padding: EdgeInsets.all(16.sp),
                  decoration: BoxDecoration(
                    color: lightMode ? AppColors.grey : AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                      GestureDetector(
                        onTapDown: (_) => HapticController.high(),
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.all(4.sp),
                          child: Icon(
                            Icons.close,
                            size: 20.sp,
                            color: AppColors.blackButton,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Image container
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(16.sp),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            height: 200.sp,
                            child: Center(
                              child: CircleProgressMaster.inline(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return SizedBox(
                            height: 200.sp,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48.sp,
                                  color: AppColors.secondaryText,
                                ),
                                SizedBox(height: 8.sp),
                                Text(
                                  "Failed to load image",
                                  style: StyleText.fontSize14Weight400.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                SizedBox(height: 4.sp),
                                Text(
                                  "Please check your internet connection",
                                  style: StyleText.fontSize12Weight400.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add this method for when there's no image available:
  void _showNoImageDialog(BuildContext context, String title) {
    showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Container(
            width: 300.sp,
            padding: EdgeInsets.all(20.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 48.sp,
                  color: AppColors.secondaryText,
                ),
                SizedBox(height: 16.sp),
                Text(
                  "No $title Available",
                  style: StyleText.fontSize16Weight600.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 8.sp),
                Text(
                  "There is no $title image uploaded for this product.",
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 20.sp),
                GestureDetector(
                  onTapDown: (_) => HapticController.low(),
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    height: 40.sp,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        "OK",
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /////////////////////////////// helper view image ////////////////////////////

  /////////////////////////////// Edit Button //////////////////////////

  Widget editCustom(VoidCallback onTap) {
    final isMobile = context.isPhone;
    return customButtonWithSvg(
      title: S.current.edit,
      function: () => _navigateToEditFlow(), // Modified this line
      width: isMobile ? 120.sp : 135.sp,
      height: 38.sp,
      color: AppColors.primary,
      textStyle: isMobile
          ? StyleText.fontSize14Weight500.copyWith(
              color: AppColors.textButton,
            )
          : StyleText.fontSize16Weight500.copyWith(
              color: AppColors.textButton,
            ),
      radius: 8.r,
      heightImage: 16.sp,
      widthImage: 16.sp,
      svgColor: AppColors.textButton,
      image: "assets/icons_assets/main_icons_assets/ic_action_edit.svg",
      space: 8.sp,
      colorBorder: Colors.transparent,
    );
  }

  void _navigateToEditFlow() {
    navigateTo(
      context,
      AddingProductAssetsDesktopScreen(
        orderData: _createOrderDataFromProduct(widget.productModel!),
        isConsumable: _isConsumable(widget.productModel!),
        isMultiProduct: false,
        currentProductIndex: 0,
        productModels: [widget.productModel!],
        isEditMode: true, // ✅ Add this
      ),
    );
  }

  Map<String, dynamic> _createOrderDataFromProduct(ProductModel product) {
    return {
      "orderId": product.orderId.value,
      "orderDate": product.orderDate.value,
      "receivingDate": product.receivingDate.value,
      "productNames": [product.productName.value],
      "products": [
        {
          "orderId": product.orderId.value,
          "productId": product.productId.value,
          "productName": product.productName.value,
          "category": product.category.value,
          "subcategory": product.subCategory.value,
          "brand": product.brand.value,
          "model": product.model.value,
          "quantity": product.quantity.value,
          "unitCost": product.unitCost.value,
          "currency": product.currency.value,
          "supplierName": product.supplierName.value,
          "usageFrequency": product.usageFrequency.value,
          "unitOfMeasurement": product.unitOfMeasurement.value,
          "status": product.status.value,
          "orderDate": product.orderDate.value,
          "receivingDate": product.receivingDate.value,
          "type": product.category.value, // Assuming type is category
        },
      ],
    };
  }

  bool _isConsumable(ProductModel product) {
    return product.usageFrequency.value.trim().isNotEmpty;
  }

  /////////////////////////////// Edit Button //////////////////////////

  /////////////////////////////// Restock Popup Button //////////////////

  Widget restockCustom(BuildContext context) {
    final isMobile = context.isPhone;
    return CustomPopupMenuButton(
      title: S.of(context).restock,
      width: isMobile ? 120.sp : 135.sp,
      iconPath:
          "assets/icons_assets/main_icons_assets/ic_data_inventory_consumables.svg",
      backgroundColor: AppColors.primary,
      iconColor: AppColors.textButton,
      onSelected: (value) {
        if (value == 'existing') {
          isMobile
              ? navigateTo(context, ExistingPatchScreen())
              : showAppDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (_) => const RestockExistingDialog(),
                );
        } else if (value == 'new') {
          isMobile
              ? navigateTo(context, NewPatchScreen())
              : showAppDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => const RestockNewBatchDialog(),
                );
        }
      },
      options: [
        PopupOption(value: 'existing', label: S.of(context).existingBatch),
        PopupOption(value: 'new', label: S.of(context).newBatch),
      ],
    );
  }

  /////////////////////////////// Restock Popup Button //////////////////

  //////////////////////////////// Stock Section ////////////////////////////////
  Widget buildStockCenteredWidget() {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final List<String> roomFilters = ['All', 'Warehouse', 'Room 13'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Filter Row
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: roomFilters.map((room) {
            final bool isSelected = room == selectedRoom;

            return Padding(
              padding: EdgeInsets.only(right: 8.sp),
              child: GestureDetector(
                onTapDown: (_) => HapticController.low(),
                onTap: () {
                  setState(() {
                    selectedRoom = room;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.card,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.sp,
                    vertical: 8.sp,
                  ),
                  child: Center(
                    child: Text(
                      room,
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: isSelected
                            ? AppColors.blackButton // ✅ black text on yellow
                            : AppColors.blackButton,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // space
        SizedBox(height: 15.sp),

        GridView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
              context,
            ),
            crossAxisSpacing: 15.sp,
            mainAxisExtent: 115.sp,
            mainAxisSpacing: 15.sp,
          ),
          itemCount: 3,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                navigateTo(context, AssignProduct());
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.sp),
                  child: Column(
                    children: [
                      // image and name & Condition
                      Row(
                        children: [
                          // image
                          Column(
                            children: [
                              Container(
                                width: 40.sp,
                                height: 40.sp,
                                decoration: BoxDecoration(
                                  color: lightMode
                                      ? AppColors.grey
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: CustomSvgImage(
                                  assetPath:
                                      "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
                                  width: 20.sp,
                                  color: AppColors.blackButton,
                                  height: 20.sp,
                                  fit: BoxFit.scaleDown,
                                ),
                              ),
                            ],
                          ),

                          // space
                          SizedBox(width: 5.sp),

                          // Name of Product & Condition
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Name of Product as ( Dell GS 15 )
                              Text(
                                "Dell GS 15",
                                style: StyleText.fontSize14Weight400.copyWith(
                                  color: AppColors.blackButton,
                                ),
                              ),
                              // space
                              SizedBox(height: 5.sp),
                              // Condition Label
                              itemTextProduct(
                                label: "${S.of(context).condition}: ",
                                value: "New",
                                labelStyle:
                                    StyleText.fontSize12Weight400.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                                valueStyle:
                                    StyleText.fontSize12Weight400.copyWith(
                                  color: AppColors.blackButton,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 5.sp),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Maintenance Schedule
                          itemTextProduct(
                            label: "${S.of(context).maintenanceSchedule}: ",
                            value: "23 Feb 2024",
                          ),

                          // space
                          SizedBox(height: 10.sp),

                          // Maintenance Frequency & Assign Button
                          Row(
                            children: [
                              itemTextProduct(
                                label:
                                    "${S.of(context).maintenanceFrequency}: ",
                                value: "Bi-Monthly",
                              ),
                              Spacer(),
                              customButton(
                                title: S.of(context).assign,
                                function: () {},
                                color: AppColors.primary,
                                radius: 4.r,
                                height: 23.sp,
                                width: 61.sp,
                                textStyle:
                                    StyleText.fontSize10Weight500.copyWith(
                                  color: AppColors.textButton,
                                ),
                              ),
                            ],
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
      ],
    );
  }
  //////////////////////////////// Stock Section ////////////////////////////////

  //////////////////////////////// Damage Section ////////////////////////////////
  Widget buildDamageWidget() {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
              context,
            ),
            crossAxisSpacing: 15.sp,
            mainAxisExtent: 115.sp,
            mainAxisSpacing: 15.sp,
          ),
          itemCount: 3,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                navigateTo(context, AllocatedDetailsEmployeeToggle());
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.sp),
                  child: Column(
                    children: [
                      // image and name & Condition
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // image
                          Column(
                            children: [
                              Container(
                                width: 50.sp,
                                height: 50.sp,
                                decoration: BoxDecoration(
                                  color: lightMode
                                      ? AppColors.grey
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Center(
                                  child: CustomSvgImage(
                                    assetPath:
                                        "assets/icons_assets/main_icons_assets/ic_data_inventory_assets.svg",
                                    width: 40.sp,
                                    color: AppColors.blackButton,
                                    height: 40.sp,
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // space
                          SizedBox(width: 5.sp),

                          // Request ID & Asset ID & Assigned To
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Request ID
                              itemTextProduct(
                                label: S.of(context).requestID,
                                value: "011000000",
                              ),
                              // space
                              SizedBox(height: 5.sp),
                              // Asset ID
                              itemTextProduct(
                                label: S.of(context).assetId,
                                value: "011000000",
                              ),
                              // space
                              SizedBox(height: 5.sp),
                              // Assigned To
                              itemTextProduct(
                                label: S.of(context).assignedTo,
                                value: "Moataz Handousa",
                              ),
                            ],
                          ),

                          // space
                          Spacer(),

                          itemTextProduct(
                            label: S.of(context).missingDate,
                            value: "28 May 2020",
                          ),
                        ],
                      ),

                      // space
                      SizedBox(height: 5.sp),

                      // Action Taken  &  Quantity
                      Row(
                        children: [
                          // Action Taken
                          itemTextProduct(
                            label: "${S.of(context).actionTaken}: ",
                            value: "Notify Security",
                          ),
                          // space
                          SizedBox(width: 80.sp),
                          // Quantity
                          itemTextProduct(
                            label: "${S.of(context).quantity}: ",
                            value: "12",
                          ),
                        ],
                      ),
                      // space
                      SizedBox(height: 7.sp),
                      // Last Seen Location
                      Row(
                        children: [
                          itemTextProduct(
                            label: "${S.of(context).lastSeenLocation}: ",
                            value: "Ahmed Salem",
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
      ],
    );
  }
  //////////////////////////////// Stock Section ////////////////////////////////

  ////////////////////////// item in any Container /////////////////////////////
  Widget itemTextProduct({
    required String label,
    required String value,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          FormatHelper.capitalize(label),
          style: labelStyle ??
              StyleText.fontSize10Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
        ),
        Text(
          FormatHelper.capitalize(value),
          style: valueStyle ??
              StyleText.fontSize8Weight400.copyWith(
                color: AppColors.blackButton,
              ),
        ),
      ],
    );
  }
  ////////////////////////// item in any Container /////////////////////////////

  //////////////////////////////// Approval Cycle  Tablet //////////////////////////////
  Widget buildApprovalCycleRow(ApprovalSection section) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final theme = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.sp),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 5.sp,
        runSpacing: 0.sp,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: List.generate(section.selectedApprovers.length * 2 - 1, (i) {
          if (i.isEven) {
            final index = i ~/ 2;
            final employee = section.selectedApprovers[index];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: CustomSvgImage.natural(
                      assetPath: employee.gender == "male"
                          ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'
                          : 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png',
                      semanticsLabel: 'Gender Icon',
                      fit: BoxFit.cover,
                      width: 40.sp,
                      height: 40.sp,
                    ),
                  ),
                ),
                SizedBox(width: 6.sp),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FormatHelper.capitalize(
                        isEnglish
                            ? "${employee.firstName} ${employee.lastName}"
                            : "${employee.firstNameInArabic} ${employee.lastNameInArabic}",
                      ),
                      style: StyleText.fontSize10Weight500.copyWith(
                        color: theme ? AppColors.blackButton : AppColors.white,
                      ),
                    ),
                    Text(
                      FormatHelper.capitalize(
                        isEnglish
                            ? employee.title ?? ''
                            : employee.titleInArabic ?? '',
                      ),
                      style: StyleText.fontSize10Weight500.copyWith(
                        color: theme ? AppColors.secondaryText : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            return Transform.rotate(
              angle: isEnglish ? 0 : 3.1416,
              child: CustomSvgImage.natural(
                assetPath:
                    "assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg",
                width: 25.sp,
                color: theme ? AppColors.text : AppColors.whiteShadow,
              ),
            );
          }
        }),
      ),
    );
  }

  //////////////////////////////// Approval Cycle  Tablet //////////////////////////////

  //////////////////////////////// Approval Cycle  Mobile //////////////////////////////
}

/////////////////////////////////// Approval //////////////////////////////////////////
class Approver {
  final String firstName;
  final String lastName;
  final String firstNameInArabic;
  final String lastNameInArabic;
  final String title;
  final String titleInArabic;
  final String gender;

  Approver({
    required this.firstName,
    required this.lastName,
    required this.firstNameInArabic,
    required this.lastNameInArabic,
    required this.title,
    required this.titleInArabic,
    required this.gender,
  });
}

class ApprovalSection {
  final GlobalKey iconKey = GlobalKey();
  final LayerLink layerLink = LayerLink();
  OverlayEntry? overlayEntry;
  String? selectedRequestType;
  TextEditingController searchController = TextEditingController();
  GlobalKey tooltipIconKey = GlobalKey();

  List<EmployeeEntity> selectedApprovers;

  ApprovalSection({
    this.selectedRequestType,
    this.selectedApprovers = const [],
  });
}
/////////////////////////////////// Approval //////////////////////////////////////////

////////////////////////////////// Restock Existing ////////////////////////////////////
class RestockExistingDialog extends StatefulWidget {
  const RestockExistingDialog({super.key});

  @override
  State<RestockExistingDialog> createState() => _RestockExistingDialogState();
}

class _RestockExistingDialogState extends State<RestockExistingDialog> {
  /////////////////////////// Controller ////////////////////////////////////

  TextEditingController orderIDController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  /////////////////////////// Controller ////////////////////////////////////

  /////////////////////////////////////// storage location //////////////////////
  // Default storage location (shown alone first)
  String? defaultStorageLocation;
  final List<Map<String, String>> storageLocations = [
    {"key": "roomA", "value": "Room A"},
    {"key": "roomB", "value": "Room B"},
    {"key": "roomC", "value": "Room C"},
  ];
  /////////////////////////////////////// storage location //////////////////////

  ////////////////////////////////////// Pick File //////////////////////////////

  PlatformFile? invoiceFile;
  Future<void> pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        invoiceFile = result.files.first;
      });
    }
  }

  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    return '${(bytes / 1024).ceil()} KB';
  }

  Widget buildFilePreview(
    PlatformFile file,
    DateTime uploadDate,
    VoidCallback onRemove,
  ) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    String size = formatBytes(file.size);
    String formattedDate = "${uploadDate.day.toString().padLeft(2, '0')}/"
        "${uploadDate.month.toString().padLeft(2, '0')}/"
        "${uploadDate.year}";

    return Container(
      width: 283.sp,
      height: 60.sp,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.secondaryText,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          // image
          Padding(
            padding: EdgeInsets.all(6.sp),
            child: kIsWeb
                ? Image.memory(
                    file.bytes!,
                    width: 36.sp,
                    height: 36.sp,
                    fit: BoxFit.cover,
                  )
                : (file.path != null
                    ? Image.file(
                        File(file.path!),
                        width: 36.sp,
                        height: 36.sp,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox()),
          ),

          // space
          SizedBox(width: 10.sp),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // file name
                Text(
                  FormatHelper.capitalize(file.name),
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                // space
                SizedBox(height: 5.sp),
                Text(
                  size,
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          // Remove button & Date
          Padding(
            padding: EdgeInsets.all(10.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTapDown: hapticDown(onRemove, HapticLevel.high),
                  onTap: onRemove,
                  child: CustomSvgImage.natural(
                    assetPath:
                        "assets/icons_assets/main_icons_assets/ic_editor_decrease.svg",
                    width: 12.sp,
                    height: 12.sp,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                Spacer(),
                Text(
                  "Date: $formattedDate",
                  style: StyleText.fontSize10Weight400.copyWith(
                    color:
                        lightMode ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////// Pick File //////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: 600.sp,
        height: 430.sp,
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with image
            Row(
              children: [
                // image
                Container(
                  width: 30.sp,
                  height: 30.sp,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomSvgImage(
                      assetPath:
                          "assets/icons_assets/main_icons_assets/ic_action_plus.svg",
                      width: 19.sp,
                      height: 19.sp,
                      color: AppColors.textButton,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
                // space
                SizedBox(width: 8.sp),
                // Restocking Existing Batch
                Text(
                  S.of(context).existingBatchRestockTitle,
                  style: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
              ],
            ),
            // space
            SizedBox(height: 20.sp),

            // Order ID and Quantity
            Row(
              children: [
                Expanded(
                  child: CustomValidatedTextFieldMaster(
                    label: S.of(context).orderID,
                    hint: S.of(context).orderID,
                    height: 36.sp,
                    controller: orderIDController,
                    onlyDigits: false,
                    textDirection: ui.TextDirection.ltr,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(width: 15.sp),
                Expanded(
                  child: CustomValidatedTextFieldMaster(
                    label: S.of(context).quantity,
                    hint: S.of(context).quantity,
                    height: 36.sp,
                    controller: quantityController,
                    textDirection: ui.TextDirection.ltr,
                    onlyDigits: false,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),

            SizedBox(height: 15.sp),

            // Storage Location
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // storage Location
                Text(
                  S.of(context).storageLocation,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                // space
                SizedBox(height: 8.sp),
                // Dropdown of storage Location
                SizedBox(
                  width: 280.sp,
                  child: CustomDropdown<String>(
                    items: (storageLocations)
                        .map((e) => DropdownItem<String>(
                            value: e['key'] ?? '', label: e['value'] ?? ''))
                        .toList(),
                    value: defaultStorageLocation,
                    onChanged: (val) {
                      setState(() {
                        defaultStorageLocation = val;
                      });
                    },
                    hint: S.of(context).selectStorageLocation,
                    height: 36.sp,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.sp),

            // + Storage Button
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                customButtonWithSvg(
                  title: S.of(context).storage,
                  function: () {},
                  textStyle: StyleText.fontSize14Weight500.copyWith(
                    color: AppTheme.readableOn(AppColors.blackButton),
                  ),
                  width: 100.sp,
                  height: 30.sp,
                  space: 8.sp,
                  radius: 4.r,
                  color: AppColors.blackButton,
                  svgColor: AppTheme.readableOn(AppColors.blackButton),
                  image:
                      "assets/icons_assets/main_icons_assets/ic_action_plus.svg",
                  widthImage: 12.sp,
                  heightImage: 12.sp,
                  colorBorder: Colors.transparent,
                ),
              ],
            ),

            SizedBox(height: 27.sp),

            // Invoice title
            Text(
              S.of(context).invoice,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.blackButton,
              ),
            ),

            SizedBox(height: 8.sp),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                invoiceFile == null
                    ? customButtonWithSvg(
                        title: S.of(context).upload,
                        function: () => pickFile('warranty'),
                        textStyle: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                        width: 170.sp,
                        height: 35.sp,
                        space: 16.sp,
                        radius: 4.r,
                        color: AppColors.primary,
                        svgColor: AppColors.textButton,
                        image:
                            "assets/icons_assets/main_icons_assets/ic_upload.svg",
                        widthImage: 16.sp,
                        heightImage: 16.sp,
                        colorBorder: Colors.transparent,
                      )
                    : buildFilePreview(invoiceFile!, DateTime.now(), () {
                        setState(() {
                          invoiceFile = null;
                        });
                      }),
              ],
            ),

            Spacer(),

            // Discard & Submit
            Row(
              textDirection: TextDirection
                  .ltr, // X-73: Cancel left, action right in both languages

              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ✅ Discard
                customButton(
                  title: S.of(context).discard,
                  function: () {
                    Navigator.pop(context);
                  },
                  textStyle: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                  width: 150.sp,
                  height: 38.sp,
                  radius: 8.r,
                  color: AppColors.grey,
                ),

                // ✅ Next
                customButton(
                  title: S.of(context).submit,
                  function: () async {
                    final confirmed =
                        await _showConfirmDialog(); // show confirm dialog
                    if (confirmed) {
                      if (!context.mounted) return;
                      await _showSuccessDialog(
                        context,
                      ); // show success dialog if Yes
                      if (!context.mounted) return;
                      Navigator.pop(
                        context,
                      ); // then close the original Restock dialog
                    }
                  },
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textButton,
                  ),
                  width: 150.sp,
                  height: 38.sp,
                  radius: 8.r,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////// Dialog Verify  //////////////////////////////

  Future<bool> _showConfirmDialog() async {
    final result = await showAppDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Container(
          width: 411.sp,
          padding: EdgeInsets.all(20.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie_assets/main_lottie_assets/lot_status_confirmation.json',
                width: 70.w,
                height: 70.h,
                fit: BoxFit.scaleDown,
              ),
              SizedBox(height: 20.sp),
              Text(
                S.of(context).addAsset,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                S.of(context).confirmAddAsset,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 15.sp),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => HapticController.low(),
                      onTap: () => Navigator.pop(context, false), // ⬅ No
                      child: Container(
                        height: 38.sp,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? AppColors.secondaryButton
                                  : AppColors.whiteShadow,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          S.of(context).no,
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 28.sp),
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => HapticController.low(),
                      onTap: () => Navigator.pop(context, true), // ⬅ Yes
                      child: Container(
                        height: 38.sp,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          S.of(context).yes,
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.textButton,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return result ?? false; // return true if yes, false if no
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    final rootContext = context;
    await showAppDialog(
      context: rootContext,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: SizedBox(
            width: 410.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
                  width: 70.w,
                  height: 70.h,
                  fit: BoxFit.scaleDown,
                  repeat: true,
                  animate: true,
                ),
                SizedBox(height: 20.sp),
                Text(
                  S.of(context).addAsset,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  S.of(context).successAddAsset,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ////////////////////////////// Dialog Verify  //////////////////////////////
}
////////////////////////////////// Restock Existing ////////////////////////////////////

////////////////////////////////// Restock New Batch ////////////////////////////////////
class RestockNewBatchDialog extends StatefulWidget {
  const RestockNewBatchDialog({super.key});

  @override
  State<RestockNewBatchDialog> createState() => _RestockNewBatchDialogState();
}

class _RestockNewBatchDialogState extends State<RestockNewBatchDialog> {
  /////////////////////////// Variable //////////////////////////////////////

  String selectedDurationUnit = "hours";

  /////////////////////////// Controller ////////////////////////////////////

  TextEditingController orderIDController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController unitCostController = TextEditingController();
  TextEditingController currencyController = TextEditingController();
  TextEditingController supplierNameController = TextEditingController();
  TextEditingController expectedLifetimeController = TextEditingController();

  /////////////////////////// Controller ////////////////////////////////////

  /////////////////////////////////////// storage location //////////////////////
  // Default storage location (shown alone first)
  String? defaultStorageLocation;
  final List<Map<String, String>> storageLocations = [
    {"key": "roomA", "value": "Room A"},
    {"key": "roomB", "value": "Room B"},
    {"key": "roomC", "value": "Room C"},
  ];
  /////////////////////////////////////// storage location //////////////////////

  ////////////////////////////////////// Pick File //////////////////////////////

  PlatformFile? invoiceNewFile;
  PlatformFile? warrantyFile;

  Future<void> pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        if (type == 'invoice') {
          invoiceNewFile = result.files.first;
        } else if (type == 'warranty') {
          warrantyFile = result.files.first;
        }
      });
    }
  }

  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    return '${(bytes / 1024).ceil()} KB';
  }

  Widget buildFilePreview(
    PlatformFile file,
    DateTime uploadDate,
    VoidCallback onRemove,
  ) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    String size = formatBytes(file.size);
    String formattedDate = "${uploadDate.day.toString().padLeft(2, '0')}/"
        "${uploadDate.month.toString().padLeft(2, '0')}/"
        "${uploadDate.year}";

    return Container(
      width: 283.sp,
      height: 60.sp,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.secondaryText,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          // image
          Padding(
            padding: EdgeInsets.all(6.sp),
            child: kIsWeb
                ? Image.memory(
                    file.bytes!,
                    width: 36.sp,
                    height: 36.sp,
                    fit: BoxFit.cover,
                  )
                : (file.path != null
                    ? Image.file(
                        File(file.path!),
                        width: 36.sp,
                        height: 36.sp,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox()),
          ),

          // space
          SizedBox(width: 10.sp),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // file name
                Text(
                  FormatHelper.capitalize(file.name),
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                // space
                SizedBox(height: 5.sp),
                Text(
                  size,
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          // Remove button & Date
          Padding(
            padding: EdgeInsets.all(10.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTapDown: hapticDown(onRemove, HapticLevel.high),
                  onTap: onRemove,
                  child: CustomSvgImage.natural(
                    assetPath:
                        "assets/icons_assets/main_icons_assets/ic_editor_decrease.svg",
                    width: 12.sp,
                    height: 12.sp,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                Spacer(),
                Text(
                  "Date: $formattedDate",
                  style: StyleText.fontSize10Weight400.copyWith(
                    color:
                        lightMode ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////// Pick File //////////////////////////////
  bool requireApproval = false;
  @override
  Widget build(BuildContext context) {
    final durationUnits = [
      {"key": "week", "value": S.of(context).week},
      {"key": "hours", "value": S.of(context).hours},
      {"key": "minutes", "value": S.of(context).minutes},
      {"key": "seconds", "value": S.of(context).seconds},
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: 645.sp,
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // ✅ Let height be dynamic
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with image
            Row(
              children: [
                // image
                Container(
                  width: 30.sp,
                  height: 30.sp,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomSvgImage(
                      assetPath:
                          "assets/icons_assets/main_icons_assets/ic_action_plus.svg",
                      width: 19.sp,
                      height: 19.sp,
                      color: AppColors.textButton,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
                // space
                SizedBox(width: 8.sp),
                // New BatchRestock Title
                Text(
                  S.of(context).newBatchRestockTitle,
                  style: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),

                Spacer(),

                Text(
                  S.of(context).automaticIDs,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),

                SizedBox(width: 15.sp),

                FlutterSwitch(
                  height: 22.0.sp,
                  width: 38.0.sp,
                  toggleSize: 18.sp,
                  value: requireApproval,
                  borderRadius: 17.sp,
                  padding: 1,
                  activeColor: AppColors.secondaryPrimary,
                  onToggle: (val) {
                    setState(() {
                      requireApproval = val;
                    });
                  },
                ),
              ],
            ),
            // space
            SizedBox(height: 20.sp),
            // Order ID and Quantity
            Row(
              children: [
                Expanded(
                  child: CustomValidatedTextFieldMaster(
                    label: S.of(context).orderID,
                    hint: S.of(context).orderID,
                    height: 36.sp,
                    controller: orderIDController,
                    onlyDigits: false,
                    textDirection: ui.TextDirection.ltr,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(width: 15.sp),
                Expanded(
                  child: CustomValidatedTextFieldMaster(
                    label: S.of(context).quantity,
                    hint: S.of(context).quantity,
                    height: 36.sp,
                    controller: quantityController,
                    textDirection: ui.TextDirection.ltr,
                    onlyDigits: false,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            //space
            SizedBox(height: 15.sp),
            // Quantity ID and Unit Cost
            Row(
              children: [
                Expanded(
                  child: CustomValidatedTextFieldMaster(
                    label: S.of(context).quantity,
                    hint: S.of(context).quantity,
                    controller: quantityController,
                    height: 36.sp,
                    onlyDigits: false,
                    textDirection: ui.TextDirection.ltr,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(width: 15.sp),
                Expanded(
                  child: CustomValidatedTextFieldMaster(
                    label: S.of(context).unitCost,
                    hint: S.of(context).unitCost,
                    controller: unitCostController,
                    height: 36.sp,
                    textDirection: ui.TextDirection.ltr,
                    onlyDigits: false,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            // space
            SizedBox(height: 15.sp),
            // Currency ID and Supplier
            Row(
              children: [
                Expanded(
                  child: CustomValidatedTextFieldMaster(
                    label: S.of(context).currency,
                    hint: S.of(context).currency,
                    height: 36.sp,
                    controller: currencyController,
                    onlyDigits: false,
                    textDirection: ui.TextDirection.ltr,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(width: 15.sp),
                Expanded(
                  child: CustomValidatedTextFieldMaster(
                    label: S.of(context).supplier,
                    hint: S.of(context).supplier,
                    controller: supplierNameController,
                    textDirection: ui.TextDirection.ltr,
                    height: 36.sp,
                    onlyDigits: false,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            // space
            SizedBox(height: 15.sp),

            Row(
              children: [
                // Expected Lifetime
                SizedBox(
                  width: 205.sp,
                  child: CustomValidatedTextFieldMaster(
                    label: S.of(context).expectedLifetime,
                    height: 36.sp,
                    hint: S.of(context).enterThePeriod,
                    controller: expectedLifetimeController,
                    onlyDigits: false,
                    textDirection: ui.TextDirection.ltr,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                SizedBox(width: 10.sp),
                Padding(
                  padding: EdgeInsets.only(top: 26.sp),
                  child: SizedBox(
                    width: 85.sp,
                    child: CustomDropdown<String>(
                      items: (durationUnits)
                          .map((e) => DropdownItem<String>(
                              value: e['key'] ?? '', label: e['value'] ?? ''))
                          .toList(),
                      value: selectedDurationUnit,
                      onChanged: (value) {
                        setState(() {
                          selectedDurationUnit = value;
                        });
                      },
                      height: 35.sp,
                    ),
                  ),
                ),
              ],
            ),

            // space
            SizedBox(height: 15.sp),

            // Product Specification & Product Warranty
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Invoice
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).invoice,
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                    SizedBox(height: 8.sp),
                    invoiceNewFile == null
                        ? customButtonWithSvg(
                            title: S.of(context).upload,
                            function: () => pickFile('invoice'),
                            textStyle: StyleText.fontSize14Weight500.copyWith(
                              color: AppColors.textButton,
                            ),
                            width: 170.sp,
                            height: 35.sp,
                            space: 16.sp,
                            radius: 4.r,
                            color: AppColors.primary,
                            svgColor: AppColors.textButton,
                            image:
                                "assets/icons_assets/main_icons_assets/ic_upload.svg",
                            widthImage: 16.sp,
                            heightImage: 16.sp,
                            colorBorder: Colors.transparent,
                          )
                        : buildFilePreview(invoiceNewFile!, DateTime.now(), () {
                            setState(() {
                              invoiceNewFile = null;
                            });
                          }),
                  ],
                ),

                SizedBox(width: 40.sp),

                // Warranty
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).warranty,
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                    SizedBox(height: 8.sp),
                    warrantyFile == null // ✅ CORRECT THIS LINE
                        ? customButtonWithSvg(
                            title: S.of(context).upload,
                            function: () => pickFile('warranty'),
                            textStyle: StyleText.fontSize14Weight500.copyWith(
                              color: AppColors.textButton,
                            ),
                            width: 170.sp,
                            height: 35.sp,
                            space: 16.sp,
                            radius: 4.r,
                            color: AppColors.primary,
                            svgColor: AppColors.textButton,
                            image:
                                "assets/icons_assets/main_icons_assets/ic_upload.svg",
                            widthImage: 16.sp,
                            heightImage: 16.sp,
                            colorBorder: Colors.transparent,
                          )
                        : buildFilePreview(warrantyFile!, DateTime.now(), () {
                            setState(() {
                              warrantyFile = null;
                            });
                          }),
                  ],
                ),
              ],
            ),

            SizedBox(height: 40.sp),

            // Storage Location
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // storage Location
                Text(
                  S.of(context).storageLocation,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                // space
                SizedBox(height: 8.sp),
                // Dropdown of storage Location
                SizedBox(
                  width: 300.sp,
                  child: CustomDropdown<String>(
                    items: (storageLocations)
                        .map((e) => DropdownItem<String>(
                            value: e['key'] ?? '', label: e['value'] ?? ''))
                        .toList(),
                    value: defaultStorageLocation,
                    onChanged: (val) {
                      setState(() {
                        defaultStorageLocation = val;
                      });
                    },
                    hint: S.of(context).selectStorageLocation,
                    height: 36.sp,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.sp),

            // + Storage Button
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                customButtonWithSvg(
                  title: S.of(context).storage,
                  function: () {},
                  textStyle: StyleText.fontSize14Weight500.copyWith(
                    color: AppTheme.readableOn(AppColors.blackButton),
                  ),
                  width: 100.sp,
                  height: 30.sp,
                  space: 8.sp,
                  radius: 4.r,
                  color: AppColors.blackButton,
                  svgColor: AppTheme.readableOn(AppColors.blackButton),
                  image:
                      "assets/icons_assets/main_icons_assets/ic_action_plus.svg",
                  widthImage: 12.sp,
                  heightImage: 12.sp,
                  colorBorder: Colors.transparent,
                ),
              ],
            ),

            SizedBox(height: 20.sp),

            // Discard & Submit
            Row(
              textDirection: TextDirection
                  .ltr, // X-73: Cancel left, action right in both languages

              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ✅ Discard
                customButton(
                  title: S.of(context).discard,
                  function: () {
                    Navigator.pop(context);
                  },
                  textStyle: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                  width: 150.sp,
                  height: 38.sp,
                  radius: 8.r,
                  color: AppColors.grey,
                ),

                // ✅ submit
                customButton(
                  title: S.of(context).submit,
                  function: () async {
                    final confirmed =
                        await _showConfirmDialog(); // show confirm dialog
                    if (confirmed) {
                      if (!context.mounted) return;
                      await _showSuccessDialog(
                        context,
                      ); // show success dialog if Yes
                      if (!context.mounted) return;
                      Navigator.pop(
                        context,
                      ); // then close the original Restock dialog
                    }
                  },
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textButton,
                  ),
                  width: 150.sp,
                  height: 38.sp,
                  radius: 8.r,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////// Dialog Verify  //////////////////////////////

  Future<bool> _showConfirmDialog() async {
    final result = await showAppDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Container(
          width: 411.sp,
          padding: EdgeInsets.all(20.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie_assets/main_lottie_assets/lot_status_confirmation.json',
                width: 70.w,
                height: 70.h,
                fit: BoxFit.scaleDown,
              ),
              SizedBox(height: 20.sp),
              Text(
                S.of(context).addAsset,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                S.of(context).confirmAddAsset,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 15.sp),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => HapticController.low(),
                      onTap: () => Navigator.pop(context, false), // ⬅ No
                      child: Container(
                        height: 38.sp,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? AppColors.secondaryButton
                                  : AppColors.whiteShadow,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          S.of(context).no,
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 28.sp),
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => HapticController.low(),
                      onTap: () => Navigator.pop(context, true), // ⬅ Yes
                      child: Container(
                        height: 38.sp,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          S.of(context).yes,
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.textButton,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return result ?? false; // return true if yes, false if no
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    final rootContext = context;
    await showAppDialog(
      context: rootContext,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: SizedBox(
            width: 410.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
                  width: 70.w,
                  height: 70.h,
                  fit: BoxFit.scaleDown,
                  repeat: true,
                  animate: true,
                ),
                SizedBox(height: 20.sp),
                Text(
                  S.of(context).addAsset,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  S.of(context).successAddAsset,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ////////////////////////////// Dialog Verify  //////////////////////////////
}

////////////////////////////////// Restock New Batch ////////////////////////////////////

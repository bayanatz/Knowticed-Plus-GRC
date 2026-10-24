import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv2_view_product/presentation/ui/pages/product_details_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv3_assign_and_suppliers/presentation/ui/pages/p11_employee_product_details_toogel.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_tabs.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class EmployeeDetailsDesktopScreen extends StatefulWidget {
  const EmployeeDetailsDesktopScreen({super.key});

  @override
  State<EmployeeDetailsDesktopScreen> createState() =>
      _EmployeeDetailsDesktopScreenState();
}

class _EmployeeDetailsDesktopScreenState
    extends State<EmployeeDetailsDesktopScreen> {
  //////////////////////////////////// Filter Bar ////////////////////////////////////////////////////////

  String selectedLabel = "In Use";

  final Map<String, Color> statusTextColors = {
    "In Use": const Color(0xFF4BB609),
    "Returned": const Color(0xFFDF1C1C),
    "Maintenance": const Color(0xFFE5B800),
    "Under Repair": const Color(0xFFFFDE59),
    "Damaged": const Color(0xFFBA1B1B),
    "Missing": const Color(0xFF797979),
    "Stolen": const Color(0xFF797979),
  };

  Widget filterSection(BuildContext context) {
    final Map<String, String> filterItems = {
      "In Use": S.of(context).inUse,
      "Returned": S.of(context).returned,
      "Maintenance": S.of(context).maintenance,
      "Under Repair": S.of(context).underRepair,
      "Damaged": S.of(context).damaged,
      "Missing": S.of(context).missing,
      "Stolen": S.of(context).stolen,
    };

    final Map<String, String> filterCounts = {
      "In Use": "14",
      "Returned": "5",
      "Maintenance": "5",
      "Under Repair": "5",
      "Damaged": "5",
      "Missing": "5",
      "Stolen": "5",
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
          // Counter box
          Container(
            // 22/10/2026 — Owner (phone): count chips match Notifications — box 35, number 14/400, label 14/600.
            width: context.isPhone ? 35.sp : 45.sp,
            height: context.isPhone ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isLight ? AppColors.white : AppColors.chatBackground),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                count,
                style: (context.isPhone
                        ? StyleText.fontSize14Weight400
                        : StyleText.fontSize20Weight500)
                    .copyWith(
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

          // Label text with dynamic color
          Text(
            FormatHelper.capitalize(label),
            style: (context.isPhone
                    ? StyleText.fontSize14Weight600
                    : StyleText.fontSize16Weight600)
                .copyWith(
              color: statusTextColors[key],
            ),
          ),

          SizedBox(width: 30.sp),
        ],
      ),
    );
  }

  //////////////////////////////////// Filter Bar ////////////////////////////////////////////////////////

  /////////////////////////////////// var ////////////////////////////////////////////
  String selectedType = 'Asset';
  /////////////////////////////////// var ////////////////////////////////////////////

  /////////////////////////////////// Controller //////////////////////////////////////
  final TextEditingController _searchController = TextEditingController();

  /////////////////////////////////// Controller //////////////////////////////////////

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
          secondTitle: S.of(context).productName,
          onSecondTap: () {
            navigateTo(context, ViewProductDetails());
          },
          thirdTitle: S.of(context).supplierDetails,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                //  Employee Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).employeeDetails,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.sp),

                // Header of Employee Info
                isMobile
                    ? Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.sp),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // image
                                  Image(
                                    image: AssetImage(
                                      "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
                                    ),
                                    width: 45.sp,
                                    height: 45.sp,
                                    fit: BoxFit.scaleDown,
                                  ),
                                  // space
                                  SizedBox(width: 5.sp),
                                  // info Employee
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Name of Employee
                                      Text(
                                        "Mona Mohammed",
                                        style: StyleText.fontSize14Weight500
                                            .copyWith(
                                          color: AppColors.blackButton,
                                        ),
                                      ),

                                      // space
                                      Text(
                                        "Marketing",
                                        style: StyleText.fontSize12Weight500
                                            .copyWith(
                                          color: AppColors.secondaryText,
                                        ),
                                      ),

                                      Text(
                                        "Marketing Manger",
                                        style: StyleText.fontSize12Weight500
                                            .copyWith(
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Spacer(),

                                  customButtonWithSvg(
                                    title: "",
                                    function: () {},
                                    width: 40.sp,
                                    height: 40.sp,
                                    color: AppColors.primary,
                                    textStyle: isMobile
                                        ? StyleText.fontSize14Weight500
                                            .copyWith(
                                            color: AppColors.textButton,
                                          )
                                        : StyleText.fontSize16Weight500
                                            .copyWith(
                                            color: AppColors.textButton,
                                          ),
                                    radius: 8.r,
                                    heightImage: 16.sp,
                                    widthImage: 16.sp,
                                    svgColor: AppColors.textButton,
                                    image:
                                        "assets/icons_assets/main_icons_assets/ic_comms_chat_yellow.svg",
                                    space: 8.sp,
                                    colorBorder: Colors.transparent,
                                  ),
                                ],
                              ),

                              SizedBox(height: 5.sp),
                              // Title & Email & Department & Phone Number
                              Row(
                                children: [
                                  // Title & Email
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Phone Number
                                      itemTextProduct(
                                        value: "+2010258963",
                                        label: "${S.of(context).phoneNumber}: ",
                                        image:
                                            "assets/icons_assets/main_icons_assets/ic_comms_phone.svg",
                                      ),
                                      // space
                                      SizedBox(height: 5.sp),
                                      // Email
                                      itemTextProduct(
                                        value: "Mona.Mohamed@GulfDev.com",
                                        label: "${S.of(context).email}: ",
                                        image:
                                            "assets/icons_assets/main_icons_assets/ic_comms_sms.svg",
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  itemText(
                                    value: "27 Dec 2024",
                                    label: "${S.of(context).submissionDate}: ",
                                    valueStyle:
                                        StyleText.fontSize10Weight500.copyWith(
                                      color: AppColors.blackButton,
                                    ),
                                    labelStyle:
                                        StyleText.fontSize10Weight500.copyWith(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        // height: 110.sp,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15.sp),
                          child: Row(
                            children: [
                              // image
                              Image(
                                image: AssetImage(
                                    "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png"),
                                width: 80.sp,
                                height: 80.sp,
                                fit: BoxFit.scaleDown,
                              ),
                              // space
                              SizedBox(width: 10.sp),
                              // info Employee
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name of Employee
                                  Text(
                                    "Mona Mohammed",
                                    style:
                                        StyleText.fontSize16Weight500.copyWith(
                                      color: AppColors.blackButton,
                                    ),
                                  ),
                                  // space
                                  SizedBox(height: 10.sp),
                                  // Title & Email & Department & Phone Number
                                  Row(
                                    children: [
                                      // Title & Email
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Title
                                          itemTextProduct(
                                            value: "Technician",
                                            label: "${S.of(context).title}: ",
                                            image:
                                                "assets/icons_assets/main_icons_assets/ic_file_doc.svg",
                                          ),

                                          // Email
                                          itemTextProduct(
                                            value: "Mona.Mohamed@GulfDev.com",
                                            label: "${S.of(context).email}: ",
                                            image:
                                                "assets/icons_assets/main_icons_assets/ic_comms_sms.svg",
                                          ),
                                        ],
                                      ),
                                      // space
                                      SizedBox(width: 38.sp),
                                      // Department & Phone Number
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Department
                                          itemTextProduct(
                                            value: "IT",
                                            label:
                                                "${S.of(context).department}: ",
                                            image:
                                                "assets/icons_assets/main_icons_assets/ic_building_office.svg",
                                          ),

                                          // Phone Number
                                          itemTextProduct(
                                            value: "+2010258963",
                                            label:
                                                "${S.of(context).phoneNumber}: ",
                                            image:
                                                "assets/icons_assets/main_icons_assets/ic_comms_phone.svg",
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Spacer(),

                              // Message button
                              customButtonWithSvg(
                                title: S.of(context).msg,
                                function: () {},
                                textStyle:
                                    StyleText.fontSize16Weight500.copyWith(
                                  color: AppColors.textButton,
                                ),
                                width: 135.sp,
                                height: 38.sp,
                                space: 8.sp,
                                radius: 8.r,
                                color: AppColors.primary,
                                image:
                                    "assets/icons_assets/main_icons_assets/ic_comms_chat_yellow.svg",
                                widthImage: 24.sp,
                                heightImage: 24.sp,
                                colorBorder: Colors.transparent,
                              ),
                            ],
                          ),
                        ),
                      ),
                // space
                SizedBox(height: 13.sp),

                // Asset  &  Consumable
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

                // Filter Widget
                filterSection(context),

                // space
                SizedBox(height: 15.sp),
                // Search
                SizedBox(
                  height: 38.sp,
                  child: AppSearchTextField(
                    controller: _searchController,
                    expanded: false,
                  ),
                ),

                // space
                SizedBox(height: 15.sp),

                // GridView of product
                SizedBox(
                  //   height: MediaQuery.sizeOf(context).height*.5, // adjust based on your UI
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
                      mainAxisExtent: 110.sp,
                    ),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          navigateTo(context, EmployeeProductDetails());
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
                                // Image & Asset ID & Quantity & Maintenance Frequency
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                                    BorderRadius.circular(4.r),
                                                color: lightMode
                                                    ? AppColors.grey
                                                    : AppColors.background,
                                              ),
                                              width: 50.sp,
                                              height: 50.sp,
                                              child: CustomSvgImage(
                                                assetPath:
                                                    "assets/icons_assets/main_icons_assets/ic_data_inventory_assets.svg",
                                                color: AppColors.blackButton,
                                                fit: BoxFit.scaleDown,
                                                height: 40.sp,
                                                width: 40.sp,
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
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    itemTextProductGridView(
                                                      value: "011000000",
                                                      label:
                                                          "${S.of(context).assetId}: ",
                                                    ),

                                                    //    itemTextProductGridView(value: S.of(context).inUse,label: "${S.of(context).status}: "),
                                                  ],
                                                ),
                                                SizedBox(height: 3.sp),
                                                itemTextProductGridView(
                                                  value: "1",
                                                  label:
                                                      "${S.of(context).quantity}: ",
                                                ),
                                                SizedBox(height: 3.sp),
                                                itemTextProductGridView(
                                                  value: "Quarter",
                                                  label:
                                                      "${S.of(context).maintenanceFrequency}: ",
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
                                SizedBox(height: 5.sp),
                                // Dell GS 15 title
                                Row(
                                  children: [
                                    // name product
                                    Text(
                                      FormatHelper.capitalize("Dell GS 15"),
                                      style: StyleText.fontSize14Weight400
                                          .copyWith(
                                        color: AppColors.blackButton,
                                      ),
                                    ),
                                  ],
                                ),
                                // Received Date & Returing Date
                                Row(
                                  children: [
                                    itemTextProductGridView(
                                      value: "28 May 2020",
                                      label: "${S.of(context).receivedDate}: ",
                                    ),
                                    Spacer(),
                                    itemTextProductGridView(
                                      value: "28 May 2020",
                                      label: "${S.of(context).returnDate}: ",
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
          ),
        ),
      ),
    );
  }

  ////////////////////////// item in any Container /////////////////////////////
  Widget itemText({
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
              StyleText.fontSize10Weight500.copyWith(
                color: AppColors.blackButton,
              ),
        ),
      ],
    );
  }
  ////////////////////////// item in any Container /////////////////////////////

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

  ////////////////////////// label item //////////////////////////////

  Widget itemTextProduct({
    required String label,
    required String value,
    required String image,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // image
        CustomSvgImage(
          assetPath: image,
          width: 11.sp,
          height: 11.sp,
          fit: BoxFit.scaleDown,
        ),

        SizedBox(width: 3.sp),

        // space
        Text(
          FormatHelper.capitalize(label),
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        Text(
          FormatHelper.capitalize(value),
          style: StyleText.fontSize14Weight500.copyWith(
            color: valueColor ?? AppColors.blackButton,
          ),
        ),
      ],
    );
  }

  ////////////////////////// label item //////////////////////////////
}

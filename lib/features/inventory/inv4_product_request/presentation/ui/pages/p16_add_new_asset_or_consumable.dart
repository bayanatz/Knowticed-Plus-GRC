import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv4_product_request/presentation/ui/pages/p17_add_new_asset_details.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class AddNewAssetsOrConsumableDesktopScreen extends StatefulWidget {
  const AddNewAssetsOrConsumableDesktopScreen({super.key, required this.type});
  final String type;

  @override
  State<AddNewAssetsOrConsumableDesktopScreen> createState() =>
      _AddNewAssetsOrConsumableDesktopScreenState();
}

class _AddNewAssetsOrConsumableDesktopScreenState
    extends State<AddNewAssetsOrConsumableDesktopScreen> {
  final TextEditingController _searchController = TextEditingController();

  ///////////////////////////// List of Data /////////////////////////////
  final List<Map<String, dynamic>> products = [
    {
      "name": "Dell GS 15",
      "category": "Electronics",
      "subcategory": "Computer",
      "specification": "TechSource Solutions",
      "requiresApprovals": "Yes",
      "status": "Out Stock",
      "lastUpdate": "28 May 2020",
      "imagePath":
          "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
    },
    {
      "name": "HP EliteBook",
      "category": "Electronics",
      "subcategory": "Laptop",
      "specification": "HP Official",
      "requiresApprovals": "Yes",
      "status": "Available",
      "lastUpdate": "10 Jan 2022",
      "imagePath":
          "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
    },
    {
      "name": "MacBook Pro",
      "category": "Electronics",
      "subcategory": "Laptop",
      "specification": "Apple Inc.",
      "requiresApprovals": "No",
      "status": "Available",
      "lastUpdate": "03 Mar 2023",
      "imagePath":
          "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
    },
    {
      "name": "Lenovo ThinkPad",
      "category": "Electronics",
      "subcategory": "Notebook",
      "specification": "Lenovo Group",
      "requiresApprovals": "Yes",
      "status": "Out Stock",
      "lastUpdate": "12 Dec 2021",
      "imagePath":
          "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
    },
    {
      "name": "Asus ZenBook",
      "category": "Electronics",
      "subcategory": "Ultrabook",
      "specification": "AsusTek Computer",
      "requiresApprovals": "No",
      "status": "Available",
      "lastUpdate": "25 Aug 2022",
      "imagePath":
          "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
    },
  ];

  ///////////////////////////// List of Data /////////////////////////////

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    Localizations.localeOf(context).languageCode == 'ar';
    Localizations.localeOf(context).languageCode == 'en';
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventoryManagement,
          onFirstTap: () {
            Navigator.pop(context);
          },
          secondTitle: S.of(context).addingNewProduct,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                // Asset Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).assetDetails,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),
                // space
                SizedBox(height: 9.sp),
                // Search
                SizedBox(
                  width: double.infinity,
                  height: 38.sp,
                  child: AppSearchTextField(
                    controller: _searchController,
                    expanded: false,
                  ),
                ),

                SizedBox(height: 15.sp),

                // GridView of product
                SizedBox(
                  height: MediaQuery.sizeOf(context).height *
                      .5, // adjust based on your UI
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
                      mainAxisExtent: 125.sp,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () {
                          navigateTo(
                            context,
                            AddNewAssetsDetailsDesktopScreen(),
                          );
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
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                                    BorderRadius.circular(4.r),
                                                color: lightMode
                                                    ? AppColors.grey
                                                    : AppColors.background,
                                              ),
                                              width: 60.sp,
                                              height: 60.sp,
                                              child: CustomSvgImage(
                                                assetPath:
                                                    "assets/icons_assets/main_icons_assets/ic_data_inventory_assets.svg",
                                                color: AppColors.blackButton,
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
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  itemTextProduct(
                                                    value: product["category"],
                                                    label:
                                                        "${S.of(context).category}: ",
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
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
                                                        product["status"],
                                                        style: StyleText
                                                            .fontSize8Weight400
                                                            .copyWith(
                                                          color: product[
                                                                      "status"] !=
                                                                  "Out Stock"
                                                              ? Color(
                                                                  0xff4BB609,
                                                                )
                                                              : Color(
                                                                  0xffDF1C1C,
                                                                ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 3.sp),
                                              itemTextProduct(
                                                value: product["subcategory"],
                                                label:
                                                    "${S.of(context).subcategory}: ",
                                              ),
                                              SizedBox(height: 3.sp),
                                              itemTextProduct(
                                                value: product["specification"],
                                                label:
                                                    "${S.of(context).specification}: ",
                                                underlineValueColor: Color(
                                                  0xff347AE2,
                                                ),
                                                underlineValue: true,
                                                valueStyle: StyleText
                                                    .fontSize10Weight500
                                                    .copyWith(
                                                  color: Color(0xff347AE2),
                                                ),
                                              ),
                                              SizedBox(height: 3.sp),
                                              itemTextProduct(
                                                value: product[
                                                    "requiresApprovals"],
                                                label:
                                                    "${S.of(context).requiresApprovals}: ",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 3.sp),
                                // name product
                                Row(
                                  children: [
                                    // name product
                                    Text(
                                      FormatHelper.capitalize(product["name"]),
                                      style: StyleText.fontSize14Weight400
                                          .copyWith(
                                        color: AppColors.blackButton,
                                      ),
                                    ),
                                  ],
                                ),
                                // Received Date
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    customButton(
                                      title: S.of(context).request,
                                      function: () {
                                        navigateTo(context, widget);
                                      },
                                      color: AppColors.primary,
                                      height: 15.sp,
                                      width: 61.sp,
                                      textStyle: TextStyle(
                                        color: AppColors.textButton,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 8.sp,
                                      ),
                                      radius: 4.r,
                                    ),

                                    Spacer(),

                                    // Received Date & Return Date
                                    Text(
                                      "${S.of(context).lastUpdate}: ",
                                      style:
                                          StyleText.fontSize8Weight400.copyWith(
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                    // value Received Date
                                    Text(
                                      product["lastUpdate"],
                                      style:
                                          StyleText.fontSize8Weight400.copyWith(
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
    TextStyle? valueStyle,
    bool underlineLabel = false,
    bool underlineValue = false,
    Color? underlineLabelColor,
    Color? underlineValueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          FormatHelper.capitalize(label),
          style: (labelStyle ??
                  StyleText.fontSize10Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ))
              .copyWith(
            decoration:
                underlineLabel ? TextDecoration.underline : TextDecoration.none,
            decorationColor: underlineLabelColor,
            decorationStyle: TextDecorationStyle.solid,
          ),
        ),
        Text(
          FormatHelper.capitalize(value),
          style: (valueStyle ??
                  StyleText.fontSize10Weight500.copyWith(
                    color: AppColors.blackButton,
                  ))
              .copyWith(
            decoration:
                underlineValue ? TextDecoration.underline : TextDecoration.none,
            decorationColor: underlineValueColor,
            decorationStyle: TextDecorationStyle.solid,
          ),
        ),
      ],
    );
  }

  /////////////////////////// ListView Item Text /////////////////////////////////////////////////////////
}

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv4_product_request/presentation/ui/pages/p15_product_request_toogel.dart';
import 'package:knowticed_plus/features/inventory/inv4_product_request/presentation/ui/pages/p20_request_details_final_toogel.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_validated_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CreateNewRequestDesktopScreen extends StatefulWidget {
  const CreateNewRequestDesktopScreen({super.key});

  @override
  State<CreateNewRequestDesktopScreen> createState() =>
      _CreateNewRequestDesktopScreenState();
}

class _CreateNewRequestDesktopScreenState
    extends State<CreateNewRequestDesktopScreen> {
  String selectedType = "Asset Return";
  TextEditingController requestIdController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int? selectedProductIndex;

  @override
  Widget build(BuildContext context) {
    final bool isRequestIdEmpty = requestIdController.text.trim().isEmpty;
    final bool isNextButtonEnabled =
        !isRequestIdEmpty && selectedProductIndex != null;
    final List<Map<String, String>> selectTypeList = [
      {"key": "Asset Return", "value": S.of(context).assetReturn},
      {"key": "Asset Repair", "value": S.of(context).assetRepair},
      {
        "key": "Routine Maintenance ",
        "value": S.of(context).routineMaintenance,
      },
      {"key": "Asset Missing", "value": S.of(context).assetMissing},
    ];
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
          secondTitle: S.of(context).productRequests,
          onSecondTap: () {
            navigateTo(context, ProductRequest());
          },
          thirdTitle: S.of(context).myRequest,
          onThirdTap: () {},
          fourthTitle: S.of(context).createNewRequest,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                // Request ID & Selected Type
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
                      bottom: 15.sp,
                    ),
                    child: Column(
                      children: [
                        buildResponsiveFields(
                          left: requestIdInputField(lightMode),
                          right: requestTypeDropdownField(selectTypeList),
                          context: context,
                        ),

                        // space
                        SizedBox(height: 15.sp),
                        // Asset Details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).assetDetails,
                              style: StyleText.fontSize12Weight400.copyWith(
                                color: AppColors.blackButton,
                              ),
                            ),
                          ],
                        ),

                        // space
                        SizedBox(height: 8.sp),
                        // search
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 36.sp,
                                child: AppSearchTextField(
                                  controller: _searchController,
                                  expanded: false,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 11.sp),

                        SizedBox(
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
                              mainAxisExtent: 103.sp,
                              mainAxisSpacing: 15.sp,
                            ),
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              final isSelected = selectedProductIndex == index;
                              return GestureDetector(
                                onTap: () {
                                  HapticController
                                      .low(); // list row: on the tap (X-117)
                                  setState(() {
                                    selectedProductIndex = index;
                                  });
                                },
                                child: Container(
                                  width: 289.sp,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(4.r),
                                    border: isSelected
                                        ? Border.all(
                                            color: AppColors.primary,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: 10.sp,
                                      right: 10.sp,
                                      left: 10.sp,
                                    ),
                                    child: Column(
                                      children: [
                                        // Image and Info
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
                                                        BorderRadius.circular(
                                                      4.r,
                                                    ),
                                                    color: lightMode
                                                        ? AppColors.grey
                                                        : AppColors.background,
                                                  ),
                                                  width: 50.sp,
                                                  height: 50.sp,
                                                  child: CustomSvgImage(
                                                    assetPath:
                                                        "assets/icons_assets/main_icons_assets/ic_data_inventory_assets.svg",
                                                    color:
                                                        AppColors.blackButton,
                                                    fit: BoxFit.scaleDown,
                                                    height: 40.sp,
                                                    width: 40.sp,
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
                                          ],
                                        ),
                                        //space
                                        SizedBox(height: 3.sp),
                                        // name product
                                        Row(
                                          children: [
                                            //space
                                            SizedBox(height: 4.sp),
                                            // name product
                                            Text(
                                              FormatHelper.capitalize(
                                                "Dell GS 15",
                                              ),
                                              style: StyleText
                                                  .fontSize14Weight400
                                                  .copyWith(
                                                color: AppColors.blackButton,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // space
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
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.sp),

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
                      title: S.of(context).next,
                      function: () {
                        navigateTo(context, RequestType());
                      },
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textButton,
                      ),
                      width: 150.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: isNextButtonEnabled
                          ? AppColors.primary
                          : const Color(0xFF989797),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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

  Widget requestIdInputField(bool lightMode) {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).requestID,
      height: 36.sp,
      hint: S.of(context).requestID,
      controller: requestIdController,
      textStyle: StyleText.fontSize14Weight400.copyWith(
        color: AppColors.blackButton,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget requestTypeDropdownField(List<Map<String, String>> selectTypeList) {
    return CustomDropdown<String>(
      items: (selectTypeList)
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value: selectedType,
      onChanged: (value) {
        setState(() {
          selectedType = value;
        });
      },
      label: S.of(context).requestType,
      height: 36.sp,
    );
  }

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

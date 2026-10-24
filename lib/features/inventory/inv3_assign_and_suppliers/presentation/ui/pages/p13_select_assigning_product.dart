import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/select_approval.dart';
import 'package:knowticed_plus/features/inventory/inv2_view_product/presentation/ui/pages/product_details_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/cards/custom_approval_shape.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_validated_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class SelectAssignProductDesktopScreen extends StatefulWidget {
  const SelectAssignProductDesktopScreen({super.key});

  @override
  State<SelectAssignProductDesktopScreen> createState() =>
      _SelectAssignProductDesktopScreenState();
}

class _SelectAssignProductDesktopScreenState
    extends State<SelectAssignProductDesktopScreen> {
  ///////////////////////////////////// Controller ////////////////////////////////////////
  TextEditingController requestController = TextEditingController();
  ///////////////////////////////////// Controller ////////////////////////////////////////

  /////////////////////////////// Approval Cycle //////////////////////////////////////////
  late ApprovalSection section;

  @override
  void initState() {
    super.initState();

    section = ApprovalSection(
      selectedApprovers: [
        EmployeeEntity(
          id: '1',
          firstName: "Ahmed",
          lastName: "Abd el Rahman",
          firstNameInArabic: "أحمد",
          lastNameInArabic: "عبد الرحمن",
          title: "HR",
          titleInArabic: "الموارد البشرية",
          gender: "male",
        ),
        EmployeeEntity(
          id: '2',
          firstName: "Sara",
          lastName: "Ali",
          firstNameInArabic: "سارة",
          lastNameInArabic: "علي",
          title: "Finance",
          titleInArabic: "المالية",
          gender: "female",
        ),
        EmployeeEntity(
          id: '3',
          firstName: "Mohamed",
          lastName: "Youssef",
          firstNameInArabic: "محمد",
          lastNameInArabic: "يوسف",
          title: "IT",
          titleInArabic: "تكنولوجيا المعلومات",
          gender: "male",
        ),
        EmployeeEntity(
          id: '4',
          firstName: "Laila",
          lastName: "Ibrahim",
          firstNameInArabic: "ليلى",
          lastNameInArabic: "إبراهيم",
          title: "Legal",
          titleInArabic: "القانونية",
          gender: "female",
        ),
        EmployeeEntity(
          id: '5',
          firstName: "Omar",
          lastName: "Salem",
          firstNameInArabic: "عمر",
          lastNameInArabic: "سالم",
          title: "Operations",
          titleInArabic: "العمليات",
          gender: "male",
        ),
      ],
    );
  }
  /////////////////////////////// Approval Cycle //////////////////////////////////////////

  ////////////////////////////// variable ////////////////////////////////////

  bool createBarCode = false;
  bool createId = false;
  bool isHidden = false;
  ////////////////////////////// variable ////////////////////////////////////

  ////////////////////////////// DropDown Var /////////////////////////////////////
  String? selectedDeliveryMethod;
  ////////////////////////////// DropDown Var /////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    Localizations.localeOf(context).languageCode == 'ar';
    Localizations.localeOf(context).languageCode == 'en';
    final durationUnits = [
      {"key": "HandDelivery", "value": S.of(context).handDelivery},
      {"key": "PickUp", "value": S.of(context).pickup},
    ];
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

                //space
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

                //space
                SizedBox(height: 20.sp),

                // Product Details and Hide
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Product Details
                    Text(
                      S.of(context).productDetails,
                      style: StyleText.fontSize18Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),

                    Spacer(),
                    // Hide and Expand
                    GestureDetector(
                      onTap: () {
                        HapticController.low(); // list row: on the tap (X-117)
                        setState(() {
                          isHidden = !isHidden;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // aligns underline with text
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isHidden
                                ? S.of(context).expand
                                : S.of(context).hide,
                            style: StyleText.fontSize14Weight500.copyWith(
                              color: const Color(0xff1877F2),
                            ),
                            textDirection: Directionality.of(context),
                          ),
                          SizedBox(height: 0.sp), // space between text and line
                          Container(
                            height: 1.sp,
                            width: (isHidden
                                        ? S.of(context).expand
                                        : S.of(context).hide)
                                    .length *
                                7.sp,
                            color: const Color(0xff1877F2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                //space
                SizedBox(height: 8.sp),

                // centre content
                if (!isHidden)
                  isMobile
                      ? Container(
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
                            child: Column(
                              children: [
                                // First Section
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // image  &  status
                                    Column(
                                      children: [
                                        Container(
                                          width: 70.sp,
                                          height: 70.sp,
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
                                                "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
                                            width: 40.sp,
                                            height: 40.sp,
                                            fit: BoxFit.scaleDown,
                                            color: AppColors.blackButton,
                                          ),
                                        ),
                                        SizedBox(height: 5.sp),
                                        // Status
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${S.of(context).status}: ",
                                              style: StyleText
                                                  .fontSize10Weight500
                                                  .copyWith(
                                                color: AppColors.blackButton,
                                              ),
                                            ),
                                            Text(
                                              S.of(context).inStock,
                                              style: StyleText
                                                  .fontSize10Weight500
                                                  .copyWith(
                                                color: AppColors.lightGreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    // space
                                    SizedBox(width: 5.sp),
                                    // productID &  productType & supplierName  & category
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        itemText(
                                          value: "100000000",
                                          label: "${S.of(context).productID}: ",
                                        ),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                          value: "100000000",
                                          label: "${S.of(context).batch}: ",
                                        ),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                          value: "Asset",
                                          label:
                                              "${S.of(context).productType}: ",
                                        ),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                          value: "Electronics Electronics  ",
                                          label: "${S.of(context).category}: ",
                                        ),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                          value: "Computer Computer",
                                          label:
                                              "${S.of(context).subcategory}: ",
                                        ),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                          value: "Dell",
                                          label: "${S.of(context).brand}: ",
                                        ),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                          value: "GZ 15",
                                          label: "${S.of(context).model}: ",
                                        ),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                          value: "5 Years",
                                          label:
                                              "${S.of(context).expectedLifetime}: ",
                                        ),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                          value: "New",
                                          label: "${S.of(context).condition}: ",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

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
                                                  ? StyleText
                                                      .fontSize10Weight500
                                                      .copyWith(
                                                      color: lightMode
                                                          ? AppColors
                                                              .secondaryText
                                                          : AppColors.grey,
                                                    )
                                                  : StyleText
                                                      .fontSize12Weight500
                                                      .copyWith(
                                                      color: lightMode
                                                          ? AppColors
                                                              .secondaryText
                                                          : AppColors.grey,
                                                    ),
                                            ),
                                            TextSpan(
                                              text:
                                                  "Lorem Ipsum Lorem IpsumLorem IpsumLorem IpsumLorem "
                                                  "IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem",
                                              style: isMobile
                                                  ? StyleText.fontSize8Weight400
                                                      .copyWith(
                                                      color: lightMode
                                                          ? AppColors
                                                              .blackButton
                                                          : AppColors.white,
                                                    )
                                                  : StyleText
                                                      .fontSize12Weight500
                                                      .copyWith(
                                                      color: lightMode
                                                          ? AppColors
                                                              .blackButton
                                                          : AppColors.white,
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
                                SizedBox(height: 20.sp),

                                // Approval Cycle
                                Row(
                                  children: [
                                    Text(
                                      "${S.of(context).approvalCycle}: ",
                                      style: StyleText.fontSize12Weight400
                                          .copyWith(
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),

                                _buildApprovalCycle(section),
                              ],
                            ),
                          ),
                        )
                      : Container(
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
                              children: [
                                // First Section
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    SizedBox(width: 10.sp),
                                    // productID &  productType & supplierName  & category
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        itemText(
                                          value: "100000000",
                                          label: "${S.of(context).productID}: ",
                                        ),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                          value: "Asset",
                                          label:
                                              "${S.of(context).productType}: ",
                                        ),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                          value: "TechSource Solutions",
                                          label:
                                              "${S.of(context).supplierName}: ",
                                        ),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                          value: "Electronics Electronics  ",
                                          label: "${S.of(context).category}: ",
                                        ),
                                      ],
                                    ),

                                    SizedBox(
                                      width:
                                          MediaQuery.sizeOf(context).width * .1,
                                    ),

                                    // subcategory &  brand & model  & expectedLifetime
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        itemText(
                                          value: "Computer Computer",
                                          label:
                                              "${S.of(context).subcategory}: ",
                                        ),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                          value: "Dell",
                                          label: "${S.of(context).brand}: ",
                                        ),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                          value: "GZ 15",
                                          label: "${S.of(context).model}: ",
                                        ),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                          value: "5 Years",
                                          label:
                                              "${S.of(context).expectedLifetime}: ",
                                        ),
                                      ],
                                    ),
                                    // space
                                    SizedBox(
                                      width:
                                          MediaQuery.sizeOf(context).width * .1,
                                    ),
                                    // subcategory &  brand & model  & expectedLifetime
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        itemText(
                                          value: "10",
                                          label: "${S.of(context).quantity}: ",
                                        ),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                          value: "10",
                                          label: "${S.of(context).unitCost}: ",
                                        ),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                          value: "USA",
                                          label: "${S.of(context).currency}: ",
                                        ),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                          value: "Electronic",
                                          label:
                                              "${S.of(context).storageRequirement}: ",
                                        ),
                                      ],
                                    ),

                                    Spacer(),

                                    // Status
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${S.of(context).status}: ",
                                          style: StyleText.fontSize10Weight500
                                              .copyWith(
                                            color: AppColors.blackButton,
                                          ),
                                        ),
                                        Text(
                                          S.of(context).inStock,
                                          style: StyleText.fontSize10Weight500
                                              .copyWith(
                                            color: AppColors.lightGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                SizedBox(height: 5.sp),
                                // name of product
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Dell GS 15",
                                      style: StyleText.fontSize14Weight400
                                          .copyWith(
                                        color: AppColors.blackButton,
                                      ),
                                    ),
                                  ],
                                ),

                                // space
                                SizedBox(height: 15.sp),

                                // Additional Note
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Additional Note:
                                    Text(
                                      "${S.of(context).additionalNote}: ",
                                      style: StyleText.fontSize12Weight500
                                          .copyWith(
                                        color: AppColors.secondaryText,
                                      ),
                                    ),

                                    // value of Additional Note:
                                    Text(
                                      "Lorem Ipsum Lorem IpsumLorem IpsumLorem",
                                      style: StyleText.fontSize12Weight500
                                          .copyWith(
                                        color: AppColors.blackButton,
                                      ),
                                    ),
                                  ],
                                ),

                                // space
                                SizedBox(height: 20.sp),
                                // Approval Cycle
                                Row(
                                  children: [
                                    Text(
                                      "${S.of(context).approvalCycle}: ",
                                      style: StyleText.fontSize12Weight400
                                          .copyWith(
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),

                                // space
                                SizedBox(height: 13.sp),

                                // Approval Cycle item
                                buildApprovalCycleRow(section),
                              ],
                            ),
                          ),
                        ),

                //space
                SizedBox(height: 20.sp),

                // Assigning Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).assigningDetails,
                      style: StyleText.fontSize18Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),

                //space
                SizedBox(height: 8.sp),

                // Assigning Details content
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.card,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.sp,
                      vertical: 15.sp,
                    ),
                    child: Column(
                      children: [
                        // qr code image &  Download as PNG & and Switch
                        isMobile
                            ? Container()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // qr code image
                                      Image(
                                        image: AssetImage(
                                            "assets/icons_assets/inventory_assets/img_qr.png"),
                                        width: 50.sp,
                                        height: 50.sp,
                                        fit: BoxFit.scaleDown,
                                      ),
                                      // space
                                      SizedBox(height: 5.sp),
                                      // Download as PNG
                                      Row(
                                        children: [
                                          // image download
                                          CustomSvgImage(
                                            assetPath:
                                                "assets/icons_assets/main_icons_assets/ic_action_download.svg",
                                            width: 16.sp,
                                            height: 16.sp,
                                            color: AppColors.blue,
                                            fit: BoxFit.scaleDown,
                                          ),

                                          SizedBox(width: 5.sp),

                                          // downloadAsPng
                                          Text(
                                            S.of(context).downloadAsPng,
                                            style: StyleText.fontSize12Weight500
                                                .copyWith(
                                              color: Color(0xff1877F2),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  Spacer(),

                                  // Create Barcode & Create Automatic IDs
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Create Barcode
                                      Text(
                                        S.of(context).createBarcode,
                                        style: StyleText.fontSize14Weight500
                                            .copyWith(
                                          color: AppColors.blackButton,
                                        ),
                                      ),

                                      // space
                                      SizedBox(height: 28.sp),

                                      // Create Automatic IDs
                                      Text(
                                        S.of(context).createAutomaticIDs,
                                        style: StyleText.fontSize14Weight500
                                            .copyWith(
                                          color: AppColors.blackButton,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(width: 9.sp),

                                  // Switch
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Switch
                                      FlutterSwitch(
                                        height: 22.0.sp,
                                        width: 38.0.sp,
                                        toggleSize: 18.0,
                                        value: createBarCode,
                                        borderRadius: 20.0,
                                        padding: 1.5,
                                        activeColor: AppColors.secondaryPrimary,
                                        onToggle: (val) {
                                          setState(() {
                                            createBarCode = val;
                                          });
                                        },
                                      ),

                                      // space
                                      SizedBox(height: 28.sp),

                                      // Switch
                                      FlutterSwitch(
                                        height: 22.0.sp,
                                        width: 38.0.sp,
                                        toggleSize: 18.0,
                                        value: createId,
                                        borderRadius: 20.0,
                                        padding: 1.5,
                                        activeColor: AppColors.secondaryPrimary,
                                        onToggle: (val) {
                                          setState(() {
                                            createId = val;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                        // Space
                        isMobile ? Container() : SizedBox(height: 16.sp),

                        // Request ID & Delivery Method
                        buildResponsiveFields(
                          left: requestIdField(),
                          right: deliveryField(durationUnits),
                          context: context,
                        ),

                        // Space
                        SizedBox(height: 15.sp),

                        // Request ID & Delivery Method
                        buildResponsiveFields(
                          left: expectLifeTimeField(durationUnits),
                          right: expectedReturnDate(durationUnits),
                          context: context,
                        ),

                        // Space
                        SizedBox(height: 15.sp),

                        // Purpose Of Use
                        Row(
                          children: [
                            // Purpose Of Use
                            Expanded(
                              child: CustomValidatedTextFieldMaster(
                                label: S.of(context).requestID,
                                hint: S.of(context).requestID,
                                controller: requestController,
                                onChanged: (_) => setState(() {}),
                                textStyle:
                                    StyleText.fontSize14Weight400.copyWith(
                                  color: AppColors.blackButton,
                                ),
                                height: 72.sp,
                                maxLines: 3,
                                showCharCount: true,
                              ),
                            ),
                          ],
                        ),

                        // Space
                        SizedBox(height: 15.sp),

                        isMobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // qr code image
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 35.sp,
                                    ),
                                    child: Image(
                                      image: AssetImage(
                                          "assets/icons_assets/inventory_assets/img_qr.png"),
                                      width: 50.sp,
                                      height: 50.sp,
                                      fit: BoxFit.scaleDown,
                                    ),
                                  ),
                                  // space
                                  SizedBox(height: 5.sp),
                                  // Download as PNG
                                  Row(
                                    children: [
                                      // image download
                                      CustomSvgImage(
                                        assetPath:
                                            "assets/icons_assets/main_icons_assets/ic_action_download.svg",
                                        width: 16.sp,
                                        height: 16.sp,
                                        color: AppColors.blue,
                                        fit: BoxFit.scaleDown,
                                      ),

                                      SizedBox(width: 5.sp),

                                      // downloadAsPng
                                      Text(
                                        S.of(context).downloadAsPng,
                                        style: StyleText.fontSize12Weight500
                                            .copyWith(color: Color(0xff1877F2)),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.sp),

                // Discard & Add Assets
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

                    // ✅ Assign
                    customButton(
                      title: S.of(context).assign,
                      function: () {
                        navigateTo(context, widget);
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

                SizedBox(height: 10.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget expectedReturnDate(List<Map<String, String>> durationUnits) {
    return CustomDateField(
      value: DateFormat('d/M/yyyy').tryParse((selectedDeliveryMethod) ?? ''),
      onChanged: (date) {
        if (date == null) return;
        ((value) {
          if (value != null) {
            setState(() {
              selectedDeliveryMethod = value;
            });
          }
        })(DateFormat('d/M/yyyy').format(date));
      },
      label: S.of(context).deliveryMethod,
      hint: "24 Nov 2018",
      height: 36.sp,
    );
  }

  Widget expectLifeTimeField(List<Map<String, String>> durationUnits) {
    return CustomDateField(
      value: DateFormat('d/M/yyyy').tryParse((selectedDeliveryMethod) ?? ''),
      onChanged: (date) {
        if (date == null) return;
        ((value) {
          if (value != null) {
            setState(() {
              selectedDeliveryMethod = value;
            });
          }
        })(DateFormat('d/M/yyyy').format(date));
      },
      label: S.of(context).expectedDeliveryDate,
      hint: "24 Nov 2018",
      height: 36.sp,
    );
  }

  Widget deliveryField(List<Map<String, String>> durationUnits) {
    return CustomDropdown<String>(
      items: (durationUnits)
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value: selectedDeliveryMethod,
      onChanged: (value) {
        setState(() {
          selectedDeliveryMethod = value;
        });
      },
      label: S.of(context).deliveryMethod,
      hint: S.of(context).deliveryMethod,
      height: 36.sp,
      labelGap: 6.sp,
    );
  }

  Widget requestIdField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).requestID,
      hint: S.of(context).requestID,
      controller: requestController,
      onChanged: (_) => setState(() {}),
      textStyle: StyleText.fontSize14Weight400.copyWith(
        color: AppColors.blackButton,
      ),
      height: 36.sp,
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

  //////////////////////////////// Approval Cycle  Mobile //////////////////////////////
  Widget _buildApprovalCycle(ApprovalSection section) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(section.selectedApprovers.length, (index) {
        final employee = section.selectedApprovers[index];

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
                  SizedBox(
                    width: 2.sp,
                  ), // Reserve equal width to align with arrow size
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
                        assetPath: employee.gender == "male"
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
                              ? "${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}"
                              : "${employee.firstName ?? ''} ${employee.lastName ?? ''}",
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
                              ? employee.titleInArabic ?? ''
                              : employee.title ?? '',
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

  //////////////////////////////// Approval Cycle  Mobile //////////////////////////////

  ////////////////////////// label item //////////////////////////////

  Widget itemTextProduct({
    required String label,
    required String value,
    required String image,
    Color? valueColor,
  }) {
    final isMobile = context.isPhone;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // image
        CustomSvgImage(
          assetPath: image,
          width: 11.sp,
          height: 11.sp,
          fit: BoxFit.scaleDown,
          color: AppColors.secondaryText,
        ),

        SizedBox(width: 3.sp),

        // space
        Text(
          FormatHelper.capitalize(label),
          style: isMobile
              ? StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.secondaryText,
                )
              : StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
        ),
        Text(
          FormatHelper.capitalize(value),
          style: isMobile
              ? StyleText.fontSize12Weight500.copyWith(
                  color: valueColor ?? AppColors.blackButton,
                )
              : StyleText.fontSize14Weight500.copyWith(
                  color: valueColor ?? AppColors.blackButton,
                ),
        ),
      ],
    );
  }

  ////////////////////////// label item //////////////////////////////
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

  //////////////////////////////// Approval Cycle //////////////////////////////
  Widget buildApprovalCycleRow(ApprovalSection section) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    var theme = Theme.of(context).brightness == Brightness.light;

    return Column(
      children: List.generate(
        (section.selectedApprovers.length / 5).ceil(), // Changed to 5
        (rowIndex) {
          final rowItems = section.selectedApprovers
              .skip(rowIndex * 5)
              .take(5)
              .toList(); // Changed to 5

          return Padding(
            padding: EdgeInsets.only(bottom: 8.sp),
            child: Row(
              children: List.generate(rowItems.length * 2 - 1, (i) {
                if (i.isEven) {
                  final index = i ~/ 2;
                  final employee = rowItems[index];
                  return Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
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
                        ],
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
                              color: theme
                                  ? AppColors.blackButton
                                  : AppColors.white,
                            ),
                          ),
                          Text(
                            FormatHelper.capitalize(
                              isEnglish
                                  ? employee.title ?? ''
                                  : employee.titleInArabic ?? '',
                            ),
                            style: StyleText.fontSize10Weight500.copyWith(
                              color: theme
                                  ? AppColors.secondaryText
                                  : AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.sp),
                    child: Transform.rotate(
                      angle: isEnglish ? 0 : 3.1416,
                      child: CustomSvgImage.natural(
                        assetPath:
                            "assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg",
                        width: 25.sp,
                        color: theme ? AppColors.text : AppColors.whiteShadow,
                      ),
                    ),
                  );
                }
              }),
            ),
          );
        },
      ),
    );
  }

  //////////////////////////////// Approval Cycle //////////////////////////////
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

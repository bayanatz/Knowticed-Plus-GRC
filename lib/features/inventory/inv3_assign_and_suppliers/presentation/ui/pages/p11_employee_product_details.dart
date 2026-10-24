import 'package:knowticed_plus/features/inventory/presentation/ui/widgets/inventory_comments_section.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/select_approval.dart';
import 'package:knowticed_plus/features/inventory/inv2_view_product/presentation/ui/pages/product_details_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/cards/custom_approval_shape.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class EmployeeProductDetailsDesktopScreen extends StatefulWidget {
  const EmployeeProductDetailsDesktopScreen({super.key});

  @override
  State<EmployeeProductDetailsDesktopScreen> createState() =>
      _EmployeeProductDetailsDesktopScreenState();
}

class _EmployeeProductDetailsDesktopScreenState
    extends State<EmployeeProductDetailsDesktopScreen> {
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

  //////////////////////////////////////// Filter person ////////////////////////////////////

  final List<Map<String, dynamic>> maintenanceDummyData = [
    {
      "status": "Complete",
      "statusColor": Colors.green,
      "icon": "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
      "scheduleDate": "23 Feb 2024",
      "requestedDate": "22 Nov 2024",
      "startDate": "23 Feb 2024",
      "endDate": "23 Feb 2024",
    },
    {
      "status": "Pending",
      "statusColor": Colors.orange,
      "icon": "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
      "scheduleDate": "12 Jun 2024",
      "requestedDate": "10 Jun 2024",
      "startDate": "12 Jun 2024",
      "endDate": "13 Jun 2024",
    },
    {
      "status": "In Progress",
      "statusColor": Colors.blue,
      "icon": "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
      "scheduleDate": "01 Jul 2024",
      "requestedDate": "28 Jun 2024",
      "startDate": "01 Jul 2024",
      "endDate": "03 Jul 2024",
    },
  ];

  //////////////////////////////////////// Filter person ////////////////////////////////////

  bool isHidden = false;

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    Localizations.localeOf(context).languageCode == 'ar';
    Localizations.localeOf(context).languageCode == 'en';
    final isTablet = context.isTablet;
    final isMobile = context.isPhone;
    final isLandscape = context.isLandscape;
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
                                      itemTextProductWithColor(
                                        value: "+2010258963",
                                        label: "${S.of(context).phoneNumber}: ",
                                        image:
                                            "assets/icons_assets/main_icons_assets/ic_comms_phone.svg",
                                      ),
                                      // space
                                      SizedBox(height: 5.sp),
                                      // Email
                                      itemTextProductWithColor(
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
                                          itemTextProductWithColor(
                                            value: "Technician",
                                            label: "${S.of(context).title}: ",
                                            image:
                                                "assets/icons_assets/main_icons_assets/ic_file_doc.svg",
                                          ),

                                          // Email
                                          itemTextProductWithColor(
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
                                          itemTextProductWithColor(
                                            value: "IT",
                                            label:
                                                "${S.of(context).department}: ",
                                            image:
                                                "assets/icons_assets/main_icons_assets/ic_building_office.svg",
                                          ),

                                          // Phone Number
                                          itemTextProductWithColor(
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
                SizedBox(height: 20.sp),
                // Request Id & Retrieve Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Request Id
                    Text(
                      "${S.of(context).requestId}: ",
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                    Text(
                      "001",
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),

                    Spacer(),

                    // Retrieve button
                    Container(
                      width: isMobile ? 120.sp : 150.sp,
                      height: 30.sp,
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: InkWell(
                        onTap: () {
                          HapticController
                              .low(); // list row: on the tap (X-117)
                          // Your function here
                        },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.sp),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomSvgImage.natural(
                                assetPath:
                                    "assets/icons_assets/main_icons_assets/ic_restore.svg",
                                width: 24.sp,
                                height: 24.sp,
                              ),
                              SizedBox(width: 8.sp),
                              Text(
                                S.of(context).retrieve,
                                style: StyleText.fontSize16Weight500.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // space
                SizedBox(height: 8.sp),

                // centre content
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
                      children: [
                        // First Section
                        isMobile
                            ? Row(
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
                                  // space
                                  SizedBox(width: 5.sp),
                                  // Asset ID: &  Category & Subcategory  & Brand
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      itemText(
                                        value: "001",
                                        label: "${S.of(context).assetId}: ",
                                      ),
                                      SizedBox(height: 7.sp),
                                      itemText(
                                        value: "Electronics Electronics  ",
                                        label: "${S.of(context).category}: ",
                                      ),
                                      SizedBox(height: 7.sp),
                                      itemText(
                                        value: "Computer Computer",
                                        label: "${S.of(context).subcategory}: ",
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
                                        value: "3 Years",
                                        label:
                                            "${S.of(context).expectedLifetime}: ",
                                      ),
                                      SizedBox(height: 7.sp),
                                      itemText(
                                        value: "New",
                                        label: "${S.of(context).condition}: ",
                                      ),
                                      SizedBox(height: 7.sp),
                                      itemText(
                                        value: "10",
                                        label: "${S.of(context).quantity}: ",
                                      ),
                                      // Pick Up Date
                                      itemText(
                                        value: "28 Nov 2024",
                                        label: "${S.of(context).pickUpDate}: ",
                                      ),
                                      // space
                                      SizedBox(height: 7.sp),
                                      // Reason Of Return
                                      itemText(
                                        value: "Damaged",
                                        label:
                                            "${S.of(context).reasonOfReturn}: ",
                                      ),
                                      // space
                                      SizedBox(height: 7.sp),
                                      // Damage Type
                                      itemText(
                                        value: "Physical Impact",
                                        label: "${S.of(context).damageType}: ",
                                      ),
                                      // space
                                      SizedBox(height: 7.sp),
                                      // Date Requested
                                      itemText(
                                        value: "15 Oct 2024",
                                        label:
                                            "${S.of(context).dateRequested}: ",
                                      ),
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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                                  "Dell GS 15",
                                                  style: StyleText
                                                      .fontSize14Weight400
                                                      .copyWith(
                                                    color:
                                                        AppColors.blackButton,
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

                        // space
                        SizedBox(height: 15.sp),

                        // Reason of Return
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
                                      text: "${S.of(context).reasonOfReturn}: ",
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
                                      text:
                                          "Lorem Ipsum Lorem IpsumLorem IpsumLorem IpsumLorem "
                                          "IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem",
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
                        SizedBox(height: 20.sp),
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
                        SizedBox(height: 13.sp),

                        // Approval Cycle item
                        isMobile
                            ? _buildApprovalCycle(section)
                            : buildApprovalCycleRow(section),

                        // // qr code image &  Download as PNG & and state
                        isMobile
                            ? Column(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                  SizedBox(height: 25.sp),
                                  customButton(
                                    title: S.of(context).inUse,
                                    function: () {},
                                    radius: 8.r,
                                    borderColor: Color(0xff4BB609),
                                    textStyle: StyleText.fontSize16Weight500
                                        .copyWith(color: Color(0xff4BB609)),
                                    height: 36.sp,
                                    width: MediaQuery.sizeOf(context).width,
                                    color: Colors.transparent,
                                  ),
                                ],
                              )
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
                                  customButton(
                                    title: S.of(context).inUse,
                                    function: () {},
                                    radius: 8.r,
                                    borderColor: Color(0xff4BB609),
                                    textStyle: StyleText.fontSize16Weight500
                                        .copyWith(color: Color(0xff4BB609)),
                                    height: 36.sp,
                                    width: 250.sp,
                                    color: Colors.transparent,
                                  ),
                                ],
                              ),

                        // space
                        SizedBox(height: 15.sp),
                      ],
                    ),
                  ),
                ),

                // space
                SizedBox(height: 20.sp),

                // Maintenance Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).maintenanceDetails,
                      style: StyleText.fontSize20Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        HapticController.low(); // list row: on the tap (X-117)
                        setState(() {
                          isHidden = !isHidden;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // aligns underline with text
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

                // space
                SizedBox(height: 8.sp),

                if (!isHidden)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: CrossAxisCountHelper
                          .getCrossAxisCountForDefaultTablet2(
                        context,
                      ),
                      crossAxisSpacing: 15.sp,
                      mainAxisSpacing: 15.sp,
                      mainAxisExtent: 89.sp,
                    ),
                    itemCount: maintenanceDummyData.length,
                    itemBuilder: (context, index) {
                      final item = maintenanceDummyData[index];
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15.sp,
                          vertical: 8.sp,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Calendar icon and two labels
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // image
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
                                      color: AppColors.blackButton,
                                      assetPath:
                                          "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
                                      fit: BoxFit.scaleDown,
                                      width: 40.sp,
                                      height: 40.sp,
                                    ),
                                  ),
                                ),
                                // space
                                SizedBox(width: 5.sp),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      itemText(
                                        label: "${S.of(context).schedule}: ",
                                        value: "23 Feb 2024",
                                      ),
                                      SizedBox(height: 4.sp),
                                      itemText(
                                        label: "${S.of(context).requested}: ",
                                        value: "22 Nov 2024",
                                      ),
                                      SizedBox(height: 4.sp),
                                      itemText(
                                        label: "${S.of(context).type}: ",
                                        value: "Repair",
                                      ),
                                    ],
                                  ),
                                ),

                                // Top Row: Status
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Text(
                                        '${S.of(context).status}: ',
                                        style: StyleText.fontSize10Weight500
                                            .copyWith(
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "${item["status"]}",
                                      style: StyleText.fontSize10Weight500
                                          .copyWith(
                                        color: item[
                                            "statusColor"], // dynamic status color
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 6.sp),
                            // Start and End date row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                itemText(
                                  label: "${S.of(context).startDate}: ",
                                  value: item["startDate"],
                                ),
                                itemText(
                                  label: "${S.of(context).endDate}: ",
                                  value: item["endDate"],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                SizedBox(height: 20.sp),

                // Inquiries And Comments and expand section
                // 22/10/2026 (Moataz): the Settings comments box.
                InventoryCommentsSection(screen: 'employee_product_details'),
                // space
                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /////////////////////////////// Approval Cycle  Mobile //////////////////////////////
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

  //////////////////////////////// Approval Cycle //////////////////////////////

  //////////////////////////// Section One ///////////////////////////////////

  Widget sectionOne() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemTextProduct(
          value: "100000000",
          label: "${S.of(context).productID}: ",
        ),
        SizedBox(height: 7.sp),
        itemTextProduct(
          value: "Asset",
          label: "${S.of(context).productType}: ",
        ),
        SizedBox(height: 7.sp),
        GestureDetector(
          onTap: () {
            // navigateTo(context, EmployeeDetails());
          },
          child: itemTextProduct(
            value: "TechSource Solutions",
            label: "${S.of(context).supplierName}: ",
            valueStyle: StyleText.fontSize11Weight400.copyWith(
              color: Color(0xff347AE2),
            ),
          ),
        ),
        SizedBox(height: 7.sp),
        itemTextProduct(
          value: "Electronics Electronics  ",
          label: "${S.of(context).category}: ",
        ),
      ],
    );
  }

  //////////////////////////// Section One ///////////////////////////////////

  //////////////////////////// Section Two ///////////////////////////////////

  Widget sectionTwo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemTextProduct(
          value: "Computer Computer",
          label: "${S.of(context).subcategory}: ",
        ),
        SizedBox(height: 7.sp),
        itemTextProduct(value: "Dell", label: "${S.of(context).brand}: "),
        SizedBox(height: 7.sp),
        itemTextProduct(value: "GZ 15", label: "${S.of(context).model}: "),
        SizedBox(height: 7.sp),
        itemTextProduct(
          value: "Bi-Weekly",
          label: "${S.of(context).maintenanceFrequency}: ",
        ),
        SizedBox(height: 7.sp),
        itemTextProduct(value: "100", label: "${S.of(context).quantity}: "),
        SizedBox(height: 7.sp),
        itemTextProduct(
          value: "5 Years",
          label: "${S.of(context).expectedLifetime}: ",
        ),
      ],
    );
  }

  //////////////////////////// Section Two ///////////////////////////////////

  //////////////////////////// Section Three ///////////////////////////////////

  Widget sectionThree() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemTextProduct(
          value: "28 Nov 2025",
          label: "${S.of(context).inServiceDate}: ",
        ),
        SizedBox(height: 7.sp),
        itemTextProduct(
          value: "10 / 100",
          label: "${S.of(context).reorderLevel}: ",
        ),
        SizedBox(height: 7.sp),
        itemTextProduct(value: "10", label: "${S.of(context).unitCost}: "),
        SizedBox(height: 7.sp),
        itemTextProduct(value: "USA", label: "${S.of(context).currency}: "),
        SizedBox(height: 7.sp),
        itemTextProduct(
          value: "Electronic",
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

  ////////////////////////// label item //////////////////////////////

  Widget itemTextProductWithColor({
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
          color: AppColors.secondaryText,
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

class MessageModel {
  final String senderName;
  final String senderTitle;
  final String avatarPath;
  final String? text;
  final String? imagePath; // NEW
  final DateTime timestamp;
  final String? docId;

  MessageModel({
    required this.senderName,
    required this.senderTitle,
    required this.avatarPath,
    this.text,
    this.imagePath,
    required this.timestamp,
    this.docId,
  });
}

class ChatCommentSection extends StatefulWidget {
  const ChatCommentSection({
    super.key,
    required this.serviceId,
    required this.modelId,
  });

  final String serviceId;
  final String modelId;

  @override
  State<ChatCommentSection> createState() => _ChatCommentSectionState();
}

class _ChatCommentSectionState extends State<ChatCommentSection> {
  bool isExpanded = false;
  final List<MessageModel> messages = [];
  final LiveRefresh _live = LiveRefresh();
  final TextEditingController _controller = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  String _getMonth(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthNames[month - 1];
  }

  Future<void> _loadComments({bool replace = false}) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Demo')
        .doc(widget.serviceId)
        .collection('RequestServices')
        .doc(widget.modelId)
        .collection('comments')
        .orderBy('timestamp')
        .get();

    final loadedMessages = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return MessageModel(
        senderName: data['senderName'] ?? '',
        senderTitle: data['senderTitle'] ?? '',
        avatarPath:
            'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png',
        text: data['text'],
        imagePath: data['imagePath'],
        timestamp: (data['timestamp']).toDate(),
        docId: doc.id, // ✅ Save Firestore document ID
      );
    }).toList();

    if (!mounted) return;
    setState(() {
      if (replace) messages.clear();
      messages.addAll(loadedMessages);
    });
    _live.watchPaths(<String>[
      'Demo/${widget.serviceId}/RequestServices/${widget.modelId}/comments',
    ], () => _loadComments(replace: true));
  }

  @override
  void dispose() {
    _live.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final String firstName = prefs.getString("firstNameRequester") ?? '';
    final String lastName = prefs.getString("lastNameRequester") ?? '';
    final String jobTitle = prefs.getString("jobTitleRequester") ?? '';
    final String fullName = '$firstName $lastName'.trim();

    final DateTime now = DateTime.now();

    final comment = MessageModel(
      senderName: fullName,
      senderTitle: jobTitle,
      avatarPath:
          'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png',
      text: text,
      imagePath: null,
      timestamp: now,
    );

    setState(() {
      messages.add(comment);
      _controller.clear();
    });

    // Save to Firestore
    await FirebaseFirestore.instance
        .collection('Demo')
        .doc(widget.serviceId)
        .collection('RequestServices')
        .doc(widget.modelId)
        .collection('comments')
        .add({
      'senderName': comment.senderName,
      'senderTitle': comment.senderTitle,
      'text': comment.text,
      'timestamp': now,
    });
  }

  ///edit message function
  void _editMessage(int index) {
    final MessageModel message = messages[index];
    if (message.text == null || message.docId == null) return;

    final TextEditingController editController = TextEditingController(
      text: message.text,
    );

    CustomDialogManager.showInput(
      context: context,
      controller: editController,
      title: S.of(context).editYourMessage,
      hint: S.of(context).editYourMessage,
      maxLines: 3,
      cancelText: S.of(context).cancel,
      confirmText: S.of(context).save,
      onConfirm: () async {
        final newText = editController.text.trim();
        if (newText.isNotEmpty) {
          // Update local state
          setState(() {
            messages[index] = MessageModel(
              senderName: message.senderName,
              senderTitle: message.senderTitle,
              avatarPath: message.avatarPath,
              text: newText,
              imagePath: null,
              timestamp: message.timestamp,
              docId: message.docId,
            );
          });

          // ✅ Update Firestore
          await FirebaseFirestore.instance
              .collection('Demo')
              .doc(widget.serviceId)
              .collection('RequestServices')
              .doc(widget.modelId)
              .collection('comments')
              .doc(message.docId)
              .update({'text': newText});
        }
      },
    );
  }

  ///delete message function
  void _deleteMessage(int index) async {
    final MessageModel message = messages[index];
    if (message.docId == null) return;

    // Delete from Firestore
    await FirebaseFirestore.instance
        .collection('Demo')
        .doc(widget.serviceId)
        .collection('RequestServices')
        .doc(widget.modelId)
        .collection('comments')
        .doc(message.docId)
        .delete();

    // Delete locally
    setState(() {
      messages.removeAt(index);
    });
  }

  Future<void> _launchExternal(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Widget _buildMediaPreview(MessageModel msg) {
    final imageUrl = msg.imagePath!;
    final isImage = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
    ].any((ext) => imageUrl.toLowerCase().contains(ext));
    final isPDF = imageUrl.toLowerCase().contains('.pdf');

    if (isImage) {
      return GestureDetector(
        onTapDown: (_) => HapticController.low(),
        onTap: () => _launchExternal(imageUrl),
        child: Row(
          children: [
            CustomSvgImage.natural(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg',
              width: 35.sp,
              height: 35.sp,
              fit: BoxFit.scaleDown,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                msg.text ?? 'Image',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    } else if (isPDF) {
      return GestureDetector(
        onTapDown: (_) => HapticController.low(),
        onTap: () => launchUrl(Uri.parse(imageUrl)),
        child: Row(
          children: [
            CustomSvgImage.natural(
              assetPath: 'assets/icons_assets/main_icons_assets/ic_pdf.svg',
              width: 35.sp,
              height: 35.sp,
              fit: BoxFit.scaleDown,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                msg.text ?? 'PDF Document',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTapDown: (_) => HapticController.low(),
        onTap: () => launchUrl(Uri.parse(imageUrl)),
        child: Row(
          children: [
            CustomSvgImage.natural(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_pdf.svg', // fallback icon
              width: 24,
              height: 24,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                msg.text ?? 'Document',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }

  // delete or Edit
  void _showCustomMenu(BuildContext context, Offset position, int index) {
    showAppDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        String? selectedItem; // to track selection

        return StatefulBuilder(
          builder: (context, setState) {
            return Stack(
              children: [
                Positioned(
                  left: position.dx,
                  top: position.dy,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 150.w,
                      padding: EdgeInsets.symmetric(vertical: 8.sp),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildOptionItem(
                            label: 'Edit',
                            iconPath:
                                "assets/icons_assets/main_icons_assets/ic_nav_back_curved.svg",
                            isSelected: selectedItem == 'edit',
                            onTap: () {
                              setState(() => selectedItem = 'edit');
                              Future.delayed(Duration(milliseconds: 150), () {
                                if (!context.mounted) return;
                                Navigator.pop(context);
                                _editMessage(index);
                              });
                            },
                            selectedColor: AppColors.red,
                            // 🔴
                            selectedBackground: AppColors.primary, // 🟡
                          ),
                          _buildOptionItem(
                            label: 'Delete',
                            iconPath:
                                "assets/icons_assets/main_icons_assets/ic_delete_trash_red.svg",
                            isSelected: selectedItem == 'delete',
                            onTap: () {
                              setState(() => selectedItem = 'delete');
                              Future.delayed(Duration(milliseconds: 150), () {
                                if (!context.mounted) return;
                                Navigator.pop(context);
                                _deleteMessage(index);
                              });
                            },
                            selectedColor: AppColors.red,
                            selectedBackground: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildOptionItem({
    required String label,
    required String iconPath,
    required bool isSelected,
    required VoidCallback onTap,
    required Color selectedColor,
    Color? selectedBackground,
  }) {
    return GestureDetector(
      onTapDown: hapticDown(onTap, HapticLevel.low),
      onTap: onTap,
      child: Container(
        width: 280.sp,
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: isSelected
              ? (selectedBackground ?? Colors.grey.shade200)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          children: [
            CustomSvgImage.natural(
              assetPath: iconPath,
              fit: BoxFit.scaleDown,
              color: isSelected ? selectedColor : AppColors.secondaryText,
              width: 14.sp,
              height: 14.sp,
            ),
            SizedBox(width: 10.sp),
            Text(
              label,
              style: StyleText.fontSize13Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Data Allow To Pick
  Future<void> _pickMedia() async {
    final prefs = await SharedPreferences.getInstance();
    final String firstName = prefs.getString("firstNameRequester") ?? '';
    final String lastName = prefs.getString("lastNameRequester") ?? '';
    final String jobTitle = prefs.getString("jobTitleRequester") ?? '';
    final String fullName = '$firstName $lastName'.trim();

    if (!mounted) return;
    final choice = await showAppDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => SimpleDialog(
        title: Text(S.of(context).selectFileSource),
        children: [
          _buildMediaOption(S.of(context).camera, 'camera'),
          _buildMediaOption(S.of(context).gallery, 'gallery'),
          _buildMediaOption(S.of(context).document, 'document'),
          _buildMediaOption(S.of(context).cancel, null),
        ],
      ),
    );

    if (choice == null) return;

    String? filePath;
    String? fileName;

    if (choice == 'camera' || choice == 'gallery') {
      final source =
          choice == 'camera' ? ImageSource.camera : ImageSource.gallery;
      final XFile? imageFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (imageFile == null) return;
      filePath = imageFile.path;
      fileName = imageFile.name;
    } else if (choice == 'document') {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      if (result == null || result.files.single.path == null) return;
      filePath = result.files.single.path!;
      fileName = result.files.single.name;
    }

    if (filePath == null || fileName == null) return;

    try {
      // Upload to Firebase Storage
      // final ref = FirebaseStorage.instance.ref(
      //   'comments_attachments/${DateTime.now().millisecondsSinceEpoch}_$fileName',
      // );
      //  await ref.putFile(File(filePath));
      //   final downloadUrl = await ref.getDownloadURL();

      final DateTime now = DateTime.now();

      final message = MessageModel(
        senderName: fullName,
        senderTitle: jobTitle,
        avatarPath: 'assets/icons_assets/main_icons_assets/ic_pdf.svg',
        text: fileName,
        imagePath: "downloadUrl",
        timestamp: now,
      );

      setState(() {
        messages.add(message);
      });

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('Demo')
          .doc(widget.serviceId)
          .collection('RequestServices')
          .doc(widget.modelId)
          .collection('comments')
          .add({
        'senderName': fullName,
        'senderTitle': jobTitle,
        'text': fileName,
        'imagePath': "downloadUrl",
        'timestamp': now,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).uploadSuccess)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${S.of(context).uploadFailed}: $e')),
      );
    }
  }

  Widget _buildMediaOption(String title, String? returnVal) {
    return Padding(
      padding: EdgeInsets.all(8.sp),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: SimpleDialogOption(
            onPressed: () => Navigator.pop(context, returnVal),
            child: Text(
              title,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.textButton,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // InquiriesAndComments & Expand & Hide
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // InquiriesAndComments
              Text(
                S.of(context).inquiriesAndComments,
                style: StyleText.fontSize22Weight700.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              Spacer(),
              // Expand & Hide
              GestureDetector(
                onTapDown: (_) => HapticController.low(),
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Text.rich(
                  TextSpan(
                    text:
                        isExpanded ? S.of(context).hide : S.of(context).expand,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: const Color(0xFF1877F2),
                      decoration: TextDecoration.underline,
                      decorationThickness: 1.2,
                      // Optional: controls thickness
                      decorationColor: const Color(0xFF1877F2),
                    ),
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),

          // space
          SizedBox(height: 8.sp),

          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  /// Message List
                  if (messages.isNotEmpty)
                    // Comment List View
                    ListView.builder(
                      itemCount: messages.length,
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: 15.sp,
                            left: 15.sp,
                            right: 15.sp,
                            top: 15.sp,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              /// Avatar + Name/Title
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipOval(
                                    child: CustomSvgImage.natural(
                                      assetPath:
                                          "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
                                      width: 35.sp,
                                      height: 35.sp,
                                      fit: BoxFit.scaleDown,
                                      semanticsLabel: 'Dart Logo',
                                    ),
                                  ),
                                  SizedBox(width: 10.sp),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg.senderName,
                                        style: StyleText.fontSize14Weight500
                                            .copyWith(
                                          color: Theme.of(
                                                    context,
                                                  ).brightness ==
                                                  Brightness.light
                                              ? AppColors.blackButton
                                              : AppColors.white,
                                        ),
                                      ),
                                      Text(
                                        msg.senderTitle,
                                        style: StyleText.fontSize12Weight500
                                            .copyWith(
                                          color: Theme.of(
                                                    context,
                                                  ).brightness ==
                                                  Brightness.light
                                              ? AppColors.secondaryText
                                              : AppColors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              /// Message or Image Bubble
                              GestureDetector(
                                onLongPressStart: (details) {
                                  _showCustomMenu(
                                    context,
                                    details.globalPosition,
                                    index,
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(top: 10.sp),
                                  child: Container(
                                    padding: msg.text != null
                                        ? EdgeInsets.symmetric(
                                            horizontal: 14.sp,
                                            vertical: 12.sp,
                                          )
                                        : EdgeInsets.all(8.sp),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: msg.imagePath != null
                                        ? _buildMediaPreview(msg)
                                        : Text(msg.text ?? ''),
                                  ),
                                ),
                              ),

                              /// Timestamp
                              Padding(
                                padding: EdgeInsets.only(top: 8.sp),
                                child: Text(
                                  "${msg.timestamp.day} ${_getMonth(msg.timestamp.month)} ${msg.timestamp.year} At ${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')} PM",
                                  style: StyleText.fontSize10Weight500.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  /// Input Comment Box
                  Padding(
                    padding: EdgeInsets.only(top: 15.sp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 15.sp),
                        Expanded(
                          child: Container(
                            height: 38.sp,
                            decoration: BoxDecoration(
                              color: AppColors.chatBackground,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 38.sp,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.r),
                                      color: AppColors.card,
                                    ),
                                    child: CustomTextField(
                                      controller: _controller,
                                      prefixIcon: Padding(
                                        padding: EdgeInsets.all(10.sp),
                                        child: GestureDetector(
                                          onTapDown: hapticDown(
                                              _pickMedia, HapticLevel.medium),
                                          onTap: _pickMedia,
                                          child: CustomSvgImage.natural(
                                            assetPath:
                                                "assets/icons_assets/main_icons_assets/ic_cloud_upload.svg",
                                            width: 16.sp,
                                            height: 16.sp,
                                            color: Theme.of(
                                                      context,
                                                    ).brightness ==
                                                    Brightness.light
                                                ? AppColors.secondaryText
                                                : AppColors.whiteShadow,
                                            fit: BoxFit.scaleDown,
                                          ),
                                        ),
                                      ),
                                      hint: S.of(context).writeAComment,
                                      fillColor: AppColors.background,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 15.sp),
                        GestureDetector(
                          onTapDown: (_) => HapticController.medium(),
                          onTap: () async => await _sendMessage(),
                          child: Container(
                            width: 35.sp,
                            height: 35.sp,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryPrimary,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: CustomSvgImage.natural(
                              assetPath:
                                  "assets/icons_assets/main_icons_assets/ic_action_send.svg",
                              width: 20.sp,
                              height: 20.sp,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                        ),
                        SizedBox(width: 15.sp),
                      ],
                    ),
                  ),

                  SizedBox(height: 15.sp),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

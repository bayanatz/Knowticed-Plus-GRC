import 'package:knowticed_plus/features/inventory/presentation/ui/widgets/inventory_comments_section.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/select_approval.dart';
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
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class EmployeeNameDetailsDesktopScreen extends StatefulWidget {
  const EmployeeNameDetailsDesktopScreen({super.key});

  @override
  State<EmployeeNameDetailsDesktopScreen> createState() =>
      _EmployeeNameDetailsDesktopScreenState();
}

class _EmployeeNameDetailsDesktopScreenState
    extends State<EmployeeNameDetailsDesktopScreen> {
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
  bool isHidden = false;
  ////////////////////////////// variable ////////////////////////////////////

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

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    Localizations.localeOf(context).languageCode == 'en';
    [
      {"key": "HandDelivery", "value": S.of(context).handDelivery},
      {"key": "PickUp", "value": S.of(context).pickup},
    ];
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
          secondTitle: S.of(context).employees,
          onSecondTap: () {},
          thirdTitle: S.of(context).employeeName,
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
                    : isTablet && !isLandscape
                        ? Container(
                            // height: 110.sp,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 15.sp,
                                bottom: 15.sp,
                                left: isArabic ? 15.sp : 0,
                                right: isArabic ? 0 : 15.sp,
                              ),
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Row(
                                    children: [
                                      // image
                                      Image(
                                        image: AssetImage(
                                          "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
                                        ),
                                        width: 80.sp,
                                        height: 80.sp,
                                        fit: BoxFit.scaleDown,
                                      ),
                                      // space
                                      SizedBox(width: 10.sp),
                                      // info Employee
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Name of Employee
                                          Row(
                                            children: [
                                              Text(
                                                "Mona Mohammed",
                                                style: StyleText
                                                    .fontSize16Weight500
                                                    .copyWith(
                                                  color: AppColors.blackButton,
                                                ),
                                              ),

                                              // Message button
                                            ],
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
                                                    label:
                                                        "${S.of(context).title}: ",
                                                    image:
                                                        "assets/icons_assets/main_icons_assets/ic_file_doc.svg",
                                                  ),

                                                  SizedBox(height: 10.sp),

                                                  // Email
                                                  itemTextProduct(
                                                    value:
                                                        "Mona.Mohamed@GulfDev.com",
                                                    label:
                                                        "${S.of(context).email}: ",
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
                                                  // space
                                                  SizedBox(height: 10.sp),
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
                                    ],
                                  ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Name of Employee
                                      Text(
                                        "Mona Mohammed",
                                        style: StyleText.fontSize16Weight500
                                            .copyWith(
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
                                                label:
                                                    "${S.of(context).title}: ",
                                                image:
                                                    "assets/icons_assets/main_icons_assets/ic_file_doc.svg",
                                              ),
                                              // space
                                              SizedBox(height: 10.sp),
                                              // Email
                                              itemTextProduct(
                                                value:
                                                    "Mona.Mohamed@GulfDev.com",
                                                label:
                                                    "${S.of(context).email}: ",
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
                                              // space
                                              SizedBox(height: 10.sp),
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
                      width: 150.sp,
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
                                borderRadius: BorderRadius.circular(4.r),
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
                            sectionOneInfo(),
                            isTablet && !isLandscape
                                ? SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * .05,
                                  )
                                : SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * .11,
                                  ),
                            // subcategory &  brand & model  & expectedLifetime
                            sectionTwoInfo(),
                            // space
                            isTablet && !isLandscape
                                ? SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * .05,
                                  )
                                : SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * .11,
                                  ),
                            // subcategory &  brand & model  & expectedLifetime
                            sectionThreeInfo(),
                          ],
                        ),

                        // name of product
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Dell GS 15",
                              style: StyleText.fontSize14Weight400.copyWith(
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
                              style: StyleText.fontSize12Weight500.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),

                            // value of Additional Note:
                            Text(
                              "Lorem Ipsum Lorem IpsumLorem IpsumLorem",
                              style: StyleText.fontSize12Weight500.copyWith(
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

                        // space
                        SizedBox(height: 20.sp),

                        // // qr code image &  Download as PNG & and state
                        Row(
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
                                          .copyWith(color: Color(0xff1877F2)),
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
                              textStyle: StyleText.fontSize16Weight500.copyWith(
                                color: Color(0xff4BB609),
                              ),
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

                SizedBox(height: 20.sp),

                //  Employee Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).requestDetails,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),
                //space
                SizedBox(height: 8.sp),
                // Requested Date &  Priority  & 	Description of Issue/Service Needed
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.card,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15.sp),
                    child: SizedBox(
                      child: Column(
                        children: [
                          // Requested Date &  Priority
                          Row(
                            children: [
                              // Requested Date
                              Expanded(
                                child: CustomDateField(
                                  value: DateFormat('d/M/yyyy')
                                      .tryParse((selectedDeliveryMethod) ?? ''),
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
                                  label: S.of(context).dateRequested,
                                  hint: "24 Nov 2018",
                                  height: 36.sp,
                                ),
                              ),
                              // space
                              SizedBox(width: 20.sp),
                              // Priority
                              Expanded(
                                child: // Selected Product
                                    CustomDropdown<String>(
                                  items: (selectedPriorityList)
                                      .map((e) => DropdownItem<String>(
                                          value: e['key'] ?? '',
                                          label: e['value'] ?? ''))
                                      .toList(),
                                  value: selectedPriority,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedPriority = value;
                                    });
                                  },
                                  label: S.of(context).priority,
                                  hint: S.of(context).priorityHigh,
                                  height: 36.sp,
                                  fillColor: AppColors.background,
                                ),
                              ),
                            ],
                          ),

                          // Description of Issue/Service Needed
                          Row(
                            children: [
                              Expanded(
                                child: CustomValidatedTextFieldMaster(
                                  label: S.of(context).descriptionOfIssue,
                                  maxLines: 3,
                                  height: 72.sp,
                                  hint: S.of(context).textHere,
                                  controller: descriptionOfIssueController,
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
                ),

                // Space
                SizedBox(height: 20.sp),

                // Maintenance ID  &  Maintenance Status  & 	Request Type &  Maintenance Service
                // Assigned To  &  Assignment Date  &  Estimated Completion Date  &  Start Date
                // End Date  &  Next Scheduled Maintenance
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.card,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15.sp),
                    child: SizedBox(
                      child: Column(
                        children: [
                          // Maintenance ID & Maintenance Status & Request Type & Maintenance Service
                          Row(
                            children: [
                              // Maintenance ID & Maintenance Status
                              Expanded(
                                child: Row(
                                  children: [
                                    // Maintenance ID
                                    Expanded(
                                      child: CustomValidatedTextFieldMaster(
                                        label: S.of(context).maintenanceId,
                                        hint: "011",
                                        controller:
                                            descriptionOfIssueController,
                                        textDirection: ui.TextDirection.ltr,
                                        onlyDigits: false,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),

                                    // space
                                    SizedBox(width: 15.sp),

                                    // Maintenance Status
                                    Expanded(
                                      child: CustomValidatedTextFieldMaster(
                                        label: S.of(context).maintenanceStatus,
                                        hint: S.of(context).onHold,
                                        controller:
                                            descriptionOfIssueController,
                                        textDirection: ui.TextDirection.ltr,
                                        onlyDigits: false,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // space
                              SizedBox(width: 20.sp),
                              // Request Type & Maintenance Service
                              Expanded(
                                child: Row(
                                  children: [
                                    // Request Type
                                    Expanded(
                                      child: CustomValidatedTextFieldMaster(
                                        label: S.of(context).requestType,
                                        hint: S.of(context).maintenance,
                                        controller:
                                            descriptionOfIssueController,
                                        textDirection: ui.TextDirection.ltr,
                                        onlyDigits: false,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                    // space
                                    SizedBox(width: 15.sp),
                                    // Maintenance Service
                                    Expanded(
                                      child: CustomValidatedTextFieldMaster(
                                        label: S.of(context).maintenanceService,
                                        hint: "",
                                        controller:
                                            descriptionOfIssueController,
                                        textDirection: ui.TextDirection.ltr,
                                        onlyDigits: false,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // space
                          SizedBox(height: 15.sp),

                          // Assigned To & Assignment Date
                          Row(
                            children: [
                              // Assigned To
                              Expanded(
                                child: CustomValidatedTextFieldMaster(
                                  label: S.of(context).assignedTo,
                                  hint: "",
                                  controller: descriptionOfIssueController,
                                  textDirection: ui.TextDirection.ltr,
                                  onlyDigits: false,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),

                              SizedBox(width: 15.sp),

                              // Assignment Date
                              Expanded(
                                child: CustomDateField(
                                  value: DateFormat('d/M/yyyy')
                                      .tryParse((selectedDeliveryMethod) ?? ''),
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
                                  label: S.of(context).assignedDate,
                                  hint: "24 Nov 2018",
                                  height: 36.sp,
                                ),
                              ),
                            ],
                          ),

                          // space
                          SizedBox(height: 15.sp),

                          // Estimated Completion Date & Start Date
                          Row(
                            children: [
                              // Estimated Completion Date
                              Expanded(
                                child: CustomDateField(
                                  value: DateFormat('d/M/yyyy')
                                      .tryParse((selectedDeliveryMethod) ?? ''),
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
                                  label: S.of(context).estimatedCompletionDate,
                                  hint: "24 Nov 2018",
                                  height: 36.sp,
                                ),
                              ),

                              SizedBox(width: 15.sp),

                              // Start Date
                              Expanded(
                                child: CustomDateField(
                                  value: DateFormat('d/M/yyyy')
                                      .tryParse((selectedDeliveryMethod) ?? ''),
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
                                  label: S.of(context).startDate,
                                  hint: "24 Nov 2018",
                                  height: 36.sp,
                                ),
                              ),
                            ],
                          ),

                          // space
                          SizedBox(height: 15.sp),

                          // End Date & Next Scheduled Maintenance
                          Row(
                            children: [
                              // End Date
                              Expanded(
                                child: CustomDateField(
                                  value: DateFormat('d/M/yyyy')
                                      .tryParse((selectedDeliveryMethod) ?? ''),
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
                                  label: S.of(context).endDate,
                                  hint: "24 Nov 2018",
                                  height: 36.sp,
                                ),
                              ),

                              SizedBox(width: 15.sp),

                              // Next Scheduled Maintenance
                              Expanded(
                                child: CustomDateField(
                                  value: DateFormat('d/M/yyyy')
                                      .tryParse((selectedDeliveryMethod) ?? ''),
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
                                  label: S.of(context).nextScheduledMaintenance,
                                  hint: "24 Nov 2018",
                                  height: 36.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Space
                SizedBox(height: 20.sp),

                // Damage Type  &  Severity Level  &  Warranty & Coverage Status  &  Warranty Expiration Date
                // Recommended Action  &  Asset Conditions  &  Work Performed/Service Actions
                // List Of Items Replaced/Used
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColors.card,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15.sp),
                    child: SizedBox(
                      child: Column(
                        children: [
                          // Damage Type  &  Severity Level
                          Row(
                            children: [
                              // Damage Type
                              Expanded(
                                child: CustomDropdown<String>(
                                  items: (selectDamageTypeList)
                                      .map((e) => DropdownItem<String>(
                                          value: e['key'] ?? '',
                                          label: e['value'] ?? ''))
                                      .toList(),
                                  value: selectDamageType,
                                  onChanged: (value) {
                                    setState(() {
                                      selectDamageType = value;
                                    });
                                  },
                                  label: S.of(context).damageType,
                                  hint: S.of(context).selectDamageType,
                                  height: 36.sp,
                                ),
                              ),

                              // space
                              SizedBox(width: 15.sp),

                              // Severity Level
                              Expanded(
                                child: CustomDropdown<String>(
                                  items: (selectDamageTypeList)
                                      .map((e) => DropdownItem<String>(
                                          value: e['key'] ?? '',
                                          label: e['value'] ?? ''))
                                      .toList(),
                                  value: selectSeverityLevel,
                                  onChanged: (value) {
                                    setState(() {
                                      selectDamageType = value;
                                    });
                                  },
                                  label: S.of(context).severityLevel,
                                  hint: S.of(context).selectDamageType,
                                  height: 36.sp,
                                ),
                              ),
                            ],
                          ),
                          // space
                          SizedBox(height: 15.sp),
                          // Warranty & Coverage Status  &  Warranty Expiration Date
                          Row(
                            children: [
                              // Warranty & Coverage Status
                              Expanded(
                                child: CustomDropdown<String>(
                                  items: (selectDamageTypeList)
                                      .map((e) => DropdownItem<String>(
                                          value: e['key'] ?? '',
                                          label: e['value'] ?? ''))
                                      .toList(),
                                  value: selectWarrantyCoverageStatus,
                                  onChanged: (value) {
                                    setState(() {
                                      selectWarrantyCoverageStatus = value;
                                    });
                                  },
                                  label: S.of(context).warrantyCoverageStatus,
                                  hint: S.of(context).selectDamageType,
                                  height: 36.sp,
                                ),
                              ),

                              // space
                              SizedBox(width: 15.sp),

                              // Warranty Expiration Date
                              Expanded(
                                child: CustomDateField(
                                  value: DateFormat('d/M/yyyy')
                                      .tryParse((selectedDeliveryMethod) ?? ''),
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
                                  label: S.of(context).warrantyExpirationDate,
                                  hint: "24 Nov 2018",
                                  height: 36.sp,
                                ),
                              ),
                            ],
                          ),
                          // space
                          SizedBox(height: 15.sp),
                          // Recommended Action  &  Asset Conditions
                          Row(
                            children: [
                              // Recommended Action
                              Expanded(
                                child: CustomDropdown<String>(
                                  items: (selectDamageTypeList)
                                      .map((e) => DropdownItem<String>(
                                          value: e['key'] ?? '',
                                          label: e['value'] ?? ''))
                                      .toList(),
                                  value: selectRecommendedAction,
                                  onChanged: (value) {
                                    setState(() {
                                      selectRecommendedAction = value;
                                    });
                                  },
                                  label: S.of(context).recommendedAction,
                                  hint: S.of(context).selectDamageType,
                                  height: 36.sp,
                                ),
                              ),

                              // space
                              SizedBox(width: 15.sp),

                              // Asset Conditions
                              Expanded(
                                child: CustomDropdown<String>(
                                  items: (selectDamageTypeList)
                                      .map((e) => DropdownItem<String>(
                                          value: e['key'] ?? '',
                                          label: e['value'] ?? ''))
                                      .toList(),
                                  value: selectAssetConditions,
                                  onChanged: (value) {
                                    setState(() {
                                      selectAssetConditions = value;
                                    });
                                  },
                                  label: S.of(context).assetConditions,
                                  hint: S.of(context).selectDamageType,
                                  height: 36.sp,
                                ),
                              ),
                            ],
                          ),

                          // space
                          SizedBox(height: 15.sp),

                          // Work Performed/Service Actions
                          Row(
                            children: [
                              // Recommended Action
                              Expanded(
                                child: CustomValidatedTextFieldMaster(
                                  label: S.of(context).workPerformed,
                                  maxLines: 3,
                                  height: 72.sp,
                                  hint: S.of(context).textHere,
                                  controller: workPerformedController,
                                  textDirection: ui.TextDirection.ltr,
                                  onlyDigits: false,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),

                          // space
                          SizedBox(height: 15.sp),

                          // List Of Items Replaced/Used
                          Row(
                            children: [
                              // List Of Items Replaced/Used
                              Expanded(
                                child: CustomValidatedTextFieldMaster(
                                  label: S.of(context).itemsReplacedUsed,
                                  maxLines: 3,
                                  height: 72.sp,
                                  hint: S.of(context).textHere,
                                  controller: listOfItemsController,
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
                ),

                // Space
                SizedBox(height: 20.sp),

                // Inquiries And Comments and expand section
                // 22/10/2026 (Moataz): the Settings comments box.
                InventoryCommentsSection(screen: 'employee_name_details'),

                SizedBox(height: 20.sp),

                // space
                SizedBox(height: 20.sp),

                /*
                   // Maintenance Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(S.of(context).maintenanceDetails,style: StyleText.fontSize20Weight600.copyWith(
                        color: AppColors.blackButton
                    ),),

                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        HapticController.low(); // list row: on the tap (X-117)
                        setState(() {
                          isHidden = !isHidden;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // aligns underline with text
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isHidden ? S.of(context).expand : S.of(context).hide,
                            style: StyleText.fontSize14Weight500.copyWith(
                              color: const Color(0xff1877F2),
                            ),
                            textDirection: Directionality.of(context),
                          ),
                          SizedBox(height: 0.sp), // space between text and line
                          Container(
                            height: 1.sp,
                            width: (isHidden ? S.of(context).expand : S.of(context).hide).length * 7.sp,
                            color: const Color(0xff1877F2),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),

                // space
                SizedBox(height: 8.sp),

                if (!isHidden)GridView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15.sp,
                    mainAxisSpacing: 15.sp,
                    childAspectRatio: 2.8,
                  ),
                  itemCount: maintenanceDummyData.length,
                  itemBuilder: (context, index) {
                    final item = maintenanceDummyData[index];
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.sp,vertical: 8.sp),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [


                          // Top Row: Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Text(
                                  '${S.of(context).status}: ',
                                  style: StyleText.fontSize10Weight500.copyWith(
                                      color: AppColors.secondaryText
                                  ),
                                ),
                              ),

                              Text("${item["status"]}",style: StyleText.fontSize10Weight500.copyWith(
                                color: item["statusColor"], // dynamic status color
                              ),)

                            ],
                          ),
                          // Calendar icon and two labels
                          Row(
                            children: [

                              Image(image: AssetImage("assets/icons_assets/main_icons_assets/ic_time_calendar.svg"),
                                width: 50.sp,
                                height: 50.sp,
                                fit: BoxFit.scaleDown,
                              ),
                              SizedBox(width: 5.sp),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    itemText(
                                      label: "${S.of(context).maintenanceSchedule}: ",
                                      value: item["scheduleDate"],
                                    ),
                                    itemText(
                                      label: "${S.of(context).requestedMaintenance}: ",
                                      value: item["requestedDate"],
                                    ),
                                  ],
                                ),
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
                 */
                SizedBox(height: 15.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///////////////////////////////// section info ////////////////////////////////
  Widget sectionOneInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemText(
          value: "Routine Maintenance",
          label: "${S.of(context).requestType}: ",
        ),
        SizedBox(height: 4.sp),
        itemText(
          value: "Electronics Electronics",
          label: "${S.of(context).category}: ",
        ),
        SizedBox(height: 4.sp),
        itemText(
          value: "Computer Computer",
          label: "${S.of(context).subcategory}: ",
        ),
        SizedBox(height: 4.sp),
        itemText(value: "Dell", label: "${S.of(context).brand}: "),
      ],
    );
  }

  Widget sectionTwoInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemText(value: "GZ 15", label: "${S.of(context).model}: "),
        SizedBox(height: 4.sp),
        itemText(
          value: "3 Years",
          label: "${S.of(context).expectedLifetime}: ",
        ),
        SizedBox(height: 4.sp),
        itemText(value: "New", label: "${S.of(context).condition}: "),
        SizedBox(height: 4.sp),
        itemText(value: "10", label: "${S.of(context).quantity}: "),
        SizedBox(height: 4.sp),
        itemText(value: "New Asset", label: "${S.of(context).assetRequest}: "),
      ],
    );
  }

  Widget sectionThreeInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemText(value: "High", label: "${S.of(context).priority}: "),
        SizedBox(height: 4.sp),
        itemText(
          value: "28 Nov 2025",
          label: "${S.of(context).maintenanceDate}: ",
        ),
        SizedBox(height: 4.sp),
        itemText(value: "28 Nov 2025", label: "${S.of(context).pickUpDate}: "),
        SizedBox(height: 4.sp),
        itemText(
          value: "28 Nov 2025",
          label: "${S.of(context).dateRequested}: ",
        ),
        SizedBox(height: 4.sp),
        itemText(
          value: "28 Nov 2025",
          label: "${S.of(context).expectedReturn}: ",
        ),
      ],
    );
  }
  ///////////////////////////////// section info ////////////////////////////////

  ////////////////////////////// DropDown Var /////////////////////////////////////
  String? selectedDeliveryMethod;
  ////////////////////////////// DropDown Var /////////////////////////////////////

  /////////////////////////// DropDown Item //////////////////////////////////////

  String? selectedPriority;
  String? selectDamageType;
  String? selectSeverityLevel;
  String? selectWarrantyCoverageStatus;
  String? selectRecommendedAction;
  String? selectAssetConditions;

  List<Map<String, String>> selectedPriorityList = [
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

  List<Map<String, String>> selectDamageTypeList = [
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

  /////////////////////////// DropDown Item //////////////////////////////////////

  TextEditingController descriptionOfIssueController = TextEditingController();
  TextEditingController workPerformedController = TextEditingController();
  TextEditingController listOfItemsController = TextEditingController();

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
}

class ApprovalSection {
  String? selectedRequestType;
  List<EmployeeEntity> selectedApprovers;

  ApprovalSection({
    this.selectedRequestType,
    this.selectedApprovers = const [],
  });
}

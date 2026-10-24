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

class AllocatedDetailsEmployee extends StatefulWidget {
  const AllocatedDetailsEmployee({super.key});

  @override
  State<AllocatedDetailsEmployee> createState() =>
      _AllocatedDetailsEmployeeState();
}

class _AllocatedDetailsEmployeeState extends State<AllocatedDetailsEmployee> {
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
  bool isHiddenContent = false;

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
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
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //  Employee Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).employeeDetails,
                      style: StyleText.fontSize16Weight600
                          .copyWith(color: AppColors.blackButton),
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
                                        "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png"),
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
                                                color: AppColors.blackButton),
                                      ),
                                      // space

                                      Text(
                                        "Marketing",
                                        style: StyleText.fontSize12Weight500
                                            .copyWith(
                                                color: AppColors.secondaryText),
                                      ),

                                      Text(
                                        "Marketing Manger",
                                        style: StyleText.fontSize12Weight500
                                            .copyWith(
                                                color: AppColors.secondaryText),
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
                                          label:
                                              "${S.of(context).phoneNumber}: ",
                                          image:
                                              "assets/icons_assets/main_icons_assets/ic_comms_phone.svg"),
                                      // space
                                      SizedBox(height: 5.sp),
                                      // Email
                                      itemTextProduct(
                                          value: "Mona.Mohamed@GulfDev.com",
                                          label: "${S.of(context).email}: ",
                                          image:
                                              "assets/icons_assets/main_icons_assets/ic_comms_sms.svg"),
                                    ],
                                  ),
                                ],
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  itemText(
                                      value: "27 Dec 2024",
                                      label:
                                          "${S.of(context).submissionDate}: ",
                                      valueStyle: StyleText.fontSize10Weight500
                                          .copyWith(
                                              color: AppColors.blackButton),
                                      labelStyle: StyleText.fontSize10Weight500
                                          .copyWith(
                                              color: AppColors.secondaryText)),
                                ],
                              )
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
                                    style: StyleText.fontSize16Weight500
                                        .copyWith(color: AppColors.blackButton),
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
                                                  "assets/icons_assets/main_icons_assets/ic_file_doc.svg"),

                                          // Email
                                          itemTextProduct(
                                              value: "Mona.Mohamed@GulfDev.com",
                                              label: "${S.of(context).email}: ",
                                              image:
                                                  "assets/icons_assets/main_icons_assets/ic_comms_sms.svg"),
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
                                                  "assets/icons_assets/main_icons_assets/ic_building_office.svg"),

                                          // Phone Number
                                          itemTextProduct(
                                              value: "+2010258963",
                                              label:
                                                  "${S.of(context).phoneNumber}: ",
                                              image:
                                                  "assets/icons_assets/main_icons_assets/ic_comms_phone.svg"),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Spacer(),

                              // Message button
                              customButtonWithSvg(
                                  title: S.of(context).msg,
                                  function: () {},
                                  textStyle: StyleText.fontSize16Weight500
                                      .copyWith(color: AppColors.textButton),
                                  width: 135.sp,
                                  height: 38.sp,
                                  space: 8.sp,
                                  radius: 8.r,
                                  color: AppColors.primary,
                                  image:
                                      "assets/icons_assets/main_icons_assets/ic_comms_chat_yellow.svg",
                                  widthImage: 24.sp,
                                  heightImage: 24.sp,
                                  colorBorder: Colors.transparent),
                            ],
                          ),
                        )),
                // space
                SizedBox(height: 20.sp),
                // Request Id & Retrieve Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Request Id
                    Text(
                      "${S.of(context).requestID}: ",
                      style: StyleText.fontSize16Weight600
                          .copyWith(color: AppColors.blackButton),
                    ),
                    Text(
                      "001",
                      style: StyleText.fontSize16Weight600
                          .copyWith(color: AppColors.blackButton),
                    ),

                    // space
                    Spacer(),
                    // Hide & Expand
                    GestureDetector(
                      onTap: () {
                        HapticController.low(); // list row: on the tap (X-117)
                        setState(() {
                          isHiddenContent = !isHiddenContent;
                        });
                      },
                      child: Text(
                        isHidden ? S.of(context).expand : S.of(context).hide,
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: const Color(0xff1877F2),
                        ),
                        textDirection: Directionality.of(context),
                      ),
                    ),
                  ],
                ),
                // space
                SizedBox(height: 8.sp),

                // centre content
                if (!isHiddenContent)
                  isMobile
                      ? Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 15.sp, right: 15.sp, top: 15.sp),
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
                                              borderRadius:
                                                  BorderRadius.circular(4.r)),
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
                                                      color: lightMode
                                                          ? AppColors
                                                              .blackButton
                                                          : AppColors.white),
                                            ),
                                            Text(
                                              S.of(context).inStock,
                                              style: StyleText
                                                  .fontSize10Weight500
                                                  .copyWith(
                                                      color:
                                                          AppColors.lightGreen),
                                            ),
                                          ],
                                        )
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
                                            label:
                                                "${S.of(context).assetId}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "Electronics Electronics  ",
                                            label:
                                                "${S.of(context).category}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "Computer Computer",
                                            label:
                                                "${S.of(context).subcategory}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "Dell",
                                            label: "${S.of(context).brand}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "GZ 15",
                                            label: "${S.of(context).model}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "3 Years",
                                            label:
                                                "${S.of(context).expectedLifetime}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "New",
                                            label:
                                                "${S.of(context).condition}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "10",
                                            label:
                                                "${S.of(context).quantity}: "),
                                        // Pick Up Date
                                        itemText(
                                            value: "28 Nov 2024",
                                            label:
                                                "${S.of(context).pickUpDate}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Reason Of Return
                                        itemText(
                                            value: "Damaged",
                                            label:
                                                "${S.of(context).reasonOfReturn}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Damage Type
                                        itemText(
                                            value: "Physical Impact",
                                            label:
                                                "${S.of(context).damageType}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Date Requested
                                        itemText(
                                            value: "15 Oct 2024",
                                            label:
                                                "${S.of(context).dateRequested}: "),
                                      ],
                                    ),
                                  ],
                                ),

                                // space
                                SizedBox(height: 15.sp),

                                // Reason of Return

                                SizedBox(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 0
                                            .sp), // or your global page padding
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  "${S.of(context).reasonOfReturn}: ",
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
                                SizedBox(height: 15.sp),

                                // Attachments
                                Row(
                                  children: [
                                    Text(
                                      S.of(context).attachments,
                                      style: StyleText.fontSize12Weight400
                                          .copyWith(
                                              color: AppColors.secondaryText),
                                    ),
                                  ],
                                ),
                                // space
                                SizedBox(height: 15.sp),

                                // Grid view
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: 3,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: CrossAxisCountHelper
                                        .getCrossAxisCountForDefaultTablet2(
                                            context),
                                    mainAxisExtent: 65.sp,
                                    crossAxisSpacing: 15.sp,
                                    mainAxisSpacing: 15.sp,
                                  ),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: AppColors.card,
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          border: Border.all(
                                              color: lightMode
                                                  ? Color(0xffB5B4B4)
                                                  : AppColors.grey)),
                                      child: Padding(
                                        padding: EdgeInsets.all(12.sp),
                                        child: Stack(
                                          alignment: Alignment.bottomLeft,
                                          children: [
                                            // Date title
                                            Positioned(
                                              right: 0,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "${S.of(context).date}: ",
                                                    style: StyleText
                                                        .fontSize10Weight400
                                                        .copyWith(
                                                            color: lightMode
                                                                ? AppColors
                                                                    .secondaryText
                                                                : AppColors
                                                                    .grey),
                                                  ),
                                                  // Date value
                                                  Text(
                                                    "28 Dec 2023",
                                                    style: StyleText
                                                        .fontSize10Weight400
                                                        .copyWith(
                                                            color: lightMode
                                                                ? AppColors
                                                                    .secondaryText
                                                                : AppColors
                                                                    .grey),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // image & details
                                            Row(
                                              children: [
                                                // image
                                                CustomSvgImage(
                                                  assetPath:
                                                      "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
                                                  width: 36.sp,
                                                  height: 36.sp,
                                                  color: AppColors.blackButton,
                                                  fit: BoxFit.scaleDown,
                                                ),

                                                //space
                                                SizedBox(width: 10.sp),

                                                // name image & Size
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Name of Image
                                                    Text(
                                                      "Watermark.png",
                                                      style: StyleText
                                                          .fontSize14Weight500
                                                          .copyWith(
                                                              color: lightMode
                                                                  ? AppColors
                                                                      .blackButton
                                                                  : AppColors
                                                                      .white),
                                                    ),

                                                    Text(
                                                      "62 KB",
                                                      style: StyleText
                                                          .fontSize12Weight500
                                                          .copyWith(
                                                              color: lightMode
                                                                  ? AppColors
                                                                      .secondaryText
                                                                  : AppColors
                                                                      .grey),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
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
                                              color: AppColors.secondaryText),
                                    ),
                                  ],
                                ),

                                _buildApprovalCycle(section),

                                customButton(
                                    radius: 8.r,
                                    borderColor: Color(0xffDF1C1C),
                                    textStyle:
                                        StyleText.fontSize16Weight500.copyWith(
                                      color: Color(0xffDF1C1C),
                                    ),
                                    width: MediaQuery.sizeOf(context).width,
                                    height: 38.sp,
                                    color: Colors.transparent,
                                    title: S.of(context).damaged,
                                    function: () {}),

                                // space
                                SizedBox(height: 15.sp),
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
                                top: 15.sp, right: 15.sp, left: 15.sp),
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
                                              BorderRadius.circular(4.r)),
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
                                    // Asset ID: &  Category & Subcategory  & Brand
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        itemText(
                                            value: "001",
                                            label:
                                                "${S.of(context).assetId}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "Electronics Electronics  ",
                                            label:
                                                "${S.of(context).category}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "Computer Computer",
                                            label:
                                                "${S.of(context).subcategory}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "Dell",
                                            label: "${S.of(context).brand}: "),
                                      ],
                                    ),

                                    SizedBox(
                                        width: isTablet && !isLandscape
                                            ? MediaQuery.sizeOf(context).width *
                                                .05
                                            : MediaQuery.sizeOf(context).width *
                                                .1),

                                    // Model &  Expected Lifetime & Condition  & Quantity
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        itemText(
                                            value: "GZ 15",
                                            label: "${S.of(context).model}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "3 Years",
                                            label:
                                                "${S.of(context).expectedLifetime}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "New",
                                            label:
                                                "${S.of(context).condition}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "10",
                                            label:
                                                "${S.of(context).quantity}: "),
                                      ],
                                    ),
                                    // space
                                    SizedBox(
                                        width: isTablet && !isLandscape
                                            ? MediaQuery.sizeOf(context).width *
                                                .05
                                            : MediaQuery.sizeOf(context).width *
                                                .1),
                                    // Pick Up Date &  Reason Of Return & Damage Type  & Date Requested & Received Date
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Pick Up Date
                                        itemText(
                                            value: "28 Nov 2024",
                                            label:
                                                "${S.of(context).pickUpDate}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Reason Of Return
                                        itemText(
                                            value: "Damaged",
                                            label:
                                                "${S.of(context).reasonOfReturn}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Damage Type
                                        itemText(
                                            value: "Physical Impact",
                                            label:
                                                "${S.of(context).damageType}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Date Requested
                                        itemText(
                                            value: "15 Oct 2024",
                                            label:
                                                "${S.of(context).dateRequested}: "),
                                      ],
                                    ),
                                  ],
                                ),

                                // name of product
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Dell GS 15",
                                      style: StyleText.fontSize14Weight400
                                          .copyWith(
                                              color: AppColors.blackButton),
                                    ),
                                    // space
                                    SizedBox(
                                        width: isTablet && !isLandscape
                                            ? 373.sp
                                            : 498.sp),
                                    // Received Date
                                    itemText(
                                        value: "28 Nov 2024",
                                        label:
                                            "${S.of(context).receivedDate}: "),
                                  ],
                                ),

                                // space
                                SizedBox(height: 15.sp),

                                // Reason of Return
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Additional Note:
                                    Text(
                                      "${S.of(context).reasonOfReturn}: ",
                                      style: StyleText.fontSize12Weight500
                                          .copyWith(
                                              color: AppColors.secondaryText),
                                    ),
                                    // value of Additional Note:

                                    Text(
                                      "Lorem Ipsum Lorem IpsumLorem IpsumLorem",
                                      style: StyleText.fontSize12Weight500
                                          .copyWith(
                                              color: AppColors.blackButton),
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
                                              color: AppColors.secondaryText),
                                    ),
                                  ],
                                ),

                                // space
                                SizedBox(height: 13.sp),

                                // Approval Cycle item
                                buildApprovalCycleRow(section),

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
                                              style: StyleText
                                                  .fontSize12Weight500
                                                  .copyWith(
                                                      color: Color(0xff1877F2)),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    Spacer(),
                                    customButton(
                                        title: S.of(context).damaged,
                                        function: () {},
                                        radius: 8.r,
                                        borderColor: Color(0xffDF1C1C),
                                        textStyle: StyleText.fontSize16Weight500
                                            .copyWith(color: Color(0xffDF1C1C)),
                                        height: 36.sp,
                                        width: 250.sp,
                                        color: Colors.transparent),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                // space
                SizedBox(height: 20.sp),

                // Maintenance Inspector
                Row(
                  children: [
                    Text(
                      S.of(context).maintenanceInspector,
                      style: StyleText.fontSize18Weight500
                          .copyWith(color: AppColors.blackButton),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        HapticController.low(); // list row: on the tap (X-117)
                        setState(() {
                          isHidden = !isHidden;
                        });
                      },
                      child: Text(
                        isHidden ? S.of(context).expand : S.of(context).hide,
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: const Color(0xff1877F2),
                        ),
                        textDirection: Directionality.of(context),
                      ),
                    ),
                  ],
                ),

                // space
                SizedBox(height: 7.sp),

                if (!isHidden)
                  isMobile
                      ? Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(15.sp),
                            child: Column(
                              children: [
                                // First Section
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // image
                                    Column(
                                      children: [
                                        Container(
                                          width: 70.sp,
                                          height: 70.sp,
                                          decoration: BoxDecoration(
                                              color: lightMode
                                                  ? AppColors.grey
                                                  : AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(4.r)),
                                          child: CustomSvgImage(
                                            assetPath:
                                                "assets/icons_assets/main_icons_assets/ic_data_inventory_damaged.svg",
                                            width: 50.sp,
                                            height: 50.sp,
                                            fit: BoxFit.scaleDown,
                                            color: AppColors.blackButton,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // space
                                    SizedBox(width: 5.sp),
                                    // Maintenance ID: &  Recevied By & Asset Conditions  & Accessories Returned
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        itemText(
                                            value: "001",
                                            label:
                                                "${S.of(context).maintenanceId}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "Moataz Handousa",
                                            label:
                                                "${S.of(context).receivedBy}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "Damaged",
                                            label:
                                                "${S.of(context).assetConditions}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "Yes",
                                            label:
                                                "${S.of(context).accessoriesReturned}: "),
                                        SizedBox(height: 7.sp),
                                        // Quantity
                                        itemText(
                                            value: "10",
                                            label:
                                                "${S.of(context).quantity}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // In-Service Date
                                        itemText(
                                            value: "28 Nov 2025",
                                            label:
                                                "${S.of(context).inServiceDate}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Expected Lifetime
                                        itemText(
                                            value: "3 Years",
                                            label:
                                                "${S.of(context).expectedLifetime}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Damage Type
                                        itemText(
                                            value: "Electrical Fault",
                                            label:
                                                "${S.of(context).damageType}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Severity Level
                                        itemText(
                                            value: "Moderate",
                                            label:
                                                "${S.of(context).severityLevel}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Storage Location
                                        itemText(
                                            value: "Floor 13",
                                            label:
                                                "${S.of(context).storageLocation}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Reason Of Return
                                        itemText(
                                            value: "28 Nov 2024",
                                            label:
                                                "${S.of(context).reviewedDate}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Damage Type
                                        itemText(
                                            value: "Damaged",
                                            label:
                                                "${S.of(context).nextDisposition}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Date Requested
                                        itemText(
                                            value: "Decommission",
                                            label:
                                                "${S.of(context).recommendedAction}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "Out",
                                            label:
                                                "${S.of(context).warrantyCoverageStatus}: "),
                                      ],
                                    ),
                                  ],
                                ),

                                // space
                                SizedBox(height: 15.sp),

                                // Reason of Return

                                SizedBox(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 0
                                            .sp), // or your global page padding
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  "${S.of(context).reasonOfReturn}: ",
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
                                SizedBox(height: 15.sp),

                                // Attachments
                                Row(
                                  children: [
                                    Text(
                                      S.of(context).attachments,
                                      style: StyleText.fontSize12Weight400
                                          .copyWith(
                                              color: AppColors.secondaryText),
                                    ),
                                  ],
                                ),
                                // space
                                SizedBox(height: 15.sp),

                                // Grid view
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: 3,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: CrossAxisCountHelper
                                        .getCrossAxisCountForDefaultTablet2(
                                            context),
                                    mainAxisExtent: 65.sp,
                                    crossAxisSpacing: 15.sp,
                                    mainAxisSpacing: 15.sp,
                                  ),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: AppColors.card,
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          border: Border.all(
                                              color: lightMode
                                                  ? Color(0xffB5B4B4)
                                                  : AppColors.grey)),
                                      child: Padding(
                                        padding: EdgeInsets.all(12.sp),
                                        child: Stack(
                                          alignment: Alignment.bottomLeft,
                                          children: [
                                            // Date title
                                            Positioned(
                                              right: 0,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "${S.of(context).date}: ",
                                                    style: StyleText
                                                        .fontSize10Weight400
                                                        .copyWith(
                                                            color: lightMode
                                                                ? AppColors
                                                                    .secondaryText
                                                                : AppColors
                                                                    .grey),
                                                  ),
                                                  // Date value
                                                  Text(
                                                    "28 Dec 2023",
                                                    style: StyleText
                                                        .fontSize10Weight400
                                                        .copyWith(
                                                            color: lightMode
                                                                ? AppColors
                                                                    .secondaryText
                                                                : AppColors
                                                                    .grey),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // image & details
                                            Row(
                                              children: [
                                                // image
                                                CustomSvgImage(
                                                  assetPath:
                                                      "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
                                                  width: 36.sp,
                                                  height: 36.sp,
                                                  color: AppColors.blackButton,
                                                  fit: BoxFit.scaleDown,
                                                ),

                                                //space
                                                SizedBox(width: 10.sp),

                                                // name image & Size
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Name of Image
                                                    Text(
                                                      "Watermark.png",
                                                      style: StyleText
                                                          .fontSize14Weight500
                                                          .copyWith(
                                                              color: lightMode
                                                                  ? AppColors
                                                                      .blackButton
                                                                  : AppColors
                                                                      .white),
                                                    ),

                                                    Text(
                                                      "62 KB",
                                                      style: StyleText
                                                          .fontSize12Weight500
                                                          .copyWith(
                                                              color: lightMode
                                                                  ? AppColors
                                                                      .secondaryText
                                                                  : AppColors
                                                                      .grey),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // space
                                SizedBox(height: 15.sp),

                                customButton(
                                    radius: 8.r,
                                    textStyle: StyleText.fontSize16Weight500
                                        .copyWith(color: AppColors.textButton),
                                    width: MediaQuery.sizeOf(context).width,
                                    height: 38.sp,
                                    color: AppColors.primary,
                                    title: S.of(context).writeOff,
                                    function: () {})
                              ],
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              color: AppColors.card),
                          child: Padding(
                            padding: EdgeInsets.all(15.sp),
                            child: Column(
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
                                              BorderRadius.circular(4.r)),
                                      child: CustomSvgImage(
                                        assetPath:
                                            "assets/icons_assets/main_icons_assets/ic_data_inventory_damaged.svg",
                                        width: 50.sp,
                                        height: 50.sp,
                                        fit: BoxFit.scaleDown,
                                        color: AppColors.blackButton,
                                      ),
                                    ),

                                    // space
                                    SizedBox(width: 10.sp),
                                    // Maintenance ID: &  Recevied By & Asset Conditions  & Accessories Returned
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        itemText(
                                            value: "001",
                                            label:
                                                "${S.of(context).maintenanceId}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "Moataz Handousa",
                                            label:
                                                "${S.of(context).receivedBy}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "Damaged",
                                            label:
                                                "${S.of(context).assetConditions}: "),
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "Yes",
                                            label:
                                                "${S.of(context).accessoriesReturned}: "),
                                      ],
                                    ),
                                    SizedBox(
                                        width: isTablet && !isLandscape
                                            ? MediaQuery.sizeOf(context).width *
                                                .03
                                            : MediaQuery.sizeOf(context).width *
                                                .1),
                                    // Quantity &  In-Service Date & Expected Lifetime  & Damage Type  & Severity Level
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Quantity
                                        itemText(
                                            value: "10",
                                            label:
                                                "${S.of(context).quantity}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // In-Service Date
                                        itemText(
                                            value: "28 Nov 2025",
                                            label:
                                                "${S.of(context).inServiceDate}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Expected Lifetime
                                        itemText(
                                            value: "3 Years",
                                            label:
                                                "${S.of(context).expectedLifetime}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Damage Type
                                        itemText(
                                            value: "Electrical Fault",
                                            label:
                                                "${S.of(context).damageType}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Severity Level
                                        itemText(
                                            value: "Moderate",
                                            label:
                                                "${S.of(context).severityLevel}: "),
                                      ],
                                    ),
                                    // space
                                    SizedBox(
                                        width: isTablet && !isLandscape
                                            ? MediaQuery.sizeOf(context).width *
                                                .03
                                            : MediaQuery.sizeOf(context).width *
                                                .1),
                                    // Storage Location &  Reviewed Date & Next Disposition  & Recommended Action & Warranty & Coverage Status
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Storage Location
                                        itemText(
                                            value: "Floor 13",
                                            label:
                                                "${S.of(context).storageLocation}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Reason Of Return
                                        itemText(
                                            value: "28 Nov 2024",
                                            label:
                                                "${S.of(context).reviewedDate}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Damage Type
                                        itemText(
                                            value: "Damaged",
                                            label:
                                                "${S.of(context).nextDisposition}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        // Date Requested
                                        itemText(
                                            value: "Decommission",
                                            label:
                                                "${S.of(context).recommendedAction}: "),
                                        // space
                                        SizedBox(height: 7.sp),
                                        itemText(
                                            value: "Out",
                                            label:
                                                "${S.of(context).warrantyCoverageStatus}: "),
                                      ],
                                    ),
                                  ],
                                ),

                                // space
                                SizedBox(height: 15.sp),
                                // Notes & Observations
                                itemText(
                                  value:
                                      "Lorem Ipsum Lorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem IpsumLorem",
                                  label: "${S.of(context).notesObservations}: ",
                                  valueStyle: StyleText.fontSize12Weight500
                                      .copyWith(color: AppColors.blackButton),
                                  labelStyle: StyleText.fontSize12Weight500
                                      .copyWith(color: AppColors.secondaryText),
                                ),
                                // space
                                SizedBox(height: 15.sp),
                                // Attachments
                                Row(
                                  children: [
                                    Text(
                                      S.of(context).attachments,
                                      style: StyleText.fontSize12Weight400
                                          .copyWith(
                                              color: AppColors.secondaryText),
                                    ),
                                  ],
                                ),
                                // space
                                SizedBox(height: 15.sp),

                                // Grid view
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: 3,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: CrossAxisCountHelper
                                        .getCrossAxisCountForDefaultTablet2(
                                            context),
                                    mainAxisExtent: 65.sp,
                                    crossAxisSpacing: 15.sp,
                                    mainAxisSpacing: 15.sp,
                                  ),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: AppColors.card,
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          border: Border.all(
                                              color: lightMode
                                                  ? Color(0xffB5B4B4)
                                                  : AppColors.grey)),
                                      child: Padding(
                                        padding: EdgeInsets.all(12.sp),
                                        child: Stack(
                                          alignment: Alignment.bottomLeft,
                                          children: [
                                            // Date title
                                            Positioned(
                                              right: 0,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "${S.of(context).date}: ",
                                                    style: StyleText
                                                        .fontSize10Weight400
                                                        .copyWith(
                                                            color: lightMode
                                                                ? AppColors
                                                                    .secondaryText
                                                                : AppColors
                                                                    .grey),
                                                  ),
                                                  // Date value
                                                  Text(
                                                    "28 Dec 2023",
                                                    style: StyleText
                                                        .fontSize10Weight400
                                                        .copyWith(
                                                            color: lightMode
                                                                ? AppColors
                                                                    .secondaryText
                                                                : AppColors
                                                                    .grey),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // image & details
                                            Row(
                                              children: [
                                                // image
                                                CustomSvgImage(
                                                  assetPath:
                                                      "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
                                                  width: 36.sp,
                                                  height: 36.sp,
                                                  color: AppColors.blackButton,
                                                  fit: BoxFit.scaleDown,
                                                ),

                                                //space
                                                SizedBox(width: 10.sp),

                                                // name image & Size
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Name of Image
                                                    Text(
                                                      "Watermark.png",
                                                      style: StyleText
                                                          .fontSize14Weight500
                                                          .copyWith(
                                                              color: lightMode
                                                                  ? AppColors
                                                                      .blackButton
                                                                  : AppColors
                                                                      .white),
                                                    ),

                                                    Text(
                                                      "62 KB",
                                                      style: StyleText
                                                          .fontSize12Weight500
                                                          .copyWith(
                                                              color: lightMode
                                                                  ? AppColors
                                                                      .secondaryText
                                                                  : AppColors
                                                                      .grey),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // space
                                SizedBox(height: 15.sp),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    customButton(
                                        radius: 8.r,
                                        textStyle: StyleText.fontSize16Weight500
                                            .copyWith(
                                                color: AppColors.textButton),
                                        width: 200.sp,
                                        height: 38.sp,
                                        color: AppColors.primary,
                                        title: S.of(context).writeOff,
                                        function: () {}),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),

                // space
                SizedBox(height: 20.sp),

                // Inquiries And Comments and expand section
                // 22/10/2026 (Moataz): the Settings comments box.
                InventoryCommentsSection(screen: 'allocated_details_employee'),
                // space
                SizedBox(height: 20.sp),
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
        children: List.generate(
          section.selectedApprovers.length * 2 - 1,
          (i) {
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
                          color:
                              theme ? AppColors.blackButton : AppColors.white,
                        ),
                      ),
                      Text(
                        FormatHelper.capitalize(
                          isEnglish
                              ? employee.title ?? ''
                              : employee.titleInArabic ?? '',
                        ),
                        style: StyleText.fontSize10Weight500.copyWith(
                          color:
                              theme ? AppColors.secondaryText : AppColors.grey,
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
          },
        ),
      ),
    );
  }

  //////////////////////////////// Approval Cycle //////////////////////////////
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
        Text(
          FormatHelper.capitalize(label),
          style: isMobile
              ? StyleText.fontSize12Weight500.copyWith(
                  color: valueColor ?? AppColors.blackButton,
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
                        left: 20.sp, right: 15.sp, bottom: 0.sp),
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
                      width:
                          2.sp), // Reserve equal width to align with arrow size
                Padding(
                  padding: EdgeInsets.only(top: 14.sp),
                  child: Container(
                    width: 32.sp,
                    height: 32.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.transparent,
                        width: 2.w,
                      ),
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
                                            color:
                                                Theme.of(context).brightness ==
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

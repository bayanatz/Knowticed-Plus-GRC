import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class AssetsDetailsDesktopScreen extends StatefulWidget {
  final ProductModel? productModel;
  const AssetsDetailsDesktopScreen({super.key, this.productModel});

  @override
  State<AssetsDetailsDesktopScreen> createState() =>
      _AssetsDetailsDesktopScreenState();
}

class _AssetsDetailsDesktopScreenState
    extends State<AssetsDetailsDesktopScreen> {
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

  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }

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
            {
              navigateTo(context, InventoryManagement());
            }
          },
          secondTitle: S.of(context).assetsNameDetails,
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
                Container(
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
                              style: StyleText.fontSize16Weight500.copyWith(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Department
                                    itemTextProduct(
                                      value: "IT",
                                      label: "${S.of(context).department}: ",
                                      image:
                                          "assets/icons_assets/main_icons_assets/ic_building_office.svg",
                                    ),

                                    // Phone Number
                                    itemTextProduct(
                                      value: "+2010258963",
                                      label: "${S.of(context).phoneNumber}: ",
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

                        // MSG button
                        customButtonWithSvg(
                          title: S.of(context).msg,
                          function: () {},
                          textStyle: StyleText.fontSize16Weight500.copyWith(
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
                        onTapDown:
                            hapticDown(_showConfirmDialog, HapticLevel.medium),
                        onTap: _showConfirmDialog,
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
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                itemText(
                                  value: "100000000",
                                  label: "${S.of(context).productID}: ",
                                ),
                                SizedBox(height: 7.sp),
                                itemText(
                                  value: "Asset",
                                  label: "${S.of(context).productType}: ",
                                ),
                                SizedBox(height: 7.sp),
                                itemText(
                                  value: "TechSource Solutions",
                                  label: "${S.of(context).supplierName}: ",
                                ),
                                SizedBox(height: 7.sp),
                                itemText(
                                  value: "Electronics Electronics  ",
                                  label: "${S.of(context).category}: ",
                                ),
                              ],
                            ),

                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * .1,
                            ),

                            // subcategory &  brand & model  & expectedLifetime
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                  value: "5 Years",
                                  label: "${S.of(context).expectedLifetime}: ",
                                ),
                              ],
                            ),
                            // space
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * .1,
                            ),
                            // subcategory &  brand & model  & expectedLifetime
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${S.of(context).status}: ",
                                  style: StyleText.fontSize10Weight500.copyWith(
                                    color: AppColors.blackButton,
                                  ),
                                ),
                                Text(
                                  S.of(context).inStock,
                                  style: StyleText.fontSize10Weight500.copyWith(
                                    color: AppColors.lightGreen,
                                  ),
                                ),
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

                // space
                SizedBox(height: 8.sp),

                if (!isHidden)
                  GridView.builder(
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
                            // Top Row: Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    '${S.of(context).status}: ',
                                    style:
                                        StyleText.fontSize10Weight500.copyWith(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${item["status"]}",
                                  style: StyleText.fontSize10Weight500.copyWith(
                                    color: item[
                                        "statusColor"], // dynamic status color
                                  ),
                                ),
                              ],
                            ),
                            // Calendar icon and two labels
                            Row(
                              children: [
                                Image(
                                  image: AssetImage(
                                    "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
                                  ),
                                  width: 50.sp,
                                  height: 50.sp,
                                  fit: BoxFit.scaleDown,
                                ),
                                SizedBox(width: 5.sp),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      itemText(
                                        label:
                                            "${S.of(context).maintenanceSchedule}: ",
                                        value: item["scheduleDate"],
                                      ),
                                      itemText(
                                        label:
                                            "${S.of(context).requestedMaintenance}: ",
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

                SizedBox(height: 15.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ////////////////////////////// Dialog Verify  //////////////////////////////

  void _showConfirmDialog() {
    showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Container(
          width: 411.sp,
          padding: EdgeInsets.all(20.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie_assets/main_lottie_assets/lot_action_restore.json',
                width: 70.sp,
                height: 70.sp,
                fit: BoxFit.scaleDown,
                repeat: true, // Set to false if you don't want it to loop
                animate: true, // Set to false to pause the animation
              ),
              SizedBox(height: 20.sp),
              Text(
                S.of(context).retrieveProduct,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                S.of(context).confirmRetrieveProduct,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 15.sp),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 38.sp),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTapDown: (_) => HapticController.low(),
                        onTap: () => Navigator.pop(context),
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
                        onTap: () {
                          Navigator.pop(context);
                          _showSuccessDialog(context);
                        },
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
              ),
            ],
          ),
        ),
      ),
    );
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
                  S.of(context).retrieveProduct,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  S.of(context).successRetrieveProduct,
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
}

class EmployeeEntity {
  final String id; // ✅ Required for selection logic
  final String? firstName;
  final String? lastName;
  final String? firstNameInArabic;
  final String? lastNameInArabic;
  final String? title;
  final String? titleInArabic;
  final String? departmentId;
  final String gender;

  EmployeeEntity({
    required this.id, // ✅ Make sure it's passed
    this.firstName,
    this.lastName,
    this.firstNameInArabic,
    this.lastNameInArabic,
    this.title,
    this.titleInArabic,
    this.departmentId,
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

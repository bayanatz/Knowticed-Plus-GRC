import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_approve_reject_buttons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/select_approval.dart';
import 'package:knowticed_plus/features/inventory/inv6_approval/presentation/ui/pages/p26_approvals_toogel.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/cards/custom_approval_shape.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

class ApprovalDetailsDesktopScreen extends StatefulWidget {
  const ApprovalDetailsDesktopScreen({super.key});

  @override
  State<ApprovalDetailsDesktopScreen> createState() =>
      _ApprovalDetailsDesktopScreenState();
}

class _ApprovalDetailsDesktopScreenState
    extends State<ApprovalDetailsDesktopScreen> {
  TextEditingController approveController = TextEditingController();
  TextEditingController rejectController = TextEditingController();
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

    approveController.addListener(() => setState(() {}));
    rejectController.addListener(() => setState(() {}));
  }
  /////////////////////////////// Approval Cycle //////////////////////////////////////////

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
            {
              navigateTo(context, InventoryManagement());
            }
          },
          secondTitle: S.of(context).approvals,
          onSecondTap: () {
            navigateTo(context, ApprovalsSection());
          },
          thirdTitle: S.of(context).requestName,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                // Request title
                Row(
                  children: [
                    Text(
                      "${S.of(context).request}:001",
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              child: Center(
                                child: CustomSvgImage(
                                  assetPath:
                                      "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
                                  width: 60.sp,
                                  height: 60.sp,
                                  fit: BoxFit.scaleDown,
                                  color: AppColors.blackButton,
                                ),
                              ),
                            ),

                            // space
                            SizedBox(width: 10.sp),
                            // Request Type &  Category: & Subcategory:  & Brand
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

                            // Model &  Maintenance Frequency & Type of Asset Request  & Priority
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
                            //Receiving Method  & Location Delivery &  Expected Return & Received Date:  & Date Requested:
                            sectionThreeInfo(),
                          ],
                        ),

                        SizedBox(height: 5.sp),

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
                              "${S.of(context).descriptionOfIssue}: ",
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
                              context,
                            ),
                            mainAxisExtent: 65.sp,
                            crossAxisSpacing: 15.sp,
                            mainAxisSpacing: 15.sp,
                          ),
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: lightMode
                                      ? Color(0xffB5B4B4)
                                      : AppColors.grey,
                                ),
                              ),
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
                                            style: StyleText.fontSize10Weight400
                                                .copyWith(
                                              color: AppColors.secondaryText,
                                            ),
                                          ),
                                          // Date value
                                          Text(
                                            "28 Dec 2023",
                                            style: StyleText.fontSize10Weight400
                                                .copyWith(
                                              color: AppColors.secondaryText,
                                            ),
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
                                                color: AppColors.blackButton,
                                              ),
                                            ),

                                            Text(
                                              "62 KB",
                                              style: StyleText
                                                  .fontSize12Weight500
                                                  .copyWith(
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
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

                        // Approval Cycle title
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

                        // height
                        SizedBox(height: 20.sp),

                        // Approve & Reject
                        CustomApproveRejectButtons(
                          myState: "pending",
                          onApprove: () {
                            showConfirmationDialog(
                              lottiePath:
                                  "assets/lottie_assets/main_lottie_assets/lot_status_approved.json",
                              title: S.of(context).approveRequest,
                              message: S
                                  .of(context)
                                  .areYouSureYouWantToApproveThisRequest,
                              onConfirm: () => commentApproveDialogAction(),
                            );
                          },
                          onReject: () {
                            showConfirmationDialog(
                              lottiePath:
                                  "assets/lottie_assets/main_lottie_assets/lot_status_rejected.json",
                              title: S.of(context).rejectRequest,
                              message: S
                                  .of(context)
                                  .areYouSureYouWantToRejectThisRequest,
                              onConfirm: () => commentRejectDialogAction(),
                            );
                          },
                        ),
                        // space
                        SizedBox(height: 15.sp),
                      ],
                    ),
                  ),
                ),
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
          value: "Weekly",
          label: "${S.of(context).maintenanceFrequency}: ",
        ),
        SizedBox(height: 4.sp),
        itemText(
          value: "New Asset",
          label: "${S.of(context).typeOfAssetRequest}: ",
        ),
        SizedBox(height: 4.sp),
        itemText(value: "High", label: "${S.of(context).priority}: "),
      ],
    );
  }

  Widget sectionThreeInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemText(value: "High", label: "${S.of(context).receivingMethod}: "),
        SizedBox(height: 4.sp),
        itemText(value: "Office", label: "${S.of(context).locationDelivery}: "),
        SizedBox(height: 4.sp),
        itemText(
          value: "28 Nov 2025",
          label: "${S.of(context).expectedReturn}: ",
        ),
        SizedBox(height: 4.sp),
        itemText(
          value: "28 Nov 2025",
          label: "${S.of(context).receivedDate}: ",
        ),
        SizedBox(height: 4.sp),
        itemText(
          value: "28 Nov 2025",
          label: "${S.of(context).dateRequested}: ",
        ),
      ],
    );
  }
  ///////////////////////////////// section info ////////////////////////////////

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

  Future<void> showConfirmationDialog({
    required String lottiePath,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    return showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.white
            : AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: SizedBox(
            width: 405.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  lottiePath, // Replace with your Lottie URL
                  width: 70.sp,
                  height: 70.sp,
                  fit: BoxFit.scaleDown,
                  repeat: true, // Set to false if you don't want it to loop
                  animate: true, // Set to false to pause the animation
                ),
                SizedBox(height: 20.sp),
                Text(
                  title,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 15.sp),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 56.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      customButton(
                        title: S.of(context).no,
                        function: () => Navigator.pop(context),
                        textStyle: StyleText.fontSize15Weight500.copyWith(
                          color: AppColors.blackButton,
                        ),
                        width: 135.sp,
                        height: 38.sp,
                        radius: 4.r,
                        color: AppColors.secondaryButton,
                      ),
                      SizedBox(width: 20.sp),
                      customButton(
                        title: S.of(context).yes,
                        function: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        textStyle: StyleText.fontSize18Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                        width: 135.sp,
                        height: 38.sp,
                        radius: 4.r,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> commentApproveDialogAction() async {
    return showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: 20.sp,
              right: 20.sp,
              left: 20.sp,
              bottom: 20.sp,
            ),
            child: SizedBox(
              width: 405.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 30.sp,
                        height: 30.sp,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: Icon(
                          Icons.check,
                          color: AppColors.textButton,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 5.sp),
                      Text(
                        S.of(context).approvalJustification,
                        style: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.sp),

                  // Justifications Row
                  Row(
                    children: [
                      Text(
                        '${S.of(context).justifications} ',
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                      Text(
                        '(${S.of(context).optional})',
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.sp),

                  CustomTextField(
                    width: 499.sp,
                    controller: approveController,
                    maxLines: 3,
                    maxLength: 500,
                    hint: S.of(context).textHere,
                    fillColor: AppColors.background,
                    onChanged: (_) => setState(() {}),
                  ),

                  SizedBox(height: 15.sp),

                  // Submit button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      customButton(
                        title: S.of(context).submit,
                        function: () async {
                          Navigator.pop(context);
                          await showSuccessDialog(
                            lottiePath:
                                "assets/lottie_assets/main_lottie_assets/lot_status_approved.json",
                            title: S.of(context).serviceRequested,
                            subtitle: S
                                .of(context)
                                .youSuccessfullyApprovedThisRequest,
                          );
                        },
                        textStyle: StyleText.fontSize16Weight500.copyWith(
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
          ),
        ),
      ),
    );
  }

  Future<void> commentRejectDialogAction() async {
    return showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 20.sp,
            right: 20.sp,
            left: 20.sp,
            bottom: 20.sp,
          ),
          child: SizedBox(
            width: 405.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //Reason Of Rejection
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 30.sp,
                      height: 30.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: Icon(
                        Icons.block_flipped,
                        color: AppColors.textButton,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 5.sp),
                    Text(
                      S.of(context).reasonOfRejection,
                      style: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),

                //space
                SizedBox(height: 20.sp),

                //Justifications
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).justifications,
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.sp),

                CustomTextField(
                  width: 499.sp,
                  controller: rejectController,
                  maxLines: 3,
                  maxLength: 500,
                  hint: S.of(context).textHere,
                  fillColor: AppColors.background,
                  onChanged: (_) => setState(() {}),
                ),

                SizedBox(height: 15.sp),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    customButton(
                      title: S.of(context).submit,
                      function: () async {
                        Navigator.pop(context);
                        await showSuccessDialog(
                          lottiePath:
                              "assets/lottie_assets/main_lottie_assets/lot_status_approved.json",
                          title: S.of(context).serviceRequested,
                          subtitle:
                              S.of(context).youSuccessfullyRejectedThisRequest,
                        );
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
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
        ),
      ),
    );
  }

  Future<void> showSuccessDialog({
    required String lottiePath,
    required String title,
    required String subtitle,
  }) async {
    return showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.white
            : AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: SizedBox(
            width: 405.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  lottiePath,
                  width: 70.sp,
                  height: 70.sp,
                  fit: BoxFit.scaleDown,
                ),
                SizedBox(height: 20.sp),
                Text(
                  title,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  subtitle,
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

  ////////////////////////// item in any Container /////////////////////////////
  Widget itemText({
    required String label,
    required String value,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    final isTablet = context.isTablet;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          FormatHelper.capitalize(label),
          style: labelStyle ??
              (isTablet
                  ? StyleText.fontSize10Weight400.copyWith(
                      color: AppColors.secondaryText,
                    )
                  : StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.secondaryText,
                    )),
        ),
        Text(
          FormatHelper.capitalize(value),
          style: valueStyle ??
              (isTablet
                  ? StyleText.fontSize10Weight400.copyWith(
                      color: AppColors.blackButton,
                    )
                  : StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.blackButton,
                    )),
        ),
      ],
    );
  }

  ////////////////////////// item in any Container /////////////////////////////
}

class ApprovalSection {
  String? selectedRequestType;
  List<EmployeeEntity> selectedApprovers;

  ApprovalSection({
    this.selectedRequestType,
    this.selectedApprovers = const [],
  });
}

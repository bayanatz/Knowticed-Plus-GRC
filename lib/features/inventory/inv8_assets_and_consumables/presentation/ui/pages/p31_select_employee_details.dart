import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/select_approval.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_validated_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class SelectEmployeeDetailsDesktopScreen extends StatefulWidget {
  const SelectEmployeeDetailsDesktopScreen({super.key});

  @override
  State<SelectEmployeeDetailsDesktopScreen> createState() =>
      _SelectEmployeeDetailsDesktopScreenState();
}

class _SelectEmployeeDetailsDesktopScreenState
    extends State<SelectEmployeeDetailsDesktopScreen> {
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
          secondTitle: S.of(context).assetsNameDetails,
          onSecondTap: () {
            Navigator.pop(context);
          },
          thirdTitle: S.of(context).assigningAssets,
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

                        // Message button
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    value: "TechSource Solutions",
                                    label: "${S.of(context).productType}: ",
                                  ),
                                  SizedBox(height: 7.sp),
                                  itemText(
                                    value: "Electronics Electronics  ",
                                    label: "${S.of(context).category}: ",
                                  ),
                                ],
                              ),

                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * .15,
                              ),

                              // subcategory &  brand & model  & expectedLifetime
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                                    label:
                                        "${S.of(context).expectedLifetime}: ",
                                  ),
                                ],
                              ),
                              // space
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * .15,
                              ),
                              // subcategory &  brand & model  & expectedLifetime
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  itemText(
                                    value: "New",
                                    label: "${S.of(context).condition}: ",
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

                            // Create Barcode & Create Automatic IDs
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Create Barcode
                                Text(
                                  S.of(context).createBarcode,
                                  style: StyleText.fontSize14Weight500.copyWith(
                                    color: AppColors.blackButton,
                                  ),
                                ),

                                // space
                                SizedBox(height: 28.sp),

                                // Create Automatic IDs
                                Text(
                                  S.of(context).createAutomaticIDs,
                                  style: StyleText.fontSize14Weight500.copyWith(
                                    color: AppColors.blackButton,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(width: 9.sp),

                            // Switch
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                        SizedBox(height: 16.sp),
                        // Request ID & Delivery Method
                        Row(
                          children: [
                            // Request ID
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
                                height: 36.sp,
                              ),
                            ),
                            // space
                            SizedBox(width: 15.sp),
                            // Delivery Method
                            Expanded(
                              child: CustomDropdown<String>(
                                items: (durationUnits)
                                    .map((e) => DropdownItem<String>(
                                        value: e['key'] ?? '',
                                        label: e['value'] ?? ''))
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
                              ),
                            ),
                          ],
                        ),

                        // Space
                        SizedBox(height: 15.sp),

                        // Expected Delivery Date & Expected Return Date
                        Row(
                          children: [
                            // Expected Delivery Date
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
                                label: S.of(context).expectedDeliveryDate,
                                hint: "24 Nov 2018",
                                height: 36.sp,
                              ),
                            ),
                            // space
                            SizedBox(width: 15.sp),
                            // Expected Return Date
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
                                label: S.of(context).expectedReturnDate,
                                hint: "24 Nov 2018",
                                height: 36.sp,
                              ),
                            ),
                          ],
                        ),

                        // Space
                        SizedBox(height: 15.sp),

                        // Purpose Of Use
                        Row(
                          children: [
                            // Purpose Of Use
                            Expanded(
                              child: CustomValidatedTextFieldMaster(
                                label: S.of(context).purposeOfUse,
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
                      function: _showConfirmDialog,
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

  ////////////////////////////// Dialog Verify  //////////////////////////////

  void _showConfirmDialog() {
    showAppDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
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
                'assets/lottie_assets/main_lottie_assets/lot_action_edit_document.json',
                width: 70.w,
                height: 70.h,
                fit: BoxFit.scaleDown,
                repeat: true, // Set to false if you don't want it to loop
                animate: true, // Set to false to pause the animation
              ),
              SizedBox(height: 20.sp),
              Text(
                S.of(context).assigningAsset,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                S.of(context).confirmAssignAsset,
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
                  S.of(context).assigningAsset,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  S.of(context).successAssignAsset,
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

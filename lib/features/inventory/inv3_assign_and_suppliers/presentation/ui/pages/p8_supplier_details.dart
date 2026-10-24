import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/pages/edit_supplier_details_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv3_assign_and_suppliers/presentation/ui/pages/p9_history_order_details_toggel.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_validated_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/inventory/helpers/constants/constant_data.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_toolbar_action_button.dart';

class SupplierDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? supplierData;

  const SupplierDetailsScreen({super.key, this.supplierData});

  @override
  State<SupplierDetailsScreen> createState() => _SupplierDetailsScreenState();
}

class _SupplierDetailsScreenState extends State<SupplierDetailsScreen> {
  ////////////////////////////// Calender ///////////////////////////////////

  String? selectStartDate;
  String? selectEndDate;
  List<Map<String, String>> selectStartDateList = [
    {"key": "Preferred", "value": "Preferred"},
    {"key": "Approved", "value": "Approved"},
    {"key": "Approved", "value": "Approved"},
  ];
  List<Map<String, String>> selectEndDateList = [
    {"key": "Preferred", "value": "Preferred"},
    {"key": "Approved", "value": "Approved"},
    {"key": "Approved", "value": "Approved"},
  ];

  ////////////////////////////// Calender ///////////////////////////////////

  ///////////////////////////// Controller //////////////////////////////////

  TextEditingController supplierIdController = TextEditingController();
  TextEditingController supplierNameController = TextEditingController();
  TextEditingController businessTypeController = TextEditingController();
  TextEditingController taxNumberController = TextEditingController();
  TextEditingController businessRegistrationController =
      TextEditingController();
  TextEditingController supplierRankController = TextEditingController();
  TextEditingController createdByController = TextEditingController();
  TextEditingController dateAddedController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController faxNumberController = TextEditingController();
  TextEditingController preferredLanguageController = TextEditingController();
  TextEditingController iBANController = TextEditingController();
  TextEditingController bankAddressController = TextEditingController();
  TextEditingController beneficiaryBankNameController = TextEditingController();
  TextEditingController beneficiaryNameController = TextEditingController();
  TextEditingController bankSWIFTController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController streetNameController = TextEditingController();
  TextEditingController stateOrProvinceController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final TextEditingController wareHouseNameController = TextEditingController();
  final TextEditingController countryWareHouseController =
      TextEditingController();
  final TextEditingController stateOrProvinceWareHouseController =
      TextEditingController();
  final TextEditingController cityWareHouseController = TextEditingController();
  final TextEditingController postalCodeWareHouseController =
      TextEditingController();
  final TextEditingController streetNameWareHouseController =
      TextEditingController();

  ///////////////////////////// Controller //////////////////////////////////

  ///////////////////////////// DropDown //////////////////////////////////

  String? selectedSupplierRank;

  List<Map<String, String>> supplierRankList = [
    {
      "key": "Strategic/Performance-based",
      "value": "Strategic/Performance-based",
    },
    {"key": "Preferred", "value": "Preferred"},
    {"key": "Approved", "value": "Approved"},
    {"key": "Qualified", "value": "Qualified"},
    {"key": "Monitored", "value": "Monitored"},
    {"key": "Occasional", "value": "Occasional"},
    {"key": "Inactive", "value": "Inactive"},
    {"key": "Suspended", "value": "Suspended"},
    {"key": "Blacklisted", "value": "Blacklisted"},
  ];

  String? selectedProductType;

  List<Map<String, String>> productTypeList = [
    {"key": "Open", "value": "Open"},
    {"key": "Partially Received", "value": "Partially Received"},
    {"key": "Received", "value": "Received"},
    {"key": "Cancelled", "value": "Cancelled"},
  ];

  ///////////////////////////// DropDown //////////////////////////////////

  //////////////////////////////////// Fill Data //////////////////////////
  void fillForm(Map<String, dynamic> data) {
    supplierIdController.text = data["supplierId"] ?? "";
    supplierNameController.text = data["supplierName"] ?? "";
    businessTypeController.text = data["businessType"] ?? "";
    taxNumberController.text = data["taxNumber"] ?? "";
    businessRegistrationController.text =
        data["businessRegistrationNumber"] ?? "";
    createdByController.text = data["createdBy"] ?? "";
    dateAddedController.text = data["dateAdded"] ?? "";

    firstNameController.text = data['contact']["firstName"] ?? "";
    middleNameController.text = data['contact']["middleName"] ?? "";
    lastNameController.text = data['contact']["lastName"] ?? "";
    titleController.text = data['contact']["title"] ?? "";
    phoneNumberController.text = data['contact']["phoneNumber"] ?? "";
    faxNumberController.text = data['contact']["fax"] ?? "";
    emailController.text = data['contact']["email"] ?? "";
    preferredLanguageController.text =
        data['contact']["preferredLanguage"] ?? "";

    iBANController.text = data['bankTransferDetails']["iban"] ?? "";
    bankAddressController.text =
        data['bankTransferDetails']["bankAddress"] ?? "";
    beneficiaryBankNameController.text =
        data['bankTransferDetails']["beneficiaryBankName"] ?? "";
    beneficiaryNameController.text =
        data['bankTransferDetails']["beneficiaryName"] ?? "";
    bankSWIFTController.text = data['bankTransferDetails']["bankSWIFT"] ?? "";

    countryController.text = data['addressDetails']["country"] ?? "";
    cityController.text = data['addressDetails']["city"] ?? "";
    streetNameController.text = data['addressDetails']["streetName"] ?? "";
    stateOrProvinceController.text = data['addressDetails']["state"] ?? "";
    postalCodeController.text = data['addressDetails']["postalCode"] ?? "";

    selectedSupplierRank = data["supplierRank"];
    setState(() {});
  }
  //////////////////////////////////// Fill Data //////////////////////////

  //////////////////////////// hide And Expand ////////////////////////////

  bool showSupplierDetails = true;
  bool showContactDetails = true;
  bool showBankDetails = true;
  bool showAddressDetails = true;
  bool showContractDetails = true;
  bool createBarCode = false;

  //////////////////////////// hide And Expand ////////////////////////////

  int selectedSection = 0; // 0 = Supplier Details, 1 = Orders History

  @override
  void initState() {
    super.initState();
    if (widget.supplierData != null) {
      fillForm(widget.supplierData!);
    }
  }

  /////////////////////////////// Color Status ///////////////////////////////////////////////////////////////

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'received':
        return const Color(0xFF4BB609);
      case 'open':
        return const Color(0xFF797979);
      case 'partially received':
        return const Color(0xFFFF814A);
      case 'cancelled':
        return const Color(0xFFDF1C1C);
      default:
        return Colors.black; // fallback/default color
    }
  }

  /////////////////////////////// Color Status ///////////////////////////////////////////////////////////////

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

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isMobile = context.isPhone;

    Localizations.localeOf(context).languageCode == 'en';
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).productName,
          onFirstTap: () {
            Navigator.pop(context);
          },
          secondTitle: S.of(context).supplierDetails,
          onSecondTap: () {
            Navigator.pop(context);
          },
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                // supplierDetails Tab and ordersHistory
                Row(
                  children: [
                    buildTab(S.of(context).supplierDetails, 0),
                    SizedBox(width: 24.sp),
                    buildTab(S.of(context).ordersHistory, 1),
                    Spacer(),
                    selectedSection == 1
                        ? SizedBox()
                        : customButtonWithSvg(
                            title: isMobile ? "" : S.of(context).edit,
                            function: () {
                              navigateTo(context, EditSupplierDetailsToggle());
                            },
                            width: isMobile ? 38.sp : 135.sp,
                            height: 38.sp,
                            color: AppColors.primary,
                            textStyle: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.textButton,
                            ),
                            radius: 8.r,
                            heightImage: 16.sp,
                            widthImage: 16.sp,
                            svgColor: AppColors.textButton,
                            image:
                                "assets/icons_assets/main_icons_assets/ic_action_edit.svg",
                            space: 8.sp,
                            colorBorder: Colors.transparent,
                          ),
                  ],
                ),

                // space
                SizedBox(height: 30.sp),

                if (selectedSection == 0) ...[
                  // Supplier Details
                  Row(
                    children: [
                      Text(
                        S.of(context).supplierDetails,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          HapticController
                              .low(); // list row: on the tap (X-117)
                          setState(() {
                            showSupplierDetails = !showSupplierDetails;
                          });
                        },
                        child: Text(
                          showSupplierDetails
                              ? S.of(context).hide
                              : S.of(context).expand,
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: Color(0xff1877F2),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // space
                  SizedBox(height: 8.sp),

                  // Supplier Details
                  if (showSupplierDetails)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15.sp),
                        child: Column(
                          children: [
                            // image
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60.sp,
                                  height: 60.sp,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.r),
                                    color: lightMode
                                        ? AppColors.grey
                                        : AppColors.background,
                                  ),
                                  child: CustomSvgImage(
                                    assetPath:
                                        "assets/icons_assets/main_icons_assets/ic_user_profile.svg",
                                    width: 35.sp,
                                    height: 35.sp,
                                    color: AppColors.blackButton,
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.sp),
                            // Supplier ID & Supplier Name
                            buildResponsiveFields(
                              left: supplierIdField(),
                              right: supplierNameField(),
                              context: context,
                            ),
                            // space
                            SizedBox(height: 15.sp),
                            // Business Type & Tax Number
                            buildResponsiveFields(
                              left: businessTypeField(),
                              right: faxNumberField(),
                              context: context,
                            ),
                            // space
                            SizedBox(height: 15.sp),
                            // Business Registration Number & Supplier Rank
                            buildResponsiveFields(
                              left: businessRegistrationField(),
                              right: supplierBankFiled(),
                              context: context,
                            ),
                            // space
                            SizedBox(height: 15.sp),
                            // Created By & Date Added
                            buildResponsiveFields(
                              left: createdByField(),
                              right: dateAddedField(),
                              context: context,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // space
                  SizedBox(height: 20.sp),

                  // Point Of Contact Details & Hide
                  Row(
                    children: [
                      Text(
                        S.of(context).pointOfContactDetails,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          HapticController
                              .low(); // list row: on the tap (X-117)
                          setState(() {
                            showContactDetails = !showContactDetails;
                          });
                        },
                        child: Text(
                          showContactDetails
                              ? S.of(context).hide
                              : S.of(context).expand,
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: Color(0xff1877F2),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // space
                  SizedBox(height: 8.sp),

                  // Point Of Contact Details
                  if (showContactDetails)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15.sp),
                        child: Column(
                          children: [
                            // First Name // Middle Name
                            buildResponsiveFields(
                              left: firstNameField(),
                              right: middleNameField(),
                              context: context,
                            ),
                            // space
                            SizedBox(height: 15.sp),
                            // Last Name & Title
                            buildResponsiveFields(
                              left: lastNameField(),
                              right: titleField(),
                              context: context,
                            ),
                            // space
                            SizedBox(height: 15.sp),
                            // Phone Number & Fax Number
                            buildResponsiveFields(
                              left: phoneNumberField(),
                              right: faxNumberField(),
                              context: context,
                            ),
                            // space
                            SizedBox(height: 15.sp),
                            // Email & Preferred Language
                            buildResponsiveFields(
                              left: emailField(),
                              right: preferredLanguageField(),
                              context: context,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // space
                  SizedBox(height: 20.sp),

                  // Bank Transfer Details & Hide
                  Row(
                    children: [
                      Text(
                        S.of(context).bankTransferDetails,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          HapticController
                              .low(); // list row: on the tap (X-117)
                          setState(() {
                            showBankDetails = !showBankDetails;
                          });
                        },
                        child: Text(
                          showBankDetails
                              ? S.of(context).hide
                              : S.of(context).expand,
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: Color(0xff1877F2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // space
                  SizedBox(height: 8.sp),
                  // Bank Transfer Details
                  if (showBankDetails)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15.sp),
                        child: Column(
                          children: [
                            // Beneficiary Name // Beneficiary Bank Name
                            buildResponsiveFields(
                              left: beneficiaryNameField(),
                              right: beneficiaryBankNameField(),
                              context: context,
                            ),
                            // space
                            SizedBox(height: 15.sp),
                            // Beneficiary Bank Account Number / IBAN & Bank SWIFT/BIC Code
                            buildResponsiveFields(
                              left: beneficiaryBankAccountNumberField(),
                              right: ibanField(),
                              context: context,
                            ),
                            // space
                            SizedBox(height: 15.sp),
                            // Bank Address
                            Row(
                              children: [
                                // Bank Address
                                Expanded(
                                  child: CustomValidatedTextFieldMaster(
                                    label: S.of(context).bankAddress,
                                    enabled: false,
                                    hint: S.of(context).bankAddress,
                                    controller: bankAddressController,
                                    maxLines: 3,
                                    height: 72.sp,
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
                  // space
                  SizedBox(height: 20.sp),
                  // Address Details & Hide
                  Row(
                    children: [
                      Text(
                        S.of(context).addressDetails,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          HapticController
                              .low(); // list row: on the tap (X-117)
                          setState(() {
                            showAddressDetails = !showAddressDetails;
                          });
                        },
                        child: Text(
                          showAddressDetails
                              ? S.of(context).hide
                              : S.of(context).expand,
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: Color(0xff1877F2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // space
                  SizedBox(height: 8.sp),
                  // Address Details
                  if (showAddressDetails)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15.sp),
                        child: Column(
                          children: [
                            // Country & State or Province
                            buildResponsiveFields(
                              left: countryField(),
                              right: stateOrProvinceField(),
                              context: context,
                            ),
                            // space
                            SizedBox(height: 15.sp),
                            // City & Postal Code
                            buildResponsiveFields(
                              left: cityField(),
                              right: postalCodeField(),
                              context: context,
                            ),
                            // space
                            SizedBox(height: 15.sp),
                            // Street Name
                            Row(
                              children: [
                                // Street Name
                                Expanded(
                                  child: CustomValidatedTextFieldMaster(
                                    label: S.of(context).streetName,
                                    enabled: false,
                                    hint: S.of(context).streetName,
                                    controller: streetNameController,
                                    maxLines: 3,
                                    height: 72.sp,
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
                  // space
                  SizedBox(height: 20.sp),
                  // Contract Details & Hide
                  Row(
                    children: [
                      Text(
                        S.of(context).contractDetails,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          HapticController
                              .low(); // list row: on the tap (X-117)
                          setState(() {
                            showContractDetails = !showContractDetails;
                          });
                        },
                        child: Text(
                          showContractDetails
                              ? S.of(context).hide
                              : S.of(context).expand,
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: Color(0xff1877F2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // space
                  SizedBox(height: 8.sp),
                  // Contract Details
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: AppColors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15.sp),
                      child: Column(
                        children: [
                          // Contract Start Date  &  Contract End Date
                          buildResponsiveFields(
                            left: contractStartDateDropdown(),
                            right: contractEndDateDropdown(),
                            context: context,
                          ),

                          // space
                          SizedBox(height: 15.sp),

                          // Contract Document  &  Tax Certificate
                          isMobile
                              ? Column(
                                  children: [
                                    // Contract Document
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // contractDocument
                                        Text(
                                          S.of(context).contractDocument,
                                          style: StyleText.fontSize14Weight400
                                              .copyWith(
                                            color: AppColors.blackButton,
                                          ),
                                        ),
                                        // Space
                                        SizedBox(height: 8.sp),
                                        // Image Container
                                        buildImageContainer(),
                                      ],
                                    ),
                                    // space
                                    isMobile
                                        ? SizedBox(height: 15.sp)
                                        : SizedBox(width: 15.sp),
                                    // Tax Certificate
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // contractDocument
                                        Text(
                                          S.of(context).taxCertificate,
                                          style: StyleText.fontSize14Weight400
                                              .copyWith(
                                            color: AppColors.blackButton,
                                          ),
                                        ),
                                        // Space
                                        SizedBox(height: 8.sp),
                                        // Image Container
                                        buildImageContainer(),
                                      ],
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    // Contract Document
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // contractDocument
                                          Text(
                                            S.of(context).contractDocument,
                                            style: StyleText.fontSize14Weight400
                                                .copyWith(
                                              color: AppColors.blackButton,
                                            ),
                                          ),
                                          // Space
                                          SizedBox(height: 8.sp),
                                          // Image Container
                                          buildImageContainer(),
                                        ],
                                      ),
                                    ),
                                    // space
                                    SizedBox(width: 15.sp),
                                    // Tax Certificate
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // contractDocument
                                          Text(
                                            S.of(context).taxCertificate,
                                            style: StyleText.fontSize14Weight400
                                                .copyWith(
                                              color: AppColors.blackButton,
                                            ),
                                          ),
                                          // Space
                                          SizedBox(height: 8.sp),
                                          // Image Container
                                          buildImageContainer(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                  //space
                  SizedBox(height: 20.sp),
                ]
                // Order History Tab
                else if (selectedSection == 1) ...[
                  Column(
                    children: [
                      // Orders History
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).ordersHistory,
                            style: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.blackButton,
                            ),
                          ),
                        ],
                      ),

                      // space
                      SizedBox(height: 8.sp),

                      // Search and DropDown
                      Row(
                        children: [
                          // Search
                          Expanded(
                            child: SizedBox(
                              height: 38.sp,
                              child: AppSearchTextField(
                                controller: _searchController,
                                expanded: false,
                              ),
                            ),
                          ),

                          // space
                          SizedBox(width: ButtonSizing.toolbarGap(context)),

                          // Selected Product
                          isMobile
                              ? customButtonWithSvg(
                                  title: "",
                                  function: () {},
                                  textStyle: StyleText.fontSize8Weight400,
                                  height: 38.sp,
                                  width: 38.sp,
                                  space: 8.sp,
                                  radius: 8.r,
                                  color: AppColors.card,
                                  image:
                                      "assets/icons_assets/main_icons_assets/ic_action_filter.svg",
                                  // 22/10/2026 — Owner: filter and sort icons are one size and colour in every module (ToolbarStyle).
                                  widthImage: ToolbarStyle.iconSize,
                                  heightImage: ToolbarStyle.iconSize,
                                  svgColor: ToolbarStyle.contentColor,
                                  colorBorder: Colors.transparent,
                                )
                              : SizedBox(
                                  width: 135.sp,
                                  child: CustomDropdown<String>(
                                    items: (productTypeList)
                                        .map((e) => DropdownItem<String>(
                                            value: e['key'] ?? '',
                                            label: e['value'] ?? ''))
                                        .toList(),
                                    value: selectedProductType,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedProductType = value;
                                      });
                                    },
                                    hint: S.of(context).productType,
                                    height: 36.sp,
                                    fillColor: AppColors.card,
                                  ),
                                ),
                        ],
                      ),

                      // space
                      SizedBox(height: 15.sp),

                      // GridView of product
                      SizedBox(
                        //   height: MediaQuery.sizeOf(context).height*.5, // adjust based on your UI
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
                            mainAxisSpacing: 15.sp,
                            mainAxisExtent: 112.sp,
                          ),
                          itemCount: ConstantData.purchaseOrders.length,
                          itemBuilder: (context, index) {
                            final order = ConstantData.purchaseOrders[index];
                            debugPrint("✔✔✔✔✔${order["usageFrequency"]}");
                            return GestureDetector(
                              onTap: () {
                                navigateTo(context, HistoryOderDetails());
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
                                      /// Image + ID + Product Count
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                            width: 30.sp,
                                            height: 30.sp,
                                            child: CustomSvgImage(
                                              assetPath:
                                                  "assets/icons_assets/main_icons_assets/ic_data_service_requests.svg",
                                              fit: BoxFit.scaleDown,
                                              color: AppColors.blackButton,
                                              height: 20.sp,
                                              width: 20.sp,
                                            ),
                                          ),
                                          //space
                                          SizedBox(width: 5.sp),
                                          // Order ID &  Closure Status
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Order ID
                                              itemTextProduct(
                                                value: order['orderId'],
                                                label:
                                                    "${S.of(context).orderID}: ",
                                              ),
                                              SizedBox(height: 2.sp),
                                              // Closure Status
                                              itemTextProduct(
                                                value: order['Status'],
                                                label:
                                                    "${S.of(context).closureStatus}: ",
                                                valueColor: getStatusColor(
                                                  order['Status'],
                                                ),
                                              ),
                                            ],
                                          ),

                                          // space
                                          Spacer(),
                                          // Order Date
                                          Row(
                                            children: [
                                              Text(
                                                FormatHelper.capitalize(
                                                  "${S.of(context).orderDate}: ",
                                                ),
                                                style: StyleText
                                                    .fontSize8Weight400
                                                    .copyWith(
                                                  color: AppColors.blackButton,
                                                ),
                                              ),
                                              Text(
                                                order['orderDate'],
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
                                      SizedBox(height: 8.sp),
                                      itemTextProduct(
                                        label:
                                            "${S.of(context).supplierName}: ",
                                        value: order['supplierName'],
                                      ),
                                      SizedBox(height: 4.sp),
                                      itemTextProduct(
                                        label: "${S.of(context).quantity}: ",
                                        value: order['quantity'].join(', '),
                                      ),
                                      SizedBox(height: 4.sp),
                                      Stack(
                                        children: [
                                          Positioned(
                                            top: 2.sp,
                                            left: isArabic ? 0 : null,
                                            right: isArabic ? null : 0,
                                            child: Row(
                                              mainAxisAlignment: isArabic
                                                  ? MainAxisAlignment.start
                                                  : MainAxisAlignment.end,
                                              children: [
                                                itemTextProduct(
                                                  value: order['receivingDate'],
                                                  label:
                                                      "${S.of(context).receivingDate}: ",
                                                ),
                                              ],
                                            ),
                                          ),
                                          itemTextProduct(
                                            label:
                                                "${S.of(context).createdBy}: ",
                                            value: order['CreatedBy'],
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
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  ////////////////////////////// Supplier section ///////////////////////////

  Widget supplierIdField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).supplierId,
      hint: S.of(context).supplierId,
      enabled: false,
      controller: supplierIdController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget supplierNameField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).supplierName,
      hint: S.of(context).supplierName,
      enabled: false,
      controller: supplierNameController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget businessTypeField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).businessType,
      hint: S.of(context).businessType,
      enabled: false,
      controller: businessTypeController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget taxNumberField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).taxNumber,
      hint: S.of(context).taxNumber,
      enabled: false,
      controller: taxNumberController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget businessRegistrationField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).businessRegistrationNumber,
      hint: S.of(context).businessRegistrationNumber,
      enabled: false,
      controller: businessRegistrationController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget supplierBankFiled() {
    return CustomDropdown<String>(
      items: (supplierRankList)
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value: selectedSupplierRank,
      onChanged: (value) {
        setState(() {
          selectedSupplierRank = value;
        });
      },
      label: S.of(context).supplierRank,
      hint: S.of(context).supplierRank,
      height: 36.sp,
    );
  }

  Widget createdByField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).createdBy,
      hint: S.of(context).createdBy,
      enabled: false,
      controller: createdByController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget dateAddedField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).dateAdded,
      hint: S.of(context).dateAdded,
      enabled: false,
      controller: dateAddedController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  ////////////////////////////// Supplier section ///////////////////////////

  Widget firstNameField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).firstName,
      hint: S.of(context).firstName,
      enabled: false,
      controller: firstNameController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget middleNameField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).middleName,
      hint: S.of(context).middleName,
      enabled: false,
      controller: middleNameController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget lastNameField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).lastName,
      hint: S.of(context).lastName,
      enabled: false,
      controller: lastNameController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget titleField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).title,
      hint: S.of(context).title,
      enabled: false,
      controller: titleController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget phoneNumberField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).phoneNumber,
      hint: S.of(context).phoneNumber,
      enabled: false,
      controller: phoneNumberController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget faxNumberField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).faxNumber,
      hint: S.of(context).faxNumber,
      enabled: false,
      controller: faxNumberController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget emailField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).email,
      hint: S.of(context).email,
      enabled: false,
      controller: emailController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget preferredLanguageField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).preferredLanguage,
      hint: S.of(context).preferredLanguage,
      enabled: false,
      controller: preferredLanguageController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  ///////////////////////////// Contact Details ////////////////////////////

  //////////////////////////// Bank Transfer ///////////////////////////////

  Widget beneficiaryNameField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).beneficiaryName,
      hint: S.of(context).beneficiaryName,
      enabled: false,
      controller: beneficiaryNameController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget beneficiaryBankNameField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).beneficiaryBankName,
      hint: S.of(context).beneficiaryBankName,
      enabled: false,
      controller: beneficiaryBankNameController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget beneficiaryBankAccountNumberField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).beneficiaryBankName,
      hint: S.of(context).beneficiaryBankName,
      enabled: false,
      controller: beneficiaryBankNameController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget ibanField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).iban,
      hint: S.of(context).iban,
      enabled: false,
      controller: iBANController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget bankAddressField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).bankAddress,
      hint: S.of(context).bankAddress,
      enabled: false,
      controller: bankAddressController,
      maxLines: 3,
      height: 72.sp,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  //////////////////////////// Bank Transfer ///////////////////////////////

  //////////////////////////// Address Details  /////////////////////////////

  Widget countryField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).country,
      hint: S.of(context).country,
      enabled: false,
      controller: countryController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget stateOrProvinceField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).state,
      hint: S.of(context).state,
      enabled: false,
      controller: stateOrProvinceController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget cityField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).city,
      hint: S.of(context).city,
      enabled: false,
      controller: cityController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget postalCodeField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).postalCode,
      hint: S.of(context).postalCode,
      enabled: false,
      controller: postalCodeController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget streetNameField() {
    return CustomValidatedTextFieldMaster(
      label: S.of(context).streetName,
      hint: S.of(context).streetName,
      enabled: false,
      controller: streetNameController,
      maxLines: 3,
      height: 72.sp,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  //////////////////////////// Address Details  /////////////////////////////

  //////////////////////////// Contract Details  /////////////////////////

  //////////////////////////// Contract Details  /////////////////////////

  Widget contractStartDateDropdown() {
    return CustomDateField(
      value: DateFormat('d/M/yyyy').tryParse((selectStartDate) ?? ''),
      onChanged: (date) {
        if (date == null) return;
        ((value) {
          if (value != null) {
            setState(() {
              selectStartDate = value;
            });
          }
        })(DateFormat('d/M/yyyy').format(date));
      },
      label: S.of(context).expectedDeliveryDate,
      hint: "24 Nov 2018",
      height: 36.sp,
    );
  }

  Widget contractEndDateDropdown() {
    return CustomDateField(
      value: DateFormat('d/M/yyyy').tryParse((selectEndDate) ?? ''),
      onChanged: (date) {
        if (date == null) return;
        ((value) {
          if (value != null) {
            setState(() {
              selectEndDate = value;
            });
          }
        })(DateFormat('d/M/yyyy').format(date));
      },
      label: S.of(context).expectedDeliveryDate,
      hint: "24 Nov 2018",
      height: 36.sp,
    );
  }

  ///////////////////////////// Contact Details ////////////////////////////

  Widget buildImageContainer() {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: lightMode ? Color(0xffB5B4B4) : AppColors.grey,
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
                    style: StyleText.fontSize10Weight400.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  // Date value
                  Text(
                    "28 Dec 2023",
                    style: StyleText.fontSize10Weight400.copyWith(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name of Image
                    Text(
                      "Watermark.png",
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),

                    Text(
                      "62 KB",
                      style: StyleText.fontSize12Weight500.copyWith(
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
  }

  //////////////////////////////// Navigate Page //////////////////////////

  Widget buildTab(String label, int index) {
    final isSelected = selectedSection == index;
    final isMobile = context.isPhone;

    // Measure text width dynamically
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: label, style: StyleText.fontSize20Weight600),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final double underlineWidth = textPainter.size.width;

    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () {
        setState(() {
          selectedSection = index;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: isMobile
                ? StyleText.fontSize16Weight600.copyWith(
                    color: isSelected
                        ? AppColors.secondaryPrimary
                        : AppColors.secondaryText,
                  )
                : StyleText.fontSize20Weight600.copyWith(
                    color: isSelected
                        ? AppColors.secondaryPrimary
                        : AppColors.secondaryText,
                  ),
          ),
          SizedBox(height: 4.sp),
          if (isSelected)
            Container(
              height: 2.sp,
              width: isMobile ? underlineWidth - 25 : underlineWidth,
              color: AppColors.secondaryPrimary,
            ),
        ],
      ),
    );
  }

  //////////////////////////////// Navigate Page //////////////////////////

  /////////////////////////// ListView Item Text /////////////////////////////////////////////////////////

  Widget itemTextProduct({
    required String label,
    required String value,
    Color? valueColor,
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
            color: valueColor ?? AppColors.blackButton,
          ),
        ),
      ],
    );
  }

  /////////////////////////// ListView Item Text /////////////////////////////////////////////////////////
}

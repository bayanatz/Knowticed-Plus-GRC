import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'dart:ui' as ui;
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/widgets/storage_location_form_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/domain/models/supplier_model.dart';
import 'package:knowticed_plus/features/inventory/presentation/controller/product_cubit.dart';
import 'package:knowticed_plus/features/inventory/inv3_assign_and_suppliers/presentation/ui/pages/p9_history_order_details_toggel.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/widgets/add_new_supplier_third/draft.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/pages/edit_supplier_details_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_toolbar_action_button.dart';

class ViewSupplierDetails extends StatefulWidget {
  final Map<String, dynamic>? supplierData;
  final SupplierModel? supplierModel; // Add this line

  const ViewSupplierDetails({
    super.key,
    this.supplierData,
    this.supplierModel, // Add this line
  });

  @override
  State<ViewSupplierDetails> createState() => _ViewSupplierDetailsState();
}

class _ViewSupplierDetailsState extends State<ViewSupplierDetails> {
  late ProductCubit _productCubit;
  String currentSupplierId = "";
  List<ProductModel> supplierOrders = [];
  bool isLoadingOrders = false;

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
  String? supplierImageUrl;

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

  // ADD THESE NEW PROPERTIES FOR MULTIPLE ITEMS:
  List<Map<String, dynamic>> allContacts = [];
  List<Map<String, dynamic>> allAddresses = [];
  List<Map<String, dynamic>> allWarehouses = [];
  bool isLoadingSubCollections = false;
  bool warehouseEnabled = false;
  String? contractDocumentUrl; // This one you already have
  String? taxCertificateUrl; // This one you already have
  String? registrationDocumentUrl; // This one you already have
  String? attachmentUrl; // NEW

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

    // Updated document URLs - using only existing SupplierModel fields
    selectedSupplierRank = data["supplierRank"];
    supplierImageUrl = data["imageSupplier"] ?? "";

    contractDocumentUrl = data['contractDocumentFileUrl'];
    taxCertificateUrl = data['taxCertificateFileUrl'];
    registrationDocumentUrl = data['registrationDocumentFileUrl'];
    attachmentUrl = data['attachmentsFileUrl'];

    setState(() {});
  }

  // 2. Update _fillFormFromSupplierModel method (around line 400)
  void _fillFormFromSupplierModel(SupplierModel supplier) {
    // Basic supplier information
    supplierIdController.text = supplier.supplierID;
    supplierNameController.text = supplier.supplierName;
    businessTypeController.text = supplier.businessType;
    selectedSupplierRank = supplier.supplierRank;

    // Optional fields with null checks
    taxNumberController.text = supplier.taxNumber;
    businessRegistrationController.text = supplier.businessRegistrationNumber;
    createdByController.text = supplier.createdBy;
    dateAddedController.text = supplier.dateAdded;

    // Contract dates
    selectStartDate = supplier.contractStartDate;
    selectEndDate = supplier.contractEndDate;

    // Contact information
    firstNameController.text = supplier.firstName;
    middleNameController.text = supplier.middleName;
    lastNameController.text = supplier.lastName;
    titleController.text = supplier.title;
    phoneNumberController.text = supplier.phoneNumber;
    faxNumberController.text = supplier.faxNumber;
    emailController.text = supplier.email;
    preferredLanguageController.text = supplier.preferredLanguage;

    // Bank transfer details
    iBANController.text = supplier.beneficiaryBankAccountNumberIBAN;
    bankAddressController.text = supplier.bankAddress;
    beneficiaryBankNameController.text = supplier.beneficiaryBankName;
    beneficiaryNameController.text = supplier.beneficiaryName;
    bankSWIFTController.text = supplier.bankSWIFTBICCode;

    // Address details
    countryController.text = supplier.country;
    cityController.text = supplier.city;
    streetNameController.text = supplier.streetName;
    stateOrProvinceController.text = supplier.stateOrProvince;
    postalCodeController.text = supplier.postalCode;

    // Warehouse details
    wareHouseNameController.text = supplier.warehouseStreetName;
    countryWareHouseController.text = supplier.warehouseCountry;
    stateOrProvinceWareHouseController.text = supplier.warehouseStateOrProvince;
    cityWareHouseController.text = supplier.warehouseCity;
    postalCodeWareHouseController.text = supplier.warehousePostalCode;
    streetNameWareHouseController.text = supplier.warehouseStreetName;

    // Document URLs - using only existing SupplierModel fields
    supplierImageUrl = supplier.imageSupplier;

    contractDocumentUrl = supplier.contractDocumentFileUrl;
    taxCertificateUrl = supplier.taxCertificateFileUrl;
    registrationDocumentUrl = supplier.registrationDocumentFileUrl;
    attachmentUrl = supplier.attachmentsFileUrl;

    // Update the UI
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

    _productCubit = ProductCubit.get(context);

    if (widget.supplierModel != null) {
      _fillFormFromSupplierModel(widget.supplierModel!);
      currentSupplierId = widget.supplierModel!.supplierID;
    } else if (widget.supplierData != null) {
      fillForm(widget.supplierData!);
      currentSupplierId = widget.supplierData!["supplierId"] ?? "";
    }

    // Load sub-collections data
    _loadSubCollectionsData();
  }

  Future<void> _loadSubCollectionsData() async {
    if (currentSupplierId.isEmpty) {
      debugPrint("No supplier ID available for loading sub-collections");
      return;
    }

    setState(() {
      isLoadingSubCollections = true;
    });

    try {
      final supplierData = await SupplierDraftStore.instance
          .readSupplierFromFirebase(supplierId: currentSupplierId);

      if (supplierData != null) {
        setState(() {
          allContacts = List<Map<String, dynamic>>.from(
            supplierData['contacts'] ?? [],
          );
          allAddresses = List<Map<String, dynamic>>.from(
            supplierData['addresses'] ?? [],
          );
          allWarehouses = List<Map<String, dynamic>>.from(
            supplierData['warehouses'] ?? [],
          );

          // Check warehouse enabled state
          warehouseEnabled = supplierData['enable'] == 'warehouse_enabled' ||
              allWarehouses.isNotEmpty;
        });

        debugPrint("✅ Loaded sub-collections:");
        debugPrint("Contacts: ${allContacts.length}");
        debugPrint("Addresses: ${allAddresses.length}");
        debugPrint("Warehouses: ${allWarehouses.length}");
        debugPrint("Warehouse enabled: $warehouseEnabled");
      }
    } catch (e) {
      debugPrint("Error loading sub-collections: $e");
    } finally {
      setState(() {
        isLoadingSubCollections = false;
      });
    }
  }

  void _loadSupplierOrders() async {
    if (currentSupplierId.isEmpty) {
      debugPrint("❌ No supplier ID available");
      return;
    }

    debugPrint("🔄 Loading orders for supplier: $currentSupplierId");
    setState(() {
      isLoadingOrders = true;
    });

    try {
      await _productCubit.loadOrdersForSupplier(currentSupplierId);
      debugPrint("✅ Orders loaded successfully");
    } catch (e) {
      debugPrint("❌ Error loading supplier orders: $e");
    } finally {
      setState(() {
        isLoadingOrders = false;
      });
    }
  }

  /////////////////////////////// Dummy Data ///////////////////////////////////////////////////////////////

  /////////////////////////////// Dummy data ///////////////////////////////////////////////////////////////

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

  // Add this method to your ViewSupplierDetails class:

  Map<String, dynamic> _convertSupplierModelToEditFormat(
    SupplierModel supplier,
  ) {
    return {
      "supplierId": supplier.supplierID,
      "supplierName": supplier.supplierName,
      "businessType": supplier.businessType,
      "taxNumber": supplier.taxNumber,
      "businessRegistrationNumber": supplier.businessRegistrationNumber,
      "supplierRank": supplier.supplierRank,
      "createdBy": supplier.createdBy,
      "dateAdded": supplier.dateAdded,
      "imageSupplier": supplier.imageSupplier,

      // Contact details
      "contact": {
        "firstName": supplier.firstName,
        "middleName": supplier.middleName,
        "lastName": supplier.lastName,
        "title": supplier.title,
        "phoneNumber": supplier.phoneNumber,
        "fax": supplier.faxNumber,
        "email": supplier.email,
        "preferredLanguage": supplier.preferredLanguage,
      },

      // Bank transfer details
      "bankTransferDetails": {
        "beneficiaryName": supplier.beneficiaryName,
        "beneficiaryBankName": supplier.beneficiaryBankName,
        "iban": supplier.beneficiaryBankAccountNumberIBAN,
        "bankSWIFT": supplier.bankSWIFTBICCode,
        "bankAddress": supplier.bankAddress,
      },

      // Address details
      "addressDetails": {
        "country": supplier.country,
        "state": supplier.stateOrProvince,
        "city": supplier.city,
        "postalCode": supplier.postalCode,
        "streetName": supplier.streetName,
      },

      // Warehouse details
      "warehouseDetails": {
        "country": supplier.warehouseCountry,
        "stateOrProvince": supplier.warehouseStateOrProvince,
        "city": supplier.warehouseCity,
        "postalCode": supplier.warehousePostalCode,
        "streetName": supplier.warehouseStreetName,
      },

      // Contract details - using only existing SupplierModel fields
      "contractStartDate": supplier.contractStartDate,
      "contractEndDate": supplier.contractEndDate,

      "contractDocumentFileUrl": supplier.contractDocumentFileUrl,
      "taxCertificateFileUrl": supplier.taxCertificateFileUrl,
      "registrationDocumentFileUrl": supplier.registrationDocumentFileUrl,
      "attachmentsFileUrl": supplier.attachmentsFileUrl,
    };
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    Localizations.localeOf(context).languageCode == 'ar';
    final isMobile = context.isPhone;

    final hasContract = (contractDocumentUrl ?? '').isNotEmpty;
    final hasTax = (taxCertificateUrl ?? '').isNotEmpty;
    final hasRegistration = (registrationDocumentUrl ?? '').isNotEmpty;
    final hasAttachment = (attachmentUrl ?? '').isNotEmpty;

    Localizations.localeOf(context).languageCode == 'en';
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventoryManagement,
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
                    // Tabs (Figma 4031:34189 / 4031:34190).
                    Expanded(
                      child: StorageTabs(
                        labels: [
                          S.of(context).supplierDetails,
                          S.of(context).ordersHistory,
                        ],
                        selected: selectedSection,
                        onChanged: (i) => setState(() => selectedSection = i),
                      ),
                    ),

                    selectedSection == 1
                        ? SizedBox()
                        : customButtonWithSvg(
                            title: isMobile ? "" : S.of(context).edit,
                            function: () {
                              // Create a comprehensive data map to pass to edit screen
                              Map<String, dynamic> supplierDataForEdit = {};

                              if (widget.supplierModel != null) {
                                // If we have SupplierModel, convert it to the expected format
                                supplierDataForEdit =
                                    _convertSupplierModelToEditFormat(
                                  widget.supplierModel!,
                                );
                              } else if (widget.supplierData != null) {
                                // Use existing supplier data
                                supplierDataForEdit = widget.supplierData!;
                              }

                              debugPrint("🔄 Passing data to edit screen:");
                              debugPrint(
                                "Supplier ID: ${supplierDataForEdit['supplierId']}",
                              );
                              debugPrint(
                                "Supplier Name: ${supplierDataForEdit['supplierName']}",
                              );
                              debugPrint(
                                "Contact data: ${supplierDataForEdit['contact']}",
                              );
                              debugPrint(
                                "Bank data: ${supplierDataForEdit['bankTransferDetails']}",
                              );
                              debugPrint(
                                "Address data: ${supplierDataForEdit['addressDetails']}",
                              );
                              debugPrint(
                                "Warehouse data: ${supplierDataForEdit['warehouseDetails']}",
                              );

                              navigateTo(
                                context,
                                EditSupplierDetailsToggle(
                                  supplierData: supplierDataForEdit,
                                ),
                              );
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              showSupplierDetails
                                  ? S.of(context).hide
                                  : S.of(context).expand,
                              style: StyleText.fontSize14Weight500.copyWith(
                                color: Color(0xff1877F2),
                              ),
                            ),
                            SizedBox(height: 0.sp),
                            Container(
                              height: 1.sp,
                              width: _getTextWidth(
                                showSupplierDetails
                                    ? S.of(context).hide
                                    : S.of(context).expand,
                                StyleText.fontSize14Weight500,
                              ),
                              color: Color(0xff1877F2),
                            ),
                          ],
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
                              children: [buildSupplierImageWidget()],
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
                              right: taxNumberField(),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              showContactDetails
                                  ? S.of(context).hide
                                  : S.of(context).expand,
                              style: StyleText.fontSize14Weight500.copyWith(
                                color: Color(0xff1877F2),
                              ),
                            ),
                            SizedBox(height: 0.sp),
                            Container(
                              height: 1.sp,
                              width: _getTextWidth(
                                showContactDetails
                                    ? S.of(context).hide
                                    : S.of(context).expand,
                                StyleText.fontSize14Weight500,
                              ),
                              color: Color(0xff1877F2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // space
                  SizedBox(height: 8.sp),

                  // Point Of Contact Details
                  if (showContactDetails) buildContactsSection(lightMode),

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              showBankDetails
                                  ? S.of(context).hide
                                  : S.of(context).expand,
                              style: StyleText.fontSize14Weight500.copyWith(
                                color: Color(0xff1877F2),
                              ),
                            ),
                            SizedBox(height: 0.sp),
                            Container(
                              height: 1.sp,
                              width: _getTextWidth(
                                showBankDetails
                                    ? S.of(context).hide
                                    : S.of(context).expand,
                                StyleText.fontSize14Weight500,
                              ),
                              color: Color(0xff1877F2),
                            ),
                          ],
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
                                  child: StorageTextField(
                                    label: S.of(context).bankAddress,
                                    controller: bankAddressController,
                                    readOnly: true,
                                    multiline: true,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              showAddressDetails
                                  ? S.of(context).hide
                                  : S.of(context).expand,
                              style: StyleText.fontSize14Weight500.copyWith(
                                color: Color(0xff1877F2),
                              ),
                            ),
                            SizedBox(height: 0.sp),
                            Container(
                              height: 1.sp,
                              width: _getTextWidth(
                                showAddressDetails
                                    ? S.of(context).hide
                                    : S.of(context).expand,
                                StyleText.fontSize14Weight500,
                              ),
                              color: Color(0xff1877F2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // space
                  SizedBox(height: 8.sp),
                  // Address Details
                  if (showAddressDetails) buildAddressesSection(lightMode),
                  // space
                  SizedBox(height: 20.sp),

                  // Warehouses Details
                  !warehouseEnabled
                      ? SizedBox()
                      : buildWarehousesSection(lightMode),

                  !warehouseEnabled ? SizedBox() : SizedBox(height: 20.sp),

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              showContractDetails
                                  ? S.of(context).hide
                                  : S.of(context).expand,
                              style: StyleText.fontSize14Weight500.copyWith(
                                color: Color(0xff1877F2),
                              ),
                            ),
                            SizedBox(height: 0.sp),
                            Container(
                              height: 1.sp,
                              width: _getTextWidth(
                                showContractDetails
                                    ? S.of(context).hide
                                    : S.of(context).expand,
                                StyleText.fontSize14Weight500,
                              ),
                              color: Color(0xff1877F2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // space
                  SizedBox(height: 8.sp),

                  // Contract Details Content
                  if (showContractDetails)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: AppColors.card,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15.sp),
                        child: Column(
                          children: [
                            // Contract Start Date & Contract End Date
                            buildResponsiveFields(
                              left: contractStartDateField(),
                              right: contractEndDateField(),
                              context: context,
                            ),

                            // space
                            SizedBox(height: 15.sp),

                            // Documents Section - Only show available documents
                            if (isMobile) ...[
                              if (hasContract) ...[
                                Text(
                                  S.of(context).contractDocument,
                                  style: StyleText.fontSize14Weight400.copyWith(
                                    color: AppColors.blackButton,
                                  ),
                                ),
                                SizedBox(height: 8.sp),
                                buildImageContainer(
                                  imageUrl: contractDocumentUrl,
                                  documentType: S.of(context).contractDocument,
                                ),
                                SizedBox(height: 15.sp),
                              ],
                              if (hasTax) ...[
                                Text(
                                  S.of(context).taxCertificate,
                                  style: StyleText.fontSize14Weight400.copyWith(
                                    color: AppColors.blackButton,
                                  ),
                                ),
                                SizedBox(height: 8.sp),
                                buildImageContainer(
                                  imageUrl: taxCertificateUrl,
                                  documentType: S.of(context).taxCertificate,
                                ),
                                SizedBox(height: 15.sp),
                              ],
                              if (hasRegistration) ...[
                                Text(
                                  "Registration Document",
                                  style: StyleText.fontSize14Weight400.copyWith(
                                    color: AppColors.blackButton,
                                  ),
                                ),
                                SizedBox(height: 8.sp),
                                buildImageContainer(
                                  imageUrl: registrationDocumentUrl,
                                  documentType: "Registration Document",
                                ),
                                SizedBox(height: 15.sp),
                              ],
                              if (hasAttachment) ...[
                                Text(
                                  S.of(context).attachments,
                                  style: StyleText.fontSize14Weight400.copyWith(
                                    color: AppColors.blackButton,
                                  ),
                                ),
                                SizedBox(height: 8.sp),
                                buildImageContainer(
                                  imageUrl: attachmentUrl,
                                  documentType: S.of(context).attachments,
                                ),
                              ],
                            ] else ...[
                              // Row 1: Contract + Tax
                              Row(
                                children: [
                                  if (hasContract)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            S.of(context).contractDocument,
                                            style: StyleText.fontSize14Weight400
                                                .copyWith(
                                              color: AppColors.blackButton,
                                            ),
                                          ),
                                          SizedBox(height: 8.sp),
                                          buildImageContainer(
                                            imageUrl: contractDocumentUrl,
                                            documentType:
                                                S.of(context).contractDocument,
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (hasContract && hasTax)
                                    SizedBox(width: 15.sp),
                                  if (hasTax)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            S.of(context).taxCertificate,
                                            style: StyleText.fontSize14Weight400
                                                .copyWith(
                                              color: AppColors.blackButton,
                                            ),
                                          ),
                                          SizedBox(height: 8.sp),
                                          buildImageContainer(
                                            imageUrl: taxCertificateUrl,
                                            documentType:
                                                S.of(context).taxCertificate,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),

                              // Row 2: Registration + Attachment (only if any)
                              if (hasRegistration || hasAttachment) ...[
                                SizedBox(height: 15.sp),
                                Row(
                                  children: [
                                    if (hasRegistration)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Registration Document",
                                              style: StyleText
                                                  .fontSize14Weight400
                                                  .copyWith(
                                                color: AppColors.blackButton,
                                              ),
                                            ),
                                            SizedBox(height: 8.sp),
                                            buildImageContainer(
                                              imageUrl: registrationDocumentUrl,
                                              documentType:
                                                  "Registration Document",
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (hasRegistration && hasAttachment)
                                      SizedBox(width: 15.sp),
                                    if (hasAttachment)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              S.of(context).attachments,
                                              style: StyleText
                                                  .fontSize14Weight400
                                                  .copyWith(
                                                color: AppColors.blackButton,
                                              ),
                                            ),
                                            SizedBox(height: 8.sp),
                                            buildImageContainer(
                                              imageUrl: attachmentUrl,
                                              documentType:
                                                  S.of(context).attachments,
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  //space
                  SizedBox(height: 20.sp),
                ]
                // Order History Tab
                else if (selectedSection == 1) ...[
                  _buildOrdersHistorySection(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    return textPainter.size.width;
  }

  // Build orders history section with BLoC integration
  Widget _buildOrdersHistorySection() {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        final isMobile = context.isPhone;

        if (state is OrderLoading || isLoadingOrders) {
          return SizedBox(
            height: 300.sp,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleProgressMaster.inline(color: AppColors.primary),
                  SizedBox(height: 16.sp),
                  Text(
                    'Loading orders for this supplier...',
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is OrderError) {
          return SizedBox(
            height: 300.sp,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: AppColors.red),
                  SizedBox(height: 16.sp),
                  Text(
                    'Error loading orders',
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.red,
                    ),
                  ),
                  SizedBox(height: 8.sp),
                  Text(
                    state.message,
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: AppColors.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.sp),
                  customButton(
                    title: S.of(context).retry,
                    function: _loadSupplierOrders,
                    wrapContent: true,
                  ),
                ],
              ),
            ),
          );
        }

        List<ProductModel> ordersToShow = [];
        if (state is OrderLoaded) {
          ordersToShow = state.filteredOrders;
        }

        return Column(
          children: [
            // Orders History Header
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

            SizedBox(height: 8.sp),

            // Search and Filter Row
            Row(
              children: [
                // Search
                AppSearchTextField(
                  controller: _searchController,
                  onChanged: (query) {
                    _productCubit.searchOrders(query);
                  },
                ),

                SizedBox(width: ButtonSizing.toolbarGap(context)),

                // Status Filter
                isMobile
                    ? customButtonWithSvg(
                        title: "",
                        function: () {
                          // Show filter dialog for mobile
                        },
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
                            _productCubit.filterOrdersByStatus(value);
                          },
                          hint: S.of(context).productType,
                          // Same box as the search field beside it: 38 tall,
                          // 12 side padding, radius 8.
                          height: 38,
                          triggerPadding: EdgeInsetsDirectional.symmetric(
                              horizontal: 12.sp),
                          suffixIconPadding:
                              EdgeInsetsDirectional.only(end: 12.sp),
                          borderRadius: BorderRadius.circular(8.r),
                          fillColor: AppColors.card,
                        ),
                      ),
              ],
            ),

            SizedBox(height: 15.sp),

            // Orders Grid or Empty State
            if (ordersToShow.isEmpty)
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 40.sp),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Empty state: animation only, larger, centred.
                    CustomEmptyState(
                      lottiePath:
                          'assets/lottie_assets/main_lottie_assets/lot_empty_state.json',
                      size: 320,
                      verticalPadding: 0,
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
                    context,
                  ),
                  crossAxisSpacing: 15.sp,
                  mainAxisSpacing: 15.sp,
                  mainAxisExtent: 112.sp,
                ),
                itemCount: ordersToShow.length,
                itemBuilder: (context, index) {
                  final order = ordersToShow[index];
                  return _buildOrderCard(order);
                },
              ),
          ],
        );
      },
    );
  }

  // Helper method to build order cards from ProductModel
  // In ViewSupplierDetails, update the _buildOrderCard method:

  // In your ViewSupplierDetails class, update the _buildOrderCard method:

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}";
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  String _formatDateString(String dateString) {
    try {
      // Try parsing the date string
      DateTime date = DateTime.parse(dateString);
      return _formatDate(date);
    } catch (e) {
      // If parsing fails, try to handle different formats
      try {
        // Handle format like "23-9-2025" (dd-M-yyyy)
        List<String> parts = dateString.split('-');
        if (parts.length == 3) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          DateTime date = DateTime(year, month, day);
          return _formatDate(date);
        }
      } catch (e) {
        debugPrint("Failed to parse date: $dateString");
      }
      return dateString; // Return original if all parsing fails
    }
  }

  Widget buildSupplierImageWidget() {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    bool hasImage = supplierImageUrl != null && supplierImageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: withHaptic(
          hasImage
              ? () => _showImagePreview(supplierImageUrl!, "Supplier Image")
              : null,
          HapticLevel.low),
      child: Container(
        width: 60.r,
        height: 60.r,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          //  color: lightMode ? AppColors.grey : AppColors.background,
          //   border: hasImage ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        child: Stack(
          children: [
            // Show supplier image or default icon
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: Image.network(
                  supplierImageUrl!,
                  width: 60.r,
                  height: 60.r,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 20.sp,
                        height: 20.sp,
                        child: CircleProgressMaster.inline(
                          strokeWidth: 2,
                          color: AppColors.primary,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: CustomSvgImage(
                        assetPath:
                            "assets/icons_assets/inventory_assets/ic_file_folder_done.svg",
                        width: 35.r,
                        height: 35.r,
                        color: AppColors.blackButton,
                        fit: BoxFit.scaleDown,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                width: 60.r,
                height: 60.r,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  color: lightMode ? Color(0xffD0D0D0) : AppColors.background,
                ),
                child: Center(
                  child: CustomSvgImage(
                    assetPath:
                        "assets/icons_assets/inventory_assets/ic_file_folder_done.svg", // Figma 4031:33990
                    width: 35.r,
                    height: 35.r,
                    color: AppColors.blackButton,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(ProductModel order) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return GestureDetector(
      onTap: () {
        debugPrint("🔍 Navigating to order details:");
        debugPrint("  - Order ID: '${order.orderId.value}'");
        debugPrint("  - Product ID: '${order.productId.value}'");
        debugPrint("  - Supplier ID: '${order.supplierId.value}'");
        debugPrint("  - Supplier Name: '${order.supplierName.value}'");

        // Navigate with the selected order data
        navigateTo(
          context,
          HistoryOderDetails(
            orderData: order, // Pass the single order
          ),
        );
      },
      child: Container(
        width: 289.sp,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.sp),
          child: Column(
            children: [
              // Image + ID + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order image
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: lightMode ? AppColors.grey : AppColors.background,
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
                  SizedBox(width: 5.sp),
                  // Order details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      itemTextProduct(
                        value: order.orderId.value,
                        label: "${S.of(context).orderID}: ",
                      ),
                      SizedBox(height: 2.sp),
                      itemTextProduct(
                        value: order.status.value,
                        label: "${S.of(context).closureStatus}: ",
                        valueColor: getStatusColor(order.status.value),
                      ),
                    ],
                  ),
                  Spacer(),
                  // Order Date
                  Text(
                    FormatHelper.capitalize("${S.of(context).orderDate}: "),
                    style: StyleText.fontSize8Weight400.copyWith(
                      color: AppColors.blackButton,
                    ),
                  ),
                  Text(
                    _formatDateString(order.orderDate.value),
                    style: StyleText.fontSize8Weight400.copyWith(
                      color: AppColors.blackButton,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.sp),
              itemTextProduct(
                label: "${S.of(context).productName}: ",
                value: order.productName.value,
              ),
              SizedBox(height: 4.sp),
              itemTextProduct(
                label: "${S.of(context).quantity}: ",
                value: order.quantity.value,
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
                          value: _formatDateString(order.orderDate.value),
                          label: "${S.of(context).receivingDate}: ",
                        ),
                      ],
                    ),
                  ),
                  itemTextProduct(
                    label: "${S.of(context).createdBy}: ",
                    value:
                        "${order.firstNameCreator.value} ${order.lastNameCreator.value}"
                            .trim(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTab(String label, int index) {
    final isSelected = selectedSection == index;

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

        // Load orders when switching to orders tab
        if (index == 1) {
          _loadSupplierOrders();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: StyleText.fontSize20Weight600.copyWith(
              color: isSelected
                  ? AppColors.secondaryPrimary
                  : AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 4.sp),
          if (isSelected)
            Container(
              height: 2.sp,
              width: underlineWidth,
              color: AppColors.secondaryPrimary,
            ),
        ],
      ),
    );
  }

  Widget buildContactsSection(bool lightMode) {
    if (isLoadingSubCollections) {
      return SizedBox(
        height: 100.h,
        child: Center(child: CircleProgressMaster.inline()),
      );
    }

    List<Map<String, dynamic>> contactsToShow = allContacts.isNotEmpty
        ? allContacts
        : [
            {
              'firstName': firstNameController.text,
              'middleName': middleNameController.text,
              'lastName': lastNameController.text,
              'title': titleController.text,
              'phoneNumber': phoneNumberController.text,
              'faxNumber': faxNumberController.text,
              'email': emailController.text,
              'preferredLanguage': preferredLanguageController.text,
            },
          ];

    return Column(
      children: [
        // Display all contacts
        ...contactsToShow.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> contact = entry.value;
          bool isPrimary = index == 0;

          return Column(
            children: [
              if (index > 0) SizedBox(height: 20.sp),

              // Header for additional contacts
              if (!isPrimary) ...[
                Row(
                  children: [
                    Text(
                      "${index + 1}${index == 1 ? 'nd' : index == 2 ? 'rd' : 'th'} Contact Details",
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.sp),
              ],

              // Contact container
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15.sp),
                  child: Column(
                    children: [
                      buildResponsiveFields(
                        left: _buildReadOnlyField(
                          S.of(context).firstName,
                          contact['firstName'] ?? '',
                        ),
                        right: _buildReadOnlyField(
                          S.of(context).middleName,
                          contact['middleName'] ?? '',
                        ),
                        context: context,
                      ),
                      SizedBox(height: 15.sp),
                      buildResponsiveFields(
                        left: _buildReadOnlyField(
                          S.of(context).lastName,
                          contact['lastName'] ?? '',
                        ),
                        right: _buildReadOnlyField(
                          S.of(context).title,
                          contact['title'] ?? '',
                        ),
                        context: context,
                      ),
                      SizedBox(height: 15.sp),
                      buildResponsiveFields(
                        left: _buildReadOnlyField(
                          S.of(context).phoneNumber,
                          contact['phoneNumber'] ?? '',
                        ),
                        right: _buildReadOnlyField(
                          S.of(context).faxNumber,
                          contact['faxNumber'] ?? '',
                        ),
                        context: context,
                      ),
                      SizedBox(height: 15.sp),
                      buildResponsiveFields(
                        left: _buildReadOnlyField(
                          S.of(context).email,
                          contact['email'] ?? '',
                        ),
                        right: _buildReadOnlyField(
                          S.of(context).preferredLanguage,
                          contact['preferredLanguage'] ?? '',
                        ),
                        context: context,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  // BUILD ADDRESSES SECTION
  Widget buildAddressesSection(bool lightMode) {
    if (isLoadingSubCollections) {
      return SizedBox(
        height: 100.h,
        child: Center(child: CircleProgressMaster.inline()),
      );
    }

    List<Map<String, dynamic>> addressesToShow = allAddresses.isNotEmpty
        ? allAddresses
        : [
            {
              'country': countryController.text,
              'stateOrProvince': stateOrProvinceController.text,
              'city': cityController.text,
              'postalCode': postalCodeController.text,
              'streetName': streetNameController.text,
            },
          ];

    return Column(
      children: [
        // Display all addresses
        ...addressesToShow.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> address = entry.value;
          bool isPrimary = index == 0;

          return Column(
            children: [
              if (index > 0) SizedBox(height: 20.sp),

              // Header for additional addresses
              if (!isPrimary) ...[
                Row(
                  children: [
                    Text(
                      "${index + 1}${index == 1 ? 'nd' : index == 2 ? 'rd' : 'th'} Address Details",
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.sp),
              ],

              // Address container
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15.sp),
                  child: Column(
                    children: [
                      buildResponsiveFields(
                        left: _buildReadOnlyField(
                          S.of(context).country,
                          address['country'] ?? '',
                        ),
                        right: _buildReadOnlyField(
                          S.of(context).state,
                          address['stateOrProvince'] ?? '',
                        ),
                        context: context,
                      ),
                      SizedBox(height: 15.sp),
                      buildResponsiveFields(
                        left: _buildReadOnlyField(
                          S.of(context).city,
                          address['city'] ?? '',
                        ),
                        right: _buildReadOnlyField(
                          S.of(context).postalCode,
                          address['postalCode'] ?? '',
                        ),
                        context: context,
                      ),
                      SizedBox(height: 15.sp),
                      Row(
                        children: [
                          Expanded(
                            child: StorageTextField(
                              label: S.of(context).description,
                              controller: TextEditingController(
                                text: address['streetName'] ?? '',
                              ),
                              readOnly: true,
                              multiline: true,
                              textDirection: ui.TextDirection.ltr,
                              onChanged: (_) {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  // BUILD WAREHOUSES SECTION
  Widget buildWarehousesSection(bool lightMode) {
    return Column(
      children: [
        // Warehouses Details Header
        Row(
          children: [
            Text(
              S.of(context).warehousesDetails,
              style: StyleText.fontSize16Weight600.copyWith(
                color: AppColors.blackButton,
              ),
            ),
            Spacer(),
            // Show warehouse status indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: warehouseEnabled
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                warehouseEnabled ? "Enabled" : "Disabled",
                style: StyleText.fontSize12Weight500.copyWith(
                  color: warehouseEnabled ? Colors.green : Colors.grey,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 10.sp),

        // Show warehouses if enabled
        if (warehouseEnabled && allWarehouses.isNotEmpty) ...[
          ...allWarehouses.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> warehouse = entry.value;
            bool isPrimary = index == 0;

            return Column(
              children: [
                if (index > 0) SizedBox(height: 20.sp),

                // Header for additional warehouses
                if (!isPrimary) ...[
                  Row(
                    children: [
                      Text(
                        "${index + 1}${index == 1 ? 'nd' : index == 2 ? 'rd' : 'th'} Warehouse Details",
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.sp),
                ],

                // Warehouse container
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15.sp),
                    child: Column(
                      children: [
                        buildResponsiveFields(
                          left: _buildReadOnlyField(
                            S.of(context).warehouseName,
                            warehouse['warehouseName'] ?? '',
                          ),
                          right: _buildReadOnlyField(
                            S.of(context).country,
                            warehouse['country'] ?? '',
                          ),
                          context: context,
                        ),
                        SizedBox(height: 15.sp),
                        buildResponsiveFields(
                          left: _buildReadOnlyField(
                            S.of(context).state,
                            warehouse['stateOrProvince'] ?? '',
                          ),
                          right: _buildReadOnlyField(
                            S.of(context).city,
                            warehouse['city'] ?? '',
                          ),
                          context: context,
                        ),
                        SizedBox(height: 15.sp),
                        buildResponsiveFields(
                          left: _buildReadOnlyField(
                            S.of(context).postalCode,
                            warehouse['postalCode'] ?? '',
                          ),
                          right: _buildReadOnlyField(
                            S.of(context).streetName,
                            warehouse['streetName'] ?? '',
                          ),
                          context: context,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ] else if (warehouseEnabled) ...[
          // No warehouses found but enabled
          Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.sp),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.orange, size: 20.sp),
                  SizedBox(width: 8.sp),
                  Text(
                    "Warehouses are enabled but no warehouse data found",
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // Warehouses disabled
          SizedBox(),

          // Container(
          //   decoration: BoxDecoration(
          //       color: Colors.grey.shade100,
          //       borderRadius: BorderRadius.circular(8.r)
          //   ),
          //   child: Padding(
          //     padding: EdgeInsets.all(20.sp),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(Icons.warehouse_outlined, color: Colors.grey.shade400, size: 24.sp),
          //         SizedBox(width: 8.sp),
          //         Text(
          //           "Warehouse details disabled for this supplier",
          //           style: StyleText.fontSize14Weight400.copyWith(color: Colors.grey.shade500),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return StorageTextField(
      label: label,
      controller: TextEditingController(text: value),
      readOnly: true,
      multiline: true,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) {},
    );
  }

  Widget contractStartDateField() {
    return StorageTextField(
      label: S.of(context).contractStartDate,
      controller: TextEditingController(text: selectStartDate ?? ""),
      readOnly: true,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget contractEndDateField() {
    return StorageTextField(
      label: S.of(context).contractEndDate,
      controller: TextEditingController(text: selectEndDate ?? ""),
      readOnly: true,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  //////////////////////////////// Supplier Details  ////////////////////////////////////

  Widget supplierIdField() => StorageTextField(
        label: S.of(context).supplierId,
        controller: supplierIdController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget supplierNameField() => StorageTextField(
        label: S.of(context).supplierName,
        controller: supplierNameController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget businessTypeField() => StorageTextField(
        label: S.of(context).businessType,
        controller: businessTypeController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget taxNumberField() => StorageTextField(
        label: S.of(context).taxNumber,
        controller: taxNumberController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget businessRegistrationField() => StorageTextField(
        label: S.of(context).businessRegistrationNumber,
        controller: businessRegistrationController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget supplierBankFiled() {
    return StorageDropdown<String>(
      label: S.of(context).supplierRank,
      hint: S.of(context).supplierRank,
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
    );
  }

  Widget createdByField() => StorageTextField(
        label: S.of(context).createdBy,
        controller: createdByController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget dateAddedField() => StorageTextField(
        label: S.of(context).dateAdded,
        controller: dateAddedController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  //////////////////////////////// Supplier Details  ////////////////////////////////////

  //////////////////////////////// Contact Details  ////////////////////////////////////

  Widget firstNameField() => StorageTextField(
        label: S.of(context).firstName,
        controller: firstNameController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget middleNameField() => StorageTextField(
        label: S.of(context).middleName,
        controller: middleNameController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget lastNameField() => StorageTextField(
        label: S.of(context).lastName,
        controller: lastNameController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget titleField() => StorageTextField(
        label: S.of(context).title,
        controller: titleController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget phoneNumberField() => StorageTextField(
        label: S.of(context).phoneNumber,
        controller: phoneNumberController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget faxNumberField() => StorageTextField(
        label: S.of(context).faxNumber,
        controller: faxNumberController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget emailField() => StorageTextField(
        label: S.of(context).email,
        controller: emailController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget preferredLanguageField() => StorageTextField(
        label: S.of(context).preferredLanguage,
        controller: preferredLanguageController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  //////////////////////////////// Contact Details  ////////////////////////////////////

  //////////////////////////////// Bank Transfer ////////////////////////////////////

  Widget beneficiaryNameField() => StorageTextField(
        label: S.of(context).beneficiaryName,
        controller: beneficiaryNameController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget beneficiaryBankNameField() => StorageTextField(
        label: S.of(context).beneficiaryBankName,
        controller: beneficiaryBankNameController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget beneficiaryBankAccountNumberField() {
    return StorageTextField(
      label: S.of(context).beneficiaryBankName,
      controller: beneficiaryBankNameController,
      readOnly: true,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget ibanField() => StorageTextField(
        label: S.of(context).iban,
        controller: iBANController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget bankAddressField() => StorageTextField(
        label: S.of(context).bankAddress,
        controller: bankAddressController,
        readOnly: true,
        multiline: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  //////////////////////////////// Bank Transfer ////////////////////////////////////

  //////////////////////////////// Address Details ////////////////////////////////////

  Widget countryField() => StorageTextField(
        label: S.of(context).country,
        controller: countryController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget stateOrProvinceField() => StorageTextField(
        label: S.of(context).state,
        controller: stateOrProvinceController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget cityField() => StorageTextField(
        label: S.of(context).city,
        controller: cityController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget postalCodeField() => StorageTextField(
        label: S.of(context).postalCode,
        controller: postalCodeController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget streetNameField() => StorageTextField(
        label: S.of(context).description,
        controller: streetNameController,
        readOnly: true,
        multiline: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  //////////////////////////////// Address Details ////////////////////////////////////

  //////////////////////////////// Warehouse Fields ////////////////////////////////////

  Widget warehouseNameField() => StorageTextField(
        label: S.of(context).warehouseName,
        controller: wareHouseNameController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget warehouseCountryField() => StorageTextField(
        label: S.of(context).country,
        controller: countryWareHouseController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget warehouseStateField() => StorageTextField(
        label: S.of(context).stateOrProvince,
        controller: stateOrProvinceWareHouseController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget warehouseCityField() => StorageTextField(
        label: S.of(context).city,
        controller: cityWareHouseController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget warehousePostalCodeField() => StorageTextField(
        label: S.of(context).postalCode,
        controller: postalCodeWareHouseController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget warehouseStreetNameField() => StorageTextField(
        label: S.of(context).streetName,
        controller: streetNameWareHouseController,
        readOnly: true,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  //////////////////////////////// Warehouse Fields ////////////////////////////////////

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

  Widget buildImageContainer({
    String? imageUrl,
    String documentType = "Document",
  }) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return GestureDetector(
      onTapDown: hasImage ? (_) => HapticController.low() : null,
      onTap: hasImage ? () => _showImagePreview(imageUrl, documentType) : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: lightMode ? Color(0xffB5B4B4) : AppColors.grey,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.sp),
          child: Row(
            children: [
              // Image preview - Show actual image thumbnail
              Container(
                width: 36.sp,
                height: 36.sp,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 16.sp,
                                height: 16.sp,
                                child: CircleProgressMaster.inline(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.broken_image,
                                color: AppColors.grey,
                                size: 20.sp,
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade100,
                        child: Icon(
                          Icons.insert_drive_file,
                          color: AppColors.grey,
                          size: 20.sp,
                        ),
                      ),
              ),

              SizedBox(width: 10.sp),

              // Document info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasImage
                          ? "$documentType.png"
                          : "No $documentType uploaded",
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.sp),
                    Text(
                      hasImage ? "Image file" : "0 KB",
                      style: StyleText.fontSize12Weight500.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              // View icon (if image exists)
            ],
          ),
        ),
      ),
    );
  }

  // Your _showImagePreview method is already good, here's a slightly enhanced version:
  void _showImagePreview(String imageUrl, String title) {
    showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width *
                0.9, // Take 90% of screen width
            margin: EdgeInsets.all(20.sp),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity, // Full width header
                  padding: EdgeInsets.all(16.sp),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.image,
                        color: AppColors.textButton,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: Text(
                          title,
                          style: StyleText.fontSize16Weight600.copyWith(
                            color: AppColors.textButton,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTapDown: (_) => HapticController.high(),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(4.sp),
                          child: Icon(
                            Icons.close,
                            color: AppColors.textButton,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Image - Full width
                Container(
                  width: double.infinity, // Full width container
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12.r),
                      bottomRight: Radius.circular(12.r),
                    ),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity, // Full width image
                      fit: BoxFit.cover, // Cover the entire width
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          width: double.infinity,
                          height: 200.sp,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleProgressMaster.inline(
                                  color: AppColors.primary,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                                SizedBox(height: 16.sp),
                                Text(
                                  "Loading image...",
                                  style: StyleText.fontSize14Weight400
                                      .copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200.sp,
                          padding: EdgeInsets.all(20.sp),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48.sp,
                                color: AppColors.red,
                              ),
                              SizedBox(height: 16.sp),
                              Text(
                                "Failed to load image",
                                style: StyleText.fontSize14Weight400
                                    .copyWith(color: Colors.red),
                              ),
                              SizedBox(height: 8.sp),
                              Text(
                                "Please check your internet connection",
                                style: StyleText.fontSize12Weight400
                                    .copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
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

  //////////////////////////////// Navigate Page //////////////////////////

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

  ////////////////////////////// Dialog Verify  //////////////////////////////
}

class ViewSupplierDetailsDebugHelpers {
  // Method to validate ProductModel data
  static void validateProductModel(ProductModel product, String context) {
    debugPrint("🔍 Validating ProductModel in $context:");
    debugPrint(
      "  ✓ Product ID: '${product.productId.value}' (${product.productId.value.isEmpty ? 'EMPTY' : 'OK'})",
    );
    debugPrint(
      "  ✓ Order ID: '${product.orderId.value}' (${product.orderId.value.isEmpty ? 'EMPTY' : 'OK'})",
    );
    debugPrint(
      "  ✓ Supplier ID: '${product.supplierId.value}' (${product.supplierId.value.isEmpty ? 'EMPTY' : 'OK'})",
    );
    debugPrint(
      "  ✓ Supplier Name: '${product.supplierName.value}' (${product.supplierName.value.isEmpty ? 'EMPTY' : 'OK'})",
    );
    debugPrint(
      "  ✓ Product Name: '${product.productName.value}' (${product.productName.value.isEmpty ? 'EMPTY' : 'OK'})",
    );
    debugPrint(
      "  ✓ Status: '${product.status.value}' (${product.status.value.isEmpty ? 'EMPTY' : 'OK'})",
    );
    debugPrint(
      "  ✓ Order Date: '${product.orderDate.value}' (${product.orderDate.value.isEmpty ? 'EMPTY' : 'OK'})",
    );
    debugPrint(
      "  ✓ Quantity: '${product.quantity.value}' (${product.quantity.value.isEmpty ? 'EMPTY' : 'OK'})",
    );
  }

  // Method to check data before navigation
  static bool canNavigateToOrderDetails(ProductModel product) {
    bool hasOrderId = product.orderId.value.isNotEmpty;
    bool hasProductId = product.productId.value.isNotEmpty;
    bool hasSupplierData = product.supplierId.value.isNotEmpty ||
        product.supplierName.value.isNotEmpty;

    debugPrint("🔍 Navigation Check:");
    debugPrint("  - Has Order ID: $hasOrderId");
    debugPrint("  - Has Product ID: $hasProductId");
    debugPrint("  - Has Supplier Data: $hasSupplierData");
    debugPrint("  - Can Navigate: ${hasOrderId && hasProductId}");

    return hasOrderId && hasProductId;
  }

  // Method to validate orders list
  static void validateOrdersList(List<ProductModel> orders, String context) {
    debugPrint("🔍 Validating Orders List in $context:");
    debugPrint("  - Total orders: ${orders.length}");

    if (orders.isEmpty) {
      debugPrint("  ⚠️ No orders found!");
      return;
    }

    for (int i = 0; i < orders.length; i++) {
      debugPrint("  - Order ${i + 1}:");
      debugPrint("    • Order ID: '${orders[i].orderId.value}'");
      debugPrint("    • Supplier: '${orders[i].supplierName.value}'");
      debugPrint("    • Status: '${orders[i].status.value}'");
    }
  }
}

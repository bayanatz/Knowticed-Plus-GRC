import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/widgets/storage_location_form_kit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/pages/add_new_supplier.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/pages/add_new_supplier_second.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/pages/add_new_supplier_third.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/widgets/add_new_supplier_third/draft.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:knowticed_plus/features/inventory/helpers/constants/constant_lists.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class EditSupplierDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? supplierData;

  const EditSupplierDetailsScreen({super.key, this.supplierData});

  @override
  State<EditSupplierDetailsScreen> createState() =>
      _EditSupplierDetailsScreenState();
}

class _EditSupplierDetailsScreenState extends State<EditSupplierDetailsScreen> {
  final ImagePicker _picker = ImagePicker();
  File? supplierImageFile;
  String? supplierImageUrl;

  // Add image picker method
  Future<void> _pickSupplierImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        supplierImageFile = File(picked.path);
      });
    }
  }

  // Add file handling variables
  String? contractDocumentUrl;
  String? taxCertificateUrl;
  String? registrationDocumentUrl;

  File? contractDocumentFile;
  File? taxCertificateFile;
  File? registrationDocumentFile;

  //////////////////////////////////// Enhanced Fill Data //////////////////////////
  // Replace your fillForm method in EditSupplierDetailsScreen with this debug version:

  void fillForm(Map<String, dynamic> data) {
    debugPrint("🔍 DEBUG: fillForm called with data:");
    debugPrint("Data keys: ${data.keys.toList()}");
    debugPrint("Full data: $data");

    // Basic supplier information
    debugPrint("Setting supplier ID: ${data["supplierId"]}");
    supplierIdController.text = data["supplierId"] ?? "";
    supplierNameController.text = data["supplierName"] ?? "";
    businessTypeController.text = data["businessType"] ?? "";
    taxNumberController.text = data["taxNumber"] ?? "";
    businessRegistrationController.text =
        data["businessRegistrationNumber"] ?? "";
    // createdByController.text = data["createdBy"] ?? "";
    // dateAddedController.text = data["dateAdded"] ?? "";

    // Add this line to get the supplier image URL
    supplierImageUrl = data["imageSupplier"] ?? "";
    debugPrint("Supplier Image URL: '$supplierImageUrl'");

    debugPrint(
      "After basic info - Supplier Name Controller: '${supplierNameController.text}'",
    );

    // ... rest of your existing fillForm code ...

    // Contact information
    debugPrint("Contact data: ${data['contact']}");
    if (data['contact'] != null) {
      var contactData = data['contact'];
      firstNameController.text = contactData["firstName"] ?? "";
      middleNameController.text = contactData["middleName"] ?? "";
      lastNameController.text = contactData["lastName"] ?? "";
      titleController.text = contactData["title"] ?? "";
      phoneNumberController.text = contactData["phoneNumber"] ?? "";
      faxNumberController.text = contactData["fax"] ?? "";
      emailController.text = contactData["email"] ?? "";
      preferredLanguageController.text = contactData["preferredLanguage"] ?? "";
      debugPrint(
          "Set contact info - First Name: '${firstNameController.text}'");
    }

    // Bank transfer details
    debugPrint("Bank data: ${data['bankTransferDetails']}");
    if (data['bankTransferDetails'] != null) {
      var bankData = data['bankTransferDetails'];
      iBANController.text = bankData["iban"] ?? "";
      bankAddressController.text = bankData["bankAddress"] ?? "";
      beneficiaryBankNameController.text =
          bankData["beneficiaryBankName"] ?? "";
      beneficiaryNameController.text = bankData["beneficiaryName"] ?? "";
      bankSWIFTController.text = bankData["bankSWIFT"] ?? "";
      debugPrint("Set bank info - IBAN: '${iBANController.text}'");
    }

    // Address details
    debugPrint("Address data: ${data['addressDetails']}");
    if (data['addressDetails'] != null) {
      var addressData = data['addressDetails'];
      countryController.text = addressData["country"] ?? "";
      cityController.text = addressData["city"] ?? "";
      streetNameController.text = addressData["streetName"] ?? "";
      stateOrProvinceController.text = addressData["state"] ?? "";
      postalCodeController.text = addressData["postalCode"] ?? "";
      debugPrint("Set address info - Country: '${countryController.text}'");
    }

    // Warehouse details
    debugPrint("Warehouse data: ${data['warehouseDetails']}");
    if (data['warehouseDetails'] != null) {
      var warehouseData = data['warehouseDetails'];
      countryWareHouseController.text = warehouseData["country"] ?? "";
      stateOrProvinceWareHouseController.text =
          warehouseData["stateOrProvince"] ?? "";
      cityWareHouseController.text = warehouseData["city"] ?? "";
      postalCodeWareHouseController.text = warehouseData["postalCode"] ?? "";
      streetNameWareHouseController.text = warehouseData["streetName"] ?? "";
      debugPrint(
        "Set warehouse info - Country: '${countryWareHouseController.text}'",
      );
    }

    // Contract details
    selectStartDate = data["contractStartDate"];
    selectEndDate = data["contractEndDate"];

    // Document URLs
    contractDocumentUrl = data['attachmentsFileUrl'];
    taxCertificateUrl = data['taxCertificateFileUrl'];
    registrationDocumentUrl = data['registrationDocumentFileUrl'];

    // Dropdown selections
    selectedSupplierRank = data["supplierRank"];

    debugPrint("✅ fillForm completed. Final check:");
    debugPrint("Supplier Name: '${supplierNameController.text}'");
    debugPrint("First Name: '${firstNameController.text}'");
    debugPrint("Country: '${countryController.text}'");
    debugPrint("Selected Rank: '$selectedSupplierRank'");
    debugPrint("Supplier Image: '$supplierImageUrl'");

    setState(() {});
  }

  List<ContactFormData> contacts = [ContactFormData()];
  List<AddressFormData> addresses = [AddressFormData()];
  List<WarehouseFormData> warehouses = [WarehouseFormData()];
  bool isLoadingSubCollections = false;

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
  String? selectedBusinessType;

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

  //////////////////////////// hide And Expand ////////////////////////////

  bool showSupplierDetails = true;
  bool showContactDetails = true;
  bool showBankDetails = true;
  bool showAddressDetails = true;
  bool showContractDetails = true;
  bool createBarCode = false;

  //////////////////////////// hide And Expand ////////////////////////////

  int selectedSection = 0; // 0 = Supplier Details, 1 = Orders History

  // Update your initState method in EditSupplierDetailsScreen:

  @override
  void initState() {
    super.initState();

    debugPrint("🚀 EditSupplierDetailsScreen initState called");
    debugPrint("Widget supplier data: ${widget.supplierData}");

    if (widget.supplierData != null) {
      debugPrint("📝 Calling fillForm with data");
      fillForm(widget.supplierData!);

      // Load sub-collections data
      _loadSubCollectionsData();
    } else {
      debugPrint("⚠️ No supplier data provided to EditSupplierDetailsScreen");
    }
  }

  ////////////////////////// New Value //////////////////////
  Future<void> _loadSubCollectionsData() async {
    if (widget.supplierData == null || supplierIdController.text.isEmpty) {
      debugPrint("No supplier ID available for loading sub-collections");
      return;
    }

    setState(() {
      isLoadingSubCollections = true;
    });

    try {
      final supplierData = await SupplierDraftStore.instance
          .readSupplierFromFirebase(supplierId: supplierIdController.text);

      if (supplierData != null) {
        _loadContactsFromFirebase(supplierData['contacts'] ?? []);
        _loadAddressesFromFirebase(supplierData['addresses'] ?? []);
        _loadWarehousesFromFirebase(supplierData['warehouses'] ?? []);
      }
    } catch (e) {
      debugPrint("Error loading sub-collections: $e");
    } finally {
      setState(() {
        isLoadingSubCollections = false;
      });
    }
  }

  // Load contacts from Firebase data
  void _loadContactsFromFirebase(List<dynamic> contactsData) {
    contacts.clear();

    if (contactsData.isEmpty) {
      // If no contacts in sub-collection, use main contact data
      contacts.add(ContactFormData());
      return;
    }

    for (var contactData in contactsData) {
      final contact = ContactFormData();
      contact.firstNameController.text = contactData['firstName'] ?? '';
      contact.middleNameController.text = contactData['middleName'] ?? '';
      contact.lastNameController.text = contactData['lastName'] ?? '';
      contact.titleController.text = contactData['title'] ?? '';
      contact.phoneNumberController.text = contactData['phoneNumber'] ?? '';
      contact.faxNumberController.text = contactData['faxNumber'] ?? '';
      contact.emailController.text = contactData['email'] ?? '';
      contact.preferredLanguageController.text =
          contactData['preferredLanguage'] ?? '';
      contacts.add(contact);
    }

    // Update the main controllers with first contact data
    if (contacts.isNotEmpty) {
      firstNameController.text = contacts[0].firstNameController.text;
      middleNameController.text = contacts[0].middleNameController.text;
      lastNameController.text = contacts[0].lastNameController.text;
      titleController.text = contacts[0].titleController.text;
      phoneNumberController.text = contacts[0].phoneNumberController.text;
      faxNumberController.text = contacts[0].faxNumberController.text;
      emailController.text = contacts[0].emailController.text;
      preferredLanguageController.text =
          contacts[0].preferredLanguageController.text;
    }

    debugPrint("✅ Loaded ${contacts.length} contacts from Firebase");
  }

  // Load addresses from Firebase data
  void _loadAddressesFromFirebase(List<dynamic> addressesData) {
    addresses.clear();

    if (addressesData.isEmpty) {
      addresses.add(AddressFormData());
      return;
    }

    for (var addressData in addressesData) {
      final address = AddressFormData();
      address.countryController.text = addressData['country'] ?? '';
      address.stateOrProvinceController.text =
          addressData['stateOrProvince'] ?? '';
      address.cityController.text = addressData['city'] ?? '';
      address.postalCodeController.text = addressData['postalCode'] ?? '';
      address.streetNameController.text = addressData['streetName'] ?? '';
      address.warehouseAddressController.text =
          addressData['warehouseAddress'] ?? '';
      addresses.add(address);
    }

    // Update main controllers with first address data
    if (addresses.isNotEmpty) {
      countryController.text = addresses[0].countryController.text;
      stateOrProvinceController.text =
          addresses[0].stateOrProvinceController.text;
      cityController.text = addresses[0].cityController.text;
      postalCodeController.text = addresses[0].postalCodeController.text;
      streetNameController.text = addresses[0].streetNameController.text;
    }

    debugPrint("✅ Loaded ${addresses.length} addresses from Firebase");
  }

  // Load warehouses from Firebase data
  void _loadWarehousesFromFirebase(List<dynamic> warehousesData) {
    warehouses.clear();

    if (warehousesData.isEmpty) {
      warehouses.add(WarehouseFormData());
      return;
    }

    for (var warehouseData in warehousesData) {
      final warehouse = WarehouseFormData();
      warehouse.countryController.text = warehouseData['country'] ?? '';
      warehouse.stateOrProvinceController.text =
          warehouseData['stateOrProvince'] ?? '';
      warehouse.cityController.text = warehouseData['city'] ?? '';
      warehouse.postalCodeController.text = warehouseData['postalCode'] ?? '';
      warehouse.streetNameController.text = warehouseData['streetName'] ?? '';
      warehouses.add(warehouse);
    }

    // Update main warehouse controllers with first warehouse data
    if (warehouses.isNotEmpty) {
      countryWareHouseController.text = warehouses[0].countryController.text;
      stateOrProvinceWareHouseController.text =
          warehouses[0].stateOrProvinceController.text;
      cityWareHouseController.text = warehouses[0].cityController.text;
      postalCodeWareHouseController.text =
          warehouses[0].postalCodeController.text;
      streetNameWareHouseController.text =
          warehouses[0].streetNameController.text;
    }

    debugPrint("✅ Loaded ${warehouses.length} warehouses from Firebase");
  }

  // Add contact management methods
  void _addNewContact() {
    setState(() {
      contacts.add(ContactFormData());
    });
  }

  void _removeContact(int index) {
    if (contacts.length > 1) {
      setState(() {
        contacts[index].dispose();
        contacts.removeAt(index);
      });
    }
  }

  // Add address management methods
  void _addNewAddress() {
    setState(() {
      addresses.add(AddressFormData());
    });
  }

  void _removeAddress(int index) {
    if (addresses.length > 1) {
      setState(() {
        addresses[index].dispose();
        addresses.removeAt(index);
      });
    }
  }

  // Add warehouse management methods
  void _addNewWarehouse() {
    setState(() {
      warehouses.add(WarehouseFormData());
    });
  }

  void _removeWarehouse(int index) {
    if (warehouses.length > 1) {
      setState(() {
        warehouses[index].dispose();
        warehouses.removeAt(index);
      });
    }
  }
  ////////////////////////// New Value //////////////////////

  /////////////////////////////// Dummy Data ///////////////////////////////////////////////////////////////

  final List<Map<String, dynamic>> purchaseOrders = [
    {
      "orderId": "011",
      "numberOfProducts": 1,
      "productNames": ["iPhone"],
      "supplierName": "Mohamed Ahmed",
      "quantity": [10],
      "orderDate": "28 Oct 2024",
      "receivingDate": "25 Feb 2024",
      "type": "Asset",
      "category": "Electronics",
      "subcategory": "Smartphones",
      "brand": "Apple",
      "model": "iPhone 14",
      "unitCost": 1200.0,
      "currency": "USD",
      "Status": "Received",
      "CreatedBy": "Amr Mesbah",
    },
    {
      "orderId": "022",
      "numberOfProducts": 1,
      "productNames": ["iPhone"],
      "supplierName": "Mohamed Ahmed",
      "quantity": [10],
      "orderDate": "28 Oct 2024",
      "receivingDate": "25 Feb 2024",
      "type": "Consumable",
      "category": "Accessories",
      "subcategory": "Chargers",
      "brand": "Apple",
      "model": "MagSafe",
      "unitCost": 45.0,
      "currency": "USD",
      "usageFrequency": "Monthly",
      "unitOfMeasurement": "Pack",
      "Status": "Cancelled",
      "CreatedBy": "Omar Ali",
    },
    {
      "orderId": "033",
      "numberOfProducts": 1,
      "productNames": ["iPhone"],
      "supplierName": "Mohamed Ahmed",
      "quantity": [10],
      "orderDate": "28 Oct 2024",
      "receivingDate": "25 Feb 2024",
      "type": "Hybrid",
      "category": "Devices",
      "subcategory": "Smartphones",
      "brand": "Apple",
      "model": "iPhone 13",
      "unitCost": 1000.0,
      "currency": "USD",
      "usageFrequency": "Weekly",
      "unitOfMeasurement": "Box",
      "Status": "Received",
      "CreatedBy": "Ahmed amr",
    },
    {
      "orderId": "044",
      "numberOfProducts": 1,
      "productNames": ["iPhone"],
      "supplierName": "Mohamed Ahmed",
      "quantity": [10],
      "orderDate": "28 Oct 2024",
      "receivingDate": "25 Feb 2024",
      "type": "Asset",
      "category": "Electronics",
      "subcategory": "Smartphones",
      "brand": "Apple",
      "model": "iPhone 12",
      "unitCost": 900.0,
      "currency": "USD",
      "Status": "Open",
      "CreatedBy": "Nader amr",
    },
    {
      "orderId": "055",
      "numberOfProducts": 2,
      "productNames": ["iPhone", "GZ15"],
      "supplierName": "Mohamed Ahmed",
      "quantity": [10, 20],
      "orderDate": "28 Oct 2024",
      "receivingDate": "25 Feb 2024",
      "type": "Consumable",
      "category": "Mixed",
      "subcategory": "Various",
      "brand": "Apple / Generic",
      "model": "iPhone 14 / GZ15",
      "unitCost": 1200.0,
      "currency": "USD",
      "usageFrequency": "Daily",
      "unitOfMeasurement": "Bundle",
      "Status": "Partially Received",
      "CreatedBy": "Omar amr",
    },
    {
      "orderId": "066",
      "numberOfProducts": 1,
      "productNames": ["iPhone"],
      "supplierName": "Mohamed Ahmed",
      "quantity": [10],
      "orderDate": "28 Oct 2024",
      "receivingDate": "25 Feb 2024",
      "type": "Hybrid",
      "category": "Electronics",
      "subcategory": "Smartphones",
      "brand": "Apple",
      "model": "iPhone 14 Pro",
      "unitCost": 1400.0,
      "currency": "USD",
      "usageFrequency": "Weekly",
      "unitOfMeasurement": "Piece",
      "Status": "Received",
      "CreatedBy": "Ali amr",
    },
    {
      "orderId": "077",
      "numberOfProducts": 1,
      "productNames": ["iPad"],
      "supplierName": "Ali Hassan",
      "quantity": [5],
      "orderDate": "01 Nov 2024",
      "receivingDate": "10 Mar 2024",
      "type": "Asset",
      "category": "Tablets",
      "subcategory": "iOS",
      "brand": "Apple",
      "model": "iPad Air",
      "unitCost": 800.0,
      "currency": "USD",
      "Status": "Received",
      "CreatedBy": "Tamer amr",
    },
    {
      "orderId": "088",
      "numberOfProducts": 1,
      "productNames": ["MacBook"],
      "supplierName": "Ali Hassan",
      "quantity": [3],
      "orderDate": "15 Nov 2024",
      "receivingDate": "01 Apr 2024",
      "type": "Asset",
      "category": "Computers",
      "subcategory": "Laptops",
      "brand": "Apple",
      "model": "MacBook Pro",
      "unitCost": 2200.0,
      "currency": "USD",
      "Status": "Received",
      "CreatedBy": "Omar amr",
    },
    {
      "orderId": "099",
      "numberOfProducts": 1,
      "productNames": ["AirPods"],
      "supplierName": "Omar Ali",
      "quantity": [15],
      "orderDate": "20 Nov 2024",
      "receivingDate": "15 Apr 2024",
      "type": "Consumable",
      "category": "Accessories",
      "subcategory": "Earphones",
      "brand": "Apple",
      "model": "AirPods Pro",
      "unitCost": 250.0,
      "currency": "USD",
      "usageFrequency": "Bi-weekly",
      "unitOfMeasurement": "Box",
      "Status": "Received",
      "CreatedBy": "Yasser amr",
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    Localizations.localeOf(context).languageCode == 'ar';
    final isMobile = context.isPhone;
    Localizations.localeOf(context).languageCode == 'en';
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventoryManagement,
          onFirstTap: () {
            Navigator.pop(context);
          },
          secondTitle: S.of(context).editingSupplierDetails,
          onSecondTap: () {
            Navigator.pop(context);
          },
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                // space
                SizedBox(height: 30.sp),

                if (selectedSection == 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      customButton(
                        title: S.of(context).delete,
                        function: () {
                          showConfirmationDialog(
                            lottiePath:
                                'assets/lottie_assets/main_lottie_assets/lot_action_delete_role.json', // Use your delete warning animation
                            title: S.of(context).deleteSupplier,
                            message: S.of(context).confirmDeleteSupplier,
                            onConfirm: _deleteSupplier,
                          );
                        },
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: Colors.white,
                        ),
                        width: 135.sp,
                        height: 38.sp,
                        radius: 8.r,
                        color: Colors.red, // Red color for delete
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

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
                          children: [
                            Text(
                              showSupplierDetails
                                  ? S.of(context).hide
                                  : S.of(context).expand,
                              style: StyleText.fontSize14Weight500.copyWith(
                                color: Color(0xff1877F2),
                              ),
                            ),
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
                            // Photo + camera badge (Figma 4307:27702).
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: buildSupplierImageWidget(),
                            ),
                            SizedBox(height: 15.sp),
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
                              left: businessTypeDropDown(),
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
                            // buildResponsiveFields(
                            //     left: createdByField(),
                            //     right: dateAddedField(),
                            //     context: context
                            // ),
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
                          children: [
                            Text(
                              showContactDetails
                                  ? S.of(context).hide
                                  : S.of(context).expand,
                              style: StyleText.fontSize14Weight500.copyWith(
                                color: Color(0xff1877F2),
                              ),
                            ),
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
                          children: [
                            Text(
                              showBankDetails
                                  ? S.of(context).hide
                                  : S.of(context).expand,
                              style: StyleText.fontSize14Weight500.copyWith(
                                color: Color(0xff1877F2),
                              ),
                            ),
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
                          children: [
                            Text(
                              showAddressDetails
                                  ? S.of(context).hide
                                  : S.of(context).expand,
                              style: StyleText.fontSize14Weight500.copyWith(
                                color: Color(0xff1877F2),
                              ),
                            ),
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
                  SizedBox(height: 26.sp),

                  // Warehouses Details
                  buildWarehousesSection(lightMode),

                  //space
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
                        child: Column(
                          children: [
                            Text(
                              showContractDetails
                                  ? S.of(context).hide
                                  : S.of(context).expand,
                              style: StyleText.fontSize14Weight500.copyWith(
                                color: Color(0xff1877F2),
                              ),
                            ),
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

                  // Contract Details
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: AppColors.card,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15.sp),
                      child: Column(
                        children: [
                          // Contract Start Date  &  Contract End Date
                          buildResponsiveFields(
                            left: contractStartDateField(),
                            right: contractEndDateField(),
                            context: context,
                          ),

                          // space
                          SizedBox(height: 15.sp),

                          // Contract Document  &  Tax Certificate
                          // Replace your contract details section in the build method:
                          isMobile
                              ? Column(
                                  children: [
                                    // Contract Document
                                    Column(
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
                                          imageFile: contractDocumentFile,
                                          documentType: "Contract Document",
                                          fileType: "contract",
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15.sp),
                                    // Tax Certificate
                                    Column(
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
                                          imageFile: taxCertificateFile,
                                          documentType: "Tax Certificate",
                                          fileType: "tax",
                                        ),
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
                                            imageFile: contractDocumentFile,
                                            documentType: "Contract Document",
                                            fileType: "contract",
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 15.sp),
                                    // Tax Certificate
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
                                            imageFile: taxCertificateFile,
                                            documentType: "Tax Certificate",
                                            fileType: "tax",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ],

                //space
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

                    // ✅ save
                    customButton(
                      title: S.of(context).save,
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

                //space
                SizedBox(height: 20.sp),
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

  Future<void> _deleteSupplier() async {
    try {
      debugPrint(
        "🗑️ Starting delete process for supplier: ${supplierIdController.text}",
      );

      // Show loading indicator (optional)
      final bool success = await SupplierDraftStore.instance
          .deleteSupplierFromFirebase(supplierId: supplierIdController.text);

      if (success) {
        // Show success dialog
        if (!mounted) return;
        await showSuccessDialog(
          lottiePath:
              'assets/lottie_assets/main_lottie_assets/lot_status_approved.json', // Use your delete success animation
          title: S.of(context).supplierDeleted,
          subtitle: S.of(context).successfullyDeletedSupplier,
        );

        // Navigate to home page
        Get.offAll(() => InventoryManagement());
      } else {
        // Show error dialog
        _showErrorDialog("Failed to delete supplier. Please try again.");
      }
    } catch (e) {
      debugPrint('❌ Error deleting supplier: $e');
      _showErrorDialog("An error occurred while deleting the supplier: $e");
    }
  }

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
                  lottiePath,
                  width: 70.sp,
                  height: 70.sp,
                  fit: BoxFit.scaleDown,
                  repeat: true,
                  animate: true,
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

  /// Supplier photo — Figma 4307:27702 (65 circle + 24 camera badge).
  /// A newly picked file wins over the saved URL.
  Widget buildSupplierImageWidget() {
    Widget? image;
    if (supplierImageFile != null) {
      image = Image.file(supplierImageFile!, fit: BoxFit.cover);
    } else if (supplierImageUrl != null && supplierImageUrl!.isNotEmpty) {
      image = Image.network(
        supplierImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }
    return CirclePhotoPicker(onTap: _pickSupplierImage, image: image);
  }

  Widget buildContactsSection(bool lightMode) {
    return Column(
      children: [
        // First Contact (Main Contact)
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
                  buildResponsiveFields(
                    left: firstNameFieldForContact(contacts[0]),
                    right: middleNameFieldForContact(contacts[0]),
                    context: context,
                  ),
                  SizedBox(height: 15.sp),
                  buildResponsiveFields(
                    left: lastNameFieldForContact(contacts[0]),
                    right: titleFieldForContact(contacts[0]),
                    context: context,
                  ),
                  SizedBox(height: 15.sp),
                  buildResponsiveFields(
                    left: phoneNumberFieldForContact(contacts[0]),
                    right: faxNumberFieldForContact(contacts[0]),
                    context: context,
                  ),
                  SizedBox(height: 15.sp),
                  buildResponsiveFields(
                    left: emailFieldForContact(contacts[0]),
                    right: preferredLanguageFieldForContact(contacts[0]),
                    context: context,
                  ),
                ],
              ),
            ),
          ),

        // Additional Contacts
        if (showContactDetails)
          ...contacts.skip(1).toList().asMap().entries.map((entry) {
            int actualIndex = entry.key + 1;
            ContactFormData contact = entry.value;
            return Column(
              children: [
                SizedBox(height: 20.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${actualIndex + 1}${actualIndex == 0 ? 'st' : actualIndex == 1 ? 'nd' : actualIndex == 2 ? 'rd' : 'th'} ${S.of(context).contact} Details",
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTapDown: (_) => HapticController.high(),
                      onTap: () => _removeContact(actualIndex),
                      child: Container(
                        width: 15.w,
                        height: 15.h,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.remove,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                  ],
                ),
                SizedBox(height: 8.sp),
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
                          left: firstNameFieldForContact(contact),
                          right: middleNameFieldForContact(contact),
                          context: context,
                        ),
                        SizedBox(height: 15.sp),
                        buildResponsiveFields(
                          left: lastNameFieldForContact(contact),
                          right: titleFieldForContact(contact),
                          context: context,
                        ),
                        SizedBox(height: 15.sp),
                        buildResponsiveFields(
                          left: phoneNumberFieldForContact(contact),
                          right: faxNumberFieldForContact(contact),
                          context: context,
                        ),
                        SizedBox(height: 15.sp),
                        buildResponsiveFields(
                          left: emailFieldForContact(contact),
                          right: preferredLanguageFieldForContact(contact),
                          context: context,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),

        SizedBox(height: 8.sp),

        // Add Contact Button
        Row(
          children: [
            customButtonWithSvg(
              title: S.of(context).contact,
              function: _addNewContact,
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppTheme.readableOn(AppColors.blackButton),
              ),
              width: 100.sp,
              height: 30.sp,
              space: 8.sp,
              radius: 4.r,
              svgColor: AppTheme.readableOn(AppColors.blackButton),
              color: AppColors.blackButton,
              image: "assets/icons_assets/main_icons_assets/ic_action_plus.svg",
              widthImage: 12.sp,
              heightImage: 12.sp,
              colorBorder: Colors.transparent,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickFile(String fileType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        setState(() {
          switch (fileType) {
            case 'contract':
              contractDocumentFile = file;
              break;
            case 'tax':
              taxCertificateFile = file;
              break;
            case 'registration':
              registrationDocumentFile = file;
              break;
          }
        });
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  Widget contractStartDateField() {
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

  Widget contractEndDateField() {
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
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
  }

  Widget firstNameFieldForContact(ContactFormData contact) => StorageTextField(
        label: S.of(context).firstName,
        controller: contact.firstNameController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget middleNameFieldForContact(ContactFormData contact) => StorageTextField(
        label: S.of(context).middleName,
        controller: contact.middleNameController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget lastNameFieldForContact(ContactFormData contact) => StorageTextField(
        label: S.of(context).lastName,
        controller: contact.lastNameController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget titleFieldForContact(ContactFormData contact) => StorageTextField(
        label: S.of(context).title,
        controller: contact.titleController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget phoneNumberFieldForContact(ContactFormData contact) =>
      StorageTextField(
        label: S.of(context).phoneNumber,
        controller: contact.phoneNumberController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget faxNumberFieldForContact(ContactFormData contact) => StorageTextField(
        label: S.of(context).faxNumber,
        controller: contact.faxNumberController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget emailFieldForContact(ContactFormData contact) => StorageTextField(
        label: S.of(context).email,
        controller: contact.emailController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget preferredLanguageFieldForContact(ContactFormData contact) =>
      StorageTextField(
        label: S.of(context).preferredLanguage,
        controller: contact.preferredLanguageController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget buildAddressesSection(bool lightMode) {
    return Column(
      children: [
        // First Address (Main Address)
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
                  buildResponsiveFields(
                    left: countryFieldForAddress(addresses[0]),
                    right: stateOrProvinceFieldForAddress(addresses[0]),
                    context: context,
                  ),
                  SizedBox(height: 15.sp),
                  buildResponsiveFields(
                    left: cityFieldForAddress(addresses[0]),
                    right: postalCodeFieldForAddress(addresses[0]),
                    context: context,
                  ),
                  SizedBox(height: 15.sp),
                  Row(
                    children: [
                      Expanded(
                        child: StorageTextField(
                          label: S.of(context).description,
                          controller: addresses[0].streetNameController,
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

        // Additional Addresses
        if (showAddressDetails)
          ...addresses.skip(1).toList().asMap().entries.map((entry) {
            int actualIndex = entry.key + 1;
            AddressFormData address = entry.value;
            return Column(
              children: [
                SizedBox(height: 20.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${actualIndex + 1}${actualIndex == 0 ? 'st' : actualIndex == 1 ? 'nd' : actualIndex == 2 ? 'rd' : 'th'} ${S.of(context).address} Details",
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTapDown: (_) => HapticController.high(),
                      onTap: () => _removeAddress(actualIndex),
                      child: Container(
                        width: 15.w,
                        height: 15.h,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.remove,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                  ],
                ),
                SizedBox(height: 8.sp),
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
                          left: countryFieldForAddress(address),
                          right: stateOrProvinceFieldForAddress(address),
                          context: context,
                        ),
                        SizedBox(height: 15.sp),
                        buildResponsiveFields(
                          left: cityFieldForAddress(address),
                          right: postalCodeFieldForAddress(address),
                          context: context,
                        ),
                        SizedBox(height: 15.sp),
                        Row(
                          children: [
                            Expanded(
                              child: StorageTextField(
                                label: S.of(context).streetName,
                                controller: address.streetNameController,
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
              ],
            );
          }),

        SizedBox(height: 8.sp),

        // Add Address Button
        Row(
          children: [
            customButtonWithSvg(
              title: S.of(context).address,
              function: _addNewAddress,
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppTheme.readableOn(AppColors.blackButton),
              ),
              width: 100.sp,
              height: 30.sp,
              space: 8.sp,
              radius: 4.r,
              svgColor: AppTheme.readableOn(AppColors.blackButton),
              color: AppColors.blackButton,
              image: "assets/icons_assets/main_icons_assets/ic_action_plus.svg",
              widthImage: 12.sp,
              heightImage: 12.sp,
              colorBorder: Colors.transparent,
            ),
          ],
        ),
      ],
    );
  }

  Widget countryFieldForAddress(AddressFormData address) => StorageTextField(
        label: S.of(context).country,
        controller: address.countryController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget stateOrProvinceFieldForAddress(AddressFormData address) =>
      StorageTextField(
        label: S.of(context).state,
        controller: address.stateOrProvinceController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget cityFieldForAddress(AddressFormData address) => StorageTextField(
        label: S.of(context).city,
        controller: address.cityController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget postalCodeFieldForAddress(AddressFormData address) => StorageTextField(
        label: S.of(context).postalCode,
        controller: address.postalCodeController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget buildWarehousesSection(bool lightMode) {
    return Column(
      children: [
        // Warehouses Details Header with Switch
        Row(
          children: [
            Text(
              S.of(context).warehousesDetails,
              style: StyleText.fontSize16Weight600.copyWith(
                color: AppColors.blackButton,
              ),
            ),
            Spacer(),
            FlutterSwitch(
              height: 22.0.sp,
              width: 38.0.sp,
              toggleSize: 18.sp,
              value: createBarCode, // This is your warehouse toggle
              borderRadius: 20.sp,
              padding: 1,
              activeColor: AppColors.secondaryPrimary,
              onToggle: (val) {
                setState(() {
                  createBarCode = val;
                });
              },
            ),
          ],
        ),

        SizedBox(height: 10.sp),

        // Show warehouses only if toggle is ON
        if (createBarCode) ...[
          // First Warehouse (Main Warehouse)
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
                    left: warehouseNameFieldForWarehouse(warehouses[0]),
                    right: countryFieldForWarehouse(warehouses[0]),
                    context: context,
                  ),
                  SizedBox(height: 15.sp),
                  buildResponsiveFields(
                    left: stateOrProvinceFieldForWarehouse(warehouses[0]),
                    right: cityFieldForWarehouse(warehouses[0]),
                    context: context,
                  ),
                  SizedBox(height: 15.sp),
                  buildResponsiveFields(
                    left: postalCodeFieldForWarehouse(warehouses[0]),
                    right: streetNameFieldForWarehouse(warehouses[0]),
                    context: context,
                  ),
                ],
              ),
            ),
          ),

          // Additional Warehouses
          ...warehouses.skip(1).toList().asMap().entries.map((entry) {
            int actualIndex = entry.key + 1;
            WarehouseFormData warehouse = entry.value;
            return Column(
              children: [
                SizedBox(height: 20.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${actualIndex + 1}${actualIndex == 0 ? 'st' : actualIndex == 1 ? 'nd' : actualIndex == 2 ? 'rd' : 'th'} ${S.of(context).warehouses} Details",
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTapDown: (_) => HapticController.high(),
                      onTap: () => _removeWarehouse(actualIndex),
                      child: Container(
                        width: 15.w,
                        height: 15.h,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.remove,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                  ],
                ),
                SizedBox(height: 8.sp),
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
                          left: warehouseNameFieldForWarehouse(warehouse),
                          right: countryFieldForWarehouse(warehouse),
                          context: context,
                        ),
                        SizedBox(height: 15.sp),
                        buildResponsiveFields(
                          left: stateOrProvinceFieldForWarehouse(warehouse),
                          right: cityFieldForWarehouse(warehouse),
                          context: context,
                        ),
                        SizedBox(height: 15.sp),
                        buildResponsiveFields(
                          left: postalCodeFieldForWarehouse(warehouse),
                          right: streetNameFieldForWarehouse(warehouse),
                          context: context,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),

          SizedBox(height: 8.sp),

          // Add Warehouse Button
          Row(
            children: [
              customButtonWithSvg(
                title: S.of(context).warehouses,
                function: _addNewWarehouse,
                textStyle: StyleText.fontSize16Weight500.copyWith(
                  color: AppTheme.readableOn(AppColors.blackButton),
                ),
                width: 120.sp,
                height: 30.sp,
                space: 8.sp,
                radius: 4.r,
                svgColor: AppTheme.readableOn(AppColors.blackButton),
                color: AppColors.blackButton,
                image:
                    "assets/icons_assets/main_icons_assets/ic_action_plus.svg",
                widthImage: 12.sp,
                heightImage: 12.sp,
                colorBorder: Colors.transparent,
              ),
            ],
          ),
        ] else ...[
          // // Show disabled state when toggle is OFF
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
          //           "Warehouse details disabled",
          //           style: StyleText.fontSize14Weight400.copyWith(
          //             color: Colors.grey.shade500,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ],
    );
  }

  // Warehouse field methods that accept WarehouseFormData parameter
  Widget warehouseNameFieldForWarehouse(WarehouseFormData warehouse) =>
      StorageTextField(
        label: S.of(context).warehouseName,
        controller: cityController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget countryFieldForWarehouse(WarehouseFormData warehouse) =>
      StorageTextField(
        label: S.of(context).country,
        controller: warehouse.countryController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget stateOrProvinceFieldForWarehouse(WarehouseFormData warehouse) =>
      StorageTextField(
        label: S.of(context).state,
        controller: warehouse.stateOrProvinceController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget cityFieldForWarehouse(WarehouseFormData warehouse) => StorageTextField(
        label: S.of(context).city,
        controller: warehouse.cityController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget postalCodeFieldForWarehouse(WarehouseFormData warehouse) =>
      StorageTextField(
        label: S.of(context).postalCode,
        controller: warehouse.postalCodeController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget streetNameFieldForWarehouse(WarehouseFormData warehouse) =>
      StorageTextField(
        label: S.of(context).streetName,
        controller: warehouse.streetNameController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  @override
  void dispose() {
    // Dispose all contact controllers
    for (var contact in contacts) {
      contact.dispose();
    }

    // Dispose all address controllers
    for (var address in addresses) {
      address.dispose();
    }

    // Dispose all warehouse controllers
    for (var warehouse in warehouses) {
      warehouse.dispose();
    }

    // Keep your existing dispose code...
    super.dispose();
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
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget businessTypeDropDown() {
    return StorageDropdown<String>(
      label: S.of(context).businessType,
      hint: S.of(context).businessType,
      items: (ConstantLists.businessTypeList())
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value: selectedBusinessType,
      onChanged: (value) {
        setState(() {
          selectedBusinessType = value;
        });
      },
    );
  }

  Widget businessTypeField() => StorageTextField(
        label: S.of(context).businessType,
        controller: businessTypeController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget taxNumberField() => StorageTextField(
        label: S.of(context).taxNumber,
        controller: taxNumberController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget businessRegistrationField() => StorageTextField(
        label: S.of(context).businessRegistrationNumber,
        controller: businessRegistrationController,
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
  //
  // Widget createdByField() => CustomValidatedTextFieldMaster(
  //   label: S.of(context).createdBy,
  //   hint: S.of(context).createdBy,
  //   enabled: true,
  //   controller: createdByController,
  //   textDirection: TextDirection.ltr,
  //   onlyDigits: false,
  //   onChanged: (_) => setState(() {}),
  // );
  //
  // Widget dateAddedField() => CustomValidatedTextFieldMaster(
  //   label: S.of(context).dateAdded,
  //   hint: S.of(context).dateAdded,
  //   enabled: true,
  //   controller: dateAddedController,
  //   textDirection: TextDirection.ltr,
  //   onlyDigits: false,
  //   onChanged: (_) => setState(() {}),
  // );

  //////////////////////////////// Supplier Details  ////////////////////////////////////

  //////////////////////////////// Contact Details  ////////////////////////////////////

  Widget firstNameField() => StorageTextField(
        label: S.of(context).firstName,
        controller: firstNameController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget middleNameField() => StorageTextField(
        label: S.of(context).middleName,
        controller: middleNameController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget lastNameField() => StorageTextField(
        label: S.of(context).lastName,
        controller: lastNameController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget titleField() => StorageTextField(
        label: S.of(context).title,
        controller: titleController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget phoneNumberField() => StorageTextField(
        label: S.of(context).phoneNumber,
        controller: phoneNumberController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget faxNumberField() => StorageTextField(
        label: S.of(context).faxNumber,
        controller: faxNumberController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget emailField() => StorageTextField(
        label: S.of(context).email,
        controller: emailController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget preferredLanguageField() => StorageTextField(
        label: S.of(context).preferredLanguage,
        controller: preferredLanguageController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  //////////////////////////////// Contact Details  ////////////////////////////////////

  //////////////////////////////// Bank Transfer ////////////////////////////////////

  Widget beneficiaryNameField() => StorageTextField(
        label: S.of(context).beneficiaryName,
        controller: beneficiaryNameController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget beneficiaryBankNameField() => StorageTextField(
        label: S.of(context).beneficiaryBankName,
        controller: beneficiaryBankNameController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget beneficiaryBankAccountNumberField() {
    return StorageTextField(
      label: S.of(context).beneficiaryBankName,
      controller: beneficiaryBankNameController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget ibanField() => StorageTextField(
        label: S.of(context).iban,
        controller: iBANController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget bankAddressField() => StorageTextField(
        label: S.of(context).bankAddress,
        controller: bankAddressController,
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
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget stateOrProvinceField() => StorageTextField(
        label: S.of(context).state,
        controller: stateOrProvinceController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget cityField() => StorageTextField(
        label: S.of(context).city,
        controller: cityController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget postalCodeField() => StorageTextField(
        label: S.of(context).postalCode,
        controller: postalCodeController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget streetNameField() => StorageTextField(
        label: S.of(context).streetName,
        controller: streetNameController,
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
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget warehouseCountryField() => StorageTextField(
        label: S.of(context).country,
        controller: countryWareHouseController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget warehouseStateField() => StorageTextField(
        label: S.of(context).stateOrProvince,
        controller: stateOrProvinceWareHouseController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget warehouseCityField() => StorageTextField(
        label: S.of(context).city,
        controller: cityWareHouseController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget warehousePostalCodeField() => StorageTextField(
        label: S.of(context).postalCode,
        controller: postalCodeWareHouseController,
        textDirection: ui.TextDirection.ltr,
        onlyDigits: false,
        onChanged: (_) => setState(() {}),
      );

  Widget warehouseStreetNameField() => StorageTextField(
        label: S.of(context).streetName,
        controller: streetNameWareHouseController,
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
    File? imageFile,
    String documentType = "Document",
    String fileType = "",
  }) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool hasImage =
        (imageUrl != null && imageUrl.isNotEmpty) || imageFile != null;

    return GestureDetector(
      onTapDown: hasImage ? (_) => HapticController.low() : null,
      onTap: hasImage
          ? () => _showImagePreview(imageUrl, imageFile, documentType)
          : null,
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
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              // Image & details
              Row(
                children: [
                  // Show actual image or placeholder
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
                            child: imageFile != null
                                ? Image.file(
                                    imageFile,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
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
                              ? (imageFile != null
                                  ? "${documentType}_new.${imageFile.path.split('.').last}"
                                  : "$documentType.png")
                              : "No $documentType uploaded",
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.blackButton,
                          ),
                        ),
                        Text(
                          hasImage
                              ? (imageFile != null
                                  ? "New file selected"
                                  : "Existing file")
                              : "0 KB",
                          style: StyleText.fontSize12Weight500.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Upload/Change button
                  GestureDetector(
                    onTapDown: (_) => HapticController.medium(),
                    onTap: () => _pickFile(fileType),
                    child: Container(
                      padding: EdgeInsets.all(8.sp),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Icon(
                        hasImage ? Icons.edit : Icons.upload,
                        size: 16.sp,
                        color: AppColors.textButton,
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

  void _showImagePreview(String? imageUrl, File? imageFile, String title) {
    showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
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
                  width: double.infinity,
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
                // Image
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12.r),
                      bottomRight: Radius.circular(12.r),
                    ),
                    child: imageFile != null
                        ? Image.file(
                            imageFile,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
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

  Widget buildTab(String label, int index) {
    final isSelected = selectedSection == index;

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
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie_assets/main_lottie_assets/lot_action_edit_document.json',
                width: 100.sp,
                height: 100.sp,
                fit: BoxFit.scaleDown,
                repeat: true, // Set to false if you don't want it to loop
                animate: true, // Set to false to pause the animation
              ),
              //     SizedBox(height: 0.sp),
              Text(
                S.of(context).editingSupplierDetails,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                S.of(context).confirmEditSupplier,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 15.sp),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.sp),
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
                        onTapDown: (_) => HapticController.medium(),
                        onTap: () async {
                          Navigator.pop(
                            context,
                          ); // Close confirmation dialog

                          debugPrint("🔄 Starting save process...");

                          try {
                            await _saveEditedSupplier(); // Actually save the data
                            debugPrint("✅ Save completed successfully");
                          } catch (e) {
                            debugPrint("❌ Save failed: $e");
                            // The _saveEditedSupplier method already handles error display
                          }
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
            width: 320.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
                  width: 70.sp,
                  height: 70.sp,
                  fit: BoxFit.scaleDown,
                  repeat: true,
                  animate: true,
                ),
                SizedBox(height: 20.sp),
                Text(
                  S.of(context).supplierEdited,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  S.of(context).successfullyEditedSupplier,
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

  Future<void> _saveEditedSupplier() async {
    try {
      debugPrint("🚀 _saveEditedSupplier called");

      // Validate required fields
      if (supplierNameController.text.trim().isEmpty) {
        throw Exception("Supplier name is required");
      }

      final draft = SupplierDraftStore.instance;

      // Convert ALL contacts from the form to ContactFormData
      List<ContactFormData> allContacts = contacts.map((contact) {
        final contactData = ContactFormData();
        contactData.firstNameController.text = contact.firstNameController.text;
        contactData.middleNameController.text =
            contact.middleNameController.text;
        contactData.lastNameController.text = contact.lastNameController.text;
        contactData.titleController.text = contact.titleController.text;
        contactData.phoneNumberController.text =
            contact.phoneNumberController.text;
        contactData.faxNumberController.text = contact.faxNumberController.text;
        contactData.emailController.text = contact.emailController.text;
        contactData.preferredLanguageController.text =
            contact.preferredLanguageController.text;
        return contactData;
      }).toList();

      // Convert ALL addresses from the form to AddressFormData
      List<AddressFormData> allAddresses = addresses.map((address) {
        final addressData = AddressFormData();
        addressData.countryController.text = address.countryController.text;
        addressData.stateOrProvinceController.text =
            address.stateOrProvinceController.text;
        addressData.cityController.text = address.cityController.text;
        addressData.postalCodeController.text =
            address.postalCodeController.text;
        addressData.streetNameController.text =
            address.streetNameController.text;
        addressData.warehouseAddressController.text =
            address.warehouseAddressController.text;
        return addressData;
      }).toList();

      // Convert ALL warehouses from the form to WarehouseDraft
      List<WarehouseDraft> allWarehouses = warehouses.map((warehouse) {
        final warehouseDraft = WarehouseDraft();
        warehouseDraft.country = warehouse.countryController.text;
        warehouseDraft.stateOrProvince =
            warehouse.stateOrProvinceController.text;
        warehouseDraft.city = warehouse.cityController.text;
        warehouseDraft.postalCode = warehouse.postalCodeController.text;
        warehouseDraft.streetName = warehouse.streetNameController.text;
        return warehouseDraft;
      }).toList();

      // Set data in draft store - Page 1 (with ALL contacts and supplier image)
      draft.setFromPage1(
        supplierID: supplierIdController.text,
        supplierName: supplierNameController.text,
        businessType: selectedBusinessType!,
        taxNumber: taxNumberController.text,
        businessRegistrationNumber: businessRegistrationController.text,
        supplierRank: selectedSupplierRank ?? '',
        createdBy:
            widget.supplierData?["createdBy"] ?? '', // Use original value
        dateAdded:
            widget.supplierData?["dateAdded"] ?? '', // Use original value
        contacts: allContacts, // ALL contacts
        supplierImageFile: supplierImageFile, // Add supplier image file
      );

      // Also preserve existing image URL if no new image was selected
      if (supplierImageFile == null &&
          supplierImageUrl != null &&
          supplierImageUrl!.isNotEmpty) {
        draft.existingSupplierImageUrl = supplierImageUrl;
      }

      // Set data in draft store - Page 2 (with ALL addresses)
      draft.setFromPage2(
        beneficiaryName: beneficiaryNameController.text,
        beneficiaryBankName: beneficiaryBankNameController.text,
        bankSWIFTBICCode: bankSWIFTController.text,
        beneficiaryBankAccountNumberIBAN: iBANController.text,
        bankAddress: bankAddressController.text,
        addresses: allAddresses, // ALL addresses
      );

      // Set data in draft store - Page 3 (with ALL warehouses)
      // Set data in draft store - Page 3 (with ALL warehouses)
      draft.setFromPage3(
        warehouses: allWarehouses,
        contractStartDate: selectStartDate ?? '',
        contractEndDate: selectEndDate ?? '',
        taxCertificateFile: taxCertificateFile, // ✅ Correct
        contractDocument1File:
            contractDocumentFile, // ✅ Use contractDocument1File
        contractDocument2File:
            registrationDocumentFile, // ✅ Use contractDocument2File
        attachmentFiles: [], // ✅ Pass empty list or actual attachment files if you have them
        existingTaxCertificateUrl: taxCertificateUrl,
        existingRegistrationDocumentUrl: registrationDocumentUrl,
        existingAttachmentsUrl: contractDocumentUrl,
        warehouseEnabled: createBarCode,
      );

      debugPrint(
        "Supplier image to save: ${supplierImageFile != null ? 'New image selected' : 'Using existing: $supplierImageUrl'}",
      );

      // Upload to Firebase
      await draft.uploadAllToFirebase();

      debugPrint(
          '✅ Supplier updated successfully with ALL items including image');

      // Clear and show success
      draft.clear();
      if (!mounted) return;
      await _showSuccessDialog(context);
      Get.offAll(() => InventoryManagement());
    } catch (e) {
      debugPrint('❌ Error saving supplier: $e');
      _showErrorDialog(e.toString());
    }
  }

  // X-17: a message dialog has no OK button and closes by itself after 5 s.
  // [error] is the technical detail; the owner sees the translated message
  // (the caller's own wording when it passes one, else the save failure).
  void _showErrorDialog(String error) {
    CustomDialogManager.showMessage(
      context: context,
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
      title: S.of(context).errorSavingSupplier,
      subtitle: S.of(context).failedToSaveSupplierCheckConnection,
      closeAfter: const Duration(seconds: 5),
    );
  }
}

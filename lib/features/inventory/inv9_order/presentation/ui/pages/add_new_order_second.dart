import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/inventory/domain/models/supplier_model.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as path;

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/widgets/add_new_supplier_third/draft.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_check_box.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_validated_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/inventory/helpers/constants/constant_lists.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/inventory/helpers/inventory_paths.dart';

class StorageAllocationData {
  String? locationId; // selected storage id
  final TextEditingController quantity = TextEditingController();
  void dispose() => quantity.dispose();
}

// Product details data model for second page
class ProductDetailsData {
  final TextEditingController quantityController;
  final TextEditingController unitCostController;
  final TextEditingController discountController;
  final TextEditingController vatController; // Add this line
  String? selectedCurrency;
  String? selectedVat; // Remove this if using text field

  ProductDetailsData()
      : quantityController = TextEditingController(),
        unitCostController = TextEditingController(),
        discountController = TextEditingController(),
        vatController = TextEditingController(); // Add this line with comma

  void dispose() {
    quantityController.dispose();
    unitCostController.dispose();
    discountController.dispose();

    vatController.dispose(); // Add this line
  }
}

class AddNewOrderPageSecond extends StatefulWidget {
  final List<ProductModel>? products; // Now using ProductModel
  final Map<String, dynamic>? orderData;
  final String? draftId; // Add this parameter
  final bool isDraftEdit; // Add this parameter

  const AddNewOrderPageSecond({
    super.key,
    this.products,
    this.orderData,
    this.draftId, // Add this
    this.isDraftEdit = false, // Add this
  });

  @override
  State<AddNewOrderPageSecond> createState() => _AddNewOrderPageSecondState();
}

class _AddNewOrderPageSecondState extends State<AddNewOrderPageSecond> {
  /////////////////////////// Controllers ///////////////////////
  TextEditingController orderIdController = TextEditingController();
  TextEditingController shippingController = TextEditingController();
  TextEditingController orderValueController = TextEditingController();
  TextEditingController supplierIdController = TextEditingController();
  TextEditingController beneficiaryNameController = TextEditingController();
  TextEditingController beneficiaryBankNameController = TextEditingController();
  TextEditingController ibanController = TextEditingController();
  TextEditingController swiftCodeController = TextEditingController();
  TextEditingController bankAddressController = TextEditingController();

  /////////////////////////// Product Details List ///////////////////////
  List<ProductDetailsData> productDetails = [];
  // Suppliers data/state
  List<SupplierModel> _suppliers = [];
  List<Map<String, String>> _supplierItems =
      []; // For CustomDropdownFormField: [{'key': id, 'value': name}]
  bool _suppliersLoading = false;
  List<Map<String, String>> _storageLocationItems =
      []; // [{key: id, value: name}]
  bool _storageLocationsLoading = false;
  bool showAddressDetails = false;
  bool showWarehouseDetails = false;

  /////////////////////////// Dropdown Variables ///////////////////////
  String? selectedOrderType;
  String? selectedExpectedDelivery;
  String? selectedDeliveryMethod;
  String? selectedStorageLocation;
  String? selectedPaymentMethod;
  String? selectedAdvancedPayment;
  String? selectedMethodOfPayment;
  String? selectedSupplierName;
  List<Map<String, dynamic>> supplierAddresses = [];
  List<Map<String, dynamic>> supplierWarehouses = [];
  bool isLoadingPickupLocations = false;
  Map<String, dynamic>? selectedPickupAddress;
  Map<String, dynamic>? selectedPickupWarehouse;
  String? deliverySelectedData;

  var employeeEntity = Get.find<MainCoreEmployeeController>().employeeEntity!;

  // Order type options
  List<Map<String, String>> orderTypeList = [
    {"key": "purchase", "value": "Purchase"},
    {"key": "sale", "value": "Sale"},
    {"key": "return", "value": "Return"},
    {"key": "transfer", "value": "Transfer"},
    {"key": "adjustment", "value": "Adjustment"},
  ];

  // Cash
  final TextEditingController cashReceiptNumberController =
      TextEditingController();
  final TextEditingController cashNoteController = TextEditingController();

  // Credit Card
  final TextEditingController ccTransactionIdController =
      TextEditingController();
  final TextEditingController ccAuthCodeController = TextEditingController();
  final TextEditingController ccCardLast4Controller = TextEditingController();

  // Cash On Delivery
  final TextEditingController codReferenceController = TextEditingController();
  final TextEditingController courierNameController = TextEditingController();
  TextEditingController orderNoteController = TextEditingController();

  List<File> selectedImages = [];
  bool isSelectingFiles = false;

  @override
  void initState() {
    super.initState();

    // Existing setup...
    if (widget.products != null) {
      for (int i = 0; i < widget.products!.length; i++) {
        productDetails.add(ProductDetailsData());
      }
    } else {
      productDetails.add(ProductDetailsData());
    }

    if (widget.orderData != null) {
      orderIdController.text = widget.orderData!['orderId'] ?? '';
      selectedOrderType = widget.orderData!['orderType'];
      orderNoteController.text = widget.orderData!['orderNote'] ?? '';
    }

    // Load draft data if editing draft
    if (widget.isDraftEdit && widget.draftId != null) {
      _loadDraftData(widget.draftId!);
    }

    _loadSuppliers();
    _loadStorageLocations();
  }

  Future<void> _loadSuppliers() async {
    try {
      setState(() => _suppliersLoading = true);

      final qs = await FirebaseFirestore.instance
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('supplier')
          .get();

      final List<SupplierModel> suppliers = [];
      final List<Map<String, String>> items = [];

      for (final doc in qs.docs) {
        final data = doc.data();
        final model = SupplierModel.fromJson(data);

        // Determine a stable key for dropdown (prefer supplierDetails.supplierID, then supplierID, else doc.id)
        final supplierKey = (model.supplierID.isNotEmpty
                ? model.supplierID
                : (model.supplierID.isNotEmpty ? model.supplierID : doc.id))
            .toString();

        final displayName = model.supplierName.toString();

        suppliers.add(model);
        items.add({
          'key': supplierKey, // what onChanged will give back
          'value': displayName, // what the user sees in the dropdown
        });
      }

      if (!mounted) return;
      setState(() {
        _suppliers = suppliers;
        _supplierItems = items;
        _suppliersLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _suppliersLoading = false);
      // Optional: you can show a toast/snackbar here
      debugPrint('Failed to load suppliers: $e');
    }
  }

  SupplierModel? _findSupplierByKeyOrName(String value) {
    for (final s in _suppliers) {
      if (s.supplierID == value ||
          s.supplierID == value ||
          s.supplierName == value) {
        return s;
      }
    }
    return null;
  }

  void _fillSupplierFieldsFromModel(SupplierModel s) {
    // Supplier ID (you have both supplierID at root and in supplierDetails — we use supplierDetails first)
    supplierIdController.text =
        s.supplierID.isNotEmpty ? s.supplierID : s.supplierID;

    // Bank transfer details → fill your existing text fields
    beneficiaryNameController.text = s.beneficiaryName;
    beneficiaryBankNameController.text = s.beneficiaryBankName;
    ibanController.text = s.beneficiaryBankAccountNumberIBAN;
    swiftCodeController.text = s.bankSWIFTBICCode;
    bankAddressController.text = s.bankAddress;
  }

  Future<void> _loadSupplierPickupLocations(String supplierId) async {
    if (supplierId.isEmpty) return;

    setState(() {
      isLoadingPickupLocations = true;
    });

    try {
      // Load supplier data with sub-collections
      final supplierData = await SupplierDraftStore.instance
          .readSupplierFromFirebase(supplierId: supplierId);

      if (supplierData != null) {
        // In _loadSupplierPickupLocations method, after loading data:
        setState(() {
          supplierAddresses = List<Map<String, dynamic>>.from(
            supplierData['addresses'] ?? [],
          );
          supplierWarehouses = List<Map<String, dynamic>>.from(
            supplierData['warehouses'] ?? [],
          );

          // Auto-select first address if available
          if (supplierAddresses.isNotEmpty) {
            selectedPickupAddress = supplierAddresses.first;
            showAddressDetails =
                true; // Show address details if addresses exist
          } else if (supplierWarehouses.isNotEmpty) {
            // Show warehouse details if no addresses but warehouses exist
            showWarehouseDetails = true;
            showAddressDetails = false;
          }

          // Auto-select first warehouse if available
          if (supplierWarehouses.isNotEmpty) {
            selectedPickupWarehouse = supplierWarehouses.first;
          }
        });

        debugPrint("✅ Loaded pickup locations:");
        debugPrint("Addresses: ${supplierAddresses.length}");
        debugPrint("Warehouses: ${supplierWarehouses.length}");
      }
    } catch (e) {
      debugPrint("Error loading pickup locations: $e");
    } finally {
      setState(() {
        isLoadingPickupLocations = false;
      });
    }
  }

  void _onSupplierSelected(String? keyOrName) {
    if (keyOrName == null) return;

    setState(() {
      selectedSupplierName = keyOrName;
    });

    final model = _findSupplierByKeyOrName(keyOrName);
    if (model != null) {
      _fillSupplierFieldsFromModel(model);

      // Load pickup locations when supplier is selected
      _loadSupplierPickupLocations(model.supplierID);

      // ADD THIS: Auto-open address details when supplier is selected
      setState(() {
        showAddressDetails = true; // Automatically show address details
        showWarehouseDetails = false; // Close warehouse details if open
      });
    }
  }

  Future<void> _loadStorageLocations() async {
    try {
      if (!mounted) return;
      setState(() => _storageLocationsLoading = true);

      // FIX: Replace hardcoded email with current user
      final userEmail = InventoryPaths.userEmail;

      final qs = await FirebaseFirestore.instance
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('InventoryUser')
          .doc(userEmail) // CHANGE FROM: .doc(InventoryPaths.userEmail)
          .collection('storage_location')
          .get();

      final items = <Map<String, String>>[];

      for (final doc in qs.docs) {
        final data = doc.data();
        final id = (data['id'] ?? doc.id).toString();
        final name =
            (data['name'] ?? data['branchName'] ?? 'Location $id').toString();
        items.add({'key': id, 'value': name});
      }

      if (!mounted) return;
      setState(() {
        _storageLocationItems = items;
        _storageLocationsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _storageLocationsLoading = false);
      debugPrint('Failed to load storage locations: $e');
    }
  }

  // Start with ONE row (dropdown only initially)
  final List<StorageAllocationData> storageAllocations = [
    StorageAllocationData(),
  ];

  void _removeStorageAllocation(int index) {
    // keep at least one base row
    if (storageAllocations.length == 1 && index == 0) return;
    setState(() {
      storageAllocations[index].dispose();
      storageAllocations.removeAt(index);
    });
  }

  void _calculateOrderTotal() {
    double totalOrderValue = 0.0;

    // Calculate total for each product
    for (int i = 0; i < productDetails.length; i++) {
      final details = productDetails[i];

      // Get values with default 0 if empty or invalid
      double quantity = double.tryParse(details.quantityController.text) ?? 0.0;
      double unitCost = double.tryParse(details.unitCostController.text) ?? 0.0;
      double vatPercent = double.tryParse(details.vatController.text) ?? 0.0;
      double discountPercent =
          double.tryParse(details.discountController.text) ?? 0.0;

      // Calculate product subtotal
      double productSubtotal = quantity * unitCost;

      // Apply VAT (assuming VAT is entered as percentage, e.g., 15 for 15%)
      double productWithVat = productSubtotal * (1 + (vatPercent / 100));

      // Apply discount (assuming discount is entered as percentage, e.g., 10 for 10%)
      double productTotal = productWithVat * (1 - (discountPercent / 100));

      totalOrderValue += productTotal;
    }

    // Use the helper method for pickup detection
    final bool isPickupSelected = _isPickupDelivery();

    if (!isPickupSelected) {
      double shippingCost = double.tryParse(shippingController.text) ?? 0.0;
      totalOrderValue += shippingCost;
      debugPrint("💰 Adding shipping cost: $shippingCost");
    } else {
      // Clear shipping cost when pickup is selected
      shippingController.text = '0.00';
      debugPrint("🚚 Pickup selected - shipping set to 0.00");
    }

    // Update order value field with calculated total
    orderValueController.text = totalOrderValue.toStringAsFixed(2);
    debugPrint("📊 Total order value: ${orderValueController.text}");
  }

  // 3. Add method to save draft to Firestore:

  Future<void> _saveDraftToFirestore(
    String draftId,
    List<String> imageUrls,
  ) async {
    final userEmail = InventoryPaths.userEmail;

    // Prepare complete draft data with explicit typing
    final Map<String, dynamic> draftData = {
      "orderId": draftId,
      "orderType": selectedOrderType ?? '',
      "status": "draft", // Important: mark as draft
      "orderDate": DateTime.now().toIso8601String(),
      "expectedDelivery": selectedExpectedDelivery ?? '',
      "deliveryMethod": selectedDeliveryMethod ?? '',
      "paymentMethod": selectedPaymentMethod ?? '',
      "shipping":
          shippingController.text.isEmpty ? "0" : shippingController.text,
      "orderValue": orderValueController.text,
      "supplierName": selectedSupplierName ?? '',
      "supplierId": supplierIdController.text,
      "deliverySelectedData": deliverySelectedData ?? '',
      "orderNote": orderNoteController.text,
      "attachmentUrls": imageUrls,

      // Storage allocations
      "storageAllocations": storageAllocations
          .map(
            (a) => <String, dynamic>{
              'storageLocationId': a.locationId ?? '',
              'quantity': a.quantity.text,
              'locationName': _storageLocationItems.firstWhere(
                    (item) => item['key'] == a.locationId,
                    orElse: () => <String, String>{'value': ''},
                  )['value'] ??
                  '',
            },
          )
          .toList(),

      // Product details
      "productDetails": productDetails.asMap().entries.map((entry) {
        int index = entry.key;
        ProductDetailsData details = entry.value;

        return <String, dynamic>{
          "productIndex": index,
          "quantity": details.quantityController.text,
          "unitCost": details.unitCostController.text,
          "discount": details.discountController.text,
          "vat": details.vatController.text,
          "currency": details.selectedCurrency ?? '',
        };
      }).toList(),

      // Products data if available
      if (widget.products != null)
        "products": widget.products!.map((p) => p.toJson()).toList(),

      // Bank transfer details if applicable
      if (selectedPaymentMethod == 'bank_transfer') ...{
        "advancedPayment": selectedAdvancedPayment ?? '',
        "methodOfPayment": selectedMethodOfPayment ?? '',
        "beneficiaryName": beneficiaryNameController.text,
        "beneficiaryBankName": beneficiaryBankNameController.text,
        "beneficiaryAccountIban": ibanController.text,
        "bankSwiftBicCode": swiftCodeController.text,
        "bankAddress": bankAddressController.text,
      },

      // Pickup location details if applicable
      if (selectedPickupAddress != null)
        "selectedPickupAddress": Map<String, dynamic>.from(
          selectedPickupAddress!,
        ),

      if (selectedPickupWarehouse != null)
        "selectedPickupWarehouse": Map<String, dynamic>.from(
          selectedPickupWarehouse!,
        ),

      // Metadata
      "isDraft": true,
      "createdAt": FieldValue.serverTimestamp(),
      "lastModified": FieldValue.serverTimestamp(),
      "createdBy": <String, dynamic>{
        "firstName": employeeEntity.firstName ?? 'Unknown',
        "lastName": employeeEntity.lastName ?? 'User',
        "email": employeeEntity.email ?? 'unknown@email.com',
        "department": employeeEntity.departmentId ?? '',
        "jobTitle": employeeEntity.title ?? '',
      },
    };

    // Save to user-specific drafts collection
    final docRef = FirebaseFirestore.instance
        .collection("Demo")
        .doc(InventoryPaths.companyId)
        .collection("InventoryUser")
        .doc(userEmail) // Use current user email
        .collection("drafts") // User-specific drafts
        .doc(draftId);

    await docRef.set(draftData);
    debugPrint(
      '✅ Draft saved to user-specific path: /Demo/${InventoryPaths.companyId}/InventoryUser/$userEmail/drafts/$draftId',
    );
  }

  // 4. Add method to load draft data (call this in initState if editing draft):

  Future<void> _loadDraftData(String draftId) async {
    try {
      final userEmail = InventoryPaths.userEmail;

      final docSnapshot = await FirebaseFirestore.instance
          .collection("Demo")
          .doc(InventoryPaths.companyId)
          .collection("InventoryUser")
          .doc(userEmail) // Use current user email
          .collection("drafts")
          .doc(draftId)
          .get();

      if (docSnapshot.exists) {
        // Your existing data loading logic...
        debugPrint('✅ Draft loaded from user-specific path');
      }
    } catch (e) {
      debugPrint('Error loading draft data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventory,
          onFirstTap: () {
            navigateTo(context, InventoryManagement());
          },
          secondTitle: S.of(context).addingNewOrder,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                // Delivery Details title
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).deliveryMethod,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Delivery Details Container
                Container(
                  padding: EdgeInsets.all(16.sp),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      buildResponsiveFields(
                        context: context,
                        left: expectedDeliveryWidget(),
                        right: deliveryMethodWidget(),
                      ),
                      //      SizedBox(height: 15.h),
                      // //    storageLocationWidget(),
                      //     SizedBox(height: 8.h),
                      //     Row(
                      //       children: [
                      //         customButtonWithSvg(
                      //           title: S.of(context).storage,
                      //           function: _addStorageAllocation,
                      //           textStyle: StyleText.fontSize14Weight500.copyWith(color: AppTheme.readableOn(AppColors.blackButton)),
                      //           width: 100.w,
                      //           height: 30.h,
                      //           space: 16.sp,
                      //           radius: 4.r,
                      //           color: AppColors.blackButton,
                      //           svgColor: AppTheme.readableOn(AppColors.blackButton),
                      //           image: "assets/icons_assets/main_icons_assets/ic_action_plus.svg",
                      //           widthImage: 12.w,
                      //           heightImage: 12.h,
                      //           colorBorder: Colors.transparent,
                      //         )
                      //       ],
                      //     ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Product Details sections
                ...buildProductDetailsSections(),

                widget.products != null && widget.products!.length == 1
                    ? SizedBox()
                    : SizedBox(height: 20.h),

                // Invoice section
                buildInvoiceSection(),

                SizedBox(height: 20.h),

                // Supplier Bank Transfer Details section
                buildSupplierDetailsSection(),

                SizedBox(height: 20.h),

                buildPickupLocationSection(),

                SizedBox(height: 20.h),

                // Attachments section
                buildAttachmentsSection(),

                SizedBox(height: 20.h),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customButton(
                      title: S.of(context).saveForLater,
                      function: () async {
                        // Show confirmation dialog first
                        _showDraftConfirmationDialog(context);
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                      width: 135.w,
                      height: 38.h,
                      radius: 8.r,
                      color: AppColors.grey,
                    ),
                    customButton(
                      title: S.of(context).submit,
                      function: () async {
                        // Show confirmation dialog
                        _showPreviewConfirmationDialog(context);
                      },
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textButton,
                      ),
                      width: 135.w,
                      height: 38.h,
                      radius: 8.r,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDraftConfirmationDialog(BuildContext rootContext) {
    showAppDialog(
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
            width: 410.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Draft icon or animation
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lot_status_confirmation.json', // or use a draft-specific animation
                  width: 70.w,
                  height: 70.h,
                  fit: BoxFit.scaleDown,
                  repeat: true,
                  animate: true,
                ),
                SizedBox(height: 20.sp),
                Text(
                  S.of(context).saveForLater,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 24.sp),
                Text(
                  "Are you sure you want to save this order as draft?",
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 24.sp),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // No Button
                    customButton(
                      title: S.of(context).no,
                      function: () {
                        Navigator.of(dialogContext).pop(); // Close dialog
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                      width: 150.w,
                      height: 38.h,
                      radius: 8.r,
                      color: AppColors.grey,
                    ),
                    // Yes Button
                    customButton(
                      title: S.of(context).yes,
                      function: () async {
                        Navigator.of(dialogContext).pop(); // Close dialog
                        // Proceed with draft save
                        await _saveDraftOrderWithDialogs(rootContext);
                      },
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textButton,
                      ),
                      width: 150.w,
                      height: 38.h,
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

  Future<void> _saveDraftOrderWithDialogs(BuildContext rootContext) async {
    try {
      // Show loading dialog
      _showDraftLoadingDialog(rootContext);

      // Generate draft ID if not exists
      String draftId = widget.isDraftEdit && widget.draftId != null
          ? widget.draftId! // Use existing draft ID when editing
          : (orderIdController.text.isNotEmpty
              ? orderIdController.text
              : "DRAFT_${DateTime.now().millisecondsSinceEpoch}");

      // Upload images first and get URLs
      List<String> imageUrls = await _uploadImagesToStorage(draftId);

      // Save draft with status = "draft"
      await _saveDraftToFirestore(draftId, imageUrls);

      // Close loading dialog
      if (rootContext.mounted) Navigator.of(rootContext).pop();

      // Show success dialog
      if (mounted) {
        if (!rootContext.mounted) return;
        _showDraftSuccessDialog(rootContext);

        // Auto-close success dialog after 2 seconds and navigate back
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            if (!rootContext.mounted) return;
            Navigator.of(rootContext).pop(); // Close success dialog
            if (!rootContext.mounted) return;
            Navigator.of(rootContext).pop(); // Navigate back to previous screen
          }
        });
      }
    } catch (error) {
      // Close loading dialog if open
      if (rootContext.mounted) Navigator.of(rootContext).pop();

      // Show error dialog
      if (rootContext.mounted) {
        _showDraftErrorDialog(rootContext, error.toString());
      }

      debugPrint('Draft save error: $error');
    }
  }

  // Draft loading dialog
  void _showDraftLoadingDialog(BuildContext rootContext) {
    showAppDialog(
      context: rootContext,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: SizedBox(
            width: 300.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleProgressMaster.inline(
                  color: Colors.orange,
                ), // Different color for draft
                SizedBox(height: 20.sp),
                Text(
                  "Saving draft...",
                  style: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                if (selectedImages.isNotEmpty) ...[
                  SizedBox(height: 8.sp),
                  Text(
                    "${selectedImages.length} image(s) to upload",
                    style: StyleText.fontSize12Weight400.copyWith(
                      color:
                          Theme.of(dialogContext).brightness == Brightness.light
                              ? AppColors.secondaryText
                              : AppColors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Draft success dialog
  void _showDraftSuccessDialog(BuildContext rootContext) {
    showAppDialog(
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
            width: 410.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
                  width: 100.sp,
                  height: 100.sp,
                  fit: BoxFit.scaleDown,
                  repeat: true,
                  animate: true,
                ),
                SizedBox(height: 20.sp),
                Text(
                  "Draft Saved Successfully!",
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 12.sp),
                Text(
                  "Your order has been saved as draft and can be edited later.",
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color:
                        Theme.of(dialogContext).brightness == Brightness.light
                            ? AppColors.secondaryText
                            : AppColors.white,
                  ),
                ),
                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Draft error dialog
  void _showDraftErrorDialog(BuildContext rootContext, String errorMessage) {
    showAppDialog(
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
            width: 410.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 60.sp, color: AppColors.red),
                SizedBox(height: 20.sp),
                Text(
                  "Draft Save Failed",
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 12.sp),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color:
                        Theme.of(dialogContext).brightness == Brightness.light
                            ? AppColors.secondaryText
                            : AppColors.white,
                  ),
                ),
                SizedBox(height: 20.sp),
                customButton(
                  title: S.of(context).ok,
                  function: () {
                    Navigator.of(dialogContext).pop();
                  },
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textButton,
                  ),
                  width: 120.w,
                  height: 38.h,
                  radius: 8.r,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Updated Address and Warehouse Checkbox Lists using CustomCheckBox
  Widget _buildAddressCheckboxList() {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    if (supplierAddresses.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Pickup Address",
          style: StyleText.fontSize14Weight600.copyWith(
            color: AppColors.blackButton,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(
              color: lightMode
                  ? AppColors.grey.withValues(alpha: 0.5)
                  : AppColors.grey.withValues(alpha: 0.5),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: supplierAddresses.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> address = entry.value;

                // Get address name/label first
                String addressName = address['addressName'] ??
                    address['name'] ??
                    address['addressLabel'] ??
                    'Address ${index + 1}';

                // Build location display name
                String locationName =
                    "${address['country'] ?? ''}, ${address['city'] ?? ''}"
                        .replaceAll(RegExp(r'^,\s*|,\s*$'), '');

                // Generate address ID (like address_1, address_2, etc.)
                String addressId = 'address_${index + 1}';

                bool isSelected = selectedPickupAddress != null &&
                    supplierAddresses.indexOf(selectedPickupAddress!) == index;

                return Container(
                  margin: EdgeInsets.only(
                    bottom: index < supplierAddresses.length - 1 ? 8.h : 0,
                  ),
                  child: InkWell(
                    onTap: () {
                      HapticController.low(); // list row: on the tap (X-117)
                      setState(() {
                        selectedPickupAddress = address;
                        selectedPickupWarehouse =
                            null; // Clear warehouse selection

                        // Save the address ID in deliverySelectedData
                        deliverySelectedData = addressId;

                        // Automatically show address details when selected
                        showAddressDetails = true;
                        showWarehouseDetails = false;
                      });

                      // Debug print to verify
                      debugPrint("✅ Selected Address ID: $addressId");
                      debugPrint(
                        "✅ deliverySelectedData: $deliverySelectedData",
                      );
                    },
                    child: Row(
                      children: [
                        // Using CustomCheckBox
                        CustomCheckBox(
                          isSelected: isSelected,
                          size: 20.w,
                          borderColor: lightMode
                              ? AppColors.secondaryText
                              : AppColors.white,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Address Name (Primary text)
                              Text(
                                addressName,
                                style: StyleText.fontSize14Weight500.copyWith(
                                  color: AppColors.blackButton,
                                ),
                              ),

                              // Location (Secondary text)
                              if (locationName.isNotEmpty) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  locationName,
                                  style: StyleText.fontSize12Weight400.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarehouseCheckboxList() {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    if (supplierWarehouses.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Pickup Warehouse",
          style: StyleText.fontSize14Weight600.copyWith(
            color: AppColors.blackButton,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(
              color: lightMode
                  ? AppColors.grey.withValues(alpha: 0.5)
                  : AppColors.grey.withValues(alpha: 0.5),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: supplierWarehouses.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> warehouse = entry.value;
                String displayName =
                    warehouse['warehouseName'] ?? 'Warehouse ${index + 1}';

                // Generate warehouse ID (like warehouse_1, warehouse_2, etc.)
                String warehouseId = 'warehouse_${index + 1}';

                bool isSelected = selectedPickupWarehouse != null &&
                    supplierWarehouses.indexOf(selectedPickupWarehouse!) ==
                        index;

                return Container(
                  margin: EdgeInsets.only(
                    bottom: index < supplierWarehouses.length - 1 ? 8.h : 0,
                  ),
                  child: InkWell(
                    onTap: () {
                      HapticController.low(); // list row: on the tap (X-117)
                      setState(() {
                        selectedPickupWarehouse = warehouse;
                        selectedPickupAddress = null; // Clear address selection

                        // Save the warehouse ID in deliverySelectedData
                        deliverySelectedData = warehouseId;

                        // Automatically show warehouse details when selected
                        showWarehouseDetails = true;
                        showAddressDetails = false;
                      });

                      // Debug print to verify
                      debugPrint("✅ Selected Warehouse ID: $warehouseId");
                      debugPrint(
                        "✅ deliverySelectedData: $deliverySelectedData",
                      );
                    },
                    child: Row(
                      children: [
                        // Using CustomCheckBox
                        CustomCheckBox(
                          isSelected: isSelected,
                          size: 20.w,
                          borderColor: AppColors.grey,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: StyleText.fontSize14Weight500.copyWith(
                                  color: AppColors.blackButton,
                                ),
                              ),
                              if (warehouse['city'] != null &&
                                  warehouse['city'].toString().isNotEmpty) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  "${warehouse['city']}, ${warehouse['country'] ?? ''}",
                                  style: StyleText.fontSize12Weight400.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPickupLocationSection() {
    var isMobile = context.isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final bool isPickupSelected = _isPickupDelivery();

    if (!isPickupSelected) return SizedBox();

    return Column(
      children: [
        // Pick Up Location Details Header
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Pick Up Location Details",
              style: StyleText.fontSize16Weight600.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // Pick Up Location Container
        Container(
          padding: EdgeInsets.all(15.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: isLoadingPickupLocations
              ? Center(
                  child: Column(
                    children: [
                      CircleProgressMaster.inline(color: AppColors.primary),
                      SizedBox(height: 8.h),
                      Text(
                        "Loading pickup locations...",
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: lightMode
                              ? AppColors.secondaryText
                              : AppColors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : isMobile
                  ? Column(
                      children: [
                        // Address Selection Checkbox List
                        if (supplierAddresses.isNotEmpty) ...[
                          _buildAddressCheckboxList(),
                          SizedBox(height: 15.h),
                        ],

                        // Warehouse Selection Checkbox List
                        if (supplierWarehouses.isNotEmpty) ...[
                          _buildWarehouseCheckboxList(),
                          SizedBox(height: 15.h),
                        ],

                        // No locations available message (shown when no data)
                        if (supplierAddresses.isEmpty &&
                            supplierWarehouses.isEmpty)
                          _buildNoLocationsMessage(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Address Selection Checkbox List
                        if (supplierAddresses.isNotEmpty) ...[
                          Expanded(child: _buildAddressCheckboxList()),
                          SizedBox(width: 15.w),
                        ],

                        // Warehouse Selection Checkbox List
                        if (supplierWarehouses.isNotEmpty) ...[
                          Expanded(child: _buildWarehouseCheckboxList()),
                        ],

                        // No locations available message (shown when no data)
                        if (supplierAddresses.isEmpty &&
                            supplierWarehouses.isEmpty)
                          Expanded(child: _buildNoLocationsMessage()),
                      ],
                    ),
        ),

        // Tabs Section (Outside Container)
        if (supplierAddresses.isNotEmpty || supplierWarehouses.isNotEmpty) ...[
          SizedBox(height: 16.h),

          // Clickable Tabs Row
          Row(
            children: [
              // Address Details Tab
              if (supplierAddresses.isNotEmpty) ...[
                GestureDetector(
                  onTapDown: (_) => HapticController.low(),
                  onTap: () {
                    setState(() {
                      showAddressDetails = !showAddressDetails;
                      if (showAddressDetails) showWarehouseDetails = false;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: showAddressDetails
                              ? AppColors.secondaryPrimary
                              : Colors.transparent,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Text(
                      "Address Details",
                      style: StyleText.fontSize20Weight600.copyWith(
                        color: showAddressDetails
                            ? AppColors.secondaryPrimary
                            : (lightMode
                                ? AppColors.secondaryText
                                : AppColors.white),
                      ),
                    ),
                  ),
                ),
              ],

              // Space between tabs
              if (supplierAddresses.isNotEmpty && supplierWarehouses.isNotEmpty)
                SizedBox(width: 30.w),

              // Warehouses Tab
              if (supplierWarehouses.isNotEmpty) ...[
                GestureDetector(
                  onTapDown: (_) => HapticController.low(),
                  onTap: () {
                    setState(() {
                      showWarehouseDetails = !showWarehouseDetails;
                      if (showWarehouseDetails) showAddressDetails = false;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: showWarehouseDetails
                              ? AppColors.secondaryPrimary
                              : Colors.transparent,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Text(
                      "Warehouses",
                      style: StyleText.fontSize20Weight600.copyWith(
                        color: showWarehouseDetails
                            ? AppColors.secondaryPrimary
                            : (lightMode
                                ? AppColors.secondaryText
                                : AppColors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Content Containers (Outside main container)
          if (showAddressDetails && selectedPickupAddress != null) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: _buildAddressDetailsDisplay(),
            ),
          ],

          if (showWarehouseDetails && selectedPickupWarehouse != null) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: _buildWarehouseDetailsDisplay(),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildAddressDetailsDisplay() {
    if (selectedPickupAddress == null) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildResponsiveFields(
          context: context,
          left: CustomValidatedTextFieldMaster(
            label: S.of(context).country,
            enabled: false,
            hint: "",
            controller: TextEditingController(
              text: selectedPickupAddress!['country'],
            ),
          ),
          right: CustomValidatedTextFieldMaster(
            label: S.of(context).state,
            enabled: false,
            hint: "",
            controller: TextEditingController(
              text: selectedPickupAddress!['stateOrProvince'],
            ),
          ),
        ),
        SizedBox(height: 15.h),
        buildResponsiveFields(
          context: context,
          left: CustomValidatedTextFieldMaster(
            label: S.of(context).city,
            enabled: false,
            hint: "",
            controller: TextEditingController(
              text: selectedPickupAddress!['city'],
            ),
          ),
          right: CustomValidatedTextFieldMaster(
            label: S.of(context).postalCode,
            enabled: false,
            hint: "",
            controller: TextEditingController(
              text: selectedPickupAddress!['postalCode'],
            ),
          ),
        ),
        SizedBox(height: 15.h),
        CustomValidatedTextFieldMaster(
          label: S.of(context).description,
          height: 72,
          showCharCount: true,
          maxLines: 3,
          enabled: false,
          hint: "",
          controller: TextEditingController(
            text: selectedPickupAddress!['streetName'],
          ),
        ),
      ],
    );
  }

  Widget _buildWarehouseDetailsDisplay() {
    if (selectedPickupWarehouse == null) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildResponsiveFields(
          context: context,
          left: CustomValidatedTextFieldMaster(
            label: S.of(context).country,
            enabled: false,
            hint: "",
            controller: TextEditingController(
              text: selectedPickupWarehouse!['country'],
            ),
          ),
          right: CustomValidatedTextFieldMaster(
            label: S.of(context).stateOrProvince,
            enabled: false,
            hint: "",
            controller: TextEditingController(
              text: selectedPickupWarehouse!['stateOrProvince'],
            ),
          ),
        ),
        SizedBox(height: 15.h),
        buildResponsiveFields(
          context: context,
          left: CustomValidatedTextFieldMaster(
            label: S.of(context).city,
            enabled: false,
            hint: "",
            controller: TextEditingController(
              text: selectedPickupWarehouse!['city'],
            ),
          ),
          right: CustomValidatedTextFieldMaster(
            label: S.of(context).postalCode,
            enabled: false,
            hint: "",
            controller: TextEditingController(
              text: selectedPickupWarehouse!['postalCode'],
            ),
          ),
        ),
        SizedBox(height: 15.h),
        CustomValidatedTextFieldMaster(
          label: S.of(context).description,
          enabled: false,
          hint: "",
          maxLines: 3,
          height: 72,
          controller: TextEditingController(
            text: selectedPickupWarehouse!['streetName'],
          ),
        ),
      ],
    );
  }

  // Updated buildProductDetailsSections to skip product section when only one product
  List<Widget> buildProductDetailsSections() {
    final isMobile = MediaQuery.of(context).size.width < 800;

    if (widget.products == null || widget.products!.isEmpty) return [];

    List<Widget> sections = [];
    int productCount = widget.products!.length;

    // If only one product, return empty list since product fields are now in invoice section
    if (productCount == 1) {
      return [];
    }

    // If more than 2 products, use horizontal ListView
    if (productCount > 2) {
      sections.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Products title
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Products Details ($productCount items)",
                  style: StyleText.fontSize16Weight600.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Horizontal scrollable container
            SizedBox(
              height: isMobile
                  ? 480.h
                  : 460.h, // Adjust height based on your form fields
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productCount,
                itemBuilder: (context, index) {
                  return Container(
                    width: isMobile
                        ? MediaQuery.of(context).size.width * 0.85
                        : 350.w,
                    margin: EdgeInsets.only(right: 16.w),
                    child: _buildSingleProductSection(index),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      // Original logic for 2 products (side by side or stacked)
      if (isMobile) {
        // Mobile: Stack vertically
        for (int i = 0; i < productCount; i++) {
          sections.add(_buildSingleProductSection(i));
          if (i < productCount - 1) sections.add(SizedBox(height: 20.h));
        }
      } else {
        // Desktop/Tablet: Display side by side
        for (int i = 0; i < productCount; i += 2) {
          if (i + 1 < productCount) {
            // Two products in this row
            sections.add(
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildSingleProductSection(i)),
                  SizedBox(width: 20.w),
                  Expanded(child: _buildSingleProductSection(i + 1)),
                ],
              ),
            );
          } else {
            // Only one product left - take full width
            sections.add(_buildSingleProductSection(i));
          }

          // Add space between rows if there are more products
          if (i + 2 < productCount) {
            sections.add(SizedBox(height: 20.h));
          }
        }
      }
    }

    return sections;
  }

  // Build no locations message
  Widget _buildNoLocationsMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.sp),
      child: Column(
        children: [
          CustomEmptyState(
            lottiePath:
                'assets/lottie_assets/main_lottie_assets/lot_empty_state.json',
            size: 120,
            verticalPadding: 0,
          ),
          SizedBox(height: 8.h),
          Text(
            "Please select a supplier with address or warehouse details",
            textAlign: TextAlign.center,
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build a single product section
  Widget _buildSingleProductSection(int index) {
    ProductModel? productInfo = widget.products![index];
    ProductDetailsData detailsData = productDetails[index];

    return Column(
      children: [
        // Product Details title
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                productInfo.productName.value.isNotEmpty
                    ? productInfo.productName.value
                    : 'Product ${index + 1}',
                style: StyleText.fontSize16Weight600.copyWith(
                  color: AppColors.blackButton,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // Product Details container
        Container(
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: widget.products!.length == 1
              ? Column(
                  children: [
                    buildResponsiveFields(
                      context: context,
                      left: buildReadOnlyField(
                        label: S.of(context).productID,
                        value: productInfo.productId.value,
                      ),
                      right: quantityWidget(detailsData),
                    ),
                    SizedBox(height: 15.sp),
                    buildResponsiveFields(
                      context: context,
                      left: unitCostWidget(detailsData),
                      right: currencyWidget(detailsData),
                    ),
                    SizedBox(height: 15.sp),
                    buildResponsiveFields(
                      context: context,
                      left: vatWidget(detailsData),
                      right: discountPercentageWidget(detailsData),
                    ),
                  ],
                )
              : Column(
                  children: [
                    // Product ID (read-only)
                    buildReadOnlyField(
                      label: S.of(context).productID,
                      value: productInfo.productId.value,
                    ),

                    // space
                    SizedBox(height: 15.h),
                    // Quantity
                    quantityWidget(detailsData),
                    // space
                    SizedBox(height: 15.h),

                    // Unit Cost
                    unitCostWidget(detailsData),
                    // space
                    SizedBox(height: 15.h),

                    // Currency
                    currencyWidget(detailsData),

                    // space
                    SizedBox(height: 15.h),

                    // VAT
                    vatWidget(detailsData),
                    // space
                    SizedBox(height: 15.h),

                    // Discount Percentage (full width)
                    discountPercentageWidget(detailsData),
                  ],
                ),
        ),
      ],
    );
  }

  // Build read-only field
  Widget buildReadOnlyField({required String label, required String value}) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StyleText.fontSize12Weight500.copyWith(
            color: AppColors.blackButton,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          width: double.infinity,
          height: 36.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: lightMode
                ? AppColors.grey.withValues(alpha: 0.3)
                : AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value.isEmpty ? "N/A" : value,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build Invoice Section - Updated to hide shipping when Pickup is selected
  // Build Invoice Section - Updated to hide shipping when Pickup is selected
  Widget buildInvoiceSection() {
    final bool hasOneProduct =
        widget.products != null && widget.products!.length == 1;

    // DEBUG: Print current delivery method value
    debugPrint("🛒 BUILDING INVOICE SECTION:");
    debugPrint("selectedDeliveryMethod: '$selectedDeliveryMethod'");

    // More comprehensive pickup detection
    final bool isPickupSelected = _isPickupDelivery();
    debugPrint("isPickupSelected: $isPickupSelected");

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              S.of(context).invoice,
              style: StyleText.fontSize16Weight600.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.sp),
        Container(
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            children: [
              // If only one product, include product fields first
              if (hasOneProduct) ...[
                // Product ID (read-only)
                buildResponsiveFields(
                  context: context,
                  left: buildReadOnlyField(
                    label: S.of(context).productID,
                    value: widget.products![0].productId.value,
                  ),
                  right: quantityWidget(productDetails[0]),
                ),
                SizedBox(height: 15.sp),

                // Unit Cost and Currency
                buildResponsiveFields(
                  context: context,
                  left: unitCostWidget(productDetails[0]),
                  right: currencyWidget(productDetails[0]),
                ),
                SizedBox(height: 15.sp),

                // VAT and Discount
                buildResponsiveFields(
                  context: context,
                  left: vatWidget(productDetails[0]),
                  right: discountPercentageWidget(productDetails[0]),
                ),
                SizedBox(height: 15.sp),
              ],

              // Standard invoice fields - CONDITIONAL SHIPPING
              buildResponsiveFields(
                context: context,
                left: paymentMethodWidget(),
                right: isPickupSelected
                    ? SizedBox() // Completely empty widget when pickup
                    : shippingWidget(), // Show shipping for other methods
              ),
              SizedBox(height: 15.h),
              buildResponsiveFields(
                context: context,
                left: orderValueWidget(),
                right: Container(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to detect pickup delivery
  bool _isPickupDelivery() {
    if (selectedDeliveryMethod == null) return false;

    final String method = selectedDeliveryMethod!.toLowerCase().trim();

    // Check various possible pickup values
    return method == 'pickup' ||
        method == 'pick up' ||
        method == 'pick_up' ||
        method.contains('pickup') ||
        method.contains('pick up');
  }

  // Build Supplier Bank Section
  Widget buildSupplierDetailsSection() {
    switch (selectedPaymentMethod) {
      case 'bank_transfer':
        return _buildSupplierBankTransferSection(); // your existing structure
      case 'credit_card':
        return _buildSupplierWidget();
      //_buildSupplierCreditCardSection()
      case 'cash_on_delivery':
        return _buildSupplierWidget();
      //_buildSupplierCodSection()
      case 'cash':
        return _buildSupplierWidget();
      //_buildSupplierCashSection()
      default:
        // Nothing selected yet -> friendly placeholder
        final lightMode = Theme.of(context).brightness == Brightness.light;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Supplier Details',
                  style: StyleText.fontSize16Weight600.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.sp),
            Container(
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Choose a payment method to enter supplier details.',
                style: StyleText.fontSize14Weight400.copyWith(
                  color: lightMode ? AppColors.secondaryText : AppColors.white,
                ),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildSupplierWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              S.of(context).supplierDetails,
              style: StyleText.fontSize16Weight600.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.sp),
        Container(
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            children: [
              buildResponsiveFields(
                context: context,
                left: supplierNameWidget(),
                right: supplierIdWidget(),
              ),
              SizedBox(height: 15.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupplierBankTransferSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              S.of(context).supplierBankTransferDetails,
              style: StyleText.fontSize16Weight600.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.sp),
        Container(
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            children: [
              buildResponsiveFields(
                context: context,
                left: supplierNameWidget(),
                right: supplierIdWidget(),
              ),
              SizedBox(height: 15.h),
              buildResponsiveFields(
                context: context,
                left: advancedPaymentWidget(),
                right: methodOfPaymentWidget(),
              ),
              SizedBox(height: 15.h),
              buildResponsiveFields(
                context: context,
                left: beneficiaryNameWidget(),
                right: beneficiaryBankNameWidget(),
              ),
              SizedBox(height: 15.h),
              buildResponsiveFields(
                context: context,
                left: beneficiaryBankAccountNumberIBANWidget(),
                right: bankSWIFTBICCodeWidget(),
              ),
              SizedBox(height: 15.h),
              bankAddressWidget(),
            ],
          ),
        ),
      ],
    );
  }

  // Build Attachments Section
  Widget buildAttachmentsSection() {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Attachments",
              style: StyleText.fontSize16Weight600.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.sp),
        Container(
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            children: [
              // File upload area
              GestureDetector(
                onTapDown:
                    isSelectingFiles ? null : (_) => HapticController.low(),
                onTap: isSelectingFiles ? null : _pickImages,
                child: Container(
                  width: double.infinity,
                  height: selectedImages.isEmpty ? 100.h : 80.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(
                      color: lightMode
                          ? AppColors.secondaryText.withValues(alpha: 0.3)
                          : AppColors.white.withValues(alpha: 0.3),
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                    color: lightMode
                        ? AppColors.grey.withValues(alpha: 0.1)
                        : AppColors.background.withValues(alpha: 0.3),
                  ),
                  child: isSelectingFiles
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20.sp,
                                height: 20.sp,
                                child: CircleProgressMaster.inline(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "Selecting files...",
                                style: StyleText.fontSize12Weight400.copyWith(
                                  color: lightMode
                                      ? AppColors.secondaryText
                                      : AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 32.sp,
                                color: lightMode
                                    ? AppColors.secondaryText
                                    : AppColors.white,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                selectedImages.isEmpty
                                    ? "Tap to select images"
                                    : "Tap to add more images",
                                style: StyleText.fontSize14Weight400.copyWith(
                                  color: lightMode
                                      ? AppColors.secondaryText
                                      : AppColors.white,
                                ),
                              ),
                              if (selectedImages.isEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 4.h),
                                  child: Text(
                                    "Multiple images supported",
                                    style:
                                        StyleText.fontSize12Weight400.copyWith(
                                      color: lightMode
                                          ? AppColors.secondaryText
                                              .withValues(alpha: 0.7)
                                          : AppColors.white
                                              .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ),

              // Display selected images
              if (selectedImages.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    color: lightMode
                        ? AppColors.grey.withValues(alpha: 0.2)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${selectedImages.length} image(s) selected",
                            style: StyleText.fontSize12Weight500.copyWith(
                              color: AppColors.blackButton,
                            ),
                          ),
                          GestureDetector(
                            onTapDown:
                                hapticDown(_clearAllImages, HapticLevel.low),
                            onTap: _clearAllImages,
                            child: Text(
                              "Clear all",
                              style: StyleText.fontSize12Weight400.copyWith(
                                color: Colors.red,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      // Image thumbnails grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: !kpIsPhoneLayout(context) ? 4 : 3,
                          crossAxisSpacing: 8.w,
                          mainAxisSpacing: 8.h,
                          childAspectRatio: 1,
                        ),
                        itemCount: selectedImages.length,
                        itemBuilder: (context, index) {
                          return _buildImageThumbnail(
                            selectedImages[index],
                            index,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  //////////////////////// Responsive Field /////////////////////////
  Widget buildResponsiveFields({
    required BuildContext context,
    required Widget left,
    required Widget right,
  }) {
    final isMobile = kpIsPhoneLayout(context);
    if (isMobile) {
      return Column(children: [left, SizedBox(height: 10.h), right]);
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

  //////////////////////// Product Detail Widgets /////////////////////////
  Widget quantityWidget(ProductDetailsData productDetail) {
    return CustomValidatedTextFieldMaster(
      enabled: true,
      label: S.of(context).quantity,
      controller: productDetail.quantityController,
      hint: S.of(context).quantity,
      onChanged: (_) {
        setState(() {});
        _calculateOrderTotal(); // Add this line
      },
      height: 36,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: true,
    );
  }

  Widget unitCostWidget(ProductDetailsData productDetail) {
    return CustomValidatedTextFieldMaster(
      enabled: true,
      label: S.of(context).unitCost,
      controller: productDetail.unitCostController,
      hint: S.of(context).unitCost,
      onChanged: (_) {
        setState(() {});
        _calculateOrderTotal(); // Add this line
      },
      height: 36,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
    );
  }

  Widget currencyWidget(ProductDetailsData productDetail) {
    return CustomDropdown<String>(
      items: (ConstantLists.currencyList())
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value: productDetail.selectedCurrency,
      onChanged: (val) {
        setState(() => productDetail.selectedCurrency = val);
        _calculateOrderTotal();
      },
      label: S.of(context).currency,
      hint: S.of(context).currency,
      height: 36,
      fillColor: AppColors.background,
    );
  }

  Widget vatWidget(ProductDetailsData productDetail) {
    return CustomValidatedTextFieldMaster(
      enabled: true,
      onlyDigits: true,
      label: S.of(context).vat,
      controller: productDetail.vatController, // Fix: was discountController
      hint: S.of(context).vat,
      onChanged: (_) {
        setState(() {});
        _calculateOrderTotal();
      },
      height: 36,
      textDirection: ui.TextDirection.ltr,
    );
  }

  Widget discountPercentageWidget(ProductDetailsData productDetail) {
    return CustomValidatedTextFieldMaster(
      enabled: true,
      label: S.of(context).discountPercentage,
      controller: productDetail.discountController,
      hint: S.of(context).discountPercentage,
      onChanged: (_) {
        setState(() {});
        _calculateOrderTotal(); // Add this line
      },
      height: 36,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
    );
  }

  //////////////////////// Other Widget Methods /////////////////////////
  Widget expectedDeliveryWidget() {
    return CustomDateField(
      value: DateFormat('d/M/yyyy').tryParse((selectedExpectedDelivery) ?? ''),
      onChanged: (date) {
        if (date == null) return;
        ((val) => setState(() => selectedExpectedDelivery = val))(
            DateFormat('d/M/yyyy').format(date));
      },
      label: S.of(context).expectedDelivery,
      hint: S.of(context).expectedDelivery,
      height: 36,
      fillColor: AppColors.background,
    );
  }

  Widget deliveryMethodWidget() {
    return CustomDropdown<String>(
      items: (ConstantLists.deliveryMethod())
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value: selectedDeliveryMethod,
      onChanged: (val) {
        debugPrint("🚚 DELIVERY METHOD SELECTED:");
        debugPrint("Value: '$val'");
        debugPrint("Type: ${val.runtimeType}");
        debugPrint("Length: ${val.length}");

        setState(() {
          selectedDeliveryMethod = val;
          if (val == 'Pick Up' ||
              val == 'pickup' ||
              val.toLowerCase() == 'pick up') {
            debugPrint("✅ PICKUP DETECTED - Clearing shipping");
            shippingController.text = '0.00';
          } else {
            debugPrint("❌ NOT PICKUP - Keeping shipping field");
          }
        });
        _calculateOrderTotal();
      },
      label: S.of(context).deliveryMethod,
      hint: S.of(context).selectDeliveryMethod,
      height: 36,
      fillColor: AppColors.background,
    );
  }

  Widget storageLocationWidget() {
    final bool showFirstRowQuantity = storageAllocations.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: storageAllocations.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            final alloc = storageAllocations[index];
            final bool showQuantity = index == 0 ? showFirstRowQuantity : true;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Storage dropdown
                Expanded(
                  child: CustomDropdown<String>(
                    items: (_storageLocationItems)
                        .map((e) => DropdownItem<String>(
                            value: e['key'] ?? '', label: e['value'] ?? ''))
                        .toList(),
                    value: alloc.locationId,
                    onChanged: (val) => setState(() => alloc.locationId = val),
                    label: S.of(context).storageLocation,
                    hint: _storageLocationsLoading
                        ? S.of(context).storageLocation
                        : S.of(context).storageLocation,
                    height: 36,
                    fillColor: AppColors.background,
                  ),
                ),

                if (showQuantity) SizedBox(width: 12.w),

                // Quantity (hidden on first row until +storage clicked)
                if (showQuantity)
                  Expanded(
                    child: CustomValidatedTextFieldMaster(
                      enabled: true,
                      label: S.of(context).quantity,
                      controller: alloc.quantity,
                      hint: S.of(context).quantity,
                      onChanged: (_) => setState(() {}),
                      height: 36,
                      textDirection: ui.TextDirection.ltr,
                      onlyDigits: true,
                    ),
                  ),

                if (showQuantity) SizedBox(width: 8.w),
                if (showQuantity)
                  // Remove
                  Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: SizedBox(
                      height: 36.h,
                      child: GestureDetector(
                        onTapDown:
                            (storageAllocations.length == 1 && index == 0)
                                ? null
                                : (_) => HapticController.high(),
                        onTap: (storageAllocations.length == 1 && index == 0)
                            ? null
                            : () => _removeStorageAllocation(index),
                        child: Container(
                          width: 15.w,
                          height: 15.h,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget paymentMethodWidget() {
    return CustomDropdown<String>(
      items: (ConstantLists.paymentMethod())
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value: selectedPaymentMethod,
      onChanged: (val) => setState(() => selectedPaymentMethod = val),
      label: S.of(context).paymentType,
      hint: S.of(context).selectPaymentMethod,
      height: 36,
      fillColor: AppColors.background,
    );
  }

  Widget shippingWidget() {
    return CustomValidatedTextFieldMaster(
      enabled: true,
      label: S.of(context).shipping,
      controller: shippingController,
      hint: S.of(context).shipping,
      onChanged: (_) {
        setState(() {});
        _calculateOrderTotal(); // Add this line
      },
      height: 36,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
    );
  }

  Widget orderValueWidget() {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).orderValue,
          style: StyleText.fontSize12Weight500.copyWith(
            color: AppColors.blackButton,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          width: double.infinity,
          height: 36.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: lightMode
                ? AppColors.grey.withValues(alpha: 0.3)
                : AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              orderValueController.text.isEmpty
                  ? "0.00"
                  : orderValueController.text,
              style: StyleText.fontSize12Weight500.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget supplierNameWidget() {
    return CustomDropdown<String>(
      items: (_supplierItems)
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value: selectedSupplierName,
      onChanged: _onSupplierSelected,
      label: S.of(context).supplierName,
      hint: _suppliersLoading
          ? (S.of(context).selectSupplierName)
          : S.of(context).selectSupplierName,
      height: 36,
      fillColor: AppColors.background,
    );
  }

  Widget supplierIdWidget() {
    return CustomValidatedTextFieldMaster(
      enabled: true,
      label: S.of(context).supplierID,
      controller: supplierIdController,
      hint: S.of(context).supplierID,
      onChanged: (_) => setState(() {}),
      height: 36,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
    );
  }

  Widget advancedPaymentWidget() {
    return CustomDropdown<String>(
      items: (orderTypeList)
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value: selectedAdvancedPayment,
      onChanged: (val) => setState(() => selectedAdvancedPayment = val),
      label: S.of(context).advancedPayment,
      hint: S.of(context).selectAdvancedPayment,
      height: 36,
      fillColor: AppColors.background,
    );
  }

  Widget methodOfPaymentWidget() {
    return CustomDropdown<String>(
      items: (orderTypeList)
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value: selectedMethodOfPayment,
      onChanged: (val) => setState(() => selectedMethodOfPayment = val),
      label: S.of(context).methodOfPayment,
      hint: S.of(context).selectMethodOfPayment,
      height: 36,
      fillColor: AppColors.background,
    );
  }

  Widget beneficiaryNameWidget() {
    return CustomValidatedTextFieldMaster(
      enabled: true,
      label: S.of(context).beneficiaryName,
      controller: beneficiaryNameController,
      hint: S.of(context).beneficiaryName,
      onChanged: (_) => setState(() {}),
      height: 36,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
    );
  }

  Widget beneficiaryBankNameWidget() {
    return CustomValidatedTextFieldMaster(
      enabled: true,
      label: S.of(context).beneficiaryBankName,
      controller: beneficiaryBankNameController,
      hint: S.of(context).beneficiaryBankName,
      onChanged: (_) => setState(() {}),
      height: 36,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
    );
  }

  Widget beneficiaryBankAccountNumberIBANWidget() {
    return CustomValidatedTextFieldMaster(
      enabled: true,
      label: S.of(context).iban,
      controller: ibanController,
      hint: S.of(context).iban,
      onChanged: (_) => setState(() {}),
      height: 36,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
    );
  }

  Widget bankSWIFTBICCodeWidget() {
    return CustomValidatedTextFieldMaster(
      enabled: true,
      label: S.of(context).swiftCode,
      controller: swiftCodeController,
      hint: S.of(context).swiftCode,
      onChanged: (_) => setState(() {}),
      height: 36,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
    );
  }

  Widget bankAddressWidget() {
    return CustomValidatedTextFieldMaster(
      enabled: true,
      label: S.of(context).bankAddress,
      controller: bankAddressController,
      hint: S.of(context).bankAddress,
      onChanged: (_) => setState(() {}),
      height: 72,
      maxLines: 3,
      showCharCount: true,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
    );
  }

  @override
  void dispose() {
    orderIdController.dispose();
    shippingController.dispose();
    orderValueController.dispose();
    supplierIdController.dispose();
    beneficiaryNameController.dispose();
    beneficiaryBankNameController.dispose();
    ibanController.dispose();
    swiftCodeController.dispose();
    bankAddressController.dispose();
    selectedImages.clear();

    for (var productDetail in productDetails) {
      productDetail.dispose();
    }

    super.dispose();
  }

  void _showPreviewConfirmationDialog(BuildContext rootContext) {
    showAppDialog(
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
            width: 410.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Question icon or custom icon
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lot_status_confirmation.json',
                  width: 70.w,
                  height: 70.h,
                  fit: BoxFit.scaleDown,
                  repeat: true,
                  animate: true,
                ),
                SizedBox(height: 20.sp),
                Text(
                  S.of(context).addOrder,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 24.sp),
                Text(
                  S.of(context).areYouSureAddingOrder,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 24.sp),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // No Button
                    customButton(
                      title: S.of(context).no,
                      function: () {
                        Navigator.of(dialogContext).pop(); // Close dialog
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                      width: 150.w,
                      height: 38.h,
                      radius: 8.r,
                      color: AppColors.grey,
                    ),
                    // Yes Button
                    customButton(
                      title: S.of(context).yes,
                      function: () async {
                        Navigator.of(dialogContext).pop(); // Close dialog
                        // Proceed with upload
                        await _uploadOrderData(rootContext);
                      },
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textButton,
                      ),
                      width: 150.w,
                      height: 38.h,
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

  // Error dialog
  void _showErrorDialog(BuildContext rootContext, String errorMessage) {
    showAppDialog(
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
            width: 410.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 60.sp, color: AppColors.red),
                SizedBox(height: 20.sp),
                Text(
                  S.of(context).uploadFailed,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 12.sp),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color:
                        Theme.of(dialogContext).brightness == Brightness.light
                            ? AppColors.secondaryText
                            : AppColors.white,
                  ),
                ),
                SizedBox(height: 20.sp),
                customButton(
                  title: S.of(context).ok,
                  function: () {
                    Navigator.of(dialogContext).pop();
                  },
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textButton,
                  ),
                  width: 120.w,
                  height: 38.h,
                  radius: 8.r,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /////////////////////////// pick image ///////////////////////////

  Future<void> _pickImages() async {
    try {
      setState(() {
        isSelectingFiles = true;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        allowedExtensions: null, // Will accept all image formats
      );

      if (result != null) {
        List<File> newFiles = result.paths.map((path) => File(path!)).toList();

        setState(() {
          // Add new images to existing list (avoiding duplicates)
          for (File newFile in newFiles) {
            bool isDuplicate = selectedImages.any(
              (existingFile) => existingFile.path == newFile.path,
            );

            if (!isDuplicate) {
              selectedImages.add(newFile);
            }
          }
        });

        // Optional: Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${newFiles.length} image(s) added successfully"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Handle error
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error selecting images: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        isSelectingFiles = false;
      });
    }
  }

  void _clearAllImages() {
    setState(() {
      selectedImages.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("All images cleared"),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Image removed"),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _buildImageThumbnail(File imageFile, int index) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(
          color: lightMode
              ? AppColors.secondaryText.withValues(alpha: 0.3)
              : AppColors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Stack(
        children: [
          // Image thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.file(
                imageFile,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: lightMode
                        ? AppColors.grey.withValues(alpha: 0.3)
                        : AppColors.background,
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        color: lightMode
                            ? AppColors.secondaryText
                            : AppColors.white,
                        size: 20.sp,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Remove button
          Positioned(
            top: 2.h,
            right: 2.w,
            child: GestureDetector(
              onTapDown: (_) => HapticController.high(),
              onTap: () => _removeImage(index),
              child: Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(Icons.close, size: 14.sp, color: Colors.white),
              ),
            ),
          ),

          // File name overlay (optional)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4.r),
                  bottomRight: Radius.circular(4.r),
                ),
              ),
              child: Text(
                imageFile.path.split('/').last,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /////////////////////////// pick image ///////////////////////////

  //////////////////////////// function for upload to firebase ///////////////////////////////

  Future<List<String>> _uploadImagesToStorage(String orderId) async {
    if (selectedImages.isEmpty) return [];

    List<String> downloadUrls = [];

    try {
      for (int i = 0; i < selectedImages.length; i++) {
        File imageFile = selectedImages[i];

        // Create unique filename
        String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${i}_${path.basename(imageFile.path)}';

        // Updated storage path to match the Firestore structure
        Reference storageRef = FirebaseStorage.instance.ref().child(
              'Demo/${InventoryPaths.companyId}/order/$orderId/attachments/$fileName',
            );

        // Upload file
        UploadTask uploadTask = storageRef.putFile(imageFile);

        // Wait for upload to complete
        TaskSnapshot snapshot = await uploadTask;

        // Get download URL
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);

        debugPrint('Image uploaded successfully: $downloadUrl');
        debugPrint(
          'Storage path: Demo/${InventoryPaths.companyId}/order/$orderId/attachments/$fileName',
        );
      }

      return downloadUrls;
    } catch (e) {
      debugPrint('Error uploading images: $e');
      throw Exception('Failed to upload images: $e');
    }
  }

  // Updated _uploadOrderData method with image upload
  Future<void> _uploadOrderData(BuildContext rootContext) async {
    try {
      debugPrint('🚀 Starting order upload process...');

      // Validate form data first
      if (!_validateFormData()) {
        debugPrint('❌ Form validation failed');
        return;
      }

      debugPrint('✅ Form validation passed');

      // Show loading dialog
      _showLoadingDialog(rootContext);

      // Generate order ID
      String orderId = orderIdController.text.isNotEmpty
          ? orderIdController.text
          : "ORD_${DateTime.now().millisecondsSinceEpoch}";

      debugPrint('📝 Order ID: $orderId');

      // Calculate order total
      _calculateOrderTotal();
      debugPrint('💰 Order value: ${orderValueController.text}');

      // Upload images
      List<String> imageUrls = [];
      if (selectedImages.isNotEmpty) {
        debugPrint('📸 Uploading ${selectedImages.length} images...');
        imageUrls = await _uploadImagesToStorage(orderId);
        debugPrint('✅ Images uploaded successfully: ${imageUrls.length} URLs');
      } else {
        debugPrint('📸 No images to upload');
      }

      // Save ProductModels
      debugPrint('📦 Preparing product models...');
      List<ProductModel> updatedProducts = await _saveCompleteProductModels(
        imageUrls,
      );
      debugPrint('✅ ${updatedProducts.length} products prepared');

      // Save to Firestore - KEEP YOUR EXISTING PATH
      debugPrint('💾 Saving to Firestore...');
      await _saveOrderToFirestore(orderId, updatedProducts, imageUrls);
      debugPrint(
          '✅ Order saved to Firestore: /Demo/${InventoryPaths.companyId}/order/$orderId');

      // Delete draft if editing
      if (widget.isDraftEdit && widget.draftId != null) {
        await _deleteDraft(widget.draftId!);
        debugPrint('🗑️ Draft deleted: ${widget.draftId}');
      }

      // IMPORTANT: Close loading dialog BEFORE showing success
      if (mounted) {
        if (!rootContext.mounted) return;
        Navigator.of(rootContext).pop();
        debugPrint('🔄 Loading dialog closed');
      }

      // Small delay to ensure dialog closes
      await Future.delayed(Duration(milliseconds: 300));

      // Show success dialog - IMPROVED VERSION
      if (mounted) {
        debugPrint('🎉 Showing success dialog...');
        if (!rootContext.mounted) return;
        await _showOrderSuccessDialog(rootContext, orderId);
      }
    } catch (error) {
      debugPrint('❌ ERROR in _uploadOrderData: $error');
      debugPrint('📍 Stack trace: ${StackTrace.current}');

      // Close loading dialog
      if (mounted) {
        try {
          if (!rootContext.mounted) return;
          Navigator.of(rootContext).pop();
        } catch (e) {
          debugPrint('⚠️ Could not close loading dialog: $e');
        }
      }

      // Show error dialog
      if (mounted) {
        if (!rootContext.mounted) return;
        _showErrorDialog(rootContext, error.toString());
      }
    }
  }

  Future<void> _showOrderSuccessDialog(
    BuildContext rootContext,
    String orderId,
  ) async {
    return showAppDialog(
      context: rootContext,
      barrierDismissible: false, // Force user to see the success
      builder: (dialogContext) => PopScope(
        canPop: false, // Prevent back button dismiss
        child: Dialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success animation
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
                  width: 120.sp,
                  height: 120.sp,
                  fit: BoxFit.scaleDown,
                  repeat: false, // Play once
                  animate: true,
                ),
                SizedBox(height: 20.sp),

                // Success title
                Text(
                  'Order Created Successfully!',
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 12.sp),

                // Order ID display
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Order ID: $orderId',
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: Colors.green[700],
                    ),
                  ),
                ),
                SizedBox(height: 16.sp),

                // Subtitle
                Text(
                  'Your order has been submitted and saved successfully.',
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color:
                        Theme.of(dialogContext).brightness == Brightness.light
                            ? AppColors.secondaryText
                            : AppColors.white,
                  ),
                ),
                SizedBox(height: 24.sp),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // View Orders button
                    customButton(
                      title: 'View Orders',
                      function: () {
                        Navigator.of(
                          dialogContext,
                        ).pop(); // Close success dialog
                        // Navigate to orders list
                        navigateTo(rootContext, InventoryManagement());
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                      width: 120.w,
                      height: 38.h,
                      radius: 8.r,
                      color: AppColors.grey,
                    ),

                    // Done button
                    customButton(
                      title: 'Done',
                      function: () {
                        Navigator.of(
                          dialogContext,
                        ).pop(); // Close success dialog
                        Navigator.of(
                          rootContext,
                        ).pop(); // Go back to previous screen
                      },
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textButton,
                      ),
                      width: 120.w,
                      height: 38.h,
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

  Future<void> _verifyOrderSaved(String orderId) async {
    try {
      debugPrint('🔍 Verifying order was saved...');

      final docSnapshot = await FirebaseFirestore.instance
          .collection("Demo")
          .doc(InventoryPaths.companyId)
          .collection("order") // CHANGED: Use main order collection
          .doc(orderId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        debugPrint('✅ ORDER VERIFICATION SUCCESS:');
        debugPrint('📄 Document ID: ${docSnapshot.id}');
        debugPrint('📊 Fields count: ${data.keys.length}');
        debugPrint(
          '🛍️ Products count: ${(data['products'] as List?)?.length ?? 0}',
        );
        debugPrint('💰 Order value: ${data['orderValue']}');
        debugPrint('👤 Created by: ${data['createdBy']?['email']}');
        debugPrint('⏰ Created at: ${data['createdAt']}');
        debugPrint(
            '🗂️ Path: /Demo/${InventoryPaths.companyId}/order/$orderId');

        return; // Order exists, success!
      } else {
        debugPrint(
            '❌ ORDER VERIFICATION FAILED: Document does not exist at path');
        throw Exception('Order was not saved to Firestore');
      }
    } catch (e) {
      debugPrint('❌ ERROR verifying order: $e');
      throw Exception('Could not verify order was saved: $e');
    }
  }

  Future<void> _saveOrderToFirestore(
    String orderId,
    List<ProductModel> products,
    List<String> imageUrls,
  ) async {
    try {
      debugPrint('💾 Starting Firestore save...');

      // Get current user email
      final userEmail = InventoryPaths.userEmail;
      debugPrint('Using user email: $userEmail');

      // Prepare storage allocations
      final storageAllocationsPayload = storageAllocations
          .map(
            (a) => {
              'storageLocationId': a.locationId ?? '',
              'quantity': a.quantity.text,
              'locationName': _storageLocationItems.firstWhere(
                    (item) => item['key'] == a.locationId,
                    orElse: () => {'value': ''},
                  )['value'] ??
                  '',
            },
          )
          .toList();

      // Prepare complete order data - THIS IS THE orderData VARIABLE
      final Map<String, dynamic> orderData = {
        "orderId": orderId,
        "orderType": selectedOrderType ?? '',
        "status": "Open",
        "orderDate": DateTime.now().toIso8601String(),
        "expectedDelivery": selectedExpectedDelivery ?? '',
        "deliveryMethod": selectedDeliveryMethod ?? '',
        "paymentMethod": selectedPaymentMethod ?? '',
        "shipping":
            shippingController.text.isEmpty ? "0" : shippingController.text,
        "orderValue": orderValueController.text,
        "supplierName": selectedSupplierName ?? '',
        "supplierId": supplierIdController.text,
        "deliverySelectedData": deliverySelectedData ?? '',
        "orderNote": orderNoteController.text,
        "attachmentUrls": imageUrls,
        "storageAllocations": storageAllocationsPayload,
        "isDraft": false,
        "createdAt": FieldValue.serverTimestamp(),
        "lastModified": FieldValue.serverTimestamp(),

        "createdBy": {
          "firstName": employeeEntity.firstName ?? 'Unknown',
          "lastName": employeeEntity.lastName ?? 'User',
          "email": employeeEntity.email ?? 'unknown@email.com',
          "department": employeeEntity.departmentId ?? '',
          "jobTitle": employeeEntity.title ?? '',
        },

        "products": products.map((p) => p.toJson()).toList(),

        // Bank transfer details if applicable
        if (selectedPaymentMethod == 'bank_transfer') ...{
          "advancedPayment": selectedAdvancedPayment ?? '',
          "methodOfPayment": selectedMethodOfPayment ?? '',
          "beneficiaryName": beneficiaryNameController.text,
          "beneficiaryBankName": beneficiaryBankNameController.text,
          "beneficiaryAccountIban": ibanController.text,
          "bankSwiftBicCode": swiftCodeController.text,
          "bankAddress": bankAddressController.text,
        },

        // Pickup location details if applicable
        if (selectedPickupAddress != null)
          "selectedPickupAddress": Map<String, dynamic>.from(
            selectedPickupAddress!,
          ),

        if (selectedPickupWarehouse != null)
          "selectedPickupWarehouse": Map<String, dynamic>.from(
            selectedPickupWarehouse!,
          ),
      };

      debugPrint('📝 Order data prepared with ${orderData.keys.length} fields');

      // FIXED: Save to the correct main order collection path
      final docRef = FirebaseFirestore.instance
          .collection("Demo")
          .doc(InventoryPaths.companyId)
          .collection("order") // CHANGED: Use main order collection
          .doc(orderId);

      await docRef.set(orderData);
      debugPrint(
          '✅ Order saved to main path: /Demo/${InventoryPaths.companyId}/order/$orderId');

      // ALSO save products to user's products collection
      for (int i = 0; i < products.length; i++) {
        final product = products[i];

        final productDocRef = FirebaseFirestore.instance
            .collection("Demo")
            .doc(InventoryPaths.companyId)
            .collection("InventoryUser")
            .doc(userEmail)
            .collection("products")
            .doc(product.productId.value);

        await productDocRef.set(product.toJson());
        debugPrint(
          '✅ Product ${product.productId.value} saved to user products collection',
        );
      }

      // Verify the save worked with updated path
      await _verifyOrderSaved(orderId);
      debugPrint('✅ Order save verification complete');
    } catch (e) {
      debugPrint('❌ Error in _saveOrderToFirestore: $e');
      throw Exception('Failed to save order: $e');
    }
  }

  // 5. CHECK IF ORDERS ARE ACTUALLY BEING CREATED
  // Add this method to check your Firestore collection
  Future<void> _debugCheckOrders() async {
    try {
      debugPrint('🔍 Checking existing orders...');

      final snapshot = await FirebaseFirestore.instance
          .collection("Demo")
          .doc(InventoryPaths.companyId)
          .collection("order")
          .limit(10)
          .get();

      debugPrint('📊 Found ${snapshot.docs.length} orders in collection');

      for (var doc in snapshot.docs) {
        final data = doc.data();
        debugPrint('📄 Order: ${doc.id}');
        debugPrint('   Type: ${data['orderType']}');
        debugPrint('   Value: ${data['orderValue']}');
        debugPrint('   Status: ${data['status']}');
        debugPrint('   Created: ${data['createdAt']}');
        debugPrint('---');
      }
    } catch (e) {
      debugPrint('❌ Error checking orders: $e');
    }
  }

  // 6. ADD DEBUG BUTTON TO YOUR UI (temporary)
  // Add this button to your build method for testing
  Widget debugButton() {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: customButton(
        title: 'Debug: Check Orders',
        function: _debugCheckOrders,
        wrapContent: true,
      ),
    );
  }

  // 7. IMPROVED VALIDATION WITH SPECIFIC ERROR MESSAGES
  bool _validateFormData() {
    List<String> errors = [];

    // Check order basic fields
    if (orderIdController.text.isEmpty) errors.add('Order ID is required');
    if (selectedOrderType == null) errors.add('Order type is required');
    if (selectedPaymentMethod == null) errors.add('Payment method is required');
    if (selectedDeliveryMethod == null) {
      errors.add('Delivery method is required');
    }
    if (selectedExpectedDelivery == null) {
      errors.add('Expected delivery is required');
    }

    // Check products
    for (int i = 0; i < productDetails.length; i++) {
      final detail = productDetails[i];
      if (detail.quantityController.text.isEmpty) {
        errors.add('Product ${i + 1}: Quantity is required');
      }
      if (detail.unitCostController.text.isEmpty) {
        errors.add('Product ${i + 1}: Unit cost is required');
      }
      if (detail.selectedCurrency == null) {
        errors.add('Product ${i + 1}: Currency is required');
      }
    }

    // Check supplier
    if (selectedSupplierName == null) {
      errors.add('Supplier selection is required');
    }

    if (errors.isNotEmpty) {
      String errorMessage =
          'Please fix the following issues:\n\n${errors.map((e) => '• $e').join('\n')}';

      _showValidationError(errorMessage);
      return false;
    }

    return true;
  }

  void _showValidationError(String message) {
    CustomDialogManager.showMessage(
      context: context,
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
      title: S.of(context).validationError,
      subtitle: message,
      closeAfter: const Duration(seconds: 5),
    );
  }

  Future<void> _deleteDraft(String draftId) async {
    try {
      final userEmail = InventoryPaths.userEmail;

      await FirebaseFirestore.instance
          .collection("Demo")
          .doc(InventoryPaths.companyId)
          .collection("InventoryUser")
          .doc(userEmail) // Use current user email
          .collection("drafts")
          .doc(draftId)
          .delete();

      debugPrint('Draft deleted successfully from user path: $draftId');
    } catch (e) {
      debugPrint('Error deleting draft: $e');
    }
  }

  Future<List<ProductModel>> _saveCompleteProductModels(
    List<String> imageUrls,
  ) async {
    if (widget.products == null) return [];

    final List<ProductModel> updatedProducts = [];

    // Prepare storage allocations data with location names
    final storageData = storageAllocations.map((allocation) {
      // Find storage location name
      String locationName = '';
      for (var item in _storageLocationItems) {
        if (item['key'] == allocation.locationId) {
          locationName = item['value'] ?? '';
          break;
        }
      }

      return {
        'locationId': allocation.locationId ?? '',
        'locationName': locationName,
        'quantity': allocation.quantity.text,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }).toList();

    // Convert storage data to JSON string
    final storageAllocationsJson = jsonEncode(storageData);

    for (int i = 0; i < widget.products!.length; i++) {
      final originalProduct = widget.products![i];
      final detailsData = productDetails[i];
      var employeeEntity =
          Get.find<MainCoreEmployeeController>().employeeEntity!;

      final updatedProduct = originalProduct.copyWith(
        quantity: FieldWithTimestamp(
          value: detailsData.quantityController.text,
          timestamp: DateTime.now(),
        ),

        firstNameCreator: FieldWithTimestamp(
          value: employeeEntity.firstName!,
          timestamp: DateTime.now(),
        ),
        lastNameCreator: FieldWithTimestamp(
          value: employeeEntity.lastName!,
          timestamp: DateTime.now(),
        ),
        firstNameArCreator: FieldWithTimestamp(
          value: employeeEntity.firstNameInArabic!,
          timestamp: DateTime.now(),
        ),
        lastNameArCreator: FieldWithTimestamp(
          value: employeeEntity.lastNameInArabic!,
          timestamp: DateTime.now(),
        ),
        departmentCreator: FieldWithTimestamp(
          value: employeeEntity.departmentId!,
          timestamp: DateTime.now(),
        ),
        departmentArCreator: FieldWithTimestamp(
          value: employeeEntity.departmentId!,
          timestamp: DateTime.now(),
        ),
        jobTitleCreator: FieldWithTimestamp(
          value: employeeEntity.title!,
          timestamp: DateTime.now(),
        ),
        jobTitleArCreator: FieldWithTimestamp(
          value: employeeEntity.titleInArabic!,
          timestamp: DateTime.now(),
        ),
        emailCreator: FieldWithTimestamp(
          value: employeeEntity.email!,
          timestamp: DateTime.now(),
        ),
        phoneCreator: FieldWithTimestamp(
          value: employeeEntity.mobilePhone!.phone,
          timestamp: DateTime.now(),
        ),

        orderId: FieldWithTimestamp(
          value: orderIdController.text,
          timestamp: DateTime.now(),
        ),

        orderType: FieldWithTimestamp(
          value: selectedOrderType ?? originalProduct.orderType.value,
          timestamp: DateTime.now(),
        ),

        unitCost: FieldWithTimestamp(
          value: detailsData.unitCostController.text,
          timestamp: DateTime.now(),
        ),

        currency: FieldWithTimestamp(
          value: detailsData.selectedCurrency ?? '',
          timestamp: DateTime.now(),
        ),

        vat: FieldWithTimestamp(
          value: detailsData.vatController.text,
          timestamp: DateTime.now(),
        ),

        discountPercentage: FieldWithTimestamp(
          value: detailsData.discountController.text,
          timestamp: DateTime.now(),
        ),

        supplierName: FieldWithTimestamp(
          value: selectedSupplierName ?? '',
          timestamp: DateTime.now(),
        ),

        supplierId: FieldWithTimestamp(
          value: supplierIdController.text,
          timestamp: DateTime.now(),
        ),

        shipping: FieldWithTimestamp(
          value: shippingController.text,
          timestamp: DateTime.now(),
        ),

        orderValue: FieldWithTimestamp(
          value: orderValueController.text,
          timestamp: DateTime.now(),
        ),

        paymentMethod: DropdownFieldWithTimestamp(
          value: selectedPaymentMethod ?? '',
          options: [],
          timestamp: DateTime.now(),
        ),

        advancedPayment: DropdownFieldWithTimestamp(
          value: selectedAdvancedPayment ?? '',
          options: [],
          timestamp: DateTime.now(),
        ),

        methodOfPayment: DropdownFieldWithTimestamp(
          value: selectedMethodOfPayment ?? '',
          options: [],
          timestamp: DateTime.now(),
        ),

        beneficiaryName: FieldWithTimestamp(
          value: beneficiaryNameController.text,
          timestamp: DateTime.now(),
        ),

        beneficiaryBankName: FieldWithTimestamp(
          value: beneficiaryBankNameController.text,
          timestamp: DateTime.now(),
        ),

        beneficiaryAccountIban: FieldWithTimestamp(
          value: ibanController.text,
          timestamp: DateTime.now(),
        ),

        bankSwiftBicCode: FieldWithTimestamp(
          value: swiftCodeController.text,
          timestamp: DateTime.now(),
        ),

        bankAddress: FieldWithTimestamp(
          value: bankAddressController.text,
          timestamp: DateTime.now(),
        ),

        orderDate: FieldWithTimestamp(
          value: DateTime.now().toIso8601String(),
          timestamp: DateTime.now(),
        ),

        expectedDelivery: FieldWithTimestamp(
          value: selectedExpectedDelivery ?? "",
          timestamp: DateTime.now(),
        ),

        // Store image URLs in attachmentsImage field
        attachmentsImage: FieldWithTimestamp(
          value: imageUrls.join(','),
          timestamp: DateTime.now(),
        ),

        orderNote: FieldWithTimestamp(
          value: orderNoteController.text,
          timestamp: DateTime.now(),
        ),

        deliveryMethod: DropdownFieldWithTimestamp(
          value: selectedDeliveryMethod ?? '',
          options: [],
          timestamp: DateTime.now(),
        ),

        // Update storage location (main storage location - first one or selected)
        storageLocation: DropdownFieldWithTimestamp(
          value: storageAllocations.isNotEmpty
              ? (storageAllocations.first.locationId ?? '')
              : '',
          options: [],
          timestamp: DateTime.now(),
        ),

        // MOST IMPORTANT: Save all storage allocations as JSON string
        storageAllocations: FieldWithTimestamp(
          value: storageAllocationsJson,
          timestamp: DateTime.now(),
        ),
      );

      updatedProducts.add(updatedProduct);
    }

    return updatedProducts;
  }

  void _showLoadingDialog(BuildContext rootContext) {
    showAppDialog(
      context: rootContext,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: SizedBox(
            width: 300.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleProgressMaster.inline(color: AppColors.primary),
                SizedBox(height: 20.sp),
                Text(
                  selectedImages.isNotEmpty
                      ? "Uploading images and order data..."
                      : "Uploading order data...",
                  style: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                if (selectedImages.isNotEmpty) ...[
                  SizedBox(height: 8.sp),
                  Text(
                    "${selectedImages.length} image(s) to upload",
                    style: StyleText.fontSize12Weight400.copyWith(
                      color:
                          Theme.of(dialogContext).brightness == Brightness.light
                              ? AppColors.secondaryText
                              : AppColors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  //////////////////////////// function for upload to firebase ///////////////////////////////

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
}

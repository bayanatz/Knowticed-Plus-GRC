import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'dart:ui' as ui;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv9_order/presentation/ui/pages/add_new_order_second_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_validated_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/features/inventory/helpers/constants/constant_lists.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/inventory/helpers/inventory_paths.dart';

// Helper class to manage UI controllers for ProductModel
class ProductFormData {
  final TextEditingController productIdController;
  final TextEditingController productTypeController;
  final TextEditingController brandController;
  final TextEditingController modelController;
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedUsageFrequency;
  String? selectedUnitOfMeasurement;
  String? selectedProductType; // Added for individual product type tracking

  ProductFormData()
      : productIdController = TextEditingController(),
        productTypeController = TextEditingController(),
        brandController = TextEditingController(),
        modelController = TextEditingController();

  void dispose() {
    productIdController.dispose();
    productTypeController.dispose();
    brandController.dispose();
    modelController.dispose();
  }

  // Validation method for required fields
  bool isValid() {
    return productIdController.text.isNotEmpty &&
        selectedProductType != null &&
        selectedCategory != null &&
        selectedSubCategory != null &&
        brandController.text.isNotEmpty &&
        modelController.text.isNotEmpty &&
        // If consumable, check additional required fields
        (!isConsumableType() ||
            (selectedUsageFrequency != null &&
                selectedUnitOfMeasurement != null));
  }

  // Helper method to check if this product is consumable
  bool isConsumableType() {
    return selectedProductType == "Consumable";
  }

  // Get missing fields for error message
  List<String> getMissingFields() {
    List<String> missing = [];

    if (productIdController.text.isEmpty) missing.add("Product ID");
    if (selectedProductType == null) missing.add("Product Type");
    if (selectedCategory == null) missing.add("Category");
    if (selectedSubCategory == null) missing.add("Subcategory");
    if (brandController.text.isEmpty) missing.add("Brand");
    if (modelController.text.isEmpty) missing.add("Model");

    if (isConsumableType()) {
      if (selectedUsageFrequency == null) missing.add("Usage Frequency");
      if (selectedUnitOfMeasurement == null) missing.add("Unit of Measurement");
    }

    return missing;
  }

  // Convert form data to ProductModel - FIXED VERSION
  // Fixed version of the toProductModel method - only showing the relevant part
  ProductModel toProductModel(
    String orderId,
    String orderType,
    String orderNote,
  ) {
    final now = DateTime.now();

    FieldWithTimestamp<String> textField(String value) =>
        FieldWithTimestamp<String>(value: value, timestamp: now);

    DropdownFieldWithTimestamp dropdownField(
      String value, [
      List<String>? options,
    ]) =>
        DropdownFieldWithTimestamp(
          value: value,
          options: options ?? [],
          timestamp: now,
        );

    // Combine brand and model for product name
    String combinedProductName =
        '${brandController.text} ${modelController.text}'.trim();

    return ProductModel(
      orderId: textField(orderId),
      orderType: textField(orderType),
      productId: textField(productIdController.text),
      orderNote: textField(orderNote),
      category: textField(selectedCategory ?? ''),
      subCategory: textField(selectedSubCategory ?? ''),
      brand: textField(brandController.text),
      model: textField(modelController.text),
      usageFrequency: textField(selectedUsageFrequency ?? ''),
      unitOfMeasurement: textField(selectedUnitOfMeasurement ?? ''),

      // FIXED: Properly combine brand and model for product name
      productName: textField(combinedProductName),

      // Rest of your fields remain the same...
      quantity: textField(''),
      unitCost: textField(''),
      currency: textField(''),
      supplierName: textField(''),
      expectedLifetime: textField(''),
      expectedDelivery: textField(''),
      deliverySelectedData: textField(''),
      reorderLevel: textField(''),
      reorderQuantity: textField(''),
      additionalNote: textField(''),
      productQuantity: textField(''),
      orderDate: textField(''),
      receivingDate: textField(''),

      storageRequirement: dropdownField(''),
      deliveryMethod: dropdownField(''),
      year: dropdownField(''),
      maintenanceFrequency: dropdownField(''),
      storageLocation: dropdownField(''),
      status: dropdownField(selectedProductType ?? ''),

      requestType: FieldWithTimestamp<List<String>>(value: [], timestamp: now),
      approvalCycle: [],

      // Images
      productSpecificationImage: textField(''),
      productWarrantyImage: textField(''),
      attachmentsImage: textField(''),

      // New fields from updated ProductModel
      paymentMethod: dropdownField(''),
      vat: textField(''),
      discountPercentage: textField(''),
      shipping: textField(''),
      orderValue: textField(''),

      firstNameCreator: textField(''),
      firstNameArCreator: textField(''),
      lastNameArCreator: textField(''),
      lastNameCreator: textField(''),
      departmentCreator: textField(''),
      departmentArCreator: textField(''),
      jobTitleCreator: textField(''),
      jobTitleArCreator: textField(''),
      emailCreator: textField(''),
      phoneCreator: textField(''),
      supplierId: textField(''),
      advancedPayment: dropdownField(''),
      methodOfPayment: dropdownField(''),
      beneficiaryName: textField(''),
      storageAllocations: textField(''),
      beneficiaryBankName: textField(''),
      beneficiaryAccountIban: textField(''),
      bankSwiftBicCode: textField(''),
      bankAddress: textField(''),

      transactionId: textField(''),
    );
  }
}

class AddNewOrderPageFirst extends StatefulWidget {
  const AddNewOrderPageFirst({super.key});

  @override
  State<AddNewOrderPageFirst> createState() => _AddNewOrderPageFirstState();
}

class _AddNewOrderPageFirstState extends State<AddNewOrderPageFirst> {
  /////////////////////////// Controllers ///////////////////////
  TextEditingController orderIdController = TextEditingController();
  TextEditingController orderNoteController = TextEditingController();

  /////////////////////////// Product List ///////////////////////
  List<ProductFormData> products = [
    ProductFormData(),
  ]; // Start with one product

  /////////////////////////// Dropdown Variables ///////////////////////
  String? selectedOrderType;
  String? selectedProductType; // For first product

  /////////////////////////// Firebase Variables ///////////////////////
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isGeneratingIds = false;
  var employeeEntity = Get.find<MainCoreEmployeeController>().employeeEntity!;

  @override
  void initState() {
    super.initState();
    _generateInitialIds();
  }

  // Validation method for the entire form
  bool _isFormValid() {
    // Check required order fields
    if (orderIdController.text.isEmpty || selectedOrderType == null) {
      return false;
    }

    // Check all products are valid
    for (int i = 0; i < products.length; i++) {
      ProductFormData product = products[i];
      // For first product, use global selectedProductType
      if (i == 0) {
        product.selectedProductType = selectedProductType;
      }
      if (!product.isValid()) {
        return false;
      }
    }

    return true;
  }

  // Get all missing fields for error display

  // Show validation error dialog
  Future<void> _showValidationErrorDialog() async {
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
          padding: EdgeInsets.all(15.r),
          child: SizedBox(
            width: 411.sp,
            height: 140,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lot_status_rejected.json',
                  width: 100.sp,
                  height: 100.sp,
                  fit: BoxFit.scaleDown,
                  repeat: true,
                  animate: true,
                ),
                SizedBox(height: 20.sp),
                Text(
                  S.of(context).incompleteForm,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Generate initial IDs when page loads
  Future<void> _generateInitialIds() async {
    setState(() {
      _isGeneratingIds = true;
    });

    try {
      await _debugCollectionContents();

      // Generate unique order ID
      String orderId = await _generateUniqueOrderId();
      orderIdController.text = orderId;

      // Save Order ID to reserve it (like supplier ID)
      await _saveOrderIdToFirestore(orderId);

      // Generate unique product ID for first product
      String productId = await _generateUniqueProductId();
      products[0].productIdController.text = productId;

      // Save Product ID to reserve it (like supplier ID)
      await _saveProductIdToFirestore(productId);

      debugPrint('Final generated IDs:');
      debugPrint('Order ID: $orderId (reserved)');
      debugPrint('Product ID: $productId (reserved)');
    } catch (e) {
      debugPrint('Error generating initial IDs: $e');
      // Fallback
      String fallbackOrderId = _generateFallbackOrderId();
      orderIdController.text = fallbackOrderId;
      await _saveOrderIdToFirestore(fallbackOrderId);

      String fallbackProductId = _generateFallbackProductId();
      products[0].productIdController.text = fallbackProductId;
      await _saveProductIdToFirestore(fallbackProductId);
    }

    setState(() {
      _isGeneratingIds = false;
    });
  }

  // Generate unique Order ID
  Future<String> _generateUniqueOrderId() async {
    String orderId;
    bool isUnique = false;
    int attempts = 0;
    const maxAttempts = 10;

    do {
      attempts++;
      orderId = await _generateOrderId();
      isUnique = await _checkOrderIdUnique(orderId);

      if (attempts >= maxAttempts) {
        // Use timestamp-based fallback if too many attempts
        orderId = _generateFallbackOrderId();
        break;
      }
    } while (!isUnique);

    return orderId;
  }

  // Generate unique Product ID
  Future<String> _generateUniqueProductId() async {
    String productId;
    bool isUnique = false;
    int attempts = 0;
    const maxAttempts = 10;

    do {
      attempts++;
      productId = await _generateProductId();
      isUnique = await _checkProductIdUnique(productId);

      if (attempts >= maxAttempts) {
        // Use timestamp-based fallback if too many attempts
        productId = _generateFallbackProductId();
        break;
      }
    } while (!isUnique);

    return productId;
  }

  Future<String> _generateOrderId() async {
    try {
      final userEmail = InventoryPaths.userEmail;

      // ✅ FIXED: Check Order_Id collection instead of orders collection
      final snapshot = await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('InventoryUser')
          .doc(userEmail)
          .collection('Order_Id') // ✅ Use ID collection only
          .get();

      int highestNumber = 0;

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data();
            String orderId = '';

            // Get order_id field from the ID collection
            if (data.containsKey('order_id')) {
              orderId = data['order_id'] ?? '';
            }

            if (orderId.isNotEmpty &&
                orderId.startsWith('OR') &&
                orderId.length >= 5) {
              String numberPart = orderId.substring(2);
              int? number = int.tryParse(numberPart);
              if (number != null && number > highestNumber) {
                highestNumber = number;
              }
            }
          } catch (e) {
            debugPrint('Error parsing order ID from document: $e');
            continue;
          }
        }
      }

      int nextNumber = highestNumber + 1;
      String formattedNumber = nextNumber.toString().padLeft(3, '0');
      String newOrderId = 'OR$formattedNumber';

      debugPrint('Generated Order ID: $newOrderId (next after $highestNumber)');
      return newOrderId;
    } catch (e) {
      debugPrint('Error generating order ID: $e');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random();
      final number = ((timestamp + random.nextInt(1000)) % 998) + 1;
      return 'OR${number.toString().padLeft(3, '0')}';
    }
  }

  Future<String> _generateProductId() async {
    try {
      final userEmail = InventoryPaths.userEmail;

      // ✅ FIXED: Check Product_Id collection instead of products collection
      final snapshot = await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('InventoryUser')
          .doc(userEmail)
          .collection('Product_Id') // ✅ Use ID collection only
          .get();

      int highestNumber = 0;

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data();
            String productId = '';

            // Get product_id field from the ID collection
            if (data.containsKey('product_id')) {
              productId = data['product_id'] ?? '';
            }

            if (productId.isNotEmpty &&
                productId.startsWith('PR') &&
                productId.length >= 5) {
              String numberPart = productId.substring(2);
              int? number = int.tryParse(numberPart);
              if (number != null && number > highestNumber) {
                highestNumber = number;
              }
            }
          } catch (e) {
            debugPrint('Error parsing product ID from document: $e');
            continue;
          }
        }
      }

      int nextNumber = highestNumber + 1;
      String formattedNumber = nextNumber.toString().padLeft(3, '0');
      String newProductId = 'PR$formattedNumber';

      debugPrint(
          'Generated Product ID: $newProductId (next after $highestNumber)');
      return newProductId;
    } catch (e) {
      debugPrint('Error generating product ID: $e');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random();
      final number = ((timestamp + random.nextInt(1000)) % 998) + 1;
      return 'PR${number.toString().padLeft(3, '0')}';
    }
  }

  String _generateFallbackOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random();
    // Use timestamp + random to avoid collisions
    final number =
        ((timestamp + random.nextInt(1000)) % 998) + 1; // Ensure 1-999
    return 'OR${number.toString().padLeft(3, '0')}';
  }

  String _generateFallbackProductId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random();
    // Use timestamp + random to avoid collisions
    final number =
        ((timestamp + random.nextInt(1000)) % 998) + 1; // Ensure 1-999
    return 'PR${number.toString().padLeft(3, '0')}';
  }

  Future<void> _debugCollectionContents() async {
    try {
      final userEmail = InventoryPaths.userEmail;
      debugPrint('=== DEBUG INFO ===');
      debugPrint('Current user email: $userEmail');

      // Check Order_Id collection
      final orderIdsSnapshot = await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('InventoryUser')
          .doc(userEmail)
          .collection('Order_Id')
          .get();

      debugPrint('Order IDs found: ${orderIdsSnapshot.docs.length}');
      for (var doc in orderIdsSnapshot.docs) {
        final data = doc.data();
        String orderId = data['order_id'] ?? '';
        debugPrint('Found reserved Order ID: $orderId');
      }

      // Check Product_Id collection
      final productIdsSnapshot = await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('InventoryUser')
          .doc(userEmail)
          .collection('Product_Id')
          .get();

      debugPrint('Product IDs found: ${productIdsSnapshot.docs.length}');
      for (var doc in productIdsSnapshot.docs) {
        final data = doc.data();
        String productId = data['product_id'] ?? '';
        debugPrint('Found reserved Product ID: $productId');
      }

      debugPrint('=== END DEBUG ===');
    } catch (e) {
      debugPrint('Debug error: $e');
    }
  }

  // Add new product function with auto-generated product ID
  void _addNewProduct() async {
    setState(() {
      products.add(ProductFormData());
    });

    // Generate and save unique product ID for the new product
    try {
      String productId = await _generateUniqueProductId();
      products.last.productIdController.text = productId;

      // Save the new Product ID to reserve it
      await _saveProductIdToFirestore(productId);

      setState(() {});
    } catch (e) {
      // Fallback
      String fallbackId = _generateFallbackProductId();
      products.last.productIdController.text = fallbackId;
      await _saveProductIdToFirestore(fallbackId);
      setState(() {});
    }
  }

  Future<void> _cleanupReservedIds() async {
    try {
      final userEmail = InventoryPaths.userEmail;

      // Clean up Order ID
      await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('InventoryUser')
          .doc(userEmail)
          .collection('Order_Id')
          .doc(orderIdController.text)
          .delete();

      // Clean up all Product IDs
      for (var product in products) {
        if (product.productIdController.text.isNotEmpty) {
          await _firestore
              .collection('Demo')
              .doc(InventoryPaths.companyId)
              .collection('InventoryUser')
              .doc(userEmail)
              .collection('Product_Id')
              .doc(product.productIdController.text)
              .delete();
        }
      }

      debugPrint('Reserved IDs cleaned up');
    } catch (e) {
      debugPrint('Error cleaning up reserved IDs: $e');
    }
  }

  // Remove product function
  void _removeProduct(int index) {
    if (products.length > 1) {
      // Keep at least one product
      setState(() {
        products[index].dispose(); // Dispose controllers
        products.removeAt(index);
      });
    }
  }

  // Helper method to check if product is consumable
  bool isConsumable(ProductFormData product, int index) {
    if (index == 0) {
      return selectedProductType == "Consumable";
    } else {
      return product.selectedProductType == "Consumable";
    }
  }

  // Convert all form data to ProductModel list - FIXED VERSION
  List<ProductModel> _convertToProductModels() {
    // Update the first product's selectedProductType before conversion
    if (products.isNotEmpty) {
      products[0].selectedProductType = selectedProductType;
    }

    return products
        .map(
          (productForm) => productForm.toProductModel(
            orderIdController.text,
            selectedOrderType ?? '',
            orderNoteController.text, // ✅ FIXED: Pass orderNote as parameter
          ),
        )
        .toList();
  }

  Future<void> _saveOrderIdToFirestore(String orderId) async {
    try {
      final userEmail = InventoryPaths.userEmail;

      await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('InventoryUser')
          .doc(userEmail) // Use dynamic email like supplier
          .collection('Order_Id') // Separate collection just for Order IDs
          .doc(orderId)
          .set({
        'created_at': FieldValue.serverTimestamp(),
        'status': 'active',
        'created_by': userEmail,
        'order_id': orderId, // Just the ID, no full data
      });

      debugPrint('Order ID $orderId reserved in Firestore');
    } catch (e) {
      debugPrint('Error saving Order ID to Firestore: $e');
      rethrow;
    }
  }

  Future<void> _saveProductIdToFirestore(String productId) async {
    try {
      final userEmail = InventoryPaths.userEmail;

      await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('InventoryUser')
          .doc(userEmail) // Use dynamic email like supplier
          .collection('Product_Id') // Separate collection just for Product IDs
          .doc(productId)
          .set({
        'created_at': FieldValue.serverTimestamp(),
        'status': 'active',
        'created_by': userEmail,
        'product_id': productId, // Just the ID, no full data
      });

      debugPrint('Product ID $productId reserved in Firestore');
    } catch (e) {
      debugPrint('Error saving Product ID to Firestore: $e');
      rethrow;
    }
  }

  Future<bool> _checkOrderIdUnique(String orderId) async {
    try {
      final userEmail = InventoryPaths.userEmail;

      DocumentSnapshot doc = await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('InventoryUser')
          .doc(userEmail)
          .collection('Order_Id') // Check the Order_Id collection
          .doc(orderId)
          .get();

      return !doc.exists; // Return true if it doesn't exist (unique)
    } catch (e) {
      debugPrint('Error checking order ID uniqueness: $e');
      return true;
    }
  }

  Future<bool> _checkProductIdUnique(String productId) async {
    try {
      final userEmail = InventoryPaths.userEmail;

      DocumentSnapshot doc = await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('InventoryUser')
          .doc(userEmail)
          .collection('Product_Id') // Check the Product_Id collection
          .doc(productId)
          .get();

      return !doc.exists; // Return true if it doesn't exist (unique)
    } catch (e) {
      debugPrint('Error checking product ID uniqueness: $e');
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventory,
          onFirstTap: () {
            navigateTo(context, InventoryManagement());
          },
          secondTitle: S.of(context).addingNewOrder,
          child: _isGeneratingIds
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleProgressMaster.inline(color: AppColors.primary),
                      SizedBox(height: 16.sp),
                      Text(
                        "Generating unique IDs...",
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      // Order & Product Details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).orderAndProductDetails,
                            style: StyleText.fontSize16Weight600.copyWith(
                              color: AppColors.blackButton,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.sp),

                      // content Page
                      Container(
                        padding: EdgeInsets.all(16.sp),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          children: [
                            // Order fields
                            buildResponsiveFields(
                              context: context,
                              left: orderIdWidget(),
                              right: orderTypeWidget(),
                            ),
                            SizedBox(height: 15.sp),

                            // First Product
                            buildResponsiveFields(
                              context: context,
                              left: productIdWidget(products[0]),
                              right: productTypeWidget(products[0], 0),
                            ),
                            SizedBox(height: 15.sp),
                            buildResponsiveFields(
                              context: context,
                              left: categoryWidget(products[0], 0),
                              right: subCategoryWidget(products[0], 0),
                            ),
                            SizedBox(height: 15.sp),
                            buildResponsiveFields(
                              context: context,
                              left: brandWidget(products[0]),
                              right: modelWidget(products[0]),
                            ),

                            if (isConsumable(products[0], 0)) ...[
                              SizedBox(height: 15.sp),
                              buildResponsiveFields(
                                context: context,
                                left: usageFrequencyWidget(products[0]),
                                right: unitOfMeasurementWidget(products[0]),
                              ),
                            ],

                            SizedBox(height: 15.sp),

                            orderNoteWidget(),
                          ],
                        ),
                      ),

                      // Additional Products in separate containers
                      ...products.skip(1).toList().asMap().entries.map((
                        entry,
                      ) {
                        int actualIndex = entry.key + 1;
                        ProductFormData product = entry.value;
                        return Column(
                          children: [
                            SizedBox(height: 20.sp),
                            // Header with title and remove button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${actualIndex + 1}${actualIndex == 0 ? 'st' : actualIndex == 1 ? 'nd' : actualIndex == 2 ? 'rd' : 'th'} ${S.of(context).productN} Details",
                                  style: StyleText.fontSize16Weight600.copyWith(
                                    color: AppColors.blackButton,
                                  ),
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTapDown: (_) => HapticController.high(),
                                  onTap: () => _removeProduct(actualIndex),
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
                              padding: EdgeInsets.all(16.sp),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Column(
                                children: [
                                  buildResponsiveFields(
                                    context: context,
                                    left: productIdWidget(product),
                                    right: productTypeWidget(
                                      product,
                                      actualIndex,
                                    ),
                                  ),
                                  SizedBox(height: 15.sp),
                                  buildResponsiveFields(
                                    context: context,
                                    left: categoryWidget(
                                      product,
                                      actualIndex,
                                    ),
                                    right: subCategoryWidget(
                                      product,
                                      actualIndex,
                                    ),
                                  ),
                                  SizedBox(height: 15.sp),
                                  buildResponsiveFields(
                                    context: context,
                                    left: brandWidget(product),
                                    right: modelWidget(product),
                                  ),

                                  // Add consumable fields if needed for additional products
                                  if (isConsumable(product, actualIndex)) ...[
                                    SizedBox(height: 15.sp),
                                    buildResponsiveFields(
                                      context: context,
                                      left: usageFrequencyWidget(product),
                                      right: unitOfMeasurementWidget(product),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      }),

                      SizedBox(height: 8.sp),
                      // + product
                      Row(
                        children: [
                          customButtonWithSvg(
                            title: S.of(context).productN,
                            function: _addNewProduct,
                            textStyle: StyleText.fontSize14Weight500.copyWith(
                              color: AppTheme.readableOn(AppColors.blackButton),
                            ),
                            width: 100.w,
                            height: 30.h,
                            space: 16.sp,
                            radius: 4.r,
                            color: AppColors.blackButton,
                            svgColor:
                                AppTheme.readableOn(AppColors.blackButton),
                            image:
                                "assets/icons_assets/main_icons_assets/ic_action_plus.svg",
                            widthImage: 12.w,
                            heightImage: 12.h,
                            colorBorder: Colors.transparent,
                          ),
                        ],
                      ),

                      SizedBox(height: 46.h),
                      // Discard & Next
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Discard
                          customButton(
                            title: S.of(context).discard,
                            function: () async {
                              await _cleanupReservedIds();
                              if (!context.mounted) return;
                              Navigator.pop(context);
                            },
                            textStyle: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.blackButton,
                            ),
                            width: 135.w,
                            height: 38.h,
                            radius: 8.r,
                            color: AppColors.grey,
                          ),

                          // Next
                          customButton(
                            title: S.of(context).next,
                            function: () async {
                              // Validate form before proceeding
                              if (!_isFormValid()) {
                                await _showValidationErrorDialog();
                                return;
                              }

                              // Convert to ProductModel list and pass to second page
                              List<ProductModel> productModels =
                                  _convertToProductModels();

                              navigateTo(
                                context,
                                AddNewOrderSecondToggle(
                                  products:
                                      productModels, // Pass ProductModel list
                                  orderData: {
                                    'orderId': orderIdController.text,
                                    'orderType': selectedOrderType,
                                    'orderNote': orderNoteController.text,
                                  },
                                ),
                              );
                            },
                            textStyle: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textButton,
                            ),
                            width: 135.w,
                            height: 38.h,
                            radius: 8.r,
                            color: !_isFormValid()
                                ? Colors.grey[400]
                                : AppColors.primary,
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

  //////////////////////// Responsive Field /////////////////////////
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
          SizedBox(width: 15.w),
          Expanded(child: right),
        ],
      );
    }
  }

  //////////////////////// Widget Methods /////////////////////////
  Widget orderIdWidget() {
    return CustomValidatedTextFieldMaster(
      enabled: false, // Make it read-only since it's auto-generated
      label: S.of(context).orderID,
      controller: orderIdController,
      hint: "Auto-generated Order ID",
      onChanged: (_) => setState(() {}),
      height: 36,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
    );
  }

  Widget orderTypeWidget() {
    return CustomDropdown<String>(
      items: (ConstantLists.orderOrderList())
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value: selectedOrderType,
      onChanged: (val) {
        setState(() {
          selectedOrderType = val;
        });
      },
      label: S.of(context).orderType,
      hint: S.of(context).selectOrderType,
      height: 36,
      fillColor: AppColors.background,
    );
  }

  Widget productIdWidget(ProductFormData product) {
    return CustomValidatedTextFieldMaster(
      enabled: false, // Make it read-only since it's auto-generated
      label: S.of(context).productID,
      controller: product.productIdController,
      hint: "Auto-generated Product ID",
      onChanged: (_) => setState(() {}),
      height: 36,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
    );
  }

  Widget productTypeWidget(ProductFormData product, [int productIndex = 0]) {
    return CustomDropdown<String>(
      items: (ConstantLists.orderProductList())
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value:
          productIndex == 0 ? selectedProductType : product.selectedProductType,
      onChanged: (val) {
        setState(() {
          if (productIndex == 0) {
            selectedProductType = val;
          } else {
            product.selectedProductType = val;
          }
        });
      },
      label: S.of(context).productType,
      hint: S.of(context).productType,
      height: 36,
      fillColor: AppColors.background,
    );
  }

  Widget categoryWidget(ProductFormData product, int index) {
    return CustomDropdown<String>(
      items: (ConstantLists.orderProductList())
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value: product.selectedCategory,
      onChanged: (val) {
        setState(() {
          product.selectedCategory = val;
        });
      },
      label: S.of(context).category,
      hint: S.of(context).category,
      height: 36,
      fillColor: AppColors.background,
    );
  }

  Widget subCategoryWidget(ProductFormData product, int index) {
    return CustomDropdown<String>(
      items: (ConstantLists.orderProductList())
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value: product.selectedSubCategory,
      onChanged: (val) {
        setState(() {
          product.selectedSubCategory = val;
        });
      },
      label: S.of(context).subcategory,
      hint: S.of(context).subcategory,
      height: 36,
      fillColor: AppColors.background,
    );
  }

  Widget brandWidget(ProductFormData product) {
    return CustomValidatedTextFieldMaster(
      enabled: true,
      label: S.of(context).brand,
      controller: product.brandController,
      hint: S.of(context).brand,
      onChanged: (_) => setState(() {}),
      height: 36,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
    );
  }

  Widget modelWidget(ProductFormData product) {
    return CustomValidatedTextFieldMaster(
      enabled: true,
      label: S.of(context).model,
      controller: product.modelController,
      hint: S.of(context).model,
      onChanged: (_) => setState(() {}),
      height: 36,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
    );
  }

  Widget orderNoteWidget() {
    return CustomValidatedTextFieldMaster(
      enabled: true,
      label: S.of(context).orderNote,
      controller: orderNoteController,
      hint: S.of(context).orderNote,
      onChanged: (_) => setState(() {}),
      height: 72,
      maxLines: 3,
      showCharCount: true,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
    );
  }

  Widget usageFrequencyWidget(ProductFormData product) {
    return CustomDropdown<String>(
      items: (ConstantLists.orderProductList())
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value: product.selectedUsageFrequency,
      onChanged: (val) {
        setState(() {
          product.selectedUsageFrequency = val;
        });
      },
      label: "Usage Frequency",
      hint: "Select Usage Frequency",
      height: 36,
      fillColor: AppColors.background,
    );
  }

  Widget unitOfMeasurementWidget(ProductFormData product) {
    return CustomDropdown<String>(
      items: (ConstantLists.orderProductList())
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value: product.selectedUnitOfMeasurement,
      onChanged: (val) {
        setState(() {
          product.selectedUnitOfMeasurement = val;
        });
      },
      label: "Unit Of Measurement",
      hint: "Select Unit Of Measurement",
      height: 36,
      fillColor: AppColors.background,
    );
  }

  @override
  void dispose() {
    orderIdController.dispose();
    orderNoteController.dispose();

    // Dispose all product controllers
    for (var product in products) {
      product.dispose();
    }

    super.dispose();
  }
}

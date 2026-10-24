import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/upload_order.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_validated_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class AddingProductAssetsDesktopScreen extends StatefulWidget {
  const AddingProductAssetsDesktopScreen({
    super.key,
    required this.orderData,
    this.isConsumable = false,
    this.isEditMode = false,
    required this.isMultiProduct,
    required this.currentProductIndex,
    required this.productModels,
  });

  final Map<String, dynamic> orderData;
  final bool isConsumable;
  final bool isEditMode;
  final bool isMultiProduct;
  final int currentProductIndex;
  final List<ProductModel> productModels;

  @override
  State<AddingProductAssetsDesktopScreen> createState() =>
      _AddingProductAssetsDesktopScreenState();
}

class _AddingProductAssetsDesktopScreenState
    extends State<AddingProductAssetsDesktopScreen> {
  ///////////////////////////////////// Var ///////////////////////////////////////////
  String? selectedMaintenanceFrequency;
  String? selectedStatus;
  String? selectedType;

  // NEW dropdown holders to satisfy ProductModel (no UI changes here)
  String? selectedPaymentMethod;
  String? selectedAdvancedPayment;
  String? selectedMethodOfPayment;
  ///////////////////////////////////// Var ///////////////////////////////////////////

  ///////////////////////////////////// Controller ////////////////////////////////////
  TextEditingController orderIDController = TextEditingController();
  TextEditingController productIDController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController subcategoryController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController unitCostController = TextEditingController();
  TextEditingController currencyController = TextEditingController();
  TextEditingController supplierNameController = TextEditingController();
  TextEditingController usageFrequencyController = TextEditingController();
  TextEditingController unitOfMeasurementController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  TextEditingController typeController = TextEditingController();

  // NEW controllers to cover extra ProductModel fields (no UI changes)
  TextEditingController vatController = TextEditingController();
  TextEditingController discountPercentageController = TextEditingController();
  TextEditingController shippingController = TextEditingController();
  TextEditingController orderValueController = TextEditingController();

  TextEditingController supplierIdController = TextEditingController();
  TextEditingController beneficiaryNameController = TextEditingController();
  TextEditingController beneficiaryBankNameController = TextEditingController();
  TextEditingController beneficiaryAccountIbanController =
      TextEditingController();
  TextEditingController bankSwiftBicCodeController = TextEditingController();
  TextEditingController bankAddressController = TextEditingController();
  TextEditingController transactionIdController = TextEditingController();
  ///////////////////////////////////// Controller ////////////////////////////////////

  ///////////////////////////////// validation of Next ////////////////////////////////
  bool isFormValid() {
    final isArabic = RegExp(r'[\u0600-\u06FF]');
    RegExp(r'[a-zA-Z]');
    final isDigits = RegExp(r'^\d+$');
    final locale = Localizations.localeOf(context).languageCode;

    if (locale == 'en') {
      return orderIDController.text.trim().isNotEmpty &&
          productIDController.text.trim().isNotEmpty &&
          categoryController.text.trim().isNotEmpty &&
          subcategoryController.text.trim().isNotEmpty &&
          brandController.text.trim().isNotEmpty &&
          modelController.text.trim().isNotEmpty &&
          quantityController.text.trim().isNotEmpty &&
          unitCostController.text.trim().isNotEmpty &&
          currencyController.text.trim().isNotEmpty &&
          supplierNameController.text.trim().isNotEmpty &&
          typeController.text.trim().isNotEmpty;
    } else {
      return isArabic.hasMatch(orderIDController.text) &&
          isArabic.hasMatch(productIDController.text) &&
          isArabic.hasMatch(categoryController.text) &&
          isArabic.hasMatch(subcategoryController.text) &&
          isDigits.hasMatch(brandController.text) &&
          isDigits.hasMatch(modelController.text) &&
          isDigits.hasMatch(quantityController.text) &&
          isDigits.hasMatch(unitCostController.text) &&
          isDigits.hasMatch(currencyController.text) &&
          isDigits.hasMatch(supplierNameController.text) &&
          isDigits.hasMatch(typeController.text);
    }
  }
  ///////////////////////////////// validation of Next ////////////////////////////////

  ///////////////////////////////// Upload image //////////////////////////////////////
  File? _selectedImage;
  Uint8List? _webImage;
  String? _imageUrl;
  bool _isUploadingImage = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          setState(() {
            _selectedImage = File(image.path);
            _webImage = null;
          });
        }
        await _uploadImageToFirebase();
      }
    } catch (e) {
      _showErrorDialog('Error picking image: $e');
    }
  }

  void _showErrorDialog(String message) {
    CustomDialogManager.showMessage(
      context: context,
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
      title: S.of(context).error,
      subtitle: message,
      closeAfter: const Duration(seconds: 5),
    );
  }

  Future<void> _uploadImageToFirebase() async {
    if ((_selectedImage == null && _webImage == null) || _isUploadingImage) {
      return;
    }

    setState(() => _isUploadingImage = true);

    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      final String fileName =
          'inventory_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String fullPath = 'inventory__images/$fileName';
      final Reference ref = storage.ref().child(fullPath);

      UploadTask uploadTask;
      if (kIsWeb && _webImage != null) {
        uploadTask = ref.putData(
          _webImage!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else if (_selectedImage != null) {
        uploadTask = ref.putFile(
          _selectedImage!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        throw Exception('No image selected');
      }

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadURL = await snapshot.ref.getDownloadURL();

      setState(() {
        _imageUrl = downloadURL;
        _isUploadingImage = false;
      });

      debugPrint('✅ Image uploaded successfully: $downloadURL');
      if (!mounted) return;
      _showSuccessDialog(context, S.of(context).imageUploadedSuccessfully);
    } catch (e) {
      setState(() => _isUploadingImage = false);
      _showErrorDialog('Failed to upload image: $e');
    }
  }

  Future<void> _showSuccessDialog(
    BuildContext context, [
    String? message,
  ]) async {
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
                  message ?? S.of(context).changingStatus,
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

  Widget uploadImage() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTapDown:
              _isUploadingImage ? null : (_) => HapticController.medium(),
          onTap: _isUploadingImage ? null : _pickImage,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor:
                    lightMode ? Colors.grey[400] : AppColors.background,
                backgroundImage: _getImageProvider(),
                child: _getImageChild(lightMode),
              ),
              if (_imageUrl == null &&
                  _webImage == null &&
                  _selectedImage == null &&
                  !_isUploadingImage)
                Positioned(
                  right: isArabic ? 30.sp : 0,
                  bottom: 0,
                  child: Container(
                    width: 20.sp,
                    height: 20.sp,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: CustomSvgImage.natural(
                      assetPath:
                          "assets/icons_assets/main_icons_assets/ic_media_camera.svg",
                      width: 1.sp,
                      height: 111.sp,
                      color: AppColors.textButton,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              if (_isUploadingImage)
                Positioned(
                  right: isArabic ? 30.sp : 0,
                  bottom: 0,
                  child: Container(
                    width: 20.sp,
                    height: 20.sp,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: 12.sp,
                      height: 12.sp,
                      child: const CircleProgressMaster.inline(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
              if (_imageUrl != null && !_isUploadingImage)
                Align(
                  alignment:
                      isArabic ? Alignment.bottomLeft : Alignment.bottomRight,
                  child: GestureDetector(
                    onTapDown: hapticDown(_removeImage, HapticLevel.high),
                    onTap: _removeImage,
                    child: Container(
                      width: 17.w,
                      height: 17.h,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 10.sp,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  ImageProvider? _getImageProvider() {
    if (_imageUrl != null) {
      return NetworkImage(_imageUrl!);
    } else if (kIsWeb && _webImage != null) {
      return MemoryImage(_webImage!);
    } else if (!kIsWeb && _selectedImage != null) {
      return FileImage(_selectedImage!);
    }
    return null;
  }

  Widget? _getImageChild(bool lightMode) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    if (_imageUrl != null || _webImage != null || _selectedImage != null) {
      return null;
    }
    return Container(
      width: 65.w,
      height: 65.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: lightMode ? Color(0xffD9D9D9) : AppColors.background,
      ),
      child: Center(
        child: CustomSvgImage(
          assetPath:
              "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
          width: 26.sp,
          height: 26.sp,
          color: AppColors.blackButton,
          fit: BoxFit.scaleDown,
        ),
      ),
    );
  }

  Future<void> _deleteImageFromFirebase(String imageUrl) async {
    try {
      final Reference ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }

  Future<void> _removeImage() async {
    if (_imageUrl != null) {
      await _deleteImageFromFirebase(_imageUrl!);
    }
    setState(() {
      _selectedImage = null;
      _webImage = null;
      _imageUrl = null;
    });
    debugPrint('✅ Image removed successfully');
  }

  ///////////////////////////////// Upload image //////////////////////////////////////

  void _loadTabData(Map<String, dynamic> data) {
    debugPrint(data.toString());
    orderIDController.text = data['orderId'] ?? '';
    productIDController.text = data['productId'] ?? '';
    categoryController.text = data['category'] ?? '';
    subcategoryController.text = data['subcategory'] ?? '';
    brandController.text = data['brand'] ?? '';
    modelController.text = data['model'] ?? '';
    quantityController.text = data['quantity'] ?? '';
    unitCostController.text = data['unitCost']?.toString() ?? '';
    currencyController.text = data['currency'] ?? '';
    supplierNameController.text = data['supplierName'] ?? '';
    usageFrequencyController.text = data['usageFrequency'] ?? '';
    unitOfMeasurementController.text = data['unitOfMeasurement'] ?? '';
    selectedMaintenanceFrequency = data['maintenanceFrequency'] ?? '';
    selectedStatus = data['status'] ?? '';
    productNameController.text = data['productName'] ?? '';
    typeController.text = data['type'] ?? '';
  }

  late int _currentDisplayIndex;

  @override
  void initState() {
    super.initState();

    debugPrint(" edit mode or ?  ${widget.isEditMode}");

    debugPrint(" edit mode or ?  ${widget.isEditMode}");
    selectedIndex = widget.currentProductIndex;

    // Initialize the local display index
    _currentDisplayIndex = widget.currentProductIndex;

    // Add this debug call temporarily
    _debugProductData();

    // Add this debug call temporarily
    _debugProductData();

    if (widget.isEditMode && widget.productModels.isNotEmpty) {
      final product = widget.productModels[widget.currentProductIndex];
      _loadDataFromProductModel(product);
    } else {
      final products = List<Map<String, dynamic>>.from(
        widget.orderData['products'] ?? [],
      );
      if (widget.isMultiProduct &&
          products.isNotEmpty &&
          widget.currentProductIndex < products.length) {
        _loadTabData(products[widget.currentProductIndex]);
      } else if (products.isNotEmpty) {
        _loadTabData(products[0]);
      } else {
        _loadTabData(widget.orderData);
      }
    }
  }

  // Load values from ProductModel in edit mode (no UI changes; just seed controllers/dropdowns)
  void _loadDataFromProductModel(ProductModel product) {
    orderIDController.text = product.orderId.value;
    productIDController.text = product.productId.value;
    categoryController.text = product.category.value;
    subcategoryController.text = product.subCategory.value;
    brandController.text = product.brand.value;
    modelController.text = product.model.value;
    quantityController.text = product.quantity.value;
    unitCostController.text = product.unitCost.value;
    currencyController.text = product.currency.value;
    supplierNameController.text = product.supplierName.value;
    usageFrequencyController.text = product.usageFrequency.value;
    unitOfMeasurementController.text = product.unitOfMeasurement.value;
    productNameController.text = product.productName.value;

    // NEW (seed so buildProductModel keeps same values)
    selectedMaintenanceFrequency = product.maintenanceFrequency.value;
    selectedStatus = product.status.value;
    selectedPaymentMethod = product.paymentMethod.value;
    selectedAdvancedPayment = product.advancedPayment.value;
    selectedMethodOfPayment = product.methodOfPayment.value;

    vatController.text = product.vat.value;
    discountPercentageController.text = product.discountPercentage.value;
    shippingController.text = product.shipping.value;
    orderValueController.text = product.orderValue.value;

    supplierIdController.text = product.supplierId.value;
    beneficiaryNameController.text = product.beneficiaryName.value;
    beneficiaryBankNameController.text = product.beneficiaryBankName.value;
    beneficiaryAccountIbanController.text =
        product.beneficiaryAccountIban.value;
    bankSwiftBicCodeController.text = product.bankSwiftBicCode.value;
    bankAddressController.text = product.bankAddress.value;
    transactionIdController.text = product.transactionId.value;
  }

  var employeeEntity = Get.find<MainCoreEmployeeController>().employeeEntity!;

  @override
  void dispose() {
    orderIDController.dispose();
    productIDController.dispose();
    categoryController.dispose();
    subcategoryController.dispose();
    brandController.dispose();
    modelController.dispose();
    quantityController.dispose();
    unitCostController.dispose();
    currencyController.dispose();
    supplierNameController.dispose();
    usageFrequencyController.dispose();
    unitOfMeasurementController.dispose();
    productNameController.dispose();
    typeController.dispose();

    // NEW
    vatController.dispose();
    discountPercentageController.dispose();
    shippingController.dispose();
    orderValueController.dispose();
    supplierIdController.dispose();
    beneficiaryNameController.dispose();
    beneficiaryBankNameController.dispose();
    beneficiaryAccountIbanController.dispose();
    bankSwiftBicCodeController.dispose();
    bankAddressController.dispose();
    transactionIdController.dispose();

    super.dispose();
  }

  ProductModel buildProductModel() {
    final now = DateTime.now();

    // ✅ Get the actual product data from the products array
    final products = List<Map<String, dynamic>>.from(
      widget.orderData["products"] ?? [],
    );
    final currentProduct =
        widget.isMultiProduct && products.length > widget.currentProductIndex
            ? products[widget.currentProductIndex]
            : (products.isNotEmpty ? products[0] : <String, dynamic>{});

    // ✅ Order-level data (where vat, shipping, orderValue, supplierId are stored)
    final orderLevelData = widget.orderData;

    final existingModel = widget.isEditMode && widget.productModels.isNotEmpty
        ? widget.productModels[widget.currentProductIndex]
        : null;

    // Helper function to safely extract value from product-level data
    String extractProductValue(String key) {
      final value = currentProduct[key];
      if (value == null) return '';

      if (value is String) return value;
      if (value is Map<String, dynamic> && value.containsKey('value')) {
        return value['value']?.toString() ?? '';
      }
      return value.toString();
    }

    // ✅ Helper function to extract values from ORDER-level data
    String extractOrderLevelValue(String key) {
      final value = orderLevelData[key];
      if (value == null) return '';

      if (value is String) return value;
      if (value is Map<String, dynamic> && value.containsKey('value')) {
        return value['value']?.toString() ?? '';
      }
      return value.toString();
    }

    // Temporary compatibility function for any remaining references
    String extractOrderValue(String key) {
      return extractProductValue(key);
    }

    // ✅ Helper function - use ORDER-level data for order-level fields
    String getValueOrPreserveFromOrderLevel(
      TextEditingController controller,
      String orderKey,
    ) {
      final controllerValue = controller.text.trim();
      if (controllerValue.isNotEmpty) {
        return controllerValue;
      }

      if (orderLevelData.containsKey(orderKey)) {
        return extractOrderLevelValue(orderKey);
      }

      return '';
    }

    // Helper for dropdowns - check both product and order level
    // String getDropdownValueOrPreserve(String? selectedValue, String orderKey) {
    //   if (selectedValue != null && selectedValue.isNotEmpty) {
    //     return selectedValue;
    //   }
    //
    //   // Check product level first
    //   if (currentProduct.containsKey(orderKey)) {
    //     return extractProductValue(orderKey);
    //   }
    //
    //   // Then check order level
    //   if (orderLevelData.containsKey(orderKey)) {
    //     return extractOrderLevelValue(orderKey);
    //   }
    //
    //   return '';
    // }

    // Helper function to get value from controller or preserve from order data
    String getValueOrPreserve(
      TextEditingController controller,
      String orderKey,
    ) {
      final controllerValue = controller.text.trim();
      if (controllerValue.isNotEmpty) {
        return controllerValue;
      }
      // Preserve from order data if controller is empty
      return extractOrderValue(orderKey);
    }

    // Helper function for dropdown fields - preserve from order data if not set
    String getDropdownValueOrPreserve(String? selectedValue, String orderKey) {
      if (selectedValue != null && selectedValue.isNotEmpty) {
        return selectedValue;
      }
      // Preserve from order data if dropdown is not set
      return extractOrderValue(orderKey);
    }

    return ProductModel(
      // -------- Basic order info --------
      firstNameCreator: FieldWithTimestamp(
        value: employeeEntity.firstName!,
        timestamp: now,
      ),
      lastNameCreator: FieldWithTimestamp(
        value: employeeEntity.lastName!,
        timestamp: now,
      ),
      firstNameArCreator: FieldWithTimestamp(
        value: employeeEntity.firstNameInArabic!,
        timestamp: now,
      ),
      lastNameArCreator: FieldWithTimestamp(
        value: employeeEntity.lastNameInArabic!,
        timestamp: now,
      ),
      departmentCreator: FieldWithTimestamp(
        value: employeeEntity.departmentId!,
        timestamp: now,
      ),
      departmentArCreator: FieldWithTimestamp(
        value: employeeEntity.departmentId!,
        timestamp: now,
      ),
      jobTitleCreator: FieldWithTimestamp(
        value: employeeEntity.title!,
        timestamp: now,
      ),
      jobTitleArCreator: FieldWithTimestamp(
        value: employeeEntity.titleInArabic!,
        timestamp: now,
      ),
      emailCreator: FieldWithTimestamp(
        value: employeeEntity.email!,
        timestamp: now,
      ),
      phoneCreator: FieldWithTimestamp(
        value: employeeEntity.mobilePhone!.phone,
        timestamp: now,
      ),

      // -------- Fields with controllers (from this screen) --------
      orderId: FieldWithTimestamp(
        value: orderIDController.text.trim(),
        timestamp: now,
      ),
      // ✅ orderType is not in order data - use existing model or empty
      orderType: existingModel?.orderType ??
          FieldWithTimestamp(value: "", timestamp: now),
      productId: FieldWithTimestamp(
        value: productIDController.text.trim(),
        timestamp: now,
      ),
      category: FieldWithTimestamp(
        value: categoryController.text.trim(),
        timestamp: now,
      ),
      subCategory: FieldWithTimestamp(
        value: subcategoryController.text.trim(),
        timestamp: now,
      ),
      brand: FieldWithTimestamp(
        value: brandController.text.trim(),
        timestamp: now,
      ),
      storageAllocations: FieldWithTimestamp(
        value: brandController.text.trim(),
        timestamp: now,
      ),
      model: FieldWithTimestamp(
        value: modelController.text.trim(),
        timestamp: now,
      ),
      quantity: FieldWithTimestamp(
        value: quantityController.text.trim(),
        timestamp: now,
      ),
      orderNote: FieldWithTimestamp(
        value: quantityController.text.trim(),
        timestamp: now,
      ),
      unitCost: FieldWithTimestamp(
        value: unitCostController.text.trim(),
        timestamp: now,
      ),
      currency: FieldWithTimestamp(
        value: currencyController.text.trim(),
        timestamp: now,
      ),
      supplierName: FieldWithTimestamp(
        value: supplierNameController.text.trim(),
        timestamp: now,
      ),
      usageFrequency: FieldWithTimestamp(
        value: usageFrequencyController.text.trim(),
        timestamp: now,
      ),
      unitOfMeasurement: FieldWithTimestamp(
        value: unitOfMeasurementController.text.trim(),
        timestamp: now,
      ),
      productName: FieldWithTimestamp(
        value: productNameController.text.trim(),
        timestamp: now,
      ),

      // -------- Preserve from existing model OR order data --------
      expectedLifetime: existingModel?.expectedLifetime ??
          FieldWithTimestamp(
            value: extractProductValue("expectedLifetime"),
            timestamp: now,
          ),
      expectedDelivery: existingModel?.expectedDelivery ??
          FieldWithTimestamp(
            value: extractProductValue("expectedDelivery"),
            timestamp: now,
          ),
      deliverySelectedData: existingModel?.deliverySelectedData ??
          FieldWithTimestamp(
            value: extractProductValue("deliverySelectedData"),
            timestamp: now,
          ),
      reorderLevel: existingModel?.reorderLevel ??
          FieldWithTimestamp(
            value: extractProductValue("reorderLevel"),
            timestamp: now,
          ),
      reorderQuantity: existingModel?.reorderQuantity ??
          FieldWithTimestamp(
            value: extractProductValue("reorderQuantity"),
            timestamp: now,
          ),
      additionalNote: existingModel?.additionalNote ??
          FieldWithTimestamp(
            value: extractProductValue("additionalNote"),
            timestamp: now,
          ),
      productQuantity: existingModel?.productQuantity ??
          FieldWithTimestamp(
            value: extractProductValue("productQuantity"),
            timestamp: now,
          ),

      storageRequirement: existingModel?.storageRequirement ??
          DropdownFieldWithTimestamp(
            value: extractProductValue("storageRequirement"),
            options: [],
            timestamp: now,
          ),
      storageLocation: existingModel?.storageLocation ??
          DropdownFieldWithTimestamp(
            value: extractProductValue("storageLocation"),
            options: [],
            timestamp: now,
          ),

      productSpecificationImage: existingModel?.productSpecificationImage ??
          FieldWithTimestamp<String>(
            value: extractProductValue("productSpecificationImage"),
            timestamp: now,
          ),
      productWarrantyImage: existingModel?.productWarrantyImage ??
          FieldWithTimestamp<String>(
            value: extractProductValue("productWarrantyImage"),
            timestamp: now,
          ),
      attachmentsImage: existingModel?.attachmentsImage ??
          FieldWithTimestamp<String>(
            value: extractProductValue("attachmentsImage"),
            timestamp: now,
          ),

      // -------- Dates from order data --------
      orderDate: FieldWithTimestamp(
        value: extractProductValue("orderDate"),
        timestamp: now,
      ),
      receivingDate: FieldWithTimestamp(
        value: extractProductValue("receivingDate"),
        timestamp: now,
      ),

      // -------- Other dropdowns - preserve from order data --------
      year: existingModel?.year ??
          DropdownFieldWithTimestamp(
            value: extractProductValue("year"),
            options: [],
            timestamp: now,
          ),
      deliveryMethod: existingModel?.deliveryMethod ??
          DropdownFieldWithTimestamp(
            value: getDropdownValueOrPreserve(null, "deliveryMethod"),
            options: [],
            timestamp: now,
          ),
      maintenanceFrequency: DropdownFieldWithTimestamp(
        value: getDropdownValueOrPreserve(
          selectedMaintenanceFrequency,
          "maintenanceFrequency",
        ),
        options: [],
        timestamp: now,
      ),
      status: DropdownFieldWithTimestamp(
        value: getDropdownValueOrPreserve(selectedStatus, "status"),
        options: [],
        timestamp: now,
      ),

      requestType: existingModel?.requestType ??
          FieldWithTimestamp(
            value:
                (currentProduct["requestType"] as List?)?.cast<String>() ?? [],
            timestamp: now,
          ),
      approvalCycle: existingModel?.approvalCycle ?? [],

      // ================= INVOICE DETAILS - Use order-level data =================
      paymentMethod: existingModel?.paymentMethod ??
          DropdownFieldWithTimestamp(
            value: getDropdownValueOrPreserve(
              selectedPaymentMethod,
              "paymentMethod",
            ),
            options: [],
            timestamp: now,
          ),

      // ✅ VAT - From ORDER level data
      vat: existingModel?.vat ??
          FieldWithTimestamp(
            value: getValueOrPreserveFromOrderLevel(vatController, "vat"),
            timestamp: now,
          ),

      discountPercentage: existingModel?.discountPercentage ??
          FieldWithTimestamp(
            value: getValueOrPreserveFromOrderLevel(
              discountPercentageController,
              "discountPercentage",
            ),
            timestamp: now,
          ),

      // ✅ SHIPPING - From ORDER level data
      shipping: existingModel?.shipping ??
          FieldWithTimestamp(
            value: getValueOrPreserveFromOrderLevel(
              shippingController,
              "shipping",
            ),
            timestamp: now,
          ),

      // ✅ ORDER VALUE - From ORDER level data
      orderValue: existingModel?.orderValue ??
          FieldWithTimestamp(
            value: getValueOrPreserveFromOrderLevel(
              orderValueController,
              "orderValue",
            ),
            timestamp: now,
          ),

      // ============ SUPPLIER BANK TRANSFER DETAILS - Use order-level data =============
      // ✅ SUPPLIER ID - From ORDER level data
      supplierId: existingModel?.supplierId ??
          FieldWithTimestamp(
            value: getValueOrPreserveFromOrderLevel(
              supplierIdController,
              "supplierId",
            ),
            timestamp: now,
          ),

      advancedPayment: existingModel?.advancedPayment ??
          DropdownFieldWithTimestamp(
            value: getDropdownValueOrPreserve(
              selectedAdvancedPayment,
              "advancedPayment",
            ),
            options: [],
            timestamp: now,
          ),

      methodOfPayment: existingModel?.methodOfPayment ??
          DropdownFieldWithTimestamp(
            value: getDropdownValueOrPreserve(
              selectedMethodOfPayment,
              "methodOfPayment",
            ),
            options: [],
            timestamp: now,
          ),

      beneficiaryName: existingModel?.beneficiaryName ??
          FieldWithTimestamp(
            value: getValueOrPreserveFromOrderLevel(
              beneficiaryNameController,
              "beneficiaryName",
            ),
            timestamp: now,
          ),

      beneficiaryBankName: existingModel?.beneficiaryBankName ??
          FieldWithTimestamp(
            value: getValueOrPreserveFromOrderLevel(
              beneficiaryBankNameController,
              "beneficiaryBankName",
            ),
            timestamp: now,
          ),

      beneficiaryAccountIban: existingModel?.beneficiaryAccountIban ??
          FieldWithTimestamp(
            value: getValueOrPreserveFromOrderLevel(
              beneficiaryAccountIbanController,
              "beneficiaryAccountIban",
            ),
            timestamp: now,
          ),

      bankSwiftBicCode: existingModel?.bankSwiftBicCode ??
          FieldWithTimestamp(
            value: getValueOrPreserveFromOrderLevel(
              bankSwiftBicCodeController,
              "bankSwiftBicCode",
            ),
            timestamp: now,
          ),

      bankAddress: existingModel?.bankAddress ??
          FieldWithTimestamp(
            value: getValueOrPreserveFromOrderLevel(
              bankAddressController,
              "bankAddress",
            ),
            timestamp: now,
          ),

      // ================= ATTACHMENTS META =================
      transactionId: existingModel?.transactionId ??
          FieldWithTimestamp(
            value: getValueOrPreserve(transactionIdController, "transactionId"),
            timestamp: now,
          ),
    );
  }

  late int selectedIndex;

  // Add this improved method to debug and fix the product type display
  String _getCurrentProductDisplayType() {
    final products = List<Map<String, dynamic>>.from(
      widget.orderData['products'] ?? [],
    );

    if (_currentDisplayIndex >= products.length) {
      return 'Assets';
    }

    final currentProduct = products[_currentDisplayIndex];
    String currentStatus =
        (currentProduct['status'] ?? '').toString().toLowerCase().trim();

    debugPrint("🔍 Product $_currentDisplayIndex: status='$currentStatus'");

    if (currentStatus == 'consumable' || currentStatus == 'consumables') {
      return 'Consumable';
    } else if (currentStatus == 'hybrid') {
      return 'Hybrid';
    } else if (currentStatus == 'assets' || currentStatus == 'asset') {
      return 'Assets';
    } else {
      return 'Assets'; // Default
    }
  }

  void _debugProductData() {
    final products = List<Map<String, dynamic>>.from(
      widget.orderData['products'] ?? [],
    );
    debugPrint("🔍 Total products: ${products.length}");
    debugPrint("🔍 Current index: ${widget.currentProductIndex}");

    for (int i = 0; i < products.length; i++) {
      final product = products[i];
      final status = product['status'] ?? 'NO_STATUS';
      debugPrint("🔍 Product $i: status = '$status'");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMulti = widget.orderData["productNames"]?.length > 1;
    final productNames = List<String>.from(
      widget.orderData["productNames"] ?? [],
    );
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return SafeArea(
      child: Scaffold(
        body: SideFrameMasterServices(
          titleText: S.of(context).inventoryManagement,
          onFirstTap: () {
            Navigator.pop(context);
          },
          secondTitle: widget.isEditMode
              ? widget
                  .productModels[widget.currentProductIndex].productName.value
              : S.of(context).addingNewProduct,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                if (isMulti)
                  Row(
                    children: List.generate(productNames.length, (index) {
                      final isSelected = selectedIndex == index;
                      final textColor = isSelected
                          ? AppColors.secondaryPrimary
                          : AppColors.secondaryText;
                      _getProductDisplayName(
                        index,
                        productNames,
                      );

                      return GestureDetector(
                        onTap: () {
                          HapticController
                              .low(); // list row: on the tap (X-117)
                          setState(() {
                            selectedIndex = index;
                            _currentDisplayIndex =
                                index; // Update the local variable instead
                            final products = List<Map<String, dynamic>>.from(
                              widget.orderData["products"] ?? [],
                            );
                            if (products.length > index) {
                              _loadTabData(products[index]);
                            }
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 32.sp),
                          child: IntrinsicWidth(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  productNames[index],
                                  textAlign: TextAlign.center,
                                  style: StyleText.fontSize20Weight500.copyWith(
                                    color: textColor,
                                  ),
                                ),
                                SizedBox(height: 4.sp),
                                if (isSelected)
                                  Container(
                                    height: 2.sp,
                                    width: double.infinity,
                                    color: textColor,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                SizedBox(height: 30.sp),

                // Order Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 1.sp),
                    Text(
                      S.of(context).orderDetails,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.sp),

                // All TextField (UI unchanged)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15.sp),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            uploadImage(),
                            const Spacer(),
                            Container(
                              height: 25.sp,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                color: lightMode
                                    ? const Color(0xffF5F5F5)
                                    : AppColors.background,
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15.sp,
                                ),
                                child: Center(
                                  child: Text(
                                    _getCurrentProductDisplayType(), // Shows the current product's type only
                                    style:
                                        StyleText.fontSize14Weight500.copyWith(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.sp),

                        // ID fields
                        buildResponsiveFields(
                          context: context,
                          left: CustomValidatedTextFieldMaster(
                            enabled: false,
                            label: S.of(context).orderID,
                            controller: orderIDController,
                            hint: S.of(context).orderID,
                            onChanged: (_) => setState(() {}),
                            height: 36,
                            textDirection: ui.TextDirection.ltr,
                            onlyDigits: false,
                          ),
                          right: CustomValidatedTextFieldMaster(
                            enabled: false,
                            label: S.of(context).productID,
                            controller: productIDController,
                            hint: S.of(context).productID,
                            onChanged: (_) => setState(() {}),
                            height: 36,
                            textDirection: ui.TextDirection.ltr,
                            onlyDigits: false,
                          ),
                        ),
                        SizedBox(height: 10.sp),

                        // Category & Subcategory
                        buildResponsiveFields(
                          context: context,
                          left: CustomValidatedTextFieldMaster(
                            enabled: false,
                            label: S.of(context).category,
                            hint: S.of(context).category,
                            height: 36,
                            controller: categoryController,
                            textDirection: ui.TextDirection.ltr,
                            onlyDigits: false,
                            onChanged: (_) => setState(() {}),
                          ),
                          right: CustomValidatedTextFieldMaster(
                            enabled: false,
                            label: S.of(context).subcategory,
                            hint: S.of(context).subcategory,
                            height: 36,
                            controller: subcategoryController,
                            textDirection: ui.TextDirection.ltr,
                            onlyDigits: false,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        SizedBox(height: 10.sp),

                        // Brand & Model
                        buildResponsiveFields(
                          context: context,
                          left: CustomValidatedTextFieldMaster(
                            enabled: false,
                            label: S.of(context).brand,
                            hint: S.of(context).brand,
                            height: 36,
                            controller: brandController,
                            textDirection: ui.TextDirection.ltr,
                            onlyDigits: false,
                            onChanged: (_) => setState(() {}),
                          ),
                          right: CustomValidatedTextFieldMaster(
                            enabled: false,
                            label: S.of(context).model,
                            hint: S.of(context).model,
                            height: 36,
                            controller: modelController,
                            textDirection: ui.TextDirection.ltr,
                            onlyDigits: false,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        SizedBox(height: 10.sp),

                        // Usage Frequency & Unit Of Measurement - only show for Consumable products
                        _getCurrentProductDisplayType() == 'Consumable'
                            ? buildResponsiveFields(
                                context: context,
                                left: CustomValidatedTextFieldMaster(
                                  enabled: false,
                                  label: S.of(context).usageFrequency,
                                  hint: S.of(context).usageFrequency,
                                  height: 36,
                                  controller: usageFrequencyController,
                                  textDirection: ui.TextDirection.ltr,
                                  onlyDigits: false,
                                  onChanged: (_) => setState(() {}),
                                ),
                                right: CustomValidatedTextFieldMaster(
                                  enabled: false,
                                  label: S.of(context).unitOfMeasurement,
                                  hint: S.of(context).unitOfMeasurement,
                                  height: 36,
                                  controller: unitOfMeasurementController,
                                  textDirection: ui.TextDirection.ltr,
                                  onlyDigits: false,
                                  onChanged: (_) => setState(() {}),
                                ),
                              )
                            : const SizedBox(),
                        _getCurrentProductDisplayType() == 'Consumable'
                            ? SizedBox(height: 10.sp)
                            : SizedBox(),

                        // Quantity & Unit Cost
                        buildResponsiveFields(
                          context: context,
                          left: CustomValidatedTextFieldMaster(
                            enabled: false,
                            label: S.of(context).quantity,
                            hint: S.of(context).quantity,
                            height: 36,
                            controller: quantityController,
                            textDirection: ui.TextDirection.ltr,
                            onlyDigits: false,
                            onChanged: (_) => setState(() {}),
                          ),
                          right: CustomValidatedTextFieldMaster(
                            enabled: false,
                            label: S.of(context).unitCost,
                            hint: S.of(context).unitCost,
                            height: 36,
                            controller: unitCostController,
                            textDirection: ui.TextDirection.ltr,
                            onlyDigits: false,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        SizedBox(height: 10.sp),

                        // Currency & Supplier Name
                        buildResponsiveFields(
                          context: context,
                          left: CustomValidatedTextFieldMaster(
                            enabled: false,
                            label: S.of(context).currency,
                            hint: S.of(context).currency,
                            controller: currencyController,
                            height: 36,
                            textDirection: ui.TextDirection.ltr,
                            onlyDigits: false,
                            onChanged: (_) => setState(() {}),
                          ),
                          right: CustomValidatedTextFieldMaster(
                            enabled: false,
                            label: S.of(context).supplierName,
                            hint: S.of(context).supplierName,
                            height: 36,
                            controller: supplierNameController,
                            textDirection: ui.TextDirection.ltr,
                            onlyDigits: false,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.sp),

                // Discard & Next
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customButton(
                      title: S.of(context).back,
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

                    //
                    customButton(
                      title: S.of(context).next,
                      function: () {
                        final productModel = buildProductModel();
                        final updatedList = [...widget.productModels];

                        if (updatedList.length > widget.currentProductIndex) {
                          updatedList[widget.currentProductIndex] =
                              productModel;
                        } else {
                          updatedList.add(productModel);
                        }

                        navigateTo(
                          context,
                          ProductDetailsAssetsDesktopScreen(
                            // ✅ Use correct class name
                            productModel: productModel,
                            orderData: widget.orderData,
                            isConsumable: widget.isConsumable,
                            productModels: updatedList,
                            currentProductIndex: widget.currentProductIndex,
                            isMultiProduct: widget.isMultiProduct,
                            isEditMode: widget.isEditMode, // ✅ Pass edit mode
                          ),
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

                SizedBox(height: 20.sp),
                Row(
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getProductDisplayName(int index, List<String> productNames) {
    if (productNames.length <= 1) {
      // Single product - use original name or default
      return productNames.isNotEmpty
          ? productNames[0]
          : S.of(context).addingNewProduct;
    } else {
      // Multiple products - use "Product 1", "Product 2", etc.
      return "${S.of(context).product} ${index + 1}";
      // If S.of(context).product is not available, you can use:
      // return "Product ${index + 1}";
    }
  }

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
}

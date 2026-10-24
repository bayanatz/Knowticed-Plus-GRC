import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/domain/models/supplier_model.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/select_approval.dart';
import 'package:knowticed_plus/features/inventory/inv9_order/presentation/ui/pages/invoice_details_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_validated_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/cards/custom_title_value_widget.dart';
import 'package:knowticed_plus/features/inventory/helpers/constants/constant_lists.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/inventory/helpers/inventory_paths.dart';

class OrderDetails extends StatefulWidget {
  final List<ProductModel> products; // Should be List<ProductModel>
  const OrderDetails({super.key, required this.products});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  String? selectStatus = 'Open';

  TextEditingController productIdController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController unitCostController = TextEditingController();
  TextEditingController currencyController = TextEditingController();
  TextEditingController vatController = TextEditingController();
  TextEditingController discountPercentageController = TextEditingController();
  List<ProductDetailsData> productDetails = [];

  SupplierModel? supplierData;
  bool isLoadingSupplier = true;

  @override
  void initState() {
    debugPrint("🚀 OrderDetails received ${widget.products.length} products");
    for (int i = 0; i < widget.products.length; i++) {
      debugPrint(
        "Product $i: ${widget.products[i].productName.value} - ID: ${widget.products[i].productId.value}",
      );
    }
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    debugPrint("🚀 OrderDetails received ${widget.products.length} products");

    selectStatus = widget.products[0].status.value;
    debugPrint("Current status: ${widget.products[0].status.value}");

    // Initialize product details
    for (int i = 0; i < widget.products.length; i++) {
      ProductDetailsData details = ProductDetailsData();
      details.quantityController.text = widget.products[i].quantity.value;
      details.unitCostController.text = widget.products[i].unitCost.value;
      details.vatController.text = widget.products[i].vat.value;
      details.discountController.text =
          widget.products[i].discountPercentage.value;
      details.selectedCurrency = widget.products[i].currency.value;
      productDetails.add(details);
    }

    // Load supplier data
    await _loadSupplierData();
  }

  Future<void> _loadSupplierData() async {
    try {
      setState(() {
        isLoadingSupplier = true;
      });

      final supplierId = widget.products[0].supplierId.value;
      debugPrint("🔍 Loading supplier with ID: '$supplierId'");

      final supplier = await _getSupplierById(
        supplierId: supplierId,
        userEmail:
            InventoryPaths.userEmail, // Replace with dynamic email if needed
      );

      setState(() {
        supplierData = supplier;
        isLoadingSupplier = false;
      });

      if (supplier != null) {
        debugPrint("✅ Supplier loaded successfully: ${supplier.supplierName}");
      } else {
        debugPrint("❌ Supplier not found for id: $supplierId");
      }
    } catch (e) {
      debugPrint("❌ Error loading supplier: $e");
      setState(() {
        isLoadingSupplier = false;
      });
    }
  }

  Future<SupplierModel?> _getSupplierById({
    required String supplierId,
    required String userEmail,
  }) async {
    try {
      debugPrint("🔍 Fetching supplier document for ID: $supplierId");

      final doc = await FirebaseFirestore.instance
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('supplier')
          .doc(supplierId)
          .get();

      debugPrint("🔍 Document exists = ${doc.exists}");

      if (!doc.exists) {
        debugPrint("❌ Supplier document not found for ID: $supplierId");
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      data['supplierID'] = doc.id;

      debugPrint("✅ Supplier data retrieved successfully");
      return SupplierModel.fromJson(data);
    } catch (e) {
      debugPrint("❌ Error in getSupplierById: $e");
      throw Exception('getSupplierById failed: $e');
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
                // Invoice
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    customButtonWithSvg(
                      title: S.of(context).invoice,
                      function: () {
                        navigateTo(
                          context,
                          InvoiceDetailsToggle(products: widget.products),
                        );
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      width: 135.sp,
                      height: 38.sp,
                      space: 8.sp,
                      radius: 4.r,
                      color: AppColors.primary,
                      svgColor: AppColors.textButton,
                      image:
                          "assets/icons_assets/main_icons_assets/ic_action_send_white.svg",
                      widthImage: 21.w,
                      heightImage: 24.h,
                      colorBorder: Colors.transparent,
                    ),
                  ],
                ),
                // space
                SizedBox(height: 15.h),
                // Request Id & Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Request Id
                    Text(
                      "${S.of(context).orderID}: ",
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),

                    Text(
                      widget.products[0].orderId.value,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),

                    Spacer(),
                    // invoice
                    Row(
                      children: [
                        // image
                        CustomSvgImage(
                          assetPath:
                              "assets/icons_assets/main_icons_assets/ic_status.svg",
                          width: 11.sp,
                          height: 11.sp,
                          fit: BoxFit.fill,
                        ),
                        // space
                        SizedBox(width: 4.w),
                        // status
                        Text(
                          "${S.of(context).status}: ",
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.blackButton,
                          ),
                        ),
                        // space
                        SizedBox(width: 10.w),
                        SizedBox(
                          width: 150.w,
                          child: CustomDropdown<String>(
                            items: (ConstantLists.statusList())
                                .map((e) => DropdownItem<String>(
                                    value: e['key'] ?? '',
                                    label: e['value'] ?? ''))
                                .toList(),
                            value: selectStatus,
                            onChanged: (value) async {
                              _showConfirmDialog(value);
                            },
                            height: 30.sp,
                            labelGap: 4.sp,
                            fillColor: AppColors.card,
                          ),
                        ),
                      ],
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
                    padding: EdgeInsets.all(15.sp),
                    child: widget.products.length == 1
                        ? _buildSingleProductView()
                        : _buildMultiProductView(),
                  ),
                ),

                // space
                SizedBox(height: 20.sp),

                // Invoice Details
                widget.products.length == 1
                    ? Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Invoice Details
                                  Text(
                                    S.of(context).invoiceDetails,
                                    style:
                                        StyleText.fontSize16Weight600.copyWith(
                                      color: AppColors.blackButton,
                                    ),
                                  ),
                                ],
                              ),
                              // space
                              SizedBox(height: 8.sp),
                              Row(
                                children: [
                                  Container(
                                    width: 440.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.card,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CustomTitleValueWidget(
                                                title:
                                                    "${S.of(context).quantity}: ",
                                                value: widget
                                                    .products[0].quantity.value,
                                                titleStyle: StyleText
                                                    .fontSize12Weight400
                                                    .copyWith(
                                                  color:
                                                      AppColors.secondaryText,
                                                ),
                                                valueStyle: StyleText
                                                    .fontSize12Weight400
                                                    .copyWith(
                                                  color: AppColors.blackButton,
                                                ),
                                              ),
                                              SizedBox(height: 13.h),
                                              CustomTitleValueWidget(
                                                title:
                                                    "${S.of(context).paymentMethod}: ",
                                                value: widget.products[0]
                                                    .paymentMethod.value,
                                                titleStyle: StyleText
                                                    .fontSize12Weight400
                                                    .copyWith(
                                                  color:
                                                      AppColors.secondaryText,
                                                ),
                                                valueStyle: StyleText
                                                    .fontSize12Weight400
                                                    .copyWith(
                                                  color: AppColors.blackButton,
                                                ),
                                              ),
                                              SizedBox(height: 13.h),
                                              CustomTitleValueWidget(
                                                title:
                                                    "${S.of(context).currency}: ",
                                                value: widget
                                                    .products[0].currency.value,
                                                titleStyle: StyleText
                                                    .fontSize12Weight400
                                                    .copyWith(
                                                  color:
                                                      AppColors.secondaryText,
                                                ),
                                                valueStyle: StyleText
                                                    .fontSize12Weight400
                                                    .copyWith(
                                                  color: AppColors.blackButton,
                                                ),
                                              ),
                                              SizedBox(height: 13.h),
                                              CustomTitleValueWidget(
                                                title:
                                                    "${S.of(context).unitCost}: ",
                                                value: widget
                                                    .products[0].unitCost.value,
                                                titleStyle: StyleText
                                                    .fontSize12Weight400
                                                    .copyWith(
                                                  color:
                                                      AppColors.secondaryText,
                                                ),
                                                valueStyle: StyleText
                                                    .fontSize12Weight400
                                                    .copyWith(
                                                  color: AppColors.blackButton,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CustomTitleValueWidget(
                                                title: "${S.of(context).vat}: ",
                                                value: widget
                                                    .products[0].vat.value,
                                                titleStyle: StyleText
                                                    .fontSize12Weight400
                                                    .copyWith(
                                                  color:
                                                      AppColors.secondaryText,
                                                ),
                                                valueStyle: StyleText
                                                    .fontSize12Weight400
                                                    .copyWith(
                                                  color: AppColors.blackButton,
                                                ),
                                              ),
                                              SizedBox(height: 13.h),
                                              CustomTitleValueWidget(
                                                title:
                                                    "${S.of(context).discountPercentage}: ",
                                                value: widget.products[0]
                                                    .discountPercentage.value,
                                                titleStyle: StyleText
                                                    .fontSize12Weight400
                                                    .copyWith(
                                                  color:
                                                      AppColors.secondaryText,
                                                ),
                                                valueStyle: StyleText
                                                    .fontSize12Weight400
                                                    .copyWith(
                                                  color: AppColors.blackButton,
                                                ),
                                              ),
                                              SizedBox(height: 13.h),
                                              CustomTitleValueWidget(
                                                title:
                                                    "${S.of(context).shipping}: ",
                                                value: widget
                                                    .products[0].shipping.value,
                                                titleStyle: StyleText
                                                    .fontSize12Weight400
                                                    .copyWith(
                                                  color:
                                                      AppColors.secondaryText,
                                                ),
                                                valueStyle: StyleText
                                                    .fontSize12Weight400
                                                    .copyWith(
                                                  color: AppColors.blackButton,
                                                ),
                                              ),
                                              SizedBox(height: 13.h),
                                              CustomTitleValueWidget(
                                                title:
                                                    "${S.of(context).deliveryMethod}: ",
                                                value: widget.products[0]
                                                    .deliveryMethod.value,
                                                titleStyle: StyleText
                                                    .fontSize12Weight400
                                                    .copyWith(
                                                  color:
                                                      AppColors.secondaryText,
                                                ),
                                                valueStyle: StyleText
                                                    .fontSize12Weight400
                                                    .copyWith(
                                                  color: AppColors.blackButton,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(width: 17.w),
                          _buildSupplierDetailsSection(),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            // This makes it take full width
                            child: // Replace the problematic ListView section with this improved version
                                Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${widget.products.length} ${S.of(context).productDetails}",
                                      style: StyleText.fontSize16Weight600
                                          .copyWith(
                                        color: AppColors.blackButton,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                _multiProductsGrid(context),
                              ],
                            ),
                          ),
                        ],
                      ),

                // space
                SizedBox(height: 20.sp),

                // Grid view
                _buildAttachmentsSection(),

                // space
                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleProductView() {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              width: 80.sp,
              height: 80.sp,
              decoration: BoxDecoration(
                color: lightMode ? AppColors.grey : AppColors.background,
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
            SizedBox(width: 12.sp),
            Expanded(child: sectionOneInfo()),
            SizedBox(width: 12.sp),
            Expanded(child: sectionTwoInfo()),
            SizedBox(width: 12.sp),
            Expanded(child: sectionThreeInfo()),
          ],
        ),
        SizedBox(height: 15.sp),
        // Product name
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.products[0].productName.value,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ],
        ),
        SizedBox(height: 15.sp),
        // Order note
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "${S.of(context).orderNote}: ",
              style: StyleText.fontSize12Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            Text(
              widget.products[0].orderNote.value,
              style: StyleText.fontSize12Weight500.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMultiProductView() {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80.h,
              width: 80.w,
              decoration: BoxDecoration(
                color: lightMode ? AppColors.grey : AppColors.chatBackground,
              ),
              child: CustomSvgImage(
                assetPath:
                    "assets/icons_assets/main_icons_assets/ic_user_profile.svg",
                width: 40.w,
                height: 50.h,
                color: AppColors.blackButton,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(child: sectionOneMultiInfo()),
            SizedBox(width: 12.w),
            Expanded(child: sectionTwoMultiInfo()),
            SizedBox(width: 12.w),
            Expanded(child: sectionThreeMultiInfo()),
          ],
        ),
        SizedBox(height: 15.sp),
        // Order note for multi-product orders
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "${S.of(context).orderNote}: ",
              style: StyleText.fontSize12Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            Expanded(
              child: Text(
                widget.products[0].orderNote.value,
                style: StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSupplierDetailsSection() {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
          width: 440.w,
          height: 143.h,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: isLoadingSupplier
                ? _buildLoadingSupplierWidget(lightMode)
                : supplierData == null
                    ? _buildNoSupplierWidget(lightMode)
                    : _buildSupplierDataWidget(lightMode),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSupplierWidget(bool lightMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24.sp,
            height: 24.sp,
            child: CircleProgressMaster.inline(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.blackButton,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Loading supplier details...",
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSupplierWidget(bool lightMode) {
    return Center(
      child: Text(
        "Supplier not found",
        style: StyleText.fontSize12Weight400.copyWith(
          color: AppColors.secondaryText,
        ),
      ),
    );
  }

  Widget _buildSupplierDataWidget(bool lightMode) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTitleValueWidget(
              title: "${S.of(context).supplierName}: ",
              value: supplierData?.supplierName ?? 'N/A',
              titleStyle: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
              valueStyle: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.blackButton,
              ),
            ),
            SizedBox(height: 13.h),
            CustomTitleValueWidget(
              title: "${S.of(context).country}: ",
              value: supplierData?.country ?? 'N/A',
              titleStyle: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
              valueStyle: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.blackButton,
              ),
            ),
            SizedBox(height: 13.h),
            CustomTitleValueWidget(
              title: "${S.of(context).stateOrProvince}: ",
              value: supplierData?.stateOrProvince ?? 'N/A',
              titleStyle: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
              valueStyle: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.blackButton,
              ),
            ),
            SizedBox(height: 13.h),
            CustomTitleValueWidget(
              title: "${S.of(context).description}: ",
              value: supplierData?.streetName ?? 'N/A',
              titleStyle: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
              valueStyle: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ],
        ),
        Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTitleValueWidget(
              title: "${S.of(context).supplierID}: ",
              value: supplierData?.supplierID ??
                  widget.products[0].supplierId.value,
              titleStyle: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
              valueStyle: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.blackButton,
              ),
            ),
            SizedBox(height: 13.h),
            CustomTitleValueWidget(
              title: "${S.of(context).city}: ",
              value: supplierData?.city ?? 'N/A',
              titleStyle: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
              valueStyle: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.blackButton,
              ),
            ),
            SizedBox(height: 13.h),
            CustomTitleValueWidget(
              title: "${S.of(context).postalCode}: ",
              value: supplierData?.postalCode ?? 'N/A',
              titleStyle: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
              valueStyle: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _multiProductsGrid(BuildContext context) {
    // choose columns based on width

    return GridView.builder(
      shrinkWrap: true, // let grid compute its own height
      physics: const NeverScrollableScrollPhysics(), // parent scroll handles it
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
          context,
        ),
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
        mainAxisExtent:
            470.h, // keep cards pleasant vertically; tweak if needed
        //childAspectRatio: isTablet ? 1.95 : 1.6,
        //  mainAxisExtent: isTablet ?  480.h : 520.h
      ),
      itemCount: widget.products.length,
      itemBuilder: (context, index) {
        final p = widget.products[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 3.w),
                Text(
                  "${widget.products[index].model.value} ${widget.products[index].brand.value}",
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: AppColors.card,
              ),
              padding: EdgeInsets.all(15.sp),
              child: Column(
                mainAxisSize: MainAxisSize.min, // <- no forced height
                children: [
                  CustomValidatedTextFieldMaster(
                    enabled: false,
                    label: S.of(context).productID,
                    hint: S.of(context).productID,
                    height: 36,
                    controller: TextEditingController(text: p.productId.value),
                  ),
                  // SizedBox(height: 8.h),
                  // CustomValidatedTextFieldMaster(
                  //   enabled: false,
                  //   label: S.of(context).productName, hint: S.of(context).productName,
                  //   height: 36, controller: TextEditingController(text: p.productName.value),
                  // ),
                  SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(
                    enabled: false,
                    label: S.of(context).quantity,
                    hint: S.of(context).quantity,
                    height: 36,
                    controller: TextEditingController(text: p.quantity.value),
                  ),
                  SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(
                    enabled: false,
                    label: S.of(context).unitCost,
                    hint: S.of(context).unitCost,
                    height: 36,
                    controller: TextEditingController(text: p.unitCost.value),
                  ),
                  SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(
                    enabled: false,
                    label: S.of(context).currency,
                    hint: S.of(context).currency,
                    height: 36,
                    controller: TextEditingController(text: p.currency.value),
                  ),
                  SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(
                    enabled: false,
                    label: S.of(context).vat,
                    hint: S.of(context).vat,
                    height: 36,
                    controller: TextEditingController(text: p.vat.value),
                  ),
                  SizedBox(height: 8.h),
                  CustomValidatedTextFieldMaster(
                    enabled: false,
                    label: S.of(context).discountPercentage,
                    hint: S.of(context).discountPercentage,
                    height: 36,
                    controller: TextEditingController(
                      text: p.discountPercentage.value,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget _buildStorageLocationSection() {
  //   final lightMode = Theme.of(context).brightness == Brightness.light;
  //   final isMobile = context.isPhone;
  //
  //   // Parse the JSON string from storageAllocations
  //   // Parse the JSON string from storageAllocations
  //   List<Map<String, dynamic>> storageData = [];
  //
  //   try {
  //     // Parse the JSON string
  //     String jsonString = widget.products[0].storageAllocations.value;
  //     List<dynamic> parsedData = json.decode(jsonString);
  //
  //     // Convert to List<Map<String, dynamic>> and handle entries
  //     storageData = parsedData
  //         .map((item) => Map<String, dynamic>.from(item))
  //         .where((item) =>
  //     item['quantity'] != null &&
  //         item['quantity'].toString().isNotEmpty &&
  //         item['quantity'].toString() != '0')
  //         .map((item) {
  //       // Handle empty location names
  //       if (item['locationName'] == null || item['locationName'].toString().isEmpty) {
  //         item['locationName'] = 'Unassigned Location';
  //       }
  //       return item;
  //     })
  //         .toList();
  //   } catch (e) {
  //     print('Error parsing storage allocations: $e');
  //     // Fallback to empty list if parsing fails
  //     storageData = [];
  //   }
  //
  //   // If no valid storage data, show a message
  //   if (storageData.isEmpty) {
  //     return Row(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Text(
  //           "${S.of(context).storageLocationAndQuantity}: ",
  //           style: isMobile
  //               ? StyleText.fontSize10Weight500.copyWith(
  //             color: AppColors.secondaryText,
  //           )
  //               : StyleText.fontSize12Weight400.copyWith(
  //             color: AppColors.secondaryText,
  //           ),
  //         ),
  //         Text(
  //           "No storage locations assigned",
  //           style: StyleText.fontSize12Weight400.copyWith(
  //             color: AppColors.secondaryText,
  //           ),
  //         ),
  //       ],
  //     );
  //   }
  //
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       // Title
  //       Text(
  //         "${S.of(context).storageLocationAndQuantity}: ",
  //         style: isMobile
  //             ? StyleText.fontSize10Weight500.copyWith(
  //           color: AppColors.secondaryText,
  //         )
  //             : StyleText.fontSize12Weight400.copyWith(
  //           color: AppColors.secondaryText,
  //         ),
  //       ),
  //
  //       // Storage locations containers on the same line
  //       Expanded(
  //         child: Wrap(
  //           spacing: 10.sp,
  //           runSpacing: 8.sp,
  //           children: storageData.map((item) {
  //             return GestureDetector(
  //               onTap: () {
  //                 // Optional: Add functionality when tapping on storage location
  //                 print('Tapped on ${item['locationName']} with quantity ${item['quantity']}');
  //               },
  //               child: Container(
  //                 padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
  //                 decoration: BoxDecoration(
  //                   color: lightMode ? const Color(0xffF5F5F5) : AppColors.background,
  //                   borderRadius: BorderRadius.circular(4.r),
  //                 ),
  //                 child: Text(
  //                   '${item['locationName']} | ${item['quantity']}',
  //                   style: StyleText.fontSize12Weight400.copyWith(
  //                     color: AppColors.blackButton,
  //                   ),
  //                 ),
  //               ),
  //             );
  //           }).toList(),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  void _showConfirmDialog(String? newValue) {
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
                repeat: true,
                animate: true,
              ),
              Text(
                "Confirm Status Change", // You can use S.of(context).confirmStatusChange
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                "Are you sure you want to change the status to \"$newValue\"?", // Custom message
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
                        onTapDown: (_) => HapticController.high(),
                        onTap: () {
                          Navigator.pop(context);
                          // Reset dropdown to previous value if user cancels
                          setState(() {
                            selectStatus = selectStatus; // Keep current value
                          });
                        },
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
                          _updateStatusInFirestore(newValue);
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

  void _updateStatusInFirestore(String? value) async {
    setState(() {
      selectStatus = value;
    });

    try {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection("Demo")
          .doc(InventoryPaths.companyId)
          .collection("order")
          .doc(widget.products[0].orderId.value);

      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        List<dynamic> products = List.from(data['products'] ?? []);

        if (products.isNotEmpty) {
          products[0]['status'] = {
            'value': value,
            'timestamp': DateTime.now().toIso8601String(),
          };

          await docRef.update({'products': products});
          debugPrint("Status updated to: $value");

          // Show success dialog after successful update
          if (!mounted) return;
          _showSuccessDialog(context);
        }
      }
    } catch (e) {
      debugPrint("Error updating Firestore: $e");
      setState(() {
        selectStatus =
            widget.products[0].status.value; // Revert to original value
      });
    }
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
                  "Status Updated", // You can use S.of(context).statusUpdated
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  "The order status has been successfully updated.", // Custom success message
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

  ///////////////////////////////// section info ////////////////////////////////
  Widget sectionOneInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemText(
          value: widget.products[0].orderType.value,
          label: "${S.of(context).orderType}: ",
        ),
        SizedBox(height: 4.sp),
        itemText(
          value: widget.products[0].orderId.value,
          label: "${S.of(context).invoice}: ",
        ),
        SizedBox(height: 4.sp),
        itemText(
          value: widget.products[0].productId.value,
          label: "${S.of(context).productID}: ",
        ),
        SizedBox(height: 4.sp),
        itemText(
          value: widget.products[0].category.value,
          label: "${S.of(context).category}: ",
        ),
      ],
    );
  }

  Widget sectionTwoInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemText(
          value: widget.products[0].subCategory.value,
          label: "${S.of(context).subcategory}: ",
        ),
        SizedBox(height: 4.sp),
        itemText(
          value: widget.products[0].brand.value,
          label: "${S.of(context).brand}: ",
        ),
        SizedBox(height: 4.sp),
        itemText(
          value: widget.products[0].model.value,
          label: "${S.of(context).model}: ",
        ),
        SizedBox(height: 4.sp),
        itemText(
          value: formatDateString(widget.products[0].expectedDelivery.value),
          label: "${S.of(context).expectedDelivery}: ",
        ),
      ],
    );
  }

  String formatDateString(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  Widget sectionThreeInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemText(value: "-", label: "${S.of(context).receivedBy}: "),
        SizedBox(height: 4.sp),
        itemText(value: "-", label: "${S.of(context).receivedDate}: "),
      ],
    );
  }

  ///////////////////////////////// section info ////////////////////////////////

  ///////////////////////////////// section info ////////////////////////////////
  Widget sectionOneMultiInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemText(label: "PO: ", value: widget.products[0].orderId.value),
        SizedBox(height: 5.h),
        itemText(
          label: "${S.of(context).expectedDelivery}: ",
          value: widget.products[0].expectedDelivery.value,
        ),
        SizedBox(height: 5.h),
        itemText(
          label: "${S.of(context).paymentMethod}: ",
          value: widget.products[0].paymentMethod.value,
        ),
        SizedBox(height: 5.h),
        itemText(
          label: "${S.of(context).deliveryMethod}: ",
          value: widget.products[0].deliveryMethod.value,
        ),
      ],
    );
  }

  Widget sectionTwoMultiInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemText(
          value: widget.products[0].shipping.value,
          label: "${S.of(context).shipping}: ",
        ),
        SizedBox(height: 5.h),
        itemText(
          value: widget.products[0].orderValue.value,
          label: "${S.of(context).orderValue}: ",
        ),
        SizedBox(height: 5.h),
        itemText(value: "-", label: "${S.of(context).receivedBy}: "),
        SizedBox(height: 5.h),
        itemText(value: "-", label: "${S.of(context).receivingDate}: "),
      ],
      //formatDateString(widget.products[0].receivingDate.value),
      //formatDateString(widget.products[0].expectedDelivery.value),
    );
  }

  Widget sectionThreeMultiInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        itemText(
          value: widget.products[0].supplierName.value,
          label: "${S.of(context).supplierName}: ",
        ),
        SizedBox(height: 5.h),
        itemText(
          value: widget.products[0].supplierId.value,
          label: "${S.of(context).supplierId}: ",
        ),
        SizedBox(height: 5.h),
        itemText(
          value: widget.products[0].bankSwiftBicCode.value,
          label: "${S.of(context).swiftCode}: ",
        ),
        SizedBox(height: 5.h),
        itemText(
          value: widget.products[0].beneficiaryBankName.value,
          label: "${S.of(context).iban}: ",
        ),
      ],
    );
  }

  ///////////////////////////////// section info ////////////////////////////////

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

  ////////////////////// ////////////////////////////////////

  // Replace your current Grid view section with this updated version

  Widget _buildAttachmentsSection() {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    // Parse attachment URLs from the JSON/string value
    List<String> attachmentUrls = [];

    try {
      String attachmentsString = widget.products[0].attachmentsImage.value;

      // Check if it's a JSON array or single URL
      if (attachmentsString.startsWith('[')) {
        // It's a JSON array
        List<dynamic> parsedUrls = json.decode(attachmentsString);
        attachmentUrls = parsedUrls.map((url) => url.toString()).toList();
      } else if (attachmentsString.startsWith('http')) {
        // It's a single URL
        attachmentUrls = [attachmentsString];
      }
    } catch (e) {
      debugPrint('Error parsing attachment URLs: $e');
      // Try as single URL if JSON parsing fails
      String attachmentsString = widget.products[0].attachmentsImage.value;
      if (attachmentsString.startsWith('http')) {
        attachmentUrls = [attachmentsString];
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Attachments title
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              S.of(context).attachments,
              style: StyleText.fontSize16Weight600.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ],
        ),

        SizedBox(height: 8.sp),

        // Grid view container
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(15),
            child: attachmentUrls.isEmpty
                ? _buildNoAttachmentsWidget(lightMode)
                : GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: CrossAxisCountHelper
                          .getCrossAxisCountForDefaultTablet2(
                        context,
                      ),
                      mainAxisExtent: 65.sp,
                      crossAxisSpacing: 15.sp,
                      mainAxisSpacing: 15.sp,
                    ),
                    itemCount: attachmentUrls.length,
                    itemBuilder: (context, index) {
                      return _buildAttachmentItem(
                        attachmentUrls[index],
                        index,
                        lightMode,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoAttachmentsWidget(bool lightMode) {
    return SizedBox(
      height: 100.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomSvgImage(
              assetPath:
                  "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
              width: 32.sp,
              height: 32.sp,
              color: AppColors.secondaryText,
              fit: BoxFit.scaleDown,
            ),
            SizedBox(height: 8.h),
            Text(
              "No attachments available",
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(String imageUrl, int index, bool lightMode) {
    // Extract filename from URL
    String fileName = _extractFileName(imageUrl);

    return GestureDetector(
      onTap: withHaptic(() => _previewImage(imageUrl), HapticLevel.low),
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
              // Image preview and details
              Row(
                children: [
                  // Image thumbnail
                  Container(
                    width: 36.sp,
                    height: 36.sp,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: lightMode ? AppColors.grey : AppColors.background,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: Image.network(
                        imageUrl,
                        width: 36.sp,
                        height: 36.sp,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 20.sp,
                              height: 20.sp,
                              child: CircleProgressMaster.inline(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.blackButton,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return CustomSvgImage(
                            assetPath:
                                "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
                            width: 24.sp,
                            height: 24.sp,
                            color: AppColors.blackButton,
                            fit: BoxFit.scaleDown,
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(width: 10.sp),

                  // File name and size
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          fileName,
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.blackButton,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Image", // You can add file size logic here if needed
                          style: StyleText.fontSize12Weight500.copyWith(
                            color: AppColors.secondaryText,
                          ),
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
    );
  }

  String _extractFileName(String url) {
    try {
      // Extract filename from Firebase URL
      Uri uri = Uri.parse(url);
      String path = uri.pathSegments.last;

      // Remove Firebase tokens and get clean filename
      if (path.contains('?')) {
        path = path.split('?').first;
      }

      // Decode URL encoded characters
      path = Uri.decodeComponent(path);

      // Extract just the filename part (after the last slash)
      if (path.contains('/')) {
        path = path.split('/').last;
      }

      return path.isNotEmpty ? path : 'Attachment';
    } catch (e) {
      return 'Attachment';
    }
  }

  void _previewImage(String imageUrl) {
    // Show full-screen image preview
    showAppDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: withHaptic(
                      () => Navigator.of(context).pop(), HapticLevel.high),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ////////////////////// ////////////////////////////////////
}

class ApprovalSection {
  String? selectedRequestType;
  List<EmployeeEntity> selectedApprovers;

  ApprovalSection({
    this.selectedRequestType,
    this.selectedApprovers = const [],
  });
}

class ProductDetailsData {
  final TextEditingController quantityController;
  final TextEditingController unitCostController;
  final TextEditingController discountController;
  final TextEditingController vatController;
  String? selectedCurrency;

  ProductDetailsData()
      : quantityController = TextEditingController(),
        unitCostController = TextEditingController(),
        discountController = TextEditingController(),
        vatController = TextEditingController();

  void dispose() {
    quantityController.dispose();
    unitCostController.dispose();
    discountController.dispose();
    vatController.dispose();
  }
}

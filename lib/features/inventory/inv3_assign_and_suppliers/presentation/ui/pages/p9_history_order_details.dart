import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/data/repository/product_repository_impl.dart';
import 'package:knowticed_plus/features/inventory/domain/models/supplier_model.dart';
import 'package:knowticed_plus/features/inventory/presentation/controller/product_cubit.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv2_view_product/presentation/ui/pages/product_details_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv3_assign_and_suppliers/presentation/ui/widgets/p9_history_order_details/table.dart';
import 'package:knowticed_plus/features/inventory/inv9_order/presentation/ui/widgets/invoice_details/download.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

class HistoryOrderDetailsDesktopScreen extends StatefulWidget {
  final List<ProductModel> products;
  const HistoryOrderDetailsDesktopScreen({super.key, required this.products});

  @override
  State<HistoryOrderDetailsDesktopScreen> createState() =>
      _HistoryOrderDetailsDesktopScreenState();
}

class _HistoryOrderDetailsDesktopScreenState
    extends State<HistoryOrderDetailsDesktopScreen> {
  late ProductCubit _productCubit;
  SupplierModel? _supplierData;
  bool _isLoadingSupplier = false;

  @override
  void initState() {
    super.initState();
    _productCubit = ProductCubit(
      ProductRepositoryImpl(FirebaseFirestore.instance),
    );
    _fetchSupplierData();
  }

  void _fetchSupplierData() async {
    if (widget.products.isEmpty) {
      debugPrint("⚠️ No products available");
      return;
    }

    // Debug product data
    final product = widget.products[0];
    debugPrint("🔍 Product Debug:");
    debugPrint("  - Product ID: '${product.productId.value}'");
    debugPrint("  - Product Name: '${product.productName.value}'");
    debugPrint("  - Supplier ID: '${product.supplierId.value}'");
    debugPrint("  - Supplier Name: '${product.supplierName.value}'");

    final supplierId = product.supplierId.value;
    if (supplierId.isEmpty) {
      debugPrint("⚠️ No supplier ID found in product data");
      return;
    }

    debugPrint("🔍 Fetching supplier data for ID: $supplierId");
    setState(() {
      _isLoadingSupplier = true;
    });

    _productCubit.loadSupplierById(supplierId);
  }

  @override
  void dispose() {
    _productCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    Localizations.localeOf(context).languageCode == 'ar';
    final bool isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final isMobile = context.isPhone;

    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          create: (context) => _productCubit,
          child: BlocListener<ProductCubit, ProductState>(
            listener: (context, state) {
              if (state is SupplierLoaded) {
                setState(() {
                  _supplierData = state.supplier as SupplierModel?;
                  _isLoadingSupplier = false;
                });
                debugPrint(
                  "✅ Supplier data loaded in UI: ${state.supplier.supplierName}",
                );
              } else if (state is SupplierError) {
                setState(() {
                  _isLoadingSupplier = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error loading supplier: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
                debugPrint("❌ Error loading supplier: ${state.message}");
              } else if (state is SupplierLoading) {
                setState(() {
                  _isLoadingSupplier = true;
                });
                debugPrint("⏳ Loading supplier data...");
              }
            },
            child: SideFrameMasterServices(
              titleText: S.of(context).inventoryManagement,
              onFirstTap: () {
                Navigator.pop(context);
              },
              secondTitle: S.of(context).productName,
              onSecondTap: () {
                navigateTo(context, ViewProductDetails());
              },
              thirdTitle: S.of(context).supplierDetails,
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  children: [
                    // Order Request & Share  & Download
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Order Request
                        Text(
                          S.of(context).orderRequest,
                          style: StyleText.fontSize16Weight600.copyWith(
                            color: AppColors.blackButton,
                          ),
                        ),
                        //space
                        Spacer(),
                        // Share
                        customButtonWithSvg(
                          title: isMobile ? "" : S.of(context).share,
                          function: () {},
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
                              "assets/icons_assets/inventory_assets/ic_action_share_nodes.svg",
                          space: 8.sp,
                          colorBorder: Colors.transparent,
                        ),
                        //space
                        SizedBox(width: isMobile ? 10.sp : 15.sp),
                        // Download
                        // Replace your download button with this:
                        customButtonWithSvg(
                          title: isMobile ? "" : S.of(context).download,
                          function: _handlePdfDownload, // Use the new method
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
                              "assets/icons_assets/main_icons_assets/ic_action_cloud_download.svg",
                          space: 8.sp,
                          colorBorder: Colors.transparent,
                        ),
                      ],
                    ),

                    // space
                    SizedBox(height: 8.sp),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: AppColors.card,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15.sp),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // First Section
                            Row(
                              children: [
                                // image branding
                                CustomSvgImage(
                                  assetPath:
                                      "assets/icons_assets/main_icons_assets/logo_knowticed.svg",
                                  height: 75.sp,
                                  width: 96.sp,
                                  fit: BoxFit.scaleDown,
                                ),
                                // space
                                isMobile ? SizedBox() : SizedBox(width: 50.sp),

                                // Master Info
                                isMobile ? SizedBox() : orderInfoUser(),

                                // space
                                Spacer(),

                                // PO-011 & Total Amount & $ currency
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // PO-011
                                    Container(
                                      width: 106.sp,
                                      height: 32.sp,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        color: AppColors.background,
                                      ),
                                      child: Center(
                                        child: Text(
                                          widget.products[0].orderId.value,
                                          style: StyleText.fontSize12Weight600
                                              .copyWith(
                                            color: AppColors.blackButton,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // space
                                    SizedBox(height: 19.sp),

                                    // Total Amount
                                    Text(
                                      S.of(context).totalAmount,
                                      style: StyleText.fontSize12Weight500
                                          .copyWith(
                                        color: AppColors.secondaryText,
                                      ),
                                    ),

                                    // space
                                    SizedBox(height: 20.sp),

                                    // Currency
                                    Text(
                                      "${widget.products[0].orderValue.value} ${widget.products[0].currency.value}",
                                      style: StyleText.fontSize20Weight600
                                          .copyWith(
                                        color: AppColors.blackButton,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            //space
                            SizedBox(height: 10.sp),

                            isMobile ? orderInfoUser() : SizedBox(),

                            //space
                            SizedBox(height: 10.sp),

                            // border Container Info
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: lightMode
                                      ? Color(0xff797979)
                                      : AppColors.grey,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // second Section
                                  isMobile
                                      ? sideInfoSection()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Side Info
                                            sideInfoSection(),

                                            //space
                                            SizedBox(width: 28.sp),

                                            // Updated Supplier Section
                                            _buildSupplierSection(),
                                          ],
                                        ),

                                  isMobile
                                      ? SizedBox(height: 0.sp)
                                      : SizedBox(),
                                  isMobile
                                      ? Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15.sp,
                                          ),
                                          child: _buildSupplierSection(),
                                        )
                                      : SizedBox(),

                                  isMobile
                                      ? SizedBox()
                                      : ProductTableWidget(
                                          data: _convertProductsToTableData(
                                            widget.products,
                                          ),
                                          locale: isEnglish ? 'en' : 'ar',
                                        ),

                                  isMobile
                                      ? Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15.sp,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                8.r,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10.sp,
                                                vertical: 10.sp,
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      itemTextProduct(
                                                        label:
                                                            "${S.of(context).productName}: ",
                                                        value: "iPhone 16",
                                                      ),
                                                      Spacer(),
                                                      itemTextProduct(
                                                        label:
                                                            "${S.of(context).no}: ",
                                                        value: "1",
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 4.sp),
                                                  itemTextProduct(
                                                    label: S
                                                        .of(context)
                                                        .categorySubcategory,
                                                    value: "",
                                                  ),
                                                  SizedBox(height: 4.sp),
                                                  itemTextProduct(
                                                    label:
                                                        "${S.of(context).quantity}: ",
                                                    value: "200",
                                                  ),
                                                  SizedBox(height: 4.sp),
                                                  itemTextProduct(
                                                    label:
                                                        "${S.of(context).unitPrice}: ",
                                                    value: "10",
                                                  ),
                                                  SizedBox(height: 4.sp),
                                                  Row(
                                                    children: [
                                                      itemTextProduct(
                                                        label:
                                                            "${S.of(context).vat}: ",
                                                        value: "10%",
                                                      ),
                                                      Spacer(),
                                                      itemTextProduct(
                                                        label:
                                                            "${S.of(context).finalAmount}: ",
                                                        value: "10000",
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                                  SizedBox(height: 15.sp),

                                  Padding(
                                    padding: EdgeInsets.only(left: 15.sp),
                                    child: Row(
                                      mainAxisAlignment: isMobile
                                          ? MainAxisAlignment.start
                                          : MainAxisAlignment.end,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              S.of(context).paymentType,
                                              style: StyleText
                                                  .fontSize12Weight500
                                                  .copyWith(
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                            // space
                                            SizedBox(height: 7.sp),
                                            Text(
                                              S.of(context).currency,
                                              style: StyleText
                                                  .fontSize12Weight500
                                                  .copyWith(
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                            // space
                                            SizedBox(height: 7.sp),
                                            Text(
                                              S.of(context).advancedDeposit,
                                              style: StyleText
                                                  .fontSize12Weight500
                                                  .copyWith(
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                            // space
                                            SizedBox(height: 7.sp),
                                            Text(
                                              S.of(context).totalHT,
                                              style: StyleText
                                                  .fontSize12Weight500
                                                  .copyWith(
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                            // space
                                            SizedBox(height: 7.sp),
                                            Text(
                                              S.of(context).totalVAT,
                                              style: StyleText
                                                  .fontSize12Weight500
                                                  .copyWith(
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                        isMobile
                                            ? Spacer()
                                            : SizedBox(
                                                width: MediaQuery.sizeOf(
                                                      context,
                                                    ).width *
                                                    .08,
                                              ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              widget.products[0].paymentMethod
                                                  .value,
                                              style: StyleText
                                                  .fontSize12Weight500
                                                  .copyWith(
                                                color: AppColors.blackButton,
                                              ),
                                            ),
                                            // space
                                            SizedBox(height: 7.sp),
                                            Text(
                                              widget.products[0].currency.value,
                                              style: StyleText
                                                  .fontSize12Weight500
                                                  .copyWith(
                                                color: AppColors.blackButton,
                                              ),
                                            ),
                                            // space
                                            SizedBox(height: 7.sp),
                                            Text(
                                              "€3,000",
                                              style: StyleText
                                                  .fontSize12Weight500
                                                  .copyWith(
                                                color: AppColors.blackButton,
                                              ),
                                            ),
                                            // space
                                            SizedBox(height: 7.sp),
                                            Text(
                                              "€3,000",
                                              style: StyleText
                                                  .fontSize12Weight500
                                                  .copyWith(
                                                color: AppColors.blackButton,
                                              ),
                                            ),
                                            // space
                                            SizedBox(height: 7.sp),
                                            Text(
                                              widget.products[0].vat.value,
                                              style: StyleText
                                                  .fontSize12Weight500
                                                  .copyWith(
                                                color: AppColors.blackButton,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 15.sp),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    endIndent: 10,
                                    indent:
                                        MediaQuery.sizeOf(context).width * .6,
                                    color: lightMode
                                        ? AppColors.grey
                                        : AppColors.whiteShadow,
                                  ),
                                  Row(
                                    mainAxisAlignment: isMobile
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 15.sp),
                                        child: Text(
                                          S.of(context).totalPrice,
                                          style: StyleText.fontSize12Weight500
                                              .copyWith(
                                            color: AppColors.blackButton,
                                          ),
                                        ),
                                      ),
                                      lightMode
                                          ? Spacer()
                                          : SizedBox(
                                              width: MediaQuery.sizeOf(
                                                    context,
                                                  ).width *
                                                  .11,
                                            ),
                                      Text(
                                        widget.products[0].orderValue.value,
                                        style: StyleText.fontSize12Weight500
                                            .copyWith(
                                          color: AppColors.blackButton,
                                        ),
                                      ),
                                      SizedBox(width: 15.sp),
                                    ],
                                  ),
                                  SizedBox(height: 15.sp),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Add this method to your _InvoiceDetailsScreenState class:
  List<Map<String, dynamic>> _convertProductsToTableData(
    List<ProductModel> products,
  ) {
    return products.map((product) {
      return {
        'productName': {
          'en': product.brand.value.isNotEmpty
              ? "${product.brand.value} ${product.model.value}"
              : 'Product Name',
          'ar': product.brand.value.isNotEmpty
              ? "${product.brand.value} ${product.model.value}"
              : 'اسم المنتج',
        },
        'category': {
          'en': product.category.value.isNotEmpty
              ? '${product.category.value} / ${product.subCategory.value}'
              : 'Category / Subcategory',
          'ar': product.category.value.isNotEmpty
              ? '${product.category.value} / ${product.subCategory.value}'
              : 'الفئة / الفئة الفرعية',
        },
        'quantity': product.quantity.value.isNotEmpty
            ? int.tryParse(product.quantity.value) ?? 0
            : 0,
        'unit': {
          'en': product.currency.value.isNotEmpty
              ? product.currency.value
              : 'Unit(s)',
          'ar': product.currency.value.isNotEmpty
              ? product.currency.value
              : 'وحدة',
        },
        'unitPrice': product.unitCost.value.isNotEmpty
            ? double.tryParse(product.unitCost.value) ?? 0.0
            : 0.0,
        'vat': product.vat.value.isNotEmpty ? '${product.vat.value}%' : '0%',
        'amount': product.orderValue.value.isNotEmpty
            ? product.orderValue.value
            : '\$0',
        'finalAmount':
            product.unitCost.value.isNotEmpty ? product.unitCost.value : '\$0',
      };
    }).toList();
  }

  Widget _buildSupplierSection() {
    if (_isLoadingSupplier) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 15.sp),
        child: Column(
          children: [
            SizedBox(
              width: 20.sp,
              height: 20.sp,
              child: CircleProgressMaster.inline(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            SizedBox(height: 8.sp),
            Text(
              "Loading supplier data...",
              style: StyleText.fontSize10Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    if (_supplierData != null) {
      return _buildSupplierInfoWithData(_supplierData!);
    }

    // Fallback to your existing supplier info section
    return supplierInfoSection();
  }

  Widget _buildSupplierInfoWithData(SupplierModel supplier) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Supplier ID
          Text(
            "${S.of(context).supplierId}: ${supplier.supplierID}",
            style: StyleText.fontSize14Weight600.copyWith(
              color: AppColors.secondaryText,
            ),
          ),

          SizedBox(height: 8.sp),

          // Supplier Name
          containerInfo(
            label: supplier.supplierName.isNotEmpty
                ? supplier.supplierName
                : S.of(context).supplierName,
            lightMode: lightMode,
          ),

          SizedBox(height: 8.sp),

          // Country, City, Postal Code
          containerInfo(
            label:
                "${supplier.country} ${supplier.city} ${supplier.postalCode}",
            lightMode: lightMode,
          ),

          SizedBox(height: 8.sp),

          // Contact Details
          containerInfo(
            label:
                "${supplier.title} ${supplier.phoneNumber} ${supplier.email}",
            lightMode: lightMode,
          ),

          SizedBox(height: 8.sp),

          // Business Type
          containerInfo(
            label: supplier.businessType.isNotEmpty
                ? supplier.businessType
                : S.of(context).businessType,
            lightMode: lightMode,
          ),

          SizedBox(height: 8.sp),

          // Tax Number
          containerInfo(
            label: supplier.taxNumber.isNotEmpty
                ? supplier.taxNumber
                : S.of(context).taxNumber,
            lightMode: lightMode,
          ),

          SizedBox(height: 8.sp),

          // Order Note
          Text(
            S.of(context).orderNote,
            style: StyleText.fontSize12Weight600.copyWith(
              color: AppColors.secondaryText,
            ),
          ),

          SizedBox(height: 4.sp),

          SizedBox(
            width: isTablet && !isLandscape ? 320.sp : 590.sp,
            child: Text(
              S.of(context).infoOrder,
              style: StyleText.fontSize10Weight500.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget supplierInfoSection() {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Supplier Id
          Text(
            "${S.of(context).supplierId}: 001",
            style: StyleText.fontSize14Weight600.copyWith(
              color: AppColors.secondaryText,
            ),
          ),

          // space
          SizedBox(height: 8.sp),

          // Supplier Name
          containerInfo(
            label: S.of(context).supplierName,
            lightMode: Theme.of(context).brightness == Brightness.light,
          ),

          // space
          SizedBox(height: 8.sp),

          // country & city & postalCode
          containerInfo(
            label:
                "${S.of(context).country} ${S.of(context).city} ${S.of(context).postalCode}",
            lightMode: Theme.of(context).brightness == Brightness.light,
          ),

          // space
          SizedBox(height: 8.sp),

          // pointOfContactDetails & phoneNumber & email
          containerInfo(
            label:
                "${S.of(context).pointOfContactDetails} ${S.of(context).phoneNumber} ${S.of(context).email}",
            lightMode: Theme.of(context).brightness == Brightness.light,
          ),

          // space
          SizedBox(height: 8.sp),

          // Business Type
          containerInfo(
            label: S.of(context).businessType,
            lightMode: Theme.of(context).brightness == Brightness.light,
          ),

          // space
          SizedBox(height: 8.sp),

          // Tax Number
          containerInfo(
            label: S.of(context).taxNumber,
            lightMode: Theme.of(context).brightness == Brightness.light,
          ),

          // space
          SizedBox(height: 8.sp),
          // Order Note
          Text(
            S.of(context).orderNote,
            style: StyleText.fontSize12Weight600.copyWith(
              color: AppColors.secondaryText,
            ),
          ),

          //space
          SizedBox(height: 4.sp),

          SizedBox(
            width: isTablet && !isLandscape ? 320.sp : 590.sp,
            child: Text(
              S.of(context).infoOrder,
              style: StyleText.fontSize10Weight500.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sideInfoSection() {
    final isTablet = context.isTablet;
    final isMobile = context.isPhone;
    final isLandscape = context.isLandscape;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(15.sp),
          child: Container(
            width: isMobile ? MediaQuery.sizeOf(context).width : 200.sp,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.background,
            ),
            child: Padding(
              padding: EdgeInsets.all(10.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  itemTextProduct(
                    label: "${S.of(context).orderID}: ",
                    value: widget.products[0].orderId.value,
                  ),
                  // space
                  SizedBox(height: isTablet && !isLandscape ? 13.sp : 9.sp),
                  itemTextProduct(
                    label: "${S.of(context).orderType}: ",
                    value: widget.products[0].orderType.value,
                  ),
                  // space
                  SizedBox(height: isTablet && !isLandscape ? 13.sp : 9.sp),
                  itemTextProduct(
                    label: "${S.of(context).orderStatus}: ",
                    value: widget.products[0].status.value,
                  ),
                  // space
                  SizedBox(height: isTablet && !isLandscape ? 13.sp : 9.sp),
                  itemTextProduct(
                    label: "${S.of(context).orderDate}: ",
                    value: DateFormat(
                      'dd MMM yyyy',
                    ).format(widget.products[0].orderId.timestamp),
                  ),
                  // space
                  SizedBox(height: isTablet && !isLandscape ? 13.sp : 9.sp),
                  itemTextProduct(
                    label: "${S.of(context).deliveryMethod}: ",
                    value: widget.products[0].deliveryMethod.value,
                  ),
                  // space
                  SizedBox(height: isTablet && !isLandscape ? 13.sp : 9.sp),

                  // Received By
                  isMobile
                      ? itemTextProduct(
                          label: "${S.of(context).receivedBy}: ",
                          value: "Yahya Yasin",
                        )
                      : Column(
                          children: [
                            Text(
                              S.of(context).receivedBy,
                              style: StyleText.fontSize12Weight500.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),
                            // space
                            SizedBox(
                              height: isTablet && !isLandscape ? 14.sp : 9.sp,
                            ),

                            // value of Received By
                            Text(
                              "Yahya Yasin",
                              style: StyleText.fontSize12Weight500.copyWith(
                                color: AppColors.blackButton,
                              ),
                            ),
                          ],
                        ),
                  // space
                  SizedBox(height: isTablet && !isLandscape ? 14.sp : 9.sp),

                  // Expected Delivery Date
                  isMobile
                      ? itemTextProduct(
                          label: "${S.of(context).expectedDeliveryDate}: ",
                          value: widget.products[0].expectedDelivery.value,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).expectedDeliveryDate,
                              style: StyleText.fontSize12Weight500.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),

                            // space
                            SizedBox(
                              height: isTablet && !isLandscape ? 14.sp : 9.sp,
                            ),
                            // value of Expected Delivery Date
                            Text(
                              widget.products[0].expectedDelivery.value,
                              style: StyleText.fontSize12Weight500.copyWith(
                                color: AppColors.blackButton,
                              ),
                            ),
                          ],
                        ),

                  // space
                  SizedBox(height: isTablet && !isLandscape ? 13.sp : 9.sp),

                  // Received Date
                  isMobile
                      ? itemTextProduct(
                          label: "${S.of(context).receivedDate}: ",
                          value: "03/05/2020",
                        )
                      : Column(
                          children: [
                            Text(
                              S.of(context).receivedDate,
                              style: StyleText.fontSize12Weight500.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),

                            // space
                            SizedBox(
                              height: isTablet && !isLandscape ? 13.sp : 9.sp,
                            ),

                            // value of Received Date
                            Text(
                              "03/05/2020",
                              style: StyleText.fontSize12Weight500.copyWith(
                                color: AppColors.blackButton,
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget orderInfoUser() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order Created By
        Row(
          children: [
            Text(
              "${S.of(context).orderCreatedBy}: ",
              style: StyleText.fontSize14Weight600.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            // Name Person
            Text(
              isArabic
                  ? "${widget.products[0].firstNameArCreator.value} ${widget.products[0].lastNameArCreator.value}"
                  : "${widget.products[0].firstNameCreator.value} ${widget.products[0].lastNameCreator.value}",
              style: StyleText.fontSize14Weight600.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ],
        ),

        // space
        SizedBox(height: 8.sp),

        // Job Title
        itemTextProduct(
          label: "${S.of(context).jobTitle}: ",
          value: isArabic
              ? widget.products[0].jobTitleArCreator.value
              : widget.products[0].jobTitleCreator.value,
        ),
        // space
        SizedBox(height: 4.sp),
        // Department
        itemTextProduct(
          label: "${S.of(context).department}: ",
          value: isArabic
              ? widget.products[0].departmentCreator.value
              : widget.products[0].departmentArCreator.value,
        ),
        // space
        SizedBox(height: 4.sp),
        // Phone Number
        itemTextProduct(
          label: "${S.of(context).phoneNumber}: ",
          value: isArabic
              ? widget.products[0].phoneCreator.value
              : widget.products[0].phoneCreator.value,
        ),
        // space
        SizedBox(height: 4.sp),
        // email
        itemTextProduct(
          label: "${S.of(context).email}: ",
          value: widget.products[0].emailCreator.value,
        ),
      ],
    );
  }

  //////////////////////////////// Under table Data /////////////////////////////

  Widget buildLabelValueRow({
    required BuildContext context,
    required String label,
    required String value,
    required bool lightMode,
  }) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: StyleText.fontSize12Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
        SizedBox(width: 30.sp),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              value,
              style: StyleText.fontSize12Weight500.copyWith(
                color: AppColors.blackButton,
              ),
            ),
          ],
        ),
        SizedBox(width: 27.sp),
      ],
    );
  }

  //////////////////////////////// Under table Data /////////////////////////////

  ///////////////////////////////// Dummy Data Table //////////////////////////////

  final List<Map<String, dynamic>> dummyData = [
    {
      'productName': {'en': 'Product Name', 'ar': 'اسم المنتج'},
      'category': {
        'en': 'Category / Subcategory',
        'ar': 'الفئة / الفئة الفرعية',
      },
      'quantity': 150,
      'unit': {'en': 'Unit(s)', 'ar': 'وحدة'},
      'unitPrice': 20,
      'vat': '0%',
      'amount': '\$3,000',
      'finalAmount': '\$3,000',
    },
    {
      'productName': {'en': 'Product Name', 'ar': 'اسم المنتج'},
      'category': {
        'en': 'Category / Subcategory',
        'ar': 'الفئة / الفئة الفرعية',
      },
      'quantity': 150,
      'unit': {'en': 'Unit(s)', 'ar': 'وحدة'},
      'unitPrice': 20,
      'vat': '0%',
      'amount': '\$3,000',
      'finalAmount': '\$3,000',
    },
    {
      'productName': {'en': 'Product Name', 'ar': 'اسم المنتج'},
      'category': {
        'en': 'Category / Subcategory',
        'ar': 'الفئة / الفئة الفرعية',
      },
      'quantity': 150,
      'unit': {'en': 'Unit(s)', 'ar': 'وحدة'},
      'unitPrice': 20,
      'vat': '0%',
      'amount': '\$3,000',
      'finalAmount': '\$3,000',
    },
  ];

  ///////////////////////////////// Dummy Data Table //////////////////////////////

  Widget containerInfo({
    required String label,
    required bool lightMode,
    TextStyle? textStyle,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
  }) {
    final isMobile = context.isPhone;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
      child: Row(
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              label,
              style: textStyle ??
                  StyleText.fontSize12Weight600.copyWith(
                    color: AppColors.blackButton,
                  ),
            ),
          ),
        ],
      ),
    );
  }

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

  // Add this method to your _InvoiceDetailsScreenState class

  Future<void> _handlePdfDownload() async {
    debugPrint('🔄 Download button pressed');

    try {
      // Validate data first
      if (widget.products.isEmpty) {
        throw Exception('No products available');
      }

      // Show loading dialog
      showAppDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircleProgressMaster.inline(),
                SizedBox(width: 20),
                Text('Generating PDF...'),
              ],
            ),
          );
        },
      );

      debugPrint('📄 Starting PDF generation...');

      // Generate PDF
      final pdfBytes = await PdfService.generateInvoicePdf(
        products: widget.products,
        supplier: _supplierData,
        isArabic: Localizations.localeOf(context).languageCode == 'ar',
      );

      debugPrint(
          '✅ PDF generated successfully, size: ${pdfBytes.length} bytes');

      // Close loading dialog
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Create filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final orderId = widget.products[0].orderId.value.isNotEmpty
          ? widget.products[0].orderId.value
          : 'invoice';
      final fileName = 'invoice_${orderId}_$timestamp.pdf';

      debugPrint('💾 Attempting to download/share PDF...');

      // Download/Share PDF
      await PdfService.downloadPdf(pdfBytes, fileName);

      debugPrint('✅ PDF download/share completed');

      // Show success dialog instead of snackbar
      if (mounted) {
        showAppDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              content: SizedBox(
                width: 411.w,
                height: 160.h,
                child: Column(
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
                      S.of(context).downloadPage,
                      style: StyleText.fontSize20Weight600.copyWith(),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      S.of(context).successDownloadPage,
                      style: StyleText.fontSize14Weight500,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      debugPrint('❌ Error in PDF download: $e');

      // Close loading dialog if still open
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error dialog instead of snackbar
      if (mounted) {
        CustomDialogManager.showMessage(
          context: context,
          lottiePath:
              'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
          title: S.of(context).error,
          subtitle: S.of(context).pdfCouldNotBeGenerated,
          closeAfter: const Duration(seconds: 5),
        );
      }
    }
  }
}

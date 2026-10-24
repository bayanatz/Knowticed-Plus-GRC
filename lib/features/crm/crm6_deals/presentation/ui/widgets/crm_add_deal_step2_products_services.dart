// ****************** FILE INFO ******************
// File Name: crm_add_deal_step2_products_services.dart
// Purpose: Step 2 (Add Products & Services with Summary) of the Add Deal wizard
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/inputs/default_switch_button.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_category_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_item_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/entities/crm_deal_line_item_draft.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_deal_summary_card.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CrmAddDealStep2ProductsServices extends StatefulWidget {
  final bool productsEnabled;
  final ValueChanged<bool> onProductsToggleChanged;
  final List<String> productCategoryIds;
  final ValueChanged<List<String>> onProductCategoryIdsChanged;

  final bool servicesEnabled;
  final ValueChanged<bool> onServicesToggleChanged;
  final List<String> serviceCategoryIds;
  final ValueChanged<List<String>> onServiceCategoryIdsChanged;
  final String currency;

  final List<CrmProductCategoryModel>? productCategories;
  final List<CrmProductItemModel>? products;
  final List<CrmServiceCategoryModel>? serviceCategories;
  final List<CrmServiceItemModel>? services;

  final List<DealProductLineItem> productLines;
  final List<DealServiceLineItem> serviceLines;
  final void Function(int index, String? productId) onProductChanged;
  final void Function(int index, String? serviceId) onServiceChanged;
  final VoidCallback onAddProductLine;
  final ValueChanged<int> onRemoveProductLine;
  final VoidCallback onAddServiceLine;
  final ValueChanged<int> onRemoveServiceLine;
  final bool isSubmitted;

  const CrmAddDealStep2ProductsServices({
    super.key,
    required this.productsEnabled,
    required this.onProductsToggleChanged,
    required this.productCategoryIds,
    required this.onProductCategoryIdsChanged,
    required this.servicesEnabled,
    required this.onServicesToggleChanged,
    required this.serviceCategoryIds,
    required this.onServiceCategoryIdsChanged,
    this.currency = 'EGP',
    this.productCategories,
    this.products,
    this.serviceCategories,
    this.services,
    required this.productLines,
    required this.serviceLines,
    required this.onProductChanged,
    required this.onServiceChanged,
    required this.onAddProductLine,
    required this.onRemoveProductLine,
    required this.onAddServiceLine,
    required this.onRemoveServiceLine,
    required this.isSubmitted,
  });

  @override
  State<CrmAddDealStep2ProductsServices> createState() =>
      _CrmAddDealStep2ProductsServicesState();
}

class _CrmAddDealStep2ProductsServicesState
    extends State<CrmAddDealStep2ProductsServices> {
  List<CrmProductCategoryModel> get _productCategories =>
      widget.productCategories == null
          ? <CrmProductCategoryModel>[]
          : widget.productCategories!
              .where((CrmProductCategoryModel c) => c.isActive && !c.isDeleted)
              .toList();

  List<CrmProductItemModel> get _availableProducts => widget.products == null
      ? <CrmProductItemModel>[]
      : widget.products!
          .where((CrmProductItemModel p) => p.isActive && !p.isDeleted)
          .where((CrmProductItemModel product) =>
              widget.productCategoryIds.contains(product.categoryId))
          .toList();

  List<CrmServiceCategoryModel> get _serviceCategories =>
      widget.serviceCategories == null
          ? <CrmServiceCategoryModel>[]
          : widget.serviceCategories!
              .where((CrmServiceCategoryModel c) => c.isActive && !c.isDeleted)
              .toList();

  List<CrmServiceItemModel> get _availableServices => widget.services == null
      ? <CrmServiceItemModel>[]
      : widget.services!
          .where((CrmServiceItemModel s) => s.isActive && !s.isDeleted)
          .where((CrmServiceItemModel service) =>
              widget.serviceCategoryIds.contains(service.categoryId))
          .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── Section 1: Details (Products & Services switches + Category) ────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Details',
            arabicName: 'التفاصيل',
          ),
          child: buildResponsiveFields(
            context: context,
            left: _buildProductToggleColumn(context),
            right: _buildServiceToggleColumn(context),
          ),
        ),

        // ── Section 2: Products/lines ─────────────────────────────────────────
        if (widget.productsEnabled) ...<Widget>[
          SizedBox(height: 24.sp),
          CrmSectionCard(
            title: FormatHelper.localizedString(
              englishName: 'Products/lines',
              arabicName: 'المنتجات / البنود',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int i = 0;
                    i < widget.productLines.length;
                    i++) ...<Widget>[
                  if (i > 0) SizedBox(height: 16.sp),
                  _buildProductLineRow(context, i, widget.productLines[i]),
                ],
                SizedBox(height: 16.sp),
                _buildAddButton(
                  title: 'Product',
                  onTap: widget.onAddProductLine,
                ),
              ],
            ),
          ),
        ],

        // ── Section 3: Services ───────────────────────────────────────────────
        if (widget.servicesEnabled) ...<Widget>[
          SizedBox(height: 24.sp),
          CrmSectionCard(
            title: FormatHelper.localizedString(
              englishName: 'Services',
              arabicName: 'الخدمات',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int i = 0;
                    i < widget.serviceLines.length;
                    i++) ...<Widget>[
                  if (i > 0) SizedBox(height: 16.sp),
                  _buildServiceLineRow(context, i, widget.serviceLines[i]),
                ],
                SizedBox(height: 16.sp),
                _buildAddButton(
                  title: 'Service',
                  onTap: widget.onAddServiceLine,
                ),
              ],
            ),
          ),
        ],

        if (widget.productsEnabled || widget.servicesEnabled) ...<Widget>[
          SizedBox(height: 24.sp),
          // ── Section 4: Summary ──────────────────────────────────────────────
          CrmSectionCard(
            title: FormatHelper.localizedString(
              englishName: 'Summary',
              arabicName: 'الملخص',
            ),
            child: CrmAddDealSummaryCard(
              productsEnabled: widget.productsEnabled,
              servicesEnabled: widget.servicesEnabled,
              productLines: widget.productLines,
              serviceLines: widget.serviceLines,
              currency: widget.currency,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProductToggleColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Products',
              style: StyleText.fontSize14Weight500.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            DefaultSwitchButton(
              value: widget.productsEnabled,
              onChanged: widget.onProductsToggleChanged,
            ),
          ],
        ),
        SizedBox(height: 8.sp),
        CustomMultiSelectFilter<String>(
          hint: 'Choose Category',
          values: widget.productCategoryIds,
          items: _productCategories
              .map((CrmProductCategoryModel category) =>
                  MultiSelectDropdownItem<String>(
                    value: category.id,
                    label: FormatHelper.localizedString(
                      englishName: category.nameEn,
                      arabicName: category.nameAr,
                    ),
                  ))
              .toList(),
          fillColor: AppColors.background,
          enabled: widget.productsEnabled,
          onChanged: widget.onProductCategoryIdsChanged,
        ),
      ],
    );
  }

  Widget _buildServiceToggleColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Services',
              style: StyleText.fontSize14Weight500.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            DefaultSwitchButton(
              value: widget.servicesEnabled,
              onChanged: widget.onServicesToggleChanged,
            ),
          ],
        ),
        SizedBox(height: 8.sp),
        CustomMultiSelectFilter<String>(
          hint: 'Choose Category',
          values: widget.serviceCategoryIds,
          items: _serviceCategories
              .map((CrmServiceCategoryModel category) =>
                  MultiSelectDropdownItem<String>(
                    value: category.id,
                    label: FormatHelper.localizedString(
                      englishName: category.nameEn,
                      arabicName: category.nameAr,
                    ),
                  ))
              .toList(),
          fillColor: AppColors.background,
          enabled: widget.servicesEnabled,
          onChanged: widget.onServiceCategoryIdsChanged,
        ),
      ],
    );
  }

  Widget _buildProductLineRow(
    BuildContext context,
    int index,
    DealProductLineItem item,
  ) {
    final bool hasSelectedProduct = item.product != null;
    final bool canSelectProduct = widget.productCategoryIds.isNotEmpty;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Product dropdown
              SizedBox(
                width: 200.sp,
                child: CustomDropdown<String>(
                  label: 'Product',
                  hint: 'Choose',
                  value: item.product,
                  items: _availableProducts
                      .map(
                          (CrmProductItemModel product) => DropdownItem<String>(
                                value: product.id,
                                label: FormatHelper.localizedString(
                                  englishName: product.nameEn,
                                  arabicName: product.nameAr,
                                ),
                              ))
                      .toList(),
                  fillColor: AppColors.background,
                  enabled: canSelectProduct,
                  errorText: (widget.isSubmitted && item.product == null)
                      ? 'Field Required'
                      : null,
                  onChanged: (String? value) =>
                      widget.onProductChanged(index, value),
                ),
              ),
              SizedBox(width: 12.sp),

              // Quantity textfield
              SizedBox(
                width: 120.sp,
                child: CustomTextField(
                  label: 'Quantity',
                  hint: 'Text Here',
                  keyboardType: TextInputType.number,
                  fillColor: AppColors.background,
                  enabled: hasSelectedProduct,
                  initialValue: item.quantity,
                  errorText: (widget.isSubmitted &&
                          hasSelectedProduct &&
                          item.quantity.trim().isEmpty)
                      ? 'Field Required'
                      : null,
                  onChanged: (String val) =>
                      setState(() => item.quantity = val),
                ),
              ),
              SizedBox(width: 12.sp),

              // Unit Price
              SizedBox(
                width: 100.sp,
                child: CustomTextField(
                  key: ValueKey<String>(
                    'product_price_${index}_${item.product}_${item.unitPrice}',
                  ),
                  label: 'Unit Price',
                  initialValue: hasSelectedProduct
                      ? '${widget.currency} ${item.unitPrice.toStringAsFixed(0)}'
                      : '',
                  readOnly: true,
                  fillColor: AppColors.background,
                ),
              ),
              SizedBox(width: 12.sp),

              // Discount
              SizedBox(
                width: 100.sp,
                child: CustomTextField(
                  key: ValueKey<String>(
                    'product_discount_${index}_${item.product}_${item.discount}',
                  ),
                  label: 'Discount',
                  initialValue: hasSelectedProduct
                      ? '${item.discount.toStringAsFixed(0)}%'
                      : '',
                  readOnly: true,
                  fillColor: AppColors.background,
                ),
              ),
              SizedBox(width: 12.sp),

              // Tax
              SizedBox(
                width: 100.sp,
                child: CustomTextField(
                  key: ValueKey<String>(
                    'product_tax_${index}_${item.product}_${item.tax}',
                  ),
                  label: 'Tax',
                  initialValue: hasSelectedProduct
                      ? '${widget.currency} ${item.tax.toStringAsFixed(0)}'
                      : '',
                  readOnly: true,
                  fillColor: AppColors.background,
                ),
              ),
              SizedBox(width: 12.sp),

              // Total
              SizedBox(
                width: 100.sp,
                child: CustomTextField(
                  key: ValueKey<String>(
                      'prod_tot_${index}_${item.quantity}_${item.total}'),
                  label: 'Total',
                  initialValue: hasSelectedProduct
                      ? '${widget.currency} ${item.total.toStringAsFixed(0)}'
                      : '',
                  readOnly: true,
                  fillColor: AppColors.background,
                ),
              ),
              SizedBox(width: 12.sp),

              // Remove Icon
              Padding(
                padding: EdgeInsets.only(top: 26.sp),
                child: IconButton(
                  icon: Icon(
                    Icons.remove_circle,
                    color: AppColors.red,
                    size: 22.sp,
                  ),
                  onPressed: withHaptic(
                      widget.productLines.length > 1
                          ? () => widget.onRemoveProductLine(index)
                          : null,
                      HapticLevel.high),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceLineRow(
    BuildContext context,
    int index,
    DealServiceLineItem item,
  ) {
    final bool hasSelectedService = item.service != null;
    final bool canSelectService = widget.serviceCategoryIds.isNotEmpty;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Service dropdown
              SizedBox(
                width: 220.sp,
                child: CustomDropdown<String>(
                  label: 'Service',
                  hint: 'Choose',
                  value: item.service,
                  items: _availableServices
                      .map(
                          (CrmServiceItemModel service) => DropdownItem<String>(
                                value: service.id,
                                label: FormatHelper.localizedString(
                                  englishName: service.nameEn,
                                  arabicName: service.nameAr,
                                ),
                              ))
                      .toList(),
                  fillColor: AppColors.background,
                  enabled: canSelectService,
                  errorText: (widget.isSubmitted && item.service == null)
                      ? 'Field Required'
                      : null,
                  onChanged: (String? value) =>
                      widget.onServiceChanged(index, value),
                ),
              ),
              SizedBox(width: 12.sp),

              // Price
              SizedBox(
                width: 120.sp,
                child: CustomTextField(
                  key: ValueKey<String>(
                    'service_price_${index}_${item.service}_${item.price}',
                  ),
                  label: 'Price',
                  initialValue: hasSelectedService
                      ? '${widget.currency} ${item.price.toStringAsFixed(0)}'
                      : '',
                  readOnly: true,
                  fillColor: AppColors.background,
                ),
              ),
              SizedBox(width: 12.sp),

              // Discount is copied from the matching discount control.
              SizedBox(
                width: 120.sp,
                child: CustomTextField(
                  key: ValueKey<String>(
                    'service_discount_${index}_${item.service}_${item.discount}',
                  ),
                  label: 'Discount',
                  fillColor: AppColors.background,
                  initialValue: hasSelectedService ? '${item.discount}%' : '',
                  readOnly: true,
                ),
              ),
              SizedBox(width: 12.sp),

              // Tax
              SizedBox(
                width: 120.sp,
                child: CustomTextField(
                  key: ValueKey<String>(
                    'service_tax_${index}_${item.service}_${item.tax}',
                  ),
                  label: 'Tax',
                  initialValue: hasSelectedService
                      ? '${widget.currency} ${item.tax.toStringAsFixed(0)}'
                      : '',
                  readOnly: true,
                  fillColor: AppColors.background,
                ),
              ),
              SizedBox(width: 12.sp),

              // Total
              SizedBox(
                width: 120.sp,
                child: CustomTextField(
                  key: ValueKey<String>(
                      'serv_tot_${index}_${item.discount}_${item.total}'),
                  label: 'Total',
                  initialValue: hasSelectedService
                      ? '${widget.currency} ${item.total.toStringAsFixed(0)}'
                      : '',
                  readOnly: true,
                  fillColor: AppColors.background,
                ),
              ),
              SizedBox(width: 12.sp),

              // Remove Icon
              Padding(
                padding: EdgeInsets.only(top: 26.sp),
                child: IconButton(
                  icon: Icon(
                    Icons.remove_circle,
                    color: AppColors.red,
                    size: 22.sp,
                  ),
                  onPressed: withHaptic(
                      widget.serviceLines.length > 1
                          ? () => widget.onRemoveServiceLine(index)
                          : null,
                      HapticLevel.high),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddButton({
    required String title,
    required VoidCallback onTap,
  }) =>
      customButtonWithSvg(
        title: title,
        function: onTap,
        textStyle: StyleText.fontSize14Weight500.copyWith(
          color: AppTheme.readableOn(AppColors.blackButton),
          fontWeight: FontWeight.bold,
        ),
        color: AppColors.blackButton,
        colorBorder: AppColors.blackButton,
        image: AppAssets.crmPlusBold,
        svgColor: AppTheme.readableOn(AppColors.blackButton),
        widthImage: 16.sp,
        heightImage: 16.sp,
        fixedWidth: 135.sp,
      );
}

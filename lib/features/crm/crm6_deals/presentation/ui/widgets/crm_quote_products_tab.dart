// ****************** FILE INFO ******************
// File Name: crm_quote_products_tab.dart
// Purpose: Products/lines tab content for Quote Details page supporting view mode and edit mode with permission banner
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_quote_summary_section.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class QuoteProductLineItemModel {
  String category;
  String product;
  String quantity;
  String unitPrice;
  String discount;
  String tax;
  String total;

  QuoteProductLineItemModel({
    this.category = 'Category x',
    this.product = 'Product x',
    this.quantity = '7',
    this.unitPrice = '\$50',
    this.discount = '20%',
    this.tax = '\$50',
    this.total = '\$50',
  });

  factory QuoteProductLineItemModel.fromSnapshot(
    Map<String, dynamic> snapshot,
    String currency,
  ) {
    final String discountValue =
        '${snapshot['Discount_Value'] ?? snapshot['Discount'] ?? ''}';
    final String discountType =
        '${snapshot['Discount_Type'] ?? ''}'.toLowerCase();
    final String formattedDiscount = discountValue.isEmpty
        ? ''
        : discountType.contains('percent') || discountType == 'percentage'
            ? '$discountValue%'
            : '$currency $discountValue';
    return QuoteProductLineItemModel(
      category: _text(snapshot, <String>[
        'Category_Name_En',
        'Category_Name_Ar',
      ]),
      product: _text(snapshot, <String>[
        'Product_Name_En',
        'Name_En',
        'Product_Name_Ar',
        'Name_Ar',
      ]),
      quantity: '${snapshot['Quantity'] ?? ''}',
      unitPrice: _money(snapshot['Unit_Price'], currency),
      discount: formattedDiscount,
      tax: _money(snapshot['Tax'], currency),
      total: _money(snapshot['Total'], currency),
    );
  }

  static String _text(Map<String, dynamic> value, List<String> keys) {
    for (final String key in keys) {
      final String text = '${value[key] ?? ''}'.trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static String _money(dynamic value, String currency) =>
      value == null || '$value'.isEmpty ? '' : '$currency $value';
}

class CrmQuoteProductsTab extends StatefulWidget {
  final bool isEditMode;
  final bool hasPermission;
  final VoidCallback? onEditTap;
  final VoidCallback? onDiscardTap;
  final VoidCallback? onSaveTap;
  final List<QuoteProductLineItemModel> items;
  final String subtotalValue;
  final String taxesValue;
  final String discountValue;
  final String totalValue;

  const CrmQuoteProductsTab({
    super.key,
    this.isEditMode = false,
    this.hasPermission = true,
    this.onEditTap,
    this.onDiscardTap,
    this.onSaveTap,
    this.items = const <QuoteProductLineItemModel>[],
    this.subtotalValue = '',
    this.taxesValue = '',
    this.discountValue = '',
    this.totalValue = '',
  });

  @override
  State<CrmQuoteProductsTab> createState() => _CrmQuoteProductsTabState();
}

class _CrmQuoteProductsTabState extends State<CrmQuoteProductsTab> {
  late List<QuoteProductLineItemModel> _items;

  static const List<String> _categories = <String>[
    'Category x',
    'Category y',
    'Category z',
  ];

  static const List<String> _products = <String>[
    'Product x',
    'Product y',
    'Product z',
  ];

  @override
  void initState() {
    super.initState();
    _items = _copyItems(widget.items);
  }

  @override
  void didUpdateWidget(covariant CrmQuoteProductsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _items = _copyItems(widget.items);
    }
  }

  List<QuoteProductLineItemModel> _copyItems(
    List<QuoteProductLineItemModel> items,
  ) =>
      items
          .map((QuoteProductLineItemModel item) => QuoteProductLineItemModel(
                category: item.category,
                product: item.product,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                discount: item.discount,
                tax: item.tax,
                total: item.total,
              ))
          .toList();

  void _addProduct() {
    setState(() {
      _items.add(QuoteProductLineItemModel());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── 1. Products/lines Section Card ───────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Products/lines',
            arabicName: 'المنتجات / البنود',
          ),
          showHideToggle: true,
          trailing: (!widget.isEditMode && widget.onEditTap != null)
              ? _buildEditButton(context)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Permission Banner (when in edit mode & hasPermission is false)
              if (widget.isEditMode && !widget.hasPermission) ...<Widget>[
                _buildPermissionBanner(context),
                SizedBox(height: 16.sp),
              ],

              // Table Rows
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (int i = 0; i < _items.length; i++) ...<Widget>[
                      if (i > 0) SizedBox(height: 12.sp),
                      _buildProductRow(context, i, _items[i]),
                    ],
                  ],
                ),
              ),

              // + Product Button (only in edit mode when user has permission)
              if (widget.isEditMode && widget.hasPermission) ...<Widget>[
                SizedBox(height: 16.sp),
                _buildAddProductButton(context),
              ],
            ],
          ),
        ),

        SizedBox(height: 24.sp),

        // ── 2. Summary Section Card ──────────────────────────────────────────
        CrmQuoteSummarySection(
          subtotalLabel: 'Subtotal (${_items.length} item)',
          subtotalValue: widget.subtotalValue,
          taxesValue: widget.taxesValue,
          discountPercentage: '',
          discountValue: widget.discountValue,
          totalValue: widget.totalValue,
        ),

        // ── 3. Bottom Discard / Save Action Bar (in edit mode) ───────────────
        if (widget.isEditMode) ...<Widget>[
          SizedBox(height: 32.sp),
          _buildEditBottomBar(context),
        ],
      ],
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return customButtonWithSvg(
      title: FormatHelper.localizedString(
        englishName: 'Edit',
        arabicName: 'تعديل',
      ),
      image: AppAssets.edit,
      widthImage: 14.sp,
      heightImage: 14.sp,
      colorBorder: Colors.transparent,
      color: AppColors.primary,
      textStyle: StyleText.fontSize14Weight500.copyWith(
        fontWeight: FontWeight.bold,
      ),
      function: widget.onEditTap!,
    );
  }

  Widget _buildPermissionBanner(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 10.sp),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7), // Light amber/yellow tint
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: const Color(0xFFFDE68A),
          width: 1.sp,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.lock_outline,
            color: AppColors.orange,
            size: 16.sp,
          ),
          SizedBox(width: 8.sp),
          Text(
            FormatHelper.localizedString(
              englishName: "You don't have permission to edit product",
              arabicName: 'ليس لديك صلاحية لتعديل المنتج',
            ),
            style: StyleText.fontSize12Weight400.copyWith(
              color: const Color(0xFF92400E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(
    BuildContext context,
    int index,
    QuoteProductLineItemModel item,
  ) {
    if (!widget.isEditMode) {
      // ── View Mode: Read-only grey textfields ──
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildCell(
            label: 'Category',
            width: 160.sp,
            child: CustomTextField(
              initialValue: item.category,
              readOnly: true,
              fillColor: AppColors.background,
            ),
          ),
          SizedBox(width: 12.sp),
          _buildCell(
            label: 'Product',
            width: 160.sp,
            child: CustomTextField(
              initialValue: item.product,
              readOnly: true,
              fillColor: AppColors.background,
            ),
          ),
          SizedBox(width: 12.sp),
          _buildCell(
            label: 'Quantity',
            width: 90.sp,
            child: CustomTextField(
              initialValue: item.quantity,
              readOnly: true,
              fillColor: AppColors.background,
            ),
          ),
          SizedBox(width: 12.sp),
          _buildCell(
            label: 'Unit Price',
            width: 140.sp,
            child: CustomTextField(
              initialValue: item.unitPrice,
              readOnly: true,
              fillColor: AppColors.background,
            ),
          ),
          SizedBox(width: 12.sp),
          _buildCell(
            label: 'Discount',
            width: 120.sp,
            child: CustomTextField(
              initialValue: item.discount,
              readOnly: true,
              fillColor: AppColors.background,
            ),
          ),
          SizedBox(width: 12.sp),
          _buildCell(
            label: 'Tax',
            width: 130.sp,
            child: CustomTextField(
              initialValue: item.tax,
              readOnly: true,
              fillColor: AppColors.background,
            ),
          ),
          SizedBox(width: 12.sp),
          _buildCell(
            label: 'Total',
            width: 140.sp,
            child: CustomTextField(
              initialValue: item.total,
              readOnly: true,
              fillColor: AppColors.background,
            ),
          ),
        ],
      );
    }

    // ── Edit Mode: Dropdowns & Editable Textfields ──
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Category Dropdown
        _buildCell(
          label: 'Category',
          width: 160.sp,
          child: CustomDropdown<String>(
            hint: 'Choose',
            value: item.category,
            items: _categories
                .map((String c) => DropdownItem<String>(value: c, label: c))
                .toList(),
            fillColor: AppColors.background,
            onChanged: (String? val) {
              if (val != null) setState(() => item.category = val);
            },
          ),
        ),
        SizedBox(width: 12.sp),

        // Product Dropdown
        _buildCell(
          label: 'Product',
          width: 160.sp,
          child: CustomDropdown<String>(
            hint: 'Choose',
            value: item.product,
            items: _products
                .map((String p) => DropdownItem<String>(value: p, label: p))
                .toList(),
            fillColor: AppColors.background,
            onChanged: (String? val) {
              if (val != null) setState(() => item.product = val);
            },
          ),
        ),
        SizedBox(width: 12.sp),

        // Quantity
        _buildCell(
          label: 'Quantity',
          width: 90.sp,
          child: CustomTextField(
            initialValue: item.quantity,
            keyboardType: TextInputType.number,
            fillColor: AppColors.background,
            onChanged: (String val) => item.quantity = val,
          ),
        ),
        SizedBox(width: 12.sp),

        // Unit Price
        _buildCell(
          label: 'Unit Price',
          width: 140.sp,
          child: CustomTextField(
            initialValue: item.unitPrice,
            fillColor: AppColors.background,
            onChanged: (String val) => item.unitPrice = val,
          ),
        ),
        SizedBox(width: 12.sp),

        // Discount
        _buildCell(
          label: 'Discount',
          width: 120.sp,
          child: CustomTextField(
            initialValue: item.discount,
            fillColor: AppColors.background,
            onChanged: (String val) => item.discount = val,
          ),
        ),
        SizedBox(width: 12.sp),

        // Tax
        _buildCell(
          label: 'Tax',
          width: 130.sp,
          child: CustomTextField(
            initialValue: item.tax,
            fillColor: AppColors.background,
            onChanged: (String val) => item.tax = val,
          ),
        ),
        SizedBox(width: 12.sp),

        // Total
        _buildCell(
          label: 'Total',
          width: 140.sp,
          child: CustomTextField(
            initialValue: item.total,
            fillColor: AppColors.background,
            onChanged: (String val) => item.total = val,
          ),
        ),
      ],
    );
  }

  Widget _buildCell({
    required String label,
    required double width,
    required Widget child,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.sp),
          child,
        ],
      ),
    );
  }

  Widget _buildAddProductButton(BuildContext context) {
    return InkWell(
      onTapDown: hapticDown(_addProduct, HapticLevel.medium),
      onTap: _addProduct,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B), // Dark container
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.add, color: AppColors.white, size: 16.sp),
            SizedBox(width: 6.sp),
            Text(
              FormatHelper.localizedString(
                englishName: 'Product',
                arabicName: 'منتج',
              ),
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditBottomBar(BuildContext context) {
    final bool isSendRequest = !widget.hasPermission;

    return Row(
      textDirection: TextDirection
          .ltr, // X-73: Cancel left, action right in both languages

      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        customButton(
          title: FormatHelper.localizedString(
            englishName: 'Discard',
            arabicName: 'تراجع',
          ),
          color: const Color(0xFFE5E7EB),
          borderColor: Colors.transparent,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.blackButton,
          ),
          function: widget.onDiscardTap ?? () {},
        ),
        customButton(
          title: isSendRequest
              ? FormatHelper.localizedString(
                  englishName: 'Send Request',
                  arabicName: 'إرسال طلب',
                )
              : FormatHelper.localizedString(
                  englishName: 'Save',
                  arabicName: 'حفظ',
                ),
          color: AppColors.primary,
          borderColor: Colors.transparent,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.blackButton,
          ),
          function: () {
            if (isSendRequest) {
              CrmControlDialogs.showSuccessDialog(
                context: context,
                title: FormatHelper.localizedString(
                  englishName: 'Request Sent',
                  arabicName: 'تم إرسال الطلب',
                ),
                subtitle: FormatHelper.localizedString(
                  englishName:
                      'Your permission request to edit products has been sent to admin.',
                  arabicName:
                      'تم إرسال طلب الصلاحية لتعديل المنتجات إلى المسؤول.',
                ),
              );
              widget.onDiscardTap?.call();
            } else {
              widget.onSaveTap?.call();
            }
          },
        ),
      ],
    );
  }
}

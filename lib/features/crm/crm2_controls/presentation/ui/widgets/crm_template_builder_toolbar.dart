// ****************** FILE INFO ******************
// File Name: crm_template_builder_toolbar.dart
// Purpose: Toolbar widget containing search, category/type filters, custom grid, layout, and add actions
// Author: Mohand Adel
// Created At: 06/10/2026

import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_field_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplateBuilderToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final String? selectedType;
  final ValueChanged<String?> onTypeChanged;
  final List<CrmTemplateSectionModel> sections;
  final List<CrmFieldTypeModel> fieldTypes;
  final VoidCallback onAdd;
  final VoidCallback onLayout;
  final VoidCallback onCustomGrid;

  const CrmTemplateBuilderToolbar({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.selectedType,
    required this.onTypeChanged,
    required this.sections,
    required this.fieldTypes,
    required this.onAdd,
    required this.onLayout,
    required this.onCustomGrid,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = kpIsPhoneLayout(context);

    if (isMobile) {
      return _buildMobileToolbar(context);
    }
    return _buildDesktopToolbar(context);
  }

  Widget _buildMobileToolbar(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppSearchTextField(
                controller: searchController,
                onChanged: onSearch,
                hintText: S.current.crmSearch,
              ),
            ),
            SizedBox(width: ButtonSizing.toolbarGap(context)),
            customButtonWithSvg(
              title: '',
              function: onAdd,
              textStyle: StyleText.fontSize14Weight600
                  .copyWith(color: AppColors.blackButton),
              color: AppColors.primary,
              image: AppAssets.crmPlusBold,
              widthImage: 18.sp,
              heightImage: 18.sp,
              colorBorder: AppColors.primary,
              svgColor: AppColors.black,
            ),
          ],
        ),
        SizedBox(height: 10.sp),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 38.sp,
                child: _buildCategoryDropdown(),
              ),
            ),
            SizedBox(width: 8.sp),
            Expanded(
              child: SizedBox(
                height: 38.sp,
                child: _buildTypeDropdown(),
              ),
            ),
            SizedBox(width: 8.sp),
            customButtonWithSvg(
              title: '',
              function: onCustomGrid,
              textStyle: StyleText.fontSize14Weight600
                  .copyWith(color: AppColors.blackButton),
              color: AppColors.primary,
              image: AppAssets.grid,
              widthImage: 18.sp,
              heightImage: 18.sp,
              colorBorder: AppColors.primary,
              svgColor: AppColors.black,
            ),
            SizedBox(width: 8.sp),
            customButtonWithSvg(
              title: '',
              function: onLayout,
              textStyle: StyleText.fontSize14Weight600
                  .copyWith(color: AppColors.blackButton),
              color: AppColors.primary,
              image: AppAssets.crmTemplate,
              widthImage: 18.sp,
              heightImage: 18.sp,
              colorBorder: AppColors.primary,
              svgColor: AppColors.black,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopToolbar(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppSearchTextField(
                controller: searchController,
                onChanged: onSearch,
                hintText: S.current.crmSearch,
              ),
            ),
            SizedBox(width: ButtonSizing.toolbarGap(context)),
            customButtonWithSvg(
              title: S.current.crmAdd,
              function: onAdd,
              // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
              textStyle: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.blackButton),
              color: AppColors.primary,
              image: AppAssets.crmPlusBold,
              widthImage: 18.sp,
              heightImage: 18.sp,
              colorBorder: AppColors.primary,
              svgColor: AppColors.black,
            ),
          ],
        ),
        SizedBox(height: 12.sp),
        Row(
          children: [
            SizedBox(
              width: 130.sp,
              height: 38.sp,
              child: _buildCategoryDropdown(),
            ),
            SizedBox(width: 12.sp),
            SizedBox(
              width: 130.sp,
              height: 38.sp,
              child: _buildTypeDropdown(),
            ),
            const Spacer(),
            customButtonWithSvg(
              title: S.current.crmCustomGrid,
              function: onCustomGrid,
              // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
              textStyle: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.blackButton),
              color: AppColors.primary,
              image: AppAssets.grid,
              widthImage: 18.sp,
              heightImage: 18.sp,
              colorBorder: AppColors.primary,
              svgColor: AppColors.black,
            ),
            SizedBox(width: 12.sp),
            customButtonWithSvg(
              title: S.current.crmLayout,
              function: onLayout,
              // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
              textStyle: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.blackButton),
              color: AppColors.primary,
              image: AppAssets.crmTemplate,
              widthImage: 18.sp,
              heightImage: 18.sp,
              colorBorder: AppColors.primary,
              svgColor: AppColors.black,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return CustomDropdown<String>(
      value: selectedCategory,
      hint: S.current.crmCategory,
      items: <String>[
        'All',
        ...sections.map((s) => FormatHelper.localizedString(
              englishName: s.nameEn,
              arabicName: s.nameAr,
            )),
      ]
          .map(
            (opt) => DropdownItem<String>(
              value: opt,
              label: opt == 'All' ? S.current.crmAll : opt,
            ),
          )
          .toList(),
      onChanged: onCategoryChanged,
      fillColor: AppColors.card,
      borderRadius: BorderRadius.circular(8.sp),
      valueStyle:
          StyleText.fontSize12Weight500.copyWith(color: AppColors.black),
      hintStyle: StyleText.fontSize12Weight500
          .copyWith(color: AppColors.secondaryBlack),
      itemStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.black),
    );
  }

  Widget _buildTypeDropdown() {
    return CustomDropdown<String>(
      value: selectedType,
      hint: S.current.crmType,
      items: <String>[
        'All',
        ...fieldTypes.map((ft) => FormatHelper.localizedString(
              englishName: ft.nameEn,
              arabicName: ft.nameAr,
            )),
      ]
          .map(
            (opt) => DropdownItem<String>(
              value: opt,
              label: opt == 'All' ? S.current.crmAll : opt,
            ),
          )
          .toList(),
      onChanged: onTypeChanged,
      fillColor: AppColors.card,
      borderRadius: BorderRadius.circular(8.sp),
      valueStyle:
          StyleText.fontSize12Weight500.copyWith(color: AppColors.black),
      hintStyle: StyleText.fontSize12Weight500
          .copyWith(color: AppColors.secondaryBlack),
      itemStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.black),
    );
  }
}

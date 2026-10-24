// Module: crm / crm17_delivery_rules
// ****************** FILE INFO ******************
// File Name: crm_delivery_rule_form_page.dart
// Purpose: Add, details, and edit page for delivery fee rules
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/domain/entities/crm_delivery_rule.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/domain/interfaces/crm_delivery_rules_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/presentation/controller/crm_delivery_rule_form_cubit.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/presentation/controller/crm_delivery_rule_form_state.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmDeliveryRuleFormPage extends StatefulWidget {
  final CrmDeliveryRule? rule;
  const CrmDeliveryRuleFormPage({super.key, this.rule});

  @override
  State<CrmDeliveryRuleFormPage> createState() =>
      _CrmDeliveryRuleFormPageState();
}

class _CrmDeliveryRuleFormPageState extends State<CrmDeliveryRuleFormPage> {
  late final CrmDeliveryRuleFormCubit _cubit;
  late bool _readOnly;
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameArController;

  @override
  void initState() {
    super.initState();
    _readOnly = widget.rule != null;
    _cubit = CrmDeliveryRuleFormCubit(
        repository: Get.find<CrmDeliveryRulesBaseRepository>(),
        rule: widget.rule);
    _nameEnController = TextEditingController(text: widget.rule?.nameEn);
    _nameArController = TextEditingController(text: widget.rule?.nameAr);
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _save() => CrmControlDialogs.showSaveDialog(
        context: context,
        title: widget.rule == null ? 'Add Rule' : 'Save Rule',
        subtitle: 'Are you sure you want to save this delivery rule?',
        onConfirm: () async {
          showLoadingIndicator();
          final bool saved = await _cubit.save();
          hideLoadingIndicator();
          if (!mounted || !saved) return;
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: S.current.crmSuccess,
            subtitle: widget.rule == null
                ? 'Delivery rule added successfully'
                : 'Delivery rule updated successfully',
            onComplete: () {
              if (mounted) {
                if (widget.rule != null) {
                  setState(() => _readOnly = true);
                } else {
                  Navigator.of(context).pop();
                }
              }
            },
          );
        },
      );

  void _delete() => CrmControlDialogs.showRemoveDialog(
        context: context,
        title: 'Delete Rule',
        subtitle: 'Are you sure you want to delete this delivery rule?',
        onConfirm: () async {
          showLoadingIndicator();
          final bool deleted = await _cubit.delete();
          hideLoadingIndicator();
          if (!mounted || !deleted) return;
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: S.current.crmSuccess,
            subtitle: 'Delivery rule deleted successfully',
            onComplete: () {
              if (mounted) Navigator.of(context).pop();
            },
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final String pageTitle = widget.rule == null
        ? FormatHelper.localizedString(
            englishName: 'Add Rule',
            arabicName: 'إضافة قاعدة',
          )
        : (_readOnly
            ? FormatHelper.localizedString(
                englishName: 'Package Details',
                arabicName: 'تفاصيل الباقة',
              )
            : FormatHelper.localizedString(
                englishName: 'Edit Rule',
                arabicName: 'تعديل القاعدة',
              ));

    return BlocConsumer<CrmDeliveryRuleFormCubit, CrmDeliveryRuleFormState>(
      bloc: _cubit,
      listener: (BuildContext context, CrmDeliveryRuleFormState state) {
        if (state.errorMessage != null) {
          final String message = state.errorMessage!;
          _cubit.clearError();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            CrmControlDialogs.showErrorDialog(
              context: context,
              title: S.current.crmAlert,
              subtitle: message,
            );
          });
        }
      },
      builder: (BuildContext context, CrmDeliveryRuleFormState state) =>
          Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.current.crm,
          secondTitle: S.current.crmSectionControls,
          thirdTitle: S.current.crmControlDeliveryRules,
          fourthTitle: pageTitle,
          onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
          onSecondTap: () => CrmNavigationHelper.pop(context),
          onThirdTap: () => CrmNavigationHelper.pop(context),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Action triggers in details mode: Edit & Delete icons on top right
                if (widget.rule != null && _readOnly) ...<Widget>[
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Wrap(
                      spacing: 8.sp,
                      children: <Widget>[
                        CustomEditIcon(
                            onTap: () => setState(() => _readOnly = false)),
                        CustomDeleteIcon(onTap: _delete),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.sp),
                ],

                // Section 1: Rule Details
                _details(state.rule),
                SizedBox(height: 14.sp),

                // Section 2: Ranges / Zones / Criteria
                if (state.rule.basedOn == 'Zone')
                  _zones(state.rule)
                else if (state.rule.basedOn == 'Criteria')
                  _criteria(state.rule)
                else
                  _ranges(state.rule.ranges),
                SizedBox(height: 14.sp),

                // Section 3: Delivery Time
                _deliveryTime(state.rule),

                // Bottom Action Buttons in Edit/Add Mode
                if (!_readOnly) ...<Widget>[
                  SizedBox(height: 24.sp),
                  Row(
                    textDirection: TextDirection
                        .ltr, // X-73: Cancel left, action right in both languages

                    children: <Widget>[
                      Expanded(
                        child: customButton(
                          title: S.current.crmDiscard,
                          function: () {
                            if (widget.rule != null) {
                              setState(() => _readOnly = true);
                            } else {
                              CrmNavigationHelper.pop(context);
                            }
                          },
                          color: AppColors.grey,
                          textColor: AppColors.black,
                        ),
                      ),
                      SizedBox(width: 16.sp),
                      Expanded(
                        child: customButton(
                          title: widget.rule == null
                              ? S.current.crmAdd
                              : S.current.crmSave,
                          function: _save,
                          color: AppColors.primary,
                          textColor: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 32.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _details(CrmDeliveryRule rule) => CrmSectionCard(
        title: FormatHelper.localizedString(
          englishName: 'Rule Details',
          arabicName: 'تفاصيل القاعدة',
        ),
        showHideToggle: true,
        child: Column(
          children: <Widget>[
            buildResponsiveFields(
              context: context,
              left: _field(
                label: 'Rule Name',
                controller: _nameEnController,
                hint: 'Text Here',
                readOnly: _readOnly,
                onChanged: _cubit.updateNameEn,
              ),
              right: Directionality(
                textDirection: TextDirection.rtl,
                child: _field(
                  label: 'اسم القاعدة',
                  controller: _nameArController,
                  hint: 'اكتب هنا',
                  readOnly: _readOnly,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  onChanged: _cubit.updateNameAr,
                ),
              ),
            ),
            SizedBox(height: 14.sp),
            buildResponsiveFields(
              context: context,
              left: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Based on',
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.text),
                  ),
                  SizedBox(height: 6.sp),
                  CustomDropdown<String>(
                    hint: 'Choose',
                    value: rule.basedOn,
                    enabled: !_readOnly,
                    fillColor: AppColors.background,
                    items: const <DropdownItem<String>>[
                      DropdownItem(value: 'Quantity', label: 'Quantity'),
                      DropdownItem(value: 'Zone', label: 'Zone'),
                      DropdownItem(value: 'Criteria', label: 'Criteria')
                    ],
                    onChanged: _cubit.updateBasedOn,
                  ),
                ],
              ),
              right: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Currency',
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.text),
                  ),
                  SizedBox(height: 6.sp),
                  CustomDropdown<String>(
                    hint: 'Choose',
                    value: rule.currency.isEmpty ? null : rule.currency,
                    enabled: !_readOnly,
                    fillColor: AppColors.background,
                    items: const <DropdownItem<String>>[
                      DropdownItem(value: 'EGP', label: 'EGP'),
                      DropdownItem(value: 'QAR', label: 'QAR'),
                      DropdownItem(value: 'SAR', label: 'SAR'),
                      DropdownItem(value: 'USD', label: 'USD')
                    ],
                    onChanged: _cubit.updateCurrency,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _ranges(List<CrmDeliveryRange> ranges,
          {int? criterionIndex, String title = 'Ranges'}) =>
      CrmSectionCard(
        title: FormatHelper.localizedString(
          englishName: title,
          arabicName: 'النطاقات',
        ),
        showHideToggle: true,
        child: Column(
          children: <Widget>[
            for (int index = 0; index < ranges.length; index++) ...<Widget>[
              _rangeItem(ranges[index], index, criterionIndex, ranges.length),
              if (index < ranges.length - 1) SizedBox(height: 16.sp),
            ],
            if (!_readOnly) ...<Widget>[
              SizedBox(height: 14.sp),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: customButtonWithSvg(
                  title: FormatHelper.localizedString(
                    englishName: 'Range',
                    arabicName: 'نطاق',
                  ),
                  function: () =>
                      _cubit.addRange(criterionIndex: criterionIndex),
                  textStyle: StyleText.fontSize14Weight500.copyWith(
                      color: AppTheme.readableOn(AppColors.blackButton)),
                  color: AppColors.blackButton,
                  image: AppAssets.crmPlusBold,
                  widthImage: 16.sp,
                  heightImage: 16.sp,
                  colorBorder: AppColors.blackButton,
                  svgColor: AppTheme.readableOn(AppColors.blackButton),
                ),
              ),
            ],
          ],
        ),
      );

  Widget _rangeItem(CrmDeliveryRange range, int index, int? criterionIndex,
          int totalRanges) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Range ${index + 1}',
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.text),
              ),
              if (!_readOnly && totalRanges > 1)
                customButtonWithSvg(
                  title: '',
                  function: () =>
                      _cubit.removeRange(index, criterionIndex: criterionIndex),
                  color: AppColors.transparent,
                  colorBorder: AppColors.transparent,
                  image: AppAssets.minusCircle,
                  widthImage: 20.sp,
                  heightImage: 20.sp,
                  fixedWidth: 24.sp,
                  fixedHeight: 24.sp,
                  svgColor: AppColors.red,
                  textStyle: StyleText.fontSize12Weight400,
                ),
            ],
          ),
          SizedBox(height: 8.sp),
          Row(
            children: <Widget>[
              Expanded(
                child: _field(
                  label: 'From',
                  initialValue: range.from == 0 ? '' : range.from.toString(),
                  hint: 'Text Here',
                  readOnly: _readOnly,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (String value) => _cubit.updateRange(
                      index, 'from', value,
                      criterionIndex: criterionIndex),
                ),
              ),
              SizedBox(width: 12.sp),
              Expanded(
                child: _field(
                  label: 'To',
                  initialValue: range.to == 0 ? '' : range.to.toString(),
                  hint: 'Text Here',
                  readOnly: _readOnly,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (String value) => _cubit.updateRange(
                      index, 'to', value,
                      criterionIndex: criterionIndex),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.sp),
          Row(
            children: <Widget>[
              Expanded(
                child: _field(
                  label: 'Delivery Fee',
                  initialValue: range.fee == 0 ? '' : range.fee.toString(),
                  hint: 'Text Here',
                  readOnly: _readOnly,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (String value) => _cubit.updateRange(
                      index, 'fee', value,
                      criterionIndex: criterionIndex),
                ),
              ),
              SizedBox(width: 12.sp),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ],
      );

  Widget _zones(CrmDeliveryRule rule) => CrmSectionCard(
        title: 'Zones',
        showHideToggle: true,
        child: Column(
          children: <Widget>[
            for (int index = 0; index < rule.zones.length; index++) ...<Widget>[
              _zoneRow(rule.zones[index], index),
              if (index < rule.zones.length - 1) SizedBox(height: 12.sp)
            ],
            if (!_readOnly)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: EdgeInsets.only(top: 14.sp),
                  child: customButtonWithSvg(
                    title: 'Zone',
                    function: _cubit.addZone,
                    textStyle: StyleText.fontSize14Weight500.copyWith(
                        color: AppTheme.readableOn(AppColors.blackButton)),
                    color: AppColors.blackButton,
                    image: AppAssets.crmPlusBold,
                    widthImage: 16.sp,
                    heightImage: 16.sp,
                    colorBorder: AppColors.blackButton,
                    svgColor: AppTheme.readableOn(AppColors.blackButton),
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _zoneRow(CrmDeliveryZone zone, int index) => buildResponsiveFields(
        context: context,
        left: CustomMultiSelectFilter<String>(
          label: 'Counties',
          hint: 'Choose',
          values: zone.counties,
          enabled: !_readOnly,
          fillColor: AppColors.background,
          items: _locations('Cairo', 'Giza', 'Alexandria'),
          onChanged: (List<String> value) =>
              _cubit.updateZone(index, counties: value),
        ),
        right: buildResponsiveFields(
          context: context,
          left: CustomMultiSelectFilter<String>(
            label: 'Cities',
            hint: 'Choose',
            values: zone.cities,
            enabled: !_readOnly,
            fillColor: AppColors.background,
            items: _locations('Nasr City', 'Dokki', 'Maadi'),
            onChanged: (List<String> value) =>
                _cubit.updateZone(index, cities: value),
          ),
          right: CustomTextField(
            initialValue: zone.fee == 0 ? '' : zone.fee.toString(),
            label: 'Delivery Fee',
            hint: 'Text Here',
            readOnly: _readOnly,
            fillColor: AppColors.background,
            onChanged: (String value) => _cubit.updateZone(index, fee: value),
          ),
        ),
      );

  List<MultiSelectDropdownItem<String>> _locations(
          String first, String second, String third) =>
      <String>[first, second, third]
          .map((String item) =>
              MultiSelectDropdownItem<String>(value: item, label: item))
          .toList();

  Widget _criteria(CrmDeliveryRule rule) => Column(children: <Widget>[
        CrmSectionCard(
          title: 'Criteria Weights',
          showHideToggle: true,
          child: Column(
            children: <Widget>[
              for (int index = 0;
                  index < rule.criteria.length;
                  index++) ...<Widget>[
                buildResponsiveFields(
                  context: context,
                  left: CustomTextField(
                    initialValue: rule.criteria[index].name,
                    label: 'Criteria',
                    hint: 'Text Here',
                    readOnly: _readOnly,
                    fillColor: AppColors.background,
                    onChanged: (String value) =>
                        _cubit.updateCriterionName(index, value),
                  ),
                  right: CustomTextField(
                    initialValue: rule.criteria[index].weight == 0
                        ? ''
                        : rule.criteria[index].weight.toString(),
                    label: 'Weight',
                    hint: 'Text Here',
                    readOnly: _readOnly,
                    fillColor: AppColors.background,
                    onChanged: (String value) =>
                        _cubit.updateCriterionWeight(index, value),
                  ),
                ),
                if (index < rule.criteria.length - 1) SizedBox(height: 12.sp)
              ],
              if (!_readOnly)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: EdgeInsets.only(top: 14.sp),
                    child: customButtonWithSvg(
                      title: 'Criteria',
                      function: _cubit.addCriterion,
                      textStyle: StyleText.fontSize14Weight500.copyWith(
                          color: AppTheme.readableOn(AppColors.blackButton)),
                      color: AppColors.blackButton,
                      image: AppAssets.crmPlusBold,
                      widthImage: 16.sp,
                      heightImage: 16.sp,
                      colorBorder: AppColors.blackButton,
                      svgColor: AppTheme.readableOn(AppColors.blackButton),
                    ),
                  ),
                ),
            ],
          ),
        ),
        for (int index = 0; index < rule.criteria.length; index++)
          Padding(
            padding: EdgeInsets.only(top: 14.sp),
            child: _ranges(
              rule.criteria[index].ranges,
              criterionIndex: index,
              title:
                  '${rule.criteria[index].name} — Weight: ${rule.criteria[index].weight}%',
            ),
          ),
      ]);

  Widget _deliveryTime(CrmDeliveryRule rule) => CrmSectionCard(
        title: FormatHelper.localizedString(
          englishName: 'Delivery Time',
          arabicName: 'وقت التوصيل',
        ),
        showHideToggle: true,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isMobile = constraints.maxWidth < 600;
            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _field(
                    label: 'From',
                    initialValue: rule.deliveryFrom == 0
                        ? ''
                        : rule.deliveryFrom.toString(),
                    hint: 'Text Here',
                    readOnly: _readOnly,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: _cubit.updateDeliveryFrom,
                  ),
                  SizedBox(height: 12.sp),
                  _field(
                    label: 'To',
                    initialValue:
                        rule.deliveryTo == 0 ? '' : rule.deliveryTo.toString(),
                    hint: 'Text Here',
                    readOnly: _readOnly,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: _cubit.updateDeliveryTo,
                  ),
                  SizedBox(height: 12.sp),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Unit',
                        style: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.text),
                      ),
                      SizedBox(height: 6.sp),
                      CustomDropdown<String>(
                        hint: 'Choose',
                        value: rule.deliveryUnit,
                        enabled: !_readOnly,
                        fillColor: AppColors.background,
                        items: const <DropdownItem<String>>[
                          DropdownItem(value: 'Minutes', label: 'Minutes'),
                          DropdownItem(value: 'Hours', label: 'Hours'),
                          DropdownItem(value: 'Days', label: 'Days')
                        ],
                        onChanged: _cubit.updateDeliveryUnit,
                      ),
                    ],
                  ),
                ],
              );
            }
            return buildResponsiveFields(
              context: context,
              left: _field(
                label: 'From',
                initialValue:
                    rule.deliveryFrom == 0 ? '' : rule.deliveryFrom.toString(),
                hint: 'Text Here',
                readOnly: _readOnly,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: _cubit.updateDeliveryFrom,
              ),
              right: buildResponsiveFields(
                context: context,
                left: _field(
                  label: 'To',
                  initialValue:
                      rule.deliveryTo == 0 ? '' : rule.deliveryTo.toString(),
                  hint: 'Text Here',
                  readOnly: _readOnly,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: _cubit.updateDeliveryTo,
                ),
                right: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Unit',
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.text),
                    ),
                    SizedBox(height: 6.sp),
                    CustomDropdown<String>(
                      hint: 'Choose',
                      value: rule.deliveryUnit,
                      enabled: !_readOnly,
                      fillColor: AppColors.background,
                      items: const <DropdownItem<String>>[
                        DropdownItem(value: 'Minutes', label: 'Minutes'),
                        DropdownItem(value: 'Hours', label: 'Hours'),
                        DropdownItem(value: 'Days', label: 'Days')
                      ],
                      onChanged: _cubit.updateDeliveryUnit,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

  Widget _field({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    required String hint,
    required bool readOnly,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
    TextAlign textAlign = TextAlign.start,
    TextDirection? textDirection,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
          SizedBox(height: 6.sp),
          CustomTextField(
            controller: controller,
            initialValue: controller == null ? initialValue : null,
            hint: hint,
            readOnly: readOnly,
            textAlign: textAlign,
            textDirection: textDirection,
            fillColor: AppColors.background,
            keyboardType: keyboardType,
            onChanged: onChanged,
          ),
        ],
      );
}

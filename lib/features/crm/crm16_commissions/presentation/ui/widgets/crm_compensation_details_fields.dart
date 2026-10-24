// Module: crm / crm16_commissions
// ****************** FILE INFO ******************
// File Name: crm_compensation_details_fields.dart
// Purpose: Compensation category and type fields for commission packages
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/presentation/controller/crm_commission_form_state.dart';

class CrmCompensationDetailsFields extends StatelessWidget {
  final CrmCommissionFormState state;
  final TextEditingController valueController;
  final bool readOnly;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onValueChanged;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<String> onTiersTypeChanged;
  final ValueChanged<String> onTiersFrequencyChanged;

  const CrmCompensationDetailsFields({
    super.key,
    required this.state,
    required this.valueController,
    required this.readOnly,
    required this.onCategoryChanged,
    required this.onTypeChanged,
    required this.onValueChanged,
    required this.onCurrencyChanged,
    required this.onTiersTypeChanged,
    required this.onTiersFrequencyChanged,
  });

  bool get _isCommission => state.compensationCategory == 'Commission';

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          buildResponsiveFields(
            context: context,
            left: CustomDropdown<String>(
              label: 'Compensation Category',
              hint: 'Choose',
              value: state.compensationCategory,
              enabled: !readOnly,
              fillColor: AppColors.background,
              items: const <DropdownItem<String>>[
                DropdownItem<String>(value: 'Commission', label: 'Commission'),
                DropdownItem<String>(
                    value: 'Compensation', label: 'Compensation'),
              ],
              onChanged: onCategoryChanged,
            ),
            right: CustomDropdown<String>(
              label: 'Compensation Type',
              hint: 'Choose',
              value: state.compensationType,
              enabled: !readOnly,
              fillColor: AppColors.background,
              items: _typeItems,
              onChanged: onTypeChanged,
            ),
          ),
          if (_isCommission &&
              state.compensationType == 'Flat Rate') ...<Widget>[
            SizedBox(height: 14.sp),
            _valueField(context, label: 'Value'),
          ],
          if (!_isCommission) ...<Widget>[
            SizedBox(height: 14.sp),
            buildResponsiveFields(
              context: context,
              left: _valueField(context, label: 'Compensation Value'),
              right: state.compensationType == 'Amount'
                  ? _currencyDropdown()
                  : const SizedBox.shrink(),
            ),
          ],
          if (_isCommission && state.compensationType == 'Tiers') ...<Widget>[
            SizedBox(height: 14.sp),
            buildResponsiveFields(
              context: context,
              left: _tiersTypeDropdown(),
              right: _tiersFrequencyDropdown(),
            ),
          ],
        ],
      );

  List<DropdownItem<String>> get _typeItems => _isCommission
      ? const <DropdownItem<String>>[
          DropdownItem<String>(value: 'Flat Rate', label: 'Flat Rate'),
          DropdownItem<String>(value: 'Product Based', label: 'Product Based'),
          DropdownItem<String>(value: 'Tiers', label: 'Tiers'),
        ]
      : const <DropdownItem<String>>[
          DropdownItem<String>(value: 'Amount', label: 'Amount'),
          DropdownItem<String>(value: 'Percentage', label: 'Percentage'),
        ];

  Widget _valueField(BuildContext context, {required String label}) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox(
          width: kpIsPhoneLayout(context) ? null : 360.sp,
          child: CustomTextField(
            controller: valueController,
            label: label,
            hint: 'Text Here',
            enabled: !readOnly,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            fillColor: AppColors.background,
            onChanged: onValueChanged,
          ),
        ),
      );

  Widget _currencyDropdown() => CustomDropdown<String>(
        label: 'Currency',
        hint: 'Choose',
        value: state.currency.isEmpty ? null : state.currency,
        enabled: !readOnly,
        fillColor: AppColors.background,
        items: const <DropdownItem<String>>[
          DropdownItem<String>(value: 'EGP', label: 'EGP'),
          DropdownItem<String>(value: 'QAR', label: 'QAR'),
          DropdownItem<String>(value: 'SAR', label: 'SAR'),
          DropdownItem<String>(value: 'USD', label: 'USD'),
        ],
        onChanged: onCurrencyChanged,
      );

  Widget _tiersTypeDropdown() => CustomDropdown<String>(
        label: 'Tiers Type',
        hint: 'Choose',
        value: state.tiersType,
        enabled: !readOnly,
        fillColor: AppColors.background,
        items: const <DropdownItem<String>>[
          DropdownItem<String>(value: 'Count', label: 'Count'),
          DropdownItem<String>(value: 'Amount', label: 'Amount'),
        ],
        onChanged: onTiersTypeChanged,
      );

  Widget _tiersFrequencyDropdown() => CustomDropdown<String>(
        label: 'Tiers Frequency',
        hint: 'Choose',
        value: state.tiersFrequency,
        enabled: !readOnly,
        fillColor: AppColors.background,
        items: const <DropdownItem<String>>[
          DropdownItem<String>(value: 'Monthly', label: 'Monthly'),
          DropdownItem<String>(value: 'Quarterly', label: 'Quarterly'),
          DropdownItem<String>(value: 'Annually', label: 'Annually'),
          DropdownItem<String>(value: 'Weekly', label: 'Weekly'),
        ],
        onChanged: onTiersFrequencyChanged,
      );
}

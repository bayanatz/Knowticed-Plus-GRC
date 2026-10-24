// ****************** FILE INFO ******************
// File Name: crm_controls_dropdown_helper.dart
// Purpose: Helper class providing dropdown items and mapping functions using CRM Control enums
// Author: Mohand Adel
// Created At: 06/08/2026

import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/enums/crm_controls_enums.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Helper class providing strongly-typed enum dropdown lists and conversion utilities
abstract class CrmControlsDropdownHelper {
  /// Returns a list of [DropdownItem<String>] for Category selection (Section / Fields)
  static List<DropdownItem<String>> get categoryDropdownItems {
    return CrmCategoryEnum.values.map((e) => e.toDropdownItem()).toList();
  }

  /// Returns a list of [DropdownItem<String>] for Status selection (Active / Inactive / Deleted)
  static List<DropdownItem<String>> get statusDropdownItems {
    return CrmStatusEnum.values.map((e) => e.toDropdownItem()).toList();
  }

  /// Returns a list of [DropdownItem<String>] for Validation Type selection
  static List<DropdownItem<String>> get validationTypeDropdownItems {
    return CrmValidationTypeEnum.values.map((e) => e.toDropdownItem()).toList();
  }

  /// Returns a list of [MultiSelectDropdownItem<String>] for Text Validation Types (String / Numbers / Symbols)
  static List<MultiSelectDropdownItem<String>>
      get validationMultiSelectDropdownItems {
    return <MultiSelectDropdownItem<String>>[
      MultiSelectDropdownItem<String>(
        value: 'String',
        label: S.current.crmValidationLetters,
      ),
      MultiSelectDropdownItem<String>(
        value: 'Numbers',
        label: S.current.crmValidationNumbers,
      ),
      MultiSelectDropdownItem<String>(
        value: 'Symbols',
        label: S.current.crmValidationSymbols,
      ),
    ];
  }

  /// Returns a list of [MultiSelectDropdownItem<String>] for Allowed File Types
  static List<MultiSelectDropdownItem<String>>
      get allowedFileTypeDropdownItems {
    return CrmAllowedFileTypeEnum.values
        .map((e) => e.toMultiSelectDropdownItem())
        .toList();
  }

  /// Returns a list of [MultiSelectDropdownItem<String>] for Purchasing Validation
  static List<MultiSelectDropdownItem<String>>
      get purchasingValidationDropdownItems {
    return CrmPurchasingValidationEnum.values
        .map((e) => e.toMultiSelectDropdownItem())
        .toList();
  }

  /// Helper to convert a string category value to [CrmCategoryEnum]
  static CrmCategoryEnum parseCategory(String? value) {
    return CrmCategoryEnum.fromValue(value) ?? CrmCategoryEnum.section;
  }

  /// Helper to convert a string status value to [CrmStatusEnum]
  static CrmStatusEnum parseStatus(String? value) {
    return CrmStatusEnum.fromValue(value) ?? CrmStatusEnum.active;
  }

  /// Helper to convert a string validation type to [CrmValidationTypeEnum]
  static CrmValidationTypeEnum parseValidationType(String? value) {
    return CrmValidationTypeEnum.fromValue(value) ?? CrmValidationTypeEnum.none;
  }
}

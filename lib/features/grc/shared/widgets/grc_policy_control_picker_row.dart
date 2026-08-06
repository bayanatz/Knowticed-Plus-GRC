/// A "pick a Policy, then pick Controls for it" row used on every GRC
/// champion/owner Add/Edit/Reassign page. Extracted because the same
/// ~55-line Row (CustomDropdown + CustomMultiSelectDropdown) was
/// copy-pasted across 6 files (3 pages x champion/owner), differing only
/// in labels, spacing, and whether a remove-row button is shown.
library;

import 'package:grc_module/core/custom/1-custom_dropdwon.dart';
import 'package:grc_module/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/grc/control/domain/entities/control_entity.dart';
import 'package:grc_module/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/grc/shared/helpers/grc_l10n.dart';

class GrcPolicyControlPickerRow extends StatelessWidget {
  final List<PolicyEntity> policies;
  final bool policiesEnabled;
  final String? policyId;
  final ValueChanged<String?> onPolicyChanged;
  final String? policyErrorText;

  final List<ControlEntity> availableControls;
  final bool controlsEnabled;
  final List<String> controlIds;
  final ValueChanged<List<String>> onControlsChanged;
  final String? controlsErrorText;
  final String controlsLabel;
  final String controlsHint;

  /// Control ids shown in the dropdown but not selectable (e.g. a Control
  /// that already has a Champion/Owner assigned elsewhere) — the item still
  /// appears, just dimmed and unresponsive to taps.
  final List<String> disabledControlIds;

  /// Horizontal gap between the two dropdowns, pre-scaled by the caller
  /// (e.g. `10.w`, `12.w`, `16.w`) — the three call sites disagreed on
  /// this value and none of them treated it as meaningful, so it stays a
  /// parameter rather than being hardcoded.
  final double spacing;

  /// When set, renders a trailing close (×) button that calls this — used
  /// by Add pages, which let the user remove an entire row.
  final VoidCallback? onRemoveRow;

  const GrcPolicyControlPickerRow({
    super.key,
    required this.policies,
    required this.policyId,
    required this.onPolicyChanged,
    required this.availableControls,
    required this.controlIds,
    required this.onControlsChanged,
    this.policiesEnabled = true,
    this.controlsEnabled = true,
    this.policyErrorText,
    this.controlsErrorText,
    this.controlsLabel = 'Control',
    this.controlsHint = 'Choose Control',
    this.disabledControlIds = const [],
    this.spacing = 12,
    this.onRemoveRow,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomDropdown<String>(
            label: S.of(context).addPolicy,
            hint: S.of(context).choosePolicy,
            enabled: policiesEnabled,
            items: policies
                .map((p) => DropdownItem<String>(
                      value: p.id,
                      label: context.isArabic ? p.policyNameAr : p.policyNameEn,
                    ))
                .toList(),
            value: policyId,
            onChanged: onPolicyChanged,
            fillColor: AppColors.background,
            required: false,
            errorText: policyErrorText,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: CustomMultiSelectDropdown<String>(
            label: grcTr(context, controlsLabel),
            hint: grcTr(context, controlsHint),
            enabled: controlsEnabled,
            items: availableControls
                .map((c) => MultiSelectDropdownItem<String>(
                      value: c.id,
                      label: context.isArabic ? c.controlsNameAr : c.controlsNameEn,
                      enabled: !disabledControlIds.contains(c.id),
                    ))
                .toList(),
            values: controlIds,
            onChanged: onControlsChanged,
            fillColor: AppColors.background,
            required: false,
            errorText: controlsErrorText,
          ),
        ),
        if (onRemoveRow != null) ...[
          SizedBox(width: 8.w),
          Padding(
            padding: EdgeInsets.only(top: 24.h),
            child: IconButton(
              icon: const Icon(Icons.close),
              color: AppColors.red,
              onPressed: onRemoveRow,
            ),
          ),
        ],
      ],
    );
  }
}

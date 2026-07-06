/// Module: Policy Management
/// Description: Table widget that displays policy controls in preview mode,
///              supports inline weight editing, Equal Weight distribution,
///              and Total Weight validation (must equal 100 to publish).
/// Author: Mohamed Elrashidy
/// Date: 2026-07-06
/// Dependencies: Flutter SDK, AppColors, AppTheme, PolicyControlModel
/// Revision History: 2026-07-06 - Initial creation

library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_controls_table_widget.dart
/// Purpose: Contains PolicyControlsTableWidget, the preview table for
///          policy controls with edit / equal-weight / publish-validation
///          capabilities.
/// Author: Mohamed Elrashidy
/// Created At: 6/7/2026

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// class name: [PolicyControlsTableWidget]
///
/// purpose: display the policy controls as a preview table. In view mode
///          rows are read-only; clicking Edit enables inline weight editing
///          per row. Equal Weight distributes 100 equally across all rows.
///          The Total Weight badge turns green at exactly 100 and red
///          otherwise, and a validation message appears when needed.
///
/// authors: Mohamed Elrashidy
///
/// created at: 6/7/2026
class PolicyControlsTableWidget extends StatefulWidget {
  final List<PolicyControlModel> controls;

  /// Called when the user taps Save after editing weights.
  final VoidCallback? onSave;

  const PolicyControlsTableWidget({
    super.key,
    required this.controls,
    this.onSave,
  });

  @override
  State<PolicyControlsTableWidget> createState() =>
      _PolicyControlsTableWidgetState();
}

class _PolicyControlsTableWidgetState
    extends State<PolicyControlsTableWidget> {
  bool _isEditing = false;

  // Temporary weight controllers used while in edit mode.
  // Kept in a list parallel to widget.controls.
  late List<TextEditingController> _weightControllers;

  @override
  void initState() {
    super.initState();
    _initWeightControllers();
  }

  @override
  void didUpdateWidget(PolicyControlsTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-sync if the controls list changed (e.g. control added/removed).
    if (oldWidget.controls.length != widget.controls.length) {
      _disposeWeightControllers();
      _initWeightControllers();
    }
  }

  /// function name: [_initWeightControllers]
  ///
  /// purpose: initialise one TextEditingController per control, seeded with
  ///          the control's current weight value.
  ///
  /// parameters: none
  ///
  /// return type: void
  void _initWeightControllers() {
    _weightControllers = widget.controls.map((c) {
      final text = c.weightController.text.trim();
      return TextEditingController(text: text.isEmpty ? '0' : text);
    }).toList();
  }

  void _disposeWeightControllers() {
    for (final c in _weightControllers) {
      c.dispose();
    }
  }

  @override
  void dispose() {
    _disposeWeightControllers();
    super.dispose();
  }

  /// function name: [_totalWeight]
  ///
  /// purpose: calculate the sum of all weight values currently held in the
  ///          temporary weight controllers.
  ///
  /// parameters: none
  ///
  /// return type: [double] - the current total weight
  double get _totalWeight {
    return _weightControllers.fold(
      0,
      (sum, c) => sum + (double.tryParse(c.text.trim()) ?? 0),
    );
  }

  bool get _isWeightValid => _totalWeight == 100;

  /// function name: [_applyEqualWeight]
  ///
  /// purpose: distribute 100 equally across all controls by setting each
  ///          weight to (100 / count), rounded to 2 decimal places.
  ///
  /// parameters: none
  ///
  /// return type: void
  void _applyEqualWeight() {
    if (widget.controls.isEmpty) return;
    final each = (100 / widget.controls.length)
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'\.?0+$'), '');
    setState(() {
      for (final c in _weightControllers) {
        c.text = each;
      }
    });
  }

  /// function name: [_saveWeights]
  ///
  /// purpose: persist the edited weights back into each control's
  ///          [weightController] and exit edit mode.
  ///
  /// parameters: none
  ///
  /// return type: void
  void _saveWeights() {
    for (int i = 0; i < widget.controls.length; i++) {
      widget.controls[i].weightController.text =
          _weightControllers[i].text.trim();
    }
    setState(() => _isEditing = false);
    widget.onSave?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTableActions(),
        SizedBox(height: 8.h),
        _buildTable(),
        SizedBox(height: 12.h),
        _buildTotalWeightBadge(),
      ],
    );
  }

  // ------------------------------------------------------------------
  // TABLE ACTIONS ROW  (Edit  |  Equal Weight + Save)
  // ------------------------------------------------------------------
  Widget _buildTableActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_isEditing)
          // Equal Weight button — only visible while editing
          _actionButton(
            label: 'Equal Weight'.tr,
            color: AppColors.primary,
            textColor: AppColors.textButton,
            onTap: _applyEqualWeight,
          )
        else
          const SizedBox.shrink(),
        Row(
          children: [
            if (_isEditing)
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _actionButton(
                  label: 'Save'.tr,
                  color: AppColors.primary,
                  textColor: AppColors.textButton,
                  onTap: _saveWeights,
                ),
              ),
            // Edit / Done toggle button
            _actionButton(
              label: _isEditing ? 'Done'.tr : 'Edit'.tr,
              color: AppColors.background,
              textColor: AppColors.text,
              leading: _isEditing
                  ? null
                  : Icon(Icons.edit_outlined,
                      size: 14.sp, color: AppColors.text),
              onTap: () {
                if (_isEditing) {
                  // discard temporary edits on "Done" without saving
                  _initWeightControllers();
                }
                setState(() => _isEditing = !_isEditing);
              },
              bordered: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
    Widget? leading,
    bool bordered = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
          border: bordered
              ? Border.all(color: AppColors.secondaryText.withOpacity(.3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading, SizedBox(width: 6.w)],
            Text(label,
                style: StyleText.fontSize14Weight500.copyWith(color: textColor)),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // TABLE
  // ------------------------------------------------------------------
  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.secondaryText.withOpacity(.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(44),    // NO
            1: FlexColumnWidth(2),      // Control Name
            2: FlexColumnWidth(2.5),    // Description
            3: FixedColumnWidth(90),    // Weight
            4: FlexColumnWidth(1.8),    // Frequency
          },
          children: [
            _buildHeaderRow(),
            for (int i = 0; i < widget.controls.length; i++)
              _buildDataRow(i),
          ],
        ),
      ),
    );
  }

  TableRow _buildHeaderRow() {
    final headers = ['NO', 'Control Name', 'Description', 'Weight', 'Frequency'];
    return TableRow(
      decoration: const BoxDecoration(color: Colors.black),
      children: headers
          .map(
            (h) => Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
              child: Text(
                h.tr,
                style: StyleText.fontSize14Weight500.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow _buildDataRow(int index) {
    final control = widget.controls[index];
    final isEven = index % 2 == 0;

    return TableRow(
      decoration: BoxDecoration(
        color: isEven ? AppColors.background : AppColors.field,
      ),
      children: [
        // NO
        _cell(Text('${index + 1}',
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText))),
        // Control Name
        _cell(Text(
          control.nameController.text.trim().isEmpty
              ? '-'
              : control.nameController.text.trim(),
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          overflow: TextOverflow.ellipsis,
        )),
        // Description
        _cell(Text(
          control.descriptionController.text.trim().isEmpty
              ? '-'
              : control.descriptionController.text.trim(),
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryText),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        )),
        // Weight — editable field in edit mode
        _cell(
          _isEditing
              ? SizedBox(
                  width: 60.w,
                  child: TextField(
                    controller: _weightControllers[index],
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.text),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 6.h),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(.4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide:
                            BorderSide(color: AppColors.primary),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                )
              : Text(
                  control.weightController.text.trim().isEmpty
                      ? '0'
                      : control.weightController.text.trim(),
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.text),
                ),
        ),
        // Frequency
        _cell(Text(
          control.frequency?.isEmpty ?? true ? '-' : control.frequency!,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        )),
      ],
    );
  }

  Widget _cell(Widget child) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      child: child,
    );
  }

  // ------------------------------------------------------------------
  // TOTAL WEIGHT BADGE
  // ------------------------------------------------------------------
  Widget _buildTotalWeightBadge() {
    final total = _isEditing ? _totalWeight : _computeSavedTotal();
    final isValid = total == 100;
    final color = isValid ? Colors.green : Colors.red;

    return Column(
      children: [
        Center(
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '${'Total Weight'.tr} : ${total.toStringAsFixed(total.truncateToDouble() == total ? 0 : 1)}',
              style: StyleText.fontSize14Weight500.copyWith(color: color),
            ),
          ),
        ),
        if (!isValid) ...[
          SizedBox(height: 6.h),
          Center(
            child: Text(
              'Total Weight should be 100'.tr,
              style: StyleText.fontSize14Weight500
                  .copyWith(color: Colors.red),
            ),
          ),
        ],
      ],
    );
  }

  /// function name: [_computeSavedTotal]
  ///
  /// purpose: compute the total weight from the controls' own
  ///          [weightController] text (the persisted values, not the
  ///          temporary edit controllers).
  ///
  /// parameters: none
  ///
  /// return type: [double] - the total of saved weight values
  double _computeSavedTotal() {
    return widget.controls.fold(
      0,
      (sum, c) =>
          sum + (double.tryParse(c.weightController.text.trim()) ?? 0),
    );
  }
}
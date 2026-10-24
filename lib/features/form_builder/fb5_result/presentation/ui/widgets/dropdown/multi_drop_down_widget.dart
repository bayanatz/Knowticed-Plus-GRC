/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: multi_drop_down_widget.dart
/// Description: `MultiDropDownWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_view_multi_select_dropdown.dart';

/// A dropdown where several items can be picked.
class MultiDropDownWidget extends StatefulWidget {
  /// The title of the dropdown field
  final String title;

  /// The hint text displayed when no value is selected
  final String hint;

  /// The currently selected value
  final String? currentValue;

  /// Callback function triggered when the value changes
  final dynamic Function(dynamic) onChanged;

  /// List of dropdown menu items
  final List<String> items;
  final List<String> selectedItems;

  /// Validator function for validating the selected value
  final String? Function(dynamic)? validator;

  /// Path to the SVG icon displayed in the dropdown
  final String? svgIconPath;

  /// Text style for the dropdown text
  final TextStyle? textStyle;

  final Color? fillColor;
  final bool isReadOnly;

  /// The text shown for an item (see [CustomMultiSelectField.itemLabel]).
  final String Function(String item)? itemLabel;

  /// Constructor for initializing the DropDownWidget instance
  const MultiDropDownWidget({
    super.key,
    required this.title,
    required this.hint,
    required this.items,
    required this.currentValue,
    required this.onChanged,
    required this.selectedItems,
    this.validator,
    this.svgIconPath,
    this.textStyle,
    this.fillColor,
    this.isReadOnly = false,
    this.itemLabel,
  });
  @override
  State<MultiDropDownWidget> createState() => _MultiDropDownWidgetState();
}

class _MultiDropDownWidgetState extends State<MultiDropDownWidget> {
  // Set from the validator; cleared whenever the parent rebuilds this field,
  // as it was when these lived on the widget itself.
  bool _isShowError = false;
  String? _errorText;

  @override
  void didUpdateWidget(covariant MultiDropDownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isShowError = false;
    _errorText = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: StyleText.fontSize14Weight400),
        verticalSpace(8),
        // Dropdown field
        SizedBox(
          height: 36,
          child: CustomMultiSelectField(
            // Fixed 36 box: the field shows the selection itself (chips
            // below would overflow it).
            showSelectedBelow: false,
            selectedItems: widget.selectedItems,
            showErrorBorder: _isShowError,
            value: widget.currentValue,
            width: double.infinity,
            svgIconPath: widget.svgIconPath,
            fillColor: widget.fillColor ?? AppColors.background,
            textStyle: widget.textStyle,
            textButton: widget.currentValue ?? widget.hint,
            items: widget.items,
            itemLabel: widget.itemLabel,
            onChanged: widget.isReadOnly ? (v) {} : widget.onChanged,
            validator: (value) {
              var flag = widget.validator?.call(value);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _isShowError = flag != null;
                  _errorText = flag;
                });
              });
              return null;
            },
          ),
        ),
        if (_isShowError && _errorText != null) ...[
          verticalSpace(4),
          Text(_errorText!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red)),
        ],
      ],
    );
  }
}

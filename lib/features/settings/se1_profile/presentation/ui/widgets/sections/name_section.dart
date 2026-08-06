import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';

import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
class NameSection extends StatefulWidget {
  final Function(String)? firstNameOnChanged;
  final String? Function(String?)? firstNameValidator;
  final String? firstNameInitialValue;
  final bool isReadOnly;
  final String firstNameHint;
  final Function(String)? middleNameOnChanged;
  final String? Function(String?)? middleNameValidator;
  final String? middleNameInitialValue;
  final String middleNameHint;
  final Function(String)? lastNameOnChanged;
  final String? lastNameInitialValue;
  final String lastNameHint;
  final String? Function(String?)? lastNameValidator;
  final bool submitted;
  final String? title;

  const NameSection({
    Key? key,
    required this.isReadOnly,
    this.firstNameOnChanged,
    this.firstNameValidator,
    this.middleNameOnChanged,
    this.middleNameValidator,
    this.lastNameOnChanged,
    this.lastNameValidator,
    this.firstNameInitialValue,
    this.middleNameInitialValue,
    this.lastNameInitialValue,
    required this.firstNameHint,
    required this.middleNameHint,
    required this.lastNameHint,
    this.submitted = false,
    this.title,
  }) : super(key: key);

  @override
  State<NameSection> createState() => _NameSectionState();
}

class _NameSectionState extends State<NameSection> {
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstNameInitialValue ?? '');
    _middleNameController = TextEditingController(text: widget.middleNameInitialValue ?? '');
    _lastNameController = TextEditingController(text: widget.lastNameInitialValue ?? '');
  }

  @override
  void didUpdateWidget(NameSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controllers if initial values change
    if (oldWidget.firstNameInitialValue != widget.firstNameInitialValue) {
      _firstNameController.text = widget.firstNameInitialValue ?? '';
    }
    if (oldWidget.middleNameInitialValue != widget.middleNameInitialValue) {
      _middleNameController.text = widget.middleNameInitialValue ?? '';
    }
    if (oldWidget.lastNameInitialValue != widget.lastNameInitialValue) {
      _lastNameController.text = widget.lastNameInitialValue ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  // Determine text direction based on locale
  TextDirection _getTextDirection() {
    return Get.locale.toString().contains('ar') ? TextDirection.rtl : TextDirection.ltr;
  }

  @override
  Widget build(BuildContext context) {
    var isPhone = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isVertical = MediaQuery.of(context).orientation == Orientation.portrait;
    final textDirection = _getTextDirection();
    final isArabic = textDirection == TextDirection.rtl;

    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.transparent,
      ),
      child: isVertical
          ? _buildVerticalLayout(context, lightMode, textDirection, isArabic)
          : _buildHorizontalLayout(context, lightMode, textDirection, isArabic),
    );
  }

  Widget _buildVerticalLayout(BuildContext context, bool lightMode, TextDirection textDirection, bool isArabic) {
    var isPhone = ContextExtension(context).isPhone;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Optional Title
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: StyleText.fontSize16Weight600.copyWith(
              color: AppColors.text
            ),
          ),
          SizedBox(height: 16.h),
        ],

        // First Name Field
        CustomTextField(
          valueStyle: StyleText.fontSize12Weight500.copyWith(
            color: AppColors.text
          ),
          label: S.of(context).firstName,
          hint: widget.firstNameHint,
          controller: _firstNameController,
          textDirection: isArabic ?  TextDirection.rtl : TextDirection.ltr,
          enabled: !widget.isReadOnly,
          onChanged: (value) {
            if (widget.firstNameOnChanged != null) {
              widget.firstNameOnChanged!(value);
            }
          },
        ),

        isPhone ? SizedBox() : SizedBox(height: 16.h),

        // Middle Name Field
        CustomTextField(
          label: S.of(context).middleName,
          hint: widget.middleNameHint,
          controller: _middleNameController,
          textDirection: isArabic ?  TextDirection.rtl : TextDirection.ltr,
          enabled: !widget.isReadOnly,
          onChanged: (value) {
            if (widget.middleNameOnChanged != null) {
              widget.middleNameOnChanged!(value);
            }
          },
        ),

        isPhone ? SizedBox() : SizedBox(height: 16.h),

        // Last Name Field
        CustomTextField(
          label: S.of(context).lastName,
          hint: widget.lastNameHint,
          controller: _lastNameController,
          textDirection: isArabic ?  TextDirection.rtl : TextDirection.ltr,
          enabled: !widget.isReadOnly,
          onChanged: (value) {
            if (widget.lastNameOnChanged != null) {
              widget.lastNameOnChanged!(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout(BuildContext context, bool lightMode, TextDirection textDirection, bool isArabic) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Optional Title
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: StyleText.fontSize16Weight600.copyWith(
              color: AppColors.text
            ),
          ),
          SizedBox(height: 16.h),
        ],

        // Row with three name fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Name
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: isArabic ? 0 : 12.w,
                  left: isArabic ? 12.w : 0,
                ),
                child: CustomTextField(
                  label: S.of(context).firstName,
                  hint: widget.firstNameHint,
                  controller: _firstNameController,
                  enabled: !widget.isReadOnly,
                  textDirection: isArabic ?  TextDirection.rtl : TextDirection.ltr,
                  onChanged: (value) {
                    if (widget.firstNameOnChanged != null) {
                      widget.firstNameOnChanged!(value);
                    }
                  },
                ),
              ),
            ),

            // Middle Name
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: isArabic ? 0 : 12.w,
                  left: isArabic ? 12.w : 0,
                ),
                child: CustomTextField(
                  label: S.of(context).middleName,
                  hint: widget.middleNameHint,
                  controller: _middleNameController,
                  textDirection: isArabic ?  TextDirection.rtl : TextDirection.ltr,
                  enabled: !widget.isReadOnly,
                  onChanged: (value) {
                    if (widget.middleNameOnChanged != null) {
                      widget.middleNameOnChanged!(value);
                    }
                  },
                ),
              ),
            ),

            // Last Name
            Expanded(
              child: CustomTextField(
                label: S.of(context).lastName,
                hint: widget.lastNameHint,
                controller: _lastNameController,
                textDirection: isArabic ?  TextDirection.rtl : TextDirection.ltr,
                enabled: !widget.isReadOnly,
                onChanged: (value) {
                  if (widget.lastNameOnChanged != null) {
                    widget.lastNameOnChanged!(value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
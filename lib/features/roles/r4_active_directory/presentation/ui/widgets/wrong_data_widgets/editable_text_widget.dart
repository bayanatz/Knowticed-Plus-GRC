/// Module: roles / r4_active_directory / presentation / ui / widgets / wrong_data_widgets
///
///*************************** FILE INFO ****************************///
/// File Name: editable_text_widget.dart
/// Purpose: Declares `EditableTextWidget`, `Validation`, `CustomPopupMenuItem`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/screen_fraction_extension.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/ui/widgets/fields/default_csv_field.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_haptic.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/generated/l10n.dart';

//Youssef Ashraf
///Used in wrong data tab inside table, changes to field when editing.
class EditableTextWidget extends StatefulWidget {
  final String text;
  final bool isEditable;
  final String? Function(String?)? validator;
  final String? Function(String?)? titleValidator;
  final bool isOptional;
  final Function(String)? onChanged;
  const EditableTextWidget(
      {super.key,
      required this.text,
      required this.isEditable,
      required this.isOptional,
      required this.onChanged,
      this.validator,
      this.titleValidator});

  @override
  State<EditableTextWidget> createState() => _EditableTextWidgetState();
}

class _EditableTextWidgetState extends State<EditableTextWidget> {
  late TextEditingController _controller;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
    hasError = widget.validator!(_controller.text) != null;
  }

  @override
  void didUpdateWidget(covariant EditableTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Owner 21/10/2026: don't overwrite what the user is typing. The cell gets the
    // capitalised copy of the lower-cased value it just stored, so while editing only
    // sync when the source truly changed (e.g. a row restore or a re-upload).
    final bool sourceChanged = widget.text != oldWidget.text;
    final bool differsFromField = widget.text.trim().toLowerCase() !=
        _controller.text.trim().toLowerCase();
    if (!widget.isEditable
        ? _controller.text != widget.text
        : (sourceChanged && differsFromField)) {
      _controller.text = widget.text;
    }
    //when upload again to rebuild validation changes if exist
    hasError = widget.validator!(_controller.text) != null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Owner 21/10/2026: table values 12 regular (Attendance table).
    TextStyle tableDataTextStyle = StyleText.fontSize12Weight400.copyWith(
      color: widget.validator != null &&
              _controller.text.isNotEmpty &&
              widget.validator!(_controller.text) != null
          ? AppColors.red
          : Theme.of(context).colorScheme.inverseSurface,
      fontWeight: FontWeight.w500,
    );
    return widget.isEditable
        ? DefaultCsvField(
            readOnly: !widget.isEditable,
            onChanged: (value) {
              setState(() {
                hasError = widget.validator!(value) != null;
              });
              widget.onChanged!(value);
            },
            hasError: hasError,
            validator: widget.validator,
            titleValidator: widget.titleValidator,
            controller: _controller,
            contentPadding: EdgeInsetsDirectional.symmetric(horizontal: 2.w),
            maxLength: 50,
          )
        : Row(
            children: [
              Text(
                widget.text,
                style: tableDataTextStyle.copyWith(height: 1.3),
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
              if (hasError && !widget.isOptional ||
                  (hasError &&
                      widget.isOptional &&
                      _controller.text.isNotEmpty))
                InkWell(
                    onTapUp: (details) {
                      String? validationMessage =
                          widget.validator!(_controller.text);
                      String? title = widget.titleValidator!(_controller.text);

                      // Check if the text is empty
                      if (_controller.text.isEmpty) {
                        validationMessage =
                            S.of(context).theDataForThisFieldIsEmpty;
                      }

                      hapticController.triggerHapticFeedback(
                          vibration: VibrateType.lightImpact,
                          hapticFeedback: HapticFeedback.lightImpact);
                      final iconPosition = details.globalPosition;
                      _showSortMenu(context, iconPosition, validationMessage!,
                          title ?? '');
                    },
                    child: SizedBox(
                        width: 0.05.w,
                        child: CustomSvgImage.natural(
                          assetPath:
                              "assets/icons_assets/main_icons_assets/ic_warning_triangle_red.svg",
                          color: AppColors.red,
                          height: isVertical ? 0.02.h : 0.03.h,
                        ))),
            ],
          );
  }
}

enum Validation {
  // ignore: constant_identifier_names
  validation,
}

void _showSortMenu(BuildContext context, Offset iconPosition, String validation,
    String title) async {
  final List<Validation> sortOptions = [
    Validation.validation,
  ];
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;
  final double menuOffsetX = iconPosition.dx - (-9.0);
  final double menuOffsetY = iconPosition.dy - (-7.0);

  final RelativeRect position = RelativeRect.fromLTRB(
    menuOffsetX,
    menuOffsetY,
    overlay.size.width - menuOffsetX,
    overlay.size.height,
  );

  selectedOption = await showMenu(
    elevation: 0,
    shadowColor: AppColors.transparent,
    color: Theme.of(context).colorScheme.onPrimary,
    context: context,
    constraints: BoxConstraints(
      minHeight: 0.0.h,
    ),
    position: position,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: AppColors.primary,
        )),
    items: sortOptions.map((option) {
      return CustomPopupMenuItem<Validation>(
          color: Theme.of(context).colorScheme.onPrimary,
          value: option,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: StyleText.fontSize16Weight500,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\u2022 ${FormatHelper.capitalize(validation)}',
                    style: StyleText.fontSize14Weight400
                        .copyWith(color: AppColors.secondaryBlack),
                  ),
                ],
              ),
            ],
          ));
    }).toList(),
  );
}

Validation? selectedOption;

class CustomPopupMenuItem<T> extends PopupMenuItem<T> {
  final Color color;
  final bool first;
  final bool last;

  const CustomPopupMenuItem({
    super.key,
    required T super.value,
    super.enabled,
    required Widget super.child,
    required this.color,
    this.first = false,
    this.last = false,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomPopupMenuItemState<T> createState() => _CustomPopupMenuItemState<T>();
}

class _CustomPopupMenuItemState<T>
    extends PopupMenuItemState<T, CustomPopupMenuItem<T>> {
  late BorderRadius borderRadius;
  double radius = 10;
  @override
  Widget build(BuildContext context) {
    borderRadius = BorderRadius.zero;
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        padding: EdgeInsets.zero,
        color: widget.color,
        child: super.build(context),
      ),
    );
  }
}

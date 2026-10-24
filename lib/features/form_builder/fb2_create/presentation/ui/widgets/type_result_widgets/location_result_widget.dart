/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: location_result_widget.dart
/// Description: `LocationResultWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/location_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/location_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/location_drop_down.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';

class LocationResultWidget extends StatelessWidget {
  const LocationResultWidget({
    super.key,
    this.fieldController,
    this.reviewModel,
    this.isValidated = false,
    this.isReadOnly = false,
    this.isWhiteFill = false,
  });
  final LocationFieldController? fieldController;
  final LocationFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isReadOnly;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FIXED: this used to be `if (title.isNotEmpty) TextRequiredWidget(…)`,
          // and THAT is why the lat/long boxes sat ABOVE every other field in
          // the row. An untitled field dropped the title line entirely, while
          // every sibling in `type_result_widgets/` renders TextRequiredWidget
          // unconditionally — an empty RichText still occupies one 14sp line.
          // The column below it therefore started a whole line early. Rendering
          // it unconditionally puts location back on the shared baseline.
          //
          // Reading the title through `_getTitle()` also drops two `!` bangs on
          // `fieldController`, which threw on the review and submission screens:
          // those pass `reviewModel` and leave `fieldController` null.
          TextRequiredWidget(
            isRequired: _getIsRequired(),
            text: _getTitle(),
          ),
          verticalSpace(4),
          _buildLocationInput(),
        ],
      ),
    );
  }

  /// Build location input based on location type
  Widget _buildLocationInput() {
    final locationType = _getLocationType();

    switch (locationType) {
      case LocationDropDown.latitudeAndLongitude:
        return _buildLatLongInputRow();
      case LocationDropDown.link:
        return _buildLinkInput();
      case null:
        return const SizedBox.shrink();
    }
  }

  /// Build row for latitude and longitude inputs
  Widget _buildLatLongInputRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildLatitudeInput()),
        horizontalSpace(15),
        Expanded(child: _buildLongitudeInput()),
      ],
    );
  }

  /// The content padding every field on these screens shares.
  ///
  /// `TextFieldResultWidget` and `DropDownResultWidget` both use exactly this,
  /// so the text inside a latitude box now sits where the text in the field
  /// beside it sits. Latitude and longitude previously passed none at all and
  /// fell back to `CustomTextField`'s default.
  static final EdgeInsetsGeometry _fieldPadding =
      EdgeInsets.symmetric(vertical: 12.sp, horizontal: 10.sp);

  /// Build latitude input field
  Widget _buildLatitudeInput() {
    return CustomTextField(
      height: 36,
      readOnly: isReadOnly,
      contentPadding: _fieldPadding,
      hint: _getLatitudeHint(),
      // These boxes were not bound to the answer, so a
      // typed location was never saved and a saved one never shown.
      initialValue: reviewModel != null
          ? reviewModel!.latitudeLocationAnswer
          : fieldController?.answerLatitude,
      onChanged: (v) => fieldController?.answerLatitude = v,
      maxLines: 1,
      fillColor: isWhiteFill ? AppColors.white : AppColors.background,
      width: double.infinity,
    );
  }

  /// Build longitude input field
  Widget _buildLongitudeInput() {
    return CustomTextField(
      height: 36,
      readOnly: isReadOnly,
      contentPadding: _fieldPadding,
      hint: _getLongitudeHint(),
      // These boxes were not bound to the answer, so a
      // typed location was never saved and a saved one never shown.
      initialValue: reviewModel != null
          ? reviewModel!.longitudeLocationAnswer
          : fieldController?.answerLongitude,
      onChanged: (v) => fieldController?.answerLongitude = v,
      maxLines: 1,
      fillColor: isWhiteFill ? AppColors.white : AppColors.background,
      width: double.infinity,
    );
  }

  /// Build link input field
  Widget _buildLinkInput() {
    return CustomTextField(
      height: 36,
      maxLines: 1,
      readOnly: isReadOnly,
      // CHANGED: was `horizontal: 14.sp, vertical: 4.sp`, its own values.
      contentPadding: _fieldPadding,
      hint: _getLinkHint(),
      // These boxes were not bound to the answer, so a
      // typed location was never saved and a saved one never shown.
      initialValue: reviewModel != null
          ? reviewModel!.linkLocationAnswer
          : fieldController?.answerLink,
      onChanged: (v) => fieldController?.answerLink = v,
      prefixIcon: CustomSvgImage.natural(
        assetPath: AppAssets.locationIcon,
        width: 16,
        height: 16,
      ),
      fillColor: isWhiteFill ? AppColors.white : AppColors.background,
      width: double.infinity,
    );
  }

  String _getTitle() {
    if (reviewModel != null) {
      return reviewModel?.title ?? '';
    }
    return fieldController?.title?.text ?? '';
  }

  bool _getIsRequired() {
    bool flag = false;
    if (reviewModel != null) {
      flag = reviewModel?.isRequired ?? false;
      return flag;
    }
    flag = fieldController?.isRequired ?? false;
    return flag;
  }

  LocationDropDown? _getLocationType() {
    if (reviewModel != null) {
      return LocationDropDownExtension.fromName(reviewModel!.locationType);
    }
    return LocationDropDownExtension.fromName(fieldController!.locationType!);
  }

  String? _getLatitudeHint() {
    if (reviewModel != null) {
      return reviewModel!.hintLatitude;
    }
    return fieldController!.hintLatitude?.text;
  }

  String? _getLongitudeHint() {
    if (reviewModel != null) {
      return reviewModel!.hintLongitude;
    }
    return fieldController!.hintLongitude?.text;
  }

  String? _getLinkHint() {
    if (reviewModel != null) {
      return reviewModel!.hintLink;
    }
    return fieldController!.hintLink?.text;
  }
}

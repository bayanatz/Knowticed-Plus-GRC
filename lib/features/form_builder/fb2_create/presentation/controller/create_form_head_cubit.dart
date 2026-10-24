/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: create_form_head_cubit.dart
/// Description: `CreateFormHeadCubit`, the header of the form being created
///              or edited (titles, descriptions, access type, orientation,
///              paddings, cover and watermark). Holds plain values: the text
///              controllers, the Form key and the image picker live in the
///              widgets.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Controllers, GlobalKey and picker moved to the UI.
library;

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/helper/extensions.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_head_data.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/access_management.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/orientation.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/form_demo_data.dart';

/// The header of the form being created or edited.
class CreateFormHeadCubit extends Cubit<CreateFormHeadState> {
  CreateFormHeadCubit() : super(CreateFormHeadInitial());

  /// Every emit is skipped once the cubit is closed (Home rule 8).
  @override
  void emit(CreateFormHeadState state) {
    if (isClosed) return;
    super.emit(state);
  }

  CreateFormHeadLoaded? get _loaded =>
      state is CreateFormHeadLoaded ? state as CreateFormHeadLoaded : null;

  /// Method Name: [init]
  ///
  /// Purpose: opens the header for a new form, or with the values of
  /// [editFormModel].
  ///
  /// Parameters:
  /// - [editFormModel]: the form being edited, or null.
  void init({FormEntity? editFormModel}) {
    final FormHeadData? head = editFormModel?.formHeadModel;
    emit(
      CreateFormHeadLoaded(
        title: head?.title ?? '',
        description: head?.description ?? '',
        arTitle: head?.arTitle ?? '',
        arDescription: head?.arDescription ?? '',
        horizontalPadding: head == null
            ? ''
            : head.horizontalPadding.toString(),
        verticalPadding: head == null ? '' : head.verticalPadding.toString(),
        watermarkOpacity: head == null ? '' : head.watermarkOpacity.toString(),
        watermarkSize: head == null ? '' : head.watermarkSize.toString(),
        cover: head?.cover,
        watermark: head?.watermark,
        // Null for a new form, so the dropdowns show their hint.
        accessManagement: head?.accessManagement,
        orientation: head?.orientation,
        fieldsVersion: _nextFieldsVersion(),
      ),
    );
  }

  int _fieldsVersion = 0;

  int _nextFieldsVersion() => ++_fieldsVersion;

  /// Method Name: [updateTitle]
  ///
  /// Purpose: stores the English title typed in its field.
  void updateTitle(String value) {
    final CreateFormHeadLoaded? current = _loaded;
    if (current != null) emit(current.copyWith(title: value));
  }

  /// Method Name: [updateArTitle]
  ///
  /// Purpose: stores the Arabic title typed in its field.
  void updateArTitle(String value) {
    final CreateFormHeadLoaded? current = _loaded;
    if (current != null) emit(current.copyWith(arTitle: value));
  }

  /// Method Name: [updateDescription]
  ///
  /// Purpose: stores the English description typed in its field.
  void updateDescription(String value) {
    final CreateFormHeadLoaded? current = _loaded;
    if (current != null) emit(current.copyWith(description: value));
  }

  /// Method Name: [updateArDescription]
  ///
  /// Purpose: stores the Arabic description typed in its field.
  void updateArDescription(String value) {
    final CreateFormHeadLoaded? current = _loaded;
    if (current != null) emit(current.copyWith(arDescription: value));
  }

  /// Method Name: [updateHorizontalPadding]
  ///
  /// Purpose: stores the horizontal padding typed in its field.
  void updateHorizontalPadding(String value) {
    final CreateFormHeadLoaded? current = _loaded;
    if (current != null) emit(current.copyWith(horizontalPadding: value));
  }

  /// Method Name: [updateVerticalPadding]
  ///
  /// Purpose: stores the vertical padding typed in its field.
  void updateVerticalPadding(String value) {
    final CreateFormHeadLoaded? current = _loaded;
    if (current != null) emit(current.copyWith(verticalPadding: value));
  }

  /// Method Name: [updateOrientation]
  ///
  /// Purpose: stores the picked orientation.
  void updateOrientation(String orientation) {
    final CreateFormHeadLoaded? current = _loaded;
    if (current != null) emit(current.copyWith(orientation: orientation));
  }

  /// Method Name: [updateAccessManagement]
  ///
  /// Purpose: stores the picked access type (the access dialog is shown
  /// when Publish is tapped).
  void updateAccessManagement(String accessManagement) {
    final CreateFormHeadLoaded? current = _loaded;
    if (current != null) {
      emit(current.copyWith(accessManagement: accessManagement));
    }
  }

  /// Method Name: [updateWatermarkOpacity]
  ///
  /// Purpose: stores the watermark opacity picked on the slider.
  void updateWatermarkOpacity(String opacity) {
    final CreateFormHeadLoaded? current = _loaded;
    if (current != null) emit(current.copyWith(watermarkOpacity: opacity));
  }

  /// Method Name: [updateWatermarkSize]
  ///
  /// Purpose: stores the watermark size picked on the slider.
  void updateWatermarkSize(String size) {
    final CreateFormHeadLoaded? current = _loaded;
    if (current != null) emit(current.copyWith(watermarkSize: size));
  }

  /// Method Name: [setCoverImage]
  ///
  /// Purpose: stores a cover image the widget already picked and checked.
  ///
  /// Parameters:
  /// - [file]: the picked image.
  void setCoverImage(File file) {
    final CreateFormHeadLoaded? current = _loaded;
    if (current != null) emit(current.copyWith(cover: file.path));
  }

  /// Method Name: [setWatermarkImage]
  ///
  /// Purpose: stores a watermark image the widget already picked.
  ///
  /// Parameters:
  /// - [file]: the picked image.
  void setWatermarkImage(File file) {
    final CreateFormHeadLoaded? current = _loaded;
    if (current != null) emit(current.copyWith(watermark: file.path));
  }

  /// Method Name: [removeCoverImage]
  ///
  /// Purpose: clears the cover image.
  void removeCoverImage() {
    final CreateFormHeadLoaded? current = _loaded;
    if (current != null) emit(current.copyWith(clearCover: true));
  }

  /// Method Name: [removeWatermarkImage]
  ///
  /// Purpose: clears the watermark image.
  void removeWatermarkImage() {
    final CreateFormHeadLoaded? current = _loaded;
    if (current != null) emit(current.copyWith(clearWatermark: true));
  }

  /// Method Name: [fillDemoData]
  ///
  /// Purpose: "Fill demo data" button: sample values in every header field
  /// (EN + AR title / description, paddings, watermark settings), Open
  /// Access and Portrait. Images stay empty.
  void fillDemoData() {
    final CreateFormHeadLoaded? current = _loaded;
    if (current == null) return;
    emit(
      current
          .copyWith(
            title: FormDemoData.title(),
            arTitle: FormDemoData.arTitle(),
            description: FormDemoData.description,
            arDescription: FormDemoData.arDescription,
            horizontalPadding: FormDemoData.horizontalPadding,
            verticalPadding: FormDemoData.verticalPadding,
            watermarkOpacity: FormDemoData.watermarkOpacity,
            watermarkSize: FormDemoData.watermarkSize,
            accessManagement: AccessManagement.openAccess.name,
            orientation: OrientationEnum.portrait.name,
          )
          .copyWithFieldsVersion(_nextFieldsVersion()),
    );
  }

  /// Method Name: [createFormHeadModel]
  ///
  /// Purpose: the header as saved on the form. Arabic digits are read as
  /// numbers; empty numbers fall back to the defaults.
  ///
  /// Returns: the header; throws when the header is not loaded.
  FormHeadData createFormHeadModel() {
    final CreateFormHeadLoaded? current = _loaded;
    if (current == null) {
      throw StateError('Cannot create form head model - state not loaded');
    }
    return FormHeadData(
      title: current.title,
      description: current.description,
      arTitle: current.arTitle,
      arDescription: current.arDescription,
      cover: current.cover,
      watermark: current.watermark,
      // These two defaults are STABLE stored values, not display text — see
      // the note on AccessManagementExtension.name.
      accessManagement:
          current.accessManagement ?? AccessManagement.openAccess.name,
      orientation: current.orientation ?? OrientationEnum.portrait.name,
      horizontalPadding:
          double.tryParse(current.horizontalPadding.toEnglishDigits()) ?? 16.0,
      verticalPadding:
          double.tryParse(current.verticalPadding.toEnglishDigits()) ?? 16.0,
      watermarkOpacity:
          int.tryParse(current.watermarkOpacity.toEnglishDigits()) ?? 50,
      watermarkSize:
          int.tryParse(current.watermarkSize.toEnglishDigits()) ?? 100,
    );
  }

  /// Method Name: [resetController]
  ///
  /// Purpose: clears the header before a new editor screen opens.
  void resetController() => emit(CreateFormHeadInitial());
}

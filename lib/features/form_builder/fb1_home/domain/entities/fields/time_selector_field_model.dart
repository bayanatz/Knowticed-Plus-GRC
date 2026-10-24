/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: time_selector_field_model.dart
/// Description: `TimeSelectorFieldModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';

/// Represents the model for a time selector field
class TimeSelectorFieldModel extends FieldModel {
  String? time, amOrPm;

  /// Title of the time selector field
  String? title;

  @override
  String? get fieldTitle => title;

  /// Flag to determine if the field is required
  bool? isRequired;

  /// Constructor for initializing the TimeSelectorFieldModel instance
  TimeSelectorFieldModel({
    this.time,
    this.amOrPm,
    this.isRequired,
    this.title,
  }) : super(FormFieldType.timeSelector);

  /// Method to duplicate the time selector field model
  /// Returns a new instance of TimeSelectorFieldModel with the same properties
  @override
  duplicate() {
    TimeSelectorFieldModel newModel = TimeSelectorFieldModel(
      amOrPm: amOrPm,
      time: time,
      isRequired: isRequired,
      title: title,
    );
    return newModel;
  }
}

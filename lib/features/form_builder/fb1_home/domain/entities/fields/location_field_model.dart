/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: location_field_model.dart
/// Description: `LocationFieldModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';

/// Represents the model for a location field
class LocationFieldModel extends FieldModel {
  /// Hint text for latitude
  String? hintLatitude;

  /// Hint text for longitude
  String? hintLongitude;

  /// Hint text for link
  String? hintLink;

  /// Type of the location (e.g., latitude and longitude)
  String locationType;

  /// Alignment of the location field
  String alignment;

  /// Flag to determine if the field is required
  bool isRequired;
  String title;

  @override
  String? get fieldTitle => title;

  /// Link of the answer
  String? linkLocationAnswer;

  /// Latitude of the answer
  String? latitudeLocationAnswer;

  /// Longitude of the answer
  String? longitudeLocationAnswer;

  /// Constructor for initializing the LocationFieldModel instance
  LocationFieldModel({
    required this.alignment,
    required this.isRequired,
    this.hintLink,
    required this.locationType,
    this.hintLongitude,
    this.hintLatitude,
    this.linkLocationAnswer,
    this.latitudeLocationAnswer,
    this.longitudeLocationAnswer,
    required this.title,
  }) : super(FormFieldType.location);

  /// Method to duplicate the location field model
  /// Returns a new instance of LocationFieldModel with the same properties
  @override
  duplicate() {
    LocationFieldModel newModel = LocationFieldModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hintLink: hintLink,
      locationType: locationType,
      hintLongitude: hintLongitude,
      hintLatitude: hintLatitude,
    );
    return newModel;
  }
}

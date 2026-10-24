/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: image_field_model.dart
/// Description: `ImageFieldModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';

/// Represents the model for an image field
class ImageFieldModel extends FieldModel {
  /// Title of the image field
  String title;

  @override
  String? get fieldTitle => title;

  /// Limitation or maximum size of the image
  String limitation;

  /// Flag to determine if the field is required
  bool isRequired;

  /// List of image links
  List<String?>? images;

  /// Constructor for initializing the ImageFieldModel instance
  ImageFieldModel({
    required this.isRequired,
    required this.title,
    required this.limitation,
    required this.images,
  }) : super(FormFieldType.image);

  /// Method to duplicate the image field model
  /// Returns a new instance of ImageFieldModel with the same properties
  @override
  duplicate() {
    ImageFieldModel newModel = ImageFieldModel(
      isRequired: isRequired,
      title: title,
      limitation: limitation,
      images: List<String>.from(images!),
    );
    return newModel;
  }
}

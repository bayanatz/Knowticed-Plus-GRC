/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: image_field_controller.dart
/// Description: `ImageFieldController` controller.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'dart:io';

import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/image_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';

import 'package:knowticed_plus/core/helper/extensions.dart'
    hide ContextExtension;
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_text.dart';

class ImageFieldController extends FieldController {
  // Text controllers for the title and limitation of the image field.
  FieldText? title, limitation;
  // Indicates whether this image field is required or not.
  bool? isRequired;
  // List to store image files.
  List<File?> images = [];
  List<String?> imagesLink = [];

  /// Constructor that initializes the controller with image field type.
  ImageFieldController() : super(FormFieldType.image) {
    init();
  }

  @override
  /// Initializes the image field controllers.
  init() {
    title = FieldText();
    limitation = FieldText(text: FormDateTimeHelper.formatInt(1));
    images = [null];
    isRequired = false;
    return super.init();
  }

  /// Inserts a list of image slots based on the limitation value.
  void insertImagesList(String value) {
    int limate = value.toEnglishNumber();
    images = [];
    imagesLink = [];
    for (int i = 0; i < limate; i++) {
      images.add(null);
      imagesLink.add(null);
    }
  }

  @override
  /// Disposes the image field controllers.
  dispose() {
    title!.dispose();
    limitation!.dispose();
    return super.dispose();
  }

  @override
  /// Prints the model data of the image field.
  printModel() {
    return super.printModel();
  }

  @override
  /// Creates a duplicate of the current image field controller.
  duplicate() {
    var newController = ImageFieldController();
    // Duplicate the title
    newController.title?.text = title?.text ?? '';
    // Duplicate the isRequired flag
    newController.isRequired = isRequired;
    // Duplicate the limitation
    newController.limitation?.text = limitation?.text ?? '';
    // Duplicate the list of images
    newController.images = images;
    newController.imagesLink = imagesLink;
    return newController;
  }

  @override
  /// Converts the image field controller to a model.
  ImageFieldModel toModel({bool isSetAnswer = false}) {
    return ImageFieldModel(
      title: title?.text ?? '',
      limitation: limitation?.text ?? '',
      isRequired: isRequired!,
      images: imagesLink,
    );
  }

  @override
  bool valid() {
    if (isRequired! && images.contains(null)) {
      return false;
    }
    return super.valid();
  }
}

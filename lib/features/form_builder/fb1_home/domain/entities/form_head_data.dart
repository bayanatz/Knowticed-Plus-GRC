/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: form_head_data.dart
/// Description: Represents the head data for form creation.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

class FormHeadData {
  /// Function Name: [titleFor]
  ///
  /// Purpose: The one place that picks the title to show: the Arabic title
  /// in an Arabic UI when the form has one, otherwise the English title.
  ///
  /// Parameters:
  /// - [arabic]: whether the app is showing Arabic.
  String titleFor({required bool arabic}) =>
      arabic && (arTitle?.isNotEmpty ?? false) ? arTitle! : title;

  /// Same rule as [titleFor], for the description.
  String descriptionFor({required bool arabic}) =>
      arabic && (arDescription?.isNotEmpty ?? false)
          ? arDescription!
          : description;

  /// The title of the form
  String title;

  /// The Arabic title of the form
  String? arTitle;

  /// The description of the form
  String description;

  /// The Arabic description of the form
  String? arDescription;

  /// The access management configuration for the form
  String accessManagement;

  /// The orientation of the form (e.g., portrait, landscape)
  String orientation;

  /// The horizontal padding of the form
  double? horizontalPadding;

  /// The vertical padding of the form
  double? verticalPadding;

  ///The cover URL or path for the form
  String? cover;

  /// The watermark URL or path for the form
  String? watermark;

  /// The opacity of the watermark
  int? watermarkOpacity;

  /// The size of the watermark
  int? watermarkSize;

  /// Constructor for initializing the FromHeadData instance
  FormHeadData({
    required this.title,
    this.arTitle,
    required this.description,
    this.arDescription,
    required this.accessManagement,
    required this.orientation,
    this.horizontalPadding,
    this.verticalPadding,
    this.watermarkSize,
    this.watermarkOpacity,
    this.watermark,
    this.cover,
  });

  FormHeadData duplicate() {
    FormHeadData newFormHeadDate = FormHeadData(
        title: title,
        description: description,
        accessManagement: accessManagement,
        orientation: orientation,
        verticalPadding: verticalPadding,
        horizontalPadding: verticalPadding,
        cover: cover,
        arTitle: arTitle,
        arDescription: arDescription,
        watermark: watermark,
        watermarkOpacity: watermarkSize,
        watermarkSize: watermarkOpacity);
    return newFormHeadDate;
  }
}

/// Module: services / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: parent_service_details.dart
/// Purpose: The current name, description, duration and image of the service
///          a request was made for. Requests are saved without these, so
///          every screen that shows a request reads them from the service.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

/// The current details of the service behind a request.
class ParentServiceDetails {
  const ParentServiceDetails({
    this.nameEnglish = '',
    this.nameArabic = '',
    this.descriptionEnglish = '',
    this.descriptionArabic = '',
    this.duration = '',
    this.unit = '',
    this.imageUrl = '',
  });

  /// Nothing found: the service was deleted or the id was empty.
  static const ParentServiceDetails empty = ParentServiceDetails();

  final String nameEnglish;
  final String nameArabic;
  final String descriptionEnglish;
  final String descriptionArabic;

  /// Number of [unit]s the service takes, as stored (e.g. "3").
  final String duration;

  /// Duration unit as stored (e.g. "days").
  final String unit;
  final String imageUrl;

  /// Whether the service was found.
  bool get exists => nameEnglish.isNotEmpty || nameArabic.isNotEmpty;
}

/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: location_drop_down.dart
/// Description: `LocationDropDown` enum, extension methods of `LocationDropDown`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/generated/l10n.dart';

enum LocationDropDown { latitudeAndLongitude, link }

/// Extension to provide additional functionalities to the LocationDropDown enum.
extension LocationDropDownExtension on LocationDropDown {
  /// STABLE identifier — persisted on the field and parsed back by [fromName].
  /// NOT translated; see [label].
  String get name {
    switch (this) {
      case LocationDropDown.latitudeAndLongitude:
        return 'Latitude And Longitude';
      case LocationDropDown.link:
        return 'Link';
    }
  }

  /// Translated label — what the user actually reads.
  String get label {
    final s = S.current;
    switch (this) {
      case LocationDropDown.latitudeAndLongitude:
        return s.latitudeAndLongitude;
      case LocationDropDown.link:
        return s.fieldTypeLink;
    }
  }

  /// Resolves a stored [name] back to its translated [label].
  static String labelFor(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final normalized = value.trim().toLowerCase();
    for (final element in LocationDropDown.values) {
      if (element.name.toLowerCase() == normalized) return element.label;
    }
    return value;
  }

  /// Returns an enum item based on its name.
  static LocationDropDown? fromName(String name) {
    return LocationDropDown.values.firstWhere(
      (element) => element.name == name,
      orElse: () => LocationDropDown.latitudeAndLongitude,
    );
  }
}

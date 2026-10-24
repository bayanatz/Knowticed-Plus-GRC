/// Module: home/h1_home_page
///
/// *********************** FILE INFO *****************************
/// File Name: home_component_model.dart
/// Purpose: Entity for hold component information to be used in the home screen
/// Author: Amr Mesbah
/// Created at: 21/9/2025
/// Updated: 11/8/2026 - Fields made final, explicit toMap() type, copyWith.
/// Updated: 21/10/2026 - D-242: [settings] — the values the user chose in the
///          widget's gear dialog, saved with the placed copy (row / column).
library;

import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_widget_settings.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/home_components.dart';

class HomeComponentModel {
  const HomeComponentModel({
    required this.component,
    required this.rowNumber,
    required this.columnNumber,
    this.settings = const <String, dynamic>{},
  });

  final HomeComponents component;
  final int rowNumber;
  final int columnNumber;

  /// What the user changed in this copy's settings dialog. Empty = the widget
  /// behaves exactly as it did before settings existed (D-242 (4)).
  final Map<String, dynamic> settings;

  static const String componentKey = 'Component';
  static const String rowNumberKey = 'Row_Number';
  static const String columnNumberKey = 'Column_Number';
  static const String settingsKey = 'Settings';

  /// The typed reader the widgets use.
  HomeWidgetSettings get widgetSettings => HomeWidgetSettings(settings);

  /// Function Name: [toMap]
  ///
  /// Purpose: Serialise this component for Firestore.
  ///
  /// Returns: [Map<String, dynamic>] the Firestore representation.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      componentKey: component.databaseName,
      rowNumberKey: rowNumber,
      columnNumberKey: columnNumber,
      // Written only when something was changed, so layouts of widgets nobody
      // touched stay byte-for-byte what they were.
      if (settings.isNotEmpty) settingsKey: settings,
    };
  }

  /// Function Name: [copyWith]
  ///
  /// Purpose: Return a copy with selected fields replaced. Needed now that the
  ///          fields are final — drag-reorder rebuilds components rather than
  ///          mutating them.
  HomeComponentModel copyWith({
    HomeComponents? component,
    int? rowNumber,
    int? columnNumber,
    Map<String, dynamic>? settings,
  }) {
    return HomeComponentModel(
      component: component ?? this.component,
      rowNumber: rowNumber ?? this.rowNumber,
      columnNumber: columnNumber ?? this.columnNumber,
      settings: settings ?? this.settings,
    );
  }

  factory HomeComponentModel.fromMap(Map<String, dynamic> map) {
    final Object? stored = map[settingsKey];
    return HomeComponentModel(
      // orElse: stored layouts may name components this build removed.
      component: HomeComponents.values.firstWhere(
        (e) => e.databaseName == map[componentKey],
        orElse: () => HomeComponents.unknown,
      ),
      rowNumber: map[rowNumberKey] as int,
      columnNumber: map[columnNumberKey] as int,
      settings: stored is Map
          ? Map<String, dynamic>.from(stored)
          : const <String, dynamic>{},
    );
  }
}

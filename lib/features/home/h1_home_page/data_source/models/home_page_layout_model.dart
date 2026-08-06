/// ********************* FILE INFO ****************************
/// File Name: home_page_layout_model.dart
/// Purpose: Entity for home page layout containing active and draft components
/// Author: Amr Mesbah
/// Created at: 21/9/2025

import 'package:grc_module/features/home/h1_home_page/domain/enum/app_bar_enum.dart';
import 'package:grc_module/features/home/h1_home_page/domain/enum/home_components.dart';

import 'package:grc_module/features/home/h1_home_page/data_source/models/home_component_model.dart';

class HomePageLayoutModel {
  final String id;
  List<HomeComponentModel> activeComponents;
  List<AppBarOptions> activeAppBarOptions;
  List<String> headerIcons; // NEW: Store header icon paths

  HomePageLayoutModel({
    required this.id,
    required this.activeComponents,
    required this.activeAppBarOptions,
    this.headerIcons = const [], // NEW: Default empty list
  });

  static String idKey = 'Id';
  static String activeComponentsKey = 'Active_Components';
  static String activeAppBarOptionsKey = 'Active_AppBar_Options';
  static String headerIconsKey = 'Header_Icons'; // NEW

  toMap() {
    return {
      idKey: id,
      activeComponentsKey:
      activeComponents.map((component) => component.toMap()).toList(),
      activeAppBarOptionsKey:
      activeAppBarOptions.map((e) => e.databaseName).toList(),
      headerIconsKey: headerIcons, // NEW: Save header icons
    };
  }

  factory HomePageLayoutModel.fromMap(Map<String, dynamic> map) {
    return HomePageLayoutModel(
      id: map[idKey],
      activeComponents:
      List<Map<String, dynamic>>.from(map[activeComponentsKey])
          .map((componentMap) => getComponentModel(componentMap))
          .toList(),
      activeAppBarOptions: List<String>.from(map[activeAppBarOptionsKey])
          .map((e) => AppBarOptions.values
          .firstWhere((option) => option.databaseName == e))
          .toList(),
      headerIcons: map[headerIconsKey] != null
          ? List<String>.from(map[headerIconsKey])
          : [], // NEW: Load header icons
    );
  }

  static HomeComponentModel getComponentModel(
      Map<String, dynamic> componentMap) {
    print(componentMap);
    // Every remaining component deserialises to the base model, so this just
    // delegates. HomeComponentModel.fromMap resolves the component enum with an
    // `orElse` fallback — required because layouts are persisted per user, so a
    // stored document may still name a component this build removed (the
    // messaging Direct_Message / Group_Message cards). Without the fallback
    // firstWhere throws StateError and the whole home page fails to load.
    return HomeComponentModel.fromMap(componentMap);
  }
}
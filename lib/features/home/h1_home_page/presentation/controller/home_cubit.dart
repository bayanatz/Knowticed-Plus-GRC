
///*************************** FILE INFO ****************************///
/// File Name: home_cubit.dart
/// Purpose: Manages the state of the home screen, including components and quotes
/// Author: Amr Mesbah
/// Created at: 20/9/2025
/// Updated: 25/1/2026 - Fixed controller initialization for resize handling

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/features/home/h1_home_page/domain/enum/home_components.dart';

import 'package:grc_module/core/constants/quotes_list.dart';
import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:grc_module/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/home/h1_home_page/data_source/models/home_component_model.dart';
import 'package:grc_module/features/home/h1_home_page/data_source/repository/home_repository.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/icon_selector_dialog_widget.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/controller/home_state.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
enum PreviewMode { desktop, tablet, mobile }

class AppHomeCubit extends Cubit<HomeState> {
  HomeRepository homeRepository = HomeRepository();

  AppHomeCubit() : super(HomeInitial()) {
    getHomeQuote();
    initModules();
    getHomeLayout();
  }

  List<Modules> modules = [];
  String quote = "";
  String author = "";
  List<HomeComponentModel> _editingComponent = [];
  List<HomeComponentModel> _readyToAddComponent = [];
  List<HomeComponentModel> get readyToAddComponent => _readyToAddComponent;
  List<HomeComponentModel> _activeComponents = [];

  // Header icons management
  List<HeaderIconItem> selectedHeaderIcons = [];

  /// Function Name: [addHeaderIcon]
  ///
  /// Purpose: Add a new icon to the header (max 3 icons)
  ///
  /// Parameters:
  /// - [icon]: The HeaderIconItem to be added
  void addHeaderIcon(HeaderIconItem icon) {
    if (selectedHeaderIcons.length < 3) {
      selectedHeaderIcons.add(icon);
      emit(HomeIconsUpdated(List.from(selectedHeaderIcons)));
    }
  }
  PreviewMode currentPreviewMode = PreviewMode.tablet; // Default to tablet

  /// Function Name: [setPreviewMode]
  ///
  /// Purpose: Change the preview mode for home layout preview
  ///
  /// Parameters:
  /// - [mode]: The PreviewMode to switch to
  void setPreviewMode(PreviewMode mode) {
    currentPreviewMode = mode;
    emit(HomePreviewModeChanged(mode));
  }

  /// Function Name: [removeHeaderIcon]
  ///
  /// Purpose: Remove an icon from the header by index
  ///
  /// Parameters:
  /// - [index]: The index of the icon to be removed
  void removeHeaderIcon(int index) {
    if (index >= 0 && index < selectedHeaderIcons.length) {
      selectedHeaderIcons.removeAt(index);
      emit(HomeIconsUpdated(List.from(selectedHeaderIcons)));
    }
  }

  /// Function Name: [getActiveRowComponents]
  ///
  /// Purpose: Get the list of active components in a specific row
  ///
  /// Parameters:
  /// - [rowIndex]: The index of the row to get components for (based 0)
  ///
  /// Returns: [List<HomeComponentModel>]: A list of active components in the specified row
  List<HomeComponentModel> getActiveRowComponents(int rowIndex) {
    List<HomeComponentModel> components = _activeComponents
        .where((component) => component.rowNumber == rowIndex + 1)
        .toList();
    components.sort((a, b) => a.columnNumber.compareTo(b.columnNumber));
    return components;
  }

  /// Function Name: [getEditRowComponents]
  ///
  /// Purpose: Get the list of components being edited in a specific row
  ///
  /// Parameters:
  /// - [rowIndex]: The index of the row to get components for (based 0)
  List<HomeComponentModel> getEditRowComponents(int rowIndex) {
    List<HomeComponentModel> components = _editingComponent
        .where((component) => component.rowNumber == rowIndex + 1)
        .toList();
    components.sort((a, b) => a.columnNumber.compareTo(b.columnNumber));
    return components;
  }

  /// Function Name: [selectComponentToEdit]
  ///
  /// Purpose: Select a component to edit based on its row and column index based 1
  ///
  /// Parameters:
  /// - [rowIndex]: The row index of the component
  /// - [columnIndex]: The column index of the component
  selectComponentToEdit({required int rowIndex, required int columnIndex}) {
    List<HomeComponents> components = HomeComponents.values;
    _readyToAddComponent = [];
    for (var component in components) {
      HomeComponentModel model =
      component.getModel(rowNumber: rowIndex, columnNumber: columnIndex);
      if (component.widget(model) != null) _readyToAddComponent.add(model);
    }
  }

  /// Function Name: [editComponent]
  ///
  /// Purpose: Edit a component in the editing list
  ///
  /// Parameters:
  /// - [HomeComponentModel][component]: The component to be edited
  editComponent(HomeComponentModel component) {
    _editingComponent.removeWhere((c) =>
    c.rowNumber == component.rowNumber &&
        c.columnNumber == component.columnNumber);
    _editingComponent.add(component);

    emit(HomeEditingComponent());
  }

  /// Method Name: [getQuoteForToday]
  ///
  /// Purpose: This method is used to get the quote for the current date.
  getHomeQuote() {
    String quoteAndAuthor = Get.locale.toString().contains('en')
        ? FormatHelper.capitalize(getQuoteForToday())
        : getQuoteForToday();
    List<String> splitQuote = quoteAndAuthor.split(' - ');
    quote = splitQuote[0];
    author = splitQuote.length > 1 ? splitQuote[1] : "Unknown";
  }

  /// Function Name: [initModules]
  ///
  /// Purpose: Initialize modules from available controllers
  /// Fixed: Properly handles missing controllers during resize/orientation changes
  initModules() {
    try {
      if (Get.isRegistered<AppDrawerCubit>()) {
        modules = Get.find<AppDrawerCubit>().allowedDrawerModules;
        print('✅ Loaded modules from AppDrawerCubit');
      } else if (Get.isRegistered<NavBarCubit>()) {
        modules = Get.find<NavBarCubit>().navBarModules;
        print('✅ Loaded modules from NavBarCubit');
      } else {
        modules = [];
        print('⚠️ Warning: Neither controller registered');
      }
    } catch (e) {
      print('❌ Error in initModules: $e');
      modules = [];
    }
  }

  /// Function Name: [getEditedComponent]
  ///
  /// Purpose: Get the component being edited based on its row and column index
  ///
  /// Parameters:
  /// - [columnIndex]: The column index of the component
  /// - [rowIndex]: The row index of the component
  HomeComponentModel? getEditedComponent(
      {required int columnIndex, required int rowIndex}) {
    HomeComponentModel? component;
    for (var model in _editingComponent) {
      if (model.columnNumber == columnIndex && model.rowNumber == rowIndex) {
        component = model;
        break;
      }
    }
    print(
        'Found component: ${component != null ? component.component.name : 'None'}');
    return component;
  }

  /// Function Name: [removeComponent]
  ///
  /// Purpose: Remove a component from the editing list
  ///
  /// Parameters:
  /// - [component]: The component to be removed
  removeComponent(HomeComponentModel component) {
    _editingComponent.removeWhere((c) =>
    c.rowNumber == component.rowNumber &&
        c.columnNumber == component.columnNumber);
    emit(HomeEditingComponent());
  }

  /// Function Name: [updateHomeComponents]
  ///
  /// Purpose: Save the edited components and header icons to Firebase
  updateHomeComponents() async {
    // Convert HeaderIconItem to svg paths for storage
    List<String> headerIconPaths = selectedHeaderIcons
        .map((icon) => icon.svgPath)
        .toList();

    Either<Failure, dynamic> result = await homeRepository.updateHomeComponents(
        components: _editingComponent,
        appBarOptions: [],
        headerIcons: headerIconPaths,
        currentUserEmail:
        Get.find<MainCoreEmployeeController>().employeeEntity!.email!);

    if (result.isRight()) {
      // Update active components immediately
      _activeComponents = List<HomeComponentModel>.from(_editingComponent);
      emit(HomeLoaded());
      // Refresh from server to ensure sync
      getHomeLayout();
    } else {
      // Handle error - extract error message properly
      String errorMessage = result.fold(
            (failure) {
          // Handle different failure types
          if (failure is FirebaseFailure) {
            return "Firebase error occurred";
          } else {
            return "An error occurred";
          }
        },
            (_) => "Unknown error",
      );
      emit(HomeError(errorMessage));
      print('Error updating home components: $errorMessage');
    }
  }

  /// Function Name: [getHomeLayout]
  ///
  ///  Purpose: Fetches the home layout from the repository and updates the state accordingly.
  Future<void> getHomeLayout() async {
    emit(HomeLoading());

    // ✅ FIX: employeeEntity can be null while login init is still running.
    // The old `employeeEntity!.email!` crashed with "Null check operator
    // used on a null value" during the first build and corrupted the
    // widget tree (duplicate GlobalKey cascade).
    final String? userEmail =
        Get.find<MainCoreEmployeeController>().employeeEntity?.email;
    if (userEmail == null || userEmail.isEmpty) {
      print('⚠️ getHomeLayout: user email not ready yet, skipping layout fetch');
      emit(HomeLoaded());
      return;
    }

    Either<Failure, dynamic> result = await homeRepository.getHomeLayout(
      currentUserEmail: userEmail,
    );
    if (result.isRight()) {
      var layoutModel = result.getOrElse(() => null);
      if (layoutModel != null) {
        _activeComponents = layoutModel.activeComponents ?? [];
        _editingComponent = List<HomeComponentModel>.from(_activeComponents);

        // Load header icons from Firebase
        if (layoutModel.headerIcons != null && layoutModel.headerIcons.isNotEmpty) {
          selectedHeaderIcons = layoutModel.headerIcons
              .map<HeaderIconItem?>((svgPath) => HeaderIconItem.fromSvgPath(svgPath))
              .where((item) => item != null)
              .cast<HeaderIconItem>()
              .toList();
        } else {
          selectedHeaderIcons = [];
        }
      }
    }
    emit(HomeLoaded());
  }
}
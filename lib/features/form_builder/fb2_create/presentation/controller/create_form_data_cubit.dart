/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: create_form_data_cubit.dart
/// Description: `CreateFormDataCubit` cubit (state management).
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'dart:developer' as developer;

import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/access_management.dart';

import 'dart:async'; // Timer — debounces the live-preview re-emit.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_head_data.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/open_access_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/restricted_access_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/check_box_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/drop_down_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/radio_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/department_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/page_controller_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/row_controller_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';

import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit_base.dart';
import 'package:knowticed_plus/core/helper/extensions.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/mappers/person_entity_factory.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_text.dart';

class CreateFormDataCubit extends CreateFormDataCubitBase {
  CreateFormDataCubit({
    required super.mainCoreEmployeeController,
    required super.addDepartmentController,
    required super.createFormHeadCubit,
  });

  // ── Live preview ──────────────────────────────────────────────────────────
  //
  // "changes to Add Title / Limitation must show immediately,
  // not after a delay or a refresh".
  //
  // Every field's editable text is a FieldText living inside the
  // FieldController in `state.pages`. Typing mutates it IN PLACE, so
  // after a keystroke `pages` still holds the same objects, Equatable sees an
  // identical state, nothing is emitted, and the preview — which reads `.text`
  // at build time — never rebuilds. It only caught up when an unrelated action
  // (add a row, toggle Required) emitted for its own reasons. Hence the delay.
  //
  // The cubit now watches those controllers and re-emits itself. Doing it here
  // rather than in a widget means it holds for all 18 field types, including
  // the ones whose widgets live under `type_field_widgets/`.

  /// Controllers currently subscribed to, so they can be unsubscribed when the
  /// form's shape changes.
  final Set<FieldText> _previewWatched = {};

  /// Coalesces a burst of keystrokes into a single emit.
  ///
  /// 80ms is below the ~100ms mark where a UI stops feeling instant, so this
  /// still reads as immediate — but it is not cosmetic. A controller notifies
  /// listeners synchronously, which can land mid-build; emitting straight from
  /// the callback would risk "setState() called during build". Hopping to a
  /// timer moves the emit to a safe point and collapses one emit per character
  /// into one per pause.
  Timer? _previewDebounce;

  void _onWatchedTextChanged() {
    _previewDebounce?.cancel();
    _previewDebounce = Timer(const Duration(milliseconds: 80), () {
      if (isClosed) return;
      final current = state;
      if (current is CreateFormDataLoaded) {
        // copyWith() with no arguments still bumps `version`, which is the only
        // thing in props that can differ here — every other field is the same
        // instance it already was.
        emit(current.copyWith());
      }
    });
  }

  /// Re-points the subscription set at whatever controllers the state now has.
  ///
  /// Driven from [onChange], so it runs after EVERY emit and no mutating method
  /// has to remember to call it.
  void _syncPreviewListeners(CreateFormDataState next) {
    final wanted = <FieldText>{};

    if (next is CreateFormDataLoaded) {
      for (final page in next.pages) {
        for (final row in page.rows) {
          final columns = row.numOfColumn;
          if (columns != null) wanted.add(columns);
          for (final field in row.controllers) {
            wanted.addAll(field.textControllers);
          }
        }
      }
    }

    for (final controller in _previewWatched.difference(wanted)) {
      // Safe on a FieldText that a deleted row already disposed:
      // ChangeNotifier.removeListener does not throw after dispose.
      controller.removeListener(_onWatchedTextChanged);
    }

    for (final controller in wanted.difference(_previewWatched)) {
      controller.addListener(_onWatchedTextChanged);
    }

    _previewWatched
      ..clear()
      ..addAll(wanted);
  }

  @override
  void onChange(Change<CreateFormDataState> change) {
    super.onChange(change);
    _syncPreviewListeners(change.nextState);
  }

  /// Method Name: [changeDropDownResultValue]
  ///
  /// Purpose: stores the option picked in a dropdown field of the preview.
  ///
  /// Parameters:
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  /// - [columnIndex]: the field in the row.
  /// - [value]: the picked option.
  void changeDropDownResultValue({
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
    String? value,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final controller = pages[pageIndex].rows[rowIndex].controllers[columnIndex];

    if (controller is DropDownFieldController) {
      controller.currentValue = value!;
    }

    emit(currentState.copyWith(pages: pages));
  }

  /// Method Name: [changeRadioResultValue]
  ///
  /// Purpose: stores the option picked in a radio field of the preview.
  ///
  /// Parameters:
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  /// - [columnIndex]: the field in the row.
  /// - [value]: the picked option.
  void changeRadioResultValue({
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
    String? value,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final controller = pages[pageIndex].rows[rowIndex].controllers[columnIndex];

    if (controller is RadioFieldController) {
      controller.selectedRadio = value!;
    }

    emit(currentState.copyWith(pages: pages));
  }

  /// Method Name: [duplicateColumn]
  ///
  /// Purpose: copies a field next to itself in its row.
  ///
  /// Parameters:
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  /// - [columnIndex]: the field in the row.
  void duplicateColumn({
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
  }) {
    if (blockIfStructureLocked()) return;
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    pages[pageIndex]
        .rows[rowIndex]
        .numOfColumn!
        .text = FormDateTimeHelper.formatInt(
      (pages[pageIndex].rows[rowIndex].numOfColumn!.text.toEnglishNumber() + 1),
    );

    final duplicated = pages[pageIndex].rows[rowIndex].controllers[columnIndex]
        .duplicate();
    if (duplicated != null) {
      pages[pageIndex].rows[rowIndex].controllers.add(duplicated);
    }

    emit(currentState.copyWith(pages: pages));
  }

  /// Method Name: [duplicateRow]
  ///
  /// Purpose: copies a row (all its fields) under itself.
  ///
  /// Parameters:
  /// - [pageIndex]: the page.
  /// - [indexRow]: the row.
  void duplicateRow({required int pageIndex, required int indexRow}) {
    if (blockIfStructureLocked()) return;
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final duplicated = pages[pageIndex].rows[indexRow].duplicate();
    if (duplicated != null) {
      // FB-HOME-14: the copy goes right after the original, on the same page
      // (it was added to the end of the LAST page).
      pages[pageIndex].rows.insert(indexRow + 1, duplicated);
    }

    emit(currentState.copyWith(pages: pages));
  }

  /// Method Name: [onRequiredSwitchChanged]
  ///
  /// Purpose: turns Required on or off for a field.
  ///
  /// Parameters:
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  /// - [columnIndex]: the field in the row.
  /// - [value]: the new Required value.
  void onRequiredSwitchChanged({
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
    required bool value,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    pages[pageIndex].rows[rowIndex].controllers[columnIndex].changeIsRequired(
      value,
    );

    emit(currentState.copyWith(pages: pages));
  }

  /// Method Name: [addPage]
  ///
  /// Purpose: adds an empty page (one text field) at the end. Refused when the form already has answers.
  void addPage() {
    if (blockIfStructureLocked()) return;
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    List<RowControllerModel> rowModel = [];
    rowModel.add(RowControllerModel(controllers: [TextFieldController()]));
    pages.add(PageControllerModel(rows: rowModel));

    emit(currentState.copyWith(pages: pages));
  }

  /// Method Name: [addPageWithRow]
  ///
  /// Purpose: moves the last row of a full page to a new page after it (the A4 preview overflowed).
  ///
  /// Parameters:
  /// - [pageIndex]: the page that overflowed.
  void addPageWithRow(int pageIndex) {
    if (blockIfStructureLocked(silent: true)) return;
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    // (large-screen bug report p.1 — picking "Radio - Text
    // Field" lagged and produced Page 53, 54 … 71): when ONE row is taller
    // than the A4 page, moving it to the next page cannot help — that page
    // overflows too and moves it on again, forever, leaving an empty page
    // behind each time. Only split a page that has a row to spare.
    if (pageIndex < 0 ||
        pageIndex >= pages.length ||
        pages[pageIndex].rows.length <= 1) {
      return;
    }
    if (pageIndex + 1 < pages.length) {
      pages[pageIndex + 1].rows.add(pages[pageIndex].rows.last);
    } else {
      pages.add(PageControllerModel(rows: [pages[pageIndex].rows.last]));
    }
    pages[pageIndex].rows.removeLast();

    emit(currentState.copyWith(pages: pages));
  }

  /// Method Name: [expandedPage]
  ///
  /// Purpose: shows or hides the fields of a page.
  ///
  /// Parameters:
  /// - [pageIndex]: the page.
  void expandedPage(int pageIndex) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    pages[pageIndex].isPageExpanded = pages[pageIndex].isPageExpanded.toggle();

    int? newExpandedPageIndex;
    for (int i = 0; i < pages.length; i++) {
      var element = pages[i];
      if (element.isPageExpanded) {
        newExpandedPageIndex = i;
        break;
      }
    }

    emit(
      currentState.copyWith(
        pages: pages,
        expandedPageIndex: newExpandedPageIndex,
      ),
    );
  }

  /// Publish double-tap guard (Home rule 15: it lived in a build method).
  bool _isPublishing = false;

  /// Function Name: [tryStartPublish]
  ///
  /// Purpose: Starts a publish unless one is already running.
  ///
  /// Returns: false when a publish is already in progress.
  bool tryStartPublish() {
    if (_isPublishing) return false;
    _isPublishing = true;
    return true;
  }

  /// Ends the publish started by [tryStartPublish].
  void endPublish() => _isPublishing = false;

  /// Function Name: [buildFormForPublish]
  ///
  /// Purpose: [createFormHomeModel] with its failure caught here, in the
  /// cubit, instead of in the Publish button (Home rule 14).
  ///
  /// Returns: the form to publish, or null when it could not be built.
  FormEntity? buildFormForPublish() {
    try {
      return createFormHomeModel();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        developer.log(
          '$e',
          name: 'CreateFormDataCubit',
          error: e,
          stackTrace: stackTrace,
        );
      }
      return null;
    }
  }

  /// Method Name: [createFormHomeModel]
  ///
  /// Purpose: builds the form from the header and the pages being edited (keeps the id and create date of a form being edited).
  ///
  /// Returns: the form; throws when the editor is not loaded (use buildFormForPublish).
  FormEntity createFormHomeModel() {
    if (state is! CreateFormDataLoaded) throw Exception('State not loaded');
    final currentState = state as CreateFormDataLoaded;

    if (mainCoreEmployeeController.employeeEntity == null) {
      throw Exception('Employee entity is not initialized');
    }

    FormHeadData formCreateModel = createFormHeadCubit.createFormHeadModel();
    PersonEntity personEntity = PersonEntityFactory.fromEmployeeEntity(
      mainCoreEmployeeController.employeeEntity!,
    );

    // An edited form keeps its id; a new form gets a new one.
    String formId;
    DateTime createDate;

    if (currentState.existingFormId != null &&
        currentState.existingFormId!.isNotEmpty) {
      // EDITING MODE: Use original ID and date
      formId = currentState.existingFormId!;
      createDate = currentState.existingCreateDate ?? DateTime.now();
    } else {
      // New form: new id and create date.
      formId =
          '${mainCoreEmployeeController.employeeEntity!.id}_${DateTime.now().toString()}';
      createDate = DateTime.now();
    }

    FormEntity formModel = FormEntity(
      personEntity: personEntity,
      pages: [],
      id: formId, // Use the determined ID
      status: FormStatus.publish,
      formHeadModel: formCreateModel,
      createDate: createDate,
    ); // Use the determined create date

    for (var i = 0; i < currentState.pages.length; i++) {
      formModel.pages.add(currentState.pages[i].toModel());
    }

    final AccessManagement? access = AccessManagementExtension.fromStored(
      formCreateModel.accessManagement,
    );
    if (access == AccessManagement.restrictedAccess) {
      formModel.restrictedAccessModel = RestrictedAccessModel(
        isEdit: currentState.isEdit,
        timeBegin: currentState.timeBegin,
        timeEnd: currentState.timeEnd,
        selectedPersons: currentState.selectedPersonList,
      );
    } else if (access == AccessManagement.openAccess) {
      formModel.openAccessModel = OpenAccessModel(
        selectedDepartments: currentState.departmentsShown,
        isEdit: currentState.isEdit,
        timeBegin: currentState.timeBegin,
        timeEnd: currentState.timeEnd,
      );
    }

    return formModel;
  }

  /// Method Name: [onDropDownOpenAccess]
  ///
  /// Purpose: adds the department picked for Open Access.
  ///
  /// Parameters:
  /// - [value]: the department id.
  void onDropDownOpenAccess(String? value) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    DepartmentModelPro? model = addDepartmentController.departmentModels
        .firstWhereOrNull((element) => element.departmentID == value);

    if (model == null) return;

    DepartmentEntity departmentEntity = DepartmentEntity(
      id: model.departmentID!,
      name: model.departmentName!,
      nameAr: model.departmentNameInArabic!,
    );

    if (value != null &&
        !currentState.departmentsShown
            .map((e) => e.id)
            .contains(departmentEntity.id)) {
      final newDepartmentsShown = List<DepartmentEntity>.from(
        currentState.departmentsShown,
      )..add(departmentEntity);

      emit(
        currentState.copyWith(
          selectedDepartment: value,
          departmentsShown: newDepartmentsShown,
        ),
      );
    }
  }

  /// Method Name: [onCancelDepartmentOpenAccess]
  ///
  /// Purpose: removes a picked Open Access department.
  ///
  /// Parameters:
  /// - [index]: its position in the picked list.
  void onCancelDepartmentOpenAccess(int index) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final newDepartmentsShown = List<DepartmentEntity>.from(
      currentState.departmentsShown,
    )..removeAt(index);

    emit(currentState.copyWith(departmentsShown: newDepartmentsShown));
  }

  /// Method Name: [addToSavedColors]
  ///
  /// Purpose: remembers a title colour so it can be picked again.
  ///
  /// Parameters:
  /// - [color]: the colour.
  void addToSavedColors(Color color) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    if (!currentState.savedColors.contains(color)) {
      final newSavedColors = List<Color>.from(currentState.savedColors)
        ..add(color);
      emit(currentState.copyWith(savedColors: newSavedColors));
    }
  }

  /// Method Name: [selectPerson]
  ///
  /// Purpose: adds or removes a person for Restricted Access.
  ///
  /// Parameters:
  /// - [person]: the person.
  void selectPerson(PersonEntity person) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final newPersonList = List<PersonEntity>.from(currentState.personList);
    final newSelectedPersonList = List<PersonEntity>.from(
      currentState.selectedPersonList,
    );

    final personIndex = newPersonList.indexWhere((p) => p.id == person.id);
    if (personIndex != -1) {
      if (newPersonList[personIndex].isSelected) {
        newPersonList[personIndex].isSelected = false;
        newSelectedPersonList.remove(newPersonList[personIndex]);
      } else {
        newPersonList[personIndex].isSelected = true;
        newSelectedPersonList.add(newPersonList[personIndex]);
      }
    }

    emit(
      currentState.copyWith(
        personList: newPersonList,
        selectedPersonList: newSelectedPersonList,
      ),
    );
  }

  /// Method Name: [selectPresonDepartment]
  ///
  /// Purpose: filters the people list by department (Restricted Access).
  ///
  /// Parameters:
  /// - [value]: the department id, or null for everyone.
  void selectPresonDepartment(String? value) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    emit(currentState.copyWith(currentPersonDepartment: value));
    filterPerson();
  }

  /// Method Name: [search]
  ///
  /// Purpose: filters the people list by name (Restricted Access).
  ///
  /// Parameters:
  /// - [value]: the search text.
  void search(String value) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    emit(currentState.copyWith(textSearch: value));
    filterPerson();
  }

  /// Method Name: [updateTimeBegin]
  ///
  /// Purpose: stores the start of the access.
  ///
  /// Parameters:
  /// - [date]: the start date.
  void updateTimeBegin(DateTime? date) {
    if (state is CreateFormDataLoaded) {
      final currentState = state as CreateFormDataLoaded;

      emit(currentState.copyWith(timeBegin: date, incrementVersion: true));
    }
  }

  /// Update time end
  void updateTimeEnd(DateTime? date) {
    if (state is CreateFormDataLoaded) {
      final currentState = state as CreateFormDataLoaded;

      emit(currentState.copyWith(timeEnd: date, incrementVersion: true));
    }
  }

  /// Update edit permission.
  void updateIsEdit(bool value) {
    if (state is CreateFormDataLoaded) {
      final currentState = state as CreateFormDataLoaded;

      emit(currentState.copyWith(isEdit: value, incrementVersion: true));
    }
  }

  /// Method Name: [addOpenAccessData]
  ///
  /// Purpose: copies the picked departments, dates and edit permission into [form] (Open Access).
  ///
  /// Parameters:
  /// - [form]: the form to publish.
  ///
  /// Returns: [form] with its Open Access settings.
  FormEntity addOpenAccessData(FormEntity form) {
    if (state is! CreateFormDataLoaded) return form;
    final currentState = state as CreateFormDataLoaded;

    form.openAccessModel = OpenAccessModel(
      selectedDepartments: currentState.departmentsShown,
      isEdit: currentState.isEdit,
      timeBegin: currentState.timeBegin,
      timeEnd: currentState.timeEnd,
    );
    return form;
  }

  /// Method Name: [addRestrictedAccessData]
  ///
  /// Purpose: copies the picked people, dates and edit permission into [form] (Restricted Access).
  ///
  /// Parameters:
  /// - [form]: the form to publish.
  ///
  /// Returns: [form] with its Restricted Access settings.
  FormEntity addRestrictedAccessData(FormEntity form) {
    if (state is! CreateFormDataLoaded) return form;
    final currentState = state as CreateFormDataLoaded;

    form.restrictedAccessModel = RestrictedAccessModel(
      isEdit: currentState.isEdit,
      timeBegin: currentState.timeBegin,
      timeEnd: currentState.timeEnd,
      selectedPersons: currentState.selectedPersonList,
    );
    return form;
  }

  /// Method Name: [resetController]
  ///
  /// Purpose: empties the editor before a new editor screen opens; the old
  /// pages' text controllers are disposed (Home rule 13).
  void resetController() {
    final CreateFormDataState old = state;
    if (old is CreateFormDataLoaded) {
      disposeAfterFrame(rows: [for (final page in old.pages) ...page.rows]);
    }
    emit(
      CreateFormDataLoaded(
        pages: [],
        expandedPageIndex: 0,
        departmentsShown: [],
        personList: [],
        shownPersonList: [],
        selectedPersonList: [],
        isEdit: false,
        savedColors: [AppColors.white, AppColors.black],
      ),
    );
  }

  @override
  Future<void> close() {
    // Unsubscribe BEFORE the dispose loop below, and cancel a pending
    // debounce so it does not emit on a closed cubit.
    _previewDebounce?.cancel();
    _previewDebounce = null;
    for (final controller in _previewWatched) {
      // Safe after dispose (ChangeNotifier.removeListener does not throw).
      controller.removeListener(_onWatchedTextChanged);
    }
    _previewWatched.clear();

    if (state is CreateFormDataLoaded) {
      final currentState = state as CreateFormDataLoaded;
      for (var page in currentState.pages) {
        for (var row in page.rows) {
          row.numOfColumn!.dispose();
          for (var controllerModel in row.controllers) {
            controllerModel.dispose();
          }
        }
      }
    }
    return super.close();
  }

  /// Method Name: [changeCheckBoxValue]
  ///
  /// Purpose: ticks or unticks an option of a checkbox field in the preview.
  ///
  /// Parameters:
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  /// - [columnIndex]: the field in the row.
  /// - [indexOption]: the new value (null keeps the current one).
  /// - [value]: whether the option is ticked.
  void changeCheckBoxValue({
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
    required int indexOption,
    required bool value,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final controller = pages[pageIndex].rows[rowIndex].controllers[columnIndex];

    if (controller is CheckBoxFieldController) {
      if (value == false) {
        controller.options[indexOption].value = false;
        emit(currentState.copyWith(pages: pages));
        return;
      }

      var maximumSelection = controller.maximumSelection;
      if (maximumSelection!.text == '') {
        controller.options[indexOption].value = value;
        emit(currentState.copyWith(pages: pages));
        return;
      } else {
        int numOfSelection = 0;
        var options = controller.options;
        for (var element in options) {
          numOfSelection = element.value ? numOfSelection + 1 : numOfSelection;
        }
        if (numOfSelection < maximumSelection.text.toEnglishNumber()) {
          controller.options[indexOption].value = value;
          emit(currentState.copyWith(pages: pages));
        }
      }
    }
  }
}

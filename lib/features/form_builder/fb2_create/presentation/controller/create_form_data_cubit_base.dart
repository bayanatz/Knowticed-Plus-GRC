/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: create_form_data_cubit_base.dart
/// Description: `CreateFormDataCubitBase` cubit (state management).
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/location_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/title_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/department_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/page_controller_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/row_controller_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/form_demo_data.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/extensions.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/mappers/person_entity_factory.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller_mapper.dart';
import 'package:knowticed_plus/features/form_builder/helpers/fb_failure.dart';

class CreateFormDataCubitBase extends Cubit<CreateFormDataState> {
  final MainCoreEmployeeController mainCoreEmployeeController;
  final MainCoreDepartmentCubit addDepartmentController;
  final CreateFormHeadCubit createFormHeadCubit;
  List<PersonEntity> _personList = [];
  List<PersonEntity> _shownPersonList = [];

  /// The form being edited already has submissions, so
  /// its STRUCTURE is locked (FB-HOME-03 / edit_validator.allowEditing):
  /// no adding / removing pages, rows or columns, no changing a field's type,
  /// no removing options. Text, hints, Required, alignment still change.
  /// The editor refuses those actions here instead of letting the user make
  /// them and then rejecting the whole save.
  bool structureLocked = false;

  /// Method Name: [blockIfStructureLocked]
  ///
  /// Purpose: true when a structure change must be refused. Unless
  /// [silent], bumps [CreateFormDataLoaded.structureLockedNotice] so the
  /// editor page tells the user why (no dialog from the cubit).
  ///
  /// Parameters:
  /// - [silent]: refuse without telling the user.
  ///
  /// Returns: true when the change is refused.
  bool blockIfStructureLocked({bool silent = false}) {
    if (!structureLocked) return false;
    final CreateFormDataState current = state;
    if (!silent && current is CreateFormDataLoaded) {
      emit(
        current.copyWith(
          structureLockedNotice: current.structureLockedNotice + 1,
        ),
      );
    }
    return true;
  }

  /// Every emit is skipped once the cubit is closed (Home rule 8).
  @override
  void emit(CreateFormDataState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Method Name: [disposeAfterFrame]
  ///
  /// Purpose: disposes the text controllers of removed rows and fields once
  /// the frame that stops showing them has been built (Home rule 13).
  ///
  /// Parameters:
  /// - [rows]: removed rows (their fields are disposed too).
  /// - [fields]: removed or replaced fields.
  void disposeAfterFrame({
    Iterable<RowControllerModel> rows = const [],
    Iterable<FieldController> fields = const [],
  }) {
    final List<RowControllerModel> oldRows = List.of(rows);
    final List<FieldController> oldFields = List.of(fields);
    if (oldRows.isEmpty && oldFields.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final RowControllerModel row in oldRows) {
        row.numOfColumn?.dispose();
        for (final FieldController field in row.controllers) {
          field.dispose();
        }
      }
      for (final FieldController field in oldFields) {
        field.dispose();
      }
    });
  }

  CreateFormDataCubitBase({
    required this.mainCoreEmployeeController,
    required this.addDepartmentController,
    required this.createFormHeadCubit,
  }) : super(CreateFormDataInitial());

  /// Method Name: [init]
  ///
  /// Purpose: opens the pages of a new form (or the demo form), or of
  /// [editFormModel]. FB-HOME-16: any error ends in an error state instead
  /// of an endless spinner.
  ///
  /// Parameters:
  /// - [editFormModel]: the form being edited, or null.
  ///
  /// Returns: [Future<void>].
  Future<void> init({FormEntity? editFormModel}) async {
    emit(CreateFormDataLoading());
    try {
      await _init(editFormModel: editFormModel);
    } catch (e, stackTrace) {
      if (isClosed) return;
      emit(CreateFormDataError(fbFailure(e, stackTrace).message));
    }
  }

  Future<void> _init({FormEntity? editFormModel}) async {
    List<PageControllerModel> pages = [];
    structureLocked = editFormModel != null && editFormModel.numberUsed > 0;

    // The id and create date of the form being edited are kept.
    String? existingFormId;
    DateTime? existingCreateDate;

    if (editFormModel == null) {
      List<RowControllerModel> rowModel = [];
      rowModel.add(RowControllerModel(controllers: [TextFieldController()]));
      pages.add(PageControllerModel(rows: rowModel));
    } else {
      existingFormId = editFormModel.id;
      existingCreateDate = editFormModel.createDate;

      for (var element in editFormModel.pages) {
        pages.add(element.toController());
      }
    }

    await setUsers();

    if (isClosed) return;
    emit(
      CreateFormDataLoaded(
        pages: pages,
        expandedPageIndex: 0,
        departmentsShown: [],
        personList: _personList,
        shownPersonList: _shownPersonList,
        selectedPersonList: [],
        isEdit: false,
        savedColors: [AppColors.white, AppColors.black],
        existingFormId: existingFormId,
        existingCreateDate: existingCreateDate,
      ),
    );
  }

  /// Method Name: [fillDemoData]
  ///
  /// Purpose: "Fill demo data" button. Replaces the current pages with the
  /// demo pages — every field type, filled in — and pre-sets the Open Access
  /// publish settings (first department, starts now, ends in 30 days,
  /// editing allowed). FB-HOME-29: applied at once on every screen size (the
  /// cubit is already loaded), so the next new form no longer opens with
  /// demo pages.
  void fillDemoData() {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;
    final oldPages = currentState.pages;

    emit(
      currentState.copyWith(
        pages: FormDemoData.buildPages(),
        expandedPageIndex: 0,
      ),
    );
    fillDemoAccess();

    // Dispose the replaced controllers after the frame, once no widget is
    // still bound to them (same pattern as deleteColumn).
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _disposePages(oldPages),
    );
  }

  /// Disposes every controller of [pages]; a failure is logged, not thrown,
  /// so one bad field does not leave the others undisposed.
  void _disposePages(List<PageControllerModel> pages) {
    for (final page in pages) {
      for (final row in page.rows) {
        try {
          row.numOfColumn?.dispose();
        } catch (e, stackTrace) {
          fbFailure(e, stackTrace);
        }
        for (final field in row.controllers) {
          try {
            field.dispose();
          } catch (e, stackTrace) {
            fbFailure(e, stackTrace);
          }
        }
      }
    }
  }

  /// Open Access publish settings for the demo form.
  void fillDemoAccess() {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final departments = List<DepartmentEntity>.from(
      currentState.departmentsShown,
    );
    final first = addDepartmentController.departmentModels.firstOrNull;
    final String? firstId = first?.departmentID;
    if (departments.isEmpty && first != null && firstId != null) {
      departments.add(
        DepartmentEntity(
          id: firstId,
          name: first.departmentName ?? '',
          nameAr: first.departmentNameInArabic ?? first.departmentName ?? '',
        ),
      );
    }

    final now = DateTime.now();
    emit(
      currentState.copyWith(
        departmentsShown: departments,
        selectedDepartment: departments.isNotEmpty
            ? departments.first.id
            : null,
        timeBegin: now,
        timeEnd: now.add(const Duration(days: 30)),
        isEdit: true,
      ),
    );
  }

  /// Method Name: [setUsers]
  ///
  /// Purpose: loads the employee list (when it is not loaded yet) and keeps it as people to pick.
  ///
  /// Returns: [Future<void>].
  Future<void> setUsers() async {
    if (mainCoreEmployeeController.allEmployeesEntities == null ||
        mainCoreEmployeeController.allEmployeesEntities!.isEmpty) {
      await mainCoreEmployeeController.getAllNewEmployees();
    }
    _personList = mainCoreEmployeeController.allEmployeesEntities!
        .map((e) => PersonEntityFactory.fromEmployeeEntity(e))
        .toList();
    _shownPersonList = _personList;
  }

  /// Method Name: [deleteRow]
  ///
  /// Purpose: removes a row; the page goes too when it was its last row. Refused when the form already has answers.
  ///
  /// Parameters:
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  void deleteRow({required int pageIndex, required int rowIndex}) {
    if (blockIfStructureLocked()) return;
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    if (pages[pageIndex].rows.length == 1) {
      deletePage(pageIndex);
      return;
    }
    final RowControllerModel removed = pages[pageIndex].rows.removeAt(rowIndex);

    emit(currentState.copyWith(pages: pages));
    disposeAfterFrame(rows: [removed]);
  }

  /// Method Name: [deletePage]
  ///
  /// Purpose: removes a page. Refused when the form already has answers.
  ///
  /// Parameters:
  /// - [pageIndex]: the page.
  void deletePage(int pageIndex) {
    if (blockIfStructureLocked()) return;
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final PageControllerModel removed = pages.removeAt(pageIndex);
    if (pages.length == 1) {
      pages[0].isPageExpanded = true;
    }

    emit(currentState.copyWith(pages: pages));
    disposeAfterFrame(rows: removed.rows);
  }

  /// Method Name: [filterPerson]
  ///
  /// Purpose: applies the department and name filters to the people list.
  void filterPerson() {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    List<PersonEntity> filtered = List.from(currentState.personList);

    if (currentState.currentPersonDepartment != null) {
      filtered = filtered
          .where(
            (element) =>
                element.department == currentState.currentPersonDepartment,
          )
          .toList();
    }
    if (currentState.textSearch != null &&
        currentState.textSearch!.isNotEmpty) {
      filtered = filtered
          .where(
            (element) => mainCoreEmployeeController
                .getEmployeeName(element.id)
                .toLowerCase()
                // FB-HOME-15: lower-case the search text too ("Ahmed" found nobody).
                .contains(currentState.textSearch!.toLowerCase()),
          )
          .toList();
    }

    emit(currentState.copyWith(shownPersonList: filtered));
  }

  /// Method Name: [changeNumberOfColumn]
  ///
  /// Purpose: sets how many fields a row has (adds text fields or removes the last ones). Refused when the form already has answers.
  ///
  /// Parameters:
  /// - [value]: the number of fields.
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  void changeNumberOfColumn({
    required int value,
    required int pageIndex,
    required int rowIndex,
  }) {
    if (blockIfStructureLocked()) {
      // Put the box back to the real column count.
      final st = state;
      if (st is CreateFormDataLoaded) {
        final row = st.pages[pageIndex].rows[rowIndex];
        row.numOfColumn?.text = FormDateTimeHelper.formatInt(
          row.controllers.length,
        );
      }
      return;
    }
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final currentLength = pages[pageIndex].rows[rowIndex].controllers.length;

    List<FieldController> removed = const [];
    if (currentLength > value) {
      final List<FieldController> row =
          pages[pageIndex].rows[rowIndex].controllers;
      removed = row.sublist(value, currentLength);
      row.removeRange(value, currentLength);
    } else if (currentLength < value) {
      int addCount = value - currentLength;
      for (var i = 0; i < addCount; i++) {
        pages[pageIndex].rows[rowIndex].controllers.add(TextFieldController());
      }
    }

    // Version will auto-increment, forcing rebuild
    emit(currentState.copyWith(pages: pages));
    disposeAfterFrame(fields: removed);
  }

  /// Method Name: [changeAlignmentValue]
  ///
  /// Purpose: stores the alignment picked for a field.
  ///
  /// Parameters:
  /// - [value]: the stored alignment name.
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  /// - [columnIndex]: the field in the row.
  void changeAlignmentValue({
    required String value,
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    pages[pageIndex].rows[rowIndex].controllers[columnIndex]
        .changeAlignmentValue(value);

    emit(currentState.copyWith(pages: pages));
  }

  /// Method Name: [changeArrangementValue]
  ///
  /// Purpose: stores the arrangement (vertical / horizontal) picked for a field's options.
  ///
  /// Parameters:
  /// - [value]: the stored arrangement name.
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  /// - [columnIndex]: the field in the row.
  void changeArrangementValue({
    required String value,
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    pages[pageIndex].rows[rowIndex].controllers[columnIndex]
        .changeArrangementValue(value);

    emit(currentState.copyWith(pages: pages));
  }

  /// Method Name: [changeLocationTypeValue]
  ///
  /// Purpose: stores the location type of a location field. Refused when the form already has answers.
  ///
  /// Parameters:
  /// - [value]: the stored location type.
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  /// - [columnIndex]: the field in the row.
  void changeLocationTypeValue({
    required String value,
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
  }) {
    if (blockIfStructureLocked()) return;
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final controller = pages[pageIndex].rows[rowIndex].controllers[columnIndex];

    if (controller is LocationFieldController) {
      controller.locationType = value;
    }

    emit(currentState.copyWith(pages: pages));
  }

  /// Method Name: [setTitleTextSize]
  ///
  /// Purpose: makes a title field's text one size bigger or smaller (0–99).
  ///
  /// Parameters:
  /// - [columnIndex]: the field in the row.
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  /// - [isAdd]: true for bigger.
  void setTitleTextSize({
    required int columnIndex,
    required int pageIndex,
    required int rowIndex,
    required bool isAdd,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final controller = pages[pageIndex].rows[rowIndex].controllers[columnIndex];

    if (controller is TitleFieldController) {
      int result;
      if (isAdd) {
        result = controller.textSize!.text.toEnglishNumber();
        result = result < 99 ? (++result) : (result);
      } else {
        result = controller.textSize!.text.toEnglishNumber();
        result = result > 0 ? (--result) : (result);
      }
      controller.textSize!.text = FormDateTimeHelper.formatInt(result)
          .doubleDigit;
    }

    emit(currentState.copyWith(pages: pages));
  }

  /// Method Name: [setTitleColor]
  ///
  /// Purpose: stores the colour of a title field.
  ///
  /// Parameters:
  /// - [columnIndex]: the field in the row.
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  /// - [color]: the colour.
  void setTitleColor({
    required int columnIndex,
    required int pageIndex,
    required int rowIndex,
    required Color color,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final controller = pages[pageIndex].rows[rowIndex].controllers[columnIndex];

    if (controller is TitleFieldController) {
      controller.titleColor = color;
    }

    emit(currentState.copyWith(pages: pages));
  }

  /// Method Name: [changeTitleStyle]
  ///
  /// Purpose: toggles bold, underline or italic on a title field.
  ///
  /// Parameters:
  /// - [columnIndex]: the field in the row.
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  /// - [style]: 'bold', 'underLine' or italic for anything else.
  void changeTitleStyle({
    required int columnIndex,
    required int pageIndex,
    required int rowIndex,
    required String style,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    final controller = pages[pageIndex].rows[rowIndex].controllers[columnIndex];

    if (controller is TitleFieldController) {
      if (style == 'bold') {
        controller.isBold = controller.isBold!.toggle();
      } else if (style == 'underLine') {
        controller.isUnderLine = controller.isUnderLine!.toggle();
      } else {
        controller.isItalic = controller.isItalic!.toggle();
      }
    }

    emit(currentState.copyWith(pages: pages));
  }

  /// Method Name: [changeFieldTypeValue]
  ///
  /// Purpose: replaces a field with an empty field of another type. Refused when the form already has answers.
  ///
  /// Parameters:
  /// - [value]: the stored field type name.
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  /// - [columnIndex]: the field in the row.
  void changeFieldTypeValue({
    required String value,
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
  }) {
    if (blockIfStructureLocked()) return;
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);

    // Get the new field type
    final newFieldType = FieldTypeExtension.fromName(value)!;
    final tempController = FieldController(newFieldType);
    final newController = tempController.initialize();

    // Replace controller
    final FieldController old =
        pages[pageIndex].rows[rowIndex].controllers[columnIndex];
    pages[pageIndex].rows[rowIndex].controllers[columnIndex] = newController;

    // Version will auto-increment, forcing rebuild
    emit(currentState.copyWith(pages: pages));
    disposeAfterFrame(fields: [old]);
  }

  /// Method Name: [addOption]
  ///
  /// Purpose: adds an option to a dropdown, radio or checkbox field.
  ///
  /// Parameters:
  /// - [columnIndex]: the field in the row.
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  void addOption({
    required int columnIndex,
    required int pageIndex,
    required int rowIndex,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    pages[pageIndex].rows[rowIndex].controllers[columnIndex].addOption();

    emit(currentState.copyWith(pages: pages));
  }

  /// Method Name: [removeOption]
  ///
  /// Purpose: removes an option. Refused when the form already has answers.
  ///
  /// Parameters:
  /// - [columnIndex]: the field in the row.
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  /// - [optionIndex]: the option.
  void removeOption({
    required int columnIndex,
    required int pageIndex,
    required int rowIndex,
    required int optionIndex,
  }) {
    if (blockIfStructureLocked()) return;
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    pages[pageIndex].rows[rowIndex].controllers[columnIndex].removeOption(
      optionIndex,
    );

    emit(currentState.copyWith(pages: pages));
  }

  /// Method Name: [onExpanded]
  ///
  /// Purpose: shows or hides the fields of a row.
  ///
  /// Parameters:
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  void onExpanded({required int pageIndex, required int rowIndex}) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    pages[pageIndex].rows[rowIndex].isRowExpanded = pages[pageIndex]
        .rows[rowIndex]
        .isRowExpanded
        .toggle();

    emit(currentState.copyWith(pages: pages));
  }

  /// Method Name: [updateFieldText]
  ///
  /// Purpose: re-emits after a field's text changed, so the preview follows.
  ///
  /// Parameters:
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  /// - [columnIndex]: the field in the row.
  void updateFieldText({
    required int pageIndex,
    required int rowIndex,
    required int columnIndex,
  }) {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    // Just emit a new state with incremented version to trigger rebuild
    emit(currentState.copyWith(incrementVersion: true));
  }

  /// Method Name: [deleteColumn]
  ///
  /// Purpose: removes a field from its row; the row goes too when it was its last field. Refused when the form already has answers.
  ///
  /// Parameters:
  /// - [columnIndex]: the field in the row.
  /// - [pageIndex]: the page.
  /// - [rowIndex]: the row in the page.
  void deleteColumn({
    required int columnIndex,
    required int pageIndex,
    required int rowIndex,
  }) {
    if (blockIfStructureLocked()) return;
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);

    if (pages[pageIndex].rows[rowIndex].controllers.length > 1) {
      // Update the number of columns
      pages[pageIndex]
          .rows[rowIndex]
          .numOfColumn!
          .text = FormDateTimeHelper.formatInt(
        (pages[pageIndex].rows[rowIndex].numOfColumn!.text.toEnglishNumber() -
            1),
      );

      final FieldController removed = pages[pageIndex]
          .rows[rowIndex]
          .controllers
          .removeAt(columnIndex);
      emit(currentState.copyWith(pages: pages));
      disposeAfterFrame(fields: [removed]);
    } else {
      deleteRow(pageIndex: pageIndex, rowIndex: rowIndex);
      return;
    }
  }

  /// Method Name: [expandAllPages]
  ///
  /// Purpose: opens every page before the Preview screen is shown (the page
  /// navigates).
  void expandAllPages() {
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;
    final pages = List<PageControllerModel>.from(currentState.pages);
    for (final element in pages) {
      element.isPageExpanded = true;
    }
    emit(currentState.copyWith(pages: pages));
  }

  /// Method Name: [addRow]
  ///
  /// Purpose: adds a row (one text field) at the end of the last page. Refused when the form already has answers.
  void addRow() {
    if (blockIfStructureLocked()) return;
    if (state is! CreateFormDataLoaded) return;
    final currentState = state as CreateFormDataLoaded;

    final pages = List<PageControllerModel>.from(currentState.pages);
    if (pages.isEmpty) {
      // FB-HOME-23: add a fresh page instead of calling init(), which was not
      // awaited and dropped the id of the form being edited (saving then
      // created a second, new form).
      pages.add(
        PageControllerModel(
          rows: [
            RowControllerModel(controllers: [TextFieldController()]),
          ],
        ),
      );
      emit(currentState.copyWith(pages: pages, expandedPageIndex: 0));
      return;
    }
    pages.last.rows.add(
      RowControllerModel(controllers: [TextFieldController()]),
    );

    emit(currentState.copyWith(pages: pages));
  }
}

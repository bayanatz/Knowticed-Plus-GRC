/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: result_analytics_cubit.dart
/// Description: `ResultAnalyticsCubit`, the Analytics view of the Results
///              page (charts, tables and text answers per field). Split out
///              of ResultCubit, which keeps the people, filters and
///              reminders.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/address_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/page_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/analytics_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/analytics_text_field_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/form_chart_data.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/user_grid_item.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/utils/analytics_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/check_box_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/drop_down_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/radio_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/address_analytics_entity.dart';

/// State of [ResultAnalyticsCubit].
class ResultAnalyticsState extends Equatable {
  /// One entry per field that has analytics.
  final List<AnalyticsEntity> analyticsData;

  /// False until the analytics were built once.
  final bool isReady;

  const ResultAnalyticsState({
    this.analyticsData = const [],
    this.isReady = false,
  });

  @override
  List<Object?> get props => [analyticsData, isReady];
}

/// The form and its submitted people, as the analytics read them.
class _AnalyticsInput {
  final FormEntity? formEntity;
  final List<UserGridItem> submittedUsers;

  const _AnalyticsInput(
      {required this.formEntity, required this.submittedUsers});
}

/// The Analytics view of the Results page.
class ResultAnalyticsCubit extends Cubit<ResultAnalyticsState> {
  ResultAnalyticsCubit() : super(const ResultAnalyticsState());

  /// Method Name: [getAnalyticsData]
  ///
  /// Description: builds the analytics of every field that has analytics,
  /// from the form and its submitted people.
  ///
  /// Parameters:
  ///   form: the form.
  ///   submittedUsers: the people who answered.
  void getAnalyticsData({
    required FormEntity form,
    required List<UserGridItem> submittedUsers,
  }) {
    final _AnalyticsInput currentState =
        _AnalyticsInput(formEntity: form, submittedUsers: submittedUsers);

    List<AnalyticsEntity> analyticsData = [];

    for (int pageIndex = 0;
        pageIndex < currentState.formEntity!.pages.length;
        pageIndex++) {
      PageEntity page = currentState.formEntity!.pages[pageIndex];
      for (int rowIndex = 0; rowIndex < page.rows.length; rowIndex++) {
        for (int fieldIndex = 0;
            fieldIndex < page.rows[rowIndex].fields.length;
            fieldIndex++) {
          if (AnalyticsHelper.isHasAnalytics(
              page.rows[rowIndex].fields[fieldIndex].type)) {
            if (page.rows[rowIndex].fields[fieldIndex].type ==
                FormFieldType.address) {
              analyticsData.add(AddressAnalyticsEntity(
                title: page.rows[rowIndex].fields[fieldIndex].fieldTitle ?? "",
                type: page.rows[rowIndex].fields[fieldIndex].type,
              ));
            } else {
              analyticsData.add(AnalyticsEntity(
                title: page.rows[rowIndex].fields[fieldIndex].fieldTitle ?? "",
                type: page.rows[rowIndex].fields[fieldIndex].type,
              ));
            }

            if (AnalyticsHelper.hasTextFieldAndAggregated(
                page.rows[rowIndex].fields[fieldIndex].type)) {
              analyticsData.last.isAggregated = false;
            }

            if (AnalyticsHelper.doughnutChartAnalytics(
                page.rows[rowIndex].fields[fieldIndex].type)) {
              _createChartAnalytics(
                pageIndex,
                rowIndex,
                fieldIndex,
                analyticsData.last,
                currentState,
              );
            }

            if (AnalyticsHelper.barChartAnalytics(
                page.rows[rowIndex].fields[fieldIndex].type)) {
              if (analyticsData.last.type == FormFieldType.address) {
                _createAddressChartAnalytics(
                  pageIndex,
                  rowIndex,
                  fieldIndex,
                  analyticsData.last,
                  currentState,
                );
                _createTableData(
                  pageIndex,
                  rowIndex,
                  fieldIndex,
                  analyticsData.last,
                  currentState,
                );
              } else {
                _createChartAnalytics(
                  pageIndex,
                  rowIndex,
                  fieldIndex,
                  analyticsData.last,
                  currentState,
                );
                // Bug report p.40 ("add tabulate to the check box"): the
                // checkbox card's Tabulate view lists each person's picks,
                // so the per-person answers are collected too.
                if (analyticsData.last.type == FormFieldType.checkBox &&
                    !AnalyticsHelper.answerAnalytics(FormFieldType.checkBox)) {
                  _getTextAnalyticsData(
                    pageIndex: pageIndex,
                    rowIndex: rowIndex,
                    fieldIndex: fieldIndex,
                    entity: analyticsData.last,
                    state: currentState,
                  );
                }
              }
            }

            if (AnalyticsHelper.answerAnalytics(
                page.rows[rowIndex].fields[fieldIndex].type)) {
              _getTextAnalyticsData(
                pageIndex: pageIndex,
                rowIndex: rowIndex,
                fieldIndex: fieldIndex,
                entity: analyticsData.last,
                state: currentState,
              );
            }
          }
        }
      }
    }

    if (isClosed) return;
    emit(ResultAnalyticsState(analyticsData: analyticsData, isReady: true));
  }

  /// Method Name: [_getAllOptions]
  ///
  /// Description: This method retrieves all options for a given field in the form.
  ///
  /// Parameters:
  ///            pageIndex: The index of the page in the form.
  ///            rowIndex: The index of the row in the page.
  ///            fieldIndex: The index of the field in the row.
  ///            state: the form and its submitted people
  ///
  /// Returns: [Map<String,int>] A list of all options for the specified field.
  Map<String, int> _getAllOptions(
    int pageIndex,
    int rowIndex,
    int fieldIndex,
    _AnalyticsInput state,
  ) {
    List<String> allOptions = [];
    FieldModel field =
        state.formEntity!.pages[pageIndex].rows[rowIndex].fields[fieldIndex];

    switch (field.type) {
      case FormFieldType.dropDown:
        allOptions = (field as DropDownFieldModel).hints;
        break;
      case FormFieldType.radio:
        allOptions = (field as RadioFieldModel).hints;
        break;
      case FormFieldType.checkBox:
        allOptions = (field as CheckBoxFieldModel).options;
        break;
      default:
        break;
    }

    Map<String, int> optionFrequency = {};
    for (String option in allOptions) {
      optionFrequency.putIfAbsent(option, () => 0);
    }
    return optionFrequency;
  }

  /// Method Name: [_createChartAnalytics]
  ///
  /// Description: This method creates chart analytics data for a given field in the form.
  ///
  /// Parameters:
  ///          pageIndex: The index of the page in the form.
  ///          rowIndex: The index of the row in the page.
  ///          fieldIndex: The index of the field in the row.
  ///          analyticsEntity: The analytics entity to store the chart data.
  ///          state: the form and its submitted people
  void _createChartAnalytics(
    int pageIndex,
    int rowIndex,
    int fieldIndex,
    AnalyticsEntity analyticsEntity,
    _AnalyticsInput state,
  ) {
    Map<String, int> optionFrequency =
        _getAllOptions(pageIndex, rowIndex, fieldIndex, state);
    FormFieldType type = state
        .formEntity!.pages[pageIndex].rows[rowIndex].fields[fieldIndex].type;

    for (UserGridItem user in state.submittedUsers) {
      if (user.page![pageIndex].rows[rowIndex].fields[fieldIndex].type ==
          type) {
        String answer = AnalyticsHelper.getFieldAnswer(
          user.page![pageIndex].rows[rowIndex].fields[fieldIndex],
        );

        if (type == FormFieldType.checkBox) {
          List<String> answers = answer.split(', ');
          for (String ans in answers) {
            if (ans.isEmpty) continue;
            optionFrequency.putIfAbsent(ans, () => 0);
            optionFrequency[ans] = optionFrequency[ans]! + 1;
          }
        } else {
          optionFrequency.putIfAbsent(answer, () => 0);
          optionFrequency[answer] = optionFrequency[answer]! + 1;
        }
      }
    }

    List<FormChartData> chartData = [];
    optionFrequency.forEach((key, value) {
      chartData.add(FormChartData(key, value.toDouble()));
    });
    analyticsEntity.chartData = chartData;
  }

  void _getTextAnalyticsData({
    required int pageIndex,
    required int rowIndex,
    required int fieldIndex,
    required AnalyticsEntity entity,
    required _AnalyticsInput state,
  }) {
    // Initialize FIRST
    entity.data ??= [];

    FormFieldType type = state
        .formEntity!.pages[pageIndex].rows[rowIndex].fields[fieldIndex].type;

    for (UserGridItem user in state.submittedUsers) {
      // Check if user has valid page structure
      if (user.page == null) {
        continue;
      }

      if (pageIndex >= user.page!.length) {
        continue;
      }

      if (rowIndex >= user.page![pageIndex].rows.length) {
        continue;
      }

      if (fieldIndex >= user.page![pageIndex].rows[rowIndex].fields.length) {
        continue;
      }

      FormFieldType userFieldType =
          user.page![pageIndex].rows[rowIndex].fields[fieldIndex].type;

      if (userFieldType == type) {
        List<String> answers = [];

        // For address fields, get the answers list directly
        if (type == FormFieldType.address) {
          AddressFieldModel addressField = user.page![pageIndex].rows[rowIndex]
              .fields[fieldIndex] as AddressFieldModel;

          AddressFieldModel originalField = state.formEntity!.pages[pageIndex]
              .rows[rowIndex].fields[fieldIndex] as AddressFieldModel;

          final expectedLength = originalField.hints.length;

          if (addressField.answers != null &&
              addressField.answers!.isNotEmpty) {
            answers = List<String>.from(addressField.answers!);

            while (answers.length < expectedLength) {
              answers.add('');
            }

            if (answers.length > expectedLength) {
              answers = answers.sublist(0, expectedLength);
            }
          } else {
            answers = List<String>.filled(expectedLength, '');
          }
        } else {
          String answer = AnalyticsHelper.getFieldAnswer(
            user.page![pageIndex].rows[rowIndex].fields[fieldIndex],
          );

          answers = [answer];
        }

        AnalyticsTextFieldEntity textFieldEntity = AnalyticsTextFieldEntity(
          person: user.person,
          submissionDate: user.submissionTime!,
          answers: answers,
        );
        entity.data!.add(textFieldEntity);
      }
    }
  }

  /// Method Name: [_createAddressChartAnalytics]
  ///
  /// Description: This method creates address chart analytics data for a given field in the form.
  ///
  /// Parameters:
  ///         pageIndex: The index of the page in the form.
  ///         rowIndex: The index of the row in the page.
  ///         fieldIndex: The index of the field in the row.
  ///         analyticsEntity: The analytics entity to store the address chart data.
  ///         state: the form and its submitted people
  void _createAddressChartAnalytics(
    int pageIndex,
    int rowIndex,
    int fieldIndex,
    AnalyticsEntity entity,
    _AnalyticsInput state,
  ) {
    AddressAnalyticsEntity addressAnalyticsEntity =
        entity as AddressAnalyticsEntity;
    List<Map<String, int>> allOptions = [];
    AddressFieldModel field = state.formEntity!.pages[pageIndex].rows[rowIndex]
        .fields[fieldIndex] as AddressFieldModel;

    for (int i = 0; i < field.hints.length; i++) {
      allOptions.add({});
    }

    for (UserGridItem user in state.submittedUsers) {
      AddressFieldModel fieldModel = user.page![pageIndex].rows[rowIndex]
          .fields[fieldIndex] as AddressFieldModel;

      // Skip if answers is null or empty
      if (fieldModel.answers == null || fieldModel.answers!.isEmpty) {
        continue;
      }

      // Use the MINIMUM of hints.length and answers.length to avoid index errors
      final maxIndex =
          fieldModel.hints.length < (fieldModel.answers?.length ?? 0)
              ? fieldModel.hints.length
              : (fieldModel.answers?.length ?? 0);

      for (int i = 0; i < maxIndex; i++) {
        if (fieldModel.answers![i].isNotEmpty) {
          allOptions[i].putIfAbsent(fieldModel.answers![i], () => 0);
          allOptions[i][fieldModel.answers![i]] =
              allOptions[i][fieldModel.answers![i]]! + 1;
        }
      }
    }

    List<List<FormChartData>> chartData = [];
    for (int i = 0; i < field.hints.length; i++) {
      List<FormChartData> chartDataList = [];
      allOptions[i].forEach((key, value) {
        chartDataList.add(FormChartData(key, value.toDouble()));
      });
      chartData.add(chartDataList);
    }
    addressAnalyticsEntity.addressItems = field.hints;
    addressAnalyticsEntity.addressChartData = chartData;
  }

  void _createTableData(
    int pageIndex,
    int rowIndex,
    int fieldIndex,
    AnalyticsEntity last,
    _AnalyticsInput state,
  ) {
    AddressAnalyticsEntity addressAnalyticsEntity =
        last as AddressAnalyticsEntity;
    List<String> headerItems = [];
    AddressFieldModel field = state.formEntity!.pages[pageIndex].rows[rowIndex]
        .fields[fieldIndex] as AddressFieldModel;

    headerItems.add(S.current.employeeName);
    for (int i = 0; i < field.hints.length; i++) {
      headerItems.add(field.hints[i]);
    }
    addressAnalyticsEntity.headerItems = headerItems;

    List<List<String>> tableList = [];
    List<String> images = [];

    for (UserGridItem user in state.submittedUsers) {
      AddressFieldModel fieldModel = user.page![pageIndex].rows[rowIndex]
          .fields[fieldIndex] as AddressFieldModel;
      List<String> row = [];
      images.add(user.person.image);
      row.add(user.person.name);

      for (int i = 0; i < field.hints.length; i++) {
        if ((i < (fieldModel.answers?.length ?? 0)) &&
            fieldModel.answers?[i] != null &&
            fieldModel.answers![i].isNotEmpty) {
          row.add(fieldModel.answers![i]);
        } else {
          row.add("");
        }
      }
      tableList.add(row);
    }

    addressAnalyticsEntity.addressTableList = tableList;
    addressAnalyticsEntity.images = images;
  }
}

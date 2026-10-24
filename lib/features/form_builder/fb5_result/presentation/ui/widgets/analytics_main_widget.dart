/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: analytics_main_widget.dart
/// Description: `AnalyticsMainWidget` widget, state and UI of the `AnalyticsMainWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/analytics_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/utils/analytics_helper.dart';

import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/column_chart.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/doughnut_chart.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/text_field_analytics.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/analytics_text_field_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/table/default_data_table.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_donut_chart_card.dart';
import 'package:knowticed_plus/core/helper/extensions.dart'
    hide ContextExtension;
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/utils/color_generator.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/form_chart_data.dart';

/// The analytics card of one field (chart, table or answers).
class AnalyticsMainWidget extends StatefulWidget {
  const AnalyticsMainWidget({required this.data, super.key});
  final AnalyticsEntity data;

  @override
  State<AnalyticsMainWidget> createState() => _AnalyticsMainWidgetState();
}

class _AnalyticsMainWidgetState extends State<AnalyticsMainWidget> {
  /// Checkbox questions only: table view instead of the bar chart.
  /// (bug report p.40 — "add tabulate to the check box";
  /// Figma MESBAH / FORM BUILDER results screen puts a "Tabulate" button in
  /// the checkbox card header). Same toggle the Address card already has.
  bool _isTabulated = false;

  bool get _isCheckBox => widget.data.type == FormFieldType.checkBox;

  @override
  Widget build(BuildContext context) {
    if (_isCheckBox && _isTabulated) {
      return _buildCheckBoxTableCard();
    }
    // Form bug report #33/#34/#38: chart questions render the app's shared
    // chart cards (core/custom/27 donut, core/custom/26 bar) instead of the
    // local Syncfusion charts. Text answers keep the original card.
    if (AnalyticsHelper.doughnutChartAnalytics(widget.data.type)) {
      return _buildDonutCard();
    }
    if (AnalyticsHelper.barChartAnalytics(widget.data.type) &&
        widget.data.isAggregated != false) {
      return _buildBarCard();
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(), verticalSpace(16), _buildBody()],
      ),
    );
  }

  Widget _buildHeader() {
    bool isTablet = !kpIsPhoneLayout(context);

    return BlocBuilder<ResultCubit, ResultState>(
      builder: (context, state) {
        if (state is! ResultLoaded) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Row(
              spacing: 10.h,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.sp),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: CustomSvgImage.natural(
                          assetPath: widget.data.type.icon,
                          height: 12.sp,
                          width: 12.sp,
                          color: AppColors.textButton,
                        ),
                      ),
                      horizontalSpace(5),
                      Expanded(
                        child: Text(
                          FormatHelper.capitalize(widget.data.title),
                          style: StyleText.fontSize12Weight500
                              .copyWith(color: AppColors.secondaryBlack)
                              .copyWith(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
                  child: Row(
                    children: [
                      Text(
                        isTablet
                            ? S.of(context).totalResponse
                            : S.of(context).total2,
                        style: StyleText.fontSize12Weight400
                            .copyWith(color: AppColors.secondaryBlack),
                      ),
                      Text(
                        '${state.submittedUsers.length}/${state.submittedUsers.length + state.pendingUsers.length}',
                        style: StyleText.fontSize14Weight600,
                      )
                    ],
                  ),
                ),
                if (isTablet) _aggregationButtonBuilder()
              ],
            ),
            if (!isTablet) verticalSpace(10),
            if (!isTablet) _aggregationButtonBuilder()
          ],
        );
      },
    );
  }

  /// Palette for chart segments / bars, one colour per option.
  List<Color> _chartColors(int count) {
    final colors = ColorGenerator.generateColors(count);
    while (colors.length < count) {
      colors.add(AppColors.grey);
    }
    return colors;
  }

  /// "Total response x/y" badge + the aggregation toggle, shown in the chart
  /// card header (ChartCard.trailing).
  Widget _buildChartTrailing() {
    bool isTablet = !kpIsPhoneLayout(context);
    return BlocBuilder<ResultCubit, ResultState>(
      builder: (context, state) {
        if (state is! ResultLoaded) return const SizedBox.shrink();
        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10.w,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isTablet
                        ? S.of(context).totalResponse
                        : S.of(context).total2,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryBlack),
                  ),
                  Text(
                    '${state.submittedUsers.length}/${state.submittedUsers.length + state.pendingUsers.length}',
                    style: StyleText.fontSize14Weight600,
                  ),
                ],
              ),
            ),
            if (widget.data.isAggregated != null) _aggregationButtonBuilder(),
            if (_isCheckBox) _tabulateButton(),
          ],
        );
      },
    );
  }

  /// "Tabulated" / "UnTabulated" toggle for checkbox questions (p.40).
  Widget _tabulateButton() {
    return customButton(
      function: () => setState(() => _isTabulated = !_isTabulated),
      title: _isTabulated ? S.of(context).untabulated : S.of(context).tabulated,
    );
  }

  /// Checkbox answers as a table: one row per person, a ✓ under every option
  /// they picked. Styled like the Address table (header row, alternating
  /// row colours) via the same DefaultDataTable.
  Widget _buildCheckBoxTableCard() {
    final List<String> options = <String>[
      for (final FormChartData d
          in widget.data.chartData ?? const <FormChartData>[])
        d.text,
    ];
    final List<AnalyticsTextFieldEntity> people =
        widget.data.data ?? const <AnalyticsTextFieldEntity>[];

    TextStyle headerStyle() =>
        StyleText.fontSize16Weight400.copyWith(color: AppColors.white);
    TextStyle cellStyle() =>
        StyleText.fontSize12Weight500.copyWith(color: AppColors.fullBlack);

    final List<DataColumn> columns = <DataColumn>[
      DataColumn(label: Text(S.of(context).NO, style: headerStyle())),
      DataColumn(label: Text(S.of(context).employeeName, style: headerStyle())),
      for (final String option in options)
        DataColumn(label: Text(option, style: headerStyle())),
    ];

    final List<DataRow> rows = <DataRow>[
      for (int i = 0; i < people.length; i++)
        DataRow(
          color: WidgetStatePropertyAll(
            i % 2 == 0 ? AppColors.evenRowColor : AppColors.oddRowColor,
          ),
          cells: <DataCell>[
            DataCell(Text('${i + 1}', style: cellStyle())),
            DataCell(Text(
              FormatHelper.capitalize(people[i].person.name),
              style: cellStyle(),
            )),
            for (final String option in options)
              DataCell(Text(
                _pickedOptions(people[i]).contains(option) ? '✓' : '',
                style: cellStyle(),
              )),
          ],
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: CustomSvgImage.natural(
                  assetPath: widget.data.type.icon,
                  height: 12.sp,
                  width: 12.sp,
                  color: AppColors.textButton,
                ),
              ),
              horizontalSpace(5),
              Expanded(
                child: Text(
                  FormatHelper.capitalize(widget.data.title),
                  style: StyleText.fontSize12Weight500
                      .copyWith(color: AppColors.secondaryBlack),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildChartTrailing(),
            ],
          ),
          verticalSpace(16),
          DefaultDataTable(columns: columns, rows: rows),
        ],
      ),
    );
  }

  /// The options one person ticked ("A, B" is stored as one string).
  Set<String> _pickedOptions(AnalyticsTextFieldEntity entry) {
    return <String>{
      for (final String answer in entry.answers)
        for (final String part in answer.split(', '))
          if (part.trim().isNotEmpty) part.trim(),
    };
  }

  /// #33/#38: donut via core DonutChartCard. Only options that were actually
  /// picked become ring segments, so no "0%" labels are drawn outside the
  /// ring and a single answer fills the ring at 100%, centred.
  Widget _buildDonutCard() {
    final data = widget.data.chartData ?? const <FormChartData>[];
    final colors = _chartColors(data.length);
    final sections = <ChartData>[
      for (int i = 0; i < data.length; i++)
        if (data[i].values > 0)
          ChartData(
              label: _westernDigits(data[i].text),
              value: data[i].values,
              color: colors[i]),
    ];
    return DonutChartCard(
      title: FormatHelper.capitalize(widget.data.title),
      dotIcon: widget.data.type.icon,
      trailing: _buildChartTrailing(),
      width: double.infinity,
      sections: sections,
      centerValue: widget.data.getTotalChartSubmissions.formatNumber(),
      centerLabel: S.of(context).total,
      chartSize: 160,
      // Bug report p.5: keep each count next to its label, not by the ring.
      compactLegend: true,
      // Vertical Arabic bug report p.29 (13/10/2026): figures in English.
      westernDigits: true,
    );
  }

  /// Arabic-Indic digits (٠-٩) → 0-9. Answers such as a time picked in the
  /// Arabic app were saved as "٤:٢١ م", so their chart labels came out in
  /// Arabic figures beside English ones (vertical bug report p.33).
  static String _westernDigits(String value) {
    const String eastern = '٠١٢٣٤٥٦٧٨٩';
    final StringBuffer out = StringBuffer();
    for (final int rune in value.runes) {
      final String ch = String.fromCharCode(rune);
      final int i = eastern.indexOf(ch);
      out.write(i >= 0 ? '$i' : ch);
    }
    return out.toString();
  }

  /// #34: vertical bars via core BarChartCard.
  Widget _buildBarCard() {
    final data = widget.data.chartData ?? const <FormChartData>[];
    return BarChartCard(
      title: FormatHelper.capitalize(widget.data.title),
      dotIcon: widget.data.type.icon,
      trailing: _buildChartTrailing(),
      width: double.infinity,
      bars: [
        for (final d in data)
          ChartData(label: _westernDigits(d.text), value: d.values),
      ],
      // Vertical Arabic bug report p.29 / p.33 (13/10/2026): English figures.
      westernDigits: true,
    );
  }

  Row _aggregationButtonBuilder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.data.isAggregated != null)
          customButton(
            function: () {
              setState(() {
                widget.data.isAggregated = !widget.data.isAggregated!;
              });
            },
            title: (widget.data.isAggregated == false)
                ? S.of(context).aggregated
                : S.of(context).unaggregated,
          )
      ],
    );
  }

  Widget _buildBody() {
    if (AnalyticsHelper.doughnutChartAnalytics(widget.data.type)) {
      return DoughnutChart(
        data: widget.data.chartData!,
        total: widget.data.getTotalChartSubmissions,
      );
    }
    if (AnalyticsHelper.answerAnalytics(widget.data.type) &&
        widget.data.isAggregated != true) {
      return TextFieldAnalytics(entity: widget.data);
    }
    if (AnalyticsHelper.barChartAnalytics(widget.data.type) &&
        widget.data.isAggregated != false) {
      return ColumnChart(data: widget.data.chartData!);
    }

    return Container();
  }
}

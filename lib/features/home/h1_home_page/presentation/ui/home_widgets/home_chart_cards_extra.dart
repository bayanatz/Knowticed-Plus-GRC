/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_chart_cards_extra.dart
/// Description: All eleven cards on the Adding Widget "Chart & Graph" tab.
/// Author: Amr Mesbah
/// Created at: 23/8/2026
///
/// Source of truth: Figma file BuJXLizpGcK5eHVBqQomXc, page "ROLE MANAGEMENT",
/// Settings > Home Layout > Adding Widget, iPad Horizontal View, node
/// 5356:111536.
///
/// GEOMETRY — read this before changing a width or a height.
///
/// The Figma frame is 1024 wide with an 80 sidebar; the chart column runs
/// x=110 to x=795, so the usable width is 685 with a 15 gutter. Every card is
/// exactly 200 tall and its width is one of 125 / 265 / 405 / 545. The five
/// rows each add up to 685 exactly:
///
///   1. Horizontal bar chart 265 + Base Line Chart 405
///   2. Table chart 405 + Bar chart 265
///   3. Stacked 265 + Grouped 265 + Pie 125
///   4. Horizontal Stacked 405 + Radial 265
///   5. Bar Chart 545 + Donut 125
///
/// The picker lays these out in a Wrap, so the row breaks fall out of the
/// widths plus the declaration order in `HomeComponents` — which is why that
/// enum lists the charts in the reading order above. Reordering the enum or
/// changing a width WILL change the rows.
///
/// Every card is a zero-field `const` widget so `HomeComponents.widget()` can
/// construct it directly.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/charts/custom_line_chart_card.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/home_card_metrics.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_widget_settings.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/settings/home_chart_values.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_donut_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_horizontal_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_grouped_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_extras.dart';
import 'package:knowticed_plus/core/custom/charts/custom_stacked_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_horizontal_stacked_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_base_line_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_pie_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_radial_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_table_chart_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/services/todo_chart_figures.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/settings/home_chart_live.dart';

/// One grid column — Pie Chart and Donut Chart.
const double kHomeChartNarrowWidth = 125;

/// Two grid columns.
const double kHomeChartWidth = 265;

/// Three grid columns — Owner 24/10/2026: the width of every chart card except
/// Bar Chart, Radial Bar Chart and Donut Chart (the Horizontal Bar Chart's).
const double kHomeChartWideWidth = 405;

/// Four grid columns — the wide Bar Chart.
const double kHomeChartFullWidth = 545;

/// Every chart card in the Figma frame is exactly this tall.
const double kHomeChartHeight = 200;

/// Figma's chart cards use 10 padding, not the 16 [ChartCard] defaults to.
EdgeInsets get _cardPadding => EdgeInsets.all(10.r);

/// Builds a chart card and rebuilds it when a module publishes its real
/// figures ([HomeChartLive]); the first build also starts the To-Do feed.
class HomeChartLiveScope extends StatefulWidget {
  const HomeChartLiveScope({super.key, required this.builder});

  final Widget Function() builder;

  @override
  State<HomeChartLiveScope> createState() => _HomeChartLiveScopeState();
}

class _HomeChartLiveScopeState extends State<HomeChartLiveScope> {
  @override
  void initState() {
    super.initState();
    TodoChartLive.ensureStarted();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: HomeChartLive.instance,
        builder: (BuildContext _, Widget? __) => widget.builder(),
      );
}

// ── The gear's Module / Values (23/10/2026) ──────────────────────────────────

/// What the chart's gear picked, or null = the card's own sample.
HomeChartValue? _picked(HomeComponentModel? model) {
  final HomeWidgetSettings? st = model?.widgetSettings;
  if (st == null) return null;
  return HomeChartCatalog.find(
    st.string(HomeSettingKey.chartModule, ''),
    st.string(HomeSettingKey.chartValues, ''),
  );
}

bool _isAr(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar';

List<Color> get _sliceColors => chartPalette();

/// One bar per series (at most [max]).
List<ChartData> _barsOf(HomeChartValue v, bool ar,
        {int max = 6, List<String>? months}) =>
    <ChartData>[
      for (int i = 0; i < v.series.take(max).length; i++)
        ChartData(
          // A value over time is labelled with the months, a snapshot with its parts.
          label: v.trend && months != null && i < months.length
              ? months[i]
              : v.series[i].label(ar),
          value: v.series[i].sample,
        ),
    ];

/// One slice per series, in the app's chart colours.
List<ChartData> _slicesOf(HomeChartValue v, bool ar) => <ChartData>[
      for (int i = 0; i < v.series.length; i++)
        ChartData(
          label: v.series[i].label(ar),
          value: v.series[i].sample,
          color: _sliceColors[i % _sliceColors.length],
        ),
    ];

/// The legend of a multi-series chart: one coloured entry per series.
List<ChartData> _legendOf(HomeChartValue v, bool ar, int max) => <ChartData>[
      for (int i = 0; i < v.series.take(max).length; i++)
        ChartData(
          label: v.series[i].label(ar),
          value: 0,
          color: _sliceColors[i % _sliceColors.length],
        ),
    ];

/// Sample buckets (W1…) for charts that stack / group the series over time.
/// Each bucket scales the series' sample figure.
List<double> _bucket(HomeChartValue v, int max, double factor) => <double>[
      for (final HomeChartSeries s in v.series.take(max)) s.sample * factor,
    ];

/// The card title: what the gear picked ("Services – Requests by status"), else
/// the card's own name (Moataz 24/10/2026: the title must follow the choice).
String _titleOf(BuildContext context, HomeComponentModel? model,
    HomeChartValue? v, String fallback,
    {int range = -1}) {
  // Arabic titles drop the tashkeel marks (the shadda in مكدّس / مجمّع read as a
  // stray underline; Moataz 24/10/2026).
  if (v == null) {
    return fallback.replaceAll(RegExp('[\u064B-\u0652]'), '');
  }
  final bool ar = _isAr(context);
  final String key =
      model?.widgetSettings.string(HomeSettingKey.chartModule, '') ?? '';
  final String name =
      range >= 0 && v.trend ? _perRange(v.title(ar), ar, range) : v.title(ar);
  for (final Modules m in Modules.values) {
    if (m.name == key) return '${m.getModuleName} – $name';
  }
  return name;
}

/// "Requests per month" → "Requests today / per day / per week" once a day
/// range is chosen (Moataz 24/10/2026); a title without "per month" is kept.
String _perRange(String title, bool ar, int range) {
  final String from = ar ? 'شهريًا' : 'per month';
  if (!title.contains(from)) return title;
  final String to = ar
      ? <String>['اليوم', 'يوميًا', 'أسبوعيًا'][range]
      : <String>['today', 'per day', 'per week'][range];
  return title.replaceAll(from, to);
}

// ── The 1D / 7D / 30D chips (24/10/2026) ─────────────────────────────────────
//
// -1 = no chip: the chart keeps its months (the gear's Period). 0 / 1 / 2 =
// 1D / 7D / 30D: a value over time is redrawn as today by 4-hour block, the
// last 7 days, the last 4 weeks. The month figure it starts from is a sample
// until the live counts are wired, like everything else in this file.

/// Sample figures are read as a 30-day total.
double _rangeShare(int range) => const <double>[0.1, 0.4, 1][range];

/// A snapshot figure for the chosen range (at least 1 while there is one).
double _scaled(double v, int range) => range < 0 || v <= 0
    ? v
    : (v * _rangeShare(range)).round().clamp(1, 1 << 30).toDouble();

/// The bars of a value over time for [range], from its latest month [m].
List<ChartData> _rangeBars(BuildContext context, double m, int range) {
  final String locale = Localizations.localeOf(context).toString();
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  late final List<String> labels;
  late final List<double> shares;
  switch (range) {
    case 0: // today, one bar per 4 hours (a working day peaks at midday)
      labels = <String>[
        for (int i = 0; i < 6; i++)
          DateFormat.j(locale).format(today.add(Duration(hours: i * 4))),
      ];
      shares = <double>[
        for (final double w in const <double>[0.4, 0.6, 1.9, 2.3, 2.1, 1.0])
          m / 24 * w
      ];
    case 1: // the last 7 days
      labels = <String>[
        for (int i = 6; i >= 0; i--)
          DateFormat.E(locale).format(today.subtract(Duration(days: i))),
      ];
      shares = <double>[for (int i = 0; i < 7; i++) m / 9 * _monthFactor(i)];
    default: // the last 4 weeks
      labels = <String>[
        for (int i = 3; i >= 0; i--)
          DateFormat.MMMd(locale).format(today.subtract(Duration(days: i * 7))),
      ];
      shares = <double>[for (int i = 0; i < 4; i++) m * 0.3 * _monthFactor(i)];
  }
  return <ChartData>[
    for (int i = 0; i < labels.length; i++)
      ChartData(label: labels[i], value: shares[i].roundToDouble()),
  ];
}

/// Plot sizes on a phone: the card is drawn at a different scale there, so the
/// same plot overflowed by 2–14 px; it takes 86% (Moataz 24/10/2026).
double _ph(BuildContext context, double v) =>
    kpIsPhoneLayout(context) ? v * 0.86 : v;

/// Realistic defaults shown before the gear picks anything (Moataz 24/10/2026:
/// "truly examples, not dummy data"): requests per month and per department,
/// split by the real request statuses.
List<String> _depts(bool ar) => ar
    ? <String>['الموارد البشرية', 'تقنية المعلومات', 'المالية']
    : <String>['HR', 'IT', 'Finance'];

List<ChartData> _statusLegend(S l, int n) => <ChartData>[
      // Status colours keep their meaning: green, red, orange, grey.
      ChartData(label: l.approved, value: 0, color: AppColors.statusApproved),
      ChartData(label: l.rejected, value: 0, color: AppColors.red),
      ChartData(label: l.pending, value: 0, color: AppColors.statusPending),
      ChartData(label: l.canceled, value: 0, color: AppColors.grey),
    ].take(n).toList();

List<ChartData> _monthly(BuildContext context, List<double> values) {
  final List<String> m = _lastMonths(context, values.length);
  return <ChartData>[
    for (int i = 0; i < values.length; i++)
      ChartData(label: m[i], value: values[i]),
  ];
}

/// The last [count] months as short names, oldest first — the x-axis of the
/// charts that stack or group a value over time. (They read "أ1 / أ2 / أ3"
/// before, which meant nothing; Moataz 23/10/2026.)
List<String> _lastMonths(BuildContext context, int count) {
  final String locale = Localizations.localeOf(context).toString();
  final DateTime now = DateTime.now();
  return <String>[
    for (int i = count - 1; i >= 0; i--)
      DateFormat.MMM(locale).format(DateTime(now.year, now.month - i)),
  ];
}

/// How many months a time chart shows: the gear's Period, 3 / 6 / 12 (6 when
/// none is chosen).
int _monthsOf(HomeComponentModel? model, {int fallback = 6}) {
  final int? n = int.tryParse(
      model?.widgetSettings.string(HomeSettingKey.chartMonths, '') ?? '');
  return n == 3 || n == 6 || n == 12 ? n! : fallback;
}

/// The width of a time chart's cell: always [base]. A longer range no longer
/// makes the card wider — the bars scroll sideways inside it (Owner
/// 24/10/2026: every chart keeps the same width).
double _timeWidth(HomeComponentModel? model, double base, {int fallback = 6}) =>
    base;

/// [base] (the last six months, oldest first) cut or extended to [n] months.
/// Longer ranges get earlier months before them; the figures are sample data
/// like the rest of the chart until the live counts are wired.
List<double> _extend(List<double> base, int n) {
  if (n <= base.length) return base.sublist(base.length - n);
  final int extra = n - base.length;
  return <double>[
    for (int i = 0; i < extra; i++)
      (base[(i * 5 + 2) % base.length] * (0.86 + 0.015 * (i % 4)))
          .roundToDouble(),
    ...base,
  ];
}

/// The bars of a time chart: [n] months of the picked value (or of [sample]
/// when nothing is picked); a snapshot value keeps its own parts.
List<ChartData> _timeBars(BuildContext context, HomeChartValue? v, bool ar,
    HomeComponentModel? model, List<double> sample,
    {int range = -1}) {
  final int n = _monthsOf(model);
  if (v == null) {
    return range >= 0
        ? _rangeBars(context, sample.last, range)
        : _monthly(context, _extend(sample, n));
  }
  if (!v.trend) {
    return <ChartData>[
      for (final ChartData b in _barsOf(v, ar))
        ChartData(label: b.label, value: _scaled(b.value, range)),
    ];
  }
  if (range >= 0) return _rangeBars(context, v.series.last.sample, range);
  return _monthly(context,
      _extend(<double>[for (final HomeChartSeries x in v.series) x.sample], n));
}

/// Month-to-month variation of the sample figures (any number of months).
double _monthFactor(int i) =>
    const <double>[1, 0.8, 1.2, 0.9, 1.1, 0.95][i % 6] * (1 + 0.04 * (i ~/ 6));

const List<List<double>> _stackedSample = <List<double>>[
  <double>[42, 6, 9],
  <double>[38, 8, 12],
  <double>[51, 5, 7],
];

const List<List<double>> _groupedSample = <List<double>>[
  <double>[42, 6, 9, 3],
  <double>[38, 8, 12, 4],
  <double>[51, 5, 7, 2],
];

/// The positions of the items (statuses, departments…) the gear chose to show;
/// none chosen = all of them.
List<int> _shownOf(HomeChartValue v, HomeComponentModel? model) {
  final List<int> picked = <int>[
    for (final String x in model?.widgetSettings
            .list(HomeSettingKey.chartSeries, const <String>[]) ??
        const <String>[])
      if (int.tryParse(x) != null &&
          int.parse(x) >= 0 &&
          int.parse(x) < v.series.length)
        int.parse(x),
  ]..sort();
  return picked.isEmpty
      ? <int>[for (int i = 0; i < v.series.length; i++) i]
      : picked;
}

/// One bar per shown item — all of them; the card scrolls when they do not fit.
List<ChartData> _barsShown(HomeChartValue v, bool ar, HomeComponentModel? m,
        {int range = -1}) =>
    <ChartData>[
      for (final int i in _shownOf(v, m))
        ChartData(
            label: v.series[i].label(ar),
            value: _scaled(v.series[i].sample, range)),
    ];

/// The `1D | 7D | 30D` chips. Tapping the chosen chip again clears it (back to
/// months).
class _RangeRow extends StatelessWidget {
  const _RangeRow({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final bool ar = _isAr(context);
    return ChartRangeTabs(
      ranges: ar
          ? <String>['1 ي', '7 أيام', '30 يوم']
          : <String>['1D', '7D', '30D'],
      selectedIndex: selected,
      onSelected: (int i) => onSelected(i == selected ? -1 : i),
    );
  }
}

/// Keeps a card's chosen range and hands it, with the chips, to [builder].
class _Ranged extends StatefulWidget {
  const _Ranged({required this.builder});

  final Widget Function(BuildContext context, int range, Widget chips) builder;

  @override
  State<_Ranged> createState() => _RangedState();
}

class _RangedState extends State<_Ranged> {
  int _range = -1;

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        _range,
        _RangeRow(
            selected: _range,
            onSelected: (int i) => setState(() => _range = i)),
      );
}

/// Locks a chart card to its Figma cell: exact width, exact 200 height.
class _ChartCell extends StatelessWidget {
  final double width;
  final Widget child;

  const _ChartCell({required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width.w, height: HomeCardMetrics.chartHeight, child: child);
  }
}

// ── Row 1 ────────────────────────────────────────────────────────────────────

/// Figma "Horizontal bar chart" (265). Replaces the old Services Offered card,
/// which carried a services-specific title the design does not use.
class HomeHorizontalBarChart extends StatelessWidget {
  const HomeHorizontalBarChart({super.key, this.model});

  /// The placed copy (carries the gear's Module / Values); null in a bare preview.
  final HomeComponentModel? model;

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final HomeChartValue? v = _picked(model);
    final bool ar = _isAr(context);
    return _Ranged(builder: (BuildContext context, int range, Widget chips) {
      return _ChartCell(
        width: kHomeChartWideWidth,
        child: HorizontalBarChartCard(
          title:
              _titleOf(context, model, v, l.horizontalBarChart, range: range),
          padding: _cardPadding,
          height: HomeCardMetrics.chartHeight,
          expandChild: true,
          // Wide card (3 columns): the range chips fit on the title row, so
          // four bars need no header row of their own.
          trailing: chips,
          // Figma's rows sit 28 apart with no x-axis underneath them.
          showAxis: false,
          rowSpacing: 0,
          labelFontSize: 10,
          barHeight: kpIsPhoneLayout(context) ? 3 : 6,
          bars: v != null
              ? _barsShown(v, ar, model, range: range)
              : <ChartData>[
                  for (int i = 0; i < 3; i++)
                    ChartData(
                        label: _depts(ar)[i],
                        value: _scaled(<double>[86, 64, 41][i], range)),
                ],
        ),
      );
    });
  }
}

/// Figma "Base Line Chart" (405): value bars over capacity tracks with a
/// dashed reference line and a count badge in the header.
class HomeBaseLineChart extends StatelessWidget {
  const HomeBaseLineChart({super.key, this.model});

  /// The placed copy (carries the gear's Module / Values); null in a bare preview.
  final HomeComponentModel? model;

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final HomeChartValue? v = _picked(model);
    final bool ar = _isAr(context);
    final int baseline =
        model?.widgetSettings.integer(HomeSettingKey.chartBaseline, 120) ?? 120;
    return _ChartCell(
      width: _timeWidth(model, kHomeChartWideWidth),
      child: BaseLineChartCard(
        title: _titleOf(context, model, v, l.baseLineChart),
        padding: _cardPadding,
        height: HomeCardMetrics.chartHeight,
        expandChild: true,
        // The badge and the dashed line both show the number typed in the gear.
        trailing: ChartCountBadge(text: '$baseline'),
        baseline: baseline.toDouble(),
        chartHeight: _ph(context, 96),
        barWidth: 10,
        bars: _timeBars(
            context, v, ar, model, <double>[80, 140, 110, 180, 150, 200]),
      ),
    );
  }
}

// ── Row 2 ────────────────────────────────────────────────────────────────────

/// Figma "Table chart" (405): the one Chart & Graph entry that is a table.
///
/// The range row sits in the header line rather than on its own row — at 200
/// tall there is only room for one of the two, and Figma's four data rows are
/// the part that carries the information.
class HomeTableChart extends StatelessWidget {
  const HomeTableChart({super.key, this.model});

  /// The placed copy (carries the gear's Module / Values); null in a bare preview.
  final HomeComponentModel? model;

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final HomeChartValue? v = _picked(model);
    final bool ar = _isAr(context);
    // Status tint follows the app's status colors so the column reads at a
    // glance rather than as four identical grey words.
    // The status is a coloured dot beside plain text (one text style).
    final List<TableChartCell> statuses = <TableChartCell>[
      TableChartCell(text: l.pending, dotColor: AppColors.statusPending),
      TableChartCell(text: l.approved, dotColor: AppColors.statusApproved),
      TableChartCell(text: l.rejected, dotColor: AppColors.red),
    ];

    return _Ranged(builder: (BuildContext context, int range, Widget chips) {
      return AnimatedSizeWrap(
        // Tables animate their size (rows added / removed / filtered).
        child: _ChartCell(
          width: kHomeChartWideWidth,
          child: TableChartCard(
            title: _titleOf(context, model, v, l.tableChart, range: range),
            padding: _cardPadding,
            height: HomeCardMetrics.chartHeight,
            expandChild: true,
            trailing: chips,
            rowSpacing: 1,
            columns: v != null
                ? <String>[ar ? 'القيمة' : 'Value', ar ? 'العدد' : 'Count']
                // Three columns, so a name fits on one line (was four, and
                // both people columns were cut with "…").
                : <String>[l.service, l.serviceRequester, l.status],
            columnFlex: v != null ? const <int>[3, 2] : const <int>[3, 5, 3],
            rows: v != null
                ? <TableChartRowData>[
                    for (final HomeChartSeries s in <HomeChartSeries>[
                      for (final int i in _shownOf(v, model)) v.series[i]
                    ])
                      TableChartRowData(cells: <TableChartCell>[
                        TableChartCell(text: s.label(ar)),
                        TableChartCell(
                            text: '${_scaled(s.sample, range).round()}'),
                      ]),
                  ]
                : <TableChartRowData>[
                    for (int i = 0; i < statuses.length; i++)
                      TableChartRowData(
                        cells: <TableChartCell>[
                          TableChartCell(
                              text: <String>[
                            ar ? 'إجازة سنوية' : 'Annual Leave',
                            ar ? 'طلب جهاز' : 'Laptop Request',
                            ar ? 'بطاقة دخول' : 'Access Card',
                          ][i]),
                          TableChartCell(
                              text: <String>[
                            ar ? 'أحمد عبد الرحمن' : 'Ahmed Abdelrahman',
                            ar ? 'سارة المطيري' : 'Sara Al-Mutairi',
                            ar ? 'خالد الحربي' : 'Khaled Al-Harbi',
                          ][i]),
                          statuses[i],
                        ],
                      ),
                  ],
          ),
        ),
      );
    });
  }
}

/// Figma "Bar chart" (265). Replaces the old Number Of Services card, which
/// carried a services-specific title the design does not use.
class HomeBarChart extends StatelessWidget {
  const HomeBarChart({super.key, this.model});

  /// The placed copy (carries the gear's Module / Values); null in a bare preview.
  final HomeComponentModel? model;

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final HomeChartValue? v = _picked(model);
    final bool ar = _isAr(context);
    return _ChartCell(
      width: _timeWidth(model, kHomeChartWidth),
      child: BarChartCard(
        title: _titleOf(context, model, v, l.barChart),
        padding: _cardPadding,
        height: HomeCardMetrics.chartHeight,
        expandChild: true,
        chartHeight: _ph(context, 97),
        barWidth: 12,
        labelRoom: 0.3,
        bars: _timeBars(
            context, v, ar, model, <double>[1180, 1420, 1310, 960, 1570, 1490]),
      ),
    );
  }
}

// ── Row 3 ────────────────────────────────────────────────────────────────────

/// Figma "Stacked Bar Chart" (265).
class HomeStackedBarChart extends StatelessWidget {
  const HomeStackedBarChart({super.key, this.model});

  /// The placed copy (carries the gear's Module / Values); null in a bare preview.
  final HomeComponentModel? model;

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final HomeChartValue? v = _picked(model);
    final bool ar = _isAr(context);
    final List<String> months =
        _lastMonths(context, _monthsOf(model, fallback: 3));
    return _ChartCell(
      width: _timeWidth(model, kHomeChartWideWidth, fallback: 3),
      child: StackedBarChartCard(
        title: _titleOf(context, model, v, l.stackedBarChart),
        padding: _cardPadding,
        height: HomeCardMetrics.chartHeight,
        expandChild: true,
        chartHeight: _ph(context, 76),
        barWidth: 34,
        series: v != null ? _legendOf(v, ar, 3) : _statusLegend(l, 3),
        bars: <StackedChartData>[
          for (int i = 0; i < months.length; i++)
            StackedChartData(
              label: months[i],
              values: v != null
                  ? _bucket(v, 3, _monthFactor(i))
                  : <double>[
                      for (final double x in _stackedSample[i % 3])
                        (x * _monthFactor(i)).roundToDouble()
                    ],
            ),
        ],
      ),
    );
  }
}

/// Figma "Grouped Bar Chart" (265) — built on the grouped card that already
/// existed in core (29); only the picker entry was missing.
class HomeGroupedBarChart extends StatelessWidget {
  const HomeGroupedBarChart({super.key, this.model});

  /// The placed copy (carries the gear's Module / Values); null in a bare preview.
  final HomeComponentModel? model;

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final HomeChartValue? v = _picked(model);
    final bool ar = _isAr(context);
    final List<String> months =
        _lastMonths(context, _monthsOf(model, fallback: 3));
    return _ChartCell(
      width: _timeWidth(model, kHomeChartWideWidth, fallback: 3),
      child: GroupedBarChartCard(
        title: _titleOf(context, model, v, l.groupedBarChart),
        padding: _cardPadding,
        height: HomeCardMetrics.chartHeight,
        expandChild: true,
        chartHeight: _ph(context, 68),
        barWidth: 9,
        series: v != null ? _legendOf(v, ar, 4) : _statusLegend(l, 4),
        groups: <GroupedBarData>[
          for (int i = 0; i < months.length; i++)
            GroupedBarData(
              label: months[i],
              values: v != null
                  ? _bucket(v, 4, _monthFactor(i))
                  : <double>[
                      for (final double x in _groupedSample[i % 3])
                        (x * _monthFactor(i)).roundToDouble()
                    ],
            ),
        ],
      ),
    );
  }
}

/// Figma "Pie Chart" (125) — the solid pie, distinct from the donut in row 5.
class HomePieChart extends StatelessWidget {
  const HomePieChart({super.key, this.model});

  /// The placed copy (carries the gear's Module / Values); null in a bare preview.
  final HomeComponentModel? model;

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final HomeChartValue? v = _picked(model);
    final bool ar = _isAr(context);
    return _ChartCell(
      width: kHomeChartWideWidth,
      child: PieChartCard(
        title: _titleOf(context, model, v, l.pieChart),
        padding: _cardPadding,
        height: HomeCardMetrics.chartHeight,
        // One grid column leaves ~105 of usable width inside the padding.
        chartSize: _ph(context, 90),
        legendBeside: true,
        sections: v != null
            ? _slicesOf(v, ar)
            : <ChartData>[
                ChartData(
                    label: l.approved,
                    value: 60,
                    color: AppColors.statusApproved),
                ChartData(label: l.rejected, value: 25, color: AppColors.red),
                ChartData(
                    label: l.pending,
                    value: 15,
                    color: AppColors.statusPending),
              ],
      ),
    );
  }
}

// ── Row 4 ────────────────────────────────────────────────────────────────────

/// Figma "Horizontal Stacked Bar Chart" (405).
class HomeHorizontalStackedBarChart extends StatelessWidget {
  const HomeHorizontalStackedBarChart({super.key, this.model});

  /// The placed copy (carries the gear's Module / Values); null in a bare preview.
  final HomeComponentModel? model;

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final HomeChartValue? v = _picked(model);
    final bool ar = _isAr(context);
    final List<int> shown = v != null ? _shownOf(v, model) : const <int>[];
    final List<ChartData> legend = v != null
        ? <ChartData>[
            for (final int i in shown)
              ChartData(
                label: v.series[i].label(ar),
                value: 0,
                color: _sliceColors[i % _sliceColors.length],
              ),
          ]
        : _statusLegend(l, 4);
    final List<String> months =
        _lastMonths(context, _monthsOf(model, fallback: 3));
    return _ChartCell(
      width: kHomeChartWideWidth,
      child: HorizontalStackedBarChartCard(
        title: _titleOf(context, model, v, l.horizontalStackedBarChart),
        padding: _cardPadding,
        height: HomeCardMetrics.chartHeight,
        expandChild: true,
        showLegend: false,
        // The colours sit under the title (they squeezed the title on the
        // title row — Moataz 24/10/2026).
        belowTitle: ChartLegendInline(items: legend, singleLine: true),
        // Figma's rows sit 30 apart.
        rowSpacing: 0,
        labelFontSize: 10,
        barHeight: 8,
        series: legend,
        bars: v != null
            ? <StackedChartData>[
                for (int i = 0; i < months.length; i++)
                  StackedChartData(label: months[i], values: <double>[
                    for (final int k in shown)
                      v.series[k].sample * _monthFactor(i),
                  ]),
              ]
            : <StackedChartData>[
                for (int i = 0; i < 3; i++)
                  StackedChartData(
                    label: _depts(ar)[i],
                    values: <List<double>>[
                      <double>[62, 9, 12, 3],
                      <double>[41, 7, 10, 2],
                      <double>[34, 5, 6, 1],
                    ][i],
                  ),
              ],
      ),
    );
  }
}

/// Figma "Radial Bar Chart" (265): concentric arcs with the legend on the left.
class HomeRadialBarChart extends StatelessWidget {
  const HomeRadialBarChart({super.key, this.model});

  /// The placed copy (carries the gear's Module / Values); null in a bare preview.
  final HomeComponentModel? model;

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final HomeChartValue? v = _picked(model);
    final bool ar = _isAr(context);
    return _ChartCell(
      width: kHomeChartWidth,
      child: RadialBarChartCard(
        title: _titleOf(context, model, v, l.radialBarChart),
        padding: _cardPadding,
        height: HomeCardMetrics.chartHeight,
        chartSize: _ph(context, 78),
        ringWidth: 7,
        ringGap: 4,
        bars: v != null
            ? <ChartData>[
                for (final ChartData b
                    in _barsOf(v, ar, max: kpIsPhoneLayout(context) ? 3 : 4))
                  ChartData(
                    label: b.label,
                    // The rings read 0–100: scale to the largest figure.
                    value: b.value /
                        v.series
                            .map((HomeChartSeries x) => x.sample)
                            .reduce((double a, double c) => a > c ? a : c) *
                        95,
                  ),
              ]
            : <ChartData>[
                ChartData(label: l.approved, value: 95),
                ChartData(label: l.pending, value: 78),
                ChartData(label: l.rejected, value: 64),
                ChartData(label: l.canceled, value: 47),
              ].take(kpIsPhoneLayout(context) ? 3 : 4).toList(),
      ),
    );
  }
}

/// Gauge Chart (405): up to three half-circle gauges, each showing what share
/// of the chosen value one item is (Approved 62 % of all requests…). The gear's
/// Module / Values pick the value and "Show items" picks which items get a
/// gauge (none picked = the first three).
class HomeGaugeChart extends StatelessWidget {
  const HomeGaugeChart({super.key, this.model});

  /// The placed copy (carries the gear's Module / Values); null in a bare preview.
  final HomeComponentModel? model;

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final HomeChartValue? v = _picked(model);
    final bool ar = _isAr(context);
    final List<(String, double)> gauges;
    if (v != null) {
      final double total = v.series
          .fold<double>(0, (double a, HomeChartSeries x) => a + x.sample);
      gauges = <(String, double)>[
        for (final int i in _shownOf(v, model).take(3))
          (v.series[i].label(ar), total <= 0 ? 0 : v.series[i].sample / total),
      ];
    } else {
      gauges = <(String, double)>[
        (l.approved, 0.62),
        (l.pending, 0.25),
        (l.rejected, 0.13),
      ];
    }
    return _ChartCell(
      width: kHomeChartWideWidth,
      child: ChartCard(
        title: _titleOf(context, model, v, ar ? 'مخطط المقياس' : 'Gauge Chart'),
        padding: _cardPadding,
        height: HomeCardMetrics.chartHeight,
        expandChild: true,
        child: Row(
          children: <Widget>[
            for (int i = 0; i < gauges.length; i++)
              Expanded(
                child: _GaugeDial(
                  label: gauges[i].$1,
                  share: gauges[i].$2.clamp(0.0, 1.0).toDouble(),
                  color: _sliceColors[i % _sliceColors.length],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One half-circle gauge with its percentage inside and its name under it.
class _GaugeDial extends StatelessWidget {
  const _GaugeDial({
    required this.label,
    required this.share,
    required this.color,
  });

  final String label;

  /// 0–1.
  final double share;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final double d =
                  (c.maxWidth - 16.w).clamp(0.0, c.maxHeight * 2).toDouble();
              return Center(
                child: SizedBox(
                  width: d,
                  height: d / 2 + 8.r,
                  child: CustomPaint(
                    painter: _GaugePainter(
                      share: share,
                      color: color,
                      track: AppColors.secondaryButton,
                      stroke: 10.r,
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        '${(share * 100).round()}%',
                        style: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.text),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 4.r),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: StyleText.fontSize12Weight400
              .copyWith(color: AppColors.secondaryText),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({
    required this.share,
    required this.color,
    required this.track,
    required this.stroke,
  });

  final double share;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(
        stroke / 2, stroke / 2, size.width - stroke, size.width - stroke);
    final Paint base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, base..color = track);
    if (share > 0) {
      canvas.drawArc(
          rect, math.pi, math.pi * share, false, base..color = color);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.share != share || old.color != color || old.track != track;
}

// ── Row 5 ────────────────────────────────────────────────────────────────────

/// The Bar chart: three grid columns (405), range buttons on the title row.
class HomeBarChartTrend extends StatelessWidget {
  const HomeBarChartTrend({super.key, this.model});

  /// The placed copy (carries the gear's Module / Values); null in a bare preview.
  final HomeComponentModel? model;

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final HomeChartValue? v = _picked(model);
    final bool ar = _isAr(context);
    return _Ranged(builder: (BuildContext context, int range, Widget chips) {
      return _ChartCell(
        width: _timeWidth(model, kHomeChartWideWidth),
        child: BarChartCard(
          title: _titleOf(context, model, v, l.barChart, range: range),
          padding: _cardPadding,
          height: HomeCardMetrics.chartHeight,
          expandChild: true,
          // Chips on the title row (wide card), so the plot keeps its height and
          // nothing overflows (1.2px before).
          trailing: chips,
          chartHeight: _ph(context, 97),
          barWidth: 18,
          labelRoom: 0.3,
          bars: _timeBars(context, v, ar, model,
              <double>[1180, 1420, 1310, 960, 1570, 1490],
              range: range),
        ),
      );
    });
  }
}

/// Figma "Donut Chart" (125) — built on the donut card that already existed in
/// core (27); only the picker entry was missing.
class HomeDonutChart extends StatelessWidget {
  const HomeDonutChart({super.key, this.model});

  /// The placed copy (carries the gear's Module / Values); null in a bare preview.
  final HomeComponentModel? model;

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final HomeChartValue? v = _picked(model);
    final bool ar = _isAr(context);
    return _ChartCell(
      width: kHomeChartWidth,
      child: DonutChartCard(
        title: _titleOf(context, model, v, l.donutChart),
        padding: _cardPadding,
        height: HomeCardMetrics.chartHeight,
        // One grid column: the ring shrinks and the legend stacks underneath,
        // which is also how Figma draws this card.
        chartSize: _ph(context, 90),
        // Legend names get the room (and two lines) instead of "…".
        ringAtEnd: true,
        legendMaxLines: 2,
        ringWidth: 16,
        showLegend: true,
        legendBelow: false,
        showPercentages: false,
        sections: v != null
            ? _slicesOf(v, ar)
            : <ChartData>[
                ChartData(
                    label: l.approved,
                    value: 60,
                    color: AppColors.statusApproved),
                ChartData(label: l.rejected, value: 25, color: AppColors.red),
                ChartData(
                    label: l.pending,
                    value: 15,
                    color: AppColors.statusPending),
              ],
      ),
    );
  }
}

/// Line chart — a trend over time (last six months). With a gear choice the
/// line is that value set's total, drifting month by month; before that it
/// shows requests per month.
class HomeLineChart extends StatelessWidget {
  const HomeLineChart({super.key, this.model});

  final HomeComponentModel? model;

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final HomeChartValue? v = _picked(model);
    final double total = v == null
        ? 160
        : v.series
            .fold<double>(0, (double a, HomeChartSeries x) => a + x.sample);
    final List<double> shape = <double>[.62, .74, .7, .88, .82, 1.0];
    // A value over time is drawn as it is; anything else drifts as before.
    final List<double> values = v != null && v.trend
        ? <double>[for (final HomeChartSeries x in v.series) x.sample]
        : <double>[for (final double f in shape) (total * f).roundToDouble()];
    return _Ranged(builder: (BuildContext context, int range, Widget chips) {
      return _ChartCell(
        width: _timeWidth(model, kHomeChartWideWidth),
        child: LineChartCard(
          title: _titleOf(context, model, v, l.lineChart, range: range),
          padding: _cardPadding,
          height: HomeCardMetrics.chartHeight,
          expandChild: true,
          trailing: chips,
          points: range >= 0
              ? _rangeBars(context, values.last, range)
              : _monthly(context, _extend(values, _monthsOf(model))),
        ),
      );
    });
  }
}

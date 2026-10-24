/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_widget_settings_schema.dart
/// Purpose: Declares the fields, units, limits and defaults of every home
///          widget's settings dialog (D-242) — `HomeWidgetSettingsSchema.of`.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// The spec is WORK/1. Knowticed Plus/_working/kp-settings/
/// WIDGET_SETTINGS_PREVIEW.html. A widget has a gear only when it has an entry
/// here AND its card reads the values — a gear that saves values nothing reads
/// would be a lie, so the rest of the widgets are added as they are wired.
///
/// DEFAULTS: where the preview's default differs from what the card shows
/// today (Requested Service statuses, To-Do tasks order), the default here is
/// TODAY's behaviour — D-242 (4): "nothing changes until a user edits it".
library;

import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_widget_settings.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/home_components.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// One choice in a select / multi-select field.
class HomeSettingOption {
  const HomeSettingOption(this.value, this.label);

  final String value;
  final String Function(S s) label;
}

/// Where a select field gets choices that depend on live data.
enum HomeOptionSource {
  none,
  servicesDepartments,

  /// The signed-in employee's Messages groups (Group Messages gear).
  messagingGroups,

  /// The company's employees, the signed-in one excluded (Employee Messages).
  messagingPeople,

  /// The forms the employee can follow (Forms Submission gear).
  forms,
}

enum HomeSettingKind { choice, period, number, multi, toggle, chartData }

/// One row of the settings dialog.
class HomeSettingField {
  const HomeSettingField._({
    required this.kind,
    required this.key,
    required this.label,
    this.options = const <HomeSettingOption>[],
    this.defaultString = '',
    this.defaultNumber = 0,
    this.defaultList = const <String>[],
    this.defaultBool = false,
    this.min = 0,
    this.max = 0,
    this.unit,
    this.source = HomeOptionSource.none,
    this.minSelected = 1,
    this.maxSelected = 0,
  });

  /// A single choice from [options].
  const HomeSettingField.choice({
    required String key,
    required String Function(S s) label,
    required List<HomeSettingOption> options,
    required String defaultValue,
    HomeOptionSource source = HomeOptionSource.none,
  }) : this._(
          kind: HomeSettingKind.choice,
          key: key,
          label: label,
          options: options,
          defaultString: defaultValue,
          source: source,
        );

  /// Period choices; "Custom range" adds two date fields.
  const HomeSettingField.period({
    required List<HomeSettingOption> options,
    required String defaultValue,
  }) : this._(
          kind: HomeSettingKind.period,
          key: HomeSettingKey.period,
          label: _periodLabel,
          options: options,
          defaultString: defaultValue,
        );

  /// A whole number with a unit and limits.
  const HomeSettingField.number({
    required String key,
    required String Function(S s) label,
    required String Function(S s) unit,
    required int min,
    required int max,
    required int defaultValue,
  }) : this._(
          kind: HomeSettingKind.number,
          key: key,
          label: label,
          unit: unit,
          min: min,
          max: max,
          defaultNumber: defaultValue,
        );

  /// Several of [options]; at least [minSelected] stay on, at most
  /// [maxSelected] (0 = no limit). A [source] loads the options live.
  const HomeSettingField.multi({
    required String key,
    required String Function(S s) label,
    required List<HomeSettingOption> options,
    List<String>? defaultValues,
    int minSelected = 1,
    int maxSelected = 0,
    HomeOptionSource source = HomeOptionSource.none,
  }) : this._(
          kind: HomeSettingKind.multi,
          key: key,
          label: label,
          options: options,
          defaultList: defaultValues ?? const <String>[],
          minSelected: minSelected,
          maxSelected: maxSelected,
          source: source,
        );

  /// An on / off switch.
  const HomeSettingField.toggle({
    required String key,
    required String Function(S s) label,
    required bool defaultValue,
  }) : this._(
          kind: HomeSettingKind.toggle,
          key: key,
          label: label,
          defaultBool: defaultValue,
        );

  /// Chart & Graph gear: Module, then that module's Values, then a Preview.
  /// Stored as two keys ([HomeSettingKey.chartModule] / [chartValues]); this
  /// field's own [key] is only its handle.
  const HomeSettingField.chartData()
      : this._(
          kind: HomeSettingKind.chartData,
          key: 'Chart_Data',
          label: _chartLabel,
        );

  final HomeSettingKind kind;
  final String key;
  final String Function(S s) label;
  final List<HomeSettingOption> options;
  final String defaultString;
  final int defaultNumber;
  final List<String> defaultList;
  final bool defaultBool;
  final int min;
  final int max;
  final String Function(S s)? unit;
  final HomeOptionSource source;
  final int minSelected;

  /// Most options a multi-select may keep; 0 = no limit.
  final int maxSelected;

  /// The default of a multi field: every option unless told otherwise.
  List<String> get defaultSelection => defaultList.isEmpty
      ? options.map((HomeSettingOption o) => o.value).toList()
      : defaultList;

  static String _periodLabel(S s) => s.hwsPeriod;
  static String _chartLabel(S s) => s.chartGraph;
}

/// All fields of one widget, in dialog order.
class HomeWidgetSettingsSchema {
  const HomeWidgetSettingsSchema(this.fields);

  final List<HomeSettingField> fields;

  /// True when the widget has a settings dialog.
  static bool has(HomeComponents component) => of(component) != null;

  /// Function Name: [of]
  ///
  /// Purpose: The schema for [component], or null when it has no gear yet.
  static HomeWidgetSettingsSchema? of(HomeComponents component) =>
      _all[component];

  // ── Shared choices ───────────────────────────────────────────────────────
  static final List<HomeSettingOption> _periodAll = <HomeSettingOption>[
    HomeSettingOption(HomeWidgetPeriod.today.key, (S s) => s.today),
    HomeSettingOption(HomeWidgetPeriod.thisWeek.key, (S s) => s.thisWeek),
    HomeSettingOption(HomeWidgetPeriod.thisMonth.key, (S s) => s.thisMonth),
    HomeSettingOption(HomeWidgetPeriod.last30Days.key, (S s) => s.last30Days),
    HomeSettingOption(HomeWidgetPeriod.thisYear.key, (S s) => s.hwsThisYear),
    HomeSettingOption(HomeWidgetPeriod.custom.key, (S s) => s.hwsCustomRange),
    HomeSettingOption(HomeWidgetPeriod.allTime.key, (S s) => s.hwsAllTime),
  ];

  static final HomeSettingField _period = HomeSettingField.period(
    options: _periodAll,
    defaultValue: HomeWidgetPeriod.allTime.key,
  );

  static final HomeSettingField _scope = HomeSettingField.choice(
    key: HomeSettingKey.scope,
    label: (S s) => s.hwsShow,
    options: <HomeSettingOption>[
      HomeSettingOption(HomeWidgetScope.mine.key, (S s) => s.myRequests),
      HomeSettingOption(
          HomeWidgetScope.department.key, (S s) => s.hwsMyDepartment),
      HomeSettingOption(HomeWidgetScope.all.key, (S s) => s.hwsAllRequests),
    ],
    defaultValue: HomeWidgetScope.all.key,
  );

  static HomeSettingField _rows(int def, int max) => HomeSettingField.number(
        key: HomeSettingKey.rows,
        label: (S s) => s.hwsRequestsShown,
        unit: (S s) => s.hwsUnitRows,
        min: 1,
        max: max,
        defaultValue: def,
      );

  /// The due-date windows the To-Do cards offer.
  static final List<HomeSettingOption> _dueOptions = <HomeSettingOption>[
    HomeSettingOption(HomeWidgetPeriod.allTime.key, (S s) => s.hwsAllTime),
    HomeSettingOption(HomeWidgetPeriod.today.key, (S s) => s.today),
    HomeSettingOption(HomeWidgetPeriod.thisWeek.key, (S s) => s.thisWeek),
    HomeSettingOption(HomeWidgetPeriod.thisMonth.key, (S s) => s.thisMonth),
  ];

  static final HomeSettingField _due = HomeSettingField.choice(
    key: HomeSettingKey.due,
    label: (S s) => s.hwsDue,
    options: _dueOptions,
    defaultValue: HomeWidgetPeriod.allTime.key,
  );

  // ── Services status keys (ServiceStatusKey literals) ─────────────────────
  static final HomeSettingOption _stPending =
      HomeSettingOption('pending', (S s) => s.pending);
  static final HomeSettingOption _stInProgress =
      HomeSettingOption('inprogress', (S s) => s.Inprogress);
  static final HomeSettingOption _stApproved =
      HomeSettingOption('approved', (S s) => s.approved);
  static final HomeSettingOption _stRejected =
      HomeSettingOption('rejected', (S s) => s.rejected);
  static final HomeSettingOption _stDone =
      HomeSettingOption('done', (S s) => s.done);
  static final HomeSettingOption _stCanceled =
      HomeSettingOption('cancel', (S s) => s.canceled);
  static final HomeSettingOption _stBreached =
      HomeSettingOption('branchsla', (S s) => s.BreachedSLA);

  /// "Buttons shown" — the one multi-select every button card's gear uses. A
  /// button the role has no permission for is dropped from the choices by the
  /// dialog (`HomeButtonAccess`), and never draws on the card.
  static HomeSettingField _buttons(List<HomeSettingOption> options) =>
      HomeSettingField.multi(
        key: HomeSettingKey.buttons,
        label: (S s) => s.hwsButtonsShown,
        options: options,
      );

  // A getter, not a `static final`: a static final is built once and a hot
  // reload never rebuilds it, so a newly added gear stayed hidden until a
  // full restart (21/10/2026). The map is small; building it per lookup is
  // cheap.
  static Map<HomeComponents, HomeWidgetSettingsSchema> get _all =>
      <HomeComponents, HomeWidgetSettingsSchema>{
        // ── Messages (Owner 21/10/2026: the gear picks WHAT the card shows) ────
        HomeComponents.groupMessages: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            // Picked in the Groups picker (home_picker_dialog.dart), 1–4;
            // nothing stored = the newest group (today's behaviour).
            HomeSettingField.multi(
              key: HomeSettingKey.groups,
              label: (S s) => s.groups,
              options: const <HomeSettingOption>[],
              defaultValues: const <String>[],
              minSelected: 1,
              maxSelected: 4,
              source: HomeOptionSource.messagingGroups,
            ),
          ],
        ),
        // ── Forms (Owner 21/10/2026: the gear picks WHICH form's percentage) ──
        HomeComponents.formsSubmission: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            // One form, picked in the picker; nothing stored = the latest
            // published form (today's behaviour).
            HomeSettingField.multi(
              key: HomeSettingKey.form,
              label: (S s) => s.form,
              options: const <HomeSettingOption>[],
              defaultValues: const <String>[],
              minSelected: 1,
              maxSelected: 1,
              source: HomeOptionSource.forms,
            ),
          ],
        ),
        HomeComponents.employeeMessages: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            HomeSettingField.multi(
              key: HomeSettingKey.people,
              label: (S s) => s.employees,
              // Picked in the Employees picker, 1–4; nothing stored = the 4
              // most recent chats (today's behaviour).
              options: const <HomeSettingOption>[],
              defaultValues: const <String>[],
              minSelected: 1,
              maxSelected: 4,
              source: HomeOptionSource.messagingPeople,
            ),
          ],
        ),
        // ── Services ───────────────────────────────────────────────────────────
        HomeComponents.requestedService: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            _scope,
            HomeSettingField.multi(
              key: HomeSettingKey.statuses,
              label: (S s) => s.hwsStatuses,
              options: <HomeSettingOption>[
                _stPending,
                _stInProgress,
                _stApproved,
                _stRejected,
                _stDone,
                _stCanceled,
              ],
            ),
            _rows(2, 3),
          ],
        ),
        HomeComponents.serviceActions: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            _buttons(<HomeSettingOption>[
              HomeSettingOption(
                  HomeButtonKey.createService, (S s) => s.createService),
              HomeSettingOption(
                  HomeButtonKey.myRequests, (S s) => s.myRequests),
              HomeSettingOption(
                  HomeButtonKey.viewApproval, (S s) => s.viewApproval),
            ]),
          ],
        ),
        HomeComponents.formActions: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            _buttons(<HomeSettingOption>[
              HomeSettingOption(
                  HomeButtonKey.createForm, (S s) => s.createForm),
              HomeSettingOption(
                  HomeButtonKey.viewDraftForm, (S s) => s.viewDraftForm),
              HomeSettingOption(HomeButtonKey.viewRequestedForm,
                  (S s) => s.viewRequestedForm),
            ]),
          ],
        ),
        HomeComponents.knowledgeHubActions: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            _buttons(<HomeSettingOption>[
              HomeSettingOption(HomeButtonKey.createHub, (S s) => s.createHub),
              HomeSettingOption(
                  HomeButtonKey.viewDashboard, (S s) => s.viewDashboard),
            ]),
          ],
        ),
        HomeComponents.scheduleMessages: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            _buttons(<HomeSettingOption>[
              HomeSettingOption(HomeButtonKey.forGroup, (S s) => s.forGroup),
              HomeSettingOption(
                  HomeButtonKey.forDirectMessage, (S s) => s.forDirectMessage),
            ]),
          ],
        ),
        HomeComponents.inventoryActions: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            _buttons(<HomeSettingOption>[
              HomeSettingOption(
                  HomeButtonKey.addProduct, (S s) => s.addProduct),
              HomeSettingOption(HomeButtonKey.order, (S s) => s.order),
              HomeSettingOption(HomeButtonKey.approvals, (S s) => s.approvals),
            ]),
          ],
        ),
        HomeComponents.inventoryNewRequest: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            _buttons(<HomeSettingOption>[
              HomeSettingOption(HomeButtonKey.asset, (S s) => s.asset),
              HomeSettingOption(
                  HomeButtonKey.consumable, (S s) => s.consumable),
              HomeSettingOption(HomeButtonKey.myRequest, (S s) => s.myRequest),
            ]),
          ],
        ),
        HomeComponents.timeTrackerQuickRequests: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            _buttons(<HomeSettingOption>[
              HomeSettingOption(
                  HomeButtonKey.checkInOut, (S s) => s.checkInOut),
              HomeSettingOption(
                  HomeButtonKey.requests, (S s) => s.timeTrackerTabRequests),
            ]),
          ],
        ),
        HomeComponents.timeTrackerQuickApprovals: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            _buttons(<HomeSettingOption>[
              HomeSettingOption(
                  HomeButtonKey.checkInOut, (S s) => s.checkInOut),
              HomeSettingOption(HomeButtonKey.timeTrackerApprovals,
                  (S s) => s.timeTrackerTabApprovals),
            ]),
          ],
        ),
        HomeComponents.serviceStatus: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            _period,
            _scope,
            HomeSettingField.multi(
              key: HomeSettingKey.statuses,
              label: (S s) => s.hwsStatusesShown,
              minSelected: 2,
              options: <HomeSettingOption>[
                _stBreached,
                _stCanceled,
                _stRejected,
                _stInProgress,
                _stApproved,
                _stDone,
              ],
            ),
          ],
        ),
        HomeComponents.myServices: HomeWidgetSettingsSchema(
          <HomeSettingField>[_period, _scope],
        ),
        HomeComponents.nearBreachedSLA: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            HomeSettingField.number(
              key: HomeSettingKey.warnPercent,
              label: (S s) => s.hwsWarnWhenSla,
              unit: (S s) => s.hwsUnitPercent,
              min: 1,
              max: 100,
              defaultValue: 80,
            ),
            HomeSettingField.toggle(
              key: HomeSettingKey.includeBreached,
              label: (S s) => s.hwsAlsoListBreached,
              defaultValue: true,
            ),
            HomeSettingField.choice(
              key: HomeSettingKey.department,
              label: (S s) => s.department,
              options: <HomeSettingOption>[
                HomeSettingOption('all', (S s) => s.hwsAllDepartments),
              ],
              defaultValue: 'all',
              source: HomeOptionSource.servicesDepartments,
            ),
            _rows(2, 3),
          ],
        ),
        HomeComponents.serviceOverview: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            HomeSettingField.multi(
              key: HomeSettingKey.tiles,
              label: (S s) => s.hwsTilesShown,
              minSelected: 2,
              options: <HomeSettingOption>[
                HomeSettingOption('services', (S s) => s.totalServices),
                HomeSettingOption('requests', (S s) => s.totalRequests),
                HomeSettingOption('sla', (S s) => s.totalSLA),
                HomeSettingOption('done', (S s) => s.totalDone),
              ],
            ),
            _period,
            _scope,
          ],
        ),
        HomeComponents.myRequestServices: HomeWidgetSettingsSchema(
          <HomeSettingField>[_period],
        ),

        // ── To-Do ──────────────────────────────────────────────────────────────
        HomeComponents.myTodoList: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            _due,
            HomeSettingField.multi(
              key: HomeSettingKey.counts,
              label: (S s) => s.hwsCountsShown,
              options: <HomeSettingOption>[
                HomeSettingOption('done', (S s) => s.done),
                HomeSettingOption('overdue', (S s) => s.overdue),
                HomeSettingOption('scheduled', (S s) => s.scheduled),
              ],
            ),
          ],
        ),
        HomeComponents.myTodoStatus: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            HomeSettingField.choice(
              key: HomeSettingKey.countOnly,
              label: (S s) => s.hwsCount,
              options: <HomeSettingOption>[
                HomeSettingOption('all', (S s) => s.hwsAllTasks),
                HomeSettingOption('open', (S s) => s.hwsOpenTasksOnly),
              ],
              defaultValue: 'all',
            ),
            _due,
            HomeSettingField.multi(
              key: HomeSettingKey.priorities,
              label: (S s) => s.hwsPrioritiesShown,
              options: <HomeSettingOption>[
                HomeSettingOption('high', (S s) => s.high),
                HomeSettingOption('medium', (S s) => s.medium),
                HomeSettingOption('low', (S s) => s.low),
              ],
            ),
          ],
        ),
        HomeComponents.myTodoBox: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            HomeSettingField.number(
              key: HomeSettingKey.rows,
              label: (S s) => s.hwsTasksShown,
              unit: (S s) => s.hwsUnitTasks,
              min: 1,
              max: 6,
              defaultValue: 4,
            ),
            HomeSettingField.choice(
              key: HomeSettingKey.show,
              label: (S s) => s.hwsShow,
              options: <HomeSettingOption>[
                HomeSettingOption('open', (S s) => s.hwsOpenTasks),
                HomeSettingOption('overdue', (S s) => s.overdue),
                HomeSettingOption('due_today', (S s) => s.hwsDueToday),
                HomeSettingOption('due_week', (S s) => s.hwsDueThisWeek),
              ],
              defaultValue: 'open',
            ),
            HomeSettingField.choice(
              key: HomeSettingKey.order,
              label: (S s) => s.hwsOrder,
              options: <HomeSettingOption>[
                HomeSettingOption('newest', (S s) => s.hwsNewest),
                HomeSettingOption('due_date', (S s) => s.hwsDueDate),
                HomeSettingOption('priority', (S s) => s.hwsPriority),
              ],
              defaultValue: 'newest',
            ),
          ],
        ),
        // Every Chart & Graph card has the same gear (23/10/2026).
        HomeComponents.horizontalBarChart: const HomeWidgetSettingsSchema(
            <HomeSettingField>[HomeSettingField.chartData()]),
        HomeComponents.baseLineChart: HomeWidgetSettingsSchema(
          <HomeSettingField>[
            const HomeSettingField.chartData(),
            // The user types the baseline; the chart draws it as the dashed line
            // and the badge shows it.
            HomeSettingField.number(
              key: HomeSettingKey.chartBaseline,
              label: (S s) => s.baseLineChart,
              unit: (S s) => '',
              min: 1,
              max: 1000000,
              defaultValue: 120,
            ),
          ],
        ),
        HomeComponents.tableChart: const HomeWidgetSettingsSchema(
            <HomeSettingField>[HomeSettingField.chartData()]),
        HomeComponents.barChart: const HomeWidgetSettingsSchema(
            <HomeSettingField>[HomeSettingField.chartData()]),
        HomeComponents.stackedBarChart: const HomeWidgetSettingsSchema(
            <HomeSettingField>[HomeSettingField.chartData()]),
        HomeComponents.groupedBarChart: const HomeWidgetSettingsSchema(
            <HomeSettingField>[HomeSettingField.chartData()]),
        HomeComponents.pieChart: const HomeWidgetSettingsSchema(
            <HomeSettingField>[HomeSettingField.chartData()]),
        HomeComponents.horizontalStackedBarChart:
            const HomeWidgetSettingsSchema(
                <HomeSettingField>[HomeSettingField.chartData()]),
        HomeComponents.radialBarChart: const HomeWidgetSettingsSchema(
            <HomeSettingField>[HomeSettingField.chartData()]),
        HomeComponents.barTrendChart: const HomeWidgetSettingsSchema(
            <HomeSettingField>[HomeSettingField.chartData()]),
        HomeComponents.lineChart: const HomeWidgetSettingsSchema(
            <HomeSettingField>[HomeSettingField.chartData()]),
        HomeComponents.donutChart: const HomeWidgetSettingsSchema(
            <HomeSettingField>[HomeSettingField.chartData()]),
        HomeComponents.gaugeChart: const HomeWidgetSettingsSchema(
            <HomeSettingField>[HomeSettingField.chartData()]),
      };
}

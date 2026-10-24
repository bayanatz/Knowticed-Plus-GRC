/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_widget_settings_dialog.dart
/// Purpose: The "[Widget name] Settings" dialog every home widget's gear opens
///          (D-242) — built from the widget's `HomeWidgetSettingsSchema`
///          inside the shared `CustomSettingsDialogFrame`.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// Returns the map to store on the placed copy, or null when the user
/// discards. Save is checked first (`HomeWidgetSettingsCubit.validate`): a
/// wrong field gets its red message and the dialog stays open.
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/settings/home_chart_values.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/dialogs/custom_settings_dialog_frame.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/inputs/default_switch_button.dart';
import 'package:knowticed_plus/core/custom/layout/custom_field_pair.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/helpers/home_button_access.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/helpers/home_scope_access.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_widget_settings.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/home_components.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/settings/home_widget_settings_schema.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_widget_settings_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/services_home_stats_cubit.dart'; // [module:services]
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_extra_widgets.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/widget_settings/home_picker_dialog.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/form_builder/forms_submission.dart'; // [module:form_builder]
import 'package:knowticed_plus/generated/l10n.dart';

/// Function Name: [showHomeWidgetSettingsDialog]
///
/// Purpose: Open the settings dialog of the widget in [model].
///
/// Returns: the new settings map (possibly empty = "all defaults"), or null
/// when the user discarded.
Future<Map<String, dynamic>?> showHomeWidgetSettingsDialog(
  BuildContext context, {
  required HomeComponentModel model,
}) async {
  final HomeWidgetSettingsSchema? schema =
      HomeWidgetSettingsSchema.of(model.component);
  if (schema == null) return null;

  final S s = S.of(context);
  final bool isArabic = context.isArabic;
  final HomeWidgetSettings stored = model.widgetSettings;

  // Owner 21/10/2026: Group / Employee Messages pick 1–4 groups or people
  // in the Figma picker (3948:122924), not in the settings form.
  if (schema.fields.length == 1 &&
      (schema.fields.single.source == HomeOptionSource.messagingGroups ||
          schema.fields.single.source == HomeOptionSource.messagingPeople ||
          schema.fields.single.source == HomeOptionSource.forms)) {
    final HomeSettingField f = schema.fields.single;
    final bool groups = f.source == HomeOptionSource.messagingGroups;
    final bool forms = f.source == HomeOptionSource.forms;
    final HomePickerCacheEntry cache = forms
        ? HomePickerCache.forms
        : (isArabic ? HomePickerCache.groupsAr : HomePickerCache.groupsEn);
    final List<HomePickItem> items = forms
        ? await _withLoader(homeFormItems, cache.fresh != null) // [module:form_builder|? <HomePickItem>[]]
        : groups
            ? await _withLoader(
                () => homeMessagingGroupItems(isArabic), cache.fresh != null)
            : homeMessagingPeopleItems(context);
    if (!context.mounted) return null;
    final List<String>? picked = await showHomePickerDialog(
      context,
      title: forms ? s.forms : (groups ? s.groups : s.employees),
      icon: forms ? kHomeFormIcon : kHomeGroupIcon, // [module:form_builder|icon: kHomeGroupIcon,]
      items: items,
      initial: stored.list(f.key, const <String>[]),
      min: f.minSelected,
      max: f.maxSelected,
    );
    return picked == null ? null : <String, dynamic>{f.key: picked};
  }

  // Choices that depend on live data.
  final Map<String, List<HomeSettingOption>> dynamicOptions =
      <String, List<HomeSettingOption>>{};
  for (final HomeSettingField f in schema.fields) {
    if (!context.mounted) return null;
    // Owner 24/10/2026: a button the role has no permission for is not offered.
    if (f.key == HomeSettingKey.buttons) {
      dynamicOptions[f.key] = <HomeSettingOption>[
        for (final HomeSettingOption o in f.options)
          if (HomeButtonAccess.allowed(model.component, o.value)) o,
      ];
    }
    // [module:services]
    if (f.source == HomeOptionSource.servicesDepartments) {
      final ServicesHomeStatsCubit stats =
          context.read<ServicesHomeStatsCubit>();
      dynamicOptions[f.key] = <HomeSettingOption>[
        f.options.first,
        for (final ServiceDepartmentOption d in stats.departmentOptions)
          HomeSettingOption(d.id, (S _) => d.name(isArabic)),
      ];
    }
    // [/module:services]
  }
  if (!context.mounted) return null;

  // Scope: only what the role allows, plus whatever the copy already holds.
  final Set<HomeWidgetScope> allowedScopes = HomeScopeAccess.servicesAllowed();
  final HomeWidgetScope held = stored.scope();

  return showCustomSettingsDialog<Map<String, dynamic>>(
    context: context,
    child: BlocProvider<HomeWidgetSettingsCubit>(
      create: (_) => HomeWidgetSettingsCubit(
        schema: schema,
        stored: model.settings,
      ),
      child: _SettingsBody(
        title: s.hwsTitle(
            homeWidgetSettingsName(s, model.component, isArabic: isArabic)),
        model: model,
        schema: schema,
        dynamicOptions: dynamicOptions,
        allowedScopes: <HomeWidgetScope>{...allowedScopes, held},
      ),
    ),
  );
}

/// Runs [load]; when the list is not remembered yet ([cached] false) a loader
/// shows over the page meanwhile, so the gear never looks frozen. A failed
/// load gives an empty list, as before.
Future<List<HomePickItem>> _withLoader(
    Future<List<HomePickItem>> Function() load, bool cached) async {
  if (cached) return load();
  showLoadingIndicator();
  await Future<void>.delayed(Duration.zero);
  try {
    return await load();
  } catch (_) {
    return const <HomePickItem>[];
  } finally {
    hideLoadingIndicator();
  }
}

/// Loads the Forms and Group Messages lists ahead of the first gear tap, so
/// the dialog opens with them already filled. Safe to call often.
void warmHomePickerLists({required bool isArabic}) {
  // [module:form_builder]
  if (HomePickerCache.forms.fresh == null) {
    homeFormItems().catchError((Object _) => const <HomePickItem>[]);
  }
  // [/module:form_builder]
  final HomePickerCacheEntry groups =
      isArabic ? HomePickerCache.groupsAr : HomePickerCache.groupsEn;
  if (groups.fresh == null) {
    homeMessagingGroupItems(isArabic)
        .catchError((Object _) => const <HomePickItem>[]);
  }
}

/// The modules the chart gear offers: those with chart values AND that this
/// employee's role includes (the same rule as the widget picker). When the role
/// cannot be read, every module with values is offered.
List<Modules> _chartModulesFor(BuildContext context, HomeComponents component) {
  final List<Modules> all = HomeChartCatalog.modulesFor(component);
  if (!Get.isRegistered<AppDrawerCubit>()) return all;
  final List<Modules> allowed = Get.find<AppDrawerCubit>().allowedDrawerModules;
  if (allowed.isEmpty) return all;
  return all.where(allowed.contains).toList();
}

/// The widget's name as the dialog title writes it.
String homeWidgetSettingsName(S s, HomeComponents component,
    {bool isArabic = false}) {
  switch (component) {
    case HomeComponents.requestedService:
      return s.requestedService;
    case HomeComponents.serviceActions:
      // The card's own title (it read "Service Actions" over a "Service"
      // card). Names stay distinct only where two cards share a title.
      return s.service;
    case HomeComponents.formActions:
      return s.forms;
    case HomeComponents.knowledgeHubActions:
      return s.knowledge_hub;
    case HomeComponents.scheduleMessages:
      return s.scheduleMessage;
    case HomeComponents.inventoryActions:
      return s.inventory;
    case HomeComponents.inventoryNewRequest:
      return s.newRequest;
    case HomeComponents.timeTrackerQuickRequests:
    case HomeComponents.timeTrackerQuickApprovals:
      return s.tracker;
    case HomeComponents.serviceStatus:
      return s.servicesStatus;
    case HomeComponents.myServices:
      return s.myServices;
    case HomeComponents.nearBreachedSLA:
      return s.nearBreachedSLA;
    case HomeComponents.serviceOverview:
      return s.hwsNameServiceOverview;
    case HomeComponents.myRequestServices:
      return s.myRequest;
    case HomeComponents.myTodoList:
      return s.hwsNameTodoCounts;
    case HomeComponents.myTodoStatus:
      return s.hwsNameTodoPriorities;
    case HomeComponents.myTodoBox:
      return s.hwsNameTodoTasks;
    case HomeComponents.groupMessages:
      return s.groupMessages;
    case HomeComponents.formsSubmission:
      return s.formsSubmission;
    case HomeComponents.employeeMessages:
      return s.employeeMessages;
    default:
      // Every Chart & Graph card: "Chart Settings" (Figma H11 / H12).
      if (component.isChart) return isArabic ? 'المخطط' : 'Chart';
      return component.databaseName.replaceAll('_', ' ');
  }
}

class _SettingsBody extends StatefulWidget {
  const _SettingsBody({
    required this.title,
    required this.model,
    required this.schema,
    required this.dynamicOptions,
    required this.allowedScopes,
  });

  final String title;

  /// The placed copy being edited — the chart Preview draws it with the draft.
  final HomeComponentModel model;
  final HomeWidgetSettingsSchema schema;
  final Map<String, List<HomeSettingOption>> dynamicOptions;
  final Set<HomeWidgetScope> allowedScopes;

  @override
  State<_SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<_SettingsBody> {
  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};

  @override
  void dispose() {
    for (final TextEditingController c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String key, String initial) =>
      _controllers.putIfAbsent(key, () => TextEditingController(text: initial));

  void _save(BuildContext context) {
    final HomeWidgetSettingsCubit cubit =
        context.read<HomeWidgetSettingsCubit>();
    if (cubit.validate(S.of(context))) {
      Navigator.of(context, rootNavigator: true).pop(cubit.result());
    } else {
      HapticController.high();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeWidgetSettingsCubit, HomeWidgetSettingsState>(
      builder: (BuildContext context, HomeWidgetSettingsState state) {
        final S s = S.of(context);
        return CustomSettingsDialogFrame(
          title: widget.title,
          onDiscard: () => Navigator.of(context, rootNavigator: true).pop(),
          onSave: () => _save(context),
          children: <Widget>[
            for (final HomeSettingField f in widget.schema.fields)
              _field(context, s, state, f),
          ],
        );
      },
    );
  }

  Widget _field(BuildContext context, S s, HomeWidgetSettingsState state,
      HomeSettingField f) {
    final HomeWidgetSettingsCubit cubit =
        context.read<HomeWidgetSettingsCubit>();
    switch (f.kind) {
      case HomeSettingKind.choice:
        return _dropdown(s, state, cubit, f, _optionsOf(f));
      case HomeSettingKind.period:
        final bool custom = state.values[f.key] == HomeWidgetPeriod.custom.key;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _dropdown(s, state, cubit, f, f.options),
            if (custom) ...<Widget>[
              SizedBox(height: 15.h),
              CustomFieldPair(
                start: CustomDateField(
                  label: s.from,
                  height: 36,
                  value: DateTime.tryParse(
                      '${state.values[HomeSettingKey.periodFrom]}'),
                  errorText: state.errors[HomeSettingKey.periodFrom],
                  onChanged: (DateTime? d) => cubit.set(
                      HomeSettingKey.periodFrom, d?.toIso8601String() ?? ''),
                ),
                end: CustomDateField(
                  label: s.to,
                  height: 36,
                  value: DateTime.tryParse(
                      '${state.values[HomeSettingKey.periodTo]}'),
                  errorText: state.errors[HomeSettingKey.periodTo],
                  onChanged: (DateTime? d) => cubit.set(
                      HomeSettingKey.periodTo, d?.toIso8601String() ?? ''),
                ),
              ),
            ],
          ],
        );
      case HomeSettingKind.number:
        return CustomTextField(
          label: f.label(s),
          controller: _controllerFor(f.key, '${state.values[f.key]}'),
          height: 36,
          keyboardType: TextInputType.number,
          onlyDigits: true,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          maxLength: 6,
          hideCounter: true,
          errorText: state.errors[f.key],
          helperText: s.hwsAllowed('${f.min}', '${f.max}'),
          suffixIcon: Padding(
            padding: EdgeInsetsDirectional.only(end: 12.w),
            child: Center(
              widthFactor: 1,
              child: Text(
                f.unit!(s),
                style: StyleText.fontSize12Weight500
                    .copyWith(color: AppColors.secondaryText),
              ),
            ),
          ),
          onChanged: (String v) => cubit.set(f.key, v),
        );
      case HomeSettingKind.multi:
        final List<String> picked =
            (state.values[f.key] as List<dynamic>).cast<String>();
        final List<HomeSettingOption> options = _optionsOf(f);
        return CustomMultiSelectFilter<String>(
          label: f.label(s),
          height: 36,
          // Same fill as the dropdowns and number fields beside it (it used
          // the card colour and stood out — Owner 22:02).
          fillColor: AppColors.background,
          items: <MultiSelectDropdownItem<String>>[
            for (final HomeSettingOption o in options)
              MultiSelectDropdownItem<String>(
                  value: o.value, label: o.label(s)),
          ],
          values: picked,
          // Shown while nothing is picked (a field that allows none).
          hint: f.minSelected == 0 ? s.mostRecent : null,
          // "All" or a count — never a comma list cut with "…".
          // Nothing picked on a field that allows it = the card's own
          // default (Employee Messages: the most recent chats).
          selectedTextBuilder: (List<MultiSelectDropdownItem<String>> sel) =>
              sel.isEmpty
                  ? s.mostRecent
                  : sel.length == options.length
                      ? s.all
                      : s.hwsSelectedCount('${sel.length}'),
          errorText: state.errors[f.key],
          helperText: f.maxSelected > 0
              ? s.hwsErrPickAtMost('${f.maxSelected}')
              : s.hwsKeepAtLeast('${f.minSelected}'),
          onChanged: (List<String> next) => cubit.set(f.key, next),
        );
      case HomeSettingKind.chartData:
        return _chartData(context, state, cubit);
      case HomeSettingKind.toggle:
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                f.label(s),
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.text),
              ),
            ),
            DefaultSwitchButton(
              value: state.values[f.key] as bool,
              onChanged: (bool v) => cubit.set(f.key, v),
            ),
          ],
        );
    }
  }

  /// Chart & Graph gear (Figma H11 / H12): Module and Values side by side,
  /// then the Preview of the chart drawn with the draft.
  Widget _chartData(BuildContext context, HomeWidgetSettingsState state,
      HomeWidgetSettingsCubit cubit) {
    final S s = S.of(context);
    final bool isArabic = context.isArabic;
    final String module = '${state.values[HomeSettingKey.chartModule]}';
    final String value = '${state.values[HomeSettingKey.chartValues]}';
    final List<HomeChartValue> values =
        HomeChartCatalog.valuesFor(module, widget.model.component);
    // Stacked and grouped bars show 3 months until told otherwise, the rest 6.
    final String defaultMonths = (widget.model.component ==
                HomeComponents.stackedBarChart ||
            widget.model.component == HomeComponents.groupedBarChart ||
            widget.model.component == HomeComponents.horizontalStackedBarChart)
        ? '3'
        : '6';
    final String chosenMonths =
        '${state.values[HomeSettingKey.chartMonths] ?? ''}';
    final String months = chosenMonths.isEmpty ? defaultMonths : chosenMonths;
    final List<String> shown =
        ((state.values[HomeSettingKey.chartSeries] as List<dynamic>?) ??
                const <dynamic>[])
            .cast<String>();
    final Map<String, dynamic> draft = module.isEmpty
        ? <String, dynamic>{HomeSettingKey.chartMonths: months}
        : <String, dynamic>{
            HomeSettingKey.chartModule: module,
            HomeSettingKey.chartValues: value,
            HomeSettingKey.chartMonths: months,
            HomeSettingKey.chartSeries: shown,
          };
    // The chart's own items (statuses, departments…): the user picks which
    // ones it shows; none picked = all, and the chart scrolls inside.
    HomeChartValue? chosenValue;
    for (final HomeChartValue v in values) {
      if (v.key == value) chosenValue = v;
    }
    final bool listChart = widget.model.component ==
            HomeComponents.horizontalBarChart ||
        widget.model.component == HomeComponents.horizontalStackedBarChart ||
        widget.model.component == HomeComponents.gaugeChart ||
        widget.model.component == HomeComponents.tableChart;
    final bool pickItems = listChart &&
        chosenValue != null &&
        !chosenValue.trend &&
        chosenValue.series.length > 1;
    // A time chart (line / bar / base line) also asks how many months to show.
    final bool timeChart = widget.model.component == HomeComponents.lineChart ||
        widget.model.component == HomeComponents.barChart ||
        widget.model.component == HomeComponents.barTrendChart ||
        widget.model.component == HomeComponents.baseLineChart ||
        widget.model.component == HomeComponents.stackedBarChart ||
        widget.model.component == HomeComponents.groupedBarChart ||
        widget.model.component == HomeComponents.horizontalStackedBarChart;
    final Widget? chart =
        widget.model.component.widget(widget.model.copyWith(settings: draft));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Phone: Module and Values each get their own row (Moataz 24/10/2026);
        // wider screens keep them side by side.
        Builder(builder: (BuildContext context) {
          final Widget moduleField = CustomDropdown<String>(
            label: s.module,
            hint: s.selectModule,
            height: 36,
            value: module.isEmpty ? null : module,
            items: <DropdownItem<String>>[
              for (final Modules m
                  in _chartModulesFor(context, widget.model.component))
                DropdownItem<String>(value: m.name, label: m.getModuleName),
            ],
            onChanged: (String v) {
              cubit.set(HomeSettingKey.chartModule, v);
              cubit.set(HomeSettingKey.chartValues, '');
              cubit.set(HomeSettingKey.chartSeries, <String>[]);
            },
          );
          final Widget valuesField = CustomDropdown<String>(
            label: isArabic ? 'القيم' : 'Values',
            // Says what to do first, then what to pick (Moataz 24/10/2026).
            hint: module.isEmpty
                ? (isArabic ? 'اختر الوحدة أولًا' : 'Select Module First')
                : (isArabic ? 'اختر القيم' : 'Select Values'),
            height: 36,
            value:
                values.any((HomeChartValue v) => v.key == value) ? value : null,
            items: <DropdownItem<String>>[
              for (final HomeChartValue v in values)
                DropdownItem<String>(value: v.key, label: v.title(isArabic)),
            ],
            errorText: state.errors[HomeSettingKey.chartValues],
            onChanged: (String v) {
              cubit.set(HomeSettingKey.chartValues, v);
              cubit.set(HomeSettingKey.chartSeries, <String>[]);
            },
          );
          if (context.isPhone) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 15.h,
              children: <Widget>[moduleField, valuesField],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16.w,
            children: <Widget>[
              Expanded(child: moduleField),
              Expanded(child: valuesField),
            ],
          );
        }),
        if (pickItems) ...<Widget>[
          SizedBox(height: 15.h),
          Builder(builder: (BuildContext context) {
            final HomeChartValue cv = chosenValue!;
            final List<String> all = <String>[
              for (int i = 0; i < cv.series.length; i++) '$i'
            ];
            return CustomMultiSelectFilter<String>(
              label: isArabic ? 'العناصر المعروضة' : 'Show',
              height: 36,
              fillColor: AppColors.background,
              // Tighter rows than the dropdown's 44, and one weight for every
              // item — the default bolds the ticked ones, which made the list
              // look uneven (Moataz 24/10/2026).
              itemHeight: 34,
              itemStyle: StyleText.fontSize14Weight400,
              items: <MultiSelectDropdownItem<String>>[
                for (int i = 0; i < cv.series.length; i++)
                  MultiSelectDropdownItem<String>(
                      value: '$i', label: cv.series[i].label(isArabic)),
              ],
              // None picked = every item.
              values: shown.isEmpty ? all : shown,
              selectedTextBuilder:
                  (List<MultiSelectDropdownItem<String>> sel) =>
                      sel.length == all.length
                          ? s.all
                          : s.hwsSelectedCount('${sel.length}'),
              onChanged: (List<String> next) => cubit.set(
                HomeSettingKey.chartSeries,
                next.isEmpty || next.length == all.length ? <String>[] : next,
              ),
            );
          }),
        ],
        if (timeChart) ...<Widget>[
          SizedBox(height: 15.h),
          CustomDropdown<String>(
            label: s.hwsPeriod,
            hint: s.hwsPeriod,
            height: 36,
            value: <String>['3', '6', '12'].contains(months) ? months : '6',
            items: <DropdownItem<String>>[
              DropdownItem<String>(
                  value: '3', label: isArabic ? 'آخر ٣ أشهر' : 'Last 3 months'),
              DropdownItem<String>(
                  value: '6', label: isArabic ? 'آخر ٦ أشهر' : 'Last 6 months'),
              DropdownItem<String>(
                  value: '12',
                  label: isArabic ? 'السنة كاملة' : 'Whole year (12 months)'),
            ],
            onChanged: (String v) => cubit.set(HomeSettingKey.chartMonths, v),
          ),
        ],
        SizedBox(height: 15.h),
        Text(
          s.preview,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
        SizedBox(height: 8.h),
        // The chart at its own size, scaled DOWN to the dialog's width.
        // Framed with a border and a soft shadow so the preview reads as a
        // sample, apart from the form above it (Moataz 24/10/2026).
        if (chart != null)
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.border),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.totalBlack.withValues(alpha: 0.12),
                  blurRadius: 12.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: chart,
            ),
          ),
      ],
    );
  }

  /// A select's options: live ones when the field has a source, the role's
  /// scopes for the scope field, the schema's otherwise.
  List<HomeSettingOption> _optionsOf(HomeSettingField f) {
    final List<HomeSettingOption>? live = widget.dynamicOptions[f.key];
    if (live != null) return live;
    if (f.key == HomeSettingKey.scope) {
      return f.options
          .where((HomeSettingOption o) =>
              widget.allowedScopes.contains(HomeWidgetScope.fromKey(o.value)))
          .toList();
    }
    return f.options;
  }

  Widget _dropdown(
      S s,
      HomeWidgetSettingsState state,
      HomeWidgetSettingsCubit cubit,
      HomeSettingField f,
      List<HomeSettingOption> options) {
    final String current = state.values[f.key] as String;
    return CustomDropdown<String>(
      label: f.label(s),
      height: 36,
      value: options.any((HomeSettingOption o) => o.value == current)
          ? current
          : null,
      items: <DropdownItem<String>>[
        for (final HomeSettingOption o in options)
          DropdownItem<String>(value: o.value, label: o.label(s)),
      ],
      errorText: state.errors[f.key],
      onChanged: (String v) => cubit.set(f.key, v),
    );
  }
}

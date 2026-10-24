/// Module: roles / r5_system_logs / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: system_logs_filter_dialog.dart
/// Description: The System Logs Filter pop-up — his Figma 3944:61314 has a
///              "Filter" button, not a Module menu (owner 21/10/2026: "filter
///              the module is not like this"). The house filter frame
///              (X-115): Module · Action · Role · Employee · Country · City
///              (all multi-select, X-40, choices only from the logs, X-119)
///              and From / To, Reset left · Apply right (X-73).
/// Author: Moataz Handousa
/// Created at: 21/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/layout/custom_field_pair.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_range_fields.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class SystemLogsFilterDialog extends StatefulWidget {
  const SystemLogsFilterDialog({super.key});

  /// Opens the filter at the house standard width (600).
  static Future<void> show(BuildContext context) {
    return CustomDialogManager.showContent<void>(
      context: context,
      width: 600,
      child: const SystemLogsFilterDialog(),
    );
  }

  @override
  State<SystemLogsFilterDialog> createState() => _SystemLogsFilterDialogState();
}

class _SystemLogsFilterDialogState extends State<SystemLogsFilterDialog> {
  final SystemLogsController _c = AppControllers.systemLogs;

  late Set<String> _modules = <String>{..._c.moduleFilters};
  late Set<String> _actions = <String>{..._c.actionFilters};
  late Set<String> _roles = <String>{..._c.roleFilters};
  late Set<String> _countries = <String>{..._c.countryFilters};
  late Set<String> _cities = <String>{..._c.cityFilters};
  late Set<String> _employees = <String>{..._c.employeeFilters};
  late DateTime? _from = _c.fromDate;
  late DateTime? _to = _c.toDate;

  Widget _multi(
    String label,
    Set<String> values,
    List<(String, String)> items,
    ValueChanged<Set<String>> onChanged,
  ) {
    final S s = S.of(context);
    return CustomMultiSelectFilter<String>(
      label: label,
      hint: s.all,
      fillColor: kDropdownFillColor,
      height: 36,
      heightSizesWholeTrigger: true,
      hintStyle:
          StyleText.fontSize12Weight400.copyWith(color: kDropdownHintColor),
      itemStyle: StyleText.fontSize12Weight400,
      values: <String>[
        for (final (String v, String _) in items)
          if (values.contains(v)) v
      ],
      items: <MultiSelectDropdownItem<String>>[
        for (final (String v, String text) in items)
          MultiSelectDropdownItem<String>(value: v, label: text),
      ],
      selectedTextBuilder: (List<MultiSelectDropdownItem<String>> picked) =>
          picked.length == 1
              ? picked.single.label
              : '$label (${picked.length})',
      onChanged: (List<String> v) {
        HapticController.low();
        setState(() => onChanged(v.toSet()));
      },
    );
  }

  List<(String, String)> _same(List<String> values) =>
      <(String, String)>[for (final String v in values) (v, v)];

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Map<String, String> people = _c.employeesInLogs(context.isArabic);
    final List<(String, String)> modules = <(String, String)>[
      for (final String name in _c.moduleNamesInLogs)
        (name, Modules.values.byName(name).getModuleName),
    ];
    return CustomFilterFrame(
      applyKey: const ValueKey<String>('systemLogsFilterApply'),
      canApply: CustomDateRangeFields.isValid(_from, _to),
      onReset: () {
        _c.resetFilter();
        Navigator.of(context).pop();
      },
      onApply: () {
        _c.applyFilterSets(
          modules: _modules,
          actions: _actions,
          roles: _roles,
          countries: _countries,
          cities: _cities,
          employees: _employees,
          from: _from,
          to: _to,
        );
        Navigator.of(context).pop();
      },
      rows: <Widget>[
        CustomFieldPair(
          start: _multi(s.module, _modules, modules, (v) => _modules = v),
          end: _multi(
            s.action,
            _actions,
            _same(_c.distinctInLogs((l) => l.action)),
            (v) => _actions = v,
          ),
        ),
        CustomFieldPair(
          start: _multi(
            s.role,
            _roles,
            _same(_c.distinctInLogs((l) => l.role)),
            (v) => _roles = v,
          ),
          end: _multi(
            s.employee,
            _employees,
            <(String, String)>[
              for (final MapEntry<String, String> p in people.entries)
                (p.key, p.value),
            ],
            (v) => _employees = v,
          ),
        ),
        CustomFieldPair(
          start: _multi(
            s.country,
            _countries,
            _same(_c.distinctInLogs((l) => l.country)),
            (v) => _countries = v,
          ),
          end: _multi(
            s.city,
            _cities,
            _same(_c.distinctInLogs((l) => l.city)),
            (v) => _cities = v,
          ),
        ),
        CustomDateRangeFields(
          from: _from,
          to: _to,
          onFrom: (DateTime? d) => setState(() => _from = d),
          onTo: (DateTime? d) => setState(() => _to = d),
        ),
      ],
    );
  }
}

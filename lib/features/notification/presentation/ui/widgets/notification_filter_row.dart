/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_filter_row.dart
/// Description: The Sender Type / By Type / Department / Time filter row shared by
///          the three notification inboxes, plus the predicate that applies it.
/// Author: Amr Mesbah
/// Created at: 26/8/2026
/// Updated: 22/10/2026 - Owner: all four filters are multi-select; a page
///          keeps one [NotificationFilterSelection].
///
/// WHY THIS EXISTS
/// ---------------
/// The row was built inside notification_page.dart only, so the Pinned and
/// Cleared lists had a search field and a sort menu but none of the four
/// dropdowns. Rather than paste a third copy of the options builders and the
/// filter predicate into each page, both the widget and the filtering live
/// here and the pages hold nothing but the four selected values.
library;

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart'
    show CustomDialogHeader;
import 'package:knowticed_plus/core/custom/pickers/custom_range_calendar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/constants/app_constants.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/domain/notification_category.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_sender_info.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The four values a page keeps, and the predicate that applies them.
///
/// 22/10/2026 — Owner: all four filters are MULTI-select. Each is a set:
/// empty = no filtering; several values in ONE filter combine with OR; the
/// four filters combine with AND. Time is a union of ranges (Week + Custom =
/// anything in the last 7 days OR inside the custom range).
class NotificationFilterSelection {
  const NotificationFilterSelection({
    this.senderType = const <String>{},
    this.byType = const <String>{},
    this.department = const <String>{},
    this.time = const <String>{},
    this.customFrom,
    this.customTo,
  });

  /// Every filter cleared — the page's starting state, and what Reset gives.
  const NotificationFilterSelection.cleared() : this();

  /// 'employee' / 'system'.
  final Set<String> senderType;

  /// [NotificationCategory] ids.
  final Set<String> byType;

  /// Department names of the senders.
  final Set<String> department;

  /// 'week' / 'month' / 'custom' (legacy 'day' / 'year' still understood).
  final Set<String> time;

  /// Time = Custom: the chosen range, whole days (owner 21/10/2026 14:45).
  final DateTime? customFrom;
  final DateTime? customTo;

  /// Whether anything narrows the list — lights the mobile Filter button.
  bool get isFiltering =>
      senderType.isNotEmpty ||
      byType.isNotEmpty ||
      department.isNotEmpty ||
      time.isNotEmpty;

  NotificationFilterSelection copyWith({
    Set<String>? senderType,
    Set<String>? byType,
    Set<String>? department,
    Set<String>? time,
    DateTime? customFrom,
    DateTime? customTo,
  }) =>
      NotificationFilterSelection(
        senderType: senderType ?? this.senderType,
        byType: byType ?? this.byType,
        department: department ?? this.department,
        time: time ?? this.time,
        customFrom: customFrom ?? this.customFrom,
        customTo: customTo ?? this.customTo,
      );
}

abstract class NotificationFilters {
  /// Whether the four filters live behind a Filter button and a dialog instead
  /// of a dropdown row: on the phone, and on an iPad held in PORTRAIT
  /// (Moataz 23/10/2026, to give the cards the space). iPad landscape and the
  /// Mac keep the dropdown row.
  static bool inDialog(BuildContext context, {required bool isMobile}) {
    if (isMobile) return true;
    if (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return false;
    }
    return MediaQuery.orientationOf(context) == Orientation.portrait;
  }

  /// The language department names are compared in. Get.locale, as the old
  /// `getEmployeeDepartmentName` used, so the menu and the predicate agree.
  static bool get _isEnglish => Get.locale.toString().contains('en');

  /// Function Name: [apply]
  ///
  /// Purpose: Narrow [source] by the toolbar [selection].
  ///
  /// [source] is the page's already-scoped list — pinned for the Pinned page,
  /// cleaned for the Cleared page — so this only ever applies the toolbar.
  /// OR inside one filter, AND across the four; an empty filter passes all.
  static List<NotificationModelSystem> apply({
    required List<NotificationModelSystem> source,
    required MainCoreEmployeeController employeeController,
    required NotificationFilterSelection selection,
    DateTime? now,
  }) {
    final List<NotificationCategory> categories = <NotificationCategory>[
      for (final NotificationCategory c in NotificationCategory.all)
        if (selection.byType.contains(c.id)) c,
    ];
    final List<bool Function(int)> timeTests =
        _timeTests(selection, now ?? DateTime.now());

    return source.where((NotificationModelSystem n) {
      // Person vs system — the same test the card layout uses, so what the
      // filter calls a system notification is exactly what renders without
      // an avatar chip.
      if (selection.senderType.isNotEmpty) {
        final String kind = employeeController.isKnownEmployee(n.senderEmail)
            ? 'employee'
            : 'system';
        if (!selection.senderType.contains(kind)) return false;
      }

      // By Type (owner list 22/10/2026): passes when the notification fits
      // ANY ticked category — see [NotificationCategory].
      if (categories.isNotEmpty &&
          !categories.any((NotificationCategory c) => c.matches(n))) {
        return false;
      }

      if (selection.department.isNotEmpty &&
          !selection.department.contains(
            NotificationSenderInfo.departmentName(
              employeeController,
              n.senderEmail,
              isEnglish: _isEnglish,
            ),
          )) {
        return false;
      }

      // A union of ranges: inside ANY chosen range passes.
      if (timeTests.isNotEmpty &&
          !timeTests.any((bool Function(int) test) => test(n.timestamp))) {
        return false;
      }
      return true;
    }).toList();
  }

  /// One test per chosen Time option. Custom with no dates picked is no
  /// range at all, so it is skipped (and alone it filters nothing).
  static List<bool Function(int)> _timeTests(
    NotificationFilterSelection selection,
    DateTime now,
  ) {
    final List<bool Function(int)> tests = <bool Function(int)>[];
    for (final String option in selection.time) {
      if (option == 'custom') {
        final DateTime? from = selection.customFrom;
        final DateTime? to = selection.customTo;
        if (from == null && to == null) continue;
        // Whole days: From's midnight up to the midnight after To.
        final int start = from == null
            ? 0
            : DateTime(from.year, from.month, from.day).millisecondsSinceEpoch;
        final int end = to == null
            ? 1 << 62
            : DateTime(to.year, to.month, to.day)
                .add(const Duration(days: 1))
                .millisecondsSinceEpoch;
        tests.add((int t) => t >= start && t < end);
        continue;
      }
      // Whole days back from now.
      final int days = switch (option) {
        'day' => 1,
        'week' => 7,
        'month' => 30,
        'year' => 365,
        _ => 0,
      };
      if (days == 0) continue;
      final int cutoff =
          now.subtract(Duration(days: days)).millisecondsSinceEpoch;
      tests.add((int t) => t >= cutoff);
    }
    return tests;
  }
}

/// The four dropdowns. Desktop and tablet lay them out in one row, leading
/// pair then trailing pair; mobile wraps them into two rows of two so nothing
/// is clipped at 375px.
///
/// 22/10/2026 — Owner: each is the core multi-select
/// ([CustomMultiSelectFilter]). Nothing ticked shows the filter's own name;
/// one ticked shows that value; several show "Name (n)" — the convention the
/// Time Tracker filters set with the same component.
class NotificationFilterRow extends StatelessWidget {
  const NotificationFilterRow({
    super.key,
    required this.notifications,
    required this.employeeController,
    required this.isMobile,
    required this.selection,
    required this.onChanged,
    this.stacked = false,
  });

  /// Lay the four out as one full-width column instead of the toolbar rows.
  ///
  /// ADDED 13/9/2026 for [showNotificationFilterDialog]. Same fields, same
  /// option builders — only the arrangement differs, so the dialog cannot
  /// drift away from the toolbar as options are added.
  final bool stacked;

  /// The list this toolbar sits above — the By Type and Department options are
  /// built from it, so the menus never offer something that matches nothing.
  final List<NotificationModelSystem> notifications;
  final MainCoreEmployeeController employeeController;
  final bool isMobile;

  /// The four current selections (and the Custom range).
  final NotificationFilterSelection selection;
  final ValueChanged<NotificationFilterSelection> onChanged;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);

    final Widget senderTypeField = _dropdown(
      label: s.senderType,
      values: selection.senderType,
      options: _senderTypeOptions(s),
      onChanged: (Set<String> v) =>
          onChanged(selection.copyWith(senderType: v)),
    );
    final Widget byTypeField = _dropdown(
      label: s.byType,
      values: selection.byType,
      options: _byTypeOptions(context),
      onChanged: (Set<String> v) => onChanged(selection.copyWith(byType: v)),
    );
    final Widget departmentField = _dropdown(
      label: s.department,
      values: selection.department,
      options: _departmentOptions(),
      onChanged: (Set<String> v) =>
          onChanged(selection.copyWith(department: v)),
    );
    // Owner 22/10/2026: Time is ONE choice — Week, Month or Custom — with no
    // tick boxes. Custom opens the platform's range calendar (as Time
    // Tracker's Time menu); Cancel keeps whatever was chosen before.
    final Widget timeField = CustomDropdown<String?>(
      hint: s.time,
      value: selection.time.isEmpty ? null : selection.time.first,
      height: 38,
      fillColor: isMobile ? AppColors.background : AppColors.card,
      hintStyle: StyleText.fontSize12Weight400,
      valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
      itemStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
      items: <DropdownItem<String?>>[
        for (final MapEntry<String, String> e in _timeOptions(s))
          DropdownItem<String?>(value: e.key, label: e.value),
      ],
      onChanged: (String? v) async {
        HapticController.low();
        if (v == null) return;
        if (v != 'custom') {
          onChanged(selection.copyWith(time: <String>{v}));
          return;
        }
        final List<DateTime?>? picked =
            await CustomRangeCalendar.showRangePicker(
          context,
          start: selection.customFrom,
          end: selection.customTo,
        );
        final DateTime? first =
            (picked == null || picked.isEmpty) ? null : picked.first;
        if (first == null) return;
        final DateTime last = (picked!.length > 1 ? picked[1] : null) ?? first;
        onChanged(
          selection.copyWith(
            time: <String>{'custom'},
            customFrom: first,
            customTo: last,
          ),
        );
      },
    );

    // ADDED 13/9/2026 — the dialog stacks all four full width, one per line,
    // each showing its own name as the hint (Figma: Time / Department /
    // Sender Type / Type). Nothing else in this build is used on that path.
    if (stacked) {
      // 23/10/2026 (Moataz): on an iPad the dialog is two columns by two rows
      // (Time | Department, Sender Type | By Type); the phone keeps one column.
      if (MediaQuery.sizeOf(context).width >= 600) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: timeField),
                SizedBox(width: 12.w),
                Expanded(child: departmentField),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: <Widget>[
                Expanded(child: senderTypeField),
                SizedBox(width: 12.w),
                Expanded(child: byTypeField),
              ],
            ),
          ],
        );
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          timeField,
          SizedBox(height: 12.h),
          departmentField,
          SizedBox(height: 12.h),
          senderTypeField,
          SizedBox(height: 12.h),
          byTypeField,
        ],
      );
    }

    // CHANGED 12/9/2026: the last dropdown row sat flush against the first
    // notification card. The gap belongs to the toolbar rather than to each
    // page's list, so it is bottom padding here and every inbox gets it.
    final Widget rows = isMobile
        ? Column(
            children: [
              Row(
                children: [
                  Expanded(child: senderTypeField),
                  SizedBox(width: 8.w),
                  Expanded(child: byTypeField),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(child: departmentField),
                  SizedBox(width: 8.w),
                  Expanded(child: timeField),
                ],
              ),
            ],
          )
        : LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) {
              // 22/10/2026 — Owner (iPad portrait): Time overflowed by 38 px.
              // When four 165s and their gaps do not fit, the four share the
              // width equally (still the same width as each other).
              final bool fits = box.maxWidth >= 4 * 165.w + 3 * 8.w + 16.w;
              if (!fits) {
                return Row(
                  children: [
                    Expanded(child: senderTypeField),
                    SizedBox(width: 8.w),
                    Expanded(child: byTypeField),
                    SizedBox(width: 8.w),
                    Expanded(child: departmentField),
                    SizedBox(width: 8.w),
                    Expanded(child: timeField),
                  ],
                );
              }
              return Row(
                // Owner 21/10/2026 14:45: all four filters the SAME width
                // (Figma 165), two on the left, two on the right.
                children: [
                  SizedBox(width: 165.w, child: senderTypeField),
                  SizedBox(width: 8.w),
                  SizedBox(width: 165.w, child: byTypeField),
                  const Spacer(),
                  SizedBox(width: 165.w, child: departmentField),
                  SizedBox(width: 8.w),
                  SizedBox(width: 165.w, child: timeField),
                ],
              );
            },
          );

    return Padding(
      padding: EdgeInsets.only(bottom: context.isPhone ? 0.sp : 0.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [rows],
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required Set<String> values,
    required List<MapEntry<String, String>> options,
    required ValueChanged<Set<String>> onChanged,
    bool Function(String value)? closeOnSelect,
  }) {
    // CHANGED 22/10/2026 — Owner: multi-select. Was the single-choice
    // CustomDropdown with an "All" entry; now nothing ticked IS "all", so the
    // lists carry no "All" row and an unfiltered field shows its own NAME
    // (Sender Type, By Type, Department, Time — owner 21/10/2026 14:45).
    return CustomMultiSelectFilter<String>(
      hint: label,
      // RAW 38, scaled inside the widget (.sp) — same height as before.
      height: 38,
      heightSizesWholeTrigger: true,
      fillColor: isMobile ? AppColors.background : AppColors.card,
      hintStyle: StyleText.fontSize12Weight400,
      valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
      itemStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
      // Only values still offered: a department that left the list must not
      // keep a tick nobody can see.
      values: <String>[
        for (final MapEntry<String, String> e in options)
          if (values.contains(e.key)) e.key,
      ],
      items: <MultiSelectDropdownItem<String>>[
        for (final MapEntry<String, String> e in options)
          MultiSelectDropdownItem<String>(value: e.key, label: e.value),
      ],
      selectedTextBuilder: (List<MultiSelectDropdownItem<String>> picked) =>
          picked.length == 1
              ? picked.single.label
              : '$label (${picked.length})',
      closeOnSelect: closeOnSelect,
      onChanged: (List<String> v) {
        HapticController.low();
        onChanged(v.toSet());
      },
    );
  }

  /// Person-sent vs system-raised.
  List<MapEntry<String, String>> _senderTypeOptions(S s) {
    // 23/10/2026 (Moataz: "if it is empty, don't put it"): only the kinds that
    // exist in this list. Same test as [NotificationFilters.apply].
    final bool hasEmployee = notifications
        .any((n) => employeeController.isKnownEmployee(n.senderEmail));
    final bool hasSystem = notifications
        .any((n) => !employeeController.isKnownEmployee(n.senderEmail));
    return <MapEntry<String, String>>[
      if (hasEmployee) MapEntry('employee', s.employee),
      if (hasSystem) MapEntry('system', s.system),
    ];
  }

  /// The owner's fixed list of notification types (22/10/2026).
  List<MapEntry<String, String>> _byTypeOptions(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode ==
        AppConstants.arabicLanguageCode;

    return <MapEntry<String, String>>[
      // Only the categories that at least one notification in this list fits.
      for (final NotificationCategory c in NotificationCategory.all)
        if (notifications.any(c.matches))
          MapEntry(c.id, c.label(isArabic: isArabic)),
    ];
  }

  /// Departments of the people who sent something in this list.
  List<MapEntry<String, String>> _departmentOptions() {
    final Set<String> names = notifications
        .where((n) => employeeController.isKnownEmployee(n.senderEmail))
        // Null-safe lookup — see notification_sender_info.dart (7/10/2026).
        .map(
          (n) => NotificationSenderInfo.departmentName(
            employeeController,
            n.senderEmail,
            isEnglish: NotificationFilters._isEnglish,
          ),
        )
        .where((d) => d.trim().isNotEmpty)
        .toSet();

    return <MapEntry<String, String>>[
      for (final String name in names.toList()..sort()) MapEntry(name, name),
    ];
  }

  /// How far back to look.
  ///
  /// 'year' was dropped 26/8/2026 and 'day' 21/10/2026; the mapping in
  /// [NotificationFilters.apply] still understands both.
  // Owner 21/10/2026 14:45: Week · Month · Custom (From / To). "All" is gone
  // with multi-select (22/10/2026): nothing ticked means all.
  List<MapEntry<String, String>> _timeOptions(S s) =>
      <MapEntry<String, String>>[
        MapEntry('week', s.week),
        MapEntry('month', s.month),
        MapEntry('custom', s.custom),
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile: the four dropdowns move into a dialog behind a Filter button
//
// ADDED 13/9/2026 (Figma MESBAH — mobile Notification screen). At 375px the
// toolbar's 2x2 grid of dropdowns ate a third of the screen before a single
// card was visible. On mobile the row is hidden, the Sort button becomes a
// Filter button, and the four live in a dialog that commits on Apply.
// ─────────────────────────────────────────────────────────────────────────────

/// Opens the mobile filter dialog.
///
/// Returns the chosen values on Apply, or null if the sheet was dismissed or
/// cancelled — so a caller can `if (result == null) return;` and leave the
/// page's own state untouched.
Future<NotificationFilterSelection?> showNotificationFilterDialog({
  required BuildContext context,
  required List<NotificationModelSystem> notifications,
  required MainCoreEmployeeController employeeController,
  required NotificationFilterSelection current,
}) {
  // 23/10/2026 (Moataz: "every dialog the same size"): the house dialog shell
  // at the house filter width (600, like the other filters) instead of this
  // file's own Dialog. On a phone the shell clamps it to the screen.
  return CustomDialogManager.showContent<NotificationFilterSelection>(
    context: context,
    width: 600,
    scrollable: true,
    child: _NotificationFilterDialog(
      notifications: notifications,
      employeeController: employeeController,
      current: current,
    ),
  );
}

class _NotificationFilterDialog extends StatefulWidget {
  const _NotificationFilterDialog({
    required this.notifications,
    required this.employeeController,
    required this.current,
  });

  final List<NotificationModelSystem> notifications;
  final MainCoreEmployeeController employeeController;
  final NotificationFilterSelection current;

  @override
  State<_NotificationFilterDialog> createState() =>
      _NotificationFilterDialogState();
}

class _NotificationFilterDialogState extends State<_NotificationFilterDialog> {
  // A DRAFT, not the page's state: picking a value here changes nothing until
  // Apply, so dismissing the sheet leaves the list exactly as it was.
  late NotificationFilterSelection _draft = widget.current;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // 22/10/2026 — Owner: "the icon size of the filter … too much" (a 20
        // icon filled the 30 circle). The core header: 30 circle, 16 icon,
        // the same in every dialog.
        CustomDialogHeader(title: s.filter, icon: AppAssets.filter),
        SizedBox(height: 16.h),

        // Same widget as the toolbar, stacked — see [stacked].
        NotificationFilterRow(
          notifications: widget.notifications,
          employeeController: widget.employeeController,
          isMobile: true,
          stacked: true,
          selection: _draft,
          onChanged: (NotificationFilterSelection v) =>
              setState(() => _draft = v),
        ),

        SizedBox(height: 20.h),
        Row(
          children: <Widget>[
            // Reset CLEARS and closes, rather than clearing the draft and
            // waiting for Apply: "Reset" on a filter sheet is read as "show me
            // everything", and a second tap to confirm it is a step nobody
            // expects.
            Expanded(
              child: customButton(
                title: s.reset,
                fullWidth: true,
                color: AppColors.darkGrey,
                textColor: AppColors.text,
                function: () => Navigator.of(context, rootNavigator: true)
                    .pop(const NotificationFilterSelection.cleared()),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: customButton(
                title: s.apply,
                fullWidth: true,
                color: AppColors.primary,
                textColor: AppColors.textButton,
                function: () =>
                    Navigator.of(context, rootNavigator: true).pop(_draft),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_widget_settings.dart
/// Purpose: Declares `HomeWidgetSettings` — the typed reader over the settings
///          map a placed home widget carries — plus the period / scope choices
///          many widgets share and the keys they are stored under.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// D-242 (Moataz, 21/10/2026): every home widget has a settings gear; the
/// values are saved per user AND per PLACED COPY, so they live on the
/// `HomeComponentModel` (keyed by its row / column) and travel with the layout.
/// Only values the user changed are stored: an empty map means "today's
/// behaviour", so no widget changes until someone edits it.
library;

/// Storage keys of the buttons a card can show (the values of
/// `HomeSettingKey.buttons`). Stable machine names, never labels.
abstract final class HomeButtonKey {
  static const String createService = 'create_service';
  static const String myRequests = 'my_requests';
  static const String viewApproval = 'view_approval';

  static const String createForm = 'create_form';
  static const String viewDraftForm = 'view_draft_form';
  static const String viewRequestedForm = 'view_requested_form';

  static const String createHub = 'create_hub';
  static const String viewDashboard = 'view_dashboard';

  static const String forGroup = 'for_group';
  static const String forDirectMessage = 'for_direct_message';

  static const String addProduct = 'add_product';
  static const String order = 'order';
  static const String approvals = 'approvals';

  static const String asset = 'asset';
  static const String consumable = 'consumable';
  static const String myRequest = 'my_request';

  static const String checkInOut = 'check_in_out';
  static const String requests = 'requests';
  static const String timeTrackerApprovals = 'tt_approvals';
}

/// Storage keys. Stable machine names, never labels. Title_Snake, like every
/// other field in the schema (Moataz, 23/10/2026).
abstract final class HomeSettingKey {
  static const String period = 'Period';
  static const String periodFrom = 'Period_From';
  static const String periodTo = 'Period_To';
  static const String scope = 'Scope';
  static const String statuses = 'Statuses';
  static const String buttons = 'Buttons';
  static const String tiles = 'Tiles';
  static const String counts = 'Counts';
  static const String rows = 'Rows';
  static const String warnPercent = 'Warn_Percent';
  static const String includeBreached = 'Include_Breached';
  static const String department = 'Department';
  static const String due = 'Due';
  static const String countOnly = 'Count_Only';
  static const String priorities = 'Priorities';
  static const String show = 'Show';
  static const String order = 'Order';

  /// Group Messages: the chosen groups' ids (1–4); none = the newest group.
  static const String groups = 'Groups';

  /// Employee Messages: chosen colleagues' emails (1–4); none = the 4 most
  /// recent chats.
  static const String people = 'People';

  /// Forms Submission: [the chosen form's id]; none = the latest published.
  static const String form = 'Form';

  /// Chart & Graph gear (23/10/2026): the module a chart reads
  /// (`Modules.name`) and which of that module's value sets it shows
  /// (`HomeChartValue.key`). None = the card's own sample.
  static const String chartModule = 'Chart_Module';
  static const String chartValues = 'Chart_Values';

  /// Time charts: how many months they show — '3', '6' (default) or '12'.
  static const String chartMonths = 'Chart_Months';

  /// Snapshot charts: which of the value's items (statuses, departments…)
  /// they show, as their positions; none = all of them.
  static const String chartSeries = 'Chart_Series';

  /// Base Line chart: the number the dashed reference line (and the badge)
  /// shows. None = the sample 120.
  static const String chartBaseline = 'Chart_Baseline';
}

/// The periods a count can cover.
enum HomeWidgetPeriod {
  today('today'),
  thisWeek('this_week'),
  thisMonth('this_month'),
  last30Days('last_30_days'),
  thisYear('this_year'),
  allTime('all_time'),
  custom('custom');

  const HomeWidgetPeriod(this.key);

  final String key;

  static HomeWidgetPeriod fromKey(String? key,
      {HomeWidgetPeriod fallback = HomeWidgetPeriod.allTime}) {
    for (final HomeWidgetPeriod p in HomeWidgetPeriod.values) {
      if (p.key == key) return p;
    }
    return fallback;
  }
}

/// Whose requests a Services count covers.
enum HomeWidgetScope {
  mine('mine'),
  department('department'),
  all('all');

  const HomeWidgetScope(this.key);

  final String key;

  static HomeWidgetScope fromKey(String? key,
      {HomeWidgetScope fallback = HomeWidgetScope.all}) {
    for (final HomeWidgetScope s in HomeWidgetScope.values) {
      if (s.key == key) return s;
    }
    return fallback;
  }
}

/// An inclusive date window, or null ends for "no limit".
class HomeDateWindow {
  const HomeDateWindow({this.from, this.to});

  /// First instant that counts (inclusive).
  final DateTime? from;

  /// First instant that no longer counts (exclusive).
  final DateTime? to;

  static const HomeDateWindow unlimited = HomeDateWindow();

  bool contains(DateTime? moment) {
    if (from == null && to == null) return true;
    if (moment == null) return false;
    if (from != null && moment.isBefore(from!)) return false;
    if (to != null && !moment.isBefore(to!)) return false;
    return true;
  }
}

/// Typed, defaulting reader over a settings map.
class HomeWidgetSettings {
  const HomeWidgetSettings(this.values);

  static const HomeWidgetSettings empty =
      HomeWidgetSettings(<String, dynamic>{});

  final Map<String, dynamic> values;

  bool get isEmpty => values.isEmpty;

  String string(String key, String fallback) {
    final Object? v = values[key];
    return v is String && v.isNotEmpty ? v : fallback;
  }

  int integer(String key, int fallback) {
    final Object? v = values[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return fallback;
  }

  bool boolean(String key, bool fallback) {
    final Object? v = values[key];
    return v is bool ? v : fallback;
  }

  List<String> list(String key, List<String> fallback) {
    final Object? v = values[key];
    if (v is List) {
      final List<String> out = v.whereType<String>().toList();
      return out.isEmpty ? fallback : out;
    }
    return fallback;
  }

  /// The chosen period. [key] lets a card read a second window field (the
  /// To-Do cards store theirs under `due`).
  HomeWidgetPeriod period({
    String key = HomeSettingKey.period,
    HomeWidgetPeriod fallback = HomeWidgetPeriod.allTime,
  }) =>
      HomeWidgetPeriod.fromKey(values[key] as String?, fallback: fallback);

  HomeWidgetScope scope({HomeWidgetScope fallback = HomeWidgetScope.all}) =>
      HomeWidgetScope.fromKey(values[HomeSettingKey.scope] as String?,
          fallback: fallback);

  /// The window the chosen period covers, taken against [now].
  ///
  /// Weeks start on Monday. A custom range runs from the start of `from` to
  /// the END of `to`; a custom range missing an end is treated as unlimited
  /// on that side (the dialog never saves one, this only guards old data).
  HomeDateWindow window(DateTime now,
      {String key = HomeSettingKey.period,
      HomeWidgetPeriod fallback = HomeWidgetPeriod.allTime}) {
    final DateTime today = DateTime(now.year, now.month, now.day);
    switch (period(key: key, fallback: fallback)) {
      case HomeWidgetPeriod.allTime:
        return HomeDateWindow.unlimited;
      case HomeWidgetPeriod.today:
        return HomeDateWindow(
            from: today, to: today.add(const Duration(days: 1)));
      case HomeWidgetPeriod.thisWeek:
        final DateTime monday =
            today.subtract(Duration(days: today.weekday - DateTime.monday));
        return HomeDateWindow(
            from: monday, to: monday.add(const Duration(days: 7)));
      case HomeWidgetPeriod.thisMonth:
        return HomeDateWindow(
            from: DateTime(now.year, now.month),
            to: DateTime(now.year, now.month + 1));
      case HomeWidgetPeriod.last30Days:
        return HomeDateWindow(
            from: today.subtract(const Duration(days: 29)),
            to: today.add(const Duration(days: 1)));
      case HomeWidgetPeriod.thisYear:
        return HomeDateWindow(
            from: DateTime(now.year), to: DateTime(now.year + 1));
      case HomeWidgetPeriod.custom:
        final DateTime? from =
            DateTime.tryParse(string(HomeSettingKey.periodFrom, ''));
        final DateTime? to =
            DateTime.tryParse(string(HomeSettingKey.periodTo, ''));
        return HomeDateWindow(
          from: from == null ? null : DateTime(from.year, from.month, from.day),
          to: to == null ? null : DateTime(to.year, to.month, to.day + 1),
        );
    }
  }
}

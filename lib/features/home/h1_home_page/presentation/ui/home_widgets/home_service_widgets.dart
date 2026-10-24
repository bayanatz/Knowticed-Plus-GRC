// [module-file:services] — deleted when the services module is split out
/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_service_widgets.dart
/// Purpose: The seven Services-module cards on the Adding Widget picker —
///          `RequestService`, `ServicesActions`, `ServicesStatus`,
///          `MyServices`, `NearBreachedSLA`, `ServiceOverview` and
///          `MyRequestServices`.
/// Author: Knowticed Plus team
/// Created at: 23/8/2026
///
/// These seven names were already referenced by `HomeComponents.widget()`, but
/// the cases were commented out because the widget files went away with the
/// old services module. Rebuilt here against Figma file BuJXLizpGcK5eHVBqQomXc,
/// Settings > Home Layout > Adding Widget, iPad Horizontal View (node
/// 4717:68984), so the commented cases could be restored as-is.
///
/// Updated: 30/8/2026 - WIRED TO REAL DATA. Every figure below used to be the
/// placeholder its Figma frame drew — 32 / 12 / 08, six bars all reading 84,
/// four tiles all reading 10, "Total 100", and two rows both named "Market
/// Research Service". They now come from [ServicesHomeStatsCubit], which reads
/// the services module's own repository; see that file for why a home card
/// cannot simply read `ServicesManagerCubit`.
///
/// While the figures are in the air — and for any source that failed — the
/// cards show an em dash rather than a zero. "No pending requests" and "we
/// could not read the requests" are different facts, and a card must not state
/// the first when it means the second.
library;

import 'package:knowticed_plus/features/home/h1_home_page/data/helpers/home_button_access.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/localized_number.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_widget_settings.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/services_home_stats_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/services_home_stats_state.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Shared scaffolding for every Services card that shows live figures.
///
/// ADDED 30/8/2026. Each card is the same three things — kick the lazy load,
/// rebuild on the cubit, render an em dash until the figures land — so the
/// `ensureLoaded` call, the BlocBuilder and the placeholder rule live here once
/// rather than seven times. Mirrors `_RolesStatCard` in
/// `home_roles_widgets.dart`.
///
/// [builder] receives:
///   * the cubit, for the counts;
///   * `format`, which renders an int in the reader's numerals, or `—` when
///     the figures are not ready.
class _ServicesStatsBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    ServicesHomeStatsCubit stats,
    String Function(int) format,
    bool ready,
  ) builder;

  const _ServicesStatsBuilder({required this.builder});

  @override
  Widget build(BuildContext context) {
    // Lazy by design: BlocProvider builds the cubit on this first read, and the
    // cubit fetches on this first ensureLoaded. An account that never opens
    // Home or the picker never triggers either.
    context.read<ServicesHomeStatsCubit>().ensureLoaded();

    return BlocBuilder<ServicesHomeStatsCubit, ServicesHomeStatsState>(
      builder: (BuildContext context, ServicesHomeStatsState state) {
        final bool ready = state is ServicesHomeStatsLoaded;
        final ServicesHomeStatsCubit stats =
            context.read<ServicesHomeStatsCubit>();

        String format(int value) =>
            ready ? LocalizedNumber.of(context, value) : '—';

        return builder(context, stats, format, ready);
      },
    );
  }
}

/// Figma: "Requested Service" — the most recent requests, each with a View
/// action.
class RequestService extends StatelessWidget {
  /// Carried for parity with every other component widget; the card itself
  /// renders the same preview regardless of its position.
  final HomeComponentModel model;

  const RequestService({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final bool isArabic = context.isArabic;
    final HomeWidgetSettings settings = model.widgetSettings;
    // D-242: 1–3 rows (default 2), chosen statuses, period-free scope.
    final int rowCount = settings.integer(HomeSettingKey.rows, 2);

    return _ServicesStatsBuilder(
      builder: (BuildContext context, ServicesHomeStatsCubit stats,
          String Function(int) format, bool ready) {
        final List<ServiceRequestSummary> recent =
            ready ? stats.recentFor(settings) : stats.recentRequests;
        return HomeWidgetCard(
          title: l.requestedService,
          icon: HomeWidgetSvg.service,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // An empty queue and an unread queue both render as placeholder
              // rows, so the card keeps its height either way and the grid does
              // not reflow when the figures land.
              // Loaded and empty: say so (18/10/2026 — two "—" rows read as broken).
              if (ready && recent.isEmpty)
                SizedBox(
                  width: 220.w,
                  child: Text(
                    l.noDataAvailable,
                    style: StyleText.fontSize12Weight500
                        .copyWith(color: AppColors.secondaryText),
                  ),
                )
              else
                for (final ServiceRequestSummary request
                    in _rowsOrPlaceholders(recent, ready, rowCount))
                  HomeEntityRow(
                    icon: HomeWidgetSvg.serviceRequest,
                    name: request.name(isArabic),
                    subtitle: request.department(isArabic).trim().isEmpty
                        ? l.department
                        : request.department(isArabic),
                    trailing: SizedBox(
                      width: 46.w,
                      child: HomeCardButton(label: l.view),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

/// Function Name: [openServicesFromHome]
///
/// Purpose: Open the Services module from a home card. ADDED 21/10/2026 —
/// the "Service" card's buttons had no onTap. Same routing as
/// `openFormBuilderFromHome`: tablet/desktop switches the side-rail module;
/// phone pushes the module page. The Services module has no shortcut hook,
/// so every button lands on its main page.
void openServicesFromHome(BuildContext context) {
  if (!kpIsPhoneLayout(context)) {
    final drawer = NotificationRouting.drawerCubit();
    final int index = drawer.allowedDrawerModules.indexOf(Modules.services);
    // The user has no Services access — nothing to open.
    if (index == -1) return;
    drawer.updateSelectedIndex(index);
  } else {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => Modules.services.widget),
    );
  }
}

/// Figma: "Service" — the three service actions, stacked.
///
/// No figures: this card is three buttons. It is the one Services card that
/// needs no data, so it does not go through [_ServicesStatsBuilder] and does
/// not trigger a load.
class ServicesActions extends StatelessWidget {
  final HomeComponentModel model;

  const ServicesActions({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    // D-242: "Buttons shown" — at least one stays; 24/10/2026: and only the
    // ones the role has permission for.
    final List<String> shown = HomeButtonAccess.shown(model, <String>[
      HomeButtonKey.createService,
      HomeButtonKey.myRequests,
      HomeButtonKey.viewApproval,
    ]);
    final List<Widget> buttons = <Widget>[
      if (shown.contains(HomeButtonKey.createService))
        HomeCardButton(
          label: l.createService,
          onTap: () => openServicesFromHome(context),
        ),
      if (shown.contains(HomeButtonKey.myRequests))
        HomeCardButton(
          label: l.myRequests,
          onTap: () => openServicesFromHome(context),
        ),
      if (shown.contains(HomeButtonKey.viewApproval))
        HomeCardButton(
          label: l.viewApproval,
          onTap: () => openServicesFromHome(context),
        ),
    ];
    // Owner 21/10/2026: reference home-card style — as Forms: HomeWidgetCard
    // header (title + Services icon), narrow width, stacked HomeCardButtons.
    return HomeWidgetCard(
      title: l.service,
      icon: Modules.services.iconPath,
      width: kHomeWidgetNarrowWidth,
      // Equal gaps title → buttons → card edge (Owner 21/10/2026).
      child: HomeCardButtonStack(
        buttons: buttons,
      ),
    );
  }
}

/// Figma: "Services Status" — six status bars, the tall 200-high card.
class ServicesStatus extends StatelessWidget {
  final HomeComponentModel model;

  const ServicesStatus({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);

    return _ServicesStatsBuilder(
      builder: (BuildContext context, ServicesHomeStatsCubit stats,
          String Function(int) format, bool ready) {
        // (label, bucket key, colour) in the order Figma lists them. The
        // fractions used to be six hardcoded decimals; they are computed below.
        final List<(String, String, Color)> all = <(String, String, Color)>[
          (l.BreachedSLA, ServiceStatusKey.breachedSla, AppColors.darkRed),
          (l.canceled, ServiceStatusKey.cancel, AppColors.lightRed),
          (l.rejected, ServiceStatusKey.rejected, AppColors.red),
          (l.Inprogress, ServiceStatusKey.inProgress, AppColors.primary),
          (l.approved, ServiceStatusKey.approved, AppColors.green),
          (l.done, ServiceStatusKey.done, AppColors.lightGreen),
        ];
        // D-242: period + scope + which statuses are drawn (default all six).
        final HomeWidgetSettings settings = model.widgetSettings;
        final List<String> shown =
            settings.list(HomeSettingKey.statuses, ServiceStatusKey.all);
        final List<(String, String, Color)> rows = all
            .where(((String, String, Color) r) => shown.contains(r.$2))
            .toList();
        final Map<String, int> counts =
            ready ? stats.countsFor(settings) : stats.statusCounts;
        // With three or fewer the card drops to one column.

        // Bars are scaled to the LARGEST bucket, not to the total — see
        // `ServicesHomeStatsCubit.statusPeak`. Flat while unread, so the card
        // does not animate six bars up from nothing on every rebuild.
        int peak = 0;
        for (final (String _, String key, Color _) in rows) {
          final int v = counts[key] ?? 0;
          if (v > peak) peak = v;
        }
        if (peak == 0) peak = 1;

        // Owner 21/10/2026 12:11 ("way 1"): ONE list, one bar row per
        // status across the full card width; the card keeps its box and the
        // list scrolls down inside it after the third row (To-Do pattern).
        return HomeWidgetCard(
          title: l.servicesStatus,
          icon: HomeWidgetSvg.service,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final (String label, String key, Color color) in rows)
                HomeProgressRow(
                  label: label,
                  value: format(counts[key] ?? 0),
                  fraction: ready ? (counts[key] ?? 0) / peak : 0,
                  color: color,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Figma: "Services" — Approved / Pending / Rejected counts.
class MyServices extends StatelessWidget {
  final HomeComponentModel model;

  const MyServices({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);

    return _ServicesStatsBuilder(
      builder: (BuildContext context, ServicesHomeStatsCubit stats,
          String Function(int) format, bool ready) {
        // D-242: period + scope.
        final Map<String, int> counts =
            ready ? stats.countsFor(model.widgetSettings) : stats.statusCounts;
        return HomeWidgetCard(
          hugContent: true,
          title: l.services,
          icon: HomeWidgetSvg.service,
          child: HomeStatTileRow(
            tiles: <HomeStatTile>[
              HomeStatTile(
                icon: HomeWidgetSvg.approved,
                label: l.approved,
                value: format(counts[ServiceStatusKey.approved] ?? 0),
              ),
              HomeStatTile(
                icon: HomeWidgetSvg.pending,
                label: l.pending,
                value: format(counts[ServiceStatusKey.pending] ?? 0),
              ),
              HomeStatTile(
                icon: HomeWidgetSvg.rejected,
                label: l.rejected,
                value: format(counts[ServiceStatusKey.rejected] ?? 0),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Figma: "Near Breached SLA" — the breach percentage sits where the module
/// glyph normally does, with a chat shortcut on each row.
///
/// ⚠️ The rows are requests that HAVE breached, not ones approaching a breach —
/// see `ServicesHomeStatsCubit.breachedRequests` for why.
class NearBreachedSLA extends StatelessWidget {
  final HomeComponentModel model;

  const NearBreachedSLA({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final bool isArabic = context.isArabic;
    final HomeWidgetSettings settings = model.widgetSettings;
    final int rowCount = settings.integer(HomeSettingKey.rows, 2);

    return _ServicesStatsBuilder(
      builder: (BuildContext context, ServicesHomeStatsCubit stats,
          String Function(int) format, bool ready) {
        // D-242: the list is requests whose SLA time used reached the warn
        // level (default 80 %), plus — when switched on — those already
        // breached; the header is their share of the requests.
        final List<ServiceRequestSummary> near = ready
            ? stats
                .nearBreachFor(settings)
                .map((ServiceRequestRecord r) => r.summary)
                .toList()
            : const <ServiceRequestSummary>[];
        final String percent = ready
            ? '${LocalizedNumber.of(context, (stats.nearBreachRatio(settings) * 100).round())}%'
            : '—';

        return HomeWidgetCard(
          title: l.nearBreachedSLA,
          trailing: Text(
            percent,
            style: CardStyles.value(14).copyWith(color: AppColors.text),
          ),
          child: Column(
            // 12:30: the list rows spread down to the bottom inset.
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Loaded and empty: say so (18/10/2026 — two "—" rows read as broken).
              if (ready && near.isEmpty)
                SizedBox(
                  width: 220.w,
                  child: Text(
                    l.noDataAvailable,
                    style: StyleText.fontSize12Weight500
                        .copyWith(color: AppColors.secondaryText),
                  ),
                )
              else
                for (final ServiceRequestSummary request
                    in _rowsOrPlaceholders(near, ready, rowCount))
                  HomeEntityRow(
                    icon: HomeWidgetSvg.serviceRequest,
                    name: request.name(isArabic),
                    subtitle: request.department(isArabic).trim().isEmpty
                        ? l.department
                        : request.department(isArabic),
                    trailing: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: CustomSvgImage(
                        assetPath: HomeWidgetSvg.chat,
                        width: 12.r,
                        height: 12.r,
                        color: AppColors.textButton,
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

/// Figma: "Services" totals — four tiles across three grid columns.
class ServiceOverview extends StatelessWidget {
  final HomeComponentModel model;

  const ServiceOverview({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final HomeWidgetSettings settings = model.widgetSettings;
    // D-242: "Tiles shown" (at least two), period and scope.
    final List<String> shown = settings.list(
      HomeSettingKey.tiles,
      const <String>['services', 'requests', 'sla', 'done'],
    );

    return _ServicesStatsBuilder(
      builder: (BuildContext context, ServicesHomeStatsCubit stats,
          String Function(int) format, bool ready) {
        final Map<String, int> counts =
            ready ? stats.countsFor(settings) : stats.statusCounts;
        final int requests =
            ready ? stats.totalFor(settings) : stats.totalRequests;
        final List<(String, HomeStatTile)> tiles = <(String, HomeStatTile)>[
          (
            'services',
            HomeStatTile(
              icon: HomeWidgetSvg.serviceTap,
              label: l.totalServices,
              // The CATALOGUE — how many services exist to be requested.
              value: format(stats.totalServices),
              iconColor: AppColors.primary,
            ),
          ),
          (
            'requests',
            HomeStatTile(
              icon: HomeWidgetSvg.serviceRequest,
              label: l.totalRequests,
              value: format(requests),
              iconColor: AppColors.primary,
            ),
          ),
          (
            'sla',
            HomeStatTile(
              icon: HomeWidgetSvg.sla,
              label: l.totalSLA,
              // ⚠️ ASSUMPTION: "Total SLA" is read as the number of requests
              // that have BREACHED their SLA — the only SLA figure a request
              // document actually carries. If the tile is meant to count
              // requests that HAVE an SLA defined, that is a different read
              // (the SLA fields on the service, not the request's state) and
              // this line is where it changes. D-242 (6): keeps this meaning.
              value: format(counts[ServiceStatusKey.breachedSla] ?? 0),
              iconColor: AppColors.primary,
            ),
          ),
          (
            'done',
            HomeStatTile(
              icon: HomeWidgetSvg.done,
              label: l.totalDone,
              value: format(counts[ServiceStatusKey.done] ?? 0),
              iconColor: AppColors.green,
            ),
          ),
        ];
        return HomeWidgetCard(
          hugContent: true,
          title: l.services,
          icon: HomeWidgetSvg.service,
          width: kHomeWidgetWideWidth,
          child: HomeStatTileRow(
            tiles: <HomeStatTile>[
              for (final (String key, HomeStatTile tile) in tiles)
                if (shown.contains(key)) tile,
            ],
          ),
        );
      },
    );
  }
}

/// Figma: "My Request" — the one-column request summary.
///
/// The only Services card scoped to the reader rather than to the whole queue,
/// which is what its title claims — see
/// `ServicesHomeStatsCubit.myRequestCounts`.
class MyRequestServices extends StatelessWidget {
  final HomeComponentModel model;

  const MyRequestServices({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final HomeWidgetSettings settings = model.widgetSettings;

    return _ServicesStatsBuilder(
      builder: (BuildContext context, ServicesHomeStatsCubit stats,
          String Function(int) format, bool ready) {
        // D-242: always my own requests; only the period can change.
        final Map<String, int> mine = ready
            ? stats.countsFor(settings, mineOnly: true)
            : stats.myRequestCounts;
        // Owner item 197 (21/10/2026): the same three counter tiles as
        // Approvals (icon over label over number), one size — not a column
        // of 16-pt glyphs.
        return HomeWidgetCard(
          hugContent: true,
          title: l.myRequest,
          icon: HomeWidgetSvg.service,
          // Owner 21/10/2026 13:16: the card hugs its three tiles — no
          // spare width after the last tile.
          width: kHomeWidgetNarrowWidth,
          // Owner 21/10/2026 13:17: the same order AND the same three icons
          // as Approvals — Approved · Pending · Rejected.
          child: HomeStatTileRow(
            tiles: <HomeStatTile>[
              HomeStatTile(
                icon: HomeWidgetSvg.approved,
                label: l.approved,
                value: format(mine[ServiceStatusKey.approved] ?? 0),
              ),
              HomeStatTile(
                icon: HomeWidgetSvg.pending,
                label: l.pending,
                value: format(mine[ServiceStatusKey.pending] ?? 0),
              ),
              HomeStatTile(
                icon: HomeWidgetSvg.rejected,
                label: l.rejected,
                value: format(mine[ServiceStatusKey.rejected] ?? 0),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Function Name: [_rowsOrPlaceholders]
///
/// Purpose: Exactly two rows for the list cards, whatever the data says.
///
/// ADDED 30/8/2026. Both list cards draw two rows in Figma, and the picker
/// lays its cards out in a `Wrap` — a card that grew or shrank when its figures
/// landed would reflow the whole grid under the user's cursor. So an empty or
/// unread list is padded to two blank-named rows: same height, no invented
/// content.
List<ServiceRequestSummary> _rowsOrPlaceholders(
  List<ServiceRequestSummary> rows,
  bool ready, [
  int wanted = 2,
]) {
  if (ready && rows.length >= wanted) return rows.take(wanted).toList();

  return <ServiceRequestSummary>[
    ...rows.take(wanted),
    for (int i = rows.length; i < wanted; i++)
      const ServiceRequestSummary(
        nameEnglish: '—',
        nameArabic: '—',
        departmentEnglish: '',
        departmentArabic: '',
      ),
  ];
}

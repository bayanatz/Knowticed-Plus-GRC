/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: adding_widget_page.dart
/// Purpose: Declares `AddingWidgetPage`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_filter_app.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_segmented_toggle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/home_components.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_state.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/add_component_wrapper.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/home_card_metrics.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/packed_wrap.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_layer.dart';

class AddingWidgetPage extends StatefulWidget {
  const AddingWidgetPage({super.key});

  @override
  State<AddingWidgetPage> createState() => _AddingWidgetPageState();
}

class _AddingWidgetPageState extends State<AddingWidgetPage> {
  // Card size lives in HomeCardMetrics, shared with the layout editor
  // (edit_home_page.dart) and the dashboard (home_screen.dart). It used to be
  // a pair of getters here, which sized the picker only and left the other two
  // screens ragged.

  int selectedTab = 0; // 0 for Widgets, 1 for Chart & Graph

  /// Canonical key for the "show everything" chip.
  static const String _allKey = 'All';

  /// Selected chip key: [_allKey] or a `Modules.name`.
  String selectedModuleKey = _allKey;

  /// Every widget the picker can offer, before any filter.
  List<HomeComponentModel> get _allComponents =>
      context.read<AppHomeCubit>().readyToAddComponent;

  /// Function Name: [_allowedModules]
  ///
  /// Purpose: The modules this employee's role actually grants, or `null` when
  ///          that cannot be determined.
  ///
  /// `null` and "empty list" mean different things and must not be conflated:
  /// no cubit means *unknown*, and the picker then shows everything rather than
  /// nothing.
  Set<Modules>? get _allowedModules {
    if (!Get.isRegistered<AppDrawerCubit>()) return null;
    final List<Modules> allowed =
        Get.find<AppDrawerCubit>().allowedDrawerModules;
    if (allowed.isEmpty) return null;
    return allowed.toSet();
  }

  /// Function Name: [_grantedComponents]
  ///
  /// Purpose: Every component the employee is actually entitled to add.
  ///
  /// FIXED 13/8/2026: the picker offered every component in
  /// `readyToAddComponent`, while the filter chips were built only from modules
  /// in `allowedDrawerModules`. Two consequences, both reported:
  ///
  ///  1. "الكل" counted components whose module had no chip, so the chips could
  ///     never sum to the total — the 14 / 0 / 1 on the add-widget screen.
  ///  2. Widgets for modules the account does not have were listed and could be
  ///     added to the home layout at all.
  ///
  /// Both are the same gap, so both close here: the entitlement filter now
  /// applies to the components themselves, and the counts derive from the
  /// filtered list. A component with no module is kept — it belongs to no
  /// module, so no grant can exclude it, and it is counted under "الكل" only.
  List<HomeComponentModel> get _grantedComponents {
    final Set<Modules>? allowed = _allowedModules;
    if (allowed == null) return _allComponents;

    return _allComponents.where((m) {
      final Modules? module = m.component.module;
      return module == null || allowed.contains(module);
    }).toList();
  }

  /// Components for the active tab: plain widgets on tab 0, charts on tab 1.
  /// Both come from the same readyToAddComponent list, so a chart is added to
  /// the layout by exactly the same AddComponentWrapper flow as a widget.
  List<HomeComponentModel> get _tabComponents => _grantedComponents
      .where((m) => m.component.isChart == (selectedTab == 1))
      .toList();

  Map<Modules, int> _countsFor(List<HomeComponentModel> models) {
    final counts = <Modules, int>{};
    for (final model in models) {
      final module = model.component.module;
      if (module == null) continue;
      counts[module] = (counts[module] ?? 0) + 1;
    }
    return counts;
  }

  /// Widgets per module. Counted off [_grantedComponents], not
  /// [_allComponents], so the chips and the "الكل" total describe the same set.
  Map<Modules, int> get _widgetCounts => _countsFor(
      _grantedComponents.where((m) => !m.component.isChart).toList());

  /// Charts per module.
  Map<Modules, int> get _chartCounts =>
      _countsFor(_grantedComponents.where((m) => m.component.isChart).toList());

  /// Counts for whichever tab is showing — the chips describe what you're
  /// actually looking at.
  Map<Modules, int> get _activeCounts =>
      selectedTab == 0 ? _widgetCounts : _chartCounts;

  int get _activeTotal => _tabComponents.length;

  /// Modules that (a) the employee's role actually has and (b) own at least one
  /// widget or chart. Deliberately spans BOTH tabs so the chip row doesn't
  /// reshuffle when you switch between Widget and Chart & Graph.
  List<Modules> get _filterModules {
    final Set<Modules> withContent = {
      ..._widgetCounts.keys,
      ..._chartCounts.keys,
    };

    if (!Get.isRegistered<AppDrawerCubit>()) return withContent.toList();

    final List<Modules> allowed =
        Get.find<AppDrawerCubit>().allowedDrawerModules;
    // Entitlement unknown — mirror [_grantedComponents] and show everything
    // that has content rather than collapsing the row to nothing.
    if (allowed.isEmpty) return withContent.toList();

    // Keep the drawer's ordering so the chips match the rail the user knows.
    return allowed.where(withContent.contains).toList();
  }

  /// Chart family of a chart component, for the Chart & Graph tab's filter.
  /// (Charts belong to no module until the gear picks one, so filtering them by
  /// module showed 0 on every chip — Moataz 24/10/2026.)
  static String _chartFamily(HomeComponents c) {
    switch (c) {
      case HomeComponents.pieChart:
      case HomeComponents.donutChart:
      case HomeComponents.radialBarChart:
      case HomeComponents.gaugeChart:
        return 'circular';
      case HomeComponents.tableChart:
        return 'table';
      case HomeComponents.lineChart:
        return 'line';
      default:
        return 'bars';
    }
  }

  List<HomeComponentModel> get _visibleComponents {
    if (selectedModuleKey == _allKey) return _tabComponents;
    if (selectedTab == 1) {
      return _tabComponents
          .where((m) => _chartFamily(m.component) == selectedModuleKey)
          .toList();
    }
    return _tabComponents
        .where((m) => m.component.module?.name == selectedModuleKey)
        .toList();
  }

  // ── Filter chips ──────────────────────────────────────────────────────────

  /// Uses the shared StatusChipFilter (core/custom/8-custom_filter_app.dart) so
  /// this page's filter looks and behaves like every other filter in the app.
  Widget _moduleFilter() {
    if (selectedTab == 1) return _chartTypeFilter();
    final modules = _filterModules;

    // Nothing to filter by — don't take up a row for a lone "All" chip.
    if (modules.isEmpty) return const SizedBox.shrink();

    final counts = _activeCounts;

    return StatusChipFilter(
      selectedKey: selectedModuleKey,
      onSelected: (key) => setState(() => selectedModuleKey = key),
      items: [
        StatusChipItem(
          key: _allKey,
          label: S.of(context).all,
          count: _activeTotal,
        ),
        ...modules.map(
          (module) => StatusChipItem(
            key: module.name,
            label: module.getModuleName,
            count: counts[module] ?? 0,
          ),
        ),
      ],
    );
  }

  /// The Chart & Graph tab's filter: by KIND of chart (bars / circular / table),
  /// which is what distinguishes one chart card from another.
  Widget _chartTypeFilter() {
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final List<HomeComponentModel> charts = _tabComponents;
    int n(String f) =>
        charts.where((m) => _chartFamily(m.component) == f).length;
    return StatusChipFilter(
      selectedKey: selectedModuleKey,
      onSelected: (key) => setState(() => selectedModuleKey = key),
      items: [
        StatusChipItem(
            key: _allKey, label: S.of(context).all, count: charts.length),
        StatusChipItem(
            key: 'bars', label: ar ? 'أعمدة' : 'Bars', count: n('bars')),
        StatusChipItem(
            key: 'line', label: ar ? 'خطي' : 'Line', count: n('line')),
        StatusChipItem(
            key: 'circular',
            label: ar ? 'دائري' : 'Circular',
            count: n('circular')),
        StatusChipItem(
            key: 'table', label: ar ? 'جدول' : 'Table', count: n('table')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // CHANGED 23/8/2026: was
    // `EdgeInsetsDirectional.only(start: isTablet ? 30.sp : 15.sp, end: 15.sp)`
    // — one flat 15.sp on both sides now, so the leading edge is the same on
    // phone and tablet and every child starts from the same line. `isTablet`
    // went with that breakpoint (its only reader), along with an already-unused
    // `lightMode` local.
    //
    // Horizontal only, deliberately: the app bar sits flush at the top as it
    // did before, and the column already ends with its own 20.sp spacer.
    //
    // The cards carry a further inset of their own — AddComponentWrapper pads
    // each one by 12 to reserve room for the gear badge — so the grid sits
    // 15 + 12 from the edge, not 15.
    final bool isMobile = kpIsPhoneLayout(context);

    // CHANGED: the page frame is SideFrameMasterServices — the breadcrumb
    // frame the settings pages use — in place of the hand-built
    // SafeArea > Padding > Column > PaginationAppBar stack. The frame supplies
    // the SafeArea and the 15.sp horizontal inset, so both went with it.
    //
    // THREE segments, and the pop counts are load-bearing. This page is two
    // routes deep (Settings > Home Layout > Adding Widget), and
    // PaginationAppBar encoded that as `length - (i + 1)` pops. The frame takes
    // the callbacks instead, so the same counts are written out: "Settings"
    // pops twice, "Home" once. On phone the frame collapses the trail to the
    // last segment plus a back chevron, which pops once.
    return Scaffold(
        backgroundColor: AppColors.background,
        // WATERMARK 25/8/2026. Wrapped here rather than relying on an ancestor: on
        // the phone branch this page is pushed onto an OUTER navigator, so it is
        // not a descendant of the wrapped HomeResponsivePage. On tablet it is,
        // and the inner layer then hands its child straight back — see the
        // nesting note in watermark_layer.dart.
        body: WatermarkLayer(
          module: Modules
              .settings, // ADDED 28/9/2026 — Home Layout is a settings page
          child: SideFrameMasterServices(
            titleText: S.of(context).settings,
            onFirstTap: () {
              // Two routes deep — Adding Widget and Home Layout both come off.
              Navigator.of(context)
                ..pop()
                ..pop();
            },
            secondTitle: S.of(context).homeLayout,
            onSecondTap: () => Navigator.of(context).maybePop(),
            thirdTitle: S.of(context).addingWidget,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _expandOnTablet(
                  isMobile: isMobile,
                  child: Column(
                    // A Column centres its children by default, and the
                    // Wrap below sizes to its runs rather than to the full
                    // width — so a row of cards that did not fill the page
                    // sat centred, drifting further from the edge the fewer
                    // widgets a filter left. Start-aligned now (23/8/2026).
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CustomSegmentedTabs (core/custom/9_filter_tab_with_container.dart).
                      // The hand-rolled switcher this replaced wired BOTH
                      // tabs to `selectedTab = 0`, so tapping
                      // "Chart & Graph" just re-opened the Widget tab.
                      Row(
                        // Was MainAxisAlignment.end, which parked the
                        // switcher against the trailing edge while
                        // everything else on the page began at the leading
                        // one (23/8/2026).
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Owner 21/10/2026: our standard two-option toggle (as List | Grid, My Dashboard | HR), not hand-set tabs.
                          CustomSegmentedToggle(
                            tabs: [
                              S.of(context).widget,
                              S.of(context).chartGraph,
                            ],
                            selectedIndex: selectedTab,
                            // Back to "All": the two tabs filter by different things.
                            onChanged: (index) => setState(() {
                              selectedTab = index;
                              selectedModuleKey = _allKey;
                            }),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.sp),

                      // Module filter and the Widget / Chart & Graph
                      // switcher both start at the leading edge. The filter
                      // stays visible on both tabs and applies to charts too.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: _moduleFilter()),
                        ],
                      ),
                      SizedBox(height: 12.w),

                      // Owner 23/10/2026: the toggle and the filter stay
                      // pinned; only the cards scroll under them.
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: const ScrollBehavior()
                              .copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeInOut,
                              switchOutCurve: Curves.easeInOut,
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.05, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              // Both tabs render the same way — charts are just
                              // components whose isChart flag is true — so tapping
                              // a chart runs the identical AddComponentWrapper
                              // flow (editComponent + pop back to Home Layout)
                              // that tapping a widget does.
                              // 18/10/2026 (Moataz): every card in the picker is
                              // the SAME cell as on the home grid — one width, one
                              // height, one even gap — so nothing spreads out.
                              child: LayoutBuilder(
                                key: ValueKey(
                                    'tab${selectedTab}_$selectedModuleKey'),
                                builder: (context, constraints) {
                                  // D-242: a settings change on a card redraws
                                  // the picker (the cubit holds the draft).
                                  return BlocBuilder<AppHomeCubit, HomeState>(
                                    buildWhen: (HomeState p, HomeState c) =>
                                        c is HomeEditingComponent,
                                    builder: (BuildContext _, HomeState __) =>
                                        PackedWrap(
                                      // 23/10/2026 (Moataz): rows are packed — a
                                      // card that fits beside the last one moves
                                      // up, so no row ends in a blank strip, on
                                      // All and on every module filter.
                                      // Tablet: every card keeps 12 badge room on top and end, so
                                      // gap − 12 shows 16 between cards (as on Home Layout).
                                      runSpacing:
                                          HomeCardMetrics.gapBesideBadge,
                                      spacing: HomeCardMetrics.gapBesideBadge,
                                      children: [
                                        for (HomeComponentModel componentModel
                                            in _visibleComponents)
                                          // Owner 23/10/2026: what you see here is what you
                                          // get on Home Layout — the SAME path as the editor
                                          // (own width, card height, scaled whole on a phone),
                                          // on every device.
                                          AddComponentWrapper(
                                            model: componentModel,
                                            component:
                                                HomeCardMetrics.heightBox(
                                              capWidth: false,
                                              height: HomeCardMetrics
                                                  .chartHeightFor(
                                                      componentModel.component),
                                              child: componentModel.component
                                                      .widget(componentModel) ??
                                                  const SizedBox.shrink(),
                                            ),
                                          )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.sp,
                )
              ],
            ),
          ),
        ));
  }

  /// [child] in an [Expanded] on tablet, as-is on phone.
  ///
  /// SideFrameMasterServices hands its child UNBOUNDED height on phone — the
  /// child sits inside the frame's own SingleChildScrollView — so an Expanded
  /// there throws. On tablet the frame wraps the child in an Expanded itself,
  /// and the pinned layout keeps working unchanged.
  Widget _expandOnTablet({
    required bool isMobile,
    required Widget child,
  }) =>
      // Phone: bounded to the page (as Home Layout does) so the toggle and
      // the filter above stay put and only the cards scroll.
      isMobile ? SideFrameBoundedBody(child: child) : Expanded(child: child);
}

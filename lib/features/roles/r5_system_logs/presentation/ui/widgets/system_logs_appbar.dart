/// Module: roles / r5_system_logs / presentation / ui / widgets
///
/// ************************ FILE INFO ******************** ///
/// FILE NAME: system_logs_appbar.dart
/// Description: this file contains the system logs appbar.
/// Author: Amr Mesbah
/// Created at: 2/2/2025
/// Updated: 12/8/2026 - Rebuilt on the core widgets (AppSearchTextField,
///          CustomFilterIcon, CustomDropdown, customButtonWithSvg). The
///          hand-rolled GestureDetector + Container buttons — one pair per
///          platform, each with its own sizes, colours and haptics — are gone.
/// Updated: 30/8/2026 - The Sort control is now the same button + anchored
///          dropdown the User Access screen uses
///          (`r3_user_access/.../search_and_filter.dart`), instead of
///          `CustomDropdown`. Picking the active option again clears the sort.
/// Updated: 30/8/2026 - The Export button's size is asked for through
///          `fixedWidth` / `fixedHeight`; the `width` / `height` it passed
///          before are ignored by `customButtonWithSvg` by design.
/// Updated: 9/10/2026 - Time Tracker phase 6: a Module menu (same button +
///          anchored menu as Sort) so the tablet screen can show one module's
///          logs (e.g. Time Tracker). The screen had no filter at all.
library;

import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_toolbar_action_button.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/ui/pages/system_logs_export_page.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/ui/widgets/system_logs_filter_dialog.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
// ADDED 30/8/2026: the Sort button and its menu rows, same as User Access.
import 'package:knowticed_plus/core/constants/app_assets.dart';

import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/helpers/constants/system_logs_constants.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
// ADDED 9/10/2026 — the Module menu's labels.

/// Was a StatefulWidget carrying three mutable public fields
/// (`isFilterDataShow`, `delayValue`, `roleValue`) that `build` reassigned
/// through `widget.x = …`. Widgets must be immutable (§17); the mutable state
/// moved into the State below.
class SystemLogsAppBar extends StatefulWidget {
  const SystemLogsAppBar({super.key});

  @override
  State<SystemLogsAppBar> createState() => _SystemLogsAppBarState();
}

class _SystemLogsAppBarState extends State<SystemLogsAppBar> {
  String? delayValue;
  late String? roleValue = AppControllers.systemLogs.status;

  SystemLogsController systemLogsController = AppControllers.systemLogs;

  /// Anchor for the sort dropdown.
  ///
  /// ADDED 30/8/2026 with the port from `CustomDropdown` to `showMenu`. The
  /// menu is positioned from this key's RenderBox measured against the overlay,
  /// so it follows the button in both LTR and RTL with no hardcoded offsets —
  /// same approach as `_SearchAndFilterState._showSortMenu`.
  final GlobalKey _sortButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ContextExtension(context).isPhone;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return BlocBuilder<SystemLogsController, SystemLogsState>(
      bloc: AppControllers.systemLogs,
      builder: (context, state) {
        final controller = AppControllers.systemLogs;

        // Drives both the filter button's fill and its label colour. This used
        // to be a local `isFilterDataShow` flag that flipped on every tap
        // regardless of whether a filter was actually applied.

        return Padding(
          padding: EdgeInsets.only(bottom: isPortrait ? 0.01.h : 0.02.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: isPortrait
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            spacing: ButtonSizing.toolbarGap(context),
            children: <Widget>[
              AppSearchTextField(
                controller: controller.searchController,
                onChanged: (value) {
                  controller.searchAndFilterLogs();
                },
              ),

              if (!isMobile) _sortButton(isPortrait),

              // CHANGED 21/10/2026 (owner: "filter the module is not like
              // this"): his Figma 3944:61314 has the house Filter button,
              // opening the Filter pop-up (Module, Action, Role, Employee,
              // Country, City, From / To) — not a Module menu.
              if (!isMobile)
                CustomFilterIcon(
                  title: S.of(context).filter,
                  active: controller.isThereFilter(),
                  onTap: () => SystemLogsFilterDialog.show(context),
                ),

              // Empty title on mobile makes customButtonWithSvg render the
              // 38.sp icon-only variant, so the two hand-built export buttons
              // collapse into this one call.
              customButtonWithSvg(
                // FIXED 30/8/2026: was `width: 200.sp, height: 38.sp`, which
                // this button ignored — `customButtonWithSvg` declares `width`
                // and `height` only to swallow the stale values dozens of old
                // call sites still pass, so the app-wide `ButtonSizing` rule
                // (135.sp wide on tablet, 38.sp on mobile) can hold. The
                // opt-in escape hatch for a call site that really is pinned to
                // a size is `fixedWidth` / `fixedHeight`, so the 200 is asked
                // for through those and is honoured.
                //
                // On mobile the title is empty, which selects the icon-only
                // variant — that one is square, and `fixedWidth` sets its side,
                // so the 200 is deliberately not applied there.
                // Owner 21/10/2026: same width / height / icon / text as Sort and Filter.
                fixedWidth: isMobile ? null : ToolbarStyle.labelledWidth,
                fixedHeight: ButtonSizing.height,
                title: isMobile ? '' : S.of(context).export,
                // NOTE 9/9/2026: this appbar is tablet/desktop only — on a
                // phone `SystemLogsTable` renders the Figma export form as the
                // whole tab instead of this table, so nothing here is
                // reachable there.
                // CHANGED 21/10/2026 (X-112, owner "the export is not like
                // this way in Figma"): his two-page export, not the
                // file-name-only dialog.
                function: () => SystemLogsExportPage.open(context),
                textStyle: ToolbarStyle.label(AppColors.textButton),
                color: AppColors.primary,
                image: AppAssets.export,
                widthImage: ToolbarStyle.iconSize,
                heightImage: ToolbarStyle.iconSize,
                svgColor: AppColors.textButton,
                colorBorder: AppColors.transparent,
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Sort ───────────────────────────────────────────────────────────────────
  //
  // PORTED 30/8/2026 from `_SearchAndFilterState` (r3_user_access) so both
  // screens present one sort control. This used to be a `CustomDropdown`: a
  // form field dressed up as a button, carrying a hint just to keep the word
  // "Sort" on a control that was never a form field, and styled by the dropdown
  // rather than by this screen.
  //
  // It also mixed the two lists up. `value:` was fed `controller.sortValue` —
  // a stable English key from `SystemLogsConstants.sortList` — while `items:`
  // were built from `sortListInArabic`, the localized labels. The two match
  // only under English, so under Arabic the dropdown could never show the
  // active option and fell back to the hint. The menu below keeps the key as
  // the value and the label as the text, which is what the two parallel lists
  // are for.

  /// Whether a sort is active. Drives the button's fill, exactly as
  /// `_sortSelected` does on the User Access screen.
  bool get _sortSelected => systemLogsController.sortValue != null;

  // Owner 21/10/2026: Sort is the house toolbar button — same width, height, icon size and text as the Filter beside it.
  Widget _sortButton(bool isPortrait) {
    return KeyedSubtree(
      key: _sortButtonKey,
      child: CustomToolbarActionButton(
        svgPath: AppAssets.sort,
        label: S.of(context).Sort,
        fill: AppColors.card,
        active: _sortSelected,
        contentColor: ToolbarStyle.contentColor,
        haptic: ToolbarHaptic.low,
        onTap: _showSortMenu,
        labelledWidth: ToolbarStyle.labelledWidth,
      ),
    );
  }

  /// The sort menu, anchored under the button and at least as wide as it.
  ///
  /// `minWidth`, not `tightFor`: the option labels ("First Name" / "Last Name",
  /// and their longer Arabic forms) must show in full, never ellipsised, so the
  /// menu is allowed to grow past the button.
  Future<void> _showSortMenu() async {
    final BuildContext? buttonContext = _sortButtonKey.currentContext;
    if (buttonContext == null) return;

    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final Size buttonSize = button.size;
    final Offset topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);

    // 4px of breathing room so the menu reads as attached to the button
    // without touching it.
    const double gap = 4.0;

    final RelativeRect position = RelativeRect.fromLTRB(
      topLeft.dx,
      topLeft.dy + buttonSize.height + gap,
      overlay.size.width - (topLeft.dx + buttonSize.width),
      0,
    );

    // The two lists are index-aligned by contract (see SystemLogsConstants):
    // `sortList[i]` is the stable key `sortLogs` switches on, and
    // `sortListInArabic[i]` is its label in the active locale. Both are read
    // once here so a locale change mid-loop cannot skew the pairing.
    final List<String> keys = SystemLogsConstants.sortList;
    final List<String> labels = SystemLogsConstants.sortListInArabic;

    final String? selected = await showMenu<String>(
      context: context,
      position: position,
      color: AppColors.card,
      constraints: BoxConstraints(minWidth: buttonSize.width),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      // The selected row is painted edge to edge, so the menu does the
      // rounding and gives up its default vertical list padding — otherwise a
      // strip of `AppColors.card` shows above and below the fill and the row
      // reads as unfilled.
      clipBehavior: Clip.antiAlias,
      menuPadding: EdgeInsets.zero,
      items: <PopupMenuEntry<String>>[
        for (int i = 0; i < keys.length; i++)
          _sortMenuItem(keys[i], i < labels.length ? labels[i] : keys[i]),
      ],
    );

    if (selected == null) return;

    // selectSortOption, not sortLogs: picking the row that is already active
    // clears the sort, and only `selectSortOption` knows that. `sortLogs` would
    // re-apply the same order instead.
    systemLogsController.selectSortOption(selected);
  }

  /// One row of the sort dropdown — same treatment as the User Access screen:
  /// the active option is a full-width primary fill with on-primary text, and
  /// there is no tick, so every row is the same width.
  ///
  /// Parameters:
  /// - [sortKey]: the stable English key from `SystemLogsConstants.sortList`.
  /// - [label]: that key's label in the active locale.
  PopupMenuItem<String> _sortMenuItem(String sortKey, String label) {
    final bool isSelected = systemLogsController.sortValue == sortKey;

    return PopupMenuItem<String>(
      value: sortKey,
      height: 40.h,
      padding: EdgeInsets.zero,
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        alignment: AlignmentDirectional.centerStart,
        color: isSelected ? AppColors.primary : AppColors.transparent,
        child: Row(
          // Stretches the fill across the menu. The menu measures its width
          // from its children's INTRINSIC width, so the row must not be given
          // an explicit `double.infinity` — that makes the measurement
          // unbounded and throws at layout.
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              label,
              style: StyleText.fontSize14Weight500.copyWith(
                color: isSelected ? AppColors.textButton : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

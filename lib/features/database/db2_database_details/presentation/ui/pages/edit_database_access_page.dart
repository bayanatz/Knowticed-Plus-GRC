/// Module: database / db2_database_details / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: edit_database_access_page.dart
/// Description: Declares `EditDatabaseAccessPage`.
/// Author: Amr Mesbah
/// Created at: 16/8/2026
///
/// "Database > Database Name > Editing Database Access" — all THREE Figma
/// variants in one file, because the access type is a dropdown at the top of
/// the same card rather than three separate destinations:
///
///   OPEN        7398:9476 (iPad V) / 7398:9790 (iPad H)
///               department multi-select, chips, one permission + window per
///               department, employee grid, "Review".
///   RESTRICTED  7398:10176 cards / 7398:10331 list (iPad V)
///               search + department filter, a list/grid toggle, and each
///               person's OWN window and level. "Grant Access".
///   PERSONAL    7398:10612
///               the dropdown and nothing else. "Save".
///
/// One page, not three: the dropdown that chooses between them is on this
/// screen, and the three frames are the same card with a different middle.
/// Both iPad orientations share it; `MemberGrid` reflows below 900px.
library;

import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_confirm_dialog.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_view_mode_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_cubit.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/access_rule_fields.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_actions.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/member_grid.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/controller/edit_database_access_cubit.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/widgets/database_details_metrics.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/widgets/member_access_rule_list.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/widgets/database_details_strings.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/database_enum_labels.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/widgets/edit_database_access_page/department_chips.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/widgets/edit_database_access_page/picked_avatar_row.dart';

part '../widgets/edit_database_access_page/edit_database_access_page_builders.dart';

class EditDatabaseAccessPage extends StatefulWidget {
  const EditDatabaseAccessPage({
    super.key,
    required this.cubit,
    required this.onReview,
    required this.onCompleted,
    required this.onExit,
  });

  /// Provided by the flow host, not created here — the draft has to survive
  /// the review screen being pushed and popped.
  final EditDatabaseAccessCubit cubit;

  /// "Review" — pushes the per-department review screen (Open only).
  final VoidCallback onReview;

  /// A finished save. Carries the refreshed record back to the Access screen.
  final ValueChanged<DatabaseEntity> onCompleted;

  /// Leaves the editor without saving.
  ///
  /// Wired by the flow host: `Navigator.of(context)` here resolves to the
  /// flow's INNER navigator, which can only move between steps. Leaving means
  /// popping the route the Access screen pushed, one level up.
  final VoidCallback onExit;

  @override
  State<EditDatabaseAccessPage> createState() => _EditDatabaseAccessPageState();
}

class _EditDatabaseAccessPageState extends State<EditDatabaseAccessPage> {
  /// Lets this screen's builder/logic extensions refresh it (setState
  /// itself may only be called inside the State class).
  void rebuild(VoidCallback fn) => setState(fn);

  final TextEditingController _search = TextEditingController();

  /// The list/grid toggle on the Restricted variant (Figma 7398:10176 grid,
  /// 7398:10331 list). Widget state: nothing saved depends on it.
  bool _tableView = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ── Access type ──────────────────────────────────────────────────────────

  /// Changing the dropdown clears the current picks (see
  /// `EditDatabaseAccessCubit.accessTypeChanged`), so it asks first whenever
  /// something would be lost.
  Future<void> _onAccessTypeChanged(DatabaseAccessType value) async {
    final CreateDatabaseState state = widget.cubit.state;
    if (state.accessType == value) return;

    if (state.grants.isEmpty) {
      widget.cubit.accessTypeChanged(value);
      return;
    }

    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);

    // Switching TO Personal is a different sentence from switching between the
    // other two: it is the only one that ends with nobody having access, so it
    // is worded as a revocation rather than as losing a selection.
    final bool toPersonal = value == DatabaseAccessType.personal;

    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: toPersonal
          ? strings.personalDropsGrantsTitle
          : strings.accessTypeChangeTitle,
      subtitle: toPersonal
          ? strings.personalDropsGrants(state.totalEmployees)
          : strings.accessTypeChangeSubtitle(state.totalEmployees),
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    widget.cubit.accessTypeChanged(value);
  }

  // ── Primary action ───────────────────────────────────────────────────────

  /// What the primary button does depends on the variant, because the Figma
  /// gives the three different labels for three different next steps: Open
  /// reviews per department, Restricted grants straight away (every rule is
  /// already on screen), Personal just saves.
  Future<void> _onPrimaryPressed() async {
    final CreateDatabaseState state = widget.cubit.state;
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);

    switch (state.accessType) {
      case DatabaseAccessType.open:
        // Granting access to nobody is a mis-tap, not an intention.
        if (state.allMembers.isEmpty) {
          await showWarningDialog(
            context: context,
            title: strings.incompleteTitle,
            subtitle: strings.pickSomeoneFirst,
            closeLabel: strings.close,
          );
          return;
        }
        widget.onReview();
        return;

      case DatabaseAccessType.restricted:
        if (state.allMembers.isEmpty) {
          if (!context.mounted) return;
          await showWarningDialog(
            context: context,
            title: strings.incompleteTitle,
            subtitle: strings.pickSomeoneFirst,
            closeLabel: strings.close,
          );
          return;
        }
        // Every person's window and level is edited on THIS screen, so this is
        // where they are checked — there is no review step to catch it later.
        if (!widget.cubit.individualRulesComplete) {
          if (!context.mounted) return;
          await showWarningDialog(
            context: context,
            title: strings.incompleteTitle,
            subtitle: strings.incompleteRows,
            closeLabel: strings.close,
          );
          return;
        }
        await _confirmAndSave();
        return;

      case DatabaseAccessType.personal:
      case null:
        await _confirmAndSave();
        return;
    }
  }

  Future<void> _confirmAndSave() async {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);

    await showConfirmDialog(
      context: context,
      title: strings.editConfirmTitle,
      subtitle: strings.editConfirmSubtitle,
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => widget.cubit.saveAccess(),
    );
  }

  /// "Discard Changes" leaves the editor. Unlike the Editing Database card —
  /// where Discard is the form's undo and Save sits next to it — this screen's
  /// footer pairs it with the action that finishes the edit, and the Figma
  /// draws no third control. So it means "abandon", and it asks before
  /// throwing away picks.
  Future<void> _onDiscardPressed() async {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);

    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: strings.discardConfirmTitle,
      subtitle: strings.discardConfirmSubtitle,
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    widget.onExit();
  }

  /// Reports the write once and then clears the flag, so a rebuild cannot
  /// re-open either dialog.
  Future<void> _onStateChanged(
    BuildContext context,
    CreateDatabaseState state,
  ) async {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);

    if (state.status == CreateDatabaseStatus.failure &&
        state.errorMessage != null) {
      // Cleared BEFORE the await: leaving the failure live while the dialog is
      // open re-opens it on the next emission.
      final String message = state.errorMessage!;
      widget.cubit.clearMessages();
      await showErrorDialog(
        context: context,
        title: strings.errorTitle,
        subtitle: message,
        closeLabel: strings.close,
      );
      return;
    }

    if (state.status == CreateDatabaseStatus.success) {
      if (!context.mounted) return;
      await showSuccessDialog(
        context: context,
        title: strings.accessSavedTitle,
        subtitle: strings.accessSavedSubtitle,
        closeLabel: strings.close,
      );
      if (!mounted) return;
      final DatabaseEntity? saved = state.createdDatabase;
      if (saved != null) widget.onCompleted(saved);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final CreateDatabaseMetrics metrics = CreateDatabaseMetrics.of(context);
    final DatabaseDetailsMetrics details = DatabaseDetailsMetrics.of(context);
    final String title = FormatHelper.capitalize(
      widget.cubit.database.localizedTitle(isArabic: context.isArabic),
    );

    return BlocConsumer<CreateDatabaseCubit, CreateDatabaseState>(
      bloc: widget.cubit,
      listener: _onStateChanged,
      builder: (BuildContext context, CreateDatabaseState state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SideFrameMasterServices(
            // Three crumbs at 1024, two at 768 — see
            // `DatabaseDetailsMetrics.showRootCrumb` for why the design drops
            // the root one at the narrower width. Both spellings exit the
            // editor, so nothing is unreachable at either size.
            titleText: details.showRootCrumb ? strings.database : title,
            secondTitle:
                details.showRootCrumb ? title : strings.editingDatabaseAccess,
            thirdTitle:
                details.showRootCrumb ? strings.editingDatabaseAccess : null,
            onFirstTap: widget.onExit,
            onSecondTap: widget.onExit,
            // SideFrameMasterServices hands its child a BOUNDED height on
            // tablet, so a fixed Column overflows the moment the member list
            // is one pixel taller than the viewport. `pageScroll` is the
            // shared fix — and on a phone it hands the child straight through,
            // because that shell is already a scroll view.
            child: CreateDatabaseMetrics.pageScroll(
              context,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: metrics.extraHorizontalInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: metrics.cardPadding,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(metrics.cardRadius),
                        boxShadow: CardStyles.shadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _accessTypeField(state, strings),
                          SizedBox(height: metrics.blockGap),
                          _variant(state, strings, metrics),
                        ],
                      ),
                    ),
                    SizedBox(height: metrics.cardToActions),
                    CreateDatabaseActions(
                      metrics: metrics,
                      discardLabel: strings.discardChanges,
                      primaryLabel: _primaryLabel(state, strings),
                      onDiscard: _onDiscardPressed,
                      onPrimary: _onPrimaryPressed,
                      isSubmitting: state.isSubmitting,
                    ),
                    SizedBox(height: metrics.blockGap),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _primaryLabel(
    CreateDatabaseState state,
    DatabaseDetailsStrings strings,
  ) {
    switch (state.accessType) {
      case DatabaseAccessType.open:
        return strings.review;
      // "Save", not "Grant Access" (Figma 7398:10512 / 7398:10230): this
      // saves a change to access that already exists.
      case DatabaseAccessType.restricted:
      case DatabaseAccessType.personal:
      case null:
        return strings.save;
    }
  }

  /// The Access Management dropdown, half width on tablet — the same width as
  /// one column of the create card's title row, so it lines up with everything
  /// else in the module. `buildResponsiveFields` with an empty right slot is
  /// what produces that without a magic number.
  Widget _accessTypeField(
    CreateDatabaseState state,
    DatabaseDetailsStrings strings,
  ) {
    return buildResponsiveFields(
      context: context,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(strings.accessManagement, style: _labelStyle),
          SizedBox(height: 6.h),
          CustomDropdown<DatabaseAccessType>(
            value: state.accessType,
            hint: strings.accessManagement,
            fillColor: _fieldFill,
            enabled: !state.isSubmitting,
            borderRadius: BorderRadius.circular(4.r),
            valueStyle: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text,
            ),
            itemStyle: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text,
            ),
            items: DatabaseAccessType.values
                .map(
                  (DatabaseAccessType type) => DropdownItem<DatabaseAccessType>(
                    value: type,
                    label: type.label(S.current),
                  ),
                )
                .toList(growable: false),
            onChanged: _onAccessTypeChanged,
          ),
        ],
      ),
      right: const SizedBox.shrink(),
    );
  }

  Widget _variant(
    CreateDatabaseState state,
    DatabaseDetailsStrings strings,
    CreateDatabaseMetrics metrics,
  ) {
    if (state.isLoadingDirectory) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        // `CircleProgressMaster` centres itself and sizes off the shortest
        // side, so it replaces the Center as well as the indicator.
        child: const CircleProgressMaster(),
      );
    }

    switch (state.accessType) {
      case DatabaseAccessType.open:
        return _openBody(state, strings, metrics);
      case DatabaseAccessType.restricted:
        return _restrictedBody(state, strings, metrics);
      case DatabaseAccessType.personal:
      case null:
        return _personalBody(strings);
    }
  }

  // ── Personal (7398:10612) ────────────────────────────────────────────────

  /// The Figma leaves this card empty below the dropdown. An empty white card
  /// reads as a screen that failed to load, so the empty state says what it
  /// MEANS instead of saying nothing.
  Widget _personalBody(DatabaseDetailsStrings strings) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Text(
        strings.personalAccessExplainer,
        style: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.secondaryText,
        ),
      ),
    );
  }

  bool _allVisibleSelected(CreateDatabaseState state) {
    final List<DatabaseMember> visible = state.visibleEmployees;
    if (visible.isEmpty) return false;
    return visible.every(state.isMemberSelected);
  }

  /// The department FILTER on the Restricted screen — single-select with an
  /// "All" row. Narrowing a list is a different job from choosing who gets
  /// access, which is why this is a plain dropdown and the Open screen's is a
  /// multi-select.
  Widget _departmentFilter(
    CreateDatabaseState state,
    DatabaseDetailsStrings strings,
  ) {
    // Sentinel for the "All" row: DropdownItem's value is non-nullable, so a
    // null option cannot be expressed directly.
    const String allSentinel = '';

    return CustomDropdown<String>(
      height: 38,
      borderRadius: BorderRadius.circular(8.r),
      value: state.selectedDepartmentId ?? allSentinel,
      hint: strings.department,
      fillColor: _fieldFill,
      valueStyle: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      itemStyle: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      items: <DropdownItem<String>>[
        DropdownItem<String>(value: allSentinel, label: strings.all),
        ...state.departments.map(
          (DatabaseDepartment dept) => DropdownItem<String>(
            value: dept.id,
            label: dept.localizedName(isArabic: context.isArabic),
          ),
        ),
      ],
      onChanged: (String value) =>
          widget.cubit.departmentSelected(value == allSentinel ? null : value),
    );
  }

  // ── Shared ───────────────────────────────────────────────────────────────

  /// The page colour — `CustomDropdown`'s own default fill — so the search box
  /// and the dropdowns match by construction rather than by two independent
  /// choices, and the theme map handles light/dark instead of an `isDark`
  /// branch here.
  Color get _fieldFill => AppColors.background;

  TextStyle get _labelStyle =>
      StyleText.fontSize14Weight500.copyWith(color: AppColors.text);
}

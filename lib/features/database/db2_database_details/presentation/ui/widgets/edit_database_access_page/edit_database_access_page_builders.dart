/// Module: database/db2_database_details
///
///*************************** FILE INFO ****************************///
/// File Name: edit_database_access_page_builders.dart
/// Description: UI builder methods of `_EditDatabaseAccessPageState` — split out of `edit_database_access_page.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/edit_database_access_page.dart';

// Split from edit_database_access_page.dart to keep every file under 700 lines.

extension _EditDatabaseAccessPageStateBuilders on _EditDatabaseAccessPageState {
  // ── Open (7398:9476 / 9790) ──────────────────────────────────────────────

  Widget _openBody(
    CreateDatabaseState state,
    DatabaseDetailsStrings strings,
    CreateDatabaseMetrics metrics,
  ) {
    // The rule shown belongs to the department in focus, so a department with
    // nobody picked yet still has fields to fill.
    final DatabaseAccessGrant grant = (state.selectedDepartmentId == null
            ? state.individualGrant
            : state.grantForDepartment(state.selectedDepartmentId!)) ??
        const DatabaseAccessGrant(members: <DatabaseMember>[]);

    // Every pick on this screen belongs to the department in FOCUS — that
    // scoping is what gives the review screen its per-department tabs. With no
    // department picked there is nowhere for a selection to go: the inherited
    // `toggleMember` would file people into an individual grant, the review
    // screen only renders department-scoped ones, and the user would be told
    // to "select at least one person" with a dozen already ticked. So the
    // grid is held back until there is a department to put them in.
    final bool hasDepartment = state.selectedDepartmentId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(strings.department, style: _labelStyle),
        SizedBox(height: 6.h),
        buildResponsiveFields(
          context: context,
          left: CustomMultiSelectFilter<String>(
            borderRadius: BorderRadius.circular(8.r),
            values: state.selectedDepartmentIds,
            hint: strings.department,
            // Same rule as the wizard's Department field (16/8/2026): the chip
            // row below is the list of picks, so the trigger keeps its label
            // instead of ellipsising a copy of them.
            alwaysShowHint: true,
            fillColor: _fieldFill,
            valueStyle: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text,
            ),
            itemStyle: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text,
            ),
            items: state.departments
                .map(
                  (DatabaseDepartment dept) => MultiSelectDropdownItem<String>(
                    value: dept.id,
                    label: dept.localizedName(isArabic: context.isArabic),
                  ),
                )
                .toList(growable: false),
            onChanged: widget.cubit.departmentsChanged,
          ),
          right: const SizedBox.shrink(),
        ),
        SizedBox(height: 10.h),

        // Only the PICKED departments become chips — the Figma shows
        // "Marketing / Design / Finance" under a field reading "Marketing",
        // not the whole org chart.
        EditAccessDepartmentChips(
          departments: state.selectedDepartments,
          selectedId: state.selectedDepartmentId,
          onSelected: widget.cubit.departmentSelected,
        ),
        SizedBox(height: metrics.blockGap),

        // db1's block, unchanged: Permissions + the two dates, already wired
        // to apply to one department when given a `departmentId`. The editing
        // screen needs exactly the same control, so it uses exactly the same
        // widget rather than a copy that could drift on spacing or on the
        // end-before-start guard.
        AccessRuleFields(
          grant: grant,
          enabled: hasDepartment && !state.isSubmitting,
          onPermissionChanged: (DatabasePermissionLevel level) =>
              widget.cubit.permissionChanged(
            level,
            departmentId: state.selectedDepartmentId,
          ),
          onStartDateChanged: (DateTime date) => widget.cubit.startDateChanged(
            date,
            departmentId: state.selectedDepartmentId,
          ),
          onEndDateChanged: (DateTime date) => widget.cubit.endDateChanged(
            date,
            departmentId: state.selectedDepartmentId,
          ),
        ),
        SizedBox(height: metrics.blockGap),

        if (!hasDepartment)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 30.h),
            child: Text(
              strings.pickDepartmentFirst,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          )
        else ...<Widget>[
          Text(strings.employeeInformation, style: _labelStyle),
          SizedBox(height: 6.h),
          Row(
            children: <Widget>[
              // AppSearchTextField's root IS an Expanded, so it goes straight
              // into the Row — wrapping it in another one throws "Competing
              // ParentDataWidgets".
              AppSearchTextField(
                controller: _search,
                hintText: strings.search,
                fillColor: _fieldFill,
                onChanged: widget.cubit.memberSearchChanged,
              ),
              SizedBox(width: ButtonSizing.toolbarGap(context)),
              EditAccessPillButton(
                // The Figma shows "Deselect All", which is the label once
                // everything visible is already in — so the label follows the
                // state rather than being fixed.
                label: _allVisibleSelected(state)
                    ? strings.deselectAll
                    : strings.selectAll,
                onTap: widget.cubit.toggleAllVisible,
              ),
            ],
          ),
          SizedBox(height: metrics.blockGap),
          MemberGrid(
            members: state.visibleEmployees,
            trailing: MemberGridTrailing.check,
            isSelected: state.isMemberSelected,
            onTap: widget.cubit.toggleMember,
            departmentLabel: (DatabaseMember member) => state.departmentNameFor(
              member.departmentId,
              isArabic: context.isArabic,
            ),
          ),
        ],
      ],
    );
  }

  // ── Restricted (7398:10176 cards / 7398:10331 list) ──────────────────────

  Widget _restrictedBody(
    CreateDatabaseState state,
    DatabaseDetailsStrings strings,
    CreateDatabaseMetrics metrics,
  ) {
    final List<DatabaseMember> visible = widget.cubit.filteredEmployees;

    // The section's own measured numbers — field widths, avatar sizes, the
    // person card's geometry. `metrics` above still owns everything the create
    // wizard already measured (card padding, radius, the page inset), which is
    // why both are in scope rather than one wrapping the other.
    final DatabaseDetailsMetrics details = DatabaseDetailsMetrics.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(strings.employeeInformation, style: _labelStyle),
        SizedBox(height: 6.h),

        // Search takes the remainder, the department filter a FIXED 150
        // (7398:10500 / 7398:10220); below 600px the row stacks.
        if (details.isPhone) ...<Widget>[
          Row(
            children: <Widget>[
              AppSearchTextField(
                controller: _search,
                hintText: strings.search,
                fillColor: _fieldFill,
                onChanged: widget.cubit.memberSearchChanged,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _departmentFilter(state, strings),
        ] else
          Row(
            children: <Widget>[
              // AppSearchTextField's root IS an Expanded, so it goes straight
              // into the Row — wrapping it in another one throws "Competing
              // ParentDataWidgets".
              AppSearchTextField(
                controller: _search,
                hintText: strings.search,
                fillColor: _fieldFill,
                onChanged: widget.cubit.memberSearchChanged,
              ),
              SizedBox(width: ButtonSizing.toolbarGap(context)),
              SizedBox(
                width: details.departmentFilterWidth,
                child: _departmentFilter(state, strings),
              ),
              SizedBox(width: ButtonSizing.toolbarGap(context)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  customViewModeButton(
                    mode: ViewMode.list,
                    function: () =>
                        rebuild(() => _tableView = withLowHaptic(true)),
                    isSelected: _tableView,
                  ),
                  SizedBox(width: details.viewToggleGap),
                  customViewModeButton(
                    mode: ViewMode.grid,
                    function: () =>
                        rebuild(() => _tableView = withLowHaptic(false)),
                    isSelected: !_tableView,
                  ),
                ],
              ),
            ],
          ),

        // The list / grid toggle, right-aligned to the card's inner edge
        // (Figma 7398:19230 / 19234 at 768, 7398:10325 / 10329 at 1024 — the
        // 768 CARDS frame simply omits it, the 768 LIST frame has it).
        // `customTableButton` and `customGridButton` are the shared pair, so
        // this toggle is the same 38sp square as every other one in the app.
        SizedBox(height: details.toggleToAvatars),

        // The strip of picked faces with a red remove badge (Figma 7398:10176).
        // Not `StackedAvatars` — that widget overlaps to save space and has no
        // per-avatar affordance; here each face is its own hit target.
        EditAccessPickedAvatarRow(
          metrics: details,
          members: state.allMembers.toList(growable: false),
          onRemove: widget.cubit.toggleIndividualMember,
        ),
        SizedBox(height: metrics.blockGap),

        MemberAccessRuleList(
          metrics: details,
          isTableView: _tableView,
          enabled: !state.isSubmitting,
          rules: visible
              .map(
                (DatabaseMember m) => MemberAccessRule(
                  member: m,
                  grant: widget.cubit.grantForMember(m),
                ),
              )
              .toList(growable: false),
          onToggle: widget.cubit.toggleIndividualMember,
          onPermissionChanged: (DatabaseMember m, DatabasePermissionLevel l) =>
              widget.cubit.memberRuleChanged(m, permission: l),
          onStartDateChanged: (DatabaseMember m, DateTime d) =>
              widget.cubit.memberRuleChanged(m, startDate: d),
          onEndDateChanged: (DatabaseMember m, DateTime d) =>
              widget.cubit.memberRuleChanged(m, endDate: d),
          departmentLabel: (DatabaseMember member) => state.departmentNameFor(
            member.departmentId,
            isArabic: context.isArabic,
          ),
        ),
      ],
    );
  }
}

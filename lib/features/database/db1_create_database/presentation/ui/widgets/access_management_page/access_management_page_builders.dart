/// Module: database/db1_create_database
///
///*************************** FILE INFO ****************************///
/// File Name: access_management_page_builders.dart
/// Description: UI builder methods of `_AccessManagementPageState` — split out of `access_management_page.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/access_management_page.dart';

// Split from access_management_page.dart to keep every file under 700 lines.

extension _AccessManagementPageStateBuilders on _AccessManagementPageState {
  // ── Variant B: By Department (7398:18600) ─────────────────────────────────

  Widget _byDepartmentBody(
    CreateDatabaseState state,
    CreateDatabaseStrings strings,
    CreateDatabaseMetrics metrics,
  ) {
    // NOTHING BELOW THE DROPDOWN UNTIL A DEPARTMENT IS PICKED.
    //
    // The screen used to render its whole body from the moment Open Access was
    // chosen: an empty chip row, a Permissions block and a pair of date fields
    // bound to no department, and the full employee directory with a "Deselect
    // All" button next to it. Filling those fields did nothing that survived —
    // `permissionChanged(departmentId: null)` with no grants has nothing to
    // write to — and "Select All" offered to grant access to the whole company
    // through a screen whose entire job is scoping access to one department.
    //
    // The gate is `selectedDepartmentIds`, not `selectedDepartmentId`: ticking
    // the first department in the multi-select also focuses it (see
    // `CreateDatabaseCubit.departmentsChanged`), so the two are never out of
    // step here, and keying off the list says what the rule actually is —
    // nothing is in play until at least one department is.
    final bool hasDepartment = state.selectedDepartmentIds.isNotEmpty;

    // The access rule shown here belongs to the department in focus, so a
    // department with no one picked yet still has fields to fill.
    final DatabaseAccessGrant grant = (state.selectedDepartmentId == null
            ? state.individualGrant
            : state.grantForDepartment(state.selectedDepartmentId!)) ??
        const DatabaseAccessGrant(members: <DatabaseMember>[]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          strings.department,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
        SizedBox(height: 6.h),
        buildResponsiveFields(
          context: context,
          left: _departmentMultiSelect(state, strings),
          right: const SizedBox.shrink(),
        ),

        // Everything else waits for a pick.
        if (!hasDepartment)
          ...<Widget>[]
        else ...<Widget>[
          SizedBox(height: 10.h),

          // Only the PICKED departments become chips — Figma 7398:18600 shows
          // "Marketing / Design / Finance" under a field reading "Marketing",
          // not the whole org chart. Listing every department here turned the
          // row into a directory and left nothing showing what was chosen.
          DepartmentChips(
            departments: state.selectedDepartments,
            selectedId: state.selectedDepartmentId,
            onSelected: widget.cubit.departmentSelected,
          ),
          SizedBox(height: metrics.blockGap),

          AccessRuleFields(
            grant: grant,
            onPermissionChanged: (level) => widget.cubit.permissionChanged(
              level,
              departmentId: state.selectedDepartmentId,
            ),
            onStartDateChanged: (date) => widget.cubit.startDateChanged(
              date,
              departmentId: state.selectedDepartmentId,
            ),
            onEndDateChanged: (date) => widget.cubit.endDateChanged(
              date,
              departmentId: state.selectedDepartmentId,
            ),
          ),
          SizedBox(height: metrics.blockGap),

          Text(
            strings.employeeInformation,
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 6.h),

          Row(
            children: <Widget>[
              // Already an Expanded internally, so no wrapper here.
              AppSearchTextField(
                controller: _search,
                hintText: strings.search,
                fillColor: _fill,
                onChanged: widget.cubit.memberSearchChanged,
              ),
              SizedBox(width: ButtonSizing.toolbarGap(context)),
              SelectAllButton(
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

          _grid(state, strings),
        ],
      ],
    );
  }
}

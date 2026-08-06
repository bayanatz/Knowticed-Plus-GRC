part of '../pages/custom_csv_table_page.dart';

class _ActiveDirectoryFilterDialog extends StatefulWidget {
  // Options populated from real CSV data
  final List<String> departments;
  final List<String> roles;
  final List<String> titles;
  final List<String> workLocations;
  final List<String> supervisors;
  final List<String> genders;
  final List<String> nationalities;
  final List<String> countries;

  // Pre-populated from controller so re-opening shows last state
  final String? initialDepartment;
  final String? initialRole;
  final String? initialTitle;
  final String? initialWorkLocation;
  final String? initialSupervisor;
  final String? initialGender;
  final String? initialNationality;
  final String? initialCountry;

  const _ActiveDirectoryFilterDialog({
    required this.departments,
    required this.roles,
    required this.titles,
    required this.workLocations,
    required this.supervisors,
    required this.genders,
    required this.nationalities,
    required this.countries,
    this.initialDepartment,
    this.initialRole,
    this.initialTitle,
    this.initialWorkLocation,
    this.initialSupervisor,
    this.initialGender,
    this.initialNationality,
    this.initialCountry,
  });

  @override
  State<_ActiveDirectoryFilterDialog> createState() =>
      _ActiveDirectoryFilterDialogState();
}

class _ActiveDirectoryFilterDialogState
    extends State<_ActiveDirectoryFilterDialog> {
  String? _department;
  String? _role;
  String? _title;
  String? _workLocation;
  String? _supervisor;
  String? _selectedGender;
  String? _selectedNationality;
  String? _country;

  @override
  void initState() {
    super.initState();
    // Restore previous selections
    _department         = widget.initialDepartment;
    _role               = widget.initialRole;
    _title              = widget.initialTitle;
    _workLocation       = widget.initialWorkLocation;
    _supervisor         = widget.initialSupervisor;
    _selectedGender     = widget.initialGender;
    _selectedNationality = widget.initialNationality;
    _country            = widget.initialCountry;
  }

  void _clearFilter() {
    setState(() {
      _department          = null;
      _role                = null;
      _title               = null;
      _workLocation        = null;
      _supervisor          = null;
      _selectedGender      = null;
      _selectedNationality = null;
      _country             = null;
    });
    // Also clear the controller immediately so the table updates live
    Get.find<ActiveDirectoryController>().clearFilters();
  }

  void _applyFilter() {
    Get.find<ActiveDirectoryController>().applyFilters(
      department:   _department,
      role:         _role,
      title:        _title,
      workLocation: _workLocation,
      supervisor:   _supervisor,
      gender:       _selectedGender,
      nationality:  _selectedNationality,
      country:      _country,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal:
        MediaQuery.of(context).size.width > 800 ? 0.2.w : 0.05.w,
        vertical: 0.05.h,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(0.02.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title row with active-filter indicator ────────────────────
            Row(
              children: [
                Text(
                  S.of(context).Filter,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: FontConstants.fontSize018.w,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                // Show how many filters are currently selected
                if (_activeCount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_activeCount ${S.of(context).active}',
                      style: AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: FontConstants.fontSize012.w,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 0.02.h),

            // ── Dropdowns ─────────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _filterRow(
                      label: S.of(context).department,
                      child: _buildDropdown(
                        hintEn: 'Select Departments',
                        hintAr: 'اختر القسم',
                        items: widget.departments,
                        value: _department,
                        onChanged: (v) => setState(() => _department = v),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    _filterRow(
                      label: S.of(context).role,
                      child: _buildDropdown(
                        hintEn: 'Select Role',
                        hintAr: 'اختر الدور',
                        items: widget.roles,
                        value: _role,
                        onChanged: (v) => setState(() => _role = v),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    _filterRow(
                      label: S.of(context).title,
                      child: _buildDropdown(
                        hintEn: 'Select Title',
                        hintAr: 'اختر اللقب',
                        items: widget.titles,
                        value: _title,
                        onChanged: (v) => setState(() => _title = v),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    _filterRow(
                      label: S.of(context).workLocation,
                      child: _buildDropdown(
                        hintEn: 'Select Work Location',
                        hintAr: 'اختر موقع العمل',
                        items: widget.workLocations,
                        value: _workLocation,
                        onChanged: (v) =>
                            setState(() => _workLocation = v),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    _filterRow(
                      label: S.of(context).superVisor,
                      child: _buildDropdown(
                        hintEn: 'Select Supervisor',
                        hintAr: 'اختر المشرف',
                        items: widget.supervisors,
                        value: _supervisor,
                        onChanged: (v) =>
                            setState(() => _supervisor = v),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    _filterRow(
                      label: S.of(context).gender,
                      child: _buildDropdown(
                        hintEn: 'Select Gender',
                        hintAr: 'اختر الجنس',
                        items: widget.genders,
                        value: _selectedGender,
                        onChanged: (v) =>
                            setState(() => _selectedGender = v),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    _filterRow(
                      label: S.of(context).nationality,
                      child: _buildDropdown(
                        hintEn: 'Select Nationality',
                        hintAr: 'اختر الجنسية',
                        items: widget.nationalities,
                        value: _selectedNationality,
                        onChanged: (v) =>
                            setState(() => _selectedNationality = v),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    _filterRow(
                      label: S.of(context).country,
                      child: _buildDropdown(
                        hintEn: 'Select City',
                        hintAr: 'اختر الدولة',
                        items: widget.countries,
                        value: _country,
                        onChanged: (v) => setState(() => _country = v),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 0.02.h),

            // ── Action buttons ────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _clearFilter,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Text(
                          S.of(context).clearFilter,
                          style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: FontConstants.fontSize013.w,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 0.015.w),
                Expanded(
                  child: InkWell(
                    // ✅ FIX: was Navigator.pop(context) — now calls applyFilter
                    onTap: _applyFilter,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          S.of(context).Apply,
                          style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: FontConstants.fontSize013.w,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Count of currently selected filters (for the badge)
  int get _activeCount => [
    _department,
    _role,
    _title,
    _workLocation,
    _supervisor,
    _selectedGender,
    _selectedNationality,
    _country,
  ].where((v) => v != null && v.isNotEmpty).length;

  Widget _buildDropdown({
    required String hintEn,
    required String hintAr,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return CustomDropdown<String>(
      hint: hintEn,
      items: [for (final item in items) DropdownItem(value: item, label: item)],
      value: value,
      onChanged: onChanged,
      fillColor: AppColors.field,
    );
  }

  Widget _filterRow({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFontStyle.cairoRegularStyle.copyWith(
            fontSize: FontConstants.fontSize013.w,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 6.h),
        child,
      ],
    );
  }
}

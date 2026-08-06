part of '../pages/custom_csv_table_page.dart';

class _ExportDialog extends StatefulWidget {
  const _ExportDialog();

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  // ── Selections ────────────────────────────────────────────────────────────
  String? _department;
  String? _role;
  String? _title;
  String? _workLocation;
  String? _supervisor;
  String? _gender;
  String? _country;
  String? _fileFormat;
  String? _language;

  bool _showPreview = false;
  String _searchQuery = '';

  // ── Static option lists ───────────────────────────────────────────────────
  final _fileFormats = ['CSV', 'Excel (.xlsx)', 'PDF'];
  final _languages   = ['English', 'Arabic', 'Both'];

  // ── Controller & real data ────────────────────────────────────────────────
  late final ActiveDirectoryController _ctrl;

  /// Extract unique sorted non-empty values from a column index.
  List<String> _extractColumn(int columnIndex) {
    if (columnIndex < 0) return [];
    return _ctrl.usersData
        .map((row) => row.length > columnIndex
        ? (row[columnIndex]?.toString().trim() ?? '')
        : '')
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  // Dropdown option lists built lazily from real data
  late final List<String> _departments;
  late final List<String> _roles;
  late final List<String> _titles;
  late final List<String> _workLocations;
  late final List<String> _supervisors;
  late final List<String> _genders;
  late final List<String> _countries;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ActiveDirectoryController>();

    // Build dropdown options once from real usersData
    _departments   = _extractColumn(_ColumnIndex.department);
    _roles         = _extractColumn(_ColumnIndex.role);
    _titles        = _extractColumn(_ColumnIndex.title);
    _workLocations = _extractColumn(_ColumnIndex.workLocation);
    _supervisors   = _extractColumn(_ColumnIndex.supervisor);
    _genders       = _extractColumn(_ColumnIndex.gender);
    _countries     = _extractColumn(_ColumnIndex.country);
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  /// Returns rows from usersData that match all active dropdown selections.
  List<List<dynamic>> get _matchingRows {
    return _ctrl.usersData.where((row) {
      bool _match(String? filter, int col) {
        if (filter == null || filter.isEmpty) return true;
        if (row.length <= col) return false;
        return row[col]?.toString().trim().toLowerCase() ==
            filter.trim().toLowerCase();
      }

      if (!_match(_department,   _ColumnIndex.department))   return false;
      if (!_match(_role,         _ColumnIndex.role))         return false;
      if (!_match(_title,        _ColumnIndex.title))        return false;
      if (!_match(_workLocation, _ColumnIndex.workLocation)) return false;
      if (!_match(_supervisor,   _ColumnIndex.supervisor))   return false;
      if (!_match(_gender,       _ColumnIndex.gender))       return false;
      if (!_match(_country,      _ColumnIndex.country))      return false;
      return true;
    }).cast<List<dynamic>>().toList();
  }

  /// [_matchingRows] further filtered by the preview search box.
  List<List<dynamic>> get _previewRows {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _matchingRows;
    return _matchingRows
        .where((row) =>
        row.any((cell) => cell?.toString().toLowerCase().contains(q) ?? false))
        .toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns a display name for a row: firstName + lastName columns.
  /// Returns a display name for a row: firstName + lastName columns.
  String _rowName(List<dynamic> row) {
    // firstName is at index 1, lastName is at index 3 (from the column comment at top)
    final first = row.length > 1
        ? (row[1]?.toString().trim() ?? '')
        : '';
    final last = row.length > 3
        ? (row[3]?.toString().trim() ?? '')
        : '';
    return '$first $last'.trim();
  }

  String _rowDepartment(List<dynamic> row) =>
      row.length > _ColumnIndex.department
          ? (row[_ColumnIndex.department]?.toString().trim() ?? '')
          : '';

  String _rowTitle(List<dynamic> row) =>
      row.length > _ColumnIndex.title
          ? (row[_ColumnIndex.title]?.toString().trim() ?? '')
          : '';

  void _clearFilter() {
    setState(() {
      _department   = null;
      _role         = null;
      _title        = null;
      _workLocation = null;
      _supervisor   = null;
      _gender       = null;
      _country      = null;
      _fileFormat   = null;
      _language     = null;
      _showPreview  = false;
      _searchQuery  = '';
    });
  }

  bool get _isDesktop => MediaQuery.of(context).size.width > 800;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: _isDesktop ? 0.08.w : 0.04.w,
        vertical: 0.04.h,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildFilterPanel()),
            if (_showPreview) ...[
              VerticalDivider(width: 1, color: AppColors.border),
              Expanded(child: _buildPreviewPanel()),
            ],
          ],
        ),
      ),
    );
  }

  // ── Filter panel ──────────────────────────────────────────────────────────

  Widget _buildFilterPanel() {
    return Container(
      color: AppColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
            child: Row(
              children: [
                Text(
                  S.current.exportDetails,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: FontConstants.fontSize018.w,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                // Live match count badge
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_matchingRows.length} ${S.current.matches}',
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: FontConstants.fontSize012.w,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _isDesktop
                  ? _buildDesktopDropdownGrid()
                  : _buildMobileDropdownList(),
            ),
          ),
          _buildFilterActions(),
        ],
      ),
    );
  }

  Widget _buildDesktopDropdownGrid() {
    final items = _dropdownItems();
    final rows  = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final left  = items[i];
      final right = i + 1 < items.length ? items[i + 1] : null;
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              SizedBox(width: 14.w),
              Expanded(child: right ?? const SizedBox()),
            ],
          ),
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  Widget _buildMobileDropdownList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _dropdownItems()
          .map((item) => Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: item,
      ))
          .toList(),
    );
  }

  List<Widget> _dropdownItems() {
    return [
      _labeledDropdown(
        labelEn: 'Department', labelAr: 'القسم',
        hintEn: 'Select Departments', hintAr: 'اختر القسم',
        items: _departments, value: _department,
        onChanged: (v) => setState(() { _department = v; _showPreview = false; }),
      ),
      _labeledDropdown(
        labelEn: 'Role', labelAr: 'الدور',
        hintEn: 'Select Role', hintAr: 'اختر الدور',
        items: _roles, value: _role,
        onChanged: (v) => setState(() { _role = v; _showPreview = false; }),
      ),
      _labeledDropdown(
        labelEn: 'Title', labelAr: 'اللقب',
        hintEn: 'Select Title', hintAr: 'اختر اللقب',
        items: _titles, value: _title,
        onChanged: (v) => setState(() { _title = v; _showPreview = false; }),
      ),
      _labeledDropdown(
        labelEn: 'Work Location', labelAr: 'موقع العمل',
        hintEn: 'Select Work Location', hintAr: 'اختر موقع العمل',
        items: _workLocations, value: _workLocation,
        onChanged: (v) => setState(() { _workLocation = v; _showPreview = false; }),
      ),
      _labeledDropdown(
        labelEn: 'Supervisor', labelAr: 'المشرف',
        hintEn: 'Select Supervisor', hintAr: 'اختر المشرف',
        items: _supervisors, value: _supervisor,
        onChanged: (v) => setState(() { _supervisor = v; _showPreview = false; }),
      ),
      _labeledDropdown(
        labelEn: 'Gender', labelAr: 'الجنس',
        hintEn: 'Select Gender', hintAr: 'اختر الجنس',
        items: _genders, value: _gender,
        onChanged: (v) => setState(() { _gender = v; _showPreview = false; }),
      ),
      _labeledDropdown(
        labelEn: 'Country', labelAr: 'الدولة',
        hintEn: 'Select Country', hintAr: 'اختر الدولة',
        items: _countries, value: _country,
        onChanged: (v) => setState(() { _country = v; _showPreview = false; }),
      ),
      _labeledDropdown(
        labelEn: 'File Format', labelAr: 'صيغة الملف',
        hintEn: 'Select File Format', hintAr: 'اختر صيغة الملف',
        items: _fileFormats, value: _fileFormat,
        onChanged: (v) => setState(() => _fileFormat = v),
      ),
      _labeledDropdown(
        labelEn: 'Language', labelAr: 'اللغة',
        hintEn: 'Select Language', hintAr: 'اختر اللغة',
        items: _languages, value: _language,
        onChanged: (v) => setState(() => _language = v),
      ),
    ];
  }

  Widget _labeledDropdown({
    required String labelEn,
    required String labelAr,
    required String hintEn,
    required String hintAr,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return CustomDropdown<String>(
      label: labelEn.isEmpty ? null : labelEn,
      hint: hintEn,
      items: [for (final item in items) DropdownItem(value: item, label: item)],
      value: value,
      onChanged: onChanged,
      borderRadius: BorderRadius.circular(8),
      fillColor: AppColors.field,
    );
  }

  Widget _buildFilterActions() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _clearFilter,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 42.h,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Text(
                    S.current.clearFilter,
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: FontConstants.fontSize013.w,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: InkWell(
              onTap: _matchingRows.isEmpty
                  ? null
                  : () => setState(() => _showPreview = true),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 42.h,
                decoration: BoxDecoration(
                  color: _matchingRows.isEmpty
                      ? AppColors.greyDark
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Preview ${_matchingRows.length} ${S.current.matches2}',
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: FontConstants.fontSize013.w,
                      fontWeight: FontWeight.w600,
                      color: _matchingRows.isEmpty ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: academic_history.dart
/// Purpose: The Academic History card — degree, university and graduation year
///          per record, stacked, with add and delete.
/// Author: Amr Mesbah
/// Created at: 13/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE2-N04/N05/N07/N17: blanket `ignore_for_file`
///          and the five REMOVED_MODULE comments removed; the university
///          TextEditingControllers live here rather than on SocialController;
///          `MediaQuery.of(Get.context!)` — read once at field-initializer time,
///          so it never updated on rotation — replaced with the build context;
///          the dead `_updateAcademicField` (an empty if-body that pretended to
///          write) is gone; the hardcoded Arabic hint comes from l10n.
/// Updated: 8/9/2026 - the red trash button (and its tablet minus-circle
///          sibling) that sat on a row of its own above the fields is replaced
///          by one minus-circle icon on the "Graduation From" title line, the
///          way Skills and Hobbies remove a row.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/academic_entry.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_add_row_button.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class AcademicHistory extends StatefulWidget {
  const AcademicHistory({
    super.key,
    required this.entries,
    required this.onEntryChanged,
    required this.onAdd,
    required this.onRemove,
    this.errorRows = const <int>{},
  });

  /// The current records, straight from the cubit's draft.
  final List<AcademicEntry> entries;

  final void Function(int index, AcademicEntry entry) onEntryChanged;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  /// 21/10/2026 (Moataz): rows whose empty fields show "required". Empty
  /// until the user presses Update with an incomplete row — opening the page
  /// shows no errors.
  final Set<int> errorRows;

  @override
  State<AcademicHistory> createState() => _AcademicHistoryState();
}

class _AcademicHistoryState extends State<AcademicHistory> {
  final HapticController _hapticController = Get.find<HapticController>();

  /// The degree keys as persisted. Kept untranslated on purpose — the label is
  /// looked up per locale in [_degreeItems].
  static const List<String> _degreeKeys = <String>[
    'bachelor',
    'master',
    'phd',
    'diploma',
    'certificate',
  ];

  /// One university controller per record, owned here (§16).
  final List<TextEditingController> _universityControllers =
      <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant AcademicHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  void _syncControllers() {
    while (_universityControllers.length < widget.entries.length) {
      _universityControllers.add(TextEditingController());
    }
    while (_universityControllers.length > widget.entries.length) {
      _universityControllers.removeLast().dispose();
    }
    for (int i = 0; i < widget.entries.length; i++) {
      // Capitalized at seed time. The old widget did this in a post-frame
      // callback that mutated the controller and called setState.
      final String value = widget.entries[i].university.isEmpty
          ? ''
          : FormatHelper.capitalize(widget.entries[i].university);
      if (_universityControllers[i].text.trim() !=
          widget.entries[i].university.trim()) {
        _universityControllers[i].text = value;
      }
    }
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _universityControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addEntry() {
    _hapticController.triggerHapticFeedback(
      vibration: VibrateType.lightImpact,
      hapticFeedback: HapticFeedback.lightImpact,
    );
    widget.onAdd();
  }

  /// Degree options. Labels come from the l10n bundle rather than inline
  /// ternaries, so the strings live in intl_en.arb / intl_ar.arb like the rest
  /// of the app.
  /// The key for a stored degree: the key itself, or the EN / AR label.
  String _degreeKeyOf(BuildContext context, String stored) {
    final String v = stored.trim();
    if (v.isEmpty) return '';
    if (_degreeKeys.contains(v)) return v;
    for (final DropdownItem<String> item in _degreeItems(context)) {
      if (item.label.toLowerCase() == v.toLowerCase()) return item.value;
    }
    return '';
  }

  List<DropdownItem<String>> _degreeItems(BuildContext context) {
    final Map<String, String> labels = <String, String>{
      'bachelor': S.of(context).bachelorDegree,
      'master': S.of(context).masterDegree,
      'phd': S.of(context).phdDegree,
      'diploma': S.of(context).diploma,
      'certificate': S.of(context).certificate,
    };

    return _degreeKeys
        .map((String key) => DropdownItem<String>(
              value: key,
              label: FormatHelper.capitalize(labels[key]!),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ContextExtension(context).isPhone;
    final bool isTablet = !kpIsPhoneLayout(context);
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      decoration: !isTablet
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.card,
            )
          : null,
      padding: EdgeInsets.only(
        top: 16.sp,
        right: 0.sp,
        left: 0.sp,
        bottom: isMobile ? 16.sp : 0.sp,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SettingsHeader(
            imagePath:
                'assets/icons_assets/settings_assets/ic_hr_academic_history.svg',
            text: FormatHelper.capitalize(S.of(context).academicHistory),
          ),
          SizedBox(height: 12.sp),

          // Every entry, stacked. This used to render only the LAST entry,
          // which is why "More" looked like it wiped the form: it appended a
          // blank entry and the filled one it replaced stopped being drawn.
          for (int i = 0; i < widget.entries.length; i++) ...<Widget>[
            if (i != 0) SizedBox(height: 20.sp),
            _buildEntry(context, i, isArabic),
          ],

          // 21/10/2026: 12 above every Add button (Degree / Skill / Hobby),
          // and on the phone the same 16 inset as the fields above it.
          SizedBox(height: 12.sp),
          // X-133: the core black Add button, "+ Add Degree".
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.sp : 0),
            child: CustomAddRowButton(
                label: S.of(context).addDegree, onTap: _addEntry),
          ),
        ],
      ),
    );
  }

  /// One academic record: degree + university on the first row, graduation
  /// year on the second.
  Widget _buildEntry(BuildContext context, int index, bool isArabic) {
    final AcademicEntry entry = widget.entries[index];
    // X-136 / K-50 (21/10/2026): a stored degree may be the KEY ("bachelor")
    // or a LABEL ("Bachelor's Degree" / "بكالوريوس"); both select the item,
    // and an unknown saved value is still shown and kept.
    final String degreeKey = _degreeKeyOf(context, entry.degree);
    final bool isValidDegree = degreeKey.isNotEmpty;

    // The first record is the employee's primary one and is always present —
    // only the extra records added with "More" can be removed.
    final bool canDelete = index > 0;
    final bool showErrors = widget.errorRows.contains(index);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: ContextExtension(context).isPhone ? 16.sp : 0.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // CHANGED 8/9/2026 — the remove affordance used to be a right-aligned
          // row of its own above the fields: a red 38×38 trash button on
          // phones, a minus-circle InkWell elsewhere. It is now the same
          // minus-circle icon Skills and Hobbies use, sitting on the SAME LINE
          // as the "Graduation From" title, so an extra academic record is
          // removed exactly the way an extra skill or hobby is.
          //
          // The title therefore has to be drawn here rather than handed to
          // CustomDropdown's `label:` — it is a Row now, not a string. Same
          // 14.sp/weight-500 text and the same [kFieldLabelGap] the dropdown
          // and the text field apply to their own labels, so the two fields on
          // this row still start at the same height.
          SizedBox(height: ContextExtension(context).isPhone ? 0.sp : 12.sp),

          // First row: degree + university.
          buildResponsiveFields(
            context: context,
            stackOnPortrait: true, // D-225 / item 109
            left: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      FormatHelper.capitalize(S.of(context).graduationFrom),
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.text),
                    ),
                    Spacer(),
                    if (canDelete) ...<Widget>[
                      SizedBox(width: 8.sp),
                      InkWell(
                        onTapDown: (_) => HapticController.high(),
                        onTap: () => widget.onRemove(index),
                        child: CustomSvgImage(
                          assetPath:
                              'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg',
                          width: 16.sp,
                          fit: BoxFit.fill,
                          height: 16.sp,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: kFieldLabelGap.sp),
                CustomDropdown<String>(
                  value: isValidDegree ? degreeKey : null,
                  items: <DropdownItem<String>>[
                    ..._degreeItems(context),
                    if (!isValidDegree && entry.degree.trim().isNotEmpty)
                      DropdownItem<String>(
                          value: entry.degree, label: entry.degree),
                  ],
                  // X-138: required — red message while empty.
                  errorText: showErrors && entry.degree.trim().isEmpty
                      ? S.of(context).thisFieldIsRequired
                      : null,
                  onChanged: (String value) => widget.onEntryChanged(
                      index, entry.copyWith(degree: value)),
                  // HEIGHT 21/9/2026 (Settings bug report p.15): one height for the row.
                  height: 40,
                  hint: FormatHelper.capitalize(S.of(context).chooseDegree),
                  // 21/10/2026 (Moataz): same text size as the other fields
                  // (was a 10 hint and the default small value).
                  enforceTypeScale: false,
                  valueStyle: StyleText.fontSize14Weight400
                      .copyWith(color: AppColors.text),
                  hintStyle: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
            // CHANGED 21/9/2026 — the title is drawn here, the same way as
            // "Graduation From" on the left, instead of by CustomTextField's
            // `label:`. The field draws its label with RichText and the left
            // column uses Text; the two lay out a few px apart, which put the
            // university box visibly lower than the degree dropdown. Same
            // widget + same [kFieldLabelGap] on both sides = same top edge.
            right: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      FormatHelper.capitalize(
                          S.of(context).universityOrInstitute),
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.text),
                    ),
                    // Same height as the remove icon on the left (it is 16.sp
                    // tall; a bare SizedBox(height) still added width).
                    SizedBox(height: 16.sp, width: 0),
                  ],
                ),
                SizedBox(height: kFieldLabelGap.sp),
                CustomTextField(
                  // Keyed per entry so each record keeps its own field state when
                  // one is inserted or removed above it.
                  key: ValueKey<String>('academic_university_$index'),
                  // HEIGHT 21/9/2026 (Settings bug report p.15): one height for the row.
                  height: 40,
                  hint: FormatHelper.capitalize(S.of(context).textHere),
                  textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                  controller: _universityControllers[index],
                  errorText: showErrors && entry.university.trim().isEmpty
                      ? S.of(context).thisFieldIsRequired
                      : null,
                  onChanged: (String value) => widget.onEntryChanged(
                    index,
                    entry.copyWith(university: value.trim()),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.sp),

          // Second row: graduation year. 21/10/2026: no longer through
          // buildResponsiveFields — stacked, it added a 15 gap under the empty
          // right side, which made the space above "+ Add Degree" 3x the
          // others. Alone in its row: full width stacked, half otherwise (R-2).
          Builder(builder: (BuildContext context) {
            final Widget year = CustomDateField(
              value: entry.graduationYear.isEmpty
                  ? null
                  : DateTime(int.tryParse(entry.graduationYear) ??
                      DateTime.now().year),
              firstDate: DateTime(DateTime.now().year - 49),
              lastDate: DateTime(DateTime.now().year, 12, 31),
              dateFormatter: (DateTime d) => d.year.toString(),
              onChanged: (DateTime? value) => widget.onEntryChanged(
                index,
                entry.copyWith(graduationYear: value?.year.toString() ?? ''),
              ),
              label: FormatHelper.capitalize(S.of(context).graduationYear),
              errorText: showErrors && entry.graduationYear.trim().isEmpty
                  ? S.of(context).thisFieldIsRequired
                  : null,
              // HEIGHT 21/9/2026 (Settings bug report p.15): one height for the row.
              height: 40,
              hint: FormatHelper.capitalize(S.of(context).selectdate),
              hintStyle: StyleText.fontSize10Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
            );
            final bool stacked = ContextExtension(context).isPhone ||
                MediaQuery.of(context).orientation == Orientation.portrait;
            return stacked
                ? year
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: year),
                      SizedBox(width: 16.sp),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  );
          }),
        ],
      ),
    );
  }
}

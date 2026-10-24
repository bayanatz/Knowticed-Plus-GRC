import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/org_chart/presentation/ui/widgets/employees_components/employees_components_subwidgets/assets_container.dart';
import 'package:knowticed_plus/features/org_chart/presentation/ui/widgets/employees_components/employees_hr_components/employee_hr_profile_components/custom_expandable_container.dart';
import 'package:knowticed_plus/features/org_chart/presentation/ui/widgets/employees_components/employees_hr_components/employee_hr_profile_components/custom_health_table.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/widgets/custom_icon_container.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/extensions/screen_fraction_extension.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/settings_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/social_permissions.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_haptic.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// 22/10/2026 (Moataz, Employee Info: "the icons are unreadable … the
/// thickness is bad"): 16 drew every row icon with a ~0.8 pt line in the
/// secondary grey. 20 + the app's icon colour reads clearly next to the
/// 12-pt label; every row icon uses this one size.
///
/// 23/10/2026 (Moataz): bigger on the iPad and the Mac so they read clearly;
/// the phone keeps 20.
double get _rowIconSize => ScreenUtil().screenWidth < 600 ? 20.sp : 26.sp;

/// One fixed square per row icon (22/10/2026: icons drawn on a narrow grid —
/// e.g. the 11-wide pin — took less room, so the labels after them started
/// at different points). Centred in the square, so every label lines up.
Widget _rowIcon(String assetPath) => SizedBox.square(
      dimension: _rowIconSize,
      child: Center(child: _ThinRowIcon(assetPath: assetPath)),
    );

/// Thinner line for the row icons (Moataz 23/10/2026: "reduce the thickness of
/// these icons, make it less"). The assets draw at ~1 pt at this size; every
/// `stroke-width` in the file is multiplied by [_strokeScale] when it is
/// loaded, so the asset files themselves stay untouched. Every icon gets the
/// same factor, so they stay equal to each other.
const double _strokeScale = 0.6;

class _ThinRowIcon extends StatefulWidget {
  const _ThinRowIcon({required this.assetPath});
  final String assetPath;

  static final Map<String, String> _cache = <String, String>{};

  @override
  State<_ThinRowIcon> createState() => _ThinRowIconState();
}

class _ThinRowIconState extends State<_ThinRowIcon> {
  String? _svg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_ThinRowIcon old) {
    super.didUpdateWidget(old);
    if (old.assetPath != widget.assetPath) _load();
  }

  Future<void> _load() async {
    final String path = widget.assetPath;
    String? svg = _ThinRowIcon._cache[path];
    if (svg == null) {
      final String raw = await rootBundle.loadString(path);
      svg = raw.replaceAllMapped(
        RegExp(r'stroke-width="([0-9.]+)"'),
        (Match m) =>
            'stroke-width="${(double.parse(m.group(1)!) * _strokeScale).toStringAsFixed(4)}"',
      );
      _ThinRowIcon._cache[path] = svg;
    }
    if (mounted && path == widget.assetPath) setState(() => _svg = svg);
  }

  @override
  Widget build(BuildContext context) {
    final String? svg = _svg;
    if (svg == null) return const SizedBox.shrink();
    return SvgPicture.string(
      svg,
      width: _rowIconSize,
      height: _rowIconSize,
      fit: BoxFit.contain,
      // 22/10/2026: the label grey, like every info-row icon.
      colorFilter: ColorFilter.mode(AppColors.infoIcon, BlendMode.srcIn),
    );
  }
}

/// Gap between a row icon and its label.
double get _iconGap => 8.sp;

/// Gap between a row label and its value.
double get _valueGap => 6.sp;

/// A row label, optionally in a fixed-width box (see
/// [CustomPersonalInfoContainer.labelColumnWidth]).
class _Lbl extends StatelessWidget {
  const _Lbl(this.data, {required this.style, this.width});
  final String data;
  final TextStyle style;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final Text text = Text(data, style: style);
    return width == null ? text : SizedBox(width: width, child: text);
  }
}

/// Every row label the Employee Info page can show, as the page prints them.
List<String> employeeInfoLabels(BuildContext context) {
  final S t = S.of(context);
  return <String>[
    t.department,
    t.superVisor,
    t.email,
    t.phoneNumber,
    t.title,
    t.compensation,
    t.jobType,
    t.manager,
    t.startDate,
    t.workingHours,
    t.daysOff,
    t.jobLocation,
    t.institutionName,
    t.degreeOrCertification,
    t.graduationYear,
    t.skills,
    t.hobbys,
  ];
}

/// Width of the widest label (with its ": ") at [fontSize] — the shared label
/// column. A hair of slack is added so the text never wraps.
double employeeInfoLabelWidth(BuildContext context, double fontSize) {
  double widest = 0;
  for (final String label in employeeInfoLabels(context)) {
    final TextPainter p = TextPainter(
      text: TextSpan(
        text: '${label.capitalize ?? label}: ',
        style: StyleText.fontSize16Weight400
            .copyWith(fontSize: fontSize, height: 1.4),
      ),
      textDirection: Directionality.of(context),
      maxLines: 1,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    if (p.width > widest) widest = p.width;
  }
  return widest + 4;
}

class CustomPersonalInfoContainer extends StatefulWidget {
  final String primaryText;
  final List<String>? secondaryTexts;
  final List<String>? personalInfoTexts;
  final List<String>? customIcons;
  final bool? isPersonalInformation;
  final bool? isPositionDetailes;
  final bool? isWorkingHours;
  final bool? isGeneralInfo;
  final bool? isAdditionalInfo;
  final bool? isAssets;
  final bool? isHealth;
  final bool? isSkills;
  final int? numberOfElementsInColumn;

  /// 22/10/2026 (Moataz, phone Employee Info: "the bubbles for the skills,
  /// the hobbies"): rows whose label is in this list show their values as
  /// bubbles (the iPad's look) instead of one comma-separated line.
  final List<String>? chipLabels;

  /// When set, every row label sits in a box this wide, so the VALUES start on
  /// one vertical line (Moataz 23/10/2026: upright iPad and phone, "all values
  /// start with the same line, aligned with the icon"). Parents compute it
  /// with [labelColumnWidthFor] from the widest label of the whole page.
  final double? labelColumnWidth;

  const CustomPersonalInfoContainer({
    this.chipLabels,
    this.labelColumnWidth,
    super.key,
    required this.primaryText,
    this.secondaryTexts,
    this.personalInfoTexts,
    this.customIcons,
    this.isPersonalInformation = false,
    this.isPositionDetailes = false,
    this.isWorkingHours = false,
    this.isGeneralInfo = false,
    this.isAdditionalInfo = false,
    this.isAssets = false,
    this.isHealth = false,
    this.isSkills = false,
    this.numberOfElementsInColumn,
  });

  @override
  State<CustomPersonalInfoContainer> createState() =>
      _CustomPersonalInfoContainerState();
}

final CustomTableWidget emergencyTableWidget = CustomTableWidget(
  initialData: [
    ['Bassem Mohamed', '987-654-3210', S.current.friend],
    ['Bassem Mohamed', '987-654-3210', S.current.friend],
    ['Bassem Mohamed', '987-654-3210', S.current.family],
  ],
  columnName1: 'Contact Name',
  columnName2: 'Contact Number',
  columnName3: 'Relationship',
  tableName: 'Emergncy Contact Information',
);

const CustomTableWidget healthTableWidget = CustomTableWidget(
  initialData: [
    ['Mazen Shaaban', '987-654-3210', '012113124255'],
    ['Mazen Shaaban', '987-654-3210', '012113124255'],
    ['Mazen Shaaban', '987-654-3210', '012113124255'],
  ],
  isHealth: true,
  columnName1: 'Insurance Provider',
  columnName2: 'Policy Number',
  columnName3: 'Contact Number',
  tableName: 'Health Insurance Details',
);

class _CustomPersonalInfoContainerState
    extends State<CustomPersonalInfoContainer> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    !kpIsPhoneLayout(context);
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Padding(
      // Phone: half the gap between the section bars (Moataz 23/10/2026).
      padding: EdgeInsets.only(
          top: (isVertical ? 0.02.h : 0.03.h) /
              (kpIsPhoneLayout(context) ? 2 : 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              hapticController.triggerHapticFeedback(
                  vibration: VibrateType.lightImpact,
                  hapticFeedback: HapticFeedback.lightImpact);
              setState(() {
                expanded = !expanded;
              });
            },
            child: ExpandableContainer(
              expanded: expanded,
              color: Colors.grey[700],
              title: widget.primaryText,
            ),
          ),
          if (expanded &&
              (widget.isPersonalInformation == true || widget.isSkills == true))
            SizedBox(height: 0.01.h),
          if (expanded && widget.isPersonalInformation == true)
            SingleChildScrollView(
              child: (isVertical &&
                      widget.isPositionDetailes != true &&
                      widget.isWorkingHours != true &&
                      widget.isGeneralInfo != true)
                  ? buildSingleColumn()
                  : buildMultiColumn(),
            ),
          if (expanded && widget.isSkills == true && widget.isSkills != null)
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isVertical ? 0.02.w : 0.02.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: widget.secondaryTexts?.map((skill) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: !AppTheme.isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              skill.capitalize ?? skill,
                              style: StyleText.fontSize16Weight400.copyWith(
                                fontSize: 12.sp,
                                color: !AppTheme.isDark
                                    ? AppColors.colorBlack
                                    : AppColors.colorWhiteDark,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                        }).toList() ??
                        [],
                  ),
                ),
              ),
            ),
          if (expanded &&
              widget.isAdditionalInfo == true &&
              widget.isAdditionalInfo != null)
            Padding(
              padding:
                  EdgeInsets.only(right: 0.02.h, left: 0.02.h, top: 0.025.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right:
                              Get.locale.toString().contains('en') ? 0.02.h : 0,
                          left: Get.locale.toString().contains('ar')
                              ? 0.02.h
                              : 0),
                      child: CustomIconContainer(
                        text: S.of(context).educationCertificate,
                        onPressed: () {},
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomIconContainer(
                      text: S.of(context).iDPhoto,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          if (expanded && widget.isAssets == true)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.02.h),
              child: Column(
                children: [
                  AssetsContainer(isEmployeeProfile: true),
                  AssetsContainer(isEmployeeProfile: true),
                ],
              ),
            ),
          if (expanded && widget.isHealth == true)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.02.h),
              child: Column(
                children: [
                  emergencyTableWidget,
                  healthTableWidget,
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Function Name: [_canSee]
  ///
  /// Purpose: Whether the signed-in employee's role grants [permission] under
  ///          Settings > Social Permissions.
  ///
  /// Added 23/8/2026: [buildMultiColumn] already gated every social section
  /// this way, but [buildSingleColumn] — the phone layout — did not, so a role
  /// with Academic History or Skills Hobbies switched off still saw them on a
  /// phone. Same checks, one helper, both layouts.
  ///
  /// Parameters:
  /// - [permission]: The social permission to test.
  ///
  /// Returns: [bool] true when the switch is on for this role.
  bool _canSee(SocialPermissions permission) =>
      Get.find<MainCoreEmployeeController>().isHasPermission(
        module: Modules.settings,
        section: SettingsPermissionsSections.socialPermissions,
        permission: permission,
      );

  Widget buildSingleColumn() {
    MediaQuery.of(context).orientation == Orientation.portrait;

    if (widget.isGeneralInfo == true) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.02.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First item - Institution Name (normal display)
            if (widget.secondaryTexts != null &&
                widget.secondaryTexts!.isNotEmpty)
              buildRowContent(0),

            SizedBox(height: 0.01.h),

            // Second and Third items in a row - Degree and Graduation Year
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_canSee(SocialPermissions.academicHistory))
                  if (widget.secondaryTexts != null &&
                      widget.secondaryTexts!.length > 1)
                    Expanded(child: buildRowContent(1)),
                if (widget.secondaryTexts != null &&
                    widget.secondaryTexts!.length > 2)
                  SizedBox(width: 0.02.w),
                if (_canSee(SocialPermissions.certificates))
                  if (widget.secondaryTexts != null &&
                      widget.secondaryTexts!.length > 2)
                    Expanded(child: buildRowContent(2)),
              ],
            ),

            // Skills with mobile-specific wrapped containers (index 3)
            if (_canSee(SocialPermissions.skillsHobbies))
              if (widget.secondaryTexts != null &&
                  widget.secondaryTexts!.length > 3) ...[
                SizedBox(height: 0.015.h),
                _buildMobileSkillsHobbiesItem(3),
              ],

            // Hobbies with mobile-specific wrapped containers (index 4)
            if (_canSee(SocialPermissions.skillsHobbies))
              if (widget.secondaryTexts != null &&
                  widget.secondaryTexts!.length > 4) ...[
                SizedBox(height: 0.015.h),
                _buildMobileSkillsHobbiesItem(4),
              ],
          ],
        ),
      );
    }

    // Default single column for other sections.
    // 22/10/2026: the same side inset as the section bar's title
    // (ExpandableContainer), so every row starts under the title's first
    // letter (it sat ~9 pt further in on the phone).
    final bool portrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: kpIsPhoneLayout(context)
          ? EdgeInsets.symmetric(horizontal: portrait ? 0.02.w : 0.02.h)
          : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: List<Widget>.generate(
          widget.secondaryTexts!.length,
          (index) => buildRowContent(index),
        ),
      ),
    );
  }

  Widget _buildMobileSkillsHobbiesItem(int index) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    // Get the raw data
    String rawData = widget.secondaryTexts![index];

    // ✅ FIXED: Check if data is null, empty, or just "-"
    if (rawData == '-' || rawData.trim().isEmpty || rawData.trim() == '-') {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.01.h, horizontal: 0.02.h),
        child: Row(
          children: [
            if (widget.customIcons != null &&
                index < widget.customIcons!.length)
              _rowIcon(widget.customIcons![index]),
            SizedBox(width: _iconGap),
            if (widget.personalInfoTexts != null &&
                index < widget.personalInfoTexts!.length)
              _Lbl(
                widget.personalInfoTexts![index].capitalize as String,
                width: widget.labelColumnWidth,
                style: StyleText.fontSize16Weight400.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.secondaryText,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            SizedBox(width: 0.01.w),
            Text(
              '-',
              style: StyleText.fontSize16Weight400.copyWith(
                fontSize: 12.sp,
                color: !AppTheme.isDark
                    ? AppColors.colorBlack
                    : AppColors.colorWhiteDark,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    // Parse the data into items
    List<String> items = [];
    if (rawData.contains('[[') || rawData.contains('[')) {
      String cleaned = rawData.replaceAll('[', '').replaceAll(']', '').trim();

      items = cleaned
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && e != '-')
          .toList();
    } else if (rawData.contains(',')) {
      items = rawData
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && e != '-')
          .toList();
    } else {
      items = [rawData.trim()];
    }

    // ✅ FIXED: If no valid items after parsing, show dash
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.01.h, horizontal: 0.02.h),
        child: Row(
          children: [
            if (widget.customIcons != null &&
                index < widget.customIcons!.length)
              _rowIcon(widget.customIcons![index]),
            SizedBox(width: _iconGap),
            if (widget.personalInfoTexts != null &&
                index < widget.personalInfoTexts!.length)
              _Lbl(
                widget.personalInfoTexts![index].capitalize as String,
                width: widget.labelColumnWidth,
                style: StyleText.fontSize16Weight400.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.secondaryText,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            SizedBox(width: 0.01.w),
            Text(
              '-',
              style: StyleText.fontSize16Weight400.copyWith(
                fontSize: 12.sp,
                color: !AppTheme.isDark
                    ? AppColors.colorBlack
                    : AppColors.colorWhiteDark,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    // 23/10/2026 (Moataz: "same as the iPad and the Mac — the bubbles start on
    // the value's row, then go to the next line; and rearrange them for the
    // perfect fit, fewer rows"): the label shares the FIRST line with the
    // bubbles, later lines start on the icon's line, and the bubbles are
    // re-ordered (widest first, each into the first line it fits) instead of
    // being kept in the order they were entered.
    final TextStyle chipStyle = StyleText.fontSize16Weight400.copyWith(
      fontSize: 12.sp,
      height: 1.4,
      color: !AppTheme.isDark ? AppColors.colorBlack : AppColors.colorWhiteDark,
      fontWeight: FontWeight.w400,
    );
    final TextStyle labelStyle = StyleText.fontSize16Weight400.copyWith(
      fontSize: 12.sp,
      color: AppColors.secondaryText,
      height: 1.4,
      fontWeight: FontWeight.w400,
    );
    final String labelText = (widget.personalInfoTexts != null &&
            index < widget.personalInfoTexts!.length)
        ? widget.personalInfoTexts![index].capitalize as String
        : '';
    final Widget labelGroup = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.customIcons != null && index < widget.customIcons!.length)
          _rowIcon(widget.customIcons![index]),
        SizedBox(width: _iconGap),
        Text(labelText, style: labelStyle),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.005.h),
      child: LayoutBuilder(builder: (context, constraints) {
        final TextDirection dir = Directionality.of(context);
        final double gap = 4.w;
        final double chipPad = 2 * 10.w;
        double textWidth(String t, TextStyle st) {
          final TextPainter p = TextPainter(
            text: TextSpan(text: t, style: st),
            textDirection: dir,
            maxLines: 1,
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          return p.width;
        }

        final List<String> labels =
            items.map((e) => e.capitalize ?? e).toList();
        final double labelW =
            _rowIconSize + 0.01.h + textWidth(labelText, labelStyle) + 8.w;
        // A little slack: text measured off-screen can differ by a pixel or two.
        final double full = constraints.maxWidth - 8.w;

        // Widest first, each into the first line with room (line 0 has the
        // label in it).
        final List<int> order = List<int>.generate(labels.length, (i) => i)
          ..sort((x, y) => textWidth(labels[y], chipStyle)
              .compareTo(textWidth(labels[x], chipStyle)));
        final List<List<int>> lines = <List<int>>[<int>[]];
        final List<double> used = <double>[labelW];
        for (final int i in order) {
          final double w = textWidth(labels[i], chipStyle) + chipPad;
          int target = -1;
          for (int l = 0; l < lines.length; l++) {
            final double extra = lines[l].isEmpty && l > 0 ? w : w + gap;
            if (used[l] + extra <= full + 0.5) {
              target = l;
              used[l] += extra;
              break;
            }
          }
          if (target == -1) {
            lines.add(<int>[i]);
            used.add(w);
          } else {
            lines[target].add(i);
          }
        }

        Widget chip(int i) => Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: lightMode ? Colors.grey[300] : Colors.grey[700],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(labels[i], style: chipStyle),
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int l = 0; l < lines.length; l++)
              Padding(
                padding: EdgeInsets.only(top: l == 0 ? 0 : 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (l == 0) ...[labelGroup, SizedBox(width: 8.w)],
                    for (int k = 0; k < lines[l].length; k++) ...[
                      if (k > 0) SizedBox(width: gap),
                      chip(lines[l][k]),
                    ],
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget buildMultiColumn() {
    // Position Details with 2x2 grid layout
    // 23/10/2026 (Moataz: iPad upright "is damaged"): two columns are too
    // narrow there — values broke letter by letter and the degree overflowed.
    // Upright, every item gets its own full-width row (R-5: fewer columns
    // when the fields are too narrow to read).
    final bool upright =
        MediaQuery.of(context).orientation == Orientation.portrait;

    if (upright &&
        widget.isPositionDetailes == true &&
        widget.secondaryTexts!.length >= 4) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPositionDetailItem(0),
          _buildPositionDetailItem(1),
          if (_canSee(SocialPermissions.shareEmailsAndSocialDataInBio))
            _buildPositionDetailItem(2),
          if (_canSee(SocialPermissions.shareCellphonesInSocialDataInBio))
            _buildPositionDetailItem(3),
        ],
      );
    }

    if (widget.isPositionDetailes == true &&
        widget.secondaryTexts!.length >= 4) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Row: Department + Supervisor
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(child: _buildPositionDetailItem(0)),
                SizedBox(width: 0.02.w),
                Expanded(child: _buildPositionDetailItem(1)),
              ],
            ),
            SizedBox(height: 0.01.h),
            // Second Row: Email + Phone
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (Get.find<MainCoreEmployeeController>().isHasPermission(
                  module: Modules.settings,
                  section: SettingsPermissionsSections.socialPermissions,
                  permission: SocialPermissions.shareEmailsAndSocialDataInBio,
                ))
                  Expanded(child: _buildPositionDetailItem(2)),
                SizedBox(width: 0.02.w),
                if (Get.find<MainCoreEmployeeController>().isHasPermission(
                  module: Modules.settings,
                  section: SettingsPermissionsSections.socialPermissions,
                  permission:
                      SocialPermissions.shareCellphonesInSocialDataInBio,
                ))
                  Expanded(child: _buildPositionDetailItem(3)),
              ],
            ),
          ],
        ),
      );
    }

    if (widget.isWorkingHours == true && widget.secondaryTexts!.length >= 5) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child: _buildWorkingHoursItem(0)),
              SizedBox(width: 0.02.w),
              Expanded(child: _buildWorkingHoursItem(1)),
              SizedBox(width: 0.02.w),
              Expanded(child: _buildWorkingHoursItem(2)),
            ],
          ),
          SizedBox(height: 0.01.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child: _buildWorkingHoursItem(3)),
              SizedBox(width: 0.02.w),
              Expanded(child: SizedBox()),
            ],
          ),
        ],
      );
    }

    // General Information layout
    if (widget.isGeneralInfo == true) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.secondaryTexts != null &&
                widget.secondaryTexts!.isNotEmpty)
              _buildGeneralInfoItem(0, false),
            if (widget.secondaryTexts != null &&
                widget.secondaryTexts!.isNotEmpty)
              SizedBox(height: 0.01.h),
            if (upright) ...[
              if (_canSee(SocialPermissions.academicHistory) &&
                  widget.secondaryTexts != null &&
                  widget.secondaryTexts!.length > 1)
                _buildGeneralInfoItem(1, false),
              if (_canSee(SocialPermissions.certificates) &&
                  widget.secondaryTexts != null &&
                  widget.secondaryTexts!.length > 2)
                _buildGeneralInfoItem(2, false),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (Get.find<MainCoreEmployeeController>().isHasPermission(
                    module: Modules.settings,
                    section: SettingsPermissionsSections.socialPermissions,
                    permission: SocialPermissions.academicHistory,
                  ))
                    if (widget.secondaryTexts != null &&
                        widget.secondaryTexts!.length > 1)
                      Expanded(child: _buildGeneralInfoItem(1, false)),
                  if (widget.secondaryTexts != null &&
                      widget.secondaryTexts!.length > 1)
                    SizedBox(width: 0.02.w),
                  if (Get.find<MainCoreEmployeeController>().isHasPermission(
                    module: Modules.settings,
                    section: SettingsPermissionsSections.socialPermissions,
                    permission: SocialPermissions.certificates,
                  ))
                    if (widget.secondaryTexts != null &&
                        widget.secondaryTexts!.length > 2)
                      Expanded(child: _buildGeneralInfoItem(2, false))
                    else
                      Expanded(child: SizedBox()),
                ],
              ),
            if (Get.find<MainCoreEmployeeController>().isHasPermission(
              module: Modules.settings,
              section: SettingsPermissionsSections.socialPermissions,
              permission: SocialPermissions.skillsHobbies,
            ))
              if (widget.secondaryTexts != null &&
                  widget.secondaryTexts!.length > 3)
                _buildGeneralInfoWrappedItem(3),
            if (Get.find<MainCoreEmployeeController>().isHasPermission(
              module: Modules.settings,
              section: SettingsPermissionsSections.socialPermissions,
              permission: SocialPermissions.skillsHobbies,
            ))
              if (widget.secondaryTexts != null &&
                  widget.secondaryTexts!.length > 4)
                _buildGeneralInfoWrappedItem(4),
          ],
        ),
      );
    }

    // Default layout (Working Hours and any other section without its own
    // grid). FIXED 22/10/2026 (Moataz: "the Working Hours values are empty on
    // the iPad and Mac"): this branch drew each row's icon and label but
    // never its VALUE, so Start Date, Working Hours, Days Off and Job
    // Location came out blank on wide screens while the phone showed them.
    // It now draws every row with [buildRowContent] — the phone's row: icon,
    // label and value, the icon centred on the first line.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // The same row spacing as the other wide sections (measured on the
        // Mac: rows 40 apart in Position Details, 24 here before), so the
        // gaps between rows match across the page.
        for (int i = 0; i < (widget.secondaryTexts?.length ?? 0); i++)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0.01.h),
            child: buildRowContent(i),
          ),
      ],
    );
  }

  Widget _buildPositionDetailItem(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.01.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (widget.customIcons != null && index < widget.customIcons!.length)
            _rowIcon(widget.customIcons![index]),
          SizedBox(width: _iconGap),
          if (widget.personalInfoTexts != null &&
              index < widget.personalInfoTexts!.length)
            _Lbl(
              widget.personalInfoTexts![index].capitalize as String,
              width: widget.labelColumnWidth,
              style: StyleText.fontSize16Weight400.copyWith(
                fontSize: 14.sp,
                color: AppColors.secondaryText,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          SizedBox(width: _valueGap),
          Flexible(
            child: Text(
              widget.secondaryTexts![index].contains('AM') ||
                      widget.secondaryTexts![index].contains('PM')
                  ? widget.secondaryTexts![index].toUpperCase()
                  : widget.secondaryTexts![index].contains('@')
                      ? widget.secondaryTexts![index]
                      : widget.secondaryTexts![index].capitalize as String,
              maxLines: 14,
              overflow: TextOverflow.ellipsis,
              style: StyleText.fontSize16Weight400.copyWith(
                fontSize: 14.sp,
                color: !AppTheme.isDark
                    ? AppColors.colorBlack
                    : AppColors.colorWhiteDark,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursItem(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.01.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (widget.customIcons != null && index < widget.customIcons!.length)
            Center(
              child: _rowIcon(widget.customIcons![index]),
            ),
          SizedBox(width: _iconGap),
          if (widget.personalInfoTexts != null &&
              index < widget.personalInfoTexts!.length)
            _Lbl(
              widget.personalInfoTexts![index].capitalize as String,
              width: widget.labelColumnWidth,
              style: StyleText.fontSize16Weight400.copyWith(
                fontSize: 14.sp,
                color: AppColors.secondaryText,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          SizedBox(width: _valueGap),
          Flexible(
            child: Text(
              widget.secondaryTexts![index].contains('AM') ||
                      widget.secondaryTexts![index].contains('PM')
                  ? widget.secondaryTexts![index].toUpperCase()
                  : widget.secondaryTexts![index].contains('@')
                      ? widget.secondaryTexts![index]
                      : widget.secondaryTexts![index].capitalize as String,
              maxLines: 14,
              overflow: TextOverflow.ellipsis,
              style: StyleText.fontSize16Weight400.copyWith(
                fontSize: 14.sp,
                color: !AppTheme.isDark
                    ? AppColors.colorBlack
                    : AppColors.colorWhiteDark,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoItem(int index, bool isSpec) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.01.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (widget.customIcons != null && index < widget.customIcons!.length)
            Center(
              child: _rowIcon(widget.customIcons![index]),
            ),
          SizedBox(width: _iconGap),
          if (widget.personalInfoTexts != null &&
              index < widget.personalInfoTexts!.length)
            _Lbl(
              widget.personalInfoTexts![index].capitalize as String,
              width: widget.labelColumnWidth,
              style: StyleText.fontSize16Weight400.copyWith(
                fontSize: 14.sp,
                color: AppColors.secondaryText,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          SizedBox(width: _valueGap),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                  color: isSpec
                      ? lightMode
                          ? Colors.grey[400]
                          : Colors.grey[700]
                      : Colors.transparent),
              child: Text(
                widget.secondaryTexts![index].contains('AM') ||
                        widget.secondaryTexts![index].contains('PM')
                    ? widget.secondaryTexts![index].toUpperCase()
                    : widget.secondaryTexts![index].contains('@')
                        ? widget.secondaryTexts![index]
                        : widget.secondaryTexts![index].capitalize as String,
                maxLines: 14,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize16Weight400.copyWith(
                  fontSize: 14.sp,
                  color: !AppTheme.isDark
                      ? AppColors.colorBlack
                      : AppColors.colorWhiteDark,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoWrappedItem(int index) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    // Get raw data
    String rawData = widget.secondaryTexts![index];

    // ✅ FIXED: Check if data is null, empty, or just "-"
    if (rawData == '-' || rawData.trim().isEmpty || rawData.trim() == '-') {
      // Show inline dash instead of wrapped containers
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.01.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.customIcons != null &&
                index < widget.customIcons!.length)
              Center(
                child: _rowIcon(widget.customIcons![index]),
              ),
            SizedBox(width: _iconGap),
            if (widget.personalInfoTexts != null &&
                index < widget.personalInfoTexts!.length)
              _Lbl(
                widget.personalInfoTexts![index].capitalize as String,
                width: widget.labelColumnWidth,
                style: StyleText.fontSize16Weight400.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.secondaryText,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            SizedBox(width: _valueGap),
            Text(
              '-',
              style: StyleText.fontSize16Weight400.copyWith(
                fontSize: 14.sp,
                color: !AppTheme.isDark
                    ? AppColors.colorBlack
                    : AppColors.colorWhiteDark,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    // Split the comma-separated string into individual items
    List<String> items = rawData
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e != '-')
        .toList();

    // ✅ FIXED: If no valid items after filtering, show dash
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.01.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.customIcons != null &&
                index < widget.customIcons!.length)
              Center(
                child: _rowIcon(widget.customIcons![index]),
              ),
            SizedBox(width: _iconGap),
            if (widget.personalInfoTexts != null &&
                index < widget.personalInfoTexts!.length)
              _Lbl(
                widget.personalInfoTexts![index].capitalize as String,
                width: widget.labelColumnWidth,
                style: StyleText.fontSize16Weight400.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.secondaryText,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            SizedBox(width: _valueGap),
            Text(
              '-',
              style: StyleText.fontSize16Weight400.copyWith(
                fontSize: 14.sp,
                color: !AppTheme.isDark
                    ? AppColors.colorBlack
                    : AppColors.colorWhiteDark,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    // Show wrapped containers for valid data
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.01.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label (icon + text)
          Row(
            children: [
              if (widget.customIcons != null &&
                  index < widget.customIcons!.length)
                Center(
                  child: _rowIcon(widget.customIcons![index]),
                ),
              SizedBox(width: _iconGap),
              if (widget.personalInfoTexts != null &&
                  index < widget.personalInfoTexts!.length)
                _Lbl(
                  widget.personalInfoTexts![index].capitalize as String,
                  width: widget.labelColumnWidth,
                  style: StyleText.fontSize16Weight400.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.secondaryText,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
          SizedBox(width: _valueGap),
          // Wrapped containers with horizontal scroll
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8.w,
                runSpacing: 4.h,
                children: items.map((item) {
                  return Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: lightMode ? Colors.grey[300] : Colors.grey[700],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      item.capitalize ?? item,
                      style: StyleText.fontSize16Weight400.copyWith(
                        fontSize: 14.sp,
                        color: !AppTheme.isDark
                            ? AppColors.colorBlack
                            : AppColors.colorWhiteDark,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRowContent(int index) {
    if (widget.chipLabels != null &&
        widget.personalInfoTexts != null &&
        index < widget.personalInfoTexts!.length &&
        widget.chipLabels!.contains(widget.personalInfoTexts![index])) {
      return _buildMobileSkillsHobbiesItem(index);
    }
    // 22/10/2026 (Moataz: icons "not aligned by eye … centred to the title
    // and the value"): the icon is centred on the FIRST line of text — the
    // texts start (icon − line) / 2 lower, so a value that wraps still
    // keeps its first line beside the icon.
    final double rowFont = kpIsPhoneLayout(context) ? 12.sp : 14.sp;
    final double lineHeight = rowFont * 1.4;
    final double textTop = ((_rowIconSize - lineHeight) / 2).clamp(0.0, 20.0);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.005.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (widget.customIcons != null && index < widget.customIcons!.length)
            _rowIcon(widget.customIcons![index]),
          SizedBox(width: _iconGap),
          if (widget.personalInfoTexts != null &&
              index < widget.personalInfoTexts!.length)
            Padding(
              padding: EdgeInsets.only(top: textTop),
              child: _Lbl(
                widget.personalInfoTexts![index].capitalize as String,
                width: widget.labelColumnWidth,
                style: StyleText.fontSize16Weight400.copyWith(
                  fontSize: rowFont,
                  color: AppColors.secondaryText,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          SizedBox(width: _valueGap),
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(top: textTop),
              child: Text(
                widget.secondaryTexts![index].contains('AM') ||
                        widget.secondaryTexts![index].contains('PM')
                    ? widget.secondaryTexts![index].toUpperCase()
                    : widget.secondaryTexts![index].contains('@')
                        ? widget.secondaryTexts![index]
                        : widget.secondaryTexts![index].capitalize as String,
                maxLines: 14,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize16Weight400.copyWith(
                  fontSize: rowFont,
                  color: !AppTheme.isDark
                      ? AppColors.colorBlack
                      : AppColors.colorWhiteDark,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

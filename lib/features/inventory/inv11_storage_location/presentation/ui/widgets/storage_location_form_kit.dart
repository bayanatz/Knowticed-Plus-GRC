/// Module: inventory_module / in11_storage_location
///
///*************************** FILE INFO ****************************///
/// File Name: storage_location_form_kit.dart
/// Purpose: One place that decides how every field on the Storage Location
///          screens looks, so text fields, dropdowns and the date field share
///          the SAME height, inner padding and corner radius.
/// Created at: 5/10/2026
///
/// Figma: MESBAH, "Stroage Location Details" (4068:28690) and
/// "Product Details_Stock_Assigning Product" (4068:30386).
///   * field box ........ 36 tall, radius 4, fill #F5F5F5
///   * inner padding .... 9 on both sides (the design drew text fields at 9
///                        and dropdowns at 8; one value is used for both so
///                        their text starts at the same x)
///   * label ............ 14 regular #2D2D2D, above the box
///   * row pitch ........ label + box + 15 gap
///   * two columns ...... 15 apart
///
/// Built ONLY from the shared custom widgets:
///   1-custom_dropdown.dart, 2-custom_textfield.dart,
///   3-custom_dropdown_calander.dart.
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/helper/location_data_service.dart';
import 'package:knowticed_plus/features/inventory/helpers/constants/constant_lists.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// The storage-location photo placeholder.
///
/// Figma draws a shelving-unit icon here (node 4068:28833). It could not be
/// exported from this account (View seat), so the inventory warehouse icon
/// stands in. To use the real one: in Figma select that layer, Export → SVG,
/// save it as assets/icons_assets/inventory_assets/storage_location_shelves.svg
/// and point this constant at it.
const String kStorageLocationPlaceholderIcon =
    'assets/icons_assets/main_icons_assets/ic_module_inventory.svg';

/// Raw design numbers. Widgets 1/2/3 take `height` UNSCALED (they apply
/// `.sp` themselves), so [height] stays a plain number here.
abstract class StorageFieldSpec {
  static const double height = 36;
  static const double noteHeight = 72;
  static const double horizontalPadding = 9;
  static const double radius = 4;
  static const double rowGap = 15;
  static const double columnGap = 15;

  /// Empty space the 14 label's line box adds ABOVE its capitals (Cairo's
  /// ascent is far taller than its cap height). Figma trims text to the cap
  /// line, so a card whose first child is a label must take this off its top
  /// padding — otherwise the top gap reads ~23 against a 15 side gap and the
  /// corner is not square (the "diagonal" between top and side insets).
  static const double labelTopTrim = 8;

  /// Card inset: 15 on every side, minus [labelTopTrim] on top when the first
  /// thing in the card is a field label.
  static EdgeInsetsGeometry cardPadding({required bool startsWithLabel}) =>
      EdgeInsetsDirectional.fromSTEB(
        15.sp,
        (startsWithLabel ? 15 - labelTopTrim : 15).sp,
        15.sp,
        15.sp,
      );

  /// Inside padding shared by the text field, the dropdown trigger and the
  /// date field. Vertical is 0 because the box height is pinned to [height].
  static EdgeInsetsGeometry get contentPadding =>
      EdgeInsetsDirectional.symmetric(horizontal: horizontalPadding.sp);

  /// Chevron inset, so the arrow sits [horizontalPadding] from the end edge,
  /// mirroring the text inset at the start edge.
  static EdgeInsetsGeometry get suffixPadding =>
      EdgeInsetsDirectional.only(start: 8.sp, end: horizontalPadding.sp);

  static BorderRadius get borderRadius => BorderRadius.circular(radius.r);
}

/// Multi-select (31-custom_multi_select_dropdown.dart) held to the SAME box
/// as [StorageDropdown]: 36 tall, 9 inset, chevron 9 from the end, 12 text
/// in [AppColors.text], hint in the shared dropdown hint grey.
///
/// `heightSizesWholeTrigger` makes the widget paint a fixed 36 box itself
/// (no InputDecorator), with [StorageFieldSpec.contentPadding] inside it.
class StorageMultiDropdown<T> extends StatelessWidget {
  const StorageMultiDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.values,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final List<MultiSelectDropdownItem<T>> items;
  final List<T> values;
  final ValueChanged<List<T>> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final bool hasValue = values.isNotEmpty;
    return CustomMultiSelectFilter<T>(
      label: label,
      hint: hint ?? label,
      items: items,
      values: values,
      onChanged: onChanged,
      selectedTextBuilder: (selected) =>
          selected.map((e) => e.label).join(', '),
      height: StorageFieldSpec.height,
      heightSizesWholeTrigger: true,
      triggerPadding: StorageFieldSpec.contentPadding,
      borderRadius: StorageFieldSpec.borderRadius,
      fillColor: kDropdownFillColor,
      valueStyle: StyleText.fontSize12Weight400.copyWith(
        color: AppColors.text,
      ),
      hintStyle: StyleText.fontSize12Weight400.copyWith(
        color: kDropdownHintColor,
      ),
      suffixIcon: CustomSvgImage(
        assetPath:
            'assets/icons_assets/main_icons_assets/ic_nav_chevron_down.svg',
        width: 20.sp,
        height: 20.sp,
        color: kDropdownTrailingIconColor(hasValue: hasValue),
      ),
    );
  }
}

/// Text field (2-custom_textfield.dart) at the storage-location spec.
class StorageTextField extends StatelessWidget {
  const StorageTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.readOnly = false,
    this.onChanged,
    this.onlyDigits = false,
    this.multiline = false,
    this.maxLength,
    this.textDirection,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final bool onlyDigits;

  /// The Additional Note box: 72 tall, 3 lines, "0/500" counter.
  final bool multiline;
  final int? maxLength;
  final ui.TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      hint: hint ?? S.of(context).textHere,
      controller: controller,
      readOnly: readOnly,
      onChanged: onChanged,
      onlyDigits: onlyDigits,
      keyboardType: onlyDigits ? TextInputType.number : null,
      textDirection: textDirection,
      maxLines: multiline ? 3 : 1,
      maxLength: multiline ? (maxLength ?? 500) : maxLength,
      showCharCount: multiline,
      height: multiline ? StorageFieldSpec.noteHeight : StorageFieldSpec.height,
      contentPadding: multiline
          ? EdgeInsetsDirectional.symmetric(
              horizontal: StorageFieldSpec.horizontalPadding.sp,
              vertical: 7.sp,
            )
          : StorageFieldSpec.contentPadding,
      borderRadius: StorageFieldSpec.borderRadius,
    );
  }
}

/// Dropdown (1-custom_dropdown.dart) at the storage-location spec.
///
/// With [readOnly] it still draws its chevron (as the read-only fields in the
/// Figma details frame do) but cannot be opened.
class StorageDropdown<T> extends StatelessWidget {
  const StorageDropdown({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.hint,
    this.readOnly = false,
  });

  final String label;
  final List<DropdownItem<T>> items;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String? hint;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<T>(
      label: label,
      hint: hint ?? label,
      items: items,
      value: value,
      onChanged: readOnly ? null : onChanged,
      enabled: !readOnly,
      height: StorageFieldSpec.height,
      triggerPadding: StorageFieldSpec.contentPadding,
      suffixIconPadding: StorageFieldSpec.suffixPadding,
      borderRadius: StorageFieldSpec.borderRadius,
    );
  }
}

/// A read-only dropdown that just shows [text] (details screen).
class StorageReadOnlyDropdown extends StatelessWidget {
  const StorageReadOnlyDropdown({
    super.key,
    required this.label,
    required this.text,
  });

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return StorageDropdown<String>(
      label: label,
      readOnly: true,
      value: text.isEmpty ? null : text,
      hint: '-',
      items: [
        if (text.isNotEmpty) DropdownItem<String>(value: text, label: text),
      ],
    );
  }
}

/// Date field (3-custom_dropdown_calander.dart) at the storage-location spec.
class StorageDateField extends StatelessWidget {
  const StorageDateField({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.readOnly = false,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return CustomDateField(
      label: label,
      hint: label,
      value: value,
      onChanged: readOnly ? null : onChanged,
      enabled: !readOnly,
      height: StorageFieldSpec.height,
      contentPadding: StorageFieldSpec.contentPadding,
      borderRadius: StorageFieldSpec.borderRadius,
    );
  }
}

/// Two fields side by side (15 apart); stacked on phones.
class StorageFieldsRow extends StatelessWidget {
  const StorageFieldsRow({super.key, required this.left, this.right});

  final Widget left;

  /// Null leaves the right column empty, keeping [left] at half width.
  final Widget? right;

  @override
  Widget build(BuildContext context) {
    final bool isPhone = kpIsPhoneLayout(context);
    if (isPhone) {
      return Column(
        children: [
          left,
          if (right != null) ...[
            SizedBox(height: StorageFieldSpec.rowGap.sp),
            right!,
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        SizedBox(width: StorageFieldSpec.columnGap.sp),
        Expanded(child: right ?? const SizedBox.shrink()),
      ],
    );
  }
}

/// Fields stacked with the design's 15 row gap between them.
class StorageFieldsColumn extends StatelessWidget {
  const StorageFieldsColumn({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: StorageFieldSpec.rowGap.sp),
          children[i],
        ],
      ],
    );
  }
}

/// A titled white card with the blue "Hide" / "Show" link on the end edge,
/// as every section in the Figma details frame has.
class StorageSection extends StatefulWidget {
  const StorageSection({
    super.key,
    required this.title,
    required this.child,
    this.collapsible = true,
    this.startsWithLabel = true,
    this.padding,
  });

  final String title;
  final Widget child;
  final bool collapsible;

  /// Whether the card's first child is a field label (see
  /// [StorageFieldSpec.labelTopTrim]). False for a card that opens with a
  /// photo, a search bar or anything else without a label line box.
  final bool startsWithLabel;
  final EdgeInsetsGeometry? padding;

  @override
  State<StorageSection> createState() => _StorageSectionState();
}

class _StorageSectionState extends State<StorageSection> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: StyleText.fontSize16Weight600.copyWith(
                  color: light ? AppColors.blackButton : AppColors.white,
                ),
              ),
            ),
            if (widget.collapsible)
              GestureDetector(
                onTapDown: (_) => HapticController.low(),
                onTap: () => setState(() => _hidden = !_hidden),
                child: Text(
                  _hidden ? S.of(context).show : S.of(context).hide,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: const Color(0xFF1877F2),
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFF1877F2),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.sp),
        if (!_hidden)
          Container(
            width: double.infinity,
            padding: widget.padding ??
                StorageFieldSpec.cardPadding(
                  startsWithLabel: widget.startsWithLabel,
                ),
            decoration: BoxDecoration(
              color: light ? AppColors.white : AppColors.chatBackground,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: widget.child,
          ),
      ],
    );
  }
}

/// Primary / secondary action button pair helpers keep the disabled look in
/// one place: a disabled button is the Discard grey and does not respond.
Color storageButtonColor({required bool enabled}) =>
    enabled ? AppColors.primary : const Color(0xCCCCCCCC);

/// Discard: dark grey fill, text in [AppColors.text].
Color get storageDiscardColor => AppColors.darkGrey;
TextStyle get storageDiscardTextStyle =>
    StyleText.fontSize16Weight500.copyWith(color: AppColors.text);

/// Fill for controls that sit INSIDE a white/card section (search bar,
/// department filter, employee cards): the opposite of the card, so they read
/// as fields on it — [AppColors.background] on [AppColors.card].
Color get kStorageInnerFill => AppColors.background;

/// The small "Employee ▾" role picker on an employee card (Figma 4068:30484):
/// 20 tall, 8 text centred vertically, 5 inset, 9 chevron.
class StorageRoleChip extends StatelessWidget {
  const StorageRoleChip({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.fillColor,
  });

  /// 'employee' or 'manager'.
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final Color textColor = light ? AppColors.secondaryText : AppColors.grey;
    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.6,
        child: SizedBox(
          width: 66.sp,
          child: CustomDropdown<String>(
            items: [
              DropdownItem<String>(
                  value: 'employee', label: S.of(context).employee),
              DropdownItem<String>(
                  value: 'manager', label: S.of(context).manager),
            ],
            value: value,
            onChanged: onChanged,
            height: 20,
            enforceTypeScale: false,
            valueStyle: StyleText.fontSize8Weight400.copyWith(
              color: textColor,
              height: 1,
            ),
            itemStyle: StyleText.fontSize12Weight400,
            triggerPadding: EdgeInsetsDirectional.symmetric(horizontal: 5.sp),
            suffixIconPadding: EdgeInsetsDirectional.only(end: 5.sp),
            suffixIcon: CustomSvgImage(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_nav_chevron_down.svg',
              width: 9.sp,
              height: 9.sp,
              fit: BoxFit.contain,
              color: textColor,
            ),
            fillColor: fillColor ?? AppColors.card,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }
}

/// Country → State/Province → City as cascading dropdowns, plus the Postal
/// Code field beside City — the two rows of the storage-location form.
///
/// Data: `LocationDataService` (core/helper/main_helper) — countries from the
/// `country_picker` package (Arabic names included), states and cities from
/// assets/data/location_data.json. Same source and behaviour as the location
/// dropdowns on the Settings edit-request screen.
///
/// The three controllers keep holding the shown LABEL (e.g. "Egypt",
/// "Cairo"), so everything that reads them — validation, the data map handed
/// to the next step, the Firestore save — is unchanged. Saved values are
/// matched back loosely on open, so older free-typed values still resolve.
///
/// When the data has no states (or no cities) for the chosen country/state,
/// that field falls back to a plain text field so the form can still be
/// completed.
class StorageLocationFields extends StatefulWidget {
  const StorageLocationFields({
    super.key,
    required this.countryController,
    required this.stateController,
    required this.cityController,
    required this.postalCode,
    this.onChanged,
  });

  final TextEditingController countryController;
  final TextEditingController stateController;
  final TextEditingController cityController;

  /// Shown at the end of the City row (the Postal Code field).
  final Widget postalCode;

  /// Called after any of the three values changes (re-run validation).
  final VoidCallback? onChanged;

  @override
  State<StorageLocationFields> createState() => _StorageLocationFieldsState();
}

class _StorageLocationFieldsState extends State<StorageLocationFields> {
  final LocationDataService _service = LocationDataService.instance;
  bool _ready = false;
  String? _countryIso;
  String? _stateCode;

  @override
  void initState() {
    super.initState();
    _service.load().then((_) {
      if (!mounted) return;
      setState(() {
        _ready = true;
        _resolveSaved();
      });
    });
  }

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  LocationOption? _match(List<LocationOption> options, String text) =>
      options.firstWhereOrNull((o) => o.matches(text)) ??
      options.firstWhereOrNull((o) => o.matchesLoose(text));

  /// Turns values already in the controllers (a draft, an edited record) back
  /// into dropdown selections. A value that matches nothing is left as typed.
  void _resolveSaved() {
    final country =
        _match(_service.countries(context), widget.countryController.text);
    if (country == null) return;
    _countryIso = country.code;
    widget.countryController.text = country.label(_isArabic);

    final states = _service.statesOf(_countryIso);
    final state = _match(states, widget.stateController.text);
    if (state == null) return;
    _stateCode = state.code;
    widget.stateController.text = state.label(_isArabic);

    final city = _match(
      _service.citiesOf(_countryIso, _stateCode),
      widget.cityController.text,
    );
    if (city != null) widget.cityController.text = city.label(_isArabic);
  }

  void _changed() => widget.onChanged?.call();

  @override
  Widget build(BuildContext context) {
    final bool ar = _isArabic;
    final countries = _service.countries(context);
    final states = _service.statesOf(_countryIso);
    final cities = _service.citiesOf(_countryIso, _stateCode);

    final Widget country = StorageDropdown<String>(
      label: S.of(context).country,
      hint: S.of(context).enterYourCountry,
      value: _countryIso,
      items: countries
          .map((o) => DropdownItem<String>(value: o.code, label: o.label(ar)))
          .toList(),
      onChanged: (iso) {
        final picked = countries.firstWhere((o) => o.code == iso);
        setState(() {
          _countryIso = iso;
          widget.countryController.text = picked.label(ar);
          // A state / city from the old country means nothing under the new one.
          _stateCode = null;
          widget.stateController.clear();
          widget.cityController.clear();
        });
        _changed();
      },
    );

    // No state data for this country → let the user type it.
    final bool typeState = _ready && _countryIso != null && states.isEmpty;
    final Widget state = typeState
        ? StorageTextField(
            label: S.of(context).stateOrProvince,
            hint: S.of(context).enterYourStateOrProvince,
            controller: widget.stateController,
            onChanged: (_) => _changed(),
          )
        : StorageDropdown<String>(
            label: S.of(context).stateOrProvince,
            hint: _countryIso == null
                ? S.of(context).country
                : S.of(context).enterYourStateOrProvince,
            value: _stateCode,
            readOnly: _countryIso == null,
            items: states
                .map((o) =>
                    DropdownItem<String>(value: o.code, label: o.label(ar)))
                .toList(),
            onChanged: (code) {
              final picked = states.firstWhere((o) => o.code == code);
              setState(() {
                _stateCode = code;
                widget.stateController.text = picked.label(ar);
                widget.cityController.clear();
              });
              _changed();
            },
          );

    // Typed state, or no city data for this state → type the city too.
    final bool typeCity =
        typeState || (_ready && _stateCode != null && cities.isEmpty);
    final String currentCity = widget.cityController.text.trim();
    final Widget city = typeCity
        ? StorageTextField(
            label: S.of(context).city,
            hint: S.of(context).enterYourCity,
            controller: widget.cityController,
            onChanged: (_) => _changed(),
          )
        : StorageDropdown<String>(
            label: S.of(context).city,
            hint: _stateCode == null
                ? S.of(context).stateOrProvince
                : S.of(context).enterYourCity,
            // Cities carry no code in the data, so the value IS the label.
            value: cities.any((o) => o.label(ar) == currentCity)
                ? currentCity
                : null,
            readOnly: _stateCode == null,
            items: cities
                .map((o) => DropdownItem<String>(
                      value: o.label(ar),
                      label: o.label(ar),
                    ))
                .toList(),
            onChanged: (label) {
              setState(() => widget.cityController.text = label);
              _changed();
            },
          );

    return StorageFieldsColumn(
      children: [
        StorageFieldsRow(left: country, right: state),
        StorageFieldsRow(left: city, right: widget.postalCode),
      ],
    );
  }
}

/// Width of the Unit box beside Storage Capacity: wide enough for the LONGEST
/// unit label in the current language ("Pallet Space", "مساحة البليت", …), so
/// no option is ever cut to "Pallet …". Measured, not hard-coded, so a new or
/// longer translation still fits. Never narrower than the original 100.
double storageUnitBoxWidth(BuildContext context) {
  final TextStyle style = StyleText.fontSize14Weight500;
  final TextDirection dir = Directionality.of(context);
  double widest = 0;
  for (final unit in ConstantLists.storageCapacityList()) {
    final painter = TextPainter(
      text: TextSpan(text: unit['value'] ?? '', style: style),
      textDirection: dir,
      maxLines: 1,
    )..layout();
    if (painter.width > widest) widest = painter.width;
  }
  // text + start inset + gap before chevron + chevron + end inset + slack
  final double width = widest +
      StorageFieldSpec.horizontalPadding.sp +
      8.sp +
      20.sp +
      StorageFieldSpec.horizontalPadding.sp +
      6.sp;
  return width < 100.sp ? 100.sp : width;
}

// ─── Page tabs (Figma 4068:28934 / 4068:28935) ───────────────────────────────

/// "Storage Location Details | Stored Products" — 20 SemiBold, the selected
/// tab in secondaryPrimary (#E5B800) and underlined, the other in
/// secondaryText (#797979), 24 apart.
class StorageTabs extends StatelessWidget {
  const StorageTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24.sp,
      runSpacing: 8.sp,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < labels.length; i++)
          InkWell(
            onTapDown: (_) => HapticController.low(),
            onTap: () => onChanged(i),
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Text(
              labels[i],
              style: StyleText.fontSize20Weight600.copyWith(
                color: i == selected
                    ? AppColors.secondaryPrimary
                    : AppColors.secondaryText,
                decoration: i == selected
                    ? TextDecoration.underline
                    : TextDecoration.none,
                decorationColor: AppColors.secondaryPrimary,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Status chip (Figma 4068:28859) ─────────────────────────────────────────

/// 100 wide, 8 × 12 padding, radius 4, inner fill, text 12 SemiBold:
/// green for active, red for inactive. An empty status reads as active —
/// that is what every new location is created with.
class StorageStatusChip extends StatelessWidget {
  const StorageStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final String s = status.trim().toLowerCase();
    final bool inactive = s == 'inactive' || s == 'غير نشط';
    return Container(
      width: 100.sp,
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: light ? kStorageInnerFill : AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        inactive ? S.of(context).inactive : S.of(context).active,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: StyleText.fontSize12Weight600.copyWith(
          height: 1.32,
          color: inactive ? Colors.red[700] : const Color(0xff4BB609),
        ),
      ),
    );
  }
}

// ─── Circular photo picker (Figma 4307:27702) ───────────────────────────────

/// 65 × 65 circle (#D9D9D9) holding the photo — or the image placeholder
/// icon when there is none — with a 24 × 24 yellow (#FFDE59) camera badge
/// flush with the bottom-end corner. Every size uses `.r` so the circle and
/// the badge never stretch into ovals. The badge stays visible after a photo
/// is picked so the photo can be changed.
class CirclePhotoPicker extends StatelessWidget {
  const CirclePhotoPicker({super.key, this.image, this.onTap});

  /// The picked / saved photo (Image.file / Image.network); null shows the
  /// placeholder icon.
  final Widget? image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool light = Theme.of(context).brightness == Brightness.light;
    final double size = 65.r;
    final double badge = 24.r;
    return GestureDetector(
      onTapDown: hapticDown(onTap, HapticLevel.medium),
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: light ? const Color(0xffD9D9D9) : AppColors.background,
              ),
              child: image != null
                  ? SizedBox(width: size, height: size, child: image)
                  : Center(
                      child: CustomSvgImage(
                        assetPath:
                            'assets/icons_assets/main_icons_assets/ic_media_image.svg',
                        width: 30.r,
                        height: 30.r,
                        fit: BoxFit.contain,
                        color: AppColors.textButton,
                      ),
                    ),
            ),
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: Container(
                width: badge,
                height: badge,
                decoration: const BoxDecoration(
                  color: Color(0xffFFDE59),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomSvgImage(
                    assetPath:
                        'assets/icons_assets/main_icons_assets/ic_media_attach_square.svg',
                    width: 14.r,
                    height: 14.r,
                    fit: BoxFit.contain,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Form tools: Clear All / Fill sample data ───────────────────────────────

/// Two small buttons at the top-end of an "Add …" form.
///
/// * **Clear All** empties every field the user can type into (auto-generated
///   IDs are kept).
/// * **Fill sample data** fills the form with realistic values so a flow can
///   be tested end to end in seconds. It only appears in debug builds — a
///   release build never shows it, so testers and customers cannot create
///   sample records by accident.
class FormToolsBar extends StatelessWidget {
  const FormToolsBar({super.key, required this.onClear, this.onFill});

  final VoidCallback onClear;
  final VoidCallback? onFill;

  @override
  Widget build(BuildContext context) {
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final bool light = Theme.of(context).brightness == Brightness.light;

    Widget button({
      required String label,
      required IconData icon,
      required VoidCallback onTap,
      required Color fill,
      required Color fg,
    }) {
      return InkWell(
        onTapDown: hapticDown(onTap, HapticLevel.low),
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.r),
        child: Container(
          height: 30.sp,
          padding: EdgeInsets.symmetric(horizontal: 10.sp),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14.sp, color: fg),
              SizedBox(width: 6.sp),
              Text(
                label,
                style: StyleText.fontSize14Weight500.copyWith(color: fg),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Wrap(
        spacing: 10.sp,
        runSpacing: 8.sp,
        children: [
          if (onFill != null && kDebugMode)
            button(
              label: ar ? 'تعبئة بيانات تجريبية' : 'Fill sample data',
              icon: Icons.auto_fix_high_rounded,
              onTap: onFill!,
              fill: const Color(0xff2D2D2D),
              fg: const Color(0xffF5F5F5),
            ),
          button(
            label: S.of(context).clearAll,
            icon: Icons.cleaning_services_outlined,
            onTap: onClear,
            fill: light ? AppColors.white : AppColors.chatBackground,
            fg: Colors.red[700]!,
          ),
        ],
      ),
    );
  }
}

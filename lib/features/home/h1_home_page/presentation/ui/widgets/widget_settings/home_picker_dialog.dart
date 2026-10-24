/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_picker_dialog.dart
/// Purpose: Declares `showHomePickerDialog` — the gear of the Group Messages
///          and Employee Messages cards: search (+ Department for people),
///          a two-column grid of tiles (picture · name · tick box), Cancel /
///          Add. Picks between [min] and [max] items.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// Figma `3948:122924` (Frame 1597885424, 622 wide): 15 padding; header =
/// 30 yellow circle + 18 "Users Group Rounded" + 8 + 16 Medium title;
/// search 38 high, radius 8, card colour, with Department (155) 15 apart;
/// tiles 65 high, radius 8, 15 apart: 10 padding, 40 picture, 5, name 14
/// Medium, 24 tick box 10 in from the top-end corner; Cancel (grey) at the
/// start, Add (yellow) at the end, 135 × 38, radius 8, 16 Medium.
/// Owner 21/10/2026: "select one group, two, three, four — maximum four,
/// minimum one"; the same picker for Employee Messages.
library;

import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_check_box.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The group icon of the picker header and of a group without a picture
/// (Figma "Linear / Users / Users Group Rounded").
const String kHomeGroupIcon =
    'assets/icons_assets/main_icons_assets/ic_users_group_rounded.svg';

/// One choice in the picker.
class HomePickItem {
  const HomePickItem({
    required this.id,
    required this.name,
    this.photo,
    this.departmentId = '',
    this.departmentName = '',
    this.isGroup = false,
    this.placeholderIcon,
    this.subtitle,
  });

  final String id;
  final String name;

  /// Network picture; empty shows the default avatar (or the group icon).
  final String? photo;
  final String departmentId;
  final String departmentName;
  final bool isGroup;

  /// Drawn when there is no picture (a form, say); null = avatar / group.
  final String? placeholderIcon;

  /// Grey second line (a form's submitted count, say); null = none.
  final String? subtitle;
}

/// One remembered picker list: what the gear last fetched, kept for [ttl] so
/// the next tap opens at once instead of waiting on Firestore.
class HomePickerCacheEntry {
  List<HomePickItem>? _items;
  DateTime? _at;
  static const Duration ttl = Duration(minutes: 2);

  /// The list while it is still fresh, else null.
  List<HomePickItem>? get fresh =>
      _items != null && DateTime.now().difference(_at!) < ttl ? _items : null;

  List<HomePickItem> store(List<HomePickItem> items) {
    _items = items;
    _at = DateTime.now();
    return items;
  }
}

/// The lists behind the Forms and Group Messages gears.
abstract final class HomePickerCache {
  static final HomePickerCacheEntry forms = HomePickerCacheEntry();
  static final HomePickerCacheEntry groupsEn = HomePickerCacheEntry();
  static final HomePickerCacheEntry groupsAr = HomePickerCacheEntry();
}

/// Function Name: [showHomePickerDialog]
///
/// Purpose: Let the user pick [min]–[max] of [items], starting from
/// [initial]. Returns the picked ids in the order they were ticked, or null
/// on Cancel.
Future<List<String>?> showHomePickerDialog(
  BuildContext context, {
  required String title,
  required List<HomePickItem> items,
  String icon = kHomeGroupIcon,
  List<String> initial = const <String>[],
  int min = 1,
  int max = 4,
}) {
  return showDialog<List<String>>(
    context: context,
    builder: (_) => _HomePickerDialog(
      title: title,
      icon: icon,
      items: items,
      initial: initial,
      min: min,
      max: max,
    ),
  );
}

class _HomePickerDialog extends StatefulWidget {
  const _HomePickerDialog({
    required this.title,
    required this.icon,
    required this.items,
    required this.initial,
    required this.min,
    required this.max,
  });

  final String title;

  /// Header glyph (groups and people: the group icon; forms: the form icon).
  final String icon;
  final List<HomePickItem> items;
  final List<String> initial;
  final int min;
  final int max;

  @override
  State<_HomePickerDialog> createState() => _HomePickerDialogState();
}

class _HomePickerDialogState extends State<_HomePickerDialog> {
  final TextEditingController _search = TextEditingController();

  /// Picked ids in tick order (that is the order the card shows them in).
  late final List<String> _picked = <String>[
    for (final String id in widget.initial)
      if (widget.items.any((HomePickItem i) => i.id == id)) id,
    // Pick-one with nothing stored: the card shows the first (newest) item,
    // so that one starts ticked (Owner 22:08).
    if (widget.max == 1 && widget.initial.isEmpty && widget.items.isNotEmpty)
      widget.items.first.id,
  ];

  /// '' = every department.
  String _department = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Departments present in the items, by name; empty for groups.
  List<MapEntry<String, String>> get _departments {
    final Map<String, String> byId = <String, String>{};
    for (final HomePickItem i in widget.items) {
      if (i.departmentId.isNotEmpty && i.departmentName.isNotEmpty) {
        byId[i.departmentId] = i.departmentName;
      }
    }
    return byId.entries.toList()
      ..sort((MapEntry<String, String> a, MapEntry<String, String> b) =>
          a.value.compareTo(b.value));
  }

  List<HomePickItem> get _shown {
    final String q = _search.text.trim().toLowerCase();
    return widget.items.where((HomePickItem i) {
      if (_department.isNotEmpty && i.departmentId != _department) {
        return false;
      }
      return q.isEmpty || i.name.toLowerCase().contains(q);
    }).toList();
  }

  void _toggle(HomePickItem item) {
    setState(() {
      if (_picked.remove(item.id)) return;
      // Pick-one (forms): a tap moves the tick.
      if (widget.max == 1) _picked.clear();
      // A 5th cannot be ticked — untick one first.
      if (_picked.length >= widget.max) return;
      _picked.add(item.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<MapEntry<String, String>> departments = _departments;
    final List<HomePickItem> shown = _shown;
    final bool canAdd = _picked.length >= widget.min;

    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Container(
        width: 622.w,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header: 30 yellow circle + 18 icon, 8, title 16 Medium.
            Row(
              children: <Widget>[
                Container(
                  width: 30.r,
                  height: 30.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: CustomSvgImage(
                    assetPath: widget.icon,
                    width: 18.r,
                    height: 18.r,
                    color: AppColors.textButton,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    widget.title,
                    style: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.text),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.r),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppSearchTextField(
                    // It is already in an Expanded here (it adds its own
                    // otherwise — two competing Expandeds threw).
                    expanded: false,
                    controller: _search,
                    hintText: s.search,
                    height: 38,
                    fillColor: AppColors.card,
                    borderRadius: BorderRadius.circular(8.r),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                // Department only when the items carry one (people).
                if (departments.isNotEmpty) ...<Widget>[
                  SizedBox(width: ButtonSizing.toolbarGap(context)),
                  SizedBox(
                    width: 155.w,
                    child: CustomDropdown<String>(
                      hint: s.department,
                      height: 38,
                      fillColor: AppColors.card,
                      borderRadius: BorderRadius.circular(8.r),
                      value: _department.isEmpty ? null : _department,
                      items: <DropdownItem<String>>[
                        DropdownItem<String>(value: '', label: s.all),
                        for (final MapEntry<String, String> d in departments)
                          DropdownItem<String>(value: d.key, label: d.value),
                      ],
                      onChanged: (String v) => setState(() => _department = v),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 15.r),
            Flexible(
              child: shown.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.r),
                      child: Center(
                        child: Text(
                          s.noResults,
                          style: StyleText.fontSize14Weight400
                              .copyWith(color: AppColors.secondaryText),
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      itemCount: shown.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        // Owner 23/10/2026: one card per row on a phone — two
                        // squeezed the names to "Media…".
                        crossAxisCount: kpIsPhoneLayout(context) ? 1 : 2,
                        mainAxisSpacing: 15.r,
                        crossAxisSpacing: 15.w,
                        mainAxisExtent: 65.r,
                      ),
                      itemBuilder: (BuildContext _, int i) {
                        final HomePickItem item = shown[i];
                        final bool picked = _picked.contains(item.id);
                        return _PickTile(
                          item: item,
                          picked: picked,
                          // Full: the others fade until one is unticked.
                          blocked: widget.max > 1 &&
                              !picked &&
                              _picked.length >= widget.max,
                          onTap: () => _toggle(item),
                        );
                      },
                    ),
            ),
            SizedBox(height: 29.r),
            Row(
              children: <Widget>[
                customButton(
                  title: s.cancel,
                  width: 135.w,
                  color: AppColors.darkGrey,
                  textStyle: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.text),
                  function: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                // Disabled (R-3) until [min] are picked.
                Opacity(
                  opacity: canAdd ? 1 : 0.5,
                  child: customButton(
                    title: s.add,
                    width: 135.w,
                    color: canAdd ? AppColors.primary : AppColors.darkGrey,
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.textButton),
                    function: () {
                      if (!canAdd) return;
                      Navigator.of(context).pop(List<String>.of(_picked));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One tile: picture, name, tick box in the top-end corner.
class _PickTile extends StatelessWidget {
  const _PickTile({
    required this.item,
    required this.picked,
    required this.blocked,
    required this.onTap,
  });

  final HomePickItem item;
  final bool picked;
  final bool blocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = (item.photo ?? '').startsWith('http');
    return Opacity(
      opacity: blocked ? 0.5 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: blocked
            ? null
            : () {
                HapticController.low();
                onTap();
              },
        child: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: hasPhoto
                    ? Image.network(
                        item.photo!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              SizedBox(width: 8.w),
              // Owner 22:02: a long name wraps to two lines and stops 8
              // before the tick box — it never runs into it.
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.name,
                      maxLines: item.subtitle == null ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.text, height: 1.2),
                    ),
                    if (item.subtitle != null)
                      Text(
                        item.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize12Weight400
                            .copyWith(color: AppColors.secondaryText),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: CustomCheckBox(isSelected: picked, size: 24.r),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => item.placeholderIcon != null
      ? Center(
          child: CustomSvgImage(
            assetPath: item.placeholderIcon!,
            width: 20.r,
            height: 20.r,
            color: AppColors.primary,
          ),
        )
      : item.isGroup
          ? Center(
              child: CustomSvgImage(
                assetPath: kHomeGroupIcon,
                width: 20.r,
                height: 20.r,
                color: AppColors.secondaryText,
              ),
            )
          : CustomSvgImage(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png',
              width: 40.r,
              height: 40.r,
              fit: BoxFit.cover,
            );
}

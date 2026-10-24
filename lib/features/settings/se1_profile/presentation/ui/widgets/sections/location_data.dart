/// Module: settings/se1_profile
///
///*************************** FILE INFO ****************************///
/// File Name: location_data.dart
/// Purpose: The Location card of the personal-information page — country,
///          province, city and street, all read-only.
/// Author: Amr Mesbah
/// Created at: 10/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE1-N06/N15/N17/N18: takes a [PersonalProfile]
///          instead of force-unwrapping the `employee` global, the commented
///          REMOVED_MODULE import and the unused `lightMode` / `isTablet`
///          locals are gone, and Colors.transparent is routed through
///          AppColors.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/helper/stored_value_ar.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/features/settings/se1_profile/domain/entities/personal_profile.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class LocationData extends StatefulWidget {
  const LocationData({super.key, required this.profile});

  /// The address values. Previously read as `employee!.country?.lastOrNull` and
  /// friends — a force-unwrap of a mutable global (CR-SKEL-SE1-N17).
  final PersonalProfile profile;

  @override
  State<LocationData> createState() => _LocationDataState();
}

class _LocationDataState extends State<LocationData> {
  late final TextEditingController _countryController;
  late final TextEditingController _provinceController;
  late final TextEditingController _cityController;
  late final TextEditingController _streetController;

  @override
  void initState() {
    super.initState();
    _countryController =
        TextEditingController(text: _display(widget.profile.country));
    _provinceController =
        TextEditingController(text: _display(widget.profile.province));
    _cityController =
        TextEditingController(text: _display(widget.profile.city));
    _streetController =
        TextEditingController(text: _display(widget.profile.street));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The screen language can change while the page is open.
    _fill();
  }

  void _fill() {
    _countryController.text = _display(widget.profile.country);
    _provinceController.text = _display(widget.profile.province);
    _cityController.text = _display(widget.profile.city);
    _streetController.text = _display(widget.profile.street);
  }

  @override
  void didUpdateWidget(covariant LocationData oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) _fill();
  }

  /// Owner 24/10/2026: a value picked from the dropdown is saved in English
  /// but read in the screen's language, as it is on the edit page.
  String _display(String value) => value.isEmpty
      ? ''
      : StoredValueAr.of(context, FormatHelper.capitalize(value));

  @override
  void dispose() {
    _countryController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPhone = ContextExtension(context).isPhone;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      decoration: isPhone
          // Mobile only: rounded like each card on the edit page.
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.card,
            )
          : BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              color: AppColors.card,
            ),
      child: Column(
        children: [
          // 20/10/2026 (Moataz "consistency in padding"): the Contact card
          // above already ends with 15, so no extra gap here — phone → Location
          // is the same 15 as Status → Contact.
          // D-223: the Contact group above ends with its 15 inset.
          // D-243: Contact's bottom 16 + 8 = 24 before this group title.
          SizedBox(height: 8.sp),
          SettingsHeader(
              // 16.sp on every device, the same inset as the fields below
              // (18/10/2026). The default is 16.sp on a phone but 0 on
              // iPad / desktop, so the heading sat 15 left of the fields.
              horizontalPadding: 16.sp,
              imagePath:
                  'assets/icons_assets/settings_assets/ic_place_city.svg',
              text: S.of(context).location),
          Padding(
            padding: EdgeInsets.only(
                top: 0.sp, right: 16.sp, left: 16.sp, bottom: 16.sp),
            child: Column(
              children: [
                // Mobile only: 16.sp after a section title. Others keep 10.sp.
                // Item 172 (21/10/2026): the same 16 after the title as the
                // Contact group above.
                SizedBox(height: 12.sp),

                // Country, Province, City in one row
                isPortrait
                    ? Column(
                        children: [
                          // Country Field
                          CustomTextField(
                            label: S.of(context).country,
                            hint: S.of(context).enterYourCountry,
                            controller: _countryController,
                            enabled: false,
                          ),
                          // Mobile only: matches the 16.h the edit page uses between fields.
                          SizedBox(height: 12.sp),

                          // Province Field
                          CustomTextField(
                            label: S.of(context).stateOrProvince,
                            hint: S.of(context).enterYourStateOrProvince,
                            controller: _provinceController,
                            enabled: false,
                          ),
                          // Mobile only: matches the 16.h the edit page uses between fields.
                          SizedBox(height: 12.sp),

                          // City Field
                          CustomTextField(
                            label: S.of(context).city,
                            hint: S.of(context).enterYourCity,
                            controller: _cityController,
                            enabled: false,
                          ),
                        ],
                      )
                    // Three equal columns separated by a 16.w gap (R-1) — the same grid the
                    // Name and Contact rows use, so every field lines up vertically.
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Country Field
                          Expanded(
                            child: CustomTextField(
                              label: S.of(context).country,
                              hint: S.of(context).enterYourCountry,
                              controller: _countryController,
                              enabled: false,
                            ),
                          ),

                          SizedBox(width: 16.w),

                          // Province Field
                          Expanded(
                            child: CustomTextField(
                              label: S.of(context).stateOrProvince,
                              hint: '_',
                              controller: _provinceController,
                              enabled: false,
                            ),
                          ),

                          SizedBox(width: 16.w),

                          // City Field
                          Expanded(
                            child: CustomTextField(
                              label: S.of(context).city,
                              hint: S.of(context).enterYourCity,
                              controller: _cityController,
                              enabled: false,
                            ),
                          ),
                        ],
                      ),

                // Mobile only: matches the 16.h the edit page uses between fields.
                // Item 172: ONE gap before Street, the same as between the
                // fields above it.
                SizedBox(height: 12.sp),

                // Street Field (Full Width)
                CustomTextField(
                  label: S.of(context).streetName,
                  hint: '-',
                  controller: _streetController,
                  enabled: false,
                ),

                // isPhone ? SizedBox() : SizedBox(height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

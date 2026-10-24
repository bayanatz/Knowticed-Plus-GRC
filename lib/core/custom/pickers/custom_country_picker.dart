/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_country_picker.dart
/// Description: Declares `CountryPickerDialog` — the Select Country dialog
///              used by every phone field (dial code + flag).
/// Author: Amr Mesbah
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 20/10/2026 - Redesigned to the app's dialog style (Moataz,
///          Settings review batch 1, Option A): standard dialog header
///          (30 primary circle + 16 icon + 8 + 18 Medium title, X-18), the
///          shared search field, 36-high rows with the flag, the name and the
///          dial code, the picked row in the primary fill, no dividers, no
///          "243 countries" helper line (C-13), radius 8, width 450 (X-20
///          compact), EN / AR, light / dark.
library;

///*************************** FILE INFO ****************************///
/// Description: Country picker dialog for selecting country and dial code.
/// Created at: 27/10/2025
/// Moved: from features/settings/.../dialogs/country_bicker.dart into
///        core/custom, because 59-custom_intl_phone_field.dart depends on it
///        and core must not import from features.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/countries_list.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_country_flag.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Shows a dialog to select a country with search functionality.
///
/// [selectedDialCode] (optional) marks the current country in the list.
Future<Country?> showCountryPickerDialog(
  BuildContext context, {
  String? selectedDialCode,
}) async {
  return await showAppDialog<Country?>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) =>
        CountryPickerDialog(selectedDialCode: selectedDialCode),
  );
}

class CountryPickerDialog extends StatefulWidget {
  const CountryPickerDialog({super.key, this.selectedDialCode});

  /// Dial code (without "+") of the country to show as picked.
  final String? selectedDialCode;

  @override
  State<CountryPickerDialog> createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<CountryPickerDialog> {
  final TextEditingController searchController = TextEditingController();
  List<Country> filteredCountries = <Country>[];

  @override
  void initState() {
    super.initState();
    filteredCountries = countries;
    searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterCountries);
    searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final String query = searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredCountries = countries;
      } else {
        filteredCountries = countries.where((Country country) {
          return country.name.toLowerCase().contains(query) ||
              country.dialCode.contains(query) ||
              country.code.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  /// Rows are 36 high (D-18) with radius 4; the picked one takes the primary
  /// fill with the text colour on it, every other row is flat on the card.
  Widget _row(Country country, bool lightMode) {
    final bool picked = widget.selectedDialCode != null &&
        widget.selectedDialCode == country.dialCode;
    final Color textColor = picked
        ? AppColors.textButton
        : (lightMode ? AppColors.blackButton : AppColors.white);

    return InkWell(
      borderRadius: BorderRadius.circular(4.r),
      hoverColor: AppColors.transparent,
      onTap: () {
        HapticController.low(); // list row: on the tap (X-117)
        Navigator.of(context).pop(country);
      },
      child: Container(
        height: 36.sp,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 10.sp),
        decoration: BoxDecoration(
          color: picked ? AppColors.primary : AppColors.transparent,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          children: <Widget>[
            AppCountryFlag(isoCode: country.code, width: 24, height: 18),
            SizedBox(width: 10.sp),
            Expanded(
              child: Text(
                country.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize14Weight400.copyWith(color: textColor),
              ),
            ),
            SizedBox(width: 10.sp),
            Text(
              '+${country.dialCode}',
              style: StyleText.fontSize14Weight400.copyWith(
                color: picked
                    ? AppColors.textButton
                    : (lightMode ? AppColors.secondaryText : AppColors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final bool isTablet = !kpIsPhoneLayout(context);
    final double listHeight = MediaQuery.of(context).size.height * 0.5;

    return Dialog(
      backgroundColor: lightMode ? AppColors.white : AppColors.chatBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: SizedBox(
          // X-20 compact dialog width; the phone keeps its 90 % so nothing is
          // cut off (X-73).
          width: isTablet ? 450.sp : MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // X-18 dialog header: 30 primary circle + 16 icon + 8 + title.
              Row(
                children: <Widget>[
                  Container(
                    width: 30.sp,
                    height: 30.sp,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: CustomSvgImage.natural(
                      assetPath:
                          'assets/icons_assets/main_icons_assets/ic_place_pin.svg',
                      width: 16.sp,
                      height: 16.sp,
                      color: AppColors.textButton,
                    ),
                  ),
                  SizedBox(width: 8.sp),
                  Expanded(
                    child: Text(
                      S.of(context).selectCountry,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize18Weight500.copyWith(
                        color:
                            lightMode ? AppColors.blackButton : AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.sp),
              // The shared search field (same radius, hint and icon as every
              // search in the app). Its root is an Expanded, hence the Row.
              Row(
                children: <Widget>[
                  AppSearchTextField(
                    controller: searchController,
                    hintText: S.of(context).searchCountry,
                    fillColor: AppColors.background,
                  ),
                ],
              ),
              SizedBox(height: 12.sp),
              SizedBox(
                height: listHeight,
                child: filteredCountries.isEmpty
                    ? Center(
                        child: Text(
                          S.of(context).noCountriesFound,
                          style: StyleText.fontSize14Weight400.copyWith(
                            color: lightMode
                                ? AppColors.secondaryText
                                : AppColors.grey,
                          ),
                        ),
                      )
                    : ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(scrollbars: false),
                        child: ListView.builder(
                          itemCount: filteredCountries.length,
                          itemExtent: 36.sp,
                          itemBuilder: (BuildContext context, int index) =>
                              _row(filteredCountries[index], lightMode),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///*************************** FILE INFO ****************************///
/// Purpose: Country picker dialog for selecting country and dial code.
/// Author: Claude AI Assistant
/// Created At: 27/10/2025
/// Moved: from features/settings/.../dialogs/country_bicker.dart into
///        core/custom, because 59-custom_intl_phone_field.dart depends on it
///        and core must not import from features.

import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/helper/main_helper/countries.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/generated/l10n.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';

/// Shows a dialog to select a country with search functionality
Future<Country?> showCountryPickerDialog(BuildContext context) async {
  return await showDialog<Country?>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) => const CountryPickerDialog(),
  );
}

class CountryPickerDialog extends StatefulWidget {
  const CountryPickerDialog({super.key});

  @override
  State<CountryPickerDialog> createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<CountryPickerDialog> {
  final TextEditingController searchController = TextEditingController();
  List<Country> filteredCountries = [];

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
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredCountries = countries;
      } else {
        filteredCountries = countries.where((country) {
          return country.name.toLowerCase().contains(query) ||
              country.dialCode.contains(query) ||
              country.code.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: lightMode ? Colors.white : AppColors.chatBackground,
      child: Container(
        width: isTablet ? 500 : MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).selectCountry,
                  style: StyleText.fontSize18Weight500.copyWith(
                    color: lightMode
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: lightMode
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            SizedBox(height: 16.sp),

            // Search Field
            TextField(
              controller: searchController,
              style: StyleText.fontSize14Weight400.copyWith(
                color: lightMode
                    ? AppColors.blackButton
                    : AppColors.white,
              ),
              decoration: InputDecoration(
                hintText: S.of(context).searchCountry,
                hintStyle: StyleText.fontSize14Weight400.copyWith(
                  color: lightMode
                      ? AppColors.secondaryText
                      : AppColors.grey,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
                filled: true,
                fillColor: lightMode ? AppColors.background : AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary, width: 1),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.sp,
                  vertical: 14.sp,
                ),
              ),
            ),

            SizedBox(height: 16.sp),

            // Results count
            Text(
              '${filteredCountries.length} countries',
              style: StyleText.fontSize12Weight400.copyWith(
                color: lightMode
                    ? AppColors.secondaryText
                    : AppColors.grey,
              ),
            ),

            SizedBox(height: 8.sp),

            // Country List
            Expanded(
              child: filteredCountries.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48.sp,
                      color: lightMode
                          ? AppColors.secondaryText
                          : AppColors.grey,
                    ),
                    SizedBox(height: 16.sp),
                    Text(
                      S.of(context).noCountriesFound,
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: filteredCountries.length,
                itemBuilder: (context, index) {
                  final country = filteredCountries[index];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop(country);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.sp,
                        vertical: 12.sp,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: lightMode
                                ? Colors.grey.shade200
                                : Colors.grey.shade800,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Flag
                          Text(
                            country.flag,
                            style: TextStyle(fontSize: 24.sp),
                          ),

                          SizedBox(width: 12.sp),

                          // Country Name
                          Expanded(
                            child: Text(
                              country.name,
                              style: StyleText.fontSize14Weight500.copyWith(
                                color: lightMode
                                    ? AppColors.blackButton
                                    : AppColors.white,
                              ),
                            ),
                          ),

                          // Dial Code
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.sp,
                              vertical: 4.sp,
                            ),
                            decoration: BoxDecoration(

                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '+${country.dialCode}',
                              style: StyleText.fontSize12Weight500.copyWith(
                                color: lightMode ? AppColors.blackButton : AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
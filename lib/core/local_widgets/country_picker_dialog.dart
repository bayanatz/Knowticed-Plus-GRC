import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/phone/countries.dart';
import 'package:demo_app/core/helper/phone/helpers.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/onboarding/welcome_screen/views/mobile_view/nav_bar.dart';

class PickerDialogStyle {
  final Color? backgroundColor;

  final TextStyle? countryCodeStyle;

  final TextStyle? countryNameStyle;

  final Widget? listTileDivider;

  final EdgeInsets? listTilePadding;

  final EdgeInsets? padding;

  final Color? searchFieldCursorColor;

  final InputDecoration? searchFieldInputDecoration;

  final EdgeInsets? searchFieldPadding;

  final double? width;

  PickerDialogStyle({
    this.backgroundColor,
    this.countryCodeStyle,
    this.countryNameStyle,
    this.listTileDivider,
    this.listTilePadding,
    this.padding,
    this.searchFieldCursorColor,
    this.searchFieldInputDecoration,
    this.searchFieldPadding,
    this.width,
  });
}

class CountryPickerDialog extends StatefulWidget {
  final List<Country> countryList;
  final Country selectedCountry;
  final ValueChanged<Country> onCountryChanged;
  final String searchText;
  final List<Country> filteredCountries;
  final PickerDialogStyle? style;
  final String languageCode;

  const CountryPickerDialog({
    Key? key,
    required this.searchText,
    required this.languageCode,
    required this.countryList,
    required this.onCountryChanged,
    required this.selectedCountry,
    required this.filteredCountries,
    this.style,
  }) : super(key: key);

  @override
  _CountryPickerDialogState createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<CountryPickerDialog> {
  late List<Country> _filteredCountries;
  late Country _selectedCountry;

  @override
  void initState() {
    _selectedCountry = widget.selectedCountry;
    _filteredCountries = widget.filteredCountries.toList()
      ..sort(
        (a, b) => a
            .localizedName(widget.languageCode)
            .compareTo(b.localizedName(widget.languageCode)),
      );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final mediaWidth = MediaQuery.of(context).size.width;
    final width = widget.style?.width ?? mediaWidth;
    const defaultHorizontalPadding = 40.0;
    const defaultVerticalPadding = 24.0;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
          vertical: defaultVerticalPadding,
          horizontal: isTablet
              ? isPortrait
                  ? 0.15.w
                  : 0.3.w
              : 0.1.w),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      child: Container(
        padding: widget.style?.padding ?? const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Padding(
              padding:
                  widget.style?.searchFieldPadding ?? const EdgeInsets.all(0),
              child: TextField(
                cursorColor: widget.style?.searchFieldCursorColor,
                cursorHeight: isTablet?0.002.h:null,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize:isTablet?FontConstants.fontSize017.w :FontConstants.fontSize017.h,
                    fontWeight: FontWeight.w400,
                    height:isTablet?2.1 :1,
                  color:Theme.of(context).colorScheme.secondaryContainer,
                ),
                decoration: InputDecoration(
                  enabled: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal:isTablet?0.02.w :0.04.w,
                    vertical: 0.01.h

                  ),
                  hintText: 'Search'.tr,
                  constraints: BoxConstraints(maxHeight: 0.05.h),
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.bubbleColor,
                        width: 1.0,
                      )),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.scrim,
                        width: 1.0,
                      )),
                  fillColor: Theme.of(context).colorScheme.inversePrimary,
                  hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize:isTablet?FontConstants.fontSize017.w :FontConstants.fontSize017.h,
                    fontWeight: FontWeight.w400,
                    height:isTablet?2.1 :1.8,
                    color:
                        themeController.currentTheme == AppColors.lightTheme
                            ? Theme.of(context).colorScheme.scrim
                            : AppColors.colorWhite,
                  ),
                ),
                onChanged: (value) {
                  _filteredCountries = widget.countryList.stringSearch(value)
                    ..sort(
                      (a, b) => a
                          .localizedName(widget.languageCode)
                          .compareTo(b.localizedName(widget.languageCode)),
                    );
                  if (mounted) setState(() {});
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredCountries.length,
                itemBuilder: (ctx, index) => Column(
                  children: <Widget>[
                    ListTile(
                      leading: kIsWeb
                          ? Image.asset(
                              'assets/png_assets/flags/${_filteredCountries[index].code.toLowerCase()}.png',
                              package: 'intl_phone_field',
                              width: 32,
                            )
                          : Text(
                              _filteredCountries[index].flag,
                              style:  TextStyle(fontSize:isTablet?25 :18,
                             
                              
                              ),
                            ),
                      contentPadding: widget.style?.listTilePadding,
                      title: Text(
                        _filteredCountries[index]
                            .localizedName(widget.languageCode),
                        style:  TextStyle(
                                fontSize: FontConstants.fontSize020.h,
                                fontWeight: FontWeight.w400,
                                height: isTablet?isPortrait?2: 2.3:null,
                                color: themeController.currentTheme ==
                                        AppColors.lightTheme
                                    ? AppColors.colorBlack
                                    : AppColors.colorWhite,
                              ),
                      ),
                      trailing: Text(
                        '+${_filteredCountries[index].dialCode}',
                        style:TextStyle(
                                fontSize: FontConstants.fontSize020.h,
                                fontWeight: FontWeight.w400,
                               height: isTablet?isPortrait?2: 2.3:null,
                                color: themeController.currentTheme ==
                                        AppColors.lightTheme
                                    ? AppColors.colorBlack
                                    : AppColors.colorWhite,
                              ),
                      ),
                      onTap: () {
                        _selectedCountry = _filteredCountries[index];
                        widget.onCountryChanged(_selectedCountry);
                        Navigator.of(context).pop();
                      },
                    ),
                    widget.style?.listTileDivider ??
                        const Divider(thickness: 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

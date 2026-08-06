// ******************* FILE INFO *******************
// File Name: toogle_control.dart
// Description: Theme & localization toggle cubit (app-wide toggle control).
// Module: core / theme
// Note: relocated here from services_management_module/main_controller/
//       controller so main.dart and other modules can use it without
//       depending on the services module.
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeAndLocalizationsState {
  final ThemeMode themeMode;
  final Locale locale;

  ThemeAndLocalizationsState({
    required this.themeMode,
    required this.locale,
  });

  ThemeAndLocalizationsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return ThemeAndLocalizationsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

class ThemeAndLocalizationsCubit extends Cubit<ThemeAndLocalizationsState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  ThemeAndLocalizationsCubit()
      : super(
    ThemeAndLocalizationsState(
      themeMode: ThemeMode.dark,
      locale: const Locale('en'),
    ),
  ) {
    _loadSettings();
  }

  /// Load theme and localization from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Theme
    final themeString = prefs.getString('themeMode');
    ThemeMode themeMode = ThemeMode.dark;
    if (themeString == ThemeMode.light.toString()) {
      themeMode = ThemeMode.light;
    }

    // Load Locale
    final localeString = prefs.getString('appLocale') ?? 'en';

    final locale = Locale(localeString);

    emit(state.copyWith(themeMode: themeMode, locale: locale));
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newTheme =
    state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', newTheme.toString());

    emit(state.copyWith(themeMode: newTheme));
  }

  /// Toggle between English and Arabic
  Future<void> toggleLanguage() async {
    final newLocale = state.locale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appLocale', newLocale.languageCode);

    emit(state.copyWith(locale: newLocale));
  }
}
